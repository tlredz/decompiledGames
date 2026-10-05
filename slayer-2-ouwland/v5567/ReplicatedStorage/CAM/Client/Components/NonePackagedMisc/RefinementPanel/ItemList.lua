local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PageBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.PageBrowser)
require(ReplicatedStorage.Packages.faye)
local ItemRow = require(script.Parent.ItemRow)
require(script.Parent.Types)
local v = {
	"All",
	"Weapons",
	"Gear",
	"Rods"
}
return function(object, data)
	return object:Create("Frame")({
		Name = "ItemList",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "Chips",
			Size = UDim2.fromScale(1, 0.07),
			BackgroundTransparency = 1,
			PageBrowser(object, data.Filter, v, {
				Key = function(_, p)
					return p
				end,
				Label = function(_, p)
					return p
				end,
				CanClick = function()
					return data.Busy:Get() ~= true
				end,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0, 0),
				TabSize = UDim2.fromScale(0.23, 0.8),
				Padding = UDim.new(0.025, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				TextXAlignment = Enum.TextXAlignment.Center,
				Backdrop = false
			})
		}),
		object:Create("ScrollingFrame")({
			Name = "Rows",
			Position = UDim2.fromScale(0, 0.09),
			Size = UDim2.fromScale(1, 0.91),
			BackgroundTransparency = 1,
			ScrollBarThickness = 3,
			ScrollBarImageTransparency = 0.5,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			object:Create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			}),
			object:Create("UIPadding")({
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6)
			}),
			object:Iterate(data.Rows, function(p: number, p2, p3)
				return ItemRow(p3, p2, p, data.Selected, data.Busy)
			end),
			object:State(function(callback, object2)
				if #callback(data.Rows) > 0 then
					return
				end

				local v2 = callback(data.Filter)
				return object2:Create("TextLabel")({
					LayoutOrder = 0,
					Size = UDim2.new(1, 0, 0, 60),
					BackgroundTransparency = 1,
					Text = v2 == "All" and "Nothing refinable yet." or `No {string.lower(v2)} to refine.`,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0.5,
					object2:Create("UITextSizeConstraint")({
						MaxTextSize = 16
					})
				})
			end)
		})
	})
end