local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local RunService = game:GetService("RunService")
local sharedData = ReplicatedStorage:WaitForChild("SharedData")
local HolidayEventConfig = require(sharedData.HolidayEventConfig)
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

function HolidayCurrencyModule.GetMultiplier()
	if not HolidayCurrencyModule.EVENTS_ENABLED then
		return 0
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

	local unixTimestamp = DateTime.now().UnixTimestamp

	for _, v in ipairs(HolidayCurrencyModule.MULTIPLIER_EVENTS) do
		if not v.enabled then
			continue
		end

		local unixTimestamp2 = DateTime.fromUniversalTime(
			v.startDate.year,
			v.startDate.month,
			v.startDate.day,
			v.startDate.hour,
			v.startDate.min,
			0,
			0
		).UnixTimestamp
		local unixTimestamp3 = DateTime.fromUniversalTime(
			v.endDate.year,
			v.endDate.month,
			v.endDate.day,
			v.endDate.hour,
			v.endDate.min,
			0,
			0
		).UnixTimestamp

		if unixTimestamp2 <= unixTimestamp and unixTimestamp <= unixTimestamp3 then
			return {
				name = v.name,
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

	if not (player and player:IsA("Player")) then
		warn("[HolidayCurrency] Invalid player")
		return 0
	end

	if not HolidayCurrencyModule.EVENTS_ENABLED then
		return 0
	end

	local v = p3 or HolidayCurrencyModule.GetMultiplier()
	local v2 = math.floor(p2 * v)

	if v2 <= 0 then
		return 0
	end

	local editData = ReplicatedStorage:FindFirstChild("editData")

	if editData then
		local success, result = pcall(function()
			editData:Invoke(player, function(p4)
				if not (p4 and p4.Data and p4.Data.Seasonal) then
					warn("[HolidayCurrency] Profile structure invalid for", player.Name)
					return
				end

				if not p4.Data.Seasonal[HolidayCurrencyModule.CURRENT_EVENT] then
					p4.Data.Seasonal[HolidayCurrencyModule.CURRENT_EVENT] = 0
				end

				local seasonal = p4.Data.Seasonal
				local CURRENT_EVENT = HolidayCurrencyModule.CURRENT_EVENT
				seasonal[CURRENT_EVENT] += v2
			end)
		end)

		if not success then
			warn("[HolidayCurrency] Failed to update profile for", player.Name, "- Error:", result)
		end
	else
		warn("[HolidayCurrency] getData BindableFunction not found!")
	end

	local success, result = pcall(function()
		local info = workspace:FindFirstChild("Info")
		local playerStats = info and info:FindFirstChild("PlayerStats")

		if not playerStats then
			return false
		end

		local child = playerStats:FindFirstChild(player.Name)
		local holidayPoints = child and child:FindFirstChild("HolidayPoints")

		if holidayPoints then
			holidayPoints.Value += v2
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
			holidayCurrencyGranted:FireClient(player, v2, p2, v, p)
		end
	end)

	if RunService:IsStudio() then
		print(string.format(
			"[HolidayCurrency] Granted %d to %s (Source: %s, Base: %d, Multiplier: %.1fx)",
			v2,
			player.Name,
			p,
			p2,
			v
		))
	end

	return v2
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
		print("[HolidayCurrency] Admin multiplier set to", adminMultiplierOverride)
	else
		info:SetAttribute("AdminMultiplierOverride", nil)
		print("[HolidayCurrency] Admin multiplier disabled, using attribute-based system")
	end
end

function HolidayCurrencyModule.GetUIDisplayInfo()
	local activeMultiplierEvent = HolidayCurrencyModule.GetActiveMultiplierEvent()
	local multiplier = HolidayCurrencyModule.GetMultiplier()
	local badgeText = string.format("%.1fX %s WEEKEND!", multiplier, string.upper(HolidayCurrencyModule.CURRENCY_NAME))
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
		return string.format("%d (%d × %.1fx)", p, p2, p3)
	end

	return (tostring(p))
end

return HolidayCurrencyModule