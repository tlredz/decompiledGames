local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Promise)
require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local localPlayer = Players.LocalPlayer
local v5 = v2.retryWithDelay(PolicyService.GetPolicyInfoForPlayerAsync, 3, 2, PolicyService, localPlayer)
local TradeController = {}

function TradeController:ListenForCanTrade(callback, flag: boolean?)
	local v6 = v.Client:WaitReplion("Data")

	if not v6 then
		return function() end
	end

	if self:CanTradeInstant() then
		task.spawn(callback, true)
		return function() end
	end

	local maid = v3.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		if not self:CanTradeInstant(flag) then
			task.spawn(callback, false)
			return
		end

		task.spawn(callback, true)
		maid:Destroy()
	end

	maid:Add(localPlayer:GetAttributeChangedSignal("__globalUpdatesInitialized"):Connect(update))
	maid:Add(v6:OnChange("TradeBanned", update))
	maid:Add(v6:OnChange("TradeLockedUntil", update))
	maid:Add(v6:OnChange("TotalStats.Wins", update))
	maid:AddPromise(v5):andThen(update)
	local unixTimestamp = DateTime.now().UnixTimestamp
	local v7 = unixTimestamp - (localPlayer:GetAttribute("JoinedTimestamp") or v6:Get("LastSession") or unixTimestamp)
	local instantFFlag = v4.FFlag.GetInstantFFlag("TradeJoinCooldown", 30)

	if v7 < instantFFlag and not RunService:IsStudio() then
		maid:Add(task.delay(instantFFlag - v7 + 1, update))
	else
		update() -- equivalent call inferred; original call site unknown
	end

	return function()
		maid:Destroy()
	end
end

function TradeController:HasTradeRequirements()
	local replion = v.Client:GetReplion("Data")

	if not replion then
		return false, "You are still loading!"
	end

	if (replion:Get("TotalStats.Wins") or 0) < 1 and not RunService:IsStudio() then
		return false, "You can't trade before getting 1 Win!"
	end

	local v6, v7 = v5:await()

	if v6 and v7 and v7.IsPaidItemTradingAllowed then
		return true
	end

	return false, "You are restricted from trading due to Roblox policy!"
end

function TradeController:CanTrade(flag: boolean?)
	if v4.FFlag.GetFFlag("TradingEnabled") ~= true or v4.FFlag.GetFFlag("TradingSystemEnabled") ~= true then
		return false, "Trading is currently disabled!"
	end

	local replion = v.Client:GetReplion("Data")

	if not replion then
		return false, "You are still loading!"
	end

	local tradeLockedUntil = replion:Get("TradeLockedUntil")
	local serverTimeNow = workspace:GetServerTimeNow()

	if replion:Get("TradeBanned") then
		return false, "You are unable to trade!"
	end

	if tradeLockedUntil and tradeLockedUntil > 0 and serverTimeNow < tradeLockedUntil then
		local v6 = tradeLockedUntil - serverTimeNow
		return false, (`You are unable to trade for {v4.ValueConvertor:FormatShortTime(v6)}`)
	end

	local hasTradeRequirements, v6 = self:HasTradeRequirements()

	if not hasTradeRequirements then
		return false, v6
	end

	if not localPlayer:GetAttribute("__globalUpdatesInitialized") then
		return false, "You are still loading!"
	end

	if not flag then
		return true
	end

	local unixTimestamp = DateTime.now().UnixTimestamp
	local v7 = unixTimestamp - (localPlayer:GetAttribute("JoinedTimestamp") or replion:Get("LastSession") or unixTimestamp)
	local instantFFlag = v4.FFlag.GetInstantFFlag("TradeJoinCooldown", 30)

	if v7 < instantFFlag and not RunService:IsStudio() then
		return false, (`You can't trade for {math.ceil(instantFFlag - v7)} seconds!`)
	end

	return true
end

function TradeController:HasTradeRequirementsInstant()
	local replion = v.Client:GetReplion("Data")

	if not replion then
		return false, "You are still loading!"
	end

	if (replion:Get("TotalStats.Wins") or 0) < 1 and not RunService:IsStudio() then
		return false, "You can't trade before getting 1 Win!"
	end

	local v6, v7 = v5:now():await()

	if v6 and v7 and v7.IsPaidItemTradingAllowed then
		return true
	end

	return false, "You are restricted from trading due to Roblox policy!"
end

function TradeController:CanTradeInstant(flag: boolean?)
	if v4.FFlag.GetInstantFFlag("TradingEnabled") ~= true or v4.FFlag.GetInstantFFlag("TradingSystemEnabled") ~= true then
		return false, "Trading is currently disabled!"
	end

	local replion = v.Client:GetReplion("Data")

	if not replion then
		return false, "You are still loading!"
	end

	local tradeLockedUntil = replion:Get("TradeLockedUntil")
	local serverTimeNow = workspace:GetServerTimeNow()

	if replion:Get("TradeBanned") then
		return false, "You are unable to trade!"
	end

	if tradeLockedUntil and tradeLockedUntil > 0 and serverTimeNow < tradeLockedUntil then
		local v6 = tradeLockedUntil - serverTimeNow
		return false, (`You are unable to trade for {v4.ValueConvertor:FormatShortTime(v6)}`)
	end

	local hasTradeRequirementsInstant, v6 = self:HasTradeRequirementsInstant()

	if not hasTradeRequirementsInstant then
		return false, v6
	end

	if not localPlayer:GetAttribute("__globalUpdatesInitialized") then
		return false, "You are still loading!"
	end

	if not flag then
		return true
	end

	local unixTimestamp = DateTime.now().UnixTimestamp
	local v7 = unixTimestamp - (localPlayer:GetAttribute("JoinedTimestamp") or replion:Get("LastSession") or unixTimestamp)
	local instantFFlag = v4.FFlag.GetInstantFFlag("TradeJoinCooldown", 30)

	if v7 < instantFFlag and not RunService:IsStudio() then
		return false, (`You can't trade for {math.ceil(instantFFlag - v7)} seconds!`)
	end

	return true
end

return TradeController