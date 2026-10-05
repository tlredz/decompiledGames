local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local Signal = require(ReplicatedStorage.Modules.Signal)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local ClientItem = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
local TrajectoryVisual = require(Players.LocalPlayer.PlayerScripts.Modules.TrajectoryVisual)
local throwables = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Throwables")
local cframe = CFrame.new(0.75, -0.5, 0)
local object = setmetatable({}, ClientItem)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientItem.new(...), object)
	self.ProjectileThrown = Signal.new()
	self._is_throwing = nil
	self._throw_type = nil
	self._throw_cooldown = 0
	self._throw_hash = 0
	self._trajectory_visual = nil
	self._cook_detonate_delay = self.Info.CanCook and self.Info.DetonateDelay
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(_)
	return nil
end

function object:CanQuickAttack()
	local v = not self._is_throwing

	if v then
		if tick() > self._throw_cooldown and (self:Get("Ammo") or 1e999) > 0 then
			return not self:IsEquipping()
		else
			return false
		end
	end

	return v
end

function object:StartShooting(p)
	if p or not (self._is_throwing or tick() < self._throw_cooldown or (self:Get("Ammo") or 1e999) <= 0 or self:IsEquipping()) then
		self._throw_type = "Throw"
		self:_StartThrow(
			"ThrowStart",
			"ThrowIdle",
			self.Info.ThrowMaxChargeTime,
			self.Info.ThrowForceMin,
			self.Info.ThrowForceMax,
			self.Info.ThrowGravity,
			"FinishShooting"
		)
		return true, "StartShooting"
	else
		return false
	end
end

function object:FinishShooting(p)
	if not p and (not self._is_throwing or tick() < self._throw_cooldown or (self:Get("Ammo") or 1e999) <= 0 or self._throw_type ~= "Throw") then
		return false
	end

	self._throw_type = nil
	local _FinishThrow, v = self:_FinishThrow("ThrowStart", "ThrowIdle", "ThrowFinish", self.Info.ThrowMaxChargeTime)

	if _FinishThrow then
		return true, "FinishShooting", self:_GetThrowCameraCFrame(), _FinishThrow, v
	end

	return false
end

function object:StartAiming(p)
	if p or not (self._is_throwing or tick() < self._throw_cooldown or (self:Get("Ammo") or 1e999) <= 0 or self:IsEquipping()) then
		self._throw_type = "Lob"
		self:_StartThrow(
			"LobStart",
			"LobIdle",
			self.Info.LobMaxChargeTime,
			self.Info.LobForceMin,
			self.Info.LobForceMax,
			self.Info.LobGravity,
			"FinishAiming"
		)
		return true, "StartAiming"
	else
		return false
	end
end

function object:FinishAiming(p)
	if not p and (not self._is_throwing or tick() < self._throw_cooldown or (self:Get("Ammo") or 1e999) <= 0 or self._throw_type ~= "Lob") then
		return false
	end

	self._throw_type = nil
	local _FinishThrow, v = self:_FinishThrow("LobStart", "LobIdle", "LobFinish", self.Info.LobMaxChargeTime)

	if _FinishThrow then
		return true, "FinishAiming", self:_GetThrowCameraCFrame(), _FinishThrow, v
	end

	return false
end

function object:Unequip(...)
	self:_CancelThrow()
	ClientItem.Unequip(self, ...)
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "ThrowEffect" then
		ClientItem.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	local v = ...

	if not v then
		return
	end

	v.Transparency = 1
	v.CanCollide = false
	local clone = (throwables:FindFirstChild(object2.ViewModel.Name) or throwables[object2.Name]):Clone()
	clone.WorldPivot = clone.Primary.CFrame
	clone.Parent = workspace
	BetterDebris:AddItem(clone, object2.Info.Lifetime + 10)
	WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), object2:GetWrap(), true)

	for _, child in pairs(clone:GetChildren()) do
		child.CanCollide = false
		child.CanTouch = false
		child.CanQuery = false
		child.Anchored = true
	end

	object2.ProjectileThrown:Fire(v, clone)
	task.defer(function()
		local isActuallyFirstPerson = object2.ClientFighter:IsActuallyFirstPerson()
		local v2 = Spring.new(
			v.Position + (isActuallyFirstPerson and -v.Velocity.Unit * 200 or createVector(0, 0, 0)),
			1,
			40
		)
		local cframe2 = CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		local lastTime = tick()
		local total = 0
		local v3 = 0
		local cframe3 = nil
		local throwableOrientation = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update_throwable_orientation()
			throwableOrientation = v:GetAttribute("ThrowableOrientation")
		end

		v:GetAttributeChangedSignal("ThrowableOrientation"):Connect(update_throwable_orientation)
		update_throwable_orientation() -- equivalent call inferred; original call site unknown

		while v:IsDescendantOf(workspace) do
			local v4 = math.clamp((tick() - lastTime) * 1.5, 0.01, 1)
			v2.Speed = v4 * 60 + 40
			v2.Target = v.Position - workspace.CurrentCamera.CFrame.UpVector * (1 - v4) * 0.5
			total += v.Velocity.Magnitude * v3 * 0.25
			cframe3 = v.Velocity.Magnitude > 0.01 and CFrame.new(v2.Position, v2.Position + v.Velocity) or CFrame.new(v2.Position) * (cframe3 and cframe3.Rotation or CFrame.identity)
			local v5 = cframe3 * cframe2 * CFrame.Angles(-total, 0, 0)

			if throwableOrientation then
				v5 = CFrame.new(v5.Position) * throwableOrientation.Rotation
			end

			if object2.ViewModel.Name == "Skullbang" and not v5.Position:FuzzyEq(workspace.CurrentCamera.CFrame.Position) then
				v5 = v5:Lerp(
					CFrame.new(v5.Position, workspace.CurrentCamera.CFrame.Position),
					(math.min(1, 1.25 * (tick() - lastTime) / object2.Info.DetonateDelay))
				)
			end

			clone:ScaleTo(v4 * 1.5)
			clone:PivotTo(v5)
			v3 = RunService.RenderStepped:Wait()
		end

		local v4 = 0

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("BasePart") or descendant:IsA("Texture") or descendant:IsA("Beam") or descendant:IsA("Decal") then
				descendant.LocalTransparencyModifier = 1
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("Trail") then
				v4 = math.max(v4, descendant.Lifetime)
			end
		end

		BetterDebris:AddItem(clone, v4)
	end)
end

function object:Destroy()
	self.ProjectileThrown:Destroy()
	self:_ClearTrajectoryVisual()
	ClientItem.Destroy(self)
end

function object:_CancelThrow()
	self:_ClearTrajectoryVisual()

	if self._is_throwing then
		self._throw_type = nil
		self._is_throwing = nil
		self._throw_hash += 1
	end

	self.ViewModel:StopAnimation("ThrowStart")
	self.ViewModel:StopAnimation("ThrowIdle")
	self.ViewModel:StopAnimation("ThrowFinish")
	self.ViewModel:StopAnimation("LobStart")
	self.ViewModel:StopAnimation("LobIdle")
	self.ViewModel:StopAnimation("LobFinish", nil, 0)
end

function object:_FinishThrow(p, p2, p3, p4)
	self:_ClearTrajectoryVisual()
	local v = self._is_throwing and math.clamp((tick() - self._is_throwing) / p4, 0, 1)
	local v2 = self._is_throwing and (self._cook_detonate_delay and self._is_throwing + (self._cook_detonate_delay or 0) - tick() or self.Info.DetonateDelay)
	self._is_throwing = nil
	self._throw_cooldown = not self.Info.Cooldown and 0 or tick() + self.Info.Cooldown or 0
	self._throw_hash += 1
	self.ViewModel:StopAnimation(p, nil, 0)
	self.ViewModel:StopAnimation(p2, nil, 0)

	if not self._cook_detonate_delay or not v2 or v2 > 0 then
		self.ViewModel:PlayAnimation(p3, AnimationLibrary.Info[self.ViewModel.Info.Animations[p3]].Length)
	end

	if self.Info.Cooldown then
		self:CooldownEffect("rbxassetid://17156089790", self.Info.Cooldown, "Throw")
	end

	return v, v2
end

function object:_StartThrow(p, p2, p3, p4, p5, p6, p7)
	self._is_throwing = tick()
	self._throw_hash += 1
	self.ViewModel:StopAnimation("Equip")
	self.ViewModel:PlayAnimation(p, 1e999)

	if self.ClientFighter.IsLocalPlayer then
		self:_CreateTractoryVisual(p3, p4, p5, p6)
	end

	local _throw_hash = self._throw_hash
	task.spawn(function()
		wait(AnimationLibrary.Info[self.ViewModel.Info.Animations[p]].Length or 0.1)

		if _throw_hash ~= self._throw_hash then
			return
		end

		self.ViewModel:PlayAnimation(p2, nil, 0)
	end)

	if self._cook_detonate_delay then
		task.delay(self._cook_detonate_delay, function()
			if _throw_hash ~= self._throw_hash then
				return
			end

			self:SimulateInputFromGameplayMechanic(p7, true)
		end)
	end
end

function object:_GetThrowCameraCFrame(p2, p3, p4)
	local cameraData = self.ClientFighter:GetCameraData(p2, p3, true)
	local v = cameraData[utf8.char(0)]
	local cframe2 = cameraData[utf8.char(1)]
	local v2 = cameraData[utf8.char(2)]
	local v3 = cameraData[utf8.char(3)]
	local v4 = v2 and v2.CFrame * (v3 or CFrame.identity)

	if v4 then
		cframe2 = CFrame.new(cframe2.Position, v4.Position) or cframe2
	end

	local raycastResult = Utility:Raycast(
		cframe2.Position,
		cframe2.Position + cframe2.LookVector * 999,
		999,
		p2,
		Enum.RaycastFilterType.Include
	)
	local v5 = CFrame.new(v.Position, raycastResult.Position) * cframe

	if p4 then
		return v5
	end

	return (Utility:EncodeCFrame(v5))
end

function object:_ClearTrajectoryVisual()
	if self._trajectory_visual then
		self._trajectory_visual:Destroy()
		self._trajectory_visual = nil
	end
end

function object:_CreateTractoryVisual(p, p2, p3, p4)
	self:_ClearTrajectoryVisual()
	local raycastWhitelist = self.ClientFighter:GetRaycastWhitelist(true)
	self._trajectory_visual = TrajectoryVisual.new()
	self._trajectory_visual:OnStep(function()
		local _GetThrowCameraCFrame = self:_GetThrowCameraCFrame(raycastWhitelist, nil, true)
		local v = math.clamp((tick() - (self._is_throwing or self._is_lobbing)) / p, 0, 1)
		local v2 = p2 + (p3 - p2) * v
		local v3

		if self._cook_detonate_delay then
			v3 = self._is_throwing + self._cook_detonate_delay - tick()
		else
			v3 = self.Info.DetonateDelay
		end

		self._trajectory_visual:Update(
			_GetThrowCameraCFrame.Position,
			_GetThrowCameraCFrame.LookVector * v2,
			workspace.Gravity * 0.5 * p4,
			nil,
			raycastWhitelist,
			v3
		)
	end)
end

function object:_Init()
	table.insert(self._connections, self.ClientFighter.Interrupted:Connect(function()
		self:_CancelThrow()
	end))
end

return object