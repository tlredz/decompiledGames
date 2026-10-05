local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Config = require(script.Parent.Config)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
return function(object)
	local tips = gameSettings.Tips
	local count = #tips
	local value = object:Value(math.random(1, count))
	local space = object:Space(function(data)
		if value:Compare(data.Index) then
			data.Size:Set(UDim2.fromScale(1, 1))
			data.Transparency:Set(0)
		else
			data.Size:Set(UDim2.fromScale(0.7, 0.7))
			data.Transparency:Set(0.5)
		end
	end)
	space:Connect(value.Changed)
	return object:Create("TextButton")({
		Name = "ZZTipFrame",
		CleanDelay = Config.InInfo.Time,
		MouseButton1Click = function()
			ScreenEffects.CircleClick()

			if value:Compare(count) then
				value:Set(1)
			else
				value += 1
			end
		end,
		Size = UDim2.fromScale(1, 0.25),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Vertical
		}),
		object:Create("TextLabel")({
			Size = UDim2.fromScale(1, 0.4),
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			Text = object:Animation("[ TIP ]", Config.TxtInfo2),
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			TextTransparency = object:Animation(0, Config.InInfo, {
				From = 1
			}),
			OnClean = function()
				return {
					TextTransparency = object:Animation(1, Config.TransitionInfo)
				}
			end,
			object:Create("UIStroke")({
				Thickness = 2,
				Transparency = object:Animation(0, Config.InInfo, {
					From = 1
				}),
				OnClean = function()
					return {
						Transparency = object:Animation(1, Config.TransitionInfo)
					}
				end,
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = -90
				})
			})
		}),
		object:Create("TextLabel")({
			Size = UDim2.fromScale(2, 0.5),
			TextColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			FontFace = Font.new(
				"rbxasset://fonts/families/SourceSansPro.json",
				Enum.FontWeight.SemiBold,
				Enum.FontStyle.Italic
			),
			TextScaled = true,
			object:Create("UIStroke")({
				Thickness = 2,
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.5),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = -90
				}),
				Transparency = object:Animation(0, Config.InInfo, {
					From = 1
				}),
				OnClean = function()
					return {
						Transparency = object:Animation(1, Config.TransitionInfo)
					}
				end
			}),
			TextTransparency = object:Animation(0, Config.InInfo, {
				From = 1
			}),
			OnClean = function()
				return {
					TextTransparency = object:Animation(1, Config.TransitionInfo)
				}
			end,
			object:Do(function(callback, object2, _)
				return {
					Text = object2:Animation(tips[callback(value)], Config.TxtInfo0)
				}
			end)
		}),
		object:Create("Frame")({
			Name = "ZButtons",
			Size = UDim2.fromScale(0.2, 0.2),
			Instance.new("UIAspectRatioConstraint"),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 3)
			}),
			object:Iterate(#tips, function(p, _, _, _)
				local transparency = object:Value(0)
				local size = object:Value(UDim2.fromScale(0.7, 0.7))
				space:Add({
					Size = size,
					Transparency = transparency,
					Index = p
				}, object, true):Call()
				return object:Create("Frame")({
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Name = "Holder",
					CleanDelay = Config.InInfo.Time,
					object:Create("ImageLabel")({
						Position = UDim2.fromScale(0.5, 1.25),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Image = "rbxassetid://119489413451678",
						BackgroundTransparency = 1,
						ImageTransparency = object:Animation(transparency, Config.InInfo, {
							From = 1
						}),
						Size = object:Animation(size, Config.TransitionInfo),
						OnClean = function()
							return {
								ImageTransparency = object:Animation(1, Config.TransitionInfo)
							}
						end
					})
				})
			end)
		})
	})
end