local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function apply()
	local v2 = nil

	for _, v3 in v do
		if not v2 or v3.priority > v2.priority then
			v2 = v3
		end
	end

	workspace.Gravity = not v2 and 196.2 or v2.value
end

local GravityManager = {}

function GravityManager.set(p: string, p2: number, priority: number)
	v[p] = {
		value = p2,
		priority = priority
	}
	apply() -- equivalent call inferred; original call site unknown
end

function GravityManager.release(p: string)
	v[p] = nil
	apply() -- equivalent call inferred; original call site unknown
end

return GravityManager