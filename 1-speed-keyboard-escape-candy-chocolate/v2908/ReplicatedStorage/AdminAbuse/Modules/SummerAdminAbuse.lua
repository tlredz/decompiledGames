local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SummerAdminAbuseConfig = require(script.SummerAdminAbuseConfig)
local NPCDanceController = require(script.NPCDanceController)
local SharedSyncedEvent = require(ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("SharedSyncedEvent"))
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local AAAudioPlayerVolume = require(ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("AAAudioPlayerVolume"))
local flag = false
local child = nil
local v = nil
local maid = Janitor.new()
local SummerAdminAbuse = {}
SummerAdminAbuse.DisplayName = SummerAdminAbuseConfig.DisplayName
SummerAdminAbuse.NeedsDuration = SummerAdminAbuseConfig.NeedsDuration
SummerAdminAbuse.SkipDoorTransition = SummerAdminAbuseConfig.SkipDoorTransition
SummerAdminAbuse.IsAdminAbuse = SummerAdminAbuseConfig.IsAdminAbuse
SummerAdminAbuse.RequiresRespawnRefire = SummerAdminAbuseConfig.RequiresRespawnRefire
SummerAdminAbuse.HasPrioritySoundtrack = SummerAdminAbuseConfig.HasPrioritySoundtrack

function SummerAdminAbuse.Fire(_)
	if flag then
		warn("[SummerAdminAbuse] Fire() ignoré — déjà en cours")
		return
	end

	flag = true
	warn("[SummerAdminAbuse] Client démarré")
	v = SharedSyncedEvent.new(SummerAdminAbuseConfig.SSE_CHANNEL)
	maid:Add(function()
		if v then
			v:destroy()
			v = nil
		end
	end)
	v:onChange("phase", function(p)
		warn("[SummerAdminAbuse] Phase →", p)
	end)
	local thread = task.spawn(function()
		local count = 0

		while flag and not child and count < 150 do
			child = Workspace.AdminAbuse.Map:FindFirstChild(SummerAdminAbuseConfig.MAP_LIVE_NAME)

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
			warn("[SummerAdminAbuse] Map '" .. SummerAdminAbuseConfig.MAP_LIVE_NAME .. "' introuvable après timeout")
			return
		end

		warn("[SummerAdminAbuse] Map trouvée — contrôleurs démarrés")
		NPCDanceController.Start(child)
		local summerAdminAbuseAudio = child:FindFirstChild("SummerAdminAbuseAudio")

		if not summerAdminAbuseAudio then
			return
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			if not flag then
				return
			end

			for _, audioPlayer in ipairs(summerAdminAbuseAudio:GetChildren()) do
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

function SummerAdminAbuse.Stop(_)
	warn("[SummerAdminAbuse] Client arrêté")
	flag = false
	maid:Cleanup()
	child = nil
end

return SummerAdminAbuse