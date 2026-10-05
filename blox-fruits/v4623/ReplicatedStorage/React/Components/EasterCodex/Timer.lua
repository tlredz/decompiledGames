local React = require(game.ReplicatedStorage.Packages.React)
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Text = React.useMemo(function()
			local unitsOfTime = TimeUtil.getUnitsOfTime(p.Seconds)
			local day = unitsOfTime.Day or 0
			local hour = unitsOfTime.Hour or 0
			local minute = unitsOfTime.Minute or 0
			local second = unitsOfTime.Second or 0
			local v = {}

			if day > 0 then
				table.insert(v, (`{day}d`))
			end

			if hour > 0 then
				table.insert(v, (`{hour}h`))
			end

			if minute > 0 then
				table.insert(v, (`{minute}m`))
			end

			if second > 0 then
				table.insert(v, (`{second}s`))
			end

			if #v == 0 then
				return "Event has Ended"
			end

			return table.concat(v, " ")
		end, { p.Seconds }),
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end