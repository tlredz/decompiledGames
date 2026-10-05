local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc.InvincibilityParticles.Attachment
local extinguishParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc.ExtinguishParticles
local freezeEffects = Players.LocalPlayer.PlayerScripts.Assets.Misc.FreezeEffects
local slowParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc.SlowParticles
local burningEffects = Players.LocalPlayer.PlayerScripts.Assets.Misc.BurningEffects
local blipEffects = Players.LocalPlayer.PlayerScripts.Assets.Misc.BlipEffects
local finishers = ReplicatedStorage.Modules.Finishers
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object.new(p)
	local object2 = setmetatable(ReplicatedClass.new(p), object)
	object2.Died = Signal.new()
	object2.HealthChanged = Signal.new()
	object2.BurnEffectPlaying = Signal.new()
	object2.Model = p.Model
	object2.RootPart = p.RootPart
	object2.AimAssistBlacklist = false
	object2._destroyed = nil
	object2._is_hidden = nil
	object2._is_dead = nil
	object2._connections = {}
	object2._hurt_effect_hash = 0
	object2._hitboxes = {}
	object2._hitboxes_small = {}
	object2._burn_effect_finish = 0
	object2._burn_effect_sound = nil
	object2._burn_effect_particles = {}
	object2._model_original_parent_hurt_effect = nil
	object2._thaw_callback = nil
	object2._thaw_highlight = nil
	object2._current_finisher = nil
	object2._invincibility_visual = nil
	object2._headshot_particles = nil
	object2._permafrost_slow_particles = nil
	object2:_Init()
	return object2
end

function object:IsRendered()
	local SHOULD_ALWAYS_REPLICATE = CONSTANTS.SHOULD_ALWAYS_REPLICATE()

	if SHOULD_ALWAYS_REPLICATE then
		return SHOULD_ALWAYS_REPLICATE
	end

	if self.ClientFighter then
		return (self.ClientFighter:IsRendered())
	end

	SHOULD_ALWAYS_REPLICATE = (workspace.CurrentCamera.CFrame.Position - self.RootPart.Position).Magnitude < CONSTANTS.RENDER_DISTANCE
	return SHOULD_ALWAYS_REPLICATE
end

function object:IsAlive()
	return not (self._destroyed or self._is_dead) and self:GetHealth() > 0
end

function object:IsHidden()
	return self._is_hidden
end

function object.GetScreenPoint(p)
	return workspace.CurrentCamera:WorldToScreenPoint(p.RootPart.Position)
end

function object:GetHitboxes(p2)
	return p2 and #self._hitboxes_small > 0 and self._hitboxes_small or self._hitboxes
end

function object:SetHidden(is_hidden)
	self._is_hidden = is_hidden
end

function object:ReplicateFromServer(p, ...)
	if p == "BurnEffect" then
		if not self:IsRendered() then
			return
		end

		self:_BurnEffect(...)
	elseif p == "ExtinguishEffect" then
		if not self:IsRendered() then
			return
		end

		self:_ExtinguishEffect(...)
	elseif p == "HurtEffect" then
		if not self:IsRendered() then
			return
		end

		self:_HurtEffect(...)
	elseif p == "HealEffect" then
		if not self:IsRendered() then
			return
		end

		self:_HealEffect(...)
	elseif p == "FreezeEffect" then
		if not self:IsRendered() then
			return
		end

		self:_FreezeEffect(...)
	elseif p == "ThawFreezeEffect" then
		if not self:IsRendered() then
			return
		end

		self:_ThawFreezeEffect(...)
	elseif p == "FinisherEffect" then
		if not self:IsRendered() then
			return
		end

		local v, v2, v3, v4 = ...
		self:_PlayFinisher(self:FromEnum(v), v2, v3, v4)
	elseif p == "BlipEffect" then
		if not self:IsRendered() then
			return
		end

		self:_BlipEffect(...)
	elseif p == "SlowEffect" then
		if not self:IsRendered() then
			return
		end

		self:_SlowEffect(...)
	elseif p == "CreateSound" then
		if not self:IsRendered() then
			return
		end

		self:_CreateSound(...)
	else
		if p ~= "Died" then
			ReplicatedClass.ReplicateFromServer(self, p, ...)
			return
		end

		self._is_dead = true
		self.Died:Fire()
	end
end

function object:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._hitboxes = {}
	self._hitboxes_small = {}
	self.Died:Destroy()
	self.HealthChanged:Destroy()
	self.BurnEffectPlaying:Destroy()

	if self.Model then
		self.Model:Destroy()
	end

	if self._current_finisher then
		self._current_finisher:Destroy()
		self._current_finisher = nil
	end

	ReplicatedClass.Destroy(self)
end

function object:_CreateSound(p2, p3, p4, octave, p5)
	local v2 = p5 and 400 or nil
	local sound = Utility:CreateSound(p2, p3 * (p5 and 2 or 1), p4, self.RootPart, true, 15, v2, v2)

	if octave and octave ~= 1 then
		local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
		pitchShiftSoundEffect.Octave = octave
		pitchShiftSoundEffect.Parent = sound
	end
end

function object:_UpdatePermafrostSlowStacks()
	if self._permafrost_slow_highlight then
		self._permafrost_slow_highlight:Destroy()
		self._permafrost_slow_highlight = nil
	end

	if not self:IsAlive() then
		return
	end

	local permafrostSlowStacks = self:IsAlive() and self:Get("ReplicatedExternalGameplayData") and self:Get("ReplicatedExternalGameplayData").PermafrostSlowStacks
	local v = (not permafrostSlowStacks and 0 or permafrostSlowStacks.Stacks or 0) / math.max(
		1,
		permafrostSlowStacks and permafrostSlowStacks.MaxStacks or 0
	)

	if v <= 0 then
		for _, v2 in pairs(self._permafrost_slow_particles or {}) do
			v2:Destroy()
		end

		self._permafrost_slow_particles = nil
	else
		if not self._permafrost_slow_particles then
			self._permafrost_slow_particles = {}

			for _, child in pairs(slowParticles:GetChildren()) do
				local clone = child:Clone()
				clone.Parent = self.RootPart
				table.insert(self._permafrost_slow_particles, clone)
			end
		end

		for _, _permafrost_slow_particle in pairs(self._permafrost_slow_particles) do
			_permafrost_slow_particle.LocalTransparencyModifier = 1 + -1 * v
		end
	end
end

function object:_UpdateInvincibilityVisual()
	if self:Get("IsInvincible") or not self._invincibility_visual then
		if self:Get("IsInvincible") and not self._invincibility_visual then
			self._invincibility_visual = attachment:Clone()
			self._invincibility_visual.Parent = self.RootPart
		end
	else
		self._invincibility_visual:Destroy()
		self._invincibility_visual = nil
	end
end

function object:_PlayFinisher(p, p2, p3, p4)
	local humanoid = self.Humanoid or self.RootPart

	if not (humanoid and humanoid:IsDescendantOf(workspace)) then
		return
	end

	if self._current_finisher then
		self._current_finisher:Destroy()
	end

	local module = require(finishers[p])
	self._current_finisher = module.new(humanoid, p2, p3)
	self._current_finisher:SetSerial(p4)

	if CONSTANTS.IS_STUDIO then
		self._current_finisher:PlayClient()
	else
		pcall(self._current_finisher.PlayClient, self._current_finisher)
	end
end

function object:_SlowEffect(p2)
	for _, child in pairs(slowParticles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self.RootPart
		BetterDebris:AddItem(clone, p2)
	end
end

function object:_BlipEffect(p2, p3, childName, p4)
	local item = p4 and self.ClientFighter and self.ClientFighter:GetItem(p4)
	local wrap = item and item:GetWrap()

	for _, v in pairs({ p2, p3 }) do
		local clone = (blipEffects:FindFirstChild(childName) or blipEffects.Default):Clone()
		clone.CFrame = v or self.RootPart.CFrame
		clone.Parent = workspace
		BetterDebris:AddItem(clone, 5)
		Utility:PlayParticles(clone)

		if wrap then
			WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), wrap, true)
		end
	end

	Utility:CreateSound("rbxassetid://123181974576488", 1, 1.5 + 0.2 * math.random(), self.RootPart, true, 5)
end

function object:_ThawFreezeEffect(p)
	if self._thaw_highlight then
		self._thaw_highlight:Destroy()
		self._thaw_highlight = nil
	end

	if p and p > 0 then
		self._thaw_highlight = Instance.new("Highlight")
		self._thaw_highlight.FillColor = Color3.fromRGB(161, 222, 255)
		self._thaw_highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
		self._thaw_highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		self._thaw_highlight.Adornee = self.Model
		self._thaw_highlight.Parent = self.Model
		BetterDebris:AddItem(self._thaw_highlight, p)
		task.spawn(function()
			local _thaw_highlight = self._thaw_highlight
			local lastTime = tick()

			while tick() < lastTime + p do
				local v = ((tick() - lastTime) / p) ^ 4
				_thaw_highlight.FillTransparency = 0.5 + 0.5 * v
				_thaw_highlight.OutlineTransparency = 0 + 1 * v
				RunService.RenderStepped:Wait()
			end
		end)
	end

	if self._thaw_callback then
		pcall(self._thaw_callback, self)
		self._thaw_callback = nil
	end
end

function object:_FreezeEffect(duration, value)
	self:_ThawFreezeEffect()
	local clone = (freezeEffects:FindFirstChild(value or "Default") or freezeEffects.Default):Clone()
	clone.PrimaryPart = clone.Primary

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
		part.Anchored = false

		if part == clone.PrimaryPart then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = clone.PrimaryPart
		weldConstraint.Part1 = part
		weldConstraint.Parent = clone.PrimaryPart
	end

	clone:SetPrimaryPartCFrame(self.RootPart.CFrame)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, duration + 3)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = self.RootPart
	weldConstraint.Part1 = clone.PrimaryPart
	weldConstraint.Parent = clone

	if value == "Bubble" or value == "Gum" then
		function self._thaw_callback()
			if not clone.PrimaryPart then
				clone:Destroy()
				return
			end

			BetterDebris:AddItem(clone, 2)
			Utility:CreateSound(
				"rbxassetid://18763517194",
				1,
				1,
				clone.PrimaryPart and clone.PrimaryPart.Position,
				true,
				10
			)
			local size = clone.PrimaryPart.Size
			Utility:RenderstepForLoop(0, 100, 10, function(p)
				if not clone.PrimaryPart then
					return true
				end

				local v = 1 - (1 - p / 100) ^ 3
				clone.PrimaryPart.Transparency = 0.5 + 0.5 * v
				clone.PrimaryPart.Size = size * (1 + 2 * v)
			end)
			clone:Destroy()
		end
	elseif value == "Temporal" then
		Utility:CreateSound("rbxassetid://18431054727", 1.5, 1 + 0.1 * math.random(), clone.PrimaryPart, true, 10)
		Utility:CreateSound("rbxassetid://8571334160", 0.75, 1.2, clone.PrimaryPart, true, 10)

		function self._thaw_callback()
			if not clone.PrimaryPart then
				clone:Destroy()
				return
			end

			BetterDebris:AddItem(clone, 2)
			Utility:CreateSound(
				"rbxassetid://8571436177",
				0.5,
				2,
				clone.PrimaryPart and clone.PrimaryPart.Position,
				true,
				10
			)
			local size = clone.PrimaryPart.Size
			Utility:RenderstepForLoop(0, 100, 5, function(p)
				if not clone.PrimaryPart then
					return true
				end

				local transparency = (p / 100) ^ 3
				clone.PrimaryPart.Transparency = transparency
				clone.PrimaryPart.Size = size * (1 + 2 * transparency)
			end)
			clone:Destroy()
		end
	elseif value == "Cocoon" then
		function self._thaw_callback()
			local cocoon = clone:FindFirstChild("Cocoon")

			if not cocoon then
				clone:Destroy()
				return
			end

			cocoon.Transparency = 1
			BetterDebris:AddItem(clone, 2)
			Utility:PlayParticles(cocoon)
		end
	elseif value == "SandBucket" then
		function self._thaw_callback()
			clone:Destroy()
		end
	elseif value == "Wires" or value == "Ropes" or value == "WhiteWires" or value == "PurpleWires" then
		function self._thaw_callback()
			clone:Destroy()
		end
	elseif value == "Selection" then
		function self._thaw_callback()
			clone:Destroy()
		end
	elseif value == "Starforge" then
		function self._thaw_callback()
			clone:Destroy()
		end
	else
		if value == "Wrapped" then
			Utility:CreateSound(
				"rbxassetid://74885181688460",
				0.875,
				1 + 0.1 * math.random(),
				clone.PrimaryPart,
				true,
				5
			)
		else
			Utility:CreateSound("rbxassetid://18429138544", 0.75, 2 + 0.5 * math.random(), clone.PrimaryPart, true, 10)
		end

		function self._thaw_callback()
			if not clone.PrimaryPart then
				clone:Destroy()
				return
			end

			BetterDebris:AddItem(clone, 2)
			local position = clone.PrimaryPart.Position
			clone.PrimaryPart:Destroy()

			for _, part in pairs(clone:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Velocity = CFrame.new(position, part.Position).LookVector * (25 + 25 * math.random())
				part.RotVelocity = CFrame.Angles(
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2
				).LookVector * (10 + 10 * math.random())
			end

			if value == "Wrapped" then
				Utility:CreateSound("rbxassetid://121822631205080", 0.875, 1, position, true, 10)
			else
				Utility:CreateSound("rbxassetid://135970869546121", 0.875, 1, position, true, 10)
			end
		end
	end

	local _thaw_callback = self._thaw_callback
	task.delay(duration, function()
		if self._thaw_callback ~= _thaw_callback then
			return
		end

		self._thaw_callback = nil
		_thaw_callback()
	end)
end

function object:_ExtinguishEffect()
	for _, _burn_effect_particle in pairs(self._burn_effect_particles) do
		_burn_effect_particle:Destroy()
	end

	self._burn_effect_particles = {}
	self._burn_effect_finish = 0

	if self._burn_effect_sound then
		self._burn_effect_sound:Destroy()
		self._burn_effect_sound = nil
	end

	local clone = extinguishParticles:Clone()
	clone.CFrame = self.RootPart.CFrame
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 10)
	Utility:CreateSound("rbxassetid://16812185839", 0.75, 1.3 + 0.2 * math.random(), clone, true)
	Utility:CreateSound("rbxassetid://16812389263", 0.75, 1.3 + 0.2 * math.random(), clone, true)
	Utility:PlayParticles(clone.Attachment)
end

function object:_BurnEffect(p, p2, p3)
	local v = p2 and self:FromEnum(p2)
	local v2 = tick() < self._burn_effect_finish

	if self._burn_effect_sound then
		self._burn_effect_sound:Destroy()
	end

	self._burn_effect_sound = Utility:CreateSound(
		"rbxassetid://13702989275",
		0.25,
		0.9 + 0.2 * math.random(),
		self.RootPart,
		true,
		10
	)
	self._burn_effect_finish = tick() + p

	if v2 then
		return
	end

	local v3 = self.RootPart.Size.Y / 2
	local clones = {}

	for _, child in pairs((burningEffects:FindFirstChild(v or "Default") or burningEffects.Default):GetChildren()) do
		if child:IsA("ParticleEmitter") then
			local clone = child:Clone()
			clone.Parent = self.RootPart
			table.insert(clones, clone)
			Utility:ScaleParticleEmitter(clone, v3)
		elseif child:IsA("Light") then
			local clone = child:Clone()
			clone.Range *= v3
			clone.Parent = self.RootPart
			BetterDebris:AddItem(clone, p + 4)
			table.insert(clones, clone)
		end
	end

	if p3 then
		WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clones), p3, true)
	end

	self._burn_effect_particles = clones
	self.BurnEffectPlaying:Fire(self._burn_effect_particles)

	while tick() < self._burn_effect_finish do
		wait(self._burn_effect_finish - tick())
	end

	for _, instance in pairs(clones) do
		if instance:IsA("ParticleEmitter") then
			instance.Enabled = false
			BetterDebris:AddItem(instance, instance.Lifetime.Max / instance.TimeScale)
		elseif instance:IsA("Light") then
			local v4 = instance
			task.spawn(function()
				local brightness = v4.Brightness
				Utility:RenderstepForLoop(0, 100, 1, function(p4)
					v4.Brightness = brightness * (1 - p4 / 100)
				end)
				v4:Destroy()
			end)
		end
	end

	self._burn_effect_sound = nil
end

function object:_HealEffect()
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(100, 255, 50)
	highlight.OutlineColor = Color3.fromRGB(179, 255, 153)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Adornee = self.Model
	highlight.Parent = self.Model
	Utility:RenderstepForLoop(0, 100, 2, function(p2)
		local v = p2 / 100
		highlight.OutlineTransparency = v
		highlight.FillTransparency = v
	end)
	highlight:Destroy()
end

function object:_HurtEffect(p)
	if math.abs(p[utf8.char(0)] or 0) < 0.001 then
		return
	end

	if p[utf8.char(1)] and not self._is_hidden and self._headshot_particles then
		Utility:PlayParticles(self._headshot_particles)
	end

	if #GameplayUtility:GetSmokeCloudsInSphere(self.RootPart.Position) > 0 then
		return
	end

	self._hurt_effect_hash += 1
	local _hurt_effect_hash = self._hurt_effect_hash

	if not self.Model.Parent then
		return
	end

	self._model_original_parent_hurt_effect = self._model_original_parent_hurt_effect or self.Model.Parent
	self.Model.Parent = workspace.HurtEffect
	workspace.HurtEffect:SetAttribute("PlayHurtEffect", workspace.HurtEffect:GetAttribute("PlayHurtEffect") + 1)
	wait(1)

	if self._hurt_effect_hash ~= _hurt_effect_hash or not self.Model.Parent then
		return
	end

	self.Model.Parent = self._model_original_parent_hurt_effect
	self._model_original_parent_hurt_effect = nil
end

function object:_PotentialHitboxAdded(part)
	if not part:IsA("BasePart") then
		return
	end

	local function check()
		if not CollectionService:HasTag(part, "EntityHitbox") then
			return
		end

		local _hitboxes_small

		if part:GetAttribute("IsSmallHitbox") then
			_hitboxes_small = self._hitboxes_small
		else
			_hitboxes_small = self._hitboxes
		end

		if not table.find(_hitboxes_small, part) then
			table.insert(_hitboxes_small, part)
		end
	end

	part:GetAttributeChangedSignal("EntityHitboxUpdate"):Connect(check)
	check()
end

function object:_Setup()
	if self.Model then
		self.Model.DescendantAdded:Connect(function(descendant)
			self:_PotentialHitboxAdded(descendant)
		end)

		for _, descendant in pairs(self.Model:GetDescendants()) do
			self:_PotentialHitboxAdded(descendant)
		end
	end
end

function object:_Init()
	self.Died:Connect(function()
		self.HealthChanged:Fire()
		self:_UpdatePermafrostSlowStacks()
	end)
	self:GetDataChangedSignal("IsInvincible"):Connect(function()
		self:_UpdateInvincibilityVisual()
	end)
	self:GetDataChangedSignal("ReplicatedExternalGameplayData"):Connect(function()
		self:_UpdatePermafrostSlowStacks()
	end)
	self:_Setup()
	self:_UpdateInvincibilityVisual()
	task.defer(self._UpdatePermafrostSlowStacks, self)
end

return object