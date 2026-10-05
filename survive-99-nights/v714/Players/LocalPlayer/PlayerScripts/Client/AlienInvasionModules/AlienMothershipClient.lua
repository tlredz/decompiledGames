local AlienMothershipClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local pivot = nil
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function TeleportParticles(player)
	if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.PrimaryPart) then
		return
	end

	local rootAttachment = player.Character.HumanoidRootPart.RootAttachment
	local clone = ReplicatedStorage.Assets.Particles.CrackyTeleportEffect.CrackyTeleportEffect:Clone()
	clone.Parent = rootAttachment

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			task.wait(v:GetAttribute("EmitDelay") or 0)

			if v:GetAttribute("EmitDuration") then
				v.Enabled = true
				task.spawn(function()
					wait(v:GetAttribute("EmitDuration"))
					v.Enabled = false
				end)
			end

			if v:GetAttribute("EmitCount") then
				v:Emit(v:GetAttribute("EmitCount"))
			end
		end)
	end

	task.spawn(function()
		wait(2)

		if player.Character and player.Character.PrimaryPart then
			Client.Sound.Play("Boosted", {
				Volume = 0.4,
				Replicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.3
				}
			})
		end
	end)
	task.spawn(function()
		wait(7)

		if clone then
			clone:Destroy()
		end
	end)
end

function HideTeleportPrompts()
	for _, v in pairs(CollectionService:GetTagged("AlienTeleportPrompt")) do
		local v2 = v
		task.spawn(function()
			v2.Enabled = false
			wait(5)
			v2.Enabled = true
		end)
	end
end

function AlienMothershipClient.TeleportToMothership(instance)
	if pivot == nil then
		pivot = instance:GetPivot()
	end

	HideTeleportPrompts()
	TeleportParticles(localPlayer)
	Client.TeleportingClient.Teleport("Alien Mothership", 1.3, {
		CoverType = "Alien Mothership"
	})
end

Client.InteractionHandler.RegisterInteraction("UFOTeleportUp", function(p)
	AlienMothershipClient.TeleportToMothership(p)
end)

function AlienMothershipClient.TeleportToEarth()
	HideTeleportPrompts()
	TeleportParticles(localPlayer)
	Client.TeleportingClient.Teleport("AlienCrashActiveCF", 1.3, {
		CoverType = "Forest"
	})
end

Client.InteractionHandler.RegisterInteraction("UFOTeleportBack", function(p)
	AlienMothershipClient.TeleportToEarth(p)
end)

function AlienMothershipClient.Init() end

return AlienMothershipClient