local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskComponent = require(script.Parent.TaskComponent)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local RewardsStyling = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.RewardsStyling)
local Resolve = require(ReplicatedStorage.CAM.Global.Powers.Resolve)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Multipliers = require(ReplicatedStorage.CAM.Global.Multipliers)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local faye = require(ReplicatedStorage.Packages.faye)
require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2)
local modulesByName = {}

for _, moduleScript in script.Parent.Events:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

local v = {}
local v2 = false
local info2 = faye.Info(0.2)

function addToTimerTracker(p, vting)
	p.vting = vting
	table.insert(v, p)

	if not v2 then
		v2 = true
		task.spawn(function()
			while #v > 0 do
				for _, v3 in ipairs(v) do
					local value = v3.vting.Started.Value
					local value2 = v3.vting.Target.Value

					if value ~= 0 then
						value2 = value + value2 - os.time()
					end

					v3:Set(value2)
				end

				task.wait(1)
			end

			v2 = false
		end)
	end
end

function removeFromTimerTracker(p)
	local index = table.find(v, p)

	if index ~= nil then
		table.remove(v, index)
	end
end

return function(maid, _: string, instance, p: number)
	local questString = instance:FindFirstChild("QuestString") or instance:WaitForChild("QuestString", 5)
	local v3 = Quests.Holder[questString ~= nil and questString.Value or instance.Name]
	local value = maid:Value()
	local value2 = maid:Value()
	local value3 = maid:Value(false)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hookTimer(p2)
		removeFromTimerTracker(value2)

		if p2 ~= nil then
			addToTimerTracker(value2, p2)
		end

		value3:Set(p2 ~= nil)
	end

	hookTimer(instance:FindFirstChild("Timer")) -- equivalent call inferred; original call site unknown
	maid:Connect(instance.ChildAdded, function(p2)
		if p2.Name == "Timer" then
			hookTimer(p2) -- equivalent call inferred; original call site unknown
		end
	end)
	maid:Connect(instance.ChildRemoved, function(p2)
		if p2.Name == "Timer" then
			hookTimer(instance:FindFirstChild("Timer")) -- equivalent call inferred; original call site unknown
		end
	end)
	maid:Add(function()
		removeFromTimerTracker(value2)
	end)

	local function updProg()
		local count = 0
		local count2 = 0

		for _, child in ipairs(instance.Tasks:GetChildren()) do
			if child.Value.Value == child.Max.Value then
				count += 1
			end

			count2 += 1
		end

		value:Set((`{count}/{count2}`))
	end

	updProg()
	local value4 = maid:Value(Color3.new(1, 0.1, 0.1))
	local flag = false
	local v4 = false
	local v5 = math.min(p * 0.2, 30)
	local v6 = math.min(p * 0.1575)
	local v7 = math.min(26, p * 0.1595)
	local size = maid:Value(UDim2.new(0, 50, 0, v6))
	local v8 = maid:Create("Frame")
	local v9 = {
		Size = UDim2.new(1, 0, 0, 200),
		BackgroundTransparency = 1,
		LayoutOrder = v3 == nil and -1 or v3.Priority or -1,
		Name = instance.Name,
		CleanDelay = info2.Time,
		OnClean = function(animator, folder)
			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("GuiObject") then
					animator:LoadAnimation(descendant, {
						BackgroundTransparency = 1
					}, info2):Play()
				end

				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
					animator:LoadAnimation(descendant, {
						TextTransparency = 1,
						TextStrokeTransparency = 1
					}, info2):Play()
				end

				if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
					animator:LoadAnimation(descendant, {
						ImageTransparency = 1
					}, info2):Play()
				end

				if descendant:IsA("UIStroke") then
					animator:LoadAnimation(descendant, {
						Transparency = 1
					}, info2):Play()
				end
			end
		end
	}
	local v12 = maid:Create("UIListLayout")({
		Name = "List",
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.Name,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 5),
		[maid:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
			p2.Parent.Size = UDim2.new(1, 0, 0, p2.AbsoluteContentSize.Y)
		end
	})

	local function fn()
		local event = v3 ~= nil and v3.Event or nil

		if event == nil then
			return nil
		end

		local v13 = modulesByName[event]

		if v13 == nil then
			return nil
		end

		return v13(maid, instance, v3, p)
	end

	local v21 = maid:Create("Frame")({
		Name = "aTitle",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, v5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		maid:Create("Frame")({
			Name = "Underline",
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = 2,
			Position = UDim2.fromScale(0, 1),
			BackgroundTransparency = 0.55
		}),
		maid:Create("Frame")({
			Name = "Bg",
			Size = UDim2.fromScale(1, 1),
			ZIndex = -1,
			BackgroundColor3 = Color3.new(),
			Position = UDim2.fromScale(0, 0),
			BackgroundTransparency = 0.65,
			maid:Create("UICorner")({
				CornerRadius = UDim.new(0.15)
			}),
			maid:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.15, 0.45),
					NumberSequenceKeypoint.new(0.25, 0.45),
					NumberSequenceKeypoint.new(0.5, 0.8),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = -90
			})
		}),
		maid:Create("Frame")({
			Name = "Holder",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			maid:Create("UIListLayout")({
				Name = "List",
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				[maid:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
					local v21 = (p2.AbsoluteContentSize.X + 5) / p2.Parent.Parent.AbsoluteSize.X
					p2.Parent.Parent.Bg.Size = UDim2.fromScale(v21, 1)
					p2.Parent.Parent.Underline.Size = UDim2.new(v21, 0, 0, 1)
				end
			}),
			maid:Create("ImageLabel")({
				Size = UDim2.fromScale(0.2, 0.8),
				maid:Create("UIAspectRatioConstraint")({
					AspectRatio = 1.2
				}),
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Image = BunchaIcons[v3 == nil and "Combat" or v3.Category or "Combat"] or BunchaIcons.Combat
			}),
			maid:Create("TextLabel")({
				Name = "Text",
				Size = UDim2.fromScale(2, 0.9),
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(1, 1, 1),
				Text = maid:Do(function(callback, _, _)
					return (`{instance.Name}  {callback(value)}`)
				end),
				TextScaled = true,
				Font = Enum.Font.SourceSansSemibold,
				TextXAlignment = Enum.TextXAlignment.Left,
				maid:Create("UIStroke")({
					Transparency = 0.75,
					Thickness = 2
				}),
				TextBoundsOnChangedInit = function(state)
					if state.TextBounds.X > 0 then
						state.Size = UDim2.fromScale(state.TextBounds.X / state.Parent.AbsoluteSize.X, 1)
					end
				end
			}),
			function()
				if v3 == nil or v3.NoCancel ~= true then
					return maid:Create("Frame")({
						Name = "zExit",
						Size = UDim2.fromScale(0.3, 1),
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						BackgroundTransparency = 1,
						Instance.new("UIAspectRatioConstraint"),
						GradientButton(maid, {
							Clicked = function()
								if flag then
									return
								end

								flag = true

								if instance ~= nil and instance.Parent ~= nil then
									local v21 = PopUpCreator.new({
										Type = "Question",
										Content = `Are you sure you want to abandon <font {string.lower(gameSettings.RichTextPopularConfigs.SoroundColorRBX)}>'{instance.Name}'</font>?`
									})
									value4:Set(Color3.new(0.35, 0.35, 0.35))

									if v21.Result:Wait(5) == "Yes" then
										SignalEvent.ToServer("RemoveQuest", instance.Name)
									else
										value4:Reset()
									end
								end

								flag = false
							end,
							BgColor = maid:Animation(value4, info),
							Properties = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5)
							},
							Image = "rbxassetid://140084835628457",
							ContentColor = maid:Animation(value4, info)
						})
					})
				end
			end
		})
	})

	local function fn2()
		return maid:Create("Frame")({
			Name = "bTimer",
			Visible = maid:Do(function(callback)
				return callback(value3) == true
			end),
			Size = size,
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
			BackgroundTransparency = 0.55,
			maid:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			maid:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				Transparency = 0.75,
				BorderOffset = UDim.new(0, -2)
			}),
			maid:Create("TextLabel")({
				Size = UDim2.fromScale(100, 0.8),
				BackgroundTransparency = 1,
				TextScaled = true,
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.SourceSansBold,
				TextStrokeTransparency = 0.85,
				Text = maid:Do(function(callback, _, p2)
					local v22 = callback(value2)

					if v22 == nil or not (v22 < 15) then
						return Utility.formatTime(v22 or 0)
					end

					if not v4 then
						v4 = true
						p2.TextColor3 = Color3.new(1, 0.3, 0.3)
					end

					ReplicatedStorage.Assets.Sounds.Misc.countDown.TimePosition = 0
					ReplicatedStorage.Assets.Sounds.Misc.countDown:Play()
					return Utility.formatTime(v22 or 0)
				end),
				TextBoundsOnChangedInit = function(_, point: Vector2)
					size:Set(UDim2.new(0, math.max(point.X, 40) + 10, 0, v6))
				end,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5)
			})
		})
	end

	v9[1], v9[2], v9[3], v9[4], v9[5], v9[6], v9[7] = v12, fn, v21, function()
	local hint = v3 ~= nil and v3.Hint or nil

	if type(hint) == "string" and hint ~= "" then
		return maid:Create("Frame")({
			Name = "aaHint",
			Size = UDim2.new(1, 0, 0, v5 * 0.8),
			BackgroundTransparency = 1,
			maid:Create("Frame")({
				Name = "Bg",
				Size = UDim2.new(0, 40, 1, 0),
				BackgroundColor3 = Color3.new(),
				BackgroundTransparency = 0.65,
				maid:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				maid:Create("TextLabel")({
					Name = "Txt",
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 6, 0.5, 0),
					Size = UDim2.new(100, 0, 1, -4),
					BackgroundTransparency = 1,
					Text = hint,
					TextScaled = true,
					Font = Enum.Font.SourceSansItalic,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0.15,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextBoundsOnChangedInit = function(p2)
						if p2.TextBounds.X > 0 then
							p2.Parent.Size = UDim2.new(0, p2.TextBounds.X + 12, 1, 0)
						end
					end
				})
			})
		})
	end
end, fn2, maid:Create("Frame")({
	Name = "cTasksHolder",
	Size = UDim2.fromScale(1, 0.5),
	Position = UDim2.new(0, 0, 0, 35),
	BackgroundTransparency = 1,
	maid:Create("UIListLayout")({
		Name = "List",
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 5),
		[maid:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
			p2.Parent.Size = UDim2.new(1, 0, 0, p2.AbsoluteContentSize.Y)
		end
	}),
	maid:Iterate(instance.Tasks:GetChildren(), function(_, p2, _, _)
		local v26 = nil

		if v3 ~= nil and v3.QuestInstance ~= nil then
			for i, child in ipairs(v3.QuestInstance.Tasks:GetChildren()) do
				if child.Name ~= p2.Name then
					continue
				end

				v26 = i
				break
			end
		end

		local v27

		if not (v3 == nil or v3.TaskSpecs == nil) then
			v27 = v3.TaskSpecs[p2.Name] or nil
		end

		local taskMarker = Quests.GetTaskMarker(v3, p2)
		local v31

		if v27 ~= nil then
			v31 = v27.Hint or nil
		end

		return TaskComponent(maid, p2, updProg, taskMarker, v26, v31, p)
	end)
}), function()
	local rewards = Quests.RewardsOf(instance, game.Players.LocalPlayer)

	if rewards == nil then
		return
	end

	return maid:Create("Frame")({
		Name = "zRewardsHolder",
		Size = UDim2.new(1, 0, 0, v7),
		BackgroundTransparency = 1,
		maid:Create("UIListLayout")({
			Name = "List",
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 2),
			[maid:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
				p2.Parent.Size = UDim2.new(0, p2.AbsoluteContentSize.X, 0, v7)
			end
		}),
		maid:Iterate(rewards, function(name2, chance, object)
			if typeof(chance) == "table" and chance.RequiresQuest ~= nil and Quests.GetPlayerQuestState(game.Players.LocalPlayer, chance.RequiresQuest) == "None" then
				return nil
			end

			local iconAndColor, textColor = RewardsStyling.GetIconAndColor(name2, chance)
			local text, text2

			if name2 == "Power" then
				local name = Resolve.NameOf(chance)
				text = Resolve.DisplayName(name) or tostring(name)
				text2 = "Unlock"
			elseif Items[name2] == nil then
				text = name2 == "FlatMastery" and "Mastery" or name2
				local v33

				if name2 == "Exp" then
					v33 = Multipliers.ExpGain(nil, "Quest")
				elseif name2 == "Wen" then
					v33 = Multipliers.WenGain(nil, "Quest")
				end

				local v34

				if name2 == "Exp" then
					v34 = Multipliers.ExpGainTag(nil, "Quest")
				elseif name2 == "Wen" then
					v34 = Multipliers.WenGainTag(nil, "Quest")
				end

				local addCommasToNumber = Utility.addCommasToNumber

				if v33 ~= nil then
					chance = math.floor(chance * v33)
				end

				text2 = "+" .. addCommasToNumber(chance) .. (v34 == nil and "" or ` ({v34})`)
			else
				local v33 = typeof(chance) ~= "table" and 1 or chance.Quantity or 1

				if typeof(chance) == "table" then
					chance = chance.Chance
				end

				text2 = "x" .. v33

				if typeof(chance) == "number" and chance < 100 then
					text2 ..= ` ({chance}%)`
				end

				text = name2
			end

			return object:Create("Frame")({
				Name = name2,
				Size = UDim2.fromScale(0.3, 1),
				BackgroundTransparency = 0.55,
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				object:Create("UIStroke")({
					BorderOffset = UDim.new(0, -4),
					Transparency = 0.75,
					Color = Color3.new(1, 1, 1)
				}),
				BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
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
						Padding = UDim.new(0, 2),
						[object:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p3)
							p3.Parent.Parent.Size = UDim2.new(0, p3.AbsoluteContentSize.X, 1, 0)
						end
					}),
					object:Create("ImageLabel")({
						Image = iconAndColor,
						Name = "Img",
						Size = UDim2.fromScale(1, 1.25),
						BackgroundTransparency = 1,
						Instance.new("UIAspectRatioConstraint")
					}),
					object:Create("TextLabel")({
						Name = "ItemName",
						Size = UDim2.fromScale(100, 1),
						BackgroundTransparency = 1,
						Text = text,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						Font = Enum.Font.SourceSansSemibold,
						TextColor3 = Color3.new(1, 1, 1),
						TextTransparency = 0.2,
						object:Create("UIStroke")({
							Transparency = 0.75,
							Thickness = 1.5
						}),
						TextBoundsOnChangedInit = function(p3)
							if p3.TextBounds.X > 0 then
								p3.Size = UDim2.new(0, p3.TextBounds.X + 2, 1, 0)
							end
						end
					}),
					object:Create("TextLabel")({
						Name = "Txt",
						Size = UDim2.fromScale(100, 1),
						BackgroundTransparency = 1,
						Text = text2,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						Font = Enum.Font.SourceSansSemibold,
						TextColor3 = textColor,
						object:Create("UIStroke")({
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
end
	return v8(v9)
end