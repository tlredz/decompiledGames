local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "DoNotPressButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(Remotes.connectComponentRemote(
		self.Instance,
		"DoNotPressLaunch",
		function(vector: Vector3, p2: number, p3: number)
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

			local gravity = workspace.Gravity
			local v2 = vector - humanoidRootPart.Position
			humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
				v2.X / p2 * p3,
				(v2.Y + 0.5 * gravity * p2 * p2) / p2,
				v2.Z / p2 * p3
			)
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		end
	))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v