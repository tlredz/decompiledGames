local DataStoreService = game:GetService("DataStoreService")
local threads = {}
local success = nil
local result = nil
task.spawn(function()
	success, result = pcall(function()
		local dataStore = DataStoreService:GetDataStore("_package/eryn.io/Cmdr")
		dataStore:GetAsync("test_key")
		return dataStore
	end)

	while #threads > 0 do
		coroutine.resume(table.remove(threads, 1))
	end
end)
return function(object, value)
	if success == nil then
		table.insert(threads, coroutine.running())
		coroutine.yield()
	end

	local flag = true
	local v

	if value:sub(1, 1) == "$" then
		value = value:sub(2)
		v = true
	else
		v = false
	end

	if value:sub(1, 1) == "." then
		value = value:sub(2)
		flag = false
	end

	if flag and not success then
		return "# You must publish this place to the web to use saved keys."
	end

	local v2 = "var_" .. (v and "global" or tostring(object.Executor.UserId))

	if flag then
		local v3 = v2 .. "_" .. value
		local async = result:GetAsync(v3) or ""

		if type(async) == "table" then
			return table.concat(async, ",") or ""
		end

		return async
	else
		local v3 = object:GetStore(v2)[value] or ""

		if type(v3) == "table" then
			return table.concat(v3, ",") or ""
		end

		return v3
	end
end