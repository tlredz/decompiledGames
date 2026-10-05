local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local PhysicsUtil = require(ReplicatedStorage.Modules.Shared.Utils.PhysicsUtil)
local StickyBombController = require(ReplicatedStorage.Modules.Client.LiveOps.StickyBombController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local v = Component.new({
	Tag = "StickySituation",
	Extensions = { OnlyRunOnPlayerHotbar }
})
local v2 = {}
local v3 = false
local v4 = nil
local v5 = nil
local thread = nil
local heartbeatConnection = nil
local v6 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function isLocalCharacterPart(instance)
	local character = Players.LocalPlayer.Character

	if character == nil then
		return false
	end

	return instance:IsDescendantOf(character)
end

local function isLocalCharacterTouchingAnyPuddle()
	local character = Players.LocalPlayer.Character

	if character ~= nil and character:FindFirstChild("NoMotorVehicleModel") ~= nil then
		return false
	end

	for _, v7 in v2 do
		if v7.Parent == nil then
			continue
		end

		for _, v8 in v7:GetTouchingParts() do
			-- equivalent call inferred; original call site unknown
			if isLocalCharacterPart(v8) then
				return true
			end
		end
	end

	return false
end

function v:LoadOneTimeAnimations()
	if self.loadedOneTimeAnimations then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://75489579786275"
	animation.Parent = self.Instance
	self.grabAnimation = animation
	self._Janitor:Add(self.grabAnimation)
	local animation2 = Instance.new("Animation")
	animation2.AnimationId = "rbxassetid://120285909986137"
	animation2.Parent = self.Instance
	self.throwAnimation = animation2
	self._Janitor:Add(self.throwAnimation)
	self.loadedOneTimeAnimations = true
end

function v:LoadAnimation()
	self.humanoid = self.Instance.Parent.Humanoid
	self.throwAnimationTrack = self.humanoid:LoadAnimation(self.throwAnimation)
end

function v:OnHit(instance, raycastResult: RaycastResult, p: number)
	if not raycastResult then
		return
	end

	instance.Anchored = true
	local impact = instance:FindFirstChild("Impact")

	if impact and impact:IsA("Sound") then
		impact:Play()
	end

	local equipEffect = instance:FindFirstChild("EquipEffect")

	if equipEffect then
		for _, child in equipEffect:GetChildren() do
			child:Emit(3)
		end
	end

	local sticky = instance:FindFirstChild("Sticky")

	if sticky then
		Debris:AddItem(sticky, 1)
		TweenService:Create(sticky, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end

	local puddleModel = instance:FindFirstChild("PuddleModel")

	if puddleModel and puddleModel:IsA("Model") then
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		local valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			puddleModel:ScaleTo((math.max(numberValue.Value * 4, 0.01)))
		end)
		local tween = TweenService:Create(
			numberValue,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Value = 1
			}
		)
		tween.Completed:Once(function()
			valueChangedConnection:Disconnect()
			numberValue:Destroy()
		end)
		tween:Play()
		task.delay(10, function()
			if not (puddleModel and puddleModel.Parent) then
				return
			end

			for _, part in puddleModel:GetDescendants() do
				if part:IsA("BasePart") then
					TweenService:Create(part, TweenInfo.new(0.75), {
						Transparency = 1
					}):Play()
				end
			end
		end)
		local children = puddleModel:GetChildren()
		local part = children[Random.new(p):NextInteger(1, #children)]

		for _, v7 in children do
			if v7 ~= part then
				v7:Destroy()
			end
		end

		if part and part:IsA("MeshPart") then
			part.Transparency = 0
			self:RegisterPuddle(part)
		end
	end
end

function v:RegisterPuddle(p)
	table.insert(v2, p)
	local touchedConnection = p.Touched:Connect(function() end)

	if heartbeatConnection == nil then
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			self:_StepStuckWatcher()
		end)
	end

	task.delay(10, function()
		touchedConnection:Disconnect()
		local index = table.find(v2, p)

		if index ~= nil then
			table.remove(v2, index)
		end
	end)
end

function v:_StepStuckWatcher()
	if isLocalCharacterTouchingAnyPuddle() then
		if thread ~= nil then
			task.cancel(thread)
			thread = nil
		end

		if v3 or os.clock() < v6 then
			return
		end

		local character = Players.LocalPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if not (character and humanoidRootPart) then
			return
		end

		v3 = true
		v4, v5 = self:ApplyStuck(character, humanoidRootPart)
	else
		if not v3 or thread ~= nil then
			return
		end

		if v5 ~= nil then
			v5()
			v5 = nil
		end

		thread = task.delay(1, function()
			thread = nil
			v3 = false
			v6 = os.clock() + 5

			if v4 ~= nil then
				v4()
				v4 = nil
			end
		end)
	end
end

function v:ApplyStuck(instance, parent)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local track, track2, moveDirectionChangedConnection, heartbeatConnection2

	if humanoid then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://83190987575615"
		local animation2 = Instance.new("Animation")
		animation2.AnimationId = "rbxassetid://120342942698575"
		track = humanoid:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action4
		track.Looped = true
		track2 = humanoid:LoadAnimation(animation2)
		track2.Priority = Enum.AnimationPriority.Action4
		track2.Looped = true
		animation:Destroy()
		animation2:Destroy()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateMovementTrack()
			local v7 = humanoid.MoveDirection.Magnitude > 0.05
			local v8

			if v7 then
				v8 = track2
			else
				v8 = track
			end

			local v9

			if v7 then
				v9 = track
			else
				v9 = track2
			end

			if not v8.IsPlaying then
				v8:Play(0.15)
			end

			if v9.IsPlaying then
				v9:Stop(0.15)
			end
		end

		updateMovementTrack() -- equivalent call inferred; original call site unknown
		moveDirectionChangedConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(updateMovementTrack)
		humanoid.WalkSpeed = 6
		heartbeatConnection2 = RunService.Heartbeat:Connect(function()
			if humanoid.Parent and humanoid.WalkSpeed ~= 6 and humanoid.WalkSpeed ~= 0 then
				humanoid.WalkSpeed = 6
			end
		end)
	else
		moveDirectionChangedConnection = nil
		track = nil
		track2 = nil
		heartbeatConnection2 = nil
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://98219614556717"
	sound.RollOffMaxDistance = 35
	sound.PlaybackSpeed = 0.4
	sound.Parent = parent
	local thread2 = task.spawn(function()
		while true do
			sound:Play()
			task.wait(1.6)
		end
	end)
	local attachment = assert(
		ReplicatedStorage:FindFirstChild("StickySituation"),
		"ReplicatedStorage.StickySituation does not exist"
	):FindFirstChild("Attachment")
	local clone = attachment:Clone()
	clone.Parent = instance:FindFirstChild("LowerTorso")
	local clone2 = attachment:Clone()
	clone2.Parent = instance:FindFirstChild("LeftLowerLeg")
	local clone3 = attachment:Clone()
	clone3.Parent = instance:FindFirstChild("RightLowerLeg")
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		Debris:AddItem(clone, 20)
		Debris:AddItem(clone2, 20)
		Debris:AddItem(clone3, 20)

		if moveDirectionChangedConnection then
			moveDirectionChangedConnection:Disconnect()
		end

		if track then
			track:Stop(0.15)
			track:Destroy()
		end

		if track2 then
			track2:Stop(0.15)
			track2:Destroy()
		end

		if heartbeatConnection2 then
			heartbeatConnection2:Disconnect()
		end

		if humanoid and humanoid.Parent and humanoid.WalkSpeed ~= 0 then
			humanoid.WalkSpeed = 16
		end
	end, function()
		task.cancel(thread2)
		local particleEmitter = clone:FindFirstChildWhichIsA("ParticleEmitter")
		particleEmitter.Enabled = false
		local particleEmitter_2 = clone2:FindFirstChildWhichIsA("ParticleEmitter")
		particleEmitter_2.Enabled = false
		local particleEmitter_3 = clone3:FindFirstChildWhichIsA("ParticleEmitter")
		particleEmitter_3.Enabled = false
	end
end

function v:Throw()
	local throwAnimationTrack = self.throwAnimationTrack
	self._Janitor:Add(throwAnimationTrack:GetMarkerReachedSignal("Throw"):Once(function()
		local mouse = Players.LocalPlayer:GetMouse()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { self.Instance, Players.LocalPlayer.Character }
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
		local position

		if raycastResult then
			position = raycastResult.Position
		else
			position = mouse.UnitRay.Origin + mouse.UnitRay.Direction * 1000
		end

		primaryPart.ThrowSound:Play()
		Remotes.fireServerComponent(
			self.Instance,
			"Throw",
			self.Instance.Handle.CFrame.Position,
			position,
			workspace:GetServerTimeNow()
		)
		local v7 = math.random(1, 1000000)
		PhysicsUtil.NewSimulation(
			primaryPart,
			primaryPart.CFrame.Position,
			position,
			200,
			workspace:GetServerTimeNow(),
			raycastParams,
			function(raycastResult2: RaycastResult?)
				if not raycastResult2 then
					return
				end

				self:OnHit(primaryPart, raycastResult2, v7)
			end,
			10.75
		)
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
			self:LoadAnimation()
			self.hasEquippedOnce = true
		end

		if Players:GetPlayerFromCharacter(self.Instance.Parent) ~= Players.LocalPlayer then
			return
		end

		local flag = false
		self._equipJanitor:Add(instance.Activated:Connect(function()
			if flag then
				return
			end

			if StickyBombController.GetStickyBombCount() <= 0 then
				task.spawn(NotificationController.NotifyCenter, "No sticky bombs left!", 3)
				CountableDevProductController.PromptPurchase(CountableDevProducts.STICKY_SITUATION, "StickySituation")
			else
				flag = true
				self:Throw()
				task.delay(0.5, function()
					flag = false
				end)
			end
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
		function(player, vector: Vector3, vector2: Vector3, p: number, p2: number)
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
			primaryPart.ThrowSound:Play()
			PhysicsUtil.NewSimulation(
				primaryPart,
				vector,
				vector2,
				200,
				p,
				raycastParams,
				function(raycastResult: RaycastResult?)
					self:OnHit(primaryPart, raycastResult, p2)
				end,
				6
			)
		end
	))
end

function v:Stop()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v