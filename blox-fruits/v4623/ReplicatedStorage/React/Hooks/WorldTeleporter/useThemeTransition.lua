local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local THEME_TRANSITION = CONSTANTS.THEME_TRANSITION

-- equivalent calls inferred from this helper; original call sites unknown
local function getKey(data)
	return (`{data.Background:ToHex()}|{data.Primary:ToHex()}|{data.Secondary:ToHex()}|{data.Text:ToHex()}`)
end

local function lerp(data, data2, value: number)
	return table.freeze({
		Background = data.Background:Lerp(data2.Background, value),
		Primary = data.Primary:Lerp(data2.Primary, value),
		Secondary = data.Secondary:Lerp(data2.Secondary, value),
		Text = data.Text:Lerp(data2.Text, value)
	})
end

return function(data, flag: boolean?)
	local state, setState = React.useState(data)
	local v = flag ~= false
	local key = getKey(data) -- equivalent call inferred; original call site unknown
	React.useEffect(function()
		local v2 = state

		if `{v2.Background:ToHex()}|{v2.Primary:ToHex()}|{v2.Secondary:ToHex()}|{v2.Text:ToHex()}` == key then
			return function() end
		end

		if not v then
			setState(data)
			return function() end
		end

		local v3 = state
		local total = 0
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			total += dt
			local v4 = math.clamp(total / THEME_TRANSITION.DURATION, 0, 1)

			if v4 >= 1 then
				renderSteppedConnection:Disconnect()
				setState(data)
			else
				setState(lerp(
					v3,
					data,
					TweenService:GetValue(v4, THEME_TRANSITION.EASING_STYLE, THEME_TRANSITION.EASING_DIRECTION)
				))
			end
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, { key, v })
	return state
end