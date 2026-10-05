local createVector = vector.create
local Component = require(game.ReplicatedStorage.Modules.Component)
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local v = Component.new({
	Tag = "Submerged" .. script.Name
})
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, true)

function v.Construct(_) end

function v:Bubble()
	local bubbles = self.Bubbles

	if not bubbles or self.Bubbling then
		return
	end

	self.Bubbling = true

	for _, emitter in bubbles:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.delay(1.5, function()
		for _, emitter in bubbles:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local tween = TweenService:Create(self.Instance, tweenInfo, {
		Size = self.Instance.Size - createVector(0, 1, 0),
		CFrame = self.Instance.CFrame - createVector(0, 0.5, 0)
	})
	self.BubbleTween = tween
	tween.Completed:Once(function()
		self.BubbleTween = nil
		self.Bubbling = false
	end)
	tween:Play()
end

function v:HasToucher()
	local v2 = false

	for k in self.Touchers do
		if k.Parent and Players:GetPlayerFromCharacter(k.Parent) then
			v2 = true
		else
			self.Touchers[k] = nil
		end
	end

	return v2
end

function v:StartTouchLoop()
	if self.TouchLoop then
		return
	end

	self.TouchLoop = task.spawn(function()
		while self:HasToucher() do
			self:Bubble()
			task.wait(4)
		end

		self.TouchLoop = nil
	end)
end

function v:Start()
	self.StartupTask = task.delay(1, function()
		local bubbles = self.Instance:WaitForChild("Bubbles", 5)

		if not bubbles then
			bubbles = script.Bubbles:Clone()
			bubbles.Parent = self.Instance
			bubbles.CFrame = self.Instance:GetPivot() + self.Instance.Size * createVector(0, 1, 0) * 0.5
			bubbles.Size = self.Instance.Size
		end

		self.Bubbles = bubbles
		self.Touchers = {}
		self.TouchConn = self.Instance.Touched:Connect(function(otherPart)
			local parent = otherPart and otherPart.Parent

			if parent and Players:GetPlayerFromCharacter(parent) then
				self.Touchers[otherPart] = true
				self:StartTouchLoop()
			end
		end)
		self.TouchEndedConn = self.Instance.TouchEnded:Connect(function(otherPart)
			self.Touchers[otherPart] = nil
		end)
		self.LoopTask = task.spawn(function()
			while task.wait(math.random(5, 25)) do
				self:Bubble()
			end
		end)
	end)
end

function v:Stop()
	if self.StartupTask then
		task.cancel(self.StartupTask)
		self.StartupTask = nil
	end

	if self.LoopTask then
		task.cancel(self.LoopTask)
		self.LoopTask = nil
	end

	if self.TouchLoop then
		task.cancel(self.TouchLoop)
		self.TouchLoop = nil
	end

	if self.BubbleTween then
		self.BubbleTween:Cancel()
		self.BubbleTween = nil
	end

	if self.TouchConn then
		self.TouchConn:Disconnect()
		self.TouchConn = nil
	end

	if self.TouchEndedConn then
		self.TouchEndedConn:Disconnect()
		self.TouchEndedConn = nil
	end
end

return v