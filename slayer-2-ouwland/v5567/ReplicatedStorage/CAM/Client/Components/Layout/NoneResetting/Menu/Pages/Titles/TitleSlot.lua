local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local faye = require(ReplicatedStorage.Packages.faye)
local sourceSansBold = Enum.Font.SourceSansBold
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0, 0, 0)
local color3 = Color3.new(0.25, 0.25, 0.25)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(1, 1, 1)
local color6 = Color3.new(0, 0, 0)
local info = faye.Info(0.25)
return function(object, object2, p, text: string, object3)
	local function heldOf(callback)
		local v = callback(p) or ""
		local v2

		if v ~= "" then
			v2 = Titles.Get(v)
		end

		if v2 == nil then
			return ""
		end

		return v2.displayName
	end

	local v = {
		BgColor = object:Value(color3),
		BgTransparency = object:Value(0.5),
		TextColor3 = object:Value(color4),
		StrokeColor = object:Value(color5),
		LabelTransparency = object:Value(0.5)
	}
	local space = object:Space(function(data)
		if object2:Compare(p.Name) then
			data.BgColor:Set(color)
			data.BgTransparency:Set(0)
			data.TextColor3:Set(color2)
			data.StrokeColor:Set(color6)
			data.LabelTransparency:Set(0)
		else
			data.BgColor:Reset()
			data.BgTransparency:Reset()
			data.TextColor3:Reset()
			data.StrokeColor:Reset()
			data.LabelTransparency:Reset()
		end
	end)
	space:Connect(object2.Changed)
	space:Add(v, object, true):Call()
	local value = object:Value(0)
	local size = object:Value(UDim2.new(0, 0, 1, 0))

	local function textSizeOf(callback)
		return callback(value) * 0.85
	end

	return object:Create("Frame")({
		Name = p.Name,
		Size = size,
		AbsoluteSizeOnChangedInit = function(_, point: Vector2)
			value:Set(point.Y)
		end,
		BackgroundColor3 = object:Animation(v.BgColor, info),
		BackgroundTransparency = object:Animation(v.BgTransparency, info),
		object:Create("UICorner")({
			CornerRadius = UDim.new(1, 0)
		}),
		object:Create("UIStroke")({
			Color = object:Animation(v.StrokeColor, info),
			BorderOffset = UDim.new(0, -3),
			Transparency = 0.825,
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0.4)
				}),
				Rotation = 45
			})
		}),
		object:Create("TextLabel")({
			Name = "SlotLabel",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(10, 0.65),
			BackgroundTransparency = 1,
			Text = text,
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = object:Animation(v.LabelTransparency, info)
		}),
		object:Create("TextButton")({
			Size = UDim2.fromScale(1.2, 1.2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			MouseButton1Click = function()
				if object3:Get() == "" then
					return
				end

				ScreenEffects.CircleClick()
				object2:Set(object2:Compare(p.Name) and "" or p.Name)
			end,
			BackgroundTransparency = 1
		}),
		object:Create("Frame")({
			Name = "Content",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
					size:Set(UDim2.new(0, point.X, 1, 0))
				end
			}),
			object:Create("Frame")({
				Name = "LeftPad",
				LayoutOrder = 0,
				Size = UDim2.fromScale(0.3, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1
			}),
			object:Create("TextLabel")({
				Name = "ResultName",
				LayoutOrder = 2,
				TextSize = object:Do(textSizeOf),
				Size = object:Do(function(callback)
					local v2 = callback(value) * 0.85
					local v4 = callback(p) or ""
					local v5

					if v4 ~= "" then
						v5 = Titles.Get(v4)
					end

					local X = TextService:GetTextSize(
						v5 == nil and "" or v5.displayName,
						v2,
						sourceSansBold,
						Vector2.new(100000, 100000)
					).X
					return UDim2.fromOffset(X, v2)
				end),
				BackgroundTransparency = 1,
				Font = sourceSansBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = object:Animation(v.TextColor3, info),
				Text = object:Do(heldOf),
				object:Create("UIGradient")({
					Color = object:Do(function(callback)
						local v2 = callback(p) or ""

						if v2 == "" or Titles.Get(v2) == nil then
							return (ColorSequence.new(Color3.new(1, 1, 1)))
						end

						return (Titles.GetColor(v2))
					end),
					Rotation = -90
				})
			}),
			object:Create("Frame")({
				Name = "EmptySpace",
				LayoutOrder = 2,
				Visible = object:Do(function(callback)
					local v2 = callback(p) or ""
					local v3

					if v2 ~= "" then
						v3 = Titles.Get(v2)
					end

					return (v3 == nil and "" or v3.displayName) == ""
				end),
				Size = UDim2.fromScale(2.4, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1
			}),
			object:Create("Frame")({
				Name = "RightPad",
				LayoutOrder = 3,
				Size = UDim2.fromScale(0.3, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1
			})
		})
	})
end