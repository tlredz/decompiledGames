local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function FireConfettiCannon(instance)
	if not (instance and instance.Parent) then
		return
	end

	local particles = instance:FindFirstChild("Particles")

	for _, child in pairs(particles:GetChildren()) do
		child:Emit(30)
	end

	instance.PrimaryPart.Blast:Play()
end

Client.Events.FireConfettiCannon:Connect(FireConfettiCannon)
Client.InteractionHandler.RegisterInteraction("FireConfetti", function(p)
	print("fire confetti")
	Client.Events.RequestFireConfettiCannon:FireServer(p)
	FireConfettiCannon(p)
end)
return {}