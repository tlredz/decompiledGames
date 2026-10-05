require(script.Parent.Parent.Parent.FayeTypes)
local repeatedCompile = require(script.Parent.repeatedCompile)
local _ = table.insert
local FayeUtility = require(script.Parent.Parent.Parent.Misc.FayeUtility)
return function(object, data, callback, callback2)
	local instance = object.Instance
	local cleanThread = object.CleanThread or object.Thread
	local v = instance[data.Method](instance, data.Index)

	local function fn(...)
		if cleanThread ~= nil and not cleanThread.IsActive then
			print("Thread is no longer active")
			return
		end

		local v2, v3 = callback(instance, ...)

		if v2 ~= nil then
			repeatedCompile(data, v2, v3, callback2, object)
		end
	end

	if data.RunOnInitialization ~= nil then
		fn()
	end

	if not object:Connect(v, fn) then
		FayeUtility.Connect(v, fn, cleanThread)
	end
end