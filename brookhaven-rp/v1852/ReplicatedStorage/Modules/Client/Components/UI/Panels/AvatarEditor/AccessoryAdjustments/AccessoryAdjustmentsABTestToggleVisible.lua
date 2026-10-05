local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "AccessoryAdjustmentsABTestToggleVisible"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local v2, v3 = ABTest.GetExperimentVariables("accessory-adjustments"):timeout(7):await()

	if v2 then
		p.Instance.Visible = v3.enabled
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v