local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LiveConfig = require(ReplicatedStorage.CAM.Global.LiveConfig)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local RewardsStyling = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.RewardsStyling)
local faye = require(ReplicatedStorage.Packages.faye)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Multipliers = require(ReplicatedStorage.CAM.Global.Multipliers)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local info = faye.Info(0.4)
local info2 = faye.Info(0.65, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
local info3 = faye.Info(0.2)

-- equivalent calls inferred from this helper; original call sites unknown
local function onMobile()
	return Platform_Handler.Platform.Value == "Mobile"
end

local color = Color3.new(1, 0, 0)
return function(maid, p)
	local v = onMobile() -- equivalent call inferred; original call site unknown
	local v3 = v and 16 or 20
	local v5 = v and 16 or 26

	local function chestSize(p2: number)
		return UDim2.new(0, p2, 0, v5)
	end

	local npcCode = p.Folder:GetAttribute("NpcCode")
	local chest = p.Folder:GetAttribute("Chest")
	local chestRarity

	if chest ~= nil then
		chestRarity = p.Folder:GetAttribute("ChestRarity") or 1
	end

	local npcDataTable = LiveConfig.get("NpcDataTable")
	local rewards = p.Rewards or npcDataTable and npcDataTable[npcCode] and npcDataTable[npcCode].Rewards
	local value = maid:Value(0.7)
	local model = p.Folder.Parent:FindFirstChildOfClass("Model")
	maid:Create("Highlight")({
		Parent = model,
		CleanDelay = info.Time,
		FillTransparency = maid:Animation(0.965, info, {
			From = 1
		}),
		OutlineTransparency = maid:Animation(0.25, info, {
			From = 1
		}),
		DepthMode = Enum.HighlightDepthMode.Occluded,
		OnClean = function()
			return {
				FillTransparency = maid:Animation(1, info3),
				OutlineTransparency = maid:Animation(1, info3)
			}
		end
	})
	local humanoid = model:FindFirstChild("Humanoid")

	local function creditPool()
		local maxHealth = humanoid ~= nil and humanoid.MaxHealth or 1
		local baseMaxHealth = model:GetAttribute("BaseMaxHealth")

		if typeof(baseMaxHealth) == "number" and baseMaxHealth > 0 then
			return (math.min(baseMaxHealth, maxHealth))
		end

		return maxHealth
	end

	local v6 = humanoid == nil and 1 or humanoid.MaxHealth or 1
	local baseMaxHealth = model:GetAttribute("BaseMaxHealth")

	if typeof(baseMaxHealth) == "number" and baseMaxHealth > 0 then
		v6 = math.min(baseMaxHealth, v6)
	end

	local value2 = maid:Value(v6)

	local function refreshPool()
		local v8 = humanoid == nil and 1 or humanoid.MaxHealth or 1
		local baseMaxHealth2 = model:GetAttribute("BaseMaxHealth")

		if typeof(baseMaxHealth2) == "number" and baseMaxHealth2 > 0 then
			v8 = math.min(baseMaxHealth2, v8)
		end

		value2:Set(v8)
	end

	if humanoid ~= nil then
		maid:Connect(humanoid:GetPropertyChangedSignal("MaxHealth"), refreshPool)
	end

	maid:Connect(model:GetAttributeChangedSignal("BaseMaxHealth"), refreshPool)
	local textColor = maid:Value(Color3.new(0.945098, 1, 0.913725))
	local v7 = maid:Create("NumberValue")({
		Value = maid:Lerp(value, 0.1)
	})
	local value4 = maid:Value(1)
	local value5 = maid:Value(Color3.new())
	local value6 = maid:Value(0.95)
	local v8 = maid:Create("NumberValue")({
		Value = maid:Lerp(value, 0.05)
	})
	local flag = false
	local text = maid:Value()
	local v9 = {}
	local value8 = maid:Value(v9)

	local function updDMG(instance)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function changeListen(p2)
			maid:Connect(p2.Changed, function(p3)
				value8:Add(p2.Name, p3)
			end)
		end

		for _, child in ipairs(instance:GetChildren()) do
			if v9[child.Name] ~= nil then
				continue
			end

			v9[child.Name] = child.Value
			changeListen(child) -- equivalent call inferred; original call site unknown
		end

		maid:Connect(instance.ChildAdded, function(p2)
			if not value8:ItemExists(p2.Name) then
				value8:Add(p2.Name, p2.Value)
				changeListen(p2) -- equivalent call inferred; original call site unknown
			end
		end)
		maid:Connect(instance.ChildRemoved, function(p2)
			value8:Remove(p2.Name)
		end)
	end

	local DMG = model:FindFirstChild("DMG")

	if DMG == nil then
		local connection = nil
		connection = maid:Add(model.ChildAdded:Connect(function(child)
			if child.Name == "DMG" then
				if connection then
					maid:Remove(connection)
					connection:Disconnect()
					connection = nil
				end

				updDMG(child)
			end
		end))
	else
		updDMG(DMG)
	end

	if humanoid ~= nil then
		local v10 = nil

		local function upd()
			local v11 = humanoid.Health / humanoid.MaxHealth
			text:Set(math.floor(humanoid.Health * 100) / 100 .. " / " .. humanoid.MaxHealth)
			textColor:Set(Utility.Lerp_Color2(color, textColor.Initial, v11))
			value:Set(v11)

			if v10 ~= nil and v11 < v10 then
				value4:Refresh()
				value6:Refresh()
				value5:Refresh()
			end

			v10 = v11
		end

		upd()
		maid:Connect(humanoid.HealthChanged, upd)
	end

	maid:Add(function()
		flag = true
	end, true)
	local v10 = maid:Create("Frame")
	local v11 = {
		v7,
		v8,
		Size = UDim2.fromScale(v and 0.9 or 0.7, 0.85),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		Name = "MainHolder",
		CleanDelay = 0.2
	}
	local v12 = maid:Create("Frame")
	local v13 = {
		Name = "healthBarHolder",
		Size = UDim2.new(1, -4, v and 0.035 or 0.0315),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.065),
		BackgroundTransparency = 1
	}
	local v14 = maid:Create("ImageLabel")({
		Name = "Bg",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1.1, 0.75),
		AnchorPoint = Vector2.new(0.5, 0.45),
		Position = UDim2.fromScale(0.5, 0.825),
		Image = "rbxassetid://96840853773997",
		ImageColor3 = Color3.new(),
		ImageTransparency = maid:Animation(0.855, info3, {
			From = 1
		}),
		OnClean = function()
			return {
				ImageTransparency = maid:Animation(1, info3)
			}
		end
	})
	local v15 = maid:Create("Frame")({
		Size = UDim2.fromScale(0.135, 1.75),
		Position = UDim2.fromScale(0, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		maid:Create("Frame")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = maid:Animation(0.25, info3, {
				From = 1
			}),
			OnClean = function()
				return {
					BackgroundTransparency = maid:Animation(1, info3)
				}
			end,
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			maid:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			maid:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.7, 0.9),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		maid:Create("TextLabel")({
			Size = UDim2.fromScale(3, 0.7),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.125, 0, 0.5),
			BackgroundTransparency = 1,
			Text = text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextScaled = true,
			TextColor3 = textColor,
			Font = Enum.Font.ArialBold,
			TextTransparency = maid:Animation(0, info3, {
				From = 1
			}),
			OnClean = function()
				return {
					TextTransparency = maid:Animation(1, info3)
				}
			end,
			maid:Create("UIStroke")({
				Thickness = 2,
				Transparency = 0.875,
				OnClean = function()
					return {
						Transparency = maid:Animation(1, info3)
					}
				end
			})
		})
	})
	local v16

	if chest ~= nil then
		v16 = maid:Create("CanvasGroup")({
			Size = UDim2.new(0, 300, 0, v5),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 0),
			BackgroundTransparency = 0.55,
			GroupTransparency = maid:Animation(0, info3, {
				From = 1
			}),
			OnClean = function()
				return {
					GroupTransparency = maid:Animation(1, info3)
				}
			end,
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
			maid:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			maid:Create("Frame")({
				Name = "bg",
				Size = UDim2.new(1, -4, 1, -4),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Rarities.Colors[chestRarity],
				ZIndex = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				maid:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				maid:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.2),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = -90
				})
			}),
			maid:Create("Frame")({
				Name = "Holder",
				Size = UDim2.new(1, -2, 1, -2),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				maid:Create("UIListLayout")({
					Name = "List",
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 1),
					[maid:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
						local parent = p2.Parent.Parent
						local v25 = p2.AbsoluteContentSize.X + 6
						parent.Size = UDim2.new(0, v25, 0, v5)
					end
				}),
				maid:Create("ImageLabel")({
					Size = UDim2.fromScale(0.2, 1),
					Instance.new("UIAspectRatioConstraint"),
					BackgroundTransparency = 1,
					Image = "rbxassetid://75570968913357"
				}),
				maid:Create("TextLabel")({
					Name = "ChestName",
					Size = UDim2.fromScale(100, 0.8),
					BackgroundTransparency = 1,
					Text = chest,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0,
					TextBoundsOnChangedInit = function(state)
						if state.AbsoluteSize.Y <= 0 or state.TextBounds.X <= 0 then
							return
						end

						local v25 = state.TextBounds.X + 2
						state.Size = UDim2.new(0, v25, 0.8, 0)
					end,
					maid:Create("UIStroke")({
						Transparency = 0.85,
						Thickness = 1.5
					})
				})
			})
		}) or nil
	end

	do local _values = table.pack(v14, v15, v16, maid:Iterate(5, function(p2, _, _, _)
	return maid:Create("Frame")({
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale((p2 - 1) * 0.2, 0.5),
		Size = UDim2.new(0.2, -2, 1, -4),
		BackgroundTransparency = maid:Animation(0.75, info3, {
			From = 1
		}),
		BackgroundColor3 = Color3.new(),
		OnClean = function()
			return {
				BackgroundTransparency = maid:Animation(1, info3)
			}
		end,
		maid:Create("UICorner")({
			CornerRadius = UDim.new(0.25)
		}),
		maid:Create("Frame")({
			Name = "bar",
			ZIndex = 2,
			BackgroundColor3 = Color3.new(1, 0, 0),
			BackgroundTransparency = maid:Animation(0, info3, {
				From = 1
			}),
			OnClean = function()
				return {
					BackgroundTransparency = maid:Animation(1, info3)
				}
			end,
			Size = maid:Do(function(callback, _, _)
				local v17 = callback(v7)
				return UDim2.fromScale(math.clamp(v17 * 5 - (p2 - 1), 0, 1), 1)
			end),
			maid:Create("UICorner")({
				CornerRadius = UDim.new(0.25)
			}),
			maid:Create("ImageLabel")({
				Name = "Inner",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://96840853773997",
				ImageColor3 = Color3.new(),
				ImageTransparency = 0.855
			})
		}),
		maid:Create("Frame")({
			Name = "barwhite",
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = maid:Animation(0, info3, {
				From = 1
			}),
			OnClean = function()
				return {
					BackgroundTransparency = maid:Animation(1, info3)
				}
			end,
			Size = maid:Do(function(callback, _, _)
				local v17 = callback(v8)
				return UDim2.fromScale(math.clamp(v17 * 5 - (p2 - 1), 0, 1), 1)
			end),
			maid:Create("UICorner")({
				CornerRadius = UDim.new(0.25)
			})
		}),
		maid:Create("UIStroke")({
			Transparency = maid:Animation(value6, info, {
				AlwaysFrom = 0,
				From = value6.Value
			}),
			Color = maid:Animation(value5, info2, {
				AlwaysFrom = Color3.new(1, 1, 1),
				From = value5.Value
			}),
			Thickness = maid:Animation(value4, info, {
				AlwaysFrom = 2,
				From = value4.Value
			})
		})
	})
end)); for _k = 1, _values.n do v13[_k] = _values[_k] end end
	do local _values = table.pack(v12(v13), function()
	if rewards == nil then
		return nil
	end

	local v17 = {
		Mastery = true
	}
	local v18 = {
		Exp = true,
		Wen = true
	}
	local v19 = {}
	local v20 = {}

	for k, reward in rewards do
		if v17[k] then
			continue
		end

		if v18[k] then
			if type(reward) == "number" then
				table.insert(v19, {
					Name = k,
					Value = reward
				})
			end
		elseif type(reward) == "table" and reward.Chance ~= nil then
			table.insert(v20, {
				Name = k,
				Value = reward
			})
		elseif type(reward) == "number" and (Items[k] ~= nil or Stats.GetSkillInfo(k) ~= nil) then
			table.insert(v20, {
				Name = k,
				Value = {
					Chance = reward,
					Quantity = 1
				}
			})
		end
	end

	local data = Utility.GetData(Players.LocalPlayer, true)
	local skillTreeUnlockedList = data and data:FindFirstChild("SkillTreeUnlockedList")
	local value9 = maid:Value(not data and 0 or math.floor(data.Exp.Goal.Value / gameSettings.expPerLevel) or 0)
	local v21

	if data then
		local v22 = value9:Get()
		local flag2 = true

		for _, v23 in v20 do
			if not (v23.Value.Level ~= nil and v22 < v23.Value.Level) then
				continue
			end

			v21 = true
			flag2 = false
			break
		end

		if flag2 then
			v21 = false
		end
	else
		v21 = data
	end

	if v21 then
		maid:Connect(data.Exp.Goal.Changed, function(p2)
			value9:Set((math.floor(p2 / gameSettings.expPerLevel)))
		end)
	end

	return maid:Create("CanvasGroup")({
		Name = "RewardsHolder",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromScale(0, 0.105),
		BackgroundTransparency = 1,
		GroupTransparency = maid:Animation(0, info3, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = maid:Animation(1, info3)
			}
		end,
		maid:Create("UIListLayout")({
			Name = "List",
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4)
		}),
		function()
			if #v19 == 0 then
				return nil
			end

			return maid:Create("Frame")({
				Name = "CurrenciesRow",
				Size = UDim2.new(0, 0, 0, v3),
				BackgroundTransparency = 1,
				maid:Create("UIListLayout")({
					Name = "List",
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 4),
					[maid:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
						p2.Parent.Size = UDim2.new(0, p2.AbsoluteContentSize.X, 0, v3)
					end
				}),
				maid:Iterate(v19, function(_, p2, maid2)
					local iconAndColor, textColor2 = RewardsStyling.GetIconAndColor(p2.Name)
					local text2 = maid2:Value("+" .. Utility.addCommasToNumber(p2.Value))

					if p2.Name == "Exp" then
						local function refreshAmount()
							local v27 = math.floor(p2.Value * Multipliers.ExpGain(nil, "NpcReward"))
							local expGainTag = Multipliers.ExpGainTag(nil, "NpcReward")
							text2:Set("+" .. Utility.addCommasToNumber(v27) .. (expGainTag == nil and "" or ` ({expGainTag})`))
						end

						refreshAmount()

						for _, v27 in Multipliers.Kinds.Exp do
							maid2:Connect(Multipliers.Changed(v27), refreshAmount)
						end

						maid2:Add(PlayerStatResolver.Attach(Players.LocalPlayer, "Exp Factor", refreshAmount))
					elseif p2.Name == "Wen" then
						local function refreshAmount()
							local v27 = math.floor(p2.Value * Multipliers.WenGain(nil, "NpcReward"))
							local wenGainTag = Multipliers.WenGainTag(nil, "NpcReward")
							text2:Set("+" .. Utility.addCommasToNumber(v27) .. (wenGainTag == nil and "" or ` ({wenGainTag})`))
						end

						refreshAmount()

						for _, v27 in Multipliers.Kinds.Wen do
							maid2:Connect(Multipliers.Changed(v27), refreshAmount)
						end
					end

					return maid2:Create("Frame")({
						Name = p2.Name,
						Size = UDim2.new(1, 0, 0, v3),
						BackgroundTransparency = 0.55,
						BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
						CleanDelay = function()
							if flag then
								return info.Time
							end

							return nil
						end,
						maid2:Create("UICorner")({
							CornerRadius = UDim.new(1)
						}),
						maid2:Create("UIStroke")({
							BorderOffset = UDim.new(0, -3),
							Transparency = 0.85,
							Color = Color3.new(1, 1, 1)
						}),
						maid2:Create("Frame")({
							Name = "Holder",
							Size = UDim2.new(1, -4, 1, -4),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							BackgroundTransparency = 1,
							maid2:Create("UIListLayout")({
								Name = "List",
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								Padding = UDim.new(0, 2),
								[maid2:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p3)
									p3.Parent.Parent.Size = UDim2.new(0, p3.AbsoluteContentSize.X, 1, 0)
								end
							}),
							maid2:Create("ImageLabel")({
								Image = iconAndColor,
								Name = "Img",
								Size = UDim2.fromScale(1, 1.25),
								BackgroundTransparency = 1,
								Instance.new("UIAspectRatioConstraint")
							}),
							maid2:Create("TextLabel")({
								Name = "ItemName",
								Size = UDim2.fromScale(100, 1),
								BackgroundTransparency = 1,
								Text = p2.Name,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextScaled = true,
								Font = Enum.Font.SourceSansSemibold,
								TextColor3 = Color3.new(1, 1, 1),
								TextTransparency = 0.2,
								maid2:Create("UIStroke")({
									Transparency = 0.75,
									Thickness = 1.5
								}),
								TextBoundsOnChangedInit = function(p3)
									if p3.TextBounds.X > 0 then
										p3.Size = UDim2.new(0, p3.TextBounds.X + 2, 1, 0)
									end
								end
							}),
							maid2:Create("TextLabel")({
								Name = "Txt",
								Size = UDim2.fromScale(100, 1),
								BackgroundTransparency = 1,
								Text = text2,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextScaled = true,
								Font = Enum.Font.SourceSansSemibold,
								TextColor3 = textColor2,
								maid2:Create("UIStroke")({
									Transparency = 0.75,
									Thickness = 1.5
								}),
								TextBoundsOnChangedInit = function(p3)
									if p3.TextBounds.X > 0 then
										p3.Size = UDim2.new(0, p3.TextBounds.X + 10, 1, 0)
									end
								end
							})
						})
					})
				end)
			})
		end,
		maid:Iterate(v20, function(_, p2, maid2)
			local iconAndColor, textColor2 = RewardsStyling.GetIconAndColor(p2.Name)
			local v23

			if Items[p2.Name] == nil then
				v23 = Stats.GetSkillInfo(p2.Name) ~= nil
			else
				v23 = false
			end

			local v24 = v23 and Stats.GetSkillInfo(p2.Name)
			local localPlayer = Players.LocalPlayer
			local text2 = maid2:Value("")

			local function refreshChance()
				local v25 = math.min(p2.Value.Chance * Multipliers.DropLuck(), 0.99)
				local v26 = Multipliers.TagOf("Luck")
				text2:Set("x" .. Utility.addCommasToNumber(p2.Value.Quantity or 1) .. " (" .. string.format("%.4g", v25 * 100) .. "%)" .. (v26 == nil and "" or ` ({v26})`))
			end

			refreshChance()

			for _, v25 in Multipliers.Kinds.Luck do
				maid2:Connect(Multipliers.Changed(v25), refreshChance)
			end

			maid2:Add(PlayerStatResolver.Attach(localPlayer, "Drop Luck Factor", refreshChance))
			local v25

			if v23 then
				v25 = not Character_info_provider.IsSkillAvailable(localPlayer, p2.Name) or false
			else
				v25 = false
			end

			local value11 = maid2:Value(v25)
			local v26

			if v23 then
				v26 = Character_info_provider.GetSkillDimReason(localPlayer, p2.Name) or nil
			end

			local value12 = maid2:Value(v26)

			if v23 and skillTreeUnlockedList then
				-- equivalent calls inferred from this helper; original call sites unknown
				local function refresh()
					local v27 = not Character_info_provider.IsSkillAvailable(localPlayer, p2.Name)
					value11:Set(v27)
					value12:Set(v27 and Character_info_provider.GetSkillDimReason(localPlayer, p2.Name) or nil)
				end

				maid2:Connect(skillTreeUnlockedList.ChildAdded, function(valueBase)
					refresh() -- equivalent call inferred; original call site unknown

					if valueBase:IsA("ValueBase") then
						maid2:Connect(valueBase.Changed, refresh)
					end
				end)

				for _, valueBase in skillTreeUnlockedList:GetChildren() do
					if valueBase:IsA("ValueBase") then
						maid2:Connect(valueBase.Changed, refresh)
					end
				end

				if data then
					maid2:Connect(data.MetRequirements.Boss.ChildAdded, refresh)

					if v24 and v24.CategoryType == "Weapon" and v24.Category ~= nil then
						local inventory = data:FindFirstChild("Inventory")
						local inventory2 = inventory and inventory:FindFirstChild("Inventory")

						if inventory2 then
							maid2:Connect(inventory2.ChildAdded, function(p3)
								if p3.Name == v24.Category then
									refresh() -- equivalent call inferred; original call site unknown
								end
							end)
						end
					end
				end
			end

			local textTransparency = maid2:Value(value11:Get() and 0.5 or 0)
			local imageTransparency = maid2:Value(value11:Get() and 0.5 or 0)
			maid2:Connect(value11.Changed, function(p3)
				textTransparency:Set(p3 and 0.5 or 0)
				imageTransparency:Set(p3 and 0.5 or 0)
			end)
			return maid2:Create("Frame")({
				Name = p2.Name,
				Size = UDim2.new(1, 0, 0, v3),
				BackgroundTransparency = 0.55,
				BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
				ClipsDescendants = false,
				CleanDelay = function()
					if flag then
						return info.Time
					end

					return nil
				end,
				maid2:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				maid2:Create("UIStroke")({
					BorderOffset = UDim.new(0, -3),
					Transparency = 0.85,
					Color = Color3.new(1, 1, 1)
				}),
				maid2:State(function(callback, object)
					local text3 = callback(value12)

					if text3 == nil then
						return nil
					end

					return object:Create("Frame")({
						Name = "ReasonTag",
						Size = UDim2.fromScale(1, 1),
						AnchorPoint = Vector2.new(0, 0.5),
						CleanDelay = function()
							if flag then
								return info.Time
							end

							return nil
						end,
						Position = UDim2.new(1, 4, 0.5, 0),
						BackgroundColor3 = Color3.fromRGB(140, 30, 30),
						BackgroundTransparency = 0.55,
						ZIndex = 4,
						object:Create("UICorner")({
							CornerRadius = UDim.new(1)
						}),
						object:Create("TextLabel")({
							Name = "Txt",
							Size = UDim2.fromScale(100, 1),
							BackgroundTransparency = 1,
							Text = text3,
							TextScaled = true,
							Position = UDim2.new(0, 6, 0, 0),
							Font = Enum.Font.SourceSans,
							TextColor3 = Color3.new(1, 0.75, 0.75),
							TextTransparency = 0,
							TextXAlignment = Enum.TextXAlignment.Left,
							object:Create("UIStroke")({
								Transparency = 0.45,
								Thickness = 1
							}),
							TextBoundsOnChangedInit = function(p3)
								if p3.TextBounds.X > 0 then
									p3.Parent.Size = UDim2.new(0, p3.TextBounds.X + 12, 1, 0)
								end
							end
						})
					})
				end),
				maid2:State(function(callback, object)
					local level = p2.Value.Level

					if level == nil or level <= callback(value9) then
						return nil
					end

					return object:Create("Frame")({
						Name = "LevelTag",
						Size = UDim2.fromScale(1, 1),
						AnchorPoint = Vector2.new(0, 0.5),
						CleanDelay = function()
							if flag then
								return info.Time
							end

							return nil
						end,
						Position = UDim2.new(1, 4, 0.5, 0),
						BackgroundColor3 = Color3.fromRGB(130, 14, 10),
						BackgroundTransparency = 0.55,
						ZIndex = 4,
						object:Create("UICorner")({
							CornerRadius = UDim.new(1)
						}),
						object:Create("TextLabel")({
							Name = "Txt",
							Size = UDim2.fromScale(100, 1),
							BackgroundTransparency = 1,
							Text = "Lvl. " .. level,
							TextScaled = true,
							Position = UDim2.new(0, 6, 0, 0),
							Font = Enum.Font.SourceSansSemibold,
							TextColor3 = Color3.new(1, 0.701961, 0.701961),
							TextTransparency = 0,
							TextXAlignment = Enum.TextXAlignment.Left,
							object:Create("UIStroke")({
								Transparency = 0.45,
								Thickness = 1
							}),
							TextBoundsOnChangedInit = function(p3)
								if p3.TextBounds.X > 0 then
									p3.Parent.Size = UDim2.new(0, p3.TextBounds.X + 12, 1, 0)
								end
							end
						})
					})
				end),
				maid2:State(function(callback)
					if callback(value11) then
						return maid2:Create("Frame")({
							Name = "Line",
							Size = UDim2.new(1, 4, 0, 1),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BackgroundTransparency = 0.5,
							BorderSizePixel = 0,
							ZIndex = 3
						})
					end

					return nil
				end),
				maid2:Create("Frame")({
					Name = "Holder",
					Size = UDim2.new(1, -4, 1, -4),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					maid2:Create("UIListLayout")({
						Name = "List",
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 2),
						[maid2:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p3)
							p3.Parent.Parent.Size = UDim2.new(0, p3.AbsoluteContentSize.X, 0, v3)
						end
					}),
					maid2:Create("Frame")({
						Size = UDim2.fromScale(1, 1.25),
						Instance.new("UIAspectRatioConstraint"),
						BackgroundTransparency = 1,
						Name = "IconHolder",
						maid2:Create("ImageLabel")({
							Name = "Bg",
							ZIndex = -1,
							Size = UDim2.fromScale(1.7, 1.7),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.6, 0.5),
							BackgroundTransparency = 1,
							Image = "rbxassetid://93437195955932",
							ImageTransparency = 0.5,
							ImageColor3 = Color3.new(0.15, 0.15, 0.15)
						}),
						maid2:Create("ImageLabel")({
							Image = iconAndColor,
							Name = "Img",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							ImageTransparency = imageTransparency
						})
					}),
					maid2:Create("TextLabel")({
						Name = "ItemName",
						Size = UDim2.fromScale(100, 1),
						BackgroundTransparency = 1,
						Text = p2.Name,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						Font = Enum.Font.SourceSansSemibold,
						TextColor3 = Color3.new(1, 1, 1),
						TextTransparency = textTransparency,
						maid2:Create("UIStroke")({
							Transparency = 0.75,
							Thickness = 1.5
						}),
						TextBoundsOnChangedInit = function(p3)
							if p3.TextBounds.X > 0 then
								p3.Size = UDim2.new(0, p3.TextBounds.X + 4, 1, 0)
							end
						end
					}),
					maid2:Create("TextLabel")({
						Name = "Txt",
						Size = UDim2.fromScale(100, 1),
						BackgroundTransparency = 1,
						Text = text2,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						Font = Enum.Font.SourceSansSemibold,
						TextTransparency = textTransparency,
						TextColor3 = textColor2,
						maid2:Create("UIStroke")({
							Transparency = 0.75,
							Thickness = 1.5
						}),
						TextBoundsOnChangedInit = function(p3)
							if p3.TextBounds.X > 0 then
								p3.Size = UDim2.new(0, p3.TextBounds.X + 2, 1, 0)
							end
						end
					})
				})
			})
		end)
	})
end, maid:Create("CanvasGroup")({
	Position = UDim2.fromScale(0, 0.105),
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	maid:Create("UIListLayout")({
		Name = "List",
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4)
	}),
	GroupTransparency = maid:Animation(0, info3, {
		From = 1
	}),
	OnClean = function()
		return {
			GroupTransparency = maid:Animation(1, info3)
		}
	end,
	maid:AdvancedIterate(value8, function(childName, p2, object, _)
		local child = Players:FindFirstChild(childName)
		local text2

		if child then
			text2 = child.Name
		else
			text2 = childName
		end

		return object:Create("Frame")({
			Name = childName,
			Size = UDim2.new(1, 0, 0, v3),
			BackgroundTransparency = 0.55,
			CleanDelay = function()
				if flag then
					return info.Time
				end

				return nil
			end,
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("UIStroke")({
				BorderOffset = UDim.new(0, -3),
				Transparency = 0.85,
				Color = Color3.new(1, 1, 1)
			}),
			object:Create("Frame")({
				Name = "Holder",
				Size = UDim2.new(1, -4, 1, -4),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				object:Create("UIListLayout")({
					Name = "List",
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2),
					AbsoluteContentSizeOnChangedInit = function(p3, point: Vector2)
						if point.X <= 0 then
							return
						end

						local parent = p3.Parent
						local parent2

						if parent ~= nil then
							parent2 = parent.Parent or nil
						end

						if parent2 == nil then
							return
						end

						parent2.Size = UDim2.new(0, point.X + 6, 0, v3)
					end
				}),
				object:Create("TextLabel")({
					Name = "PlayerName",
					LayoutOrder = 1,
					Size = UDim2.fromScale(100, 1),
					BackgroundTransparency = 1,
					Text = text2,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0.2,
					object:Create("UIStroke")({
						Transparency = 0.85,
						Thickness = 1.5
					}),
					After = function(p3)
						p3.Size = UDim2.new(0, p3.TextBounds.X + 2, 1, 0)
					end
				}),
				object:State(function(callback, object2)
					local v18 = p2 / callback(value2)
					return object2:Create("TextLabel")({
						Name = "Txt",
						LayoutOrder = 2,
						Size = UDim2.fromScale(100, 1),
						BackgroundTransparency = 1,
						Text = Utility.addCommasToNumber(math.floor(p2 * 100) / 100) .. " (" .. math.floor(v18 * 100) .. "%)",
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						Font = Enum.Font.SourceSansSemibold,
						TextColor3 = Color3.new(1, 1, 1),
						TextTransparency = 0,
						object2:Create("UIStroke")({
							Transparency = 0.75,
							Thickness = 1.5
						}),
						After = function(p3)
							p3.Size = UDim2.new(0, p3.TextBounds.X + 2, 1, 0)
						end
					})
				end)
			})
		})
	end)
})); for _k = 1, _values.n do v11[2 + _k] = _values[_k] end end
	return v10(v11)
end