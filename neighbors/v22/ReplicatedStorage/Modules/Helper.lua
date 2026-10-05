local Helper = {}
local Arrow = require(script.Arrow)
local localPlayer = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "HelperUI"
screenGui.DisplayOrder = 3
screenGui.IgnoreGuiInset = false
screenGui.ResetOnSpawn = false

function Helper.AddArrow(_, p)
	return Arrow.new(p)
end

return Helper