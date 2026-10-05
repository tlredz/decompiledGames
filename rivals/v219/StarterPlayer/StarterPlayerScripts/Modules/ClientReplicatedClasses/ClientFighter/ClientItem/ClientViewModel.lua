local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("ContentProvider")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local SoundLibrary = require(ReplicatedStorage.Modules.SoundLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local Charm = require(Players.LocalPlayer.PlayerScripts.Modules.Charm)
local ViewModelAnimator = require(script:WaitForChild("ViewModelAnimator"))
local viewModels = workspace:WaitForChild("ViewModels")
local firstPerson = viewModels:WaitForChild("FirstPerson")
local viewModels2 = ReplicatedStorage.Assets:WaitForChild("Temp"):WaitForChild("ViewModels")
local scopeGlareGui1 = Players.LocalPlayer.PlayerScripts.UserInterface.ScopeGlareGui1
local scopeGlareGui2 = Players.LocalPlayer.PlayerScripts.UserInterface.ScopeGlareGui2
local muzzleFlashes = Players.LocalPlayer.PlayerScripts.Assets.Misc.MuzzleFlashes
local viewModelRoot = Players.LocalPlayer.PlayerScripts.Assets.Misc.ViewModelRoot
local viewModels3 = Players.LocalPlayer.PlayerScripts.Assets.ViewModels
local charms = Players.LocalPlayer.PlayerScripts.Modules.Charms
local color = Color3.fromRGB(0, 0, 0)
local v = {
	createVector(0.5, 0.5, 0.5),
	createVector(-0.5, 0.5, 0.5),
	createVector(-0.5, 0.5, -0.5),
	createVector(0.5, 0.5, -0.5),
	createVector(0.5, -0.5, 0.5),
	createVector(-0.5, -0.5, 0.5),
	createVector(-0.5, -0.5, -0.5),
	createVector(0.5, -0.5, -0.5)
}
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object.new(serial, clientItem)
	local self = setmetatable(ReplicatedClass.new(serial), object)
	self.AnimationPlayed = Signal.new()
	self.AnimationStopped = Signal.new()
	self.Equipped = Signal.new()
	self.Unequipped = Signal.new()
	self.ClientItem = clientItem
	self.Name = self:Get("Name")
	self.Info = ItemLibrary.ViewModels[self.Name]
	self.Model = viewModelRoot:Clone()
	self.ItemModel = Utility:LookThrough(viewModels3, self.Name):Clone()
	self.Animator = ViewModelAnimator.new(self)
	self.Charm = nil
	self.ShouldPlayReloadAnimationInstantly = nil
	self.RightArmIKControlDisabled = nil
	self.LeftArmIKControlDisabled = nil
	self.CurrentBobbingValue = Vector2.zero
	self.CurrentRecoilValue = createVector(0, 0, 0)
	self.CurrentSwayValue = Vector2.zero
	self.CurrentJumpValue = 0
	self.CurrentAimValue = 0
	self.CurrentInspectValue = 0
	self.CurrentLandingValue = 0
	self._serial = serial
	self._destroyed = false
	self._connections = {}
	self._preloaded_sounds = {}
	self._last_hitmarker_sounds = {}
	self._left_arm = self.Model.LeftArm
	self._left_arm_shirt_texture = self._left_arm.ShirtTexture
	self._right_arm = self.Model.RightArm
	self._right_arm_shirt_texture = self._right_arm.ShirtTexture
	self._shirt_id = nil
	self._left_arm_color = nil
	self._right_arm_color = nil
	self._body_model = nil
	self._original_scale = self.ItemModel:GetScale()
	self._equip_spring = Spring.new(0, 0.625, 12.5)
	self._aim_spring = Spring.new(0, 1, 30)
	self._crouching_spring = Spring.new(0, 0.875, 17.5)
	self._sliding_spring = Spring.new(0, 0.5, 12.5)
	self._sprinting_spring = Spring.new(0, 0.75, self.Info.PlayAnimationsInstantly and 100 or 15)
	self._bobbing_speed_spring = Spring.new(0, 1, 20)
	self._bobbing_value_spring = Spring.new(Vector2.zero, 0.5, 12.5)
	self._sway_spring = Spring.new(Vector2.zero, 0.5, 12.5)
	self._landing_spring = Spring.new(0, 0.75, 10)
	self._jump_spring = Spring.new(0, 0.5, 15)
	self._tilt_spring = Spring.new(Vector2.zero, 0.5, 15)
	self._recoil_spring = Spring.new(createVector(0, 0, 0), 0.875, 100)
	self._unrecoil_spring = Spring.new(createVector(0, 0, 0), 0.375, 25)
	self._head_raycast_spring = Spring.new(0, 1, 50)
	self._raycast_tilt_spring = Spring.new(0, 1, 50)
	self._impulse_position_spring = Spring.new(createVector(0, 0, 0), 0.25, 20)
	self._inspect_spring = Spring.new(0, 1, 20)
	self._instant_set_inspect_spring = true
	self._render_cooldown = 0
	self._is_equipped = false
	self._root_part_offset_inverse = self.Info.RootPartOffset:Inverse()
	self._root_part_offset_override = nil
	self._root_part_offset_override_inverse = nil
	self._custom_sprinting_enabled = 0
	self._bobbing_tick = 0
	self._aim_position_attachment = nil
	self._aim_lookat_attachment = nil
	self._center_attachment = nil
	self._muzzle_attachments = {}
	self._charm_attachment_model = nil
	self._charm_pivot_attachment = nil
	self._charm_sub_model = nil
	self._scope_glare_attachment = nil
	self._scope_glare_gui1 = nil
	self._scope_glare_gui2 = nil
	self._was_first_person = nil
	self._local_transparency_modifiers = {}
	self._local_transparency_modifier_update = {}
	self._hidden_submodels = {}
	self._animation_context_submodels = {}
	self._arm_submodels = {}
	self._original_wrap_properties = nil
	self._original_object_transparencies = {}
	self._right_arm_wrapped_part = nil
	self._left_arm_wrapped_part = nil
	self._wrapped_only_objects = {}
	self._can_wrap_left_arm = false
	self._can_wrap_right_arm = false
	self._submodels_behind_head_values = {}
	self._submodel_boundingbox_attachments = {}
	self:_Init()
	return self
end

function object.GetCameraOffset(p)
	if Utility:AngleBetweenVectors(p.Model.Camera.CFrame.LookVector, p.Model.HumanoidRootPart.CFrame.LookVector) > 1.5707963267948966 then
		return CFrame.identity
	end

	return p.Model.HumanoidRootPart.CFrame:ToObjectSpace(p.Model.Camera.CFrame)
end

function object.GetImage(p)
	return p.Info.Image
end

function object:IsEquipped()
	return self._is_equipped
end

function object:IsRenderingDisabled()
	return tick() < self._render_cooldown or (self.Animator:IsRenderingDisabled() or self.ClientItem.ClientFighter:Get("IsHiddenByEmotes") or self.ClientItem.ClientFighter:Get("IsHiddenByCutscene") or self.ClientItem.ClientFighter.Entity and self.ClientItem.ClientFighter.Entity:IsEmoting())
end

function object:IsAimingAnimationEnabled()
	return self._aim_position_attachment and self._aim_lookat_attachment and (self.ClientItem.Info.AimScopePercent or PlayerDataController:GetSetting("ViewModel Aiming"))
end

function object:AreAnimationsPlaying(...)
	return self.Animator:AreAnimationsPlaying(...)
end

function object:IsAnimationPlaying(...)
	return self.Animator:IsAnimationPlaying(...)
end

function object:GetAnimationTrack(...)
	return self.Animator:GetAnimationTrack(...)
end

function object:GetAnimationKeys(...)
	return self.Animator:GetAnimationKeys(...)
end

function object:Inspect(...)
	return self.Animator:Inspect(...)
end

function object:StopInspecting(...)
	return self.Animator:StopInspecting(...)
end

function object:PlayAnimation(...)
	return self.Animator:PlayAnimation(...)
end

function object:StopAnimation(...)
	return self.Animator:StopAnimation(...)
end

function object:ChangeEquipAnimation(...)
	return self.Animator:ChangeEquipAnimation(...)
end

function object:ChangeIdleAnimation(...)
	return self.Animator:ChangeIdleAnimation(...)
end

function object:ChangeSprintAnimation(...)
	return self.Animator:ChangeSprintAnimation(...)
end

function object:ChangeInspectAnimation(...)
	return self.Animator:ChangeInspectAnimation(...)
end

function object:GetMuzzlePosition()
	local v2

	if self:IsRenderingDisabled() then
		v2 = self:_GetDefaultMuzzlePosition()
	end

	if v2 or not (#self._muzzle_attachments > 0) then
		if v2 or not (self._body_model and self._body_model.PrimaryPart) then
			return v2 or self:_GetDefaultMuzzlePosition()
		end

		return self._body_model.PrimaryPart.Position
	else
		local v3 = createVector(0, 0, 0)

		for _, _muzzle_attachment in pairs(self._muzzle_attachments) do
			v3 += _muzzle_attachment.WorldPosition
		end

		return v3 / #self._muzzle_attachments
	end
end

function object:GetMuzzleAttachment()
	return self._muzzle_attachments[1]
end

function object:GetWrap()
	return (self.ClientItem.ClientFighter:Get("IsSpectating") or not PlayerDataController:GetSetting("Wraps Disabled")) and self:Get("Wrap")
end

function object:SetParent(parent)
	self.Model.Parent = parent
	self.Animator:LoadAnimations()
end

function object:SetArmsData(value, p, p2)
	assert(
		not value or typeof(value) == "string",
		"Argument 1 invalid, expected a string or nil, got " .. tostring(value)
	)
	self._shirt_id = value or ""
	self._left_arm_color = p or color
	self._right_arm_color = p2 or color
	self:_UpdateArms()
end

function object:SetAiming(p)
	assert(typeof(p) == "boolean", "Argument 1 invalid, expected a boolean")
	self._aim_spring.Target = p and 1 or 0
	self._aim_spring.Speed = 30 * (not p and 1 or self.ClientItem.Info.AimSpeed or 1)

	if p then
		self:StopInspecting()
	end
end

function object:SetCustomSprintingEnabled(p2, p3)
	if p2 then
		self._custom_sprinting_enabled = tick() + p2
	end

	if p3 then
		self._sprinting_spring.Value = 0
	end
end

function object:SetCFrame(cFrame)
	self.Model.PrimaryPart.CFrame = cFrame
end

function object:CreateSound(...)
	return self.ClientItem:CreateSound(...)
end

function object:CreateSpectatorSound(...)
	return self.ClientItem:CreateSpectatorSound(...)
end

function object:OverrideRootPartOffset(root_part_offset_override)
	self._root_part_offset_override = root_part_offset_override
	self._root_part_offset_override_inverse = self._root_part_offset_override_inverse and self._root_part_offset_override:Inverse()
end

function object:HideSubModel(p, duration)
	self._hidden_submodels[p] = (self._hidden_submodels[p] or 0) + 1
	self:_UpdateSubModelVisibility()
	local _hidden_submodel = self._hidden_submodels[p]

	local function callback()
		if self._hidden_submodels[p] ~= _hidden_submodel then
			return
		end

		self._hidden_submodels[p] = false
		self:_UpdateSubModelVisibility()
	end

	if duration > 0 then
		if duration < 1e999 then
			task.delay(duration, callback)
		end
	else
		task.spawn(callback)
	end
end

function object:Impulse(velocity, p2, p3, p4)
	self._impulse_position_spring.Position = p4 and self._impulse_position_spring.Target or self._impulse_position_spring.Position
	self._impulse_position_spring.Velocity = velocity
	self._impulse_position_spring.Damper = p2 or self._impulse_position_spring.Damper
	self._impulse_position_spring.Speed = p3 or self._impulse_position_spring.Speed
end

function object:ApplyRecoil(p2)
	assert(typeof(p2) == "Vector3", "Argument 1 invalid, expected a Vector3")
	self._recoil_spring.Target += p2
	self._unrecoil_spring.Target += p2
end

function object:Equip(p)
	self._is_equipped = true
	self.Equipped:Fire(p)
	self._instant_set_inspect_spring = true
	self._render_cooldown = tick() + 0.1
	self.Animator:SetInspectCooldown(0)
	self.Animator:PlayIdleAnimation()
	self:CreateSound(
		SoundLibrary.EquipSounds[math.random(#SoundLibrary.EquipSounds)],
		p and 0.25 or 0.5,
		0.9 + 0.2 * math.random(),
		true,
		5
	)

	if p then
		self._equip_spring.Value = 0.5
	elseif not self.Animator:PlayEquipAnimation() then
		self._equip_spring.Value = 1
	end
end

function object:Unequip()
	self._is_equipped = false
	self.Unequipped:Fire()

	if self._highlight then
		self._highlight:Destroy()
		self._highlight = nil
	end

	self.Animator:StopAllAnimations()
end

function object:MuzzleFlash()
	if self._aim_spring.Target >= 1 and PlayerDataController:GetSetting("Aiming Hides Muzzle Flashes") then
		return
	end

	for _, _muzzle_attachment in pairs(self._muzzle_attachments) do
		Utility:PlayParticles(_muzzle_attachment)
	end
end

function object:PlayHitAnimation(p)
	if p and self.Info.Animations.HeavyAttackAnimationHit then
		self:PlayAnimation("HeavyAttackAnimationHit", nil, 0)
	end
end

function object:PlayHitmarkerSound(p, p2)
	if #self._last_hitmarker_sounds > 10 then
		for i = #self._last_hitmarker_sounds % 10, 1, -1 do
			self._last_hitmarker_sounds[i]:Destroy()
			table.remove(self._last_hitmarker_sounds, i)
		end
	end

	if not p then
		self:_CreateHitmarkerSound("rbxassetid://13110130082", 1.5 / p2, 1 + 0.2 * math.random(), script, true, 1)
		return
	end

	self:_CreateHitmarkerSound("rbxassetid://16537449730", 3 / p2, 1 + 0.2 * math.random(), script, true, 1)
	self:_CreateHitmarkerSound("rbxassetid://16537337310", 2 / p2, 1 + 0.2 * math.random(), script, true, 1)
end

function object:Update(p, data, p2)
	if p2.IsActive then
		local isInspectAnimationPlaying = self.Animator:IsInspectAnimationPlaying()
		self._inspect_spring.Target = isInspectAnimationPlaying and 1 or 0
		local _inspect_spring = self._inspect_spring
		local v2

		if self._instant_set_inspect_spring then
			v2 = self._inspect_spring.Target
		else
			v2 = self._inspect_spring.Value
		end

		_inspect_spring.Value = v2
		self._instant_set_inspect_spring = false
		local v3 = self.ClientItem.ClientFighter:GetCameraSway(true) * 35
		local state = self.ClientItem.ClientFighter.Entity.Humanoid:GetState()
		local sprintTrack = self.Animator:GetSprintTrack()
		local currentInspectValue = self._inspect_spring.Value
		local currentAimValue = self._aim_spring.Value * (1 - currentInspectValue * 0.125)
		local v5 = 1 - currentAimValue
		local currentRecoilValue = self._recoil_spring.Value - self._unrecoil_spring.Value
		local v7 = data.IsActuallySprinting and self._aim_spring.Target == 0

		if self._highlight or not data.IsActuallyFirstPerson or self:IsRenderingDisabled() or not PlayerDataController:GetSetting("ViewModel Highlight") then
			if self._highlight and not data.IsActuallyFirstPerson then
				self._highlight:Destroy()
				self._highlight = nil
			end
		else
			self._highlight = Instance.new("Highlight")
			self._highlight.Name = "ViewModel"
			self._highlight.FillTransparency = 1
			self._highlight.OutlineTransparency = 0.875
			self._highlight.OutlineColor = Color3.new()
			self._highlight.Adornee = self.Model
			self._highlight.Parent = self.Model
		end

		if sprintTrack then
			if v7 and not sprintTrack.IsPlaying then
				self.Animator:PlaySprintAnimation()
			elseif not v7 and sprintTrack.IsPlaying then
				self.Animator:StopSprintAnimation()
			end

			if sprintTrack.IsPlaying then
				sprintTrack:AdjustSpeed(self.Animator.SprintTrackSpeed * self._bobbing_speed_spring.Value / 0.1111111111111111 * 0.8)
			end
		end

		local transparency = data.IsActuallyFirstPerson and 0 or 1
		self._left_arm.Transparency = transparency
		self._right_arm.Transparency = transparency
		self._left_arm_shirt_texture.Transparency = transparency
		self._right_arm_shirt_texture.Transparency = transparency

		if self._scope_glare_gui1 and self._scope_glare_gui2 then
			local unit = (workspace.CurrentCamera.CFrame.Position - self._scope_glare_attachment.WorldPosition).Unit
			local lookVector = self.ClientItem.ClientFighter.Entity.RootPart.CFrame.LookVector
			local _scope_glare_gui1 = self._scope_glare_gui1
			local enabled = not data.IsActuallyFirstPerson

			if enabled then
				if self._aim_spring.Target >= 1 then
					enabled = Utility:AngleBetweenVectors(unit, lookVector) < 0.7853981633974483
				else
					enabled = false
				end
			end

			_scope_glare_gui1.Enabled = enabled
			self._scope_glare_gui2.Enabled = false
		end

		if self:IsRenderingDisabled() then
			self:SetCFrame(CFrame.identity)
			self:_StepBehindHeadSubmodels(false)
		elseif data.IsActuallyFirstPerson then
			self:_StepBehindHeadSubmodels(true)
			self:_UpdateHiddenArmSubmodels(true)
			local v9 = (CONSTANTS.DEVICE == "VR" and workspace.CurrentCamera.CFrame * CameraController.VRCameraCFrame.Rotation + CameraController.VRCameraCFrame.Position * 1.4142135623730951 / 2 or workspace.CurrentCamera.CFrame) * p2.ViewModelOffset * (self._root_part_offset_override or self.Info.RootPartOffset)
			self._sway_spring.Value += Vector2.new(v3.Y * 0.5, v3.X)
			local currentSwayValue = self._sway_spring.Value * 0.0003
			local cframe = self._aim_lookat_attachment and self._aim_lookat_attachment.WorldCFrame:ToObjectSpace(self.Model.PrimaryPart.CFrame) or CFrame.identity
			local lerped = CFrame.new(currentSwayValue.Y * 1, -currentSwayValue.X * 2, 0):Lerp(
				cframe:Inverse() * CFrame.Angles(0, currentSwayValue.Y * 0.05625, 0) * CFrame.Angles(
					currentSwayValue.X * 0.1,
					0,
					0
				) * cframe,
				currentAimValue
			)
			local value2 = self._impulse_position_spring.Value
			local cframe2 = CFrame.new(value2)
			local value3 = self._equip_spring.Value
			local v11 = CFrame.new(0, -0.5 * value3, 0.25 * value3) * CFrame.Angles(
				-0.7853981633974483 * value3,
				0,
				0.7853981633974483 * value3
			)
			self._sliding_spring.Target = data.IsSliding and 1 or 0
			local v12 = self._sliding_spring.Value * v5
			local cframe3 = CFrame.Angles(0, 0, -0.3490658503988659 * v12)
			local identity

			if self.Info.DisableProceduralSprinting then
				identity = CFrame.identity
			else
				local v13 = v7 and not (sprintTrack and sprintTrack.IsPlaying) and not isInspectAnimationPlaying and tick() > self._custom_sprinting_enabled
				self._sprinting_spring.Target = (v13 or state == Enum.HumanoidStateType.Climbing) and 1 or 0
				local value4 = self._sprinting_spring.Value
				identity = CFrame.Angles(0, 0.4363323129985824 * value4, 0) * CFrame.Angles(
					-0.4363323129985824 * value4,
					0,
					0
				)
			end

			self._bobbing_speed_spring.Target = data.MoveSpeed / CONSTANTS.BASE_WALKSPEED * 0.1111111111111111 * (data.IsGrounded and 1 or 0.05)
			self._bobbing_tick += self._bobbing_speed_spring.Value * p * 60
			local v13 = v7 and sprintTrack and sprintTrack.IsPlaying and 0.25 or 1
			local v14 = math.max(0, data.MoveSpeed / CONSTANTS.BASE_WALKSPEED) ^ 2.5 * ((data.IsSliding or data.IsBeingKnockedBack) and 0 or 1) * v13 * 0.05 * (self.ClientItem.Info.AimScopePercent and 1 or v5)
			local v15 = self.Info.FramesPerSecond and math.floor(self._bobbing_tick * self.Info.FramesPerSecond) / self.Info.FramesPerSecond or self._bobbing_tick
			local v16 = math.sin(v15) * v14 * 2
			local v17 = math.cos(v15 * 2 + 1.5707963267948966) * v14
			self._bobbing_value_spring.Target = Vector2.new(v16, v17)
			local target = self.Info.FramesPerSecond and self._bobbing_value_spring.Target or self._bobbing_value_spring.Value
			local cframe4 = CFrame.new(target.X, target.Y, 0)
			self._landing_spring.Velocity = data.JustLanded and -10 - 15 * v5 or self._landing_spring.Velocity
			local currentLandingValue = self._landing_spring.Value
			local cframe5 = CFrame.new(0, currentLandingValue * 0.125, 0)
			self._jump_spring.Target = math.max(
				-16 * v5,
				math.abs(data.PlayerVelocity.Y) ^ 1.25 * math.sign(data.PlayerVelocity.Y)
			)
			local currentJumpValue = self._jump_spring.Value * (2 - 1.5 * currentAimValue)
			local cframe6 = CFrame.Angles(
				math.clamp(math.rad(-currentJumpValue / 6), -0.7853981633974483, 0.7853981633974483),
				0,
				0
			)
			local isAimingAnimationEnabled = self:IsAimingAnimationEnabled()
			local v19

			if self.Info.FramesPerSecond then
				v19 = math.floor(currentAimValue * self.Info.FramesPerSecond + (self.ClientItem.Info.AimScopePercent and 0 or 0.5)) / self.Info.FramesPerSecond or currentAimValue
			else
				v19 = currentAimValue
			end

			local identity2 = not isAimingAnimationEnabled and CFrame.identity or CFrame.lookAt(
				self._aim_position_attachment.WorldPosition,
				self._aim_lookat_attachment.WorldPosition,
				self._aim_position_attachment.WorldCFrame.UpVector
			):ToObjectSpace(self.Model.PrimaryPart.CFrame)
			local cframe7 = CFrame.new(identity2.Position)
			local v20 = identity2 - identity2.Position
			local cframe8 = data.IsActuallyFirstPerson and (self.ClientItem.Info.AimScopePercent or 1e999) <= currentAimValue and CFrame.new(
				0,
				0,
				10
			) or not isAimingAnimationEnabled and CFrame.identity or CFrame.identity:Lerp(
				(self._root_part_offset_override_inverse or self._root_part_offset_inverse) * p2.ViewModelOffset:Inverse(),
				currentAimValue
			) * CFrame.identity:Lerp(cframe7, v19) * CFrame.identity:Lerp(v20, v19)
			local v21 = -data.MoveVelocity:Cross(self.ClientItem.ClientFighter.Entity.RootPart.CFrame.LookVector).Y / CONSTANTS.BASE_WALKSPEED * (1 + currentAimValue)
			local v22 = data.MoveVelocity:Cross(self.ClientItem.ClientFighter.Entity.RootPart.CFrame.RightVector).Y / CONSTANTS.BASE_WALKSPEED * (1 - currentAimValue * 0.75)
			self._tilt_spring.Target = Vector2.new(v21, data.IsSliding and 0 or v22)
			local value5 = self._tilt_spring.Value
			local v23 = cframe:Inverse() * CFrame.Angles(
				value5.Y * 0.06981317007977318 * 0.5,
				0,
				value5.X * 0.06981317007977318
			) * cframe
			local v24 = CFrame.new(
				Vector3.new(0, 0, currentRecoilValue.Z),
				(Vector3.new(currentRecoilValue.X, math.abs(currentRecoilValue.Y), currentRecoilValue.Z - 1))
			) * CFrame.Angles(
				math.abs(currentRecoilValue.Y) * 0.7853981633974483,
				0,
				1.5707963267948966 * -currentRecoilValue.X
			)
			local v25 = CFrame.new(currentRecoilValue.X * 2, -currentRecoilValue.Z / 10, currentRecoilValue.Z) * CFrame.Angles(
				0,
				currentRecoilValue.X * -2.5,
				currentRecoilValue.X * 10
			)
			local v26 = cframe:Inverse() * CFrame.identity:Lerp(v24, 1 - currentAimValue) * CFrame.identity:Lerp(
				v25,
				currentAimValue
			) * cframe
			self:SetCFrame(v9 * lerped * cframe2 * v11 * cframe3 * identity * cframe4 * cframe5 * cframe6 * cframe8 * v23 * v26)
			self.CurrentBobbingValue = target
			self.CurrentSwayValue = currentSwayValue
			self.CurrentJumpValue = currentJumpValue
			self.CurrentLandingValue = currentLandingValue
		else
			local rotationCFrame = self.ClientItem.ClientFighter:GetRotationCFrame()
			self:SetCFrame(CFrame.new(self.ClientItem.ClientFighter.Entity.Head.Position) * rotationCFrame)
			self:_StepBehindHeadSubmodels(nil, rotationCFrame)
			self:_UpdateHiddenArmSubmodels(false)
		end

		if self.Charm then
			task.defer(self.Charm.Update, self.Charm, p, not data.IsActuallyFirstPerson)
		end

		if self._was_first_person ~= data.IsActuallyFirstPerson then
			self._was_first_person = data.IsActuallyFirstPerson

			for k, _arm_submodel in pairs(self._arm_submodels) do
				k:ScaleTo(_arm_submodel.OriginalScale * (data.IsActuallyFirstPerson and 1 or 1.7))
			end

			if ItemLibrary.THIRD_PERSON_VIEWMODEL_BLACKLIST[self.Name] then
				self:_UpdateWrap()
			end
		end

		self.CurrentRecoilValue = currentRecoilValue
		self.CurrentAimValue = currentAimValue
		self.CurrentInspectValue = currentInspectValue
		local v9

		if data.IsActuallyFirstPerson then
			v9 = firstPerson
		else
			v9 = viewModels
		end

		self:SetParent(v9)
		return true
	elseif self.Model ~= viewModels2 then
		pcall(function()
			self:SetParent(viewModels2)
		end)
	end
end

function object:Destroy()
	self._destroyed = true

	for _, _preloaded_sound in pairs(self._preloaded_sounds) do
		_preloaded_sound:Destroy()
	end

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for k in pairs(self._wrapped_only_objects) do
		k:Destroy()
	end

	self.Equipped:Destroy()
	self.Unequipped:Destroy()
	self.AnimationPlayed:Destroy()
	self.AnimationStopped:Destroy()

	if self.Charm then
		self.Charm:Destroy()
	end

	self.Animator:Destroy()
	self.ItemModel:Destroy()
	self.Model:Destroy()
	ReplicatedClass.Destroy(self)
end

function object:_UpdateHiddenArmSubmodels(p)
	for folder, _arm_submodel in pairs(self._arm_submodels) do
		local v2 = _arm_submodel.HideInThirdPerson and not p and 1 or 0

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				self:_LocalTransparencyModifier(part, "HiddenArmSubmodel", v2)
			end
		end
	end
end

function object:_IsSubmodelBehindHead(instance, p)
	local _ = self._animation_context_submodels[instance]
	local head = self.ClientItem.ClientFighter.Entity and (self.ClientItem.ClientFighter.Entity.Head or self.ClientItem.ClientFighter.Entity.RootPart)

	if not (head and instance.PrimaryPart) then
		return false
	end

	local v2 = p or head.CFrame.Rotation

	for _, v3 in pairs(self._submodel_boundingbox_attachments[instance]) do
		if v3.WorldPosition:FuzzyEq(head.Position) or Utility:AngleBetweenVectors(
			v3.WorldPosition - head.Position,
			v2.LookVector
		) < 1.5707963267948966 then
			return false
		end
	end

	return true
end

function object:_StepBehindHeadSubmodels(p, p2)
	for _, folder in pairs(self.ItemModel:GetChildren()) do
		local v2

		if p == nil then
			v2 = not self:_IsSubmodelBehindHead(folder, p2)
		else
			v2 = p
		end

		local v3 = v2 or false

		if self._submodels_behind_head_values[folder] == v3 then
			continue
		end

		self._submodels_behind_head_values[folder] = v3
		local v4 = v3 and 0 or 1

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				self:_LocalTransparencyModifier(part, "BehindHead", v4)
			end
		end

		if self.Charm and folder == self._charm_sub_model then
			self.Charm:SetHidden(not v3)
		end
	end
end

function object:_GetDefaultMuzzlePosition()
	return (CFrame.new(self.ClientItem.ClientFighter.Entity.Head.Position) * self.ClientItem.ClientFighter:GetRotationCFrame() * CFrame.new(
		0.5,
		-0.5,
		-0.5
	)).Position
end

function object._AnimationWait(p, ...)
	return p.Animator:AnimationWait(...)
end

function object:_CreateHitmarkerSound(...)
	local sound = self.ClientItem.ItemInterface:CreateSound(...)

	if sound then
		table.insert(self._last_hitmarker_sounds, sound)
	end
end

function object:_UpdateLocalTransparencyModifiers()
	for k in pairs(self._local_transparency_modifiers) do
		self:_UpdateLocalTransparencyModifier(k)
	end
end

function object:_UpdateLocalTransparencyModifier(folder)
	self._local_transparency_modifier_update[folder] = true
	task.defer(function()
		if not self._local_transparency_modifier_update[folder] then
			return
		end

		self._local_transparency_modifier_update[folder] = nil
		local localTransparencyModifier = 0

		for _, v3 in pairs(self._local_transparency_modifiers[folder]) do
			localTransparencyModifier = math.max(localTransparencyModifier, v3)
		end

		folder.LocalTransparencyModifier = localTransparencyModifier

		for _, descendant in pairs(folder:GetDescendants()) do
			if not (descendant:IsA("Texture") or descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Decal")) then
				continue
			end

			descendant.LocalTransparencyModifier = localTransparencyModifier
		end
	end)
end

function object:_LocalTransparencyModifier(p, p2, p3)
	if not p then
		return
	end

	self._local_transparency_modifiers[p] = self._local_transparency_modifiers[p] or {}

	if self._local_transparency_modifiers[p][p2] == p3 then
		return
	end

	self._local_transparency_modifiers[p][p2] = p3
	self:_UpdateLocalTransparencyModifier(p)
end

function object:_UpdateWrap()
	local wrap

	if not (ItemLibrary.THIRD_PERSON_VIEWMODEL_BLACKLIST[self.Name] and not self._was_first_person) then
		wrap = self:GetWrap()
	end

	if not (wrap or self._original_wrap_properties) then
		return
	end

	local v2 = wrap ~= nil
	local _can_wrap_left_arm = v2 and self._can_wrap_left_arm
	local _can_wrap_right_arm = v2 and self._can_wrap_right_arm
	self:_LocalTransparencyModifier(self._left_arm, "FistsWrap", _can_wrap_left_arm and 1 or 0)
	self:_LocalTransparencyModifier(self._left_arm_shirt_texture, "FistsWrap", _can_wrap_left_arm and 1 or 0)
	self:_LocalTransparencyModifier(self._right_arm, "FistsWrap", _can_wrap_right_arm and 1 or 0)
	self:_LocalTransparencyModifier(self._right_arm_shirt_texture, "FistsWrap", _can_wrap_right_arm and 1 or 0)

	for k, _wrapped_only_object in pairs(self._wrapped_only_objects) do
		local _can_wrap_left_arm2

		if v2 then
			_can_wrap_left_arm2 = k.Name == "LeftArmWrapped" and self._can_wrap_left_arm

			if not _can_wrap_left_arm2 then
				if k.Name == "RightArmWrapped" then
					_can_wrap_left_arm2 = self._can_wrap_right_arm
				else
					_can_wrap_left_arm2 = false
				end
			end
		else
			_can_wrap_left_arm2 = v2
		end

		k.Parent = _can_wrap_left_arm2 and _wrapped_only_object or nil
	end

	self._original_wrap_properties = self._original_wrap_properties or WrapController:RecordOriginalWrapProperties(self.Model)
	WrapController:ApplyWrap(self._original_wrap_properties, wrap)
	self:_UpdateLocalTransparencyModifiers()
end

function object:_UpdateSubModelVisibility()
	for _, folder in pairs(self.ItemModel:GetChildren()) do
		local _animation_context_submodel = self._animation_context_submodels[folder]
		local _hidden_submodel = self._hidden_submodels[folder.Name]

		if not (_animation_context_submodel or _hidden_submodel ~= nil) then
			continue
		end

		local v2 = (_hidden_submodel or _animation_context_submodel and not self:AreAnimationsPlaying(_animation_context_submodel)) and 1 or 0

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") or descendant:IsA("Texture") then
				self:_LocalTransparencyModifier(descendant, "SubModelVisibility", v2)
			end
		end
	end
end

function object:_UpdateArms()
	WrapController:ResetWrap(self._original_wrap_properties)
	self._original_wrap_properties = nil
	self._right_arm_shirt_texture.Texture = self._shirt_id
	self._left_arm_shirt_texture.Texture = self._shirt_id
	self._right_arm.Color = self._right_arm_color
	self._left_arm.Color = self._left_arm_color
	self._right_arm_wrapped_part.Color = self._right_arm_color
	self._left_arm_wrapped_part.Color = self._left_arm_color

	if self.Name == "Hand Gun" then
		for _, child in pairs(self.ItemModel:GetChildren()) do
			if child:FindFirstChild("MeshPart") then
				child.MeshPart.Color = child:GetAttribute("IsRightHand") and self._right_arm_color or self._left_arm_color
			end
		end
	end

	self:_UpdateWrap()
end

function object:_Setup()
	if CosmeticLibrary.IGNORE_TRANSPARENCY_WHITELIST[self.ClientItem.Name] then
		for _, part in pairs(self.ItemModel:GetDescendants()) do
			if part:IsA("BasePart") then
				part:SetAttribute("IgnoreTransparency", true)
			end
		end
	end

	self.Model.Name = (not self.ClientItem.ClientFighter.Player and "???" or self.ClientItem.ClientFighter.Player.Name or "???") .. " - " .. self.ClientItem.Name .. " - " .. self.Name
	self._right_arm.Mesh.Scale = CONSTANTS.DEVICE == "VR" and createVector(0, 0, 0) or self._right_arm.Mesh.Scale
	self._left_arm.Mesh.Scale = CONSTANTS.DEVICE == "VR" and createVector(0, 0, 0) or self._left_arm.Mesh.Scale
	self._right_arm_wrapped_part = self.Model.RightArmWrapped
	self._right_arm_wrapped_part.Parent = nil
	self._wrapped_only_objects[self._right_arm_wrapped_part] = self.Model
	self._left_arm_wrapped_part = self.Model.LeftArmWrapped
	self._left_arm_wrapped_part.Parent = nil
	self._wrapped_only_objects[self._left_arm_wrapped_part] = self.Model
	self.ItemModel.Name = "ItemVisual"
	self.ItemModel.Parent = self.Model
	self._body_model = self.Model:FindFirstChild("Body")
	self._aim_position_attachment = self.Model:FindFirstChild("_aim_position", true)
	self._aim_lookat_attachment = self.Model:FindFirstChild("_aim_lookat", true)
	self._center_attachment = self.Model:FindFirstChild("_center", true)
	self._charm_attachment_model = self.Model:FindFirstChild("_charm_attachment_model", true)
	self._charm_pivot_attachment = self._charm_attachment_model and self._charm_attachment_model:FindFirstChild(
		"_charm_pivot_attachment",
		true
	) or self.Model:FindFirstChild("_charm_pivot_attachment", true)
	self._scope_glare_attachment = self.Model:FindFirstChild("_scope_glare", true)
	local primaryPart = self.Model.PrimaryPart
	local identity = CFrame.identity
	local v2 = nil

	for _, folder in pairs(self.ItemModel:GetChildren()) do
		if folder.Name == "_fake" then
			self._can_wrap_left_arm = folder:FindFirstChild("LeftArmWrapped")
			self._can_wrap_right_arm = folder:FindFirstChild("RightArmWrapped")
			task.defer(folder.Destroy, folder)
		else
			folder.PrimaryPart = folder.Primary
			v2 = v2 or folder.PrimaryPart.CFrame
			local v3 = folder.Name == "_right_arm" and "RightArm" or folder.Name == "_left_arm" and "LeftArm" or nil

			if v3 then
				self._arm_submodels[folder] = {
					OriginalScale = folder:GetScale(),
					HideInThirdPerson = folder:GetAttribute("HideInThirdPerson")
				}
				local v4 = self.Model[v3]
				folder.Parent = v4
				folder:PivotTo(v4.CFrame)
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = v4
				weldConstraint.Part1 = folder.PrimaryPart
				weldConstraint.Parent = folder.PrimaryPart
			else
				local motor6D = Instance.new("Motor6D")
				motor6D.Part0 = primaryPart
				motor6D.Part1 = folder.PrimaryPart
				motor6D.Name = "ItemVisual[\"" .. folder.Name .. "\"]"
				motor6D.C0 = folder:GetAttribute("C0") or folder.PrimaryPart.CFrame:ToObjectSpace(v2):Inverse() * identity
				motor6D.C1 = folder:GetAttribute("C1") or CFrame.identity
				motor6D.Parent = primaryPart
			end

			for _, part in pairs(folder:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.CastShadow = false
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Massless = true

				if part == folder.PrimaryPart then
					continue
				end

				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = folder.PrimaryPart
				weldConstraint.Part1 = part
				weldConstraint.Parent = folder.PrimaryPart
				part.Anchored = false
			end

			folder.PrimaryPart.Anchored = false

			if not v3 then
				folder.PrimaryPart.Name = folder.Name .. "Primary"
				folder:PivotTo(primaryPart.CFrame)
				local animationContexts = folder:GetAttribute("AnimationContexts")

				if animationContexts then
					self._animation_context_submodels[folder] = {}
					local v4 = 1

					for i = 1, #animationContexts do
						if string.sub(animationContexts, i - 1, i) ~= ", " then
							continue
						end

						table.insert(
							self._animation_context_submodels[folder],
							(string.sub(animationContexts, v4, i - 2))
						)
						v4 = i + 1
					end

					if v4 <= #animationContexts then
						table.insert(
							self._animation_context_submodels[folder],
							(string.sub(animationContexts, v4, #animationContexts))
						)
					end
				end

				if self._charm_pivot_attachment and self._charm_pivot_attachment:IsDescendantOf(folder) then
					self._charm_sub_model = folder
				end

				self._submodel_boundingbox_attachments[folder] = {}
				local boundingBox, v4 = folder:GetBoundingBox()

				for k, v5 in pairs(v) do
					local attachment = Instance.new("Attachment")
					attachment.Name = "_boundingbox" .. k
					attachment.Parent = folder.PrimaryPart
					attachment.WorldCFrame = boundingBox * CFrame.new(v4 * v5)
					table.insert(self._submodel_boundingbox_attachments[folder], attachment)
				end
			end
		end
	end

	for _, descendant in pairs(self.Model:GetDescendants()) do
		if descendant.Name ~= "_muzzle" then
			continue
		end

		table.insert(self._muzzle_attachments, descendant)
		local muzzleFlashParticlesName = descendant:GetAttribute("MuzzleFlashParticlesName")
		local v3 = muzzleFlashParticlesName and muzzleFlashes:FindFirstChild(muzzleFlashParticlesName) or muzzleFlashes:FindFirstChild(self.Name) or muzzleFlashes:FindFirstChild(self.ClientItem.Name) or muzzleFlashes.Default

		for _, child in pairs(v3.Attachment:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = descendant
		end
	end

	if self._scope_glare_attachment then
		self._scope_glare_gui1 = scopeGlareGui1:Clone()
		self._scope_glare_gui1.Enabled = false
		self._scope_glare_gui1.Parent = self._scope_glare_attachment
		self._scope_glare_gui2 = scopeGlareGui2:Clone()
		self._scope_glare_gui2.Enabled = false
		self._scope_glare_gui2.Parent = self._scope_glare_attachment
	end

	if self._charm_pivot_attachment then
		if self:Get("Charm") then
			local charm = self:Get("Charm")
			local child = charms:FindFirstChild(charm.Name, true)
			self.Charm = (child and require(child) or Charm).new(self, charm, self._charm_pivot_attachment)
			self.Charm:SetParent(self.Model)
		else
			if self._charm_pivot_attachment then
				self._charm_pivot_attachment:Destroy()
			end

			if self._charm_attachment_model then
				self._charm_attachment_model:Destroy()
			end
		end
	end

	if self.ClientItem.ClientFighter.IsLocalPlayer then
		for _, animation in pairs(self.Info.Animations) do
			SoundLibrary:PreloadSounds(SoundLibrary.AnimationSounds[animation], self._preloaded_sounds)
		end

		if SoundLibrary.ViewModelSounds[self.Name] then
			SoundLibrary:PreloadSounds(SoundLibrary.ViewModelSounds[self.Name], self._preloaded_sounds)
		end
	end

	self:SetArmsData(nil, nil, nil)
	self:SetParent(viewModels2)
	self:SetCFrame(CFrame.identity)
end

function object:_Init()
	self.Animator.AnimationPlayed:Connect(function(...)
		self.AnimationPlayed:Fire(...)
		self:_UpdateSubModelVisibility()
	end)
	self.Animator.AnimationStopped:Connect(function(...)
		self.AnimationStopped:Fire(...)
		self:_UpdateSubModelVisibility()
	end)
	table.insert(
		self._connections,
		self.ClientItem.ClientFighter:GetDataChangedSignal("IsSpectating"):Connect(function()
			self:_UpdateWrap()
		end)
	)
	table.insert(self._connections, PlayerDataController:GetSettingChangedSignal("Wraps Disabled"):Connect(function()
		self:_UpdateWrap()
	end))
	self:_Setup()
	self:_UpdateWrap()
end

return object