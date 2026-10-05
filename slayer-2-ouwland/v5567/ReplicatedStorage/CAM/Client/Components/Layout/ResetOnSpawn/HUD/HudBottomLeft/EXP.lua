local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Multipliers = require(ReplicatedStorage.CAM.Global.Multipliers)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
return function(object, _, p)
	local v = (p == nil or p.Scale == nil) and 1 or p.Scale
	local v2 = (p == nil or p.Down == nil) and 0 or p.Down
	local data = Utility.GetData(game.Players.LocalPlayer, true)
	local rotation = object:Value(0)

	local function upd()
		rotation:Set(23 + data.Exp.Current.Value / data.Exp.Goal.Value * 135)
	end

	rotation:Set(23 + data.Exp.Current.Value / data.Exp.Goal.Value * 135)
	object:Connect(data.Exp.Current.Changed, upd)
	return object:Create("Frame")({
		Name = "ExpFrame",
		Size = UDim2.fromScale(0.6 * v, 0.6 * v),
		AnchorPoint = Vector2.new(0, 1),
		object:Create("UIAspectRatioConstraint")({}),
		Position = UDim2.fromScale(0.05, 0.65 + v2),
		BackgroundTransparency = 1,
		object:Create("ImageLabel")({
			Name = "Bg",
			Image = "rbxassetid://128184210513075",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ImageColor3 = Color3.new(0.1, 0.1, 0.1)
		}),
		object:Create("ImageLabel")({
			Name = "Fg",
			Image = "rbxassetid://89591198478041",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ImageColor3 = gameSettings.lvlColor,
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.49, 1),
					NumberSequenceKeypoint.new(0.51, 0),
					NumberSequenceKeypoint.new(1, 0)
				}),
				Rotation = rotation
			})
		}),
		object:Create("Frame")({
			Name = "Context",
			Size = UDim2.fromScale(1, 0.5),
			Position = UDim2.fromScale(0.25, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			BackgroundColor3 = Color3.new(),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.8, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			object:Create("TextLabel")({
				Name = "Exp",
				Position = UDim2.fromScale(0.075, 0.2),
				Size = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Text = object:Do(function(callback)
					local v3 = callback(data.Exp.Current)
					local v4 = callback(data.Exp.Goal)
					local levelCostFactor = Multipliers.LevelCostFactor((math.floor(v4 / gameSettings.expPerLevel)))
					return math.round(v3 / levelCostFactor) .. " / " .. math.round(v4 / levelCostFactor)
				end),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = true,
				Font = Enum.Font.GothamBold,
				TextColor3 = gameSettings.lvlColor,
				object:Create("UIStroke")({
					Thickness = 1,
					Transparency = 0.5
				})
			}),
			object:Create("TextLabel")({
				Name = "Level",
				Position = UDim2.fromScale(0.075, 0.66),
				Size = UDim2.fromScale(1, 0.6),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Text = object:Do(function(callback)
					return "Lv " .. math.floor(callback(data.Exp.Goal) / gameSettings.expPerLevel)
				end),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = true,
				Font = Enum.Font.GothamBold,
				TextColor3 = Color3.new(1, 1, 1),
				object:Create("UIStroke")({
					Thickness = 2,
					Transparency = 0.5
				})
			})
		})
	})
end