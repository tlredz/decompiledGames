local parent = script.Parent.Parent
local components = parent.Components
local shared = components.Parent.Parent.Shared
local Util = require(parent.Util)
local React = require(shared.React)
local Button = require(components.Button)
require(components.Button.Props)

local function TextButton(classNamesByTag)
	classNamesByTag.BackgroundTransparency = 0
	classNamesByTag.BorderSizePixel = 0
	local classNames = Util.ClassNames("TextButton", classNamesByTag[React.Tag])
	classNamesByTag[React.Tag] = classNames
	return React.createElement(Button, classNamesByTag, {
		Text = React.createElement("TextLabel", {
			[React.Tag] = classNames,
			Text = classNamesByTag.Text
		})
	})
end

return TextButton