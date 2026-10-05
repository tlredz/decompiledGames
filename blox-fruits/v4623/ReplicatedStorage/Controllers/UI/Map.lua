local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local Spring = require(game.ReplicatedStorage.Packages.Spring)
require(game.ReplicatedStorage.Spritesheets)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Map"):tag("UI"):tag("Controller"):traceback():display():build()
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local Map = require(game.ReplicatedStorage.React.Components.Map)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local use = require(game.ReplicatedStorage.React.Hooks.Island.use)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local playerGui

if RunService:IsRunning() then
	local Players2 = game:GetService("Players")
	playerGui = Players2.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local class = {}
class.__index = class

function class:Open()
	v.info(function()
		return ":Open()"
	end)

	if self._IsOpen then
		v.trace("already open")
		return
	end

	self._IsOpen = true
	self._OnOpen:Fire()
end

function class:IsOpen()
	return self._IsOpen
end

function class:SetNavigationTarget(navigationTarget)
	v.info(function()
		return (`:SetNavigationTarget(island={navigationTarget})`)
	end)

	if navigationTarget == self._NavigationTarget then
		return
	end

	self._NavigationTarget = navigationTarget
	self.OnNavigationTargetChanged:Fire(navigationTarget)
end

function class:SetRecommendation(recommendation)
	v.info(function()
		return (`:SetRecommendation(island={recommendation})`)
	end)

	if recommendation == self._Recommendation then
		return
	end

	self._Recommendation = recommendation
	self.OnRecommendationChanged:Fire(recommendation)
end

function class:RegisterOpenButton(p2)
	v.info(function()
		return (`:RegisterOpenButton(button={p2})`)
	end)
	table.insert(self._OpenButtons, p2)
	p2.Visible = Players.LocalPlayer:GetAttribute("HasUnlockedMap") == true
	return function()
		local index = table.find(self._OpenButtons, p2)

		if index then
			table.remove(self._OpenButtons, index)
		end
	end
end

function class:GetNavigationTarget()
	v.info(function()
		return ":GetNavigationTarget()"
	end)
	return self._NavigationTarget
end

function class:GetMarkers()
	v.info(function()
		return ":GetMarkers()"
	end)
	return table.clone(self._Markers)
end

function class:SetMarker(p2: string, vector2: Vector3, icon, color: Color3, text: string?)
	v.info(function()
		return (`:SetMarker(key={p2}, position={vector2}, icon={icon}, fillColor={color}, text={text})`)
	end)
	assert(vector2, "bad position")
	local v2 = {
		Icon = icon,
		Key = p2,
		FillColor = color,
		Position = vector2,
		Text = text
	}
	table.freeze(v2)
	self._Markers[p2] = v2
	self._OnMarkerChanged:Fire(p2, v2)
end

function class:RemoveMarker(p2: string)
	v.info(function()
		return (`:RemoveMarker(key={p2}})`)
	end)

	if self._Markers[p2] then
		self._Markers[p2] = nil
		self._OnMarkerChanged:Fire(p2, nil)
	end
end

function class:GetIslandsAsync()
	v.info(function()
		return ":GetIslandsAsync()"
	end)

	while self._Islands == nil and self.IsInitialized do
		task.wait()
	end

	assert(self._Islands, "bad islands")
	return table.clone(self._Islands)
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

return ServiceLocker(function()
	v.info("init()")
	local object = setmetatable({
		IsInitialized = true,
		_Connections = {},
		_IsOpen = false,
		_IsOpenButtonVisible = true,
		_Islands = nil,
		_OpenButtons = {},
		_Markers = {},
		_NavigationTarget = nil,
		_OnMarkerChanged = Signal.new(),
		OnRecommendationChanged = Signal.new(),
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new(),
		OnNavigationTargetChanged = Signal.new(),
		_Controllers = {}
	}, class)
	table.insert(object._Connections, Players.LocalPlayer:GetAttributeChangedSignal("HasUnlockedMap"):Connect(function()
		for _, guiObject in object._OpenButtons do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = Players.LocalPlayer:GetAttribute("HasUnlockedMap") == true
			end
		end
	end))

	local function component(_)
		local state, setState = React.useState(object._IsOpen)
		local state2, setState2 = React.useState(table.freeze(table.clone(object._Markers)))
		local state3, setState3 = React.useState(object._NavigationTarget)
		local state4, setState4 = React.useState(nil)
		local state5, setState5 = React.useState(nil)
		local v2 = useAttribute(Players.LocalPlayer, "VictoryIsland")
		local victoryIsland = use(useCurrentSea(), v2)
		React.useEffect(function()
			local onNavigationTargetChangedConnection = object.OnNavigationTargetChanged:Connect(function(_)
				setState5(nil)
				setState3(object._NavigationTarget)

				if object:IsOpen() and object._NavigationTarget then
					task.wait(0.5)
					object:Close()
				end
			end)
			local connection = object._OnMarkerChanged:Connect(function(_, _)
				setState2(table.freeze(table.clone(object._Markers)))
			end)
			local connection2 = object._OnOpen:Connect(function()
				setState5(nil)
				setState(true)
			end)
			local onClosedConnection = object.OnClosed:Connect(function()
				setState(false)
				setState5(nil)
				Players.LocalPlayer:SetAttribute("VictoryIsland", nil)
			end)
			local onRecommendationChangedConnection = object.OnRecommendationChanged:Connect(function(p)
				setState4(p)
			end)
			return function()
				connection2:Disconnect()
				onClosedConnection:Disconnect()
				onNavigationTargetChangedConnection:Disconnect()
				connection:Disconnect()
				onRecommendationChangedConnection:Disconnect()
			end
		end, {})
		React.useEffect(function()
			local cameraSubject = workspace.CurrentCamera.CameraSubject

			if not (state and state3 and cameraSubject and cameraSubject.Parent and cameraSubject.Parent:IsA("Model") and cameraSubject.Parent:FindFirstChild("Head")) then
				return function() end
			end

			local head = cameraSubject.Parent:FindFirstChild("Head")
			assert(head and head:IsA("BasePart"), "bad head")
			local v5 = Spring.new(1.35, 1.5, 0)
			v5:Set(1)
			local v6 = head.CFrame:Inverse() * workspace.CurrentCamera.CFrame
			local eulerAnglesYXZ, v7 = (head.CFrame * v6):ToEulerAnglesYXZ()
			local v8 = v7 % 6.283185307179586
			local cFrame = head.CFrame
			local _, v9, _ = (CFrame.lookAt(cFrame.Position, state3.World.Position, createVector(0, 1, 0)) * CFrame.fromEulerAnglesYXZ(
				eulerAnglesYXZ,
				0,
				0
			) * CFrame.new(0, 0, v6.Position.Magnitude)):ToEulerAnglesYXZ()
			local v10 = v9 % 6.283185307179586
			local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				v5:Step(dt)
				cFrame = head.CFrame
				workspace.CurrentCamera.CFrame = CFrame.new(cFrame.Position) * CFrame.fromEulerAnglesYXZ(
					eulerAnglesYXZ,
					(v8 + (v10 - v8) * v5:Get()) % 6.283185307179586,
					0
				) * CFrame.new(0, 0, v6.Position.Magnitude)
			end)
			return function()
				renderSteppedConnection:Disconnect()
			end
		end, { state3, state })
		local markers = React.useMemo(function()
			return TableUtil.values(state2)
		end, { state2 })
		local v6 = useLastInput()
		local createElement = React.createElement
		local v8 = {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Active = false
		}
		local createElement2 = React.createElement
		local v11 = {
			IsOpen = state,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = 0,
			Markers = 0,
			UserId = 0,
			NavigationTarget = 0,
			Recommendation = 0,
			SelectedIsland = 0,
			VictoryIsland = 0,
			OnAction = 0
		}
		local size

		if v6 == "Touch" then
			size = UDim2.fromScale(0.8, 0.8)
		else
			size = UDim2.fromScale(0.65, 0.65)
		end

		v11.Size = size
		v11.Markers = markers
		v11.UserId = Players.LocalPlayer.UserId
		v11.NavigationTarget = state3
		v11.Recommendation = state4
		v11.SelectedIsland = state5
		v11.VictoryIsland = victoryIsland

		function v11.OnAction(data)
			if data.Type == "NavigateTo" then
				object:SetNavigationTarget(data.Target)
			elseif data.Type == "ClearNavigation" then
				object:SetNavigationTarget(nil)
			elseif data.Type == "Select" then
				setState5(data.Island)
			elseif data.Type == "Exit" then
				object:Close()
			end
		end

		return createElement("Frame", v8, {
			Map = createElement2(Map, v11)
		})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "MapRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = 50
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(component, {}), screenGui)))
	end)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("Map", function()
			return object:Open()
		end, function()
			return object:Close()
		end, function()
			return object:IsOpen()
		end)
	end)
	v.trace(function()
		return "initialization complete"
	end)
	return object
end, function(list)
	for _, _Connection in list._Connections do
		_Connection:Disconnect()
	end

	list._OnMarkerChanged:Destroy()
	list.OnNavigationTargetChanged:Destroy()
	list.OnRecommendationChanged:Destroy()
	list.OnClosed:Destroy()
	list._OnOpen:Destroy()
	setmetatable(list, nil)
	table.clear(list)
end)