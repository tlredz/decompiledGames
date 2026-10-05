local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local ShrinePin = require(script.Parent.ShrinePin)
require(script.Parent.Types)

local function shrinesOf()
	local Regions = require(ReplicatedStorage.Regions)
	local result = {}

	for _, region in Regions.Regions do
		for _, v in region.Shrines or {} do
			if not (typeof(v.Name) == "string" and typeof(v.At) == "CFrame") then
				continue
			end

			table.insert(result, {
				Name = v.Name,
				Position = v.At.Position
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Name < b.Name
	end)
	return result
end

return function(object, p, p2)
	local value = object:Value({})
	object:Spawn(function()
		Archives.WaitLoaded()
		value:Set((shrinesOf()))
	end)
	return object:Create("Frame")({
		Name = "Shrines",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Iterate(value, function(_, p3, p4)
			return ShrinePin(p4, p, p3, p2)
		end)
	})
end