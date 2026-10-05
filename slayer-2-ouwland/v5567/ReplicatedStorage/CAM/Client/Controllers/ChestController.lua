local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.CAM.Global.Types.ChestTypes)
local LiveConfig = require(ReplicatedStorage.CAM.Global.LiveConfig)
local ChestAnimations = require(script.ChestAnimations)
local ChestSeal = require(script.ChestSeal)
local chest = gameSettings.Tags.Chest
local v = {}
local v2 = {}
local connections = {}
local v3 = nil
local flag = false

local function onChestAdded(model)
	local chestGuid = model:GetAttribute("ChestGuid")

	if typeof(chestGuid) == "string" then
		local v4 = v[chestGuid]

		if v4 and v4.state == "Opened" then
			model:SetAttribute("IsOpen", true)
		end
	end

	task.spawn(ChestAnimations.track, model)
	task.spawn(ChestSeal.track, model)
end

local ChestController = {}

function ChestController.handleState(p)
	if p.state == "Despawned" then
		v[p.chestGuid] = nil
	else
		v[p.chestGuid] = p
	end
end

function ChestController.start()
	if flag then
		return
	end

	flag = true

	local function applyIds(chestsLootTable)
		local v4 = {}

		if chestsLootTable then
			for k in chestsLootTable do
				v4[#v4 + 1] = k
			end

			table.sort(v4)
		end

		v2 = v4
	end

	v3 = LiveConfig.listen("ChestsLootTable", applyIds)
	applyIds(LiveConfig.get("ChestsLootTable"))

	for _, model in CollectionService:GetTagged(chest) do
		if model:IsA("Model") then
			onChestAdded(model)
		end
	end

	connections[#connections + 1] = CollectionService:GetInstanceAddedSignal(chest):Connect(function(model)
		if model:IsA("Model") then
			onChestAdded(model)
		end
	end)
end

function ChestController.teardown()
	flag = false

	if v3 then
		v3()
		v3 = nil
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	v = {}
	v2 = {}
	ChestAnimations.teardown()
	ChestSeal.teardown()
end

function ChestController.getChestIds()
	return v2
end

return ChestController