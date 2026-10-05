local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local PreviewModel = require(game.ReplicatedStorage.Controllers.UI.Spinner.Components.PreviewModel)
local SpinnerPreview = require(game.ReplicatedStorage.React.Components.SpinnerPreview)
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

function class:Open(p2)
	self.IsOpen = true
	self._OnOpen:Fire(p2)
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

	local v3 = nil
	local Net = require(game.ReplicatedStorage.Modules.Net)
	local v4 = {
		_IsAlive = true,
		_Connections = { Net:RemoteEvent("_AdminPreviewCmd").OnClientEvent:Connect(function(p)
				v3:Open(p)
			end) },
		IsOpen = false,
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new()
	}
	v3 = setmetatable(v4, class)

	local function component(_)
		local state, setState = React.useState({})
		local state2, setState2 = React.useState(v3.IsOpen)
		local state3, setState3 = React.useState(nil)
		React.useEffect(function()
			local v5 = state[#state]

			if v5 then
				setState3(v5)
			end
		end, { state })

		local function fn()
			if #state > 0 then
				PreviewModel.Destroy()

				for _, v5 in pairs(state) do
					local v6 = v5
					pcall(function(...)
						v6:Destroy()
					end)
				end

				setState({})
				setState3(nil)
			end
		end

		React.useEffect(function()
			local connection = v3._OnClose:Connect(function()
				setState2(false)
			end)
			local connection2 = v3._OnOpen:Connect(function(items)
				fn()
				local Players = game:GetService("Players")
				local playerGui2 = Players.LocalPlayer:FindFirstChild("PlayerGui")
				local child

				if playerGui2 then
					child = playerGui2:FindFirstChild(PreviewModel.HOLDER_NAME)
				else
					print("can't find screen")
				end

				if child then
					local clones = {}

					for _, item in pairs(items) do
						local v5 = PreviewModel.TryFindById(child, item)
						print((`{item}={v5}`))

						if v5 then
							table.insert(clones, (v5:Clone()))
						end

						setState(clones)
					end
				end

				setState2(true)
			end)
			return function()
				connection:Disconnect()
				connection2:Disconnect()
			end
		end, {})
		React.useEffect(function()
			if not state2 then
				fn()
			end
		end, { state2 })
		print("selection", state3)

		if state2 then
			return (React.createElement(SpinnerPreview, {
				Selected = state3,
				OnClose = function()
					v3:Close()
				end
			}))
		end

		return nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "PreviewSpinModelDebugger"
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

	v = v3
	return function()
		v3:Destroy()
	end
end

return ServiceProxy(function()
	return v or class
end)