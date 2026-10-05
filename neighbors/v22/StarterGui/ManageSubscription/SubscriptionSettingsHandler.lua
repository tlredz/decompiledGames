local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local main = script.Parent.Main
local settingsList = main.SettingsList
local button = settingsList["Subscriber Perks"].Button
local subscriptionPerks = main.SubscriptionPerks
local template = script.Template
local _ = settingsList.Parent.Parent
local SubscriptionSettings = require(game.ReplicatedStorage.Assets.Data.UIData.SubscriptionSettings)
local Network = require(ReplicatedStorage.Modules.Network)
local UI = require(ReplicatedStorage.Modules.UI)
local Server = require(ReplicatedStorage.Modules.Server)
local Perks = require(script.Perks)
local tweenInfo = TweenInfo.new(0.25)
local uDim = UDim2.fromScale(0.25, 0.5)
local uDim2 = UDim2.fromScale(0.75, 0.5)
local color = Color3.fromRGB(212, 52, 47)
local color2 = Color3.fromRGB(52, 212, 47)
Color3.fromRGB(238, 238, 238)
Color3.fromRGB(29, 29, 29)
local attributesBySettingName = Network:invoke("FetchVipSettings")
main.Close.MouseButton1Click:Connect(function()
	main.Visible = false
end)
button.MouseButton1Click:Connect(function()
	subscriptionPerks.Visible = not subscriptionPerks.Visible
end)
subscriptionPerks.Close.MouseButton1Click:Connect(function()
	subscriptionPerks.Visible = false
end)

for _, perk in ipairs(Perks) do
	local clone = template:Clone()
	clone.Text = perk
	clone.Parent = subscriptionPerks.List
end

local function CreateToggleSetting(subscriptionSetting, flag: boolean)
	local clone = settingsList.Toggle:Clone()
	clone.Setting.Text = subscriptionSetting.Display
	local attribute = flag or false
	local now = 0
	local switch = clone.Switch
	local ball = switch.Ball

	local function Animate()
		TweenService:Create(ball, tweenInfo, {
			Position = attribute and uDim2 or uDim
		}):Play()
		TweenService:Create(switch, tweenInfo, {
			BackgroundColor3 = attribute and color2 or color
		}):Play()
	end

	clone.Switch.Button.MouseButton1Click:Connect(function()
		if subscriptionSetting.Cooldown and os.clock() - now < subscriptionSetting.Cooldown then
			return
		end

		now = os.clock()
		attribute = not attribute
		Network:fire("ChangeVipSetting", subscriptionSetting.SettingName, attribute)
		attributesBySettingName[subscriptionSetting.SettingName] = attribute
		Animate()
	end)
	Players.LocalPlayer:GetAttributeChangedSignal(subscriptionSetting.SettingName):Connect(function()
		attribute = Players.LocalPlayer:GetAttribute(subscriptionSetting.SettingName)
		attributesBySettingName[subscriptionSetting.SettingName] = attribute
		Animate()
	end)
	Animate()
	UI:Bind(clone.Switch.Button)
	return clone
end

local function CreateSettingList()
	for _, subscriptionSetting in SubscriptionSettings do
		if subscriptionSetting.ExcludedServers and table.find(
			subscriptionSetting.ExcludedServers,
			Server:GetServerType()
		) or subscriptionSetting.MinimumRank and Players.LocalPlayer:GetRankInGroup(15109848) < subscriptionSetting.MinimumRank then
			continue
		end

		local v = attributesBySettingName[subscriptionSetting.SettingName]
		local v2

		if subscriptionSetting.Type == "Toggle" then
			v2 = CreateToggleSetting(subscriptionSetting, v)
		end

		v2.Parent = settingsList
		v2.Visible = true
	end

	local absoluteContentSize = settingsList.UIListLayout.AbsoluteContentSize
	settingsList.CanvasSize = UDim2.fromOffset(0, absoluteContentSize.Y)
end

UI:RegisterScrollingFrame(settingsList, { script.Parent.Main.UIScale })
CreateSettingList()