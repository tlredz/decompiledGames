local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bindable = require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)

local function DestroyThing(animationTrack)
	if typeof(animationTrack) == "RBXScriptConnection" then
		task.spawn(animationTrack.Disconnect, animationTrack)
	elseif typeof(animationTrack) == "Instance" then
		if animationTrack:IsA("AnimationTrack") and animationTrack.IsPlaying then
			task.spawn(function()
				animationTrack:Stop(0.05)
				task.delay(0.11666666666666667, function()
					animationTrack:Destroy()
				end)
			end)
		else
			task.spawn(animationTrack.Destroy, animationTrack)
		end
	elseif type(animationTrack) == "thread" then
		pcall(task.cancel, animationTrack)
	elseif type(animationTrack) == "function" then
		task.spawn(animationTrack)
	elseif type(animationTrack) == "table" then
		task.spawn(function(connection)
			if connection.Destroy then
				connection:Destroy()
			elseif connection.Disconnect then
				connection:Disconnect()
			end
		end, animationTrack)
	end
end

local function Add(p, value)
	if value == nil then
		return nil
	end

	if typeof(value) ~= "RBXScriptConnection" and typeof(value) ~= "Instance" and type(value) ~= "thread" and type(value) ~= "function" then
		if type(value) == "table" then
			if type(value.Destroy) ~= "function" and type(value.Disconnect) ~= "function" then
				error("Unknown thing: table (missing Destroy/Disconnect)")
			end
		else
			error((`Unknown thing: {typeof(value)}`))
		end
	end

	if p.Destroyed then
		DestroyThing(value)
	else
		table.insert(p.Things, value)
		return value
	end

	return value
end

local v = {
	Destroy = function(self)
		if self.Destroyed then
			return false
		end

		self.Destroyed = true

		for _, thing in ipairs(self.Things) do
			DestroyThing(thing)
		end

		self.Destroying:Fire()
		return true
	end,
	IsDestroyed = function(p)
		return p.Destroyed
	end,
	Add = Add
}
local frozen = table.freeze({
	__index = v,
	__call = Add
})
table.freeze(v)
return table.freeze({
	new = function()
		return (setmetatable({
			Destroyed = false,
			Destroying = Bindable.new(),
			Things = {}
		}, frozen))
	end
})