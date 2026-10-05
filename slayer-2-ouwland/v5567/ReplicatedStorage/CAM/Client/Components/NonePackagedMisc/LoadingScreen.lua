local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Config)
local Loading = require(script.Loading)
local Tips = require(script.Tips)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local color = Color3.new(1, 0.843137, 0.145098)
local color2 = Color3.new(1, 1, 1)
return function(parent, options)
	local v = faye.new()
	local v2 = options or {}
	local title = v2.Title or "Unknown Location"
	local subTitle = v2.SubTitle
	local titleColor = v2.TitleColor or color
	local subTitleColor = v2.SubTitleColor or color2
	local parent2

	if gameSettings.IsRunning then
		parent2 = Instance.new("ScreenGui", parent)
		parent2.Name = "LoadingScreen"
		parent2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		parent2.DisplayOrder = 999999999
	else
		parent2 = Instance.new("Frame", parent)
		parent2.Size = UDim2.fromScale(1, 1)
		parent2.BackgroundTransparency = 1
	end

	v:Create("TextButton")({
		Parent = parent2,
		CleanDelay = Config.InInfo.Time,
		v:Create("Frame")({
			ZIndex = 2,
			Size = UDim2.fromScale(0.06, 0.06),
			Instance.new("UIAspectRatioConstraint"),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(0.915, 0.9115),
			BackgroundTransparency = 1,
			Loading(v)
		}),
		Size = v:Animation(UDim2.fromScale(1.2, 1.2), Config.InInfo2, {
			From = UDim2.fromScale(2, 2)
		}),
		BackgroundColor3 = Color3.new(0, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		OnClean = function()
			return {
				Size = v:Animation(UDim2.fromScale(1.35, 1.35), Config.InInfo)
			}
		end,
		v:Create("ImageLabel")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.2, 1.2),
			Image = "rbxassetid://83160300762151",
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			ImageTransparency = v:Animation(0, Config.InInfo, {
				From = 1
			}),
			OnClean = function()
				return {
					ImageTransparency = v:Animation(1, Config.InInfo)
				}
			end
		}),
		v:Create("Frame")({
			Name = "Bottom",
			Size = UDim2.fromScale(1, 0.4),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			BackgroundColor3 = Color3.new(),
			v:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) }),
				Rotation = -90
			}),
			BackgroundTransparency = v:Animation(0, Config.InInfo, {
				From = 1
			}),
			OnClean = function()
				return {
					BackgroundTransparency = v:Animation(1, Config.InInfo)
				}
			end
		}),
		v:Create("Frame")({
			Name = "Top",
			Size = UDim2.fromScale(1, 0.8),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromScale(0, 0),
			BackgroundColor3 = Color3.new(),
			v:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) }),
				Rotation = 90
			}),
			BackgroundTransparency = v:Animation(0, Config.InInfo, {
				From = 1
			}),
			OnClean = function()
				return {
					BackgroundTransparency = v:Animation(1, Config.InInfo)
				}
			end
		}),
		v:Create("ImageLabel")({
			Name = "Logo",
			Size = UDim2.fromScale(0.4, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			v:Create("UIAspectRatioConstraint")({
				AspectRatio = 2.5
			}),
			Position = v:Animation(UDim2.fromScale(0.5, 0.3), Config.InInfo2, {
				From = UDim2.fromScale(0.5, 0)
			}),
			Image = "rbxassetid://126485150671055",
			BackgroundTransparency = 1,
			ImageTransparency = v:Animation(0, Config.InInfo, {
				From = 1
			}),
			OnClean = function()
				return {
					ImageTransparency = v:Animation(1, Config.InInfo)
				}
			end
		}),
		v:Create("Frame")({
			Name = "BottomContent",
			Size = UDim2.fromScale(0.3, 0.15),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = v:Animation(UDim2.fromScale(0.5, 0.815), Config.InInfo3, {
				From = UDim2.fromScale(0.5, 1)
			}),
			BackgroundTransparency = 1,
			v:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 2)
			}),
			v:Create("TextLabel")({
				Name = "IntroText",
				Size = UDim2.fromScale(1, 0.2),
				TextScaled = true,
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.SourceSansBold,
				TextTransparency = v:Animation(0.2, Config.InInfo, {
					From = 1
				}),
				OnClean = function()
					return {
						TextTransparency = v:Animation(1, Config.TransitionInfo)
					}
				end,
				v:Create("UIStroke")({
					Thickness = 4,
					v:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.5),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = -90
					}),
					Transparency = v:Animation(0, Config.InInfo, {
						From = 1
					}),
					OnClean = function()
						return {
							Transparency = v:Animation(1, Config.TransitionInfo)
						}
					end
				}),
				BackgroundTransparency = 1,
				Text = v:Animation("Now Entering...", Config.TxtInfo0)
			}),
			v:Create("TextLabel")({
				Name = "Title",
				Size = UDim2.fromScale(1, 0.3),
				TextScaled = true,
				TextColor3 = titleColor,
				Font = Enum.Font.SourceSansBold,
				TextTransparency = v:Animation(0, Config.InInfo, {
					From = 1
				}),
				OnClean = function()
					return {
						TextTransparency = v:Animation(1, Config.TransitionInfo)
					}
				end,
				v:Create("UIStroke")({
					Thickness = 4,
					Transparency = v:Animation(0, Config.InInfo, {
						From = 1
					}),
					OnClean = function()
						return {
							Transparency = v:Animation(1, Config.TransitionInfo)
						}
					end,
					v:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = -90
					})
				}),
				BackgroundTransparency = 1,
				Text = v:Animation(title, Config.TxtInfo2)
			}),
			subTitle and v:Create("TextLabel")({
				Name = "ZSubTitle",
				Size = UDim2.fromScale(1, 0.2),
				TextScaled = true,
				TextColor3 = subTitleColor,
				Font = Enum.Font.SourceSansBold,
				v:Create("UIStroke")({
					Thickness = 4,
					v:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = -90
					})
				}),
				BackgroundTransparency = 1,
				Text = v:Animation(subTitle, Config.TxtInfo1)
			}),
			Tips(v)
		})
	})
	return function()
		v:Destroy()
	end, parent2
end