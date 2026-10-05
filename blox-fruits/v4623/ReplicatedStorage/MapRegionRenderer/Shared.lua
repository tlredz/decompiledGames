local Constants = require(script.Parent.Constants)
local CollectionService = game:GetService("CollectionService")
return {
	GetAllObjects = function()
		local result = {}

		for _, v in CollectionService:GetTagged(Constants.TAG_PROPERTY) do
			table.insert(result, v)
		end

		for _, v in CollectionService:GetTagged(Constants.TAG_OPTIMIZED) do
			table.insert(result, v)
		end

		return result
	end
}