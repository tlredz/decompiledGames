local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local PathUtil = require(game.ReplicatedStorage.Definitions.QATask.PathUtil)
local StepBuilder = require(game.ReplicatedStorage.Definitions.QATask.Builders.StepBuilder)
local ExpectationBuilder = require(game.ReplicatedStorage.Definitions.QATask.Builders.ExpectationBuilder)
local Types = require(game.ReplicatedStorage.Definitions.QATask.Types)

local function copy(data)
	local v = {
		_Current = {
			Key = data._Current.Key,
			Parent = data._Current.Parent,
			Children = table.clone(data._Current.Children),
			Tags = table.clone(data._Current.Tags),
			Source = data._Current.Source,
			Scope = data._Current.Scope,
			Icon = data._Current.Icon,
			Title = data._Current.Title,
			Description = data._Current.Description,
			Steps = table.clone(data._Current.Steps),
			Expectations = table.clone(data._Current.Expectations)
		},
		setKey = data.setKey,
		setParent = data.setParent,
		setSource = data.setSource,
		setScope = data.setScope,
		setTitle = data.setTitle,
		setDescription = data.setDescription,
		setIcon = data.setIcon,
		insertTag = data.insertTag,
		insertChild = data.insertChild,
		insertStep = data.insertStep,
		insertExpectation = data.insertExpectation,
		getPath = data.getPath,
		build = data.build
	}
	table.freeze(v)
	return v
end

local TaskBuilder = {
	Step = StepBuilder,
	Expectation = ExpectationBuilder,
	Builder = {}
}

function TaskBuilder.Builder.new(p, parent2)
	local qATaskKey, v = Types.QATaskKey(p)
	assert(qATaskKey, (`expected a task key, received an invalid value: {v}`))

	if parent2 ~= nil then
		local qATaskPath, v2 = Types.QATaskPath(parent2)
		assert(qATaskPath, (`expected a parent path, received an invalid value: {v2}`))
	end

	return {
		_Current = {
			Key = p,
			Parent = parent2,
			Children = {},
			Tags = {},
			Source = "Static",
			Steps = {},
			Expectations = {}
		},
		setKey = function(p3, p4)
			local qATaskKey2, v2 = Types.QATaskKey(p4)
			assert(qATaskKey2, (`expected a task key, received an invalid value: {v2}`))
			local v3 = copy(p3)
			v3._Current.Key = p4
			TableUtil.deepFreeze(v3)
			return v3
		end,
		setParent = function(p3, parent)
			if parent ~= nil then
				local qATaskPath, v2 = Types.QATaskPath(parent)
				assert(qATaskPath, (`expected a parent path, received an invalid value: {v2}`))
			end

			local v2 = copy(p3)
			v2._Current.Parent = parent
			TableUtil.deepFreeze(v2)
			return v2
		end,
		setSource = function(self, source)
			local qATaskSource, v2 = Types.QATaskSource(source)
			assert(qATaskSource, (`expected a task source, received an invalid value: {v2}`))
			local v3 = copy(self)
			v3._Current.Source = source
			TableUtil.deepFreeze(v3)
			return v3
		end,
		setScope = function(self, scope)
			if scope ~= nil then
				local qATaskScope, v2 = Types.QATaskScope(scope)
				assert(qATaskScope, (`expected a task scope, received an invalid value: {v2}`))
			end

			local v2 = copy(self)
			v2._Current.Scope = scope
			TableUtil.deepFreeze(v2)
			return v2
		end,
		setTitle = function(self, title: string)
			assert(title ~= "", (`task "{self._Current.Key}" needs a non-empty title`))
			local v2 = copy(self)
			v2._Current.Title = title
			TableUtil.deepFreeze(v2)
			return v2
		end,
		setDescription = function(self, description: string?)
			local v2 = copy(self)
			local _Current = v2._Current

			if description == "" then
				description = nil
			end

			_Current.Description = description
			TableUtil.deepFreeze(v2)
			return v2
		end,
		setIcon = function(self, icon)
			if icon ~= nil then
				local sprite, v2 = TypeUtil.Types.Sprite(icon)
				assert(sprite, (`expected a sprite, received an invalid value: {v2}`))
			end

			local v2 = copy(self)
			v2._Current.Icon = icon
			TableUtil.deepFreeze(v2)
			return v2
		end,
		insertTag = function(self, p4)
			local v2, v3 = Types.Tag(p4)
			assert(v2, (`expected a task tag, received an invalid value: {v3}`))
			local v4 = copy(self)

			for _, tag in v4._Current.Tags do
				assert(tag ~= p4, (`task "{v4._Current.Key}" already has the "{p4}" tag assigned`))
			end

			table.insert(v4._Current.Tags, p4)
			TableUtil.deepFreeze(v4)
			return v4
		end,
		insertChild = function(self, p4)
			local qATaskKey2, v2 = Types.QATaskKey(p4)
			assert(qATaskKey2, (`expected a child key, received an invalid value: {v2}`))
			local v3 = copy(self)

			for _, v4 in v3._Current.Children do
				assert(v4 ~= p4, (`task "{v3._Current.Key}" already has a child at key "{p4}"`))
			end

			table.insert(v3._Current.Children, p4)
			TableUtil.deepFreeze(v3)
			return v3
		end,
		insertStep = function(self, p4)
			local v2, v3 = Types.Step(p4)
			assert(v2, (`expected a built step, received an invalid value: {v3}`))
			local v4 = copy(self)
			table.insert(v4._Current.Steps, p4)
			TableUtil.deepFreeze(v4)
			return v4
		end,
		insertExpectation = function(self, p4)
			local expectation, v2 = Types.Expectation(p4)
			assert(expectation, (`expected a built expectation, received an invalid value: {v2}`))
			local v3 = copy(self)
			table.insert(v3._Current.Expectations, p4)
			TableUtil.deepFreeze(v3)
			return v3
		end,
		getPath = function(p3)
			return PathUtil.join(p3._Current.Parent, p3._Current.Key)
		end,
		build = function(p3)
			local _Current = p3._Current
			local key = _Current.Key
			local title = _Current.Title
			assert(title ~= nil, (`need to assign a title to task "{key}" before build`))
			local joined = PathUtil.join(_Current.Parent, key)
			local v2 = {
				Key = key,
				Path = joined,
				Parent = _Current.Parent,
				Children = 0,
				Tags = 0,
				Source = 0,
				Scope = 0,
				Icon = 0,
				Title = 0,
				Description = 0,
				Steps = 0,
				Expectations = 0
			}
			local children

			if #_Current.Children > 0 then
				children = table.clone(_Current.Children)
			end

			v2.Children = children
			local tags

			if #_Current.Tags > 0 then
				tags = table.clone(_Current.Tags)
			end

			v2.Tags = tags
			v2.Source = _Current.Source
			v2.Scope = _Current.Scope
			v2.Icon = _Current.Icon
			v2.Title = title
			v2.Description = _Current.Description
			local steps

			if #_Current.Steps > 0 then
				steps = table.clone(_Current.Steps)
			end

			v2.Steps = steps
			local expectations

			if #_Current.Expectations > 0 then
				expectations = table.clone(_Current.Expectations)
			end

			v2.Expectations = expectations
			setmetatable(v2, {
				__tostring = function(...)
					return (`QATaskDef({joined})`)
				end
			})
			TableUtil.deepFreeze(v2)
			local qATask, v7 = Types.QATask(v2)
			assert(qATask, (`task "{joined}" built into an invalid definition: {v7}`))
			return v2
		end
	}
end

function TaskBuilder.Builder.fromDefinition(data)
	local v = TaskBuilder.Builder.new(data.Key, data.Parent):setTitle(data.Title)

	if data.Source then
		v = v:setSource(data.Source)
	end

	if data.Scope then
		v = v:setScope(data.Scope)
	end

	if data.Description then
		v = v:setDescription(data.Description)
	end

	if data.Icon then
		v = v:setIcon(data.Icon)
	end

	if data.Tags then
		for _, tag in data.Tags do
			v = v:insertTag(tag)
		end
	end

	if data.Children then
		for _, v2 in data.Children do
			v = v:insertChild(v2)
		end
	end

	if data.Steps then
		for _, step in data.Steps do
			v = v:insertStep(StepBuilder.fromDefinition(step))
		end
	end

	if data.Expectations then
		for _, expectation in data.Expectations do
			v = v:insertExpectation(ExpectationBuilder.fromDefinition(expectation))
		end
	end

	return v
end

function TaskBuilder.Builder.fromDraft(data, p)
	local qATaskDraft, v = Types.QATaskDraft(data)
	assert(qATaskDraft, (`expected a task draft, received an invalid value: {v}`))
	local v2 = TaskBuilder.Builder.new(data.Key, data.Parent):setTitle(data.Title):setSource(p)

	if data.Scope then
		v2 = v2:setScope(data.Scope)
	end

	if data.Description then
		v2 = v2:setDescription(data.Description)
	end

	if data.Icon then
		v2 = v2:setIcon(data.Icon)
	end

	if data.Tags then
		for _, tag in data.Tags do
			v2 = v2:insertTag(tag)
		end
	end

	if data.Steps then
		for _, step in data.Steps do
			v2 = v2:insertStep(StepBuilder.fromDefinition(step))
		end
	end

	if data.Expectations then
		for _, expectation in data.Expectations do
			v2 = v2:insertExpectation(ExpectationBuilder.fromDefinition(expectation))
		end
	end

	return v2
end

function TaskBuilder.toDraft(data)
	local v = {
		Key = data.Key,
		Parent = data.Parent,
		Tags = 0,
		Scope = 0,
		Icon = 0,
		Title = 0,
		Description = 0,
		Steps = 0,
		Expectations = 0
	}
	local tags

	if data.Tags then
		tags = table.clone(data.Tags)
	end

	v.Tags = tags
	v.Scope = data.Scope
	v.Icon = data.Icon
	v.Title = data.Title
	v.Description = data.Description
	local steps

	if data.Steps then
		steps = table.clone(data.Steps)
	end

	v.Steps = steps
	local expectations

	if data.Expectations then
		expectations = table.clone(data.Expectations)
	end

	v.Expectations = expectations
	return v
end

return TaskBuilder