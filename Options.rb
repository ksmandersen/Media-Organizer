require "./Config.rb"

require "optparse"

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
	
	# Force overwrite in target dir
	opts.on("-f", "--force", "Force overwrite of video files in target dir") do |v|
		$config[:do_force] = true
	end
	
	opts.on("--dry-run", "Only match files, dont write anything") do |v|
		$config[:dry_run] = true
	end

	opts.separator ""
	opts.separator "Locations:"

	# change orgin_path
	opts.on("-i DIR", "--input-dir DIR", "Input directory for video files") do |d|
		raise "No such directory" unless File.directory?(d)
		$config[:origin_dir] = d 
	end

	# Change target_path
	opts.on("-o DIR", "--output-dir DIR", "Output directory for video files") do |d|
		raise "No such directory" unless File.directory?(d)
		$config[:target_dir] = d
	end

	# Change handbrake_cli
	opts.on("--handbrake-cli PATH", "Path to the HandbrakeCLI binary") do |f|
		raise "No such file" unless File.file?(f)
		$config[:target_path] = f
	end

	opts.separator ""
	opts.separator "Features:"

	# skip/do tags
	opts.on("--[no-]tags", "Add mp4v2 tags to video files") do |b|
		$config[:do_tags] = b
	end

	# skip/do encoding
	opts.on("--[no-]encode", "Encode video files to MPEG-4") do |b|
		$config[:do_encode] = b
	end

	# skip/do iTunes import
	opts.on("--[no-]import", "Import video files to iTunes") do |b|
		$config[:do_import] = b
	end

	# skip/do cleanup
	opts.on("--[no-]cleanup", "Delete original video files") do |b|
		$config[:do_cleanup] = b
	end

end.parse!