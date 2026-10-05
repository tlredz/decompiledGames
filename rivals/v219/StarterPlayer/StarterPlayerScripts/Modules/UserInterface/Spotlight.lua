local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "Spotlight")
	self._spotlight_hash = 0
	self._spotlight_connection = nil
	self._spotlight_reference = nil
	self._spotlight_transparency = 1
	self:_Init()
	return self
end

function class:GetCurrentReference()
	return self._spotlight_reference
end

function class:ChangeSubject(spotlight_reference, p)
	if p and self:GetCurrentReference() ~= p then
		return
	end

	self._spotlight_hash += 1

	if self._spotlight_connection then
		self._spotlight_connection:Disconnect()
		self._spotlight_connection = nil
	end

	if self._spotlight_reference then
		self._spotlight_reference.ZIndex -= 1
	end

	self._spotlight_reference = spotlight_reference

	if not self._spotlight_reference then
		self:_SetTransparency(1)
		return
	end

	self._spotlight_reference.ZIndex += 1
	self:_SetTransparency(0.75)
	local v = Spring.new(self.Frame.AbsolutePosition, 0.875, 25)
	local v2 = Spring.new(self.Frame.AbsoluteSize, 0.875, 25)
	self._spotlight_connection = RunService.RenderStepped:Connect(function()
		v.Target = self._spotlight_reference.AbsolutePosition
		v2.Target = self._spotlight_reference.AbsoluteSize
		local v3 = v.Value - self.Frame.Parent.AbsolutePosition
		self.Frame.Position = UDim2.new(0, v3.X - 8, 0, v3.Y - 8)
		self.Frame.Size = UDim2.new(0, v2.Value.X + 16, 0, v2.Value.Y + 16)
	end)
end

function class:_UpdateVisibility()
	self.Frame.Visible = not GuiService.MenuIsOpen
end

function class:_SetTransparency(p)
	local _spotlight_hash = self._spotlight_hash
	task.spawn(function()
		Utility:RenderstepForLoop(0, 100, 4, function(p2)
			if _spotlight_hash ~= self._spotlight_hash then
				return true
			end

			self._spotlight_transparency += (p - self._spotlight_transparency) * (1 - (1 - p2 / 100) ^ 2)

			for _, image in pairs(self.Frame:GetChildren()) do
				if image:IsA("ImageLabel") then
					image.ImageTransparency = self._spotlight_transparency
				else
					image.BackgroundTransparency = self._spotlight_transparency
				end
			end
		end)

		if _spotlight_hash ~= self._spotlight_hash then
			return
		end

		if p >= 1 then
			self.Frame.Size = UDim2.new(3, 0, 3, 0)
			self.Frame.Position = UDim2.new(-1, 0, -1, 0)
		end
	end)
end

function class:_Init()
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
	self:ChangeSubject(nil)
end

return class._new()