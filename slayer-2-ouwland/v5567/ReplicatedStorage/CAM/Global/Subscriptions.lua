local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Subscriptions = {
	Ids = {
		VIP = "EXP-3131334743635919345"
	}
}
local isServer = RunService:IsServer()
local subscriptionProductInfoAsyncs = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function attributeOf(value: string)
	return "Subscription_" .. string.gsub(value, "[^%w_]", "_")
end

function Subscriptions.GetInfo(p: string)
	if subscriptionProductInfoAsyncs[p] == nil then
		local success, subscriptionProductInfoAsync = pcall(
			MarketplaceService.GetSubscriptionProductInfoAsync,
			MarketplaceService,
			p
		)

		if success then
			subscriptionProductInfoAsyncs[p] = subscriptionProductInfoAsync
		end
	end

	return subscriptionProductInfoAsyncs[p]
end

function Subscriptions.GetIcon(p: string)
	local info = Subscriptions.GetInfo(p)

	if info == nil or info.IconImageAssetId == nil then
		return nil
	end

	return (`rbxassetid://{info.IconImageAssetId}`)
end

function Subscriptions.RefreshAll(p)
	for _, id in Subscriptions.Ids do
		task.spawn(Subscriptions.Refresh, p, id)
	end
end

function Subscriptions.Refresh(instance, value: string)
	local success, userSubscriptionStatusAsync = pcall(
		MarketplaceService.GetUserSubscriptionStatusAsync,
		MarketplaceService,
		instance,
		value
	)

	if success and userSubscriptionStatusAsync ~= nil then
		instance:SetAttribute(attributeOf(value), userSubscriptionStatusAsync.IsSubscribed == true)
	end

	return instance:GetAttribute(attributeOf(value)) == true
end

function Subscriptions.Has(instance, value: string)
	local attribute = instance:GetAttribute(attributeOf(value))

	if attribute == nil and isServer then
		return Subscriptions.Refresh(instance, value)
	end

	return attribute == true
end

function Subscriptions.Tenured(instance, value: string)
	if not Subscriptions.Has(instance, value) then
		return false
	end

	local v = attributeOf(value) .. "_FirstPaidEnd"
	local attribute = instance:GetAttribute(v)

	if not (attribute == nil and isServer) then
		return attribute ~= nil and attribute <= os.time()
	end

	local success, userSubscriptionPaymentHistoryAsync = pcall(
		MarketplaceService.GetUserSubscriptionPaymentHistoryAsync,
		MarketplaceService,
		instance,
		value
	)

	if not success then
		warn((`[Subscriptions] payment history failed for {instance.Name}: {userSubscriptionPaymentHistoryAsync}`))
		return false
	end

	for _, v2 in userSubscriptionPaymentHistoryAsync do
		if v2.PaymentStatus == Enum.SubscriptionPaymentStatus.Paid then
			attribute = math.min(attribute or 1e999, v2.CycleEndTime.UnixTimestamp)
		end
	end

	instance:SetAttribute(v, attribute)
	return attribute ~= nil and attribute <= os.time()
end

function Subscriptions.Changed(value: string, p)
	return (p or Players.LocalPlayer):GetAttributeChangedSignal(attributeOf(value))
end

function Subscriptions.Prompt(p: string, p2)
	local v = p2 or Players.LocalPlayer
	local thread = coroutine.running()
	local flag = false
	local promptSubscriptionPurchaseFinishedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish(flag2: boolean)
		if flag then
			return
		end

		flag = true
		promptSubscriptionPurchaseFinishedConnection:Disconnect()
		task.spawn(thread, flag2)
	end

	promptSubscriptionPurchaseFinishedConnection = MarketplaceService.PromptSubscriptionPurchaseFinished:Connect(function(p3, p4: string, flag2: boolean)
		if p3 == v and p4 == p then
			finish(flag2 == true) -- equivalent call inferred; original call site unknown
		end
	end)
	task.delay(60, finish, false)
	MarketplaceService:PromptSubscriptionPurchase(v, p)
	return coroutine.yield()
end

if isServer then
	Players.UserSubscriptionStatusChanged:Connect(Subscriptions.Refresh)
	MarketplaceService.PromptSubscriptionPurchaseFinished:Connect(function(p, p2: string, flag: boolean)
		if flag then
			task.delay(2, function()
				if p.Parent ~= nil then
					Subscriptions.Refresh(p, p2)
				end
			end)
		end
	end)
end

return Subscriptions