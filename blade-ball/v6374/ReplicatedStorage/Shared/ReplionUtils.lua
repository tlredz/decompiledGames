local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3("@game/ReplicatedStorage/Packages/Replion")
local v2 = require3("@game/ReplicatedStorage/Packages/Charm")
local ReplionUtils = {
	observeReplionPath = function(object, p, callback)
		callback(object:Get(p), nil)
		return (object:OnChange(p, callback))
	end
}

function ReplionUtils.observeTableContent(p, p2, callback)
	local v3 = {}
	local connection = ReplionUtils.observeReplionPath(p, p2, function(options, options2)
		local v4

		if options == nil then
			v4 = false
		else
			v4 = type(options) ~= "table"
		end

		assert(not v4, "Value is not a table")
		local v5 = options or {}
		local v6 = options2 or {}

		for k, v7 in v5 do
			if not v7 or v6[k] then
				continue
			end

			local v8 = k
			local v9 = v7
			task.spawn(function()
				v3[v8] = callback(v8, v9)
			end)
		end

		for k, v7 in v6 do
			if not v7 or v5[k] then
				continue
			end

			local v8 = v3[k]

			if not v8 then
				continue
			end

			local v9 = v8
			local v10 = k
			task.spawn(function()
				v9()
				v3[v10] = nil
			end)
		end
	end)
	return function()
		connection:Disconnect()

		for _, callback2 in v3 do
			task.spawn(callback2)
		end

		table.clear(v3)
	end
end

function ReplionUtils.observeClientReplion(p: string, callback)
	local replion = v.Client:GetReplion(p)
	local v3

	if replion then
		v3 = callback(replion, false)
	else
		v3 = nil
	end

	local v4 = v.Client:OnReplionAdded(function(p2)
		if p2._channel == p then
			if replion == p2 then
				return
			end

			if v3 then
				replion = nil
				v3()
				v3 = nil
			end

			replion = p2
			v3 = callback(p2, true)
		end
	end)
	local v5 = v.Client:OnReplionRemoved(function(p2)
		if p2._channel == p then
			if replion == p2 then
				return
			end

			if v3 then
				replion = nil
				v3()
				v3 = nil
			end
		end
	end)
	return function()
		v4:Destroy()
		v5:Destroy()

		if v3 then
			v3()
			v3 = nil
		end
	end
end

function ReplionUtils.pathToString(list)
	if type(list) == "table" then
		return (table.concat(list, "."))
	end

	return list
end

function ReplionUtils.atom(object, p)
	local atom = v2.atom(object:Get(p))
	object:OnChange(p, function(p2)
		atom(p2)
	end)
	return atom
end

return ReplionUtils