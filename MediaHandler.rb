require "./Actions.rb"
require "./lib/threadpool/lib/threadpool.rb"
require "thread"

class MediaHandler
	
	def process(media)
		if media.empty?
			$log.debug("Nothing to process.. exiting")
			return
		end
		
		pool = ThreadPool.new(4)
		mutex = Mutex.new
		
		media.each do |item|
			pool.process {
				begin
					if item.native
						Actions::Copy.run(item, mutex)
					else
						Actions::Encode.run(item)
					end
					
					Actions::Tag.run(item)
					Actions::Import.run(item, mutex)
					Actions::Clean.run(item)
				rescue
					$log.error($!)
					next
				end	
			}
		end
		
		pool.join
		return
	end
	
end