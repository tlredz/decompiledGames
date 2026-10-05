local CampfireEffectModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
CampfireEffectModule.FireEffectEnabled = false
CampfireEffectModule.PlayerNearFire = false
local mainFire = nil

function Enable()
	if not mainFire then
		mainFire = workspace.Map.Campground.MainFire
	end

	Client.ColorCorrectionLightingClient.ToggleFire(true)
	Client.WeatherEffectModule.LessRain(true)
	mainFire.PrimaryPart.FarAway.Enabled = false
	mainFire.PrimaryPart.BillboardGui.Frame.Visible = true
	CampfireEffectModule.PlayerNearFire = true
end

function Disable()
	if not mainFire then
		mainFire = workspace.Map.Campground.MainFire
	end

	Client.ColorCorrectionLightingClient.ToggleFire(false)
	Client.WeatherEffectModule.LessRain(false)
	mainFire.PrimaryPart.FarAway.Enabled = true
	mainFire.PrimaryPart.BillboardGui.Frame.Visible = false
	CampfireEffectModule.PlayerNearFire = false

	if not Client.InventoryHandler.GetCurrentlyEquipped() or Client.InventoryHandler.GetCurrentlyEquipped():GetAttribute("ToolName") ~= "Flashlight" then
		Client.StatsUI.HideBar()
	end
end

function CampfireEffectModule.SetEnabled(fireEffectEnabled)
	if fireEffectEnabled ~= CampfireEffectModule.FireEffectEnabled then
		CampfireEffectModule.FireEffectEnabled = fireEffectEnabled

		if CampfireEffectModule.FireEffectEnabled then
			Enable()
		else
			Disable()
		end
	end
end

return CampfireEffectModule