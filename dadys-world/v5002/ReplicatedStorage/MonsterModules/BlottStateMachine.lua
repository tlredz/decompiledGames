local BlottStateMachine = {}
local BlottConfig = require(script.Parent.BlottConfig)
local v = {}
local EMERGING = BlottConfig.HANDS.STATES.EMERGING
v[EMERGING] = {
	[BlottConfig.HANDS.STATES.IDLE] = true,
	[BlottConfig.HANDS.STATES.RETURNING] = true
}
local IDLE = BlottConfig.HANDS.STATES.IDLE
v[IDLE] = {
	[BlottConfig.HANDS.STATES.ATTACKING] = true,
	[BlottConfig.HANDS.STATES.RETURNING] = true,
	[BlottConfig.HANDS.STATES.SEARCHING] = true
}
local ATTACKING = BlottConfig.HANDS.STATES.ATTACKING
v[ATTACKING] = {
	[BlottConfig.HANDS.STATES.COOLDOWN] = true,
	[BlottConfig.HANDS.STATES.RETURNING] = true
}
local COOLDOWN = BlottConfig.HANDS.STATES.COOLDOWN
v[COOLDOWN] = {
	[BlottConfig.HANDS.STATES.IDLE] = true,
	[BlottConfig.HANDS.STATES.RETURNING] = true
}
local SEARCHING = BlottConfig.HANDS.STATES.SEARCHING
v[SEARCHING] = {
	[BlottConfig.HANDS.STATES.IDLE] = true,
	[BlottConfig.HANDS.STATES.ATTACKING] = true,
	[BlottConfig.HANDS.STATES.RETURNING] = true
}
v[BlottConfig.HANDS.STATES.RETURNING] = {}
local v7 = {}

function BlottStateMachine.InitializeHand(p, character)
	v7[p] = {
		currentState = BlottConfig.HANDS.STATES.EMERGING,
		previousState = nil,
		stateStartTime = tick(),
		character = character,
		data = {}
	}
	return v7[p]
end

function BlottStateMachine.TransitionState(p, currentState, options)
	local v8 = v7[p]

	if not v8 then
		warn("BlottStateMachine: No data for hand", p)
		return false
	end

	local currentState2 = v8.currentState

	if not (v[currentState2] and v[currentState2][currentState]) then
		warn("BlottStateMachine: Invalid transition from", currentState2, "to", currentState)
		return false
	end

	v8.previousState = currentState2
	v8.currentState = currentState
	v8.stateStartTime = tick()
	v8.data = options or {}
	print("BlottStateMachine: Hand", p, "transitioned from", currentState2, "to", currentState)
	return true
end

function BlottStateMachine.GetState(p)
	local v8 = v7[p]

	if v8 then
		return v8.currentState, v8.stateStartTime, v8.data
	end

	return nil
end

function BlottStateMachine.CanTransition(p, value)
	local v8 = v7[p]
	return not not v8 and (value or 0) <= tick() - v8.stateStartTime
end

function BlottStateMachine.GetValidTransitions(p)
	local v8 = v7[p]

	if not v8 then
		return {}
	end

	local v9 = v[v8.currentState] or {}
	local result = {}

	for k, _ in pairs(v9) do
		table.insert(result, k)
	end

	return result
end

function BlottStateMachine.UpdateStateData(p, items)
	local v8 = v7[p]

	if not v8 then
		return false
	end

	for k, item in pairs(items) do
		v8.data[k] = item
	end

	return true
end

function BlottStateMachine.CleanupHand(p)
	v7[p] = nil
	print("BlottStateMachine: Cleaned up data for hand", p)
end

function BlottStateMachine.GetActiveHands()
	local result = {}

	for k, v8 in pairs(v7) do
		table.insert(result, {
			id = k,
			state = v8.currentState,
			timeInState = tick() - v8.stateStartTime
		})
	end

	return result
end

function BlottStateMachine.EmergencyReturnAll(p)
	local count = 0

	for k, v8 in pairs(v7) do
		if not (v8.character == p and BlottStateMachine.TransitionState(k, BlottConfig.HANDS.STATES.RETURNING)) then
			continue
		end

		count += 1
	end

	print("BlottStateMachine: Emergency return for", count, "hands")
	return count
end

function BlottStateMachine.CleanupCharacter(p)
	local count = 0

	for k, v8 in pairs(v7) do
		if v8.character ~= p then
			continue
		end

		v7[k] = nil
		count += 1
	end

	print("BlottStateMachine: Cleaned up", count, "hands for character")
	return count
end

return BlottStateMachine