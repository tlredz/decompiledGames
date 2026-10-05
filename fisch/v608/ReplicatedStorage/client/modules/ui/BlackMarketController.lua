game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("SoundService")
game:GetService("UserInputService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local shared = ReplicatedStorage.shared
local modules = shared.modules
local packages = ReplicatedStorage.packages
local blackMarket = Players.LocalPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("BlackMarket")
require(shared.Monetization)
require(legacyControllers.CurrencyController)
require(legacyControllers.DataController)
require(modules.EventAppraise)
require(modules.library.fish)
local library = require(modules.library)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local Net = require(packages.Net)
require(packages.Trove)
require(modules.library.bait)
require(modules.fishing.bobbers)
require(modules.library.rods)
require(modules.SkinCrates)

local function comma_value(price)
	local v = math.ceil(price)

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

local function getTableKeys(items)
	local result = {}

	for k, _ in pairs(items) do
		table.insert(result, k)
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatCountdown(p)
	local v = math.max(math.floor(p), 0)
	local v2 = math.floor(v / 3600)
	local v3 = math.floor(v % 3600 / 60)
	local v4 = v % 60
	return string.format("%02d:%02d:%02d", v2, v3, v4)
end

local remoteEvent = Net:RemoteEvent("BlackMarket/Open", -1)
local remoteEvent2 = Net:RemoteEvent("BlackMarket/ReplicateItems", -1)
local remoteEvent3 = Net:RemoteEvent("BlackMarket/Purchase", -1)
local remoteFunction = Net:RemoteFunction("BlackMarket/GetRestockTime", -1)
local BlackMarketController = {}
local v = {}
local flag = nil
local v2 = nil
local heartbeatConnection = nil
local v3 = {}
local heartbeatConnection2 = nil

local function updateTimerDisplay(p)
	if not (blackMarket and blackMarket:FindFirstChild("timer")) then
		return
	end

	local timer = blackMarket.timer
	local v4 = math.floor(p / 3600)
	local v5 = math.floor(p % 3600 / 60)
	local v6 = math.floor(p % 60)
	timer.Text = string.format("Restocks in: %02d:%02d:%02d", v4, v5, v6)
end

local startTimer

startTimer = function(p)
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	v2 = p
	updateTimerDisplay(v2)
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v4 = v2 - workspace:GetServerTimeNow()

		if v4 > 0 then
			if blackMarket.Visible then
				updateTimerDisplay(v4)
			end
		else
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			coroutine.wrap(function()
				local v5 = remoteFunction:InvokeServer()

				if v5 then
					startTimer(v5)
				end
			end)()
		end
	end)
end

local function updateLockedDrops()
	for k, v4 in v3 do
		if k.Parent then
			local v5 = v4 - workspace:GetServerTimeNow()
			local outOfStock = k.ItemPreview.OutOfStock
			outOfStock.Text = formatCountdown(v5)
		else
			v3[k] = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureLockedConnection()
	if heartbeatConnection2 then
		return
	end

	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if blackMarket.Visible and next(v3) then
			updateLockedDrops()
		end
	end)
end

function BlackMarketController:Toggle(visible: boolean?)
	if visible == nil then
		visible = not blackMarket.Visible
	end

	if visible == blackMarket.Visible then
		return
	end

	blackMarket.Visible = visible

	if visible then
		coroutine.wrap(function()
			local v4 = remoteFunction:InvokeServer()

			if v4 then
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end

				v2 = v4
				updateTimerDisplay(v2)
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					local v5 = v2 - workspace:GetServerTimeNow()

					if v5 > 0 then
						if blackMarket.Visible then
							updateTimerDisplay(v5)
						end
					else
						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end

						coroutine.wrap(function()
							local v6 = remoteFunction:InvokeServer()

							if v6 then
								startTimer(v6)
							end
						end)()
					end
				end)
			end
		end)()
	elseif heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

function BlackMarketController.init()
	remoteEvent.OnClientEvent:Connect(function(...)
		BlackMarketController:Toggle(...)
	end)
	blackMarket:WaitForChild("Close").Activated:Connect(function()
		BlackMarketController:Toggle(false)
	end)
	local v4 = {}
	local clones = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sortEntries()
		table.sort(clones, function(a, b)
			local timedDrop = a:GetAttribute("TimedDrop") == true
			local timedDrop2 = b:GetAttribute("TimedDrop") == true

			if timedDrop ~= timedDrop2 then
				return timedDrop
			end

			if timedDrop and timedDrop2 then
				local expired = a:GetAttribute("Expired") == true
				local expired2 = b:GetAttribute("Expired") == true

				if expired ~= expired2 then
					return expired2
				end

				local unlocksAt = a:GetAttribute("UnlocksAt") or 0
				local unlocksAt2 = b:GetAttribute("UnlocksAt") or 0

				if unlocksAt == unlocksAt2 then
					return a.Name < b.Name
				end

				return unlocksAt < unlocksAt2
			else
				local v5 = a:GetAttribute("OutOfStock") and not v4[a.Name]
				local selected = b:GetAttribute("OutOfStock") and not v4[b.Name]

				if v5 ~= selected then
					return selected
				end

				local sortKey = a:GetAttribute("SortKey")
				local sortKey2 = b:GetAttribute("SortKey")

				if sortKey == sortKey2 then
					return a.Name < b.Name
				end

				return sortKey < sortKey2
			end
		end)

		for k, v5 in clones do
			v5.LayoutOrder = k
		end
	end

	blackMarket:GetPropertyChangedSignal("Visible"):Connect(function()
		table.clear(v4)

		if blackMarket.Visible then
			if #clones > 0 then
				sortEntries() -- equivalent call inferred; original call site unknown
			end

			updateLockedDrops()
			coroutine.wrap(function()
				local v5 = remoteFunction:InvokeServer()

				if v5 then
					if heartbeatConnection then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end

					v2 = v5
					updateTimerDisplay(v2)
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						local v6 = v2 - workspace:GetServerTimeNow()

						if v6 > 0 then
							if blackMarket.Visible then
								updateTimerDisplay(v6)
							end
						else
							if heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end

							coroutine.wrap(function()
								local v7 = remoteFunction:InvokeServer()

								if v7 then
									startTimer(v7)
								end
							end)()
						end
					end)
				end
			end)()
		elseif heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
	local list = blackMarket:WaitForChild("List")
	local sample = list:WaitForChild("Sample")
	ensureLockedConnection() -- equivalent call inferred; original call site unknown
	remoteEvent2.OnClientEvent:Connect(function(_, p)
		local v5 = v
		v = p
		table.clear(clones)
		table.clear(v3)
		local v6 = {}

		for k, _ in v5 do
			if not v[k] then
				v6[k] = true
			end
		end

		for _, child in list:GetChildren() do
			if v6[child.Name] then
				child:Destroy()
			end
		end

		for childName, v7 in v do
			for k, v8 in v7 do
				local clone

				if v5[childName] then
					clone = list:FindFirstChild(childName)
				else
					clone = sample:Clone()
					clone.Name = childName
					clone.Parent = list
					local v9 = childName
					clone:WaitForChild("ItemPreview"):WaitForChild("BuyButton").Activated:Connect(function()
						if flag then
							return
						end

						flag = true
						remoteEvent3:FireServer(v9)
						v4[v9] = true
						task.delay(0.1, function()
							flag = false
						end)
					end)
				end

				if not clone then
					continue
				end

				table.insert(clones, clone)
				local itemPreview = clone:WaitForChild("ItemPreview")
				local itemHeader = itemPreview:WaitForChild("ItemHeader")
				local itemTitle = itemHeader:WaitForChild("ItemTitle")
				local buyButton = itemPreview:WaitForChild("BuyButton")
				local outOfStock = itemPreview:WaitForChild("OutOfStock")
				local item = itemPreview:WaitForChild("Item")
				local itemIcon = item:WaitForChild("ItemIcon")
				local amount = item:WaitForChild("Amount")

				if v8.locked then
					local questionMarksLol = item:WaitForChild("questionMarksLol")
					local new = itemHeader:WaitForChild("New")
					itemTitle.Text = "???"
					itemIcon.Visible = false
					questionMarksLol.Visible = true
					amount.Visible = false
					buyButton.Visible = false
					outOfStock.Visible = true
					outOfStock.Text = formatCountdown(v8.unlocksAt - workspace:GetServerTimeNow())
					new.Text = "SOON"
					new.SoonGradient.Enabled = true
					new.UIGradient.Enabled = false
					clone:SetAttribute("SortKey", "zzz_locked")
					clone:SetAttribute("OutOfStock", true)
					clone:SetAttribute("TimedDrop", true)
					clone:SetAttribute("UnlocksAt", v8.unlocksAt)
					clone:SetAttribute("Expired", false)
					clone.Visible = true
					v3[clone] = v8.unlocksAt
				else
					local questionMarksLol_2 = item:WaitForChild("questionMarksLol")
					questionMarksLol_2.Visible = false
					itemIcon.Visible = true
					local new = itemHeader:WaitForChild("New")

					if v8.expired then
						new.Text = "ENDED"
					else
						new.Text = "NEW"
					end

					new.SoonGradient.Enabled = false
					new.UIGradient.Enabled = true
					local displayName = v8.displayName or k
					clone.ItemPreview.ItemHeader.ItemTitle.Text = displayName
					clone.ItemPreview.BuyButton.Text = `C${comma_value(v8.price)}`
					clone.ItemPreview.Item.ItemIcon.Image = v8.customIcon or v8.reward == "ItemOrFish" and (library.fish[k] and library.fish[k].Icon or library.items[k] and library.items[k].Icon) or v8.reward == "Boat" and library.vessels[k] and library.vessels[k].Icon or v8.reward == "Bait" and library.bait[k] and library.bait[k].Icon or v8.reward == "Bobber" and library.bobbers[k] and library.bobbers[k].Icon or v8.reward == "Lantern" and library.lanterns[k] and library.lanterns[k].Icon or v8.reward == "Rod" and library.rods[k] and library.rods[k].Icon or v8.reward == "Skin" and library.skins[k] and library.skins[k].Icon or v8.reward == "SkinCrates" and library.skinCrates[k] and library.skinCrates[k].Icon or ""
					clone:SetAttribute("SortKey", displayName)

					if v8.timedDrop then
						clone:SetAttribute("TimedDrop", true)
						clone:SetAttribute("UnlocksAt", v8.unlocksAt)
					else
						clone:SetAttribute("TimedDrop", false)
					end

					clone:SetAttribute("Expired", v8.expired == true)
					local amount2 = v8.amount or 1

					if amount2 > 1 then
						amount.Text = `x{amount2}`
						amount.Visible = true
					else
						amount.Visible = false
					end

					clone:SetAttribute("OutOfStock", amount2 <= 0)

					if amount2 <= 0 then
						buyButton.Visible = false
						outOfStock.Visible = true
						outOfStock.Text = v8.expired and "EXPIRED" or "Out of Stock"
					else
						buyButton.Visible = true
						outOfStock.Visible = false
					end

					clone.Visible = true
				end
			end

			sortEntries() -- equivalent call inferred; original call site unknown
		end
	end)
	local timer = blackMarket:FindFirstChild("timer")

	if timer then
		timer.Text = "Restocks in: --:--:--"
		coroutine.wrap(function()
			local v5 = remoteFunction:InvokeServer()

			if v5 then
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end

				v2 = v5
				updateTimerDisplay(v2)
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					local v6 = v2 - workspace:GetServerTimeNow()

					if v6 > 0 then
						if blackMarket.Visible then
							updateTimerDisplay(v6)
						end
					else
						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end

						coroutine.wrap(function()
							local v7 = remoteFunction:InvokeServer()

							if v7 then
								startTimer(v7)
							end
						end)()
					end
				end)
			end
		end)()
	end
end

return BlackMarketController