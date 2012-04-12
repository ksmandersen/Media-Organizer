require "./Config"
require "./Helpers"
require "./MediaItem"

require "fileutils"
require "handbrake"
require "optparse"
require "pathname"

$season_regexp = /(s[0-9]+e[0-9]+)|([0-9]+x[0-9]+)/i

class MediaSorter
	attr_accessor :media
	
	def initialize
		self.media = Array.new
	end
	
	def search
		Dir.chdir($config[:origin_path])
		Dir.glob("**/*") do |path|
			# Houston we have a file!
			if File.file?(path) then
				$log.debug("File Found: " + path)
				
				item = MediaItem.new
				
				# Set the full path for the file
				item.fullpath = path
				
				# Infer the extension from the path
				item.extension = File.extname(item.filename).sub(/\./, '')
				item.extension_original = item.extension
				
				# Search for well formated episode filenames.
				# ----------
				# Currently matches:
				# How.I.Met.Your.Mother.S01E04.garbage.m4v
				# How I Met Your Mother S01E04 garbage.m4v
				# How I Met Your Mother 01x04 garbage.m4v
				# How I Met Your Mother - S01E04 garbage.m4v
				# How I Met Your Mother - [1x04] garbage.m4v
				if $config[:extension_supported].include?(item.extension) and item.filename.match($season_regexp) then
					$log.debug("File passes extension and regex test")
					
					# Split the filename into 3 parts
					# ----------
					# The leader with the showtitle: How.I.Met.Your.Mother
					# The season and episode part: S01E04 or 01x04
					# The title, lang, extension and other garbage
					parts = item.filename.split($season_regexp)
					
					# Format the show name properly
					# ----------
					# Throw away all . and - and make them into spaces
					# Then trim the title and camelcase it
					item.show = Helpers::camelcase parts[0].gsub(/\.|\-|\[/) {|a| " " }.strip
					
					
					# Attempt to infer the showname from the enclosing folder
					# ----------
					# Currently works for:
					# How I Met Your Mother/
					# How I Met Your Mother/Season 1/
					paths = item.fullpath.split /\//
					
					if item.show.empty? and paths.length > 1 then
						p = paths[paths.length - 2]
						# If the current folder is a season folder then go further
						if p.downcase.match(/season/) && paths.length > 2 then
							p = paths[paths.length - 3]
						end
						
						# Make sure that we haven't backed into the outbox folder
						if !$config[:origin_path].split(/\//).include?(p) and !p.downcase.match(/season/) then
							item.show = Helpers::camelcase p.gsub(/\.|\-|\[/) {|a| " " }.strip
						end
					end
					
					# Find the season number from the S01 or 01x part
					item.season = parts[1][/[0-9]+/].to_i
					
					# Find the episodenubmer from the E04 or x04 part
					item.episode = parts[1].split(/e|x/i)[1].to_i
					
					# Add the item to the queue of items
					# but only if it's valid.
					if item.valid? then
						$log.debug("File parsed as: " + item.to_s)
						$log.debug("File is valid tv show... Adding to queue")
						self.media.push item
					else
						$log.debug("File is not a tv show.. Skipping")
					end
				end # extesion and regex test
				
			end # file?
		end # do path
	end # search
	
	def move_item(item)
		# Create the folder structure if it doesn't exist
		if !File.exists?(item.target) then
			$log.debug("Creating folder structure")
			FileUtils.mkdir_p item.target
		end
		
		if item.native? then
			# Move the damn file!
			$log.debug("Moving the video file to target dir")
			FileUtils.mv item.origin + item.filename, item.target + item.to_s
		else
			# If the item has be encoded then
			# delete the original
			$log.debug("Deleting original video file")
			FileUtils.rm item.origin + item.filename
		end
	end # move_item
	
	def tag_item(item)
		file = item.target + item.to_s
		workflow = Helpers::trailingslash($config[:lib_path]) + 'add_tv_tags.workflow'
		cmd = 'automator -i "' + file + '" ' + workflow
		
		$log.debug("Tagging item from TheTVDB")
		
		command = Thread.new do
			system(cmd)
		end
		command.join
		
		$log.debug("Tagging complete")
		
	end #tag_item
	
	def import_item(item)
		file = item.target + item.to_s
		workflow = Helpers::trailingslash($config[:lib_path]) + 'itunes_import.workflow'
		cmd = 'automator -i "' + file + '" ' + workflow
		
		$log.debug("Importing video into iTunes")
		
		command = Thread.new do
			system(cmd)
		end
		command.join
		
		$log.debug("Import complete")
	end # import_item
	
	
	def encode_item(item)
		# Set up the handbrake process
		hb = HandBrake::CLI.new(:bin_path => $config[:handbrake_cli], :trace => $config[:handbrake_trace])
		project = hb.input(item.origin + item.filename)
		project.preset("AppleTV 2")

		item.extension = "m4v"
		
		$log.debug("Encoding video to m4v")
		
		command = Thread.new do
			project.output(item.target + item.to_s)
		end
		command.join
		
		$log.debug("Encoding process complete")
	end # encode_item
	
	def process
		# Just quit if no media has been found
		if self.media.empty? then
			$log.debug("Nothing to do.. exiting")
			exit
		end
		
		# Process each item
		self.media.each do |item|
			# Encode
			if $config[:do_encode] and !item.native? then
				self.encode_item item
			end
			
			# Move
			self.move_item item
			
			# Tag
			if $config[:do_tags] and $config[:extensions_native].include?(item.extension) then
				self.tag_item item
			end
			
			# Import
			if $config[:do_import] and $config[:extensions_native].include?(item.extension) then
				self.import_item item
			end
		end # queue.each
		
		$log.debug("Nothing more to do.. exiting")
	end # process
end

OptionParser.accept(Pathname) do |pn|
	begin
		Pathname.new(pn) if pn
		raise "No such directory" unless File.directory?(pn)
	rescue ArgumentError
		raise OptionParser::InvalidArgument, s
	end
end

# Parse command line arguments
OptionParser.new do |opts|
	opts.banner = "Usage: Run.sh [options]"
	
	# This displays the help screen, all programs are
	# assumed to have this option.
	opts.on( '-h', '--help', 'Display this screen' ) do
		puts opts
		exit
	end
	
	# Verbose output. Changes log level to debug
	opts.on("-v", "--verbose", "Run verbosely") do |v|
		$config[:log_level] = Logger::DEBUG
	end
	
	opts.separator ""
	opts.separator "Paths:"
	
	# change orgin_path
	opts.on("-i PATH", "--input-path PATH", "Input directory for video files") do |d|
		puts d
		$config[:origin_path] = d 
	end
	
	# Change target_path
	opts.on("-o PATH", "--output-path PATH", "Output directory for video files") do |d|
		$config[:target_path] = d
	end
	
	# Change handbrake_cli
	opts.on("--handbrake-cli PATH", "Path to the HandbrakeCLI binary") do |d|
		$config[:target_path] = d
	end
	
	opts.separator ""
	opts.separator "Features:"
	
	# Skip tags
	opts.on("--skip-tags", "Don't add mp4v2 tags to video files") do
		$config[:do_tags] = false
	end
	
	# Skip import
	opts.on("--skip-import", "Don't import video files to iTunes") do
		$config[:do_import] = false
	end
	
	# Skip tags
	opts.on("--skip-encode", "Don't encode video files") do
		$config[:do_encode] = false
	end
		
end.parse!

# Let the magic begin!
sorter = MediaSorter.new
sorter.search
sorter.process