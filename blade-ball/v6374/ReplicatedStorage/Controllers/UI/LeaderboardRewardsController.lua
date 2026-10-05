local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(game.ReplicatedStorage.Packages.Replion)
local v = require3(game.ReplicatedStorage.Packages.Net)
local v2 = require3(game.ReplicatedStorage.ClientGameModules.GuiHandler)
require3(game.ReplicatedStorage.Shared.RankedSeasonData)
local v3 = require3(game.ReplicatedStorage.Common.Utils)
local v4 = require3(game.ReplicatedStorage.Common.Utils)
local icons = v3.Icons
local localPlayer = game.Players.LocalPlayer
local remoteFunction = v:RemoteFunction("ClaimRankedLeaderboardReward")
local remoteEvent = v:RemoteEvent("ShowLeaderboardReward")
local window = localPlayer:WaitForChild("PlayerGui"):WaitForChild("LeaderboardRewards").Window
local v5 = nil
local v6 = nil

local function open(p, p2, p3, p4, p5, items)
	v5 = p2
	v6 = p
	window.PlaceLabel.Text = string.format(
		"<stroke color=\"rgb(0,0,0)\" joins=\"miter\" thickness=\"2\">You scored <font color=\"rgb(255,25,25)\">%s Elo</font> and placed <font color=\"rgb(255,25,25)\">#%s</font>!</stroke>",
		v4.ValueConvertor:AddCommas(p5),
		p4
	)
	window.SeasonLabel.Text = string.format("(Season %s - Ranked %s)", p3, p2)

	for _, item in items do
		local clone = script.RewardTemplate:Clone()
		local visible

		if item.Icon == nil then
			visible = item.Sword ~= nil
		else
			visible = false
		end

		clone.Viewport.Visible = visible
		clone.Icon.Visible = not visible

		if item.Sword then
			clone.NameLabel.Text = item.Sword
		elseif item.RandomAbilities then
			clone.NameLabel.Text = "Random Ability"
		elseif item.Ability then
			clone.NameLabel.Text = item.Ability
		end

		if visible then
			icons:SetSwordIconAsViewportByName(clone.Viewport, item.Sword)
		else
			clone.Icon.Image = item.Icon
		end

		clone.Parent = window.RewardList
	end

	while v2._currentGui do
		task.wait()
	end

	v2:Open("LeaderboardRewards", true)
end

return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(open)
		local flag = false
		window.ClaimButton.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			task.delay(2, function()
				flag = false
			end)

			if remoteFunction:InvokeServer(v6, v5) then
				v2:Close("LeaderboardRewards")

				for _, guiBase2d in window.RewardList:GetChildren() do
					if guiBase2d:IsA("GuiBase2d") then
						guiBase2d:Destroy()
					end
				end
			end
		end)
	end
}