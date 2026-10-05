local Arc = require(script.Parent:WaitForChild("Arc"))
local Beacon = require(script.Parent:WaitForChild("Beacon"))
local ArcWithBeacon = {}
ArcWithBeacon.__index = ArcWithBeacon
setmetatable(ArcWithBeacon, Arc)

function ArcWithBeacon.new()
	local self = setmetatable(Arc.new(), ArcWithBeacon)
	self.Beacon = Beacon.new()
	self:Hide()
	return self
end

function ArcWithBeacon.Update(p, cframe: CFrame)
	local v, v2 = Arc.Update(p, cframe)
	local beacon = p.Beacon

	if v then
		beacon:Update(CFrame.new(v2) * CFrame.new(0, 0.001, 0), v)
		return v, v2
	end

	beacon:Hide()
	return v, v2
end

function ArcWithBeacon.Hide(p)
	Arc.Hide(p)
	p.Beacon:Hide()
end

function ArcWithBeacon.Destroy(p)
	Arc.Destroy(p)
	p.Beacon:Destroy()
end

return ArcWithBeacon