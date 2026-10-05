local Network = {
	Events = {}
}
local v = {}
setmetatable(Network.Events, {
	__newindex = function(_, p, p2)
		if v[p] then
			table.insert(v[p], p2)
		else
			v[p] = { p2 }
		end
	end,
	__index = function(_, p)
		if v[p] then
			return v[p][1]
		end

		return nil
	end
})
local remoteEvent = nil
local remoteFunction = nil
local Players = game:GetService("Players")

function Network.ListenTo(_, p: string, callback)
	local function fn(...)
		callback(...)
	end

	Network.Events[p] = fn
	return {
		Disconnect = function()
			local v2 = v[p]

			if v2 then
				for k, v3 in pairs(v2) do
					if v3 ~= fn then
						continue
					end

					table.remove(v2, k)

					if next(v2) then
						break
					end

					v[p] = nil
					return
				end
			end
		end
	}
end

local RunService = game:GetService("RunService")

if RunService:IsClient() then
	function OnGetData(p: string, ...)
		local v2 = v[p]

		if not v2 then
			warn(("[ClientEvent] - No event connected for %s"):format(p))
			return
		end

		local v3 = nil

		for _, v4 in ipairs(v2) do
			v3 = table.pack(v4(...))
		end

		return table.unpack(v3)
	end

	local flag = false

	function Network.Fire(_, p: string, ...)
		if not flag then
			repeat
				task.wait()
			until flag
		end

		remoteEvent:FireServer(p, ...)
	end

	function Network.Invoke(_, p: string, ...)
		if flag then
			return remoteFunction:InvokeServer(p, ...)
		end

		repeat
			task.wait()
		until flag

		return remoteFunction:InvokeServer(p, ...)
	end

	task.spawn(function()
		remoteFunction = game.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("RemoteFunction")
		remoteEvent = game.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("RemoteEvent")
		remoteFunction.OnClientInvoke = OnGetData
		remoteEvent.OnClientEvent:Connect(OnGetData)
		flag = true
	end)
else
	function OnGetData(p, p2: string, ...)
		local v2 = v[p2]

		if not v2 then
			return
		end

		local v3 = nil

		for _, v4 in ipairs(v2) do
			v3 = { v4(p, ...) }
		end

		return table.unpack(v3)
	end

	local remote = game.ReplicatedStorage:FindFirstChild("Remote") or Instance.new("Folder", game.ReplicatedStorage)
	remote.Name = "Remote"
	local remoteFunction2 = game.ReplicatedStorage.Remote:FindFirstChild("RemoteFunction") or Instance.new(
		"RemoteFunction",
		remote
	)
	local remoteEvent2 = game.ReplicatedStorage.Remote:FindFirstChild("RemoteEvent") or Instance.new(
		"RemoteEvent",
		remote
	)

	function Network.FireWithCondition(_, p: string, callback, ...)
		assert(callback and typeof(callback) == "function", "Condition must be a function")

		for _, player in pairs(Players:GetPlayers()) do
			if callback(player) then
				remoteEvent2:FireClient(player, p, ...)
			end
		end
	end

	function Network.FireAllWithin(_, items, p: string, ...)
		assert(items and typeof(items) == "table", "Target must be a table")

		for _, player in pairs(items) do
			remoteEvent2:FireClient(player, p, ...)
		end
	end

	function Network.FireAllExcept(_, p, p2: string, ...)
		for _, player in pairs(Players:GetChildren()) do
			if player ~= p then
				remoteEvent2:FireClient(player, p2, ...)
			end
		end
	end

	function Network:FireAllClients(p: string, ...)
		remoteEvent2:FireAllClients(p, ...)
	end

	function Network.Fire(_, player, p: string, ...)
		remoteEvent2:FireClient(player, p, ...)
	end

	function Network.Invoke(_, player, p: string, ...)
		return remoteFunction2:InvokeClient(player, p, ...)
	end

	remoteFunction2.OnServerInvoke = OnGetData
	remoteEvent2.OnServerEvent:Connect(OnGetData)
end

return Network