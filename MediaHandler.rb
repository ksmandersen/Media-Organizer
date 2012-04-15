require "./Actions.rb"

class MediaHandler
	
	def process(media)
		if media.empty?
			$log.debug("Nothing to process.. exiting")
			return
		end
		
		media.each do |item|
			begin
				if item.native
					Actions::Copy.run(item)
				else
					Actions::Encode.run(item)
				end
				
				Actions::Tag.run(item)
				Actions::Import.run(item)
				Actions::Clean.run(item)
			rescue 
				next
			end
		end
	end
	
end