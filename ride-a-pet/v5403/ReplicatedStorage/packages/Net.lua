local RunService = game:GetService("RunService")
local Net = {}

function Net:RemoteEvent(p: string)
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
		local child = script:WaitForChild(name, 10)

		if not child then
			error("Failed to find RemoteEvent: " .. name, 2)
		end

		return child
	end
end

function Net:UnreliableRemoteEvent(p: string)
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
		local child = script:WaitForChild(name, 10)

		if not child then
			error("Failed to find UnreliableRemoteEvent: " .. name, 2)
		end

		return child
	end
end

function Net:Connect(p: string, callback)
	if RunService:IsServer() then
		return self:RemoteEvent(p).OnServerEvent:Connect(callback)
	end

	return self:RemoteEvent(p).OnClientEvent:Connect(callback)
end

function Net:ConnectUnreliable(p: string, callback)
	if RunService:IsServer() then
		return self:UnreliableRemoteEvent(p).OnServerEvent:Connect(callback)
	end

	return self:UnreliableRemoteEvent(p).OnClientEvent:Connect(callback)
end

function Net:RemoteFunction(p: string)
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
		local child = script:WaitForChild(name, 10)

		if not child then
			error("Failed to find RemoteFunction: " .. name, 2)
		end

		return child
	end
end

function Net:Handle(p: string, onServerInvoke)
	local remoteFunction = self:RemoteFunction(p)
	remoteFunction.OnServerInvoke = onServerInvoke
end

function Net:Invoke(p: string, ...)
	return self:RemoteFunction(p):InvokeServer(...)
end

function Net.Clean(_)
	script:ClearAllChildren()
end

return Net