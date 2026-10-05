local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacy = ReplicatedStorage.client.legacy
local legacyUiLoader = require(legacy.legacyUiLoader)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local utils = ReplicatedStorage.shared.utils
require(utils.NumberUtils)
local sharedFunctions = ReplicatedStorage.shared.modules.SharedPersonalAquarium.SharedFunctions
local RewardFunctions = require(sharedFunctions.RewardFunctions)
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("PersonalAquarium/EquipBest")
local anno_localthought = ReplicatedStorage.events.anno_localthought
local v = {
	["C$"] = "Value",
	XP = "XP",
	Items = "Item"
}
local flag = false
require("../Types")
local _ = legacyUiLoader.PlayerGui.hud.safezone.PersonalAquarium
local Header = {
	_CurrentTab = "Online"
}

function Header.Start(_, dependencies)
	Header.Dependencies = dependencies
	Header.Dependencies.Shared.PersonalAquariumController.ProfileCacheChangedSignal:Connect(function(_)
		Header.Opened()
	end)
	local profitMethod = Header.Dependencies.Instance.Profits.ProfitMethod
	profitMethod.Online.Activated:Connect(function()
		Header._SwitchTab("Online")
	end)
	profitMethod.Offline.Activated:Connect(function()
		Header._SwitchTab("Offline")
	end)

	for _, button in Header.Dependencies.Instance.ProfitType:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v2 = button
		button.Activated:Connect(function()
			Header._EquipBest(v2.Name)
		end)
	end
end

function Header.Opened()
	Header._SetProfits()
	Header._RefreshProfitTypes()
end

function Header._RefreshProfitTypes()
	local cache = Header.Dependencies.Shared.PersonalAquariumController.Cache
	local bestProfitType = cache and cache.BestProfitType

	for _, button in Header.Dependencies.Instance.ProfitType:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v2 = v[button.Name]
		local visible

		if bestProfitType == nil or v2 == nil then
			visible = false
		else
			visible = bestProfitType == v2
		end

		button.Tabbed.Visible = visible
		button.Label.TextColor3 = visible and Color3.fromRGB(126, 199, 255) or Color3.fromRGB(255, 255, 255)
	end
end

function Header._SwitchTab(currentTab)
	if currentTab == Header._CurrentTab then
		return
	end

	for _, button in Header.Dependencies.Instance.Profits.ProfitMethod:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local visible = button.Name == currentTab
		button.Tabbed.Visible = visible
		button.Label.TextColor3 = visible and Color3.fromRGB(126, 199, 255) or Color3.fromRGB(255, 255, 255)
		button.Interactable = not visible
	end

	Header._CurrentTab = currentTab
	Header._SetProfits()
end

function Header._EquipBest(p: string)
	local v2 = v[p]

	if not v2 then
		return
	end

	if flag then
		anno_localthought:Fire("Please wait a moment before equipping best fish again...")
		return
	end

	flag = true
	task.delay(20, function()
		flag = false
	end)
	remoteEvent:FireServer(v2)
end

function Header._SetProfits()
	local label = Header.Dependencies.Instance.Profits.Label
	local cache = Header.Dependencies.Shared.PersonalAquariumController.Cache
	local fishIndex = cache and cache.FishIndex

	if not fishIndex then
		return
	end

	local v2 = {}

	for _, v3 in fishIndex do
		table.insert(v2, (DataController.getItem(v3)))
	end

	local active = cache and cache.FishFoodInventory.Active

	if not active then
		return
	end

	local v3 = Header._CurrentTab == "Online" and RewardFunctions.getFullOnlineHourlyProfit(v2, active) or RewardFunctions.getFullOfflineHourlyProfit(
		v2,
		active
	)
	label.Text = `<font color="#ffdcac">{v3.HourlyCoins}C$</font>`
	label.Text ..= `, <font color="#9bf7ff">{v3.HourlyXP}XP</font>`
	label.Text ..= `, <font color="#ff9f92">{v3.HourlyItems} item{v3.HourlyItems == 1 and "" or "s"}</font>`
	label.Text ..= " /hr"
end

return Header