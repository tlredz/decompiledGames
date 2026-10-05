local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local sourceSansBold = Enum.Font.SourceSansBold
local color = Color3.new(0.15, 0.15, 0.15)
local color2 = Color3.new(1, 1, 1)
local color3 = Color3.new(0, 0, 0)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local ClanEvents = require(ReplicatedStorage.CAM.Global.ClanEvents)
local Spinners = require(ReplicatedStorage.CAM.Global.Spinners)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local spinning = ReplicatedStorage.Assets.Sounds.Spinning

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(childName: string)
	local child = spinning:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone = child:Clone()
	clone.Parent = script
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength)
end

local info = faye.Info(0.25)
local info2 = faye.Info(0.4)
local info3 = faye.Info(1.35, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, -1, false, 0)
local springInfo = faye.SpringInfo(0.6, 1, 0.5)
local v = {}
table.insert(v, -3)
table.insert(v, -2)
table.insert(v, -1)
table.insert(v, 0)
table.insert(v, 1)
table.insert(v, 2)
table.insert(v, 3)
local NOTHING = Spinners.NOTHING

local function rollEntry(flag: boolean)
	if flag then
		return (ClanEvents.Wheel(Players.LocalPlayer).Roll())
	end

	return (Spinners.EvilArt.Roll())
end

local function iconOf(p: string?)
	if p == nil or p == NOTHING or p == "Nothing" then
		return "rbxassetid://79144759456190"
	end

	local item = Items[`{p} Orb`]
	return item ~= nil and item.Icon or "rbxassetid://79144759456190"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function labelOf(p: string?)
	if p == nil or p == NOTHING then
		return "Nothing"
	end

	return p
end

return function(maid, parent, p2, p3: number)
	local Y = GuiService:GetGuiInset().Y
	local v2

	if p2.IsClan == nil then
		v2 = workspace:GetAttribute("IsMenu") == true
	else
		v2 = p2.IsClan == true
	end

	local v3 = v2 and "ClanSpin" or "EvilArtSpin"
	local value = maid:Value(nil)
	local v4 = nil
	Players.LocalPlayer:SetAttribute("SpinnerOpen", true)
	maid:Add(function()
		Players.LocalPlayer:SetAttribute("SpinnerOpen", nil)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function close()
		PopUpCreator.signal:Fire(p3)
	end

	local function testDraw()
		if v2 then
			return ClanEvents.Wheel(Players.LocalPlayer).Roll()
		end

		return Spinners.EvilArt.Roll()
	end

	maid:Create("Frame")({
		Parent = parent,
		Name = "Spinner",
		Position = UDim2.new(0, 0, 0, -Y),
		Size = UDim2.new(1, 0, 1, Y),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = maid:Animation(p2.BackgroundTransparency or 0.1, info, {
			From = 1
		}),
		OnClean = function()
			return {
				BackgroundTransparency = maid:Animation(1, info2)
			}
		end,
		maid:Create("TextButton")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			OnClean = function(p4)
				p4.Size = UDim2.fromScale()
			end,
			function(p4)
				v4 = p4
			end
		}),
		maid:State(function(callback, object)
			local v5 = callback(value)

			if v5 == nil then
				local text = object:Value("Waiting for response")
				object:Spawn(function()
					local v6 = 0

					while true do
						v6 = v6 % 3 + 1
						text:Set(text.Initial .. string.rep(".", v6))
						task.wait(0.5)
					end
				end)
				return object:Create("Frame")({
					Name = "Loading",
					Size = UDim2.fromScale(0.5, 0.5),
					Instance.new("UIAspectRatioConstraint"),
					BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = object:Animation(0.75, info, {
						From = 1
					}),
					object:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = 45
					}),
					OnClean = function()
						return {
							BackgroundTransparency = object:Animation(1, info2)
						}
					end,
					object:Create("UICorner")({
						CornerRadius = UDim.new(0.075)
					}),
					object:Create("Frame")({
						Name = "Holder",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						object:Create("UIListLayout")({
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0.015, 0)
						}),
						object:Create("TextLabel")({
							Name = "ATitle",
							Size = UDim2.fromScale(1, 0.08),
							BackgroundTransparency = 1,
							Text = text,
							TextTransparency = object:Animation(0, info),
							Font = Enum.Font.SourceSansItalic,
							TextScaled = true,
							TextColor3 = Color3.new(1, 1, 1),
							OnClean = function()
								return {
									TextTransparency = object:Animation(1, info2)
								}
							end
						}),
						object:Create("Frame")({
							Name = "Bar",
							Size = UDim2.fromScale(0.1, 0.1),
							Instance.new("UIAspectRatioConstraint"),
							BackgroundTransparency = 1,
							object:Create("ImageLabel")({
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								Image = "rbxassetid://16708634837",
								ImageTransparency = 0.75,
								OnClean = function()
									return {
										ImageTransparency = object:Animation(1, info2)
									}
								end
							}),
							object:Create("ImageLabel")({
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								Image = "rbxassetid://16708879099",
								Rotation = object:Animation(360, info3),
								OnClean = function()
									return {
										ImageTransparency = object:Animation(1, info2)
									}
								end
							})
						})
					})
				})
			else
				local value2 = object:Value(UDim2.fromScale(0.5, 0.5))
				local value3 = object:Value(0)
				local value4 = object:Value(180)
				local flag = true
				local flag2 = false
				local flag3 = false
				local flag4 = false

				-- equivalent calls inferred from this helper; original call sites unknown
				local function complete()
					if flag4 then
						return
					end

					flag4 = true
					SignalEvent.ToServer(v2 and "ClanSpinComplete" or "EvilArtSpinComplete")
				end

				local v6 = {}

				local function entryAt(p4: number)
					local v7 = v6[p4]

					if v7 ~= nil then
						return v7
					end

					if v2 then
						v7 = ClanEvents.Wheel(Players.LocalPlayer).Roll()
					else
						v7 = Spinners.EvilArt.Roll()
					end

					v6[p4] = v7
					return v7
				end

				local v7 = {}
				local v8 = nil

				-- equivalent calls inferred from this helper; original call sites unknown
				local function setRowEntry(p4, p5: string?)
					if p4.Icon ~= nil then
						local icon = p4.Icon
						local image

						if p5 == nil or p5 == NOTHING or p5 == "Nothing" then
							image = "rbxassetid://79144759456190"
						else
							local item = Items[`{p5} Orb`]
							image = item == nil and "rbxassetid://79144759456190" or item.Icon or "rbxassetid://79144759456190"
						end

						icon.Image = image
					end

					if p4.Label ~= nil then
						p4.Label.Text = (p5 == nil or p5 == NOTHING) and "Nothing" or p5
					end
				end

				local function landStamp(icon)
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.Name = "Stamp"
					imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
					imageLabel.Position = UDim2.fromScale(0.5, 0.5)
					imageLabel.Size = UDim2.fromScale(2, 2)
					imageLabel.BackgroundTransparency = 1
					local v9 = v5
					local image

					if v9 == nil or v9 == NOTHING or v9 == "Nothing" then
						image = "rbxassetid://79144759456190"
					else
						local item = Items[`{v9} Orb`]
						image = item == nil and "rbxassetid://79144759456190" or item.Icon or "rbxassetid://79144759456190"
					end

					imageLabel.Image = image
					imageLabel.ZIndex = 5
					local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
					uIAspectRatioConstraint.Parent = imageLabel
					imageLabel.Parent = icon
					local tween = TweenService:Create(imageLabel, tweenInfo, {
						Size = UDim2.fromScale(1, 1),
						ImageTransparency = 1
					})
					tween.Completed:Once(function()
						imageLabel:Destroy()
					end)
					tween:Play()
				end

				local function revealLanded(data)
					if v8 == nil or v8.Parent == nil then
						return
					end

					playSound("Results") -- equivalent call inferred; original call site unknown
					local frame = data.Frame
					local label = data.Label or frame:FindFirstChild("Label")

					if label == nil then
						local icon = data.Icon or frame:FindFirstChild("Icon")

						if icon == nil then
							return
						end

						local Y2 = frame.AbsoluteSize.Y
						local v9 = Y2 * 0.15
						local text = (v5 == NOTHING or v5 == "Nothing") and "Nothing" or v5
						local textSize = Y2 * 0.45
						local X = TextService:GetTextSize(text, textSize, sourceSansBold, Vector2.new(100000, 100000)).X
						local v12 = v9 + Y2 + v9 + X + v9 * 2
						local X2 = v8.Parent.AbsoluteSize.X
						TweenService:Create(v8, tweenInfo2, {
							Size = UDim2.fromScale(v12 / X2, v8.Size.Y.Scale)
						}):Play()
						TweenService:Create(frame, tweenInfo2, {
							BackgroundColor3 = color2,
							BackgroundTransparency = 0
						}):Play()
						TweenService:Create(icon, tweenInfo2, {
							Position = UDim2.new(0, v9 + Y2 / 2, 0.5, 0)
						}):Play()
						local uIShadow = Instance.new("UIShadow")
						uIShadow.BlurRadius = UDim.new(1, 0)
						uIShadow.Offset = UDim2.fromScale(0.05, 0.05)
						uIShadow.Transparency = 1
						uIShadow.Parent = icon
						TweenService:Create(uIShadow, tweenInfo2, {
							Transparency = 0.65
						}):Play()
						local textLabel = Instance.new("TextLabel")
						textLabel.Name = "ResultName"
						textLabel.AnchorPoint = Vector2.new(0, 0.5)
						textLabel.Position = UDim2.new(0, v9 * 2 + Y2, 0.5, 0)
						textLabel.Size = UDim2.new(0, X, 0, textSize)
						textLabel.BackgroundTransparency = 1
						textLabel.Text = text
						textLabel.TextSize = textSize
						textLabel.TextXAlignment = Enum.TextXAlignment.Left
						textLabel.Font = sourceSansBold
						textLabel.TextColor3 = color3
						textLabel.TextTransparency = 1
						textLabel.ZIndex = 3
						textLabel.Parent = frame
						TweenService:Create(textLabel, tweenInfo2, {
							TextTransparency = 0
						}):Play()
						landStamp(icon)
					else
						local Y2 = frame.AbsoluteSize.Y
						local v10 = labelOf(v5) -- equivalent call inferred; original call site unknown
						local textSize = Y2 * 0.45
						local textSize2 = Y2 * 0.65
						local v13 = TextService:GetTextSize(v10, textSize2, sourceSansBold, Vector2.new(100000, 100000)).X + Y2 * 0.15 * 4
						local X = v8.Parent.AbsoluteSize.X
						TweenService:Create(v8, tweenInfo2, {
							Size = UDim2.fromScale(v13 / X, v8.Size.Y.Scale)
						}):Play()
						TweenService:Create(frame, tweenInfo2, {
							BackgroundColor3 = color2,
							BackgroundTransparency = 0
						}):Play()
						label.TextScaled = false
						label.TextSize = textSize
						label.Size = UDim2.fromScale(1, 1)
						TweenService:Create(label, tweenInfo2, {
							TextSize = textSize2,
							TextColor3 = color3
						}):Play()
						local uIStroke = label:FindFirstChildOfClass("UIStroke")

						if uIStroke ~= nil then
							TweenService:Create(uIStroke, tweenInfo2, {
								Transparency = 1
							}):Play()
						end
					end
				end

				local v9 = 0

				local function paint()
					for _, v10 in v7 do
						local v11 = v10.Index - v9

						if v11 < -3 then
							v10.Index += 7
							local index = v10.Index
							local v12 = v6[index]

							if v12 == nil then
								if v2 then
									v12 = ClanEvents.Wheel(Players.LocalPlayer).Roll()
								else
									v12 = Spinners.EvilArt.Roll()
								end

								v6[index] = v12
							end

							setRowEntry(v10, v12) -- equivalent call inferred; original call site unknown
							v11 = v10.Index - v9
						end

						v10.Frame.Position = UDim2.fromScale(0.5, v11 / 7 + 0.5)
					end
				end

				local v10 = 3 + math.random() * 3
				local v11 = os.clock() + v10 * 0.3
				local v12 = v10 * 0.7
				local flag5 = false
				local v13 = 0
				local v14 = 0
				local v15 = 0
				local total = 0

				local function beginBrake(p4: number)
					flag5 = true
					local v16 = math.max(math.ceil(v9 + p4), math.floor(v9) + 1)
					v6[v16] = v5

					for _, v17 in v7 do
						if v17.Index ~= v16 then
							continue
						end

						setRowEntry(v17, v5) -- equivalent call inferred; original call site unknown
					end

					v13 = v9
					v14 = v16
					v15 = (v16 - v9) * 4 / 8
					total = 0
					paint()
				end

				local v16 = math.floor(v9 + 0.5)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function biteOnCrossing()
					local v17 = math.floor(v9 + 0.5)

					if v17 == v16 then
						return
					end

					v16 = v17
					playSound("Tick") -- equivalent call inferred; original call site unknown
					value2:Refresh()
					value3:Refresh()
					value4:Refresh()
				end

				object:Connect(RunService.RenderStepped, function(p4: number)
					if not flag then
						return
					end

					if flag5 then
						total += p4
						local v17 = math.clamp(total / v15, 0, 1)
						v9 = v13 + (v14 - v13) * (1 - (1 - v17) ^ 4)

						if v17 >= 1 then
							v9 = v14
							flag = false
							flag2 = true

							for _, v18 in v7 do
								if v18.Index ~= v14 then
									continue
								end

								paint()
								revealLanded(v18)
								break
							end

							complete() -- equivalent call inferred; original call site unknown
							task.delay(2, close)
						end
					else
						v9 += p4 * 8

						if flag3 then
							beginBrake(4)
						elseif v11 <= os.clock() then
							beginBrake(8 * v12 / 4)
						end
					end

					paint()
					biteOnCrossing() -- equivalent call inferred; original call site unknown
				end)

				if v4 ~= nil then
					object:Connect(v4.MouseButton1Click, function()
						ScreenEffects.CircleClick()

						if flag2 then
							close() -- equivalent call inferred; original call site unknown
						elseif flag3 then
							flag = false
							complete() -- equivalent call inferred; original call site unknown
							close() -- equivalent call inferred; original call site unknown
						elseif flag then
							flag3 = true
						end
					end)
				end

				return object:Create("Frame")({
					Name = "Spin",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					object:Create("Frame")({
						Name = "Center",
						Instance.new("UIAspectRatioConstraint"),
						Size = UDim2.fromScale(0.1, 0.1),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						object:Create("UIListLayout")({
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0, 2)
						}),
						object:Create("Frame")({
							Name = "ALeftPointer",
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(0.3, 0.3),
							object:Create("ImageLabel")({
								Size = UDim2.fromScale(1, 1),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = object:Animation(value2, springInfo, {
									AlwaysFrom = UDim2.fromScale(0.5, 0.7)
								}),
								Rotation = object:Animation(value3, springInfo, {
									AlwaysFrom = 45
								}),
								BackgroundTransparency = 1,
								Image = "rbxassetid://18240409219"
							})
						}),
						object:Create("Frame")({
							Name = "InnerSpinner",
							Size = UDim2.fromScale(1.5, 0.8),
							BackgroundTransparency = 1,
							function(p4)
								v8 = p4
							end,
							object:Create("CanvasGroup")({
								Name = "Strip",
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 7),
								BackgroundTransparency = 1,
								object:Create("UIGradient")({
									Rotation = 90,
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(0.5, 0),
										NumberSequenceKeypoint.new(1, 1)
									})
								}),
								object:Iterate(v, function(_, p4: number, object2)
									local v17 = nil
									local v18 = nil
									local v19 = object2:Create("Frame")
									local v20 = {
										Name = `Row{p4}`,
										AnchorPoint = Vector2.new(0.5, 0.5),
										Position = UDim2.fromScale(0.5, p4 / 7 + 0.5),
										Size = UDim2.fromScale(1, 0.14285714285714285),
										BackgroundColor3 = color,
										BackgroundTransparency = 1
									}
									local v21 = object2:Create("UICorner")({
										CornerRadius = UDim.new(1, 0)
									})
									local v22

									if v2 then
										local v23 = object2:Create("TextLabel")
										local v24 = {
											Name = "Label",
											AnchorPoint = Vector2.new(0.5, 0.5),
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromScale(0.9, 0.45),
											BackgroundTransparency = 1
										}
										local v25 = v6[p4]

										if v25 == nil then
											if v2 then
												v25 = ClanEvents.Wheel(Players.LocalPlayer).Roll()
											else
												v25 = Spinners.EvilArt.Roll()
											end

											v6[p4] = v25
										end

										v24.Text = (v25 == nil or v25 == NOTHING) and "Nothing" or v25
										v24.TextScaled = true
										v24.Font = sourceSansBold
										v24.TextColor3 = Color3.new(1, 1, 1)
										v24[1], v24[2] = object2:Create("UIStroke")({
	Transparency = 0.5
}), function(p5)
	v18 = p5
end
										v22 = v23(v24)
									else
										local v23 = object2:Create("ImageLabel")
										local v24 = {
											Name = "Icon",
											AnchorPoint = Vector2.new(0.5, 0.5),
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromScale(1, 1),
											Instance.new("UIAspectRatioConstraint"),
											BackgroundTransparency = 1
										}
										local v25 = v6[p4]

										if v25 == nil then
											if v2 then
												v25 = ClanEvents.Wheel(Players.LocalPlayer).Roll()
											else
												v25 = Spinners.EvilArt.Roll()
											end

											v6[p4] = v25
										end

										local image

										if v25 == nil or v25 == NOTHING or v25 == "Nothing" then
											image = "rbxassetid://79144759456190"
										else
											local item = Items[`{v25} Orb`]
											image = item == nil and "rbxassetid://79144759456190" or item.Icon or "rbxassetid://79144759456190"
										end

										v24.Image = image
										v24[2] = function(p5)
	v17 = p5
end
										v22 = v23(v24)
									end

									v20[1], v20[2], v20[3] = v21, v22, function(instance)
	local v23 = {
		Frame = instance,
		Icon = v17 or instance:FindFirstChild("Icon"),
		Label = v18 or instance:FindFirstChild("Label"),
		Index = p4
	}

	if v23.Icon == nil and v23.Label == nil then
		task.defer(function()
			v23.Icon = instance:FindFirstChild("Icon")
			v23.Label = instance:FindFirstChild("Label")
		end)
	end

	table.insert(v7, v23)
end
									return v19(v20)
								end)
							})
						}),
						object:Create("Frame")({
							Name = "ZRightPointer",
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(0.3, 0.3),
							object:Create("ImageLabel")({
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = object:Animation(value2, springInfo, {
									AlwaysFrom = UDim2.fromScale(0.5, 0.7)
								}),
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								Rotation = object:Animation(value4, springInfo, {
									AlwaysFrom = 135
								}),
								Image = "rbxassetid://18240409219"
							})
						})
					})
				})
			end
		end)
	})
	maid:Spawn(function()
		local success, result = pcall(SignalFunction.ToServer, v3)

		if not success or typeof(result) ~= "string" then
			if not RunService:IsStudio() then
				close() -- equivalent call inferred; original call site unknown
				return
			end

			if v2 then
				result = ClanEvents.Wheel(Players.LocalPlayer).Roll()
			else
				result = Spinners.EvilArt.Roll()
			end
		end

		value:Set(result)
	end)
end