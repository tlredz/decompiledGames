local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)

local function fn(object, p)
	if not (object:IsAlwaysVisible() or object:IsUnlockedClient()) then
		return false
	end

	local icon = object:GetIcon()

	if icon ~= nil then
		p.Icon.Image = icon
	end

	return true
end

ItemRenderer.RegisterRenderer(ItemRenderer.VEHICLES_CONTEXT, MenuItem, fn)
ItemRenderer.RegisterRenderer(ItemRenderer.TOOLS_CONTEXT, MenuItem, fn)
ItemRenderer.RegisterRenderer(ItemRenderer.PROPS_CONTEXT, MenuItem, fn)
ItemRenderer.RegisterRenderer(ItemRenderer.HOUSES_CONTEXT, MenuItem, fn)
return {}