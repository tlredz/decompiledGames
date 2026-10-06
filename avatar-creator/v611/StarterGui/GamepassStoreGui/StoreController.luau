local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
local storeButton = parent.StoreButton
local root = parent.Root
local panel = root.Panel
local MenuFade = require(game.ReplicatedStorage.MenuFade)
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
local name = "Gamepasses"

local function paintCategory()
	local visible = name == "Coins"
	panel.Title.Text = "Store"
	panel.Packs.Visible = not visible
	panel.Status.Visible = not visible
	panel.Coins.Visible = visible
	panel.Subtitle.Text = visible and "Balance: " .. tostring(localPlayer:GetAttribute("Coins") or 0) .. " coins · Choose a coin pack" or "Permanent perks for your time here"

	for _, button in panel.Categories:GetChildren() do
		if button:IsA("GuiButton") then
			button.BackgroundColor3 = button.Name == name and CatalogUI.colors.accent or CatalogUI.colors.raised
		end
	end
end

for _, button in panel.Categories:GetChildren() do
	if not button:IsA("GuiButton") then
		continue
	end

	local v = button
	button.Activated:Connect(function()
		name = v.Name
		paintCategory()
	end)
end

localPlayer:GetAttributeChangedSignal("Coins"):Connect(paintCategory)
paintCategory()
local uIScale = Instance.new("UIScale", storeButton)
local uIScale2 = Instance.new("UIScale", panel)

local function layout()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local scale = math.min(localPlayer:GetAttribute("InterfaceScale") or 1, viewportSize.X / 1000, viewportSize.Y / 800)
	uIScale.Scale = scale
	storeButton.Position = UDim2.new(1, -18, 1, -18 - scale * 140)
	local MobileCatalogLayout = require(game.ReplicatedStorage.MobileCatalogLayout)

	if not MobileCatalogLayout.IsMobile() then
		uIScale2.Scale = math.min(
			localPlayer:GetAttribute("InterfaceScale") or 1,
			(viewportSize.X - 48) / 780,
			(viewportSize.Y - 48) / 620
		)
	end
end

local function open()
	paintCategory()
	MenuFade.Set(root, "Visible", true)
end

storeButton.Activated:Connect(open)
panel.Close.Activated:Connect(function()
	MenuFade.Set(root, "Visible", false)
end)
local v = nil

local function hover(p)
	if game.Players.LocalPlayer:GetAttribute("MobileHUDActive") then
		return
	end

	if v then
		v:Cancel()
	end

	local v2 = p and not localPlayer:GetAttribute("ReducedMotion") and 104 or 90
	local TweenService = game:GetService("TweenService")
	v = TweenService:Create(storeButton.Icon, TweenInfo.new(0.15), {
		Size = UDim2.fromOffset(v2, v2)
	})
	v:Play()
end

storeButton.MouseEnter:Connect(function()
	hover(true)
end)
storeButton.MouseLeave:Connect(function()
	hover(false)
end)

local function visibility()
	local v2 = false

	for _, childName in ipairs({ "PreferencesGui" }) do
		local child = playerGui:FindFirstChild(childName)

		if child and child.Enabled and child.Panel.Visible then
			v2 = true
		end
	end

	for _, childName in ipairs({
		"CatalogGui",
		"CommunityGui",
		"WearingGui",
		"RobloxSaveOutfitGui"
	}) do
		local child = playerGui:FindFirstChild(childName)

		if child and child.Enabled then
			v2 = true
		end
	end

	local backgroundPreviewGui = playerGui:FindFirstChild("BackgroundPreviewGui")
	local v3 = backgroundPreviewGui and backgroundPreviewGui:FindFirstChild("Stage") and backgroundPreviewGui.Stage.Visible and true or v2
	storeButton.Visible = not (v3 or root.Visible)

	if v3 then
		MenuFade.Set(root, "Visible", false)
	end
end

for _, childName in ipairs({
	"CatalogGui",
	"CommunityGui",
	"WearingGui",
	"RobloxSaveOutfitGui"
}) do
	playerGui:WaitForChild(childName):GetPropertyChangedSignal("Enabled"):Connect(visibility)
end

task.spawn(function()
	playerGui:WaitForChild("BackgroundPreviewGui"):WaitForChild("Stage"):GetPropertyChangedSignal("Visible"):Connect(visibility)
end)
root:GetPropertyChangedSignal("Visible"):Connect(visibility)
local ViewportLayoutWatch = require(game.ReplicatedStorage:WaitForChild("ViewportLayoutWatch"))
ViewportLayoutWatch.Bind(layout)
localPlayer:GetAttributeChangedSignal("InterfaceScale"):Connect(layout)
layout()
visibility()

for _, childName in ipairs({ "PreferencesGui" }) do
	local child = playerGui:WaitForChild(childName)
	child.Panel:GetPropertyChangedSignal("Visible"):Connect(visibility)
	child:GetPropertyChangedSignal("Enabled"):Connect(visibility)
end

visibility()
localPlayer:GetAttributeChangedSignal("MobileHUDActive"):Connect(function()
	if not localPlayer:GetAttribute("MobileHUDActive") then
		task.defer(layout)
	end
end)