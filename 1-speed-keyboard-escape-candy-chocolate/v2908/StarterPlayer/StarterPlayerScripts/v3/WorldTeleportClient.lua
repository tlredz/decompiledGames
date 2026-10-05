local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local WorldTeleportUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("WorldTeleportUISystem"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local openWorldTeleportModal = remotes:WaitForChild("OpenWorldTeleportModal")

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCloseButton(instance)
	if instance:IsDescendantOf(playerGui) then
		instance.MouseButton1Click:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end
end

for _, v in ipairs(CollectionService:GetTagged("WorldTeleportCloseBtn")) do
	if v:IsDescendantOf(playerGui) then
		v.MouseButton1Click:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end
end

CollectionService:GetInstanceAddedSignal("WorldTeleportCloseBtn"):Connect(function(p)
	task.defer(function()
		setupCloseButton(p) -- equivalent call inferred; original call site unknown
	end)
end)
openWorldTeleportModal.OnClientEvent:Connect(function(p)
	WorldTeleportUISystem:Open(p)
end)
ClientState:RegisterModalListener(function(p)
	if p then
		WorldTeleportUISystem:Refresh()
	end
end)
remotes:WaitForChild("UpdateUI").OnClientEvent:Connect(function()
	WorldTeleportUISystem:Refresh()
end)