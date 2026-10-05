local parent = script.Parent.Parent
local Enums = require(parent.Enums)
local State = require(parent.State)
local Util = require(parent.Util)
local shared = parent.Parent.Shared
local components = parent.Components
local Button = require(components.Button)
local React = require(shared.React)
require(shared.Settings)
local hooks = parent.Hooks
local useSpring = require(hooks.useSpring)
local useStyleSheet = require(hooks.useStyleSheet)

local function SettingsItem(props)
	local v = useStyleSheet("Palette", "Color3")
	local v2 = React.useContext(State.Context).Status == Enums.UserStatus.BoomboxPurchased
	local v3 = not props.Setting.RequiresBoombox or v2
	local setting = props.Setting
	local order = setting.Order
	local v4, v5 = React.useBinding(props.Value)
	v5(props.Value)
	local v6 = useSpring(v4:map(function(p)
		if p then
			return 1
		end

		return 0
	end), {
		tension = 800,
		friction = 30
	})
	local createElement = React.createElement
	local v8 = {
		[React.Tag] = Util.ClassNames("SettingsItem", order % 2 ~= 0 and "isAlt" or nil, not v3 and "isLocked" or nil)
	}
	local onActivated

	if v3 then
		onActivated = props.OnActivated
	end

	v8.OnActivated = onActivated
	v8.LayoutOrder = setting.Order
	v8.HoverScale = v3 and 1.05 or 1
	v8.PressScale = v3 and 0.95 or 1
	return createElement(Button, v8, {
		Info = React.createElement("CanvasGroup", {
			[React.Tag] = "Info"
		}, {
			Title = React.createElement("TextLabel", {
				[React.Tag] = "Title",
				Text = setting.Title
			}),
			Description = React.createElement("TextLabel", {
				[React.Tag] = "Description",
				Text = setting.Description
			})
		}),
		Icon = React.createElement("ImageLabel", {
			[React.Tag] = "Icon",
			ImageColor3 = v6:map(function(p)
				return v("Color-Gray"):Lerp(v("Color-Active"), p)
			end),
			Image = setting.Icon
		})
	})
end

return SettingsItem