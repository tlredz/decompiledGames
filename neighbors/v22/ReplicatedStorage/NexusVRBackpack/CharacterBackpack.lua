local v = {
	[Enum.KeyCode.ButtonL3] = true,
	[Enum.KeyCode.ButtonR3] = true
}
local VRService = game:GetService("VRService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Backpack3D = require(script.Parent:WaitForChild("UI"):WaitForChild("Backpack3D"))
local CharacterBackpack = {}
CharacterBackpack.__index = CharacterBackpack

function CharacterBackpack.new(instance)
	local object = setmetatable({
		Enabled = true,
		Player = Players:GetPlayerFromCharacter(instance),
		KeyCode = Enum.KeyCode.ButtonR3,
		UserCFrame = Enum.UserCFrame.RightHand,
		Events = {}
	}, CharacterBackpack)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	while not humanoid do
		instance.ChildAdded:Wait()
		humanoid = instance:FindFirstChildOfClass("Humanoid")
	end

	object.Humanoid = humanoid
	object.Backpack = Backpack3D.new(
		object.Player:WaitForChild("PlayerGui"),
		{ instance, object.Player:WaitForChild("Backpack") }
	)
	table.insert(object.Events, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode ~= object.KeyCode or gameProcessed and not v[input.KeyCode] or #object.Backpack.Inventory.Tools == 0 then
			return
		end

		object:Open()
	end))
	table.insert(object.Events, UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode ~= object.KeyCode then
			return
		end

		object:Close()
	end))
	table.insert(object.Events, object.Humanoid.Died:Connect(function()
		object:Destroy()
	end))
	table.insert(object.Events, object.Player.CharacterAdded:Connect(function()
		object:Destroy()
	end))
	table.insert(object.Events, object.Player.CharacterRemoving:Connect(function()
		object:Destroy()
	end))
	object:SetKeyCode(Enum.KeyCode.ButtonR3)
	return object
end

function CharacterBackpack:GetBackpackCFrame()
	return Workspace.CurrentCamera:GetRenderCFrame() * UserInputService:GetUserCFrame(Enum.UserCFrame.Head):Inverse() * UserInputService:GetUserCFrame(self.UserCFrame)
end

function CharacterBackpack:GetHandPosition()
	return self:GetBackpackCFrame().Position
end

function CharacterBackpack:SetKeyCode(keyCode)
	self.KeyCode = keyCode

	if UserInputService:IsKeyDown(keyCode) then
		self:Open()
	end
end

function CharacterBackpack:SetUserCFrame(userCFrame)
	self.UserCFrame = userCFrame
end

function CharacterBackpack:Open()
	if not self.Enabled or self.Backpack.Opened then
		return
	end

	self.Backpack:Open()
	local nexusVRCharacterModelControllerApi = self.NexusVRCharacterModelControllerApi

	if nexusVRCharacterModelControllerApi then
		nexusVRCharacterModelControllerApi:DisableControllerInput(self.UserCFrame)
	end

	local v2 = (Workspace.CurrentCamera:GetRenderCFrame() * VRService:GetUserCFrame(Enum.UserCFrame.Head):Inverse()):Inverse() * self:GetBackpackCFrame()
	self.UpdateFocusEvent = RunService.RenderStepped:Connect(function()
		self.Backpack:MoveTo(Workspace.CurrentCamera:GetRenderCFrame() * VRService:GetUserCFrame(Enum.UserCFrame.Head):Inverse() * v2)
		self.Backpack:UpdateFocusedToolWorldSpace(self:GetHandPosition())
	end)
end

function CharacterBackpack:Close()
	if not self.Backpack.Opened then
		return
	end

	if self.UpdateFocusEvent then
		self.UpdateFocusEvent:Disconnect()
		self.UpdateFocusEvent = nil
	end

	local focusedTool = self.Backpack:GetFocusedTool()

	if focusedTool then
		self.Humanoid:EquipTool(focusedTool)
	else
		self.Humanoid:UnequipTools()
	end

	self.Backpack:Close()
	local nexusVRCharacterModelControllerApi = self.NexusVRCharacterModelControllerApi

	if nexusVRCharacterModelControllerApi then
		nexusVRCharacterModelControllerApi:EnableControllerInput(self.UserCFrame)
	end
end

function CharacterBackpack:Destroy()
	if self.UpdateFocusEvent then
		self.UpdateFocusEvent:Disconnect()
		self.UpdateFocusEvent = nil
	end

	for _, event in self.Events do
		event:Disconnect()
	end

	self.Events = {}

	if not self.Backpack.Opened then
		self.Backpack:Destroy()
		return
	end

	self.Backpack:Close()
	task.delay(0.1, function()
		self.Backpack:Destroy()
	end)
end

return CharacterBackpack