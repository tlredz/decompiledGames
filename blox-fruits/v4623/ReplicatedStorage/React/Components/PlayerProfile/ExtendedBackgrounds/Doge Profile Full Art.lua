local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local useClock = require(ReplicatedStorage.React.Hooks.useClock)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local v = {
	{
		Image = "rbxassetid://112371031027575",
		Size = Vector2.new(919, 411),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://112371031027575",
		Size = Vector2.new(919, 411),
		Position = Vector2.yAxis * 411
	},
	{
		Image = "rbxassetid://99807973353471",
		Size = Vector2.new(919, 411),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://99807973353471",
		Size = Vector2.new(919, 411),
		Position = Vector2.yAxis * 411
	},
	{
		Image = "rbxassetid://103448453412512",
		Size = Vector2.new(919, 411),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://103448453412512",
		Size = Vector2.new(919, 411),
		Position = Vector2.yAxis * 411
	},
	{
		Image = "rbxassetid://87963661557649",
		Size = Vector2.new(919, 411),
		Position = Vector2.zero
	}
}
local v2 = {
	{
		Image = "rbxassetid://104394506423170",
		Size = Vector2.new(919, 411),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://104394506423170",
		Size = Vector2.new(919, 411),
		Position = Vector2.yAxis * 411
	},
	{
		Image = "rbxassetid://119823766101401",
		Size = Vector2.new(919, 411),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://119823766101401",
		Size = Vector2.new(919, 411),
		Position = Vector2.yAxis * 411
	},
	{
		Image = "rbxassetid://113823976647096",
		Size = Vector2.new(919, 411),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://113823976647096",
		Size = Vector2.new(919, 411),
		Position = Vector2.yAxis * 411
	},
	{
		Image = "rbxassetid://92277299415527",
		Size = Vector2.new(919, 411),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://92277299415527",
		Size = Vector2.new(919, 411),
		Position = Vector2.yAxis * 411
	},
	{
		Image = "rbxassetid://115382652660641",
		Size = Vector2.new(919, 411),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://115382652660641",
		Size = Vector2.new(919, 411),
		Position = Vector2.yAxis * 411
	}
}
local v3 = {
	{
		Image = "rbxassetid://109547225680783",
		Size = Vector2.new(892, 410),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://109547225680783",
		Size = Vector2.new(892, 410),
		Position = Vector2.yAxis * 410
	},
	{
		Image = "rbxassetid://77155672156827",
		Size = Vector2.new(892, 410),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://77155672156827",
		Size = Vector2.new(892, 410),
		Position = Vector2.yAxis * 410
	},
	{
		Image = "rbxassetid://78235676813279",
		Size = Vector2.new(892, 410),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://78235676813279",
		Size = Vector2.new(892, 410),
		Position = Vector2.yAxis * 410
	},
	{
		Image = "rbxassetid://94154623479679",
		Size = Vector2.new(892, 410),
		Position = Vector2.zero
	}
}
local v4 = {
	{
		Image = "rbxassetid://105673470092133",
		Size = Vector2.new(892, 410),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://105673470092133",
		Size = Vector2.new(892, 410),
		Position = Vector2.yAxis * 410
	},
	{
		Image = "rbxassetid://79322993480315",
		Size = Vector2.new(892, 410),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://79322993480315",
		Size = Vector2.new(892, 410),
		Position = Vector2.yAxis * 410
	},
	{
		Image = "rbxassetid://123332483288944",
		Size = Vector2.new(892, 410),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://123332483288944",
		Size = Vector2.new(892, 410),
		Position = Vector2.yAxis * 410
	},
	{
		Image = "rbxassetid://83082364874080",
		Size = Vector2.new(892, 410),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://83082364874080",
		Size = Vector2.new(892, 410),
		Position = Vector2.yAxis * 410
	},
	{
		Image = "rbxassetid://124439835603626",
		Size = Vector2.new(892, 410),
		Position = Vector2.zero
	},
	{
		Image = "rbxassetid://124439835603626",
		Size = Vector2.new(892, 410),
		Position = Vector2.yAxis * 410
	}
}

local function getFrame(p: number, list, list2)
	local v5 = #list * 0.15

	if p < v5 then
		return list[math.clamp(math.ceil(p / 0.15), 1, #list)]
	end

	return list2[math.floor((p - v5) / 0.15) % #list2 + 1]
end

local createElement = React.createElement
return function(p)
	local v5 = useClock()
	local mapped = v5:map(function(p2: number)
		local v6 = v
		local v7 = v2
		local v8 = #v6 * 0.15

		if p2 < v8 then
			return v6[math.clamp(math.ceil(p2 / 0.15), 1, #v6)]
		end

		return v7[math.floor((p2 - v8) / 0.15) % #v7 + 1]
	end)
	local mapped2 = v5:map(function(p2: number)
		local v6 = v3
		local v7 = v4
		local v8 = #v6 * 0.15

		if p2 < v8 then
			return v6[math.clamp(math.ceil(p2 / 0.15), 1, #v6)]
		end

		return v7[math.floor((p2 - v8) / 0.15) % #v7 + 1]
	end)
	local background

	if p and p.PreviewModel then
		background = createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(32, 32, 32),
			Size = UDim2.fromScale(1, 0.904),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			ZIndex = -99999
		})
	end

	local children = {
		background = background,
		topRightNew = createElement("ImageLabel", {
			Image = mapped:map(function(p2)
				return p2.Image
			end),
			Size = UDim2.fromScale(1, 0.55),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0.0898869),
			ImageRectSize = mapped:map(function(p2)
				return p2.Size
			end),
			ImageRectOffset = mapped:map(function(p2)
				return p2.Position
			end),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = -1000
		}, {
			a = createElement("UIAspectRatioConstraint", {
				AspectRatio = 2.236009732360097
			}),
			backgroundGradient = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://70789151946758",
				ImageColor3 = Color3.fromRGB(160, 17, 17),
				ImageTransparency = 0.7,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(1, 1),
				ZIndex = -999999
			})
		}),
		topRightGlow = createElement("Frame", {
			Size = UDim2.fromScale(0.587, 0.446),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0.0898869),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = -1000
		}, {
			a = createElement("UIAspectRatioConstraint", {
				AspectRatio = 2.236009732360097
			}),
			backgroundGradient = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://70789151946758",
				ImageColor3 = Color3.fromRGB(160, 17, 17),
				ImageTransparency = 0.7,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(1, 1),
				ZIndex = -999999
			})
		}),
		bottomRightGlow = createElement("Frame", {
			Size = UDim2.fromScale(0.523, 0.408),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = -1000
		}, {
			a = createElement("UIAspectRatioConstraint", {
				AspectRatio = 2.175609756097561
			}),
			backgroundGradient = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://96772976207126",
				ImageColor3 = Color3.fromRGB(160, 17, 17),
				ImageTransparency = 0.7,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(1, 1),
				ZIndex = -999999
			})
		}),
		bottomRightNew = createElement("ImageLabel", {
			Image = mapped2:map(function(p2)
				return p2.Image
			end),
			Size = UDim2.fromScale(1, 0.475),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 1),
			ImageRectSize = mapped2:map(function(p2)
				return p2.Size
			end),
			ImageRectOffset = mapped2:map(function(p2)
				return p2.Position
			end),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = -1000
		}, {
			a = createElement("UIAspectRatioConstraint", {
				AspectRatio = 2.175609756097561
			}),
			backgroundGradient = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://96772976207126",
				ImageColor3 = Color3.fromRGB(160, 17, 17),
				ImageTransparency = 0.7,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(1, 1),
				ZIndex = -999999
			})
		}),
		viewportGlow = 0,
		viewportOverlay = 0,
		frameBreak = 0
	}
	local viewportGlow

	if not (p and p.PreviewModel) then
		viewportGlow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://81307242642772",
			ImageColor3 = Color3.fromRGB(240, 10, 10),
			ImageTransparency = 0.36,
			Position = UDim2.fromScale(0.153, 0.484),
			Size = UDim2.fromScale(0.295, 0.79),
			ZIndex = -10
		})
	end

	children.viewportGlow = viewportGlow
	local viewportOverlay

	if not (p and p.PreviewModel) then
		viewportOverlay = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.021, 0.856),
			Size = UDim2.fromScale(0.265, 0.741),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			uICorner = createElement("UICorner", {
				BottomLeftRadius = UDim.new(0.03, 0),
				BottomRightRadius = UDim.new(0.03, 0),
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS,
				TopLeftRadius = UDim.new(0.03, 0),
				TopRightRadius = UDim.new(0.03, 0)
			}),
			uIStroke = createElement("UIStroke", {
				Color = Color3.fromRGB(255, 58, 58),
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.007
			})
		})
	end

	children.viewportOverlay = viewportOverlay
	children.frameBreak = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://72708849117526",
		Position = UDim2.fromScale(1.07848e-7, 1),
		Size = UDim2.fromScale(0.438, 0.904),
		ZIndex = -999
	}, {
		uICorner = createElement("UICorner", {
			BottomLeftRadius = UDim.new(0, 5),
			BottomRightRadius = UDim.new(0, 5),
			CornerRadius = UDim.new(0, 5),
			TopLeftRadius = UDim.new(0, 5),
			TopRightRadius = UDim.new(0, 5)
		})
	})
	return createElement("Folder", {}, children)
end