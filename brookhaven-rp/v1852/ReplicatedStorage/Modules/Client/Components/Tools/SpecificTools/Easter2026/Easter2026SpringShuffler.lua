local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local PhysicsUtil = require(ReplicatedStorage.Modules.Shared.Utils.PhysicsUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local Easter2026Controller = require(ReplicatedStorage.Modules.Client.LiveOps.Easter2026Controller)
local v = Component.new({
	Tag = "Easter2026SpringShuffler",
	Extensions = { OnlyRunOnPlayerHotbar }
})
local v2 = {
	{
		Id = 128802399883482,
		Repeat = true,
		Filter = "Dance",
		Name = "Dance 15"
	},
	{
		Id = 76524571498092,
		Repeat = true,
		Filter = "Dance",
		Name = "Dance 7"
	},
	{
		Id = 120576623712766,
		Repeat = true,
		Filter = "Dance",
		Name = "Dance 12"
	}
}

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
	self.throwAnimationTrack = self.humanoid:LoadAnimation(self.throwAnimation)
end

function v:OnHit(state, raycastResult: RaycastResult)
	if not raycastResult then
		return
	end

	state.Impact:Play()
	state.Anchored = true

	for _, child in state.EquipEffect:GetChildren() do
		child:Emit(3)
	end

	for _, child in state.Flash:GetChildren() do
		child.Enabled = true
	end

	for _, child in state.Stars:GetChildren() do
		child.Enabled = true
	end

	state.ProjectileModel.ProjectilePart.Anchored = true
	state.ProjectileModel.ProjectilePart:WaitForChild("WeldConstraint"):Destroy()
	state.ProjectileModel.ProjectileBase.Anchored = true
	state.ProjectileModel.ProjectileBase:WaitForChild("WeldConstraint"):Destroy()
	TweenService:Create(state.ProjectileModel.ProjectilePart, TweenInfo.new(5), {
		Rotation = createVector(0, 1800, 0)
	}):Play()
	TweenService:Create(state.ProjectileModel.ProjectileBase, TweenInfo.new(5), {
		Rotation = createVector(0, 1800, 0)
	}):Play()
	local projectileModel = state.ProjectileModel
	local floor = state.Flash:WaitForChild("Floor")
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local cframe = CFrame.new(raycastResult.Position)
	local valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		projectileModel:ScaleTo(numberValue.Value * 2 + 1)
		projectileModel:PivotTo(cframe * CFrame.new((Vector3.new(0, numberValue.Value * 13, 0))))
		floor.Size = NumberSequence.new(numberValue.Value * 10)
	end)
	local tween = TweenService:Create(numberValue, TweenInfo.new(1), {
		Value = 1
	})
	tween.Completed:Once(function()
		valueChangedConnection:Disconnect()
		numberValue:Destroy()
	end)
	tween:Play()
	task.delay(5, function()
		TweenService:Create(projectileModel.ProjectilePart, TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()
		TweenService:Create(projectileModel.ProjectileBase, TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()

		for _, child in state.Flash:GetChildren() do
			child.Enabled = false
		end

		for _, child in state.Stars:GetChildren() do
			child.Enabled = false
		end
	end)
	self:TriggerAnimation(raycastResult.Position, state.Music)
	local pointLight = state.Flash:FindFirstChild("PointLight")

	if pointLight then
		TweenService:Create(pointLight, TweenInfo.new(1), {
			Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		}):Play()
		TweenService:Create(pointLight, TweenInfo.new(1), {
			Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		}):Play()
		TweenService:Create(pointLight, TweenInfo.new(1), {
			Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		}):Play()
	end
end

function v:Throw()
	local throwAnimationTrack = self.throwAnimationTrack
	self._Janitor:Add(throwAnimationTrack:GetMarkerReachedSignal("Throw"):Once(function()
		local mouse = Players.LocalPlayer:GetMouse()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { self.Instance, game.Players.LocalPlayer.Character }
		raycastParams.RespectCanCollide = true
		raycastParams.CollisionGroup = "Default"
		local clone = self.Instance.ProjectileModel:Clone()
		clone:ScaleTo(1)
		local primaryPart = clone.PrimaryPart
		primaryPart.Trail.Enabled = true
		primaryPart.WeldConstraint:Destroy()
		primaryPart.Parent = workspace
		clone:Destroy()
		local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)

		if raycastResult then
			Remotes.fireServerComponent(
				self.Instance,
				"Throw",
				self.Instance.Handle.CFrame.Position,
				raycastResult.Position,
				workspace:GetServerTimeNow()
			)
			PhysicsUtil.NewSimulation(
				primaryPart,
				primaryPart.CFrame.Position,
				raycastResult.Position,
				200,
				workspace:GetServerTimeNow(),
				raycastParams,
				function(raycastResult2: RaycastResult?, _: Vector3)
					if not raycastResult2 then
						return
					end

					self:OnHit(primaryPart, raycastResult2)
				end,
				6
			)
		else
			Remotes.fireServerComponent(
				self.Instance,
				"Throw",
				self.Instance.Handle.CFrame.Position,
				mouse.UnitRay.Origin + mouse.UnitRay.Direction * 1000,
				workspace:GetServerTimeNow()
			)
			PhysicsUtil.NewSimulation(
				primaryPart,
				primaryPart.CFrame.Position,
				mouse.UnitRay.Origin + mouse.UnitRay.Direction * 1000,
				200,
				workspace:GetServerTimeNow(),
				raycastParams,
				function(raycastResult2: RaycastResult?, _: Vector3)
					if not raycastResult2 then
						return
					end

					self:OnHit(primaryPart, raycastResult2)
				end,
				6
			)
		end
	end))
	throwAnimationTrack:Play()
end

function v:TriggerAnimation(vector2: Vector3, object)
	local humanoidRootPart = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local magnitude = (humanoidRootPart.Position - vector2).Magnitude

	if magnitude == nil or magnitude >= 15 then
		return
	end

	if object and object.IsLoaded then
		object.TimePosition = 10
		object:Play()
	end

	local v3 = v2[math.random(1, #v2)]
	local v4 = EmotesController.PlayEmote(v3, false, 0, true)

	if v4 then
		task.delay(5, function()
			if v4.IsPlaying then
				EmotesController.StopEmote()
			end

			TweenService:Create(object, TweenInfo.new(0.5), {
				Volume = 0
			}):Play()
		end)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:LoadOneTimeAnimations()

		if not self.hasEquippedOnce then
			self:LoadAnimation()
			self.hasEquippedOnce = true
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

			if Easter2026Controller.SpringShufflerCounter == 0 then
				NotificationController.NotifyCenter("Out of shufflers! You'll need to wait until next event!")
				return
			end

			flag = true
			self:Throw()
			task.delay(0.5, function()
				flag = false
			end)
		end))
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self._equipJanitor:Cleanup()
	end))
end

function v:Start()
	self._Janitor:Add(Remotes.connectComponentRemote(
		self.Instance,
		"Thrown",
		function(player, vector2: Vector3, vector3: Vector3, p: number)
			local clone = self.Instance.ProjectileModel:Clone()
			clone:ScaleTo(1)
			local primaryPart = clone.PrimaryPart
			primaryPart.Trail.Enabled = true
			primaryPart.WeldConstraint:Destroy()
			primaryPart.Parent = workspace
			clone:Destroy()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { self.Instance, player.Character }
			raycastParams.RespectCanCollide = true
			raycastParams.CollisionGroup = "Default"
			PhysicsUtil.NewSimulation(
				primaryPart,
				vector2,
				vector3,
				200,
				p,
				raycastParams,
				function(raycastResult: RaycastResult?, _: Vector3)
					self:OnHit(primaryPart, raycastResult)
				end
			)
		end
	))
end

function v:Stop()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v