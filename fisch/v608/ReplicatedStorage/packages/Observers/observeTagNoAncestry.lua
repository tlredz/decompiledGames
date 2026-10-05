local CollectionService = game:GetService("CollectionService")

function observeTagNoAncestry(tag: string, callback)
	local v = {}
	local connection = nil

	local function OnInstanceAdded(instance)
		if not connection.Connected then
			return
		end

		task.defer(function()
			local v2, v3 = xpcall(function(p)
				local v4 = callback(p)
				assert(typeof(v4) == "nil" or typeof(v4) == "function", "callback must return a function")
				return v4
			end, debug.traceback, instance)

			if v2 then
				if type(v3) == "function" then
					if instance:HasTag(tag) then
						v[instance] = v3
					else
						task.spawn(v3)
					end
				end
			else
				local v4 = string.split(v3, "\n")[1]
				local v5 = string.find(v4, ": ")
				local v6 = not v5 and "" or v4:sub(v5 + 1)
				warn((`error while calling observeTag("{tag}") callback:{v6}\n{v3}`))
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function OnInstanceRemoved(p)
		local v2 = v[p]

		if typeof(v2) == "function" then
			task.spawn(v2)
		end
	end

	connection = CollectionService:GetInstanceAddedSignal(tag):Connect(OnInstanceAdded)
	local connection2 = CollectionService:GetInstanceRemovedSignal(tag):Connect(OnInstanceRemoved)
	task.defer(function()
		if not connection.Connected then
			return
		end

		for _, v2 in CollectionService:GetTagged(tag) do
			task.spawn(OnInstanceAdded, v2)
		end
	end)
	return function()
		connection:Disconnect()
		connection2:Disconnect()
		task.defer(function()
			local v2 = next(v)

			while v2 do
				OnInstanceRemoved(v2) -- equivalent call inferred; original call site unknown
				task.wait()
				v2 = next(v, v2)
			end
		end)
	end
end

return observeTagNoAncestry