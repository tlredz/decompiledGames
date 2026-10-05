local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local uDim = UDim.new(0.1, 0)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.78, 0),
	NumberSequenceKeypoint.new(1, 1)
})
local color = Color3.fromRGB(255, 202, 3)
local color2 = Color3.fromRGB(255, 241, 153)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, color),
	ColorSequenceKeypoint.new(0.45, color2),
	ColorSequenceKeypoint.new(0.55, color2),
	ColorSequenceKeypoint.new(1, color)
})
local colorSequence2 = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.354059, Color3.fromRGB(255, 93, 177)),
	ColorSequenceKeypoint.new(0.666667, Color3.fromRGB(156, 106, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 221, 255))
})
local numberSequence2 = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.12, 0.38),
	NumberSequenceKeypoint.new(0.5, 0.82),
	NumberSequenceKeypoint.new(0.88, 0.38),
	NumberSequenceKeypoint.new(1, 1)
})
local OptionButtonEffects = {}

function OptionButtonEffects.PremiumGlow(_)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)
	local ref4 = React.useRef(nil)
	React.useEffect(function()
		local total = 0
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt
			local midpoint = (math.sin(total * 3.8) + 1) / 2
			local current = ref.current

			if current then
				current.Thickness = midpoint * 0.035 + 0.075
				current.Transparency = (1 - midpoint) * 0.22 + 0.14
			end

			local current2 = ref2.current

			if current2 then
				current2.Thickness = midpoint * 0.025 + 0.05
				current2.Transparency = (1 - midpoint) * 0.18 + 0.46
			end

			local current3 = ref3.current

			if current3 then
				current3.BackgroundTransparency = 0.91 - midpoint * 0.06
			end

			local current4 = ref4.current

			if current4 then
				current4.Rotation = total * 95 % 360
			end
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, {})
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0
	}, {
		outerGlow = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0
		}, {
			uICorner = React.createElement("UICorner", {
				CornerRadius = uDim
			}),
			uIStroke = React.createElement("UIStroke", {
				ref = ref,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = color,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.085,
				Transparency = 0.24
			}, {
				uIGradient = React.createElement("UIGradient", {
					ref = ref4,
					Color = colorSequence,
					Transparency = numberSequence
				})
			})
		}),
		innerBleed = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.975, 0.84),
			ZIndex = 0
		}, {
			uICorner = React.createElement("UICorner", {
				CornerRadius = uDim
			}),
			uIStroke = React.createElement("UIStroke", {
				ref = ref2,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = color,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.06,
				Transparency = 0.55
			}, {
				uIGradient = React.createElement("UIGradient", {
					Color = colorSequence,
					Rotation = 180,
					Transparency = numberSequence
				})
			})
		}),
		inwardGlow = React.createElement("Frame", {
			ref = ref3,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.97, 0.82),
			ZIndex = 0
		}, {
			uICorner = React.createElement("UICorner", {
				CornerRadius = uDim
			}),
			uIGradient = React.createElement("UIGradient", {
				Transparency = numberSequence2
			})
		})
	})
end

function OptionButtonEffects.PartyGlow()
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0
	}, {
		outerGlow = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0
		}, {
			uICorner = React.createElement("UICorner", {
				CornerRadius = uDim
			}),
			uIStroke = React.createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.new(1, 1, 1),
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.085
			}, {
				uIGradient = React.createElement("UIGradient", {
					Color = colorSequence2,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					})
				})
			})
		})
	})
end

function OptionButtonEffects.Rainbow()
	local ref = React.useRef(nil)
	React.useEffect(function()
		local v = 0
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local current = ref.current

			if current then
				local colorSequenceKeypoints = {}

				for i = 0, 12 do
					local v2 = (v + i / 12) % 1
					colorSequenceKeypoints[i] = ColorSequenceKeypoint.new(i / 12, Color3.fromHSV(v2, 1, 1))
				end

				current.Color = ColorSequence.new(colorSequenceKeypoints)
			end

			v = (v + 0.5 * dt) % 1
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, {})
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0
	}, {
		outerGlow = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0
		}, {
			uICorner = React.createElement("UICorner", {
				CornerRadius = uDim
			}),
			uIStroke = React.createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.new(1, 1, 1),
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.085,
				Transparency = 0
			}, {
				uIGradient = React.createElement("UIGradient", {
					ref = ref,
					Color = colorSequence2
				})
			})
		})
	})
end

return OptionButtonEffects