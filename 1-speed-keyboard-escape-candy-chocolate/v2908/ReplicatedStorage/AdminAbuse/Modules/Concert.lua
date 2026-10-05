local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LaserSweep = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("LaserSweep"))
local StageLights = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("StageLights"))
local SpeakerShockwaves = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("SpeakerShockwaves"))
local ConcertDirector = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("ConcertDirector"))
local DJAnimationController = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("DJAnimationController"))
local LightCubeController = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("LightCubeController"))
local MusicNameDiffuserController = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("MusicNameDiffuserController"))
local ConcertZoneController = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("ConcertZoneController"))
local ConcertOrbController = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("ConcertOrbController"))
local ConcertAnnouncementController = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("ConcertAnnouncementController"))
local NeonPulseController = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("NeonPulseController"))
local ConcertSharedConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ConcertSharedConfig"))
local flag = false
local heartbeatConnection = nil
local thread = nil
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = nil
local total = 0
local x3ll3nScene = nil
local audioAnalyzer = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheSceneRefs()
	local aAX3LL3N_Live = Workspace:FindFirstChild("AAX3LL3N_Live")

	if aAX3LL3N_Live then
		x3ll3nScene = aAX3LL3N_Live:FindFirstChild("X3ll3nScene")
		local concertAudio = x3ll3nScene and x3ll3nScene:FindFirstChild("ConcertAudio")

		if concertAudio then
			audioAnalyzer = concertAudio:FindFirstChild("AudioAnalyzer")
		end
	end
end

local Concert = {}
Concert.NeedsDuration = false
Concert.SkipDoorTransition = false
Concert.RequiresRespawnRefire = true
Concert.IsAdminAbuse = true

function Concert.Fire(_, _, p)
	if flag then
		warn("[Concert] Session Concert déjà en cours, ignorer Fire()")
		return
	end

	flag = true
	warn("[Concert] Session Concert démarrée sur le client. isLateJoiner = " .. tostring(p))
	v = LaserSweep.new({
		pattern = "Sweep"
	})
	v2 = StageLights.new({
		pattern = "ConcertScan",
		activeZone = "PublicZone"
	})
	v3 = SpeakerShockwaves.new()
	v4 = DJAnimationController.new()
	v5 = LightCubeController.new()
	v7 = MusicNameDiffuserController.new()
	v8 = ConcertZoneController.new()
	v9 = ConcertOrbController.new()
	v10 = ConcertAnnouncementController.new()
	v11 = NeonPulseController.new()
	v6 = ConcertDirector.new(v2, v, v3, v4, v5, v7, v9, v10, p)
	thread = task.spawn(function()
		local count = 0

		while flag and not x3ll3nScene and count < 150 do
			cacheSceneRefs() -- equivalent call inferred; original call site unknown

			if x3ll3nScene then
				continue
			end

			task.wait(0.1)
			count += 1
		end

		if not (flag and x3ll3nScene) then
			warn("[Concert] Scène introuvable après timeout, laser/lights désactivés")
			return
		end

		v:scan(x3ll3nScene)
		v2:scan(x3ll3nScene)
		v5:scan(x3ll3nScene)
		v7:scan(x3ll3nScene)
		v8:scan(x3ll3nScene)
		v9:scan(x3ll3nScene)
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if not flag then
				return
			end

			local timePosition = 0
			local v12 = not (audioAnalyzer and audioAnalyzer.Parent) and 0 or audioAnalyzer.PeakLevel

			if x3ll3nScene then
				local concertAudio = x3ll3nScene:FindFirstChild("ConcertAudio")

				if concertAudio then
					local audioPlayer = concertAudio:FindFirstChild("AudioPlayer")

					if audioPlayer then
						local assetId = audioPlayer.AssetId

						if v6 and assetId ~= "" then
							if v6._currentAssetId == assetId then
								if v6._currentAudioPlayer ~= audioPlayer then
									v6._currentAudioPlayer = audioPlayer
									warn("[Concert] Instance AudioPlayer mise à jour (même AssetId)")
								end
							else
								v6._currentAudioPlayer = audioPlayer
								v6._currentAssetId = assetId

								for _, v14 in ipairs(ConcertSharedConfig.ConcertMusic) do
									if v14.AssetId ~= assetId then
										continue
									end

									v6:loadTrack(v14.Metadata, v14.Name, audioPlayer.TimePosition)
									break
								end
							end
						end

						if audioPlayer.IsReady then
							timePosition = audioPlayer.TimePosition
							local Players = game:GetService("Players")
							local localPlayer = Players.LocalPlayer

							if localPlayer then
								if localPlayer:GetAttribute("AdminAbuseMuted") == true then
									if audioPlayer.Volume ~= 0 then
										audioPlayer.Volume = 0
									end
								elseif audioPlayer.Volume ~= 1 and timePosition > 0.2 then
									audioPlayer.Volume = 1
								end
							end
						end
					end
				end
			end

			if v6 then
				v6:update(dt, v12, timePosition)
			end

			if v7 then
				v7:update(dt)
			end

			if v8 then
				v8:update(dt)
			end

			if v11 then
				v11:update(dt)
			end

			if timePosition > 0 then
				total += dt

				if total >= 0.5 then
					total = 0
					print(string.format("[Concert Timeline] Temps de la piste en cours : %.1f s", timePosition))
				end
			end
		end)
	end)
end

function Concert.Stop(_)
	warn("[Concert] Session Concert arrêtée sur le client")
	flag = false

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

	if v4 then
		v4:destroy()
		v4 = nil
	end

	if v5 then
		v5:destroy()
		v5 = nil
	end

	if v7 then
		v7:destroy()
		v7 = nil
	end

	if v8 then
		v8:destroy()
		v8 = nil
	end

	if v9 then
		v9:destroy()
		v9 = nil
	end

	if v10 then
		v10:destroy()
		v10 = nil
	end

	if v11 then
		v11:destroy()
		v11 = nil
	end

	if v6 then
		v6:destroy()
		v6 = nil
	end

	x3ll3nScene = nil
	audioAnalyzer = nil
end

return Concert