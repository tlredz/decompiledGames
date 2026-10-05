local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.KeybindHints)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local info = faye.Info(0.18)
local info2 = faye.Info(0.15)
local font = Font.new(gameSettings.preferedFont.Family, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local uDim = UDim.new(0.35, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function partsOf(value)
	if typeof(value) == "string" then
		return { value }
	end

	return value
end

return function(object, value, data)
	local rowHeight = data.RowHeight
	local v = partsOf(value) -- equivalent call inferred; original call site unknown
	local size = object:Value(UDim2.fromOffset(0, rowHeight))
	return object:Create("Frame")({
		Name = "Hint",
		Size = size,
		BackgroundTransparency = 1,
		CleanDelay = info2.Time,
		object:Create("CanvasGroup")({
			Name = "Group",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = object:Animation(UDim2.fromScale(0.5, 0.5), info, {
				From = UDim2.fromScale(0.5 + 0.075 * (data.SlideDirection or 1), 0.5)
			}),
			Size = UDim2.new(1, 24, 1, 24),
			BackgroundTransparency = 1,
			GroupTransparency = object:Animation(0, info, {
				From = 1
			}),
			OnClean = {
				Position = object:Animation(UDim2.fromScale(0.5 + 0.075 * (data.SlideDirection or 1), 0.5), info2),
				GroupTransparency = object:Animation(1, info2)
			},
			object:Create("Frame")({
				Name = "Pill",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -24, 1, -24),
				BackgroundColor3 = Color3.new(),
				BackgroundTransparency = 0.8,
				object:Create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				}),
				object:Create("UIShadow")({
					BlurRadius = uDim,
					Transparency = 0.6
				}),
				object:Create("UIPadding")({
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10)
				}),
				object:Create("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 1),
					AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
						size:Set(UDim2.fromOffset(point.X + 20, rowHeight))
					end
				}),
				object:Iterate(v, function(layoutOrder: number, value3, object2)
					if typeof(value3) == "table" and value3.Bind ~= nil then
						value3 = InputHandler.KeyLabel(value3.Bind) or value3.Bind
					end

					if typeof(value3) == "string" then
						return object2:Create("TextLabel")({
							Name = "Text",
							LayoutOrder = layoutOrder,
							Size = UDim2.new(0, 0, 1, 0),
							AutomaticSize = Enum.AutomaticSize.X,
							BackgroundTransparency = 1,
							Text = value3,
							TextSize = rowHeight - 5,
							FontFace = font,
							TextColor3 = Color3.new(1, 1, 1),
							TextXAlignment = data.TextXAlignment or Enum.TextXAlignment.Left,
							CleanDelay = info2.Time,
							object2:Create("UIStroke")({
								Thickness = 1,
								Color = Color3.new(),
								Transparency = 0.85
							})
						})
					end

					if value3.Icon == nil then
						return object2:Create("Frame")({
							Name = value3.Key,
							LayoutOrder = layoutOrder,
							Size = UDim2.fromOffset(rowHeight, rowHeight),
							BackgroundTransparency = 1,
							CleanDelay = info2.Time,
							function(instance)
								instance:AddTag("UIkey")
							end
						})
					end

					return object2:Create("ImageLabel")({
						Name = "Icon",
						LayoutOrder = layoutOrder,
						Size = UDim2.fromOffset(rowHeight * 1.15, rowHeight * 1.15),
						BackgroundTransparency = 1,
						Image = BunchaIcons[value3.Icon] or "",
						CleanDelay = info2.Time
					})
				end)
			})
		})
	})
end