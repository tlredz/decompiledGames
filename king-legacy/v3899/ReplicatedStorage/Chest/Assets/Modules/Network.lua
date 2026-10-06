local Network = {}
local RunService = game:GetService("RunService")
game:GetService("ServerStorage")
game:GetService("ReplicatedStorage")
local remoteEvent = Instance.new("RemoteEvent")
local remoteFunction = Instance.new("RemoteFunction")
local bindableEvent = Instance.new("BindableEvent")
local bindableFunction = Instance.new("BindableFunction")
local v = {
	Fire = bindableEvent.Fire,
	Invoke = bindableFunction.Invoke,
	FireServer = remoteEvent.FireServer,
	InvokeServer = remoteFunction.InvokeServer
}

function RegisterEvent(instance, callback)
	if instance:IsA("BindableEvent") then
		instance.Event:Connect(callback)
		return true
	end

	if instance:IsA("BindableFunction") then
		instance.OnInvoke = callback
		return true
	end

	if instance:IsA("RemoteEvent") then
		instance.OnServerEvent:Connect(callback)
		return true
	end

	if instance:IsA("RemoteFunction") then
		instance.OnServerInvoke = callback
		return true
	else
		warn("[Network] Unsupported Event type for registration:", instance.ClassName)
	end
end

function Network:Connect(childName: string, p: string, callback)
	local clientNetwork = script.ClientNetwork

	if RunService:IsServer() and (p == "Invoke" or p == "Fire") then
		clientNetwork = script.ServerNetwork
	end

	local child = clientNetwork:FindFirstChild(childName)

	if not child then
		return
	end

	if callback then
		RegisterEvent(child, callback)
	end
end

function Network.Create(_, name: string, className: string, callback)
	local clientNetwork = script.ClientNetwork

	if RunService:IsServer() and (className == "BindableEvent" or className == "BindableFunction") then
		clientNetwork = script.ServerNetwork
	end

	if clientNetwork:FindFirstChild(name) then
		return
	end

	local instance = Instance.new(className)
	instance.Name = name

	if callback then
		RegisterEvent(instance, callback)
	end

	instance.Parent = clientNetwork
end

setmetatable(Network, {
	__index = function(_, p)
		return function(_, childName: string, ...)
			local clientNetwork = script.ClientNetwork

			if RunService:IsServer() and (p == "Invoke" or p == "Fire") then
				clientNetwork = script.ServerNetwork
			end

			if clientNetwork:FindFirstChild(childName) then
				return v[p](clientNetwork[childName], ...)
			end

			warn("[Network] Event not found:", childName)
		end
	end
})
return Network