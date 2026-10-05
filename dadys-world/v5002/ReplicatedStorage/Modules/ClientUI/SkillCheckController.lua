local SkillCheckController = {}
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage2.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage2.SharedUtils.Audio)
local SkillCheckTouchButton = require(ReplicatedStorage2.Modules.Gameplay.SkillCheckTouchButton)
local v = nil
local v2 = nil
local count = 0

function SkillCheckController.abortActive(p)
	local v3 = v2

	if not v3 or p ~= nil and v3.generator ~= p then
		return
	end

	v3.abort()
end

function SkillCheckController.isDoorCheckActive()
	local generator = v2 and v2.generator
	return typeof(generator) == "Instance" and generator:GetAttribute("TrickOrTreatUsed") ~= nil
end

function SkillCheckController.init(p)
	v = p
	local calibrate = GameContext.Gui and GameContext.Gui.Menu and GameContext.Gui.Menu:FindFirstChild("Calibrate")
	local buttonDisplay = calibrate and calibrate:FindFirstChild("ButtonDisplay")

	if calibrate and buttonDisplay then
		SkillCheckController.setupCalibrateHoverEffect(calibrate, buttonDisplay)
	end
end

function SkillCheckController:setupCalibrateHoverEffect(p)
	self.AutoButtonColor = false
	local backgroundColor3 = p.BackgroundColor3
	local color = Color3.new(backgroundColor3.R * 0.85, backgroundColor3.G * 0.85, backgroundColor3.B * 0.85)
	local color2 = Color3.new(backgroundColor3.R * 0.7, backgroundColor3.G * 0.7, backgroundColor3.B * 0.7)
	local v3 = false
	local v4 = nil
	self.MouseEnter:Connect(function()
		v3 = true

		if not v4 then
			p.BackgroundColor3 = color
		end
	end)
	self.MouseLeave:Connect(function()
		v3 = false

		if not v4 then
			p.BackgroundColor3 = backgroundColor3
		end
	end)
	self.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v4 = input
			p.BackgroundColor3 = color2
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input ~= v4 then
			return
		end

		v4 = nil
		p.BackgroundColor3 = v3 and color or backgroundColor3
	end)
end

function SkillCheckController.areFramesOverlapping(p, p2)
	local scale = p.Position.Width.Scale
	local scale2 = p2.Position.Width.Scale
	local v3 = p2.Position.Width.Scale + p2.Size.Width.Scale
	return scale2 <= scale and scale <= v3
end

function SkillCheckController.hideAllUI()
	local gui = GameContext.Gui

	if gui and gui.Menu then
		local skillCheckFrame = gui.Menu:FindFirstChild("SkillCheckFrame")

		if skillCheckFrame then
			skillCheckFrame.Visible = false
		end

		local spaceBarPromptText = gui.Menu:FindFirstChild("SpaceBarPromptText")

		if spaceBarPromptText then
			spaceBarPromptText.Visible = false
		end

		local calibrate = gui.Menu:FindFirstChild("Calibrate")

		if calibrate then
			calibrate.Visible = false
		end

		local skillCheckMessage = gui.Menu:FindFirstChild("SkillCheckMessage")

		if skillCheckMessage then
			skillCheckMessage.Visible = false
		end
	end
end

function SkillCheckController.updatePromptText(currentMinigameType)
	if GameContext.skillchecking then
		return
	end

	if currentMinigameType then
		GameContext.currentMinigameType = currentMinigameType
	elseif not GameContext.currentgenerator then
		GameContext.currentMinigameType = "default"
	end

	local inputManager = GameContext.Player.PlayerScripts:FindFirstChild("InputManager", true)

	if inputManager then
		local updateSkillCheckPrompt = inputManager:FindFirstChild("UpdateSkillCheckPrompt")

		if updateSkillCheckPrompt and updateSkillCheckPrompt:IsA("BindableFunction") then
			updateSkillCheckPrompt:Invoke(GameContext.currentMinigameType)
		end
	end
end

function SkillCheckController.disconnectRenderStep()
	local renderstep = GameContext.renderstep

	if renderstep then
		renderstep:Disconnect()
		GameContext.renderstep = nil
	end
end

function SkillCheckController.startCleanupLoop()
	task.spawn(function()
		while true do
			task.wait(1)

			if GameContext.skillchecking or GameContext.currentgenerator ~= nil then
				continue
			end

			local gui = GameContext.Gui

			if not (gui and gui.Menu) then
				continue
			end

			if not (gui.Menu.SpaceBarPromptText.Visible == true or gui.Menu.Calibrate.Visible == true or gui.Menu:FindFirstChild("SkillCheckMessage") and gui.Menu.SkillCheckMessage.Visible == true) then
				continue
			end

			SkillCheckController.hideAllUI()
		end
	end)
end

local function getTrinketCustomProperties()
	local generatorText = nil
	local generatorSound = nil

	for i = 1, 2 do
		local attribute = GameContext.Player:GetAttribute("EquippedTrinket" .. i)

		if not attribute then
			continue
		end

		local child = ReplicatedStorage2.TrinketData:FindFirstChild(attribute)

		if not child then
			continue
		end

		local success, result = pcall(require, child)

		if not (success and result) then
			continue
		end

		if result.GeneratorText then
			generatorText = result.GeneratorText
		end

		if result.GeneratorSound then
			generatorSound = result.GeneratorSound
		end

		if generatorText or generatorSound then
			break
		end
	end

	return generatorText, generatorSound
end

function SkillCheckController.playFailFeedback()
	local gui = GameContext.Gui

	if not gui then
		return
	end

	task.spawn(function()
		local trinketCustomProperties, v3 = getTrinketCustomProperties()

		if v3 then
			Audio:Play(v3, {
				Parent = gui
			})
		else
			Audio:Play("Sounds.UI.SkillCheck.Wrong")
		end

		local skillCheckMessage = gui.Menu and gui.Menu:FindFirstChild("SkillCheckMessage")

		if not skillCheckMessage then
			return
		end

		skillCheckMessage.Text = trinketCustomProperties or "Be careful! They can hear you..."
		skillCheckMessage.UIGradient.Enabled = true
		skillCheckMessage.UIGradientWin.Enabled = false
		skillCheckMessage.Visible = true
		skillCheckMessage.TextTransparency = 0
		skillCheckMessage.TextStrokeTransparency = 0
		task.wait(2)
		local tween = TweenService:Create(
			skillCheckMessage,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false),
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
		skillCheckMessage.Visible = false
	end)
end

local function runHorizontalSkillCheck(p, value, character, generator)
	local gui = GameContext.Gui
	local humanoid = character and character.Parent and character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return "noinput", false
	end

	SkillCheckController.abortActive()
	count += 1
	local token = count
	GameContext.skillchecking = true
	local v4 = false
	local v5 = nil
	local v6 = nil
	local fn
	local connection = nil
	local connection2 = nil
	local completedConnection = nil
	local renderSteppedConnection = nil
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function releaseRenderStep()
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()

			if GameContext.renderstep == renderSteppedConnection then
				GameContext.renderstep = nil
			end

			renderSteppedConnection = nil
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function releaseBinds()
		if connection then
			connection:Disconnect()
		end

		if connection2 then
			connection2:Disconnect()
		end

		if completedConnection then
			completedConnection:Disconnect()
		end

		releaseRenderStep() -- equivalent call inferred; original call site unknown
	end

	v2 = {
		token = token,
		generator = generator,
		abort = function()
			if v2 and v2.token == token then
				v2 = nil
			end

			if v5 ~= nil then
				return
			end

			flag = true
			releaseBinds() -- equivalent call inferred; original call site unknown

			if v6 then
				v6:Cancel()
			end

			gui.Menu.SkillCheckFrame.Visible = false
			gui.Menu.Calibrate.Visible = false
			v5 = "noinput"
		end
	}
	gui.Menu.SkillCheckFrame.Visible = true
	gui.Menu.Calibrate.Visible = true
	connection2 = SkillCheckTouchButton.bind(gui.Menu.Calibrate, function()
		return v6 ~= nil and v4 == false
	end, function()
		fn()
	end)
	gui.Menu.SpaceBarPromptText.Visible = true
	SkillCheckController.updatePromptText("default")
	gui.Menu.StopGenerator.Visible = false
	gui.Menu.SkillCheckMessage.Visible = false
	gui.Menu.SkillCheckMessage.TextTransparency = 1
	gui.Menu.SkillCheckMessage.TextStrokeTransparency = 1
	gui.Menu.SkillCheckFrame.RequiredArea.Size = UDim2.new(p, 0, 1, 0)
	gui.Menu.SkillCheckFrame.RequiredArea.Position = UDim2.new(math.clamp(value, 0.1, 0.75), 0, 0, 0)
	gui.Menu.SkillCheckFrame.GoldArea.Size = UDim2.new(p / 3, 0, 1, 0)
	gui.Menu.SkillCheckFrame.GoldArea.Position = gui.Menu.SkillCheckFrame.RequiredArea.Position + UDim2.new(
		(p - p / 3) / 2,
		0,
		0,
		0
	)
	gui.Menu.SkillCheckFrame.Marker.Position = UDim2.new(0, 0, -0.399, 0)
	gui.Menu.SkillCheckFrame.Position = UDim2.new(0.35, 0, 0.8, 0)
	gui.Menu.SkillCheckFrame.RequiredArea.BackgroundTransparency = 1
	gui.Menu.SkillCheckFrame.GoldArea.BackgroundTransparency = 1
	gui.Menu.SkillCheckFrame.Marker.BackgroundTransparency = 1
	gui.Menu.SkillCheckFrame.BackgroundTransparency = 1
	Audio:PlayOne("Sounds.UI.SkillCheck.SkillCheck")
	local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	TweenService:Create(gui.Menu.SkillCheckFrame, tweenInfo, {
		Position = UDim2.new(0.35, 0, 0.78, 0)
	}):Play()
	TweenService:Create(gui.Menu.SkillCheckFrame, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(gui.Menu.SkillCheckFrame.Marker, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(gui.Menu.SkillCheckFrame.RequiredArea, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(gui.Menu.SkillCheckFrame.GoldArea, tweenInfo, {
		Transparency = 0
	}):Play()
	task.wait(1)

	if flag then
		return v5, true
	end

	if GameContext.currentgenerator == nil or humanoid.Health <= 0 then
		connection2:Disconnect()
		gui.Menu.SkillCheckFrame.Visible = false
		gui.Menu.Calibrate.Visible = false
		gui.Menu.SkillCheckMessage.Visible = false
		gui.Menu.SpaceBarPromptText.Visible = false
		v2 = nil
		return "noinput", false
	else
		local tweenInfo2 = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		local v7 = false
		local v8 = false
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local areFramesOverlapping = SkillCheckController.areFramesOverlapping(
				gui.Menu.SkillCheckFrame.Marker,
				gui.Menu.SkillCheckFrame.RequiredArea
			)

			if SkillCheckController.areFramesOverlapping(
				gui.Menu.SkillCheckFrame.Marker,
				gui.Menu.SkillCheckFrame.GoldArea
			) then
				if not v8 then
					v8 = true
					v7 = false
					Audio:PlayOne("Sounds.UI.SkillCheck.Ticks.TinierTick")
				end
			else
				v8 = false
			end

			if areFramesOverlapping and not (v7 or v8) then
				v7 = true
				Audio:PlayOne("Sounds.UI.SkillCheck.Ticks.TinyTick")
			end
		end)
		GameContext.renderstep = renderSteppedConnection

		-- equivalent calls inferred from this helper; original call sites unknown
		local function disconnectAll()
			if connection then
				connection:Disconnect()
			end

			if connection2 then
				connection2:Disconnect()
			end

			releaseRenderStep() -- equivalent call inferred; original call site unknown
		end

		fn = function()
			v4 = true
			v6:Pause()
			v6:Destroy()
			local areFramesOverlapping = SkillCheckController.areFramesOverlapping(
				gui.Menu.SkillCheckFrame.Marker,
				gui.Menu.SkillCheckFrame.RequiredArea
			)
			local areFramesOverlapping2 = SkillCheckController.areFramesOverlapping(
				gui.Menu.SkillCheckFrame.Marker,
				gui.Menu.SkillCheckFrame.GoldArea
			)

			if areFramesOverlapping then
				if areFramesOverlapping2 then
					gui.Menu.SkillCheckFrame.Visible = false
					gui.Menu.Calibrate.Visible = false
					v4 = false
					v5 = "supercomplete"

					if v.haptic then
						v.haptic:Play("PulseSingle")
					end

					if GameContext.currentgenerator ~= nil then
						Audio:PlayOne("Sounds.UI.SkillCheck.Correct")
						Audio:PlayOne("Sounds.UI.SkillCheck.GoldAreaHit")
						task.spawn(function()
							gui.Menu.SkillCheckMessage.Text = "Great Job!"
							gui.Menu.SkillCheckMessage.UIGradient.Enabled = false
							gui.Menu.SkillCheckMessage.UIGradientWin.Enabled = true
							gui.Menu.SkillCheckMessage.Visible = true
							gui.Menu.SpaceBarPromptText.Visible = true
							gui.Menu.SkillCheckMessage.TextTransparency = 0
							gui.Menu.SkillCheckMessage.TextStrokeTransparency = 0
							task.wait(1)
							local tweenInfo3 = TweenInfo.new(
								1,
								Enum.EasingStyle.Quad,
								Enum.EasingDirection.Out,
								0,
								false
							)
							local tween = TweenService:Create(gui.Menu.SkillCheckMessage, tweenInfo3, {
								TextTransparency = 1,
								TextStrokeTransparency = 1
							})
							tween:Play()
							tween.Completed:Wait()
							gui.Menu.SkillCheckMessage.Visible = false
						end)
					end
				else
					gui.Menu.SkillCheckFrame.Visible = false
					gui.Menu.Calibrate.Visible = false
					v4 = false
					v5 = true

					if v.haptic then
						v.haptic:Play("PulseSingleSmall")
					end

					if GameContext.currentgenerator ~= nil then
						Audio:PlayOne("Sounds.UI.SkillCheck.Correct")
						task.spawn(function()
							gui.Menu.SkillCheckMessage.Text = "Good Job!"
							gui.Menu.SkillCheckMessage.UIGradient.Enabled = true
							gui.Menu.SkillCheckMessage.UIGradientWin.Enabled = false
							gui.Menu.SkillCheckMessage.Visible = true
							gui.Menu.SpaceBarPromptText.Visible = true
							gui.Menu.SkillCheckMessage.TextTransparency = 0
							gui.Menu.SkillCheckMessage.TextStrokeTransparency = 0
							task.wait(1)
							local tweenInfo3 = TweenInfo.new(
								1,
								Enum.EasingStyle.Quad,
								Enum.EasingDirection.Out,
								0,
								false
							)
							local tween = TweenService:Create(gui.Menu.SkillCheckMessage, tweenInfo3, {
								TextTransparency = 1,
								TextStrokeTransparency = 1
							})
							tween:Play()
							tween.Completed:Wait()
							gui.Menu.SkillCheckMessage.Visible = false
						end)
					end
				end
			else
				gui.Menu.SkillCheckFrame.Visible = false
				gui.Menu.Calibrate.Visible = false
				v4 = false
				v5 = false

				if GameContext.currentgenerator ~= nil then
					task.spawn(function()
						local trinketCustomProperties, v9 = getTrinketCustomProperties()

						if v9 then
							Audio:Play(v9, {
								Parent = gui
							})
						else
							Audio:Play("Sounds.UI.SkillCheck.Wrong")
						end

						if trinketCustomProperties then
							gui.Menu.SkillCheckMessage.Text = trinketCustomProperties
						else
							gui.Menu.SkillCheckMessage.Text = "Be careful! They can hear you..."
						end

						gui.Menu.SkillCheckMessage.Visible = true
						gui.Menu.SpaceBarPromptText.Visible = true
						SkillCheckController.updatePromptText(GameContext.currentMinigameType)
						gui.Menu.SkillCheckMessage.UIGradient.Enabled = true
						gui.Menu.SkillCheckMessage.UIGradientWin.Enabled = false
						gui.Menu.SkillCheckMessage.TextTransparency = 0
						gui.Menu.SkillCheckMessage.TextStrokeTransparency = 0
						task.wait(2)
						local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
						local tween = TweenService:Create(gui.Menu.SkillCheckMessage, tweenInfo3, {
							TextTransparency = 1,
							TextStrokeTransparency = 1
						})
						tween:Play()
						tween.Completed:Wait()
						gui.Menu.SkillCheckMessage.Visible = false
					end)
				end
			end

			disconnectAll() -- equivalent call inferred; original call site unknown
		end

		v6 = TweenService:Create(gui.Menu.SkillCheckFrame.Marker, tweenInfo2, {
			Position = UDim2.new(1, 0, -0.399, 0)
		})
		connection = InputService:OnAction("SkillCheckTap", function()
			if InputService:IsTyping() then
				return
			end

			if v4 == false then
				fn()
			end
		end)
		v6:Play()
		completedConnection = v6.Completed:Connect(function()
			gui.Menu.SkillCheckFrame.Visible = false
			gui.Menu.Calibrate.Visible = false
			v4 = false
			v5 = "noinput"

			if GameContext.currentgenerator ~= nil and humanoid.Health > 0 then
				task.spawn(function()
					local trinketCustomProperties, v9 = getTrinketCustomProperties()

					if v9 then
						Audio:Play(v9, {
							Parent = gui
						})
					else
						Audio:Play("Sounds.UI.SkillCheck.Wrong")
					end

					if trinketCustomProperties then
						gui.Menu.SkillCheckMessage.Text = trinketCustomProperties
					else
						gui.Menu.SkillCheckMessage.Text = "Be careful! They can hear you..."
					end

					gui.Menu.SpaceBarPromptText.Visible = true
					gui.Menu.SkillCheckMessage.Visible = true
					gui.Menu.SkillCheckMessage.UIGradient.Enabled = true
					gui.Menu.SkillCheckMessage.UIGradientWin.Enabled = false
					gui.Menu.SkillCheckMessage.TextTransparency = 0
					gui.Menu.SkillCheckMessage.TextStrokeTransparency = 0
					task.wait(2)
					local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
					local tween = TweenService:Create(gui.Menu.SkillCheckMessage, tweenInfo3, {
						TextTransparency = 1,
						TextStrokeTransparency = 1
					})
					tween:Play()
					tween.Completed:Wait()
					gui.Menu.SkillCheckMessage.Visible = false
				end)
			end

			releaseBinds() -- equivalent call inferred; original call site unknown
		end)

		while v5 == nil do
			task.wait()
		end

		releaseBinds() -- equivalent call inferred; original call site unknown

		if v2 and v2.token == token then
			v2 = nil
		end

		return v5, flag
	end
end

function SkillCheckController.handleInvoke(generator, p2, p3)
	local gui = GameContext.Gui
	local character = GameContext.Character
	local currentMinigameType = GameContext.currentMinigameType

	if generator ~= "cancel" then
		pcall(function()
			local StickerController = require(ReplicatedStorage2.Modules.ClientUI.StickerController)

			if StickerController.ForceCloseWheel then
				StickerController.ForceCloseWheel()
			end
		end)
	end

	if generator == "cancel" then
		SkillCheckController.abortActive()

		if GameContext.skillchecking ~= true then
			return "cancelled"
		end

		v.circleHandler.CleanUp(GameContext.Player)
		v.treadmillHandler.ForceStopSkillCheck()
		GameContext.skillchecking = false
		SkillCheckController.hideAllUI()
		return "cancelled"
	elseif generator and type(p2) == "table" and p2.type == "treadmill" then
		if gui.Menu.SpaceBarPromptText then
			gui.Menu.SpaceBarPromptText.Visible = true
			SkillCheckController.updatePromptText("movement")
		end

		gui.Menu.StopGenerator.Visible = false
		local trinketCustomProperties, v3 = getTrinketCustomProperties()
		GameContext.skillchecking = true
		local v4 = v.treadmillHandler.HandleSkillCheck(GameContext.Player, p2, trinketCustomProperties, v3)
		GameContext.skillchecking = false

		if GameContext.currentgenerator == nil then
			gui.Menu.SpaceBarPromptText.Visible = false
			return v4
		end

		gui.Menu.StopGenerator.Visible = true
		gui.Menu.SpaceBarPromptText.Visible = true
		GameContext.currentMinigameType = currentMinigameType
		SkillCheckController.updatePromptText(currentMinigameType)
		return v4
	elseif generator and type(p2) == "table" and p2.type == "circle" then
		if gui.Menu.SpaceBarPromptText then
			gui.Menu.SpaceBarPromptText.Visible = true
			SkillCheckController.updatePromptText("circle")
		end

		gui.Menu.StopGenerator.Visible = false
		GameContext.skillchecking = true
		local v3 = v.circleHandler.HandleSkillCheck(GameContext.Player, p2)
		GameContext.skillchecking = false

		if GameContext.currentgenerator == nil then
			gui.Menu.SpaceBarPromptText.Visible = false
			return v3
		end

		gui.Menu.StopGenerator.Visible = true
		gui.Menu.SpaceBarPromptText.Visible = true
		GameContext.currentMinigameType = currentMinigameType
		SkillCheckController.updatePromptText(currentMinigameType)
		return v3
	else
		if not (generator and p2 and p3) then
			return "noinput"
		end

		local v3, v4 = runHorizontalSkillCheck(p2, p3, character, generator)

		if v4 then
			return v3
		end

		if GameContext.currentgenerator == nil then
			gui.Menu.SpaceBarPromptText.Visible = false
		else
			gui.Menu.StopGenerator.Visible = true
			gui.Menu.SpaceBarPromptText.Visible = true
			GameContext.currentMinigameType = currentMinigameType
			SkillCheckController.updatePromptText(currentMinigameType)
		end

		GameContext.skillchecking = false
		return v3
	end
end

return SkillCheckController