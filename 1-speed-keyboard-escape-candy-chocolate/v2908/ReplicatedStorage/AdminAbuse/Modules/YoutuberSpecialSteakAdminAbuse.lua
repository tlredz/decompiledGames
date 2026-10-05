local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local YoutuberSpecialSteakAdminAbuseConfig = require(script.YoutuberSpecialSteakAdminAbuseConfig)
local NPCDanceController = require(script.NPCDanceController)
local SharedSyncedEvent = require(ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("SharedSyncedEvent"))
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local AAAudioPlayerVolume = require(ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("AAAudioPlayerVolume"))
local flag = false
local v = nil
local v2 = nil
local maid = Janitor.new()
local YoutuberSpecialSteakAdminAbuse = {}
YoutuberSpecialSteakAdminAbuse.DisplayName = YoutuberSpecialSteakAdminAbuseConfig.DisplayName
YoutuberSpecialSteakAdminAbuse.NeedsDuration = YoutuberSpecialSteakAdminAbuseConfig.NeedsDuration
YoutuberSpecialSteakAdminAbuse.SkipDoorTransition = YoutuberSpecialSteakAdminAbuseConfig.SkipDoorTransition
YoutuberSpecialSteakAdminAbuse.IsAdminAbuse = YoutuberSpecialSteakAdminAbuseConfig.IsAdminAbuse
YoutuberSpecialSteakAdminAbuse.RequiresRespawnRefire = YoutuberSpecialSteakAdminAbuseConfig.RequiresRespawnRefire
YoutuberSpecialSteakAdminAbuse.HasPrioritySoundtrack = YoutuberSpecialSteakAdminAbuseConfig.HasPrioritySoundtrack

function YoutuberSpecialSteakAdminAbuse.Fire(_)
	if flag then
		warn("[YoutuberSpecialSteakAdminAbuse] Fire() ignoré — déjà en cours")
		return
	end

	flag = true
	warn("[YoutuberSpecialSteakAdminAbuse] Client démarré")
	v2 = SharedSyncedEvent.new(YoutuberSpecialSteakAdminAbuseConfig.SSE_CHANNEL)
	maid:Add(function()
		if v2 then
			v2:destroy()
			v2 = nil
		end
	end)
	v2:onChange("phase", function(p)
		warn("[YoutuberSpecialSteakAdminAbuse] Phase →", p)
	end)
	local thread = task.spawn(function()
		local count = 0

		while flag and not v and count < 150 do
			local child = Workspace.AdminAbuse.Map:FindFirstChild(YoutuberSpecialSteakAdminAbuseConfig.MAP_LIVE_NAME)
			local scriptables = child and child:FindFirstChild("Scriptables")
			local nPCs = scriptables and scriptables:FindFirstChild("NPCs")
			local nPCsModel = nPCs and nPCs:FindFirstChildWhichIsA("Model")

			if child and nPCsModel then
				v = child
			else
				task.wait(0.1)
				count += 1
			end
		end

		if not flag then
			return
		end

		if not v then
			warn("[YoutuberSpecialSteakAdminAbuse] Map '" .. YoutuberSpecialSteakAdminAbuseConfig.MAP_LIVE_NAME .. "' introuvable après timeout")
			return
		end

		warn("[YoutuberSpecialSteakAdminAbuse] Map trouvée — contrôleurs démarrés")
		NPCDanceController.Start(v)
		local youtuberSpecialSteakAdminAbuseAudio = v:FindFirstChild("YoutuberSpecialSteakAdminAbuseAudio")

		if not youtuberSpecialSteakAdminAbuseAudio then
			return
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			if not flag then
				return
			end

			for _, audioPlayer in ipairs(youtuberSpecialSteakAdminAbuseAudio:GetChildren()) do
				if audioPlayer:IsA("AudioPlayer") then
					AAAudioPlayerVolume.ApplyFrame(audioPlayer)
				end
			end
		end)

		if flag then
			maid:Add(heartbeatConnection)
			return
		end

		heartbeatConnection:Disconnect()
		NPCDanceController.Stop()
	end)
	maid:Add(function()
		pcall(task.cancel, thread)
	end)
	maid:Add(NPCDanceController, "Stop")
end

function YoutuberSpecialSteakAdminAbuse.Stop(_)
	warn("[YoutuberSpecialSteakAdminAbuse] Client arrêté")
	flag = false
	maid:Cleanup()
	v = nil
end

return YoutuberSpecialSteakAdminAbuse