local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Policies = require(ReplicatedStorage.CAM.Global.Policies)
local Subscriptions = require(ReplicatedStorage.CAM.Global.Subscriptions)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local shopSettings = require(ReplicatedStorage.CAM.Global.shopSettings)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local VipAccess = {
	ProductId = shopSettings.VipPass.VipMonth.ProductId,
	Month = 2592000
}

local function now()
	return workspace:GetServerTimeNow()
end

local function monthOf(p, flag: boolean)
	local root = Utility.GetRoot(p)

	if root == nil and flag and p.Parent ~= nil then
		root = Utility.GetRoot(p, true)
	end

	if root == nil then
		return nil
	end

	local parent = root:FindFirstChild("VipMonth")

	if parent == nil then
		if not flag then
			return nil
		end

		parent = Instance.new("Folder")
		parent.Name = "VipMonth"
		parent.Parent = root
	end

	for _, childName in { "Started", "Duration" } do
		if parent:FindFirstChild(childName) ~= nil then
			continue
		end

		if not flag then
			return nil
		end

		local numberValue = Instance.new("NumberValue")
		numberValue.Name = childName
		numberValue.Parent = parent
	end

	return parent
end

function VipAccess.Remaining(p)
	local v = monthOf(p, false)

	if v == nil then
		return 0
	end

	local started = v:FindFirstChild("Started")
	local duration = v:FindFirstChild("Duration")

	if started == nil or duration == nil or duration.Value <= 0 then
		return 0
	end

	return (math.max(started.Value + duration.Value - workspace:GetServerTimeNow(), 0))
end

function VipAccess.Active(p)
	return VipAccess.Remaining(p) > 0
end

function VipAccess.EndsAt(p)
	local v = monthOf(p, false)

	if v == nil then
		return nil
	end

	local started = v:FindFirstChild("Started")
	local duration = v:FindFirstChild("Duration")

	if started == nil or duration == nil or duration.Value <= 0 then
		return nil
	end

	return started.Value + duration.Value
end

function VipAccess.Has(p)
	if Subscriptions.Has(p, Subscriptions.Ids.VIP) then
		return true
	end

	return VipAccess.Active(p)
end

function VipAccess.Tenured(p)
	if Subscriptions.Tenured(p, Subscriptions.Ids.VIP) then
		return true
	end

	local v = monthOf(p, false)
	local first

	if v ~= nil then
		first = v:FindFirstChild("First")
	end

	return first ~= nil and VipAccess.Active(p) and workspace:GetServerTimeNow() - first.Value >= VipAccess.Month
end

function VipAccess.CanBuy(p)
	return not VipAccess.Active(p)
end

local object = setmetatable({}, {
	__mode = "k"
})

function VipAccess.Changed(p)
	local v = p or Players.LocalPlayer
	local v2 = object[v]

	if v2 ~= nil then
		return v2
	end

	local v3 = simplesignal.new()
	object[v] = v3

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fire()
		v3:Fire(VipAccess.Has(v))
	end

	v:GetAttributeChangedSignal((`Subscription_{Subscriptions.Ids.VIP:gsub("-", "_")}`)):Connect(fire)
	task.spawn(function()
		local root = Utility.GetRoot(v, true)

		if root == nil then
			return
		end

		local function watch(vipMonth)
			if vipMonth.Name ~= "VipMonth" then
				return
			end

			for _, childName in { "Started", "Duration" } do
				local child = vipMonth:FindFirstChild(childName)

				if child ~= nil then
					child.Changed:Connect(fire)
				end
			end

			vipMonth.ChildAdded:Connect(function(numberValue)
				if numberValue:IsA("NumberValue") then
					numberValue.Changed:Connect(fire)
				end
			end)
			fire() -- equivalent call inferred; original call site unknown
		end

		local vipMonth = root:FindFirstChild("VipMonth")

		if vipMonth ~= nil then
			watch(vipMonth)
		end

		root.ChildAdded:Connect(watch)
	end)
	return v3
end

function VipAccess.PromptPurchase(p)
	local v = p or Players.LocalPlayer

	if VipAccess.Has(v) then
		return false
	end

	if not Policies.Loaded or Policies.IsEligibleToPurchaseSubscription then
		Subscriptions.Prompt(Subscriptions.Ids.VIP, p)
		return true
	end

	if not VipAccess.CanBuy(v) then
		return false
	end

	MarketplaceService:PromptProductPurchase(v, VipAccess.ProductId)
	return true
end

function VipAccess.Grant(p, value: number)
	assert(RunService:IsServer(), "VipAccess: only the server grants a month")

	if typeof(value) ~= "number" or value <= 0 then
		return false, "A month needs a length."
	end

	local parent = monthOf(p, true)

	if parent == nil then
		return false, "Your data isn't loaded yet."
	end

	if parent:FindFirstChild("First") == nil then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "First"
		numberValue.Value = workspace:GetServerTimeNow()
		numberValue.Parent = parent
	end

	local remaining = VipAccess.Remaining(p)
	local started = parent:FindFirstChild("Started")
	started.Value = workspace:GetServerTimeNow()
	local duration = parent:FindFirstChild("Duration")
	duration.Value = remaining + value
	return true
end

return VipAccess