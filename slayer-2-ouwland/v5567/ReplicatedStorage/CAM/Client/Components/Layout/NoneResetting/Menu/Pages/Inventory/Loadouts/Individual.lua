local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local info = faye.Info(0.15, Enum.EasingStyle.Sine)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
return function(object, object2, object3, instance)
	local aspectRatio = Platform_Handler.Platform.Value == "Mobile" and 4.5 or 6.5
	local v2 = {
		Editable = object:Value(false),
		ButtonEnabled = object:Value(true),
		In = false,
		TextColor = object:Value(Color3.new(1, 1, 1)),
		Color = object:Value(Color3.new(0.15, 0.15, 0.15)),
		AspectRatio = object:Value(aspectRatio),
		EquippedAspect = aspectRatio * 0.5384615384615384,
		StrokeTransparency = object:Value(1),
		StrokeSize = object:Value(UDim2.new(1, -6, 1, -6)),
		Name = instance.Name,
		TextSize = object:Value(UDim2.new(1, 0, 1, -6)),
		TextPosition = object:Value(UDim2.fromScale(0.5, 0.5))
	}
	local v3 = object2:Add(v2, object, true):Call()
	local text = nil
	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Name = "Holder",
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = object:Animation(v2.AspectRatio, info)
		}),
		object:Create("Frame")({
			object:Create("UIAspectRatioConstraint")({
				AspectRatio = aspectRatio
			}),
			Name = "Main",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = object:Animation(v2.Color, info),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.25)
			}),
			object:Create("TextButton")({
				ZIndex = 2,
				Visible = v2.ButtonEnabled,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				MouseEnter = function()
					v2.In = true
					v3:Call()
				end,
				MouseLeave = function()
					v2.In = false
					v3:Call()
				end,
				MouseButton1Click = function(p)
					if object3:Compare(instance.Name) then
						object3:Reset()
					else
						object3:Set(instance.Name)
					end

					ScreenEffects.StrokeClick(p)
				end
			}),
			object:Create("Frame")({
				Name = "StrokeHolder",
				ZIndex = 3,
				Size = object:Animation(v2.StrokeSize, info),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				object:Create("UICorner")({
					CornerRadius = UDim.new(0.25)
				}),
				BackgroundTransparency = 1,
				object:Create("UIStroke")({
					Transparency = object:Animation(v2.StrokeTransparency, info),
					Color = Color3.new(1, 1, 1)
				})
			}),
			object:Create("Frame")({
				Name = "TextHolder",
				Position = object:Animation(v2.TextPosition, info),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = object:Animation(v2.TextSize, info),
				BackgroundTransparency = 1,
				object:Create("TextBox")({
					Name = "Txt",
					Size = UDim2.fromScale(1, 1),
					TextScaled = true,
					TextEditable = v2.Editable,
					ClearTextOnFocus = false,
					Position = UDim2.fromScale(0.02, 0.5),
					AnchorPoint = Vector2.new(0, 0.5),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					Font = Enum.Font.SourceSansSemibold,
					BackgroundTransparency = 1,
					Text = instance:FindFirstChild("Name").Value,
					TextColor3 = object:Animation(v2.TextColor, info),
					FocusLost = function(p)
						local text2 = p.Text

						if text ~= nil and text ~= text2 then
							text2 = SignalFunction.ToServer("HandleLoadoutActions", instance.Name, 3, text2)
							p.Text = text2
						end

						text = text2
					end,
					function(p)
						text = p.Text
					end
				})
			}),
			object:State(function(callback, object4, _)
				if callback(v2.Editable) then
					return { object4:Create("Frame")({
							Name = "Save",
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 6, 0.5, 0),
							Size = UDim2.new(0.2925, 0, 1, -12),
							BackgroundTransparency = 1,
							GradientButton(object4, {
								TweenInfo = object4.Info(0.1),
								BgColor = Color3.new(0.807843, 0.94902, 0.74902),
								TextXAlignment = Enum.TextXAlignment.Center,
								TextBoxSize = UDim2.fromScale(1, 1),
								Text = "Save",
								Clicked = function()
									SignalEvent.ToServer("HandleLoadoutActions", instance.Name, 1)
									object3:Reset()
								end
							})
						}), object4:Create("Frame")({
							Name = "Load",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(0.2925, 0, 1, -12),
							BackgroundTransparency = 1,
							GradientButton(object4, {
								BgColor = Color3.new(0.55, 0.55, 0.55),
								TextXAlignment = Enum.TextXAlignment.Center,
								Text = "Load",
								TextBoxSize = UDim2.fromScale(1, 1),
								TweenInfo = object4.Info(0.1),
								Properties = {
									AnchorPoint = Vector2.new(0.5, 0),
									Position = UDim2.fromScale(0.5, 0)
								},
								Clicked = function()
									SignalEvent.ToServer("HandleLoadoutActions", instance.Name, 2)
									object3:Reset()
								end
							})
						}), object4:Create("Frame")({
							Name = "Cancel",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -6, 0.5, 0),
							Size = UDim2.new(0.2925, 0, 1, -12),
							BackgroundTransparency = 1,
							GradientButton(object4, {
								BgColor = Color3.new(1, 0.364706, 0.364706),
								TextXAlignment = Enum.TextXAlignment.Center,
								Text = "Close",
								TextBoxSize = UDim2.fromScale(1, 1),
								TweenInfo = object4.Info(0.1),
								Properties = {
									AnchorPoint = Vector2.new(1, 0),
									Position = UDim2.fromScale(1, 0)
								},
								Clicked = function()
									object3:Reset()
								end
							})
						}) }
				end
			end)
		})
	})
end