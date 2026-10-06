local v = {}
msg = "To protect your data, DataStores are only accessible using Studio Lite's DataStoreScript found in the blue-plus."
print(script:GetFullName())

function v.GetDataStore(_, ...)
	error(msg, 2)
end

function v.GetGlobalDataStore(_, ...)
	error(msg, 2)
end

function v.GetOrderedDataStore(_, ...)
	error(msg, 2)
end

function v.GetRequestBudgetForRequestType(_, ...)
	error(msg, 2)
end

function v.ListDataStoresAsync(_, ...)
	error(msg, 2)
end

local v2 = {
	__index = game:GetService("DataStoreService")
}
return (setmetatable(v, v2))