local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local shared = ReplicatedStorage.shared
local modules = shared.modules
local packages = ReplicatedStorage.packages
local localPlayer = Players.LocalPlayer
local dailyShop = localPlayer.PlayerGui:WaitForChild("hud").safezone.DailyShop
local Monetization = require(shared.Monetization)
local ViewOddsController = require(legacyControllers.ViewOddsController)
local library = require(modules.library)
local DailyShopConfig = require(modules.DailyShopConfig)
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("DailyShop/Open")
local remoteEvent2 = Net:RemoteEvent("DailyShop/ReplicateItems")
local remoteEvent3 = Net:RemoteEvent("DailyShop/Purchase")
local remoteEvent4 = Net:RemoteEvent("DailyShop/Refresh")
local remoteEvent5 = Net:RemoteEvent("DailyShop/AdEnroll")
local v = {
	ItemOrFish = { "fish", "items" },
	Boat = { "vessels" },
	Bait = { "bait" },
	Bobber = { "bobbers" },
	Lantern = { "lanterns" },
	Rod = { "rods" },
	Skin = { "skins" },
	SkinCrates = { "skinCrates" }
}
local v2 = {}
local v3 = {}
local rerolls = {}
local nextRefresh = nil
local DailyShop = {}

local function commaValue(price: number)
	local v4 = tostring((math.ceil(price)))

	repeat
		local v5
		v4, v5 = string.gsub(v4, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v5 == 0

	return v4
end

local function formatTime(p: number)
	local v4 = math.floor(p / 3600)
	local v5 = math.floor(p % 3600 / 60)
	local v6 = p % 60
	local v7 = ""

	if v4 > 0 then
		v7 ..= `{v4}h `
	end

	if v5 > 0 then
		v7 ..= `{v5}m `
	end

	if v6 > 0 or v7 == "" then
		return v7 .. `{v6}s`
	end

	return v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPaidRestricted()
	return localPlayer:GetAttribute("PolicyPaidRandomItemsRestricted") == true
end

local function resolveIcon(item)
	if item.customIcon then
		return item.customIcon
	end

	for _, v4 in v[item.reward] or {} do
		local v5 = library[v4] and library[v4][item.name]

		if v5 and v5.Icon then
			return v5.Icon
		end
	end

	return ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateRefreshLabel()
	if not nextRefresh then
		return
	end

	local v4 = nextRefresh - DateTime.now().UnixTimestamp
	dailyShop.Header.Refresh.Label.Text = not (v4 > 0) and "Refreshing..." or `Refreshing in {formatTime(v4)}`
end

local function updateRefreshButtons()
	for _, v4 in v3 do
		local source = DailyShopConfig.ResolveSource(localPlayer, v4.Config, rerolls)
		v4.Source = source
		local rerollSource = DailyShopConfig.RerollSources[source]
		v4.Instance.Visible = not rerollSource.RestrictedByPolicy or localPlayer:GetAttribute("PolicyPaidRandomItemsRestricted") ~= true
		v4.Instance.Rerolls.Text = rerolls[source] or 0

		if not rerollSource.Label then
			continue
		end

		local label = v4.Instance:FindFirstChild("Label")

		if label then
			label.Text = `{rerollSource.Display or ""}{rerollSource.Label}`
		end
	end
end

function DailyShop:Toggle(flag: boolean?)
	local visible

	if flag == nil then
		visible = not dailyShop.Visible
	else
		visible = flag
	end

	if visible == dailyShop.Visible then
		return
	end

	if flag and not localPlayer:GetAttribute("A/B_DailyShopAdReroll") then
		remoteEvent5:FireServer()
	end

	dailyShop.Visible = visible
end

local function setupRefreshButton(refreshButton)
	local child = dailyShop:FindFirstChild(refreshButton.Button)

	if not child then
		warn((`[DailyShop] missing refresh button {refreshButton.Button}`))
		return
	end

	local v4 = {
		Instance = child,
		Config = refreshButton,
		Source = refreshButton.Sources[#refreshButton.Sources]
	}
	table.insert(v3, v4)
	local rerollSource = DailyShopConfig.RerollSources[v4.Source]

	if rerollSource.ProductId then
		child.Label.Text = `{Monetization:GetRobuxPrice(rerollSource.ProductId, false)}`
	end

	child.MouseButton1Click:Connect(function()
		if ViewOddsController.IsLoading then
			return
		end

		local source = v4.Source
		local rerollSource2 = DailyShopConfig.RerollSources[source]

		if not DailyShopConfig.IsSourceUnlocked(localPlayer, source, rerolls) then
			return
		end

		local v5

		if rerollSource2.ConfirmOdds == "Always" then
			v5 = true
		elseif rerollSource2.ConfirmOdds == "IfRestricted" then
			v5 = isPaidRestricted()
		else
			v5 = false
		end

		if v5 then
			local promptConfirmOdds = ViewOddsController.PromptConfirmOdds("dailyShop")
			dailyShop.Visible = true

			if not promptConfirmOdds then
				return
			end
		end

		remoteEvent4:FireServer(source)
	end)
end

local function createEntry(parent, instance, name: string)
	local clone = instance:Clone()
	clone.Name = name
	clone.BuyButton.MouseButton1Click:Connect(function()
		remoteEvent3:FireServer(name)
	end)
	clone.Parent = parent
	v2[name] = clone
	return clone
end

function DailyShop.init()
	local list = dailyShop.List
	local sample = list:WaitForChild("Sample")
	remoteEvent.OnClientEvent:Connect(function(...)
		DailyShop:Toggle(...)
	end)
	dailyShop.Close.Activated:Connect(function()
		DailyShop:Toggle(false)
	end)
	dailyShop.viewChances.Activated:Connect(function()
		ViewOddsController.ShowOdds("dailyShop")
	end)

	for _, refreshButton in DailyShopConfig.RefreshButtons do
		setupRefreshButton(refreshButton)
	end

	updateRefreshButtons()
	localPlayer:GetAttributeChangedSignal("PolicyPaidRandomItemsRestricted"):Connect(updateRefreshButtons)
	localPlayer:GetAttributeChangedSignal("A/B_DailyShopAdReroll"):Connect(updateRefreshButtons)
	localPlayer:GetAttributeChangedSignal("VideoAdsRemaining"):Connect(updateRefreshButtons)
	localPlayer:GetAttributeChangedSignal("VideoAdAvailable"):Connect(updateRefreshButtons)
	task.spawn(function()
		while true do
			updateRefreshLabel() -- equivalent call inferred; original call site unknown
			task.wait(1)
		end
	end)
	remoteEvent2.OnClientEvent:Connect(function(p, items)
		rerolls = p.Rerolls or {}
		updateRefreshButtons()
		nextRefresh = p.NextRefresh
		updateRefreshLabel() -- equivalent call inferred; original call site unknown

		for k, v4 in v2 do
			if items[k] then
				continue
			end

			v4:Destroy()
			v2[k] = nil
		end

		for k, item in items do
			local clone = v2[k]

			if not clone then
				clone = sample:Clone()
				clone.Name = k
				local v5 = k
				clone.BuyButton.MouseButton1Click:Connect(function()
					remoteEvent3:FireServer(v5)
				end)
				clone.Parent = list
				v2[k] = clone
			end

			clone.Label.Text = item.name
			clone.Amount.Text = not (item.amount > 1) and "" or `x{item.amount}`
			clone.BuyButton.Label.Text = `C${commaValue(item.price)}`
			clone.TextLabel.Text = ""
			clone.ImageLabel.Image = resolveIcon(item)
			clone.SoldOut.Visible = item.amount <= 0
			clone.Visible = true
		end
	end)
end

return DailyShop