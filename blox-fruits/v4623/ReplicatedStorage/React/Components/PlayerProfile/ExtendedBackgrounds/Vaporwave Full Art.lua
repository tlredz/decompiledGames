local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local useClock = require(ReplicatedStorage.React.Hooks.useClock)
local createElement = React.createElement
local v = {
	{
		Image = "rbxassetid://105971457616557",
		Colour = Color3.fromRGB(21, 4, 64),
		Size = Vector2.new(0.145042, 0.443098),
		Y = 0.573321,
		Phase = 0
	},
	{
		Image = "rbxassetid://80341741372735",
		Colour = Color3.fromRGB(21, 4, 64),
		Size = Vector2.new(0.239165, 0.580826),
		Y = 0.604299,
		Phase = 0.5
	},
	{
		Image = "rbxassetid://99782396925000",
		Colour = Color3.fromRGB(16, 3, 48),
		Size = Vector2.new(0.201255, 0.488758),
		Y = 0.548192,
		Phase = 1
	}
}
local color = Color3.fromRGB(255, 0, 240)
local color2 = Color3.fromRGB(66, 231, 255)
local color3 = Color3.fromRGB(201, 94, 255)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.866303, 0),
	NumberSequenceKeypoint.new(1, 1)
})
local frozen = table.freeze({
	Thickness = 0.015,
	StartY = 0.9,
	EndY = -0.05,
	ScaleMin = 0.25,
	ScaleMax = 1.5,
	WidthMin = 0.65,
	WidthMax = 1,
	WidthTime = 0.95
})
local frozen2 = table.freeze({
	Thickness = 0.01,
	StartY = 0.05,
	EndY = 1.05,
	ScaleMin = 0.25,
	ScaleMax = 1.5,
	WidthMin = 0.75,
	WidthMax = 1,
	WidthTime = 0.3
})

local function neonFlicker(p: number)
	return math.clamp(
		(math.abs(math.sin(p * 11.3) * 0.5 + math.sin(p * 27.7) * 0.3 + math.sin(p * 43.1) * 0.2) - 0.7) / 0.3,
		0,
		1
	) * 0.42999999999999994 + 0.27
end

local function gridLine(mapped, mapped2, backgroundTransparency)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		Position = mapped,
		Size = mapped2
	}, {
		uIGradient = createElement("UIGradient", {
			Transparency = numberSequence
		}),
		uIStroke = createElement("UIStroke", {
			Color = color3,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.4,
			Transparency = backgroundTransparency:map(function(p: number)
				return p * 0.7 + 0.3
			end)
		}, {
			uIGradient = createElement("UIGradient", {
				Transparency = numberSequence
			})
		})
	})
end

local function gridLines(object, props)
	local v2 = {}

	for i = 1, 3 do
		local v4 = (i - 1) / 3
		local mapped = object:map(function(p: number)
			return (p * 0.3 + v4) % 1
		end)
		local mapped2 = mapped:map(function(p: number)
			return UDim2.fromScale(0, props.StartY + (props.EndY - props.StartY) * p)
		end)
		local mapped3 = mapped:map(function(p: number)
			local v5 = props.WidthMin + (props.WidthMax - props.WidthMin) * math.clamp(p / props.WidthTime, 0, 1)
			local v6 = props.ScaleMin + (props.ScaleMax - props.ScaleMin) * p
			return UDim2.fromScale(v5, props.Thickness * v6)
		end)
		local mapped4 = mapped:map(function(p: number)
			return 1 - math.clamp(p / 0.3, 0, 1)
		end)
		v2[`line{i}`] = gridLine(mapped2, mapped3, mapped4)
	end

	return createElement("Frame", {
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1)
	}, v2)
end

local function topMountainTile(mapped, mapped2)
	return createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://93488704879571",
		ImageColor3 = Color3.fromRGB(171, 171, 171),
		Position = mapped,
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(1.23988, 0.617043),
		ZIndex = 2
	}, {
		uIGradient = createElement("UIGradient", {
			Offset = mapped2,
			Rotation = 104,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.557981, 0),
				NumberSequenceKeypoint.new(0.843111, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
end

local function palmTree(props, mapped, mapped2)
	return createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Image = props.Image,
		ImageColor3 = props.Colour,
		ImageTransparency = mapped2,
		Position = mapped,
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(props.Size.X, props.Size.Y),
		ZIndex = 3
	})
end

local function bottomMountainTile(mapped, mapped2, mapped3, flag: boolean)
	return createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = flag and "rbxassetid://135295464678455" or "rbxassetid://89841896120061",
		ImageColor3 = Color3.fromRGB(171, 171, 171),
		ImageTransparency = 0.11,
		Position = mapped,
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(1.20489, 0.53479),
		ZIndex = 2
	}, {
		uIGradient = createElement("UIGradient", {
			Offset = mapped3,
			Rotation = 40,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.155525, 0),
				NumberSequenceKeypoint.new(1, 0)
			})
		}),
		wireframe = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = flag and "rbxassetid://78832770734569" or "rbxassetid://131560240946020",
			ImageTransparency = 0.47,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1)
		}, {
			uIGradient = createElement("UIGradient", {
				Color = mapped2,
				Offset = mapped3,
				Rotation = 40,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.155525, 0),
					NumberSequenceKeypoint.new(1, 0)
				})
			})
		})
	})
end

return function(_)
	local v2 = useClock()
	local mapped = v2:map(function(p: number)
		return p * 0.025 % 1.23988
	end)
	local mapped2 = mapped:map(function(p: number)
		return UDim2.fromScale(-p, 0.417799)
	end)
	local mapped3 = mapped:map(function(p: number)
		return UDim2.fromScale(-p + 1.23988, 0.417799)
	end)
	local mapped4 = mapped:map(function(p: number)
		return Vector2.new(p / 1.23988, -0.239999995)
	end)
	local mapped5 = mapped:map(function(p: number)
		return Vector2.new(p / 1.23988 - 1, -0.239999995)
	end)
	local mapped6 = v2:map(function(p: number)
		return p * 0.1 % 2.40978
	end)
	local mapped7 = v2:map(function(p: number)
		local midpoint = (math.sin(p * 1.2) + 1) / 2
		return ColorSequence.new(color:Lerp(color2, midpoint), color2:Lerp(color, midpoint))
	end)
	local mapped8 = v2:map(neonFlicker)
	local v3 = {
		backgroundGradient = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://111613236874900",
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = -999999
		}),
		sun = createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://105915065848267",
			Position = UDim2.fromScale(0.621546, -0.232081),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.48012, 0.853222),
			ZIndex = 0
		}),
		mountainA = topMountainTile(mapped2, mapped4),
		mountainB = topMountainTile(mapped3, mapped5)
	}

	for k, v4 in v do
		local v5 = v4
		local mapped9 = v2:map(function(p: number)
			local v6 = 1.25 - (p * 0.1 + v5.Phase) % 1.5
			return UDim2.fromScale(v6, v5.Y)
		end)
		local mapped10 = mapped9:map(function(udim: UDim2)
			return (math.clamp((0.5 - udim.X.Scale) / 0.37, 0, 1))
		end)
		v3[`palm{k}`] = palmTree(v4, mapped9, mapped10)
	end

	local v4 = {
		backgroundGradient = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://96772976207126",
			ImageTransparency = 0.19,
			Position = UDim2.fromScale(1, 0.11114),
			Size = UDim2.fromScale(0.88886, 0.88886),
			ZIndex = -999999
		}, {
			uIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 41, 137)),
					ColorSequenceKeypoint.new(0.487047, Color3.fromRGB(100, 0, 177)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(53, 4, 95))
				}),
				Rotation = -90
			})
		})
	}

	for i = 0, 3 do
		local v5 = i
		local mapped9 = mapped6:map(function(p: number)
			return UDim2.fromScale(-p + v5 * 1.20489, 0.5658)
		end)
		local v6 = i
		local mapped10 = mapped6:map(function(p: number)
			return Vector2.new(p / 1.20489 + -0.1 - v6, 0)
		end)
		v4[`mountain{i}`] = bottomMountainTile(mapped9, mapped7, mapped10, i % 2 == 1)
	end

	return createElement("Folder", nil, {
		viewportGlow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://81307242642772",
			ImageColor3 = Color3.fromRGB(255, 125, 231),
			ImageTransparency = mapped8,
			Position = UDim2.fromScale(0.153, 0.484),
			Size = UDim2.fromScale(0.295, 0.79),
			ZIndex = -10
		}),
		background = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.0211764, 0.855702),
			Size = UDim2.fromScale(0.265098, 0.74079),
			ZIndex = 0
		}, {
			uICorner = createElement("UICorner", {
				BottomLeftRadius = UDim.new(0.05, 0),
				BottomRightRadius = UDim.new(0.05, 0),
				CornerRadius = UDim.new(0.05, 0),
				TopLeftRadius = UDim.new(0.05, 0),
				TopRightRadius = UDim.new(0.05, 0)
			}),
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.607572
			}),
			uIStroke = createElement("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.005
			}),
			topLines = createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Image = "rbxassetid://78042544197509",
				Position = UDim2.fromScale(-0.0755416, -0.029698),
				Size = UDim2.fromOffset(383, 96)
			}, {
				horizontals = gridLines(v2, frozen)
			}),
			bottomLines = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://116213960293240",
				Position = UDim2.fromScale(-0.0755416, 1.19169),
				Size = UDim2.fromOffset(383, 174)
			}, {
				horizontals = gridLines(v2, frozen2)
			})
		}),
		frameBreak = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://111732591409314",
			Position = UDim2.fromScale(1.07848e-7, 1),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.391853, 0.904),
			ZIndex = -999
		}, {
			uICorner = createElement("UICorner", {
				BottomLeftRadius = UDim.new(0, 5),
				BottomRightRadius = UDim.new(0, 5),
				CornerRadius = UDim.new(0, 5),
				TopLeftRadius = UDim.new(0, 5),
				TopRightRadius = UDim.new(0, 5)
			})
		}),
		topRightDecor = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = UDim2.fromScale(1, 0.0940001),
			Size = UDim2.fromScale(0.623085, 0.555291),
			ZIndex = -9999
		}, v3),
		profileOutlineColorOverride = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.021, 0.856),
			Size = UDim2.fromScale(0.265, 0.741),
			ZIndex = 2
		}, {
			uICorner = createElement("UICorner", {
				BottomLeftRadius = UDim.new(0.03, 0),
				BottomRightRadius = UDim.new(0.03, 0),
				CornerRadius = UDim.new(0.03, 0),
				TopLeftRadius = UDim.new(0.03, 0),
				TopRightRadius = UDim.new(0.03, 0)
			}),
			uIStroke = createElement("UIStroke", {
				Color = Color3.fromRGB(255, 202, 235),
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.007
			})
		}),
		bottomRightDecor = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(0.660671, 0.529306),
			ZIndex = -9999
		}, v4)
	})
end