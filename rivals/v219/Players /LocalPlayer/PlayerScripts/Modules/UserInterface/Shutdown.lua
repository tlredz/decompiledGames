local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local GlowyBackground = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("GlowyBackground"))
local ChickenFooter = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ChickenFooter"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local shutdown = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("Shutdown")
local v = {
	[Enum.CloseReason.Unknown] = "Unknown shutdown",
	[Enum.CloseReason.RobloxMaintenance] = "Roblox maintenance",
	[Enum.CloseReason.OutOfMemory] = "The server ran out of memory",
	[Enum.CloseReason.ServerEmpty] = "The server is now empty",
	[Enum.CloseReason.DeveloperUpdate] = "Migrating to new servers",
	[Enum.CloseReason.DeveloperShutdown] = "Shutdown by the developers"
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.EnabledChanged = Signal.new()
	self.Enabled = nil
	self:_Init()
	return self
end

function class:Enable(p2)
	self.Enabled = true
	self.EnabledChanged:Fire()
	UILibrary.MainGui.Enabled = false
	Teleporting.GUI.Parent = nil
	local clone = shutdown:Clone()
	clone.Parent = Players.LocalPlayer.PlayerGui
	local lastTime = tick()
	RunService.RenderStepped:Connect(function(dt)
		clone.MainFrame.Container.Icon.Rotation += (math.sin((tick() - lastTime) * 2 % 6.283185307179586) + 1) * dt * 300
	end)
	local v2 = v[p2] or p2 and p2.Name or ""
	local v3 = ChickenFooter.new()
	v3:SetStatus("Server Restart")
	v3:SetMessage((v2 == "" and "" or v2 .. " — ") .. "Hang tight while I find a new server for you!")
	v3:SetPicture("Sensei")
	v3:EnableTimer()
	v3:SetParent(clone.MainFrame)
	local shutdown2 = GlowyBackground.new("Shutdown")
	shutdown2:SetParent(clone.MainFrame)
	shutdown2:SetEnabled(true)
	Utility:RenderstepForLoop(0, 100, 1, function(p3)
		local imageTransparency = (1 - p3 / 100) ^ 5
		clone.MainFrame.Container.Icon.ImageTransparency = imageTransparency
	end)
end

function class:_Init() end

return class._new()