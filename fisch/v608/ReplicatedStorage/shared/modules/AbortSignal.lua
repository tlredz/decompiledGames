local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Signal"))
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local AbortSignal = {}

function AbortSignal.new()
	return (setmetatable({
		Aborted = false,
		Reason = "",
		OnAbort = Signal.new(),
		_trove = Trove.new()
	}, {
		__index = AbortSignal
	}))
end

function AbortSignal:Abort(value: string)
	if not self.Aborted and self._trove then
		local reason = value or "Operation aborted!"
		self.Aborted = true
		self.Reason = reason
		self.OnAbort:Fire(reason)
		task.defer(function()
			self:Destroy()
		end)
	end
end

function AbortSignal:SetTimeout(duration: number, value: string?)
	local thread = task.delay(duration, self.Abort, self, value or "Timed out")
	self._trove:Add(thread)
	return thread
end

function AbortSignal:BindToSignal(object2, p: string)
	local connection = object2:Once(function()
		self:Abort(p)
	end)
	self._trove:Add(connection)
	return connection
end

function AbortSignal.ThrowIfAborted(p)
	if p.Aborted then
		error(p.Reason, 2)
	end
end

function AbortSignal:Destroy()
	self._trove:Clean()
	self._trove = nil
	self.OnAbort = nil
end

return AbortSignal