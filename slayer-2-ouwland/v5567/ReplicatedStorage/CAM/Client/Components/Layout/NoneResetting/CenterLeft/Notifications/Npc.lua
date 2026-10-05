local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local textplus = require(ReplicatedStorage.Packages.textplus)
local info = faye.Info(0.3, Enum.EasingStyle.Back)
local info2 = faye.Info(0.1, Enum.EasingStyle.Linear)
local info3 = faye.Info(0.2, Enum.EasingStyle.Back)
return function(object, data)
	if object == nil then
		return
	else
		return object:SpecialThread(function(object2, _)
			local pS2npcshout = script.PS2npcshout

			if data ~= nil and data.Sound ~= nil then
				pS2npcshout = ReplicatedStorage.Assets.Sounds:QueryDescendants((`Sound#{data.Sound}`))[1] or pS2npcshout
			end

			pS2npcshout.TimePosition = 0
			pS2npcshout:Play()
			return object2:Create("Frame")({
				Name = "NpcNotification",
				Size = UDim2.new(1, 0, 0, 58),
				BackgroundTransparency = 1,
				CleanDelay = info2.Time,
				object2:Create("CanvasGroup")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					object2:Create("Frame")({
						Size = UDim2.fromScale(1, 1),
						Name = "Bg",
						ZIndex = 0,
						BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
						object2:Create("UICorner")({
							CornerRadius = UDim.new(1)
						}),
						object2:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 1)
							})
						}),
						object2:Create("UIStroke")({
							BorderOffset = UDim.new(0, -2),
							Color = Color3.new(1, 1, 1),
							object2:Create("UIGradient")({
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.5),
									NumberSequenceKeypoint.new(1, 1)
								})
							})
						})
					}),
					object2:Create("Frame")({
						Size = UDim2.new(1, -4, 1, -2),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						Name = "ActualHolder",
						object2:Create("UIListLayout")({
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							FillDirection = Enum.FillDirection.Horizontal
						}),
						object2:Create("ImageLabel")({
							Size = UDim2.fromScale(1, 1),
							Instance.new("UIAspectRatioConstraint"),
							BackgroundTransparency = 1,
							Image = data.Icon,
							Name = "AAIcon",
							object2:Create("UICorner")({
								CornerRadius = UDim.new(1)
							})
						}),
						object2:Create("Frame")({
							Size = UDim2.fromScale(0.8, 0.9),
							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Name = "TxtHolder",
							BackgroundTransparency = 1,
							After = function(p)
								textplus.new(data.Text, {
									XAlignment = Enum.TextXAlignment.Left,
									YAlignment = Enum.TextYAlignment.Center,
									Size = 22.6925,
									Font = Enum.Font.SourceSansSemibold,
									Style = { "Fade", "Wiggle" },
									Amplitude = 1.1,
									Speed = 5,
									Chunks = 4,
									StepFactor = 1.35
								}):Play(p)
							end
						})
					}),
					Size = object2:Animation(UDim2.fromScale(1, 1), info, {
						From = UDim2.fromScale(0.9, 0.9)
					}),
					OnClean = function(object3)
						return {
							GroupTransparency = object3:Animation(1, info2),
							Size = object3:Animation(UDim2.fromScale(0.7, 0.7), info3)
						}
					end
				})
			})
		end, {
			Lifetime = data.Duration or 3
		})
	end
end