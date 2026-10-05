local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local MarkerHandler = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local MarkerPin = require(script.Parent.MarkerPin)
require(script.Parent.Types)

local function listed()
	local result = {}

	for k, currentMarker in MarkerHandler.currentMarkers do
		if currentMarker.onMap == true and currentMarker.position ~= nil then
			table.insert(result, {
				Key = k,
				Data = currentMarker
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Key < b.Key
	end)
	local v = {}

	for _, v2 in result do
		table.insert(v, (`{v2.Key}={tostring(v2.Data.ping)}`))
	end

	return result, table.concat(v, ";")
end

return function(maid, p)
	local v, v2 = listed()
	local value = maid:Value(v)
	maid:Add(MarkerHandler.markerCount.Changed:Connect(function()
		local v3, v4 = listed()

		if v4 == v2 then
			return
		end

		v2 = v4
		value:Set(v3)
	end))
	return maid:Create("Frame")({
		Name = "Markers",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		maid:Iterate(value, function(_, p2, p3)
			return MarkerPin(p3, p, p2.Key, p2.Data)
		end)
	})
end