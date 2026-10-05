local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local Textures = require(game.ReplicatedStorage.Textures)
local Util = require(game.ReplicatedStorage.React.Components.Map.Util)
require(game.ReplicatedStorage.React.Components.Map.Types)
local UserHeadshot = require(game.ReplicatedStorage.React.Components.Map.UserHeadshot)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local useCameraCFrame = require(game.ReplicatedStorage.React.Hooks.useCameraCFrame)
local useRedirectedPositions = require(game.ReplicatedStorage.React.Hooks.Map.useRedirectedPositions)
local useWeightedPosition = require(game.ReplicatedStorage.React.Hooks.Map.useWeightedPosition)
local useMapDefinition = require(game.ReplicatedStorage.React.Hooks.Map.useMapDefinition)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v = useCameraCFrame(props.Target == nil)
	local v3 = useMapDefinition((useCurrentSea()))
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if props.Target then
			if not state then
				setState(props.Target.CFrame)
			end

			local cFrameChangedConnection = props.Target:GetPropertyChangedSignal("CFrame"):Connect(function()
				setState(props.Target.CFrame)
			end)
			return function()
				cFrameChangedConnection:Disconnect()
			end
		else
			if state then
				setState(nil)
			end

			return function() end
		end
	end, { props.Target })
	local v4 = props.Target and state or v
	local v5, v6 = useWeightedPosition(v3, v4.Position, props.MapBounds, props.AbsoluteCanvasSize)
	local useMemo = React.useMemo

	local function fn()
		for _, island in props.Islands do
			if island.World.BackendPosition and (island.World.BackendPosition - v4.Position).Magnitude <= island.World.Diameter / 2 then
				return island
			end

			if v6 and table.find(v6, island.Index.Key) and (island.World.Position - v4.Position).Magnitude <= island.World.Diameter / 2 then
				return island
			end
		end

		return nil
	end

	local islands = props.Islands
	local v8

	if v6 then
		v8 = table.concat(v6, "_")
	end

	local v9 = useMemo(fn, { islands, v8, v4.Position:Floor() })
	local v10 = useRedirectedPositions(v3, props.MapBounds, props.AbsoluteCanvasSize)
	local total = 0

	if v9 and v10 and v10[v9.Index.Key] then
		v5 = v10[v9.Index.Key]
		total += 55
	end

	local lookVector = v4.LookVector
	local v11 = math.atan2(lookVector.X, -lookVector.Z)
	local v14 = {
		Position = Util.getGuiPosition(v5.X, v5.Z, props.MapBounds, props.AbsoluteCanvasSize, true),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = 0.1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.08, 0.08),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		ZIndex = total + 10
	}
	local icon

	if props.UserId then
		icon = createElement(UserHeadshot, {
			UserId = props.UserId,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BorderColor3 = props.Color,
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED
		})
	end

	return createElement("Frame", v14, {
		Icon = icon,
		VisionCone = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = Textures.misc["vision-cone.png"],
			Size = UDim2.fromScale(2, 2.5),
			Active = false,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = math.deg(v11),
			ZIndex = CONSTANTS.LAYER.CONTENT
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		})
	})
end