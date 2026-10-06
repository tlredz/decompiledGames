local RunService = game:GetService("RunService")
local wallyInstanceManager = require(script.Parent.Parent.Parent.wallyInstanceManager)
require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)
local RecycledSpawn = require(script.Parent.Parent.Utilities.RecycledSpawn)
local version = require(script.Parent.Parent.version)
local v = {}
local total = 0
local v2 = {}
local v3 = {}
local ClientProcess = {}

function ClientProcess.start()
	debug.setmemorycategory("BridgeNet2")
	Output.log((`Loading client version {version}`))
	local v4 = wallyInstanceManager.waitForInstance(script.Parent.Parent.Parent, "dataRemoteEvent", 1)
	local v5 = wallyInstanceManager.waitForInstance(script.Parent.Parent.Parent, "metaRemoteEvent", 1)
	v4.OnClientEvent:Connect(function(p)
		table.insert(v2, p)
	end)
	RunService.PostSimulation:Connect(function()
		debug.profilebegin("BridgeNet2")

		if total > 0 then
			v4:FireServer({ table.unpack(v, 1, total) })
			total = 0
			table.clear(v)
		end

		debug.profilebegin("BridgeNet2:Receive")

		for _, v6 in v2 do
			for k, v7 in v6 do
				local v8 = v3[k]

				if not v8 then
					continue
				end

				if #v8 == 1 then
					local v9 = v8[1]

					if #v7 == 0 then
						RecycledSpawn(v9)
					else
						for _, v10 in v7 do
							RecycledSpawn(v9, v10)
						end
					end
				else
					local clone = table.clone(v8)

					if #v7 == 0 then
						for _, v9 in clone do
							RecycledSpawn(v9)
						end
					else
						for _, v9 in clone do
							for _, v10 in v7 do
								RecycledSpawn(v9, v10)
							end
						end
					end
				end
			end
		end

		table.clear(v2)
		debug.profileend()
	end)
	task.spawn(function()
		for _ = 1, 15 do
			task.wait()
		end

		v5:FireServer("1")
	end)
	Output.log("Loaded")
end

function ClientProcess.registerBridge(p)
	if not v3[p] then
		v3[p] = {}
	end
end

function ClientProcess.addToQueue(p, p2)
	v[total + 1] = p2
	v[total + 2] = p
	total += 2
end

function ClientProcess.connect(p, callback)
	table.insert(v3[p], callback)
	return function()
		local index = table.find(v3[p], callback)

		if index then
			table.remove(v3[p], index)
		end
	end
end

return ClientProcess