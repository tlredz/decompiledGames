local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local VisualBinder = require(script.VisualBinder)
local lootDrop = gameSettings.Tags.LootDrop or "LootDrop"
local connections = {}
local LootDropController = {}

function LootDropController.start()
	for _, part in CollectionService:GetTagged(lootDrop) do
		if part:IsA("BasePart") then
			VisualBinder.attach(part)
		end
	end

	connections[#connections + 1] = CollectionService:GetInstanceAddedSignal(lootDrop):Connect(function(part)
		if part:IsA("BasePart") then
			VisualBinder.attach(part)
		end
	end)
	connections[#connections + 1] = CollectionService:GetInstanceRemovedSignal(lootDrop):Connect(function(part)
		if part:IsA("BasePart") then
			VisualBinder.cleanup(part)
		end
	end)
end

function LootDropController.teardown()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	VisualBinder.teardown()
end

return LootDropController