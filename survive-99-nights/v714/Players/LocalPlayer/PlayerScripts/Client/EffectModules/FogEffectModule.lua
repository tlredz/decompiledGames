local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
Client.Events.FadeOutFogBlock:Connect(function(_, instance)
	if not instance then
		return
	end

	instance:SetAttribute("Destroyed", true)

	if (instance.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		instance:Destroy()
		return
	end

	TweenService:Create(instance, TweenInfo.new(0.5), {
		Transparency = 1
	}):Play()
	wait(0.5)
	instance:Destroy()
end)
Client.Utility.ForAllTagged("FogBlock", function(instance)
	instance.Touched:Connect(function(otherPart)
		if instance:GetAttribute("Destroyed") then
			return
		end

		if otherPart == Client.PlayerHandler.HumanoidRootPart or otherPart.Name == "TorchTouchZone" then
			Client.Events.FadeOutFogBlock:FireAllClients(instance)
		end

		if localPlayer:GetAttribute("Class") == "Explorer" and otherPart == Client.PlayerHandler.HumanoidRootPart then
			Client.WalkspeedController.ExplorerSpeedBoost()
		end
	end)
end)
return {}