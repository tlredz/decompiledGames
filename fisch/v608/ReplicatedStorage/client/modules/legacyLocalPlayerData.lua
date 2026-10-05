local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local luauSignal = require(ReplicatedStorage.packages.luauSignal)
local dataTemplate = require(ReplicatedStorage.shared.dataTemplate)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local localPlayer = Players.LocalPlayer
local LegacyLocalPlayerData = {
	loaded = luauSignal(),
	folder = nil,
	data = table.freeze(table.clone(dataTemplate)),
	forPublicPlayer = function(p, value: number?)
		return ReplicatedStorage.publicPlayerData:WaitForChild(p.Name, value or 60)
	end
}

function LegacyLocalPlayerData.init()
	LegacyLocalPlayerData.folder = workspace.PlayerStats:WaitForChild(localPlayer.Name, 1800):WaitForChild("T"):WaitForChild(localPlayer.Name)
	LegacyLocalPlayerData.loaded:fire()
	local folder = LegacyLocalPlayerData.folder
	assert(folder, "luau")
	local newdata = folder:WaitForChild("Stats"):WaitForChild("newdata")
	assert(newdata:IsA("StringValue"), "luau")
	LegacyLocalPlayerData._onNewDataChanged(newdata.Value)
	newdata.Changed:Connect(LegacyLocalPlayerData._onNewDataChanged)
end

function LegacyLocalPlayerData._onNewDataChanged(json: string)
	LegacyLocalPlayerData.data = table.freeze(HttpService:JSONDecode(json))
end

function LegacyLocalPlayerData.fetch()
	if not LegacyLocalPlayerData.folder then
		LegacyLocalPlayerData.loaded:wait()
	end

	return LegacyLocalPlayerData.folder
end

function LegacyLocalPlayerData.fetchWithProfile()
	if not LegacyLocalPlayerData.folder then
		LegacyLocalPlayerData.loaded:wait()
	end

	DataController.PlayerDataReplicator:WaitForLoaded()
	return LegacyLocalPlayerData.folder, DataController.PlayerDataReplicator
end

function LegacyLocalPlayerData.onFieldNameChanged(_: string) end

return LegacyLocalPlayerData