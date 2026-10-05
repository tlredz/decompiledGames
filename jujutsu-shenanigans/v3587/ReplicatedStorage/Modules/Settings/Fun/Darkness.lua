local TweenService = game:GetService("TweenService")
return {
	Btn = 1,
	SortOrder = 10,
	Desc = "OLED",
	Callback = function(p)
		if p == true and _G.LocalSettings.Goodnight == true then
			_G.LocalSettings.Goodnight = false
			_G.SettingUpdate.Goodnight:Fire()
		end

		if p == true and _G.LocalSettings.Sunset == true then
			_G.LocalSettings.Sunset = false
			_G.SettingUpdate.Sunset:Fire()
		end

		if p == true and _G.LocalSettings.Jolly == true then
			_G.LocalSettings.Jolly = false
			_G.SettingUpdate.Jolly:Fire()
		end

		if p == true then
			TweenService:Create(game.Lighting, TweenInfo.new(0.5), {
				ClockTime = 0,
				Ambient = Color3.fromRGB(0, 0, 0),
				OutdoorAmbient = Color3.fromRGB(0, 0, 0),
				FogColor = Color3.fromRGB(0, 0, 0),
				EnvironmentDiffuseScale = 0,
				FogEnd = 50,
				Brightness = 0
			}):Play()
			return
		end

		local config = game.Lighting.Config
		TweenService:Create(game.Lighting, TweenInfo.new(0.5), {
			ClockTime = config:GetAttribute("ClockTime"),
			Ambient = config:GetAttribute("Ambient"),
			OutdoorAmbient = config:GetAttribute("OutdoorAmbient"),
			FogColor = config:GetAttribute("FogColor"),
			Brightness = config:GetAttribute("Brightness"),
			FogEnd = config:GetAttribute("FogEnd")
		}):Play()
	end
}