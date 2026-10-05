local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local useTheme = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useTheme)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v = useTheme()
	local slot = p.Slot
	local island = slot.Island
	local state, setState = React.useState(Enum.GuiState.Idle)
	local v2

	if state == Enum.GuiState.Idle then
		v2 = false
	else
		v2 = state ~= Enum.GuiState.NonInteractable
	end

	local imageTransparency = 1 - slot.Presence
	local v4 = v2 and 0.6 or 0.8
	local uDim = UDim2.fromScale(0.5 + math.cos(slot.Angle) * slot.Radius, 0.5 + math.sin(slot.Angle) * slot.Radius)
	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false,
		Position = uDim,
		Size = slot.Size
	}, p), {
		Button = createElement("ImageButton", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = CONSTANTS.LAYER.OVERLAY,
			Active = not slot.IsCentered,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AnchorPoint = Vector2.new(0.5, 0.5),
			[React.Change.GuiState] = function(p2)
				setState(p2.GuiState)
			end,
			[React.Event.Activated] = function(_)
				p.OnClick()
			end
		}, {
			GlowIcon = createElement("ImageLabel", {
				Position = UDim2.fromScale(0.5, 0.5),
				Image = island.Display.Icon.Image,
				ImageRectOffset = island.Display.Icon.ImageRectOffset,
				ImageRectSize = island.Display.Icon.ImageRectSize,
				ImageTransparency = imageTransparency,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}),
			ShadowContainer = createElement("Frame", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(0.6, 0.6),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5)
			}, {
				UICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
				}),
				Glow = createElement("UIShadow", {
					Color = v.Primary,
					BlurRadius = UDim.new(0.5, 0),
					Transparency = v4 + (1 - v4) * imageTransparency
				})
			})
		})
	})
end