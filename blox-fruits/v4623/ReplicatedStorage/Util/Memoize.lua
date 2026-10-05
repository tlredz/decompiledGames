function catch(...)
	local v = { ... }
	local v2 = select("#", ...)
	return function()
		return unpack(v, 1, v2)
	end
end

local v = {
	__mode = "k"
}

local function weak_table()
	return (setmetatable({}, v))
end

local function strong_table()
	return {}
end

local v2 = {}

local function arg2key(p)
	if p == nil then
		return v2
	end

	return p
end

local threads = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh_thread(p, p2, callback)
	if not callback then
		return
	end

	if threads[p2] then
		task.cancel(threads[p2])
	end

	threads[p2] = task.delay(45, function()
		p[p2] = nil

		if typeof(callback) == "function" then
			callback(p2)
		end
	end)
end

local function new_memoizer_1_to_n(callback)
	return function(callback2, p)
		local v3 = callback()
		return function(p2)
			local v4

			if p2 == nil then
				v4 = v2
			else
				v4 = p2
			end

			local v5 = v3[v4]
			refresh_thread(v3, v4, p) -- equivalent call inferred; original call site unknown

			if v5 then
				return v5()
			end

			local v8 = catch(callback2(p2))
			v3[v4] = v8
			return v8()
		end
	end
end

local function new_memoizer_m_to_n(callback, callback2)
	local memoize_m_to_n

	memoize_m_to_n = function(p, callback3, p2)
		if p == 0 then
			local v3 = nil
			return function()
				if v3 then
					return v3()
				end

				v3 = catch(callback3())
				return v3()
			end
		elseif p == 1 then
			return callback2(callback3, p2)
		end

		local v3 = callback()
		return function(p3, ...)
			local v4

			if p3 == nil then
				v4 = v2
			else
				v4 = p3
			end

			local v5 = v3[v4]
			refresh_thread(v3, v4, p2) -- equivalent call inferred; original call site unknown

			if v5 then
				return v5(...)
			end

			local v8 = memoize_m_to_n(p - 1, function(...)
				return callback3(p3, ...)
			end, p2)
			v3[v4] = v8
			return v8(...)
		end
	end

	return function(p, p2)
		local v3 = callback()
		return function(...)
			local v4 = select("#", ...)
			local v5 = v3[v4]

			if v5 then
				return v5(...)
			end

			local v6 = memoize_m_to_n(v4, p, p2)
			v3[v4] = v6
			return v6(...)
		end
	end
end

function weak_memoize_1_to_n(callback, p)
	local v3 = weak_table()
	return function(p2)
		local v4

		if p2 == nil then
			v4 = v2
		else
			v4 = p2
		end

		local v5 = v3[v4]
		refresh_thread(v3, v4, p) -- equivalent call inferred; original call site unknown

		if v5 then
			return v5()
		end

		local v8 = catch(callback(p2))
		v3[v4] = v8
		return v8()
	end
end

function strong_memoize_1_to_n(callback, p)
	local v3 = strong_table()
	return function(p2)
		local v4

		if p2 == nil then
			v4 = v2
		else
			v4 = p2
		end

		local v5 = v3[v4]
		refresh_thread(v3, v4, p) -- equivalent call inferred; original call site unknown

		if v5 then
			return v5()
		end

		local v8 = catch(callback(p2))
		v3[v4] = v8
		return v8()
	end
end

local weak_memoize_1_to_n2 = weak_memoize_1_to_n
local memoize_m_to_n

memoize_m_to_n = function(p, callback, p2)
	if p == 0 then
		local v3 = nil
		return function()
			if v3 then
				return v3()
			end

			v3 = catch(callback())
			return v3()
		end
	elseif p == 1 then
		return weak_memoize_1_to_n2(callback, p2)
	end

	local v3 = weak_table()
	return function(p3, ...)
		local v4

		if p3 == nil then
			v4 = v2
		else
			v4 = p3
		end

		local v5 = v3[v4]
		refresh_thread(v3, v4, p2) -- equivalent call inferred; original call site unknown

		if v5 then
			return v5(...)
		end

		local v8 = memoize_m_to_n(p - 1, function(...)
			return callback(p3, ...)
		end, p2)
		v3[v4] = v8
		return v8(...)
	end
end

function weak_memoize_m_to_n(p, p2)
	local v3 = weak_table()
	return function(...)
		local v4 = select("#", ...)
		local v5 = v3[v4]

		if v5 then
			return v5(...)
		end

		local v6 = memoize_m_to_n(v4, p, p2)
		v3[v4] = v6
		return v6(...)
	end
end

local strong_memoize_1_to_n2 = strong_memoize_1_to_n
local memoize_m_to_n2

memoize_m_to_n2 = function(p, callback, p2)
	if p == 0 then
		local v3 = nil
		return function()
			if v3 then
				return v3()
			end

			v3 = catch(callback())
			return v3()
		end
	elseif p == 1 then
		return strong_memoize_1_to_n2(callback, p2)
	end

	local v3 = strong_table()
	return function(p3, ...)
		local v4

		if p3 == nil then
			v4 = v2
		else
			v4 = p3
		end

		local v5 = v3[v4]
		refresh_thread(v3, v4, p2) -- equivalent call inferred; original call site unknown

		if v5 then
			return v5(...)
		end

		local v8 = memoize_m_to_n2(p - 1, function(...)
			return callback(p3, ...)
		end, p2)
		v3[v4] = v8
		return v8(...)
	end
end

function strong_memoize_m_to_n(p, p2)
	local v3 = strong_table()
	return function(...)
		local v4 = select("#", ...)
		local v5 = v3[v4]

		if v5 then
			return v5(...)
		end

		local v6 = memoize_m_to_n2(v4, p, p2)
		v3[v4] = v6
		return v6(...)
	end
end

return strong_memoize_m_to_n