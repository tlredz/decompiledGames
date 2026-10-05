local createVector = vector.create
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local TimeTrialController = require(ReplicatedStorage.client.legacyControllers.TimeTrialController)
local GliderController = require(ReplicatedStorage.client.legacyControllers.Items.GliderController)
local v = Component.new({
	Tag = "TimeTrial/EndZone",
	Ancestors = { Workspace },
	Extensions = nil
})

function v:Construct()
	self.Trove = Trove.new()
end

function v:OnTouched(p2)
	if not self.Active then
		return
	end

	if localPlayer.Character and p2.Parent == localPlayer.Character then
		local requireSection = self.Instance:GetAttribute("RequireSection")

		if requireSection and not TimeTrialController:IsSectionLoaded(requireSection) then
			return
		end

		TimeTrialController:EndTrial(self.Instance.Parent.Name, true)
		GliderController:UnequipGlider()
		local humanoidRootPart = p2.Parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		end
	end
end

function v:Start()
	if not self.Instance then
		return
	end

	self.Active = true
	self.Trove:Connect(self.Instance.Touched, function(p)
		self:OnTouched(p)
	end)
end

function v:Stop()
	self.Active = false
	self.Trove:Clean()
end

return v