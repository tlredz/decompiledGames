local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local Custom = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Custom)
local projectiles = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Projectiles")
local object = setmetatable({}, Custom)
object.__index = object

function object.new(...)
	local self = setmetatable(Custom.new(...), object)
	self.Data.GrapplingHookPartActive = false
	self._use_cooldown = 0
	self._use_cooldown_hash = 0
	self._use_animation_hash = 0
	self._current_hook_connections = {}
	self._current_hook_part = nil
	self._current_hook_velocity = nil
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(_)
	return nil
end

function object:CanQuickAttack()
	return tick() > self._use_cooldown and not self:IsEquipping()
end

function object:StartShooting(p)
	if not p and (tick() < self._use_cooldown or self:IsEquipping()) then
		return false
	end

	self._use_cooldown_hash += 1
	self._use_animation_hash += 1
	local _use_cooldown_hash = self._use_cooldown_hash
	local _use_animation_hash = self._use_animation_hash
	local v = self.Info.HookRange / self.Info.HookSpeed
	self._use_cooldown = tick() + v + self.Info.MissedCooldown
	self:CooldownEffect("rbxassetid://101933751328343", v, "Cooldown", true)
	self.ViewModel:StopAnimation("Inspect", 0)
	self.ViewModel:StopAnimation("Equip", 0)
	self.ViewModel:StopAnimation("Inspect", 0)
	self.ViewModel:StopAnimation("Pull", 0)
	task.spawn(function()
		if self.ViewModel.Info.Animations.ShootMissed then
			self.ViewModel:StopAnimation("ShootMissed", 0)
		end

		self.ViewModel:PlayAnimation("Shoot")

		if self.ViewModel.Info.Animations.ShootWaiting then
			wait(AnimationLibrary.Info[self.ViewModel.Info.Animations.Shoot].Length)

			if not self.IsEquipped or _use_animation_hash ~= self._use_animation_hash then
				return
			end

			self.ViewModel:PlayAnimation("ShootWaiting")
		end
	end)
	task.delay(v, function()
		if self._use_cooldown_hash ~= _use_cooldown_hash then
			return
		end

		self:CooldownEffect("rbxassetid://101933751328343", self.Info.MissedCooldown, "Cooldown")
	end)
	local cameraData = self.ClientFighter:GetCameraData()

	if self.ClientFighter.IsLocalPlayer then
		self:_ShootHookEffect(Utility:DecodeCFrame(cameraData[utf8.char(0)]))
	else
		local head = self.ClientFighter.Entity and (self.ClientFighter.Entity.Head or self.ClientFighter.Entity.RootPart)

		if head then
			self:_ShootHookEffect(CFrame.new(head.Position) * self.ClientFighter:GetRotationCFrame())
		end
	end

	return true, "StartShooting", cameraData
end

function object:Unequip(...)
	self._use_animation_hash += 1
	Custom.Unequip(self, ...)
end

function object:ReplicateFromServer(p, ...)
	if p == "GrapplerPull" then
		if not self:IsRendered() then
			return
		end

		self._use_animation_hash += 1

		if self.ViewModel.Info.Animations.ShootWaiting then
			self.ViewModel:StopAnimation("ShootWaiting", 0)
		end

		if not self.IsEquipped then
			return
		end

		local vector2, _ = ...
		local position = self.ClientFighter.Entity and self.ClientFighter.Entity:IsAlive() and self.ClientFighter.Entity.RootPart.Position
		self:_Shake("GrapplerPull")
		self.ViewModel:StopAnimation("Equip", 0)
		self.ViewModel:StopAnimation("Inspect", 0)
		self.ViewModel:StopAnimation("Shoot", 0)
		self.ViewModel:PlayAnimation("Pull", 0.5)
		self.ViewModel:PlayPullSounds()

		if not vector2 or not position or vector2:FuzzyEq(position) then
			self:_DeleteHookPart()
			return
		end

		local v = (vector2 - position).Unit * self.Info.SelfPullForce
		local v2 = math.min(self.Info.HookRange, (vector2 - position).Magnitude) / self.Info.SelfPullForce
		self.ViewModel:HideHookSubModel(v2)

		if self._current_hook_part and self._current_hook_part:IsDescendantOf(workspace) then
			self._current_hook_part.Anchored = true
			self._current_hook_part.CFrame = CFrame.new(vector2, position) * CFrame.Angles(0, 3.141592653589793, 0)
			BetterDebris:AddItem(self._current_hook_part, v2)

			for _, springConstraint in pairs(self._current_hook_part:GetDescendants()) do
				if springConstraint:IsA("SpringConstraint") then
					springConstraint.Radius = 0
				end
			end
		end

		if self.ItemInterface then
			self.ItemInterface:PlaySpeedLines(v2)
		end

		if self.ClientFighter.IsLocalPlayer then
			self.ClientFighter.Entity:HardDash(v, v2, nil, nil, "GrapplerPull")
		end
	elseif p == "GrapplerTrackPart" then
		if not self:IsRendered() then
			return
		end

		local v, v2 = ...

		if v and self._current_hook_part and self._current_hook_velocity and not self._destroyed then
			table.insert(self._current_hook_connections, RunService.Heartbeat:Connect(function(_)
				if not (self._current_hook_part and self._current_hook_velocity) then
					return
				end

				local v3 = v.Position + v2

				if not self._current_hook_part.Position:FuzzyEq(v3) then
					self._current_hook_velocity.Velocity = CFrame.new(self._current_hook_part.Position, v3).LookVector * self._current_hook_velocity.Velocity.Magnitude
				end
			end))
		end
	elseif p == "GrapplerCooldown" then
		if not self:IsRendered() then
			return
		end

		local v = ...
		self._use_cooldown_hash += 1
		self._use_cooldown = tick() + v
		self:CooldownEffect("rbxassetid://101933751328343", self.Info.Cooldown, "Cooldown")
	elseif p == "GrapplerMiss" then
		if not self:IsRendered() then
			return
		end

		local v = self.Info.HookRange / self.Info.HookSpeed

		if self._current_hook_part then
			BetterDebris:AddItem(self._current_hook_part, v)
		end

		task.spawn(function()
			local _use_animation_hash = self._use_animation_hash
			wait(v)

			if _use_animation_hash ~= self._use_animation_hash then
				return
			end

			self._use_animation_hash += 1
			local v3 = self.ViewModel.Info.Animations.ShootMissed and 0 or nil
			self.ViewModel:StopAnimation("Shoot", v3)

			if self.ViewModel.Info.Animations.ShootWaiting then
				self.ViewModel:StopAnimation("ShootWaiting", v3)
			end

			if self.ViewModel.Info.Animations.ShootMissed then
				self.ViewModel:PlayAnimation("ShootMissed")
			end
		end)
	else
		Custom.ReplicateFromServer(self, p, ...)
	end
end

function object:Destroy()
	self:_DeleteHookPart()
	Custom.Destroy(self)
end

function object:_UpdateHookPartExistence()
	if self._current_hook_part then
		self.ViewModel.Animator:SetInspectCooldown(1e999)
	else
		self.ViewModel.Animator:SetInspectCooldown(0)
	end
end

function object:_CheckCancelHooking()
	if self.IsEquipped then
		return
	end

	self:_DeleteHookPart()

	if self.ItemInterface then
		self.ItemInterface:PlaySpeedLines(0)
	end

	self.ClientFighter.Entity.Gameplay:CancelHardDash("GrapplerPull")
end

function object:_DeleteHookPart()
	for _, _current_hook_connection in pairs(self._current_hook_connections) do
		_current_hook_connection:Disconnect()
	end

	self._current_hook_connections = {}
	self._current_hook_velocity = nil

	if self._current_hook_part then
		self._current_hook_part:Destroy()
		self._current_hook_part = nil
		self:SetReplicate("GrapplingHookPartActive", false)
	end

	self.ViewModel:HideHookSubModel(0)
end

function object:_ShootHookEffect()
	self:_DeleteHookPart()
	local position = nil
	local mousePositionFromCameraData = nil

	if self.ClientFighter.IsLocalPlayer then
		local cameraData = self.ClientFighter:GetCameraData(nil, nil, true)
		position = (cameraData[utf8.char(0)] * CFrame.new(0.5, -0.75, -1)).Position
		mousePositionFromCameraData = GameplayUtility:GetMousePositionFromCameraData(
			self.ClientFighter:Get("EnvironmentID"),
			self.ClientFighter:GetEntityLookupParams(),
			cameraData[utf8.char(0)],
			cameraData[utf8.char(1)],
			cameraData[utf8.char(2)],
			cameraData[utf8.char(3)]
		)
	else
		local head = self.ClientFighter.Entity and (self.ClientFighter.Entity.Head or self.ClientFighter.Entity.RootPart)

		if head then
			local v = CFrame.new(head.Position) * self.ClientFighter:GetRotationCFrame()
			position = v.Position
			mousePositionFromCameraData = GameplayUtility:GetMousePositionFromCameraData(
				self.ClientFighter:Get("EnvironmentID"),
				self.ClientFighter:GetEntityLookupParams(),
				v,
				v
			)
		end
	end

	if not position or not mousePositionFromCameraData or position:FuzzyEq(mousePositionFromCameraData) then
		return
	end

	local cframe = CFrame.new(position, mousePositionFromCameraData)
	local v = self.Info.HookRange / self.Info.HookSpeed + 1
	self.ViewModel:HideHookSubModel(v)
	self._current_hook_part = Instance.new("Part")
	self._current_hook_part.Name = "Hook"
	self._current_hook_part.Size = createVector(1, 1, 1)
	self._current_hook_part.Transparency = 1
	self._current_hook_part.CFrame = cframe
	self._current_hook_part.CanCollide = false
	self._current_hook_part.CanTouch = false
	self._current_hook_part.CanQuery = false
	self._current_hook_part.Parent = workspace
	BetterDebris:AddItem(self._current_hook_part, v)
	self:SetReplicate("GrapplingHookPartActive", true)
	self._current_hook_part.Destroying:Connect(function()
		task.defer(self._DeleteHookPart, self)
	end)
	self._current_hook_velocity = Instance.new("BodyVelocity")
	self._current_hook_velocity.Velocity = self._current_hook_part.CFrame.LookVector * self.Info.HookSpeed
	self._current_hook_velocity.MaxForce = createVector(100000, 100000, 100000)
	self._current_hook_velocity.Parent = self._current_hook_part
	local clone = (projectiles:FindFirstChild(self.ViewModel.Name) or projectiles[self.Name]):Clone()
	clone.PrimaryPart = clone.Primary
	clone:PivotTo(self._current_hook_part.CFrame)

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = self._current_hook_part
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		part.Anchored = false
	end

	local muzzleAttachment = self.ViewModel:GetMuzzleAttachment()
	local _to_muzzle = clone:FindFirstChild("_to_muzzle", true)
	local rootPart = self.ClientFighter.Entity and self.ClientFighter.Entity.RootPart

	if muzzleAttachment and _to_muzzle and rootPart then
		BetterDebris:AddItem(_to_muzzle, v)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update_parent()
			task.spawn(pcall, function()
				if muzzleAttachment:IsDescendantOf(workspace) and self.IsEquipped and (muzzleAttachment.WorldPosition - rootPart.Position).Magnitude < 32 then
					_to_muzzle.Parent = muzzleAttachment
					_to_muzzle.WorldCFrame = muzzleAttachment.WorldCFrame
				else
					_to_muzzle.Parent = rootPart
					_to_muzzle.WorldCFrame = rootPart.CFrame
				end
			end)
		end

		local v2 = 0
		table.insert(self._current_hook_connections, RunService.RenderStepped:Connect(function()
			if tick() < v2 then
				return
			end

			v2 = tick() + 0.1
			update_parent() -- equivalent call inferred; original call site unknown
		end))
		table.insert(self._current_hook_connections, self.ClientFighter.EquippedItemChanged:Connect(update_parent))
		table.insert(self._current_hook_connections, muzzleAttachment.AncestryChanged:Connect(update_parent))
		task.spawn(pcall, function()
			if muzzleAttachment:IsDescendantOf(workspace) and self.IsEquipped and (muzzleAttachment.WorldPosition - rootPart.Position).Magnitude < 32 then
				_to_muzzle.Parent = muzzleAttachment
				_to_muzzle.WorldCFrame = muzzleAttachment.WorldCFrame
			else
				_to_muzzle.Parent = rootPart
				_to_muzzle.WorldCFrame = rootPart.CFrame
			end
		end)
	end

	clone.Parent = self._current_hook_part
	WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), self:GetWrap(), true)
	self.ViewModel:PlayShootSounds()
end

function object:_Init()
	self:GetDataChangedSignal("GrapplingHookPartActive"):Connect(function()
		self:_UpdateHookPartExistence()
	end)
	self.EquippedChanged:Connect(function()
		self:_CheckCancelHooking()
	end)
	self:_UpdateHookPartExistence()
end

return object