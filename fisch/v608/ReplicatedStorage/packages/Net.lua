local RunService = game:GetService("RunService")
local Net = {}

function Net:UnreliableRemoteEvent(p: string, value: number?)
	local name = "URE/" .. p

	if RunService:IsServer() then
		local v2 = script:FindFirstChild(name)

		if not v2 then
			v2 = Instance.new("UnreliableRemoteEvent")
			v2.Name = name
			v2.Parent = script
		end

		return v2
	else
		local v2 = value or 10

		if v2 == -1 then
			v2 = nil
		end

		local child = script:WaitForChild(name, v2)

		if not child then
			error("Failed to find UnreliableRemoteEvent: " .. name, 2)
		end

		return child
	end
end

function Net:RemoteEvent(p: string, value: number?, flag: boolean?)
	local name = "RE/" .. p

	if RunService:IsServer() then
		local v2 = script:FindFirstChild(name)

		if not v2 then
			v2 = Instance.new("RemoteEvent")
			v2.Name = name
			v2.Parent = script
		end

		return v2
	else
		local v2 = value or 10

		if v2 == -1 then
			v2 = nil
		end

		local child = script:WaitForChild(name, v2)

		if not (child or flag) then
			error("Failed to find RemoteEvent: " .. name, 2)
		end

		return child
	end
end

function Net:ConnectUnreliable(p: string, callback)
	if RunService:IsServer() then
		return self:UnreliableRemoteEvent(p, -1).OnServerEvent:Connect(callback)
	end

	return self:UnreliableRemoteEvent(p, -1).OnClientEvent:Connect(callback)
end

function Net:Connect(p: string, callback)
	if RunService:IsServer() then
		return self:RemoteEvent(p, -1).OnServerEvent:Connect(callback)
	end

	return self:RemoteEvent(p, -1).OnClientEvent:Connect(callback)
end

function Net:RemoteFunction(p: string, value: number?)
	local name = "RF/" .. p

	if RunService:IsServer() then
		local v2 = script:FindFirstChild(name)

		if not v2 then
			v2 = Instance.new("RemoteFunction")
			v2.Name = name
			v2.Parent = script
		end

		return v2
	else
		local v2 = value or 10

		if v2 == -1 then
			v2 = nil
		end

		local child = script:WaitForChild(name, v2)

		if not child then
			error("Failed to find RemoteFunction: " .. name, 2)
		end

		return child
	end
end

function Net:Handle(p: string, callback)
	if RunService:IsServer() then
		local remoteFunction = self:RemoteFunction(p)
		remoteFunction.OnServerInvoke = callback
	else
		local remoteFunction_2 = self:RemoteFunction(p, -1)
		remoteFunction_2.OnClientInvoke = callback
	end
end

function Net:Invoke(p: string, ...)
	return self:RemoteFunction(p, -1):InvokeServer(...)
end

function Net:Fire(p: string, ...)
	if RunService:IsServer() then
		return self:RemoteEvent(p):FireAllClients(...)
	end

	return self:RemoteEvent(p, -1):FireServer(...)
end

function Net:FireClient(player: string, player2, ...)
	if typeof(player2) ~= "table" then
		return self:RemoteEvent(player):FireClient(player2, ...)
	end

	for _, v in player2 do
		self:FireClient(player, v, ...)
	end
end

function Net:FireClientsInRange(p: string, vector: Vector3, p2: number, ...)
	local remoteEvent = self:RemoteEvent(p)

	for _, player in game.Players:GetPlayers() do
		local distanceFromCharacter = player:DistanceFromCharacter(vector)

		if distanceFromCharacter ~= 0 and distanceFromCharacter < p2 then
			remoteEvent:FireClient(player, ...)
		end
	end
end

function Net.Clean(_)
	script:ClearAllChildren()
end

return Net