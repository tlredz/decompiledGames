local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local v = nil
local virtualEvents = {}
local seed = nil
local bxor = bit32.bxor
local v4 = nil
local Flags = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Flags"))
local NetServer

if RunService:IsServer() and RunService:IsRunning() then
	NetServer = require(game.ServerScriptService:WaitForChild("NetServer"))
else
	NetServer = nil
end

local v5 = false

if RunService:IsRunning() then
	if isServer then
		seed = tostring(math.random(-9999999, 9999999))

		script.seed.OnServerInvoke = function()
			return seed
		end
	else
		seed, v5 = script.seed:InvokeServer()

		script.seed.OnClientInvoke = function(p, p2)
			v5 = p
			seed = p2
			v4 = seed * 2
		end
	end

	v4 = seed * 2
end

local netutil = require(script.netutil)
local getname = netutil()["1"]()

if RunService:IsRunning() then
	if RunService:IsServer() then
		function NetServer.cb(p)
			v = p
		end

		NetServer.getname = getname
		NetServer.set({
			key = v4,
			seed = seed,
			IDBASE = 909090,
			virtualEvents = virtualEvents,
			script = script
		})
	else
		repeat
			task.wait()
			pcall(function()
				local v7 = nil

				for _, child in pairs(script:GetChildren()) do
					if child:GetAttribute("Id") == nil then
						continue
					end

					v7 = child
					break
				end

				v = v7
			end)
		until v

		local replicatedStorage = game.ReplicatedStorage
		local v7 = {
			replicatedStorage.Util,
			replicatedStorage.Remotes,
			replicatedStorage.Assets,
			replicatedStorage.Common,
			replicatedStorage.FX
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function sp(p)
			p.Parent = v7[math.random(#v7)]
		end

		sp(v) -- equivalent call inferred; original call site unknown
		script.ChildAdded:Connect(function(child)
			if child:GetAttribute("Id") then
				v = child
				task.defer(function()
					sp(v) -- equivalent call inferred; original call site unknown
				end)
			end
		end)
	end
end

local function fn(childName)
	if virtualEvents[childName] then
		return virtualEvents[childName]
	end

	local child = script:WaitForChild(childName, 99)
	local v7 = {
		__OnServerEvent = {},
		__OnClientEvent = {}
	}
	v7.OnServerEvent = {
		Connect = function(self, p)
			table.insert(v7.__OnServerEvent, p)
			NetServer.connectOrganic(child, p)
		end
	}
	v7.OnClientEvent = {
		Connect = function(self, callback)
			child.OnClientEvent:Connect(function(...)
				callback(...)
			end)
		end
	}
	assert((`failed to find event {childName}`))

	function v7:FireServer(...)
		if not v5 then
			child:FireServer(...)
			return
		end

		v:FireServer(getname(childName), bxor(v:GetAttribute("Id") + 909090, v4), ...)
	end

	function v7:FireClient(player, ...)
		child:FireClient(player, ...)
	end

	function v7:FireAllClients(...)
		child:FireAllClients(...)
	end

	virtualEvents[childName] = v7
	return v7
end

local function get(p, className, flag: boolean?)
	local name = (className == "RemoteEvent" and "RE/" or "RF/") .. p

	if RunService:IsServer() or not RunService:IsRunning() then
		local instance = script:FindFirstChild(name)

		if not instance then
			instance = Instance.new(className)
			instance.Name = name
			instance.Parent = script

			if flag and Flags.ALLOW_VIRTUAL_REMOTES then
				instance:SetAttribute("Virtual", true)
			end
		end

		if instance:GetAttribute("Virtual") and Flags.ALLOW_VIRTUAL_REMOTES then
			return (fn(name))
		end

		return instance
	else
		local child = script:WaitForChild(name, 99)

		if not child then
			error(string.format("Failed to find %s: %s", className, name))
		end

		if child:GetAttribute("Virtual") and Flags.ALLOW_VIRTUAL_REMOTES then
			return (fn(name))
		end

		return child
	end
end

local Net = {}

function Net.RemoteEvent(_, p: string, flag: boolean?)
	return (get(p, "RemoteEvent", flag))
end

function Net.RemoteFunction(_, p: string)
	return (get(p, "RemoteFunction"))
end

return Net