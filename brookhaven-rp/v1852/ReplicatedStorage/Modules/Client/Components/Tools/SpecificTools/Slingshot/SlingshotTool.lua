local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PhysicsUtil = require(ReplicatedStorage.Modules.Shared.Utils.PhysicsUtil)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "SlingshotTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self.rock = self.Instance:WaitForChild("Rock")
end

function v:StartListeningToUsage()
	self._equipJanitor:Cleanup()
	local mouse = Players.LocalPlayer:GetMouse()
	self._equipJanitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonR2 then
			Remotes.fireServerComponent(self.Instance, "Fire", mouse.Hit.Position)
		end
	end))
	self._equipJanitor:Add(Remotes.connectComponentRemote(self.Instance, "LobProjectile", function(_: Vector3)
		local clone = self.rock:Clone()
		clone.Transparency = 0
		clone.Trail.Enabled = true
		clone:FindFirstChild("WeldConstraint"):Destroy()
		clone.CFrame = CFrame.new(self.Instance.Handle.ShootAttachment.WorldPosition)
		clone.Parent = workspace
		PhysicsUtil.AutoProjectileToLocation(
			clone,
			self.Instance.Handle.ShootAttachment.WorldPosition,
			mouse.Hit.Position
		)
		Debris:AddItem(clone, 6)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { clone, self.Instance, self.Instance.Parent }
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			local raycastResult = workspace:Raycast(clone.Position, clone.AssemblyLinearVelocity * dt, raycastParams)

			if raycastResult then
				clone.CFrame = CFrame.new(raycastResult.Position)
				clone.Anchored = true
				clone.Transparency = 1
				renderSteppedConnection:Disconnect()
			end
		end)
		task.delay(6, function()
			renderSteppedConnection:Disconnect()
		end)
	end))
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:StartListeningToUsage()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self._equipJanitor:Cleanup()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v