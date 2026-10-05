if script.Parent.Parent ~= game.Players.LocalPlayer.Character then
	return
end

local CameraShaker = require(game.ReplicatedStorage.Modules.CameraShaker)
CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1)