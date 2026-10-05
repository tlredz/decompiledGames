local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DebugLibrary = require(ReplicatedStorage.Modules.DebugLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local DebugController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("DebugController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local emptySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EmptySlot")
local settings = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Settings")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self.SettingObjects = {}
	self.HidePartyDisplay = true
	self._open_animation_disabled = true
	self:_Init()
	return self
end

function object:_Setup()
	local count = 0

	local function create_command(p2)
		local module = require(settings:WaitForChild(p2.InputType))
		local v = module.new(p2)
		v.Replicate:Connect(function()
			DebugController:Command(p2.Name, v.Value)
		end)
		v.SettingFrame.LayoutOrder = count
		v.SettingFrame.Parent = self.Container
		self.SettingObjects[p2.Name] = v
		count += 1
	end

	local function create_empty_slots(value)
		local v = value or 0

		for _ = 1, math.max(0, v - count) + 2 - (not (v < count) and 0 or (count - 1) % 2 + 1) do
			local clone = emptySlot:Clone()
			clone.LayoutOrder = count
			clone.Parent = self.Container
			count += 1
		end
	end

	local flag = false

	for _, v in pairs(DebugLibrary.Order) do
		if not DebugLibrary:IsAuthorizedToUseCommand(v.Name, PlayerDataController:Get("PermissionsRoles")) then
			continue
		end

		if v.InputType == "Divider" then
			if flag then
				create_empty_slots()

				for _ = 1, count % 2 + 2 do
					create_command(v)
				end
			end
		else
			create_command(v)
			flag = true
		end
	end

	create_empty_slots(16)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self:_Setup()
	ButtonEffect:Add(self.CloseButton)
end

return object._new()