local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local keybindSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("KeybindSlot")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._objects = {}
	self._generate_hashes = {}
	self:_Init()
	return self
end

function class:_ObjectRemoved(p2)
	self._generate_hashes[p2] = (self._generate_hashes[p2] or 0) + 1

	if self._objects[p2] then
		self._objects[p2].Slot:Destroy()
		self._objects[p2] = nil
	end
end

function class:_ObjectAdded(parent)
	self:_ObjectRemoved(parent)

	if not (parent:IsDescendantOf(Players.LocalPlayer.PlayerGui) or parent:IsDescendantOf(workspace) or parent:IsDescendantOf(ReplicatedStorage) or parent:IsDescendantOf(Players.LocalPlayer.PlayerScripts.Assets.Temp)) then
		return
	end

	local _generate_hash = self._generate_hashes[parent]
	local inputName = parent:GetAttribute("InputName")
	local enumType = parent:GetAttribute("EnumType")
	local enumName = parent:GetAttribute("EnumName")
	local inputIcons, pressedIcon, v2, enum

	if enumType and enumType ~= "" and enumName and enumName ~= "" then
		inputIcons, pressedIcon, v2 = InputLibrary:GetInputIcons(enumType, enumName)
		enum = Enum[enumType][enumName]
	else
		if not inputName or inputName == "" then
			return
		end

		inputIcons, pressedIcon, v2 = InputLibrary:GetInputIconsByInputName(inputName)
		enum = InputLibrary:FindFirstEnum(inputName)
	end

	if not (enum and _generate_hash == self._generate_hashes[parent]) then
		return
	end

	local clone = keybindSlot:Clone()
	clone.Icon.Image = inputIcons
	clone.Icon.Title.Text = v2
	clone.Name = _generate_hash
	clone.Parent = parent
	self._objects[parent] = {
		Enum = enum,
		Icon = inputIcons,
		PressedIcon = pressedIcon,
		InputString = v2,
		Slot = clone
	}
end

function class:_AddAllObjects()
	for _, v in pairs(CollectionService:GetTagged("UIKeybindContainer")) do
		self:_ObjectAdded(v)
	end
end

function class:_Init()
	CollectionService:GetInstanceRemovedSignal("UIKeybindContainer"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)
	CollectionService:GetInstanceAddedSignal("UIKeybindContainer"):Connect(function(p)
		self:_ObjectAdded(p)
	end)
	UserInputService.InputBegan:Connect(function(input)
		for _, _object in pairs(self._objects) do
			if not (_object.Enum == input.KeyCode or _object.Enum == input.UserInputType) then
				continue
			end

			_object.Slot.Icon.Image = _object.PressedIcon
			_object.Slot.Icon.Title.Position = UDim2.new(0.5, 0, 0.525, 0)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		for _, _object in pairs(self._objects) do
			if not (_object.Enum == input.KeyCode or _object.Enum == input.UserInputType) then
				continue
			end

			_object.Slot.Icon.Image = _object.Icon
			_object.Slot.Icon.Title.Position = UDim2.new(0.5, 0, 0.45, 0)
		end
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_AddAllObjects()
	end)

	for k, v in pairs(SettingsLibrary.Info) do
		if v.InputType == "Hotkey" then
			PlayerDataController:GetSettingChangedSignal(k):Connect(function()
				self:_AddAllObjects()
			end)
		end
	end

	task.spawn(self._AddAllObjects, self)
end

return class._new()