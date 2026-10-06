local module = require("@game/ReplicatedStorage/Omni")
local Players = game:GetService("Players")
local module2 = require("@game/ReplicatedStorage/Omni/Libs/TopBarPlus/Packages/GoodSignal")
local v = module.Libs.DataContainerClient.New("TradeInfo")

local function GetInboxNotices()
	local inbox = module.Data.Inbox
	local result = {}

	for k, v2 in inbox and inbox.List or {} do
		if v2.Deleted or v2.Claimed == true then
			continue
		end

		local v3

		if typeof(v2.Rewards) == "table" then
			v3 = next(v2.Rewards) ~= nil
		else
			v3 = false
		end

		if v3 or v2.CommerceGift then
			result[k] = true
		end
	end

	return result
end

local function GetGuildNotices()
	local guild = module.Data.Guild
	local result = {}

	for _, v2 in guild and guild.Invites or {} do
		if v2.GuildId then
			result[v2.GuildId] = true
		end
	end

	return result
end

local function GetTradeNotices()
	local result = {}
	local userId = module.Instance.UserId
	local value = v:GetValue({ userId })

	if not v.Ready or not value or value.Trading then
		return result
	end

	if value.RequestsAllowed ~= true or module.Data.Settings["Allow Trade Requests"] ~= true or module.Data.Trade.Pending then
		return result
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local tradeRequestDuration = module.Shared.Trade.TradeRequestDuration

	for k, v2 in value.Requests or {} do
		if not (k ~= userId and module.Utils.Validator:ValidateNumber(v2)) then
			continue
		end

		local v3 = serverTimeNow - v2

		if v3 < 0 or tradeRequestDuration <= v3 then
			continue
		end

		local playerByUserId = Players:GetPlayerByUserId(k)
		local value2 = v:GetValue({ k })

		if not playerByUserId or not value2 or value2.Trading or value2.RequestsAllowed ~= true then
			continue
		end

		if value.Blocked and value.Blocked[k] or value2.Blocked and value2.Blocked[userId] then
			continue
		end

		result[k] = v2
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearNotice(p, k)
	local v2 = p[k]

	if not v2 then
		return
	end

	p[k] = nil
	v2.Signal:Fire()
	v2.Signal:DisconnectAll()
end

local function Reconcile(object, items, items2)
	for k, item in items do
		if items2[k] == item.Value then
			continue
		end

		ClearNotice(items, k) -- equivalent call inferred; original call site unknown
	end

	for k, item in items2 do
		if items[k] then
			continue
		end

		local signal = module2.new()
		items[k] = {
			Value = item,
			Signal = signal
		}
		object:notify(signal)
	end
end

return {
	Bind = function(object, data)
		local v2 = true
		local v3 = {}
		local v4 = {
			Inbox = {},
			Guilds = {},
			Trade = {}
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function RefreshInbox()
			if not v2 then
				return
			end

			Reconcile(data.Inbox, v4.Inbox, GetInboxNotices())
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function RefreshGuilds()
			if not v2 then
				return
			end

			Reconcile(data.Guilds, v4.Guilds, GetGuildNotices())
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function RefreshTrade()
			if not v2 then
				return
			end

			Reconcile(data.Trade, v4.Trade, GetTradeNotices())
		end

		object:addToJanitor(function()
			v2 = false

			for _, connection in v3 do
				connection:Disconnect()
			end

			for _, v5 in v4 do
				for k in v5 do
					ClearNotice(v5, k) -- equivalent call inferred; original call site unknown
				end
			end

			table.clear(v3)
		end)
		table.insert(v3, module:OnDataChanged({ "Inbox" }, RefreshInbox))
		table.insert(v3, module:OnDataChanged({ "Guild" }, RefreshGuilds))
		table.insert(v3, module:OnDataChanged({ "Settings" }, RefreshTrade))
		table.insert(v3, module:OnDataChanged({ "Trade" }, RefreshTrade))
		table.insert(v3, v:OnChange({}, RefreshTrade))
		table.insert(v3, module.Utils.Loop:Connect({
			Time = 1,
			Callback = RefreshTrade
		}))
		RefreshInbox() -- equivalent call inferred; original call site unknown
		RefreshGuilds() -- equivalent call inferred; original call site unknown
		RefreshTrade() -- equivalent call inferred; original call site unknown
	end
}