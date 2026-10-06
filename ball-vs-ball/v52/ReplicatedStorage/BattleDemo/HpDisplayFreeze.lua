local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local HpDisplayFreeze = {}

function HpDisplayFreeze.freeze(p: number)
	v[p] = true
end

function HpDisplayFreeze.unfreeze(p: number)
	if not v[p] then
		return
	end

	v[p] = nil

	for _, callback in ipairs(table.clone(v4)) do
		task.spawn(callback, p)
	end
end

function HpDisplayFreeze.resolve(p: number, p2: number)
	if v[p] and v2[p] ~= nil then
		return v2[p]
	end

	v2[p] = p2
	return p2
end

function HpDisplayFreeze.isAnyFrozen(list)
	for _, v5 in ipairs(list) do
		if v[v5] then
			return true
		end
	end

	return false
end

function HpDisplayFreeze.resolveKills(p: number, value: number?, flag: boolean)
	local v5 = v3[p]

	if not flag or v5 == nil then
		v3[p] = value or -1
		return value
	end

	if v5 == -1 then
		return nil
	end

	return v5
end

function HpDisplayFreeze.onUnfreeze(callback)
	table.insert(v4, callback)
	return function()
		local index = table.find(v4, callback)

		if index then
			table.remove(v4, index)
		end
	end
end

return HpDisplayFreeze