local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Grinding"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._point = nil
end

function v:GetPoint()
	return self._point
end

function v:SetPoint(point: CFrame)
	self._point = point
end

function v:Stop()
	self._Janitor:Destroy()
end

return v