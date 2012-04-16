require "fileutils"
require "handbrake"

module Actions
	class Import
		def self.run(item)
			if !$config[:do_import]
				$log.debug("> Import disabled.. skipping")
				return
			end
			
			
			if !$config[:extensions_native].include?(item.extension) and !item.encoded
				$log.debug("> Cannot tag " + item.extension + " files.. skipping")
				return
			end
			
			file = item.target + item.to_s
			$log.debug("> Import: " + file)
			
			workflow = Helpers::trailingslash($config[:lib_path]) + 'itunes_import.workflow'
			cmd = 'automator -i "' + file + '" ' + workflow
			
			begin
				command = Thread.new do
					system(cmd)
				end
				command.join
			rescue
				$log.error("> ERROR. Something went wrong while importing.. skipping")
				$log.error($!)
				raise
			end
			
			$log.debug("> Done!")
		end
	end
	
	class Tag
		def self.run(item)
			if !$config[:do_tags]
				$log.debug("> Tagging disabled.. skipping")
				return
			end
			
			if !$config[:extensions_native].include?(item.extension) and !item.encoded
				$log.debug("> Cannot tag " + item.extension + " files.. skipping")
				return
			end
			
			file = 	item.target + item.to_s
			$log.debug("> Tag: " + file)
			
			workflow = Helpers::trailingslash($config[:lib_path]) + 'add_tv_tags.workflow'
			cmd = 'automator -i "' + file + '" ' + workflow
			
			begin
				command = Thread.new do
					system(cmd)
				end
				command.join
			rescue
				$log.error("> ERROR. Something went wrong while tagging.. skipping")
				$log.error($!)
				raise
			end
			
			$log.debug("> Done!")
		end
	end
	
	class Encode
		def self.run(item)
			if !$config[:do_encode]
				$log.debug("> Encoding disabled.. skipping")
				raise
			end
			
			item.encoded = true
			
			file = item.origin + item.filename
			target = item.target + item.to_s
			
			$log.debug("> Encode: " + file)
			$log.debug("> Target: " + target)
			
			# Check if already exists
			if !File.exists?(file)
				$log.error("> Origin file doesn't exist!.. skipping")
				raise
			end
			
			# Check if the target already exists
			if File.exists?(target)
				if !$config[:do_force]
					$log.error("> Target file already exists!.. skipping")
					raise
				end
				
				# Force is with you, so remove the target
				begin
					FileUtils.rm(target)
				rescue
					$log.error("> FAILED to copy file")
					$log.error($!)
					raise
				end
			end
		
			
			begin
				# Set up the handbrake process
				hb = HandBrake::CLI.new(:bin_path => $config[:handbrake_cli], :trace => $config[:handbrake_trace])
				project = hb.input(file)
				project.preset("AppleTV 2")
				
				command = Thread.new do
					project.output(target)
				end
				command.join
			rescue
				$log.error("> Something went wrong while encoding.. skipping")
				$log.error($!)
				raise
			end
			
			$log.debug("> Done!")
		end
	end
	
	class Copy
		def self.run(item)
			file = item.origin + item.filename
			target = item.target + item.to_s
			
			$log.debug("> Copy: " + file)
			$log.debug("> Destionation: " + target)
			
			# The file we're trying to copy doesn't exist
			if !File.exists?(file)
				$log.error("> Origin file doesn't exist!.. skipping")
				raise
			end
			
			if !Dir.exists?(item.target)
				$log.debug("> Creating target directory")
				begin
					FileUtils.mkdir_p(item.target)
				rescue
					$log.error("> Failed to create target directory.. skipping")
					$log.error($!)
					raise
				end
			end
			
			# Check if the target already exists
			if File.exists?(target)
				if !$config[:do_force]
					$log.error("> Target file already exists!.. skipping")
					raise
				end
			
				# Force is with you, so remove the target
				begin
					FileUtils.rm(target)
				rescue
					$log.error("> FAILED to copy file")
					$log.error($!)
					raise
				end
			end
			
			# Copy that file now
			begin
				FileUtils.cp(file, target)
			rescue
				$log.error("> FAILED to copy file")
				$log.error($!)
				raise
			end
			
			$log.debug("> Done!")
		end
	end
	
	class Clean
		def self.run(item)
			if !$config[:do_cleanup]
				$log.debug("> Cleanup disabled.. skipping")
				return
			end
			
			file = item.origin + item.filename
			$log.debug("> Clean: " + file)
			
			if !File.exists?(file)
				$log.error("> File doesn't exist.. skipping")
				raise
			end
			
			begin
				FileUtils.rm(file)
			rescue
				$log.error("> FAILED to remove file")
				$log.error($!)
				raise
			end
			
			$log.debug("> Done!")
		end
	end
end