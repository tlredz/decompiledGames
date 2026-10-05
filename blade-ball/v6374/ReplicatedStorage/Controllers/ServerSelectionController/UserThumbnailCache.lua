local v = {}
local UserThumbnailCache = {
	ContainsThreshold = function(_, list, p: number)
		local count = #list
		local count2 = 0

		for i = 1, count do
			if v[list[i]] then
				count2 += 1
			end
		end

		return p <= count2 / count
	end,
	Append = function(_, p: number, p2: string)
		if v[p] then
			return
		end

		v[p] = p2
	end,
	Get = function(_, p: number)
		local v2 = v[p]

		if v2 then
			return true, v2
		end

		return false, nil
	end,
	Dump = function(self)
		table.clear(v)
	end
}
task.defer(function()
	while true do
		task.wait(300)
		UserThumbnailCache:Dump()
	end
end)
return UserThumbnailCache