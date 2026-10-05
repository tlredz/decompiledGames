local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local faye = require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local wen = Utility.GetData(game.Players.LocalPlayer, true).Wen
local info = faye.Info(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Utility2 = require(ReplicatedStorage.CAM.Global.Utility)
return function(object, _)
	local value = wen.Value
	local text = object:Value()
	local v = 0
	local UpdValue

	UpdValue = function(p: number, flag: boolean?)
		local v2 = math.random(1, 999)
		v = v2

		if flag then
			value = p
		elseif p ~= 0 then
			local v3 = math.sign(p)
			value += math.max(math.floor(math.abs(p) * 0.5), 1) * v3
		end

		text:Set(value == 0 and "-" or Utility2.addCommasToNumber(value))

		if value ~= wen.Value then
			task.delay(0.05, function()
				if v ~= v2 or not object.IsActive then
					return
				end

				UpdValue(wen.Value - value)
			end)
		end
	end

	UpdValue(wen.Value, true)
	local v2 = object:Create("Frame")({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(-0.3, 0.5),
		Size = UDim2.fromScale(10, 0.85),
		BackgroundTransparency = 1,
		object:Create("TextLabel")({
			Name = "Txt",
			Size = UDim2.fromScale(1, 0.8),
			Text = text,
			BackgroundTransparency = 1,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = gameSettings.wenColor,
			FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
			object:Create("UIStroke")({
				Thickness = 2,
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					})
				})
			})
		}),
		object:Do(function(callback, object2, _)
			local v3 = callback(wen)

			if value == nil or value == v3 then
				if value ~= nil then
					v3 = v3 - value or v3
				end

				UpdValue(v3)
			else
				local v4 = v3 - value
				local wenColor = gameSettings.wenColor

				if math.sign(v4) < 0 then
					script.Diplete:Play()
					wenColor = Color3.new(1, 0.0745098, 0.0901961)
				else
					script.Gain:Play()
				end

				local text2

				if v4 >= 0 then
					text2 = "+" .. Utility2.addCommasToNumber(v4)
				else
					text2 = Utility2.addCommasToNumber(v4)
				end

				if value ~= nil then
					v3 = v3 - value or v3
				end

				UpdValue(v3)
				return object2:SpecialThread(function(object3, _)
					return object3:Create("TextLabel")({
						Text = text2,
						Size = UDim2.fromScale(1, 1),
						Position = UDim2.fromScale(0, -1),
						BackgroundTransparency = 1,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Right,
						TextColor3 = wenColor,
						TextTransparency = object3:Animation(1, info),
						FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
						object3:Create("UIStroke")({
							Thickness = 1,
							Transparency = object3:Animation(1, info, {
								From = 0.25
							})
						})
					})
				end, {
					Lifetime = 1
				})
			end
		end)
	})
	return object:Create("Frame")({
		Name = "WenFrame",
		Size = UDim2.fromScale(0.6, 0.6),
		AnchorPoint = Vector2.new(0, 1),
		object:Create("UIAspectRatioConstraint")({}),
		Position = UDim2.fromScale(0.05, 0.65),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "Bg",
			Size = UDim2.fromScale(3, 1),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			BackgroundColor3 = Color3.new(),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) }),
				Rotation = 180
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		}),
		object:Create("Frame")({
			Name = "InnerBg",
			Size = UDim2.new(3, -6, 1, -6),
			Position = UDim2.fromScale(-0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.5),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = 180
				})
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		}),
		object:Create("ImageLabel")({
			Name = "Icon",
			Size = UDim2.fromScale(1.5, 1.5),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = BunchaIcons.Wen,
			ZIndex = 2
		}),
		v2
	})
end