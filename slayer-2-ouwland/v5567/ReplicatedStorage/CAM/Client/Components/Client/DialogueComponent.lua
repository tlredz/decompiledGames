local ReplicatedStorage = game:GetService("ReplicatedStorage")
local textplus = require(game.ReplicatedStorage.Packages.textplus)
local Dialogue = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
local faye = require(ReplicatedStorage.Packages.faye)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local DialogueUtility = require(script.DialogueUtility)
local Camera_Traffic_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Camera_Traffic_Handler)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local info = faye.Info(0.45)
local info2 = faye.Info(0.75)
local info3 = faye.Info(0.25)
local info4 = faye.Info(0.2)
local springInfo = faye.SpringInfo(0.3, 1, 0.5)
local Option = require(script.Option)
local typeof2 = typeof
local info5 = faye.Info(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)
local v = {
	Back = 1,
	Close = 2,
	Cancel = 2,
	Nevermind = 2,
	Farewell = 2,
	["Not yet"] = 2
}
local v2 = {
	["Buy the selection"] = 1,
	["Sell the selection"] = 1,
	["Make the exchange"] = 1,
	["Take the drawings"] = 1
}
return function(parent2, p2: string, instance)
	local v3 = Platform_Handler.Platform.Value == "Mobile"
	local v4 = v3 and 0.44999999999999996 or 0.3
	local v5 = 1 - v4 + 0.0625
	local instance2, maxActivationDistance

	if instance == nil then
		instance2 = nil
		maxActivationDistance = nil
	else
		maxActivationDistance = instance.MaxActivationDistance
		local parent = instance.Parent
		instance2 = instance
		local v6 = nil

		while parent ~= nil do
			if parent.ClassName == "Model" then
				if parent.PrimaryPart ~= nil then
					instance2 = parent
					break
				end
			elseif parent:IsA("BasePart") then
				v6 = v6 or parent
			else
				break
			end

			parent = parent.Parent
		end

		if instance2 == instance then
			instance2 = v6
		end
	end

	local v6 = p2 == nil and "NoQuest" or p2
	Dialogue.ResetStorage()
	local character = game.Players.LocalPlayer.Character
	local primaryPart

	if character == nil or character.PrimaryPart == nil then
		primaryPart = nil
	else
		primaryPart = character.PrimaryPart
	end

	local value = DialogueUtility.ExtractValue(v6, instance)

	if value == nil then
		return
	end

	local diagloue = Dialogue.Diagloues[value]

	if diagloue == nil then
		return
	end

	if diagloue ~= nil and diagloue.BeforeRun ~= nil then
		local beforeRun = DialogueUtility.BeforeRun(diagloue.BeforeRun, instance)

		if beforeRun ~= nil then
			if beforeRun == false or Dialogue.Diagloues[beforeRun] == nil then
				return
			else
				value = beforeRun
			end
		end
	end

	local position

	if instance2 == nil then
		position = false
	else
		position = instance2:IsA("BasePart") and instance2.Position or instance2.PrimaryPart.Position
	end

	local v7 = faye.new()
	local flag = false
	local value2 = v7:Value({})
	local value3 = v7:Value(false)
	local count = 0
	local v8 = v7:Create("Frame")({
		Name = "DialogueHolder",
		Size = UDim2.fromScale(0.8, 0.8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1
	})
	local v9 = nil
	local v10 = nil
	local icon

	if instance2 == nil then
		icon = nil
	else
		icon = instance:GetAttribute("Icon") or instance2:GetAttribute("Icon")
	end

	local name

	if instance2 == nil then
		name = nil
	else
		name = instance:GetAttribute("Name") or instance2.Name
	end

	local value4 = v7:Value(icon)
	local value5 = v7:Value(name)
	local v11 = nil
	local v12 = nil
	local space = v7:Space(function(data)
		if data.In == true then
			data.Fg:Set(Color3.new(1, 1, 1))
			data.Bg:Set(Color3.new(1, 1, 1))
			data.Txt:Set(Color3.new())
			data.ST:Set(0.7)
			data.S:Set(UDim2.fromScale(1.1, 1.1))
		else
			data.S:Reset()
			data.ST:Reset()
			data.Txt:Reset()
			data.Bg:Reset()
			data.Fg:Reset()
		end
	end)
	local v13 = v7:Create("Frame")
	local v14 = {
		Parent = parent2,
		Name = "DialogueContent",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, v5),
		Size = UDim2.fromScale(0.9, (v5 - 0.0125) * 1.35),
		BackgroundTransparency = 1,
		CleanDelay = info.Time
	}
	local v15

	if v3 then
		v15 = v7:Create("UIScale")({
			Scale = 2
		})
	end

	v14[1] = v15
	local v16 = v13(v14)
	v7:Create("Frame")({
		Parent = parent2,
		Name = "DialogueFrame",
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.fromScale(1, v4),
		BackgroundTransparency = v7:Animation(0, info4, {
			From = 1
		}),
		BackgroundColor3 = Color3.new(),
		v7:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.25),
				NumberSequenceKeypoint.new(0.8, 0.9),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Rotation = -90
		}),
		Position = UDim2.fromScale(0, 1),
		OnClean = function(object)
			if v10 ~= nil then
				object:Configure(v10)({
					GroupTransparency = object:Animation(1, info)
				})
			end

			return {
				BackgroundTransparency = object:Animation(1, info)
			}
		end,
		v7:Create("Frame")({
			Name = "Actual",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			v7:Create("TextButton")({
				Name = "ClickDetector",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1.2, 1),
				BackgroundTransparency = 1,
				ZIndex = 2,
				Visible = v7:DelayValue(value3, nil):For(false, info.Time),
				MouseButton1Click = function(p3)
					if not value3:Get() then
						return
					end

					ScreenEffects.StrokeClick(p3.Parent, UDim.new(1))

					if flag then
						if v9 ~= nil then
							v9:Print(v8)
						end
					else
						if typeof2(diagloue.Answers) == "table" then
							return
						end

						if diagloue.IfTrue then
							DialogueUtility.DoAll(diagloue.IfTrue, instance)
						else
							DialogueUtility.Close()
						end
					end
				end,
				v7:State(function(callback, object)
					if callback(value3) then
						return object:Create("ImageLabel")({
							Name = "PointerImage",
							Size = object:Animation(UDim2.fromScale(0.2, 0.2), springInfo, {
								From = UDim2.fromScale(0.1, 0.1)
							}),
							Instance.new("UIAspectRatioConstraint"),
							Image = "rbxassetid://18240409219",
							BackgroundTransparency = 1,
							Rotation = 90,
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = object:Animation(UDim2.fromScale(0.5, 0.95), info5, {
								From = UDim2.fromScale(0.5, 1.05)
							}),
							OnClean = function(object2)
								return {
									ImageTransparency = object2:Animation(1, info3)
								}
							end
						})
					end

					return nil
				end)
			}),
			v7:Create("Frame")({
				Name = "Bg",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				v7:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				v7:State(function(callback, object)
					local image = callback(value4)
					local text = callback(value5)

					if image == nil and (text == nil or text == "") then
						return nil
					end

					return object:Create("Frame")({
						Name = "NpcProfileHolder",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.3, 0.02),
						Size = UDim2.fromScale(0.4, 0.2),
						object:Create("UIListLayout")({
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0.025, 0)
						}),
						BackgroundTransparency = 1,
						function()
							if image == nil then
								return nil
							end

							return object:Create("ImageLabel")({
								Size = UDim2.fromScale(0.35, 1),
								object:Create("UIAspectRatioConstraint")({}),
								BackgroundTransparency = 1,
								Image = "rbxassetid://16873598266",
								ImageColor3 = Color3.new(0.15, 0.15, 0.15),
								object:Create("ImageLabel")({
									BackgroundTransparency = 1,
									Size = UDim2.fromScale(1, 1),
									Image = image,
									object:Create("UICorner")({
										CornerRadius = UDim.new(1)
									}),
									CleanFunction = function()
										return {
											ImageTransparency = object:Animation(1, info2)
										}
									end
								}),
								CleanFunction = function()
									return {
										ImageTransparency = object:Animation(1, info2)
									}
								end
							})
						end,
						function()
							if text == nil or text == "" then
								return nil
							end

							return object:Create("TextLabel")({
								Name = "NpcName",
								Size = UDim2.fromScale(1, 0.9),
								BackgroundTransparency = 1,
								Text = text,
								TextScaled = true,
								TextXAlignment = Enum.TextXAlignment.Left,
								Font = Enum.Font.SourceSansSemibold,
								TextColor3 = Color3.new(1, 1, 1),
								object:Create("UIStroke")({
									Thickness = 1,
									Transparency = 0.75,
									CleanFunction = function()
										return {
											Transparency = object:Animation(1, info2)
										}
									end
								}),
								CleanFunction = function()
									return {
										TextTransparency = object:Animation(1, info2)
									}
								end
							})
						end
					})
				end),
				BackgroundColor3 = Color3.new(0.05, 0.05, 0.05),
				Size = v7:Animation(UDim2.fromScale(1, 1), springInfo, {
					From = UDim2.fromScale(0.8, 0.8)
				}),
				v7:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.2),
						NumberSequenceKeypoint.new(1, 0.4)
					}),
					Rotation = 90
				}),
				ZIndex = -1,
				CleanFunction = function()
					return {
						BackgroundTransparency = v7:Animation(1, info2)
					}
				end
			}),
			v7:Create("UIAspectRatioConstraint")({
				AspectRatio = 3
			}),
			v8,
			v7:Create("Frame")({
				Name = "ButtonHolder",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(1.035, 0.5),
				Size = UDim2.fromScale(0.3, 0.2),
				BackgroundTransparency = 1,
				v7:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0.2, 0),
					SortOrder = Enum.SortOrder.Name
				}),
				v7:AdvancedIterate(value2, function(p3, p4, object)
					count += 1
					local v17 = object:Create("Frame")
					local name2

					if v2[p3] == nil then
						if v[p3] == nil then
							name2 = p3
						else
							name2 = "ZZZZZZZZZ" .. v[p3]
						end
					else
						name2 = "000000000" .. v2[p3]
					end

					return v17({
						Name = name2,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Option(object, p3, p4, count, space)
					})
				end)
			})
		})
	})
	local v17 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resolveContinue(callback)
		if type(callback) == "function" then
			return callback(v17, instance, Dialogue.Storage) == true
		end

		return callback == true
	end

	local function applyNodeIcon(diagloue2)
		if diagloue2.Icon == nil and diagloue2.Name == nil then
			-- equivalent call inferred; original call site unknown
			if not resolveContinue(diagloue2.ContinueIcon) then
				if not value4:Compare(icon) then
					value4:Set(icon)
				end

				if not value5:Compare(name) then
					value5:Set(name)
				end
			end
		else
			if diagloue2.Icon ~= nil and not value4:Compare(diagloue2.Icon) then
				value4:Set(diagloue2.Icon)
			end

			if diagloue2.Name ~= nil and not value5:Compare(diagloue2.Name) then
				value5:Set(diagloue2.Name)
			end
		end
	end

	local flag2 = false
	local cFrame = nil
	local count2 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function lerpCameraTo(cframe: CFrame, fn)
		count2 += 1
		local v18 = count2
		local currentCamera = workspace.CurrentCamera
		local cFrame2 = currentCamera.CFrame
		local lastTime = os.clock()
		task.spawn(function()
			while count2 == v18 do
				if Camera_Traffic_Handler.Equipped_Hirearchy ~= "Dialogue" then
					break
				end

				local v19 = math.min((os.clock() - lastTime) / 0.5, 1)
				currentCamera.CFrame = cFrame2:Lerp(cframe, v19 * v19 * (3 - v19 * 2))

				if v19 >= 1 then
					if fn ~= nil then
						fn()
					end

					break
				else
					task.wait()
				end
			end
		end)
	end

	local function releaseCamera()
		if not flag2 then
			return
		end

		flag2 = false
		local v18 = cFrame
		cFrame = nil

		if v18 == nil then
			Camera_Traffic_Handler.Dialogue = false
			return
		end

		local function fn()
			Camera_Traffic_Handler.Dialogue = false
		end

		lerpCameraTo(v18, fn) -- equivalent call inferred; original call site unknown
	end

	local function applyNodeCamera(diagloue2)
		local cameraCFrame = diagloue2.CameraCFrame

		if typeof2(cameraCFrame) == "function" then
			cameraCFrame = cameraCFrame(instance, Dialogue.Storage)
		end

		if typeof2(cameraCFrame) == "CFrame" then
			if not flag2 then
				flag2 = true
				cFrame = workspace.CurrentCamera.CFrame
				Camera_Traffic_Handler.Dialogue = true
			end

			count2 += 1
			local v18 = count2
			local currentCamera = workspace.CurrentCamera
			local cFrame2 = currentCamera.CFrame
			local lastTime = os.clock()
			local v19 = nil
			task.spawn(function()
				while count2 == v18 do
					if Camera_Traffic_Handler.Equipped_Hirearchy ~= "Dialogue" then
						break
					end

					local v20 = math.min((os.clock() - lastTime) / 0.5, 1)
					currentCamera.CFrame = cFrame2:Lerp(cameraCFrame, v20 * v20 * (3 - v20 * 2))

					if v20 >= 1 then
						if v19 ~= nil then
							v19()
						end

						break
					else
						task.wait()
					end
				end
			end)
		else
			-- equivalent call inferred; original call site unknown
			if not resolveContinue(diagloue2.ContinueCamera) then
				if not flag2 then
					return
				end

				flag2 = false
				local v18 = cFrame
				cFrame = nil

				if v18 == nil then
					Camera_Traffic_Handler.Dialogue = false
				else
					local function fn()
						Camera_Traffic_Handler.Dialogue = false
					end

					lerpCameraTo(v18, fn) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end

	local v18 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fireHidden()
		local v19 = v18
		v18 = nil

		if v19 ~= nil and typeof2(v19.OnHidden) == "function" then
			task.spawn(v19.OnHidden, instance, Dialogue.Storage)
		end
	end

	local v19 = nil
	local v20 = 0

	local function tryEnableClick(p3)
		local v21 = v20 - os.clock()

		if v21 > 0 then
			task.delay(v21, function()
				if v19 == p3 then
					value3:Set(true)
				end
			end)
		else
			value3:Set(true)
		end
	end

	local function PerformDialogue(p3: string)
		local v21 = math.random(1, 999)
		v19 = v21
		fireHidden() -- equivalent call inferred; original call site unknown
		diagloue = Dialogue.Diagloues[p3]

		if diagloue == nil or diagloue.Text == nil or diagloue.Answers == nil then
			value3:Reset()

			if flag2 then
				flag2 = false
				local v22 = cFrame
				cFrame = nil

				if v22 == nil then
					Camera_Traffic_Handler.Dialogue = false
				else
					local function fn()
						Camera_Traffic_Handler.Dialogue = false
					end

					lerpCameraTo(v22, fn) -- equivalent call inferred; original call site unknown
				end
			end

			DialogueUtility.Close()
		else
			v20 = os.clock() + (tonumber(diagloue.MinShowTime) or 0)

			if diagloue.NotSkipable or diagloue.NoInput then
				value3:Reset()
			else
				if v20 > os.clock() then
					value3:Reset()
				end

				tryEnableClick(v21)
			end

			applyNodeCamera(diagloue)
			applyNodeIcon(diagloue)

			if typeof2(diagloue.OnShow) == "function" then
				task.spawn(diagloue.OnShow, instance, Dialogue.Storage)
			end

			v18 = diagloue
			v17 = p3
			local content

			if type(diagloue.Content) == "function" then
				content = diagloue.Content
			end

			if content ~= v12 then
				-- equivalent call inferred; original call site unknown
				if not resolveContinue(diagloue.ContinueContent) then
					v12 = content

					if v11 ~= nil then
						v11:Destroy()
						v11 = nil
					end

					if content ~= nil then
						v11 = v7:Extend()
						content(v11, v16.Instance, instance, Dialogue.Storage)
					end
				end
			end

			local text

			if type(diagloue.Text) == "function" then
				text = diagloue.Text(instance, Dialogue.Storage)
			else
				text = diagloue.Text
			end

			v7:Spawn(function()
				value2:Reset()
				local children = v8:GetChildren()

				for i = 1, #children do
					children[i]:Destroy()
				end

				flag = true
				local clone = table.clone(gameSettings.DialogueTextSettings)

				if v3 and clone.MobileScale ~= nil then
					clone.Scale = clone.MobileScale
				end

				clone.MobileScale = nil
				clone.Overfill = true
				local Y = v8.AbsoluteSize.Y

				if Y > 0 then
					for _ = 1, 6 do
						if textplus.new(text, clone):GetContentSize(v8).Y <= Y * 0.98 then
							break
						else
							clone.Scale *= 0.92
						end
					end
				end

				v9, v10 = textplus.new(text, clone):Play(v8)
				v9:Wait()
				v9 = nil
				flag = false
				local answers = diagloue.Answers

				if typeof(answers) == "table" then
					value3:Reset()
					count = 0
					local v22 = v20 - os.clock()

					if v22 > 0 then
						task.delay(v22, function()
							if v19 == v21 then
								value2:Set(answers)
							end
						end)
					else
						value2:Set(answers)
					end
				elseif answers == true then
					if diagloue.NoInput then
						value3:Reset()
					else
						tryEnableClick(v21)
					end
				else
					value3:Reset()

					if typeof2(answers) == "number" then
						if answers ~= 1e999 then
							task.delay(answers, function()
								if v19 == v21 then
									DialogueUtility.Close()
								end
							end)
						end
					else
						DialogueUtility.Close()
					end
				end

				if typeof2(diagloue.AutoNext) == "number" then
					task.delay(diagloue.AutoNext, function()
						if v19 ~= v21 then
							return
						end

						if diagloue.IfTrue then
							DialogueUtility.DoAll(diagloue.IfTrue, instance)
						else
							DialogueUtility.Close()
						end
					end)
				end
			end)
		end
	end

	PerformDialogue(value)
	v7:Connect(Dialogue.AttemptDialogue, function(p3)
		PerformDialogue(p3)
	end)
	local track = nil

	if position ~= nil and primaryPart ~= nil and maxActivationDistance ~= nil then
		local primaryPart2

		if instance2:IsA("BasePart") then
			primaryPart2 = instance2
		else
			primaryPart2 = instance2.PrimaryPart
		end

		local v21 = instance2:IsA("Model") and instance2:GetAttribute("IdleNpc") == true or instance2:GetAttribute("NoDialogueTurn") == true
		local defaultCF = instance2:GetAttribute("DefaultCF")

		if not v21 and defaultCF == nil and primaryPart2 ~= nil then
			defaultCF = primaryPart2.CFrame
			instance2:SetAttribute("DefaultCF", defaultCF)
		end

		local humanoid = instance2:FindFirstChild("Humanoid")

		if humanoid ~= nil then
			if instance2:GetAttribute("NoDialogueAnim") ~= true then
				track = humanoid.Animator:LoadAnimation(script.NpcYaps:FindFirstChild("Anim" .. math.random(1, 3)))
				track:Play()
			end

			if not v21 and primaryPart2 ~= nil and defaultCF ~= nil then
				local position2 = primaryPart.Position
				TweenService:Create(primaryPart2, tweenInfo, {
					CFrame = CFrame.new(
						defaultCF.Position,
						(vector.create(position2.X, defaultCF.Position.Y, position2.Z))
					)
				}):Play()
			end
		end

		task.spawn(function()
			while v7.IsActive and primaryPart ~= nil do
				if maxActivationDistance < vector.magnitude(primaryPart.Position - position) then
					DialogueUtility.Close()
				end

				task.wait(0.2)
			end
		end)
	end

	return function()
		v19 = nil
		SignalEvent.ToServer("NpcTalking", "Ended")
		fireHidden() -- equivalent call inferred; original call site unknown

		if flag2 then
			flag2 = false
			local v21 = cFrame
			cFrame = nil

			if v21 == nil then
				Camera_Traffic_Handler.Dialogue = false
			else
				local function fn()
					Camera_Traffic_Handler.Dialogue = false
				end

				lerpCameraTo(v21, fn) -- equivalent call inferred; original call site unknown
			end
		end

		if track ~= nil then
			track:Stop(0.5)
		end

		if instance2 ~= nil and instance2:IsA("Model") and instance2:FindFirstChild("Humanoid") ~= nil and instance2:GetAttribute("IdleNpc") ~= true and instance2:GetAttribute("NoDialogueTurn") ~= true then
			local primaryPart2 = instance2.PrimaryPart

			if primaryPart2 ~= nil then
				local defaultCF = instance2:GetAttribute("DefaultCF")

				if defaultCF ~= nil then
					TweenService:Create(primaryPart2, tweenInfo, {
						CFrame = defaultCF
					}):Play()
				end
			end
		end

		value3:Reset()
		v7:Destroy()
	end
end