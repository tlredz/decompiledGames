local RunService = game:GetService("RunService")
local v = {}
local PeodizService = {}
PeodizService.__index = PeodizService
local Functions = require(script.Functions)

function PeodizService.new(p, p2)
	local object = setmetatable({}, PeodizService)
	object.Type = "Heartbeat"
	object.LifeTime = p.Time or 1
	object.Tween = p.Tween or nil

	if p2 then
		object.Function = p2
		object.YieldEvent = Instance.new("BindableEvent")
	end

	if Functions[object.Type] then
		object.UpdateFunction = Functions[object.Type]
	end

	table.insert(v, object)
	local yieldEvent = object.YieldEvent

	if p2 and yieldEvent then
		yieldEvent.Event:Wait()
		yieldEvent:Destroy()
	else
		return object
	end
end

function PeodizService.Heartbeat(p, p2)
	local object = setmetatable({}, PeodizService)
	object.Type = "Heartbeat"
	object.LifeTime = p.Time or 1
	object.NoYield = true
	object.Tween = p.Tween or nil

	if p2 then
		object.Function = p2
	end

	if Functions[object.Type] then
		object.UpdateFunction = Functions[object.Type]
	end

	table.insert(v, object)
	return object
end

function PeodizService:HeartbeatWait(p)
	local object = setmetatable({}, PeodizService)
	object.Type = "HeartbeatWait"
	object.LifeTime = self.Time or 1

	if self.WaitTime and self.WaitTime <= 0 then
		self.WaitTime = 0.016666666666666666
	end

	self.WaitTime = self.WaitTime or 0.016666666666666666
	object.WaitTime = self.WaitTime
	object.Tween = self.Tween or nil

	if p then
		object.Function = p
		object.YieldEvent = Instance.new("BindableEvent")
	end

	if Functions[object.Type] then
		object.UpdateFunction = Functions[object.Type]
	end

	table.insert(v, object)
	local yieldEvent = object.YieldEvent

	if p and yieldEvent then
		yieldEvent.Event:Wait()
		yieldEvent:Destroy()
	else
		return object
	end
end

function PeodizService:CustomForLoop(p)
	local object = setmetatable({}, PeodizService)
	object.Type = "CustomForLoop"

	if self.WaitTime and self.WaitTime <= 0 then
		self.WaitTime = 0.016666666666666666
	end

	self.WaitTime = self.WaitTime or 0.016666666666666666
	self.Step = self.Step or 10
	self.Start = self.Start or 0
	self.End = self.End or 1
	object.Step = self.Step
	object.Start = self.Start
	object.End = self.End
	object.WaitTime = self.WaitTime
	object.LifeTime = object.End / object.Step * object.WaitTime
	object.Tween = self.Tween or nil
	object.CurrentWaitTime = self.WaitTime
	object.CurrentTime = object.Start / object.End

	if p then
		object.Function = p
		object.YieldEvent = Instance.new("BindableEvent")
	end

	if Functions[object.Type] then
		object.UpdateFunction = Functions[object.Type]
	end

	table.insert(v, object)
	local yieldEvent = object.YieldEvent

	if p and yieldEvent then
		yieldEvent.Event:Wait()
		yieldEvent:Destroy()
	else
		return object
	end
end

function PeodizService:CustomForceForLoop(p)
	local object = setmetatable({}, PeodizService)
	object.Type = "CustomForceForLoop"

	if self.WaitTime and self.WaitTime <= 0 then
		self.WaitTime = 0.016666666666666666
	end

	self.WaitTime = self.WaitTime or 0.016666666666666666
	self.Step = self.Step or 10
	self.Start = self.Start or 0
	self.End = self.End or 1
	object.StepData = {}
	object.Step = self.Step
	object.Start = self.Start
	object.End = self.End
	object.WaitTime = self.WaitTime
	object.LifeTime = object.End / object.Step * object.WaitTime
	object.Tween = self.Tween or nil
	object.CurrentWaitTime = self.WaitTime
	object.CurrentTime = object.Start / object.End

	if p then
		object.Function = p
		object.YieldEvent = Instance.new("BindableEvent")
	end

	if Functions[object.Type] then
		object.UpdateFunction = Functions[object.Type]
	end

	table.insert(v, object)
	local yieldEvent = object.YieldEvent

	if p and yieldEvent then
		yieldEvent.Event:Wait()
		yieldEvent:Destroy()
	else
		return object
	end
end

function PeodizService:ForLoop(p)
	local object = setmetatable({}, PeodizService)
	object.Type = "ForLoop"

	if self.WaitTime and self.WaitTime <= 0 then
		self.WaitTime = 0.016666666666666666
	end

	self.WaitTime = self.WaitTime or 0.016666666666666666
	self.Step = self.Step or 10

	if self.Step < 0 then
		self.Step = 1
	end

	object.WaitTime = self.WaitTime
	object.LifeTime = self.WaitTime * self.Step
	object.Tween = self.Tween or nil

	if self.Instant then
		object.CurrentTime = 1 / object.Step
		object.CurrentWaitTime = object.WaitTime
	end

	if p then
		object.Function = p
		object.YieldEvent = Instance.new("BindableEvent")
	end

	if Functions[object.Type] then
		object.UpdateFunction = Functions[object.Type]
	end

	table.insert(v, object)
	local yieldEvent = object.YieldEvent

	if p and yieldEvent then
		yieldEvent.Event:Wait()
		yieldEvent:Destroy()
	else
		return object
	end
end

function PeodizService:ForceForLoop(p)
	local object = setmetatable({}, PeodizService)
	object.Type = "ForceForLoop"

	if self.WaitTime and self.WaitTime <= 0 then
		self.WaitTime = 0.016666666666666666
	end

	self.WaitTime = self.WaitTime or 0.016666666666666666
	self.Step = self.Step or 10
	object.StepData = {}
	object.Step = self.Step
	object.WaitTime = self.WaitTime
	object.LifeTime = self.WaitTime * self.Step
	object.Tween = self.Tween or nil

	if self.Instant then
		object.CurrentTime = 1 / object.Step
		object.CurrentWaitTime = object.WaitTime
	end

	if p then
		object.Function = p
		object.YieldEvent = Instance.new("BindableEvent")
	end

	if Functions[object.Type] then
		object.UpdateFunction = Functions[object.Type]
	end

	table.insert(v, object)
	local yieldEvent = object.YieldEvent

	if p and yieldEvent then
		yieldEvent.Event:Wait()
		yieldEvent:Destroy()
	else
		return object
	end
end

function PeodizService:Update(p)
	self.CurrentTime = self.CurrentTime or 0
	self.CurrentWaitTime = self.CurrentWaitTime or 0
	self.WaitTime = self.WaitTime or 0.016666666666666666
	self.LifeTime = self.LifeTime or 1
	self.CurrentTime = math.min(self.CurrentTime + p / self.LifeTime, 1)
	self.CurrentWaitTime += p

	if self.UpdateFunction then
		self:UpdateFunction(p)
	end

	if self and self.CurrentTime == 1 and not self.Finished then
		self:Destroy()
	end
end

function PeodizService:Connect(p)
	if p then
		if not self.Function then
			self.Function = p
		end

		if not (self.YieldEvent or self.NoYield) then
			local bindableEvent = Instance.new("BindableEvent")
			self.YieldEvent = bindableEvent
			bindableEvent.Event:Wait()
			bindableEvent:Destroy()
		end
	end
end

function PeodizService:Destroy()
	if self.Finished then
		return
	end

	self.Finished = true

	if self.YieldEvent then
		self.YieldEvent:Fire()
	end

	for k, v2 in pairs(v) do
		if v2 ~= self then
			continue
		end

		table.remove(v, k)

		for k2, _ in pairs(self) do
			self[k2] = nil
		end

		table.clear(self)
		break
	end
end

RunService.Heartbeat:Connect(function(dt)
	for _, v2 in pairs(v) do
		v2:Update(dt)
	end
end)
return PeodizService