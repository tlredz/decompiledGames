local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BanLibrary = require(ReplicatedStorage.Modules.BanLibrary)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local banLogSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("BanLogSlot")
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
	local banHistory = self._ban_data.BanHistory or {}
	self.EmptyText.Visible = #banHistory == 0
	self.List.Visible = not self.EmptyText.Visible

	for _, v in pairs(banHistory) do
		local clone = banLogSlot:Clone()
		clone.Picture.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, (tostring(v.Moderator)))
		clone.Date.Text = v.Date
		clone.Duration.Text = v.Duration and v.Duration >= BanLibrary.PERMANENT_BAN_DURATION and "∞" or not v.Duration and "" or v.Duration .. "d" or ""
		clone.Moderator.Text = "• • •"
		clone.Reason.Text = v.Reason
		clone.Reason.TextColor3 = BanLibrary:IsBanLogANote(v) and Color3.fromRGB(127, 127, 127) or BanLibrary:IsBanLogABan(v) and Color3.fromRGB(
			255,
			50,
			50
		) or Color3.fromRGB(100, 255, 50)
		clone.Parent = self.Container
		local v3 = v
		task.spawn(function()
			local moderator = clone.Moderator
			local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, v3.Moderator)

			if success then
				moderator.Text = nameFromUserIdAsync
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