local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local modules = ReplicatedStorage.shared.modules
local SharedStorage = require(modules.SharedStorage)
local FurnitureController = require(ReplicatedStorage.client.legacyControllers.FurnitureController)
Net:RemoteEvent("Storage/RequestedOpenStorageCrate", -1)
local remoteEvent = Net:RemoteEvent("PersonalAquarium/Furniture/VisitorAquarium")
local v = Component.new({
	Tag = SharedStorage.Constants.STORAGE_CRATE_COLLECTION_SERVICE_TAG,
	Ancestors = { Workspace },
	Extensions = nil
})

local function getAquariumIdFromAncestry(p)
	local parent = p.Parent

	while parent and parent ~= Workspace do
		if tonumber(parent.Name) then
			return parent.Name
		else
			parent = parent.Parent
		end
	end

	return nil
end

function v:Start()
	local proximityPrompt = self.Instance:FindFirstChild("ProximityPrompt", true)

	if not proximityPrompt then
		return
	end

	local function isOwnCrate()
		local parent = self.Instance.Parent
		local name

		while true do
			if not parent or parent == Workspace then
				name = nil
				break
			end

			if tonumber(parent.Name) then
				name = parent.Name
				break
			else
				parent = parent.Parent
			end
		end

		return name == tostring(Players.LocalPlayer.UserId)
	end

	local function refreshPrompt()
		local v2 = proximityPrompt
		local parent = self.Instance.Parent
		local name

		while true do
			if not parent or parent == Workspace then
				name = nil
				break
			end

			if tonumber(parent.Name) then
				name = parent.Name
				break
			else
				parent = parent.Parent
			end
		end

		v2.Enabled = name == tostring(Players.LocalPlayer.UserId) and not FurnitureController.IsEditing
	end

	self._visitorConnection = remoteEvent.OnClientEvent:Connect(refreshPrompt)
	self._editConnection = FurnitureController.EditModeChanged:Connect(refreshPrompt)
	local parent = self.Instance.Parent
	local name

	while true do
		if not parent or parent == Workspace then
			name = nil
			break
		end

		if tonumber(parent.Name) then
			name = parent.Name
			break
		else
			parent = parent.Parent
		end
	end

	proximityPrompt.Enabled = name == tostring(Players.LocalPlayer.UserId) and not FurnitureController.IsEditing
end

function v:Stop()
	if self._visitorConnection then
		self._visitorConnection:Disconnect()
		self._visitorConnection = nil
	end

	if self._editConnection then
		self._editConnection:Disconnect()
		self._editConnection = nil
	end
end

return v