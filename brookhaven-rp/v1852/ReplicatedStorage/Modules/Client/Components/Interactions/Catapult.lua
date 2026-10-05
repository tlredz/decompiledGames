local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "Catapult"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(Remotes.connectComponentRemote(
		self.Instance,
		"CatapultLaunch",
		function(vector: Vector3, p2: number)
			local character = Players.LocalPlayer.Character

			if character == nil then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart == nil then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid == nil then
				return
			end

			humanoid.Sit = false
			humanoidRootPart.AssemblyLinearVelocity = vector.Unit * p2
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		end
	))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v