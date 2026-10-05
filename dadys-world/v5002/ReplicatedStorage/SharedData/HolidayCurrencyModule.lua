local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local sharedData = ReplicatedStorage:WaitForChild("SharedData")
local HolidayEventConfig = require(sharedData.HolidayEventConfig)
local SimulatedTime = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("SimulatedTime"))
local HolidayCurrencyModule = {
	CURRENT_EVENT = HolidayEventConfig.CURRENT_EVENT,
	EVENTS_ENABLED = HolidayEventConfig.EVENTS_ENABLED,
	CURRENCY_NAME = HolidayEventConfig.CURRENCY_NAME,
	COLLECTIBLE_ITEM_NAME = HolidayEventConfig.COLLECTIBLE_ITEM_NAME,
	MULTIPLIER_EVENTS = HolidayEventConfig.MULTIPLIER_EVENTS,
	GENERATOR_REWARD = 5,
	MONSTER_REWARD = 1,
	COLLECTIBLE_REWARD = 5,
	_adminMultiplierOverride = nil,
	UI_OPTIONS = {
		showBreakdownInDeathScreen = true,
		show2xBadgeOnDeathScreen = true,
		show2xIndicatorInHUD = true,
		multiplierColor = Color3.fromRGB(255, 215, 0)
	}
}
local v = {}

local function recordRunGrant(player, value, p, multiplier)
	local v2 = v[player]

	if not v2 then
		v2 = {
			Earned = 0,
			BySource = {},
			Multiplier = multiplier,
			MultiplierMixed = false
		}
		v[player] = v2
	end

	local v3 = tostring(value or "Unknown")
	v2.Earned += p
	v2.BySource[v3] = (v2.BySource[v3] or 0) + p

	if v2.Multiplier ~= multiplier then
		v2.MultiplierMixed = true
	end
end

if RunService:IsServer() then
	Players.PlayerRemoving:Connect(function(player)
		task.delay(10, function()
			v[player] = nil
		end)
	end)
end

function HolidayCurrencyModule.GetMultiplier()
	if not HolidayCurrencyModule.EVENTS_ENABLED then
		return 1
	end

	local info = workspace:FindFirstChild("Info")

	if not info then
		return 1
	end

	local adminMultiplierOverride = info:GetAttribute("AdminMultiplierOverride")

	if adminMultiplierOverride and adminMultiplierOverride > 0 then
		return adminMultiplierOverride
	end

	local currentEventMultiplier = info:GetAttribute("CurrentEventMultiplier")

	if currentEventMultiplier and currentEventMultiplier > 0 then
		return currentEventMultiplier
	end

	return 1
end

function HolidayCurrencyModule.GetActiveMultiplierEvent()
	local info = workspace:FindFirstChild("Info")

	if not info then
		return nil
	end

	local adminMultiplierOverride = info:GetAttribute("AdminMultiplierOverride")

	if adminMultiplierOverride and adminMultiplierOverride > 0 then
		return {
			name = "Admin Override",
			multiplier = adminMultiplierOverride
		}
	end

	local holidayEventActive = info:GetAttribute("HolidayEventActive")
	local currentEventMultiplier = info:GetAttribute("CurrentEventMultiplier")

	if not (holidayEventActive and currentEventMultiplier and currentEventMultiplier > 1) then
		return nil
	end

	local unixTimestamp = SimulatedTime.now().UnixTimestamp

	for _, v2 in ipairs(HolidayCurrencyModule.MULTIPLIER_EVENTS) do
		if not v2.enabled then
			continue
		end

		local unixTimestamp2 = DateTime.fromUniversalTime(
			v2.startDate.year,
			v2.startDate.month,
			v2.startDate.day,
			v2.startDate.hour,
			v2.startDate.min,
			0,
			0
		).UnixTimestamp
		local unixTimestamp3 = DateTime.fromUniversalTime(
			v2.endDate.year,
			v2.endDate.month,
			v2.endDate.day,
			v2.endDate.hour,
			v2.endDate.min,
			0,
			0
		).UnixTimestamp

		if unixTimestamp2 <= unixTimestamp and unixTimestamp <= unixTimestamp3 then
			return {
				name = v2.name,
				multiplier = currentEventMultiplier
			}
		end
	end

	return {
		name = "Special Event",
		multiplier = currentEventMultiplier
	}
end

function HolidayCurrencyModule.Grant(player, p, p2, p3)
	if RunService:IsClient() then
		warn("[HolidayCurrency] SECURITY: Grant() called from client - BLOCKED")
		return 0
	end

	if not HolidayEventConfig.ENABLED then
		return 0
	end

	if not (player and player:IsA("Player")) then
		warn("[HolidayCurrency] Invalid player")
		return 0
	end

	local multiplier = p3 or HolidayCurrencyModule.GetMultiplier()
	local v3 = math.floor(p2 * multiplier)

	if v3 <= 0 then
		return 0
	end

	local v4 = false
	local v5 = "profile not loaded (editData skipped the write)"
	local editData = ReplicatedStorage:FindFirstChild("editData")

	if editData then
		local success, result = pcall(function()
			editData:Invoke(player, function(p4)
				v5 = "profile write did not complete"

				if p4 and p4.Data and p4.Data.Seasonal then
					local HOLIDAY_KEY = HolidayEventConfig.HOLIDAY_KEY
					local currencyKey = HolidayEventConfig.CurrencyKey

					if not p4.Data.Seasonal[HOLIDAY_KEY] then
						p4.Data.Seasonal[HOLIDAY_KEY] = {}
					end

					if not p4.Data.Seasonal[HOLIDAY_KEY][currencyKey] then
						p4.Data.Seasonal[HOLIDAY_KEY][currencyKey] = 0
					end

					p4.Data.Seasonal[HOLIDAY_KEY][currencyKey] += v3
					v4 = true
					local playerData = ReplicatedStorage:FindFirstChild("PlayerData")

					if playerData then
						local child = playerData:FindFirstChild((tostring(player.UserId)))
						local seasonal = child and child:FindFirstChild("Seasonal")

						if seasonal then
							local child2 = seasonal:FindFirstChild(HOLIDAY_KEY)
							local child3 = child2 and child2:FindFirstChild(currencyKey)

							if child3 then
								child3.Value = p4.Data.Seasonal[HOLIDAY_KEY][currencyKey]
							end
						end
					end
				else
					v5 = "profile structure invalid (no Seasonal table)"
				end
			end)
		end)

		if not success then
			v5 = "editData error: " .. tostring(result)
		end
	else
		v5 = "editData BindableFunction not found"
	end

	if not v4 then
		warn(string.format(
			"[HolidayCurrency] Grant NOT credited for %s (Source: %s, Amount: %d) - %s",
			player.Name,
			tostring(p),
			v3,
			v5
		))
		return 0
	end

	recordRunGrant(player, p, v3, multiplier)
	local success, result = pcall(function()
		local info = workspace:FindFirstChild("Info")
		local playerStats = info and info:FindFirstChild("PlayerStats")

		if not playerStats then
			return false
		end

		local child = playerStats:FindFirstChild(player.Name)
		local holidayPoints = child and child:FindFirstChild("HolidayPoints")

		if holidayPoints then
			holidayPoints.Value += v3
			return true
		end

		return false
	end)

	if not (success and result) then
		warn("[HolidayCurrency] Failed to update stats for", player.Name)
	end

	pcall(function()
		local events = ReplicatedStorage:FindFirstChild("Events")
		local holidayCurrencyGranted = events and events:FindFirstChild("HolidayCurrencyGranted")

		if holidayCurrencyGranted then
			holidayCurrencyGranted:FireClient(player, v3, p2, multiplier, p)
		end
	end)
	return v3
end

function HolidayCurrencyModule.GetRunSummary(p)
	local bySource = {}
	local v3 = v[p]

	if not v3 then
		return {
			Earned = 0,
			BySource = bySource
		}
	end

	for k, v4 in pairs(v3.BySource) do
		bySource[k] = v4
	end

	local v4 = {
		Earned = v3.Earned,
		BySource = bySource,
		Multiplier = 0
	}
	local multiplier

	if not v3.MultiplierMixed then
		multiplier = v3.Multiplier
	end

	v4.Multiplier = multiplier
	return v4
end

function HolidayCurrencyModule.ResetRunSummary(p)
	v[p] = nil
end

function HolidayCurrencyModule.BuildMatchHistoryField(p)
	if not HolidayEventConfig.ENABLED then
		return nil
	end

	local runSummary = HolidayCurrencyModule.GetRunSummary(p)

	if runSummary.Earned <= 0 then
		return nil
	end

	return {
		Path = HolidayEventConfig.GetCurrencyPath(),
		Earned = runSummary.Earned,
		BySource = runSummary.BySource,
		Multiplier = runSummary.Multiplier
	}
end

function HolidayCurrencyModule.SetAdminMultiplier(adminMultiplierOverride)
	if RunService:IsClient() then
		warn("[HolidayCurrency] SECURITY: SetAdminMultiplier() called from client - BLOCKED")
		return
	end

	local info = workspace:FindFirstChild("Info")

	if not info then
		warn("[HolidayCurrency] workspace.Info not found, cannot set admin multiplier")
	elseif adminMultiplierOverride and type(adminMultiplierOverride) == "number" and adminMultiplierOverride > 0 then
		info:SetAttribute("AdminMultiplierOverride", adminMultiplierOverride)
	else
		info:SetAttribute("AdminMultiplierOverride", nil)
	end
end

function HolidayCurrencyModule.GetUIDisplayInfo()
	local activeMultiplierEvent = HolidayCurrencyModule.GetActiveMultiplierEvent()
	local multiplier = HolidayCurrencyModule.GetMultiplier()
	local badgeText = string.format("%.0fX %s WEEKEND!", multiplier, string.upper(HolidayCurrencyModule.CURRENCY_NAME))
	return {
		isActive = multiplier > 1,
		multiplier = multiplier,
		eventName = activeMultiplierEvent and activeMultiplierEvent.name or nil,
		showBreakdown = HolidayCurrencyModule.UI_OPTIONS.showBreakdownInDeathScreen,
		showBadge = HolidayCurrencyModule.UI_OPTIONS.show2xBadgeOnDeathScreen,
		showHUDIndicator = HolidayCurrencyModule.UI_OPTIONS.show2xIndicatorInHUD,
		color = HolidayCurrencyModule.UI_OPTIONS.multiplierColor,
		badgeText = badgeText,
		currencyName = HolidayCurrencyModule.CURRENCY_NAME,
		collectibleItemName = HolidayCurrencyModule.COLLECTIBLE_ITEM_NAME
	}
end

function HolidayCurrencyModule.FormatCurrencyDisplay(p, p2, p3)
	if p3 and p3 > 1 and HolidayCurrencyModule.UI_OPTIONS.showBreakdownInDeathScreen then
		return string.format("%d (%d × %.0fx)", p, p2, p3)
	end

	return (tostring(p))
end

return HolidayCurrencyModule