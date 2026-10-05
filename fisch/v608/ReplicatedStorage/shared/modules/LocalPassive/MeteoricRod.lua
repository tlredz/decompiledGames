local MeteoricRod = {}
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local module = require("./PassiveHandler")
local color = Color3.fromRGB(255, 140, 50)
local color2 = Color3.fromRGB(255, 90, 40)
local color3 = Color3.fromRGB(255, 190, 70)
local color4 = Color3.fromRGB(255, 214, 140)
local color5 = Color3.fromRGB(70, 30, 10)
local gothamBold = Enum.Font.GothamBold
local uDim = UDim2.fromScale(0.1, 0.03)

local function findUiSound(childName: string?)
	if not childName then
		return nil
	end

	local resources = ReplicatedStorage:FindFirstChild("resources")
	local sounds = resources and resources:FindFirstChild("sounds")
	local sfx = sounds and sounds:FindFirstChild("sfx")
	local sfxUi = sfx and sfx:FindFirstChild("ui")
	local sound = sfxUi and sfxUi:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		return sound
	end

	return nil
end

local function playSound(p: string?, reel)
	local uiSound = findUiSound(p)

	if uiSound then
		local clone = uiSound:Clone()
		clone.Name = uiSound.Name .. "Clone"
		clone.PlaybackSpeed = math.random(90, 110) / 100
		clone.Parent = reel
		clone:Play()
		task.delay(math.max(clone.TimeLength * 2, 2), function()
			clone:Destroy()
		end)
	end
end

local function buildMeteorPlaceholder()
	local frame = Instance.new("Frame")
	frame.Name = "meteorPlaceholder"
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.BackgroundColor3 = color
	frame.BorderSizePixel = 0
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = frame
	return frame
end

function MeteoricRod.Morph(p, _, object)
	local config = p.config
	local v = { object.reel }
	local meteor = script:FindFirstChild("meteor")

	if meteor then
		table.insert(v, meteor)
	end

	for _, v2 in {
		config.FallSoundName or "meteor",
		config.HitSoundName or "meteorImpact",
		config.DodgeSoundName or "meteorDodge"
	} do
		local uiSound = findUiSound(v2)

		if uiSound then
			table.insert(v, uiSound)
		end
	end

	object:Preload(v)

	local function fadeOutMeteor(image)
		local v2 = {
			Size = UDim2.fromOffset(image.Size.X.Offset * 1.6, image.Size.Y.Offset * 1.6)
		}

		if image:IsA("ImageLabel") then
			v2.ImageTransparency = 1
		else
			v2.BackgroundTransparency = 1
		end

		local v3 = object.logicTweens:Create(image, TweenInfo.new(0.2, Enum.EasingStyle.Quart), v2)
		v3.Completed:Once(function()
			image:Destroy()
		end)
		v3:Play()
	end

	local function exitMeteor(gui, startX: number, startY: number, endX: number, endY: number, flightTime: number, spinSpeed: number)
		local v2 = endY - startY

		if v2 <= 0 then
			gui:Destroy()
			return
		end

		local v3 = (1.2 - endY) / v2
		local v4 = endX + (endX - startX) * v3
		local v5 = v3 * flightTime / 2.2
		local v6 = object.logicTweens:Create(gui, TweenInfo.new(v5, Enum.EasingStyle.Linear), {
			Position = UDim2.fromScale(v4, 1.2),
			Rotation = gui.Rotation + spinSpeed * v5
		})
		v6.Completed:Once(function()
			gui:Destroy()
		end)
		v6:Play()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function barToScreenX(number: number)
		local reel_bar = object.reel_bar
		local absoluteSize = object.reel.AbsoluteSize

		if absoluteSize.X <= 0 then
			return number
		end

		return (reel_bar.AbsolutePosition.X - object.reel.AbsolutePosition.X + number * reel_bar.AbsoluteSize.X) / absoluteSize.X
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getBarScreenY()
		local reel_bar = object.reel_bar
		local absoluteSize = object.reel.AbsoluteSize

		if absoluteSize.Y <= 0 then
			return reel_bar.Position.Y.Scale
		end

		return (reel_bar.AbsolutePosition.Y - object.reel.AbsolutePosition.Y + reel_bar.AbsoluteSize.Y / 2) / absoluteSize.Y
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function guiWidthInBarSpace(gui)
		local X = object.reel_bar.AbsoluteSize.X

		if X <= 0 then
			return 0
		end

		return gui.AbsoluteSize.X / X
	end

	local count = 0
	local count2 = 0
	object.BuildEndingData:Bind(function(p2)
		p2.MeteoricRod_DodgeCount = count
		p2.MeteoricRod_HitCount = count2
		return p2
	end)
	local v2 = {}
	local v3 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearAllMeteors()
		for _, v4 in v2 do
			v4.resolved = true
			v4.gui:Destroy()
		end

		table.clear(v2)
	end

	p.reelTrove:Add(clearAllMeteors)

	local function spawnDodgeText()
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "MeteorDodgeText"
		textLabel.Size = uDim
		textLabel.AnchorPoint = Vector2.new(0.5, 1)
		local barPosition = object.barPosition
		local reel_bar = object.reel_bar
		local absoluteSize = object.reel.AbsoluteSize

		if not (absoluteSize.X <= 0) then
			barPosition = (reel_bar.AbsolutePosition.X - object.reel.AbsolutePosition.X + barPosition * reel_bar.AbsoluteSize.X) / absoluteSize.X
		end

		local barScreenY = getBarScreenY() -- equivalent call inferred; original call site unknown
		textLabel.Position = UDim2.fromScale(barPosition, barScreenY - 0.04)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = color4
		textLabel.TextStrokeColor3 = color5
		textLabel.TextStrokeTransparency = 0.3
		textLabel.Font = gothamBold
		textLabel.TextScaled = true
		textLabel.Text = "DODGE!"
		textLabel.ZIndex = 27
		textLabel.Parent = object.reel
		TweenService:Create(textLabel, TweenInfo.new(1.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = textLabel.Position - UDim2.fromScale(0, 0.04)
		}):Play()
		task.delay(0.55, function()
			if not textLabel.Parent then
				return
			end

			TweenService:Create(textLabel, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		end)
		task.delay(1.2, function()
			textLabel:Destroy()
		end)
	end

	local function pulseOverlay(bar, backgroundColor: Color3)
		local frame = Instance.new("Frame")
		frame.Name = "MeteorPulse"
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = backgroundColor
		frame.BackgroundTransparency = 0.35
		frame.BorderSizePixel = 0
		frame.ZIndex = bar.ZIndex + 1
		frame.Parent = bar
		local tween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		})
		tween.Completed:Once(function()
			frame:Destroy()
		end)
		tween:Play()
	end

	local flag = false
	local v4 = nil
	local v5 = nil
	local v6 = nil

	local function resolvePlayerbarTint()
		if flag then
			return
		end

		flag = true
		local reel_playerbar = object.reel_playerbar

		if reel_playerbar:IsA("ImageLabel") or reel_playerbar:IsA("ImageButton") then
			v4 = "ImageColor3"
		elseif reel_playerbar.BackgroundTransparency < 1 then
			v4 = "BackgroundColor3"
		else
			return
		end

		v5 = reel_playerbar[v4]
	end

	local function flashPlayerbar(color6: Color3)
		if not flag then
			flag = true
			local reel_playerbar = object.reel_playerbar

			if reel_playerbar:IsA("ImageLabel") or reel_playerbar:IsA("ImageButton") then
				v4 = "ImageColor3"
				v5 = reel_playerbar[v4]
			elseif reel_playerbar.BackgroundTransparency < 1 then
				v4 = "BackgroundColor3"
				v5 = reel_playerbar[v4]
			end
		end

		local v7 = v4
		local v8 = v5

		if v7 == nil or v8 == nil then
			return
		end

		local reel_playerbar = object.reel_playerbar

		if v6 then
			v6:Cancel()
			reel_playerbar[v7] = v8
		end

		local tween = TweenService:Create(
			reel_playerbar,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{
				[v7] = color6
			}
		)
		tween.Completed:Once(function()
			if v6 == tween then
				v6 = nil
			end
		end)
		v6 = tween
		tween:Play()
	end

	local function flashBar(color6: Color3, flag2: boolean)
		pulseOverlay(object.reel_progress.bar, color6)
		flashPlayerbar(color6)

		if flag2 and object.fx then
			object.fx:SpawnShake(object.reel_bar, 1.4, 0.5, 0.02, true)
		end

		if v3 then
			v3:Cancel()
		end

		local v7 = object.logicTweens:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
			{
				BackgroundColor3 = color6
			}
		)
		v3 = v7
		v7:Play()
	end

	local function resolveMeteor(state)
		if state.resolved then
			return
		end

		state.resolved = true
		local index = table.find(v2, state)

		if index then
			table.remove(v2, index)
		end

		local v7 = guiWidthInBarSpace(state.gui) -- equivalent call inferred; original call site unknown

		if math.abs(state.targetBarX - object.barPosition) - object.barSize / 2 - v7 / 2 <= 0 then
			count2 += 1
			fadeOutMeteor(state.gui)
			playSound(config.HitSoundName or "meteorImpact", object.reel)
			flashBar(color2, true)
			object:AddProgress(config.HIT_PROGRESS_LOSS)
		else
			count += 1
			exitMeteor(state.gui, state.startX, state.startY, state.endX, state.endY, state.flightTime, state.spinSpeed)
			playSound(config.DodgeSoundName or "meteorDodge", object.reel)
			flashBar(color3, false)
			spawnDodgeText()
			object:AddProgress(config.DODGE_PROGRESS_GAIN)
		end
	end

	p.reelTrove:Add((object.OnLogicStep:Connect(function()
		if object.active then
			local now = tick()

			for i = #v2, 1, -1 do
				local v7 = v2[i]
				local v8 = math.clamp((now - v7.startTime) / v7.flightTime, 0, 1)
				local v9 = v8 ^ 2.2
				local v10 = v7.startX + (v7.endX - v7.startX) * v9
				local v11 = v7.startY + (v7.endY - v7.startY) * v9
				local v12 = v9 * 0.44999999999999996 + 0.55
				v7.gui.Position = UDim2.fromScale(v10, v11)
				v7.gui.Size = UDim2.fromOffset(v7.widthPixels * v12, v7.heightPixels * v12)
				v7.gui.Rotation = v7.baseRotation + (now - v7.startTime) * v7.spinSpeed

				if v8 >= 1 then
					resolveMeteor(v7)
				end
			end
		else
			clearAllMeteors() -- equivalent call inferred; original call site unknown
		end
	end)))
	p.reelTrove:Add((task.spawn(function()
		object:WaitUntilReady()
		local random = object:GetRandom(7)
		object:WaitLogic(2)

		for _ = 1, config.METEOR_COUNT do
			if not object.active then
				break
			end

			local number = random:NextNumber(0.05, 0.95)
			local endX = barToScreenX(number) -- equivalent call inferred; original call site unknown
			local barScreenY = getBarScreenY() -- equivalent call inferred; original call site unknown
			local startX, startY

			if random:NextNumber(0, 100) <= 35 then
				startX = random:NextNumber() < 0.5 and -0.2 or 1.2
				startY = math.min(barScreenY - random:NextNumber(0.55, 0.85), -0.2)
			else
				startX = endX - random:NextNumber(-0.12, 0.12)
				startY = math.min(barScreenY - 0.55, -0.2)
			end

			local meteor2 = script:FindFirstChild("meteor")
			local clone

			if meteor2 and meteor2:IsA("GuiObject") then
				clone = meteor2:Clone()
			else
				clone = buildMeteorPlaceholder()
			end

			local widthPixels = config.METEOR_WIDTH * object.reel_bar.AbsoluteSize.X
			local heightPixels = widthPixels * (not (clone.Size.X.Offset > 0 and clone.Size.Y.Offset > 0) and 1 or clone.Size.Y.Offset / clone.Size.X.Offset)
			local absoluteSize = object.reel.AbsoluteSize
			local magnitude = Vector2.new((endX - startX) * absoluteSize.X, (barScreenY - startY) * absoluteSize.Y).Magnitude
			local v12 = math.max(0.55, barScreenY + 0.2) * absoluteSize.Y
			local flightTime = config.FLIGHT_TIME * math.clamp(not (v12 > 0) and 1 or magnitude / v12, 1, 1.6)
			local v14 = -math.deg((math.atan2((endX - startX) * absoluteSize.X, (barScreenY - startY) * absoluteSize.Y)))
			local number2 = random:NextNumber(90, 260)

			if random:NextNumber() < 0.5 then
				number2 = -number2
			end

			clone.Rotation = v14
			clone.Size = UDim2.fromOffset(widthPixels * 0.55, heightPixels * 0.55)
			clone.Position = UDim2.fromScale(startX, startY)
			clone.ZIndex = 26
			clone.Parent = object.reel
			p.reelTrove:Add(clone)
			playSound(config.FallSoundName or "meteor", object.reel)
			table.insert(v2, {
				gui = clone,
				startTime = tick(),
				startX = startX,
				endX = endX,
				startY = startY,
				endY = barScreenY,
				targetBarX = number,
				flightTime = flightTime,
				baseRotation = v14,
				spinSpeed = number2,
				widthPixels = widthPixels,
				heightPixels = heightPixels,
				resolved = false
			})
			object:WaitLogic(random:NextNumber(config.SPAWN_INTERVAL_MIN, config.SPAWN_INTERVAL_MAX))
		end
	end)))
end

setmetatable(MeteoricRod, module)
return MeteoricRod