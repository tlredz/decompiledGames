local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local DebugLibrary = require(ReplicatedStorage.Modules.DebugLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local object = setmetatable({}, Prompt)
object.__index = object

function object.new()
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.ConfirmButton = self.PromptFrame:WaitForChild("Confirm")
	self.BudgetText = self.PromptFrame:WaitForChild("Budget")
	self.BudgetTimerText = self.PromptFrame:WaitForChild("BudgetTimer")
	self.HeaderFrame = self.PromptFrame:WaitForChild("Header")
	self.HeaderWrapFrame = self.HeaderFrame:WaitForChild("Wrap")
	self.HeaderSkinFrame = self.HeaderFrame:WaitForChild("Skin")
	self.List = self.PromptFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.RecipientAddButton = self.Container:WaitForChild("RewardAdd"):WaitForChild("Add")
	self._reward_value_template = self.Container:WaitForChild("BugRewardRecepientSlot")
	self._reward_value_frames = {}
	self:_Init()
	return self
end

function object:Confirm()
	if #self._reward_value_frames == 0 then
		Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
		return
	end

	local success, result = pcall(
		ReplicatedStorage.Remotes.Debug.Command.InvokeServer,
		ReplicatedStorage.Remotes.Debug.Command,
		"SendBugRewards",
		self:_GetBatch(true)
	)

	if success and result then
		self:CloseRequest()
		return
	end

	warn("Failed to send rewards:", result)
	Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
end

function object:_GetBatch(p2)
	local result = {}

	for _, _reward_value_frame in pairs(self._reward_value_frames) do
		local text = _reward_value_frame.Player.Box.Text

		if text == "" and p2 then
			Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
			return
		else
			table.insert(
				result,
				{
					text,
					tonumber(_reward_value_frame.Wraps.Box.Text) or 0,
					tonumber(_reward_value_frame.Skins.Box.Text) or 0
				}
			)
		end
	end

	return result
end

function object:_UpdateBudgetText()
	local total = 0
	local total2 = 0

	for _, v in pairs(self:_GetBatch()) do
		total += v[2]
		total2 += v[3]
	end

	local v = PlayerDataController:Get("SendBugRewardsCooldown") and ServerOsTime:Get() < PlayerDataController:Get("SendBugRewardsCooldown")
	self.BudgetText.Text = string.format(
		"×%s Net Wraps   ×%s Bug Net Skins",
		v and 0 or math.max(0, DebugLibrary.MAX_NET_WRAPS_PER_CYCLE - total),
		v and 0 or math.max(0, DebugLibrary.MAX_BUG_NET_SKINS_PER_CYCLE - total2)
	)
	local budgetText = self.BudgetText
	local textColor

	if v or DebugLibrary.MAX_NET_WRAPS_PER_CYCLE < total or DebugLibrary.MAX_BUG_NET_SKINS_PER_CYCLE < total2 then
		textColor = Color3.fromRGB(255, 50, 50)
	else
		textColor = Color3.fromRGB(255, 255, 255)
	end

	budgetText.TextColor3 = textColor
	self.BudgetTimerText.Text = not v and "Bug rewards ready to be handed out!" or string.format(
		"Budget refreshes in %s",
		Utility:TimeFormat2((math.ceil(PlayerDataController:Get("SendBugRewardsCooldown") - ServerOsTime:Get())))
	)
end

function object:_UpdateBudgetTextLoop()
	while not self._destroyed do
		self:_UpdateBudgetText()
		wait(1)
	end
end

function object:_AddRewardValueFrame()
	local clone = self._reward_value_template:Clone()
	clone.Wraps.Box.Text = "1"
	clone.LayoutOrder = self._reward_value_template.LayoutOrder + #self._reward_value_frames
	clone.Close.Visible = #self._reward_value_frames > 0
	clone.Parent = self.Container
	table.insert(self._reward_value_frames, clone)
	ButtonEffect:Add(clone.Close)
	clone.Close.MouseButton1Click:Connect(function()
		clone:Destroy()
		local index = table.find(self._reward_value_frames, clone)

		if index then
			table.remove(self._reward_value_frames, index)
			self:_UpdateBudgetText()
		end
	end)

	local function update()
		clone.Wraps.Box.Text = clone.Wraps.Box.Text == "" and "" or math.clamp(
			math.floor(tonumber(clone.Wraps.Box.Text) or 0),
			0,
			DebugLibrary.MAX_NET_WRAPS_PER_PLAYER
		)
		clone.Skins.Box.Text = clone.Skins.Box.Text == "" and "" or math.clamp(
			math.floor(tonumber(clone.Skins.Box.Text) or 0),
			0,
			DebugLibrary.MAX_BUG_NET_SKINS_PER_PLAYER
		)
		self:_UpdateBudgetText()
	end

	clone.Wraps.Box:GetPropertyChangedSignal("Text"):Connect(update)
	clone.Skins.Box:GetPropertyChangedSignal("Text"):Connect(update)
	update()
	self:_UpdateBudgetText()
end

function object:_Setup()
	RewardSlot.new({
		Name = "Net",
		Quantity = 1,
		Weapon = "IsRandom"
	}):SetParent(self.HeaderWrapFrame)
	RewardSlot.new({
		Name = "Bug Net",
		Quantity = 1,
		Weapon = "Scythe"
	}):SetParent(self.HeaderSkinFrame)
	self._reward_value_template.Parent = nil
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.ConfirmButton.MouseButton1Click:Connect(function()
		self:Confirm()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self.RecipientAddButton.MouseButton1Click:Connect(function()
		self:_AddRewardValueFrame(nil)
	end)
	self:_Setup()
	self:_UpdateBudgetText()
	self:_AddRewardValueFrame()
	task.spawn(self._UpdateBudgetTextLoop, self)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ConfirmButton)
	ButtonEffect:Add(self.RecipientAddButton)
end

return object