local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("RunService")
return {
	init = function()
		ContentProvider:PreloadAsync((CollectionService:GetTagged("preload")))
	end
}