local import = _G.import("event")
local import2 = _G.import("romodel")
local import3 = _G.import("iterator")
local import4 = _G.import("iconData")
local import5 = _G.import("viewImports")
local basic = import5:get("basic")
local ux = import5:get("ux")
game:GetService("MarketplaceService")
local _ = game.Players.LocalPlayer
local v = {
	{
		Menu = "Inventory",
		Label = "Chairs",
		Tab = "Chair",
		Icon = "Chair"
	},
	{
		Menu = "Inventory",
		Label = "Pets",
		Tab = "Pet",
		Icon = "Pet"
	},
	{
		Menu = "Profile",
		Label = "Profile",
		Icon = "Head"
	}
}
local model = import2.model(basic.ImageButton, basic.Corner, ux.Button)

function model.init(p)
	return {
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(1.1, 0, 1.1, 0),
		CornerRadius = UDim.new(1, 0),
		MouseButton1Down = function()
			import.fire("openMenu", p.Menu, {
				PageId = p.Tab
			})
		end
	}
end

function model.prespawn(p)
	return nil, {
		Inner = import2.make(import2.wrap("ImageLabel", basic.Gradient, basic.Corner), {
			Location = "Center",
			CornerRadius = UDim.new(1, 0),
			Size = UDim2.new(0.9, 0, 0.9, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Image = "rbxassetid://120822935454304",
			GradientColor = ColorSequence.new(Color3.fromRGB(8, 234, 255), Color3.fromRGB(255, 1, 103)),
			GradientRotation = 90
		}, {
			Image = import2.make(basic.ImageLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.52, 0, 0.49, 0),
				Scale = 1,
				Image = import4[p.Icon]
			}),
			Text = import2.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.9, 0),
				Size = UDim2.new(0.96, 0, 0.35, 0),
				Text = p.Label,
				StrokeWidth = 3,
				ZIndex = 2
			})
		})
	}
end

function model:despawn()
	self.Con = false
end

local model2 = import2.model(basic.EmptyList)

function model2.init()
	return {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0.84, 0),
		Size = UDim2.new(1, 0, 1, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0.07, 0)
	}, import3.mapArr(v, function(p, p2)
		return p, import2.make(model, p2)
	end)
end

local model3 = import2.model("ScreenGui", basic.Ui)

function model3.init()
	return {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Name = "RightBar",
		Scale = 0.23,
		AspectRatio = 3,
		MaxSize = 400,
		MinSize = 55,
		Location = "BottomCenter",
		Content = {
			Main = import2.make(model2)
		}
	}
end

return {
	BottomRightBar = model3
}