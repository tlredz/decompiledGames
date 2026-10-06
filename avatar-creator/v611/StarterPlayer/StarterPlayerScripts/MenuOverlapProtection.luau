local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local v = {}
local v2 = false
local v3 = {
	"ScreenGui.Frame.CatalogButton",
	"ScreenGui.Frame.CatelogButton",
	"ScreenGui.CommunityButton",
	"ScreenGui.WearingButton",
	"PreferencesGui.SettingsButton",
	"GamepassStoreGui.StoreButton",
	"LeaderboardGui.LeaderboardButton",
	"UGCClaimGui.CoinHUD",
	"UGCClaimGui.CoinHUD.InviteFriends",
	"UGCClaimGui.CoinHUD.JoinGroup",
	"UGCClaimGui.CoinHUD.FavoriteReward",
	"GiveawayGui.LayoutBounds.GiveawayButton"
}

local function at(value)
	local child = playerGui

	for childName in value:gmatch("[^.]+") do
		child = child and child:FindFirstChild(childName)
	end

	return child
end

local function overlap(child, p)
	local absolutePosition = child.AbsolutePosition
	local absolutePosition2 = p.AbsolutePosition
	local absoluteSize = child.AbsoluteSize
	local absoluteSize2 = p.AbsoluteSize
	return absolutePosition.X < absolutePosition2.X + absoluteSize2.X + 8 and absolutePosition.X + absoluteSize.X > absolutePosition2.X - 8 and absolutePosition.Y < absolutePosition2.Y + absoluteSize2.Y + 8 and absolutePosition.Y + absoluteSize.Y > absolutePosition2.Y - 8
end

RunService:BindToRenderStep("MenuOverlapProtection", Enum.RenderPriority.Last.Value + 50, function()
	local MobileCatalogLayout = require(game.ReplicatedStorage.MobileCatalogLayout)
	local isMobile = MobileCatalogLayout.IsMobile()
	local firstVisitTutorialGui = playerGui:FindFirstChild("FirstVisitTutorialGui")
	local child = playerGui

	for childName in ("FirstVisitTutorialGui.SafeArea.TourCard"):gmatch("[^.]+") do
		child = child and child:FindFirstChild(childName)
	end

	local mobileMenuOpen = localPlayer:GetAttribute("MobileMenuOpen") == true

	if firstVisitTutorialGui then
		if isMobile and mobileMenuOpen and firstVisitTutorialGui.Enabled then
			firstVisitTutorialGui.Enabled = false
			v2 = true
		elseif v2 and not (isMobile and mobileMenuOpen) then
			firstVisitTutorialGui.Enabled = true
			v2 = false
		end
	end

	local child2 = playerGui

	for childName in ("UGCClaimGui.Panel"):gmatch("[^.]+") do
		child2 = child2 and child2:FindFirstChild(childName)
	end

	local child3 = playerGui

	for childName in ("WearingGui.Root.Panel"):gmatch("[^.]+") do
		child3 = child3 and child3:FindFirstChild(childName)
	end

	local child4 = playerGui

	for childName in ("PreferencesGui.Panel"):gmatch("[^.]+") do
		child4 = child4 and child4:FindFirstChild(childName)
	end

	local v4 = nil

	if isMobile or not (child3 and child3.Visible and child3:FindFirstAncestorWhichIsA("ScreenGui").Enabled) then
		if isMobile or not (child2 and child2.Visible and child2:FindFirstAncestorWhichIsA("ScreenGui").Enabled) then
			if isMobile or not (child4 and child4.Visible and child4:FindFirstAncestorWhichIsA("ScreenGui").Enabled) then
				if isMobile and not mobileMenuOpen and firstVisitTutorialGui and firstVisitTutorialGui.Enabled and child and child.Visible then
					v4 = child
				end
			else
				v4 = child4
			end
		else
			v4 = child2
		end
	else
		v4 = child3
	end

	for _, v5 in v3 do
		local child5 = playerGui

		for childName in v5:gmatch("[^.]+") do
			child5 = child5 and child5:FindFirstChild(childName)
		end

		if not child5 then
			continue
		end

		if v4 and overlap(child5, v4) then
			if child5.Visible then
				v[child5] = true
			end

			child5.Visible = false
		elseif v[child5] then
			if not mobileMenuOpen then
				child5.Visible = true
			end

			v[child5] = nil
		end
	end
end)