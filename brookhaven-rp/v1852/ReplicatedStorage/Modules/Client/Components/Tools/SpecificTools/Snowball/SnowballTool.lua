local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
require(ReplicatedStorage.Packages.t)
local v = Component.new({
	Tag = "SnowballTool"
})
local PhysicsUtil = require(ReplicatedStorage.Modules.Shared.Utils.PhysicsUtil)
local VisualEffectsUtil = require(ReplicatedStorage.Modules.Shared.Utils.VisualEffectsUtil)

function v:LoadOneTimeAnimations()
	if self.loadedOneTimeAnimations then
		return
	end

	local animation = Instance.new("Animation")
	animation.Parent = self.Instance
	animation.AnimationId = "rbxassetid://75489579786275"
	self.grabAnimation = animation
	self._Janitor:Add(self.grabAnimation)
	local animation2 = Instance.new("Animation")
	animation2.Parent = self.Instance
	animation2.AnimationId = "rbxassetid://120285909986137"
	self.throwAnimation = animation2
	self._Janitor:Add(self.throwAnimation)
	self.loadedOneTimeAnimations = true
end

function v:LoadAnimation()
	self.humanoid = self.Instance.Parent.Humanoid
	local track = self.humanoid:LoadAnimation(self.grabAnimation)
	track:Play()
	self.throwAnimationTrack = self.humanoid:LoadAnimation(self.throwAnimation)
	self._Janitor:Add(track:GetMarkerReachedSignal("HasPickedUp"):Connect(function()
		self.Instance.Handle.Transparency = 0
		self.Instance.Handle.Scoop:Play()
		local snowEquipEffect = self.Instance.Handle.SnowEquipEffect
		VisualEffectsUtil.ForParticles(snowEquipEffect, function(object)
			object:Emit(3)
		end)
		self.hasEquippedOnce = true
	end))
	self._Janitor:Add(track.Ended:Once(function()
		track:Destroy()
	end))
end

function v:ThrowSnowball()
	local throwAnimationTrack = self.throwAnimationTrack
	self._Janitor:Add(throwAnimationTrack:GetMarkerReachedSignal("Throw"):Once(function()
		local mouse = Players.LocalPlayer:GetMouse()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { self.Instance, game.Players.LocalPlayer.Character }
		raycastParams.RespectCanCollide = true
		raycastParams.CollisionGroup = "Default"
		local clone = self.Instance.Projectile:Clone()
		clone.Trail.Enabled = true
		clone.WeldConstraint:Destroy()
		clone.Parent = workspace
		local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)

		if raycastResult then
			Remotes.fireServerComponent(
				self.Instance,
				"SnowballThrow",
				self.Instance.Handle.CFrame.Position,
				raycastResult.Position,
				workspace:GetServerTimeNow()
			)
			PhysicsUtil.NewSimulation(
				clone,
				clone.CFrame.Position,
				raycastResult.Position,
				200,
				workspace:GetServerTimeNow(),
				raycastParams,
				function(_: RaycastResult?, _: Vector3)
					clone.Impact:Play()
					clone.Anchored = true

					for _, child in clone.SnowEquipEffect:GetChildren() do
						child:Emit(3)
					end
				end
			)
		else
			Remotes.fireServerComponent(
				self.Instance,
				"SnowballThrow",
				self.Instance.Handle.CFrame.Position,
				mouse.UnitRay.Origin + mouse.UnitRay.Direction * 1000,
				workspace:GetServerTimeNow()
			)
			PhysicsUtil.NewSimulation(
				clone,
				clone.CFrame.Position,
				mouse.UnitRay.Origin + mouse.UnitRay.Direction * 1000,
				200,
				workspace:GetServerTimeNow(),
				raycastParams,
				function(raycastResult2: RaycastResult?, _: Vector3)
					clone.Impact:Play()
					clone.Anchored = true
					clone.CFrame = CFrame.new(raycastResult2.Position)

					for _, child in clone.SnowEquipEffect:GetChildren() do
						child:Emit(3)
					end
				end
			)
		end
	end))
	throwAnimationTrack:Play()
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:LoadOneTimeAnimations()

		if not self.hasEquippedOnce then
			self.Instance.Handle.Transparency = 1
			self:LoadAnimation()
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(self.Instance.Parent)

		if playerFromCharacter ~= Players.LocalPlayer then
			return
		end

		self.owningPlayer = playerFromCharacter
		local flag = false
		self._equipJanitor:Add(instance.Activated:Connect(function()
			if playerFromCharacter ~= Players.LocalPlayer or flag then
				return
			end

			flag = true
			self:ThrowSnowball()
			task.delay(0.5, function()
				flag = false
			end)
		end))
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self._equipJanitor:Cleanup()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(
		self.Instance,
		"SnowballThrown",
		function(player, vector: Vector3, vector2: Vector3, p: number)
			local clone = self.Instance.Projectile:Clone()
			clone.Trail.Enabled = true
			clone.WeldConstraint:Destroy()
			clone.Parent = workspace
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { self.Instance, player.Character }
			raycastParams.RespectCanCollide = true
			raycastParams.CollisionGroup = "Default"
			PhysicsUtil.NewSimulation(
				clone,
				vector,
				vector2,
				200,
				p,
				raycastParams,
				function(_: RaycastResult?, _: Vector3)
					clone.Impact:Play()
					clone.Anchored = true

					for _, child in clone.SnowEquipEffect:GetChildren() do
						child:Emit(3)
					end
				end
			)
		end
	))
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v