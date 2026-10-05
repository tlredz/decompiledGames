local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
return function(p)
	local ref = React.useRef(nil)
	React.useEffect(function()
		local thread = task.spawn(function()
			while ref.current and p.TimeEnds do
				local now = DateTime.now()
				local v = math.max(0, p.TimeEnds.UnixTimestamp - now.UnixTimestamp)

				if v == 0 then
					ref.current.Text = "Ended"
					break
				end

				local formatted = TimeUtil.format(v, "short")
				ref.current.Text = formatted
				task.wait(0.1)
			end
		end)
		return function()
			task.cancel(thread)
		end
	end, { p.TimeEnds, ref.current })
	return createElement("TextLabel", {
		ref = ref,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.035, 0.5),
		Size = UDim2.fromScale(1.211, 0.9),
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
		Text = not p.TimeEnds and "Select to Preview!" or nil
	}, {
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
		})
	})
end