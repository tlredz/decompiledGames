local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.15)
local info2 = faye.Info(0.5)
local springInfo = faye.SpringInfo(0.5, 1, 0.7)
local springInfo2 = faye.SpringInfo(0.9, 1, 0.7)
local springInfo3 = faye.SpringInfo(1.5, 1, 0.65)
local springInfo4 = faye.SpringInfo(2.5, 1.5, 0.5)
local springInfo5 = faye.SpringInfo(0.5, 1.5, 0.25)
local from = math.random(1, 12) * 30
local color = Color3.new(1, 1, 1)
return function(parent, value: number, value2: number, p2)
	local v2 = value or 1
	local v3 = value2 or 1
	local v4 = p2 or nil
	local animator = faye.new()
	local v5 = animator:Create("CanvasGroup")
	local v6 = {
		Parent = parent,
		ZIndex = 99999,
		GroupTransparency = animator:Animation(0, info2, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = animator:Animation(1, info2)
			}
		end,
		Instance.new("UIAspectRatioConstraint"),
		Size = UDim2.new(1, 0, 1, 58),
		Position = UDim2.new(0.5, 0, 0.3, -58),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1
	}
	local v7 = animator:Create("ImageLabel")({
		Name = "Bg",
		ZIndex = -1,
		BackgroundTransparency = 1,
		Image = "rbxassetid://134657809787110",
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.4
	})
	local v8 = animator:Create("ImageLabel")({
		Name = "Fg",
		ZIndex = 0,
		BackgroundTransparency = 1,
		Image = "rbxassetid://107356746520573",
		Size = animator:Animation(
			UDim2.fromScale(0.4, 0.4),
			animator.Info(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				From = UDim2.fromScale(0.35, 0.35)
			}
		),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ImageColor3 = Color3.new(1, 0.65098, 0),
		ImageTransparency = 0.35,
		Rotation = animator:Animation(from + 360, animator.Info(20, nil, nil, -1), {
			From = from
		}),
		animator:Create("ImageLabel")({
			Name = "InnerGlow",
			BackgroundTransparency = 1,
			Image = "rbxassetid://134657809787110",
			Size = UDim2.fromScale(1.1, 1.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageColor3 = Color3.new(1, 0.737255, 0.247059),
			ImageTransparency = 0.05
		})
	})
	local v9 = animator:Create("ImageLabel")({
		Image = "rbxassetid://125645961128867",
		Position = animator:Animation(UDim2.fromScale(0.5, 0.5), springInfo, {
			From = UDim2.fromScale(0.5, 0.6)
		}),
		ImageTransparency = animator:Animation(0, info2, {
			From = 1
		}),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Size = UDim2.fromScale(0.25, 0.25),
		animator:Create("Frame")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.35, 0.35),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			function(parent2)
				local parent3 = nil
				local v11 = v2
				local v12 = v2 + v3

				local function addTxt(text: number)
					if parent3 ~= nil then
						animator:LoadAnimation(parent3, {
							Position = UDim2.fromScale(0.5, -0.5)
						}, info):Play()
						parent3 = nil
					end

					parent3 = animator:Create("TextLabel")({
						Parent = parent2,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 1.5),
						TextScaled = true,
						Size = UDim2.fromScale(0.65, 0.65),
						Text = text,
						Font = Enum.Font.SourceSansBold,
						TextColor3 = Color3.new(0.301961, 0.203922, 0.035294),
						CleanDelay = 0.5
					})
					animator:LoadAnimation(parent3, {
						Position = UDim2.fromScale(0.5, v11 == v12 and 0.65 or 0.5)
					}, info):Play()
				end

				addTxt(v2)
				animator:Delay(info.Time, function(...)
					local v13 = math.max(math.floor((v12 - v11) * 0.4), 1)

					while v11 < v12 and v13 > 0 do
						v11 = math.min(v11 + v13, v12)
						addTxt(v11)
						task.wait(info.Time)
					end

					parent3.Instance.Size = UDim2.fromScale(1, 1)
					animator:LoadAnimation(parent3, {
						Size = UDim2.fromScale(0.65, 0.65)
					}, springInfo5):Play()
					animator:Create("UIStroke")({
						Color = Color3.new(1, 1, 1),
						Thickness = animator:Animation(0, info2, {
							From = 3
						}),
						Parent = parent3
					})
					animator:Create("TextLabel")({
						Parent = parent2,
						Size = UDim2.fromScale(1, 0.3),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.15),
						BackgroundTransparency = 1,
						Text = "LVL",
						TextScaled = true,
						TextTransparency = animator:Animation(0.25, info2, {
							From = 1
						}),
						Font = Enum.Font.SourceSansBold,
						TextColor3 = Color3.new(0.301961, 0.203922, 0.035294),
						CleanDelay = 0.5
					})
				end)
			end
		})
	})
	local v10 = animator:Create("Frame")({
		BackgroundTransparency = 1,
		Name = "WingsHolderOut",
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.3, 0.3),
		ZIndex = 1,
		animator:Create("ImageLabel")({
			Name = "WingLeft",
			Image = "rbxassetid://114292041262067",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = animator:Animation(UDim2.fromScale(0.5, 0.5), springInfo2, {
				From = UDim2.fromScale(0.5, 0.7)
			}),
			Rotation = animator:Animation(0, springInfo3, {
				From = math.random(1, 3) * (math.random(1, 2) == 1 and -1 or 1) * 30
			}),
			OnClean = function()
				return {
					Rotation = animator:Animation(-22.5, info2)
				}
			end
		}),
		animator:Create("ImageLabel")({
			Name = "WingRight",
			Image = "rbxassetid://83381746375246",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = animator:Animation(UDim2.fromScale(0.5, 0.5), springInfo2, {
				From = UDim2.fromScale(0.5, 0.7)
			}),
			Rotation = animator:Animation(0, springInfo3, {
				From = math.random(1, 3) * (math.random(1, 2) == 1 and -1 or 1) * 30
			}),
			OnClean = function()
				return {
					Rotation = animator:Animation(22.5, info2)
				}
			end
		})
	})
	local v11 = animator:Create("Frame")({
		BackgroundTransparency = 1,
		Name = "WingsHolderIn",
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.3, 0.3),
		ZIndex = 1,
		animator:Create("ImageLabel")({
			Name = "WingLeft",
			Image = "rbxassetid://133649793896076",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = animator:Animation(UDim2.fromScale(0.5, 0.5), springInfo2, {
				From = UDim2.fromScale(0.5, 0.7)
			}),
			Rotation = animator:Animation(0, springInfo3, {
				From = math.random(1, 3) * (math.random(1, 2) == 1 and -1 or 1) * 30
			}),
			OnClean = function()
				return {
					Rotation = animator:Animation(-10, info2)
				}
			end
		}),
		animator:Create("ImageLabel")({
			Name = "WingRight",
			Image = "rbxassetid://83767820309973",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = animator:Animation(UDim2.fromScale(0.5, 0.5), springInfo2, {
				From = UDim2.fromScale(0.5, 0.7)
			}),
			Rotation = animator:Animation(0, springInfo4, {
				From = math.random(1, 3) * (math.random(1, 2) == 1 and -1 or 1) * 25
			}),
			OnClean = function()
				return {
					Rotation = animator:Animation(10, info2)
				}
			end
		})
	})
	local v12 = animator:Create("Frame")
	local v13 = {
		Position = animator:Animation(UDim2.fromScale(0.5, 0.65), springInfo3, {
			From = UDim2.fromScale(0.5, 0.7)
		}),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.2, 0.05),
		BackgroundTransparency = 1,
		Name = "RewardsHolder"
	}
	local v14 = animator:Create("Frame")({
		Name = "Bg",
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		Transparency = 0.3,
		animator:Create("UICorner")({
			CornerRadius = UDim.new(0.25)
		}),
		animator:Create("UIStroke")({
			Thickness = 1,
			BorderOffset = UDim.new(0, -3),
			Color = Color3.new(1, 1, 1),
			Transparency = 0.75
		})
	})
	local v15 = animator:Create("Frame")
	local v16 = {
		Name = "Holder",
		Size = UDim2.fromScale(0.8, 0.8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1
	}
	local v17 = animator:Create("UIListLayout")({
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 3),
		AbsoluteContentSizeOnChangedInit = function(p3)
			p3.Parent.Parent.Bg.Size = UDim2.fromScale(
				p3.AbsoluteContentSize.X / p3.Parent.Parent.AbsoluteSize.X + 0.04,
				1
			)
		end
	})
	local v18

	if v4 ~= nil then
		v18 = animator:Iterate(v4, function(value3, p3, _, _)
			local v19 = color
			local v20 = nil
			local item = Items[value3]
			local v21, icon

			if item then
				v21 = Rarities.Colors[item.Rarity]
				icon = item.Icon
			else
				v21 = gameSettings[value3 .. "Color"] or gameSettings[string.lower(value3) .. "Color"] or v19
				icon = BunchaIcons[value3]
				v20 = v21
			end

			return animator:Create("Frame")({
				CleanDelay = 0.5,
				Size = UDim2.fromScale(1, 1),
				animator:Create("UICorner")({
					CornerRadius = UDim.new(0.25)
				}),
				BackgroundColor3 = v21,
				animator:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.65),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = math.random(1, 3) * 120
				}),
				animator:Create("UIStroke")({
					Thickness = 1,
					BorderOffset = UDim.new(0, -3),
					Transparency = 0.75,
					Color = v21
				}),
				animator:Create("ImageLabel")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(0.9, 0.9),
					Image = icon
				}),
				animator:Create("TextLabel")({
					Size = UDim2.fromScale(2, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					TextScaled = true,
					Text = "x" .. Utility.addCommasToNumber(p3),
					TextColor3 = v20 or color,
					Font = Enum.Font.SourceSansBold,
					Position = UDim2.fromScale(0.5, 0),
					animator:Create("UIStroke")({
						Thickness = 1,
						Transparency = 0.75
					})
				})
			})
		end) or nil
	end

	v16[2], v16[3] = v17, v18
	do local _values = table.pack(v14, v15(v16)); for _k = 1, _values.n do v13[_k] = _values[_k] end end
	do local _values = table.pack(v7, v8, v9, v10, v11, v12(v13)); for _k = 1, _values.n do v6[1 + _k] = _values[_k] end end
	v5(v6)
	return function()
		animator:Destroy()
	end
end