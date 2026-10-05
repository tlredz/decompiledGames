local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PhysicsUtil = require(ReplicatedStorage.Modules.Shared.Utils.PhysicsUtil)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = false
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v2 = Component.new({
	Tag = "BowTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v2:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	v = v or require(ReplicatedStorage.Modules.Shared.Components.Triggers.GunHitReceiver)
	self.FakeArrow = self.Instance:WaitForChild("FakeArrow")
end

function v2:StartListeningToUsage()
	self._equipJanitor:Cleanup()
	local mouse = Players.LocalPlayer:GetMouse()
	local v3 = false
	local instance = self.Instance
	self._equipJanitor:Add(instance.Activated:Connect(function()
		if not v3 then
			v3 = true
			task.delay(0.5, function()
				v3 = false
			end)
			Remotes.fireServerComponent(self.Instance, "Fire", mouse.Hit.Position)
		end
	end))
	self._equipJanitor:Add(Remotes.connectComponentRemote(self.Instance, "LobProjectile", function(vector2: Vector3)
		local clone = self.FakeArrow:Clone()
		clone.AssemblyLinearVelocity = createVector(0, 0, 0)
		clone.Transparency = 0
		clone.Massless = true
		clone.Trail.Enabled = true
		clone:FindFirstChild("WeldConstraint"):Destroy()
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.CFrame = CFrame.new(self.Instance.Handle.ShootAttachment.WorldPosition)
		clone.Parent = workspace
		clone:AddTag("BowArrowProjectile")
		Debris:AddItem(clone, 10)

		if (vector2 - self.Instance.Handle.ShootAttachment.WorldPosition).Magnitude > 200 then
			local unit = (vector2 - self.Instance.Handle.ShootAttachment.WorldPosition).Unit
			vector2 = self.Instance.Handle.ShootAttachment.WorldPosition + unit * 200
		end

		PhysicsUtil.AutoProjectileToLocation(clone, self.Instance.Handle.ShootAttachment.WorldPosition, vector2)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.CollisionGroup = "PCollision"
		raycastParams.FilterDescendantsInstances = {
			clone,
			self.Instance,
			self.Instance.Parent,
			workspace.Vehicles
		}
		local renderSteppedConnection = nil
		local v4 = false
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			local raycastResult = workspace:Raycast(
				clone.Position,
				clone.AssemblyLinearVelocity * dt * 2,
				raycastParams
			)

			if raycastResult and not v4 then
				v4 = true
				local component = ComponentUtil.FindComponentByAncestor(raycastResult.Instance, "GunHitReceiver", v)

				if component then
					local playerFromCharacter = Players:GetPlayerFromCharacter(self.Instance.Parent)

					if playerFromCharacter and playerFromCharacter:IsA("Player") then
						v.OnPlayerShot(component, playerFromCharacter, raycastResult.Position)
					end
				end

				local clone2 = clone:Clone()
				clone2.AssemblyLinearVelocity = createVector(0, 0, 0)
				clone2.AssemblyAngularVelocity = createVector(0, 0, 0)
				clone2.Massless = true
				clone2.Anchored = false
				clone2.CFrame = CFrame.new(
					raycastResult.Position,
					raycastResult.Position + clone.AssemblyLinearVelocity
				)
				clone2:RemoveTag("BowArrowProjectile")
				clone2:RemoveTag("OrientPartToVelocity")
				clone2.Trail.Enabled = false
				clone2.Parent = workspace
				clone.Transparency = 1
				clone.Anchored = true
				Debris:AddItem(clone2, 10)
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Parent = clone2
				weldConstraint.Part0 = clone2
				weldConstraint.Part1 = raycastResult.Instance
				weldConstraint.Enabled = true
				local destroyingConnection = raycastResult.Instance.Destroying:Once(function()
					clone2:Destroy()
				end)
				clone2.Destroying:Once(function()
					destroyingConnection:Disconnect()
				end)
				renderSteppedConnection:Disconnect()
			end
		end)
		task.delay(6, function()
			renderSteppedConnection:Disconnect()
		end)
	end))
end

function v2:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:StartListeningToUsage()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self._equipJanitor:Cleanup()
	end))
end

function v2:Stop()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v2