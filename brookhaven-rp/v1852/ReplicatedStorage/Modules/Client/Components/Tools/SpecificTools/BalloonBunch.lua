local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "BalloonBunch",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = self._Janitor:Add(Janitor.new())
end

function v:Start()
	local function activate()
		local localPlayer = game.Players.LocalPlayer
		local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")

		if not self.Instance:IsDescendantOf(localPlayer.Character) or localPlayer.Character.Humanoid.Sit then
			self._equipJanitor:Cleanup()
			return
		end

		local vectorForce = Instance.new("VectorForce")
		vectorForce.Name = "LowGravity"
		vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
		vectorForce.Attachment0 = humanoidRootPart:WaitForChild("RootAttachment")
		vectorForce.Force = Vector3.new(0, humanoidRootPart.AssemblyMass * (workspace.Gravity * 0.75), 0)
		vectorForce.Parent = humanoidRootPart
		self._equipJanitor:Add(vectorForce)
	end

	self._Janitor:Add(self.Instance.Equipped:Connect(activate))
	self._Janitor:Add(self.Instance.Unequipped:Connect(activate))
	self._Janitor:Add(game.Players.LocalPlayer.Character.Humanoid.Seated:Connect(activate))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v