require "fileutils"
require "handbrake"
require "tempfile"
require "net/http"

module Actions
	class Import
		def self.run(item, mutex)
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
				mutex.synchronize {
					system(cmd)
				}
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
			
			$log.debug("> Tagging file..")
			
			file = item.target + item.to_s
			$log.debug("> Tag: " + file)
			
			tag_cmd = 'mp4tags -r AabcCdDeEgGHiIjlLmMnNoOpPBRsStTxXwyzZ --type tvshow --show "' + item.show + '" --season ' + item.season.to_s +  ' --episode ' + item.episode.to_s + ' --song "' + item.title + '" --year ' + item.year.to_s + ' --description "' + item.description + '" "' + file + '"'			
			
			begin
				system(tag_cmd)
			rescue
				$log.error("> ERROR. Failed to tag file. Search went bad.. Skipping")
				raise
			end
			
			begin
				tmpfile = Tempfile.new("thumb")
				Net::HTTP.start("thetvdb.com") { |http|
					resp = http.get(item.thumb_url)
					tmpfile.write(resp.body)
					
					art_cmd = 'mp4art --remove --add "' + tmpfile.path + '" "' + file + '"'
					system(art_cmd)
				}
			rescue
				$log.error("ERROR. Failed to art cover art")
				raise
			end
			
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
				
				project.output(target)
			rescue
				$log.error("> Something went wrong while encoding.. skipping")
				$log.error($!)
				raise
			end
			
			$log.debug("> Done!")
		end
	end
	
	class Copy
		def self.run(item, mutex)
			file = item.origin + item.filename
			target = item.target + item.to_s
			
			$log.debug("> Copy: " + file)
			$log.debug("> Destionation: " + target)
			
			# The file we're trying to copy doesn't exist
			if !File.exists?(file)
				$log.error("> Origin file doesn't exist!.. skipping")
				raise
			end
			
			mutex.synchronize {
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
			}
			
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