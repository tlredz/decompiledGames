local Type = require(game.ReplicatedStorage.Packages.Type)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local Types = {
	StepType = Type.literal("SetLevel", "Item", "GoTo", "RunCommand", "Custom"),
	STEP_TYPES = table.freeze({
		"SetLevel",
		"Item",
		"GoTo",
		"RunCommand",
		"Custom"
	}),
	Step = TypeUtil.Types.BetterUnion({
		SetLevel = Type.strictInterface({
			Type = Type.literal("SetLevel"),
			Level = Type.integer,
			Command = Type.optional(Type.string)
		}),
		Item = Type.strictInterface({
			Type = Type.literal("Item"),
			ItemId = Type.integer,
			Command = Type.optional(Type.string)
		}),
		GoTo = Type.strictInterface({
			Type = Type.literal("GoTo"),
			Text = Type.string,
			Command = Type.optional(Type.string)
		}),
		RunCommand = Type.strictInterface({
			Type = Type.literal("RunCommand"),
			Text = Type.string,
			Command = Type.string
		}),
		Custom = Type.strictInterface({
			Type = Type.literal("Custom"),
			Text = Type.string,
			Command = Type.optional(Type.string)
		})
	}),
	ExpectationType = Type.literal("Never", "Always", "Sometimes"),
	EXPECTATION_TYPES = table.freeze({ "Never", "Always", "Sometimes" }),
	Expectation = TypeUtil.Types.BetterUnion({
		Never = Type.strictInterface({
			Type = Type.literal("Never"),
			Behavior = Type.string
		}),
		Always = Type.strictInterface({
			Type = Type.literal("Always"),
			Behavior = Type.string
		}),
		Sometimes = Type.strictInterface({
			Type = Type.literal("Sometimes"),
			Condition = Type.string,
			Behavior = Type.string
		})
	}),
	TAGS = table.freeze({
		"REACT",
		"LIVE_OPS",
		"BOOT",
		"STREAMING",
		"NPC",
		"ECONOMY",
		"PLATFORM/MOBILE",
		"PLATFORM/CONSOLE",
		"MAPS/SEA_1",
		"MAPS/SEA_2",
		"MAPS/SEA_3",
		"CHESTS"
	}),
	Tag = Type.literal(
		"REACT",
		"LIVE_OPS",
		"BOOT",
		"STREAMING",
		"NPC",
		"ECONOMY",
		"PLATFORM/MOBILE",
		"PLATFORM/CONSOLE",
		"MAPS/SEA_1",
		"MAPS/SEA_2",
		"MAPS/SEA_3",
		"CHESTS"
	),
	QATaskKey = function(value)
		if type(value) ~= "string" then
			return false, (`expected a string key, received "{typeof(value)}"`)
		end

		if value == "" then
			return false, "key cannot be empty"
		end

		if value:find("/") then
			return false, (`key "{value}" cannot contain "/"`)
		end

		if value:match("^[%w%-_%.]+$") == nil then
			return false, (`key "{value}" may only contain letters, numbers, "-", "_" and "."`)
		end

		return true, nil
	end,
	QATaskPath = function(value)
		if type(value) ~= "string" then
			return false, (`expected a string path, received "{typeof(value)}"`)
		end

		if value:sub(1, 1) ~= "/" then
			return false, (`path "{value}" must start with "/"`)
		end

		if value:len() > 1 and value:sub(-1) == "/" then
			return false, (`path "{value}" cannot end with "/"`)
		end

		if value:find("//", 1, true) then
			return false, (`path "{value}" cannot contain empty segments`)
		end

		return true, nil
	end,
	QATaskSource = Type.literal("Static", "Registered", "Custom"),
	QATaskScope = Type.literal("Branch", "Global")
}
Types.QATask = Type.strictInterface({
	Key = Types.QATaskKey,
	Path = Types.QATaskPath,
	Parent = Type.optional(Types.QATaskPath),
	Children = Type.optional(Type.array(Types.QATaskKey)),
	Tags = Type.optional(Type.array(Types.Tag)),
	Source = Type.optional(Types.QATaskSource),
	Scope = Type.optional(Types.QATaskScope),
	Icon = Type.optional(TypeUtil.Types.Sprite),
	Title = Type.string,
	Description = Type.optional(Type.string),
	Steps = Type.optional(Type.array(Types.Step)),
	Expectations = Type.optional(Type.array(Types.Expectation))
})
Types.QATaskDraft = Type.strictInterface({
	Key = Types.QATaskKey,
	Parent = Type.optional(Types.QATaskPath),
	Tags = Type.optional(Type.array(Types.Tag)),
	Scope = Type.optional(Types.QATaskScope),
	Icon = Type.optional(TypeUtil.Types.Sprite),
	Title = Type.string,
	Description = Type.optional(Type.string),
	Steps = Type.optional(Type.array(Types.Step)),
	Expectations = Type.optional(Type.array(Types.Expectation))
})
Types.QARank = Type.literal("QAAdmin", "QATester")
Types.RANKS = table.freeze({ "QATester", "QAAdmin" })
Types.Permissions = Type.strictInterface({
	Rank = Type.optional(Types.QARank),
	CanRead = Type.boolean,
	CanComplete = Type.boolean,
	CanWrite = Type.boolean
})
Types.CompletionRecord = Type.strictInterface({
	Sha = Type.string,
	UserId = Type.integer,
	UserName = Type.string,
	Timestamp = Type.number
})
Types.CompletionMap = Type.map(Types.QATaskPath, Types.CompletionRecord)
Types.AssignmentRecord = Type.strictInterface({
	UserId = Type.integer,
	UserName = Type.string,
	AssignedBy = Type.integer,
	Timestamp = Type.number
})
Types.AssignmentMap = Type.map(Types.QATaskPath, Types.AssignmentRecord)
Types.Progress = Type.strictInterface({
	Done = Type.integer,
	Total = Type.integer
})
Types.ProgressMap = Type.map(Types.QATaskPath, Types.Progress)
Types.BuildStamp = Type.strictInterface({
	Branch = Type.string,
	Sha = Type.string
})
Types.ShaSummary = Type.strictInterface({
	Sha = Type.string,
	Count = Type.integer,
	EarliestTimestamp = Type.number,
	LatestTimestamp = Type.number
})
Types.TesterInfo = Type.strictInterface({
	UserId = Type.integer,
	Name = Type.string,
	Rank = Types.QARank
})
Types.Filter = Type.strictInterface({
	Tag = Type.optional(Types.Tag),
	Text = Type.optional(Type.string),
	AssignedTo = Type.optional(Type.integer)
})
Types.ServerRequest = TypeUtil.Types.BetterUnion({
	GetPermissions = Type.strictInterface({
		Type = Type.literal("GetPermissions")
	}),
	GetTaskTreeRoots = Type.strictInterface({
		Type = Type.literal("GetTaskTreeRoots"),
		Filter = Type.optional(Types.Filter)
	}),
	GetTask = Type.strictInterface({
		Type = Type.literal("GetTask"),
		Path = Types.QATaskPath,
		Filter = Type.optional(Types.Filter)
	}),
	GetParentTask = Type.strictInterface({
		Type = Type.literal("GetParentTask"),
		Path = Types.QATaskPath,
		Filter = Type.optional(Types.Filter)
	}),
	GetChildrenTasks = Type.strictInterface({
		Type = Type.literal("GetChildrenTasks"),
		Path = Types.QATaskPath,
		Filter = Type.optional(Types.Filter)
	}),
	GetState = Type.strictInterface({
		Type = Type.literal("GetState")
	}),
	GetProgress = Type.strictInterface({
		Type = Type.literal("GetProgress"),
		Paths = Type.array(Types.QATaskPath),
		Filter = Type.optional(Types.Filter)
	}),
	SetTaskCompletion = Type.strictInterface({
		Type = Type.literal("SetTaskCompletion"),
		Path = Types.QATaskPath,
		IsCompleted = Type.boolean,
		Filter = Type.optional(Types.Filter)
	}),
	CreateTask = Type.strictInterface({
		Type = Type.literal("CreateTask"),
		Draft = Types.QATaskDraft
	}),
	UpdateTask = Type.strictInterface({
		Type = Type.literal("UpdateTask"),
		Path = Types.QATaskPath,
		Draft = Types.QATaskDraft
	}),
	DeleteTask = Type.strictInterface({
		Type = Type.literal("DeleteTask"),
		Path = Types.QATaskPath
	}),
	ResetAll = Type.strictInterface({
		Type = Type.literal("ResetAll"),
		Filter = Type.optional(Types.Filter)
	}),
	ResetSubtree = Type.strictInterface({
		Type = Type.literal("ResetSubtree"),
		Path = Types.QATaskPath,
		Filter = Type.optional(Types.Filter)
	}),
	ResetSha = Type.strictInterface({
		Type = Type.literal("ResetSha"),
		Sha = Type.string,
		Filter = Type.optional(Types.Filter)
	}),
	GetShaSummary = Type.strictInterface({
		Type = Type.literal("GetShaSummary"),
		Filter = Type.optional(Types.Filter)
	}),
	AssignTask = Type.strictInterface({
		Type = Type.literal("AssignTask"),
		Path = Types.QATaskPath,
		UserId = Type.optional(Type.integer),
		Filter = Type.optional(Types.Filter)
	}),
	GetTesters = Type.strictInterface({
		Type = Type.literal("GetTesters")
	})
})
Types.ServerResponse = TypeUtil.Types.BetterUnion({
	GetPermissions = Type.strictInterface({
		Type = Type.literal("GetPermissions"),
		Permissions = Types.Permissions
	}),
	GetTaskTreeRoots = Type.strictInterface({
		Type = Type.literal("GetTaskTreeRoots"),
		Roots = Type.array(Types.QATask),
		Progress = Types.ProgressMap
	}),
	GetTask = Type.strictInterface({
		Type = Type.literal("GetTask"),
		Task = Type.optional(Types.QATask),
		Progress = Types.ProgressMap
	}),
	GetParentTask = Type.strictInterface({
		Type = Type.literal("GetParentTask"),
		Task = Type.optional(Types.QATask),
		Progress = Types.ProgressMap
	}),
	GetChildrenTasks = Type.strictInterface({
		Type = Type.literal("GetChildrenTasks"),
		Tasks = Type.array(Types.QATask),
		Progress = Types.ProgressMap
	}),
	GetState = Type.strictInterface({
		Type = Type.literal("GetState"),
		Build = Types.BuildStamp,
		Completions = Types.CompletionMap,
		Assignments = Types.AssignmentMap
	}),
	GetProgress = Type.strictInterface({
		Type = Type.literal("GetProgress"),
		Progress = Types.ProgressMap
	}),
	SetTaskCompletion = Type.strictInterface({
		Type = Type.literal("SetTaskCompletion"),
		DidChange = Type.boolean,
		Current = Type.boolean,
		Record = Type.optional(Types.CompletionRecord),
		Progress = Types.ProgressMap
	}),
	CreateTask = Type.strictInterface({
		Type = Type.literal("CreateTask"),
		Task = Type.optional(Types.QATask),
		Error = Type.optional(Type.string)
	}),
	UpdateTask = Type.strictInterface({
		Type = Type.literal("UpdateTask"),
		Task = Type.optional(Types.QATask),
		Error = Type.optional(Type.string)
	}),
	DeleteTask = Type.strictInterface({
		Type = Type.literal("DeleteTask"),
		DidDelete = Type.boolean,
		Error = Type.optional(Type.string)
	}),
	ResetAll = Type.strictInterface({
		Type = Type.literal("ResetAll"),
		Count = Type.integer
	}),
	ResetSubtree = Type.strictInterface({
		Type = Type.literal("ResetSubtree"),
		Count = Type.integer
	}),
	ResetSha = Type.strictInterface({
		Type = Type.literal("ResetSha"),
		Count = Type.integer
	}),
	GetShaSummary = Type.strictInterface({
		Type = Type.literal("GetShaSummary"),
		Entries = Type.array(Types.ShaSummary)
	}),
	AssignTask = Type.strictInterface({
		Type = Type.literal("AssignTask"),
		Count = Type.integer,
		Error = Type.optional(Type.string)
	}),
	GetTesters = Type.strictInterface({
		Type = Type.literal("GetTesters"),
		Testers = Type.array(Types.TesterInfo)
	}),
	Denied = Type.strictInterface({
		Type = Type.literal("Denied"),
		Error = Type.string
	})
})
Types.ChangeEvent = TypeUtil.Types.BetterUnion({
	TaskCreated = Type.strictInterface({
		Type = Type.literal("TaskCreated"),
		Task = Types.QATask
	}),
	TaskUpdated = Type.strictInterface({
		Type = Type.literal("TaskUpdated"),
		Task = Types.QATask
	}),
	TaskDeleted = Type.strictInterface({
		Type = Type.literal("TaskDeleted"),
		Path = Types.QATaskPath
	}),
	PermissionsChanged = Type.strictInterface({
		Type = Type.literal("PermissionsChanged"),
		Permissions = Types.Permissions
	}),
	OpenMenu = Type.strictInterface({
		Type = Type.literal("OpenMenu")
	}),
	CompletionChanged = Type.strictInterface({
		Type = Type.literal("CompletionChanged"),
		Path = Types.QATaskPath,
		Record = Type.optional(Types.CompletionRecord),
		Progress = Types.ProgressMap
	}),
	AssignmentChanged = Type.strictInterface({
		Type = Type.literal("AssignmentChanged"),
		Paths = Type.array(Types.QATaskPath),
		Assignment = Type.optional(Types.AssignmentRecord)
	}),
	StateReset = Type.strictInterface({
		Type = Type.literal("StateReset")
	})
})

function Types.SourceNode(data)
	if type(data) ~= "table" then
		return false, (`expected a table, received "{typeof(data)}"`)
	end

	if type(data.title) ~= "string" then
		return false, (`expected a string "title", received "{typeof(data.title)}"`)
	end

	if data.id ~= nil and type(data.id) ~= "string" then
		return false, (`expected a string "id", received "{typeof(data.id)}"`)
	end

	if data.description ~= nil and type(data.description) ~= "string" then
		return false, (`expected a string "description", received "{typeof(data.description)}"`)
	end

	if data.tags ~= nil then
		local v, v2 = Type.array(Type.string)(data.tags)

		if not v then
			return false, (`bad "tags": {v2}`)
		end
	end

	if data.subtasks == nil then
		return true, nil
	end

	if type(data.subtasks) ~= "table" then
		return false, (`expected a table "subtasks", received "{typeof(data.subtasks)}"`)
	end

	for k, subtask in data.subtasks do
		local sourceNode, v = Types.SourceNode(subtask)

		if not sourceNode then
			return false, (`bad subtask #{k}: {v}`)
		end
	end

	return true, nil
end

return Types