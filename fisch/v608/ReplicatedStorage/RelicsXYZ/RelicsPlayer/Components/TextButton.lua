local parent = script.Parent.Parent
local components = parent.Components
local shared = components.Parent.Parent.Shared
local hooks = parent.Hooks
local useStyleSheet = require(hooks.useStyleSheet)
local Util = require(parent.Util)
local React = require(shared.React)
local Button = require(components.Button)
require(components.Button.Props)

local function TextButton(state)
	local v = useStyleSheet("Palette", "Color3")

	if not state.BackgroundColor3 then
		state.BackgroundColor3 = v("Color-White")
	end

	state.BackgroundTransparency = 0
	state.BorderSizePixel = 0
	local classNames = Util.ClassNames("TextButton", state[React.Tag])
	state[React.Tag] = classNames
	return React.createElement(Button, state, {
		Text = React.createElement("TextLabel", {
			[React.Tag] = classNames,
			Text = state.Text
		})
	})
end

return TextButton