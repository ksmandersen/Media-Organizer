#require "digest/md5"

class CacheHandler
	attr_accessor :shows
		
	def initialize
		self.shows = Hash.new
	end
	
	def get(key)
		self.shows[key]
	end
	
	def put(key, value)
		self.shows[key] = value
	end
	
	private
	
	# def write
	# 	self.shows.each do |show|
	# 		File.open("./cache/info/" . Digest::MD5.hexdigest(show.name), "w+") do |file|
	# 			Marshal.dump(show)
	# 		end
	# 	end
	# end
	# 
	# def read
	# 	File.chdir("./cache/info")
	# 	File.glob("*") do |path|
	# 		File.open(path, "r") do |file|
	# 			Marshal.load(file)
	# 		end
	# 	end
	# end
end