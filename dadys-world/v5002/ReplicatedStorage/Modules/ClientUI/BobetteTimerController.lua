local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LuvColor3Utils = require(ReplicatedStorage.Modules.Utils.LuvColor3Utils)
local BobetteTimerController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function playTween(uIGradient, tweenInfo, p)
	local tween = TweenService:Create(uIGradient, tweenInfo, p)
	tween:Play()
	return tween
end

function BobetteTimerController.create(parent)
	local parts = ReplicatedStorage:FindFirstChild("Parts")
	local renderParts = parts and parts:FindFirstChild("RenderParts")
	local bobette = renderParts and renderParts:FindFirstChild("Bobette")
	local timerDisplay = bobette and bobette:FindFirstChild("TimerDisplay")

	if not timerDisplay then
		warn("BobetteTimerController: TimerDisplay template not found")
		return nil
	end

	if not parent then
		warn("BobetteTimerController: No parent model provided")
		return nil
	end

	local clone = timerDisplay:Clone()
	clone.StudsOffset = createVector(0, 6, 0)
	clone.Parent = parent
	local timer = clone:FindFirstChild("Timer")
	return {
		billboard = clone,
		timer = timer,
		timeLeft = timer and timer:FindFirstChild("TimeLeft"),
		smoothTimeLeft = timer and timer:FindFirstChild("SmoothTimeLeft"),
		textLabel = clone:FindFirstChild("TextLabel"),
		running = false,
		threads = {},
		tweens = {}
	}
end

function BobetteTimerController:cancel()
	if not self then
		return
	end

	self.running = false

	for _, thread in ipairs(self.threads) do
		if typeof(thread) == "RBXScriptConnection" then
			local connection = thread
			pcall(function()
				connection:Disconnect()
			end)
		else
			pcall(task.cancel, thread)
		end
	end

	self.threads = {}

	for _, tween in ipairs(self.tweens) do
		local v = tween
		pcall(function()
			v:Cancel()
		end)
	end

	self.tweens = {}

	if self.billboard then
		self.billboard.Enabled = false
		self.billboard:Destroy()
		self.billboard = nil
	end
end

function BobetteTimerController:start(duration)
	if not (self and self.billboard) then
		warn("BobetteTimerController: Invalid timer")
		return
	end

	if self.running then
		BobetteTimerController.cancel(self)
		return
	end

	self.running = true
	self.threads = {}
	self.tweens = {}
	local billboard = self.billboard
	local timeLeft = self.timeLeft
	local smoothTimeLeft = self.smoothTimeLeft
	local textLabel = self.textLabel

	if timeLeft and timeLeft:FindFirstChild("UIGradient") then
		local offsetEnd = timeLeft.UIGradient:GetAttribute("OffsetEnd") or 1
		timeLeft.UIGradient.Offset = Vector2.new(offsetEnd, 0)
		timeLeft.ImageColor3 = Color3.fromRGB(68, 170, 109)
	end

	if smoothTimeLeft and smoothTimeLeft:FindFirstChild("UIGradient") then
		local offsetEnd = smoothTimeLeft.UIGradient:GetAttribute("OffsetEnd") or 1
		smoothTimeLeft.UIGradient.Offset = Vector2.new(offsetEnd, 0)
	end

	billboard.Enabled = true
	local thread = task.spawn(function()
		if not self.running then
			return
		end

		task.delay(2.5, function()
			if self.running and billboard then
				TweenService:Create(billboard, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					StudsOffset = createVector(0, 4, 0)
				}):Play()
			end
		end)
		local v = not (timeLeft and timeLeft:FindFirstChild("UIGradient")) and 0 or timeLeft.UIGradient:GetAttribute("OffsetStart") or 0

		if timeLeft and timeLeft:FindFirstChild("UIGradient") then
			local tweens = self.tweens
			local uIGradient = timeLeft.UIGradient
			local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
			local v2 = {
				Offset = Vector2.new(v, 0)
			}
			table.insert(tweens, playTween(uIGradient, tweenInfo, v2))
		end

		if smoothTimeLeft and smoothTimeLeft:FindFirstChild("UIGradient") then
			local tweens = self.tweens
			local uIGradient = smoothTimeLeft.UIGradient
			local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
			local v2 = {
				Offset = Vector2.new(v, 0)
			}
			table.insert(tweens, playTween(uIGradient, tweenInfo, v2))
		end

		local color = Color3.fromRGB(68, 170, 109)
		local color2 = Color3.fromRGB(220, 60, 60)
		local lastTime = tick()

		if timeLeft then
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if self.running then
					local v2 = math.clamp((tick() - lastTime) / duration, 0, 1) ^ 5
					timeLeft.ImageColor3 = LuvColor3Utils.lerp(color, color2, v2)
				elseif heartbeatConnection then
					heartbeatConnection:Disconnect()
				end
			end)
			table.insert(self.threads, heartbeatConnection)
		end

		if textLabel then
			local thread2 = task.spawn(function()
				local v2 = tick() + duration

				while tick() < v2 and self.running do
					local v3 = math.max(0, v2 - tick())
					textLabel.Text = string.format("%.1fs", v3)
					task.wait(0.1)
				end

				if self.running and textLabel then
					textLabel.Text = "0.0s"
				end
			end)
			table.insert(self.threads, thread2)
		end

		local total = 0

		while total < duration and self.running do
			task.wait(0.1)
			total += 0.1
		end

		if not self.running then
			return
		end

		task.wait(0.5)
		BobetteTimerController.cancel(self)
	end)
	table.insert(self.threads, thread)
end

function BobetteTimerController.new(p)
	return BobetteTimerController.create(p)
end

return BobetteTimerController