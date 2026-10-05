require(script.Parent.Types)
local Config = require(script.Parent.Config)
local DEFAULT_ALERT_ICON_SETTINGS = Config.DEFAULT_ALERT_ICON_SETTINGS
local DEFAULT_ICON_SETTINGS = Config.DEFAULT_ICON_SETTINGS
local DEFAULT_VIEWPORT_SETTINGS = Config.DEFAULT_VIEWPORT_SETTINGS

local function normalizeAlertIconSettings(alertIconSettings)
	local maxDistance

	if alertIconSettings and alertIconSettings.MaxDistance ~= nil then
		maxDistance = alertIconSettings.MaxDistance
	else
		maxDistance = DEFAULT_ALERT_ICON_SETTINGS.MaxDistance
	end

	local icon

	if alertIconSettings then
		icon = alertIconSettings.Icon
	else
		icon = DEFAULT_ALERT_ICON_SETTINGS.Icon
	end

	local sprite

	if alertIconSettings then
		sprite = alertIconSettings.Sprite
	else
		sprite = DEFAULT_ALERT_ICON_SETTINGS.Sprite
	end

	local color

	if alertIconSettings and alertIconSettings.Color ~= nil then
		color = alertIconSettings.Color
	else
		color = DEFAULT_ALERT_ICON_SETTINGS.Color
	end

	local backgroundColor

	if alertIconSettings and alertIconSettings.BackgroundColor ~= nil then
		backgroundColor = alertIconSettings.BackgroundColor
	else
		backgroundColor = DEFAULT_ALERT_ICON_SETTINGS.BackgroundColor
	end

	local imageColor

	if alertIconSettings and alertIconSettings.ImageColor ~= nil then
		imageColor = alertIconSettings.ImageColor
	else
		imageColor = DEFAULT_ALERT_ICON_SETTINGS.ImageColor
	end

	local borderColor

	if alertIconSettings and alertIconSettings.BorderColor ~= nil then
		borderColor = alertIconSettings.BorderColor
	else
		borderColor = DEFAULT_ALERT_ICON_SETTINGS.BorderColor
	end

	return {
		MaxDistance = maxDistance,
		Icon = icon,
		Sprite = sprite,
		Color = color,
		BackgroundColor = backgroundColor,
		ImageColor = imageColor,
		BorderColor = borderColor
	}
end

local function normalizeIconSettings(iconSettings)
	local customIcon

	if iconSettings then
		customIcon = iconSettings.CustomIcon
	else
		customIcon = DEFAULT_ICON_SETTINGS.CustomIcon
	end

	local sprite

	if iconSettings then
		sprite = iconSettings.Sprite
	else
		sprite = DEFAULT_ICON_SETTINGS.Sprite
	end

	local showIsland

	if iconSettings and iconSettings.ShowIsland ~= nil then
		showIsland = iconSettings.ShowIsland
	else
		showIsland = DEFAULT_ICON_SETTINGS.ShowIsland
	end

	return {
		CustomIcon = customIcon,
		Sprite = sprite,
		ShowIsland = showIsland
	}
end

local function normalizeViewportSettings(viewportSettings)
	local minDistance

	if viewportSettings and viewportSettings.MinDistance ~= nil then
		minDistance = viewportSettings.MinDistance
	else
		minDistance = DEFAULT_VIEWPORT_SETTINGS.MinDistance
	end

	local model

	if viewportSettings then
		model = viewportSettings.Model
	else
		model = DEFAULT_VIEWPORT_SETTINGS.Model
	end

	local useIconAsBackground

	if viewportSettings and viewportSettings.UseIconAsBackground ~= nil then
		useIconAsBackground = viewportSettings.UseIconAsBackground
	else
		useIconAsBackground = DEFAULT_VIEWPORT_SETTINGS.UseIconAsBackground
	end

	return {
		MinDistance = minDistance,
		Model = model,
		UseIconAsBackground = useIconAsBackground
	}
end

return {
	normalize = function(options)
		local v = options or {}
		local v2 = {
			AlertIconSettings = normalizeAlertIconSettings(v.AlertIconSettings),
			IconSettings = normalizeIconSettings(v.IconSettings),
			ViewportSettings = normalizeViewportSettings(v.ViewportSettings),
			ShowOffScreenAlert = v.ShowOffScreenAlert == nil or v.ShowOffScreenAlert,
			EdgeIndicatorOutlineColor = v.EdgeIndicatorOutlineColor or Config.DEFAULT_EDGE_INDICATOR_OUTLINE_COLOR,
			DestroyOnApproach = 0,
			Target = 0
		}
		local DEFAULT_DESTROY_ON_APPROACH_DISTANCE

		if v.DestroyOnApproach == true then
			DEFAULT_DESTROY_ON_APPROACH_DISTANCE = Config.DEFAULT_DESTROY_ON_APPROACH_DISTANCE
		elseif type(v.DestroyOnApproach) == "number" then
			DEFAULT_DESTROY_ON_APPROACH_DISTANCE = v.DestroyOnApproach
		end

		v2.DestroyOnApproach = DEFAULT_DESTROY_ON_APPROACH_DISTANCE
		v2.Target = v.Target
		return v2
	end
}