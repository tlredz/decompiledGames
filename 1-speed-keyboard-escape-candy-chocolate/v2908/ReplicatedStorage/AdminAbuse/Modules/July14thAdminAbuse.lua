local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local July14thAdminAbuseConfig = require(script.July14thAdminAbuseConfig)
local July14thAdminAbuseCutscenes = require(script.July14thAdminAbuseCutscenes)
local FireworksController = require(script.FireworksController)
local ShowController = require(script.ShowController)
local July14thAdminAbuseLightsDirector = require(script.July14thAdminAbuseLightsDirector)
local July14thAdminAbuseCommandPanel = require(script.July14thAdminAbuseCommandPanel)
local July14thAdminAbuseReporterPanel = require(script.July14thAdminAbuseReporterPanel)
local NPCDanceController = require(script.NPCDanceController)
local LaserSweep = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("LaserSweep"))
local StageLights = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("StageLights"))
local SharedSyncedEvent = require(ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("SharedSyncedEvent"))
local AAAudioPlayerVolume = require(ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("AAAudioPlayerVolume"))
local flag = false
local heartbeatConnection = nil
local thread = nil
local child = nil
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local audioAnalyzer = nil
local July14thAdminAbuse = {}
July14thAdminAbuse.DisplayName = July14thAdminAbuseConfig.DisplayName
July14thAdminAbuse.NeedsDuration = July14thAdminAbuseConfig.NeedsDuration
July14thAdminAbuse.SkipDoorTransition = July14thAdminAbuseConfig.SkipDoorTransition
July14thAdminAbuse.IsAdminAbuse = July14thAdminAbuseConfig.IsAdminAbuse
July14thAdminAbuse.RequiresRespawnRefire = July14thAdminAbuseConfig.RequiresRespawnRefire
July14thAdminAbuse.HasPrioritySoundtrack = July14thAdminAbuseConfig.HasPrioritySoundtrack

function July14thAdminAbuse.Fire(_)
	if flag then
		warn("[July14thAdminAbuse] Fire() ignoré — déjà en cours")
		return
	end

	flag = true
	warn("[July14thAdminAbuse] Client démarré")
	v = SharedSyncedEvent.new(July14thAdminAbuseConfig.SSE_CHANNEL)
	v:onChange("phase", function(p)
		warn("[July14thAdminAbuse] Phase →", p)
	end)
	v:onChange("OpeningCutscene", function(p)
		July14thAdminAbuseCutscenes.playOpening(p)
	end)
	v:onChange("EndingCutscene", function(p)
		July14thAdminAbuseCutscenes.playEnding(p)
	end)
	v:onChange("CleanupDone", function()
		July14thAdminAbuseCutscenes.notifyCleanupDone()
	end)
	v:onFire("firework", function(p)
		if not child then
			return
		end

		for _ = 1, p and p.count or 1 do
			FireworksController.FireRandom(child)
		end
	end)
	local remotes = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes")
	local july14thAdminAbuseCommand = remotes:WaitForChild("July14thAdminAbuseCommand", 15)
	local july14thAdminAbuseWinOrbCollected = remotes:WaitForChild("July14thAdminAbuseWinOrbCollected", 15)

	if july14thAdminAbuseCommand and july14thAdminAbuseCommand:IsA("RemoteEvent") then
		July14thAdminAbuseCommandPanel.init(v, july14thAdminAbuseCommand, july14thAdminAbuseWinOrbCollected)
	else
		warn("[July14thAdminAbuse] July14thAdminAbuseCommand remote introuvable — panel de commande désactivé")
	end

	local july14thAdminAbuseReporterMessage = remotes:WaitForChild("July14thAdminAbuseReporterMessage", 15)

	if july14thAdminAbuseReporterMessage and july14thAdminAbuseReporterMessage:IsA("RemoteEvent") then
		July14thAdminAbuseReporterPanel.init(july14thAdminAbuseReporterMessage)
	else
		warn("[July14thAdminAbuse] July14thAdminAbuseReporterMessage remote introuvable — panel reporter désactivé")
	end

	thread = task.spawn(function()
		local count = 0

		while flag and not child and count < 150 do
			child = Workspace.AdminAbuse.Map:FindFirstChild(July14thAdminAbuseConfig.MAP_LIVE_NAME)

			if child then
				continue
			end

			task.wait(0.1)
			count += 1
		end

		if not flag then
			return
		end

		if not child then
			warn("[July14thAdminAbuse] Map '" .. July14thAdminAbuseConfig.MAP_LIVE_NAME .. "' introuvable après timeout")
			return
		end

		warn("[July14thAdminAbuse] Map trouvée — boucle de rendu démarrée")
		ShowController.RunSequential(child)
		NPCDanceController.Start(child)
		local scriptables = child:FindFirstChild("Scriptables")
		local spotlights = scriptables and scriptables:FindFirstChild("Spotlights")
		local laserSpots = scriptables and scriptables:FindFirstChild("LaserSpots")

		if spotlights and laserSpots then
			v2 = StageLights.new({
				pattern = July14thAdminAbuseConfig.STAGE_LIGHT_PATTERNS[1],
				colorCycle = true,
				colorPalette = July14thAdminAbuseConfig.LIGHT_COLOR_PALETTE,
				colorCycleMinSec = July14thAdminAbuseConfig.LIGHT_COLOR_CYCLE_MIN_SEC,
				colorCycleMaxSec = July14thAdminAbuseConfig.LIGHT_COLOR_CYCLE_MAX_SEC
			})
			v3 = LaserSweep.new({
				pattern = July14thAdminAbuseConfig.LASER_PATTERN,
				colorCycle = true,
				colorPalette = July14thAdminAbuseConfig.LIGHT_COLOR_PALETTE,
				colorCycleMinSec = July14thAdminAbuseConfig.LIGHT_COLOR_CYCLE_MIN_SEC,
				colorCycleMaxSec = July14thAdminAbuseConfig.LIGHT_COLOR_CYCLE_MAX_SEC
			})
			v2:scan(spotlights)
			v3:scan(laserSpots)
			v4 = July14thAdminAbuseLightsDirector.new(v2, v3)
		else
			warn("[July14thAdminAbuse] Scriptables/Spotlights ou Scriptables/LaserSpots introuvable — lights/lasers désactivés")
		end

		local july14thAdminAbuseAudio = child:FindFirstChild("July14thAdminAbuseAudio")
		audioAnalyzer = july14thAdminAbuseAudio and july14thAdminAbuseAudio:FindFirstChild("AudioAnalyzer")
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if not flag then
				return
			end

			local peakLevel = audioAnalyzer and audioAnalyzer.Parent and audioAnalyzer.PeakLevel or 0

			if v4 then
				v4:update(dt, peakLevel)
			end

			if july14thAdminAbuseAudio then
				for _, audioPlayer in ipairs(july14thAdminAbuseAudio:GetChildren()) do
					if audioPlayer:IsA("AudioPlayer") then
						AAAudioPlayerVolume.ApplyFrame(audioPlayer)
					end
				end
			end
		end)
	end)
end

function July14thAdminAbuse.Stop(_)
	warn("[July14thAdminAbuse] Client arrêté")
	flag = false
	July14thAdminAbuseCutscenes.stop()
	ShowController.Stop()
	July14thAdminAbuseCommandPanel.Stop()
	July14thAdminAbuseReporterPanel.Stop()
	NPCDanceController.Stop()

	if thread then
		task.cancel(thread)
		thread = nil
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v then
		v:destroy()
		v = nil
	end

	if v2 then
		v2:destroy()
		v2 = nil
	end

	if v3 then
		v3:destroy()
		v3 = nil
	end

	v4 = nil
	audioAnalyzer = nil
	child = nil
end

July14thAdminAbuse.Hidden = true
return July14thAdminAbuse