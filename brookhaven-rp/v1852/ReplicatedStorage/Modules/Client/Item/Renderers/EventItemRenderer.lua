local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local EventItem = require(ReplicatedStorage.Modules.Shared.Item.Items.EventItem)
local v = "PropVIP"
ItemRenderer.RegisterRenderer(ItemRenderer.VEHICLES_CONTEXT, EventItem, function(object, instance)
	if object:ShowCornerIcon() and instance:FindFirstChild(v) then
		local child = instance:FindFirstChild(v)
		child.Visible = true
		child.Image = object.eventCornerIcon
	end

	local lock = instance:FindFirstChild("Lock")

	if lock then
		lock.Visible = not (object:IsUnlockedClient() or object:GetGamepass())
	end

	return true
end)
local v2 = "ConditionIcon"
ItemRenderer.RegisterRenderer(ItemRenderer.TOOLS_CONTEXT, EventItem, function(object, instance)
	if object:ShowCornerIcon() and instance:FindFirstChild(v2) then
		local child = instance:FindFirstChild(v2)
		child.Visible = true
		child.Image = object.eventCornerIcon
	end

	local lock = instance:FindFirstChild("Lock")

	if lock then
		lock.Visible = not (object:IsUnlockedClient() or object:GetGamepass())
	end

	return true
end)
local v3 = "PropTheme"
ItemRenderer.RegisterRenderer(ItemRenderer.PROPS_CONTEXT, EventItem, function(object, instance)
	if object:ShowCornerIcon() and instance:FindFirstChild(v3) then
		local child = instance:FindFirstChild(v3)
		child.Visible = true
		child.Image = object.eventCornerIcon
	end

	local lock = instance:FindFirstChild("Lock")

	if lock then
		lock.Visible = not (object:IsUnlockedClient() or object:GetGamepass())
	end

	return true
end)
local v4 = "CornerIcon"
ItemRenderer.RegisterRenderer(ItemRenderer.HOUSES_CONTEXT, EventItem, function(object, instance)
	if object:ShowCornerIcon() and instance:FindFirstChild(v4) then
		local child = instance:FindFirstChild(v4)
		child.Visible = true
		child.Image = object.eventCornerIcon
	end

	local lock = instance:FindFirstChild("Lock")

	if lock then
		lock.Visible = not (object:IsUnlockedClient() or object:GetGamepass())
	end

	return true
end)
return {}