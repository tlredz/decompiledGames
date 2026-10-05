local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local LRPointer = require(script.Parent.Buttons.LRPointer)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.4)
return function(parent2, p2, p3, callback)
	local v = p2 == nil
	local v2 = p2 or faye.new()
	local text = p3 or v2:Value("Player2")
	local v4 = callback or function(_: number) end
	v2:Create("CanvasGroup")({
		Parent = parent2,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1.075),
		Size = UDim2.fromScale(0.3, 0.2),
		BackgroundTransparency = 1,
		GroupTransparency = v2:Animation(0, info, {
			From = 1
		}),
		OnClean = function(animator, instance)
			local uIShadow = instance:FindFirstChildOfClass("UIShadow")

			if uIShadow ~= nil then
				animator:LoadAnimation(uIShadow, {
					Transparency = 1
				}, info):Play()
			end

			return {
				GroupTransparency = animator:Animation(1, info)
			}
		end,
		v2:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		v2:Create("UIShadow")({
			BlurRadius = UDim.new(0.8, 0),
			Transparency = v2:Animation(0, info, {
				From = 1
			})
		}),
		v2:Create("Frame")({
			Name = "holder",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.3),
			Size = UDim2.fromScale(0.4, 0.2),
			BackgroundTransparency = 1,
			v2:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.2, 0),
				SortOrder = Enum.SortOrder.Name
			}),
			v2:Create("Frame")({
				Name = "ALeft",
				Size = UDim2.fromScale(0.75, 0.75),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundTransparency = 1,
				LRPointer(v2, 180, function()
					v4(-1)
				end),
				Utility.AddTag(v2:Create("Frame")({
					Name = "Spectate_Prev",
					BackgroundTransparency = gameSettings.KeybindTextTransparency,
					AnchorPoint = Vector2.new(1, 0.5),
					Size = UDim2.fromOffset(20, 20),
					Position = UDim2.new(-0.2, 0, 0.5, 0),
					ZIndex = -1,
					Instance.new("UIAspectRatioConstraint")
				}), "UIkey")
			}),
			v2:Create("Frame")({
				Name = "CRight",
				Size = UDim2.fromScale(0.75, 0.75),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundTransparency = 1,
				LRPointer(v2, 0, function()
					v4(1)
				end),
				Utility.AddTag(v2:Create("Frame")({
					Name = "Spectate_Next",
					BackgroundTransparency = gameSettings.KeybindTextTransparency,
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.fromOffset(20, 20),
					Position = UDim2.new(1.2, 0, 0.5, 0),
					ZIndex = -1,
					Instance.new("UIAspectRatioConstraint")
				}), "UIkey")
			}),
			v2:Create("Frame")({
				Name = "CName",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				v2:Create("TextLabel")({
					Size = UDim2.fromScale(100, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					TextXAlignment = Enum.TextXAlignment.Center,
					TextScaled = true,
					Text = text,
					BackgroundTransparency = 1,
					Font = Enum.Font.SourceSansSemibold,
					TextColor3 = Color3.new(1, 1, 1),
					TextBoundsOnChangedInit = function(p4, p5)
						local parent = p4.Parent.Parent
						parent.Size = UDim2.new(p5.X / parent.Parent.AbsoluteSize.X, 0, parent.Size.Y.Scale)
					end,
					v2:Create("UIStroke")({
						Thickness = 2,
						v2:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.4),
								NumberSequenceKeypoint.new(1, 0.7)
							}),
							Rotation = -90
						})
					})
				})
			})
		})
	})
	return function()
		if v then
			v2:Destroy()
		end
	end
end