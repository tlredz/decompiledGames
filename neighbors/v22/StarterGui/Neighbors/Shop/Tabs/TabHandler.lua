local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parent = script.Parent.Parent
local _ = parent.Parent.Parent
local tabList = parent.Tabs.TabList
local pages = parent.Pages
local Server = require(ReplicatedStorage.Modules.Server)
local UI = require(ReplicatedStorage.Modules.UI)
local TweenUtil = require(ReplicatedStorage.Modules.TweenUtil)
local Network = require(ReplicatedStorage.Modules.Network)
require(ReplicatedStorage.Modules.Data)
local ShopTabs = require(game.ReplicatedStorage.Assets.Data.UIData.ShopTabs)
local backgroundColor3 = tabList.Tab.Button.BackgroundColor3
local color = Color3.fromRGB(27, 27, 27)
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- equivalent calls inferred from this helper; original call sites unknown
local function getShopTabInfo(name: string)
	for _, shopTab in next, ShopTabs, nil do
		if shopTab.Display == name then
			return shopTab
		end
	end

	return nil
end

local function ChangeTabColor(instance, isSelected: boolean)
	if instance:GetAttribute("IsSelected") == isSelected then
		return
	end

	instance:SetAttribute("IsSelected", isSelected)
	local shopTabInfo = getShopTabInfo(instance.Name) -- equivalent call inferred; original call site unknown

	if not shopTabInfo then
		return
	end

	local selectedColor = shopTabInfo.SelectedColor or backgroundColor3
	TweenService:Create(instance.Icon, tweenInfo, {
		ImageColor3 = isSelected and selectedColor or color
	}):Play()
	TweenService:Create(instance.Title, tweenInfo, {
		TextColor3 = isSelected and selectedColor or color
	}):Play()

	if instance.Button:FindFirstChild("UIGradient") then
		TweenUtil:Create(instance.Button.UIGradient, tweenInfo, {
			Color = isSelected and color or shopTabInfo.BackgroundColor
		}):Play()
	else
		TweenService:Create(instance.Button, tweenInfo, {
			BackgroundColor3 = isSelected and color or backgroundColor3
		}):Play()
	end
end

local function SelectTab(clone)
	for _, frame in tabList:GetChildren() do
		if frame:IsA("Frame") then
			ChangeTabColor(frame, false)
		end
	end

	ChangeTabColor(clone, true)
end

for k, shopTab in ShopTabs do
	local clone = tabList.Tab:Clone()
	clone.Title.Text = shopTab.Display
	clone.Icon.Image = shopTab.Icon
	clone.LayoutOrder = k
	clone.Visible = true
	local trueName = shopTab.TrueName or shopTab.Display
	clone.Name = trueName

	if shopTab.FeatureReady == false and not (RunService:IsStudio() and Server:IsTestServer()) then
		clone.Visible = false
	end

	clone.Icon.ImageColor3 = color
	clone.Title.TextColor3 = color

	if shopTab.BackgroundColor then
		if typeof(shopTab.BackgroundColor) == "ColorSequence" then
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Rotation = 90
			uIGradient.Color = shopTab.BackgroundColor
			uIGradient.Parent = clone.Button
			clone.Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		else
			clone.Button.BackgroundColor3 = shopTab.BackgroundColor
		end
	end

	clone.Parent = tabList
	local clone2 = pages:FindFirstChild(trueName)

	if k == 1 then
		SelectTab(clone)
	end

	if not clone2 then
		clone2 = pages.EmptyPage:Clone()
		clone2.Name = trueName
		clone2.Parent = pages
		clone2.Visible = false
	end

	clone2.LayoutOrder = k

	if shopTab.Display == "Profile" and localPlayer:GetAttribute("Profile") ~= true then
		clone.NotificationDot.Visible = true
	end

	localPlayer:GetAttributeChangedSignal("Profile"):Once(function()
		clone.NotificationDot.Visible = false
	end)
	local v2 = clone
	local v3 = shopTab
	clone.Button.MouseButton1Click:Connect(function()
		pages.SetPage:Fire(clone2)

		if v2.NotificationDot.Visible then
			v2.NotificationDot.Visible = false

			if v3.Display == "Profile" then
				Network:fire("NotificatedPressed", "Profile")
			end
		end
	end)
	local v4 = clone
	clone2:GetPropertyChangedSignal("Visible"):Connect(function()
		ChangeTabColor(v4, clone2.Visible)
	end)
	UI:Bind(clone.Button)
	UI:AddShadowOnHover(clone)
	ChangeTabColor(clone, clone2.Visible)
end

pages.SetPage.Event:Connect(function(p)
	parent.Hotbar.SearchBar.Search.TextBox.Text = ""

	for _, shopTab in ShopTabs do
		local child = pages:FindFirstChild(shopTab.TrueName or shopTab.Display)

		if not child then
			continue
		end

		parent.Count.Visible = p.Name == "Items"
		parent.Hotbar.FilterBar.Visible = p.Name == "Items"
		local searchBar = parent.Hotbar.SearchBar
		searchBar.Visible = p.Name ~= "Weekly" and p.Name ~= "Featured" and p.Name ~= "UGC"
		child.Visible = p == child
	end
end)