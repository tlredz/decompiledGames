local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local rankInGroup = 0
local _, _ = pcall(function()
	rankInGroup = localPlayer:GetRankInGroup(15109848)
end)
return {
	IsLocalPlayerDeveloper = function(_)
		return rankInGroup >= 200
	end
}