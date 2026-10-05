local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IndependenceDayConfig = require(script.IndependenceDayConfig)
local IndependenceDayCutscenes = require(script.IndependenceDayCutscenes)
local FireworksController = require(script.FireworksController)
local ShowController = require(script.ShowController)
local IndependenceDayLightsDirector = require(script.IndependenceDayLightsDirector)
local IndependenceDayCommandPanel = require(script.IndependenceDayCommandPanel)
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
local IndependenceDay = {}
IndependenceDay.DisplayName = IndependenceDayConfig.DisplayName
IndependenceDay.NeedsDuration = IndependenceDayConfig.NeedsDuration
IndependenceDay.SkipDoorTransition = IndependenceDayConfig.SkipDoorTransition
IndependenceDay.IsAdminAbuse = IndependenceDayConfig.IsAdminAbuse
IndependenceDay.RequiresRespawnRefire = IndependenceDayConfig.RequiresRespawnRefire
IndependenceDay.HasPrioritySoundtrack = IndependenceDayConfig.HasPrioritySoundtrack

function IndependenceDay.Fire(_)
	if flag then
		warn("[IndependenceDay] Fire() ignoré — déjà en cours")
		return
	end

	flag = true
	warn("[IndependenceDay] Client démarré")
	v = SharedSyncedEvent.new(IndependenceDayConfig.SSE_CHANNEL)
	v:onChange("phase", function(p)
		warn("[IndependenceDay] Phase →", p)
	end)
	v:onChange("OpeningCutscene", function(p)
		IndependenceDayCutscenes.playOpening(p)
	end)
	v:onChange("EndingCutscene", function(p)
		IndependenceDayCutscenes.playEnding(p)
	end)
	v:onChange("CleanupDone", function()
		IndependenceDayCutscenes.notifyCleanupDone()
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
	local independenceDayCommand = remotes:WaitForChild("IndependenceDayCommand", 15)
	local independenceDayWinOrbCollected = remotes:WaitForChild("IndependenceDayWinOrbCollected", 15)

	if independenceDayCommand and independenceDayCommand:IsA("RemoteEvent") then
		IndependenceDayCommandPanel.init(v, independenceDayCommand, independenceDayWinOrbCollected)
	else
		warn("[IndependenceDay] IndependenceDayCommand remote introuvable — panel de commande désactivé")
	end

	thread = task.spawn(function()
		local count = 0

		while flag and not child and count < 150 do
			child = Workspace.AdminAbuse.Map:FindFirstChild(IndependenceDayConfig.MAP_LIVE_NAME)

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
			warn("[IndependenceDay] Map '" .. IndependenceDayConfig.MAP_LIVE_NAME .. "' introuvable après timeout")
			return
		end

		warn("[IndependenceDay] Map trouvée — boucle de rendu démarrée")
		ShowController.RunSequential(child)
		NPCDanceController.Start(child)
		local scriptables = child:FindFirstChild("Scriptables")
		local spotlights = scriptables and scriptables:FindFirstChild("Spotlights")
		local laserSpots = scriptables and scriptables:FindFirstChild("LaserSpots")

		if spotlights and laserSpots then
			v2 = StageLights.new({
				pattern = IndependenceDayConfig.STAGE_LIGHT_PATTERNS[1],
				colorCycle = true,
				colorPalette = IndependenceDayConfig.LIGHT_COLOR_PALETTE,
				colorCycleMinSec = IndependenceDayConfig.LIGHT_COLOR_CYCLE_MIN_SEC,
				colorCycleMaxSec = IndependenceDayConfig.LIGHT_COLOR_CYCLE_MAX_SEC
			})
			v3 = LaserSweep.new({
				pattern = IndependenceDayConfig.LASER_PATTERN,
				colorCycle = true,
				colorPalette = IndependenceDayConfig.LIGHT_COLOR_PALETTE,
				colorCycleMinSec = IndependenceDayConfig.LIGHT_COLOR_CYCLE_MIN_SEC,
				colorCycleMaxSec = IndependenceDayConfig.LIGHT_COLOR_CYCLE_MAX_SEC
			})
			v2:scan(spotlights)
			v3:scan(laserSpots)
			v4 = IndependenceDayLightsDirector.new(v2, v3)
		else
			warn("[IndependenceDay] Scriptables/Spotlights ou Scriptables/LaserSpots introuvable — lights/lasers désactivés")
		end

		local independenceDayAudio = child:FindFirstChild("IndependenceDayAudio")
		audioAnalyzer = independenceDayAudio and independenceDayAudio:FindFirstChild("AudioAnalyzer")
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if not flag then
				return
			end

			local peakLevel = audioAnalyzer and audioAnalyzer.Parent and audioAnalyzer.PeakLevel or 0

			if v4 then
				v4:update(dt, peakLevel)
			end

			if independenceDayAudio then
				for _, audioPlayer in ipairs(independenceDayAudio:GetChildren()) do
					if audioPlayer:IsA("AudioPlayer") then
						AAAudioPlayerVolume.ApplyFrame(audioPlayer)
					end
				end
			end
		end)
	end)
end

function IndependenceDay.Stop(_)
	warn("[IndependenceDay] Client arrêté")
	flag = false
	IndependenceDayCutscenes.stop()
	ShowController.Stop()
	IndependenceDayCommandPanel.Stop()
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

IndependenceDay.Hidden = true
return IndependenceDay