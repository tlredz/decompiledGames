local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FamilyRoles = require(ReplicatedStorage.Modules.Shared.Family.FamilyRoles)
local FamilyPlayer = {}
FamilyPlayer.__index = FamilyPlayer

function FamilyPlayer.new(player, p: string, hidden: boolean)
	local object = setmetatable({}, FamilyPlayer)
	object._Janitor = Janitor.new()
	object._player = player
	object._role = p or FamilyRoles[1]
	object._hidden = hidden

	if player.Character then
		object:CharacterAdded(player.Character)
	end

	object._Janitor:Add(player.CharacterAdded:Connect(function(character)
		object:CharacterAdded(character)
	end))
	object._Janitor:Add(RunService.RenderStepped:Connect(function()
		object:UpdateUIVisibility()
	end))
	object._raycastParams = RaycastParams.new()
	object._raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	return object
end

function FamilyPlayer:CharacterAdded(instance)
	if self._familyUI then
		self._familyUI:Destroy()
	end

	self:UpdateNameGui(self._role)

	if self._player == Players.LocalPlayer then
		return
	end

	local familyUI = self._Janitor:Add(ReplicatedStorage.FamilyBillboard:Clone())
	familyUI.Role.Text = self._role
	familyUI.Username.Text = self._player.DisplayName
	familyUI.Icon.Image = `rbxthumb://type=AvatarHeadShot&id={self._player.UserId}&w=150&h=150`
	familyUI.Adornee = instance:WaitForChild("HumanoidRootPart")
	familyUI.Enabled = true
	familyUI.Parent = Players.LocalPlayer.PlayerGui
	self:UpdateNameGui(self._role)
	self._familyUI = familyUI
end

function FamilyPlayer:UpdateRole(p: string)
	self._role = p or FamilyRoles[1]

	if self._familyUI then
		self._familyUI.Role.Text = self._role or FamilyRoles[1]
	end

	self:UpdateNameGui(self._role)
end

function FamilyPlayer:UpdateUIVisibility()
	if not self._familyUI then
		return
	end

	if self._hidden then
		self._familyUI.Enabled = false
		return
	end

	local character = self._player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	self._raycastParams.FilterDescendantsInstances = { Players.LocalPlayer.Character, character }
	local currentCamera = workspace.CurrentCamera
	local v = humanoidRootPart.Position - currentCamera.CFrame.Position
	local raycastResult = workspace:Raycast(currentCamera.CFrame.Position, v, self._raycastParams)
	local magnitude = (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude
	self._familyUI.Enabled = magnitude > 800 or raycastResult ~= nil
end

function FamilyPlayer:SetHidden(hidden: boolean)
	self._hidden = hidden

	if self._familyUI then
		self._familyUI.Enabled = not hidden
	end
end

function FamilyPlayer:UpdateNameGui(text: string)
	local character = self._player.Character

	if not character then
		return
	end

	local head = character:FindFirstChild("Head")

	if not head then
		return
	end

	local nameGUI = head:FindFirstChild("NameGUI")

	if not nameGUI then
		return
	end

	nameGUI.FamilyLabel.Text = text
end

function FamilyPlayer:Destroy()
	self:UpdateNameGui("")
	self._Janitor:Destroy()
end

return FamilyPlayer