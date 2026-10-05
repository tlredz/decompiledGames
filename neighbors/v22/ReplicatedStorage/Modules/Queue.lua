local Queue = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Modules.TableUtil)
Queue.Status = {
	Success = true,
	Cancel = true,
	Repeat = false
}

-- equivalent calls inferred from this helper; original call sites unknown
local function safeCancel(updateThread: thread)
	pcall(task.cancel, updateThread)
end

function Queue.new(value: number?)
	local self = setmetatable({}, {
		__index = Queue
	})
	self.Items = {}
	self.UpdateRate = value or 0
	self.Running = false
	self.Destroyed = false
	return self
end

function Queue:Add(callback, id)
	if id and self:Get(id) or self.Destroyed then
		return false
	end

	table.insert(self.Items, {
		Callback = callback,
		Id = id,
		TimeAdded = os.clock()
	})
	self:_startRunning()
	return true
end

function Queue:Remove(p)
	local v = self:Get(p)

	if v then
		TableUtil.remove(self.Items, v)
	end
end

function Queue:Get(p2)
	for _, item in next, self.Items, nil do
		if item.Id == p2 then
			return item
		end
	end

	return nil
end

function Queue:GetNext()
	local v = nil

	for _, item in next, self.Items, nil do
		if not v or v.TimeAdded > item.TimeAdded then
			v = item
		end
	end

	return v
end

function Queue:Run()
	local next2 = self:GetNext()

	if next2 then
		if next2.Callback() then
			TableUtil.remove(self.Items, next2)
		else
			next2.TimeAdded = os.clock()
		end
	end
end

function Queue:_startRunning()
	if self.Running or #self.Items == 0 or self.Destroyed then
		return
	end

	self.Running = true
	self.UpdateThread = task.spawn(function()
		while #self.Items > 0 and not self.Destroyed do
			self:Run()
			task.wait(self.UpdateRate)
		end

		self.Running = false
	end)
end

function Queue:Destroy()
	self.Destroyed = true

	if self.UpdateThread then
		safeCancel(self.UpdateThread) -- equivalent call inferred; original call site unknown
		self.UpdateThread = nil
	end

	table.clear(self.Items)
end

return Queue