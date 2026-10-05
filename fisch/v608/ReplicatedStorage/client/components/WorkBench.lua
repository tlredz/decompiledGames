local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local FurnitureController = require(ReplicatedStorage.client.legacyControllers.FurnitureController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local remoteEvent = Net:RemoteEvent("PersonalAquarium/Construction/RequestedOpenWorkBench")
local remoteEvent2 = Net:RemoteEvent("PersonalAquarium/Furniture/VisitorAquarium")
local v = Component.new({
	Tag = "WorkBench",
	Ancestors = { Workspace },
	Extensions = nil
})
v.OpenConstruction = Signal.new()

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

	local function isOwnWorkbench()
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

	local storage = HudController:GetSafeZone():FindFirstChild("storage")

	local function isStorageOpen()
		return storage ~= nil and storage.Visible
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

		local enabled = name == tostring(Players.LocalPlayer.UserId) and not FurnitureController.IsEditing

		if enabled then
			enabled = storage == nil or not storage.Visible
		end

		v2.Enabled = enabled
	end

	self._editConnection = FurnitureController.EditModeChanged:Connect(refreshPrompt)
	self._visitorConnection = remoteEvent2.OnClientEvent:Connect(refreshPrompt)

	if storage then
		self._storageConnection = storage:GetPropertyChangedSignal("Visible"):Connect(refreshPrompt)
	end

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

	local enabled2 = name == tostring(Players.LocalPlayer.UserId) and not FurnitureController.IsEditing

	if enabled2 then
		enabled2 = storage == nil or not storage.Visible
	end

	proximityPrompt.Enabled = enabled2
end

function v:Stop()
	if self._editConnection then
		self._editConnection:Disconnect()
		self._editConnection = nil
	end

	if self._visitorConnection then
		self._visitorConnection:Disconnect()
		self._visitorConnection = nil
	end

	if self._storageConnection then
		self._storageConnection:Disconnect()
		self._storageConnection = nil
	end
end

remoteEvent.OnClientEvent:Connect(function()
	if FurnitureController.IsEditing then
		return
	end

	local safeZone = HudController:GetSafeZone()
	local storage = safeZone:FindFirstChild("storage")

	if storage and storage.Visible then
		return
	end

	local construction = safeZone:FindFirstChild("construction")

	if construction and construction:IsA("GuiObject") then
		construction.Visible = true
	end

	v.OpenConstruction:Fire()
end)
return v