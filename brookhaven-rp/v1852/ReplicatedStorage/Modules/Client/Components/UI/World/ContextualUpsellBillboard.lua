local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ContextualUpsellBillboard"
})
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local v2, v3 = ABTest.GetExperimentVariables("map-gamepass-icon"):timeout(7):await()

	if v2 then
		local iconEnabled = v3.iconEnabled
		p.Instance.Visible = iconEnabled
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v