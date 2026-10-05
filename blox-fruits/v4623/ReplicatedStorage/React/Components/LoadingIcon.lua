local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(data)
	local scale = data.Scale or 1
	local speed = data.Speed or 1
	local v = math.round(scale * 128 / 2)
	local v2 = data.IsOpen == nil or data.IsOpen
	local v3 = data.IsAnimated == nil or data.IsAnimated
	local onCloseComplete = data.OnCloseComplete
	local state, setState = React.useState(false)
	local v4 = useSpring(0, v2 and v3 and 1 or 0, 1.5 * speed, 2 * speed)
	local v5 = not v3 and (v2 and 1 or 0) or v4
	React.useEffect(function()
		if v2 == false and math.abs(v5) < 0.025 and not state then
			setState(true)

			if onCloseComplete then
				onCloseComplete()
			end
		end

		return function() end
	end, { v2, v5, state })
	math.round(v5 * v)
	local v6 = usePeriod(v3, 0.64 / speed)
	local imageRectOffset = React.useMemo(function()
		local v8 = math.floor(v6 * 8) % 8
		return Vector2.new(v8 * 128, 0)
	end, { v6 })
	local mergeImageLabel = RobloxTypes.mergeImageLabel
	local v9 = {
		Active = false,
		AutomaticSize = data.AutomaticSize or Enum.AutomaticSize.XY,
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Image = `rbxassetid://{132925322271666}`,
		ImageColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		ImageRectOffset = imageRectOffset,
		ImageRectSize = Vector2.one * 128,
		ImageTransparency = 0,
		ScaleType = 0,
		Size = 0
	}
	local v10 = 1 - v5
	v9.ImageTransparency = math.max(v10, data.ImageTransparency or 0)
	v9.ScaleType = Enum.ScaleType.Stretch
	v9.Size = data.Size or UDim2.fromScale(0, 0)
	return createElement("ImageLabel", mergeImageLabel(v9, data))
end