local FlashlightReplicateClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.FlashlightToggle:Connect(function(player, p, p2)
	if player.Character and player.Character.PrimaryPart then
		local toolHandle = player.Character:FindFirstChild("ToolHandle")

		if toolHandle and toolHandle:GetAttribute("ToolName") == "Flashlight" then
			if p then
				local transparency = p2 == "Admin Flashlight" and 0.2 or 0.75
				toolHandle.ConeHolder.ConeLight.Transparency = transparency
				task.spawn(function()
					if toolHandle.ConeHolder:WaitForChild("HighlightFlashlightCone", 1) then
						toolHandle.ConeHolder.HighlightFlashlightCone.FillTransparency = 0.95
					end
				end)
				toolHandle.ConeHolder.ConeLight.PointLight.Enabled = true
			else
				toolHandle.ConeHolder.ConeLight.Transparency = 1
				toolHandle.ConeHolder.ConeLight.PointLight.Enabled = false
				task.spawn(function()
					if toolHandle.ConeHolder:WaitForChild("HighlightFlashlightCone", 1) then
						toolHandle.ConeHolder.HighlightFlashlightCone.FillTransparency = 1
					end
				end)
			end
		end
	end
end)
local count = 0
Client.Events.FlashlightWarning:Connect(function(p)
	local batteryBar = Client.Interface.StatBars.BatteryBar
	local v = nil

	if p then
		count += 1
		batteryBar.BatteryWarning.Visible = true
	end

	if not p then
		task.spawn(function()
			v = count
			wait(0.7)

			if v == count then
				batteryBar.BatteryWarning.Visible = false
			end
		end)
	end
end)

function FlashlightReplicateClient.Init()
	task.spawn(function() end)
end

return FlashlightReplicateClient