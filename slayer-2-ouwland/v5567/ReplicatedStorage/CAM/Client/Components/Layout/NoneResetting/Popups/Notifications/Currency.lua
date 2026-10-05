local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)

local function playRowSound(sound: string?)
	if sound == nil then
		return
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local sounds

	if assets ~= nil then
		sounds = assets:FindFirstChild("Sounds") or nil
	end

	local misc

	if sounds ~= nil then
		misc = sounds:FindFirstChild("Misc") or nil
	end

	local sound2 = misc ~= nil and misc:FindFirstChild(sound) or nil

	if sound2 == nil or not sound2:IsA("Sound") then
		return
	end

	local clone = sound2:Clone()
	clone.Parent = script
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength + 3)
end

local info = faye.Info(0.3, Enum.EasingStyle.Back)
local info2 = faye.Info(0.2, Enum.EasingStyle.Linear)
local typeof2 = typeof
return function(object, p)
	return object:SpecialThread(function(object2)
		return object2:Create("Frame")({
			Name = "CurrencyNotification",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			CleanDelay = info2.Time,
			object2:Create("Frame")({
				Size = UDim2.fromScale(1, 1),
				Name = "ActualHolder",
				After = function()
					return {
						Size = object2:Animation(UDim2.fromScale(1, 1), info, {
							From = UDim2.fromScale(0.75, 0.75)
						})
					}
				end,
				OnClean = function(object3)
					return {
						Size = object3:Animation(UDim2.fromScale(0.8, 0.8), info2)
					}
				end,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				object2:Create("Frame")({
					Name = "Bg",
					Size = UDim2.new(1, 14, 1, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					object2:Create("UICorner")({
						CornerRadius = UDim.new(1)
					}),
					BackgroundColor3 = Color3.new(0.05, 0.05, 0.05),
					BackgroundTransparency = 0.45,
					OnClean = function()
						return {
							BackgroundTransparency = object2:Animation(1, info2)
						}
					end
				}),
				object2:Create("Frame")({
					Name = "Holder",
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(1, 0.9),
					BackgroundTransparency = 1,
					object2:Create("UIListLayout")({
						Name = "List",
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 5)
					}),
					object2:Iterate(p.Content, function(p2: number, data, object3, _)
						if typeof2(data) ~= "table" then
							return
						end

						local text

						if type(data.Value) == "string" then
							text = data.Value
						elseif math.sign(data.Value) == 1 then
							text = "+" .. Utility.addCommasToNumber(data.Value)
						else
							text = Utility.addCommasToNumber(data.Value)
						end

						if data.Add ~= nil then
							text ..= " " .. data.Add
						end

						if data.Tag ~= nil then
							text ..= " (" .. data.Tag .. ")"
						end

						playRowSound(data.Sound)
						return object3:Create("Frame")({
							OnClean = function()
								return {
									BackgroundTransparency = object3:Animation(1, info2)
								}
							end,
							Name = "no" .. p2,
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 0.5,
							object3:Create("UIStroke")({
								Transparency = 0.9,
								Color = Color3.new(1, 1, 1),
								OnClean = function()
									return {
										Transparency = object3:Animation(1, info2)
									}
								end
							}),
							object3:Create("UIListLayout")({
								Name = "List",
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder
							}),
							object3:Create("UICorner")({
								CornerRadius = UDim.new(1)
							}),
							BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
							object3:Create("ImageLabel")({
								LayoutOrder = 1,
								Size = UDim2.fromScale(0.5, 1.2),
								Instance.new("UIAspectRatioConstraint"),
								Image = data.Icon,
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.fromScale(0, 0.5),
								BackgroundTransparency = 1,
								OnClean = function()
									return {
										ImageTransparency = object3:Animation(1, info2)
									}
								end
							}),
							object3:Create("TextLabel")({
								Name = "Text",
								LayoutOrder = 2,
								Size = UDim2.fromScale(1, 0.9),
								Text = text,
								TextScaled = true,
								BackgroundTransparency = 1,
								Font = Enum.Font.SourceSansSemibold,
								TextColor3 = data.Color,
								object3:Create("UIStroke")({
									Transparency = 0.9
								}),
								OnClean = function()
									return {
										TextTransparency = object3:Animation(1, info2)
									}
								end,
								function(p3)
									p3.Size = UDim2.new(0, p3.TextBounds.X + 4, 1, 0)
								end
							}),
							function()
								local level = data.Level

								if type(level) ~= "table" then
									return
								end

								local function levelText(layoutOrder: number, name: string, text2: string, p6: number, textXAlignment)
									return object3:Create("TextLabel")({
										Name = name,
										LayoutOrder = layoutOrder,
										Size = UDim2.fromScale(1, 0.9),
										Text = text2,
										TextScaled = true,
										TextXAlignment = textXAlignment,
										BackgroundTransparency = 1,
										Font = Enum.Font.SourceSansSemibold,
										TextColor3 = data.Color,
										object3:Create("UIStroke")({
											Transparency = 0.9
										}),
										OnClean = function()
											return {
												TextTransparency = object3:Animation(1, info2)
											}
										end,
										function(p8)
											p8.Size = UDim2.new(0, p8.TextBounds.X + p6, 1, 0)
										end
									})
								end

								return {
									levelText(3, "LevelFrom", `Lv {level.From}`, 10, Enum.TextXAlignment.Right),
									object3:Create("ImageLabel")({
										Name = "LevelArrow",
										LayoutOrder = 4,
										Size = UDim2.fromScale(0.35, 0.7),
										Instance.new("UIAspectRatioConstraint"),
										Image = BunchaIcons.LevelArrow,
										BackgroundTransparency = 1,
										OnClean = function()
											return {
												ImageTransparency = object3:Animation(1, info2)
											}
										end
									}),
									levelText(5, "LevelTo", `Lv {level.To}`, 4, Enum.TextXAlignment.Left)
								}
							end,
							function(p3)
								local absoluteContentSize = p3.List.AbsoluteContentSize
								p3.Size = UDim2.new(0, absoluteContentSize.X + 6, 1, 0)
							end
						})
					end),
					After = function(instance)
						instance.Parent.Parent.Size = UDim2.fromScale(
							(instance.List.AbsoluteContentSize.X + 18) / instance.Parent.AbsoluteSize.X,
							1
						)

						for _, child in instance:GetChildren(), nil, nil do
							if child.ClassName ~= "Frame" then
								continue
							end

							local offset = child.Size.X.Offset
							child.Size = UDim2.fromScale((offset + 10) / instance.AbsoluteSize.X, 1)
							child.Text.Size = UDim2.fromScale(child.Text.TextBounds.X / (offset + 6), 1)

							for _, childName in { "LevelFrom", "LevelTo" } do
								local child2 = child:FindFirstChild(childName)

								if child2 ~= nil then
									child2.Size = UDim2.fromScale(child2.Size.X.Offset / (offset + 6), 1)
								end
							end
						end
					end
				})
			})
		})
	end, {
		Lifetime = p.Time
	})
end