local Signal = require(game.ReplicatedStorage.Packages.Signal)
local PathUtil = require(game.ReplicatedStorage.Definitions.QATask.PathUtil)
local Types = require(game.ReplicatedStorage.Definitions.QATask.Types)
local listsByPath = {}
local paths = {}
local Registry = {
	OnRegistered = Signal.new()
}

function Registry.register(list)
	local qATask, v = Types.QATask(list)
	assert(qATask, (`cannot register an invalid task: {v}`))
	assert(list.Source ~= "Custom", "custom tasks are saved through the QA service, not registered in code")
	assert(
		list.Path == PathUtil.join(list.Parent, list.Key),
		(`task path "{list.Path}" does not match its parent "{list.Parent}" and key "{list.Key}"`)
	)
	assert(listsByPath[list.Path] == nil, (`a task is already registered at "{list.Path}"`))

	if not table.isfrozen(list) then
		table.freeze(list)
	end

	listsByPath[list.Path] = list
	table.insert(paths, list.Path)
	Registry.OnRegistered:Fire(list)
	return list
end

function Registry.find(p)
	return listsByPath[p]
end

function Registry.getAll()
	local result = {}

	for _, v in paths do
		local v2 = listsByPath[v]

		if v2 then
			table.insert(result, v2)
		end
	end

	return result
end

return Registry