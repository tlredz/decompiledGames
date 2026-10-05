local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local React = require(game.ReplicatedStorage.Packages.React)
local OutlinedText = require(script.Parent.OutlinedText)
local ProgressBar = require(script.Parent.ProgressBar)

-- equivalent calls inferred from this helper; original call sites unknown
local function secondsRemaining(p: number?)
	if p then
		return (math.max(0, (math.ceil(p - Workspace:GetServerTimeNow()))))
	end

	return 0
end

local function ObjectiveRow(props)
	local objective = props.Objective
	local state, setState = React.useState(function()
		local deadline = objective.Deadline

		if deadline then
			return (math.max(0, (math.ceil(deadline - Workspace:GetServerTimeNow()))))
		end

		return 0
	end)
	React.useEffect(function()
		local deadline = objective.Deadline

		if not deadline then
			return
		end

		local v = secondsRemaining(deadline) -- equivalent call inferred; original call site unknown
		setState(v)
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			local v3 = secondsRemaining(deadline) -- equivalent call inferred; original call site unknown

			if v3 ~= v then
				v = v3
				setState(v3)
			end
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, { objective.Deadline or false })
	local formatted = `{objective.Current}/{objective.Max}`

	if objective.Deadline then
		formatted = not (state > 0) and "Time expired" or string.format(
			"%d:%02d remaining",
			math.floor(state / 60),
			state % 60
		)
	end

	local createElement = React.createElement
	local v2 = {
		BackgroundTransparency = 1,
		Position = props.Position,
		Size = props.Size
	}
	local v3 = {
		label = React.createElement(OutlinedText, {
			Position = UDim2.fromScale(0, 0.25),
			Size = UDim2.fromScale(1, 0.45),
			Text = objective.Text,
			TextTransparency = 0.25,
			ShowStroke = false
		}),
		progress = 0,
		bar = 0
	}
	local createElement2 = React.createElement
	local v5 = {
		Position = UDim2.fromScale(0, 0.72),
		Size = UDim2.fromScale(objective.Deadline and 1 or 0.13, 0.4),
		Text = formatted,
		TextColor = 0,
		ShowStroke = false
	}
	local textColor

	if objective.Deadline and state == 0 then
		textColor = Color3.fromRGB(255, 100, 100)
	end

	v5.TextColor = textColor
	v3.progress = createElement2(OutlinedText, v5)
	local bar

	if not objective.Deadline then
		bar = React.createElement(ProgressBar, {
			Current = objective.Current,
			Max = objective.Max,
			RootProps = {
				Position = UDim2.fromScale(0.16, 0.72),
				Size = UDim2.fromScale(0.74, 0.2)
			}
		})
	end

	v3.bar = bar
	return createElement("Frame", v2, v3)
end

return React.memo(ObjectiveRow)