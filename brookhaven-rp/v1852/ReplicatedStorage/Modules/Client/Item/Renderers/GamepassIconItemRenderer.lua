local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local GamepassIconItem = require(ReplicatedStorage.Modules.Shared.Item.GamepassIconItem)
local v = "PropVIP"
ItemRenderer.RegisterRenderer(ItemRenderer.VEHICLES_CONTEXT, GamepassIconItem, function(object, instance)
	if not object:IsShowIcon() then
		return true
	end

	local purchasable = object:GetPurchasable()

	if purchasable == nil or instance:FindFirstChild(v) == nil then
		return true
	end

	local child = instance:FindFirstChild(v)
	local smallIcon = purchasable:GetSmallIcon()

	if smallIcon ~= nil then
		child.Visible = true
		child.Image = smallIcon
	end

	return true
end)
local v2 = "ConditionIcon"
ItemRenderer.RegisterRenderer(ItemRenderer.TOOLS_CONTEXT, GamepassIconItem, function(object, instance)
	if not object:IsShowIcon() then
		return true
	end

	local purchasable = object:GetPurchasable()

	if purchasable == nil or instance:FindFirstChild(v2) == nil then
		return true
	end

	local child = instance:FindFirstChild(v2)
	local smallIcon = purchasable:GetSmallIcon()

	if smallIcon ~= nil then
		child.Visible = true
		child.Image = smallIcon
	end

	return true
end)
local v3 = "PropTheme"
ItemRenderer.RegisterRenderer(ItemRenderer.PROPS_CONTEXT, GamepassIconItem, function(object, instance)
	if not object:IsShowIcon() then
		return true
	end

	local purchasable = object:GetPurchasable()

	if purchasable == nil or instance:FindFirstChild(v3) == nil then
		return true
	end

	local child = instance:FindFirstChild(v3)
	local smallIcon = purchasable:GetSmallIcon()

	if smallIcon ~= nil then
		child.Visible = true
		child.Image = smallIcon
	end

	return true
end)
local v4 = "CornerIcon"
ItemRenderer.RegisterRenderer(ItemRenderer.HOUSES_CONTEXT, GamepassIconItem, function(object, instance)
	if not object:IsShowIcon() then
		return true
	end

	local purchasable = object:GetPurchasable()

	if purchasable == nil or instance:FindFirstChild(v4) == nil then
		return true
	end

	local child = instance:FindFirstChild(v4)
	local smallIcon = purchasable:GetSmallIcon()

	if smallIcon ~= nil then
		child.Visible = true
		child.Image = smallIcon
	end

	return true
end)
local v5 = "VipIcon"
ItemRenderer.RegisterRenderer(ItemRenderer.EMOTES_CONTEXT, GamepassIconItem, function(object, instance)
	if not object:IsShowIcon() then
		return true
	end

	local purchasable = object:GetPurchasable()

	if purchasable == nil or instance:FindFirstChild(v5) == nil then
		return true
	end

	local child = instance:FindFirstChild(v5)
	local smallIcon = purchasable:GetSmallIcon()

	if smallIcon ~= nil then
		child.Visible = true
		child.Image = smallIcon
	end

	return true
end)
return {}