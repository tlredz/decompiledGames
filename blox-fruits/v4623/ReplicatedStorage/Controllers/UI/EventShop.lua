local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local Easter2026 = require(game.ReplicatedStorage.EventConfig.Easter2026)
local EventShop = require(game.ReplicatedStorage.React.Components.EventShop)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Quantity.use)
local celebration = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Celebration")
local playerGui

if RunService:IsRunning() then
	local Players = game:GetService("Players")
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

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

function class:Open(p)
	if self.IsOpen then
		return
	end

	self.IsOpen = true
	self._OnOpen:Fire(p)
end

function class:Close()
	if not self.IsOpen then
		return
	end

	self.IsOpen = false
	self._OnClose:Fire()
	self.OnClosed:Fire()
end

function class:GetIfInitialized()
	if v == self and v and v._IsAlive then
		return true
	end

	return false
end

function class.init()
	local v2 = v

	if v2 and v2:GetIfInitialized() then
		return function()
			v2:Destroy()
		end
	end

	local object = setmetatable({
		_IsAlive = true,
		_Connections = {},
		IsOpen = false,
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new(),
		_Controllers = {}
	}, class)

	local function component(_)
		local state, setState = React.useState(nil)
		local state2, setState2 = React.useState({})
		local state3, setState3 = React.useState(object.IsOpen)
		local v3 = use(Easter2026.CURRENCY_NAME, "Material")
		React.useEffect(function()
			local connection = object._OnClose:Connect(function()
				setState3(false)
			end)
			local connection2 = object._OnOpen:Connect(function(p)
				print("EventMenu opened:", p)
				setState(p)
				setState3(true)
			end)
			return function()
				connection:Disconnect()
				connection2:Disconnect()
			end
		end, {})
		React.useEffect(function()
			if state == nil or not state3 then
				return function() end
			end

			local flag = true
			local thread = task.spawn(function()
				while flag do
					pcall(function(...)
						setState2(celebration:InvokeServer("GetStore")[1])
					end)
					task.wait(1)
				end
			end)
			return function()
				flag = false
				task.cancel(thread)
			end
		end, { state, state3 })

		if state3 then
			return (React.createElement(EventShop, {
				Size = UDim2.fromScale(2, 0.7),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				EventType = state,
				CurrencyAmount = v3 or 0,
				OnClick = function(p: string)
					print("Clicked item with id", p)
					celebration:InvokeServer("Purchase", p)
				end,
				OnExit = function()
					object:Close()
				end,
				Items = state2
			}, {}))
		end

		return nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "EventShopRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = 1
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(component, {}), screenGui)))
	end)

	if v ~= nil then
		v:Destroy()
		v = nil
	end

	v = object
	return function()
		object:Destroy()
	end
end

return ServiceProxy(function()
	return v or class
end)