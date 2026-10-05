local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(currentState, states)
	local self = setmetatable({}, StateMachine)
	self._currentState = currentState
	self._states = states
	local state = states[currentState]

	if state and state.Enter then
		task.spawn(function()
			state:Enter()
		end)
	end

	return self
end

function StateMachine:GetCurrentState()
	return self._currentState
end

function StateMachine:CanTransition(p2)
	local _state = self._states[self._currentState]

	if not (_state and _state.Transitions) then
		return false
	end

	for _, transition in _state.Transitions do
		if transition == p2 then
			return true
		end
	end

	return false
end

function StateMachine:ForceTransition(currentState)
	local _state = self._states[currentState]

	if not _state then
		warn((`StateMachine: Force transition failed. Invalid state: {tostring(currentState)}`))
		return false
	end

	local _state2 = self._states[self._currentState]

	if _state2 and _state2.Exit then
		_state2:Exit()
	end

	self._currentState = currentState

	if _state and _state.Enter then
		task.spawn(function()
			_state:Enter()
		end)
	end

	return true
end

function StateMachine:Transition(p)
	if self:CanTransition(p) then
		return self:ForceTransition(p)
	end

	warn((`StateMachine: Illegal transition attempt from {tostring(self._currentState)} to {tostring(p)}`))
	return false
end

function StateMachine:Update(p2: number)
	local _state = self._states[self._currentState]

	if not (_state and _state.Update) then
		return
	end

	_state:Update(p2)
end

return StateMachine