local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "FaceListABT"
})
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local v2, v3 = ABTest.GetExperimentVariables("lazy-loading-lists", "face-list"):timeout(3):await()
	local v4

	if v2 then
		v4 = v3["face-list"] or false
	else
		v4 = false
	end

	if v4 then
		p.Instance:AddTag("FaceList")
	else
		p.Instance:AddTag("FaceListStandard")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v