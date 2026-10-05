local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local ClientItem = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
local TracerEffect = require(Players.LocalPlayer.PlayerScripts.Modules.TracerEffect)
local projectiles = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Projectiles")
local object = setmetatable({}, ClientItem)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientItem.new(...), object)
	self.Shot = Signal.new()
	self.ProjectileShot = Signal.new()
	self.ToggleAimEnabled = true
	self.Data.IsAiming = false
	self._last_shot = 0
	self._burst_count = 0
	self._shoot_cooldown = 0
	self._is_revolver_quick_shooting = nil
	self._shoot_animation_num = 1
	self._last_shoot_animation_name = nil
	self._shoot_cooldown_no_ammo = 0
	self._on_shoot_callback = nil
	self._shot_but_ammo_hasnt_updated = false
	self._reload_threads = {}
	self._reload_cooldown = 0
	self._reload_cancel_cooldown = 0
	self._reload_cancel_expiration = 0
	self._reload_delay = 0
	self._local_tracers = {}
	self._on_reload_callback = nil
	self._projectile_part_to_model = {}
	self._is_input_queueing = false
	self._camera_displacement_spring = Spring.new(Vector2.zero, 1, 25)
	self._shoot_animation_name_prefix = nil
	self._num_shooting_animations = nil
	self:_Init()
	return self
end

function object:CanQuickAttack()
	return tick() > self._shoot_cooldown and self:Get("Ammo") > 0 and not self:IsEquipping()
end

function object.GetAutoShootReactionTime(p)
	if p.Info.BurstCount > 1 then
		return (p.Info.BurstCooldown * p.Info.BurstCount) ^ 2
	end

	return p.Info.ShootCooldown ^ 2
end

function object.GetAimSpeed(object2)
	return object2:Get("IsAiming") and object2.Info.AimSpeed or 1
end

function object:IsFullyAiming()
	return self:Get("IsAiming") and (not self.Info.AimScopePercent or self.ViewModel.CurrentAimValue >= self.Info.AimScopePercent)
end

function object:ChangeShootAnimationNamePrefix(shoot_animation_name_prefix)
	self._shoot_animation_name_prefix = shoot_animation_name_prefix
	self._num_shooting_animations = #self.ViewModel:GetAnimationKeys(self._shoot_animation_name_prefix)
	self._shoot_animation_num = self._num_shooting_animations == 0 and 0 or math.clamp(
		self._shoot_animation_num,
		1,
		self._num_shooting_animations
	)
end

function object:StartShooting(p, p2)
	if tick() < (self._is_revolver_quick_shooting or 0) and not p2 then
		return false
	end

	local ammo = self:Get("Ammo")

	if not p then
		if tick() < self._shoot_cooldown_no_ammo or self:IsEquipping() then
			return false
		end

		if tick() < self._reload_cooldown and (tick() < self._reload_cancel_cooldown or ammo <= 0 or tick() >= self._reload_cancel_expiration) then
			return false
		end

		if self.Info.MaxAmmo and ammo <= 0 and tick() > self._reload_delay then
			local v = { self:StartReloading() }

			if v[1] then
				return table.unpack(v)
			end

			self._shoot_cooldown_no_ammo = tick() + math.max(0.1, self.Info.ShootCooldown)
			self:CreateSound("rbxassetid://13087319223", 1, 1, true, 5)
			return false
		elseif tick() < self._shoot_cooldown then
			if not self._is_input_queueing and not self.Info.InputSpammingEnabled.StartShooting and self._shoot_cooldown - tick() < 0.1 then
				self._is_input_queueing = true
				task.delay(self._shoot_cooldown - tick(), function()
					self._is_input_queueing = false
					self.ClientFighter:Input("StartShooting")
				end)
			end

			return false
		elseif self.Name == "Minigun" and (self.ViewModel.IsWindingMinigun or not self.ViewModel.IsChargingMinigun) then
			task.defer(self.ViewModel.StartChargingMinigun, self.ViewModel)
			return false
		end
	end

	if p2 then
		self._is_revolver_quick_shooting = tick() + self.Info.QuickShotCooldown * self.Info.MaxAmmo
	end

	self.ViewModel:StopAnimation("Equip")
	self.ViewModel:StopAnimation("EquipEmpty")
	self:_ResetReloadState()
	self._burst_count = tick() - self._last_shot >= self.Info.ShootCooldown and 0 or self._burst_count
	self._burst_count = self._burst_count % self.Info.BurstCount + 1
	self._last_shot = tick()
	local isFullyAiming = self:IsFullyAiming()
	local v = ammo + (p and 1 or 0)
	local quickShotCooldown = p2 and self.Info.QuickShotCooldown or self._burst_count < self.Info.BurstCount and self.Info.BurstCooldown or self.Info.ShootCooldown
	self._shoot_cooldown = tick() + quickShotCooldown

	if self._num_shooting_animations > 0 then
		local last_shoot_animation_name

		if p2 and self.ViewModel.Info.Animations.FinalQuickShot and v == 1 then
			last_shoot_animation_name = "FinalQuickShot"
		elseif p2 then
			last_shoot_animation_name = "QuickShot"
		elseif self.ViewModel.Info.Animations.FinalShoot and v == 1 then
			last_shoot_animation_name = "FinalShoot"
		elseif self.ViewModel.Info.Animations.ShootAiming and isFullyAiming then
			last_shoot_animation_name = "ShootAiming"
		else
			last_shoot_animation_name = self._shoot_animation_name_prefix .. self._shoot_animation_num
		end

		self._shoot_animation_num = self._num_shooting_animations == 0 and 0 or self._shoot_animation_num % self._num_shooting_animations + 1

		if self._last_shoot_animation_name then
			self.ViewModel:StopAnimation(self._last_shoot_animation_name)
		end

		self._last_shoot_animation_name = last_shoot_animation_name
		self.ViewModel:PlayAnimation(last_shoot_animation_name, quickShotCooldown, 0)
	end

	local cameraData = self.ClientFighter:GetCameraData()

	if self._on_shoot_callback then
		self._on_shoot_callback(cameraData)
	end

	self:_Recoil(isFullyAiming and 0.5 or 1)
	self.ViewModel:MuzzleFlash()

	if v < 1e999 and v <= self.Info.MaxAmmo * 0.25 then
		self:CreateSound("rbxassetid://13087319223", 1, 1, true, 5)
	end

	if self.ClientFighter.IsLocalPlayer and self.Info.IsRaycast and not self.Info.DisableTracerEffects then
		self:_LocalTracers(isFullyAiming, p2)
	end

	if self.Info.AimScopePercent or self.Name == "Shotgun" then
		task.defer(self.Input, self, "FinishAiming")
		self.ToggleOffMobileInputButton:Fire("mobile_aim")
	end

	self._shot_but_ammo_hasnt_updated = true
	self.Shot:Fire()

	if self.ClientFighter:Get("IsSpectating") then
		self._camera_displacement_spring.Value = Vector2.new(
			0.017453292519943295,
			math.sign(math.random() - 0.5) * 0.017453292519943295
		) * (isFullyAiming and self.Info.ShootCameraDisplacementRecoilWhileAiming or self.Info.ShootCameraDisplacementRecoil)
		self:_StartCameraDisplacementLoop()
	end

	if not isFullyAiming then
		if p2 then
			isFullyAiming = false
		else
			isFullyAiming = nil
		end
	end

	return true, "StartShooting", cameraData, isFullyAiming, p2
end

function object:StartReloading(p, p2, p3, p4)
	local ammo = self:Get("Ammo")
	local ammoReserve = self:Get("AmmoReserve")

	if self._shot_but_ammo_hasnt_updated then
		ammo = math.max(0, ammo - 1)
	end

	if not self.Info.ReloadType then
		return false
	end

	if not p and (tick() < self._reload_cooldown or self:IsEquipping() or not self.ClientFighter:Get("InfiniteAmmoReserve") and ammoReserve and ammoReserve <= 0) then
		return false
	end

	if self.Info.MaxAmmo <= ammo then
		return false
	end

	task.defer(self.Input, self, "FinishAiming")
	self.ToggleOffMobileInputButton:Fire("mobile_aim")
	self.ViewModel:StopAnimation("Equip")
	self.ViewModel:StopAnimation("EquipEmpty")

	if self._last_shoot_animation_name then
		self.ViewModel:StopAnimation(self._last_shoot_animation_name, 0)
	end

	self._is_revolver_quick_shooting = nil
	self._shoot_animation_num = 1
	self:_ResetReloadState()

	if self._on_reload_callback then
		self._on_reload_callback()
	end

	local v = ammo == 0
	local v2 = p2 and self:FromEnum(p2) or v and self.Info.NumEmptyReloadFiles > 0 and "EmptyReload" or "Reload"
	local v3 = self:Get("NumReloadsSoFar") % self.Info.NumReloadFiles + 1
	local v4 = self.Info.ReloadFiles[v2][v3]
	local v5 = p3 and self:FromEnum(p3) or v and self.ViewModel.Animator:HasEmptyReloadAnimations() and "EmptyReload" or v3 == 1 and "Reload" or "Reload" .. v3 or "Reload"

	if self.Info.ReloadType == "Regular" then
		local length = v4.Length
		local actionTimestamp = v4.ActionTimestamp
		self._reload_cooldown = tick() + length
		self._reload_cancel_expiration = tick() + v4.ActionTimestamp
		self._reload_cancel_cooldown = tick() + (not v and 0.25 or length)
		table.insert(self._reload_threads, task.spawn(function()
			self:CooldownEffect("rbxassetid://17139961241", actionTimestamp, "Reload", true)
			wait(actionTimestamp)
			self:CooldownEffect("rbxassetid://17156089790", length - actionTimestamp, "Reload")
		end))
		table.insert(self._reload_threads, task.spawn(function()
			self.ViewModel:PlayAnimation(v5, length, self.ViewModel.ShouldPlayReloadAnimationInstantly and 0 or 0.1)
		end))
	else
		if self.Info.ReloadType ~= "Segmented" then
			return false
		end

		local startLength = v4.StartLength
		local startActionTimestamp = v4.StartActionTimestamp
		local segmentLength = v4.SegmentLength
		local segmentActionTimestamp = v4.SegmentActionTimestamp
		local finishLength = v4.FinishLength
		local finishActionTimestamp = v4.FinishActionTimestamp
		local v6

		if p4 then
			v6 = utf8.codepoint(p4)
		else
			v6 = math.min(
				(self.ClientFighter:Get("InfiniteAmmoReserve") or not ammoReserve) and 1e999 or ammoReserve,
				self.Info.MaxAmmo - ammo
			) - (startActionTimestamp and 1 or 0) - (finishActionTimestamp and 1 or 0)
		end

		local v7 = startLength + segmentLength * v6 + finishLength
		local reload_cancel_cooldown = startActionTimestamp or startLength + segmentActionTimestamp
		self._reload_cooldown = tick() + v7
		self._reload_cancel_expiration = 1e999

		if not v then
			reload_cancel_cooldown = tick() + 0.25
		end

		self._reload_cancel_cooldown = reload_cancel_cooldown
		table.insert(self._reload_threads, task.spawn(function()
			if startActionTimestamp then
				self:CooldownEffect("rbxassetid://17139961241", startActionTimestamp, "Reload", true)
			end

			wait(startLength)

			for _ = 1, v6 do
				self:CooldownEffect("rbxassetid://17139961241", segmentActionTimestamp, "Reload", true)
				wait(segmentLength)
			end

			if finishActionTimestamp then
				self:CooldownEffect("rbxassetid://17139961241", finishActionTimestamp, "Reload", true)
			end
		end))
		table.insert(self._reload_threads, task.spawn(function()
			local length = AnimationLibrary.Info[self.ViewModel.Info.Animations[v5 .. "Start"]].Length
			local length2 = AnimationLibrary.Info[self.ViewModel.Info.Animations[v5 .. "Segment"]].Length
			local length3 = AnimationLibrary.Info[self.ViewModel.Info.Animations[v5 .. "Finish"]].Length
			self.ViewModel:PlayAnimation(
				v5 .. "Start",
				length,
				self.ViewModel.ShouldPlayReloadAnimationInstantly and 0 or 0.1
			)
			wait(length)

			for _ = 1, v6 do
				self.ViewModel:PlayAnimation(v5 .. "Segment", length2, 0)
				wait(length2)
			end

			if self.ViewModel.Info.Animations[v5 .. "SegmentFinal"] then
				self.ViewModel:PlayAnimation(v5 .. "SegmentFinal", length2, 0)
				wait(AnimationLibrary.Info[self.ViewModel.Info.Animations[v5 .. "SegmentFinal"]].Length)
			end

			self.ViewModel:PlayAnimation(v5 .. "Finish", length3, 0)
		end))
	end

	return true, "StartReloading", self:ToEnum(v2), self:ToEnum(v5)
end

function object:StartAiming(p)
	if not p and (self:Get("IsAiming") or tick() < self._reload_cooldown or self:IsEquipping()) then
		return false
	end

	self:SetReplicate("IsAiming", true)
	self.StopSprinting:Fire()
	self.ViewModel:SetAiming(true)
	self:SetReplicate("FOVOffset", self.Info.AimFOVOffset)
	self:_StartAimAssist()

	if self.ClientFighter:Get("IsSpectating") then
		self:CreateSound("rbxassetid://13949557885", 1, 1, true, 5)

		if self.ViewModel.PlayAimSound then
			self.ViewModel:PlayAimSound(true)
		end
	end

	if self.Info.AimScopePercent then
		self.ViewModel:StopAnimation(self.ViewModel.Animator:GetInspectAnimationKey())
		self.ViewModel:StopAnimation(self.ViewModel.Animator:GetRareInspectAnimationKey())
	end

	return true, "StartAiming"
end

function object:FinishAiming(_)
	if not self:Get("IsAiming") then
		return false
	end

	self:_FinishAiming()
	self.AttemptToSprintAgain:Fire()

	if self.ClientFighter:Get("IsSpectating") then
		self:CreateSound("rbxassetid://13949557844", 1, 1, true, 5)

		if self.ViewModel.PlayAimSound then
			self.ViewModel:PlayAimSound(false)
		end
	end

	return true, "FinishAiming"
end

function object.StartSprinting(object2, _)
	object2:SimulateInputFromGameplayMechanic("FinishAiming", true)
	return false
end

function object:Equip(...)
	ClientItem.Equip(self, ...)
	self._is_revolver_quick_shooting = nil
	self._shoot_cooldown = self._shoot_cooldown and self._shoot_cooldown >= 1e999 and 0 or self._shoot_cooldown
	self:_ResetReloadState()
end

function object:Unequip(...)
	self._is_revolver_quick_shooting = nil
	self._shoot_cooldown = self._shoot_cooldown and self._shoot_cooldown >= 1e999 and 0 or self._shoot_cooldown
	self:_ResetReloadState()
	self:_FinishAiming()
	ClientItem.Unequip(self, ...)
end

function object.Update(data, ...)
	ClientItem.Update(data, ...)

	if data.ItemInterface then
		local aimScopePercent = data.Info.AimScopePercent

		if aimScopePercent then
			if data.ViewModel.CurrentAimValue >= data.Info.AimScopePercent then
				aimScopePercent = data.ClientFighter:IsActuallyFirstPerson()
			else
				aimScopePercent = false
			end
		end

		if data.ItemInterface:IsScopeActive() or not aimScopePercent then
			if data.ItemInterface:IsScopeActive() and not aimScopePercent then
				data.ItemInterface:SetScopeActive(false)
			end
		else
			data.ItemInterface:SetScopeActive(true)
		end
	end
end

function object:ReplicateFromServer(p, ...)
	if p == "ShootEffect" then
		if not self:IsRendered() then
			return
		end

		self:_ShootEffect(...)
	elseif p == "ProjectileEffect" then
		if not self:IsRendered() then
			return
		end

		self:_ProjectileEffect(...)
	else
		if p ~= "ResetReloadState" then
			ClientItem.ReplicateFromServer(self, p, ...)
			return
		end

		if not self:IsRendered() then
			return
		end

		self:_ResetReloadState()
	end
end

function object:Destroy()
	self.Shot:Destroy()
	self.ProjectileShot:Destroy()
	self:_ResetReloadState()
	self:_FinishAiming()

	for _, v in pairs(self._projectile_part_to_model) do
		v:Destroy()
	end

	ClientItem.Destroy(self)
end

function object:_StartCameraDisplacementLoop()
	if self._camera_displacement_loop_active or self._camera_displacement_spring.Value.Magnitude < 0.001 then
		return
	end

	task.spawn(function()
		self._camera_displacement_loop_active = true

		while true do
			local v = RunService.RenderStepped:Wait()

			if self._destroyed or self._camera_displacement_spring.Value.Magnitude < 0.001 or not self.ClientFighter:Get("IsSpectating") then
				break
			end

			CameraController:ApplyRotationDelta(self._camera_displacement_spring.Value * v, true)
		end

		self._camera_displacement_loop_active = false
	end)
end

function object:_FinishAiming()
	self:SetReplicate("IsAiming", false)
	self.ViewModel:SetAiming(false)
	self:SetReplicate("FOVOffset", 0)
	self:_FinishAimAssist()
end

function object:_ProjectileEffect(instance, p)
	if not instance then
		return
	end

	instance.Transparency = 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function get_setting(p2)
		if p and p[p2] ~= nil then
			return p[p2]
		end

		return self.Info[p2]
	end

	local projectileNameOverride = p and p.ProjectileNameOverride
	local clone = (projectileNameOverride and projectiles:FindFirstChild(projectileNameOverride) or projectiles:FindFirstChild(self.ViewModel.Name) or projectiles[self.Name]):Clone()
	clone.Parent = workspace
	self._projectile_part_to_model[instance] = clone
	BetterDebris:AddItem(clone, 60)
	WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), self:GetWrap(), true)
	instance.Destroying:Connect(function()
		self._projectile_part_to_model[instance] = nil
	end)

	for _, child in pairs(clone:GetChildren()) do
		child.CanCollide = false
		child.CanTouch = false
		child.CanQuery = false
		child.Massless = true
		child.Anchored = true
	end

	self.ProjectileShot:Fire(instance, clone)

	-- equivalent call inferred; original call site unknown
	if get_setting("ProjectileLogicOptimized") then
		local cframe = CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		local v = Spring.new(instance.Position, 1, 100)

		while not self._destroyed and instance:IsDescendantOf(workspace) do
			v.Target = instance.Position
			clone:PivotTo(CFrame.new(v.Value) * instance.CFrame.Rotation * cframe)
			RunService.RenderStepped:Wait()
		end

		clone:Destroy()
	else
		local v = 0.5

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("Trail") then
				v = math.max(v, effect.Lifetime)
			elseif effect:IsA("ParticleEmitter") then
				v = math.max(v, effect.Lifetime.Max)
			end
		end

		local v2 = get_setting("ProjectileVisualSpinEnabled") -- equivalent call inferred; original call site unknown
		local v3 = get_setting("ProjectileType") -- equivalent call inferred; original call site unknown
		local setting

		if v3 then
			local v4 = get_setting("ProjectileType") -- equivalent call inferred; original call site unknown

			if v4 == "RaycastProjectile" then
				setting = self.ClientFighter:IsActuallyFirstPerson() and PlayerDataController:GetSetting("Projectile Smoothing")
			else
				setting = false
				local v5 = get_setting("ProjectileType") -- equivalent call inferred; original call site unknown

				if v5 == "PhysicalProjectile" then
					local v6 = get_setting("ProjectilePhysicalClientSided") -- equivalent call inferred; original call site unknown
					setting = not v6

					if setting then
						setting = self.ClientFighter:IsActuallyFirstPerson() and PlayerDataController:GetSetting("Projectile Smoothing")
					end
				end
			end
		else
			setting = self.ClientFighter:IsActuallyFirstPerson() and PlayerDataController:GetSetting("Projectile Smoothing")
		end

		local v4 = Spring.new(
			instance.Position + (not setting and createVector(0, 0, 0) or -instance.Velocity.Unit * 200 or createVector(
				0,
				0,
				0
			)),
			1,
			40
		)
		local cframe = CFrame.Angles(0, 0, math.random() * 3.141592653589793 * 2)
		local lastTime = tick()
		local v5 = tick() + v
		local v6 = createVector(0, 0, 0)
		local v7 = 0
		local v8 = false
		local total = 0
		local velocity = createVector(0, 0, 0)

		while not self._destroyed and tick() < v5 do
			if instance:IsDescendantOf(workspace) then
				v5 = tick() + v
				v4.Target = instance.Position
			else
				v4.Target += v6 * v7

				if not v8 then
					v8 = true

					for _, descendant in pairs(clone:GetDescendants()) do
						if descendant:IsA("BasePart") or descendant:IsA("Texture") or descendant:IsA("Decal") then
							descendant.LocalTransparencyModifier = 1
						elseif descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") then
							descendant.Enabled = false
						elseif descendant:IsA("Light") then
							local v9 = descendant
							local brightness = descendant.Brightness
							task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 1, function(p2)
								v9.Brightness = brightness * (1 - p2 / 100)
							end)
						end
					end
				end
			end

			total += instance.Velocity.Magnitude * v7 * 0.25
			v4.Speed = math.clamp(tick() - lastTime, 0.01, 1) * 60 + 40

			if instance.Velocity.Magnitude > 0.01 then
				velocity = instance.Velocity or velocity
			end

			local cframe2

			if v2 then
				cframe2 = CFrame.Angles(-total, 0, 0)
			else
				cframe2 = CFrame.identity
			end

			if velocity.Magnitude > 0.01 and self.Name ~= "Flare Gun" then
				clone:PivotTo(CFrame.new(v4.Position, v4.Position + velocity) * cframe * cframe2)
			else
				clone:PivotTo(CFrame.new(v4.Position) * cframe * instance.CFrame.Rotation * cframe2)
			end

			v6 = velocity.Magnitude > v6.Magnitude and velocity or v6
			v7 = RunService.RenderStepped:Wait()
		end

		clone:SetAttribute("Destroying", true)
		BetterDebris:AddItem(clone, v)
	end
end

function object:_ResetReloadState()
	self._reload_cooldown = 0

	for _, _reload_thread in pairs(self._reload_threads) do
		pcall(task.cancel, _reload_thread)
	end

	self:StopCooldownEffect("Reload")
	self.ViewModel:StopAnimation("Reload")
	self.ViewModel:StopAnimation("EmptyReload")
	self.ViewModel:StopAnimation("ReloadStart")
	self.ViewModel:StopAnimation("ReloadSegment")
	self.ViewModel:StopAnimation("ReloadFinish")
	self.ViewModel:StopAnimation("EmptyReloadStart")
	self.ViewModel:StopAnimation("EmptyReloadSegment")
	self.ViewModel:StopAnimation("EmptyReloadFinish")

	for i = 2, self.Info.NumReloadFiles do
		self.ViewModel:StopAnimation("Reload" .. i)
	end
end

function object:_LocalTracers(p, p2)
	local entityLookupParams = self.ClientFighter:GetEntityLookupParams()
	local environmentID = self.ClientFighter:Get("EnvironmentID")
	local isCrouching = self.ClientFighter:IsCrouching()
	local raycastWhitelist = self.ClientFighter:GetRaycastWhitelist(true)
	local raycastResults = {}

	for i = 1, self.Info.ShootPellets do
		local quickShotSpread = p2 and self.Info.QuickShotSpread or self.Info.ShootSpread
		local spread = GameplayUtility:GetSpread(
			quickShotSpread + math.min(
				self.Info.ShootSpreadPerVelocityLimit,
				self.ClientFighter.Entity.RootPart.Velocity.Magnitude * self.Info.ShootSpreadPerVelocityUnit
			),
			self.Info.AimSpreadMultiplier,
			p,
			isCrouching,
			i,
			self.Info.ShootPellets,
			self.Info.ShootSpreadConsistent
		)
		local cameraData = self.ClientFighter:GetCameraData(raycastWhitelist, spread, true)
		local v3 = cameraData[utf8.char(0)]
		local v4 = cameraData[utf8.char(1)]
		local v5 = cameraData[utf8.char(2)]
		local v6 = cameraData[utf8.char(3)]
		local position = v5 and (v5.CFrame * v6).Position or (v4 * spread * CFrame.new(
			0,
			0,
			-CONSTANTS.MAX_RAYCAST_DISTANCE
		)).Position
		local position2 = v3.Position
		local unit = (position - position2).Unit

		for i2 = 0, self.Info.RaycastBounceCount do
			if unit ~= unit then
				table.insert(raycastResults, {
					Position = position2 + unit * CONSTANTS.MAX_RAYCAST_DISTANCE
				})
				break
			end

			local _, v7 = GameplayUtility:GetEntitiesFromRaycast(
				environmentID,
				entityLookupParams,
				position2,
				unit,
				CONSTANTS.MAX_RAYCAST_DISTANCE,
				self.Info.RaycastPierceCount
			)
			local v8 = {
				Position = v7.Position
			}

			if i2 > 0 then
				v8.LastRaycastResult = raycastResults[#raycastResults]
				v8.StartPosition = v8.LastRaycastResult.Position
			end

			table.insert(raycastResults, v8)

			if not v7.Normal then
				break
			end

			position2 = v7.Position
			unit = GameplayUtility:GetRaycastRedirection(
				environmentID,
				entityLookupParams,
				unit - 2 * unit:Dot(v7.Normal) * v7.Normal,
				position2,
				self.Info.RaycastBounceRedirectionAngle
			)
		end
	end

	table.insert(self._local_tracers, raycastResults)
	task.delay(1, function()
		local index = table.find(self._local_tracers, raycastResults)

		if index then
			table.remove(self._local_tracers, index)
		end
	end)
	self:_Tracers({
		RaycastResults = raycastResults,
		IsEnemy = false,
		IsLocal = true
	})
end

function object:_CorrectLocalTracers(items)
	local v = table.remove(self._local_tracers, 1)

	if not v then
		return
	end

	for k, item in pairs(items) do
		for k2, v2 in pairs(item) do
			v[k][k2] = v2
		end

		v[k].StartPosition = v[k].CurrentTracerPosition
	end
end

function object:_Tracers(p2, p3)
	local v2, v3, v4 = TracerEffect:VerifyTracerData(p2, p3, {
		FriendlyTracerColor = self.ViewModel.GetFriendlyTracerColor and self.ViewModel:GetFriendlyTracerColor(),
		ActuallyFirstPerson = self.ClientFighter:IsActuallyFirstPerson(),
		MuzzlePosition = self.ViewModel:GetMuzzlePosition()
	})

	if self.ViewModel.CustomTracers then
		return self.ViewModel:CustomTracers(v2, v3, v4)
	end

	TracerEffect:Play(v2, v3, v4)
end

function object:_ShootEffect(items)
	local raycastResults = {}

	for k, item in pairs(items) do
		raycastResults[utf8.codepoint(k) + 1] = {
			Position = item[utf8.char(0)] or nil,
			Instance = item[utf8.char(1)] or nil,
			Normal = item[utf8.char(2)] or nil,
			LastRaycastIndex = item[utf8.char(3)] and utf8.codepoint(item[utf8.char(3)]) + 1 or nil
		}
	end

	for _, v2 in pairs(raycastResults) do
		local lastRaycastResult

		if v2.LastRaycastIndex then
			lastRaycastResult = raycastResults[v2.LastRaycastIndex] or nil
		end

		v2.LastRaycastResult = lastRaycastResult
		v2.LastRaycastIndex = nil
		local startPosition

		if v2.LastRaycastResult then
			startPosition = v2.LastRaycastResult.Position or nil
		end

		v2.StartPosition = startPosition
	end

	if not (self.ClientFighter.IsLocalPlayer and #self._local_tracers > 0) then
		self:_Tracers({
			RaycastResults = raycastResults,
			IsEnemy = Players.LocalPlayer:GetAttribute("TeamID") ~= self.ClientFighter.Player:GetAttribute("TeamID"),
			IsLocal = self.ClientFighter.IsLocalPlayer
		})
	end

	self:_ImpactMarkers(raycastResults)
end

function object:_CheckReload()
	if self:Get("Ammo") <= 0 then
		if self.Name == "Daggers" then
			self._reload_delay = tick() + 0.2
			wait(0.2)
		end

		self:SimulateInputFromGameplayMechanic("StartReloading")
	end
end

function object:_Init()
	self:GetDataChangedSignal("Ammo"):Connect(function()
		self._shot_but_ammo_hasnt_updated = false
		self:_CheckReload()
	end)
	self:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:_CheckReload()
	end)
	self.ViewModel.AnimationPlayed:Connect(function(p)
		if (p == self.ViewModel.Animator:GetInspectAnimationKey() or p == self.ViewModel.Animator:GetRareInspectAnimationKey()) and self._last_shoot_animation_name then
			self.ViewModel:StopAnimation(self._last_shoot_animation_name, 0)
		end
	end)
	table.insert(self._connections, self.ClientFighter.Interrupted:Connect(function()
		self:_ResetReloadState()
		self:SimulateInputFromGameplayMechanic("FinishAiming", true)
	end))
	self:ChangeShootAnimationNamePrefix("Shoot")
end

return object