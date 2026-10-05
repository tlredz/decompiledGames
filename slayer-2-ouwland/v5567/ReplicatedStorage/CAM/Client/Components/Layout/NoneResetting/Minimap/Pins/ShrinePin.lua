local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local ShrineUnlock = require(ReplicatedStorage.CAM.Client.Modules.ShrineUnlock)
local MapSettings = require(ReplicatedStorage.CAM.Client.Modules.MapSettings)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
require(script.Parent.Types)
local color = Color3.new()
local info = faye.Info(0.15)
local info2 = faye.Info(0.2, Enum.EasingStyle.Back)
local uDim = UDim.new(1, 0)
local locked = BunchaIcons.Locked
local color2 = Color3.new(1, 1, 1)
local sourceSansBold = Enum.Font.SourceSansBold
local info3 = faye.Info(0.3)
return function(maid, data, p, p2)
	local value = maid:Value(Archives.IsUnlocked("Shrines", p.Name))
	maid:Add(Archives.Connect("Shrines", function(list)
		if table.find(list, p.Name) ~= nil then
			value:Set(true)
		end
	end))
	local value2 = maid:Value(false)
	local visible = MapSettings.Watch(maid, "ShrineNames")
	local visible2 = MapSettings.Watch(maid, "ShrineIcons")
	local point = data.Point(p.Position)
	local v3 = data.Side * 0.66
	return maid:Create("Frame")({
		Name = p.Name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(point.X, point.Y),
		Size = UDim2.fromOffset(data.Side, data.Side),
		Rotation = -data.Rotation,
		BackgroundTransparency = 1,
		maid:Create("ImageLabel")({
			Name = "Icon",
			Visible = visible2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.32, 1.32),
			BackgroundTransparency = 1,
			Image = "rbxassetid://87391380841973",
			maid:Create("UIShadow")({
				Color = color,
				Transparency = maid:Do(function(callback)
					return maid:Animation(callback(value2) and 0.15 or 0.5, info)
				end),
				BlurRadius = uDim
			}),
			maid:Create("UIScale")({
				Scale = maid:Do(function(callback)
					return maid:Animation(callback(value2) and 1.2 or 1, info2)
				end)
			})
		}),
		maid:Create("TextButton")({
			Name = "Hitbox",
			ZIndex = 2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.98, 1.98),
			BackgroundTransparency = 1,
			Visible = p2.Clickable,
			function(parent)
				local frame = Instance.new("Frame")
				frame.Name = "NoSelection"
				frame.BackgroundTransparency = 1
				frame.Size = UDim2.new()
				frame.Parent = parent
				parent.SelectionImageObject = frame
			end,
			MouseButton1Click = function()
				if value:Get() then
					ShrineUnlock.Travel(p.Name, p2.OnTravel)
				else
					ShrineUnlock.Ask(p.Name)
				end
			end,
			MouseEnter = function()
				value2:Set(true)
			end,
			MouseLeave = function()
				value2:Set(false)
			end
		}),
		maid:Create("Frame")({
			Name = "Label",
			Visible = visible,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, -0.010000000000000037),
			Size = UDim2.fromOffset(0, v3),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			maid:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 3)
			}),
			maid:State(function(callback, object)
				if callback(value) then
					return
				else
					return object:Create("ImageLabel")({
						Name = "Lock",
						LayoutOrder = 1,
						Size = UDim2.fromScale(0.8, 0.8),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						BackgroundTransparency = 1,
						Image = locked,
						ImageColor3 = color2,
						object:Create("UIShadow")({
							Color = color,
							Transparency = 0.5,
							BlurRadius = uDim
						}),
						CleanDelay = info3.Time,
						OnClean = function()
							return {
								ImageTransparency = object:Animation(1, info3)
							}
						end
					})
				end
			end),
			maid:Create("TextLabel")({
				Name = "Name",
				LayoutOrder = 2,
				Size = UDim2.fromOffset(0, v3),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = "Shrine",
				TextSize = v3 * 0.8,
				Font = sourceSansBold,
				TextColor3 = color2,
				maid:Create("UIStroke")({
					Thickness = 2,
					Color = Color3.new()
				}),
				maid:Create("UIShadow")({
					Color = color,
					Transparency = 0.5,
					BlurRadius = uDim
				})
			})
		})
	})
end