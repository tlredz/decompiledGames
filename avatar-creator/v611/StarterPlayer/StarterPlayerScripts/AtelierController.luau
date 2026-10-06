local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local AtelierTheme = require(game.ReplicatedStorage.AtelierTheme)
local colors = AtelierTheme.colors
local screenGui = playerGui:WaitForChild("ScreenGui")
local catalogGui = playerGui:WaitForChild("CatalogGui")
local communityGui = playerGui:WaitForChild("CommunityGui")
local wearingGui = playerGui:WaitForChild("WearingGui")
local v = {
	{ screenGui.Frame.CatalogButton, catalogGui },
	{ screenGui.Frame.CatelogButton },
	{ screenGui.CommunityButton, communityGui },
	{ screenGui.WearingButton, wearingGui }
}

local function style(guiObject)
	if guiObject.Name == "SurfacePattern" or guiObject:FindFirstAncestor("SurfacePattern") or (guiObject:GetAttribute("IconNavigation") or guiObject.Parent and guiObject.Parent:GetAttribute("IconNavigation")) then
		return
	end

	if guiObject.Name == "NavEmoji" or (guiObject.Name == "TopPolish" or guiObject:FindFirstAncestor("TopPolish")) then
		return
	end

	if guiObject.Name == "LookBackdrop" or guiObject:FindFirstAncestor("LookBackdrop") or guiObject:FindFirstAncestor("BackgroundsPanel") then
		return
	end

	if guiObject.Name == "AnniversaryPanel" or guiObject:FindFirstAncestor("AnniversaryPanel") or (guiObject.Name == "CatalogHome" or guiObject:FindFirstAncestor("CatalogHome")) then
		return
	end

	if not (guiObject:IsA("GuiObject") and guiObject.Name ~= "BrowseCreator") then
		return
	end

	guiObject:SetAttribute("AtelierStyled", nil)
	AtelierTheme.style(guiObject)

	if guiObject.Name == "BackToCatalog" or guiObject == catalogGui.Root.Panel.Close then
		guiObject.BackgroundColor3 = Color3.fromRGB(164, 48, 57)
	end

	if guiObject:IsA("GuiButton") then
		local uICorner = guiObject:FindFirstChildOfClass("UICorner")

		if uICorner then
			uICorner.CornerRadius = UDim.new(0, 8)
		end

		local uIStroke = guiObject:FindFirstChildOfClass("UIStroke")

		if uIStroke then
			uIStroke.Color = Color3.fromRGB(85, 96, 113)
			uIStroke.Thickness = 1
			uIStroke.Transparency = 0.65
			guiObject.MouseEnter:Connect(function()
				uIStroke.Transparency = 0.1
			end)
			guiObject.MouseLeave:Connect(function()
				uIStroke.Transparency = 0.65
			end)
		end
	end
end

for _, folder in ipairs({
	screenGui,
	catalogGui,
	communityGui,
	wearingGui
}) do
	for _, descendant in ipairs(folder:GetDescendants()) do
		style(descendant)
	end

	folder.DescendantAdded:Connect(function(descendant)
		task.defer(function()
			if descendant.Parent then
				style(descendant)
			end
		end)
	end)

	if not folder:FindFirstChild("Root") then
		continue
	end

	folder.Root.BackgroundColor3 = Color3.fromRGB(10, 13, 18)
	folder.Root.BackgroundTransparency = 1
end

screenGui.AtelierRail.Visible = false
catalogGui.Root.LivePreview.BackgroundColor3 = Color3.fromRGB(29, 34, 41)
catalogGui.Root.Panel.Title.Text = "Catalog"
catalogGui.Root.Panel.Subtitle.Text = "Discover pieces for your next look"

-- equivalent calls inferred from this helper; original call sites unknown
local function opened(screenGui2)
	if not screenGui2 then
		return false
	end

	if screenGui2:IsA("ScreenGui") then
		return screenGui2.Enabled
	end

	return screenGui2.Visible
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scale(instance, scale2)
	(instance:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", instance)).Scale = scale2
end

local function layout()
	local absoluteSize = screenGui.AbsoluteSize
	local scale2 = math.min(
		game.Players.LocalPlayer:GetAttribute("InterfaceScale") or 1,
		absoluteSize.X / 900,
		absoluteSize.Y / 600
	)
	local enabled = opened(catalogGui) -- equivalent call inferred; original call site unknown

	if not enabled then
		local screenGui2 = communityGui

		if screenGui2 then
			if screenGui2:IsA("ScreenGui") then
				enabled = screenGui2.Enabled
			else
				enabled = screenGui2.Visible
			end
		else
			enabled = false
		end

		if not enabled then
			local screenGui3 = wearingGui

			if screenGui3 then
				if screenGui3:IsA("ScreenGui") then
					enabled = screenGui3.Enabled
				else
					enabled = screenGui3.Visible
				end
			else
				enabled = false
			end
		end
	end

	for i, v4 in ipairs(v) do
		local v5 = v4[1]
		scale(v5, scale2) -- equivalent call inferred; original call site unknown
		v5.Size = UDim2.fromOffset(184, 48)
		v5.AnchorPoint = Vector2.zero
		v5.BackgroundColor3 = colors.surface
		v5.Visible = not enabled
		v5.NavIndex.Visible = false
		local navTitle = v5.NavTitle
		navTitle.Font = Enum.Font.GothamMedium
		navTitle.TextSize = 15
		navTitle.TextColor3 = colors.text
		navTitle.Position = UDim2.fromOffset(16, 0)
		navTitle.Size = UDim2.new(1, -32, 1, 0)
		navTitle.TextXAlignment = i <= 2 and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left

		if i <= 2 then
			v5.Size = UDim2.fromOffset(350, 96)
			v5.AnchorPoint = Vector2.new(0.5, 0.5)
			navTitle.TextSize = 21
			navTitle.Font = Enum.Font.GothamBold
			v5.Position = UDim2.new(0.5, (i == 1 and -187 or 187) * scale2, 0, scale2 * 48 + 16)
		else
			v5.Position = UDim2.new(0, 20, 0.5, (-86 + (i - 3) * 62) * scale2)
		end
	end

	local IconNavigation = require(game.ReplicatedStorage.IconNavigation)
	IconNavigation.Apply(playerGui, nil, game.Players.LocalPlayer:GetAttribute("InterfaceScale") or 1)
	local MobileCatalogLayout = require(game.ReplicatedStorage.MobileCatalogLayout)

	if not MobileCatalogLayout.IsMobile() then
		local absoluteSize2 = catalogGui.Root.AbsoluteSize
		local scale3 = math.max(
			0.1,
			(math.min(
				game.Players.LocalPlayer:GetAttribute("InterfaceScale") or 1,
				absoluteSize2.X / 1000,
				absoluteSize2.Y / 660
			))
		)
		local v5 = 12 / scale3
		local v6 = math.max(1, (absoluteSize2.X - 16) / scale3)
		local v7 = math.max(1, (absoluteSize2.Y - 16) / scale3)
		local v8 = math.floor(v6 * 0.27)
		local v9 = math.min(210, v6 * 0.12)
		local panel = catalogGui.Root.Panel

		local function position(instance, p, p2, p3)
			local uISizeConstraint = instance:FindFirstChildOfClass("UISizeConstraint")

			if uISizeConstraint then
				uISizeConstraint.MinSize = Vector2.zero
				uISizeConstraint.MaxSize = Vector2.new(100000, 100000)
			end

			scale(instance, scale3) -- equivalent call inferred; original call site unknown
			instance.AnchorPoint = Vector2.zero
			instance.Position = UDim2.fromOffset(p, p2)
			instance.Size = UDim2.fromOffset(p3, v7)
		end

		position(catalogGui.Root.LivePreview, 8, 8, v8)
		position(panel, (v8 + v5) * scale3 + 8, 8, v6 - v8 - v9 - v5 * 2)
		position(catalogGui.Root.AnniversaryPanel, (v6 - v9) * scale3 + 8, 8, v9)

		for _, v10 in ipairs({ communityGui.Root.Panel }) do
			local absoluteSize3 = v10.Parent.AbsoluteSize
			local scale4 = math.max(
				0.1,
				(math.min(
					game.Players.LocalPlayer:GetAttribute("InterfaceScale") or 1,
					(absoluteSize3.X - 64) / 1100,
					(absoluteSize3.Y - 64) / 640
				))
			)
			local uISizeConstraint = v10:FindFirstChildOfClass("UISizeConstraint")

			if uISizeConstraint then
				uISizeConstraint.MinSize = Vector2.zero
				uISizeConstraint.MaxSize = Vector2.new(2200, 2200)
			end

			scale(v10, scale4) -- equivalent call inferred; original call site unknown
			v10.AnchorPoint = Vector2.new(0.5, 0.5)
			v10.Position = UDim2.fromScale(0.5, 0.5)
			v10.Size = UDim2.fromOffset(1100, 640)
		end
	end
end

for _, v2 in ipairs(v) do
	local v3 = v2[1]
	local screenGui2 = v2[2]

	if not screenGui2 then
		continue
	end

	local v4 = screenGui2
	v3.Activated:Connect(function()
		task.defer(function()
			for i, v5 in ipairs(v) do
				local screenGui3 = v5[2]

				if not (screenGui3 and screenGui3 ~= v4) then
					continue
				end

				if screenGui3:IsA("ScreenGui") then
					screenGui3.Enabled = false
				else
					screenGui3.Visible = false
				end
			end

			layout()
		end)
	end)
	screenGui2:GetPropertyChangedSignal(screenGui2:IsA("ScreenGui") and "Enabled" or "Visible"):Connect(function()
		task.defer(layout)
	end)
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
layout()
catalogGui.Root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
local TweenService = game:GetService("TweenService")

for _, v2 in ipairs({ screenGui.Frame.CatalogButton, screenGui.Frame.CatelogButton }) do
	local v3 = nil
	local v4 = v2

	local function hover(p)
		if game.Players.LocalPlayer:GetAttribute("MobileHUDActive") then
			return
		end

		local v5 = game.Players.LocalPlayer:GetAttribute("ReducedMotion") and 1 or p
		local absoluteSize = screenGui.AbsoluteSize
		local v6 = math.min(
			game.Players.LocalPlayer:GetAttribute("InterfaceScale") or 1,
			absoluteSize.X / 900,
			absoluteSize.Y / 600
		)
		local uIScale = v4:FindFirstChildOfClass("UIScale")

		if v3 then
			v3:Cancel()
		end

		if uIScale then
			v3 = TweenService:Create(
				uIScale,
				TweenInfo.new(
					game.Players.LocalPlayer:GetAttribute("ReducedMotion") and 0 or 0.16,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),
				{
					Scale = v6 * v5
				}
			)
			v3:Play()
		end
	end

	local hover2 = hover
	v2.MouseEnter:Connect(function()
		hover2(1.06)
	end)
	local hover3 = hover
	v2.MouseLeave:Connect(function()
		hover3(1)
	end)
	local v5 = v2
	local hover4 = hover
	v2:GetPropertyChangedSignal("Visible"):Connect(function()
		if not v5.Visible then
			hover4(1)
		end
	end)
end

local function border(descendant)
	if descendant.Name == "SurfacePattern" or descendant:FindFirstAncestor("SurfacePattern") or (descendant:GetAttribute("IconNavigation") or descendant.Parent and descendant.Parent:GetAttribute("IconNavigation")) then
		return
	end

	if descendant.Name == "TopPolish" or descendant:FindFirstAncestor("TopPolish") or (descendant.Name == "AnniversaryPanel" or descendant:FindFirstAncestor("AnniversaryPanel")) then
		return
	end

	if descendant.Name == "CatalogHome" or descendant:FindFirstAncestor("CatalogHome") or descendant.Name == "BrowseCreator" or not descendant:IsA("GuiObject") then
		return
	end

	if not (descendant:IsA("GuiButton") or descendant:IsA("TextBox")) and (not descendant:IsA("Frame") or descendant.Name ~= "Panel" and descendant.Name ~= "LivePreview" and descendant.Name ~= "Preview" and descendant.Name ~= "Details" and descendant.Name ~= "FilterPanel" and descendant.Name ~= "PublishPanel" and not (descendant.Name:match("^Item_") or descendant.Name:match("^Outfit_"))) then
		return
	end

	local uIStroke = descendant:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", descendant)
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Thickness = descendant:IsA("Frame") and 1.5 or 1.2
	uIStroke.Color = Color3.new(1, 1, 1)
	uIStroke.Transparency = 0.28
	local uIGradient = uIStroke:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", uIStroke)
	uIGradient.Rotation = 30
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(166, 192, 231)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(68, 85, 110)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(129, 151, 197))
	})
end

for _, folder in ipairs({
	screenGui,
	catalogGui,
	communityGui,
	wearingGui
}) do
	for _, descendant in ipairs(folder:GetDescendants()) do
		border(descendant)
	end

	folder.DescendantAdded:Connect(function(descendant)
		task.defer(function()
			if descendant.Parent then
				border(descendant)
			end
		end)
	end)
end

game.Players.LocalPlayer:GetAttributeChangedSignal("InterfaceScale"):Connect(layout)
game.Players.LocalPlayer:GetAttributeChangedSignal("ReducedMotion"):Connect(layout)
game.Players.LocalPlayer:GetAttributeChangedSignal("MobileHUDActive"):Connect(function()
	if not game.Players.LocalPlayer:GetAttribute("MobileHUDActive") then
		task.defer(layout)
	end
end)
screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
local ViewportLayoutWatch = require(game.ReplicatedStorage.ViewportLayoutWatch)
ViewportLayoutWatch.Bind(layout)
game.Players.LocalPlayer:GetAttributeChangedSignal("MobileLayoutRevision"):Connect(function()
	task.defer(layout)
end)