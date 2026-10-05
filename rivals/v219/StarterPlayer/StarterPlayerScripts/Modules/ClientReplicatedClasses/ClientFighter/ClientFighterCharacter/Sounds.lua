local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundLibrary = require(ReplicatedStorage.Modules.SoundLibrary)
local Sounds = {}
Sounds.__index = Sounds

function Sounds.new(clientFighterCharacter)
	local self = setmetatable({}, Sounds)
	self.ClientFighterCharacter = clientFighterCharacter
	self._last_footstep = 0
	self._falling_start = nil
	self._falling_sound = nil
	self._footsteps_disabled = 0
	self:_Init()
	return self
end

function Sounds:DisableFootsteps(p2)
	self._footsteps_disabled = tick() + p2
end

function Sounds:Update(p, p2)
	self:_UpdateFalling(p, p2)
	self:_UpdateFootstep(p, p2)
end

function Sounds:Destroy()
	self:_ClearFallingSound()
end

function Sounds:_ClearFallingSound()
	if self._falling_sound then
		self._falling_sound:Destroy()
		self._falling_sound = nil
	end
end

function Sounds:_UpdateFalling(_, state)
	local isGrounded = state.IsGrounded or state.IsHiddenByCutscene

	if isGrounded or self._falling_start then
		if isGrounded and self._falling_start and tick() - self._falling_start > 0.25 then
			self:_ClearFallingSound()
			self.ClientFighterCharacter.ClientFighter:CreateSound(
				"rbxassetid://16736552001",
				math.clamp((tick() - self._falling_start - 1) * 0.45, 0, 0.9) + 0.1,
				1 + 0.75 * math.random(),
				true,
				5
			)
			self._falling_start = nil
			state.JustLanded = true
			return true
		end
	else
		self._falling_start = tick()
		self._falling_sound = self.ClientFighterCharacter.ClientFighter.IsLocalPlayer and self.ClientFighterCharacter.ClientFighter:CreateSound(
			"rbxassetid://16737738355",
			0,
			1,
			true
		)
		self.ClientFighterCharacter.ClientFighter:CreateSound(
			"rbxassetid://16736552098",
			0.5,
			1 + 0.5 * math.random(),
			true,
			5
		)

		if self._falling_sound then
			self._falling_sound.Looped = true
		end
	end

	if self._falling_sound then
		self._falling_sound.Volume = math.min(
			1,
			(math.sqrt((math.max(0, -self.ClientFighterCharacter.RootPart.Velocity.Y - 24))) / 15) ^ 2 * 2
		)
	end
end

function Sounds:_UpdateFootstep(_, data)
	if not data.IsAlive or data.IsCrouching or data.IsSliding or not (data.IsGrounded or data.IsClimbing) or data.IsHiddenByEmotes or data.IsHiddenByCutscene then
		return
	end

	if tick() < self._footsteps_disabled then
		return
	end

	local currentEmote = self.ClientFighterCharacter:GetCurrentEmote()

	if currentEmote and currentEmote.Info.HideFootsteps and not self.ClientFighterCharacter.ClientFighter:Get("IsInDuel") then
		return
	end

	local scale = self.ClientFighterCharacter.ClientFighter.Entity:Get("Scale") or 1
	local v = 1 + (scale - 1) / 2
	local v2 = data.IsClimbing and math.abs(data.PlayerVelocity.Y * 1.25) or data.MoveSpeed / v

	if v2 < 1 or tick() < self._last_footstep + 4.5 / v2 then
		return
	end

	self._last_footstep = tick()
	local v3 = data.IsClimbing and "Climbing" or scale >= 2 and "Stomping" or not SoundLibrary.FootstepSounds[self.ClientFighterCharacter.Humanoid.FloorMaterial.Name] and "Default" or self.ClientFighterCharacter.Humanoid.FloorMaterial.Name or "Default"
	local footstepSound = SoundLibrary.FootstepSounds[v3]
	local v4 = SoundLibrary.FootstepSounds[footstepSound] or footstepSound

	if #v4 == 0 then
		return
	end

	local v5 = (0.875 + 0.25 * math.random()) * (1 + 0.1 * (v2 / 16))
	local v6 = v2 / 32 * (v3 == "Default" and 2 or 1) * (v3 == "Stomping" and 2 or 1) * (self.ClientFighterCharacter.ClientFighter:Get("IsSpectating") and 0.5 or 1)
	self.ClientFighterCharacter.ClientFighter:CreateSound(v4[math.random(#v4)], v6 * 0.75, v5, true, 5, 32, 100)
end

function Sounds:_Init()
	self.ClientFighterCharacter.Died:Connect(function()
		self:_ClearFallingSound()
	end)
end

return Sounds