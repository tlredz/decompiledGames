local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MonetizationController"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("PurchasePrompt")
	self._started = false
	self._blur = Instance.new("BlurEffect")
	self:_Init()
	return self
end

function class:Start()
	if self._started then
		return
	end

	self._started = true
	Utility:CreateSound("rbxassetid://17900058344", 1, 1, script, true, 10)
	Utility:RenderstepForLoop(0, 100, 2, function(p)
		if not self._started then
			return true
		end

		local v = 1 - (1 - p / 100) ^ 4
		self.Frame.BackgroundTransparency = 1 + -0.5 * v
		self._blur.Size = 56 * v
	end)
end

function class:Finish(p)
	assert(not p or typeof(p) == "boolean", "Argument 1 invalid, expected a boolean or nil, got " .. tostring(p))

	if not self._started then
		return
	end

	self._started = false

	if p then
		Utility:CreateSound("rbxassetid://7819009374", 1, 1, script, true, 10)
	end

	Utility:RenderstepForLoop(0, 100, 2, function(p2)
		if self._started then
			return true
		end

		local v = 1 - (1 - p2 / 100) ^ 4
		self.Frame.BackgroundTransparency = 0.5 + 0.5 * v
		self._blur.Size = 56 * (1 - v)
	end)
end

function class:_Setup()
	self._blur.Size = 0
	self._blur.Name = "PurchasePrompt"
	self._blur.Parent = Lighting
end

function class:_Init()
	MonetizationController.PurchaseStarted:Connect(function(...)
		self:Start(...)
	end)
	MonetizationController.PurchaseFinished:Connect(function(...)
		self:Finish(...)
	end)
	self:_Setup()
end

return class._new()