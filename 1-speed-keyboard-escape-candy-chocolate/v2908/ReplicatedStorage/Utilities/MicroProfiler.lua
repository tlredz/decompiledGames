return {
	Call = function(p, callback)
		debug.profilebegin(p)
		local v = table.pack(pcall(callback))
		debug.profileend()

		if not v[1] then
			error(v[2], 0)
		end

		return table.unpack(v, 2, v.n)
	end
}