local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local frozen = table.freeze({
	Color3.fromRGB(52, 74, 94),
	Color3.fromRGB(94, 52, 60),
	Color3.fromRGB(52, 94, 66),
	Color3.fromRGB(88, 74, 40),
	Color3.fromRGB(74, 52, 94)
})
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		MaxPage = UILabs.Slider(3, 1, #frozen, 1),
		WidthPx = UILabs.Slider(270, 80, math.round(workspace.CurrentCamera.ViewportSize.X), 1),
		HeightPx = UILabs.Slider(320, 80, math.round(workspace.CurrentCamera.ViewportSize.Y), 1)
	}
}, function(p)
	local maxPage = p.controls.MaxPage
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
	local state, setState = React.useState(1)
	React.useEffect(function()
		if maxPage < state then
			setState(maxPage)
		end
	end, { maxPage, state })

	local function contentComponent(_)
		return createElement("Frame", {
			BackgroundColor3 = frozen[math.clamp(state, 1, #frozen)],
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
		}, {
			Label = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.6, 0.2),
				Text = `Page {state}`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			})
		})
	end

	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(widthPx, heightPx)
	}, {
		Carousel = createElement(parentModule, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ContentComponent = contentComponent,
			CurrentPage = state,
			MaxPage = maxPage,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.92, 0.9),
			OnPageChanged = function(p2: number)
				setState(p2)
			end
		})
	})
end)