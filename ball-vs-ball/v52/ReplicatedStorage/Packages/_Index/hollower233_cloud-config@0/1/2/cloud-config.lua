local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local Net = require(script.Parent.Net)
local remoteFunction = Net:RemoteFunction("CloudConfigGetAll")
local v = nil
local v2 = nil

local function groupBy(items, name: string)
	local result = {}

	for _, item in items do
		local v3 = item[name]
		result[v3] = result[v3] or {}
		table.insert(result[v3], item)
	end

	return result
end

local function retryUntilSuccess(fn)
	local v3 = 1
	local result

	while true do
		local success
		success, result = pcall(fn)

		if success then
			break
		end

		warn((`[CloudConfig] 读取配置失败，{v3} 秒后重试：{result}`))
		task.wait(v3)
		v3 = math.min(v3 * 2, 60)
	end

	return result
end

local function loadRawConfig()
	local dataStore = DataStoreService:GetDataStore("cloudConfig")
	local v3 = retryUntilSuccess(function()
		return dataStore:GetAsync("config")
	end)

	if type(v3) == "table" then
		return {
			server = type(v3.server) ~= "table" and {} or v3.server,
			studio = type(v3.studio) ~= "table" and {} or v3.studio
		}
	end

	warn((`[CloudConfig] 配置不是 table，已使用空配置，当前类型: {typeof(v3)}`))
	return {
		server = {},
		studio = {}
	}
end

local function buildEntry(k: string, list)
	if type(list) ~= "table" then
		warn((`[CloudConfig] {k} 配置不是 table，已回退为空配置，当前类型: {typeof(list)}`))
		return {}
	end

	if #list == 0 then
		return {}
	end

	if type(list[1]) ~= "table" then
		warn((`[CloudConfig] {k} 首行数据不是 table，已回退为空配置`))
		return {}
	end

	local result = {
		list = list
	}
	local v3 = {}
	local v4 = {}

	for k2, v5 in list[1] do
		if type(v5) ~= "string" then
			continue
		end

		local output = "by" .. k2:sub(1, 1):upper() .. k2:sub(2)
		result[output] = {}
		table.insert(v3, {
			name = k2,
			output = output
		})
	end

	for _, v5 in list do
		for _, v6 in v3 do
			if v4[v6.name] then
				continue
			end

			local v7 = result[v6.output]
			local v8 = v5[v6.name]

			if v7[v8] then
				result[v6.output] = groupBy(list, v6.name)
				v4[v6.name] = true
			else
				v7[v8] = v5
			end
		end
	end

	return result
end

local function buildSnapshot(p)
	local result = {}

	for k, v3 in p[RunService:IsStudio() and "studio" or "server"] or {} do
		if k == "misc" then
			result.misc = type(v3) ~= "table" and {} or v3
		else
			result[k] = buildEntry(k, v3)
		end
	end

	return result
end

local function fetchClientSnapshot()
	return (remoteFunction:InvokeServer())
end

local function getAll()
	if RunService:IsServer() then
		return v
	end

	if v2 == nil then
		v2 = remoteFunction:InvokeServer()
	end

	return v2
end

if RunService:IsServer() then
	v = buildSnapshot(loadRawConfig())

	remoteFunction.OnServerInvoke = function(_)
		return v
	end
end

return {
	getAll = getAll
}