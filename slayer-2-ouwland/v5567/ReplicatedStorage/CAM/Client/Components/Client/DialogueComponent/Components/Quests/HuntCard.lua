local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local BossHunts = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.BossHunts)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local RewardsStyling = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.RewardsStyling)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Multipliers = require(ReplicatedStorage.CAM.Global.Multipliers)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
local Transition = require(script.Parent.Transition)
require(script.Parent.Types)
local info = Transition.Info
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0.5, 0.5, 0.5)
local v = {
	Common = 0.97,
	UnCommon = 0.95,
	Rare = 0.92,
	Epic = 0.88,
	Legendary = 0.82,
	Mythic = 0.74
}
local v2 = {
	Muzan = BunchaIcons.MuzanIcon,
	Crow = BunchaIcons.CrowIcon
}

-- equivalent calls inferred from this helper; original call sites unknown
local function loadRegions()
	return require(ReplicatedStorage.Regions)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function loadDialogues()
	return require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
end

local function playerRace()
	local Utility2 = require(ReplicatedStorage.CAM.Global.Utility)
	local data = Utility2.GetData(localPlayer)
	return data ~= nil and data.Race.Value or nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bossIcon(data)
	local regions = loadRegions() -- equivalent call inferred; original call site unknown
	return regions.GetNpcIcon(data.Boss) or v2[data.Side]
end

local function rewardsOf(data)
	require(ReplicatedStorage.Regions)
	local questInfo = Quests.GetQuestInfo(data.Quest)
	local entry = BossHunts.Entry(data.Boss)
	local rewards = questInfo ~= nil and questInfo.Rewards or entry == nil and {} or BossHunts.Rewards(entry) or {}
	local v3 = entry == nil and 1 or BossHunts.Factor(entry)
	local result = {}
	local maxLevelMastery = questInfo ~= nil and questInfo.MaxLevelMastery or entry ~= nil and BossHunts.MaxLevelMastery(entry) or nil

	if maxLevelMastery == nil or not Quests.AtLevelCap(localPlayer) then
		if rewards.Exp ~= nil then
			table.insert(result, {
				Icon = BunchaIcons.Exp,
				Amount = math.floor(rewards.Exp * v3 * Multipliers.ExpGain(nil, "Quest")),
				Tag = Multipliers.ExpGainTag(nil, "Quest")
			})
		end
	else
		table.insert(result, {
			Icon = RewardsStyling.GetIconAndColor("FlatMastery"),
			Amount = maxLevelMastery * v3
		})
	end

	if rewards.Wen ~= nil then
		table.insert(result, {
			Icon = BunchaIcons.Wen,
			Amount = math.floor(rewards.Wen * v3 * Multipliers.WenGain(nil, "Quest")),
			Tag = Multipliers.WenGainTag(nil, "Quest")
		})
	end

	for k, reward in rewards do
		local item = Items[k]

		if item ~= nil and typeof(reward) == "table" and reward.Quantity ~= nil then
			table.insert(result, {
				Icon = item.Icon,
				Amount = reward.Quantity
			})
		end
	end

	return result
end

return function(object, data, p: string, p2, size)
	local function remaining()
		return (math.max(0, data.ExpiresAt - workspace:GetServerTimeNow()))
	end

	local text = object:Value(Utility.formatTime((math.max(0, data.ExpiresAt - workspace:GetServerTimeNow()))))
	object:Spawn(function()
		while true do
			task.wait(0.25)
			text:Set(Utility.formatTime((math.max(0, data.ExpiresAt - workspace:GetServerTimeNow()))))
		end
	end)
	local v3 = Rarities.Colors[table.find(Rarities.Order, data.Tier)] or color
	local v4 = v[data.Tier] or 0.97
	local entry = BossHunts.Entry(data.Boss)
	local data2 = Utility.GetData(localPlayer)
	local goal

	if data2 == nil then
		goal = nil
	else
		goal = data2.Exp.Goal or nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function lockedBecause()
		if goal == nil or entry == nil then
			return ""
		end

		local v5 = goal.Value / gameSettings.expPerLevel

		if v5 < entry.MinLevel then
			return (`Min level is {entry.MinLevel}`)
		end

		if entry.MaxLevel == nil or not (entry.MaxLevel < v5) then
			return ""
		end

		return (`Max level is {entry.MaxLevel}`)
	end

	local v5 = lockedBecause() -- equivalent call inferred; original call site unknown
	local value2 = object:Value(v5)

	if goal ~= nil then
		object:Connect(goal.Changed, function()
			local v7 = lockedBecause() -- equivalent call inferred; original call site unknown
			value2:Set(v7)
		end)
	end

	local v6 = rewardsOf(data)
	local v7 = {}
	local v8 = {}
	local zero = Vector2.zero
	local v9 = 0.8

	local function refitRewards()
		if zero.X <= 0 or zero.Y <= 0 then
			return
		end

		local total = 0

		for k in v6 do
			local v10 = v7[k]

			if v10 == nil or v8[k] == nil then
				return
			else
				total += v10 + 1
			end
		end

		local v10 = math.max(#v6 - 1, 0) * 4 + #v6 * 3
		local v11 = math.clamp((zero.X * 0.97 - v10) / (zero.Y * total), 0, 0.8)

		if math.abs(v11 - v9) > 0.02 then
			v9 = v11
		end

		local v12 = v9 * zero.Y

		for k, v13 in v8 do
			local v14 = v12 * (v7[k] + 1) + 3
			v13:Set(UDim2.fromScale(v14 / zero.X, v9))
		end
	end

	local flag = false
	local value3 = object:Value(0.35)
	local value4 = object:Value(0.25)
	local value5 = object:Value(v4)

	local function applyEmphasis(flag2: boolean)
		if flag2 then
			value3:Set(0.1)
			value4:Set(0)
			value5:Set((math.max(v4 - 0.15, 0)))
		else
			value3:Reset()
			value4:Reset()
			value5:Reset()
		end
	end

	local v10 = object:Create("Frame")
	local v11 = {
		Name = `Hunt{data.Id}`,
		Size = size,
		BackgroundColor3 = Color3.new(0.065, 0.065, 0.065),
		BackgroundTransparency = object:Animation(value3, info, {
			From = 1
		}),
		OnClean = Transition.FadeOutOnClean()
	}
	local v12 = object:Create("UICorner")({
		CornerRadius = UDim.new(0.25)
	})
	local v13 = object:Create("Frame")({
		Name = "Glow",
		ZIndex = -1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = v3,
		BackgroundTransparency = 0.95,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.25)
		}),
		object:Create("UIShadow")({
			BlurRadius = UDim.new(0.8),
			Color = v3,
			Transparency = object:Animation(value5, info, {
				From = 1
			})
		})
	})
	local v14 = object:Create("Frame")
	local v15 = {
		Name = "Content",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}
	local v16 = object:Create("UIPadding")({
		PaddingLeft = UDim.new(0.01, 0),
		PaddingRight = UDim.new(0.015, 0),
		PaddingTop = UDim.new(0.03, 0),
		PaddingBottom = UDim.new(0.03, 0)
	})
	local v22 = object:Create("Frame")({
		Name = "Portrait",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(1, 0.72),
		BackgroundTransparency = 1,
		object:Create("UIAspectRatioConstraint")({}),
		object:Create("ImageLabel")({
			Name = "Boss",
			ZIndex = 5,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = bossIcon(data),
			ImageTransparency = object:Animation(value4, info, {
				From = 1
			})
		}),
		object:Create("Frame")({
			Name = "Bg",
			ZIndex = -1,
			Size = UDim2.fromScale(0.8, 0.8),
			Instance.new("UIAspectRatioConstraint"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = 45,
			BackgroundTransparency = 0.7,
			BackgroundColor3 = v3,
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0.8)
				}),
				Rotation = -90
			}),
			object:Create("UIShadow")({
				BlurRadius = UDim.new(1),
				Color = v3,
				Transparency = 0.8
			})
		})
	})
	local v23 = object:Create("TextLabel")
	local v24 = {
		Name = "Quest",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0.21, 0.5),
		Size = UDim2.fromScale(0.53, 0.5),
		BackgroundTransparency = 1,
		Text = 0,
		TextScaled = true,
		TextXAlignment = 0,
		TextYAlignment = 0,
		TextColor3 = 0,
		TextTransparency = 0,
		Font = 0
	}
	local title = BossHunts.Title
	local boss = data.Boss
	local Utility2 = require(ReplicatedStorage.CAM.Global.Utility)
	local data3 = Utility2.GetData(localPlayer)
	local v25

	if data3 ~= nil then
		v25 = data3.Race.Value or nil
	end

	v24.Text = title(boss, v25)
	v24.TextXAlignment = Enum.TextXAlignment.Left
	v24.TextYAlignment = Enum.TextYAlignment.Bottom
	v24.TextColor3 = color
	v24.TextTransparency = object:Animation(value4, info, {
		From = 1
	})
	v24.Font = Enum.Font.SourceSansBold
	do local _values = table.pack(v16, v22, v23(v24), object:Create("Frame")({
	Name = "Rewards",
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.fromScale(0.19, 0.5),
	Size = UDim2.fromScale(0.55, 0.5),
	BackgroundTransparency = 1,
	AbsoluteSizeOnChangedInit = function(p4)
		zero = p4.AbsoluteSize
		refitRewards()
	end,
	object:Create("UIListLayout")({
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4)
	}),
	object:Iterate(v6, function(layoutOrder: number, data4, object2)
		local size2 = object2:Value(UDim2.fromScale(1 / math.max(#v6, 1), 0.8))
		v8[layoutOrder] = size2
		return object2:Create("Frame")({
			Name = `Reward{layoutOrder}`,
			LayoutOrder = layoutOrder,
			Size = size2,
			BackgroundTransparency = 1,
			object2:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 3)
			}),
			object2:Create("ImageLabel")({
				Name = "Icon",
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = data4.Icon,
				ImageTransparency = object2:Animation(value4, info, {
					From = 1
				}),
				object2:Create("UIAspectRatioConstraint")({
					DominantAxis = Enum.DominantAxis.Height
				})
			}),
			object2:Create("TextLabel")({
				Name = "Amount",
				LayoutOrder = 2,
				Size = UDim2.fromScale(50, 1),
				BackgroundTransparency = 1,
				Text = Utility.addCommasToNumber(data4.Amount) .. (data4.Tag == nil and "" or ` ({data4.Tag})`),
				TextScaled = true,
				TextWrapped = false,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = color,
				TextTransparency = object2:Animation(value4, info, {
					From = 1
				}),
				Font = Enum.Font.SourceSansSemibold,
				TextBoundsOnChangedInit = function(p5)
					local textBounds = p5.TextBounds

					if textBounds.X <= 0 or textBounds.Y <= 0 then
						return
					end

					v7[layoutOrder] = textBounds.X / textBounds.Y
					refitRewards()
				end
			})
		})
	end)
}), object:Create("Frame")({
	Name = "Clock",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.fromScale(1, 0.5),
	Size = UDim2.fromScale(0.21, 0.55),
	BackgroundColor3 = color2,
	BackgroundTransparency = object:Animation(0.85, info, {
		From = 1
	}),
	object:Create("UICorner")({
		CornerRadius = UDim.new(0, 6)
	}),
	object:Create("UIPadding")({
		PaddingLeft = UDim.new(0.06, 0),
		PaddingRight = UDim.new(0.06, 0),
		PaddingTop = UDim.new(0.06, 0),
		PaddingBottom = UDim.new(0.06, 0)
	}),
	object:Create("TextLabel")({
		Name = "Value",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.7),
		BackgroundTransparency = 1,
		Text = text,
		TextScaled = true,
		TextColor3 = color,
		TextTransparency = object:Animation(value4, info, {
			From = 1
		}),
		Font = Enum.Font.SourceSansSemibold
	})
})); for _k = 1, _values.n do v15[_k] = _values[_k] end end
	do local _values = table.pack(v12, v13, v14(v15), object:Create("TextButton")({
	Name = "Claim",
	ZIndex = 3,
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	MouseButton1Click = function()
		ScreenEffects.CircleClick()
		local canAddQuest, reason, blocking = Quests.CanAddQuest(localPlayer, data.Quest)

		if canAddQuest then
			SignalEvent.ToServer("BossHuntsRequest", {
				action = "Claim",
				id = data.Id
			})
			return
		end

		p2.HuntDenial = {
			Reason = reason,
			Blocking = blocking
		}
		local dialogues = loadDialogues() -- equivalent call inferred; original call site unknown
		dialogues.AttemptDialogue:Fire(p)
	end,
	MouseEnter = function()
		if flag then
			return
		end

		flag = true
		value3:Set(0.1)
		value4:Set(0)
		value5:Set((math.max(v4 - 0.15, 0)))
	end,
	MouseLeave = function()
		if not flag then
			return
		end

		flag = false
		value3:Reset()
		value4:Reset()
		value5:Reset()
	end
}), object:State(function(callback, object2)
	local text2 = callback(value2)

	if text2 == "" then
		return
	else
		return object2:Create("CanvasGroup")({
			Name = "LevelCover",
			ZIndex = 10,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			GroupTransparency = object2:Animation(0, info, {
				From = 1
			}),
			OnClean = {
				GroupTransparency = object2:Animation(1, info)
			},
			object2:Create("TextButton")({
				Name = "Plate",
				CleanDelay = info.Time,
				Size = UDim2.fromScale(1, 1),
				Text = "",
				AutoButtonColor = false,
				BackgroundColor3 = Color3.new(),
				BackgroundTransparency = 0.25,
				object2:Create("UICorner")({
					CornerRadius = UDim.new(0.25)
				}),
				object2:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 6)
				}),
				object2:Create("ImageLabel")({
					Name = "Lock",
					LayoutOrder = 1,
					Size = UDim2.fromScale(0.34, 0.34),
					BackgroundTransparency = 1,
					Image = BunchaIcons.Locked,
					object2:Create("UIAspectRatioConstraint")({})
				}),
				object2:Create("TextLabel")({
					Name = "Reason",
					LayoutOrder = 2,
					Size = UDim2.fromScale(0.46, 0.3),
					BackgroundTransparency = 1,
					Text = text2,
					TextScaled = true,
					TextWrapped = false,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = color,
					Font = Enum.Font.SourceSansBold
				})
			})
		})
	end
end)); for _k = 1, _values.n do v11[_k] = _values[_k] end end
	return v10(v11)
end