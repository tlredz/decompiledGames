local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Builders = require(script.Builders)
local PathUtil = require(script.PathUtil)
local Registry = require(script.Registry)
local Types = require(script.Types)

local function uniqueKey(p, p2)
	if p2[p] == nil then
		return p
	end

	local v = 2

	while p2[`{p}-{v}`] ~= nil do
		v += 1
	end

	return (`{p}-{v}`)
end

local QATask = {
	Types = Types,
	Builders = Builders,
	PathUtil = PathUtil,
	Registry = Registry,
	REQUEST_REMOTE_NAME = "RequestQATask",
	CHANGE_REMOTE_NAME = "OnQATaskChange",
	RANK_ATTRIBUTE = "QARank",
	isFilterEmpty = function(data)
		if data == nil then
			return true
		end

		return data.Tag == nil and (data.Text == nil or data.Text == "") and data.AssignedTo == nil
	end,
	filterKey = function(data)
		if data == nil then
			return ""
		end

		return (`{data.Tag or ""}|{data.Text or ""}|{data.AssignedTo or ""}`)
	end,
	registerTask = function(p)
		return Registry.register(p)
	end,
	getPermissionsForRank = function(rank)
		local v = {
			Rank = rank,
			CanRead = rank ~= nil,
			CanComplete = rank ~= nil,
			CanWrite = rank == "QAAdmin"
		}
		table.freeze(v)
		return v
	end,
	buildTreeFromSource = function(items)
		local v = {}
		local visit

		visit = function(data, p, p2)
			local sourceNode, v2 = Types.SourceNode(data)
			assert(sourceNode, (`bad source node under "{p or PathUtil.ROOT}": {v2}`))
			local id = data.id
			local slugify = PathUtil.slugify

			if id == nil then
				id = data.title
			end

			local v3 = slugify(id)

			if p2[v3] ~= nil then
				local v4 = 2

				while p2[`{v3}-{v4}`] ~= nil do
					v4 += 1
				end

				v3 = `{v3}-{v4}`
			end

			p2[v3] = true
			local v4 = Builders.Task.Builder.new(v3, p):setTitle(data.title):setSource("Static")

			if data.description ~= nil then
				v4 = v4:setDescription(data.description)
			end

			if data.tags ~= nil then
				for _, tag in data.tags do
					local v5, v6 = Types.Tag(tag)
					assert(v5, (`bad tag on "{v4:getPath()}": {v6}`))
					v4 = v4:insertTag(tag)
				end
			end

			local path = v4:getPath()
			local v5 = {}

			if data.subtasks ~= nil then
				local v6 = {}

				for _, subtask in data.subtasks do
					table.insert(v5, visit(subtask, path, v6))
				end
			end

			for _, v6 in v5 do
				v4 = v4:insertChild(v6.Key)
			end

			local v6 = v4:build()
			assert(v[v6.Path] == nil, (`duplicate task path "{v6.Path}"`))
			v[v6.Path] = v6
			return v6
		end

		local v2 = {}

		for _, item in items do
			visit(item, nil, v2)
		end

		return v
	end,
	getRoots = function(items)
		local result = {}

		for _, item in items do
			if item.Parent == nil then
				table.insert(result, item)
			end
		end

		table.sort(result, function(a, b)
			return PathUtil.compare(a.Path, b.Path)
		end)
		return result
	end,
	getChildren = function(items, p)
		local item = items[p]
		local result = {}
		local v = {}

		if item and item.Children then
			for _, v2 in item.Children do
				local item2 = items[PathUtil.join(p, v2)]

				if not item2 then
					continue
				end

				v[v2] = true
				table.insert(result, item2)
			end
		end

		local v2 = {}

		for _, item2 in items do
			if item2.Parent == p and v[item2.Key] == nil then
				table.insert(v2, item2)
			end
		end

		table.sort(v2, function(a, b)
			return PathUtil.compare(a.Path, b.Path)
		end)

		for _, v3 in v2 do
			table.insert(result, v3)
		end

		return result
	end,
	getDescendantPaths = function(items, p)
		local result = {}

		for k in items do
			if PathUtil.isAncestorOf(p, k) then
				table.insert(result, k)
			end
		end

		table.sort(result, function(a, b)
			return PathUtil.compare(a, b)
		end)
		return result
	end,
	getAncestors = function(p, p2)
		local parent = PathUtil.parentOf(p2)
		local result = {}

		while parent ~= nil do
			local v = p[parent]

			if v then
				table.insert(result, 1, v)
			end

			parent = PathUtil.parentOf(parent)
		end

		return result
	end
}

function QATask.countLeaves(items, p)
	local count = 0

	for k in items do
		if not (PathUtil.isAncestorOf(p, k) and #QATask.getChildren(items, k) == 0) then
			continue
		end

		count += 1
	end

	if count == 0 and items[p] ~= nil then
		return 1
	end

	return count
end

function QATask.freezeMap(p)
	TableUtil.deepFreeze(p)
	return p
end

return QATask