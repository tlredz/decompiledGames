local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local RunService2 = game:GetService("RunService")
local isClient = RunService2:IsClient()
local ClientResourceLoader = {}

repeat
	task.wait()
	local Global = require(game.ReplicatedStorage.Global)
until Global.TestGameWarn or GlobalUtil.FFlags.IsUnitTest == true

local testGameWarn

if GlobalUtil.FFlags.IsUnitTest == false then
	local Global = require(game.ReplicatedStorage.Global)
	testGameWarn = Global.TestGameWarn
else
	testGameWarn = function() end
end

ClientResourceLoader.ContainerInstances = {}
ClientResourceLoader.Containers = {}
ClientResourceLoader.ClientsUsingResources = {}
local v = {}
local v2 = {
	__index = v
}

local function MakeContainer(containerInstance, name)
	local self = setmetatable({
		ContainerInstance = containerInstance,
		ContainerName = name,
		LoadedResources = {},
		ResourceLocks = setmetatable({}, {
			__mode = "v"
		}),
		StaticResources = {},
		OnlyMatchTopLevel = true,
		Processing = {}
	}, v2)

	if isClient then
		setmetatable(self.LoadedResources, {
			__mode = "kv"
		})
	end

	ClientResourceLoader.Containers[name] = self

	if not isServer then
		return self
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	self.ClientContainer = Instance.new("Folder", ReplicatedStorage:WaitForChild("StreamedResourcesFolder"))
	self.ClientContainer.Name = name
	local folder = Instance.new("Folder", self.ClientContainer)
	folder.Name = "___Processing"
	self.ProcessingDummy = folder
	return self
end

if isServer and GlobalUtil.FFlags.IsUnitTest == false then
	local folder = Instance.new("Folder", game.ServerStorage)
	folder.Name = "ServerResourcesFolder"
	local folder_2 = Instance.new("Folder", game.ReplicatedStorage)
	folder_2.Name = "StreamedResourcesFolder"

	function ClientResourceLoader:RegisterServerResource(p2)
		if ClientResourceLoader.Containers[p2] then
			return ClientResourceLoader.Containers[p2]
		end

		if not isServer then
			return
		end

		ClientResourceLoader.ContainerInstances[p2] = self
		self.Parent = folder
		return (MakeContainer(self, p2))
	end

	function ClientResourceLoader.LockObjects(p, ...)
		local container = ClientResourceLoader.Containers[p]
		local result = {}

		for _, name in { ... } do
			local v4 = {
				name = name
			}
			table.insert(result, v4)
			table.insert(container.ResourceLocks, v4)
			v4.resource = container:LoadResource(name, true)
		end

		return result
	end

	function ClientResourceLoader.BindResourcesToScript(instance, p, ...)
		local v3 = ClientResourceLoader.LockObjects(p, ...)
		local ancestryChangedConnection = nil
		ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				v3 = nil
				ancestryChangedConnection:Destroy()
			end
		end)
	end

	function ClientResourceLoader.BindContainersToScript(instance, items)
		if isClient then
			error("Can't bind resources from client")
		end

		for k, list in items do
			local v3 = ClientResourceLoader.LockObjects(k, unpack(list))
			local ancestryChangedConnection = nil
			ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					v3 = nil
					ancestryChangedConnection:Destroy()
				end
			end)
		end
	end

	local function PlayerAdded(p)
		ClientResourceLoader.ClientsUsingResources[p] = {}
	end

	game.Players.PlayerAdded:Connect(PlayerAdded)
	game.Players.PlayerRemoving:Connect(function(player)
		ClientResourceLoader.ClientsUsingResources[player] = nil
	end)

	function v:KeepLoaded(...)
		for _, v3 in { ... } do
			self.StaticResources[v3] = self:LoadResource(v3)
		end
	end

	function v.StreamToPlayer(_, _, _) end

	function v:MirrorHierarchy(value)
		local containerInstance = self.ContainerInstance
		local clientContainer = self.ClientContainer
		local v3 = {}
		local v4 = nil
		local v5 = nil

		for k in string.gmatch(value, "([^.]+)") do
			table.insert(v3, k)
		end

		if self.OnlyMatchTopLevel then
			v5 = containerInstance
			containerInstance = (containerInstance or self.ContainerInstance):FindFirstChild(v3[1])
			v4 = clientContainer
			clientContainer = (clientContainer or self.ClientContainer):FindFirstChild(v3[1])
		else
			for i, childName in ipairs(v3) do
				local folder2 = (containerInstance or self.ContainerInstance):FindFirstChild(childName)
				local child = (clientContainer or self.ClientContainer):FindFirstChild(childName)

				if folder2:IsA("Folder") and not child and i < #v3 then
					local folder3 = Instance.new("Folder", clientContainer or self.ClientContainer)
					folder3.Name = childName
					v5 = containerInstance
					containerInstance = folder2
					v4 = clientContainer
					clientContainer = folder3
				else
					v5 = containerInstance
					containerInstance = folder2
					v4 = clientContainer
					clientContainer = child
				end
			end
		end

		return containerInstance or clientContainer, v4, v5
	end

	function v:VerifyResourceExists(value)
		if self.LoadedResources[value] then
			return "IsLoaded"
		end

		local child = nil

		for childName in string.gmatch(value, "([^.]+)") do
			child = (child or self.ContainerInstance):FindFirstChild(childName)
		end

		if child then
			return "Exists", child
		end

		return false
	end

	function v:LoadResource(p, p2)
		local loadedResource = self.LoadedResources[p]

		if loadedResource then
			loadedResource.Access = tick()
			return loadedResource.Instance
		end

		local mirrorHierarchy, parent2 = self:MirrorHierarchy(p)

		if not mirrorHierarchy then
			return
		end

		local parent = mirrorHierarchy.Parent

		if self.Processing[mirrorHierarchy] then
			if p2 then
				return
			end

			self.Processing[mirrorHierarchy].Skip = true

			repeat
				task.wait()
			until not self.Processing[mirrorHierarchy]

			local loadedResource2 = self.LoadedResources[p]

			if loadedResource2 then
				loadedResource2.Access = tick()
				return loadedResource2.Instance
			end
		end

		if p2 then
			task.spawn(function()
				local v4 = {
					objects = {}
				}
				self.Processing[mirrorHierarchy] = v4

				for _, folder2 in mirrorHierarchy:GetChildren() do
					table.insert(v4.objects, folder2)
					folder2.Parent = self.ProcessingDummy

					if not v4.Skip then
						task.wait(#folder2:GetDescendants() * 0.0005)
					end
				end

				for _, object2 in v4.objects do
					object2.Parent = mirrorHierarchy
				end

				self.Processing[mirrorHierarchy] = nil
				mirrorHierarchy.Parent = parent2
				self.LoadedResources[p] = {
					Instance = mirrorHierarchy,
					Parent = parent,
					Access = tick()
				}
			end)
		else
			mirrorHierarchy.Parent = parent2
			self.LoadedResources[p] = {
				Instance = mirrorHierarchy,
				Parent = parent,
				Access = tick()
			}
		end

		return mirrorHierarchy
	end

	function v:UnloadResource(p2)
		local loadedResource = self.LoadedResources[p2]

		if loadedResource then
			loadedResource.Instance.Parent = loadedResource.Parent
			self.LoadedResources[p2] = nil
			testGameWarn("Unloaded resource", p2)
		end
	end

	function v.Increment(p, p2)
		local containerName = p.ContainerName

		for _, clientsUsingResource in ClientResourceLoader.ClientsUsingResources do
			local v3 = clientsUsingResource[containerName]

			if not v3 then
				v3 = {}
				clientsUsingResource[containerName] = v3
			end

			v3[p2] = (v3[p2] or 0) + 1
		end
	end

	function v.Decrement(p, _, p2)
		local containerName = p.ContainerName

		for _, clientsUsingResource in ClientResourceLoader.ClientsUsingResources do
			local v3 = clientsUsingResource[containerName]

			if not v3 then
				v3 = {}
				clientsUsingResource[containerName] = v3
			end

			v3[p2] = (v3[p2] or 0) - 1
		end
	end

	function v:ReclaimResources()
		local v3 = {}

		for _, resourceLock in self.ResourceLocks do
			v3[resourceLock.name] = true
		end

		for k, loadedResource in self.LoadedResources do
			local v4 = false

			if self.StaticResources[k] or v3[k] or not (loadedResource.Access < tick() - 20) then
				continue
			end

			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn("expired time, want to unload", loadedResource.Instance)

			for _, resourceLock in self.ResourceLocks do
				if resourceLock.resource ~= loadedResource.Instance then
					continue
				end

				warn("Can't unload, locked on diff path", loadedResource)
				v4 = true
			end

			if v4 then
				continue
			end

			for _, loadedResource2 in self.LoadedResources do
				if not (loadedResource ~= loadedResource2 and loadedResource.Instance == loadedResource2.Instance and loadedResource2.Access >= tick() - 20) then
					continue
				end

				v4 = true
				break
			end

			if not v4 then
				self:UnloadResource(k)
			end
		end
	end

	task.spawn(function()
		while task.wait(21) do
			for _, container in ClientResourceLoader.Containers do
				container:ReclaimResources()
			end
		end
	end)

	script.Request.OnServerInvoke = function(_, p, p2)
		local container = ClientResourceLoader.Containers[p]

		if not container then
			return
		end

		local v3 = container:VerifyResourceExists(p2)

		if v3 == "Exists" then
			container:LoadResource(p2)
			return true
		elseif v3 == "IsLoaded" then
			return true
		end

		return false, v3
	end
end

if isClient and GlobalUtil.FFlags.IsUnitTest == false then
	local streamedResourcesFolder = game.ReplicatedStorage:WaitForChild("StreamedResourcesFolder")

	function ClientResourceLoader.GetClientContainer(childName)
		local value = streamedResourcesFolder:WaitForChild(childName)

		if value:IsA("ObjectValue") then
			value = value.Value
		end

		return (MakeContainer(value, childName))
	end

	function v:GetRaw(value)
		local loadedResource = self.LoadedResources[value]

		if loadedResource then
			return loadedResource
		end

		local child = nil

		for childName in string.gmatch(value, "([^.]+)") do
			child = (child or self.ContainerInstance):FindFirstChild(childName)
		end

		return child
	end

	function v:Await(value, p2)
		local loadedResource = self.LoadedResources[value]

		if loadedResource then
			return loadedResource
		end

		local lastTime = tick()
		local child = nil

		for childName in string.gmatch(value, "([^.]+)") do
			if p2 then
				local v3 = p2 - (tick() - lastTime)
				child = (child or self.ContainerInstance):WaitForChild(childName, v3)
			else
				child = (child or self.ContainerInstance):WaitForChild(childName)
			end
		end

		if child then
			self.LoadedResources[value] = child
		end

		return child
	end

	task.spawn(function()
		while task.wait(30) do
			local loadedResources = {}

			for _, container in ClientResourceLoader.Containers do
				for _, loadedResource in container.LoadedResources do
					if not loadedResource.Parent then
						table.insert(loadedResources, loadedResource)
					end
				end
			end

			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn("Resources still loaded after server reclaimed: ", unpack(loadedResources))
		end
	end)

	function v:RequestResource(p)
		testGameWarn("Requesting resource", p)
		local v3, v4 = script.Request:InvokeServer(self.ContainerName, p)

		if v3 then
			return self:Await(p)
		end

		warn("server rejected loading resource: [", p, "] reason:", v4)
	end

	function v.Free(_, p)
		script.RemoteEvent:FireServer(p)
	end
end

function v:Get(value)
	if not isServer then
		return self:GetRaw(value) or self:RequestResource(value)
	end

	self:LoadResource(value)
	local child = nil

	for childName in string.gmatch(value, "([^.]+)") do
		child = (child or self.ClientContainer):FindFirstChild(childName)
	end

	return child
end

function ClientResourceLoader.AwaitContainer(p)
	while not ClientResourceLoader.Containers[p] do
		task.wait()
	end

	return ClientResourceLoader.Containers[p]
end

return ClientResourceLoader