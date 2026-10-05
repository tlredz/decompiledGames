local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local tweenHelpers = require(game.ReplicatedStorage.SharedUtils.tweenHelpers)
local styleController = require(game.ReplicatedStorage.SharedUtils.styleController)
local events = ReplicatedStorage:WaitForChild("Events", 10)

if not events then
	warn("[TwistedSquirmEscapeUI] Events folder not found!")
	return
end

local twistedSquirmGrab = nil
local flag = false
local flag2 = false
local v = 0
local v2 = nil
local now = 0
local count = 0
local v3 = {
	STRUGGLES_TO_ESCAPE = 20,
	PROGRESS_PER_STRUGGLE = 5,
	MIN_INPUT_INTERVAL = 0.05,
	DECAY_RATE = 3,
	DECAY_DELAY = 0.8,
	WRONG_INPUT_PENALTY = 2,
	WRONG_INPUT_COOLDOWN = 0.15,
	TOUCH_ZONE_WIDTH = 0.4,
	STICK_THRESHOLD = 0.5
}
local v4 = nil
local escapeFrame = nil
local progressBar = nil
local fill = nil
local title = nil
local hint = nil
local directionIndicator = nil
local leftArrow = nil
local rightArrow = nil
local leftArrowBg = nil
local rightArrowBg = nil
local timerBar = nil
local fill2 = nil
local vignette = nil
local leftTouchZone = nil
local rightTouchZone = nil
local nextIndicator = nil
local v5 = nil

local function createEscapeUI()
	local twistedSquirmEscapeUI = playerGui:WaitForChild("TwistedSquirmEscapeUI", 5)

	if not twistedSquirmEscapeUI then
		warn("[TwistedSquirmEscapeUI] TwistedSquirmEscapeUI never arrived in PlayerGui — struggle UI unavailable")
		return false
	end

	vignette = twistedSquirmEscapeUI:WaitForChild("Vignette")
	escapeFrame = twistedSquirmEscapeUI:WaitForChild("EscapeFrame")
	tweenHelpers.saveInitials(escapeFrame)
	title = escapeFrame:WaitForChild("Title")
	directionIndicator = escapeFrame:WaitForChild("DirectionIndicator")
	hint = escapeFrame:WaitForChild("Hint")
	progressBar = escapeFrame:WaitForChild("ProgressBar")
	timerBar = escapeFrame:WaitForChild("TimerBar")
	leftArrowBg = directionIndicator:WaitForChild("LeftArrowBg")
	rightArrowBg = directionIndicator:WaitForChild("RightArrowBg")
	nextIndicator = directionIndicator:WaitForChild("NextIndicator")
	leftArrow = leftArrowBg:WaitForChild("LeftArrow")
	rightArrow = rightArrowBg:WaitForChild("RightArrow")
	fill = progressBar:WaitForChild("Fill")
	fill2 = timerBar:WaitForChild("Fill")
	leftTouchZone = twistedSquirmEscapeUI:WaitForChild("LeftTouchZone")
	rightTouchZone = twistedSquirmEscapeUI:WaitForChild("RightTouchZone")
	v5 = styleController.new(twistedSquirmEscapeUI.Stylesheets)
	v5:Apply(directionIndicator, "directionIndicator")
	v5:Apply(timerBar, "timerBar")
	v4 = twistedSquirmEscapeUI
	return true
end

local renderSteppedConnection = nil

local function screenShake(shakeDuration, shakeIntensity)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local lastTime = tick()

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v6 = tick() - lastTime

		if shakeDuration < v6 then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		else
			local v7 = shakeIntensity * (1 - v6 / shakeDuration)
			local v8 = (math.random() - 0.5) * 2 * v7 * 0.01
			local v9 = (math.random() - 0.5) * 2 * v7 * 0.01
			currentCamera.CFrame *= CFrame.new(v8, v9, 0)
		end
	end)
end

local function screenBlur(blurDuration, blurSize)
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "SquirmEscapeBlur"
	blurEffect.Size = blurSize
	blurEffect.Parent = Lighting
	TweenService:Create(blurEffect, TweenInfo.new(blurDuration), {
		Size = 0
	}):Play()
	task.delay(blurDuration, function()
		blurEffect:Destroy()
	end)
end

local function getInputHint()
	return "Wiggle back and forth to break free!"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateArrowLabels()
	leftArrow.Text = "◄◄"
	rightArrow.Text = "►►"
end

local thread = nil
local thread2 = nil
local distributedGameTime = 0
local v6 = 4

local function highlightNextSide(p)
	if not (leftArrowBg and rightArrowBg) then
		return
	end

	local color = Color3.fromRGB(80, 180, 80)
	local color2 = Color3.fromRGB(40, 80, 40)
	local color3 = Color3.fromRGB(100, 255, 100)
	local color4 = Color3.fromRGB(100, 100, 100)
	local color5 = Color3.fromRGB(40, 40, 40)
	local color6 = Color3.fromRGB(60, 60, 60)
	local color7 = Color3.fromRGB(40, 80, 50)
	local color8 = Color3.fromRGB(150, 255, 150)
	local color9 = Color3.fromRGB(80, 200, 100)
	local color10 = Color3.fromRGB(50, 35, 35)
	local color11 = Color3.fromRGB(150, 120, 120)
	local color12 = Color3.fromRGB(100, 60, 60)

	if p == "left" or p == nil then
		TweenService:Create(leftArrow, TweenInfo.new(0.1), {
			TextColor3 = color
		}):Play()
		TweenService:Create(leftArrowBg, TweenInfo.new(0.1), {
			BackgroundColor3 = color2
		}):Play()
		local stroke = leftArrowBg:FindFirstChild("Stroke")

		if stroke then
			TweenService:Create(stroke, TweenInfo.new(0.1), {
				Color = color3
			}):Play()
		end

		if leftTouchZone and leftTouchZone.Visible then
			TweenService:Create(leftTouchZone, TweenInfo.new(0.1), {
				BackgroundColor3 = color7,
				TextColor3 = color8
			}):Play()
			local uIStroke = leftTouchZone:FindFirstChildOfClass("UIStroke")

			if uIStroke then
				TweenService:Create(uIStroke, TweenInfo.new(0.1), {
					Color = color9
				}):Play()
			end
		end
	else
		TweenService:Create(leftArrow, TweenInfo.new(0.1), {
			TextColor3 = color4
		}):Play()
		TweenService:Create(leftArrowBg, TweenInfo.new(0.1), {
			BackgroundColor3 = color5
		}):Play()
		local stroke = leftArrowBg:FindFirstChild("Stroke")

		if stroke then
			TweenService:Create(stroke, TweenInfo.new(0.1), {
				Color = color6
			}):Play()
		end

		if leftTouchZone and leftTouchZone.Visible then
			TweenService:Create(leftTouchZone, TweenInfo.new(0.1), {
				BackgroundColor3 = color10,
				TextColor3 = color11
			}):Play()
			local uIStroke = leftTouchZone:FindFirstChildOfClass("UIStroke")

			if uIStroke then
				TweenService:Create(uIStroke, TweenInfo.new(0.1), {
					Color = color12
				}):Play()
			end
		end
	end

	if p == "right" or p == nil then
		TweenService:Create(rightArrow, TweenInfo.new(0.1), {
			TextColor3 = color
		}):Play()
		TweenService:Create(rightArrowBg, TweenInfo.new(0.1), {
			BackgroundColor3 = color2
		}):Play()
		local stroke = rightArrowBg:FindFirstChild("Stroke")

		if stroke then
			TweenService:Create(stroke, TweenInfo.new(0.1), {
				Color = color3
			}):Play()
		end

		if rightTouchZone and rightTouchZone.Visible then
			TweenService:Create(rightTouchZone, TweenInfo.new(0.1), {
				BackgroundColor3 = color7,
				TextColor3 = color8
			}):Play()
			local uIStroke = rightTouchZone:FindFirstChildOfClass("UIStroke")

			if uIStroke then
				TweenService:Create(uIStroke, TweenInfo.new(0.1), {
					Color = color9
				}):Play()
			end
		end
	else
		TweenService:Create(rightArrow, TweenInfo.new(0.1), {
			TextColor3 = color4
		}):Play()
		TweenService:Create(rightArrowBg, TweenInfo.new(0.1), {
			BackgroundColor3 = color5
		}):Play()
		local stroke = rightArrowBg:FindFirstChild("Stroke")

		if stroke then
			TweenService:Create(stroke, TweenInfo.new(0.1), {
				Color = color6
			}):Play()
		end

		if rightTouchZone and rightTouchZone.Visible then
			TweenService:Create(rightTouchZone, TweenInfo.new(0.1), {
				BackgroundColor3 = color10,
				TextColor3 = color11
			}):Play()
			local uIStroke = rightTouchZone:FindFirstChildOfClass("UIStroke")

			if uIStroke then
				TweenService:Create(uIStroke, TweenInfo.new(0.1), {
					Color = color12
				}):Play()
			end
		end
	end

	if nextIndicator then
		if p == nil then
			nextIndicator.Text = "START!"
		elseif p == "left" then
			nextIndicator.Text = "◄◄◄"
		else
			nextIndicator.Text = "►►►"
		end
	end
end

local function updateTimerBar()
	if not (fill2 and distributedGameTime) then
		return
	end

	local v7 = workspace.DistributedGameTime - distributedGameTime
	local v8 = math.max(0, v6 - v7) / v6
	TweenService:Create(fill2, TweenInfo.new(0.1), {
		Size = UDim2.new(math.clamp(v8, 0, 1), 0, 1, 0)
	}):Play()

	if v8 > 0.5 then
		Color3.fromRGB(200, 150, 60)
	elseif v8 > 0.25 then
		Color3.fromRGB(220, 100, 50)
	else
		Color3.fromRGB(220, 50, 50)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startTimerLoop()
	if thread2 then
		return
	end

	thread2 = task.spawn(function()
		while flag2 do
			updateTimerBar()
			task.wait(0.1)
		end

		thread2 = nil
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTimerLoop()
	if thread2 then
		task.cancel(thread2)
		thread2 = nil
	end
end

local function updateProgressBar()
	if not fill then
		return
	end

	local v7 = v / 100
	TweenService:Create(fill, TweenInfo.new(0.08), {
		Size = UDim2.new(math.clamp(v7, 0, 1), 0, 1, 0)
	}):Play()
	local progressText = progressBar:FindFirstChild("ProgressText")

	if progressText then
		progressText.Text = string.format("%.0f%%", v)
	end

	local imageTransparency = 0.4 - v7 * 0.2

	if vignette then
		vignette.ImageTransparency = imageTransparency
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startTitlePulse()
	if thread then
		return
	end

	thread = task.spawn(function()
		thread = nil
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTitlePulse()
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

local function startDecayLoop() end

local function stopDecayLoop() end

local connections = {}

local function flashArrow(p, p2)
	p.TextColor3 = p2 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 80, 80)
	TweenService:Create(p, TweenInfo.new(0.15), {
		TextColor3 = Color3.fromRGB(150, 150, 150)
	}):Play()
end

local function flashTouchButton(instance, p)
	if not (instance and instance.Visible) then
		return
	end

	local color = p and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(100, 40, 40)
	local color2 = p and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 150, 150)
	local color3 = p and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
	instance.BackgroundColor3 = color
	instance.TextColor3 = color2
	local uIStroke = instance:FindFirstChildOfClass("UIStroke")

	if uIStroke then
		uIStroke.Color = color3
	end

	TweenService:Create(instance, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(60, 40, 40),
		TextColor3 = Color3.fromRGB(255, 200, 200)
	}):Play()

	if uIStroke then
		TweenService:Create(uIStroke, TweenInfo.new(0.15), {
			Color = Color3.fromRGB(180, 80, 80)
		}):Play()
	end
end

local function processStruggleInput(p)
	if not flag2 then
		return
	end

	local now2 = tick()

	if now2 - now < v3.MIN_INPUT_INTERVAL or v2 == p then
		return
	end

	v2 = p
	now = now2
	v = math.min(100, v + v3.PROGRESS_PER_STRUGGLE)

	if _G.SquirmArmWiggleTrigger then
		_G.SquirmArmWiggleTrigger(p)
	end

	local v7 = p == "left" and leftArrow or rightArrow
	local v8 = p == "left" and leftTouchZone or rightTouchZone
	flashArrow(v7, true)
	flashTouchButton(v8, true)
	highlightNextSide(p == "left" and "right" or "left")

	if p == "left" then
		directionIndicator:SetAttribute("direction", 1)
	elseif p == "right" then
		directionIndicator:SetAttribute("direction", 0)
	end

	if vignette then
		vignette.ImageTransparency = 0.2
		TweenService:Create(vignette, TweenInfo.new(0.1), {
			ImageTransparency = 0.4
		}):Play()
	end

	updateProgressBar()

	if twistedSquirmGrab then
		twistedSquirmGrab:FireServer("Struggle", p)
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local cframe = CFrame.new((math.random() - 0.5) * 0.02, (math.random() - 0.5) * 0.02, 0)
		currentCamera.CFrame *= cframe
	end
end

local function setupInputHandlers()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connections = {}
	table.insert(connections, UserInputService.InputBegan:Connect(function(input, _)
		if not flag2 then
			return
		end

		if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
			processStruggleInput("left")
		elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
			processStruggleInput("right")
		end
	end))

	if leftTouchZone then
		table.insert(connections, leftTouchZone.MouseButton1Down:Connect(function()
			processStruggleInput("left")
		end))
		table.insert(connections, leftTouchZone.TouchTap:Connect(function()
			processStruggleInput("left")
		end))
	end

	if rightTouchZone then
		table.insert(connections, rightTouchZone.MouseButton1Down:Connect(function()
			processStruggleInput("right")
		end))
		table.insert(connections, rightTouchZone.TouchTap:Connect(function()
			processStruggleInput("right")
		end))
	end

	local v7 = {}
	local v8 = {}
	table.insert(connections, UserInputService.TouchStarted:Connect(function(p, _)
		if not flag2 then
			return
		end

		v7[p] = p.Position.X
		v8[p] = nil
	end))
	table.insert(connections, UserInputService.TouchMoved:Connect(function(p, _)
		if not flag2 then
			return
		end

		local v9 = v7[p]

		if not v9 then
			return
		end

		local X = p.Position.X
		local v10 = X - v9

		if v10 < -50 then
			if v8[p] ~= "left" then
				v8[p] = "left"
				processStruggleInput("left")
				v7[p] = X
			end
		elseif v10 > 50 and v8[p] ~= "right" then
			v8[p] = "right"
			processStruggleInput("right")
			v7[p] = X
		end
	end))
	table.insert(connections, UserInputService.TouchEnded:Connect(function(otherPart, _)
		v7[otherPart] = nil
		v8[otherPart] = nil
	end))
	local v9 = nil
	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if not flag2 then
			return
		end

		if input.KeyCode == Enum.KeyCode.Thumbstick1 or input.KeyCode == Enum.KeyCode.Thumbstick2 then
			local X = input.Position.X

			if X < -v3.STICK_THRESHOLD then
				if v9 ~= "left" then
					v9 = "left"
					processStruggleInput("left")
				end
			elseif v3.STICK_THRESHOLD < X then
				if v9 ~= "right" then
					v9 = "right"
					processStruggleInput("right")
				end
			else
				v9 = nil
			end
		end
	end))
end

local hideEscapeUI

local function isStillGrabbable(instance)
	if localPlayer.Character ~= instance or not (instance and instance.Parent) then
		return false
	end

	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers and instance.Parent ~= inGamePlayers then
		return false
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startGrabFailsafe(p, p2)
	local character = localPlayer.Character
	local v7 = os.clock() + p2 + 1.5
	task.spawn(function()
		while count == p do
			if not (v7 <= os.clock()) then
				local character2 = character
				local v9

				if localPlayer.Character == character2 and character2 and character2.Parent then
					local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

					if inGamePlayers and character2.Parent ~= inGamePlayers then
						v9 = false
					else
						local humanoid = character2:FindFirstChildOfClass("Humanoid")

						if humanoid == nil then
							v9 = false
						else
							v9 = humanoid.Health > 0
						end
					end
				else
					v9 = false
				end

				if v9 then
					task.wait(0.25)
					continue
				end
			end

			hideEscapeUI(false)
			break
		end
	end)
end

local function showEscapeUI(data)
	count += 1
	local v7 = count

	if not ((v4 or createEscapeUI()) and count == v7) then
		return
	end

	if data then
		v3.STRUGGLES_TO_ESCAPE = data.strugglesToEscape or v3.STRUGGLES_TO_ESCAPE
		v3.PROGRESS_PER_STRUGGLE = 100 / v3.STRUGGLES_TO_ESCAPE
		v3.DECAY_RATE = data.decayRate or v3.DECAY_RATE
		v3.DECAY_DELAY = data.decayDelay or v3.DECAY_DELAY
	end

	stopTimerLoop() -- equivalent call inferred; original call site unknown
	stopTitlePulse() -- equivalent call inferred; original call site unknown
	v = 0
	v2 = nil
	now = tick()
	flag2 = true
	v6 = not data and 4 or data.maxDuration or 4
	distributedGameTime = workspace.DistributedGameTime
	TweenService:Create(fill, TweenInfo.new(0), {
		Size = UDim2.new(0, 0, 1, 0)
	}):Play()
	local progressText = progressBar:FindFirstChild("ProgressText")

	if progressText then
		progressText.Text = "0%"
	end

	if vignette then
		vignette.ImageColor3 = Color3.fromRGB(0, 0, 0)
		vignette.ImageTransparency = 1
	end

	if fill2 then
		TweenService:Create(fill2, TweenInfo.new(0), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		fill2.BackgroundColor3 = Color3.fromRGB(200, 150, 60)
	end

	hint.Text = "Wiggle back and forth to break free!"
	updateArrowLabels() -- equivalent call inferred; original call site unknown
	highlightNextSide(nil)
	local touchEnabled = UserInputService.TouchEnabled
	leftTouchZone.Visible = touchEnabled
	rightTouchZone.Visible = touchEnabled

	if touchEnabled then
		leftArrowBg.Visible = false
		rightArrowBg.Visible = false
		v3.PROGRESS_PER_STRUGGLE = 100 / v3.STRUGGLES_TO_ESCAPE * 1.25
	else
		leftArrowBg.Visible = true
		rightArrowBg.Visible = true
	end

	v4.Enabled = true
	setupInputHandlers()
	startTitlePulse() -- equivalent call inferred; original call site unknown
	startTimerLoop() -- equivalent call inferred; original call site unknown
	startGrabFailsafe(v7, v6) -- equivalent call inferred; original call site unknown
	escapeFrame.Position = UDim2.new(0.5, 0, -0.25, 0)
	TweenService:Create(escapeFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = tweenHelpers.getInitial(escapeFrame, "Position")
	}):Play()

	if data and data.shake then
		screenShake(data.shakeDuration or 0.3, data.shakeIntensity or 20)
	end

	if data and data.blur then
		screenBlur(data.blurDuration or 0.4, data.blurSize or 18)
	end
end

hideEscapeUI = function(p)
	count += 1
	local v7 = count
	flag2 = false
	stopTitlePulse() -- equivalent call inferred; original call site unknown
	stopTimerLoop() -- equivalent call inferred; original call site unknown

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connections = {}

	if not v4 then
		return
	end

	if p then
		fill.Size = UDim2.new(1, 0, 1, 0)
		local progressText = progressBar:FindFirstChild("ProgressText")

		if progressText then
			progressText.Text = "ESCAPED!"
		end

		TweenService:Create(vignette, TweenInfo.new(0.2), {
			ImageColor3 = Color3.fromRGB(100, 255, 100),
			ImageTransparency = 0
		}):Play()
		task.wait(0.3)

		if count ~= v7 then
			return
		end
	end

	TweenService:Create(escapeFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, -0.3, 0)
	}):Play()
	TweenService:Create(vignette, TweenInfo.new(0.3), {
		ImageTransparency = 1
	}):Play()
	task.wait(0.3)

	if count ~= v7 then
		return
	end

	v4.Enabled = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playEscapeEffects(data)
	if data.shake then
		screenShake(data.shakeDuration or 0.5, data.shakeIntensity or 15)
	end

	if data.blur then
		screenBlur(data.blurDuration or 0.3, data.blurSize or 24)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupEventHandler(p)
	if flag then
		return
	end

	flag = true
	p.OnClientEvent:Connect(function(p2, data)
		if p2 == "GrabStart" then
			showEscapeUI(data)

			if UserInputService.TouchEnabled and twistedSquirmGrab then
				twistedSquirmGrab:FireServer("SetMobile")
			end
		elseif p2 == "GrabProgress" then
			if data and data.percentage then
				v = data.percentage * 100
				updateProgressBar()
			end
		elseif p2 == "GrabEnd" then
			hideEscapeUI(data and data.escaped)
		elseif p2 == "EscapeEffect" then
			playEscapeEffects(data) -- equivalent call inferred; original call site unknown
		end
	end)
end

twistedSquirmGrab = events:FindFirstChild("TwistedSquirmGrab")

if twistedSquirmGrab then
	local v7 = twistedSquirmGrab

	if not flag then
		flag = true
		v7.OnClientEvent:Connect(function(p, data)
			if p == "GrabStart" then
				showEscapeUI(data)

				if UserInputService.TouchEnabled and twistedSquirmGrab then
					twistedSquirmGrab:FireServer("SetMobile")
				end
			elseif p == "GrabProgress" then
				if data and data.percentage then
					v = data.percentage * 100
					updateProgressBar()
				end
			elseif p == "GrabEnd" then
				hideEscapeUI(data and data.escaped)
			elseif p == "EscapeEffect" then
				playEscapeEffects(data) -- equivalent call inferred; original call site unknown
			end
		end)
	end
else
	task.spawn(function()
		twistedSquirmGrab = events:WaitForChild("TwistedSquirmGrab", 300)

		if twistedSquirmGrab then
			setupEventHandler(twistedSquirmGrab) -- equivalent call inferred; original call site unknown
		end
	end)
end