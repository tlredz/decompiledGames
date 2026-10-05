local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
local state = require(script.Parent.Parent.state)
local module = require("./gui")
return function(list)
	return module({
		name = list.name,
		core = true,
		ignoreGuiInset = true,
		vide.create("Frame")({
			BackgroundTransparency = 0.45,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			Name = list.name,
			Size = list.size,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Visible = function()
				return state.windowRoute() == list.name
			end,
			vide.create("UIAspectRatioConstraint")({
				AspectRatio = list.aspectRatio
			}),
			vide.create("UIStroke")({
				Thickness = 1,
				Transparency = 0.6,
				Color = Color3.fromRGB(93, 93, 93)
			}),
			table.unpack(list)
		})
	})
end