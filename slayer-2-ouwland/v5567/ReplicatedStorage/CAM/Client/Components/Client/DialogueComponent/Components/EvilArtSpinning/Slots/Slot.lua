local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local faye = require(ReplicatedStorage.Packages.faye)
local sourceSansBold = Enum.Font.SourceSansBold
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0, 0, 0)
local color3 = Color3.new()
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(1, 1, 1)
local color6 = Color3.new(0, 0, 0)
local info = faye.Info(0.25)
return function(object, object2, p)
	local function iconOf(p2: string?)
		local v

		if p2 ~= nil then
			v = DemonArts[p2]
		end

		return v ~= nil and v.Icon or ""
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function heldOf(callback)
		return callback(p) or ""
	end

	local image = object:Do(function(callback)
		local v2 = heldOf(callback) -- equivalent call inferred; original call site unknown
		local v3

		if v2 ~= nil then
			v3 = DemonArts[v2]
		end

		return v3 ~= nil and v3.Icon or ""
	end)
	local v2 = {
		BgColor = object:Value(color3),
		BgTransparency = object:Value(0.6),
		TextColor3 = object:Value(color4),
		StrokeColor = object:Value(color5)
	}
	local space = object:Space(function(data)
		if object2:Compare(p.Name) then
			data.BgColor:Set(color)
			data.BgTransparency:Set(0)
			data.TextColor3:Set(color2)
			data.StrokeColor:Set(color6)
		else
			data.BgColor:Reset()
			data.BgTransparency:Reset()
			data.TextColor3:Reset()
			data.StrokeColor:Reset()
		end
	end)
	space:Connect(object2.Changed)
	space:Add(v2, object, true):Call()
	local value = object:Value(0)
	local size = object:Value(UDim2.new(0, 0, 1, 0))

	local function textSizeOf(callback)
		return callback(value) * 0.45
	end

	return object:Create("Frame")({
		Name = p.Name,
		Size = size,
		AbsoluteSizeOnChangedInit = function(_, point: Vector2)
			value:Set(point.Y)
		end,
		BackgroundColor3 = object:Animation(v2.BgColor, info),
		BackgroundTransparency = object:Animation(v2.BgTransparency, info),
		object:Create("UICorner")({
			CornerRadius = UDim.new(1, 0)
		}),
		object:Create("UIStroke")({
			Color = object:Animation(v2.StrokeColor, info),
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
		object:Create("TextButton")({
			Size = UDim2.fromScale(1.2, 1.2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			MouseButton1Click = function()
				ScreenEffects.CircleClick()
				object2:Set(p.Name)
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
				Visible = object:Do(function(callback)
					local v3 = heldOf(callback) -- equivalent call inferred; original call site unknown

					if v3 == "" then
						return false
					else
						local v5

						if v3 ~= nil then
							v5 = DemonArts[v3]
						end

						return (v5 ~= nil and v5.Icon or "") == ""
					end
				end),
				Size = UDim2.fromScale(0.3, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1
			}),
			object:Create("Frame")({
				Name = "IconSlot",
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Visible = object:Do(function(callback)
					local v3 = heldOf(callback) -- equivalent call inferred; original call site unknown

					if v3 == "" then
						return true
					else
						local v5

						if v3 ~= nil then
							v5 = DemonArts[v3]
						end

						return (v5 ~= nil and v5.Icon or "") ~= ""
					end
				end),
				object:Create("ImageLabel")({
					Name = "Icon",
					Visible = object:Do(function(callback)
						local v3 = heldOf(callback) -- equivalent call inferred; original call site unknown
						local v4

						if v3 ~= nil then
							v4 = DemonArts[v3]
						end

						return (v4 ~= nil and v4.Icon or "") ~= ""
					end),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.7, 0.7),
					BackgroundTransparency = 1,
					Image = image,
					object:Create("UIShadow")({
						BlurRadius = UDim.new(1, 0),
						Offset = UDim2.fromScale(0.05, 0.05),
						Transparency = 0.65
					})
				})
			}),
			object:Create("TextLabel")({
				Name = "ResultName",
				LayoutOrder = 2,
				TextSize = object:Do(textSizeOf),
				Size = object:Do(function(callback)
					local v3 = callback(value) * 0.45
					local X = TextService:GetTextSize(
						callback(p) or "",
						v3,
						sourceSansBold,
						Vector2.new(100000, 100000)
					).X
					return UDim2.fromOffset(X, v3)
				end),
				BackgroundTransparency = 1,
				Font = sourceSansBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = object:Animation(v2.TextColor3, info),
				Text = object:Do(heldOf)
			}),
			object:Create("Frame")({
				Name = "RightPad",
				LayoutOrder = 3,
				Visible = object:Do(function(callback)
					return (callback(p) or "") ~= ""
				end),
				Size = UDim2.fromScale(0.3, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1
			})
		})
	})
end