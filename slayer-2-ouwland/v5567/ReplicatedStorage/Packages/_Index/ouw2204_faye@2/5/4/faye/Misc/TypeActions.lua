local insert = table.insert
local find = table.find
local remove = table.remove

-- equivalent calls inferred from this helper; original call sites unknown
local function getIndex(value, p)
	for k, item in pairs(value) do
		if p == item then
			return k
		end
	end

	return nil
end

local v = {
	Add = function(state, p)
		state.Value += p
		state.Changed:Fire(state.Value)
		return state
	end,
	Remove = function(state, p)
		state.Value -= p
		state.Changed:Fire(state.Value)
		return state
	end
}
return {
	number = {
		Add = function(state, p)
			state.Value += p
			state.Changed:Fire(state.Value, p, nil, 1)
			return state
		end,
		Remove = function(state, p)
			state.Value -= p
			state.Changed:Fire(state.Value, p, nil, 2)
			return state
		end
	},
	Vector3 = v,
	Vector2 = v,
	UDim2 = v,
	UDim = v,
	table = {
		Add = function(p, p2, p3)
			if p2 == nil then
				return
			end

			local value = p.Value

			if p3 == nil then
				insert(value, p2)
				p.Changed:Fire(value, find(value, p2), p2, 1, true)
			else
				value[p2] = p3
				p.Changed:Fire(value, p2, p3, 1)
			end
		end,
		Remove = function(p, p2)
			if p2 == nil then
				return
			end

			local value = p.Value

			if value[p2] == nil then
				local index = find(value, p2)

				if index == nil then
					local index2 = getIndex(value, p2) -- equivalent call inferred; original call site unknown

					if index2 == nil then
						return
					end

					value[index2] = nil
					p.Changed:Fire(value, index2, p2, 2)
				else
					remove(value, index)
					p.Changed:Fire(value, index, p2, 2, true)
				end
			else
				local v2 = value[p2]
				value[p2] = nil
				p.Changed:Fire(value, p2, v2, 2)
			end
		end
	}
}