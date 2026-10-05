local ABLazyPanelController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Modules.Client.UI.LazyPanels)
require(ReplicatedStorage.Modules.Client.UI.PanelController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
require(GameSdkShared.Modules.ABTest)
local Remotes = require(ReplicatedStorage.Packages.Remotes)

function ABLazyPanelController.FrameworkInit() end

function ABLazyPanelController.LoadABLazyPanel(p: string, p2: string)
	local v, folder = Remotes.invokeServer("LoadABLazyPanel", p, p2)

	if not v then
		error("Failed to load AB lazy panel: " .. tostring(p) .. " " .. tostring(p2))
	end

	local descendantCount = folder:GetAttribute("DescendantCount")

	while not descendantCount do
		RunService.RenderStepped:Wait()
		descendantCount = folder:GetAttribute("DescendantCount")
	end

	while #folder:GetDescendants() < descendantCount do
		RunService.RenderStepped:Wait()
	end

	local clone = folder:Clone()

	for _, descendant in clone:GetDescendants() do
		if not descendant:HasTag("__Panel") then
			continue
		end

		descendant:AddTag("Panel")
		descendant:RemoveTag("__Panel")
	end

	Remotes.fireServer("ClientReceivedABLazyPanel", p, p2)
	return clone
end

function ABLazyPanelController.FrameworkStart() end

return ABLazyPanelController