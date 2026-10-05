local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OfflineItem = require(ReplicatedStorage.Modules.Shared.Item.OfflineItem)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local BaseGamepassItem = {}
BaseGamepassItem.__index = BaseGamepassItem
BaseGamepassItem.Inherits = { OfflineItem }

function BaseGamepassItem.Cast(p)
	return p
end

function BaseGamepassItem.new(gamepasses, id: string, displayName: string)
	return (setmetatable({
		id = id,
		gamepasses = gamepasses,
		displayName = displayName
	}, BaseGamepassItem))
end

function BaseGamepassItem.GetName(p)
	return p.id
end

function BaseGamepassItem.GetDisplayName(p)
	return p.displayName or p.id
end

function BaseGamepassItem.IsUnlockedServer(p, p2)
	local ServerScriptService = game:GetService("ServerScriptService")
	local GamepassService = require(ServerScriptService.Modules.PlayerData.GamepassService)

	for _, gamepass in p.gamepasses do
		if GamepassService.IsPermanentlyOwned(p2, gamepass) then
			return true
		end
	end

	return false
end

function BaseGamepassItem:IsUnlockedClient()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)

	for _, gamepass in self.gamepasses do
		if GamepassController.IsPermanentlyOwned(gamepass) then
			return true
		end
	end

	return false
end

function BaseGamepassItem:IsUnlockedOrJustBoughtClient(p: number?)
	if self:IsUnlockedClient() then
		return true
	end

	for _, gamepass in self.gamepasses do
		if Gamepasses.GetId(gamepass) == p then
			return true
		end
	end

	return false
end

return BaseGamepassItem