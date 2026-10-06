local RunService = game:GetService("RunService")
local v = {}
local FastRenderer = {}
FastRenderer.__index = FastRenderer
local Functions = require(script.Functions)

function FastRenderer.new(p, p2)
	local object = setmetatable({}, FastRenderer)
	object.Type = "Heartbeat"
	object.LifeTime = p.Time or 1

	if p2 then
		object.Function = p2
		object.YieldEvent = Instance.new("BindableEvent")
	end

	if Functions[object.Type] then
		object.UpdateFunction = Functions[object.Type]
	end

	table.insert(v, object)

	if p2 and object.YieldEvent then
		object.YieldEvent.Event:Wait()
		object.YieldEvent:Destroy()
	else
		return object
	end
end

function FastRenderer:Update(p)
	self.CurrentTime = self.CurrentTime or 0
	self.LifeTime = self.LifeTime or 1
	self.CurrentTime = math.min(self.CurrentTime + p / self.LifeTime, 1)

	if self.UpdateFunction then
		self:UpdateFunction(p)
	end

	if self and self.CurrentTime == 1 and not self.Finished then
		self:Destroy()
	end
end

function FastRenderer:Connect(p)
	if p then
		if not self.Function then
			self.Function = p
		end

		if not (self.YieldEvent or self.NoYield) then
			self.YieldEvent = Instance.new("BindableEvent")
			self.YieldEvent.Event:Wait()
			self.YieldEvent:Destroy()
		end
	end
end

function FastRenderer:Destroy()
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
		break
	end
end

RunService.RenderStepped:Connect(function(dt)
	for _, v2 in pairs(v) do
		v2:Update(dt)
	end
end)
return FastRenderer