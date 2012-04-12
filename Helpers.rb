# A module of various helper methods
# used throughout the code.
module Helpers
	
	# Reformats a string to have the first character of every
	# word in uppercase
	#
	# Example:
	# how i met your mother			->		How I Met Your Mother
	def self.camelcase(str)
		return str.gsub(/^[a-z]|\s+[a-z]/) { |a| a.upcase }
	end
	
	# Adds a leading zero to a number less than 10 and
	# returns it as a string.
	#
	# Example:
	# 4		->		04
	# 14	->		14
	def self.leadingzero(num)
		if num < 10
			return "0" + num.to_s
		else
			num.to_s
		end
	end
	
	# Adds a trailing slas to a string such as a path.
	#
	# Example:
	# /var/www			->		/var/www/
	# /var/www/			->		/var/www/
	def self.trailingslash(str)
		#return str.gsub /[^\/]$/, '\1/'
		#return str << '/' if str[-1].chr != '/'
		return str.gsub(/^(.*[^\/])$/, '\1/')
	end

end