local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
require(ReplicatedStorage.Modules.ModerationLibrary)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local actionLogSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ActionLogSlot")
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(ban_data)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.EmptyText = self.PromptFrame:WaitForChild("Empty")
	self.List = self.PromptFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._ban_data = ban_data
	self:_Init()
	return self
end

function object:_Setup()
	local actionHistory = self._ban_data.ActionHistory or {}
	self.EmptyText.Visible = #actionHistory == 0
	self.List.Visible = not self.EmptyText.Visible

	for _, v in pairs(actionHistory) do
		local clone = actionLogSlot:Clone()
		clone.Picture.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, (tostring(v.TargetUserID)))
		clone.Date.Text = os.date("%x", v.Timestamp) .. " " .. os.date("%X", v.Timestamp)
		clone.Target.Text = "• • •"
		clone.Action.Text = v.Action
		clone.Parent = self.Container
		local v3 = v
		task.spawn(function()
			local target = clone.Target
			local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, v3.TargetUserID)

			if success then
				target.Text = nameFromUserIdAsync
			end
		end)
	end
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

return object