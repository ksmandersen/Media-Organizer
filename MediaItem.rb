require "./Config"
require "./Helpers"

# Encapsulation class for a media item
# (or rather a video file)
class MediaItem
	attr_accessor :show, :season, :episode
	attr_accessor :fullpath, :extension
	attr_accessor :extension_original
	attr_accessor :description, :title, :thumb_url, :year
	
	# Flags for processing
	attr_accessor :copied, :encoded, :tagged, :cleaned, :imported
	
	# Is the video file of a native extension?
	# Native extensions are expressed in the
	# configuration file.
	attr_accessor :native
	
	
	def initialize
		self.native = false
		self.copied = false
		self.encoded = false
		self.tagged = false
		self.cleaned = false
		self.imported = false
	end
	
	# Is the media item valid?
	# A media item must have a show title,
	# season number and episode number.
	def valid?
		return !(self.show.empty? or self.season.zero? or self.episode.zero?)
	end
	
	# The output filename of the media item
	def to_s
		ext = (self.encoded) ? 'm4v' : self.extension
		return self.show + ' - S' + Helpers::leadingzero(self.season) + 'E' + Helpers::leadingzero(self.episode) + '.' + ext
	end
	
	# What is the original filename?
	#
	# Example:
	# /origin/some/path/some file.avi
	def filename
		return self.fullpath.split('/').last
	end
	
	# Where did the file come from?
	#
	# Example:
	# /origin/some/path/
	def origin
		# Split the full path of the video file by /
		# and then exclude the last part (whic is the filename)
		# and join the path back together
		paths = self.fullpath.split('/')
		if paths.length > 1 then
			res = Helpers::trailingslash(Helpers::trailingslash($config[:origin_dir]) + paths.slice(0, paths.length - 1).join('/'))
		else
			res = Helpers::trailingslash($config[:origin_dir])
		end
		return res
	end
	
	# Where should the processed file go?
	#
	# Example:
	# /target/How I Met Your Mother/Season 1/
	def target
		return Helpers::trailingslash($config[:target_dir]) + Helpers::trailingslash(self.show) + Helpers::trailingslash("Season " + self.season.to_s)
	end
end