local SoundCache = require(script.SoundCache)
local Tween = require(script.Tween)
local RunService = game:GetService("RunService")
local SoundFont = {
	_keyDownLookup = {},
	_soundQueue = {},
	_startSoundQueue = function(self)
		if self._queueConnection then
			return
		end

		self._queueConnection = RunService.Heartbeat:Connect(function(dt)
			local count = #self._soundQueue

			if count == 0 then
				self:_stopSoundQueue()
				return
			end

			local v = count - 35
			local v2 = 1

			for i, v3 in ipairs(self._soundQueue) do
				if v > 0 then
					self._soundQueue[i] = nil
					v3:Destroy()
					v -= 1
				elseif v3.State == "Destroying" then
					self._soundQueue[i] = nil
				else
					if v3.State == "Active" then
						if v3.Sustained or self._keyDownLookup[v3.Note] then
							v3.Lifetime += dt

							if v3.Lifetime >= v3.MaxLifetime then
								v3:Fade()
							end
						else
							v3:Fade()
						end
					end

					if v2 ~= i then
						self._soundQueue[v2] = v3
						self._soundQueue[i] = nil
					end

					v2 += 1
				end
			end
		end)
	end,
	_stopSoundQueue = function(self)
		if self._activeQueue then
			self._activeQueue:Disconnect()
			self._activeQueue = nil
		end

		for _, v in self._soundQueue do
			v:Destroy()
		end

		table.clear(self._soundQueue)
	end
}
local v = {}
local PianoFont = require(script.Fonts.PianoFont)
v[1] = PianoFont
local TrumpetFont = require(script.Fonts.TrumpetFont)
v[2] = TrumpetFont
local DrumFont = require(script.Fonts.DrumFont)
v[3] = DrumFont
local class = {}
class.__index = class

function class.new(note, p, sustained)
	local v2 = v[p]
	local customFunction = v2.CustomFunction(note)
	local sound = SoundCache:GetSound()
	sound.SoundGroup = game.SoundService.Effect
	sound.Volume = 5 * v2.VolumeModifier
	sound.SoundId = "rbxassetid://" .. v2.AssetIds[customFunction.asset]
	sound.TimePosition = customFunction.timePosition + (v2.Offset or 0.04)
	sound.Pitch = customFunction.pitch
	sound.Parent = script.Parent
	local v3 = {}
	setmetatable(v3, class)
	v3.Source = script.Parent
	v3.Sustained = sustained
	v3.Sound = sound
	v3.Note = note
	v3.State = "Inactive"
	v3.Lifetime = 0
	v3.MaxLifetime = v2.MaxLifetime
	v3.Tween = Tween.new(sound, TweenInfo.new(v2.Fadeout), {
		Volume = 0
	})
	return v3
end

function class:Play()
	if self.State ~= "Inactive" then
		return
	end

	self.State = "Active"
	self.Sound:Play()
end

function class:Fade()
	if self.State ~= "Active" then
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

function class:Destroy()
	if self.State == "Destroying" then
		return
	end

	self.State = "Destroying"
	self.Sound:Stop()
	self.Tween:Cancel()
	self.Tween:Destroy()
	SoundCache:ReturnSound(self.Sound)
end

function SoundFont:PlayNote(p, p2, p3)
	local v2 = p3 == nil or p3
	local v3 = class.new(p, p2, v2)
	v3:Play()
	self._keyDownLookup[p] = true
	table.insert(self._soundQueue, v3)

	if not self._activeQueue then
		self:_startSoundQueue()
	end

	return v3
end

function SoundFont:StopNote(p2)
	self._keyDownLookup[p2] = nil
end

return SoundFont