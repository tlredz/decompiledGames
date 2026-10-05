local TweenModule = {}
local EasingEquations = require(script.EasingEquations)
local RunService = game:GetService("RunService")
game:GetService("HttpService")
local isServer = RunService:IsServer()

function TweenModule.new(tweenFunction, value, value2, value3, easingProperties)
	local v = {
		TweenFunction = tweenFunction,
		Elapsed = 0,
		Duration = value or 1,
		EasingStyle = value2 or "Linear",
		EasingDirection = value3 or "Out",
		EasingProperties = easingProperties
	}
	setmetatable(v, {
		__index = TweenModule
	})
	v.ID = math.random(99999999)
	return v
end

function TweenModule.Easing(p, p2, value, p3)
	return EasingEquations[p2](p, value or "Out", p3)
end

function TweenModule:Destroy()
	self.Destroyed = true
	self:Stop()
end

function TweenModule:LinkToInstance(instance2)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance2.AncestryChanged:Connect(function()
		ancestryChangedConnection:Disconnect()
		self:Destroy()
	end)
end

function TweenModule:BindToComplete(completeFunction)
	self.CompleteFunction = completeFunction
end

function TweenModule:Play()
	self:Start()
end

function TweenModule:Start()
	self.Elapsed = 0
	self:Resume()
end

function TweenModule:Stop()
	self.Active = false

	if isServer then
		if self.HeartbeatEvent then
			self.HeartbeatEvent:Disconnect()
			self.HeartbeatEvent = nil
		end
	else
		RunService:UnbindFromRenderStep("Tween" .. self.ID)
	end

	if self.CompleteFunction then
		self.CompleteFunction(self.Elapsed >= self.Duration)
	end
end

function TweenModule:Resume()
	if self.Destroyed then
		warn("This tween can not be resumed because it has been destroyed")
	end

	if self.Elapsed >= self.Duration or self.Active then
		return
	end

	self.Active = true

	local function UpdateFunction(p)
		self.Elapsed += p

		if not self.Active then
			return
		end

		local v = math.clamp(self.Elapsed / self.Duration, 0, 1)
		local v2 = self.EasingStyle == "Linear" and v or EasingEquations[self.EasingStyle](
			v,
			self.EasingDirection,
			self.EasingProperties
		)

		if self.TweenFunction(v2, p) then
			self:Stop()
		end

		if v >= 1 then
			if self.Repeats then
				self.Elapsed = 0
			else
				self:Stop()
			end
		end
	end

	if isServer then
		self.HeartbeatEvent = RunService.Heartbeat:Connect(UpdateFunction)
	else
		RunService:BindToRenderStep(
			"Tween" .. self.ID,
			self.RenderPriority or Enum.RenderPriority.Last.Value,
			UpdateFunction
		)
	end
end

return TweenModule