local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local TimeTrialController = require(ReplicatedStorage.client.legacyControllers.TimeTrialController)
local v = Component.new({
	Tag = "TimeTrial/StartZone",
	Ancestors = { Workspace },
	Extensions = nil
})

function v:Construct()
	self.Trove = Trove.new()
end

function v:Tick(_)
	if not self.Active then
		return
	end

	if localPlayer.Character and not TimeTrialController.ActiveTrialName and localPlayer:DistanceFromCharacter(self.Instance.Position) < self.Instance.Size.X / 2 then
		TimeTrialController:StartTrial(self.Instance.Parent.Name)
	end
end

function v:Start()
	if not self.Instance then
		return
	end

	self.Active = true
	self.Trove:Connect(RunService.Heartbeat, function()
		self:Tick()
	end)
end

function v:Stop()
	self.Active = false
	self.Trove:Clean()
end

return v