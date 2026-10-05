local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local parent = script.Parent.Parent
local ParticipantDirectory = require(parent.Presentation.ParticipantDirectory)
local SkinCatalog = require(parent.Weapons.SkinCatalog)
local DaggerConfig = require(parent.Weapons.DaggerConfig)
local FantasyKnifeAudio = require(script.Parent.FantasyKnifeAudio)
local DaggerAudio = {}
DaggerAudio.__index = DaggerAudio

function DaggerAudio.new(playback, cfg)
	FantasyKnifeAudio.install(playback)
	return (setmetatable({
		playback = playback,
		cfg = cfg,
		records = {},
		previewAt = 0,
		remoteTimes = {}
	}, DaggerAudio))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function key(p, p2)
	local v = SkinCatalog.get(p)
	return v and "Knife_" .. v.SoundProfile .. "_" .. p2
end

function DaggerAudio:play(instance, p)
	local localPlayer = Players.LocalPlayer
	local v

	if localPlayer == nil then
		v = false
	else
		v = instance == localPlayer.Character
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local currentCamera = workspace.CurrentCamera

	if not humanoidRootPart or not v and (not currentCamera or (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > self.cfg.RemoteActionDistance) then
		return
	end

	local v2 = key(instance:GetAttribute("DaggerSkin"), p) -- equivalent call inferred; original call site unknown

	if not v2 then
		return
	end

	if not v then
		local now = os.clock()

		while self.remoteTimes[1] and now - self.remoteTimes[1] > 0.12 do
			table.remove(self.remoteTimes, 1)
		end

		if #self.remoteTimes >= 4 then
			return
		else
			table.insert(self.remoteTimes, now)
		end
	end

	local playback = self.playback
	local v3

	if not (v or not humanoidRootPart) then
		v3 = humanoidRootPart
	end

	playback:one(v2, v3, v and 1 or 0.85)
	local layer = FantasyKnifeAudio.layer
	local playback2 = self.playback

	if v or not humanoidRootPart then
		humanoidRootPart = nil
	end

	layer(playback2, v2, humanoidRootPart, v and 1 or 0.85)
end

function DaggerAudio:update()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = {}

	for _, v2 in ParticipantDirectory.list() do
		local character = v2.Character

		if not (character and character.Parent and character:GetAttribute("DaggerEquipped")) then
			continue
		end

		v[character] = true
		local daggerDrawStartedAt = character:GetAttribute("DaggerDrawStartedAt")
		local localPlayer = Players.LocalPlayer

		if localPlayer then
			if character == Players.LocalPlayer.Character then
				localPlayer = character:GetAttribute("LocalMeleeActive") == true
			else
				localPlayer = false
			end
		end

		local localMeleeStartedAt = localPlayer and character:GetAttribute("LocalMeleeStartedAt") or character:GetAttribute("ReachStartedAt")
		local tackleStartedAt = character:GetAttribute("TackleStartedAt")
		local daggerState = character:GetAttribute("DaggerState")
		local localMeleePhase = localPlayer and character:GetAttribute("LocalMeleePhase") or character:GetAttribute("ReachPhase")
		local studioKnifeActionAt = v2:GetAttribute("StudioKnifeActionAt")
		local studioKnifeAction = v2:GetAttribute("StudioKnifeAction")
		local record = self.records[character]

		if record then
			local RunService = game:GetService("RunService")

			if (RunService:IsStudio() or game.PlaceId == 130574217370467) and v2:GetAttribute("StudioKnifePreview") and studioKnifeActionAt and studioKnifeActionAt ~= record.previewAt then
				if studioKnifeAction == "Stab" then
					self:play(character, "Swing")

					if localPlayer then
						record.lastLocalSwingAt = serverTimeNow
					end
				elseif studioKnifeAction == "Dive" then
					self:play(character, "Dive")
				end
			end

			record.previewAt = studioKnifeActionAt

			if daggerDrawStartedAt and daggerDrawStartedAt ~= record.draw and serverTimeNow - daggerDrawStartedAt < 0.5 then
				self:play(character, "Equip")
			end

			record.draw = daggerDrawStartedAt

			if daggerState == "Stowed" and (record.state == "Held" or record.state == "Drawing") then
				self:play(character, "Sheath")
			end

			record.state = daggerState

			if tackleStartedAt and tackleStartedAt ~= record.dive and serverTimeNow - tackleStartedAt < 0.4 and serverTimeNow - (record.lastDiveAt or -1e999) > 0.4 then
				self:play(character, "Dive")
				record.lastDiveAt = serverTimeNow
			end

			record.dive = tackleStartedAt

			if localMeleeStartedAt and localMeleeStartedAt ~= record.stab and localMeleeStartedAt + DaggerConfig.StabDelay <= serverTimeNow then
				if serverTimeNow - localMeleeStartedAt < DaggerConfig.StabDelay + 0.35 and not character:GetAttribute("TackleActive") and serverTimeNow - (record.lastSwingAt or -1e999) > 0.4 then
					self:play(character, "Swing")
					record.lastSwingAt = serverTimeNow
				end

				record.stab = localMeleeStartedAt
			end

			if not localMeleeStartedAt then
				record.stab = nil
			end

			local v3 = localMeleePhase == "Tracking" or localMeleePhase == "Windup"
			local v4 = record.phase == "Tracking" or record.phase == "Windup"

			if v3 and not v4 then
				record.prepareStab = localMeleeStartedAt
				record.prepareDive = tackleStartedAt

				if serverTimeNow - record.windupAt > 0.9 and not character:GetAttribute("TackleActive") then
					self:play(character, "Windup")
					record.windupAt = serverTimeNow
				end
			elseif v4 and not v3 and daggerState == "Held" and localMeleeStartedAt == record.prepareStab and tackleStartedAt == record.prepareDive and not character:GetAttribute("TackleActive") and serverTimeNow - (record.cancelAt or 0) > 0.9 then
				self:play(character, "Cancel")
				record.cancelAt = serverTimeNow
			end

			record.phase = localMeleePhase
		else
			self.records[character] = {
				previewAt = studioKnifeActionAt,
				draw = daggerDrawStartedAt,
				stab = localMeleeStartedAt,
				dive = tackleStartedAt,
				state = daggerState,
				phase = localMeleePhase,
				windupAt = serverTimeNow
			}

			if daggerState == "Drawing" and type(daggerDrawStartedAt) == "number" and serverTimeNow - daggerDrawStartedAt < 0.3 then
				self:play(character, "Equip")
			end
		end
	end

	for k in self.records do
		if not v[k] then
			self.records[k] = nil
		end
	end
end

function DaggerAudio.hit(p, data)
	if type(data) ~= "table" or typeof(data.position) ~= "Vector3" then
		return
	end

	local skin = data.skin
	local v = SkinCatalog.get(skin)
	local v2 = v and "Knife_" .. v.SoundProfile .. "_Hit"

	if not v2 then
		return
	end

	local localPlayer = Players.LocalPlayer

	if localPlayer and data.catcher == localPlayer.UserId then
		p.playback:one(v2, nil, 1)
		FantasyKnifeAudio.layer(p.playback, v2, nil, 1)
	else
		local currentCamera = workspace.CurrentCamera

		if not currentCamera or (data.position - currentCamera.CFrame.Position).Magnitude > p.cfg.RemoteActionDistance then
			return
		end

		local attachment = Instance.new("Attachment")
		attachment.Name = "KnifeImpactAudio"
		attachment.Parent = workspace.Terrain
		attachment.WorldPosition = data.position
		p.playback:one(v2, attachment, 0.9)
		FantasyKnifeAudio.layer(p.playback, v2, attachment, 0.9)
		Debris:AddItem(attachment, 4)
	end
end

function DaggerAudio:preview(p, p2)
	local localPlayer = Players.LocalPlayer

	if localPlayer:GetAttribute("ArmoryOpen") ~= true and localPlayer:GetAttribute("BalloonOfferOpen") ~= true or os.clock() - self.previewAt < 0.18 then
		return
	end

	if not table.find(SkinCatalog.SoundEvents, p2) then
		return
	end

	local v = key(p, p2) -- equivalent call inferred; original call site unknown
	local v2 = v and self.playback:template(v)

	if not v2 then
		return
	end

	self.previewAt = os.clock()
	self.previewSerial = (self.previewSerial or 0) + 1
	local previewSerial = self.previewSerial
	task.spawn(function()
		if not pcall(function()
			local ContentProvider = game:GetService("ContentProvider")
			ContentProvider:PreloadAsync({ v2 })
		end) or previewSerial ~= self.previewSerial or not self.playback.alive then
			return
		end

		if localPlayer:GetAttribute("ArmoryOpen") ~= true and localPlayer:GetAttribute("BalloonOfferOpen") ~= true then
			return
		end

		if self.previewVoice then
			self.playback:remove(self.previewVoice)
		end

		self.previewVoice = self.playback:create(v, v2, nil, 1.15, 1, false)
		self.playback:trace(v, self.previewVoice ~= nil)
		FantasyKnifeAudio.layer(self.playback, v, nil, 1.15)
	end)
end

function DaggerAudio.destroy(p)
	table.clear(p.records)
end

return DaggerAudio