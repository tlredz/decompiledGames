local TweenService = game:GetService("TweenService")
return {
	Btn = 1,
	SortOrder = 9,
	Desc = "When you just need to chill",
	Callback = function(p)
		if p == true and _G.LocalSettings.Goodnight == true then
			_G.LocalSettings.Goodnight = false
			_G.SettingUpdate.Goodnight:Fire()
		end

		if p == true and _G.LocalSettings.Darkness == true then
			_G.LocalSettings.Darkness = false
			_G.SettingUpdate.Darkness:Fire()
		end

		if p == true then
			TweenService:Create(game.Lighting, TweenInfo.new(0.5), {
				ClockTime = 17.7,
				Ambient = Color3.fromRGB(172, 109, 33),
				OutdoorAmbient = Color3.fromRGB(255, 163, 87),
				FogColor = Color3.fromRGB(84, 0, 0)
			}):Play()
			return
		end

		local config = game.Lighting.Config
		TweenService:Create(game.Lighting, TweenInfo.new(0.5), {
			ClockTime = config:GetAttribute("ClockTime"),
			Ambient = config:GetAttribute("Ambient"),
			OutdoorAmbient = config:GetAttribute("OutdoorAmbient"),
			FogColor = config:GetAttribute("FogColor")
		}):Play()
	end
}