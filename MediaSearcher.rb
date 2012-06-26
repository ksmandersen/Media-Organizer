require "./MediaItem.rb"
require "./Helpers.rb"
require "./CacheHandler.rb"
require "tvdb_party"

class MediaSearcher
	attr_accessor :media
	attr_accessor :cache
	
	def initialize
		self.media = Array.new
		self.cache = CacheHandler.new
	end
	
	def run!
		dir = $config[:origin_dir]
		
		# Hrmm, go give a valid dir bitch!
		if !File.exists?(dir) then
			$log.error("The origin dir does not exist. Check your input path!")
			raise
		end
		
		# Find out if there are any files to process in the input dir
		count = 0	
		exclude = [".", "..", ".DS_Store"]
		Dir.entries(dir).each do |entry|
			if !exclude.include?(entry) then
				count += 1
			end
		end
		
		# There are no files to process
		if count < 1 then
			$log.info("There are no files to match.. exiting")
			return
		end
		
		Dir.chdir(dir)
		
		# Look at every folder and file in the input dir
		Dir.glob("**/*") do |path|
			$log.debug("################################################")
			$log.debug("Search")
			$log.debug("> Path: " + path)
			
			# This is a directory, skip it
			if !File.file?(path) then
				$log.debug("> is directory.. skipping")
				next
			end
			
			# This is a file
			$log.debug("> is file..")
			
			# Make sure the file is one that is supported
			ext = File.extname(path).downcase.sub(/\./, '')
			if !$config[:extensions_supported].include?(ext) then
				$log.debug("> is non-supported extension (#{ext}).. skipping")
				next
			end
			
			$log.debug("> is supported extension (#{ext}).. matching")
			self.match(path)
			
		end
	end
	
	def match(file)
		match_p = nil
		patterns = [/s[0-9]{1,2}e[0-9]{1,3}/i, /[0-9]{1,2}x[0-9]{1,3}/, /(^|[\.\ \-\_])[0-9]{3}($|[\.\ \-\_])/]
		
		$log.debug("Match")
		
		item = MediaItem.new
		item.fullpath = file
		item.extension = File.extname(item.filename).downcase.sub(/\./, '')
		
		# Try each pattern until there is a match
		md = nil
		patterns.each do |pattern|
			md = item.filename.match(pattern)
			if md then
				$log.debug("> Matched with: " + md.to_s)
				match_p = pattern
				break
			end
		end
		
		# No match was found, carry on to next file
		if match_p == nil then
			$log.warn(file + " >> No match found")
			return
		end
		
		# This indicates wether or not this is a file that might need to be
		# cleaned up later after encoding.
		item.native = $config[:extensions_native].include?(item.extension)
		
		# Clean out all noise from the season/episode token
		token = md.to_s.downcase.gsub(/[\ \.\-\[\]\_]/, " ").strip
		
		if token.include?("s")
			item.season = token[/[0-9]+/].to_i
			item.episode = token.split('e')[1].to_i
		elsif token.include?("x")
			item.season = token[/[0-9]+/].to_i
			item.episode = token.split('x')[1].to_i
		elsif token.length == 3
			item.season = token[0].to_i
			item.episode = token[1,2].to_i
		elsif token.length == 4
			item.season = token[0,1].to_i
			item.episode = token[2,3].to_i
		else
			$log.debug("> Could not find season/episode from token.. skipping")
			return
		end
		
		if item.season.zero? or item.episode.zero?
			$log.warn(file + " >> Could not find valid season/episode (zero).. skipping")
			return
		end
		
		$log.debug("> Season: " + item.season.to_s)
		$log.debug("> Episode: " + item.episode.to_s)
		
		
		item.show = Helpers::camelcase item.filename.split(match_p)[0].gsub(/\.|\-|\[|\_/) {|a| " " }.strip
		
		if !item.show.empty?
			self.search(item)
			$log.debug("> Show: " + item.show)
			media.push item
			return
		end
		
		$log.debug("> Filename does not contain show title.. trying folder structure")
		
		# Try to infer the show title from the enclosing folders.
		# Work from the folder containing the file out to the root.
		# This is very greedy. It accepts anything that doesn't contain
		# the word season.
		#
		# Less than optimal!
		dirs = file.split('/').reverse!
		dirs[1, dirs.size-1].each do |dir|
			if !dir.downcase.include?('season')
				item.show = dir.gsub(/\.|\-|\[\_/) {|a| " " }.strip
			end
		end
		
		if item.show.empty?
			$log.warn(file + " >> Folder structure does not contain a show title.. skipping")
			return
		end
		
		self.search(item)
		
		$log.debug("> Show: " + item.show)
		media.push item
		
	end
	
	def search(item)
		begin
			# Check the cache first
			show = self.cache.get(item.show)
			
			if !show
				tvdb = TvdbParty::Search.new($config[:tvdb_api_key])
				
				$log.debug("Search TVDB for matches")
				results = tvdb.search(item.show)
			
				if results.empty?
					$log.debug("> No match found")
				end
				
				# Do a second cache check on first results show name
				show = self.cache.get(results[0]["seriesName"])
				
				if !show
					show = tvdb.get_series_by_id(results[0]["seriesid"])
					self.cache.put(show.name, show)
				end
			
			$log.debug("> Match found. Updating attributes..")
			else
				$log.debug("Cache hit!")
			end # !show
			
			episode = show.get_episode(item.season, item.episode)
			
			if !show or !episode
				$log.debug("> No match found")
			end

			
			item.show = show.name if show
			item.description = episode && episode.overview ? episode.overview.gsub(/"/, "\\\"") : ""
			item.title = episode ? episode.name : item.episode.to_s
			item.thumb_url = episode ? episode.thumb : ""
			item.year = episode ? episode.air_date.year : 0

		rescue
			$log.error(item.fullpath + " >> Failed to search TVDB")
			$log.error($!)
		end	#begin
	end	# search
end # class