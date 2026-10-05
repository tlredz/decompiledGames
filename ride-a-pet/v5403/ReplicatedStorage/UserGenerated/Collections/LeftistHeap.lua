function _merge1(callback, state, left)
	if not state.Left then
		state.Left = left
		return state
	end

	state.Right = _merge(callback, state.Right, left)

	if state.Left.Npl < state.Right.Npl then
		local right = state.Right
		local left2 = state.Left
		state.Left = right
		state.Right = left2
	end

	state.Npl = state.Right.Npl + 1
	return state
end

function _merge(callback, p, p2)
	if not p then
		return p2
	end

	if not p2 then
		return p
	end

	if callback(p.Value, p2.Value) < 0 then
		return _merge1(callback, p, p2)
	end

	return _merge1(callback, p2, p)
end

local v = {}
local frozen = table.freeze({
	__index = v
})

function v:Merge(p)
	if self.Root ~= p.Root then
		self.Root = _merge(self.Comparator, self.Root, p.Root)
		p.Root = nil
	end
end

function v:Insert(p)
	self.Root = _merge(self.Comparator, {
		Value = p,
		Npl = 0
	}, self.Root)
end

function v.Min(p)
	assert(p.Root)
	return p.Root.Value
end

function v.TryMin(p)
	if p.Root then
		return true, p.Root.Value
	end

	return false, nil
end

function v:Pop()
	assert(self.Root)
	local value = self.Root.Value
	self.Root = _merge(self.Comparator, self.Root.Left, self.Root.Right)
	return value
end

function v:TryPop()
	if not self.Root then
		return false, nil
	end

	local value = self.Root.Value
	self.Root = _merge(self.Comparator, self.Root.Left, self.Root.Right)
	return true, value
end

function v:PopFast()
	self.Root = _merge(self.Comparator, self.Root.Left, self.Root.Right)
end

function v.Empty(p)
	return p.Root == nil
end

function v:Clear()
	self.Root = nil
end

table.freeze(v)
return table.freeze({
	Compare = function(p, p2)
		if p < p2 then
			return -1
		end

		if p2 < p then
			return 1
		end

		return 0
	end,
	new = function(comparator, _)
		assert(type(comparator) == "function")
		return (setmetatable({
			Comparator = comparator
		}, frozen))
	end
})