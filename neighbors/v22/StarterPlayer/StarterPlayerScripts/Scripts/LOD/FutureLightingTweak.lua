local Server = require(game.ReplicatedStorage.Modules.Server)

if not game.Lighting:FindFirstChild("Bloom") or Server:GetLightingType() == Enum.Technology.Future and game.Lighting.Bloom.Intensity ~= 1 then
	return
end

local intensity = game.Lighting.Bloom.Intensity

function doLightingLOD()
	if not game.Lighting:FindFirstChild("Bloom") then
		return
	end

	if UserSettings().GameSettings.SavedQualityLevel.Value < Enum.SavedQualitySetting.QualityLevel4.Value then
		game.Lighting.Bloom.Intensity = 0.15
	else
		game.Lighting.Bloom.Intensity = intensity
	end
end

doLightingLOD()
UserSettings().GameSettings.Changed:Connect(function(p)
	if p == "SavedQualityLevel" then
		doLightingLOD()
	end
end)