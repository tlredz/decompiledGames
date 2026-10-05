local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local color = Color3.new(1, 0.121569, 0.121569)
local color2 = Color3.new(0.435294, 1, 0.435294)
local info = faye.Info(0.3)
return function(parent, udim: UDim2?, point: Vector2?)
	local v = faye.new()
	local value = v:Value(1)
	local value2 = v:Value(0)
	local position = v:Value(udim or UDim2.fromScale(0.1, 0.25))
	v:Create("CanvasGroup")({
		Parent = parent,
		GroupTransparency = v:Animation(0, info, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = v:Animation(1, info)
			}
		end,
		AnchorPoint = point or Vector2.new(0, 0.5),
		Size = UDim2.fromScale(0.2, 0.2),
		Position = position,
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1,
		v:Create("ImageLabel")({
			Size = UDim2.fromScale(1, 1),
			Image = "rbxassetid://123372383123665",
			ImageColor3 = Color3.new(0.15, 0.15, 0.15),
			BackgroundTransparency = 1,
			ImageTransparency = 0.4
		}),
		v:Create("Frame")({
			Size = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			ClipsDescendants = true,
			ZIndex = 2,
			BackgroundTransparency = 1,
			v:Create("ImageLabel")({
				Size = UDim2.fromScale(2, 1),
				BackgroundTransparency = 1,
				ImageColor3 = v:Do(function(callback, _, _)
					local v2 = callback(value)

					if callback(value2) == 1 and v2 >= 0.65 then
						local v3 = 1 - (1 - v2) / 0.35
						position:Set(position.Initial + UDim2.fromOffset(
							math.random(-10, 10) * v3,
							math.random(-10, 10) * v3
						))
					end

					return Utility.Lerp_Color2(color2, color, v2)
				end),
				Image = "rbxassetid://70625589865840",
				v:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.499, 0),
						NumberSequenceKeypoint.new(0.501, 1),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = v:Do(function(callback, _, _)
						return (math.clamp(callback(value) * 360 - 180, 0, 180))
					end)
				})
			})
		}),
		v:Create("Frame")({
			Size = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ClipsDescendants = true,
			ZIndex = 2,
			BackgroundTransparency = 1,
			v:Create("ImageLabel")({
				Size = UDim2.fromScale(2, 1),
				Position = UDim2.fromScale(-1, 0),
				BackgroundTransparency = 1,
				ImageColor3 = v:Do(function(callback, _, _)
					return Utility.Lerp_Color2(color2, color, callback(value))
				end),
				Image = "rbxassetid://70625589865840",
				v:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.499, 1),
						NumberSequenceKeypoint.new(0.501, 0),
						NumberSequenceKeypoint.new(1, 0)
					}),
					Rotation = v:Do(function(callback, _, _)
						return (math.clamp(callback(value) * 360, 0, 180))
					end)
				})
			})
		})
	})
	return function()
		v:Destroy()
	end, value, value2
end