local ConcertDirector = {}
ConcertDirector.__index = ConcertDirector
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local function ema(p: number, p2: number, p3: number, p4: number)
	return p + (1 - math.exp(-p3 * p4)) * (p2 - p)
end

local v = {
	"NoGravity",
	"Spinning",
	"ChickenParty",
	"FastDay"
}

local function updateStateValue(name: string, flag: boolean)
	local Workspace = game:GetService("Workspace")
	local parent = Workspace:FindFirstChild("ConcertState")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "ConcertState"
		parent.Parent = game:GetService("Workspace")
	end

	local v3 = parent:FindFirstChild(name)

	if not v3 then
		v3 = Instance.new("BoolValue")
		v3.Name = name
		v3.Parent = parent
	end

	v3.Value = flag
	warn(string.format("[ConcertDirector StateDbg] %s défini à %s", name, (tostring(flag))))
end

local function getCurrentStateValue(childName: string)
	local Workspace = game:GetService("Workspace")
	local concertState = Workspace:FindFirstChild("ConcertState")

	if concertState then
		local boolValue = concertState:FindFirstChild(childName)

		if boolValue and boolValue:IsA("BoolValue") then
			return boolValue.Value
		end
	end

	return false
end

local v2 = {
	Low = { "SkyRise", "AudienceSweep", "Wave" },
	Medium = {
		"AudienceSweep",
		"Fan",
		"Mirror",
		"ConcertScan"
	},
	High = {
		"Cross",
		"Wave",
		"Alternating",
		"ConcertScan"
	},
	Drop = {
		"Fan",
		"Cross",
		"AudienceSweep",
		"Alternating"
	}
}
local _ = {
	Drop = 0.85,
	High = 0.65,
	Medium = 0.35,
	Low = 0
}

function ConcertDirector.new(stageLights, laserSweep, speakerShockwaves, djController, lightCubeController, musicNameDiffuserController, concertOrbController, concertAnnouncementController, p)
	local self = setmetatable({}, ConcertDirector)
	self._stageLights = stageLights
	self._laserSweep = laserSweep
	self._speakerShockwaves = speakerShockwaves
	self._djController = djController
	self._lightCubeController = lightCubeController
	self._musicNameDiffuserController = musicNameDiffuserController
	self._concertOrbController = concertOrbController
	self._concertAnnouncementController = concertAnnouncementController
	self._energySlow = 0
	self._energyFast = 0
	self._currentPattern = "ConcertScan"
	self._timeSinceLastChange = 0
	self._nextChangeDuration = math.random(8, 15)
	self._currentAudioPlayer = nil
	self._currentAssetId = nil
	self._localTimePosition = nil
	self._lastServerTimePosition = nil
	self._executedCues = {}
	self._joinTimePosition = 0
	self._trackCues = nil
	self._currentCueIndex = 1
	self._manualModeActive = false
	self._isFirstTrackLoaded = false
	self._isLateJoiner = p == true
	return self
end

function ConcertDirector:loadTrack(p, p2, value)
	if self._musicNameDiffuserController and p2 then
		self._musicNameDiffuserController:setSongName(p2)
	end

	local v3 = value or 0

	if p and p.Cues and #p.Cues > 0 then
		self._trackCues = {}

		for _, cue in ipairs(p.Cues) do
			table.insert(self._trackCues, cue)
		end

		table.sort(self._trackCues, function(a, b)
			return a.Time < b.Time
		end)
		warn(string.format("[ConcertDirector LoadTrack] Cues de la track chargées : %d cues.", #self._trackCues))

		for i, _trackCue in ipairs(self._trackCues) do
			warn(string.format(
				"  - Cue %d: Time=%.1fs, Action=%s, NoGravity=%s, Text=%s, SpawnOrbs=%s",
				i,
				_trackCue.Time,
				tostring(_trackCue.Action),
				tostring(_trackCue.NoGravity),
				tostring(_trackCue.Text),
				(tostring(_trackCue.SpawnOrbs))
			))
		end

		local v4 = {}

		for _, childName in ipairs(v) do
			local Workspace = game:GetService("Workspace")
			local concertState = Workspace:FindFirstChild("ConcertState")
			local value2

			if concertState then
				local boolValue = concertState:FindFirstChild(childName)

				if boolValue and boolValue:IsA("BoolValue") then
					value2 = boolValue.Value
				else
					value2 = false
				end
			else
				value2 = false
			end

			v4[childName] = value2
		end

		local action = nil
		local v5 = false

		if not self._isFirstTrackLoaded then
			self._isFirstTrackLoaded = true
			v5 = self._isLateJoiner and v3 > 2 and true or false
		end

		if v5 then
			warn(string.format(
				"[ConcertDirector LoadTrack] Premier chargement (Late-Join) à %.2f s. Recherche des cues antérieures...",
				v3
			))
			local currentCueIndex = 1

			for i, _trackCue in ipairs(self._trackCues) do
				if not (_trackCue.Time <= v3) then
					break
				end

				for _, v7 in ipairs(v) do
					if _trackCue[v7] ~= nil then
						v4[v7] = _trackCue[v7]
					end
				end

				if _trackCue.Action ~= nil then
					action = _trackCue.Action
				end

				currentCueIndex = i + 1
			end

			self._currentCueIndex = currentCueIndex
			self._localTimePosition = v3
			self._lastServerTimePosition = v3
			self._executedCues = {}
			self._joinTimePosition = v3

			for i, _trackCue in ipairs(self._trackCues) do
				if _trackCue.Time < v3 then
					self._executedCues[i] = true
				end
			end

			warn("[ConcertDirector] Chargement de " .. #self._trackCues .. " cues (commence à la cue " .. currentCueIndex .. " au temps " .. v3 .. "s).")

			if action then
				if action == "Automatic" then
					if self._djController then
						self._djController:setMode("Automatic")
					end
				else
					if self._stageLights then
						self._stageLights:setPattern(action)
					end

					if self._laserSweep then
						self._laserSweep:setPattern(action)
					end

					if self._lightCubeController then
						self._lightCubeController:setPattern(action)
					end

					if self._djController then
						if action == "SkyRise" or action == "AudienceSweep" or action == "Mirror" or action == "Blackout" or action == "Fan" then
							self._djController:setMode("ForcedIdle")
						else
							self._djController:setMode("ForcedVibe")
						end
					end
				end
			end
		else
			warn(string.format(
				"[ConcertDirector LoadTrack] Chargement normal de la piste. Lecture depuis le début (0.0s). Temps serveur actuel: %.2f s",
				v3
			))
			self._currentCueIndex = 1
			self._localTimePosition = 0
			self._lastServerTimePosition = 0
			self._executedCues = {}
			self._joinTimePosition = 0
			warn("[ConcertDirector] Chargement de " .. #self._trackCues .. " cues (lecture depuis le début).")
		end

		warn(string.format(
			"[ConcertDirector LoadTrack] Analyse de départ terminée. startIndex=%d",
			self._currentCueIndex
		))

		for _, v6 in ipairs(v) do
			updateStateValue(v6, v4[v6])
		end

		if action == "Automatic" then
			self._manualModeActive = false
		else
			self._manualModeActive = true
		end
	else
		self._trackCues = nil
		self._localTimePosition = nil
		self._lastServerTimePosition = nil
		self._manualModeActive = false

		if self._djController then
			self._djController:setMode("Automatic")
		end
	end
end

function ConcertDirector:_executeCue(data)
	warn(string.format("[ConcertDirector] Exécution de la Cue: %s à %.1fs", tostring(data.Action), data.Time))

	for _, v3 in ipairs(v) do
		if data[v3] ~= nil then
			updateStateValue(v3, data[v3])
		end
	end

	if data.SpawnOrbs ~= nil and self._concertOrbController then
		self._concertOrbController:spawnOrbs(data.SpawnOrbs)
	end

	if data.PlayHorn ~= nil and data.PlayHorn ~= false then
		local soundId

		if data.PlayHorn == 1 then
			soundId = "rbxassetid://5671650124"
		elseif data.PlayHorn == 2 then
			soundId = "rbxassetid://121104033043165"
		elseif type(data.PlayHorn) == "string" then
			soundId = string.find(data.PlayHorn, "121104033043165") and "rbxassetid://121104033043165" or string.find(
				data.PlayHorn,
				"5671650124"
			) and "rbxassetid://5671650124" or data.PlayHorn
		else
			local v4 = { "rbxassetid://5671650124", "rbxassetid://121104033043165" }
			soundId = v4[math.random(1, #v4)]
		end

		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = 0.5
		sound.Looped = false
		sound.Parent = SoundService
		sound:Play()
		Debris:AddItem(sound, 10)
		warn(string.format("[ConcertDirector] Joue le son de corne : %s", soundId))
	end

	if data.Text ~= nil and self._concertAnnouncementController then
		self._concertAnnouncementController:showText(data.Text)
	end

	if data.FlyText ~= nil and self._concertAnnouncementController then
		self._concertAnnouncementController:showFlyText(data.FlyText)
	end

	if data.LuckyText ~= nil and self._concertAnnouncementController then
		self._concertAnnouncementController:showLuckyText(data.LuckyText)
	end

	if data.LokiText ~= nil and self._concertAnnouncementController then
		self._concertAnnouncementController:showLokiText(data.LokiText)
	end

	local action = data.Action

	if not action then
		return
	end

	if action == "Automatic" then
		self._manualModeActive = false

		if self._djController then
			self._djController:setMode("Automatic")
		end
	else
		if self._stageLights then
			self._stageLights:setPattern(action)
		end

		if self._laserSweep then
			self._laserSweep:setPattern(action)
		end

		if self._lightCubeController then
			self._lightCubeController:setPattern(action)
		end

		if self._djController then
			if action == "SkyRise" or action == "AudienceSweep" or action == "Mirror" or action == "Blackout" or action == "Fan" then
				self._djController:setMode("ForcedIdle")
			else
				self._djController:setMode("ForcedVibe")
			end
		end
	end
end

function ConcertDirector:_pickRandomPattern(p2)
	local v3 = v2[p2] or v2.Medium
	local v4 = v3[math.random(1, #v3)]

	if v4 == self._currentPattern and #v3 > 1 then
		for _, v5 in ipairs(v3) do
			if v5 ~= self._currentPattern then
				return v5
			end
		end
	end

	return v4
end

function ConcertDirector:update(p: number, value: number, value2: number)
	local v3 = value or 0
	local v4 = value2 or 0

	if self._manualModeActive and self._trackCues then
		local flag

		if self._lastServerTimePosition and not (math.abs(v4 - self._lastServerTimePosition) > 0.001) then
			flag = false
		else
			self._lastServerTimePosition = v4
			flag = true
		end

		if flag then
			local v5 = not self._localTimePosition and 0 or v4 - self._localTimePosition or 0

			if math.abs(v5) > 0.5 then
				local _localTimePosition = self._localTimePosition
				local _currentCueIndex = self._currentCueIndex
				warn(string.format(
					"[ConcertDirector Resync] Jump détecté ! Ancien temps local: %s s, Nouveau temps serveur: %.2f s, Dérive: %.2f s",
					tostring(_localTimePosition),
					v4,
					v5
				))

				if v5 < -0.5 then
					warn("[ConcertDirector Resync] Retour en arrière détecté. Conservation des flags d'exécution (ne jamais rejouer les mêmes cues).")
				elseif v5 > 0.5 then
					warn(string.format(
						"[ConcertDirector Resync] Saut en avant détecté. Rattrapage des cues entre %s s et %.2f s...",
						tostring(_localTimePosition),
						v4
					))

					for i = self._currentCueIndex, #self._trackCues do
						local _trackCue = self._trackCues[i]

						if not (_trackCue and _trackCue.Time <= v4) then
							break
						end

						if self._executedCues[i] then
							continue
						end

						if v4 - _trackCue.Time <= 5 then
							warn(string.format(
								"[ConcertDirector Resync] Rattrapage de la Cue %d (%s) à %.1f s",
								i,
								tostring(_trackCue.Action),
								_trackCue.Time
							))
							self:_executeCue(_trackCue)
						else
							warn(string.format(
								"[ConcertDirector Resync] Cue %d (%s) trop ancienne (retard de %.1fs), ignorée pour éviter le flood.",
								i,
								tostring(_trackCue.Action),
								v4 - _trackCue.Time
							))
						end

						self._executedCues[i] = true
					end
				end

				local v6 = {}

				for _, childName in ipairs(v) do
					local Workspace = game:GetService("Workspace")
					local concertState = Workspace:FindFirstChild("ConcertState")
					local value3

					if concertState then
						local boolValue = concertState:FindFirstChild(childName)

						if boolValue and boolValue:IsA("BoolValue") then
							value3 = boolValue.Value
						else
							value3 = false
						end
					else
						value3 = false
					end

					v6[childName] = value3
				end

				local action = nil
				local currentCueIndex = 1

				if v4 > 2 then
					for i, _trackCue in ipairs(self._trackCues) do
						if not (_trackCue.Time <= v4) then
							break
						end

						for _, v9 in ipairs(v) do
							if _trackCue[v9] ~= nil then
								v6[v9] = _trackCue[v9]
							end
						end

						if _trackCue.Action ~= nil then
							action = _trackCue.Action
						end

						currentCueIndex = i + 1
					end
				end

				self._currentCueIndex = currentCueIndex
				warn(string.format(
					"[ConcertDirector Resync] Index de cue mis à jour: %d -> %d (startIndex=%d)",
					_currentCueIndex,
					self._currentCueIndex,
					currentCueIndex
				))

				for _, v8 in ipairs(v) do
					updateStateValue(v8, v6[v8])
				end

				if action then
					if action == "Automatic" then
						self._manualModeActive = false

						if self._djController then
							self._djController:setMode("Automatic")
						end
					else
						self._manualModeActive = true

						if self._stageLights then
							self._stageLights:setPattern(action)
						end

						if self._laserSweep then
							self._laserSweep:setPattern(action)
						end

						if self._lightCubeController then
							self._lightCubeController:setPattern(action)
						end

						if self._djController then
							if action == "SkyRise" or action == "AudienceSweep" or action == "Mirror" or action == "Blackout" or action == "Fan" then
								self._djController:setMode("ForcedIdle")
							else
								self._djController:setMode("ForcedVibe")
							end
						end
					end
				end
			end

			self._localTimePosition = v4
		elseif self._localTimePosition then
			self._localTimePosition += p
		else
			self._localTimePosition = v4
		end

		local _localTimePosition = self._localTimePosition
		local _trackCue = self._trackCues[self._currentCueIndex]

		while _trackCue and _trackCue.Time <= _localTimePosition do
			local _currentCueIndex = self._currentCueIndex

			if not self._executedCues[_currentCueIndex] then
				self._executedCues[_currentCueIndex] = true
				self:_executeCue(_trackCue)
			end

			self._currentCueIndex += 1
			_trackCue = self._trackCues[self._currentCueIndex]
		end
	end

	local _energySlow = self._energySlow
	self._energySlow = _energySlow + (1 - math.exp(p * -0.5)) * (v3 - _energySlow)
	local _energyFast = self._energyFast
	self._energyFast = _energyFast + (1 - math.exp(p * -5)) * (v3 - _energyFast)
	local v5

	if self._energyFast > 0.85 and self._energySlow > 0.4 then
		v5 = "Drop"
	elseif self._energySlow > 0.65 then
		v5 = "High"
	elseif self._energySlow > 0.35 then
		v5 = "Medium"
	else
		v5 = "Low"
	end

	if not self._manualModeActive then
		self._timeSinceLastChange += p
		local v6 = v5 == "Drop" and self._energyFast > 0.9 and self._timeSinceLastChange > 3 and (self._currentPattern == "SkyRise" or self._currentPattern == "Wave")

		if self._timeSinceLastChange >= self._nextChangeDuration or v6 then
			self._timeSinceLastChange = 0

			if v5 == "Low" then
				self._nextChangeDuration = math.random(10, 20)
			elseif v5 == "Medium" then
				self._nextChangeDuration = math.random(8, 15)
			elseif v5 == "High" then
				self._nextChangeDuration = math.random(6, 12)
			elseif v5 == "Drop" then
				self._nextChangeDuration = math.random(4, 8)
			end

			local _pickRandomPattern = self:_pickRandomPattern(v5)
			self._currentPattern = _pickRandomPattern

			if self._stageLights then
				self._stageLights:setPattern(_pickRandomPattern)
			end

			if self._laserSweep then
				self._laserSweep:setPattern(_pickRandomPattern)
			end

			if self._lightCubeController then
				self._lightCubeController:setPattern(_pickRandomPattern)
			end
		end
	end

	if self._stageLights then
		self._stageLights:update(p, v3)
	end

	if self._laserSweep then
		self._laserSweep:update(p, v3)
	end

	if self._speakerShockwaves then
		self._speakerShockwaves:update(p, v3)
	end

	if self._djController then
		self._djController:update(p, v3)
	end

	if self._lightCubeController then
		self._lightCubeController:update(p)
	end
end

function ConcertDirector.destroy(_)
	local Workspace = game:GetService("Workspace")
	local concertState = Workspace:FindFirstChild("ConcertState")

	if concertState then
		concertState:Destroy()
	end
end

return ConcertDirector