local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local AudioPlayback = {}
AudioPlayback.__index = AudioPlayback

local function assetReady(sound)
	local v = sound and sound:IsA("Sound")

	if v then
		if sound:GetAttribute("Enabled") == false or sound.SoundId:match("%S") == nil or sound.SoundId == "rbxassetid://0" then
			return false
		else
			return sound.SoundId ~= "0"
		end
	end

	return v
end

function AudioPlayback.new(library, catalog, cfg)
	local folder = Instance.new("Folder")
	folder.Name = "GameAudioPlayback"
	folder.Parent = SoundService
	return (setmetatable({
		library = library,
		catalog = catalog,
		cfg = cfg,
		folder = folder,
		voices = {},
		loops = {},
		cooldowns = setmetatable({}, {
			__mode = "k"
		}),
		random = Random.new(),
		voiceCount = 0,
		music = nil,
		musicToken = "",
		alive = true,
		emitters = setmetatable({}, {
			__mode = "k"
		})
	}, AudioPlayback))
end

function AudioPlayback:template(p2)
	if self.library:GetAttribute("Enabled") == false then
		return nil
	end

	local v = self.catalog[p2]

	if not v then
		return nil
	end

	local library = self.library

	for _, childName in string.split(v.Path, "/") do
		library = library and library:FindFirstChild(childName)
	end

	local v2 = library and library:IsA("Sound")

	if v2 then
		if library:GetAttribute("Enabled") == false or library.SoundId:match("%S") == nil or library.SoundId == "rbxassetid://0" then
			v2 = false
		else
			v2 = library.SoundId ~= "0"
		end
	end

	return v2 and library or nil
end

function AudioPlayback:trace(lastCue, lastCuePlayed)
	if self.library:GetAttribute("DebugEvents") ~= true then
		return
	end

	self.folder:SetAttribute("LastCue", lastCue)
	self.folder:SetAttribute("LastCuePlayed", lastCuePlayed)
	local v = "Cue_" .. lastCue
	self.folder:SetAttribute(v, (self.folder:GetAttribute(v) or 0) + 1)
end

function AudioPlayback:remove(p)
	if not (p and self.voices[p]) then
		return
	end

	self.voices[p] = nil
	self.voiceCount -= 1

	if p.tween then
		p.tween:Cancel()
	end

	p.sound:Destroy()
end

function AudioPlayback:create(p, instance, part, value, value2, looped)
	if not self.alive or self.voiceCount >= self.cfg.MaxVoices or part and not part:IsDescendantOf(workspace) then
		return nil
	end

	local clone = instance:Clone()
	clone.Name = "CoH_" .. p
	clone.PlayOnRemove = false
	clone.Looped = looped
	clone.Volume = instance.Volume * (value or 1)
	clone.PlaybackSpeed = instance.PlaybackSpeed * (value2 or 1)
	local v

	if part and part:IsA("BasePart") then
		v = part:FindFirstChild("CoHAudioEmitter")

		if not v then
			v = Instance.new("Attachment")
			v.Name = "CoHAudioEmitter"
			v.Parent = part
			self.emitters[v] = true
		end
	end

	clone.Parent = v or part or self.folder
	local knifeMaxSeconds = tonumber(instance:GetAttribute("KnifeMaxSeconds"))

	if knifeMaxSeconds and (knifeMaxSeconds ~= knifeMaxSeconds or knifeMaxSeconds <= 0) then
		knifeMaxSeconds = nil
	end

	local v2 = knifeMaxSeconds and math.clamp(knifeMaxSeconds, 0.2, self.cfg.MaxOneShotSeconds) or self.cfg.MaxOneShotSeconds
	local v3 = {
		sound = clone,
		template = instance,
		id = instance.SoundId,
		key = p,
		deadline = looped and 1e999 or os.clock() + v2,
		knifeFade = not looped and knifeMaxSeconds ~= nil
	}
	self.voices[v3] = true
	self.voiceCount += 1

	if not looped then
		clone.Ended:Once(function()
			self:remove(v3)
		end)
	end

	if clone.PlaybackRegionsEnabled then
		clone.TimePosition = clone.PlaybackRegion.Min
	end

	clone:Play()
	return v3
end

function AudioPlayback:one(p, p2, p3, value)
	local v = self.catalog[p]

	if not v then
		return false
	end

	local v2 = p2 or self.folder
	local nows = self.cooldowns[v2]

	if not nows then
		nows = {}
		self.cooldowns[v2] = nows
	end

	local now = os.clock()

	if now - (nows[p] or -1e999) < v.MinInterval then
		return false
	end

	nows[p] = now
	local template = self:template(p)
	local v3 = math.clamp(tonumber(template and template:GetAttribute("PitchVariation")) or 0, 0, 0.04)
	local v4 = value or 1

	if v3 > 0 then
		v4 *= self.random:NextNumber(1 - v3, v3 + 1)
	end

	local v5 = template and self:create(p, template, p2, p3, v4, false)
	self:trace(p, v5 ~= nil)
	return v5 ~= nil
end

function AudioPlayback:loop(p, p2, p3, value, value2)
	local v = p2 and self:template(p2)
	local loop = self.loops[p]

	if loop and (not self.voices[loop] or not v or loop.template ~= v or loop.id ~= v.SoundId) then
		self:remove(loop)
		self.loops[p] = nil
		loop = nil
	end

	if v and not ((value or 1) <= 0.001) then
		if not loop then
			loop = self:create(p2, v, p3, value, value2, true)
			self.loops[p] = loop
			self:trace(p2, loop ~= nil)
		end

		if loop then
			loop.sound.Volume = v.Volume * (value or 1)
			loop.sound.PlaybackSpeed = v.PlaybackSpeed * (value2 or 1)
		end
	elseif loop then
		self:remove(loop)
		self.loops[p] = nil
	end
end

function AudioPlayback:setMusic(musicSlot)
	local template = self:template(musicSlot)
	local musicToken = musicSlot .. ":" .. (not template and "" or template.SoundId or "")

	if self.musicToken == musicToken and (not self.music or self.voices[self.music]) then
		local music = self.music

		if music and os.clock() >= music.fadeEnd then
			music.sound.Volume = template.Volume
			music.sound.PlaybackSpeed = template.PlaybackSpeed
		end
	else
		self.musicToken = musicToken
		self.folder:SetAttribute("MusicSlot", musicSlot)

		if self.music then
			local music = self.music

			if music.tween then
				music.tween:Cancel()
			end

			music.deadline = os.clock() + self.cfg.MusicFade + 0.1
			music.tween = TweenService:Create(music.sound, TweenInfo.new(self.cfg.MusicFade), {
				Volume = 0
			})
			music.tween:Play()
		end

		self.music = nil

		if template then
			local music = self:create(musicSlot, template, nil, 0, 1, true)

			if music then
				music.fadeEnd = os.clock() + self.cfg.MusicFade
				music.tween = TweenService:Create(music.sound, TweenInfo.new(self.cfg.MusicFade), {
					Volume = template.Volume
				})
				music.tween:Play()
				self.music = music
				self:trace(musicSlot, true)
			else
				self.musicToken = ""
			end
		end
	end
end

function AudioPlayback:update()
	local now = os.clock()

	for k in self.voices do
		if k.knifeFade and not k.tween and k.deadline - 0.12 <= now and now < k.deadline and k.sound.Parent then
			k.tween = TweenService:Create(k.sound, TweenInfo.new(0.12), {
				Volume = 0
			})
			k.tween:Play()
		end

		if k.sound.Parent and k.template.Parent then
			local template = k.template
			local v = template and template:IsA("Sound")

			if v then
				if template:GetAttribute("Enabled") == false or template.SoundId:match("%S") == nil or template.SoundId == "rbxassetid://0" then
					v = false
				else
					v = template.SoundId ~= "0"
				end
			end

			if v and self.library:GetAttribute("Enabled") ~= false and k.id == k.template.SoundId and not (k.deadline <= now) then
				continue
			end
		end

		self:remove(k)
	end
end

function AudioPlayback:destroy()
	self.alive = false

	for k in self.voices do
		self:remove(k)
	end

	for k in self.emitters do
		k:Destroy()
	end

	self.folder:Destroy()
end

return AudioPlayback