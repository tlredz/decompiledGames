local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local Summer2026Util = {}
local v = {
	{
		ticketsRequired = 20,
		icon = "rbxassetid://88306220869779",
		unlockable = "Summer2026BobcatTool",
		type = "Tool & Prop",
		week = 1
	},
	{
		ticketsRequired = 100,
		icon = "rbxassetid://102204016470103",
		unlockable = "Summer2026Cannon",
		type = "Tool",
		week = 1
	},
	{
		ticketsRequired = 500,
		icon = "rbxassetid://133650645614424",
		unlockable = "Summer2026BalloonBunch",
		type = "Tool",
		week = 1
	},
	{
		ticketsRequired = 1500,
		icon = "rbxassetid://115362057114647",
		unlockable = "Summer2026SlipAndSlide",
		type = "Prop",
		week = 1
	},
	{
		ticketsRequired = 3750,
		icon = "rbxassetid://100870605770883",
		unlockable = "Summer2026GWagon",
		type = "Vehicle",
		week = 1
	},
	{
		ticketsRequired = 4200,
		icon = "rbxassetid://123583033830179",
		unlockable = "Summer2026Glider",
		type = "Tool",
		week = 2
	},
	{
		ticketsRequired = 4900,
		icon = "rbxassetid://103007258375343",
		unlockable = "Summer2026PhotoBooth",
		type = "Prop",
		week = 2
	},
	{
		ticketsRequired = 5900,
		icon = "rbxassetid://102431181702374",
		unlockable = "Summer2026Trampoline",
		type = "Prop",
		week = 2
	},
	{
		ticketsRequired = 7400,
		icon = "rbxassetid://127453923581110",
		unlockable = "Summer2026WaterBalloonLauncher",
		type = "Tool",
		week = 2
	},
	{
		ticketsRequired = 9800,
		icon = "rbxassetid://85179611301304",
		unlockable = "Summer2026FreeHouse",
		type = "House",
		week = 2
	},
	{
		ticketsRequired = 10000,
		icon = "rbxassetid://134744088854119",
		isPerpetual = true,
		week = 1
	}
}

function Summer2026Util.GetDevProductValues()
	return {
		[CountableDevProducts.SUMMER_2026_SMALL_TICKETS] = 500,
		[CountableDevProducts.SUMMER_2026_MEDIUM_TICKETS] = 1800,
		[CountableDevProducts.SUMMER_2026_LARGE_TICKETS] = 4000,
		[CountableDevProducts.SUMMER_2026_HUGE_TICKETS] = 10000
	}
end

function Summer2026Util.GetTickets(total: number, callback)
	for k, v2 in Summer2026Util.GetDevProductValues() do
		total += callback(k) * v2
	end

	return total
end

function Summer2026Util.GetSmallestSufficientBundle(p: number)
	local SUMMER_2026_HUGE_TICKETS = CountableDevProducts.SUMMER_2026_HUGE_TICKETS
	local v2 = nil

	for k, v3 in Summer2026Util.GetDevProductValues() do
		if not (p <= v3 and (v2 == nil or v3 < v2)) then
			continue
		end

		SUMMER_2026_HUGE_TICKETS = k
		v2 = v3
	end

	return {
		product = SUMMER_2026_HUGE_TICKETS,
		tickets = v2 or Summer2026Util.GetDevProductValues()[CountableDevProducts.SUMMER_2026_HUGE_TICKETS]
	}
end

function Summer2026Util.GetStoreTicketBundleUpsell(p: number, p2: number)
	if p >= 10000 then
		return nil
	end

	if p2 == 1 then
		return CountableDevProducts.SUMMER_2026_HUGE_TICKETS
	end

	return Summer2026Util.GetSmallestSufficientBundle(10000 - p).product
end

function Summer2026Util.GetSortedUnlockables()
	local result = {}

	for _, v2 in v do
		if v2.unlockable ~= nil and v2.type ~= nil then
			table.insert(result, {
				ticketsRequired = v2.ticketsRequired,
				unlockable = v2.unlockable,
				type = v2.type,
				week = v2.week
			})
		end
	end

	return result
end

function Summer2026Util.GetRewardSteps()
	return v
end

function Summer2026Util.GetPerpetualInfo()
	return {
		cost = 200,
		lastStepTickets = v[#v].ticketsRequired
	}
end

function Summer2026Util.GetRewardProgress(p: number)
	local bonusProgress = 0
	local v3 = 0
	local v4 = nil

	for k, v6 in v do
		if p < v6.ticketsRequired - (v6.isPerpetual and 200 or 0) then
			local v7 = v6.ticketsRequired - (v6.isPerpetual and 200 or 0)
			local v8 = not (k > 1) and 0 or v[k - 1].ticketsRequired
			v4 = (p - v8) / (v7 - v8)
			v3 = k
			break
		elseif k == #v then
			local v7 = p - p % 200
			local v8 = v7 + 200
			bonusProgress = (p - v7) / (v8 - v7)
			v3 = k
			v4 = 1
		end
	end

	local v6 = (v3 - 1) / #v
	return {
		progress = (v3 / #v - v6) * v4 + v6,
		bonusProgress = bonusProgress,
		claimed = v3 - 1
	}
end

return Summer2026Util