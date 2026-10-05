local Players = game:GetService("Players")
local Maid = require(game.ReplicatedStorage.Packages.Maid)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
local createElement = React.createElement
local Controller = {}
Controller.__index = Controller

function Controller:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false
	self._Maid:Destroy()
	pcall(function()
		self._Root:unmount()
	end)
	pcall(function()
		self._Instance:Destroy()
	end)
	setmetatable(self, nil)
	table.clear(self)
end

function Controller.new(value: string, body: string, callback, value2: string?, value3: string?)
	local object = setmetatable({}, Controller)
	object._IsAlive = true
	object._Maid = Maid.new()
	object._Instance = Instance.new("Folder")
	object._Instance.Name = "ConfirmationDialog"
	object._Instance.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	object._Root = ReactRoblox.createRoot(object._Instance)
	local portal = ReactRoblox.createPortal(createElement(parentModule, {
		Title = value:upper(),
		Body = body,
		ConfirmText = value2 or "Continue",
		CancelText = value3 or "Cancel",
		OnCloseComplete = function()
			object:Destroy()
		end,
		OnResponse = function(flag: boolean)
			callback(flag)
		end
	}), object._Instance)
	object._Root:render(portal)
	return object
end

return Controller