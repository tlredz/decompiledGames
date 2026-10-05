local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PrivateServerBuildConstants = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerBuildConstants)
local allSlotNames = PrivateServerBuildConstants.GetAllSlotNames()

local function fn(registry)
	return {
		DisplayName = "Prop build ID",
		Transform = function(p)
			return p, registry.Cmdr.Util.MakeFuzzyFinder(allSlotNames)(p)
		end,
		ValidateOnce = function(p)
			return PrivateServerBuildConstants.IsValidSlotName(p), "Unknown build"
		end,
		Autocomplete = function(_, p)
			return p
		end,
		Parse = function(p)
			return p
		end,
		Default = function(_)
			return allSlotNames[1]
		end
	}
end

return function(registry)
	registry:RegisterType("propBuild", (fn(registry)))
end