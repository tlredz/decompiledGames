local localPlayer = game.Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local import = _G.import("romodel")
local import2 = _G.import("iterator")
local basic = _G.import("viewImports"):get("basic")
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

local v = {
	Explode = {
		Icon = "rbxassetid://83271695869042",
		DisplayText = "Explode All!",
		Color = ColorSequence.new(Color3.fromRGB(255, 34, 67), Color3.fromRGB(199, 9, 85)),
		ProductId = 3596878426
	},
	Blind = {
		Offset = 0.52,
		Icon = "rbxassetid://90951726569520",
		DisplayText = "Blind All!",
		Color = ColorSequence.new(Color3.fromRGB(82, 194, 255), Color3.fromRGB(48, 127, 230)),
		ProductId = 3596878434
	},
	Scare = {
		Offset = 0.52,
		Icon = "rbxassetid://92095294889857",
		DisplayText = "Scare All!",
		Color = ColorSequence.new(Color3.fromRGB(134, 255, 5), Color3.fromRGB(39, 171, 87)),
		ProductId = 3596878420
	}
}
local model2 = import.model(basic.ImageButton, basic.Corner, basic.Stroke, basic.Gradient)

function model2.init(p)
	local v2 = v[p.Id]
	return {
		Image = "rbxassetid://120822935454304",
		GradientColor = v2.Color,
		GradientRotation = 90,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(1, 0, 4.25, 0),
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CornerRadius = UDim.new(0.2, 0),
		AspectRatio = 4.25,
		Scale = 1,
		StrokeWidth = 3,
		MouseButton1Down = function()
			MarketplaceService:PromptProductPurchase(localPlayer, v2.ProductId)
		end
	}, {
		Icon = import.make(basic.ImageLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.475, 0),
			Size = UDim2.new(1.25, 0, 1.25, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Image = v2.Icon
		}),
		TextLabel = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(v2.Offset or 0.55, 0, 0.51, 0),
			Size = UDim2.new(0.75, 0, 0.45, 0),
			Font = Enum.Font.GothamBlack,
			Text = string.upper(v2.DisplayText),
			StrokeWidth = 3
		})
	}
end

local model3 = import.model(basic.EmptyElement)

function model3.init()
	return {
		Size = UDim2.new(1, 0, 1, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical
	}, {
		XButton = import.make(model),
		Topbar = import.make(basic.EmptyList, {
			Size = UDim2.new(1, 0, 0.1, 0),
			Padding = UDim.new(0.055, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		}, import2.mapArr({ "Explode", "Blind", "Scare" }, function(p, id)
			return p, import.make(model2, {
				Id = id
			})
		end))
	}
end

local model4 = import.model("ScreenGui", basic.Ui)

function model4.init()
	return {
		Name = "TrollMenu",
		Scale = 0.7,
		AspectRatio = 1.777,
		Location = "Center",
		Content = {
			Main = import.make(model3)
		}
	}
end

return {
	TrollMenu = model4
}