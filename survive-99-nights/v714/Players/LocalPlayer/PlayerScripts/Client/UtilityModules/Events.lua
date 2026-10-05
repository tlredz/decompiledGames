local Events = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local remoteEvents = game.ReplicatedStorage.RemoteEvents

function Events.Init()
	ConfigureConnections()
end

function AddEvent(name)
	local object = setmetatable({}, {
		__index = Events
	})
	object.BindableEvent = Client.BindableEvent.new()
	object.Name = name
	local instance = remoteEvents:FindFirstChild(name)

	if instance and instance:IsA("RemoteEvent") then
		object.RemoteEvent = instance
		instance.OnClientEvent:Connect(function(...)
			object.BindableEvent:Fire(...)
		end)
	elseif instance and instance:IsA("RemoteFunction") then
		object.RemoteFunction = instance
	end

	Events[name] = object
	return object
end

function ConfigureConnections()
	setmetatable(Events, {
		__index = function(_, p)
			return AddEvent(p)
		end
	})
	remoteEvents.ChildAdded:Connect(function(child)
		local v = Events[child.Name]

		if v then
			if child:IsA("RemoteEvent") then
				v.RemoteEvent = child
				child.OnClientEvent:Connect(function(...)
					v.BindableEvent:Fire(...)
				end)
			elseif child:IsA("RemoteFunction") then
				v.RemoteFunction = child

				if v.OnInvokeFunction then
					v.RemoteFunction.OnClientInvoke = v.OnInvokeFunction
				end
			end
		end
	end)
end

function Events:Connect(onBindableEvent)
	return self.BindableEvent:Connect(onBindableEvent)
end

Events.OnClientInvoke = function(self, p2)
	if rawget(self, "RemoteFunction") then
		self.RemoteFunction.OnClientInvoke = p2
	else
		self.OnInvokeFunction = p2
	end
end

function Events:Wait()
	return self.BindableEvent:Wait()
end

function Events:FireServer(...)
	if rawget(self, "RemoteEvent") then
		self.RemoteEvent:FireServer(...)
	else
		warn("Remote event does not exist for event", self.Name)
	end
end

function Events:InvokeServer(...)
	if rawget(self, "RemoteFunction") then
		return self.RemoteFunction:InvokeServer(...)
	end

	warn("Remote function does not exist for event", self.Name)
end

function Events.FireOtherClients(p, ...)
	if rawget(p, "RemoteEvent") then
		p.RemoteEvent:FireServer("FireAllClients", ...)
	else
		warn("Remote event does not exist for event", p.Name)
	end
end

function Events.FireAllClients(data, ...)
	data.BindableEvent:Fire(localPlayer, ...)

	if rawget(data, "RemoteEvent") then
		data.RemoteEvent:FireServer("FireAllClients", ...)
	else
		warn("Remote event does not exist for event", data.Name)
	end
end

function Events:Fire(...)
	self.BindableEvent:Fire(...)
end

return Events