local parent = script.Parent
local Note = {}
Note.__index = Note
local piano = game.SoundService.Piano
local Tween = require(parent.Tween)
local SoundCache = require(script.SoundCache)

function Note.new(source, origin, p, p2, p3, p4, data, sustained)
	local v = p2 + (data.Transposition or 0)
	local v2

	if data.CustomFunction then
		v2 = data.CustomFunction(v, p4)
	else
		v2 = {}
		local pitch

		if v > 61 then
			pitch = 1.059463 ^ (v - 61)
		else
			pitch = not (v < 1) and 1 or 1.059463 ^ (-(1 - v))
		end

		v2.pitch = pitch
		local v4 = math.clamp(v, 1, 61)
		local v5 = (v4 - 1) % 12 + 1
		v2.timePosition = (math.ceil(v4 / 12) - 1) * 16 + (1 - v5 % 2) * 8
		v2.asset = math.ceil(v5 / 2)
	end

	local sound = SoundCache:GetSound()
	sound.SoundGroup = piano
	sound.SoundId = "rbxassetid://" .. data.AssetIds[v2.asset]
	sound.Volume = p3 * p4 * (v2.volumeModifier or data.VolumeModifier or 1)
	sound.TimePosition = v2.timePosition + (data.Offset or 0.04)
	sound.Pitch = v2.pitch
	sound.Parent = piano
	local v3 = {}
	setmetatable(v3, Note)
	v3.Source = source
	v3.Origin = origin
	v3.Index = p
	v3.Volume = sound.Volume
	v3.Sustained = sustained
	v3.Sound = sound
	v3.State = "Inactive"
	v3.Lifetime = 0
	v3.MaxLifetime = data.MaxLifetime
	v3.Tween = Tween.new(sound, TweenInfo.new(data.Fadeout), {
		Volume = 0
	})
	return v3
end

function Note:Play()
	if self.State ~= "Inactive" then
		warn("[Note]: Attempted to Play non-Inactive note")
		return
	end

	self.State = "Active"
	self.Sound:Play()
end

function Note:Fade()
	if self.State ~= "Active" then
		warn("[Note]: Attempted to Fade non-Active note")
		return
	end

	self.State = "Fading"
	task.spawn(function()
		self.Tween:Play()
		self.Tween.Completed:Wait()

		if self.State ~= "Destroying" then
			self:Destroy()
		end
	end)
end

function Note:Destroy()
	if self.State == "Destroying" then
		return
	end

	self.State = "Destroying"
	self.Sound:Stop()
	self.Tween:Cancel()
	self.Tween:Destroy()
	SoundCache:ReturnSound(self.Sound)
end

return Note