require "./Config.rb"
require "./Options.rb"
require "./MediaSearcher.rb"
require "./MediaHandler.rb"

# Let the magic begin!
begin
	$log.debug("=============== SEARCH FOR FILES ===============")
	
	searcher = MediaSearcher.new
	searcher.run!
	
	$log.debug("=============== PROCESS THE FILES ===============")
	
	handler = MediaHandler.new
	handler.process(searcher.media)
	
	$log.debug("=============== ALL DONE ===============")

rescue
	$log.error("Something went wrong.. Aborting")
	$log.debug($!)
	raise
end