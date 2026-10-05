local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage.Packages.Observers)
local Timer = require(ReplicatedStorage.Packages.Timer)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function sync(state, now: number)
	local timePosition = now % state.Length

	if math.abs(timePosition - state.TimePosition) > 0.05 or state.Length == 0 then
		state.TimePosition = timePosition
	end
end

local function triggerResyncFor(state, p: number)
	while p > 0 do
		sync(state, os.clock()) -- equivalent call inferred; original call site unknown
		p -= task.wait()
	end
end

Timer.Simple(1, function()
	local now = os.clock()

	for _, v2 in v do
		sync(v2, now) -- equivalent call inferred; original call site unknown
	end
end)
return {
	Add = function(_, p)
		table.insert(v, p)
		local thread = task.spawn(triggerResyncFor, p, 1)
		return function()
			if coroutine.status(thread) == "suspended" then
				pcall(task.cancel, thread)
			end

			local index = table.find(v, p)

			if index then
				table.remove(v, index)
			end
		end
	end
}