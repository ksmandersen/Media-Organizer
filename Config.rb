require "Logger"

$config = {
	
	########################
	##        PATHS        #
	########################
	
	# The path containing video files to be processed
	# overwritten by: -i, --input-path
	:origin_path => "/Volumes/Macintosh HD/Download/TV Shows",
	
	# The path to put the renamed and tagged videos
	# overwritten by: -o, --output-path
	:target_path => "/Volumes/Macintosh HD/TV Shows",
	
	# Where is the Handbrake CLI located?
	# overwritten by: --handbrake-cli
	:handbrake_cli => '/usr/local/bin/HandbrakeCLI',
	
	########################
	##      FEATURES       #
	########################
	
	# Wanna add some meta tags?
	# overwritten by: --skip-tags
	:do_tags => true,
	
	# Wanna import into iTunes?
	# overwritten by: --skip-import
	:do_import => true,
	
	# Wanna encode files?
	# overwritten by: --skip-encode
	:do_encode => true,
	
	########################
	##       LOGGING       #
	########################
	
	# Should Handbrake print out a verbose trace?
	:handbrake_trace => false,
	
	# How much output do you want?
	:log_level => Logger::DEBUG,
	
	#################################
	##           WARNING           ##
	## DO NOT EDIT BELOW THIS LINE ##
	#################################
	
	:lib_path => File.dirname(__FILE__) + '/lib',
	
	:extension_supported => ["mp4", "m4v", "avi", "mkv"],
	:extensions_native => ["mp4", "m4v"]	
}

# Set up logging
$log = Logger.new(STDOUT)
$log.level = $config[:log_level]

$log.formatter = proc do |severity, datetime, progname, msg|
	"#{msg}\n"
end