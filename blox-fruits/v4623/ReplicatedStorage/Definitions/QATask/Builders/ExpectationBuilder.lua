local Types = require(game.ReplicatedStorage.Definitions.QATask.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function finish(list)
	table.freeze(list)
	local expectation, v = Types.Expectation(list)
	assert(expectation, (`expectation built into an invalid value: {v}`))
	return list
end

local ExpectationBuilder = {
	Never = {
		new = function(behavior: string)
			assert(behavior ~= "", "expectation needs a non-empty behavior")
			return finish({
				Type = "Never",
				Behavior = behavior
			})
		end
	},
	Always = {
		new = function(behavior: string)
			assert(behavior ~= "", "expectation needs a non-empty behavior")
			return finish({
				Type = "Always",
				Behavior = behavior
			})
		end
	},
	Sometimes = {
		new = function(condition: string, behavior: string)
			assert(condition ~= "", "expectation needs a non-empty condition")
			assert(behavior ~= "", "expectation needs a non-empty behavior")
			return finish({
				Type = "Sometimes",
				Condition = condition,
				Behavior = behavior
			})
		end
	}
}

function ExpectationBuilder.fromDefinition(data)
	if data.Type == "Never" then
		return ExpectationBuilder.Never.new(data.Behavior)
	end

	if data.Type == "Always" then
		return ExpectationBuilder.Always.new(data.Behavior)
	end

	if data.Type == "Sometimes" then
		return ExpectationBuilder.Sometimes.new(data.Condition, data.Behavior)
	end

	error((`unknown expectation type "{data.Type}"`))
end

function ExpectationBuilder.getLabel(data)
	if data.Type == "Never" then
		return (`Never: {data.Behavior}`)
	end

	if data.Type == "Always" then
		return (`Always: {data.Behavior}`)
	end

	if data.Type == "Sometimes" then
		return (`When {data.Condition}: {data.Behavior}`)
	end

	error((`unknown expectation type "{data.Type}"`))
end

return ExpectationBuilder