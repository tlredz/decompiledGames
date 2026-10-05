local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2)
return function(object, p, p2)
	return object:Create("Frame")({
		Name = "bTimer",
		Size = UDim2.new(0.15, 0, 0, 25),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = object:Animation(0.5, info, {
			From = 1
		}),
		OnClean = function()
			return {
				BackgroundTransparency = object:Animation(1, info)
			}
		end,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.175),
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		object:Create("UIStroke")({
			Color = Color3.new(1, 1, 1),
			BorderOffset = UDim.new(0, -2),
			Transparency = object:Animation(0.8, info, {
				From = 1
			}),
			OnClean = function()
				return {
					Transparency = object:Animation(1, info)
				}
			end
		}),
		object:Create("TextLabel")({
			Size = UDim2.fromScale(100, 0.8),
			BackgroundTransparency = 1,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.SourceSansBold,
			TextTransparency = object:Animation(0, info, {
				From = 1
			}),
			TextStrokeTransparency = object:Animation(0.85, info, {
				From = 1
			}),
			OnClean = function()
				return {
					TextTransparency = object:Animation(1, info),
					TextStrokeTransparency = object:Animation(1, info)
				}
			end,
			Text = object:Do(function(callback, _, p3)
				local v = callback(p)

				if callback(p2) == true then
					p3.TextColor3 = Color3.new(1, 1, 1)
					return "Come back at night"
				end

				if v == nil or not (v > 0 and v < 10) then
					p3.TextColor3 = Color3.new(1, 1, 1)
				else
					p3.TextColor3 = Color3.new(1, 0.3, 0.3)
					ReplicatedStorage.Assets.Sounds.Misc.countDown.TimePosition = 0
					ReplicatedStorage.Assets.Sounds.Misc.countDown:Play()
				end

				return (`Spawns in {Utility.formatTime(v)}`)
			end),
			TextBoundsOnChangedInit = function(p3, p4)
				if p4.X <= 0 then
					return
				end

				p3.Parent.Size = UDim2.new(0, p4.X + 10, 0, p3.Parent.Size.Y.Offset)
			end,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5)
		})
	})
end