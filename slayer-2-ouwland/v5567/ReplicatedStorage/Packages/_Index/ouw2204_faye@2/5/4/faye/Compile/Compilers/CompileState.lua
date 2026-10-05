require(script.Parent.Parent.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Parent.Parent.Misc.FayeUtility)
return function(data, p, p2, callback)
	local cleanThread = data.CleanThread or data.Thread

	if p2.IsState and (cleanThread == nil or cleanThread.Extend == nil) then
		warn("State only works if the entity has a thread and the thread has an :Extend method")
		return
	end

	local v = nil
	local v2 = nil
	local fn = nil
	local fn2 = nil
	local thread = nil

	local function onChanged(p3: string?)
		if thread ~= nil then
			FayeUtility.CallDestroy(thread)
			thread = nil
		end

		if p2.IsState then
			thread = cleanThread:Extend(true)
		end

		local func, v4 = p2.Func(fn, thread or cleanThread, data.Instance)
		local v5 = p2.IsState and {
			Instance = data.Instance,
			Thread = thread
		} or data

		if func == nil then
			if p3 == "is_first123" and v == nil then
				fn2()
			elseif thread ~= nil then
				FayeUtility.CallDestroy(thread)
				thread = nil
			end
		elseif p ~= nil and FayeUtility.tof(p) ~= FayeUtility.numbertxt then
			callback(v5, {
				[p] = func
			}, thread)
		elseif v4 == nil then
			callback(v5, { func }, thread)
		else
			callback(v5, {
				[func] = v4
			}, thread)
		end
	end

	fn = function(instance)
		if instance == nil then
			return
		end

		if FayeUtility.tof(instance) == "table" and instance.__type == "Instance" then
			instance = instance.Instance
		end

		if v == nil then
			v = {}
			v2 = {}
		end

		if instance.ClassName == nil then
			if v[instance.Id] == nil then
				v[instance.Id] = true
				FayeUtility.tins(v2, instance.Changed:Connect(onChanged, v2))
			end

			return instance:Get()
		else
			if v[instance] == nil then
				v[instance] = true
				FayeUtility.tins(v2, instance.Changed:Connect(onChanged))
			end

			return instance.Value
		end
	end

	local v4 = nil

	fn2 = function()
		if v4 ~= nil then
			FayeUtility.RemoveFromThread(v4, fn2)
		end

		FayeUtility.RemoveFromEntity(data, fn2)

		if thread ~= nil then
			FayeUtility.CallDestroy(thread)
			thread = nil
		end

		if v ~= nil then
			FayeUtility.tc(v)
			v = nil
		end

		if v2 ~= nil then
			FayeUtility.ClearAllConnections(v2)
			v2 = nil
		end

		fn = nil
		onChanged = nil
		fn2 = nil
	end

	task.spawn(onChanged, "is_first123")
	FayeUtility.AddToEntity(data, fn2)

	if cleanThread == nil then
		return
	end

	v4 = cleanThread

	if v4._isCleanAncestor then
		local parentThread = v4

		while parentThread ~= nil and not parentThread._hc do
			parentThread = parentThread.ParentThread
		end

		v4 = parentThread or v4
	end

	FayeUtility.AddToThread(v4, fn2)
end