local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local interfaceutility = require(ReplicatedStorage.Packages.interfaceutility)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local SkillTreeConfig = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder.SkillTreeConfig)

local function iconFor(p: string)
	local statsAndDebuff = BunchaIcons.StatsAndDebuffs[p]

	if statsAndDebuff ~= nil then
		return statsAndDebuff
	end

	local v = SkillTreeConfig[p]
	return v ~= nil and v.Icon or nil
end

local color = Color3.new(1, 1, 1)
local info = faye.Info(0.2)
local info2 = faye.Info(0.2)
local color2 = Color3.fromRGB(150, 150, 155)

local function quotesFor(p: string, p2: number)
	local result = {}

	for k, v in PlayerProgression.GetStats(p, p2) do
		if type(v) == "number" and v ~= 0 then
			local icon = BunchaIcons.StatsAndDebuffs[k]

			if icon == nil then
				local v3 = SkillTreeConfig[k]
				icon = v3 ~= nil and v3.Icon or nil
			end

			local v2 = {
				Icon = icon,
				Text = `{v > 0 and "+" or ""}{v} {k}`,
				Stat = true
			}
			table.insert(result, v2)
		elseif v == true then
			local grantedSkill = PlayerProgression.GrantedSkills[k]
			local icon

			if grantedSkill ~= nil then
				icon = grantedSkill.Skill.icon
			end

			table.insert(result, {
				Icon = icon,
				Text = k,
				Stat = true
			})
		end
	end

	return result
end

function Row(object, _: number, p)
	local backgroundColor = gameSettings.raceColors[p] or gameSettings.raceColors.Human
	local lerped = backgroundColor:Lerp(color, 0.4)
	local text = object:Value("Lv 2")
	local text2 = object:Value("35 / 250")
	local value3 = object:Value(UDim2.fromScale(0.14, 0.45))
	local color4 = object:Value(backgroundColor)
	local value5 = object:Value(color)
	local visible = object:Value(false)
	local value7 = object:Value((quotesFor(p, 2)))
	local v2 = nil
	local HSV, v3, v4 = backgroundColor:ToHSV()
	local color3 = Color3.fromHSV(HSV, v3 * 0.35, v4 * 0.75)
	local folder = PlayerProgression.GetFolder(Players.LocalPlayer, p)
	local current

	if folder == nil then
		current = nil
	else
		current = folder:FindFirstChild("Current") or nil
	end

	local max

	if folder == nil then
		max = nil
	else
		max = folder:FindFirstChild("Max") or nil
	end

	if current == nil or max == nil then
		warn((`ProgressHolder: no saved bar for the {p} ladder`))
	else
		object:Reactive(function(callback)
			local v5 = callback(current)
			local v6 = callback(max)
			local levelOfMax = PlayerProgression.LevelOfMax(v6)
			local v7

			if PlayerProgression.MaxLevel() <= levelOfMax then
				v7 = v6 <= v5
			else
				v7 = false
			end

			text:Set((`Lv {levelOfMax}`))
			text2:Set(v7 and "(Max)" or `{v5} / {v6}`)
			value3:Set(UDim2.fromScale(not (v6 > 0) and 0 or math.clamp(v5 / v6, 0, 1), 0.45))
			local v9

			if v7 then
				v9 = color3
			else
				v9 = backgroundColor
			end

			color4:Set(v9)
			local v11

			if v7 then
				v11 = color2
			else
				v11 = color
			end

			value5:Set(v11)
			visible:Set(v7)

			if levelOfMax ~= v2 then
				v2 = levelOfMax
				value7:Set((quotesFor(p, levelOfMax)))
			end
		end)
	end

	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 0.5),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0.025, 0)
		}),
		object:Create("Frame")({
			Name = "TopHolder",
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0.3),
			BackgroundTransparency = 1,
			object:Create("Frame")({
				Name = "ActualHolder",
				Size = UDim2.new(1, -6, 1, -6),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 6, 0.5, 0),
				BackgroundTransparency = 1,
				object:Create("Frame")({
					Name = "ActualHolder",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 4, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					ZIndex = 2,
					object:Create("UIListLayout")({
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 6)
					}),
					object:Create("Frame")({
						Name = "Icon",
						LayoutOrder = 1,
						Size = UDim2.fromScale(0.5, 1),
						Instance.new("UIAspectRatioConstraint"),
						BackgroundTransparency = 1,
						object:Create("ImageLabel")({
							Name = "Image",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Image = BunchaIcons[`{p}Progress`] or ""
						})
					}),
					object:Create("TextLabel")({
						Name = "Title",
						LayoutOrder = 2,
						Size = UDim2.fromScale(0.5, 1),
						BackgroundTransparency = 1,
						Text = `<font color="#{lerped:ToHex()}">{p}</font> Progress`,
						RichText = true,
						TextColor3 = Color3.new(1, 1, 1),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						Font = Enum.Font.SourceSans
					})
				}),
				object:Create("Frame")({
					Name = "Bg",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = backgroundColor,
					BackgroundTransparency = 0.5,
					object:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.35),
							NumberSequenceKeypoint.new(0.7, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}),
					object:Create("UICorner")({
						CornerRadius = UDim.new(1)
					})
				})
			})
		}),
		object:Create("Frame")({
			Name = "XBars",
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0.4),
			BackgroundTransparency = 1,
			object:Create("Frame")({
				Name = "BarHolder",
				BackgroundTransparency = 0.5,
				Size = UDim2.fromScale(1, 1),
				object:Create("UICorner")({
					CornerRadius = UDim.new(0.15)
				}),
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.5),
						NumberSequenceKeypoint.new(0.3, 0.9),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = -90
				}),
				object:Create("Frame")({
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.fromScale(1, 0.625),
					BackgroundTransparency = 1,
					Name = "TextHolder",
					object:Create("Frame")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.58),
						Size = UDim2.new(1, 8, 0, 2),
						ZIndex = 2,
						BackgroundTransparency = 0.25,
						Visible = visible
					}),
					object:Create("TextLabel")({
						Size = UDim2.fromScale(100, 1),
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.fromScale(1, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Right,
						TextColor3 = object:Animation(value5, info2),
						Text = text2,
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						TextBoundsOnChangedInit = function(p2)
							local parent = p2.Parent
							local absoluteSize = interfaceutility.GetAbsoluteSize(parent.Parent)

							if absoluteSize.X <= 0 then
								return
							end

							local offsetTextSize = interfaceutility.GetOffsetTextSize(p2)
							parent.Size = UDim2.fromScale(math.min(offsetTextSize / absoluteSize.X, 1), 0.625)
						end,
						object:Create("UIStroke")({
							Thickness = 2,
							Color = color4,
							object:Create("UIGradient")({
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.7),
									NumberSequenceKeypoint.new(0.4, 0.95),
									NumberSequenceKeypoint.new(1, 1)
								}),
								Rotation = -90
							})
						})
					})
				}),
				object:Create("Frame")({
					AnchorPoint = Vector2.new(0, 0),
					Position = UDim2.fromScale(0, 0),
					Size = UDim2.fromScale(1, 0.625),
					BackgroundTransparency = 1,
					Name = "LevelHolder",
					object:Create("TextLabel")({
						Size = UDim2.fromScale(100, 1),
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.fromScale(0, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = color,
						Text = text,
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						TextBoundsOnChangedInit = function(p2)
							local parent = p2.Parent
							local absoluteSize = interfaceutility.GetAbsoluteSize(parent.Parent)

							if absoluteSize.X <= 0 then
								return
							end

							local offsetTextSize = interfaceutility.GetOffsetTextSize(p2)
							parent.Size = UDim2.fromScale(math.min(offsetTextSize / absoluteSize.X, 1), 0.625)
						end,
						object:Create("UIStroke")({
							Thickness = 2,
							Color = color4,
							object:Create("UIGradient")({
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.7),
									NumberSequenceKeypoint.new(0.4, 0.95),
									NumberSequenceKeypoint.new(1, 1)
								}),
								Rotation = -90
							})
						})
					})
				}),
				object:Create("Frame")({
					Name = "FillHolder",
					Size = UDim2.new(1, -4, 1, -4),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					object:Create("Frame")({
						Name = "Fill",
						Size = object:Animation(value3, info),
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						BackgroundColor3 = object:Animation(color4, info2),
						object:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.3, 0),
								NumberSequenceKeypoint.new(1, 1)
							}),
							Rotation = -90
						})
					})
				})
			})
		}),
		object:Create("ScrollingFrame")({
			Name = "RewardsHolder",
			LayoutOrder = 3,
			Size = UDim2.fromScale(1, 0.3),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.X,
			CanvasSize = UDim2.fromScale(0, 0),
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
				AbsoluteContentSizeOnChangedInit = function(p2)
					p2.Parent.CanvasSize = UDim2.new(0, p2.AbsoluteContentSize.X, 0, 0)
				end
			}),
			object:Iterate(value7, function(layoutOrder: number, p3, object2)
				return object2:Create("Frame")({
					Name = `Reward{layoutOrder}`,
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(0.2, 0.8),
					BackgroundTransparency = 0.9,
					object2:Create("UICorner")({
						CornerRadius = UDim.new(0.25)
					}),
					object2:Create("UIPadding")({
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4)
					}),
					object2:Create("UIListLayout")({
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 3)
					}),
					function()
						if p3.Icon == nil then
							return
						else
							return object2:Create("ImageLabel")({
								Name = "Icon",
								LayoutOrder = 1,
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								Image = p3.Icon,
								object2:Create("UIAspectRatioConstraint")({
									DominantAxis = Enum.DominantAxis.Height
								})
							})
						end
					end,
					object2:Create("TextLabel")({
						Name = "Amount",
						LayoutOrder = 2,
						Size = UDim2.fromScale(10, 0.75),
						BackgroundTransparency = 1,
						Text = p3.Text,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = color,
						Font = Enum.Font.SourceSans,
						TextBoundsOnChangedInit = function(p4)
							local parent = p4.Parent

							if parent == nil or not parent:IsA("GuiObject") then
								return
							end

							local Y = parent.AbsoluteSize.Y

							if Y <= 0 or p4.TextBounds.X <= 0 then
								return
							end

							local v5 = p3.Icon == nil and 0 or Y + 3
							parent.Size = UDim2.new(0, 8 + v5 + math.ceil(p4.TextBounds.X), 0.8, 0)
						end
					})
				})
			end)
		})
	})
end

return function(object)
	local sidesFor = PlayerProgression.SidesFor(Players.LocalPlayer)
	local v = {}

	for _, v2 in ipairs(sidesFor) do
		table.insert(v, v2)
	end

	return object:Create("Frame")({
		Name = "ProgressHolder",
		Size = UDim2.fromScale(1, 0.45),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0.05, 0)
		}),
		object:Iterate(v, function(p, p2, p3)
			return Row(p3, p, p2)
		end)
	})
end