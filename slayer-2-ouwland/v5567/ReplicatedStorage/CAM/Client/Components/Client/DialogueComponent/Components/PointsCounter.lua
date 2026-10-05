local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local wen = ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.HudBottomRight.FirstVertical.Wen
local localPlayer = Players.LocalPlayer
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(1, 0.0745098, 0.0901961)
local info = faye.Info(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
return function(object)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function total()
		return tonumber(localPlayer:GetAttribute("RunPoints")) or 0
	end

	local value = object:Value(total())
	object:Connect(localPlayer:GetAttributeChangedSignal("RunPoints"), function()
		value:Set(total())
	end)
	local v = total() -- equivalent call inferred; original call site unknown
	local text = object:Value()
	local v2 = 0
	local UpdValue

	UpdValue = function(p: number, flag: boolean?)
		local v3 = math.random(1, 999)
		v2 = v3

		if flag then
			v = p
		elseif p ~= 0 then
			local v4 = math.sign(p)
			v += math.max(math.floor(math.abs(p) * 0.5), 1) * v4
		end

		text:Set(Utility.addCommasToNumber(v))

		if v ~= total() then
			task.delay(0.05, function()
				if v2 ~= v3 or not object.IsActive then
					return
				end

				UpdValue(total() - v)
			end)
		end
	end

	UpdValue(total(), true)
	local v3 = object:Create("Frame")({
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
			TextColor3 = color,
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
			local v4 = callback(value)

			if v == nil or v == v4 then
				if v ~= nil then
					v4 = v4 - v or v4
				end

				UpdValue(v4)
			else
				local v5 = v4 - v
				local textColor = color

				if math.sign(v5) < 0 then
					wen.Diplete:Play()
					textColor = color2
				else
					wen.Gain:Play()
				end

				local text2

				if v5 >= 0 then
					text2 = "+" .. Utility.addCommasToNumber(v5)
				else
					text2 = Utility.addCommasToNumber(v5)
				end

				UpdValue(v4 - v)
				return object2:SpecialThread(function(object3, _)
					return object3:Create("TextLabel")({
						Text = text2,
						Size = UDim2.fromScale(1, 1),
						Position = UDim2.fromScale(0, -1),
						BackgroundTransparency = 1,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Right,
						TextColor3 = textColor,
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
		Name = "PointsFrame",
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
			Size = UDim2.fromScale(0.975, 0.975),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = BunchaIcons.OuwigaharaPoints,
			ZIndex = 2
		}),
		v3
	})
end