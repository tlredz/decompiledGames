local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local frozen = table.freeze({
	"All",
	"Swords",
	"Guns",
	"Gear",
	"Consumables",
	"Materials",
	"Accessories",
	"Trinkets"
})
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		OptionCount = UILabs.Slider(#frozen, 1, #frozen, 1),
		WidthPx = UILabs.Slider(140, 40, 480, 1),
		HeightPx = UILabs.Slider(30, 12, 120, 1),
		IsDisabled = false,
		IsCompact = false,
		ForceClose = false
	}
}, function(p)
	local optionCount = p.controls.OptionCount
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
	local state, setState = React.useState(frozen[1])
	local options = React.useMemo(function()
		local result = {}

		for i = 1, math.min(optionCount, #frozen) do
			local text = frozen[i]
			result[text] = {
				Text = text,
				LayoutOrder = i
			}
		end

		return result
	end, { optionCount })
	React.useEffect(function()
		if options[state] == nil then
			setState(frozen[1])
		end
	end, { options, state })
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.round(widthPx * 2), (math.round(heightPx * 8)))
	}, {
		Dropdown = createElement(parentModule, {
			AnchorPoint = Vector2.new(0.5, 0),
			ForceClose = p.controls.ForceClose,
			IsCompact = p.controls.IsCompact,
			IsDisabled = p.controls.IsDisabled,
			Options = options,
			Position = UDim2.fromScale(0.5, 0.08),
			SelectedKey = state,
			Size = UDim2.fromOffset(widthPx, heightPx),
			OnMenuClose = function()
				print("menu close")
			end,
			OnMenuOpen = function()
				print("menu open")
			end,
			OnSelection = function(p2: string)
				setState(p2)
			end
		})
	})
end)