local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local AnalyticsUtil = require(game.ReplicatedStorage.Util.AnalyticsUtil)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("HUD"):tag("UI"):tag("Controller"):traceback():display():build()
local HUD = require(game.ReplicatedStorage.React.Components.HUD)
require(game.ReplicatedStorage.React.Components.HUD.Types)
local playerGui

if RunService:IsRunning() then
	local Players = game:GetService("Players")
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local class = {}
class.__index = class

function class:Open()
	if self._IsOpen then
		v.trace("already open")
		return
	end

	self._IsOpen = true
	self._OnOpen:Fire()
end

function class:RegisterPage(p2, callback, callback2, callback3)
	local function scrubSelf(p3, callback4)
		return function(p4, ...)
			if p4 == p3 then
				return callback4(...)
			end

			return callback4(p4, ...)
		end
	end

	local v2 = {
		key = p2
	}

	local function fn(...)
		AnalyticsUtil.reportActivity((`HUD/{p2}`))
		return callback(...)
	end

	function v2.open(p3, ...)
		if p3 == v2 then
			return fn(...)
		end

		return fn(p3, ...)
	end

	function v2.close(p3, ...)
		if p3 == v2 then
			return callback2(...)
		end

		return callback2(p3, ...)
	end

	function v2.isOpen(p3, ...)
		if p3 == v2 then
			return callback3(...)
		end

		return callback3(p3, ...)
	end

	table.freeze(v2)
	assert(self._Pages[p2] == nil, (`already registered page at key "{p2}"`))
	self._Pages[p2] = v2
end

function class:GetPageControllerAsync(p2)
	local _Page = self._Pages[p2]

	while _Page == nil and self.IsInitialized do
		task.wait()
		_Page = self._Pages[p2]
	end

	assert(_Page, "bad controller")
	return _Page
end

function class:CloseOthers(...)
	local v2 = { ... }

	for k, _Page in self._Pages do
		if table.find(v2, k) then
			continue
		end

		local v3 = _Page
		local success, result = pcall(function()
			v3.close()
		end)

		if not success then
			warn((`closing "{k}" failed: "{result}"`))
		end
	end
end

function class:ClosePages(...)
	local v2 = { ... }

	for k, _Page in self._Pages do
		if not table.find(v2, k) then
			continue
		end

		local v3 = _Page
		local success, result = pcall(function()
			v3.close()
		end)

		if not success then
			warn((`closing "{k}" failed: "{result}"`))
		end
	end
end

function class:IsPageOpenAsync(p)
	return self:GetPageControllerAsync(p).isOpen()
end

function class:IsOpen()
	return self._IsOpen
end

function class:Close()
	v.info(":Close()")

	if not self._IsOpen then
		v.trace("already closed")
		return
	end

	self._IsOpen = false
	self._OnClose:Fire()
	self.OnClosed:Fire()
end

function class:SetMenuVisibility(isMenuVisible: boolean)
	if self._IsMenuVisible == isMenuVisible then
		return
	end

	self._IsMenuVisible = isMenuVisible
	self._OnMenuVisibilityChanged:Fire(isMenuVisible)
end

function class:GetMenuVisibility()
	return self._IsMenuVisible
end

return ServiceLocker(function()
	v.info("init()")
	local object = setmetatable({
		IsInitialized = true,
		_Connections = {},
		_IsOpen = false,
		_IsMenuVisible = true,
		_Pages = {},
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new(),
		_OnMenuVisibilityChanged = Signal.new(),
		_Controllers = {}
	}, class)

	local function component(_)
		local state, setState = React.useState(object._IsOpen)
		local state2, setState2 = React.useState(object._IsMenuVisible)
		React.useEffect(function()
			local connection = object._OnOpen:Connect(function()
				setState(true)
			end)
			local onClosedConnection = object.OnClosed:Connect(function()
				setState(false)
			end)
			local connection2 = object._OnMenuVisibilityChanged:Connect(function(p)
				setState2(p)
			end)
			return function()
				connection:Disconnect()
				onClosedConnection:Disconnect()
				connection2:Disconnect()
			end
		end, {})
		return React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Active = false
		}, {
			HUD = React.createElement(HUD, {
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(1, 1),
				OnMenuAction = state2 and function(p)
					local pageControllerAsync = object:GetPageControllerAsync(p.Key)

					if pageControllerAsync.isOpen() then
						pageControllerAsync.close()
						return
					end

					object:CloseOthers()
					pageControllerAsync.open()
				end or nil,
				IsOpen = state,
				Visible = state2,
				OnExit = function()
					object:Close()
				end
			}, {})
		})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "HUDRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = -2
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(component), screenGui)))
	end)
	return object
end, function(list)
	for _, _Connection in list._Connections do
		_Connection:Disconnect()
	end

	setmetatable(list, nil)
	table.clear(list)
end)