local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local class = {}
class.__index = class

if RunService:IsServer() then
	function class:_pull()
		local sortedAsync = nil
		local success, result = pcall(function()
			if self.DataStore then
				sortedAsync = self.DataStore:GetSortedAsync(false, 10)
			end
		end)

		if not (success and sortedAsync) then
			print("Failed to pull from ordered datastore: " .. tostring(result))
		end

		return sortedAsync
	end

	function class:_replicate(object)
		local currentPage = object:GetCurrentPage()

		for i = 1, 10 do
			local v = currentPage[i]

			if v then
				local key = tonumber(v.key)
				local value = v.value or 0
				self.Folder:SetAttribute(tostring(i), string.format("%d,%d", key, value))
			else
				self.Folder:SetAttribute(tostring(i), "-,-")
			end
		end
	end

	function class:_init()
		while not self.Destroyed do
			task.wait(10)

			if self.Destroyed then
				break
			end

			local _pull = self:_pull()

			if _pull then
				self:_replicate(_pull)
			end

			task.wait(50)
		end
	end

	function class.Set(p, p2, p3)
		local success = nil

		for i = 1, 3 do
			local result
			success, result = pcall(function()
				p.DataStore:SetAsync(p2, p3)
			end)

			if success then
				return true
			end

			warn(("Failed to update OrderedDataStore for %s (attempt %d): %s"):format(p2, i, result))
			task.wait(1)
		end

		return success
	end

	function class:Destroy()
		self.Destroyed = true
	end

	function class.new(name: string)
		assert(name and typeof(name) == "string", "Global leaderboard must receive string key")
		local self = setmetatable({}, class)
		local success, result = pcall(function()
			return DataStoreService:GetOrderedDataStore(name)
		end)

		if not success then
			print("Failed to load global datastore: " .. tostring(result))
			return
		end

		self.DataStore = result
		self.Folder = Instance.new("Folder")
		self.Folder.Name = name
		self.Folder.Parent = script
		self.Destroyed = false
		task.spawn(self._init, self)
		return self
	end

	return class
else
	local PlayerCache = require(script.Parent:WaitForChild("PlayerCache"))

	function class.Pull(p)
		local attributes = p.Folder:GetAttributes()
		local result = {}

		for k, attribute in pairs(attributes) do
			local v = tonumber(k)
			local v2, v3 = table.unpack(attribute:split(","))

			if tonumber(v2) and tonumber(v3) then
				result[v] = {
					Name = PlayerCache.fetchPlayerNameFromCache((tonumber(v2))),
					Value = tonumber(v3)
				}
			else
				result[v] = {
					Name = "---",
					Value = "-"
				}
			end
		end

		return result
	end

	function class._init(_) end

	function class:Destroy()
		self.Destroyed = true
	end

	function class.new(childName: string)
		assert(childName and typeof(childName) == "string", "Client Global leaderboard must receive string key")
		local child = script:WaitForChild(childName, 99)

		if not child then
			print("Could not find client folder for " .. tostring(childName))
			return
		end

		local self = setmetatable({}, class)
		self.Folder = child
		self.Destroyed = false
		task.spawn(self._init, self)
		return self
	end

	return class
end