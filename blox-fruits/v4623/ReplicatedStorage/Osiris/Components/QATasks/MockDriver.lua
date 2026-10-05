local QATask = require(game.ReplicatedStorage.Definitions.QATask)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)
local builders = QATask.Builders
local pathUtil = QATask.PathUtil

-- equivalent calls inferred from this helper; original call sites unknown
local function node(title: string, id: string?, description: string?, tags, subtasks)
	return {
		title = title,
		id = id,
		description = description,
		tags = tags,
		subtasks = subtasks
	}
end

local function buildSample()
	return QATask.buildTreeFromSource({
		node(
			"Combat",
			"combat",
			nil,
			nil,
			{ node("Fruits", "fruits", "Validating the functionality of all the blox fruits", nil, {
					{
						title = "Blizzard-Blizzard",
						id = "blizzard",
						description = "Verify the moveset for the Blizzard-Blizzard fruit",
						tags = nil,
						subtasks = {
							{
								title = "\"X\" Move",
								id = nil,
								description = "Use the \"X\" move to make sure it works as expected.",
								tags = nil,
								subtasks = nil
							},
							{
								title = "\"C\" Move",
								id = nil,
								description = "Use the \"C\" move to make sure it works as expected.",
								tags = nil,
								subtasks = nil
							}
						}
					}
				}), node("Swords", "swords", nil, { "ECONOMY" }, nil) }
		),
		node(
			"HUD",
			"hud",
			"The UI immediately accessible to a user.",
			nil,
			{ node("Boot", "boot", "Does the HUD boot as expected?", { "BOOT" }, nil) }
		)
	})
end

return {
	new = function(p, value: number?)
		local clone = table.clone(buildSample())
		local v = {}
		local v2 = {}
		local v3 = {}
		local v4 = value or 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function wait()
			if v4 > 0 then
				task.wait(v4)
			end
		end

		local function inScope(p2, p3)
			return p2 == nil or p2[p3] == true
		end

		local function children(p2, p3)
			local result = {}

			for _, v5 in QATask.getChildren(clone, p2) do
				local path = v5.Path

				if p3 == nil or p3[path] == true then
					table.insert(result, v5)
				end
			end

			return result
		end

		local leaves

		leaves = function(p2, p3)
			local result = {}
			local v5 = children(p2, nil)

			if #v5 == 0 then
				if p3 == nil or p3[p2] == true then
					table.insert(result, p2)
				end
			else
				for _, v6 in v5 do
					for _, v7 in leaves(v6.Path, p3) do
						table.insert(result, v7)
					end
				end
			end

			return result
		end

		local function scopeFor(data)
			if QATask.isFilterEmpty(data) then
				return nil
			end

			local result = {}
			local text

			if not (data.Text == nil or data.Text == "") then
				text = data.Text:lower()
			end

			local includeSubtree

			includeSubtree = function(path)
				result[path] = true

				for _, v5 in children(path, nil) do
					includeSubtree(v5.Path)
				end
			end

			for k, v5 in clone do
				if not (data.Tag == nil or v5.Tags ~= nil and table.find(v5.Tags, data.Tag) ~= nil) then
					continue
				end

				if not (text == nil or v5.Title:lower():find(text, 1, true) ~= nil) then
					continue
				end

				if data.AssignedTo ~= nil then
					local v6 = v2[k]

					if v6 == nil or v6.UserId ~= data.AssignedTo then
						continue
					end
				end

				result[k] = true

				for _, v6 in children(k, nil) do
					includeSubtree(v6.Path)
				end

				local parent = v5.Parent

				while parent ~= nil do
					result[parent] = true
					parent = pathUtil.parentOf(parent)
				end
			end

			return result
		end

		local function progressOf(items, p2)
			local result = {}

			for _, item in items do
				if not (clone[item] ~= nil and (p2 == nil or p2[item] == true)) then
					continue
				end

				local v5 = leaves(item, p2)
				local count = 0

				for _, v6 in v5 do
					if v[v6] ~= nil then
						count += 1
					end
				end

				result[item] = {
					Done = count,
					Total = #v5
				}
			end

			return result
		end

		local function progressOfTasks(items, p2)
			local paths = {}

			for _, item in items do
				table.insert(paths, item.Path)
			end

			return (progressOf(paths, p2))
		end

		local function resolve(p2)
			local v5 = clone[p2]

			if v5 == nil then
				return nil
			end

			local children2 = {}

			for _, v7 in children(p2, nil) do
				table.insert(children2, v7.Key)
			end

			local clone2 = table.clone(v5)

			if not (#children2 > 0) then
				children2 = nil
			end

			clone2.Children = children2
			return table.freeze(clone2)
		end

		local function resolveAll(items)
			local result = {}

			for _, item in items do
				table.insert(result, (resolve(item.Path)))
			end

			return result
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function emit(p2)
			for _, callback in v3 do
				task.spawn(callback, p2)
			end
		end

		local function descendants(p2, p3)
			local result = {}

			for k in clone do
				if pathUtil.isAncestorOf(p2, k) and (p3 == nil or p3[k] == true) then
					table.insert(result, k)
				end
			end

			return result
		end

		return {
			LocalUserId = 1,
			getPermissions = function()
				wait() -- equivalent call inferred; original call site unknown
				return QATask.getPermissionsForRank(p)
			end,
			getRoots = function(p2)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = scopeFor(p2)
				local v6 = {}

				for _, v7 in QATask.getRoots(clone) do
					local path = v7.Path

					if v5 == nil or v5[path] == true then
						table.insert(v6, v7)
					end
				end

				local all = resolveAll(v6)
				local paths = {}

				for _, v7 in all do
					table.insert(paths, v7.Path)
				end

				return all, (progressOf(paths, v5))
			end,
			getTask = function(p2, p3)
				wait() -- equivalent call inferred; original call site unknown
				return resolve(p2), (progressOf({ p2 }, scopeFor(p3)))
			end,
			getChildren = function(p2, p3)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = scopeFor(p3)
				local all = resolveAll(children(p2, v5))
				local paths = {}

				for _, v6 in all do
					table.insert(paths, v6.Path)
				end

				return all, (progressOf(paths, v5))
			end,
			getState = function()
				wait() -- equivalent call inferred; original call site unknown
				return {
					Branch = "mock",
					Sha = "mock123"
				}, table.clone(v), table.clone(v2)
			end,
			getProgress = function(p2, p3)
				wait() -- equivalent call inferred; original call site unknown
				return (progressOf(p2, scopeFor(p3)))
			end,
			setCompletion = function(p2, flag: boolean, p3)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = scopeFor(p3)
				local selected = v[p2] ~= nil

				if selected == flag then
					return false, selected, v[p2], (progressOf({ p2 }, v5))
				end

				local v7 = descendants(p2, v5)
				table.insert(v7, p2)

				if flag then
					local v8 = {
						Sha = "mock123",
						UserId = 1,
						UserName = "mock tester",
						Timestamp = os.time()
					}

					for _, v9 in v7 do
						v[v9] = v8
					end
				else
					for _, v8 in v7 do
						v[v8] = nil
					end

					local parent = pathUtil.parentOf(p2)

					while parent ~= nil do
						v[parent] = nil
						parent = pathUtil.parentOf(parent)
					end
				end

				local clone2 = table.clone(v7)
				local parent = pathUtil.parentOf(p2)

				while parent ~= nil do
					table.insert(clone2, parent)
					parent = pathUtil.parentOf(parent)
				end

				return true, flag, v[p2], (progressOf(clone2, v5))
			end,
			createTask = function(p2)
				wait() -- equivalent call inferred; original call site unknown
				local success, result = pcall(function()
					return builders.Task.Builder.fromDraft(p2, "Custom"):setScope(p2.Scope or "Branch"):build()
				end)

				if not success then
					return nil, (tostring(result))
				end

				if clone[result.Path] ~= nil then
					return nil, (`a task already exists at "{result.Path}"`)
				end

				clone[result.Path] = result
				local task2 = resolve(result.Path)
				emit({
					Type = "TaskCreated",
					Task = task2
				}) -- equivalent call inferred; original call site unknown
				return task2, nil
			end,
			updateTask = function(p2, p3)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = clone[p2]

				if v5 == nil or v5.Source ~= "Custom" then
					return nil, (`no custom task at "{p2}"`)
				end

				local success, result = pcall(function()
					return builders.Task.Builder.fromDraft(p3, "Custom"):setScope(p3.Scope or "Branch"):build()
				end)

				if not success then
					return nil, (tostring(result))
				end

				clone[p2] = result
				local task2 = resolve(p2)
				emit({
					Type = "TaskUpdated",
					Task = task2
				}) -- equivalent call inferred; original call site unknown
				return task2, nil
			end,
			deleteTask = function(path)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = clone[path]

				if v5 == nil or v5.Source ~= "Custom" then
					return false, (`no custom task at "{path}"`)
				end

				clone[path] = nil

				for _, v6 in descendants(path, nil) do
					clone[v6] = nil
				end

				emit({
					Type = "TaskDeleted",
					Path = path
				}) -- equivalent call inferred; original call site unknown
				return true, nil
			end,
			resetAll = function(p2)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = scopeFor(p2)
				local count = 0

				for k in table.clone(v) do
					if not (v5 == nil or v5[k] == true) then
						continue
					end

					v[k] = nil
					count += 1
				end

				emit({
					Type = "StateReset"
				}) -- equivalent call inferred; original call site unknown
				return count
			end,
			resetSubtree = function(p2, p3)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = scopeFor(p3)
				local count = 0
				local v6 = descendants(p2, v5)

				if v5 == nil or v5[p2] == true then
					table.insert(v6, p2)
				end

				for _, v7 in v6 do
					if v[v7] == nil then
						continue
					end

					v[v7] = nil
					count += 1
				end

				emit({
					Type = "StateReset"
				}) -- equivalent call inferred; original call site unknown
				return count
			end,
			resetSha = function(p2: string, p3)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = scopeFor(p3)
				local count = 0

				for k, v6 in table.clone(v) do
					if not (v6.Sha == p2 and (v5 == nil or v5[k] == true)) then
						continue
					end

					v[k] = nil
					count += 1
				end

				emit({
					Type = "StateReset"
				}) -- equivalent call inferred; original call site unknown
				return count
			end,
			getShaSummary = function(p2)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = scopeFor(p2)
				local count = 0
				local earliestTimestamp = 1e999
				local latestTimestamp = 0

				for k, v8 in v do
					if not (v5 == nil or v5[k] == true) then
						continue
					end

					count += 1
					earliestTimestamp = math.min(earliestTimestamp, v8.Timestamp)
					latestTimestamp = math.max(latestTimestamp, v8.Timestamp)
				end

				if count == 0 then
					return {}
				end

				return {
					{
						Sha = "mock123",
						Count = count,
						EarliestTimestamp = earliestTimestamp,
						LatestTimestamp = latestTimestamp
					}
				}
			end,
			assignTask = function(p2, userId: number?, p4)
				wait() -- equivalent call inferred; original call site unknown
				local v5 = scopeFor(p4)
				local paths = descendants(p2, v5)

				if v5 == nil or v5[p2] == true then
					table.insert(paths, 1, p2)
				end

				local assignment = userId ~= nil and {
					UserId = userId,
					UserName = `user {userId}`,
					AssignedBy = 1,
					Timestamp = os.time()
				} or nil

				for _, v8 in paths do
					if assignment == nil then
						v2[v8] = nil
					else
						v2[v8] = assignment
					end
				end

				emit({
					Type = "AssignmentChanged",
					Paths = paths,
					Assignment = assignment
				}) -- equivalent call inferred; original call site unknown
				return #paths, nil
			end,
			getTesters = function()
				wait() -- equivalent call inferred; original call site unknown
				return {
					{
						UserId = 1,
						Name = "mock tester",
						Rank = "QAAdmin"
					},
					{
						UserId = 2,
						Name = "other tester",
						Rank = "QATester"
					}
				}
			end,
			runCommand = function(p2: string)
				print((`[mock] run command: {p2}`))
			end,
			onChange = function(callback)
				table.insert(v3, callback)
				return function()
					local index = table.find(v3, callback)

					if index then
						table.remove(v3, index)
					end
				end
			end
		}
	end
}