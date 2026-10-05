local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local faye = require(ReplicatedStorage.Packages.faye)
local color = Color3.new(0.15, 0.15, 0.15)
local color2 = Color3.fromRGB(155, 208, 255)
local color3 = Color3.new(0.87, 0.87, 0.87)
local info = faye.Info(0.15)
local rbxassetfontsfamiliesSourceSansProjson = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.SemiBold,
	Enum.FontStyle.Normal
)
local springInfo = faye.SpringInfo(0.3, 1, 0.5)
local info2 = faye.Info(0.3)
local info3 = faye.Info(0.2)
local info4 = faye.Info(0.125)

local function optionBars(object, p: number, count: number)
	local v = p == 1
	local v2 = p == count

	if v and v2 then
		return object:Create("Frame")({
			Size = UDim2.fromScale(1, 1),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		})
	end

	if v or v2 then
		return { object:Create("Frame")({
				Size = UDim2.fromScale(1, 1),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				})
			}), object:Create("Frame")({
				Size = UDim2.fromScale(1, 0.5),
				Position = UDim2.fromScale(0, v and 0.5 or 0)
			}) }
	end

	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 1)
	})
end

return function(object, object2, list, options)
	local v = options or {}
	local zIndex = v.ZIndex or 3

	-- equivalent calls inferred from this helper; original call sites unknown
	local function labelOf(p)
		for _, v2 in list do
			if v2.Value == p then
				return v2.Label
			end
		end

		return ""
	end

	local value = object:Value(false)
	local v3 = labelOf(object2:Get()) -- equivalent call inferred; original call site unknown
	local text = object:Value(v3)
	object:Connect(object2.Changed, function()
		local v6 = labelOf(object2:Get()) -- equivalent call inferred; original call site unknown
		text:Set(v6)
		value:Set(false)
	end)
	local value3 = object:Value(color)
	local value4 = object:Value(Color3.new(1, 1, 1))
	object:Connect(value.Changed, function()
		if value:Get() then
			value3:Set(Color3.new(1, 1, 1))
			value4:Set(Color3.new())
		else
			value3:Reset()
			value4:Reset()
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function allowed()
		return v.CanClick == nil or v.CanClick()
	end

	return object:Create("Frame")({
		Name = "Dropdown",
		AnchorPoint = v.AnchorPoint,
		Position = v.Position,
		Size = v.Size or UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = zIndex,
		object:Create("TextButton")({
			Name = "Pill",
			AutoButtonColor = false,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = object:Animation(value3, info),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				Transparency = 0.8
			}),
			object:Create("TextLabel")({
				Name = "Label",
				Text = text,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.08, 0.5),
				Size = UDim2.fromScale(0.7, 0.55),
				BackgroundTransparency = 1,
				TextColor3 = object:Animation(value4, info),
				Font = Enum.Font.SourceSansSemibold,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			object:Create("Frame")({
				Name = "ChevronCell",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.3, 1),
				BackgroundTransparency = 1,
				object:Create("ImageLabel")({
					Name = "Chevron",
					Image = BunchaIcons.ServerBrowser.Dropdown,
					ImageColor3 = object:Animation(value4, info),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					ScaleType = Enum.ScaleType.Fit
				})
			}),
			MouseButton1Click = function()
				if not allowed() then
					return
				end

				ScreenEffects.CircleClick()
				value:Set(not value:Get())
			end
		}),
		object:State(function(callback, object3)
			if not callback(value) then
				return nil
			end

			local count = #list
			return object3:Create("Frame")({
				Name = "Options",
				Position = UDim2.fromScale(0, 1.1),
				Size = UDim2.new(1, 0, 0, count * 25),
				BackgroundTransparency = 1,
				ZIndex = zIndex + 1,
				object3:Create("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center
				}),
				object3:Iterate(list, function(layoutOrder: number, p2, object4)
					local flag = false
					local value5 = object4:Value(0)
					local value6 = object4:Value(Color3.new(1, 1, 1))
					local value7 = object4:Value(Color3.new())

					local function updPlate()
						if object2:Get() == p2.Value then
							value6:Set(color2)
							value7:Set(Color3.new())
							value5:Set(0)
						elseif flag then
							value6:Set(color3)
							value7:Set(Color3.new())
							value5:Set(0)
						else
							value6:Reset()
							value7:Reset()
							value5:Reset()
						end
					end

					object4:Connect(object2.Changed, updPlate)
					updPlate()
					return object4:Create("TextButton")({
						Name = p2.Label,
						AutoButtonColor = false,
						LayoutOrder = layoutOrder,
						Size = object4:Animation(UDim2.new(1, 0, 0, 25), springInfo, {
							From = UDim2.new(1, 0, 0, 8.75)
						}),
						BackgroundTransparency = 1,
						ZIndex = zIndex + 2,
						ClipsDescendants = true,
						OnClean = function(object5)
							return {
								Size = object5:Animation(UDim2.new(1, 0, 0, 0), info4)
							}
						end,
						object4:Create("CanvasGroup")({
							Name = "Bg",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							GroupColor3 = object4:Animation(value6, info3),
							GroupTransparency = object4:Animation(value5, info3),
							optionBars(object4, layoutOrder, count)
						}),
						object4:Create("TextLabel")({
							Name = "Txt",
							Text = p2.Label,
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 0.8),
							BackgroundTransparency = 1,
							ZIndex = zIndex + 3,
							TextColor3 = object4:Animation(value7, info3),
							TextTransparency = object4:Animation(0, info2, {
								From = 1
							}),
							FontFace = rbxassetfontsfamiliesSourceSansProjson,
							TextSize = 20
						}),
						MouseEnter = function()
							flag = true
							updPlate()
						end,
						MouseLeave = function()
							flag = false
							updPlate()
						end,
						MouseButton1Click = function()
							if not allowed() then
								return
							end

							ScreenEffects.CircleClick()
							object2:Set(p2.Value)
						end
					})
				end)
			})
		end)
	})
end