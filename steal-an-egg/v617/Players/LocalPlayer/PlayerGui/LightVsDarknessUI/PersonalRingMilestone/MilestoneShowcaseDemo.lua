local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
local progressBar = parent:WaitForChild("ProgressBar")
local progressBar2 = progressBar:WaitForChild("ProgressBar")
local ringScoreLabel = parent:WaitForChild("RingScoreHolder"):WaitForChild("RingScoreHolder"):WaitForChild("RingScoreLabel")
local color = Color3.fromRGB(85, 85, 85)
local color2 = Color3.fromRGB(71, 255, 0)
local uDim = UDim2.fromScale(1.03563285, 1.58552635)
local uDim2 = UDim2.fromScale(-0.470256448, 1.16447556)
local uDim3 = UDim2.fromScale(1.13319373, 1.7348907)
local uDim4 = UDim2.fromScale(-0.519036949, 1.16447568)
local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local v = {
	{
		name = "Milestone1",
		value = 50
	},
	{
		name = "Milestone2",
		value = 150
	},
	{
		name = "Milestone3",
		value = 300
	}
}
local value = v[#v].value
local v2 = {}
local count = 0
local v3 = true

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelTweens(p)
	for k, tween in pairs(p.tweens) do
		tween:Cancel()
		p.tweens[k] = nil
	end
end

local function play(p, p2, p3, p4, p5)
	local tween = p.tweens[p2]

	if tween then
		tween:Cancel()
	end

	local tween2 = TweenService:Create(p3, p4, p5)
	p.tweens[p2] = tween2
	tween2:Play()
	return tween2
end

local function build()
	for i, v4 in ipairs(v) do
		local child = progressBar:FindFirstChild(v4.name)

		if not child then
			continue
		end

		local claimButton = child:FindFirstChild("ClaimButton")
		local claimedOverlay = claimButton and claimButton:FindFirstChild("ClaimedOverlay")
		v2[i] = {
			value = v4.value,
			frame = child,
			baseSize = child.Size,
			button = claimButton,
			overlay = claimedOverlay,
			checkmark = claimedOverlay and claimedOverlay:FindFirstChild("CompletedCheckmark"),
			checkSize = claimedOverlay and claimedOverlay:FindFirstChild("CompletedCheckmark") and claimedOverlay.CompletedCheckmark.Size or nil,
			unlockedDecor = child:FindFirstChild("UnlockedDecor"),
			lockedDecor = child:FindFirstChild("NotUnlockedDecor"),
			tweens = {},
			state = nil,
			fillPoint = 0
		}
	end
end

local function measureFillPoints()
	local Y = progressBar.AbsolutePosition.Y
	local Y2 = progressBar.AbsoluteSize.Y

	if Y2 <= 0 then
		return false
	end

	for _, v4 in pairs(v2) do
		local frame = v4.frame
		v4.fillPoint = math.clamp((frame.AbsolutePosition.Y + frame.AbsoluteSize.Y * 0.5 - Y) / Y2, 0, 1)
	end

	return true
end

local function fillScaleFor(p)
	local value2 = 0
	local fillPoint = 0

	for _, v4 in ipairs(v2) do
		if p <= v4.value then
			local v5 = v4.value - value2
			local v6 = v5 > 0 and (p - value2) / v5 or 1
			return fillPoint + (v4.fillPoint - fillPoint) * v6
		else
			value2 = v4.value
			fillPoint = v4.fillPoint
		end
	end

	return fillPoint
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setDecor(p, visible)
	if p.unlockedDecor then
		p.unlockedDecor.Visible = visible
	end

	if p.lockedDecor then
		p.lockedDecor.Visible = not visible
	end
end

local function punch(data)
	local baseSize = data.baseSize
	data.frame.Size = UDim2.new(baseSize.X.Scale, baseSize.X.Offset + 12, baseSize.Y.Scale, baseSize.Y.Offset + 8)
	local frame = data.frame
	local punch2 = data.tweens.punch

	if punch2 then
		punch2:Cancel()
	end

	local tween = TweenService:Create(frame, tweenInfo2, {
		Size = baseSize
	})
	data.tweens.punch = tween
	tween:Play()
end

local function setState(state, state2, p)
	if state.state == state2 then
		return
	end

	state.state = state2
	cancelTweens(state) -- equivalent call inferred; original call site unknown
	local visible = state2 ~= "Locked"
	local button = state.button
	local overlay = state.overlay
	local checkmark = state.checkmark
	setDecor(state, visible) -- equivalent call inferred; original call site unknown
	state.frame.Size = state.baseSize

	if p then
		local frame = state.frame
		local bg = state.tweens.bg

		if bg then
			bg:Cancel()
		end

		local tween = TweenService:Create(frame, tweenInfo, {
			BackgroundColor3 = visible and color2 or color
		})
		state.tweens.bg = tween
		tween:Play()
	else
		state.frame.BackgroundColor3 = visible and color2 or color
	end

	if button then
		button.Image = visible and "rbxassetid://73951419137281" or "rbxassetid://111037630886814"
		button.Position = visible and uDim2 or uDim4
		button.Size = visible and uDim or uDim3
	end

	if overlay then
		overlay.Visible = state2 == "Claimed"
	end

	if state2 == "Locked" then
		if p then
			punch(state)
		end
	elseif state2 == "Ready" then
		if p then
			punch(state)
		end

		if button then
			button.Size = uDim
			local v6 = {
				Size = UDim2.fromScale(uDim.X.Scale * 1.07, uDim.Y.Scale * 1.07)
			}
			local pulse = state.tweens.pulse

			if pulse then
				pulse:Cancel()
			end

			local tween = TweenService:Create(button, tweenInfo4, v6)
			state.tweens.pulse = tween
			tween:Play()
		end
	else
		if not overlay then
			return
		end

		if p then
			overlay.ImageTransparency = 1
			local overlay2 = state.tweens.overlay

			if overlay2 then
				overlay2:Cancel()
			end

			local tween = TweenService:Create(overlay, tweenInfo, {
				ImageTransparency = 0.64
			})
			state.tweens.overlay = tween
			tween:Play()

			if checkmark then
				checkmark.ImageTransparency = 1
				checkmark.Size = UDim2.fromScale(state.checkSize.X.Scale * 0.2, state.checkSize.Y.Scale * 0.2)
				local v8 = {
					Size = state.checkSize,
					ImageTransparency = 0
				}
				local check = state.tweens.check

				if check then
					check:Cancel()
				end

				local tween2 = TweenService:Create(checkmark, tweenInfo3, v8)
				state.tweens.check = tween2
				tween2:Play()
			end

			punch(state)
		else
			overlay.ImageTransparency = 0.64

			if checkmark then
				checkmark.ImageTransparency = 0
				checkmark.Size = state.checkSize
			end
		end
	end
end

local v4 = 0

local function applyValue(p)
	v4 = p
	progressBar2.Size = UDim2.new(1, 0, fillScaleFor(p), 0)
	ringScoreLabel.Text = string.format("%d", p // 1)

	for _, v5 in ipairs(v2) do
		if v5.state == "Locked" and v5.value <= p then
			setState(v5, "Ready", true)
		end
	end
end

local function rampTo(p, p2, p3)
	local v5 = v4
	local v6 = p2 - v5

	if v6 == 0 or p3 <= 0 then
		applyValue(p2)
		return
	end

	local total = 0
	local thread = coroutine.running()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if p == count then
			total += dt
			local v7 = math.min(total / p3, 1)
			applyValue(v5 + v6 * TweenService:GetValue(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

			if v7 >= 1 then
				heartbeatConnection:Disconnect()
				task.spawn(thread)
			end
		else
			heartbeatConnection:Disconnect()
			task.spawn(thread)
		end
	end)
	coroutine.yield()
end

local function resetAll()
	for _, v5 in ipairs(v2) do
		v5.state = nil

		if v5.state == "Locked" then
			continue
		end

		v5.state = "Locked"
		cancelTweens(v5) -- equivalent call inferred; original call site unknown
		local button = v5.button
		local overlay = v5.overlay
		local _ = v5.checkmark
		setDecor(v5, false) -- equivalent call inferred; original call site unknown
		v5.frame.Size = v5.baseSize
		v5.frame.BackgroundColor3 = color

		if button then
			button.Image = "rbxassetid://111037630886814"
			button.Position = uDim4
			button.Size = uDim3
		end

		if overlay then
			overlay.Visible = false
		end
	end

	applyValue(0)
end

local function stale(p)
	return not v3 or p ~= count
end

local function pause(p, duration)
	task.wait(duration)
	return v3 and p == count and true or false
end

local function runShowcase()
	count += 1
	local v5 = count

	while v3 and v5 == count do
		resetAll()
		task.wait(0.6)

		if not v3 or v5 ~= count then
			break
		end

		rampTo(v5, v[1].value, 1.1)

		if not v3 or v5 ~= count then
			break
		end

		task.wait(0.9)

		if not v3 or v5 ~= count then
			break
		end

		setState(v2[1], "Claimed", true)
		task.wait(0.7)

		if not v3 or v5 ~= count then
			break
		end

		rampTo(v5, v[2].value, 1.5)

		if not v3 or v5 ~= count then
			break
		end

		task.wait(2.4)

		if not v3 or v5 ~= count then
			break
		end

		rampTo(v5, value * 0.78, 1.2)

		if not v3 or v5 ~= count then
			break
		end

		task.wait(1.8)

		if not v3 or v5 ~= count then
			break
		end
	end
end

local function cleanup()
	v3 = false
	count += 1

	for _, v5 in ipairs(v2) do
		cancelTweens(v5) -- equivalent call inferred; original call site unknown
	end
end

script.Destroying:Once(cleanup)
build()
task.spawn(function()
	for _ = 1, 120 do
		if not v3 then
			return
		end

		if measureFillPoints() then
			runShowcase()
			return
		else
			RunService.Heartbeat:Wait()
		end
	end

	warn("[MilestoneShowcase] ProgressBar never resolved a non-zero height.")
end)