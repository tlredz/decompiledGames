local QATask = require(game.ReplicatedStorage.Definitions.QATask)
local Store = require(game.ReplicatedStorage.Osiris.Components.QATasks.Store)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)
local pathUtil = QATask.PathUtil

-- equivalent calls inferred from this helper; original call sites unknown
local function run(p, formatted: string, fn)
	local v = p.pending:get()

	if v[formatted] then
		return
	end

	v[formatted] = true
	task.spawn(function()
		local success, result = pcall(fn)
		v[formatted] = nil

		if not success then
			Store.setMessage(p, tostring(result), true)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheTask(p, p2)
	local get = p.tasks:get()
	get[p2.Path] = p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mergeProgress(p, items)
	local v = p.progress:get()

	for k, item in items do
		v[k] = item
	end
end

local function cacheChildren(p, p2, items)
	local paths = {}

	for _, item in items do
		cacheTask(p, item) -- equivalent call inferred; original call site unknown
		table.insert(paths, item.Path)
	end

	local get = p.children:get()
	get[Store.childrenKey(p2)] = paths
end

-- equivalent calls inferred from this helper; original call sites unknown
local function invalidateChildren(data, parent)
	local get = data.children:get()
	get[Store.childrenKey(parent)] = nil
end

local function ancestorsOf(p)
	local parent = pathUtil.parentOf(p)
	local result = {}

	while parent ~= nil do
		table.insert(result, parent)
		parent = pathUtil.parentOf(parent)
	end

	return result
end

local Loader = {
	isPending = function(p, p2: string)
		return p.pending:get()[p2] == true
	end,
	getFilter = function(data, p)
		local tag = data.tagFilter:get()
		local text = data.filter:get()
		local v3 = data.onlyMine:get()

		if tag == Store.ANY_TAG and text == "" and not v3 then
			return nil
		end

		if tag == Store.ANY_TAG then
			tag = nil
		end

		if text == "" then
			text = nil
		end

		local assignedTo

		if v3 then
			assignedTo = p.LocalUserId
		end

		return {
			Tag = tag,
			Text = text,
			AssignedTo = assignedTo
		}
	end,
	isFiltered = function(p)
		return p.filterKey:get() ~= ""
	end
}

function Loader.syncFilter(data, p)
	local filterKey = QATask.filterKey(Loader.getFilter(data, p))

	if data.filterKey:get() == filterKey then
		return
	end

	data.filterKey:set(filterKey)
	table.clear(data.children:get())
	table.clear(data.progress:get())
	data.shaSummary:set(nil)
end

function Loader.clearFilter(data)
	data.filter:set("")
	data.tagFilter:set(Store.ANY_TAG)
	data.onlyMine:set(false)
end

function Loader.loadPermissions(p, p2)
	if p.permissions:get() ~= nil then
		return
	end

	local function fn()
		p.permissions:set(p2.getPermissions())
	end

	local v = p.pending:get()

	if v.permissions then
		return
	end

	v.permissions = true
	local v2 = "permissions"
	task.spawn(function()
		local success, result = pcall(fn)
		v[v2] = nil

		if not success then
			Store.setMessage(p, tostring(result), true)
		end
	end)
end

function Loader.loadState(data, p)
	if data.stateLoaded:get() then
		return
	end

	local function fn()
		local state, v, v2 = p.getState()
		data.build:set(state)
		data.completions:set(v)
		data.assignments:set(v2)
		data.stateLoaded:set(true)
	end

	local v = data.pending:get()

	if v.state then
		return
	end

	v.state = true
	local v2 = "state"
	task.spawn(function()
		local success, result = pcall(fn)
		v[v2] = nil

		if not success then
			Store.setMessage(data, tostring(result), true)
		end
	end)
end

function Loader.ensureChildren(p, p2, p3)
	local childrenKey = Store.childrenKey(p3)

	if p.children:get()[childrenKey] ~= nil then
		return
	end

	local filter = Loader.getFilter(p, p2)
	local v = p.filterKey:get()

	local function fn()
		local v2, v3

		if p3 == nil then
			v2, v3 = p2.getRoots(filter)
		else
			v2, v3 = p2.getChildren(p3, filter)
		end

		if p.filterKey:get() ~= v then
			return
		end

		cacheChildren(p, p3, v2)
		mergeProgress(p, v3) -- equivalent call inferred; original call site unknown
	end

	run(p, `children:{childrenKey}`, fn) -- equivalent call inferred; original call site unknown
end

function Loader.ensureTask(p, p2, p3)
	if p.tasks:get()[p3] ~= nil then
		return
	end

	local filter = Loader.getFilter(p, p2)
	local v = p.filterKey:get()

	local function fn()
		local task2, v2 = p2.getTask(p3, filter)

		if task2 then
			cacheTask(p, task2) -- equivalent call inferred; original call site unknown
		end

		if p.filterKey:get() == v then
			mergeProgress(p, v2) -- equivalent call inferred; original call site unknown
		end
	end

	run(p, `task:{p3}`, fn) -- equivalent call inferred; original call site unknown
end

function Loader.ensureProgress(p, p2, p3)
	if p.progress:get()[p3] ~= nil then
		return
	end

	local filter = Loader.getFilter(p, p2)
	local v = p.filterKey:get()

	local function fn()
		local progress = p2.getProgress({ p3 }, filter)

		if p.filterKey:get() == v then
			mergeProgress(p, progress) -- equivalent call inferred; original call site unknown
		end
	end

	run(p, `progress:{p3}`, fn) -- equivalent call inferred; original call site unknown
end

function Loader.refreshProgress(p, p2, list)
	if #list == 0 then
		return
	end

	local filter = Loader.getFilter(p, p2)
	local v = p.filterKey:get()

	local function fn()
		local progress = p2.getProgress(list, filter)

		if p.filterKey:get() == v then
			mergeProgress(p, progress) -- equivalent call inferred; original call site unknown
		end
	end

	run(p, `progress-refresh:{table.concat(list, ",")}`, fn) -- equivalent call inferred; original call site unknown
end

function Loader.refreshAll(data, p)
	table.clear(data.children:get())
	table.clear(data.tasks:get())
	table.clear(data.progress:get())
	data.permissions:set(nil)
	data.stateLoaded:set(false)
	data.shaSummary:set(nil)
	Loader.loadPermissions(data, p)
	Loader.loadState(data, p)
end

function Loader.refreshState(data, p)
	table.clear(data.progress:get())
	data.stateLoaded:set(false)
	data.shaSummary:set(nil)
	Loader.loadState(data, p)
end

function Loader.getChildren(p, p2)
	local v = p.children:get()[Store.childrenKey(p2)]

	if v == nil then
		return nil
	end

	local v2 = p.tasks:get()
	local result = {}

	for _, v3 in v do
		local v4 = v2[v3]

		if v4 then
			table.insert(result, v4)
		end
	end

	return result
end

function Loader.isCompleted(p, p2)
	return p.completions:get()[p2] ~= nil
end

function Loader.getCompletion(p, p2)
	return p.completions:get()[p2]
end

function Loader.getAssignment(p, p2)
	return p.assignments:get()[p2]
end

function Loader.getProgress(p, p2, p3)
	local v = p.progress:get()[p3]

	if v ~= nil then
		return v.Done, v.Total, true
	end

	Loader.ensureProgress(p, p2, p3)
	return Loader.isCompleted(p, p3) and 1 or 0, 1, false
end

function Loader.setCompletion(data, p, p2, flag: boolean)
	local v = data.completions:get()
	local v2 = v[p2]

	if flag then
		v[p2] = {
			Sha = not data.build:get() and "" or data.build:get().Sha,
			UserId = p.LocalUserId,
			UserName = "you",
			Timestamp = os.time()
		}
	else
		v[p2] = nil

		for _, v3 in ancestorsOf(p2) do
			v[v3] = nil
		end
	end

	local filter = Loader.getFilter(data, p)
	local v3 = data.filterKey:get()

	local function fn()
		local _, v4, v5, v6 = p.setCompletion(p2, flag, filter)

		if v4 then
			v[p2] = v5 or v[p2] or v2
		else
			v[p2] = nil
		end

		if data.filterKey:get() == v3 then
			mergeProgress(data, v6) -- equivalent call inferred; original call site unknown
		end

		if flag then
			data.stateLoaded:set(false)
			Loader.loadState(data, p)
		end
	end

	run(data, `complete:{p2}`, fn) -- equivalent call inferred; original call site unknown
end

function Loader.navigate(p, p2, p3)
	p.currentPath:set(p3)
	p.selectedPath:set(p3)

	if p3 ~= nil then
		Loader.ensureTask(p, p2, p3)
	end

	Loader.ensureChildren(p, p2, p3)
end

function Loader.select(p, p2, p3)
	p.selectedPath:set(p3)

	if p3 ~= nil then
		Loader.ensureTask(p, p2, p3)
		Loader.ensureChildren(p, p2, p3)
	end
end

function Loader.loadTesters(p, p2)
	local function fn()
		p.testers:set(p2.getTesters())
	end

	local v = p.pending:get()

	if v.testers then
		return
	end

	v.testers = true
	local v2 = "testers"
	task.spawn(function()
		local success, result = pcall(fn)
		v[v2] = nil

		if not success then
			Store.setMessage(p, tostring(result), true)
		end
	end)
end

function Loader.loadShaSummary(p, p2)
	if p.shaSummary:get() ~= nil then
		return
	end

	local filter = Loader.getFilter(p, p2)

	local function fn()
		p.shaSummary:set(p2.getShaSummary(filter))
	end

	local v = p.pending:get()

	if v["sha-summary"] then
		return
	end

	v["sha-summary"] = true
	local v2 = "sha-summary"
	task.spawn(function()
		local success, result = pcall(fn)
		v[v2] = nil

		if not success then
			Store.setMessage(p, tostring(result), true)
		end
	end)
end

function Loader.assign(p, p2, p3, p4: number?)
	local filter = Loader.getFilter(p, p2)

	local function fn()
		local v, v2 = p2.assignTask(p3, p4, filter)

		if v2 then
			Store.setMessage(p, v2, true)
			return
		end

		local setMessage = Store.setMessage
		local v4

		if p4 then
			v4 = `assigned {v} task(s)`
		else
			v4 = `unassigned {v} task(s)`
		end

		setMessage(p, v4, false)
		Loader.refreshState(p, p2)
	end

	run(p, `assign:{p3}`, fn) -- equivalent call inferred; original call site unknown
end

function Loader.resetAll(p, p2)
	local filter = Loader.getFilter(p, p2)

	local function fn()
		local v = p2.resetAll(filter)
		Store.setMessage(p, `reset {v} completion(s)`, false)
		Loader.refreshState(p, p2)
	end

	local v = p.pending:get()

	if v["reset-all"] then
		return
	end

	v["reset-all"] = true
	local v2 = "reset-all"
	task.spawn(function()
		local success, result = pcall(fn)
		v[v2] = nil

		if not success then
			Store.setMessage(p, tostring(result), true)
		end
	end)
end

function Loader.resetSubtree(p, p2, p3)
	local filter = Loader.getFilter(p, p2)

	local function fn()
		local v = p2.resetSubtree(p3, filter)
		Store.setMessage(p, `reset {v} completion(s) under "{p3}"`, false)
		Loader.refreshState(p, p2)
	end

	run(p, `reset:{p3}`, fn) -- equivalent call inferred; original call site unknown
end

function Loader.resetSha(p, p2, p3: string)
	local filter = Loader.getFilter(p, p2)

	local function fn()
		local v = p2.resetSha(p3, filter)
		Store.setMessage(p, `reset {v} completion(s) from {p3}`, false)
		Loader.refreshState(p, p2)
	end

	run(p, `reset-sha:{p3}`, fn) -- equivalent call inferred; original call site unknown
end

function Loader.applyChange(data, p, data2)
	if data2.Type == "TaskCreated" then
		cacheTask(data, data2.Task) -- equivalent call inferred; original call site unknown
		invalidateChildren(data, data2.Task.Parent) -- equivalent call inferred; original call site unknown

		if data2.Task.Parent then
			local get = data.tasks:get()
			get[data2.Task.Parent] = nil
		end

		Loader.refreshProgress(data, p, (ancestorsOf(data2.Task.Path)))
	elseif data2.Type == "TaskUpdated" then
		cacheTask(data, data2.Task) -- equivalent call inferred; original call site unknown
	elseif data2.Type == "TaskDeleted" then
		local v = data.tasks:get()
		local v2 = data.children:get()
		local v3 = data.progress:get()
		local parent = pathUtil.parentOf(data2.Path)
		v[data2.Path] = nil
		v2[data2.Path] = nil
		v3[data2.Path] = nil

		for k in table.clone(v) do
			if not pathUtil.isAncestorOf(data2.Path, k) then
				continue
			end

			v[k] = nil
			v2[k] = nil
			v3[k] = nil
		end

		invalidateChildren(data, parent) -- equivalent call inferred; original call site unknown

		if parent then
			v[parent] = nil
		end

		local v4 = data.selectedPath:get()

		if v4 ~= nil and (v4 == data2.Path or pathUtil.isAncestorOf(data2.Path, v4)) then
			data.selectedPath:set(parent)
		end

		local v5 = data.currentPath:get()

		if v5 ~= nil and (v5 == data2.Path or pathUtil.isAncestorOf(data2.Path, v5)) then
			data.currentPath:set(parent)
		end

		Loader.refreshProgress(data, p, (ancestorsOf(data2.Path)))
	elseif data2.Type == "PermissionsChanged" then
		data.permissions:set(data2.Permissions)
	elseif data2.Type == "CompletionChanged" then
		local record = data2.Record

		if record == nil then
			local get_2 = data.completions:get()
			get_2[data2.Path] = nil
		else
			local get_3 = data.completions:get()
			get_3[data2.Path] = record
		end

		mergeProgress(data, data2.Progress) -- equivalent call inferred; original call site unknown
		data.stateLoaded:set(false)
		Loader.loadState(data, p)
	elseif data2.Type == "AssignmentChanged" then
		local v = data.assignments:get()
		local assignment = data2.Assignment

		for _, path in data2.Paths do
			if assignment == nil then
				v[path] = nil
			else
				v[path] = assignment
			end
		end

		if data.onlyMine:get() then
			table.clear(data.children:get())
			table.clear(data.progress:get())
		end
	elseif data2.Type == "StateReset" then
		Loader.refreshState(data, p)
	end
end

function Loader.openCreate(p, parent)
	local emptyEditor = Store.emptyEditor()
	emptyEditor.Mode = "Create"
	emptyEditor.Parent = parent
	p.editor:set(emptyEditor)
end

function Loader.defaultCommand(data)
	if data.Type == "SetLevel" then
		return (`/level {math.max(1, (math.round(data.Level)))}`)
	end

	if data.Type == "Item" then
		return (`/i2 {math.round(data.ItemId)}`)
	end

	if not (data.Type == "GoTo" and data.Text ~= "") then
		return nil
	end

	return (`/goto {data.Text}`)
end

function Loader:syncStepCommand()
	if not self.AutoCommand then
		return
	end

	local defaultCommand = Loader.defaultCommand(self)

	if defaultCommand == nil then
		self.AutoCommand = false
	else
		self.Command = defaultCommand
	end
end

function Loader.rowToStep(data)
	local success, result = pcall(function()
		local command

		if data.Command ~= "" then
			command = data.Command
		end

		local step = QATask.Builders.Step

		if data.Type == "SetLevel" then
			return step.SetLevel.new(math.round(data.Level), command)
		end

		if data.Type == "Item" then
			return step.Item.new(math.round(data.ItemId), command)
		end

		if data.Type == "GoTo" then
			return step.GoTo.new(data.Text, command)
		end

		if data.Type == "RunCommand" then
			return step.RunCommand.new(data.Text, data.Command)
		end

		return step.Custom.new(data.Text, command)
	end)

	if success then
		return result, nil
	end

	return nil, (tostring(result))
end

function Loader.rowToExpectation(data)
	local success, result = pcall(function()
		local expectation = QATask.Builders.Expectation

		if data.Type == "Never" then
			return expectation.Never.new(data.Behavior)
		end

		if data.Type == "Sometimes" then
			return expectation.Sometimes.new(data.Condition, data.Behavior)
		end

		return expectation.Always.new(data.Behavior)
	end)

	if success then
		return result, nil
	end

	return nil, (tostring(result))
end

function Loader.openEdit(p, data)
	local emptyEditor = Store.emptyEditor()
	emptyEditor.Mode = "Edit"
	emptyEditor.Path = data.Path
	emptyEditor.Parent = data.Parent
	emptyEditor.Key = data.Key
	emptyEditor.Title = data.Title
	emptyEditor.Description = data.Description or ""
	emptyEditor.IsGlobal = data.Scope == "Global"

	if data.Tags then
		for _, tag in data.Tags do
			emptyEditor.Tags[tag] = true
		end
	end

	if data.Steps then
		for _, step in data.Steps do
			local v = {
				Id = emptyEditor.NextRowId,
				Type = step.Type,
				Level = step.Type ~= "SetLevel" and 1 or step.Level,
				ItemId = step.Type ~= "Item" and 0 or step.ItemId,
				Text = step.Type ~= "GoTo" and step.Type ~= "RunCommand" and step.Type ~= "Custom" and "" or step.Text,
				Command = step.Command or "",
				AutoCommand = false
			}
			v.AutoCommand = Loader.defaultCommand(v) == v.Command
			emptyEditor.NextRowId += 1
			table.insert(emptyEditor.Steps, v)
		end
	end

	if data.Expectations then
		for _, expectation in data.Expectations do
			local v = {
				Id = emptyEditor.NextRowId,
				Type = expectation.Type,
				Condition = expectation.Type ~= "Sometimes" and "" or expectation.Condition,
				Behavior = expectation.Behavior
			}
			emptyEditor.NextRowId += 1
			table.insert(emptyEditor.Expectations, v)
		end
	end

	p.editor:set(emptyEditor)
end

function Loader.closeEditor(p)
	p.editor:set(nil)
end

function Loader:addStepRow(p)
	local v = {
		Id = self.NextRowId,
		Type = p,
		Level = 1,
		ItemId = 0,
		Text = "",
		Command = "",
		AutoCommand = p == "SetLevel" or p == "Item" or p == "GoTo"
	}
	Loader.syncStepCommand(v)
	table.insert(self.Steps, v)
	self.NextRowId += 1
end

function Loader:addExpectationRow(p)
	table.insert(self.Expectations, {
		Id = self.NextRowId,
		Type = p,
		Condition = "",
		Behavior = ""
	})
	self.NextRowId += 1
end

function Loader.formToDraft(data)
	local key

	if data.Key == "" then
		key = pathUtil.slugify(data.Title)
	else
		key = data.Key
	end

	if data.Title == "" then
		return nil, "a task needs a title"
	end

	local tags = {}

	for _, v2 in QATask.Types.TAGS do
		if data.Tags[v2] then
			table.insert(tags, v2)
		end
	end

	local rowToSteps = {}

	for k, step in data.Steps do
		Loader.syncStepCommand(step)
		local rowToStep, v2 = Loader.rowToStep(step)

		if rowToStep == nil then
			return nil, (`step #{k}: {v2}`)
		else
			table.insert(rowToSteps, rowToStep)
		end
	end

	local rowToExpectations = {}

	for k, expectation in data.Expectations do
		local rowToExpectation, v2 = Loader.rowToExpectation(expectation)

		if rowToExpectation == nil then
			return nil, (`expectation #{k}: {v2}`)
		else
			table.insert(rowToExpectations, rowToExpectation)
		end
	end

	local v2 = {
		Key = key,
		Parent = data.Parent,
		Title = data.Title,
		Description = 0,
		Tags = 0,
		Scope = 0,
		Icon = nil,
		Steps = 0,
		Expectations = 0
	}
	local description

	if data.Description ~= "" then
		description = data.Description
	end

	v2.Description = description

	if not (#tags > 0) then
		tags = nil
	end

	v2.Tags = tags
	v2.Scope = data.IsGlobal and "Global" or "Branch"

	if not (#rowToSteps > 0) then
		rowToSteps = nil
	end

	v2.Steps = rowToSteps

	if not (#rowToExpectations > 0) then
		rowToExpectations = nil
	end

	v2.Expectations = rowToExpectations
	local qATaskDraft, v4 = QATask.Types.QATaskDraft(v2)

	if qATaskDraft then
		return v2, nil
	end

	return nil, v4
end

function Loader.submitEditor(p, p2)
	local v = p.editor:get()

	if v == nil or v.IsSubmitting then
		return
	end

	local formToDraft, error = Loader.formToDraft(v)

	if formToDraft == nil then
		v.Error = error
		return
	end

	v.Error = nil
	v.IsSubmitting = true

	local function fn()
		local v3

		if v.Mode == "Edit" then
			v3 = v.Path ~= nil
		else
			v3 = false
		end

		local task2, v5

		if v3 then
			task2, v5 = p2.updateTask(v.Path, formToDraft)
		else
			task2, v5 = p2.createTask(formToDraft)
		end

		v.IsSubmitting = false

		if not task2 then
			v.Error = v5 or "unknown error"
			return
		end

		if v3 then
			Loader.applyChange(p, p2, {
				Type = "TaskUpdated",
				Task = task2
			})
		else
			Loader.applyChange(p, p2, {
				Type = "TaskCreated",
				Task = task2
			})
		end

		Store.setMessage(p, `saved "{task2.Title}"`, false)
		Loader.closeEditor(p)
		Loader.select(p, p2, task2.Path)
	end

	local v3 = p.pending:get()

	if v3.editor then
		return
	end

	v3.editor = true
	local v4 = "editor"
	task.spawn(function()
		local success, result = pcall(fn)
		v3[v4] = nil

		if not success then
			Store.setMessage(p, tostring(result), true)
		end
	end)
end

function Loader.deleteTask(p, p2, path)
	local function fn()
		local v, v2 = p2.deleteTask(path)

		if not v then
			Store.setMessage(p, v2 or "could not delete task", true)
			return
		end

		Loader.applyChange(p, p2, {
			Type = "TaskDeleted",
			Path = path
		})
		Store.setMessage(p, `deleted "{path}"`, false)
	end

	run(p, `delete:{path}`, fn) -- equivalent call inferred; original call site unknown
end

return Loader