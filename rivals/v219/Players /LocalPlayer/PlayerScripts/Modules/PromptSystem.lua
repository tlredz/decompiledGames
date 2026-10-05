local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("GuiService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local prompts = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompts")
local PromptSystem = {}
PromptSystem.__index = PromptSystem

function PromptSystem.new(button)
	local v

	if typeof(button) == "Instance" then
		v = button:IsA("ImageButton")
	else
		v = false
	end

	assert(v, "Argument 1 invalid, expected an ImageButton, got " .. tostring(button))
	local object = setmetatable({}, PromptSystem)
	object.PromptAdded = Signal.new()
	object.PromptRemoved = Signal.new()
	object.PromptsFrame = button
	object.PromptsFrameBackground = object.PromptsFrame:WaitForChild("Background")
	object.CurrentPrompt = nil
	object._locked = false
	object:_Init()
	return object
end

function PromptSystem:GetDefaultElement()
	return self.CurrentPrompt and self.CurrentPrompt:GetDefaultElement()
end

function PromptSystem:Lock(locked)
	assert(typeof(locked) == "boolean", "Argument 1 invalid, expected a boolean, got " .. tostring(locked))
	self._locked = locked
end

function PromptSystem:Open(value, ...)
	assert(
		not value or typeof(value) == "string",
		"Argument 1 invalid, expected a string or nil, got " .. tostring(value)
	)
	self:Close(true)

	if not value then
		return self.CurrentPrompt
	end

	local module = require(prompts[value])
	assert(module.GetDefaultElement, "You forgot to implement " .. value .. ":GetDefaultElement()")
	assert(module.CloseRequest, "You forgot to implement " .. value .. ":CloseRequest()")
	assert(module.Open, "You forgot to implement " .. value .. ":Open()")
	assert(module.Destroy, "You forgot to implement " .. value .. ":Destroy()")
	self.CurrentPrompt = module.new(...)
	self.CurrentPrompt.Closed:Connect(function()
		self:Close()
	end)
	self.CurrentPrompt.OpenPrompt:Connect(function(...)
		self:Open(...)
	end)
	self.CurrentPrompt:Open(self.PromptsFrame)
	local currentPrompt = self.CurrentPrompt
	self.PromptsFrame.Visible = true
	task.spawn(
		Utility.RenderstepForLoop,
		Utility,
		(1 - self.PromptsFrameBackground.BackgroundTransparency) * 100,
		100,
		4,
		function(p)
			if self.CurrentPrompt ~= currentPrompt then
				return true
			end

			local v = 1 - (1 - p / 100) ^ 5
			self.PromptsFrameBackground.BackgroundTransparency = 1 + -0.667 * v
		end
	)
	self.PromptAdded:Fire(self.CurrentPrompt)
	return self.CurrentPrompt
end

function PromptSystem:Close(p)
	assert(not p or typeof(p) == "boolean", "Argument 1 invalid, expected a boolean or nil, got " .. tostring(p))
	local currentPrompt = self.CurrentPrompt

	if currentPrompt then
		self.CurrentPrompt = nil
		self:Lock(false)
		currentPrompt:Destroy()
		self.PromptRemoved:Fire(currentPrompt)

		if p then
			return
		else
			task.spawn(function()
				Utility:RenderstepForLoop(
					self.PromptsFrameBackground.BackgroundTransparency * 100,
					100,
					10,
					function(p2)
						if self.CurrentPrompt then
							return true
						end

						local v = p2 / 100
						self.PromptsFrameBackground.BackgroundTransparency = 0.333 + 0.667 * v
					end
				)
				self.PromptsFrame.Visible = self.CurrentPrompt ~= nil
			end)
		end
	end
end

function PromptSystem:Destroy()
	self:Close(true)
	self.PromptAdded:Destroy()
	self.PromptRemoved:Destroy()
end

function PromptSystem:_IsMouseWithinPromptBounds()
	if self._locked then
		return true
	end

	local promptFrame = self.CurrentPrompt and self.CurrentPrompt.PromptFrame
	return promptFrame and UILibrary:IsMouseWithinBounds(promptFrame.AbsolutePosition, promptFrame.AbsoluteSize)
end

function PromptSystem:_Init()
	self.PromptsFrame.MouseButton1Click:Connect(function()
		if not self:_IsMouseWithinPromptBounds() then
			self:Close()
		end
	end)
end

return PromptSystem