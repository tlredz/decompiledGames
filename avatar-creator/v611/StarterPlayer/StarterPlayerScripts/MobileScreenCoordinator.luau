local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local MobileCatalogLayout = require(game.ReplicatedStorage.MobileCatalogLayout)
local MobilePanelLayout = require(game.ReplicatedStorage.MobilePanelLayout)
local v = {
	"CatalogGui",
	"CommunityGui",
	"WearingGui",
	"RobloxSaveOutfitGui",
	"PreferencesGui.Panel",
	"EditorToolsGui.Panel",
	"GamepassPerkControls.Frame",
	"UGCClaimGui.Panel",
	"UGCClaimGui.Help",
	"UGCClaimGui.GiftDialog",
	"GamepassStoreGui.Root",
	"LeaderboardGui.Root",
	"GiveawayGui.Shade",
	"BackgroundPreviewGui.Stage",
	"SaveOutfitShortcutGui.ResetConfirmation",
	"CoinGiftDialogGui.Shield",
	"VIPGiftDialogGui.Shield",
	"UGCVIPBenefitsGui.Shield",
	"StarterPackGui.Shield"
}
local v2 = {
	"ScreenGui.Frame.CatalogButton",
	"ScreenGui.Frame.CatelogButton",
	"ScreenGui.CommunityButton",
	"ScreenGui.WearingButton",
	"PreferencesGui.SettingsButton",
	"GamepassStoreGui.StoreButton",
	"LeaderboardGui.LeaderboardButton",
	"UGCClaimGui.CoinHUD",
	"GiveawayGui.LayoutBounds.GiveawayButton"
}
local v3 = {}
local v4 = {}
local v5 = {}
local count = 0
local v6 = false
local total = 0

local function at(value)
	local child = playerGui

	for childName in value:gmatch("[^.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			return
		end
	end

	return child
end

local function visible(screenGui)
	if screenGui:IsA("ScreenGui") then
		return screenGui.Enabled
	end

	if not screenGui.Visible then
		return false
	end

	local parent = screenGui.Parent

	while parent and parent ~= playerGui do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("ScreenGui") and not parent.Enabled then
			return false
		else
			parent = parent.Parent
		end
	end

	return true
end

local function resetLayers()
	for k, displayOrder in v4 do
		if k.Parent then
			k.DisplayOrder = displayOrder
		end
	end

	v4 = {}

	for _, v7 in v5 do
		v7.Visible = false
	end
end

RunService:BindToRenderStep("MobileScreenCoordinator", Enum.RenderPriority.Last.Value + 30, function(p)
	total += p
	local isMobile = MobileCatalogLayout.IsMobile()

	if total >= 0.1 then
		total = 0
		MobileCatalogLayout.Apply(playerGui)
		MobilePanelLayout.Apply(playerGui)
	end

	if isMobile then
		localPlayer:SetAttribute("MobileScreensActive", true)
		local v7 = -1
		local screenGui = nil

		for _, v8 in v do
			local v9 = at(v8)

			if not v9 then
				continue
			end

			local v10 = visible(v9)

			if v10 and not v3[v9] then
				count += 1
				v3[v9] = count
			end

			if not v10 then
				v3[v9] = nil
			end

			if not (v10 and v7 < v3[v9]) then
				continue
			end

			v7 = v3[v9]
			screenGui = v9
		end

		local v8 = screenGui ~= nil
		localPlayer:SetAttribute("MobileMenuOpen", v8)

		if v8 then
			for _, v9 in v2 do
				local v10 = at(v9)

				if v10 then
					v10.Visible = false
				end
			end

			local touchGui = playerGui:FindFirstChild("TouchGui")

			if touchGui then
				touchGui.Enabled = false
			end

			local parent = screenGui:IsA("ScreenGui") and screenGui or screenGui:FindFirstAncestorWhichIsA("ScreenGui")

			for k, displayOrder in v4 do
				if not (k ~= parent and k.Parent) then
					continue
				end

				k.DisplayOrder = displayOrder
				v4[k] = nil
			end

			if v4[parent] == nil then
				v4[parent] = parent.DisplayOrder
			end

			parent.DisplayOrder = 350

			for k, v10 in v5 do
				v10.Visible = k == parent
			end

			if not v5[parent] then
				local textButton = Instance.new("TextButton")
				textButton.Name = "MobileModalBackdrop"
				textButton.Text = ""
				textButton.Size = UDim2.fromScale(1, 1)
				textButton.BackgroundColor3 = Color3.fromRGB(14, 18, 24)
				textButton.BackgroundTransparency = 1
				textButton.BorderSizePixel = 0
				textButton.AutoButtonColor = false
				textButton.Active = true
				textButton.ZIndex = 0
				textButton.Parent = parent
				v5[parent] = textButton
			end

			v5[parent].Visible = true
		elseif v6 then
			resetLayers()

			for _, v9 in v2 do
				local v10 = at(v9)

				if v10 then
					v10.Visible = true
				end
			end

			local touchGui = playerGui:FindFirstChild("TouchGui")

			if touchGui then
				touchGui.Enabled = true
			end
		end

		v6 = v8
	else
		if localPlayer:GetAttribute("MobileScreensActive") then
			MobileCatalogLayout.Apply(playerGui)
			MobilePanelLayout.Apply(playerGui)
			localPlayer:SetAttribute("MobileScreensActive", false)
			localPlayer:SetAttribute(
				"MobileLayoutRevision",
				(localPlayer:GetAttribute("MobileLayoutRevision") or 0) + 1
			)
		end

		if v6 then
			for _, v7 in v2 do
				local v8 = at(v7)

				if v8 then
					v8.Visible = true
				end
			end

			local touchGui = playerGui:FindFirstChild("TouchGui")

			if touchGui then
				touchGui.Enabled = true
			end
		end

		v6 = false
		localPlayer:SetAttribute("MobileMenuOpen", false)
		resetLayers()
	end
end)