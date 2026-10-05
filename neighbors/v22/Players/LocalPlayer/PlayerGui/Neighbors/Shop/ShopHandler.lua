game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("UserInputService")
local parent = script.Parent
parent.Visible = false
local parent2 = parent.Parent
local inspectItemPage = parent.InspectItemPage
local inspectItem = inspectItemPage.InspectItem
local _ = parent2.UIScale
local UI = require(ReplicatedStorage.Modules.UI)
require(game.ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
require(game.ReplicatedStorage.Modules.Data)
local Server = require(ReplicatedStorage.Modules.Server)
local Network = require(ReplicatedStorage.Modules.Network)
local Money = require(ReplicatedStorage.Modules.Money)
local localPlayer = Players.LocalPlayer
Instance.new("BindableEvent")
local _ = parent.ItemSkinsPage.Preview
local _, result = pcall(function()
	if not _G.Policy then
		local _G2 = _G
		local PolicyService = game:GetService("PolicyService")
		_G2.Policy = PolicyService:GetPolicyInfoForPlayerAsync(localPlayer)
	end

	return _G.Policy
end)

if not result then
	print("Failed to load in policies...")
end

if Server:IsAdultServer() then
	parent.Header.Title.Text = `{parent.Header.Title.Text} 18+`
end

local function GetMaxSlots()
	return 3 + (localPlayer:GetAttribute("ExtraSlots") and 2 or 0) + (localPlayer:GetAttribute("ExtraSlots2") and 2 or 0) + (localPlayer:GetAttribute("ExtraSlots3") and 2 or 0) + (localPlayer:GetAttribute("InfiniteSlots") and 1e999 or 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateCreditsCounter(credits: number)
	parent.Header.Credits.Amount.Text = Money(credits)
end

inspectItem.Close.MouseButton1Click:Connect(function()
	inspectItemPage.Visible = false
	inspectItem.Buttons.Gift.Visible = false
end)
inspectItem.Buttons.Cancel.MouseButton1Click:Connect(function()
	inspectItemPage.Visible = false
	inspectItem.Buttons.Gift.Visible = false
end)

for _, button in inspectItem.Buttons:GetChildren() do
	if button:IsA("ImageButton") then
		UI:Bind(button)
	end
end

if UI:GetDeviceType() == "Mobile" then
	UI:FillFrameToMaxHeight(parent, parent.UIScale, 10)
else
	UI:RegisterConstantUIScale(parent.UIScale, {
		PC = 1.25,
		Mobile = 1,
		Tablet = 1.4
	})
end

UI:Bind(inspectItem.ViewContent)
UI:Bind(inspectItem.Close)
inspectItemPage.Visible = false
parent.Header.Close.Activated:Connect(function()
	parent.Visible = false
end)
local v = false
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if not v then
		parent.Pages.SetPage:Fire(parent.Pages.Featured)
		v = true
	end

	for _, scrollingFrame in parent:GetDescendants() do
		if scrollingFrame:IsA("ScrollingFrame") then
			scrollingFrame.CanvasPosition = Vector2.zero
		end
	end

	if not parent.Visible then
		parent.InspectItemPage.Visible = false
		parent.ItemSkinsPage.Visible = false
		parent.ItemTitlesPage.Visible = false
	end
end)
UI:Bind(parent.Header.Close)
local credits = localPlayer:GetAttribute("Credits") or 0
UpdateCreditsCounter(credits) -- equivalent call inferred; original call site unknown
localPlayer:GetAttributeChangedSignal("Credits"):Connect(function()
	UpdateCreditsCounter(localPlayer:GetAttribute("Credits")) -- equivalent call inferred; original call site unknown
end)
Network:listen("PlayBuySound", function()
	return script.BuySound:Play()
end)
Network:listen("PlayNewTitleSound", function()
	return script.NewTitle:Play()
end)
Network:listen("OpenValentineBundle", function()
	parent.Visible = true
	parent.Pages.SetPage:Fire(parent.Pages.Skins)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function onCategoryCreated(child)
	if child:GetAttribute("Category") then
		child:GetPropertyChangedSignal("Visible"):Connect(function()
			local scrollingFrame = child:FindFirstAncestorOfClass("ScrollingFrame")

			if not scrollingFrame.Visible then
				return
			end

			local v2 = false

			for _, child2 in scrollingFrame:GetChildren() do
				if not (child2:GetAttribute("Category") and child2.Visible) then
					continue
				end

				v2 = true
				break
			end

			if not v2 then
				local clone = script.EmptyPage:Clone()
				clone.Parent = scrollingFrame
			elseif scrollingFrame:FindFirstChild("EmptyPage") then
				scrollingFrame.EmptyPage:Destroy()
			end
		end)
	end
end

for _, scrollingFrame in parent.Pages:GetChildren() do
	if not scrollingFrame:IsA("ScrollingFrame") then
		continue
	end

	scrollingFrame.ChildAdded:Connect(onCategoryCreated)

	for _, child in scrollingFrame:GetChildren() do
		onCategoryCreated(child) -- equivalent call inferred; original call site unknown
	end
end

script.Parent.Visible = false