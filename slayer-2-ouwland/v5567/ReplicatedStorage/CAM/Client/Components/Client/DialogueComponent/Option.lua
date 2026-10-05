local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local _ = faye.SpringInfo
local info = faye.Info
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local DialogueUtility = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.DialogueUtility)
local v = info(0.2)
local _ = typeof
local v2 = info(0.1, Enum.EasingStyle.Sine)
return function(object, text: string, p2: string, p3: number, object2)
	local firstDelayTime = (p3 - 1) * 0.025
	local fg = object:Value(Color3.new(0.15, 0.15, 0.15))
	local bg = object:Value(Color3.new())
	local txt = object:Value(Color3.new(1, 1, 1))
	local value4 = object:Value(UDim2.fromScale(1, 1))
	local ST = object:Value(1)
	local v4 = object2:Add({
		S = value4,
		ST = ST,
		Fg = fg,
		Bg = bg,
		Txt = txt,
		In = false
	}, object, true)
	return object:Create("TextButton")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		MouseEnter = function()
			v4.In = true
			v4:Call()
		end,
		MouseLeave = function()
			v4.In = false
			v4:Call()
		end,
		MouseButton1Click = function(_)
			ScreenEffects.CircleClick()
			DialogueUtility.DoAll(p2, text)
		end,
		object:Create("TextLabel")({
			Name = "Copytxtforbounds",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			TextScaled = true,
			Size = UDim2.fromScale(15, 0.7),
			BackgroundTransparency = 1,
			Text = text,
			Font = Enum.Font.SourceSansSemibold,
			TextTransparency = 1
		}),
		After = { function(state)
				local v5 = math.max((state.Copytxtforbounds.TextBounds.X + 25) / state.AbsoluteSize.X, 1)
				state.Size = UDim2.fromScale(v5, 1)
				state.Copytxtforbounds:Destroy()
			end },
		CleanDelay = 0.25,
		object:Create("Frame")({
			Name = "Actual",
			Size = object:Animation(value4, v2, {
				FirstDelayTime = firstDelayTime,
				From = UDim2.fromScale(0.75, 0.75)
			}),
			BackgroundColor3 = object:Animation(fg, v),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Visible = object:DelayProperty(true, firstDelayTime, false),
			BackgroundTransparency = 0.1,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			CleanFunction = function()
				return {
					BackgroundTransparency = object:Animation(1, v)
				}
			end,
			object:Create("TextLabel")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				TextScaled = true,
				Size = UDim2.fromScale(15, 0.7),
				BackgroundTransparency = 1,
				TextColor3 = object:Animation(txt, v),
				Text = text,
				ZIndex = 2,
				Font = Enum.Font.SourceSansSemibold,
				CleanFunction = function()
					return {
						TextTransparency = object:Animation(1, v)
					}
				end
			}),
			object:Create("Frame")({
				Name = "Inner",
				Size = UDim2.new(1, -6, 1, -6),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				BackgroundTransparency = 1,
				object:Create("UIStroke")({
					Thickness = 1,
					CleanFunction = function()
						if v4.In then
							return {
								Transparency = object:Animation(1, v)
							}
						end
					end,
					Transparency = object:Animation(ST, v)
				})
			}),
			object:Create("Frame")({
				Name = "Bg",
				Size = UDim2.new(1, -5, 1, -5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = object:Animation(bg, v),
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.9),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = 90
				}),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				CleanFunction = function()
					return {
						BackgroundTransparency = object:Animation(1, v)
					}
				end
			})
		})
	})
end