local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ProximityPromptShared = require(ReplicatedStorage.Modules.Client.Interactables.ProximityPromptShared)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "DressUp"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._isEditorOpen = false
end

function v:_SetPromptEnabled(enabled: boolean)
	if self._interactionPrompt ~= nil then
		self._interactionPrompt:SetEnabled(enabled)
	elseif self._nativePrompt ~= nil then
		self._nativePrompt.Enabled = enabled
	end
end

function v:_OnClosing()
	if self._isEditorOpen ~= true then
		return
	end

	self._isEditorOpen = false
	local houseKey = Players.LocalPlayer.PlayerGui:WaitForChild("NoResetGUIHandler"):WaitForChild("HouseKey")
	houseKey.House.Value.Visible = true
	self:_SetPromptEnabled(true)
end

function v:_OpenAvatarEditor(p)
	local character = Players.LocalPlayer.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local seatPart = humanoid.SeatPart

	if seatPart ~= nil and seatPart:IsDescendantOf(Workspace.Vehicles) or PanelController.IsOpen(
		"NoResetGUIHandler",
		"AvatarEditorMenu"
	) then
		return
	end

	local waitForComponent = ComponentUtil.FindAndWaitForComponentByTag(nil, "AvatarEditorMenu", false)

	if waitForComponent == nil then
		return
	end

	local noResetGUIHandler = p.PlayerGui:WaitForChild("NoResetGUIHandler")
	waitForComponent.InitialCategory = "Accessories"
	PanelController.OpenPanelByContext("NoResetGUIHandler", "AvatarEditorMenu")
	PanelController.ToggleGroup("TopDetails", false)
	local houseKey = noResetGUIHandler:WaitForChild("HouseKey")
	houseKey.House.Value.Visible = false
	self._isEditorOpen = true
	self:_SetPromptEnabled(false)
end

function v:Start()
	local instance = self.Instance
	local proximityPrompt = instance:FindFirstChildOfClass("ProximityPrompt")
	self._nativePrompt = proximityPrompt
	local v2 = PanelController.WaitForPanel("NoResetGUIHandler", "AvatarEditorMenu")
	v2:RegisterListener(self, v2.Events.Closing, function(_)
		self:_OnClosing()
	end)

	if CollectionService:HasTag(instance, ProximityPromptShared.NEW_SYSTEM_TAG) == true then
		if CollectionService:HasTag(instance, "InteractionPrompt") == false then
			instance:AddTag("InteractionPrompt")
		end

		if instance:GetAttribute("PromptText") == nil then
			instance:SetAttribute("PromptText", proximityPrompt == nil and "Dress up" or proximityPrompt.ActionText)
		end

		if instance:GetAttribute("InteractDistance") == nil then
			instance:SetAttribute(
				"InteractDistance",
				proximityPrompt == nil and 6 or proximityPrompt.MaxActivationDistance
			)
		end

		if proximityPrompt ~= nil then
			proximityPrompt.Enabled = false
		end

		self._Janitor:AddPromise(InteractionPrompt:WaitForInstance(instance):andThen(function(interactionPrompt)
			self._interactionPrompt = interactionPrompt
			self._Janitor:Add(interactionPrompt.Interacted:Connect(function()
				self:_OpenAvatarEditor(Players.LocalPlayer)
			end))
		end))
	elseif proximityPrompt == nil then
		warn("No child ProximityPrompt on DressUp component")
	else
		self._Janitor:Add(proximityPrompt.Triggered:Connect(function(player)
			self:_OpenAvatarEditor(player)
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v