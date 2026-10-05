local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isStudio = RunService:IsStudio()
local isServer = RunService:IsServer()
local v = {}
local bindableEvent = nil
local parent

if isServer == true then
	parent = ReplicatedStorage:FindFirstChild("RemoteEvents")

	if parent == nil then
		parent = Instance.new("Folder")
		parent.Name = "RemoteEvents"
		parent.Parent = ReplicatedStorage
	elseif isStudio == true then
		warn((`[{script.Name}]: ReplicatedStorage "RemoteEvents" container was already defined`))
	end
else
	parent = ReplicatedStorage:FindFirstChild("RemoteEvents")

	if parent == nil then
		bindableEvent = Instance.new("BindableEvent")
		task.spawn(function()
			while task.wait() do
				parent = ReplicatedStorage:FindFirstChild("RemoteEvents")

				if parent == nil then
					continue
				end

				bindableEvent:Fire()
				break
			end
		end)
	end
end

local class = {}
class.__index = class

function class.New(fn)
	return (setmetatable({
		fn = fn,
		is_disconnected = false,
		real_connection = nil
	}, class))
end

function class:Disconnect()
	self.is_disconnected = true

	if self.real_connection ~= nil then
		self.real_connection:Disconnect()
	end
end

local Remote = {}
Remote.__index = Remote

function Remote.New(name: string, flag: boolean)
	if type(name) ~= "string" then
		error((`[{script.Name}]: name must be a string`))
	end

	if isServer == true then
		if v[name] ~= nil then
			error((`[{script.Name}]: RemoteEvent {name} was already defined`))
		end

		v[name] = true
		local instance = Instance.new(flag == true and "UnreliableRemoteEvent" or "RemoteEvent")
		instance.Name = name
		instance.Parent = parent
		return instance
	else
		local child = parent and parent:FindFirstChild(name)

		if child ~= nil then
			return child
		end

		local v3 = {}
		local object = setmetatable({
			OnClientEvent = {
				Connect = function(self, onOnClientEvent)
					if child ~= nil then
						return child.OnClientEvent:Connect(onOnClientEvent)
					end

					local v4 = class.New(onOnClientEvent)
					table.insert(v3, v4)
					return v4
				end
			},
			OnServerEvent = {
				Connect = function()
					error((`[{script.Name}]: Can't connect to "OnServerEvent" client-side`))
				end
			},
			RemoteEvent = nil
		}, Remote)

		local function on_container_ready()
			local lastTime = os.clock()

			while true do
				child = parent:FindFirstChild(name)

				if child ~= nil then
					break
				end

				if lastTime ~= nil and os.clock() - lastTime > 20 then
					warn((`[{script.Name}]: RemoteEvent "{name}" hasn't been defined server-side`))
					lastTime = nil
				end

				task.wait()
			end

			for _, v4 in ipairs(v3) do
				if v4.is_disconnected == false then
					v4.real_connection = child.OnClientEvent:Connect(v4.fn)
				end
			end

			object.RemoteEvent = child
			v3 = nil
		end

		if parent == nil then
			local eventConnection = nil
			eventConnection = bindableEvent.Event:Connect(function()
				eventConnection:Disconnect()
				on_container_ready()
			end)
		else
			task.spawn(on_container_ready)
		end

		return object
	end
end

function Remote:FireServer(...)
	if self.RemoteEvent ~= nil then
		self.RemoteEvent:FireServer(...)
	end
end

function Remote.FireClient(_)
	error((`[{script.Name}]: Can't use "FireClient" client-side`))
end

function Remote.FireAllClients(_)
	error((`[{script.Name}]: Can't use "FireAllClients" client-side`))
end

return Remote