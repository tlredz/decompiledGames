local RandomBoxClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()

function Rand(p, p2)
	return p + random:NextNumber() * (p2 - p)
end

Client.Events.VisualOpenPresent:Connect(function(p)
	RandomBoxClient.OpenChest(p, false, true)
end)

function RandomBoxClient.OpenChest(instance, p, p2)
	if p then
		instance:Destroy()
		return
	end

	if not p2 then
		Client.Events.RequestOpenItemChest:FireServer(instance)
	end

	if p2 then
		if instance.PrimaryPart:FindFirstChild("ProximityAttachment") then
			instance.PrimaryPart.ProximityAttachment:Destroy()
		end

		instance:RemoveTag("Interaction")
	end

	instance:PivotTo((instance:GetAttribute("OrigCF")))
	local clone = instance:Clone()
	clone.Parent = workspace.Particles
	instance:Destroy()
	local primaryPart = clone.PrimaryPart
	Client.Utility.SpawnParticles("PresentVFX", primaryPart.CFrame)
	task.delay(20, function()
		clone:Destroy()
	end)
end

function RandomBoxClient.Init() end

return RandomBoxClient