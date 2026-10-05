local Settings = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Settings.MusicMuted = true
Settings.MouselockEnabled = false

function EnabledMouselockButton()
	task.spawn(function()
		wait(35)

		if Client.GuiButtonHandler.GetCurrentPlatform() == "Touch" then
			local shiftlockButton = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MobileButtons"):WaitForChild("Frame"):WaitForChild("ShiftlockButton")
			shiftlockButton.Visible = true
		end
	end)
end

function Settings.Init()
	Client.Events.LoadSettings:Connect(function(options)
		for k, v in pairs(options or {}) do
			Settings:Set(k, v)
		end

		Settings.SettingsLoaded = true
		Client.Events.SettingsLoaded:Fire()
	end)
	Client.Events.UpdateClientSetting:Connect(function(p, p2)
		Settings:Set(p, p2)
	end)
end

Client.Events.MouselockEnabledChanged:Connect(function(p)
	if Client.GuiButtonHandler.GetCurrentPlatform() == "Touch" and p then
		local shiftlockButton = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MobileButtons"):WaitForChild("Frame"):WaitForChild("ShiftlockButton")
		shiftlockButton.Visible = true
	end
end)

function Settings.Toggle(_, p)
	Settings:Set(p, not Settings[p])
end

function Settings:Set(p, p2)
	local v = Settings[p]

	if v == p2 then
		return
	end

	Settings[p] = p2
	Client.Events[p .. "Changed"]:Fire(p2, v)

	if not Settings.SettingsLoaded then
		return false
	end

	Client.Events.UpdateClientSetting:FireServer(p, p2)
	return true
end

return Settings