local RunService = game:GetService("RunService")
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local PlayerDataUtil = {}
local DragonNames = require(game.ReplicatedStorage.Modules.Asset.DragonNames)
local now = 1
local v = nil
local localPlayer = game.Players.LocalPlayer

function PlayerDataUtil.getEquippedFruit(p)
	local v2 = {}

	if p then
		v2.DevilFruit = p.DevilFruit
		v2.DragonType = p.DragonType
	else
		local RunService2 = game:GetService("RunService")

		if RunService2:IsServer() then
			task.spawn(error, (`data is nil: {debug.traceback()}`))
		end
	end

	local RunService2 = game:GetService("RunService")
	local v3 = RunService2:IsClient() and PlayerDataUtil.getDevilFruitInstance(localPlayer)

	if v3 then
		if v2.DevilFruit == nil then
			v2.DevilFruit = v3.Value
		end

		if v2.DragonType == nil then
			v2.DragonType = v3:GetAttribute("DragonType")
		end
	end

	if v2.DevilFruit ~= DragonNames.Permanent or not v2.DragonType then
		return v2.DevilFruit or ""
	end

	if v2.DragonType == "East" then
		return DragonNames.East
	end

	if v2.DragonType == "West" then
		return DragonNames.West
	else
		warn((`Dragon type is neither east nor west?? {v2.DragonType}`))
	end

	return v2.DevilFruit or ""
end

function PlayerDataUtil.isFruitOwned(p, p2: string, flag: boolean?)
	assert(p2, "Needs fruitName")
	local robuxFruits = p.RobuxFruits

	if RunService:IsClient() and RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		if robuxFruits then
			local robuxFruits2 = v or {}

			for k, robuxFruit in pairs(robuxFruits) do
				robuxFruits2[k] = robuxFruit
			end

			v = robuxFruits2
		else
			local Net

			if v then
				if not v[p2] and (flag and 0 or 3) < tick() - now then
					now = tick()
					Net = require(game.ReplicatedStorage.Modules.Net)
					v = Net:RemoteFunction("ReadPlayerData"):InvokeServer("RobuxFruits")
					now = tick()
				end
			else
				now = tick()
				Net = require(game.ReplicatedStorage.Modules.Net)
				v = Net:RemoteFunction("ReadPlayerData"):InvokeServer("RobuxFruits")
				now = tick()
			end
		end

		robuxFruits = v

		if not robuxFruits then
			print("No fruits")
			return false
		end
	end

	assert(robuxFruits, "Needs data.RobuxFruits")

	if (p2 == DragonNames.East or p2 == DragonNames.West) and robuxFruits[DragonNames.Permanent] then
		return true
	end

	return robuxFruits[p2] == true
end

function PlayerDataUtil.isFruitAccessible(p, p2: string)
	local fruitEquipped = PlayerDataUtil.isFruitEquipped(p, p2)
	return not fruitEquipped and PlayerDataUtil.isFruitOwned(p, p2) and true or fruitEquipped
end

function PlayerDataUtil.isFruitEquipped(p, value)
	local equippedFruit = PlayerDataUtil.getEquippedFruit(p)
	local v2 = {}

	if typeof(value) == "string" then
		table.insert(v2, value)
	else
		v2 = value
	end

	return table.find(v2, equippedFruit) ~= nil
end

function PlayerDataUtil.getDataInstance(instance)
	local dataLoaded = instance:FindFirstChild("DataLoaded")
	local data = instance:FindFirstChild("Data")

	if dataLoaded and data then
		return assert(data:IsA("Folder")) and data or nil
	end

	return nil
end

function PlayerDataUtil.getBeliInstance(p)
	local dataInstance = PlayerDataUtil.getDataInstance(p)
	local beli = dataInstance and dataInstance:FindFirstChild("Beli")

	if beli then
		return assert(beli:IsA("IntValue")) and beli or nil
	end

	return nil
end

function PlayerDataUtil.getFragmentsInstance(p)
	local dataInstance = PlayerDataUtil.getDataInstance(p)
	local fragments = dataInstance and dataInstance:FindFirstChild("Fragments")

	if fragments then
		return assert(fragments:IsA("IntValue")) and fragments or nil
	end

	return nil
end

function PlayerDataUtil.getDevilFruitInstance(p)
	local dataInstance = PlayerDataUtil.getDataInstance(p)
	local devilFruit = dataInstance and dataInstance:FindFirstChild("DevilFruit")

	if devilFruit then
		return assert(devilFruit:IsA("StringValue")) and devilFruit or nil
	end

	return nil
end

function PlayerDataUtil.waitForDataFolderReady(instance, callback)
	local RunService2 = game:GetService("RunService")
	assert(RunService2:IsClient())
	local childAddedConnection = nil
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanup()
		flag = true

		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		childAddedConnection = nil
	end

	local v2 = nil
	local checkAndResolve

	checkAndResolve = function()
		if flag then
			return
		end

		v2 = PlayerDataUtil.getDataInstance(instance)

		if v2 then
			cleanup() -- equivalent call inferred; original call site unknown
			callback(v2)
		elseif not childAddedConnection then
			childAddedConnection = instance.ChildAdded:Connect(checkAndResolve)
		end
	end

	task.defer(checkAndResolve)
	return cleanup
end

return PlayerDataUtil