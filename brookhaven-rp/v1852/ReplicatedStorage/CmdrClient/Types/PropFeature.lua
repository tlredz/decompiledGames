local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Props = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Props)
local v = {}

for _, entry in Props.Entries do
	local requirementBehaviorData = entry.RequirementBehaviorData

	if requirementBehaviorData then
		v[requirementBehaviorData.Behavior] = true
	elseif entry.Item then
		v[entry.Item] = true
	end
end

local v2 = {}

for k in v do
	table.insert(v2, k)
end

local function fn(registry)
	return {
		DisplayName = "Feature Name",
		Transform = function(p)
			return p, registry.Cmdr.Util.MakeFuzzyFinder(v2)(p)
		end,
		ValidateOnce = function(p)
			return table.find(v2, p) ~= nil, "No feature with that name could be found."
		end,
		Autocomplete = function(_, p)
			return p
		end,
		Parse = function(p)
			return p
		end,
		Default = function(_)
			return v2[1]
		end
	}
end

return function(registry)
	registry:RegisterType("propFeature", (fn(registry)))
end