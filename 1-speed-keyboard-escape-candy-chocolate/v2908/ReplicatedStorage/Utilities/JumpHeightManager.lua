local v = {}
local v2 = nil
local jumpHeight = 7.2

local function apply()
	if not (v2 and v2.Parent) then
		return
	end

	local v3 = nil

	for _, v4 in v do
		if not v3 or v4.priority > v3.priority then
			v3 = v4
		end
	end

	local v4 = v2
	local jumpHeight2

	if v3 then
		jumpHeight2 = v3.value
	else
		jumpHeight2 = jumpHeight
	end

	v4.JumpHeight = jumpHeight2
end

local JumpHeightManager = {}

function JumpHeightManager.setHumanoid(p)
	v2 = p
	jumpHeight = p.JumpHeight
	v = {}
	apply()
end

function JumpHeightManager.set(p: string, p2: number, priority: number)
	v[p] = {
		value = p2,
		priority = priority
	}
	apply()
end

function JumpHeightManager.release(p: string)
	v[p] = nil
	apply()
end

return JumpHeightManager