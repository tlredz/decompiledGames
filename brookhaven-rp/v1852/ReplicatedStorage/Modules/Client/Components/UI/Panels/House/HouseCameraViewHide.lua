local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseCameraViewHide"
})
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local v2, v3 = ABTest.GetExperimentVariables("house-cameras-rework"):timeout(5):await()

	if not (v2 and v3.cameraEnabled) then
		return
	end

	local houseCam = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler"):WaitForChild("HouseCam")
	self._Janitor:Add(houseCam:GetPropertyChangedSignal("Visible"):Connect(function()
		local visible = houseCam.Visible

		for _, descendant in self.Instance:GetDescendants() do
			if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
				continue
			end

			descendant.Transparency = visible and 1 or 0
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v