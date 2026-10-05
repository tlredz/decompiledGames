local TweenService = game:GetService("TweenService")
return {
	Btn = 1,
	SortOrder = 3,
	Desc = "When you just need that little nap",
	Callback = function(p)
		if p == true and _G.LocalSettings.Sunset == true then
			_G.LocalSettings.Sunset = false
			_G.SettingUpdate.Sunset:Fire()
		end

		if p == true and _G.LocalSettings.Darkness == true then
			_G.LocalSettings.Darkness = false
			_G.SettingUpdate.Darkness:Fire()
		end

		if p == true then
			TweenService:Create(game.Lighting, TweenInfo.new(0.5), {
				ClockTime = 0,
				Ambient = Color3.new(0, 0, 0),
				OutdoorAmbient = Color3.fromRGB(40, 50, 75),
				FogColor = Color3.new(0, 0, 0),
				EnvironmentDiffuseScale = 0
			}):Play()
			return
		end

		local config = game.Lighting.Config
		TweenService:Create(game.Lighting, TweenInfo.new(0.5), {
			ClockTime = config:GetAttribute("ClockTime"),
			Ambient = config:GetAttribute("Ambient"),
			OutdoorAmbient = config:GetAttribute("OutdoorAmbient"),
			FogColor = config:GetAttribute("FogColor"),
			EnvironmentDiffuseScale = config:GetAttribute("EnvironmentDiffuseScale")
		}):Play()
	end
}