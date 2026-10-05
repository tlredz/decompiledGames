require(script.DungeonCameraClient)
require(script.PlayerDungeonControllerComponent)
require(game.ReplicatedStorage.Modules.Net)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = Maid.new()
require(script.NPCCallbacks)
local localPlayer = game.Players.LocalPlayer
require(game.ReplicatedStorage.DungeonShared)
require(script.DungeonHighlighter)
local parent = nil

local function onAddedToDungeon(p)
	parent = p
end

local function waitForReplicationObject(explorerGUID: string)
	local dungeonReplicationObjects = game.ReplicatedStorage:WaitForChild("DungeonReplicationObjects")

	while true do
		local child = dungeonReplicationObjects:FindFirstChild(explorerGUID, true)

		if not child then
			task.wait()
		end

		if child then
			return child
		end
	end
end

local function handleExplorerGuidChange()
	require(script.Interface)
	v:DoCleaning()
	v.onGuidChanged = task.spawn(function()
		local explorerGUID = localPlayer:GetAttribute("ExplorerGUID")
		local v2 = explorerGUID and waitForReplicationObject(explorerGUID)

		if v2 then
			parent = assert(v2.Parent).Parent
			local v3 = v
			local Interface = require(script.Interface)
			v3.Interface = Interface.setupInterface(assert(v2.Parent).Parent)
		end
	end)
end

localPlayer:GetAttributeChangedSignal("ExplorerGUID"):Connect(handleExplorerGuidChange)
task.spawn(handleExplorerGuidChange)
task.defer(function()
	require(script.ReconnectionPrompt)
end)
return {}