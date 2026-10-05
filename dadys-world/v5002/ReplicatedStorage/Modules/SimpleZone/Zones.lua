local RunService = game:GetService("RunService")
local _ = script.Parent
local Zones = {
	ActiveZones = {},
	TotalZoneVolume = 0
}

function Zones.registerZone(p, p2)
	Zones.ActiveZones[p] = p2
end

function Zones.deregisterZone(p)
	Zones.ActiveZones[p] = nil
end

RunService.PostSimulation:Connect(function(_)
	for k, activeZone in Zones.ActiveZones do
		local queryOptions = activeZone.QueryOptions

		if queryOptions.ThrottlingEnabled then
			local now = os.clock()

			if now - k._lastUpdate < queryOptions.UpdateInterval then
				continue
			else
				k._lastUpdate = now
			end
		end

		local v

		if queryOptions.FireMode == "OnEnter" or queryOptions.FireMode == "Both" then
			v = queryOptions.FireMode ~= "None"
		else
			v = false
		end

		local v2

		if queryOptions.FireMode == "OnExit" or queryOptions.FireMode == "Both" then
			v2 = queryOptions.FireMode ~= "None"
		else
			v2 = false
		end

		if queryOptions.InSeperateQuerySpace then
			local _worldModel = k._worldModel
			local dynamic = k._querySpace.dynamic
			local cFrames = table.create(#dynamic.replicas)

			for k2, v3 in dynamic.index do
				cFrames[k2] = v3.CFrame
			end

			_worldModel:BulkMoveTo(dynamic.replicas, cFrames, Enum.BulkMoveMode.FireCFrameChanged)
		end

		k:Update(activeZone.QueryParams, v, v2)
	end
end)
return Zones