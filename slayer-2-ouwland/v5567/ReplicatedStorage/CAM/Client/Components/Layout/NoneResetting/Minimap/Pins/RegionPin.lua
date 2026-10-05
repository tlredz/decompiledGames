local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local MapSettings = require(ReplicatedStorage.CAM.Client.Modules.MapSettings)
require(script.Parent.Types)
local sourceSansBold = Enum.Font.SourceSansBold
local info = faye.Info(0.3)
local color = Color3.new()
local uDim = UDim.new(1, 0)
return function(maid, data, data2)
	local visible = MapSettings.Watch(maid, "AreaNames")
	local value = maid:Value(Archives.IsUnlocked("Regions", data2.Name))
	maid:Add(Archives.Connect("Regions", function(list)
		if table.find(list, data2.Name) ~= nil then
			value:Set(true)
		end
	end))
	local point = data.Point(data2.Position)
	local v2 = data.Side * 0.84 * (data2.Sub and 0.7 or 1)
	local v3 = data2.Stack * (data.Side * 0.84 + 2)
	local size = maid:Value(UDim2.fromOffset(0, v2))
	return maid:Create("Frame")({
		Name = data2.Name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(point.X, point.Y),
		Size = UDim2.fromOffset(data.Side, data.Side),
		Rotation = -data.Rotation,
		BackgroundTransparency = 1,
		maid:Create("TextLabel")({
			Name = "Label",
			Visible = visible,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, v3),
			Size = UDim2.fromOffset(12, v2),
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = v2 * 0.8,
			maid:Create("UIPadding")({
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6)
			}),
			BackgroundTransparency = 1,
			Text = maid:Do(function(callback)
				if callback(value) then
					return data2.Name
				end

				return "???"
			end),
			TextTransparency = maid:Do(function(callback)
				callback(value)
				return maid:Animation(0, info)
			end),
			Font = sourceSansBold,
			TextColor3 = Color3.new(1, 1, 1),
			maid:Create("UIStroke")({
				Thickness = 2,
				Color = Color3.new(),
				Transparency = 0
			}),
			ZIndex = 5,
			AbsoluteSizeOnChangedInit = function(_, point2: Vector2)
				size:Set(UDim2.fromOffset(point2.X, point2.Y))
			end
		}),
		maid:Create("Frame")({
			Name = "Plate",
			Visible = visible,
			ZIndex = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, v3),
			Size = size,
			BackgroundTransparency = 1,
			maid:Create("UIShadow")({
				Color = color,
				BlurRadius = uDim,
				Transparency = 0.6
			})
		})
	})
end