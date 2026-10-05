local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local object = setmetatable({}, Prompt)
object.__index = object

function object.new()
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.Container = self.PromptFrame:WaitForChild("Container")
	self.TextFrame = self.PromptFrame:WaitForChild("TextFrame")
	self.TextFrameBox = self.TextFrame:WaitForChild("Box")
	self.TextFrameBackground = self.TextFrame:WaitForChild("Background")
	self._reward_slot = nil
	self:_Init()
	return self
end

function object:_Update()
	if self._reward_slot then
		self._reward_slot:Destroy()
		self._reward_slot = nil
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, self.TextFrameBox.Text)

	if success then
		local success2, result2 = pcall(function()
			local v = RewardSlot.new(result)
			v:UseHighResolutionImage()
			v:SetInteractable(false)
			v:SetParent(self.Container)
			return v
		end)

		if success2 then
			self._reward_slot = result2
		end
	end

	local textFrameBackground = self.TextFrameBackground
	local imageColor

	if self.TextFrameBox.Text == "" or self._reward_slot then
		imageColor = Color3.fromRGB(255, 255, 255)
	else
		imageColor = Color3.fromRGB(255, 50, 50)
	end

	textFrameBackground.ImageColor3 = imageColor
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.TextFrameBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_Update()
	end)
	self:_Update()
	ButtonEffect:Add(self.CloseButton)
end

return object