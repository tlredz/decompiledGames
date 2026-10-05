local RunService = game:GetService("RunService")
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local React = require(game.ReplicatedStorage.Packages.React)
local Net = RunService:IsRunning() and require(game.ReplicatedStorage.Modules.Net) or nil
local Map = require(game.ReplicatedStorage.Definitions.Map)
local useTaskPool = require(game.ReplicatedStorage.React.Hooks.useTaskPool)
local useGlobalState = require(game.ReplicatedStorage.React.Hooks.useGlobalState)
require(game.ReplicatedStorage.React.Hooks.Island.useAll)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local v

if Net then
	v = Net:RemoteFunction("RequestBonusMomentReplication") or nil
else
	v = nil
end

local v2 = Net and Net:RemoteEvent("OnBonusMomentReplicatedChange") or nil
return function(p, p2, p3: string?)
	local v3 = useTaskPool("useBonusMomentsRequest", true)
	local current, v5 = useGlobalState("useBonusMoments", {})
	local useRef = React.useRef(current)
	useRef.current = current
	React.useEffect(function()
		if v3 and v then
			local flag = false
			task.spawn(function()
				local v6 = v:InvokeServer({
					Type = "GetMomentProgress"
				})

				if flag then
					return
				end

				assert(v6.Type == "GetMomentProgress", (`bad response "{v6.Type}"`))
				TableUtil.deepFreeze(v6.Data)
				v5(v6.Data)
			end)
			return function()
				flag = true
			end
		else
			return function() end
		end
	end, { v3 })
	React.useEffect(function()
		if v3 and v2 then
			local onClientEventConnection = v2.OnClientEvent:Connect(function(data)
				assert(data.Type == "OnCompletionChanged", (`unknown type: {data.Type}`))
				assert(Map.fromAddress(data.Address).Type == "BonusMoment", (`bad address "{data.Type}"`))
				TableUtil.deepFreeze(data.Data)
				v5(data.Data)
			end)
			return function()
				onClientEventConnection:Disconnect()
			end
		else
			return function() end
		end
	end, { v3 })
	return React.useMemo(function()
		local result = {}

		for k, isCompleted in current do
			local v7 = Map.fromAddress(k)
			assert(v7.Type == "BonusMoment", (`bad address "{v7.Type}"`))
			local definition = v7.Definition

			if not ((not p or definition.Index.Map == p) and (not p2 or definition.Index.Island == p2) and (not p3 or definition.Index.Key == p3)) then
				continue
			end

			local v8 = {
				Sea = definition.Index.Map,
				Address = Map.getAddress(definition),
				IslandKey = definition.Index.Island,
				Name = definition.Index.Key,
				IsCompleted = isCompleted
			}
			table.freeze(v8)
			table.insert(result, v8)
		end

		table.freeze(result)
		return result
	end, {
		p,
		p2,
		p3,
		current
	})
end