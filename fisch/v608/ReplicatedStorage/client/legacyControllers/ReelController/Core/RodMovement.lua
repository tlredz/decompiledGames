local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.packages.Trove)
require("../Types")
local RodMovement = {}
RodMovement.__index = RodMovement

function RodMovement.new(current)
	local object = setmetatable({}, RodMovement)
	object.current = current
	object.trove = current.trove:Extend()
	object.InputLockedUntil = 0
	object.CurrentInputDirection = -1
	object.CurrentVelocity = 0
	object.CurrentAcceleration = 0
	object.MaxAcceleration = 1e999
	object.BarElasticity = 0.5
	object.SimulateLegacyPhysics = true
	object.BounceDebounce = false
	object.AllowedInputs = {
		MouseButton1 = true,
		Space = true,
		Touch = true,
		ButtonA = true
	}
	object.Paused = false
	return object
end

function RodMovement:Start()
	self.trove:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if self.Disabled then
			return
		end

		if self.AllowedInputs[input.KeyCode.Name] or self.AllowedInputs[input.UserInputType.Name] then
			self:InputBegan(input)
		elseif input.KeyCode == Enum.KeyCode.P and not gameProcessed and (RunService:IsStudio() or game.GameId == 6756890519) then
			self.current.isPaused = not self.current.isPaused
		end
	end))
	self.trove:Add(UserInputService.InputEnded:Connect(function(input)
		if self.Disabled then
			return
		end

		if self.AllowedInputs[input.KeyCode.Name] or self.AllowedInputs[input.UserInputType.Name] then
			self:InputEnded(input)
		end
	end))
end

function RodMovement:Disable()
	self.Disabled = true
end

function RodMovement.Stop(p)
	p.trove:Clean()
end

function RodMovement:Tick(p: number)
	if self.Disabled or self.Paused or not self.current.active then
		return
	end

	local v = self.current.maxBarPosition - self.current.minBarPosition

	if v <= self.current.barSize then
		self.current.barPosition = self.current.minBarPosition + v / 2
		return
	end

	local barPosition = self.current.minBarPosition + self.current.barSize / 2
	local barPosition2 = self.current.maxBarPosition - self.current.barSize / 2
	local v4 = self.CurrentInputDirection * self.current.barMoveSpeed * math.clamp(self.current.accel, -1, 1) * 1.5
	local v5 = self.current.barPosition <= barPosition and v4 < 0 and 0 or barPosition2 <= self.current.barPosition and v4 > 0 and 0 or v4
	local v6 = math.clamp(0.85 / math.sqrt((math.abs(self.current.accel))), -1000000, 1000000)
	local smoothDamp, currentAcceleration = TweenService:SmoothDamp(
		self.CurrentVelocity,
		v5,
		self.CurrentAcceleration,
		v6,
		self.MaxAcceleration,
		p
	)
	self.CurrentVelocity = smoothDamp
	self.CurrentAcceleration = currentAcceleration
	self.current.barPosition += self.CurrentVelocity * p

	if self.current.barPosition <= barPosition then
		self.current.barPosition = barPosition

		if not (self.CurrentVelocity < 0) then
			self.BounceDebounce = false
			return
		end

		if not self.BounceDebounce then
			self.current.OnBarBounce:Fire(false, self.CurrentVelocity)
		end

		self.CurrentVelocity *= -self.BarElasticity
		self.BounceDebounce = true
		task.delay(0.1, function()
			self.BounceDebounce = false
		end)
	elseif barPosition2 <= self.current.barPosition then
		self.current.barPosition = barPosition2

		if self.CurrentVelocity > 0 then
			if not self.BounceDebounce then
				self.current.OnBarBounce:Fire(true, self.CurrentVelocity)
			end

			self.CurrentVelocity *= -self.BarElasticity
			self.BounceDebounce = true
			task.delay(0.1, function()
				self.BounceDebounce = false
			end)
		else
			self.BounceDebounce = false
		end
	end
end

function RodMovement:InputBegan(_)
	if self.InputLockedUntil > workspace:GetServerTimeNow() then
		return
	end

	if self.CurrentInputDirection ~= 1 then
		self.current.OnBarDirectionChange:Fire(1)
	end

	self.CurrentInputDirection = 1

	if self.SimulateLegacyPhysics then
		self.CurrentAcceleration = 0
	end
end

function RodMovement:InputEnded(_)
	if self.InputLockedUntil > workspace:GetServerTimeNow() then
		return
	end

	if self.CurrentInputDirection ~= -1 then
		self.current.OnBarDirectionChange:Fire(-1)
	end

	self.CurrentInputDirection = -1

	if self.SimulateLegacyPhysics then
		self.CurrentAcceleration = 0
	end
end

function RodMovement:ApplyImpulse(p2: number)
	self.CurrentVelocity += p2
	self.CurrentAcceleration = 0
end

function RodMovement:LockInput(p2: number, currentInputDirection: number?)
	self.InputLockedUntil = math.max(self.InputLockedUntil + p2, workspace:GetServerTimeNow() + p2)

	if currentInputDirection then
		self.CurrentInputDirection = currentInputDirection
	end
end

return RodMovement