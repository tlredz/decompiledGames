local FayeUtility = require(script.Parent.Misc.FayeUtility)
require(script.Parent.FayeTypes)
return function(callback, p)
	local v = nil
	local v2 = nil
	local fn = nil
	local onChanged = nil

	local function fn2(instance)
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

	onChanged = function(p2: string)
		callback(fn2)

		if p2 == "is_first123" and v2 == nil then
			fn()
		end
	end

	fn = function()
		if p ~= nil then
			FayeUtility.RemoveFromThread(p, fn)
		end

		if v ~= nil then
			FayeUtility.tc(v)
			v = nil
		end

		if v2 ~= nil then
			FayeUtility.ClearAllConnections(v2)
			v2 = nil
		end

		fn2 = nil
		onChanged = nil
		fn = nil
	end

	task.spawn(onChanged, "is_first123")

	if p == nil then
		return fn()
	end

	FayeUtility.AddToThread(p, fn)
end