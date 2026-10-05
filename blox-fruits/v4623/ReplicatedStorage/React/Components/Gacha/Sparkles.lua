local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.4, 1),
	NumberSequenceKeypoint.new(0.48, 0),
	NumberSequenceKeypoint.new(0.52, 0),
	NumberSequenceKeypoint.new(0.6, 1),
	NumberSequenceKeypoint.new(1, 1)
})
local createElement = React.createElement
return function(p)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(0)
	React.useEffect(function()
		local heartbeatConnection

		if ref.current and ref2.current and p.Enabled ~= false then
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				ref3.current += dt
				local midpoint = (math.sin(ref3.current * (p.Speed or 0.2) * 3.141592653589793 * 2) + 1) / 2

				if ref.current then
					ref.current.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(midpoint, 1),
						NumberSequenceKeypoint.new(1, 0)
					})
				end
			end)
		else
			heartbeatConnection = nil
		end

		return function()
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end
	end, { p.Enabled, ref.current, ref2.current })
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		ref = ref2,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://131002855302679",
		ScaleType = Enum.ScaleType.Fit,
		Visible = p.Enabled ~= false
	}, p), {
		UIGradient = createElement("UIGradient", {
			ref = ref,
			Transparency = numberSequence
		})
	})
end