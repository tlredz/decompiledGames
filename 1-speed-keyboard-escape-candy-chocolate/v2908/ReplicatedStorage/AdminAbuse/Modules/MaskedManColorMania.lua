local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
ReplicatedStorage:WaitForChild("AdminAbuse")
local KeycapScoreBarClient = require(script.KeycapScoreBarClient)
local MaskedManColorManiaConfig = require(script.MaskedManColorManiaConfig)
local MaskedManColorManiaCutscenes = require(script.MaskedManColorManiaCutscenes)
local BossAnimationClient = require(script.BossAnimationClient)
local WinPadClient = require(script.WinPadClient)
local OrbsClient = require(script.OrbsClient)
local KeycapColorClient = require(script.KeycapColorClient)
local FakeAdminMessageUtil = require(ReplicatedStorage.Utilities.FakeAdminMessageUtil)
local MaskedManMessagePanel = require(script.MaskedManMessagePanel)
local ColorBeam = require(script.AttacksClient.ColorBeam)
local ColorTimeshift = require(script.AttacksClient.ColorTimeshift)
local InkRain = require(script.AttacksClient.InkRain)
local PaintBalloonRain = require(script.AttacksClient.PaintBalloonRain)
local NoobUncoloners = require(script.AttacksClient.NoobUncoloners)
local PaintSprayer = require(script.AttacksClient.PaintSprayer)
local v = nil
local flag = false
local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function isCutscenePayloadFresh(p)
	local firedAt = p.firedAt
	return type(firedAt) ~= "number" or os.time() - firedAt <= 20
end

local function handleFx(p: string, data)
	if p == "OpeningCutscene" then
		if not isCutscenePayloadFresh(data) then
			return
		end

		task.spawn(function()
			local child = workspace:FindFirstChild(data.mapName, true)

			if child then
				MaskedManColorManiaCutscenes.init(child)
				MaskedManColorManiaCutscenes.playOpening()
			end
		end)
	elseif p == "EndingCutscene" then
		if not isCutscenePayloadFresh(data) then
			return
		end

		task.spawn(function()
			local child = workspace:FindFirstChild(data.mapName, true)

			if child then
				MaskedManColorManiaCutscenes.init(child)
				MaskedManColorManiaCutscenes.playEnding()
			end
		end)
	elseif p == "ColorBeamWarn" then
		ColorBeam.ColorBeamWarn(data)
	elseif p == "ColorBeamHit" then
		ColorBeam.ColorBeamHit(data)
	elseif p == "ColorTimeshiftBegin" then
		task.spawn(ColorTimeshift.begin, data.fadeIn)
	elseif p == "ColorTimeshiftEnd" then
		task.spawn(ColorTimeshift.finish, data.fadeOut)
	elseif p == "InkRainDrop" then
		InkRain.InkRainDrop(data)
	elseif p == "PaintBalloonDrop" then
		PaintBalloonRain.PaintBalloonDrop(data)
	elseif p == "SpawnPaintSprayerPickup" then
		PaintSprayer.SpawnPaintSprayerPickup(data)
	elseif p == "DespawnPaintSprayerPickup" then
		PaintSprayer.DespawnPaintSprayerPickup(data)
	elseif p == "NpcSummonFx" then
		NoobUncoloners.NpcSummonFx(data)
	elseif p == "NpcDied" then
		NoobUncoloners.NpcDied(data)
	elseif p == "DisappearNPC" then
		NoobUncoloners.DisappearNPC(data)
	elseif p == "BossLaugh" then
		BossAnimationClient.playLaugh()
	elseif p == "BossRoar" then
		BossAnimationClient.playRoar()
	elseif p == "ShowBossMessage" then
		local message = data.message

		if type(message) ~= "string" or message == "" then
			return
		end

		local senderId = data.senderId or MaskedManColorManiaConfig.DefaultSenderId
		local duration = data.duration or 8

		if type(data.senderName) == "string" and type(data.senderIcon) == "string" then
			FakeAdminMessageUtil.show({
				message = message,
				senderName = data.senderName,
				senderUserId = senderId,
				preloadedThumb = data.senderIcon,
				duration = duration
			})
		else
			task.spawn(function()
				local success, result = pcall(function()
					return Players:GetNameFromUserIdAsync(senderId)
				end)
				FakeAdminMessageUtil.show({
					message = message,
					senderName = success and result or "User" .. tostring(senderId),
					senderUserId = senderId,
					preloadedThumb = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(senderId),
					duration = duration
				})
			end)
		end
	elseif p == "SpawnOrbs" then
		local v2 = type(data.count) == "number" and math.max(1, (math.floor(data.count))) or 1
		task.spawn(OrbsClient.spawnFromZone, v2)
	elseif p == "SpawnGiantOrbs" then
		local v2 = type(data.count) == "number" and math.max(1, (math.floor(data.count))) or 1
		task.spawn(OrbsClient.spawnGiantFromZone, v2)
	end
end

local MaskedManColorMania = {}
MaskedManColorMania.IsAdminAbuse = true
MaskedManColorMania.NeedsDuration = false

function MaskedManColorMania.Fire(_)
	flag = false
	flag2 = false
	v = KeycapScoreBarClient.new({
		sseChannelName = MaskedManColorManiaConfig.sseChannelName,
		bossIcon = MaskedManColorManiaConfig.bossIcon,
		durationSec = MaskedManColorManiaConfig.BossTheatreDurationSec,
		keycapTag = MaskedManColorManiaConfig.KeycapTag,
		keycapColoredTag = MaskedManColorManiaConfig.KeycapColoredTag,
		onFx = function(p, p2)
			if p == "OpeningCutscene" then
				if flag then
					return
				else
					flag = true
				end
			elseif p == "EndingCutscene" then
				if flag2 then
					return
				else
					flag2 = true
				end
			end

			handleFx(p, p2)
		end
	})
	v:fire()
	local _sse = v._sse

	if _sse then
		_sse:onChange("OpeningCutscene", function(p)
			if type(p) == "table" and p.mapName and not flag and isCutscenePayloadFresh(p) then
				task.delay(5, function()
					if not flag then
						flag = true
						local v2 = p

						if not isCutscenePayloadFresh(v2) then
							return
						end

						task.spawn(function()
							local child = workspace:FindFirstChild(v2.mapName, true)

							if child then
								MaskedManColorManiaCutscenes.init(child)
								MaskedManColorManiaCutscenes.playOpening()
							end
						end)
					end
				end)
			end
		end)
		_sse:onChange("EndingCutscene", function(p)
			if type(p) == "table" and p.mapName and not flag2 and isCutscenePayloadFresh(p) then
				task.delay(2, function()
					if not flag2 then
						flag2 = true
						local v2 = p

						if not isCutscenePayloadFresh(v2) then
							return
						end

						task.spawn(function()
							local child = workspace:FindFirstChild(v2.mapName, true)

							if child then
								MaskedManColorManiaCutscenes.init(child)
								MaskedManColorManiaCutscenes.playEnding()
							end
						end)
					end
				end)
			end
		end)
	end

	BossAnimationClient.start(v._sse, MaskedManColorManiaConfig.mapModelName, MaskedManColorManiaConfig)
	WinPadClient.start(MaskedManColorManiaConfig)
	KeycapColorClient.start(MaskedManColorManiaConfig)
	PaintSprayer.start(MaskedManColorManiaConfig)
	task.spawn(function()
		local adminAbuse = workspace:WaitForChild("AdminAbuse", 10)
		local map = adminAbuse and adminAbuse:WaitForChild("Map", 10)
		local child = map and map:WaitForChild(MaskedManColorManiaConfig.mapModelName .. "_Live", 10)

		if child then
			OrbsClient.scan(child)
		else
			warn("[MaskedManColorMania] OrbsClient.scan: map clone not found")
		end
	end)
	task.spawn(function()
		local child = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes"):WaitForChild(
			MaskedManColorManiaConfig.MessageCommandRemoteName,
			10
		)

		if child then
			MaskedManMessagePanel.init(child)
		else
			warn("[MaskedManColorMania] MessageCommandRemote not found — trusted message panel disabled")
		end
	end)
end

function MaskedManColorMania.Stop()
	MaskedManColorManiaCutscenes.stopAll()
	flag = false
	flag2 = false
	BossAnimationClient.stop()
	WinPadClient.stop()
	KeycapColorClient.stop()
	OrbsClient.cleanup()
	ColorBeam.cleanup()
	ColorTimeshift.cleanup()
	InkRain.cleanup()
	PaintBalloonRain.cleanup()
	NoobUncoloners.cleanup()
	PaintSprayer.cleanup()
	MaskedManMessagePanel.Stop()

	if v then
		v:stop()
		v = nil
	end
end

MaskedManColorMania.Hidden = true
return MaskedManColorMania