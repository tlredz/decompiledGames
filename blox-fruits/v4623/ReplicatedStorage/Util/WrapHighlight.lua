local WrapHighlightService = require(game.ReplicatedStorage.WrapHighlightService)
return function(p)
	while WrapHighlightService:GetIfInitialized() == false do
		task.wait()
	end

	return WrapHighlightService:TryWrap(p)
end