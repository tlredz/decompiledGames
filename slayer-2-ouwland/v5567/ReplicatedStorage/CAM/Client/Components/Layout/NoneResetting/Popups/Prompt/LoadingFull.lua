local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.25)
local info2 = faye.Info(0.4)
local info3 = faye.Info(1.35, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, -1, false, 0)
return function(object, parent, p2, p3: number)
	local text = object:Value(p2.Content or "Waiting for response")
	local Y = GuiService:GetGuiInset().Y
	local value2 = object:Value(0.5)
	object:Create("Frame")({
		Parent = parent,
		object:Create("TextButton")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			OnClean = function(p4)
				p4.Size = UDim2.fromScale()
			end
		}),
		Position = UDim2.new(0, 0, 0, -Y),
		Size = UDim2.new(1, 0, 1, Y),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = object:Animation(p2.BackgroundTransparency or 0.2, info, {
			From = 1
		}),
		OnClean = function()
			return {
				BackgroundTransparency = object:Animation(1)
			}
		end,
		object:Create("Frame")({
			Size = UDim2.fromScale(0.5, 0.5),
			Name = "ComponentHolder",
			Instance.new("UIAspectRatioConstraint"),
			BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = object:Animation(0.75, info),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) }),
				Rotation = 45
			}),
			OnClean = function()
				return {
					BackgroundTransparency = object:Animation(1, info2)
				}
			end,
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.075)
			}),
			object:Create("Frame")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Name = "Holder",
				object:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0.015, 0)
				}),
				object:Create("TextLabel")({
					Name = "ATitle",
					Size = UDim2.fromScale(1, 0.08),
					BackgroundTransparency = 1,
					Text = text,
					TextTransparency = object:Animation(0, info),
					Font = Enum.Font.SourceSansItalic,
					TextScaled = true,
					TextColor3 = Color3.new(1, 1, 1),
					OnClean = function()
						return {
							TextTransparency = object:Animation(1, info2)
						}
					end
				}),
				object:Create("Frame")({
					Name = "Bar",
					Size = UDim2.fromScale(0.1, 0.1),
					Instance.new("UIAspectRatioConstraint"),
					AnchorPoint = Vector2.new(0.4, 0.4),
					Position = UDim2.fromScale(0.5, 0.7),
					BackgroundTransparency = 1,
					object:Create("ImageLabel")({
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Image = "rbxassetid://16708634837",
						ImageTransparency = 0.75,
						OnClean = function()
							return {
								ImageTransparency = object:Animation(1, info2)
							}
						end
					}),
					object:Create("ImageLabel")({
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Image = "rbxassetid://16708879099",
						ImageTransparency = 0,
						Rotation = object:Animation(360, info3),
						OnClean = function()
							return {
								ImageTransparency = object:Animation(1, info2)
							}
						end
					})
				}),
				object:Create("TextButton")({
					Size = UDim2.fromScale(1, 0.075),
					BackgroundTransparency = 1,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					object:Create("TextLabel")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.fromScale(1, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Text = "Close",
						TextScaled = true,
						BackgroundTransparency = 1,
						Font = Enum.Font.SourceSansSemibold,
						TextColor3 = Color3.new(1, 0.375, 0.375),
						TextTransparency = object:Animation(value2, info, {
							From = 1
						}),
						OnClean = function()
							return {
								TextTransparency = object:Animation(1, info2)
							}
						end
					}),
					MouseEnter = function()
						value2:Set(0)
					end,
					MouseLeave = function()
						value2:Reset()
					end,
					MouseButton1Click = function()
						ScreenEffects.CircleClick()
						PopUpCreator.signal:Fire(p3)
					end
				})
			})
		})
	})
	object:Spawn(function()
		local v = 0

		while true do
			v = v % 3 + 1
			text:Set(text.Initial .. string.rep(".", v))
			task.wait(0.5)
		end
	end)
end