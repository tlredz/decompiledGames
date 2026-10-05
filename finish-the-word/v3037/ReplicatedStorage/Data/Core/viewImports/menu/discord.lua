local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("global")
local import4 = _G.import("viewImports")
local basic = import4:get("basic")
local menu = import4:get("menu")
local model = import.model(basic.ImageButton)

function model.init()
	return {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1.03, 0, -0.025, 0),
		Size = UDim2.new(0.15, 0, 0.15, 0),
		Image = "rbxassetid://139260875194032",
		MouseButton1Down = function(p)
			p.Ui:Destroy()
		end
	}
end

local model2 = import.model(menu.Button)

function model2.init()
	return {
		Position = UDim2.new(0.5, 0, 0.825, 0),
		Size = UDim2.new(1, 0, 0.1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Delta = 0.01,
		AspectRatio = 4.31343284,
		Variant = "grayscale",
		Clickable = true,
		Text = "CLAIM!",
		GradientRotation = 85,
		GradientColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 106, 0)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 106, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 246, 0)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 106, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 106, 0))
		}),
		MouseButton1Down = function(object)
			object:verify()
		end
	}
end

function model2:verify()
	if import3.get("playerSave", game.Players.LocalPlayer).Flags.VerifiedDiscord then
		import2.fire("signal", "You have already verified your Discord")
		return
	end

	local codeInputBox = self.Ui.CodeInputBox
	local _, v = import2.remoteFire("verifyDiscord", codeInputBox.Text)
	import2.fire("signal", v)
end

local model3 = import.model("TextBox", basic.Padding)

function model3.init()
	return {
		Position = UDim2.new(0.5, 0, 0.695, 0),
		Size = UDim2.new(0.59, 0, 0.09, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		PaddingTop = UDim.new(0.18, 0),
		PaddingBottom = UDim.new(0.18, 0),
		CornerRadius = UDim.new(0.15, 0),
		StrokeWidth = 1,
		StrokeColor = Color3.fromRGB(255, 255, 255),
		StrokeTransparency = 0.65,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextTransparency = 0.65,
		PlaceholderText = "Type code here...",
		PlaceholderColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.ExtraBold, Enum.FontStyle.Italic),
		ZIndex = 3
	}, {
		Background = import.make(basic.ImageLabel, {
			Location = "Center",
			Size = UDim2.new(3, 0, 4, 0),
			Image = "rbxassetid://72042537511464",
			ScaleType = Enum.ScaleType.Fit,
			AspectRatio = 9.77966102,
			ZIndex = -1
		})
	}
end

local model4 = import.model(basic.EmptyElement)

function model4.init()
	return {
		Position = UDim2.new(0.5, 0, 0.09, 0),
		Size = UDim2.new(0.93, 0, 0.178, 0),
		AnchorPoint = Vector2.new(0.5, 0)
	}, {
		Background = import.make(basic.ImageLabel, {
			Location = "Center",
			Size = UDim2.new(1, 0, 1, 0),
			AspectRatio = 7.19834711,
			Image = "rbxassetid://93238616124307"
		}),
		HeadlineLabel = import.make(import.wrap(basic.TextLabel, basic.Gradient), {
			Location = "Center",
			Size = UDim2.new(0.85, 0, 0.65, 0),
			ZIndex = 2,
			Text = "Join our Discord to earn free Yen and exclusive bonus codes!",
			FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.ExtraBold),
			LineHeight = 0.9,
			GradientRotation = 15,
			GradientColor = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 246, 255)),
				ColorSequenceKeypoint.new(0.02, Color3.fromRGB(0, 246, 255)),
				ColorSequenceKeypoint.new(0.36, Color3.fromRGB(11, 141, 254)),
				ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 246, 255)),
				ColorSequenceKeypoint.new(0.98, Color3.fromRGB(0, 246, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 246, 255))
			})
		})
	}
end

local model5 = import.model(basic.TextLabel)

function model5.init()
	return {
		Position = UDim2.new(0.5, 0, 0.295, 0),
		Size = UDim2.new(0.8, 0, 0.17, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		RichText = true,
		Text = [[
Type <font color="#73FF00">/verify</font> in <font color="#73FF00">#bot-commands</font> to get your CODE
<font color="#FF7B00">Enter this CODE below to complete verification</font> ✅ 
		]],
		LineHeight = 1.1,
		FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.ExtraBold, Enum.FontStyle.Italic)
	}
end

local model6 = import.model(basic.ImageLabel)

function model6.init()
	return {
		Position = UDim2.new(0.5, 0, 0.38, 0),
		Size = UDim2.new(1.32, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Image = "rbxassetid://139635015215047",
		ScaleType = Enum.ScaleType.Fit,
		AspectRatio = 5.7593985
	}, {
		DiscordGuide = import.make(basic.ImageLabel, {
			Position = UDim2.new(0.192, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1.52, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://128124418828356",
			ScaleType = Enum.ScaleType.Fit
		}),
		YenIcon = import.make(basic.ImageLabel, {
			Position = UDim2.new(0.7, 0, 0.5, 0),
			Size = UDim2.new(0.4, 0, 0.4, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://70625507175795",
			ScaleType = Enum.ScaleType.Fit
		})
	}
end

local model7 = import.model(basic.ConstrainedElement, basic.Ui)

function model7.init(_)
	return {
		Location = "Center",
		Size = UDim2.new(0.7, 0, 0.7, 0),
		AspectRatio = 1.34709193,
		BackgroundTransparency = 0
	}, {
		MainHeadline = import.make(model4),
		SubHeadline = import.make(model5),
		Foo = import.make(model6),
		CodeInputBox = import.make(model3),
		VerifyButton = import.make(model2),
		Xbutton = import.make(model)
	}
end

return {
	Discord = model7
}