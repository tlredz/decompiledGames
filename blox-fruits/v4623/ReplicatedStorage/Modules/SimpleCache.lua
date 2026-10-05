function simpleCache(duration: number)
	assert(duration)
	local v = {}
	local flag = false
	local thread = nil

	local function update()
		if flag then
			print("Cache has been destroyed and cannot be updated.")
			return
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		thread = task.delay(duration, function()
			thread = nil
			table.clear(v)
		end)
	end

	return {
		Clear = function(_)
			update()
			table.clear(v)
		end,
		Get = function(_, p)
			update()
			local index = v[p]

			if not index then
				if #v > 0 then
					index = table.find(v, p)
				else
					index = false
				end
			end

			return index
		end,
		Edit = function(_, callback)
			if flag then
				print("Cache has been destroyed and cannot be edited.")
				return
			end

			update()
			local v3 = callback(v)

			if typeof(v3) == "table" then
				v = v3
			else
				warn("Attempt to set cache to bad type", typeof(v3), debug.traceback())
			end
		end,
		Dump = function(_)
			update()
			print(v)
		end,
		Destroy = function(_)
			if not flag then
				flag = true

				if thread then
					task.cancel(thread)
					thread = nil
				end

				table.clear(v)
			end
		end
	}
end

return {
	new = simpleCache
}