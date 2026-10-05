local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local faye = require(ReplicatedStorage.Packages.faye)
local interfaceutility = require(ReplicatedStorage.Packages.interfaceutility)
local config = require(ReplicatedStorage.SmartBone.Dependencies.Iris.config)
local springInfo = faye.SpringInfo(0.3, 1, 0.45)
local Config = require(script.Parent.Config)
local HoldPress = require(script.Parent.HoldPress)
local random = Random.new()
local vector = Vector2.new(12, 12)

-- equivalent calls inferred from this helper; original call sites unknown
local function trim(value: string)
	return value:match("^%s*(.-)%s*$") or ""
end

local function splitTopLevel(value: string, p: string)
	local v = 0
	local result = {}
	local v2 = 1

	for i = 1, #value do
		local v3 = value:sub(i, i)

		if v3 == "{" or v3 == "(" then
			v += 1
		elseif v3 == "}" or v3 == ")" then
			v -= 1
		elseif v3 == p and v == 0 then
			table.insert(result, value:sub(v2, i - 1))
			v2 = i + 1
		end
	end

	table.insert(result, value:sub(v2))
	return result
end

local parseValue

parseValue = function(value: string)
	local v = trim(value) -- equivalent call inferred; original call site unknown

	if v == "true" then
		return true
	elseif v == "false" then
		return false
	end

	local v2 = tonumber(v)

	if v2 then
		return v2
	end

	if v:sub(1, 1) ~= "{" or v:sub(-1) ~= "}" then
		return v
	end

	local result = {}

	for _, v3 in splitTopLevel(v:sub(2, -2), ",") do
		table.insert(result, parseValue(v3))
	end

	return result
end

local function parseChecks(checks: string)
	local result = {}

	for _, v in splitTopLevel(checks, ",") do
		local v2 = trim(v) -- equivalent call inferred; original call site unknown
		local v3 = v2:sub(1, 1)
		local v4 = v2:sub(-1)

		if v3 == "(" and v4 == ")" or v3 == "{" and v4 == "}" then
			v2 = v2:sub(2, -2)
		end

		local v5 = {}

		for _, v6 in splitTopLevel(v2, ",") do
			local match, v7 = v6:match("^%s*([%w_ ]-)%s*=%s*(.-)%s*$")

			if match and v7 then
				v5[match:match("^%s*(.-)%s*$") or ""] = parseValue(v7)
			end
		end

		if v5.Name ~= nil then
			result[v5.Name] = v5.Value
		end
	end

	return result
end

local v = {}

function getChecksModule(childName: string)
	if v[childName] then
		return v[childName]
	end

	local child = script.Checks:FindFirstChild(childName)

	if child == nil then
		return
	end

	local v2 = v
	local module = require(child)
	v2[childName] = module
	return v[childName]
end

return function(parent, instance, p2, object)
	local objectText = instance.ObjectText
	local actionText = instance.ActionText

	if #objectText == 0 then
		objectText = nil
	end

	if #actionText == 0 then
		actionText = nil
	end

	local icon = instance:GetAttribute("Icon")
	local maskUntilQuest = instance:GetAttribute("MaskUntilQuest")

	if typeof(maskUntilQuest) == "string" and Quests.GetPlayerQuestState(Players.LocalPlayer, maskUntilQuest) == "None" then
		objectText = "???"
		icon = nil
	end

	local checks = instance:GetAttribute("Checks")
	local v2 = checks == nil and {} or parseChecks(checks)
	local v3 = {}

	if next(v2) ~= nil then
		for k, v4 in v2 do
			local checksModule = getChecksModule(k)

			if checksModule ~= nil then
				checksModule(v4, v3)
			end
		end
	end

	local v4 = v3 and #v3 > 0
	local value = object:Value(0)
	local value2 = object:Value(0.15)
	local value3 = object:Value(0.6)
	local value4 = object:Value(Color3.new(1, 1, 1))
	local value5 = object:Value(Color3.new(0.175, 0.175, 0.175))
	local value6 = object:Value(Color3.new(1, 1, 1))
	local value7 = object:Value(0.65)
	local value8 = object:Value(1)
	local value9 = object:Value(1)
	local value10 = object:Value(0)
	local value11 = object:Value(1)
	local value12 = object:Value(false)
	local v5 = nil

	local function update()
		local v6 = value9:Get()
		local v7 = value11:Get()

		if v7 >= 2 then
			v6 = v7 + 1
		end

		if v6 ~= v5 then
			local value13 = false
			v5 = v6
			local v8 = false

			if v6 == 2 then
				value5:Set(Color3.new())
				value6:Set(Color3.new())
				value7:Set(0)
				value8:Set(0.5)
				value13 = true
			elseif v6 >= 3 then
				v8 = true
				value13 = value12.Value
				value3:Set(1)
				value:Set(1)
				value8:Set(1)
				value2:Set(1)
				value7:Set(1)

				if v6 == 3 then
					value5:Set(Config.TriggeredColor)
					value4:Set(Config.TriggeredColor)
				else
					value5:Reset()
				end
			else
				value8:Reset()
				value7:Reset()
				value6:Reset()
				value5:Reset()
			end

			if not v8 then
				value3:Reset()
				value:Reset()
				value2:Reset()
				value4:Reset()
			end

			value12:Set(value13)
		end
	end

	value9.Changed:Connect(update)
	value11.Changed:Connect(update)
	local keyContent = Config.GetKeyContent(instance, p2)
	local v6

	if keyContent.Type == "Text" then
		v6 = object:Create("TextLabel")({
			Size = UDim2.fromScale(1, 0.785),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Text = keyContent.Content,
			TextTransparency = object:Animation(value, Config.TransitionInfoLong),
			Font = Enum.Font.SourceSansBold,
			TextScaled = true,
			TextColor3 = object:Animation(value6, Config.TransitionInfo)
		})
	else
		v6 = object:Create("ImageLabel")({
			Size = UDim2.fromScale(0.85, 0.85),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageTransparency = object:Animation(value, Config.TransitionInfoLong),
			Image = keyContent.Content,
			ImageColor3 = object:Animation(value6, Config.TransitionInfo)
		})
	end

	local v7

	if not (v3 == nil or not (#v3 > 0)) then
		local v8 = { object:Create("UIListLayout")({
				Name = "List",
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0.05, 0)
			}) }

		for _, v9 in v3 do
			local v10 = object:Create("Frame")
			local v11 = {
				Name = "ChkEntry",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1 / #v3)
			}
			local v12 = object:Create("UIListLayout")({
				Name = "List",
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.0075, 0)
			})
			local v13

			if v9.Image then
				v13 = object:Create("ImageLabel")({
					Name = "ChkIcon",
					Size = UDim2.fromScale(1, 1),
					Instance.new("UIAspectRatioConstraint"),
					BackgroundTransparency = 1,
					ImageTransparency = object:Animation(value, Config.TransitionInfoLong),
					Image = v9.Image,
					ImageColor3 = object:Animation(value4, Config.TransitionInfoLong)
				})
			end

			local v14

			if v9.Text then
				v14 = object:Create("TextLabel")({
					Name = "ChkText",
					Size = UDim2.fromScale(10, 0.925),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					Text = v9.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = Color3.new(1, 0.3, 0.3),
					TextTransparency = object:Animation(value, Config.TransitionInfoLong)
				})
			end

			v11[1], v11[2], v11[3] = v12, v13, v14
			table.insert(v8, v10(v11))
		end

		v7 = object:Create("Frame")({
			Name = "bchecks",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, #v3 * 0.3),
			unpack(v8)
		})
	end

	local v8 = object:Create("Frame")
	local v9 = {
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}
	local v10 = object:Create("Frame")({
		Name = "Bg",
		object:Create("Frame")({
			Size = UDim2.new(1, -10, 1, -10),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 2,
			BackgroundColor3 = object:Animation(value4, Config.TransitionInfo),
			BackgroundTransparency = object:Animation(value8, Config.TransitionInfo),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.075)
			}),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.15),
					NumberSequenceKeypoint.new(0.3, 0.7),
					NumberSequenceKeypoint.new(1, 0.9)
				}),
				Rotation = 0
			})
		}),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "BgActual",
			BackgroundTransparency = object:Animation(value, Config.TransitionInfo),
			Size = object:Animation(UDim2.fromScale(1, 1), springInfo, {
				From = UDim2.fromScale(0.75, 0.75)
			}),
			BackgroundColor3 = object:Animation(value5, Config.TransitionInfo),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.15),
					NumberSequenceKeypoint.new(1, 0.7)
				}),
				Rotation = -35
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.1)
			})
		}),
		object:State(function(callback, object2, _)
			if callback(value12) then
				return object2:Create("Frame")({
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Name = "Holding",
					CleanDelay = config.CleanDelay,
					object2:Create("Frame")({
						Size = UDim2.fromScale(0.5, 1),
						Position = UDim2.fromScale(0),
						Name = "right",
						BackgroundTransparency = 1,
						ClipsDescendants = true,
						object2:Create("Frame")({
							Name = "Holder",
							Size = UDim2.fromScale(2, 1),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0, 0),
							object2:Create("UIStroke")({
								Thickness = 2,
								BorderOffset = UDim.new(0, -4),
								Color = object2:Animation(value4, Config.TransitionInfoLong),
								Transparency = object2:Animation(value, Config.TransitionInfoLong),
								object2:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 0.3),
										NumberSequenceKeypoint.new(0.499, 0.3),
										NumberSequenceKeypoint.new(0.501, 1),
										NumberSequenceKeypoint.new(1, 1)
									}),
									Rotation = object2:Do(function(callback2, _, _)
										return (math.clamp((1 - callback2(value10)) * 360 - 180, 0, 180))
									end)
								})
							}),
							object2:Create("UICorner")({
								CornerRadius = UDim.new(0.1)
							})
						})
					}),
					object2:Create("Frame")({
						Size = UDim2.fromScale(0.5, 1),
						Position = UDim2.fromScale(0.5),
						Name = "right",
						BackgroundTransparency = 1,
						ClipsDescendants = true,
						object2:Create("Frame")({
							Name = "Holder",
							Size = UDim2.fromScale(2, 1),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(-1, 0),
							object2:Create("UIStroke")({
								Thickness = 2,
								BorderOffset = UDim.new(0, -4),
								Color = object2:Animation(value4, Config.TransitionInfoLong),
								Transparency = object2:Animation(value, Config.TransitionInfoLong),
								object2:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(0.499, 1),
										NumberSequenceKeypoint.new(0.501, 0.3),
										NumberSequenceKeypoint.new(1, 0.3)
									}),
									Rotation = object2:Do(function(callback2, _, _)
										return (math.clamp((1 - callback2(value10)) * 360, 0, 180))
									end)
								})
							}),
							object2:Create("UICorner")({
								CornerRadius = UDim.new(0.1)
							})
						})
					})
				})
			end
		end)
	})
	local v11 = object:Create("TextButton")({
		BackgroundTransparency = 1,
		Name = "DetectBox",
		Size = UDim2.fromScale(1, 1),
		InputBegan = HoldPress(object, instance)
	})
	local v12 = object:Create("Frame")
	local v13 = {
		Name = "Holder",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}
	local v14 = object:Create("UIListLayout")({
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.05, 0),
		Name = "List"
	})

	if v7 == nil then
		v7 = nil
	end

	local v15

	if (actionText or v6) and not v4 then
		local v16 = object:Create("Frame")
		local v17 = {
			Name = "cActionContent",
			Size = UDim2.fromScale(1, 0.45),
			BackgroundTransparency = 1
		}
		local v18 = object:Create("UIListLayout")({
			Name = "List",
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.015, 0)
		})
		local v19 = object:Create("Frame")
		local v20 = {
			Name = "KeyHolder",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = object:Animation(value4, Config.TransitionInfoLong),
			Instance.new("UIAspectRatioConstraint"),
			BackgroundTransparency = object:Animation(value7, Config.TransitionInfoLong)
		}
		local v21 = object:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.95) }),
			Rotation = 135
		})
		local v22 = object:Create("UICorner")
		local cornerRadius

		if p2 == Enum.ProximityPromptInputType.Gamepad then
			cornerRadius = UDim.new(1)
		else
			cornerRadius = UDim.new(0.1)
		end

		v20[2], v20[3], v20[4], v20[5] = v21, v22({
	CornerRadius = cornerRadius
}), object:Create("UIStroke")({
	BorderOffset = UDim.new(-0.1, 0),
	Thickness = 1.5,
	Color = object:Animation(value6, Config.TransitionInfoLong),
	Transparency = object:Animation(value3, Config.TransitionInfoLong)
}), v6
		local v25 = v19(v20)
		local v26

		if actionText then
			v26 = object:Create("TextLabel")({
				Name = "actiontxt",
				BackgroundTransparency = 1,
				TextScaled = true,
				Font = Enum.Font.SourceSansSemibold,
				Text = actionText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.fromScale(1, 0.8),
				TextTransparency = object:Animation(value2, Config.TransitionInfoLong),
				TextColor3 = object:Animation(value4, Config.TransitionInfoLong)
			})
		end

		v17[1], v17[2], v17[3] = v18, v25, v26
		v15 = v16(v17)
	end

	local v16

	if objectText or icon then
		local v17 = object:Create("Frame")
		local v18 = {
			Name = "aObjectContent",
			Size = UDim2.fromScale(1, 0.35),
			BackgroundTransparency = 1
		}
		local v19 = object:Create("UIListLayout")({
			Name = "List",
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal
		})
		local v20

		if objectText then
			v20 = object:Create("TextLabel")({
				Name = "ObjectText",
				Size = UDim2.fromScale(10, 1),
				BackgroundTransparency = 1,
				TextScaled = true,
				Font = Enum.Font.SourceSansSemibold,
				Text = objectText,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = object:Animation(value4, Config.TransitionInfoLong),
				TextTransparency = object:Animation(value, Config.TransitionInfoLong)
			})
		end

		local v21

		if icon then
			v21 = object:Create("ImageLabel")({
				Size = UDim2.fromScale(1, 1),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundTransparency = 1,
				ImageTransparency = object:Animation(value, Config.TransitionInfoLong),
				Image = icon,
				ImageColor3 = object:Animation(value4, Config.TransitionInfoLong)
			})
		end

		v18[1], v18[2], v18[3] = v19, v20, v21
		v16 = v17(v18)
	end

	v13[1], v13[2], v13[3], v13[4] = v14, v7, v15, v16
	v9[1], v9[2], v9[3] = v10, v11, (v12(v13))

	function v9.After(p3)
		local absoluteSize = interfaceutility.GetAbsoluteSize(p3)

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end

		local v17 = 0
		local total = 0
		local count = 0
		local aObjectContent = p3.Holder:FindFirstChild("aObjectContent")

		if aObjectContent ~= nil then
			local v18 = 0.35 * absoluteSize.Y
			local total2 = 0
			local objectText2 = aObjectContent:FindFirstChild("ObjectText")

			if objectText2 ~= nil then
				local v19 = v18 * objectText2.Size.Y.Scale
				local X = TextService:GetTextSize(objectText2.Text, v19, objectText2.Font, Vector2.new(1e999, 1e999)).X
				objectText2.Size = UDim2.fromScale(X / absoluteSize.X, objectText2.Size.Y.Scale)
				total2 += X
			end

			if aObjectContent:FindFirstChildOfClass("ImageLabel") ~= nil then
				total2 += v18
			end

			v17 = math.max(v17, total2)
			total += v18
			count += 1
		end

		local bchecks = p3.Holder:FindFirstChild("bchecks")

		if bchecks ~= nil then
			local frames = {}

			for _, frame in bchecks:GetChildren() do
				if frame:IsA("Frame") then
					table.insert(frames, frame)
				end
			end

			local count2 = #frames

			if count2 > 0 then
				local v18 = bchecks.Size.Y.Scale * absoluteSize.Y / count2
				local v19 = 0

				for _, v20 in frames do
					local total2 = 0
					local uIListLayout = v20:FindFirstChildOfClass("UIListLayout")
					local v21 = (uIListLayout and uIListLayout.Padding.Scale or 0) * absoluteSize.X
					local chkText = v20:FindFirstChild("ChkText")

					if chkText ~= nil then
						local v22 = v18 * chkText.Size.Y.Scale
						local X = TextService:GetTextSize(chkText.Text, v22, chkText.Font, Vector2.new(1e999, 1e999)).X
						chkText.Size = UDim2.fromScale(X / absoluteSize.X, chkText.Size.Y.Scale)
						total2 += X
					end

					if v20:FindFirstChild("ChkIcon") ~= nil then
						total2 += v18

						if chkText ~= nil then
							total2 += v21
						end
					end

					v19 = math.max(v19, total2)
				end

				local uIListLayout = bchecks:FindFirstChildOfClass("UIListLayout")
				local absoluteContentSize = uIListLayout and uIListLayout.AbsoluteContentSize or Vector2.new(
					v19,
					v18 * count2
				)
				local v20 = math.max(absoluteContentSize.Y, v18 * count2)
				v17 = math.max(v17, (math.max(absoluteContentSize.X, v19)))
				total += v20
				count += 1
			end
		end

		local cActionContent = p3.Holder:FindFirstChild("cActionContent")

		if cActionContent ~= nil then
			local v18 = 0.45 * absoluteSize.Y
			local v19 = 0.015 * absoluteSize.X
			local actiontxt = cActionContent:FindFirstChild("actiontxt")
			local v20

			if actiontxt == nil then
				v20 = v18
			else
				local v21 = v18 * actiontxt.Size.Y.Scale
				local X = TextService:GetTextSize(actiontxt.Text, v21, actiontxt.Font, Vector2.new(1e999, 1e999)).X
				actiontxt.Size = UDim2.fromScale(X / absoluteSize.X, actiontxt.Size.Y.Scale)
				v20 = v18 + v19 + X
			end

			v17 = math.max(v17, v20)
			total += v18
			count += 1
		end

		if count > 1 then
			total += 0.035 * absoluteSize.Y * (count - 1)
		end

		p3.Bg.Size = UDim2.fromScale(
			(v17 + vector.X) / absoluteSize.X,
			(total + vector.Y) / absoluteSize.Y + p3.Holder.List.Padding.Scale * (#p3.Holder:GetChildren() - 2)
		)
	end

	v8(v9)
	local coolDown = instance:GetAttribute("CoolDown") or Config.CoolDown
	local v17 = nil
	local v18 = false
	local v19 = 0
	local holdDuration = instance.HoldDuration

	local function stateManager()
		local v20 = 1
		local number = random:NextNumber(1, 999)
		v19 = number

		if v18 == true then
			object:Spawn(function()
				local lastTime = os.clock()

				while number == v19 do
					local v21 = math.clamp((os.clock() - lastTime) / holdDuration, 0, 1)
					value10:Set(v21)

					if v21 >= 1 then
						break
					else
						task.wait()
					end
				end
			end)
			v20 = 2
		end

		value9:Set(v20)
	end

	object:Connect(instance.PromptButtonHoldBegan, function()
		if v4 or instance:GetAttribute("OnCooldown") then
			return
		end

		v18 = true
		v17 = Config.PlaySound(object, instance, "Hold", v17)
		stateManager()
	end)
	object:Connect(instance.PromptButtonHoldEnded, function()
		if not v18 then
			return
		end

		v18 = false

		if value11:Compare(1) then
			v17 = Config.PlaySound(object, instance, "NoneFromHold", v17)
		end

		task.wait()

		if not object.IsActive then
			return
		end

		stateManager()
	end)
	object:Connect(instance.Triggered, function()
		if v4 or not value11:Compare(1) then
			return
		end

		v17 = Config.PlaySound(object, instance, "Triggered", v17)
		value11:Set(2)
		instance:SetAttribute("OnCooldown", true)
		task.wait(coolDown)
		instance:SetAttribute("OnCooldown", nil)

		if not object.IsActive then
			return
		end

		if value11 ~= nil and value11:Compare(2) then
			value11:Reset()
		end
	end)
	return function()
		if v17 and v17.Parent then
			object:Remove(v17)
			v17:Destroy()
			v17 = nil
		end

		value11:Set(3)
		task.wait(Config.CleanDelay)
	end
end