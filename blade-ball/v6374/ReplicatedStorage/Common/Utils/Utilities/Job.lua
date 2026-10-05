local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Trove)
local Job = {}
Job.__index = Job

function Job.new(p)
	return (setmetatable({
		tasks = {},
		cleaner = p or v.new(),
		_execution = nil,
		currentTask = 1
	}, Job))
end

function Job:setNewCleaner(p2)
	self.cleaner = p2 or v.new()
	return self
end

function Job.addTask(p, callback)
	table.insert(p.tasks, callback)
	return p
end

function Job:cancel(flag: boolean)
	if not self._execution or coroutine.status(self._execution) == "dead" then
		return self
	end

	coroutine.close(self._execution)
	self._execution = nil

	if not flag then
		self.cleaner:Destroy()
	end

	return self
end

function Job:run(value: number?, ...)
	local v2 = { ... }
	local currentTask = value or 1

	if not self.tasks[currentTask] then
		return
	end

	self:cancel(true)
	self._execution = task.spawn(function()
		while currentTask <= #self.tasks do
			self.currentTask = currentTask

			if self.tasks[currentTask](self, unpack(v2)) == Job.Break then
				break
			else
				currentTask += 1
			end
		end
	end)
	return self
end

function Job:skip(value: number?, ...)
	local count = #self.tasks
	local currentTask = self.currentTask

	if count <= currentTask then
		return
	end

	self:cancel(true)
	self:run(math.min(currentTask + (value or 1), count), ...)
	return self
end

function Job.clone(p)
	return (setmetatable({
		tasks = table.clone(p.tasks),
		cleaner = p.cleaner:Extend(),
		_execution = nil,
		currentTask = 1
	}, Job))
end

Job.Break = {}
return Job