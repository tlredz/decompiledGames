local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HandleInvalidPlayer = require(script.Parent.HandleInvalidPlayer)
local Output = require(script.Parent.Parent.Utilities.Output)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local wallyInstanceManager = require(script.Parent.Parent.Parent.wallyInstanceManager)
require(script.Parent.Parent.Types)
local RecycledSpawn = require(script.Parent.Parent.Utilities.RecycledSpawn)
local version = require(script.Parent.Parent.version)
local ServerIdentifiers = require(script.Parent.ServerIdentifiers)
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}

local function playerAdded(p)
	v[p] = true
	v2[p] = 0
	v3[p] = {}
	v5[p] = {}
end

local ServerProcess = {}

function ServerProcess.start()
	task.spawn(function()
		debug.setmemorycategory("BridgeNet2")
		Output.log((`Loading server version {version}`))
		local v7 = wallyInstanceManager.get(script.Parent.Parent.Parent, "metaRemoteEvent")

		if not v7 then
			v7 = Instance.new("RemoteEvent")
			v7.Name = "metaRemoteEvent"
			wallyInstanceManager.add(script.Parent.Parent.Parent, v7)
		end

		local v8 = wallyInstanceManager.get(script.Parent.Parent.Parent, "dataRemoteEvent")

		if not v8 then
			v8 = Instance.new("RemoteEvent")
			v8.Name = "dataRemoteEvent"
			wallyInstanceManager.add(script.Parent.Parent.Parent, v8)
		end

		Players.PlayerAdded:Connect(playerAdded)
		Players.PlayerRemoving:Connect(function(player)
			v[player] = nil
			v2[player] = nil
			v3[player] = nil
			v5[player] = nil
		end)
		v7.OnServerEvent:Connect(function(player, p)
			if p == "1" then
				v2[player] = nil
				v8:FireClient(player, v3[player])
				v3[player] = nil
			end
		end)
		v8.OnServerEvent:Connect(function(p, p2)
			if typeof(p2) == "table" then
				table.insert(v5[p], p2)
			else
				HandleInvalidPlayer(p)
			end
		end)
		local v9 = {}

		local function addContentToQueue(p, id, content)
			local v10 = v9[p]

			if not v10 then
				v9[p] = {
					[id] = { content }
				}
			elseif v10[id] then
				table.insert(v10[id], content)
			else
				v10[id] = { content }
			end
		end

		RunService.PostSimulation:Connect(function()
			debug.profilebegin("BridgeNet2")
			debug.profilebegin("BridgeNet2:Send")

			for _, v10 in v4 do
				local kind = v10.playerContainer.kind
				local value = v10.playerContainer.value
				local id = v10.id
				local content = v10.content

				if kind == "single" then
					addContentToQueue(value, id, content)
				elseif kind == "all" then
					for k in v do
						addContentToQueue(k, id, content)
					end
				elseif kind == "except" then
					for _, v11 in value do
						v[v11] = false
					end

					for k, v11 in v do
						if v11 then
							addContentToQueue(k, id, content)
						else
							v[k] = true
						end
					end
				elseif kind == "set" then
					for _, v11 in value do
						addContentToQueue(v11, id, content)
					end
				end
			end

			for player, v10 in v9 do
				if v2[player] then
					if v3[player] then
						for k, v11 in v10 do
							if v3[player][k] then
								v3[player][k] = TableKit.MergeArrays(v3[player][k], v11)
							else
								v3[player][k] = v11
							end
						end
					else
						v3[player] = v10
					end
				else
					v8:FireClient(player, v10)
				end

				v9[player] = nil
			end

			table.clear(v4)
			debug.profileend()
			debug.profilebegin("BridgeNet2:Receive")

			for k, v10 in v5 do
				for _, v11 in v10 do
					for i = 1, #v11, 2 do
						local v12 = v11[i]
						local v13 = v11[i + 1]

						if typeof(v13) ~= "string" then
							HandleInvalidPlayer(k)
							break
						end

						local v14 = v6[v13]

						if not v14 then
							continue
						end

						for _, v15 in v14 do
							debug.profilebegin((tostring(ServerIdentifiers.deser(v13))))
							RecycledSpawn(v15, k, v12)
							debug.profileend()
						end
					end
				end

				table.clear(v5[k])
			end

			debug.profileend()
			debug.profileend()
		end)
		Output.log("Loaded")
	end)
end

function ServerProcess.addToQueue(playerContainer, id, content)
	table.insert(v4, {
		playerContainer = playerContainer,
		id = id,
		content = content
	})
end

function ServerProcess.setInvalidPlayerFunction(callback)
	HandleInvalidPlayer = callback
end

function ServerProcess.registerBridge(p: string)
	if not v6[p] then
		v6[p] = {}
	end
end

function ServerProcess.connect(p: string, p2)
	table.insert(v6[p], p2)
	return function()
		local index = table.find(v6[p], p2)
		table.remove(v6[p], index)
	end
end

return ServerProcess