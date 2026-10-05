local Players = game:GetService("Players")
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
require(game.ReplicatedStorage.Packages.Signal)
require(game.ReplicatedStorage.Types.TradeTypes)
local Inventory = require(game.ReplicatedStorage.Controllers.UI.Inventory)

function menuFunction(...) end

local v = nil
local class = {}
class.__index = class

function class:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false

	if v == self then
		v = nil
	end

	for _, _Connection in self._Connections do
		_Connection:Disconnect()
	end

	setmetatable(self, nil)
	table.clear(self)
end

function class:Open()
	if self.IsOpen then
		return
	end

	self.IsOpen = true
	self._OnOpen:Fire()
	local main = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
	local statsButton = main:FindFirstChild("StatsButton")

	if statsButton and statsButton.Visible then
		menuFunction()
	end

	local menuButton = main:FindFirstChild("MenuButton")

	if menuButton then
		menuButton.Visible = false
	end

	Inventory:Close()
end

function class:Close()
	if not self.IsOpen then
		return
	end

	self.IsOpen = false
	local menuButton = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):FindFirstChild("MenuButton")

	if menuButton then
		menuButton.Visible = true
	end

	self._OnClose:Fire()
	self.OnClosed:Fire()
end

function class.GetIfInitialized(p)
	if v == p and v and v._IsAlive then
		return true
	end

	return false
end

return ServiceProxy(function()
	return v or class
end)