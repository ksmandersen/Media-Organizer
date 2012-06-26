require "./Config.rb"
require "./Options.rb"
require "./MediaSearcher.rb"
require "./MediaHandler.rb"

# Let the magic begin!
begin
	$log.debug("=============== SEARCH FOR FILES ===============")
	
	searcher = MediaSearcher.new
	searcher.run!
	
	if !$config[:dry_run]
		
		$log.debug("=============== PROCESS THE FILES ===============")	
		
		handler = MediaHandler.new
		handler.process(searcher.media)
		
		$log.debug("=============== ALL DONE ===============")
	end

rescue
	$log.error("Something went wrong.. Aborting")
	$log.debug($!)
	raise
end