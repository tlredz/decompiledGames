local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.Modules
local Network = require(modules.Network)
return {
	FilterText = function(_, p)
		local success, result = pcall(function()
			return Network:invoke("FilterText", p)
		end)

		if success and typeof(result) == "string" then
			return result
		end

		return false
	end
}