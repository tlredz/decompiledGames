local Types = require(game.ReplicatedStorage.Definitions.QATask.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function finish(list)
	table.freeze(list)
	local v, v2 = Types.Step(list)
	assert(v, (`step built into an invalid value: {v2}`))
	return list
end

-- equivalent calls inferred from this helper; original call sites unknown
local function assertOptionalCommand(p: string?)
	assert(p == nil or p ~= "", "command must be nil or a non-empty string")
end

local StepBuilder = {
	SetLevel = {
		new = function(level: number, command: string?)
			assert(level > 0, (`level must be above 0, received {level}`))
			assert(level == math.round(level), (`level must be a whole number, received {level}`))
			assertOptionalCommand(command) -- equivalent call inferred; original call site unknown
			return finish({
				Type = "SetLevel",
				Level = level,
				Command = command
			})
		end
	},
	Item = {
		new = function(itemId: number, command: string?)
			assert(itemId == math.round(itemId), (`itemId must be a whole number, received {itemId}`))
			assertOptionalCommand(command) -- equivalent call inferred; original call site unknown
			return finish({
				Type = "Item",
				ItemId = itemId,
				Command = command
			})
		end
	},
	GoTo = {
		new = function(text: string, command: string?)
			assert(text ~= "", "go-to step needs a non-empty text")
			assertOptionalCommand(command) -- equivalent call inferred; original call site unknown
			return finish({
				Type = "GoTo",
				Text = text,
				Command = command
			})
		end
	},
	RunCommand = {
		new = function(text: string, command: string)
			assert(text ~= "", "run-command step needs a non-empty text")
			assert(command ~= "", "run-command step needs a non-empty command")
			return finish({
				Type = "RunCommand",
				Text = text,
				Command = command
			})
		end
	},
	Custom = {
		new = function(text: string, command: string?)
			assert(text ~= "", "custom step needs a non-empty text")
			assertOptionalCommand(command) -- equivalent call inferred; original call site unknown
			return finish({
				Type = "Custom",
				Text = text,
				Command = command
			})
		end
	}
}

function StepBuilder.fromDefinition(data)
	if data.Type == "SetLevel" then
		return StepBuilder.SetLevel.new(data.Level, data.Command)
	end

	if data.Type == "Item" then
		return StepBuilder.Item.new(data.ItemId, data.Command)
	end

	if data.Type == "GoTo" then
		return StepBuilder.GoTo.new(data.Text, data.Command)
	end

	if data.Type == "RunCommand" then
		return StepBuilder.RunCommand.new(data.Text, data.Command)
	end

	if data.Type == "Custom" then
		return StepBuilder.Custom.new(data.Text, data.Command)
	end

	error((`unknown step type "{data.Type}"`))
end

function StepBuilder.getLabel(data)
	if data.Type == "SetLevel" then
		return (`Set level to {data.Level}`)
	end

	if data.Type == "Item" then
		return (`Obtain item #{data.ItemId}`)
	end

	if data.Type == "GoTo" then
		return (`Go to {data.Text}`)
	end

	if not (data.Type ~= "RunCommand" and data.Type ~= "Custom") then
		return data.Text
	end

	error((`unknown step type "{data.Type}"`))
end

return StepBuilder