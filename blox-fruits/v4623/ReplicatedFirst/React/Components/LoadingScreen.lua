local ReplicatedFirst = game:GetService("ReplicatedFirst")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local RobloxTypes = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("RobloxTypes"))
local useSpring = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Hooks"):WaitForChild("Animation"):WaitForChild("useSpring"))
local usePeriod = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Hooks"):WaitForChild("Animation"):WaitForChild("usePeriod"))
local TEXTURES = require(script.TEXTURES)
local createElement = React.createElement

function logo(p)
	local imageTransparency = useSpring(1, p.Visible == false and 1 or 0, 0.5, 0.8)
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		BackgroundTransparency = 1,
		Visible = true,
		ImageTransparency = imageTransparency,
		Image = TEXTURES.IMAGES.LOGO,
		ScaleType = Enum.ScaleType.Fit
	}, p))
end

function backgroundGradient(p)
	local v = useSpring(1, p.Visible == false and 0 or 1, 0.5, 0.8)
	return createElement("UIGradient", {
		Transparency = NumberSequence.new(1 - v),
		Color = ColorSequence.new(Color3.new():Lerp(Color3.new(1, 1, 1), v))
	})
end

function loadingText(props)
	local v = math.floor(3 * usePeriod(true, 3, true) + 1)
	local v4 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
		Position = UDim2.fromScale(0.015, 0.5),
		Size = UDim2.fromScale(0.420096, 0.44132),
		Text = 0,
		TextColor3 = 0,
		TextScaled = true,
		TextXAlignment = 0
	}
	local v5

	if props.Stage == "Unloaded" then
		v5 = `Requesting {props.AssetsLoaded}/{props.AssetsNeeded} Textures`
	else
		v5 = props.LoadingMessage
	end

	v4.Text = v5 .. string.rep(".", v)
	v4.TextColor3 = Color3.new(1, 1, 1)
	v4.TextXAlignment = Enum.TextXAlignment.Left
	return createElement("TextLabel", v4, {
		UIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.05
		})
	})
end

return function(props)
	return createElement("CanvasGroup", RobloxTypes.mergeFrame({
		BackgroundTransparency = 1,
		Active = false
	}, props), {
		UIGradient = createElement(backgroundGradient, {
			Visible = props.Stage ~= "Loaded"
		}),
		Color = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(95, 172, 240),
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1)
		}, {
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 117, 171)),
					ColorSequenceKeypoint.new(0.2, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(0.8, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(47, 117, 171))
				}),
				Rotation = 90
			}),
			NEW = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1)
			}, {
				Island = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://117177099788723",
					ImageColor3 = Color3.fromRGB(39, 76, 136),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.471785, 0.474806),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.186813, 0.349413)
				}),
				Island2 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://74095102426333",
					ImageColor3 = Color3.fromRGB(39, 76, 136),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.392731, 0.784267),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.153846, 0.172099)
				}),
				Island3 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://105961223486918",
					ImageColor3 = Color3.fromRGB(39, 76, 136),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.247609, 0.455018),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.147253, 0.209909)
				}),
				Island4 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://93688627690669",
					ImageColor3 = Color3.fromRGB(39, 76, 136),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.0871702, 0.664927),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.117949, 0.209909)
				}),
				Island5 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://134010555627856",
					ImageColor3 = Color3.fromRGB(39, 76, 136),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.121462, 0.349572),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0483516, 0.0625815)
				}),
				Island6 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://81070810119247",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.121785, 0.133541),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.117216, 0.229465)
				}),
				Island7 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://87302176845013",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.227808, 0.961162),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.16541, 0.274648)
				}),
				Island8 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://135126768778129",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.617726, 0.961905),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.157052, 0.254461)
				}),
				Island9 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://75694993684199",
					ImageColor3 = Color3.fromRGB(39, 76, 136),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.389001, 0.241199),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.107692, 0.119948)
				}),
				Island10 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://105690263408353",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.487861, 0.036966),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.16337, 0.0756193)
				}),
				Island11 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://94122141064358",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.630416, 0.331783),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.131868, 0.255541)
				}),
				Island12 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://98241227830695",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.791698, 0.557253),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.161172, 0.220339)
				}),
				Island13 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://116123368242359",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.918051, 0.348288),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.16337, 0.222947)
				}),
				Island14 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://131324815140025",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.839776, 0.114188),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.203663, 0.230769)
				}),
				Island15 = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://106842947411078",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.82362, 0.824184),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.129875, 0.162726)
				}),
				ShipAnimate = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://127743608710523",
					ImageColor3 = Color3.fromRGB(27, 53, 95),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.612919, 0.718281),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				SailboatAnimate = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://74140210649216",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.634378, 0.0747757),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0533527, 0.0668165)
				}),
				SailboatAnimate2 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://84736683041863",
					ImageColor3 = Color3.fromRGB(39, 76, 136),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.173711, 0.666461),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.061761, 0.0782269)
				}),
				SailboatAnimate3 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://74002662805962",
					ImageColor3 = Color3.fromRGB(32, 63, 113),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.231927, 0.0579267),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.102564, 0.0677966)
				}),
				WaveAnimate = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.630501, 0.611371),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate2 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.588743, 0.593118),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate3 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.498633, 0.181124),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.040293, 0.0394634)
				}),
				WaveAnimate4 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.448816, 0.147225),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate5 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.239292, 0.261958),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate6 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.196802, 0.235882),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate7 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.277388, 0.623105),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate8 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.234897, 0.610067),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate9 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.0268383, 0.475778),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate10 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(-0.0207808, 0.458829),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate11 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.964567, 0.667434),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate12 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.925007, 0.624409),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate13 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.98215, 0.580081),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate14 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.582065, 0.648982),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0389604, 0.0381582)
				}),
				WaveAnimate15 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.412186, 0.924279),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate16 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.333798, 0.943835),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0571904, 0.0560129)
				}),
				WaveAnimate17 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.253462, 0.187179),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0430208, 0.0421351)
				}),
				WaveAnimate18 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.0878943, 0.40491),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0430208, 0.0421351)
				}),
				WaveAnimate19 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.0966855, 0.833854),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0430208, 0.0421351)
				}),
				WaveAnimate20 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.0498915, 0.818209),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0561153, 0.0421351)
				}),
				WaveAnimate21 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.780202, 0.317557),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0430208, 0.0421351)
				}),
				WaveAnimate22 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.7487, 0.299304),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0430208, 0.0421351)
				}),
				WaveAnimate23 = createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://76079206532938",
					ImageColor3 = Color3.fromRGB(40, 78, 140),
					ImageTransparency = 0.58,
					Position = UDim2.fromScale(0.729652, 0.338417),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.0430208, 0.0421351)
				})
			})
		}),
		Footer = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = 0.5,
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0.0936178)
		}, {
			LoadingText = createElement(loadingText, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.015, 0.5),
				Size = UDim2.fromScale(0.420096, 0.44132),
				Stage = props.Stage,
				LoadingMessage = props.LoadingMessage,
				AssetsLoaded = props.AssetsLoaded,
				AssetsNeeded = props.AssetsNeeded
			}),
			Logo = createElement(logo, {
				Visible = props.Stage ~= "Unloaded",
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromScale(0.982417, 0.710257),
				ScaleType = Enum.ScaleType.Fit,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(4.475, 2.3499999999999996)
			})
		})
	})
end