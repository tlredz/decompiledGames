local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local RobloxPlusItem = require(ReplicatedStorage.Modules.Shared.Item.Items.RobloxPlusItem)
local v = "PropVIP"
ItemRenderer.RegisterRenderer(ItemRenderer.VEHICLES_CONTEXT, RobloxPlusItem, function(_, instance)
	local image = instance:FindFirstChild(v)

	if image ~= nil and image:IsA("ImageLabel") then
		image.Visible = true
		image.Image = "rbxassetid://78611328817266"
	end

	return true
end)
local v2 = "ConditionIcon"
ItemRenderer.RegisterRenderer(ItemRenderer.TOOLS_CONTEXT, RobloxPlusItem, function(_, instance)
	local image = instance:FindFirstChild(v2)

	if image ~= nil and image:IsA("ImageLabel") then
		image.Visible = true
		image.Image = "rbxassetid://78611328817266"
	end

	return true
end)
local v3 = "PropTheme"
ItemRenderer.RegisterRenderer(ItemRenderer.PROPS_CONTEXT, RobloxPlusItem, function(_, instance)
	local image = instance:FindFirstChild(v3)

	if image ~= nil and image:IsA("ImageLabel") then
		image.Visible = true
		image.Image = "rbxassetid://78611328817266"
	end

	return true
end)
local v4 = "CornerIcon"
ItemRenderer.RegisterRenderer(ItemRenderer.HOUSES_CONTEXT, RobloxPlusItem, function(_, instance)
	local image = instance:FindFirstChild(v4)

	if image ~= nil and image:IsA("ImageLabel") then
		image.Visible = true
		image.Image = "rbxassetid://78611328817266"
	end

	return true
end)
local v5 = "VipIcon"
ItemRenderer.RegisterRenderer(ItemRenderer.EMOTES_CONTEXT, RobloxPlusItem, function(_, instance)
	local image = instance:FindFirstChild(v5)

	if image ~= nil and image:IsA("ImageLabel") then
		image.Visible = true
		image.Image = "rbxassetid://78611328817266"
	end

	return true
end)
return {}