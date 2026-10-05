local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local object = setmetatable({}, Prompt)
object.__index = object

function object.new()
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.ConfirmButton = self.PromptFrame:WaitForChild("Confirm")
	self.List = self.PromptFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.RecipientValueBox = self.Container:WaitForChild("RecipientValue"):WaitForChild("Input"):WaitForChild("Box")
	self.RecipientAddFrame = self.Container:WaitForChild("RewardAdd")
	self.RecipientAddInputFrame = self.RecipientAddFrame:WaitForChild("Input")
	self.RecipientAddInputAddButton = self.RecipientAddInputFrame:WaitForChild("Add")
	self.RecipientAddInputAddNetButton = self.RecipientAddInputFrame:WaitForChild("AddNet")
	self.RecipientAddInputAddBugNetButton = self.RecipientAddInputFrame:WaitForChild("AddBugNet")
	self._reward_value_template = self.Container:WaitForChild("RewardValue")
	self._reward_value_frames = {}
	self:_Init()
	return self
end

function object:Confirm()
	if #self._reward_value_frames == 0 then
		Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
		return
	end

	local text = self.RecipientValueBox.Text

	if text == "" then
		Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
		return
	end

	local v = {}

	for _, _reward_value_frame in pairs(self._reward_value_frames) do
		local text2 = _reward_value_frame.Input.Box.Text

		if text2 == "" then
			continue
		end

		if self:_IsValidJSON(text2) then
			table.insert(v, HttpService:JSONDecode(text2))
		else
			Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
			return
		end
	end

	local success, result = pcall(HttpService.JSONEncode, HttpService, v)

	if success then
		local success2, result2 = pcall(
			ReplicatedStorage.Remotes.Debug.Command.InvokeServer,
			ReplicatedStorage.Remotes.Debug.Command,
			"SendOfflineGiftRewards",
			{ text, result }
		)

		if success2 and result2 then
			self:CloseRequest()
			return
		end

		warn("Failed to send rewards:", result2)
		Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
	else
		warn("Failed to encode reward_datas:", result)
		Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
	end
end

function object:_IsValidJSON(p)
	return (pcall(HttpService.JSONDecode, HttpService, p))
end

function object:_AddRewardValueFrame(p)
	local clone = self._reward_value_template:Clone()
	clone.LayoutOrder = self._reward_value_template.LayoutOrder + #self._reward_value_frames
	clone.Input.Box.Text = not p and "" or HttpService:JSONEncode(p)
	clone.Parent = self.Container
	table.insert(self._reward_value_frames, clone)
	clone.Input.Close.MouseButton1Click:Connect(function()
		clone:Destroy()
		local index = table.find(self._reward_value_frames, clone)

		if index then
			table.remove(self._reward_value_frames, index)
		end
	end)
	clone.Input.Box:GetPropertyChangedSignal("Text"):Connect(function()
		local background = clone.Input.Background
		local imageColor

		if clone.Input.Box.Text == "" or self:_IsValidJSON(clone.Input.Box.Text) then
			imageColor = Color3.fromRGB(255, 255, 255)
		else
			imageColor = Color3.fromRGB(255, 50, 50)
		end

		background.ImageColor3 = imageColor
	end)
	ButtonEffect:Add(clone.Input.Close)
end

function object:_Setup()
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
	self.RecipientAddInputAddButton.MouseButton1Click:Connect(function()
		self:_AddRewardValueFrame(nil)
	end)
	self.RecipientAddInputAddNetButton.MouseButton1Click:Connect(function()
		self:_AddRewardValueFrame({
			Name = "Net",
			Quantity = 1,
			Weapon = "IsRandom"
		})
	end)
	self.RecipientAddInputAddBugNetButton.MouseButton1Click:Connect(function()
		self:_AddRewardValueFrame({
			Name = "Bug Net",
			Quantity = 1,
			Weapon = "Scythe"
		})
	end)
	self:_Setup()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ConfirmButton)
	ButtonEffect:Add(self.RecipientAddInputAddButton)
	ButtonEffect:Add(self.RecipientAddInputAddNetButton)
	ButtonEffect:Add(self.RecipientAddInputAddBugNetButton)
end

return object