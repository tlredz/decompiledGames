local CollectionService = game:GetService("CollectionService")

function observeTag(tag: string, callback, items)
	local v = {}
	local v2 = {}
	local connection = nil

	local function IsGoodAncestor(instance)
		if items == nil then
			return true
		end

		for _, ancestor in items do
			if instance:IsDescendantOf(ancestor) then
				return true
			end
		end

		return false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function AttemptStartup(instance)
		v[instance] = "__inflight__"
		task.defer(function()
			if v[instance] ~= "__inflight__" then
				return
			end

			local v3, v4 = xpcall(function(p)
				local v5 = callback(p)
				assert(typeof(v5) == "nil" or typeof(v5) == "function", "callback must return a function")
				return v5
			end, debug.traceback, instance)

			if v3 then
				if type(v4) == "function" then
					if v[instance] == "__inflight__" then
						v[instance] = v4
					else
						task.spawn(v4)
					end
				end
			else
				local v5 = string.split(v4, "\n")[1]
				local v6 = string.find(v5, ": ")
				local v7 = not v6 and "" or v5:sub(v6 + 1)
				warn((`error while calling observeTag("{tag}") callback:{v7}\n{v4}`))
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function AttemptCleanup(p)
		local v3 = v[p]
		v[p] = "__dead__"

		if typeof(v3) == "function" then
			task.spawn(v3)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function OnAncestryChanged(instance)
		local flag

		if items == nil then
			flag = true
		else
			local flag2 = true

			for _, ancestor in items do
				if not instance:IsDescendantOf(ancestor) then
					continue
				end

				flag = true
				flag2 = false
				break
			end

			if flag2 then
				flag = false
			end
		end

		if flag then
			if v[instance] == "__dead__" then
				AttemptStartup(instance) -- equivalent call inferred; original call site unknown
			end
		else
			AttemptCleanup(instance) -- equivalent call inferred; original call site unknown
		end
	end

	local function OnInstanceAdded(instance)
		if not (connection.Connected and v[instance] == nil) then
			return
		end

		v[instance] = "__dead__"
		v2[instance] = instance.AncestryChanged:Connect(function()
			OnAncestryChanged(instance) -- equivalent call inferred; original call site unknown
		end)
		OnAncestryChanged(instance) -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function OnInstanceRemoved(p)
		AttemptCleanup(p) -- equivalent call inferred; original call site unknown
		local connection2 = v2[p]

		if connection2 then
			connection2:Disconnect()
			v2[p] = nil
		end

		v[p] = nil
	end

	connection = CollectionService:GetInstanceAddedSignal(tag):Connect(OnInstanceAdded)
	local connection2 = CollectionService:GetInstanceRemovedSignal(tag):Connect(OnInstanceRemoved)
	task.defer(function()
		if not connection.Connected then
			return
		end

		for _, v3 in CollectionService:GetTagged(tag) do
			task.spawn(OnInstanceAdded, v3)
		end
	end)
	return function()
		connection:Disconnect()
		connection2:Disconnect()
		local v3 = next(v)

		while v3 do
			OnInstanceRemoved(v3) -- equivalent call inferred; original call site unknown
			v3 = next(v)
		end
	end
end

return observeTag