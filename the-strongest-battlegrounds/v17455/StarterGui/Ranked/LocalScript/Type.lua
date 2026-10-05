local RunService = game:GetService("RunService")
local Type = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function randf(p, p2)
	return p + (p2 - p) * math.random()
end

local function pickSoundId(list)
	if not list then
		return nil
	end

	if type(list) ~= "table" then
		return list
	end

	if #list == 0 then
		return nil
	end

	return list[math.random(1, #list)]
end

local function makeSound(parent, soundId, value, playbackSpeed)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = value or 0.5
	sound.PlayOnRemove = false
	sound.RollOffMaxDistance = 100
	sound.Parent = parent

	if playbackSpeed and sound:IsA("Sound") then
		sound.PlaybackSpeed = playbackSpeed
	end

	return sound
end

local function buildRichVisible(_raw, _index)
	if #_raw <= _index then
		return _raw
	end

	local v = 1
	local v2 = {}

	while v <= _index do
		local v3 = string.find(_raw, "<", v, true)

		if not v3 or _index < v3 then
			break
		end

		local v4 = string.find(_raw, ">", v3 + 1, true)

		if not v4 or _index < v4 then
			break
		end

		local v5 = string.sub(_raw, v3 + 1, v4 - 1)
		v = v4 + 1
		local v6 = string.gsub(v5, "^%s+", "")
		local v7 = string.sub(v6, 1, 1) == "/"
		local v8 = string.sub(v6, -1) == "/"
		local v9

		if v7 then
			v9 = string.match(v6, "^/%s*([%w]+)")
		else
			v9 = string.match(v6, "^([%w]+)")
		end

		if not v9 then
			continue
		end

		local v10 = string.lower(v9)

		if v7 then
			if v2[#v2] == v10 then
				table.remove(v2, #v2)
			else
				for i = #v2, 1, -1 do
					if v2[i] ~= v10 then
						continue
					end

					table.remove(v2, i)
					break
				end
			end
		elseif not v8 then
			table.insert(v2, v10)
		end
	end

	local v3 = string.sub(_raw, 1, _index)

	if #v2 == 0 then
		return v3
	end

	local v4 = {}

	for i = #v2, 1, -1 do
		v4[#v4 + 1] = ("</%s>"):format(v2[i])
	end

	return v3 .. table.concat(v4)
end

local function isAudibleChar(value, p)
	if p then
		return true
	end

	return not string.match(value, "%s")
end

local class = {}
class.__index = class

function class:isBusy()
	return self._alive
end

function class:skip()
	if not self._alive then
		return
	end

	self._index = #self._raw
	self:_renderCurrent()
	self:_finish()
end

function class:stop()
	if not self._alive then
		return
	end

	self._alive = false

	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end
end

function class:_renderCurrent(p)
	if self._useRich then
		self._target.Text = buildRichVisible(self._raw, self._index)
	else
		self._target.Text = string.sub(self._raw, 1, self._index)
	end

	if not p then
		local SoundService = game:GetService("SoundService")
		SoundService:PlayLocalSound(script.Click)
	end
end

function class:_finish()
	self._alive = false

	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end

	if self._onComplete then
		task.defer(self._onComplete)
	end
end

function Type:play(raw, options)
	assert(self and self:IsA("TextLabel") or self:IsA("TextBox"), "Typewriter.play expects a TextLabel or TextBox")
	assert(type(raw) == "string", "Typewriter.play expects a string as text")

	if self.Text == raw then
		return
	end

	local v = options or {}
	local cps = tonumber(v.cps) or 30
	local soundId = v.soundId
	local volume = v.volume == nil and 0.5 or v.volume or 0.5
	local pitchRange = v.pitchRange or { 1, 1 }
	local playOnWhitespace = v.playOnWhitespace == true
	local punctuationPauses = v.punctuationPauses or {
		["."] = 8,
		[","] = 3,
		["!"] = 8,
		["?"] = 8,
		[":"] = 4,
		[";"] = 4
	}
	local richText = v.richText ~= nil and v.richText or self.RichText
	local noSound = v.NoSound
	self.RichText = richText
	local object = setmetatable({
		_target = self,
		_raw = raw,
		_index = 0,
		_alive = true,
		_conn = nil,
		_useRich = richText,
		_onChar = v.onChar,
		_onComplete = v.onComplete
	}, class)
	local v3 = 0
	local v4 = 0
	local v5 = nil
	object._conn = RunService.Heartbeat:Connect(function(dt)
		if not object._alive then
			return
		end

		if not self.Parent then
			object:stop()
			return
		end

		v3 += dt * cps
		local v6 = math.floor(v3)

		if v6 <= 0 then
			return
		end

		v3 -= v6

		for _ = 1, v6 do
			if object._index >= #object._raw then
				object:_finish()
				break
			end

			object._index += 1
			object:_renderCurrent(noSound)
			local v8 = string.sub(object._raw, object._index, object._index)

			if soundId and (playOnWhitespace or not string.match(v8, "%s")) then
				local soundId2 = soundId

				if soundId2 then
					if type(soundId2) == "table" then
						if #soundId2 == 0 then
							soundId2 = nil
						else
							soundId2 = soundId2[math.random(1, #soundId2)]
						end
					end
				else
					soundId2 = nil
				end

				if soundId2 then
					if v5 and v5.Parent then
						v5.SoundId = soundId2
						v5.Volume = volume
						v5.PlaybackSpeed = randf(pitchRange[1], pitchRange[2])
					else
						local playbackSpeed = randf(pitchRange[1], pitchRange[2]) -- equivalent call inferred; original call site unknown
						local sound = Instance.new("Sound")
						sound.SoundId = soundId2
						sound.Volume = volume or 0.5
						sound.PlayOnRemove = false
						sound.RollOffMaxDistance = 100
						sound.Parent = self

						if playbackSpeed and sound:IsA("Sound") then
							sound.PlaybackSpeed = playbackSpeed
						end

						v5 = sound
					end

					v5:Play()
					print("PLAYING")
				end
			end

			if object._onChar then
				task.defer(object._onChar, v8, object._index)
			end

			local punctuationPaus = punctuationPauses[v8]

			if punctuationPaus and punctuationPaus > 0 then
				v4 = punctuationPaus / math.max(1, cps)
			end
		end
	end)
	return object
end

return Type