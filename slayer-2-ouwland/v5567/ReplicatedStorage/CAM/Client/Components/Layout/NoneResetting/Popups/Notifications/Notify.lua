local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local textplus = require(game.ReplicatedStorage.Packages.textplus)
local Config = require(script.Parent.Config)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
return function(object, data)
	if data == nil then
		return
	end

	local type2 = data.Type or Config.DefaultTxt
	local icon = data.Icon or Config.Types[type2] or Config.Types.Default
	local contentColor = data.ContentColor or Config.DefaultColor
	local v = textplus.new(data.Text, {
		Color = data.ContentColor or nil,
		Font = data.Font or Enum.Font.SourceSansSemibold,
		Scaled = true,
		XAlignment = Enum.TextXAlignment.Center,
		Step = 0.005,
		Overfill = true,
		Wrapped = false,
		Chunks = 2,
		UseCanvas = true
	})
	local duration = data.Duration or Config.DefaultDurations[type2] or 3
	local sound = data.Sound or script.Sounds:FindFirstChild(type2)
	sound.TimePosition = 0
	sound:Play()
	local value = object:Value(0.5)
	local value2 = object:Value(0.65)
	local value3 = object:Value(UDim2.fromScale(0.5, 0.5))
	return object:SpecialThread(function(instance)
		return instance:Create("Frame")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			CleanDelay = Config.OutInfo.Time,
			instance:Create("Frame")({
				Name = "Sibling",
				Size = UDim2.new(0, 0, 0.8, -6),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = instance:Animation(value3, Config.InInfo, {
					From = UDim2.fromScale(0.42, 0.5)
				}),
				BackgroundTransparency = 1,
				instance:Create("UICorner")({
					CornerRadius = UDim.new(0.5, 0)
				}),
				ZIndex = 2,
				instance:Create("UIStroke")({
					Color = Config.ColorsLight[type2],
					Transparency = instance:Animation(value2, Config.OutInfo),
					OnClean = function()
						return {
							Transparency = instance:Animation(1, Config.OutInfo)
						}
					end
				}),
				instance:Create("TextButton")({
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					MouseEnter = function()
						value:Set(0)
						value2:Set(0)
					end,
					MouseLeave = function()
						value:Reset()
						value2:Reset()
					end,
					MouseButton1Click = function(_)
						ScreenEffects.CircleClick()
						instance:Destroy()
					end
				})
			}),
			instance:Create("Frame")({
				Size = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = instance:Animation(value3, Config.InInfo, {
					From = UDim2.fromScale(0.42, 0.5)
				}),
				BackgroundTransparency = instance:Animation(value, Config.OutInfo),
				BackgroundColor3 = data.BgColor or Config.Colors[type2],
				instance:Create("UICorner")({
					CornerRadius = UDim.new(0.5, 0)
				}),
				instance:Create("UIListLayout")({
					Name = "List",
					Padding = UDim.new(0, 5),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal
				}),
				instance:Create("Frame")({
					Size = UDim2.fromScale(1, 1),
					Instance.new("UIAspectRatioConstraint"),
					BackgroundTransparency = 1,
					instance:Create("ImageLabel")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.6, 0.6),
						ImageColor3 = contentColor,
						BackgroundTransparency = 1,
						Image = icon,
						OnClean = function()
							return {
								ImageTransparency = instance:Animation(1, Config.OutInfo)
							}
						end
					}),
					instance:Create("Frame")({
						Name = "BarHolder",
						Size = UDim2.new(0, 2, 0.6, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(1, 0, 0.5, 0),
						BackgroundTransparency = 0.75,
						instance:Create("Frame")({
							Name = "Bar",
							Position = UDim2.fromScale(0, 1),
							AnchorPoint = Vector2.new(0, 1),
							Size = instance:Animation(UDim2.fromScale(1, 0), instance.Info(duration), {
								From = UDim2.fromScale(1, 1)
							}),
							OnClean = function()
								return {
									BackgroundTransparency = instance:Animation(1, Config.OutInfo)
								}
							end
						}),
						OnClean = function()
							return {
								BackgroundTransparency = instance:Animation(1, Config.OutInfo)
							}
						end
					})
				}),
				OnClean = function()
					value3:Set(UDim2.fromScale(0.58, 0.5))
					return {
						BackgroundTransparency = instance:Animation(1, Config.OutInfo)
					}
				end,
				function(p)
					local absoluteSize = p.AbsoluteSize
					local contentSize = v:GetContentSize(p.Parent)
					local v2 = contentSize == nil and 0 or contentSize.X
					return { instance:Create("Frame")({
							Name = "TextHolderGrow",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = instance:Animation(UDim2.new(0, v2, 1, 0), Config.InInfo, {
								From = UDim2.fromScale(0, 1)
							}),
							BackgroundTransparency = 1,
							instance:Create("CanvasGroup")({
								BackgroundTransparency = 1,
								Name = "HolderReal",
								Size = UDim2.new(0, v2, 1, 0),
								GroupTransparency = instance:Animation(0, Config.InInfo, {
									From = 1
								}),
								OnClean = function()
									return {
										GroupTransparency = instance:Animation(1, Config.OutInfo)
									}
								end,
								function(instance2)
									task.defer(function()
										if instance2.Parent == nil then
											return
										end

										if type(data.Text) ~= "string" or string.find(
											string.lower(data.Text),
											"style=",
											1,
											true
										) == nil then
											v:Print(instance2)
											return
										end

										v:Play(instance2)
										instance2.Destroying:Once(function()
											v:Stop()
										end)
									end)
								end
							})
						}), function(p2)
							local v3 = v2 + 24 + absoluteSize.Y * 0.6

							if p2.Parent ~= nil then
								local sibling = p2.Parent:FindFirstChild("Sibling")

								if sibling ~= nil then
									instance:LoadAnimation(sibling, {
										Size = UDim2.new(0, v3 - 6, 1, -6)
									}, Config.InInfo):Play()
								end
							end

							return {
								Size = instance:Animation(UDim2.new(0, v3, 1, 0), Config.InInfo)
							}
						end }
				end
			})
		})
	end, {
		Lifetime = duration
	})
end