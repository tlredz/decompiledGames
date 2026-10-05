local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local isServer = RunService:IsServer()
local RuntimeExplorerHooks = {
	Client = {},
	Server = {}
}

if not isServer then
	local client = RuntimeExplorerHooks.Client

	local function createObserverGroup()
		return {
			observers = {},
			currentValue = nil,
			changeCounter = 0,
			observe = function(self, callback)
				local v = {
					callback = callback,
					cleanFn = nil,
					stopped = false
				}
				table.insert(self.observers, v)
				task.defer(function()
					if v.stopped then
						return
					end

					self.changeCounter += 1
					local changeCounter = self.changeCounter
					local cleanFn = callback(self.currentValue)

					if not v.stopped and changeCounter == self.changeCounter then
						v.cleanFn = cleanFn
					elseif cleanFn then
						task.spawn(cleanFn)
					end
				end)
				return function()
					if v.stopped then
						return
					end

					v.stopped = true

					if v.cleanFn then
						task.spawn(v.cleanFn)
						v.cleanFn = nil
					end

					local index = table.find(self.observers, v)

					if index then
						table.remove(self.observers, index)
					end
				end
			end,
			get = function(self)
				return self.currentValue
			end,
			notify = function(self, currentValue)
				if currentValue == self.currentValue then
					return
				end

				self.currentValue = currentValue
				self.changeCounter += 1
				local changeCounter = self.changeCounter

				for _, observer in self.observers do
					if observer.stopped then
						continue
					end

					if observer.cleanFn then
						task.spawn(observer.cleanFn)
						observer.cleanFn = nil
					end

					local v = observer
					task.spawn(function()
						if v.stopped then
							return
						end

						local callback = v.callback(currentValue)

						if not v.stopped and changeCounter == self.changeCounter then
							v.cleanFn = callback
						elseif callback then
							task.spawn(callback)
						end
					end)
				end
			end
		}
	end

	local observerGroup = createObserverGroup()
	local observerGroup2 = createObserverGroup()
	local v = nil
	local v2 = nil
	local v3 = nil

	function client.ObserveSelected(_, callback)
		return observerGroup:observe(callback)
	end

	function client.GetSelected(_)
		return observerGroup:get()
	end

	function client.SelectInstance(_, p, flag: boolean?)
		assert(v, "RuntimeExplorerHooks: client not bound yet")

		if flag then
			assert(v3, "RuntimeExplorerHooks: client not bound yet")
			v3(true)
		end

		v(p)
	end

	function client.ObserveToolOpened(_, callback)
		return observerGroup2:observe(callback)
	end

	function client.IsToolOpen(_)
		return observerGroup2:get() or false
	end

	function client.OpenTool(_)
		assert(v3, "RuntimeExplorerHooks: client not bound yet")
		v3(true)
	end

	function client.CloseTool(_)
		assert(v3, "RuntimeExplorerHooks: client not bound yet")
		v3(false)
	end

	function client.ToggleTool(_)
		assert(v2 and v3, "RuntimeExplorerHooks: client not bound yet")
		v3(not v2())
	end

	function client._notifySelected(_, p)
		observerGroup:notify(p)
	end

	function client._notifyToolOpened(_, flag: boolean)
		observerGroup2:notify(flag)
	end

	function client._bindSelectFunction(_, callback)
		v = callback
	end

	function client._bindToolControl(_, callback, callback2)
		v2 = callback
		v3 = callback2
	end
end

if not isServer then
	return RuntimeExplorerHooks
end

local server = RuntimeExplorerHooks.Server
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = nil

local function cleanupAdmin(p)
	local v6 = v[p]

	if v6 then
		for _, v7 in v6 do
			if v7.stopped then
				continue
			end

			v7.stopped = true

			if not v7.cleanFn then
				continue
			end

			task.spawn(v7.cleanFn)
			v7.cleanFn = nil
		end
	end

	v[p] = nil
	v2[p] = nil
	v3[p] = nil
	local connection = v4[p]

	if connection then
		connection:Disconnect()
		v4[p] = nil
	end
end

function server.ObserveSelectedByAdmin(_, p, callback)
	if not v[p] then
		v[p] = {}
		v3[p] = 0
	end

	if not v4[p] then
		v4[p] = Players.PlayerRemoving:Connect(function(player)
			if player == p then
				cleanupAdmin(p)
			end
		end)
	end

	local v6 = {
		callback = callback,
		cleanFn = nil,
		stopped = false
	}
	table.insert(v[p], v6)
	local v7 = v2[p]

	if v7 ~= nil then
		task.defer(function()
			if v6.stopped or not v3[p] then
				return
			end

			v3[p] += 1
			local v10 = v3[p]
			local cleanFn = callback(v7)

			if not v6.stopped and v3[p] == v10 then
				v6.cleanFn = cleanFn
			elseif cleanFn then
				task.spawn(cleanFn)
			end
		end)
	end

	return function()
		if v6.stopped then
			return
		end

		v6.stopped = true

		if v6.cleanFn then
			task.spawn(v6.cleanFn)
			v6.cleanFn = nil
		end

		local v8 = v[p]

		if v8 then
			local index = table.find(v8, v6)

			if index then
				table.remove(v8, index)
			end

			if #v8 == 0 then
				v[p] = nil
				v3[p] = nil
				local connection = v4[p]

				if connection then
					connection:Disconnect()
					v4[p] = nil
				end
			end
		end
	end
end

function server.SelectInstanceForAdmin(_, p, p2, flag: boolean?)
	assert(v5, "RuntimeExplorerHooks: server not bound yet")
	v5(p, p2, flag)
end

function server._notifyAdminSelected(_, p, p2)
	if v2[p] == p2 then
		return
	end

	v2[p] = p2

	if not v3[p] then
		v3[p] = 0
	end

	v3[p] += 1
	local v7 = v3[p]
	local v8 = v[p]

	if not v8 then
		return
	end

	for _, v9 in v8 do
		if v9.stopped then
			continue
		end

		if v9.cleanFn then
			task.spawn(v9.cleanFn)
			v9.cleanFn = nil
		end

		local v10 = v9
		task.spawn(function()
			if v10.stopped then
				return
			end

			local callback = v10.callback(p2)

			if not v10.stopped and v3[p] == v7 then
				v10.cleanFn = callback
			elseif callback then
				task.spawn(callback)
			end
		end)
	end
end

function server._bindAdminSelectFunction(_, callback)
	v5 = callback
end

return RuntimeExplorerHooks