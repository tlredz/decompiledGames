local fn
local fn2
local fn3
local SchedulerMinHeap = {
	push = function(self, p)
		local v = #self + 1
		self[v] = p
		fn2(self, p, v)
	end,
	peek = function(list)
		return list[1]
	end,
	pop = function(self)
		local v = self[1]

		if v == nil then
			return nil
		end

		local v2 = self[#self]
		self[#self] = nil

		if v2 ~= v then
			self[1] = v2
			fn3(self, v2, 1)
		end

		return v
	end
}

fn2 = function(list, p, p2: number)
	while true do
		local v = math.floor(p2 / 2)
		local v2 = list[v]

		if v2 == nil or not (fn(v2, p) > 0) then
			break
		end

		list[v] = p
		list[p2] = v2
		p2 = v
	end
end

fn3 = function(list, p, p2: number)
	local v = #list

	while p2 < v do
		local v2 = p2 * 2
		local v3 = list[v2]
		local v4 = v2 + 1
		local v5 = list[v4]

		if v3 == nil or not (fn(v3, p) < 0) then
			if v5 == nil or not (fn(v5, p) < 0) then
				break
			end

			list[p2] = v5
			list[v4] = p
			p2 = v4
		elseif v5 == nil or not (fn(v5, v3) < 0) then
			list[p2] = v3
			list[v2] = p
			p2 = v2
		else
			list[p2] = v5
			list[v4] = p
			p2 = v4
		end
	end
end

fn = function(p, p2)
	local v = p.sortIndex - p2.sortIndex

	if v == 0 then
		return p.id - p2.id
	end

	return v
end

return SchedulerMinHeap