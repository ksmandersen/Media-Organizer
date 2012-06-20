require "Logger"

$config = {
	
	########################
	##        PATHS        #
	########################
	
	# The path containing video files to be processed
	# overwritten by: -i, --input-path
	:origin_dir => "/Volumes/Media/Download/Shows",
	
	# The path to put the renamed and tagged videos
	# overwritten by: -o, --output-path
	:target_dir => "/Volumes/Media/Shows",
	
	# Where is the Handbrake CLI located?
	# overwritten by: --handbrake-cli
	:handbrake_cli => '/usr/local/bin/HandbrakeCLI',
	
	########################
	##      FEATURES       #
	########################
	
	# Wanna add some meta tags?
	# overwritten by: --[no-]tags
	:do_tags => true,
	
	# Wanna import into iTunes?
	# overwritten by: --[no-]import
	:do_import => true,
	
	# Wanna encode files?
	# overwritten by: --[no-]encode
	:do_encode => true,
	
	# Wanna delete the original files after import?
	# overwritten by: --[no-]cleanup
	:do_cleanup => false,
	
	# Force a overwrite in target directory?
	# overwritten by: -f, --force
	:do_force => false,
	
	########################
	##      API KEYS       #
	########################
	
	# Used for looking up correct show titles
	# fan art and etc.
	:tvdb_api_key => "YOUR-API-KEY",
	
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
	
	:extensions_supported => ["mp4", "m4v", "avi", "mkv"],
	:extensions_native => ["mp4", "m4v"]	
}

# Set up logging
$log = Logger.new(STDOUT)
$log.level = $config[:log_level]

$log.formatter = proc do |severity, datetime, progname, msg|
	"#{msg}\n"
end