local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local TimedEvents = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.TimedEvents)
local faye = require(ReplicatedStorage.Packages.faye)
local interfaceutility = require(ReplicatedStorage.Packages.interfaceutility)
local v = {
	Race = {
		Color = Color3.fromRGB(161, 199, 230),
		Check = function(p: string)
			local data = Utility.GetData(Players.LocalPlayer)
			local race

			if data == nil then
				race = false
			else
				race = data:FindFirstChild("Race")
			end

			return race ~= nil and race.Value == p
		end
	},
	Level = {
		Color = gameSettings.lvlColor,
		Check = function(p: number)
			local data = Utility.GetData(Players.LocalPlayer)
			local exp

			if data == nil then
				exp = false
			else
				exp = data:FindFirstChild("Exp")
			end

			local goal

			if exp == nil then
				goal = false
			else
				goal = exp:FindFirstChild("Goal")
			end

			return goal ~= nil and p <= math.floor(goal.Value / gameSettings.expPerLevel)
		end
	}
}
local color = Color3.new(1, 0, 0)
local color2 = Color3.new(1, 1, 1)
local info = faye.Info(0.2)
local info2 = faye.Info(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local info3 = faye.Info(0.3)
return function(parent2, p2, callback)
	local v2 = p2 or TimedEvents.FinalSelection
	local animator = faye.new()
	local value = animator:Value(Utility.formatTime(v2.Every))
	local v3 = string.split(string.gsub(Utility.formatTime(v2.Every), "s", ""), ":")
	local color3 = v2.Color or Color3.new(0, 0, 0)
	local v4 = {}
	local count = 0

	for i, v5 in ipairs(v3) do
		if i > 1 then
			table.insert(v4, {
				Type = "Separator"
			})
		end

		for _ = 1, #v5 do
			count += 1
			table.insert(v4, {
				Type = "Digit",
				Digit = count
			})
		end
	end

	local textColor = color2
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local digitLabels = {}

	local function makeDigitLabel(parent, text: string)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Value"
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Position = UDim2.fromScale(0, -1)
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextColor3 = textColor
		textLabel.Text = text
		textLabel.Parent = parent
		return textLabel
	end

	local function setDigit(digit: number, text: string)
		local parent = v6[digit]

		if not (parent ~= nil and v8[digit] ~= text) then
			return
		end

		v8[digit] = text
		local v10 = digitLabels[digit]
		local digitLabel = makeDigitLabel(parent, text)
		digitLabels[digit] = digitLabel

		if v10 == nil then
			digitLabel.Position = UDim2.fromScale(0, 0)
			return
		end

		animator:LoadAnimation(v10, {
			Position = UDim2.fromScale(0, 1)
		}, info2):Play()
		task.delay(info2.Time + 0.05, v10.Destroy, v10)
		animator:LoadAnimation(digitLabel, {
			Position = UDim2.fromScale(0, 0)
		}, info2):Play()
	end

	local v9 = {}
	local v10 = {}
	local folder = nil
	local v11 = nil
	local lock = nil
	local v12 = 0
	local total = 0
	local total2 = 0

	local function updateBgSize()
		if v11 == nil or folder == nil then
			return
		end

		local absoluteSize = interfaceutility.GetAbsoluteSize(folder)

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end

		local v13 = math.max(v12, total, total2)

		if v13 <= 0 then
			return
		end

		local v14 = 1
		local v15 = 0

		for _, childName in ipairs({ "Title", "CounterHolder", "RequirementsHolder" }) do
			local child = (childName ~= "RequirementsHolder" or #v10 > 0) and folder:FindFirstChild(childName)

			if not child then
				continue
			end

			v14 = math.min(v14, child.Position.Y.Scale)
			v15 = math.max(v15, child.Position.Y.Scale + child.Size.Y.Scale)
		end

		v11.Size = UDim2.fromScale(
			math.min(1, (v13 + 20) / absoluteSize.X),
			(math.min(1, v15 - v14 + 20 / absoluteSize.Y))
		)
		v11.Position = UDim2.fromScale(0.5, (v14 + v15) / 2)
	end

	local v13 = animator:Create("Frame")({
		Name = "TimedEventHolder",
		Parent = parent2,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = animator:Animation(UDim2.new(1, -6, 1, -6), info3, {
			From = UDim2.new(0.85, -6, 0.85, -6)
		}),
		BackgroundTransparency = 1,
		OnClean = function(animator2, folder2)
			for _, descendant in ipairs(folder2:GetDescendants()) do
				if descendant:IsA("GuiObject") then
					animator2:LoadAnimation(descendant, {
						BackgroundTransparency = 1
					}, info3):Play()
				end

				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
					animator2:LoadAnimation(descendant, {
						TextTransparency = 1,
						TextStrokeTransparency = 1
					}, info3):Play()
				end

				if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
					animator2:LoadAnimation(descendant, {
						ImageTransparency = 1
					}, info3):Play()
				end

				if descendant:IsA("UIStroke") then
					animator2:LoadAnimation(descendant, {
						Transparency = 1
					}, info3):Play()
				end
			end

			return {
				Size = animator2:Animation(UDim2.new(0.85, -6, 0.85, -6), info3)
			}
		end,
		function()
			local v14 = animator:Create("Frame")({
				Name = "Bg",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -4, 1, -4),
				BackgroundColor3 = Color3.new(0.075, 0.075, 0.075),
				animator:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.2),
						NumberSequenceKeypoint.new(1, 0.9)
					}),
					Rotation = 22.5
				}),
				animator:Create("UICorner")({
					CornerRadius = UDim.new(0.2)
				}),
				animator:Create("UIStroke")({
					BorderOffset = UDim.new(0, -4),
					Transparency = 0.75,
					Color = Color3.new(1, 1, 1)
				})
			})
			v11 = typeof(v14) == "Instance" and v14 or v14.Instance
			return v14
		end,
		animator:Create("Frame")({
			Name = "Title",
			Size = UDim2.fromScale(1, 0.28),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.05),
			BackgroundTransparency = 1,
			animator:Create("UIListLayout")({
				Name = "List",
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0)
			}),
			animator:Create("ImageLabel")({
				Name = "Lock",
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.7, 0.7),
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Fit,
				Image = BunchaIcons.Locked,
				ImageColor3 = Color3.new(1, 1, 1),
				Visible = false,
				animator:Create("UIAspectRatioConstraint")({
					AspectRatio = 1
				})
			}),
			animator:Create("TextLabel")({
				Name = "Text",
				LayoutOrder = 2,
				Size = UDim2.fromScale(100, 1),
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(1, 1, 1),
				Text = v2.Title,
				TextScaled = true,
				Font = Enum.Font.SourceSansSemibold,
				animator:Create("UIStroke")({
					Thickness = 2,
					Color = color3,
					animator:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.85),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = -90
					})
				})
			})
		}),
		animator:Create("Frame")({
			Name = "CounterHolder",
			Size = UDim2.fromScale(1, 0.35),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.36),
			BackgroundTransparency = 1,
			animator:Create("UIListLayout")({
				Name = "List",
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2)
			}),
			animator:Iterate(v4, function(layoutOrder, p4, object)
				if p4.Type == "Separator" then
					local v14 = object:Create("Frame")({
						Name = `Separator{layoutOrder}`,
						LayoutOrder = layoutOrder,
						CleanDelay = info3.Time,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						object:Create("UIAspectRatioConstraint")({
							AspectRatio = 0.15
						}),
						object:Create("TextLabel")({
							Name = "Colon",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Text = ":",
							TextScaled = true,
							Font = Enum.Font.SourceSansBold,
							TextColor3 = Color3.new(1, 1, 1)
						})
					})
					v7[layoutOrder] = typeof(v14) == "Instance" and v14 or v14.Instance
					return v14
				else
					local v14 = object:Create("Frame")({
						Name = `Digit{p4.Digit}`,
						LayoutOrder = layoutOrder,
						CleanDelay = info3.Time,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						ClipsDescendants = true,
						object:Create("UIAspectRatioConstraint")({
							AspectRatio = 0.55
						})
					})
					v6[p4.Digit] = typeof(v14) == "Instance" and v14 or v14.Instance
					v7[layoutOrder] = v6[p4.Digit]
					return v14
				end
			end)
		}),
		animator:Create("Frame")({
			Name = "RequirementsHolder",
			Size = UDim2.fromScale(1, 0.2),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.73),
			BackgroundTransparency = 1,
			animator:Create("UIListLayout")({
				Name = "List",
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4)
			}),
			animator:Iterate(v2.Requirements or {}, function(name, p4, object)
				local v14 = object:Create("TextLabel")({
					Name = "Txt",
					CleanDelay = info3.Time,
					LayoutOrder = 2,
					Size = UDim2.fromScale(100, 0.8),
					BackgroundTransparency = 1,
					Text = `{name} {p4}`,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0.2,
					object:Create("UIStroke")({
						Transparency = 0.75,
						Thickness = 1.5
					})
				})
				local label = typeof(v14) == "Instance" and v14 or v14.Instance
				table.insert(v10, label)
				local v16 = object:Create("Frame")({
					Name = name,
					CleanDelay = info3.Time,
					Size = UDim2.fromScale(0.3, 0.9),
					BackgroundTransparency = 0.25,
					BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
					object:Create("UICorner")({
						CornerRadius = UDim.new(1)
					}),
					object:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 0.9)
						}),
						Rotation = 202.5
					}),
					object:Create("UIListLayout")({
						Name = "List",
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 0)
					}),
					v14
				})
				local v17 = v[name]
				table.insert(v9, {
					Check = v17 ~= nil and (function()
						return v17.Check(p4)
					end or nil) or nil,
					Label = label,
					Pill = typeof(v16) == "Instance" and v16 or v16.Instance
				})
				return v16
			end)
		})
	})
	folder = typeof(v13) == "Instance" and v13 or v13.Instance

	for _, descendant in ipairs(folder:GetDescendants()) do
		-- equivalent calls inferred from this helper; original call sites unknown
		local v14 = descendant
		local v15 = descendant

		local function apply(p3: string)
			local v16 = v14[p3]

			if v16 >= 1 then
				return
			end

			v14[p3] = 1
			animator:LoadAnimation(v14, {
				[p3] = v16
			}, info3):Play()
		end

		if descendant:IsA("GuiObject") then
			apply("BackgroundTransparency") -- equivalent call inferred; original call site unknown
		end

		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			apply("TextTransparency") -- equivalent call inferred; original call site unknown
			apply("TextStrokeTransparency") -- equivalent call inferred; original call site unknown
		end

		if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			apply("ImageTransparency") -- equivalent call inferred; original call site unknown
		end

		if not descendant:IsA("UIStroke") then
			continue
		end

		apply("Transparency") -- equivalent call inferred; original call site unknown
	end

	local function MeasureContent()
		local counterHolder = folder:FindFirstChild("CounterHolder")
		local title = folder:FindFirstChild("Title")

		if counterHolder == nil or title == nil or title:FindFirstChild("Text") == nil then
			return
		end

		v12 = 0
		total = 0
		total2 = 0

		for _, v14 in ipairs(v10) do
			local offsetTextSize = interfaceutility.GetOffsetTextSize(v14)
			local parent = v14.Parent
			local absoluteSize = interfaceutility.GetAbsoluteSize(parent.Parent)
			parent.Size = UDim2.fromScale((offsetTextSize + 20) / absoluteSize.X, 0.9)
			v14.Size = UDim2.fromScale(interfaceutility.GetScaledTextSize(v14), 0.8)
			total2 += offsetTextSize + 20
		end

		total2 += math.max(0, #v10 - 1) * 4
		local Y = interfaceutility.GetAbsoluteSize(folder:FindFirstChild("CounterHolder")).Y

		for _, v14 in ipairs(v4) do
			total += Y * (v14.Type == "Digit" and 0.55 or 0.15)
		end

		total += math.max(0, #v4 - 1) * 2
		local title2 = folder:FindFirstChild("Title")
		local text = title2:FindFirstChild("Text")
		local absoluteSize = interfaceutility.GetAbsoluteSize(title2)

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end

		lock = title2:FindFirstChild("Lock")
		v12 = interfaceutility.GetOffsetTextSize(text)
		text.Size = UDim2.fromScale(v12 / absoluteSize.X, 1)
		v12 += absoluteSize.Y * 0.7
		updateBgSize()
	end

	MeasureContent()
	local X = interfaceutility.GetAbsoluteSize(folder).X
	folder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local X2 = folder.AbsoluteSize.X

		if X2 <= 0 or X > 0 and math.abs(X2 - X) / X < 0.15 then
			return
		end

		X = X2
		MeasureContent()
	end)
	local v14 = false
	local v15 = nil
	animator:Spawn(function(...)
		while true do
			local v16

			if callback then
				v16 = math.clamp(callback(), 0, v2.Every)
			else
				v16 = v2.Every - workspace:GetServerTimeNow() % v2.Every
			end

			local formatTime = Utility.formatTime(v16)
			value:Set(formatTime)
			local v17 = string.gsub(formatTime, "s", "")
			local v18 = #v4 - #v17

			for i, v19 in ipairs(v4) do
				local v20 = v7[i]

				if v20 == nil then
					continue
				end

				local v21 = i - v18

				if v21 < 1 then
					v20.Visible = false

					if v19.Type == "Digit" then
						v8[v19.Digit] = nil
					end
				else
					v20.Visible = true

					if v19.Type == "Digit" then
						setDigit(v19.Digit, string.sub(v17, v21, v21))
					end
				end
			end

			local visible = false

			for _, v20 in ipairs(v9) do
				local met = v20.Check == nil or v20.Check() == true
				visible = not met or visible

				if met == v20.Met then
					continue
				end

				v20.Met = met
				v20.Pill.Visible = not met
			end

			if lock ~= nil and lock.Visible ~= visible then
				lock.Visible = visible
			end

			if v16 <= 30 then
				local v20 = math.floor(v16)

				if v20 ~= v15 then
					v15 = v20
					ReplicatedStorage.Assets.Sounds.Misc.countDown.TimePosition = 0
					ReplicatedStorage.Assets.Sounds.Misc.countDown:Play()
				end

				v14 = not v14
				textColor = v14 and color or color2

				for _, animation in pairs(digitLabels) do
					animator:LoadAnimation(animation, {
						TextColor3 = textColor
					}, info):Play()
				end
			else
				v15 = nil

				if textColor ~= color2 then
					textColor = color2

					for _, animation in pairs(digitLabels) do
						animator:LoadAnimation(animation, {
							TextColor3 = color2
						}, info):Play()
					end
				end
			end

			task.wait(0.5)
		end
	end)
	return function()
		animator:Destroy()
	end
end