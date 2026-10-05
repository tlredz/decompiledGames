local createVector = vector.create
local ContextActionService = game:GetService("ContextActionService")
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
require(ReplicatedStorage.Modules.BetterDebris)
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
require(ReplicatedStorage.Modules.ItemLibrary)
require(ReplicatedStorage.Modules.TestLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local UserInterfaceController = require(Players.LocalPlayer.PlayerScripts.Controllers.UserInterfaceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local EmoteController = require(Players.LocalPlayer.PlayerScripts.Controllers.EmoteController)
local DebugState = require(Players.LocalPlayer.PlayerScripts.Controllers.DebugController.DebugState)
local v = { "Aim", "Sprint", "Crouch" }
local v2 = {
	Aim = false,
	Sprint = false,
	Crouch = false
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.StateChanged = Signal.new()
	self.SlideStep = Signal.new()
	self.LocalFighter = nil
	self.IsCrouching = false
	self.IsSprinting = false
	self.IsSliding = false
	self.CameraLean = 0
	self._internal_local_fighter_added = Signal.new()
	self._controls_connections = {}
	self._crouching_start_time = 0
	self._crouching_release_time = 0
	self._sprinting_start_time = 0
	self._sprinting_release_time = 0
	self._sliding_cooldown = 0
	self._sliding_start_time = 0
	self._sliding_release_time = 0
	self._sliding_velocity = nil
	self._sliding_last_floor = nil
	self._sliding_last_floor_physical_properties = nil
	self._update_slide_direction = nil
	self._is_input_spamming = {}
	self._mobile_input_down = {}
	self._is_leaning_right = false
	self._is_leaning_left = false
	self._original_jump_power = nil
	self._jump_hash = 0
	self._double_jumps_used = {}
	self._auto_shoot_hash = 0
	self._auto_shoot_connection = nil
	self._scroll_delta = 0.5
	self:_Init()
	return self
end

function class:AreInputsDisabled()
	if GamepadService.GamepadCursorEnabled or GuiService.SelectedObject or self.LocalFighter and self.LocalFighter:Get("IsHiddenByCutscene") then
		return true
	end

	if ControlsController.CurrentControls ~= "Gamepad" then
		return false
	end

	local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Equipment)
	local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)

	if Pages.PageSystem.CurrentPage or Equipment.IsOpen or SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject.DuelInterface.Voting:IsOpen() then
		return true
	end

	return false
end

function class:IsAlive()
	return self.LocalFighter and self.LocalFighter:IsAlive()
end

function class:IsFrozen()
	return self.LocalFighter and self.LocalFighter.Entity and self.LocalFighter.Entity:Get("IsFrozen")
end

function class:IsInputDown(p)
	local v3 = CameraController:GetPublicState() == CameraController.CameraState.States.ThirdPersonUnlockedMouse and { Enum.UserInputType.MouseButton2 } or nil

	if ControlsController.CurrentControls == "Touch" then
		return (self:IsMobileInputDown(p))
	end

	return (InputLibrary:IsInputDown(p, v3))
end

function class:IsMobileInputDown(p2)
	return self._mobile_input_down[p2]
end

function class.GetTimeSince(p, value, value2)
	return tick() - p["_" .. string.lower(value) .. "_" .. string.lower(value2) .. "_time"]
end

function class:SetCameraLean(cameraLean)
	self.CameraLean = cameraLean
	self.LocalFighter.LocalCameraLean = self.CameraLean
	self:_UpdateServerState("CameraLean", self.CameraLean)
end

function class:SetCrouching(isCrouching)
	if not isCrouching then
		ControlsController:ToggleInput("Crouch", false)
	end

	if isCrouching == self.IsCrouching then
		return
	end

	self.IsCrouching = isCrouching
	self.LocalFighter.IsCrouchingLocally = self.IsCrouching
	self[self.IsCrouching and "_crouching_start_time" or "_crouching_release_time"] = tick()
	self:_UpdateServerState("IsCrouching", self.IsCrouching)
	self.StateChanged:Fire("IsCrouching")
	self:_UpdateWalkSpeed()

	if self.IsCrouching then
		self:SetSprinting(false)
		self.LocalFighter.Entity.RootPart.Velocity = Vector3.new(
			self.LocalFighter.Entity.RootPart.Velocity.X,
			math.min(0, self.LocalFighter.Entity.RootPart.Velocity.Y),
			self.LocalFighter.Entity.RootPart.Velocity.Z
		)
	end
end

function class:SetSprinting(isSprinting)
	if isSprinting == self.IsSprinting then
		return
	end

	if not (self.LocalFighter and self.LocalFighter:CanSprint() and isSprinting) then
		isSprinting = false
	end

	self.IsSprinting = isSprinting
	self.LocalFighter.IsSprintingLocally = self.IsSprinting
	self[self.IsSprinting and "_sprinting_start_time" or "_sprinting_release_time"] = tick()
	self:_UpdateServerState("IsSprinting", self.IsSprinting)
	self.StateChanged:Fire("IsSprinting")
	self:_UpdateWalkSpeed()

	if self.IsSprinting then
		self:SetCrouching(false)
	end
end

function class:PlayMechanicsSound(...)
	if not self.LocalFighter then
		return
	end

	ReplicatedStorage.Remotes.Replication.Fighter.PlayMechanicsSound:FireServer(...)
	return self.LocalFighter:PlayMechanicsSound(...)
end

function class:StopSliding(p)
	if not self.IsSliding then
		return
	end

	if self._sliding_last_floor then
		self._sliding_last_floor.CustomPhysicalProperties = self._sliding_last_floor_physical_properties
		self._sliding_last_floor = nil
		self._sliding_last_floor_physical_properties = nil
	end

	if self._sliding_velocity then
		self._sliding_velocity:Destroy()
		self._sliding_velocity = nil
	end

	self._sliding_cooldown = tick() + 0.25
	self._update_slide_direction = nil
	self.IsSliding = false
	self.LocalFighter.IsSlidingLocally = false
	self._sliding_release_time = tick()
	self:_UpdateServerState("IsSliding", false)
	self.StateChanged:Fire("IsSliding")
	self:_UpdateWalkSpeed()

	if self:IsAlive() then
		self.LocalFighter.Entity:StopSlidingAnimation()
		self.LocalFighter.Entity.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)

		if p then
			local v3 = self.LocalFighter.Entity.RootPart.Velocity * 0.6 + Vector3.new(
				0,
				CONSTANTS.BASE_JUMPPOWER * 0.5,
				0
			)
			self.LocalFighter.Entity:AirborneTrigger(v3, 12, true)
		end

		if self:IsInputDown("Sprint") then
			self:SetSprinting(true)
		end
	end
end

function class:Slide()
	if self.IsSliding or tick() < self._sliding_cooldown or not self:IsAlive() or self.LocalFighter.Entity.Humanoid:GetState() == Enum.HumanoidStateType.Climbing or self.LocalFighter:AreItemsLocked() or not self.LocalFighter:CanSlide() or self:IsFrozen() then
		return
	end

	self._sliding_cooldown = 1e999
	self.IsSliding = true
	self.LocalFighter.IsSlidingLocally = true
	self._sliding_start_time = tick()
	self:_UpdateServerState("IsSliding", true)
	self.StateChanged:Fire("IsSliding")
	self.LocalFighter.Entity.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	self.LocalFighter.Entity.Humanoid.AutoRotate = false
	self.LocalFighter.Entity:AirborneCancel()
	self:SetCrouching(false)
	self:SetSprinting(false)
	self:_UpdateWalkSpeed()
	self._sliding_velocity = Instance.new("BodyVelocity")
	self._sliding_velocity.Parent = self.LocalFighter.Entity.RootPart
	local lastTime = tick()
	local Y = self.LocalFighter.Entity.RootPart.Position.Y
	local v3 = nil
	local v4 = nil
	local v5 = self:PlayMechanicsSound("Slide")
	local v6 = tick() + 0.25
	local rotation = self.LocalFighter.Entity.RootPart.CFrame.Rotation
	local _GetWalkSpeed = self:_GetWalkSpeed(true)

	function self._update_slide_direction(p)
		v4 = p or self.LocalFighter:GetMoveVector(true, true, self.LocalFighter.Entity.RootPart.CFrame.LookVector)
		task.spawn(self.LocalFighter.Entity.PlaySlidingAnimationAsync, self.LocalFighter.Entity, v4)
	end

	self._update_slide_direction()
	local v7 = 0

	while self:IsAlive() and self.IsSliding and tick() < lastTime + 1 do
		local floor = self.LocalFighter:GetFloor()
		local Y2 = self.LocalFighter.Entity.RootPart.Position.Y

		if floor then
			v3 = nil
		else
			v3 = v3 or tick()
		end

		if Y2 < Y - 1 then
			lastTime = tick()

			if v5 and v6 < tick() then
				v5.TimePosition = 0
				v5.Volume = 0
			end

			v6 = tick() + 0.25
			Y = Y2
		else
			Y = math.max(Y, Y2)
		end

		if v5 and v5.Volume == 0 and floor then
			v5.TimePosition = 0
			v5.Volume = 0.375
		end

		local lookVector = v4.Magnitude <= 0.01 and self.LocalFighter.Entity.RootPart.CFrame.LookVector or v4.Unit
		local normal = createVector(0, 1, 0)

		if floor ~= self._sliding_last_floor then
			if self._sliding_last_floor then
				self._sliding_last_floor.CustomPhysicalProperties = self._sliding_last_floor_physical_properties
				self._sliding_last_floor = nil
				self._sliding_last_floor_physical_properties = nil
			end

			if floor and not floor:IsA("Terrain") then
				self._sliding_last_floor = floor
				self._sliding_last_floor_physical_properties = self._sliding_last_floor.CurrentPhysicalProperties
			end
		end

		if floor then
			local position = self.LocalFighter.Entity.RootPart.Position
			local v8 = position + lookVector * 0.1
			local raycastResult = Utility:Raycast(
				position,
				position + createVector(0, -1, 0),
				999,
				{ floor },
				Enum.RaycastFilterType.Include
			)
			local raycastResult2 = Utility:Raycast(
				v8,
				v8 + createVector(0, -1, 0),
				999,
				{ floor },
				Enum.RaycastFilterType.Include
			)

			if Utility:AngleBetweenVectors(
				(raycastResult2.Position - raycastResult.Position).Unit,
				createVector(-0, -1, -0)
			) > 0.7853981633974483 then
				lookVector = (raycastResult2.Position - raycastResult.Position).Unit
				normal = raycastResult2.Normal or raycastResult.Normal or normal
			end
		end

		if normal.Magnitude < 0.5 then
			self.SlideStep:Fire()
		end

		if floor then
			v7 = (tick() - lastTime) / 1 or v7
		end

		local slidingSpeedMax = self.LocalFighter:Get("SlidingSpeedMax") or 3
		local v8 = lookVector * (slidingSpeedMax + (1 - slidingSpeedMax) * v7) * _GetWalkSpeed
		local v9 = not v3 and createVector(0, 0, 0) or normal * -workspace.Gravity * (tick() - v3) ^ 2
		self._sliding_velocity.Velocity = v8 + v9
		self._sliding_velocity.MaxForce = Vector3.new(1, v3 and 0.1 or 1, 1) * 100000

		if v8.Magnitude > 0.01 then
			self.LocalFighter.Entity.RootPart.CFrame = self.LocalFighter.Entity.RootPart.CFrame:Lerp(
				CFrame.new(self.LocalFighter.Entity.RootPart.Position, self.LocalFighter.Entity.RootPart.Position + v8),
				0.25
			)
			rotation = self.LocalFighter.Entity.RootPart.CFrame.Rotation
		else
			self.LocalFighter.Entity.RootPart.CFrame = CFrame.new(self.LocalFighter.Entity.RootPart.Position) * rotation
		end

		RunService.RenderStepped:Wait()
	end

	v5:Destroy()

	if self.IsSliding then
		self:StopSliding()
	end
end

function class:Jump(p, value, p2)
	if not self:IsAlive() or self:IsFrozen() or not p2 and self.LocalFighter.Entity:IsAirborne() then
		return
	end

	self._original_jump_power = self._original_jump_power or self.LocalFighter.Entity.Humanoid.JumpPower
	self._jump_hash += 1
	local _jump_hash = self._jump_hash
	self.LocalFighter.Entity.Humanoid.JumpPower = (p or self._original_jump_power) * (value or 1)
	self.LocalFighter.Entity.Humanoid.Jump = true

	if p or value then
		task.defer(function()
			if _jump_hash ~= self._jump_hash or not self:IsAlive() then
				return
			end

			self.LocalFighter.Entity.Humanoid.JumpPower = self._original_jump_power
			self._original_jump_power = nil
		end)
	end
end

function class:DoubleJump()
	if not self:IsAlive() or self:IsFrozen() then
		return
	end

	local moveVector = self.LocalFighter:GetMoveVector(true, true)
	self.LocalFighter.Entity.RootPart.Velocity = moveVector * self.LocalFighter.Entity.Humanoid.WalkSpeed * 1 + Vector3.new(
		0,
		self.LocalFighter.Entity.Humanoid.JumpPower * 1.1,
		0
	)
	self.LocalFighter.Entity:AirborneRedirect()
	self:PlayMechanicsSound("DoubleJump")
end

function class:JumpRequest(...)
	self:Jump(...)
end

function class:DoubleJumpRequest()
	local objectID = self.LocalFighter and self.LocalFighter.EquippedItem and self.LocalFighter.EquippedItem:Get("ObjectID")
	local maxDoubleJumps = self.LocalFighter and self.LocalFighter.EquippedItem and not self.LocalFighter:Get("DisableDoubleJumping") and self.LocalFighter.EquippedItem.Info.MaxDoubleJumps

	if objectID and maxDoubleJumps and (self._double_jumps_used[objectID] or 0) < (maxDoubleJumps or 0) and not self.LocalFighter:IsGrounded() then
		self._double_jumps_used[objectID] = (self._double_jumps_used[objectID] or 0) + 1
		self:DoubleJump()
	end
end

function class:HighJump()
	if not self:IsAlive() then
		return
	end

	self:StopSliding(true)
	self:_SpamJumpRequests(nil, 1.25, true)
end

function class:EquippedItemInput(...)
	if not self.LocalFighter then
		return
	end

	self.LocalFighter:Input(...)
end

function class:SimulateInputBegan(p, p2)
	if InputLibrary:InputIs(p, "UseEmote") then
		local page = UserInterfaceController:GetPage("PickEmote")

		if page and page:IsOpen() then
			page:SetAllEmotesOpen(true)
		end
	end

	if self:AreInputsDisabled() then
		return
	end

	for _, v3 in pairs(v) do
		if InputLibrary:InputIs(p, v3) and ControlsController:IsToggled(v3) then
			ControlsController:ToggleInput(v3, false)
			return self:SimulateInputEnded(p, p2)
		elseif InputLibrary:InputIs(p, v3) and self:_IsToggleInput(v3) then
			ControlsController:ToggleInput(v3, true)
		end
	end

	if p2 and not UserInterfaceController:IsPageOpen("Panels") and ControlsController.CurrentControls == "MouseKeyboard" or CameraController:GetPublicState() == CameraController.CameraState.States.ThirdPersonUnlockedMouse and p.UserInputType == Enum.UserInputType.MouseButton2 then
		return
	end

	if InputLibrary:InputIs(p, "OpenPlayerList") then
		if SpectateController.CurrentDuelSubject then
			SpectateController.CurrentDuelSubject.DuelInterface.Scoreboard:Open(true)
		end
	elseif InputLibrary:InputIs(p, "Ping") then
		self.LocalFighter:Ping()
	end

	if not self:IsAlive() then
		return
	end

	if InputLibrary:InputIs(p, "Jump") and self.LocalFighter.Entity.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing then
		if self.IsSliding then
			self:HighJump()
			return
		end

		self:DoubleJumpRequest()
		self:_SpamJumpRequests()
	elseif InputLibrary:InputIs(p, "Crouch") and not (self.IsSliding or self:IsFrozen()) then
		local isSprinting = self.IsSprinting or tick() - self._sprinting_release_time < 0.125
		local v3

		if ControlsController.CurrentControls == "Touch" then
			v3 = PlayerDataController:GetSetting("Easy Slide Mobile")
		else
			v3 = PlayerDataController:GetSetting("Easy Slide")
		end

		if v3 and isSprinting and self.LocalFighter:GetMoveVector(true, true).Magnitude > 0.01 and self.LocalFighter:IsGrounded() then
			self:Slide()
		else
			self:SetCrouching(true)
		end
	elseif InputLibrary:InputIs(p, "Slide") and not self.IsSliding and self.LocalFighter:IsGrounded() then
		self:Slide()
	elseif (InputLibrary:InputIs(p, "Sprint") or InputLibrary:InputIs(p, "AutoSprint")) and not self.IsSliding then
		self:SetSprinting(true)
	elseif InputLibrary:InputIs(p, "LeanLeft") then
		if not self._is_leaning_left then
			self._is_leaning_left = true
			self:SetCameraLean(self.CameraLean - 1)
		end
	elseif InputLibrary:InputIs(p, "LeanRight") then
		if not self._is_leaning_right then
			self._is_leaning_right = true
			self:SetCameraLean(self.CameraLean + 1)
		end
	else
		if EmoteController:CanEmote() then
			for i = 1, CONSTANTS.MAX_EQUIPPABLE_EMOTES do
				if InputLibrary:InputIs(p, "UseEmote" .. i) then
					EmoteController:UseEmote((tostring(i)))
				end
			end
		end

		if InputLibrary:InputIs(p, "EquipPrimary") then
			self.LocalFighter:EquipItem(1)
		elseif InputLibrary:InputIs(p, "EquipSecondary") then
			self.LocalFighter:EquipItem(2)
		elseif InputLibrary:InputIs(p, "EquipMelee") then
			self.LocalFighter:EquipItem(3)
		elseif InputLibrary:InputIs(p, "EquipUtility") then
			self.LocalFighter:EquipItem(4)
		elseif InputLibrary:InputIs(p, "EquipLast") then
			self.LocalFighter:EquipIncrement(-1)
		elseif InputLibrary:InputIs(p, "EquipNext") then
			self.LocalFighter:EquipIncrement(1)
		elseif InputLibrary:InputIs(p, "QuickMelee") then
			self.LocalFighter:QuickAttackDown("Melee", p)
		elseif InputLibrary:InputIs(p, "QuickUtility") then
			self.LocalFighter:QuickAttackDown("Utility", p)
		elseif InputLibrary:InputIs(p, "UseEmote") and EmoteController:CanEmote() then
			local page = UserInterfaceController:GetPage("PickEmote")

			if not (page and page:IsOpen()) then
				UserInterfaceController:OpenPage("PickEmote", true)
			end
		elseif self.LocalFighter.EquippedItem then
			for _, itemInput in pairs(InputLibrary.ItemInputs) do
				if not InputLibrary:InputIs(p, itemInput) then
					continue
				end

				local v3 = itemInput
				task.spawn(function()
					local startName = InputLibrary.Inputs[v3].StartName

					if self.LocalFighter.EquippedItem.Info.InputSpammingEnabled[startName] then
						self:_InputSpam(v3, startName)
					else
						self:EquippedItemInput(startName)
					end
				end)
			end
		elseif InputLibrary:InputIs(p, "Shoot") and self.LocalFighter.Entity and self.LocalFighter.Entity:Get("IsGrabbingSnowball") then
			local cameraData = self.LocalFighter:GetCameraData(nil, nil, true, true)
			local v3 = cameraData[utf8.char(2)]
			local v4 = cameraData[utf8.char(3)]
			local v5 = v3 and v3.CFrame * v4

			if v5 then
				ReplicatedStorage.Remotes.Replication.Fighter.SnowballThrow:FireServer(v5.Position)
			end
		end
	end
end

function class:SimulateInputEnded(p)
	if not self.LocalFighter or CameraController:GetPublicState() == CameraController.CameraState.States.ThirdPersonUnlockedMouse and p.UserInputType == Enum.UserInputType.MouseButton2 then
		return
	end

	for _, v3 in pairs(v) do
		if InputLibrary:InputIs(p, v3) and self:_IsToggleInput(v3) and ControlsController:IsToggled(v3) then
			return
		end
	end

	if InputLibrary:InputIs(p, "Crouch") then
		if self.IsCrouching then
			self:SetCrouching(false)

			if self:IsInputDown("Sprint") then
				self:SetSprinting(true)
			end
		end
	elseif InputLibrary:InputIs(p, "Sprint") or InputLibrary:InputIs(p, "AutoSprint") then
		self:SetSprinting(false)
	elseif InputLibrary:InputIs(p, "LeanLeft") then
		if self._is_leaning_left then
			self._is_leaning_left = false
			self:SetCameraLean(self.CameraLean + 1)
		end
	elseif InputLibrary:InputIs(p, "LeanRight") and self._is_leaning_right then
		self._is_leaning_right = false
		self:SetCameraLean(self.CameraLean - 1)
	end

	if InputLibrary:InputIs(p, "QuickMelee") then
		self.LocalFighter:QuickAttackUp("Melee")
	elseif InputLibrary:InputIs(p, "QuickUtility") then
		self.LocalFighter:QuickAttackUp("Utility")
	elseif InputLibrary:InputIs(p, "OpenPlayerList") then
		if SpectateController.CurrentDuelSubject then
			SpectateController.CurrentDuelSubject.DuelInterface.Scoreboard:Open(false)
		end
	elseif InputLibrary:InputIs(p, "UseEmote") and ControlsController.CurrentControls == "MouseKeyboard" then
		local page = UserInterfaceController:GetPage("PickEmote")

		if page then
			page:PickEarly()
		end
	elseif self.LocalFighter.EquippedItem then
		for _, itemInput in pairs(InputLibrary.ItemInputs) do
			if InputLibrary:InputIs(p, itemInput) then
				self:EquippedItemInput(InputLibrary.Inputs[itemInput].FinishName)
			end
		end
	end
end

function class:MobileInput(p, p2)
	if p2 and self:AreInputsDisabled() then
		return
	end

	local mobileButton = InputLibrary.MobileButtons[p]
	local _mobile_input_down = self._mobile_input_down
	local v3

	if mobileButton then
		v3 = mobileButton.InputName or p
	else
		v3 = p
	end

	_mobile_input_down[v3] = p2
	self[p2 and "SimulateInputBegan" or "SimulateInputEnded"](self, p, false)
end

function class:WaitForLocalFighter()
	if not self.LocalFighter then
		self._internal_local_fighter_added:Wait()
	end

	return self.LocalFighter
end

function class:_CanAutoShoot()
	if self.LocalFighter and self.LocalFighter.EquippedItem and not self.LocalFighter:Get("IsHiddenByCutscene") then
		return ControlsController.CurrentControls == "Touch" or ControlsController.CurrentControls == "Gamepad" or (self.LocalFighter:Get("CheaterMode") or DebugState:Get("AreHandicapsEnabled"))
	end

	return false
end

function class:_ToggleAutoShoot()
	self._auto_shoot_hash += 1
	local _auto_shoot_hash = self._auto_shoot_hash

	if self._auto_shoot_connection then
		self._auto_shoot_connection:Disconnect()
		self._auto_shoot_connection = nil
	end

	if not self:_CanAutoShoot() then
		return
	end

	local cheaterMode = self.LocalFighter:Get("CheaterMode")
	local v3 = cheaterMode and 0 or PlayerDataController:GetSetting("Auto Shoot Reaction Time") / 1000
	local setting

	if not cheaterMode then
		setting = PlayerDataController:GetSetting("Auto Shoot")
	end

	local autoShootRestriction

	if not cheaterMode then
		autoShootRestriction = self.LocalFighter:Get("AutoShootRestriction")
	end

	local v4

	if cheaterMode then
		v4 = nil
	else
		v4 = autoShootRestriction or setting
	end

	if setting == "Disabled" or autoShootRestriction == "Disabled" then
		return
	end

	local raycastWhitelist = nil
	local v5 = 0
	local v6 = true

	local function can_autoshoot()
		if not (self.LocalFighter and self.LocalFighter.EquippedItem and self.LocalFighter:IsAlive()) then
			return
		end

		local autoShootReactionTime = self.LocalFighter.EquippedItem:GetAutoShootReactionTime()
		local autoShootReach = self.LocalFighter.EquippedItem:GetAutoShootReach()

		if not (autoShootReactionTime and autoShootReach) then
			return
		end

		local now = tick()

		if v5 < now then
			v5 = tick() + 2
			raycastWhitelist = self.LocalFighter:GetRaycastWhitelist(true, { self.LocalFighter }, nil, true)
		end

		if Players.LocalPlayer.PlayerGui:FindFirstChild("FlashbangGui") then
			return
		end

		local raycastResult = Utility:Raycast(
			workspace.CurrentCamera.CFrame.Position,
			workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * autoShootReach,
			autoShootReach,
			raycastWhitelist,
			Enum.RaycastFilterType.Include
		)

		if not raycastResult.Instance then
			return
		end

		if not (Utility:AngleBetweenVectors(
			workspace.CurrentCamera.CFrame.LookVector,
			CFrame.new(self.LocalFighter.Entity.RootPart.Position, raycastResult.Instance.Position).LookVector
		) < 1.5707963267948966) then
			return
		end

		local entityFromModel = raycastResult.Instance and raycastResult.Instance.AssemblyRootPart and raycastResult.Instance.AssemblyRootPart.Parent and raycastResult.Instance.AssemblyRootPart.Parent:HasTag("Entity") and GameplayUtility:GetEntityFromModel(raycastResult.Instance.AssemblyRootPart.Parent)

		if entityFromModel and not entityFromModel.AimAssistBlacklist and entityFromModel:IsAlive() and not GameplayUtility:GetSmokeCloudBetweenPoints(
			workspace.CurrentCamera.CFrame.Position,
			raycastResult.Position
		) then
			return self.LocalFighter.EquippedItem, autoShootReactionTime
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish_shooting(value)
		if not v6 then
			return
		end

		v6 = false
		task.delay(value or 0, self.EquippedItemInput, self, "FinishShooting")
	end

	local function start_shooting()
		v6 = true
		self:EquippedItemInput("StartShooting")

		if self.LocalFighter.EquippedItem and self.LocalFighter.EquippedItem.Name ~= "Flamethrower" then
			if not v6 then
				return
			end

			v6 = false
			task.delay(0.03, self.EquippedItemInput, self, "FinishShooting")
		end
	end

	local flag = false

	local function hold(p)
		if flag then
			return
		end

		flag = true
		local equippedItem = self.LocalFighter.EquippedItem
		local v7 = tick() + p

		while true do
			local _, v8 = can_autoshoot()

			if not v8 or self.LocalFighter.EquippedItem ~= equippedItem then
				break
			end

			if v7 < tick() then
				v6 = true
				self:EquippedItemInput("StartShooting")

				if self.LocalFighter.EquippedItem and self.LocalFighter.EquippedItem.Name ~= "Flamethrower" and v6 then
					v6 = false
					task.delay(0.03, self.EquippedItemInput, self, "FinishShooting")
				end
			end

			RunService.RenderStepped:Wait()

			if _auto_shoot_hash ~= self._auto_shoot_hash then
				return
			end
		end

		flag = false
	end

	self._auto_shoot_connection = RunService.RenderStepped:Connect(function()
		if flag then
			return
		end

		local _, v7 = can_autoshoot()

		if v7 then
			local v8

			if v4 == "Dynamic" then
				v8 = math.clamp(v7, 0.025, 0.125)
			else
				v8 = v3
			end

			task.defer(hold, v8)
		else
			finish_shooting() -- equivalent call inferred; original call site unknown
		end
	end)
end

function class:_IsToggleInput(p2)
	local setting

	if ControlsController.CurrentControls == "Touch" then
		setting = v2[p2]
	end

	local v3 = "Toggle " .. p2

	if setting == nil then
		setting = SettingsLibrary.Info[v3] and PlayerDataController:GetSetting(v3)
	end

	local toggleAimEnabled = self.LocalFighter and self.LocalFighter.EquippedItem and self.LocalFighter.EquippedItem.ToggleAimEnabled
	return setting and (p2 ~= "Aim" or toggleAimEnabled)
end

function class:_AutoSprintEnabled()
	return PlayerDataController:GetSetting("Auto Sprint") or ControlsController.CurrentControls == "Touch"
end

function class:_UpdateServerState(p, ...)
	ReplicatedStorage.Remotes.Replication.Fighter.UpdateState:FireServer(EnumLibrary:ToEnum(p), ...)
end

function class:_InputSpam(p, p2)
	if self._is_input_spamming[p] then
		return
	end

	self._is_input_spamming[p] = true

	while self.LocalFighter and self.LocalFighter.EquippedItem and self.LocalFighter.EquippedItem.Info.InputSpammingEnabled[p2] and self:IsInputDown(p) do
		local _IsToggleInput = self:_IsToggleInput(p)
		self:EquippedItemInput(p2)
		local v3 = not _IsToggleInput and self.LocalFighter.EquippedItem.Info.InputSpammingEnabled[p2]

		if not v3 then
			break
		end

		if v3 <= 0 then
			RunService.RenderStepped:Wait()
		else
			wait(v3)
		end
	end

	self._is_input_spamming[p] = false
end

function class:_SpamJumpRequests(...)
	while not self.IsSliding and self:IsInputDown("Jump") do
		self:JumpRequest(...)
		RunService.RenderStepped:Wait()
	end
end

function class:_GetWalkSpeed(p)
	if self:IsFrozen() then
		return 0
	end

	local isEmoting = self.LocalFighter.Entity:IsEmoting()
	local currentEmote = self.LocalFighter.Entity:GetCurrentEmote()
	local isPageOpen = UserInterfaceController:IsPageOpen()
	local v3 = ((not self.IsSprinting or isEmoting) and 0 or self.LocalFighter:Get("SprintingSpeedBoost") or 0.5) + (not (self.LocalFighter and self.LocalFighter.Entity) and 0 or self.LocalFighter.Entity:GetBoost("Speed") or 0)
	local v4 = isPageOpen and isPageOpen.Name == "PickEmote" and 0 or 1
	local traversalWalkSpeedMultiplier = isEmoting and CosmeticLibrary.Cosmetics[currentEmote.Name].TraversalWalkSpeedMultiplier or 1
	local v5 = not (self.LocalFighter and self.LocalFighter.EquippedItem) and 1 or self.LocalFighter.EquippedItem.Info.WalkSpeedMultiplier or 1
	local v6 = self.IsCrouching and 0.5 or 1
	local v7 = self.IsSliding and not p and 0 or 1
	local v8 = v4 * traversalWalkSpeedMultiplier * v5 * v6 * v7
	return CONSTANTS.BASE_WALKSPEED * (1 + v3) * v8
end

function class:_UpdateWalkSpeed()
	if self.IsSliding or not self:IsAlive() then
		return
	end

	self.LocalFighter.Entity.Humanoid.WalkSpeed = self:_GetWalkSpeed()
end

function class:_UpdateCharacterRotation()
	if self.IsSliding or not self:IsAlive() then
		return
	end

	local publicState = CameraController:GetPublicState()
	local isEmoting = self.LocalFighter.Entity:IsEmoting()
	self.LocalFighter.Entity.Humanoid.AutoRotate = not publicState or publicState == CameraController.CameraState.States.ThirdPersonUnlockedMouse

	if not publicState or publicState == CameraController.CameraState.States.CustomFreecam or publicState == CameraController.CameraState.States.ThirdPersonUnlockedMouse and isEmoting then
		return
	end

	local v3 = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)

	if v3.Magnitude > 0.01 then
		self.LocalFighter.Entity.RootPart.CFrame = CFrame.new(
			self.LocalFighter.Entity.RootPart.Position,
			self.LocalFighter.Entity.RootPart.Position + v3
		)
	end
end

function class:_SetupControls()
	for _, _controls_connection in pairs(self._controls_connections) do
		_controls_connection:Disconnect()
	end

	self._controls_connections = {}

	if self:IsMobileInputDown("AutoSprint") then
		task.spawn(self.MobileInput, self, "AutoSprint", false)
	end

	if not self.LocalFighter then
		return
	end

	RunService.RenderStepped:Connect(function()
		self:_UpdateCharacterRotation()
		self:_UpdateWalkSpeed()

		if not self:_AutoSprintEnabled() then
			return
		end

		local moveVector = self.LocalFighter and not (self.IsCrouching or self.IsSliding) and self.LocalFighter:GetMoveVector()
		local v3 = moveVector and moveVector.Magnitude >= 0.9

		if v3 and not self.IsSprinting then
			self:MobileInput("AutoSprint", true)
		elseif not v3 and self.IsSprinting then
			self:MobileInput("AutoSprint", false)
		end
	end)

	if ControlsController.CurrentControls == "Touch" then
		return
	end

	table.insert(self._controls_connections, UserInputService.InputBegan:Connect(function(...)
		self:SimulateInputBegan(...)
	end))
	table.insert(self._controls_connections, UserInputService.InputEnded:Connect(function(...)
		self:SimulateInputEnded(...)
	end))

	if ControlsController.CurrentControls == "MouseKeyboard" then
		table.insert(self._controls_connections, UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if gameProcessed or CameraController:GetPublicState() == CameraController.CameraState.States.ThirdPersonUnlockedMouse or not (self:IsAlive() and PlayerDataController:GetSetting("Scroll Equip")) then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local v3 = math.floor(self._scroll_delta + input.Position.Z) - math.floor(self._scroll_delta)
				self._scroll_delta += input.Position.Z

				if math.abs(v3) > 0 then
					self.LocalFighter:EquipIncrement(-math.sign(v3))
				end
			end
		end))
	end
end

function class._BindMovementActionsLoop(_)
	local ControlModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	local Keyboard = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"):WaitForChild("Keyboard"))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function get_keyboard_module()
		for k, controller in pairs(ControlModule.controllers) do
			if k == Keyboard then
				return controller
			end
		end
	end

	local v3 = {
		WalkForward = { "moveForwardAction", function(_, p, _)
				local controller = get_keyboard_module() -- equivalent call inferred; original call site unknown

				if not controller then
					return
				end

				controller.forwardValue = p == Enum.UserInputState.Begin and -1 or 0
				controller:UpdateMovement(p)
				return Enum.ContextActionResult.Pass
			end },
		WalkBackward = { "moveBackwardAction", function(_, p, _)
				local controller = get_keyboard_module() -- equivalent call inferred; original call site unknown

				if not controller then
					return
				end

				controller.backwardValue = p == Enum.UserInputState.Begin and 1 or 0
				controller:UpdateMovement(p)
				return Enum.ContextActionResult.Pass
			end },
		WalkLeftward = { "moveLeftAction", function(_, p, _)
				local controller = get_keyboard_module() -- equivalent call inferred; original call site unknown

				if not controller then
					return
				end

				controller.leftValue = p == Enum.UserInputState.Begin and -1 or 0
				controller:UpdateMovement(p)
				return Enum.ContextActionResult.Pass
			end },
		WalkRightward = { "moveRightAction", function(_, p, _)
				local controller = get_keyboard_module() -- equivalent call inferred; original call site unknown

				if not controller then
					return
				end

				controller.rightValue = p == Enum.UserInputState.Begin and 1 or 0
				controller:UpdateMovement(p)
				return Enum.ContextActionResult.Pass
			end }
	}

	local function update(p)
		local v4, v5 = table.unpack(v3[p])

		if ContextActionService:GetBoundActionInfo(v4) then
			ContextActionService:UnbindAction(v4)
		end

		local inputs = InputLibrary:GetInputs(p)

		if inputs and #inputs > 0 then
			ContextActionService:BindActionAtPriority(v4, v5, false, 2000, table.unpack(inputs))
		end
	end

	for k in pairs(v3) do
		for _, v4 in pairs(InputLibrary.HOTKEY_FORMATS) do
			for _, formatString in pairs(v4) do
				local v5 = k
				PlayerDataController:GetSettingChangedSignal(string.format(formatString, k)):Connect(function()
					update(v5)
				end)
			end
		end
	end

	while true do
		for k, list in pairs(v3) do
			local v4, _ = table.unpack(list)
			local boundActionInfo = ContextActionService:GetBoundActionInfo(v4)
			local v5 = not (boundActionInfo and boundActionInfo.inputTypes and boundActionInfo.inputTypes[1])

			if not v5 then
				if typeof(boundActionInfo.inputTypes[1]) == "EnumItem" then
					v5 = boundActionInfo.inputTypes[1].EnumType == Enum.PlayerActions
				else
					v5 = false
				end
			end

			if v5 then
				update(k)
			end
		end

		wait(1)
	end
end

function class._DisableRobloxJumpButton(_)
	while true do
		if next(ContextActionService:GetBoundActionInfo("jumpAction") or {}) then
			ContextActionService:UnbindAction("jumpAction")
		end

		wait(1)
	end
end

function class:_HookFighter()
	local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
	self.LocalFighter = FighterController:WaitForLocalFighter()
	self.LocalFighter.StopSliding:Connect(function()
		self:StopSliding()
	end)
	self.LocalFighter:GetDataChangedSignal("AutoShootRestriction"):Connect(function()
		self:_ToggleAutoShoot()
	end)
	self.LocalFighter:GetDataChangedSignal("CheaterMode"):Connect(function()
		self:_ToggleAutoShoot()
	end)
	self.LocalFighter:GetDataChangedSignal("IsHiddenByCutscene"):Connect(function()
		self:_ToggleAutoShoot()
	end)
	local connections = {}
	self.LocalFighter.EquippedItemChanged:Connect(function(p)
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		connections = {}
		self:_UpdateWalkSpeed()
		self:_ToggleAutoShoot()

		if not p then
			return
		end

		table.insert(connections, p.StopSprinting:Connect(function()
			self:SetSprinting(false)
		end))
		table.insert(connections, p.AttemptToSprintAgain:Connect(function()
			if self:IsInputDown("Sprint") or self:IsInputDown("AutoSprint") then
				self:SetSprinting(true)
			end
		end))
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_auto_jump()
		if self.LocalFighter.Entity and self.LocalFighter.Entity.Humanoid then
			self.LocalFighter.Entity.Humanoid.AutoJumpEnabled = PlayerDataController:GetSetting("Auto Jump") or self.LocalFighter.Entity:IsAirborne()
		end
	end

	PlayerDataController:GetSettingChangedSignal("Auto Jump"):Connect(update_auto_jump)

	local function entity_added(instance)
		self._original_humanoid_animations = {}
		self._double_jumps_used = {}
		self:SetCrouching(false)
		self:SetSprinting(false)
		self:StopSliding()
		self:_UpdateWalkSpeed()
		instance.Humanoid.CameraOffset = createVector(0, 1, 0)
		local bodyForce = Instance.new("BodyForce")
		bodyForce.Name = "CustomGravity"
		bodyForce.Parent = instance.RootPart

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update_gravity()
			local gravity = not self.IsCrouching and instance:Get("Gravity") or 1
			local v3 = CONSTANTS.BASE_GRAVITY * gravity
			local assemblyMass = instance.RootPart.AssemblyMass
			bodyForce.Force = Vector3.new(0, assemblyMass * workspace.Gravity * (1 - v3), 0)
			instance.Humanoid.JumpPower = CONSTANTS.BASE_JUMPPOWER
		end

		instance:GetDataChangedSignal("Gravity"):Connect(update_gravity)
		instance.EmoteStatusChanged:Connect(update_gravity)
		self.StateChanged:Connect(update_gravity)
		local v3 = self.IsCrouching and 1 or instance:Get("Gravity") or 1
		local v4 = CONSTANTS.BASE_GRAVITY * v3
		bodyForce.Force = Vector3.new(0, instance.RootPart.AssemblyMass * workspace.Gravity * (1 - v4), 0)
		instance.Humanoid.JumpPower = CONSTANTS.BASE_JUMPPOWER

		-- equivalent calls inferred from this helper; original call sites unknown
		local function descendant_added(part)
			if part:IsA("BasePart") then
				part:GetPropertyChangedSignal("AssemblyMass"):Connect(update_gravity)
				part:GetPropertyChangedSignal("Mass"):Connect(update_gravity)
			end
		end

		instance.Model.DescendantAdded:Connect(descendant_added)

		for _, descendant in pairs(instance.Model:GetDescendants()) do
			descendant_added(descendant) -- equivalent call inferred; original call site unknown
		end

		instance.Humanoid.Jumping:Connect(function()
			update_gravity() -- equivalent call inferred; original call site unknown
			self:StopSliding(true)
		end)
		instance.Humanoid.StateChanged:Connect(function(_, p)
			local v5 = self.IsCrouching and 1 or instance:Get("Gravity") or 1
			local v6 = CONSTANTS.BASE_GRAVITY * v5
			local assemblyMass = instance.RootPart.AssemblyMass
			bodyForce.Force = Vector3.new(0, assemblyMass * workspace.Gravity * (1 - v6), 0)
			instance.Humanoid.JumpPower = CONSTANTS.BASE_JUMPPOWER

			if p == Enum.HumanoidStateType.Climbing then
				self:StopSliding()
			elseif p == Enum.HumanoidStateType.Landed then
				self._double_jumps_used = {}
			end
		end)
		instance.Humanoid.Died:Connect(function()
			self:SetSprinting(false)
			self:SetCrouching(false)
			self:StopSliding()
		end)
		instance.AirborneChanged:Connect(function()
			self:_UpdateServerState("IsAirborne", instance:IsAirborne())
			update_auto_jump() -- equivalent call inferred; original call site unknown
		end)
		instance.RedirectSliding:Connect(function(p)
			if self._update_slide_direction then
				self._update_slide_direction(p)
			end
		end)
		update_auto_jump() -- equivalent call inferred; original call site unknown
	end

	self.LocalFighter.EntityAdded:Connect(entity_added)

	if self.LocalFighter.Entity then
		task.spawn(entity_added, self.LocalFighter.Entity)
	end

	self._internal_local_fighter_added:Fire()
	self:_SetupControls()
	self:_ToggleAutoShoot()
	task.defer(self._DisableRobloxJumpButton, self)
	task.defer(self._BindMovementActionsLoop, self)
end

function class:_Init()
	ControlsController.ControlsChanged:Connect(function()
		self:_SetupControls()
		self:_ToggleAutoShoot()
	end)
	PlayerDataController:GetSettingChangedSignal("Auto Shoot"):Connect(function()
		self:_ToggleAutoShoot()
	end)
	PlayerDataController:GetSettingChangedSignal("Auto Shoot Reaction Time"):Connect(function()
		self:_ToggleAutoShoot()
	end)
	DebugState:GetDataChangedSignal("AreHandicapsEnabled"):Connect(function()
		self:_ToggleAutoShoot()
	end)
	task.defer(self._HookFighter, self)
end

return class._new()