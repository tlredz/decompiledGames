local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCList = require(ReplicatedStorage.NPCManager.NPCList)
local v = {}
local v2 = {}
local DialogueRegistry = {}

function v2.getSortedProviders(p)
	local providers = {}

	for _, provider in p.providers do
		table.insert(providers, provider)
	end

	table.sort(providers, function(a, b)
		if a.priority == b.priority then
			return a.id < b.id
		end

		return a.priority > b.priority
	end)
	return providers
end

function v2.install(p: string, p2)
	local entry = NPCList.List[p]

	if not entry or typeof(entry.DialogueCallback) ~= "function" then
		return false
	end

	local dialogueCallback = entry.DialogueCallback

	local function fn(...)
		local v4 = dialogueCallback(...)

		for _, v5 in v2.getSortedProviders(p2) do
			local callback = v5.callback(v4, ...)

			if callback ~= nil then
				return callback
			end
		end

		return v4
	end

	p2.entry = entry
	p2.original = dialogueCallback
	p2.wrapper = fn
	entry.DialogueCallback = fn
	return true
end

function v2.startInstall(p: string, state)
	if state.installing or state.wrapper then
		return
	end

	state.installing = true
	task.spawn(function()
		while v[p] == state and next(state.providers) ~= nil and not (state.wrapper or v2.install(p, state)) do
			task.wait(1)
		end

		state.installing = false
	end)
end

function v2.removeState(p: string, data)
	if data.entry and data.wrapper and data.entry.DialogueCallback == data.wrapper then
		data.entry.DialogueCallback = data.original
	end

	if v[p] == data then
		v[p] = nil
	end
end

function DialogueRegistry.register(p: string, id: string, priority: number, callback)
	assert(p ~= "", "NPC id cannot be empty")
	assert(id ~= "", "Provider id cannot be empty")
	assert(typeof(priority) == "number", "Priority must be a number")
	assert(typeof(callback) == "function", "Provider callback must be a function")
	local v3 = v[p]

	if not v3 then
		v3 = {
			providers = {},
			entry = nil,
			original = nil,
			wrapper = nil,
			installing = false
		}
		v[p] = v3
	end

	local v4 = {
		id = id,
		priority = priority,
		callback = callback
	}
	v3.providers[id] = v4
	v2.startInstall(p, v3)
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true

		if v3.providers[id] ~= v4 then
			return
		end

		v3.providers[id] = nil

		if next(v3.providers) == nil then
			v2.removeState(p, v3)
		end
	end
end

return DialogueRegistry