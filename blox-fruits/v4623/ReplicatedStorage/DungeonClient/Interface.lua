local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local createElement = React.createElement
require(script.Objectives)
local TopBar = require(script.TopBar)
local Healthbars = require(script.Healthbars)
local DungeonQueueSettingsMenu = require(script.DungeonQueueSettingsMenu)
local BuffSelector = require(script.BuffSelector)
local buffSelector = BuffSelector.BuffSelector
local buffList = BuffSelector.BuffList
local DungeonResultsUI = require(script.DungeonResultsUI)

local function rootComponent(p)
	local UserInputService = game:GetService("UserInputService")
	local touchEnabled = UserInputService.TouchEnabled

	if touchEnabled then
		local UserInputService2 = game:GetService("UserInputService")
		touchEnabled = not UserInputService2.KeyboardEnabled
	end

	local objectives = p.dungeonFolder:WaitForChild("Objectives")
	local explorers = p.dungeonFolder:WaitForChild("Explorers")
	React.useRef(0.5)
	local ref = React.useRef(2)
	local ref2 = React.useRef(false)
	local ref3 = React.useRef("")
	local ref4 = React.useRef(workspace.CurrentCamera.ViewportSize.Y)
	local ref5 = React.useRef(workspace.CurrentCamera.ViewportSize.X)
	React.useEffect(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function onViewportSizeChanged()
			ref4.current = workspace.CurrentCamera.ViewportSize.Y
			ref5.current = workspace.CurrentCamera.ViewportSize.X
			ref.current = math.clamp(math.floor(ref4.current / 882 * 2), 1, 4)
		end

		local viewportSizeChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportSizeChanged)
		onViewportSizeChanged() -- equivalent call inferred; original call site unknown
		return function()
			viewportSizeChangedConnection:Disconnect()
		end
	end, {})
	React.useMemo(function()
		return {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 0)
		}
	end, {})
	local ref6 = React.useRef("")

	local function formatTime(p2: number)
		math.floor(p2 / 60)
		local v = p2 % 60
		local v2 = math.floor(v)
		local v3 = math.floor((v - v2) * 1000)
		return string.format("%02d.%03d", v2, v3)
	end

	local function updateTimer(timeLeft)
		local v = timeLeft or p.dungeonFolder:GetAttribute("TimeLeft")

		if not v then
			ref6.current = ""
			return
		end

		local v2 = math.floor(v / 60)
		local v3 = v % 60
		local current = tostring(v2) .. ":" .. string.format("%02d", v3)

		if v <= 59 then
			current = "<b><font color=\"#FF0000\">" .. current .. "</font></b>"
		end

		ref6.current = current
	end

	p.dungeonFolder:GetAttributeChangedSignal("TimeLeft"):Connect(updateTimer)
	updateTimer(p.dungeonFolder:GetAttribute("TimeLeft") or math.random(1, 999))
	local state, setState = React.useState({})
	local v = React.useMemo(function()
		local children = {}

		for _, explorerFolder in state do
			table.insert(children, createElement(Healthbars, {
				explorerFolder = explorerFolder
			}))
		end

		return children
	end, { state })
	local _, setState2 = React.useState({})
	React.useMemo(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function onObjectiveAdded(_)
			setState2(objectives:GetChildren())
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onExplorerAdded(_)
			setState(explorers:GetChildren())
		end

		objectives.ChildAdded:Connect(onObjectiveAdded)

		for _, _ in objectives:GetChildren() do
			onObjectiveAdded() -- equivalent call inferred; original call site unknown
		end

		explorers.ChildAdded:Connect(onExplorerAdded)

		for _, _ in explorers:GetChildren() do
			onExplorerAdded() -- equivalent call inferred; original call site unknown
		end

		objectives.ChildRemoved:Connect(function(_)
			onObjectiveAdded() -- equivalent call inferred; original call site unknown
		end)
		explorers.ChildRemoved:Connect(function(_)
			onExplorerAdded() -- equivalent call inferred; original call site unknown
		end)
	end, {})
	local size

	if touchEnabled then
		size = UDim2.new(0.2, 0, 0.25, 0)
	else
		size = UDim2.new(0.15, 0, 0.2, 0)
	end

	local position

	if touchEnabled then
		position = UDim2.new(0, 2, 0.15, 0)
	else
		position = UDim2.new(0.005, 2, 0.5, 0)
	end

	local v7 = createElement("Frame", {
		Size = size,
		Position = position,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, { createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 1)
		}), v })
	return createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, { createElement("Frame", {
			Size = UDim2.new(0.2, 0, 0.05, 0),
			Position = UDim2.new(0.5, 0, 0.1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = ref2
		}, { createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Text = ref3,
				TextColor3 = Color3.fromRGB(255, 0, 0),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				TextScaled = true,
				Font = Enum.Font.RobotoMono,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center
			}) }), v7, (createElement(TopBar, {
			DungeonFolder = p.dungeonFolder,
			TimerValue = ref6
		})) })
end

function setupInterface(dungeonFolder)
	local maid = Maid.new()
	local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
	screenGui.Name = "DungeonInterface"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.IgnoreGuiInset = true
	local root = ReactRoblox.createRoot(screenGui)
	root:render(createElement(rootComponent, {
		dungeonFolder = dungeonFolder
	}))
	maid:GiveTask(function()
		root:unmount()
		screenGui:Destroy()
	end)
	return maid
end

function setupWaitingForPlayersInterface(dungeonWaitingFolder)
	local maid = Maid.new()
	local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
	screenGui.Name = "DungeonWaitingForPlayers"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.IgnoreGuiInset = true
	local root = ReactRoblox.createRoot(screenGui)
	local WaitingForPlayers = require(script.WaitingForPlayers)
	root:render(createElement(WaitingForPlayers, {
		dungeonWaitingFolder = dungeonWaitingFolder
	}))
	maid:GiveTask(function()
		root:unmount()
		screenGui:Destroy()
	end)
	return maid
end

local RunService = game:GetService("RunService")

if RunService:IsRunning() then
	local RunService2 = game:GetService("RunService")

	if RunService2:IsClient() and game.Players.LocalPlayer then
		game.Players.LocalPlayer.ChildAdded:Connect(function(objectValue)
			if objectValue.Name == "TeleporterPadObjectReference" and objectValue:IsA("ObjectValue") then
				local maid = Maid.new()
				local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
				screenGui.Name = "DungeonQueueSettingsMenu"
				screenGui.ResetOnSpawn = false
				screenGui.IgnoreGuiInset = true
				local root = ReactRoblox.createRoot(screenGui)
				root:render(createElement(DungeonQueueSettingsMenu, {
					teleporterPad = objectValue.Value,
					onClose = function()
						maid:DoCleaning()
					end
				}))
				maid:GiveTask(function()
					root:unmount()
					screenGui:Destroy()
				end)
				objectValue.AncestryChanged:Connect(function(_, parent)
					if not (parent or game.Players.LocalPlayer:GetAttribute("IsTeleporting")) then
						maid:DoCleaning()
					end
				end)
			end
		end)
		task.spawn(function()
			local buffSelector2 = game.ReplicatedStorage.DungeonShared:WaitForChild("BuffSelector", 99999)

			if buffSelector2 then
				buffSelector2.OnClientInvoke = function(buffs)
					local maid = Maid.new()
					local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
					screenGui.Name = "BuffSelectorMenu"
					screenGui.ResetOnSpawn = false
					screenGui.IgnoreGuiInset = true
					screenGui.DisplayOrder = 1000
					local root = ReactRoblox.createRoot(screenGui)
					local thread = coroutine.running()
					root:render(createElement(buffSelector, {
						onClose = function(p2)
							task.spawn(thread, p2)
							maid:DoCleaning()
						end,
						buffs = buffs
					}))
					maid:GiveTask(function()
						root:unmount()
						screenGui:Destroy()
					end)
					return (coroutine.yield())
				end
			end
		end)
		task.spawn(function()
			local buffReplicator = game.ReplicatedStorage.DungeonShared:WaitForChild("BuffReplicator", 99999)
			local v = Maid.new()

			if buffReplicator then
				local v2 = nil
				buffReplicator.OnClientEvent:Connect(function(buffs)
					v:DoCleaning()

					if v2 then
						v2(buffs)
						return
					end

					local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
					screenGui.Name = "BuffListMenu"
					screenGui.ResetOnSpawn = false
					screenGui.IgnoreGuiInset = true
					ReactRoblox.createRoot(screenGui):render(createElement(function(p2)
						local state, setState = React.useState(p2.buffs)
						v2 = setState
						return createElement(buffList, {
							buffs = state
						})
					end, {
						buffs = buffs
					}))
				end)
			end
		end)
		task.spawn(function()
			local resultsScreen = game.ReplicatedStorage.DungeonShared:WaitForChild("ResultsScreen", 99999)
			local maid = Maid.new()

			if resultsScreen then
				resultsScreen.OnClientEvent:Connect(function(p)
					maid:DoCleaning()
					maid:GiveTask(task.spawn(function()
						local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
						local spinnerWindow = playerGui:FindFirstChild("SpinnerWindow")

						if spinnerWindow and spinnerWindow.Enabled then
							spinnerWindow:GetPropertyChangedSignal("Enabled"):Wait()
						end

						local screenGui = Instance.new("ScreenGui", playerGui)
						screenGui.Name = "ResultsScreen"
						screenGui.ResetOnSpawn = false
						screenGui.IgnoreGuiInset = true
						screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
						local root = ReactRoblox.createRoot(screenGui)

						function p.onClose()
							maid:DoCleaning()
						end

						root:render(createElement(DungeonResultsUI, p))
						maid:GiveTask(function()
							root:unmount()
							screenGui:Destroy()
						end)
					end))
				end)
			end
		end)
		game.ReplicatedStorage.DungeonShared.ChildAdded:Connect(function(remoteEvent)
			if remoteEvent.Name == "ReturnToHub" and remoteEvent:IsA("RemoteEvent") then
				local maid = Maid.new()
				local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
				screenGui.Name = "ReturningToHubShortly"
				screenGui.ResetOnSpawn = false
				screenGui.IgnoreGuiInset = true
				local root = ReactRoblox.createRoot(screenGui)
				local ReturningToHubShortly = require(script.ReturningToHubShortly)
				root:render(createElement(ReturningToHubShortly, {}))
				maid:GiveTask(function()
					root:unmount()
					screenGui:Destroy()
				end)
				remoteEvent.AncestryChanged:Connect(function(_, parent)
					if not parent then
						maid:DoCleaning()
					end
				end)
			end
		end)
	end
end

local function handleDungeonWaitingForPlayers(folder)
	if folder.Name == "DungeonWaitingForPlayers" and folder:IsA("Folder") then
		local v = setupWaitingForPlayersInterface(folder)
		folder.AncestryChanged:Connect(function(_, parent)
			if not parent then
				v:DoCleaning()
			end
		end)
	end
end

game.ReplicatedStorage.ChildAdded:Connect(handleDungeonWaitingForPlayers)

if game.ReplicatedStorage:FindFirstChild("DungeonWaitingForPlayers") then
	task.spawn(handleDungeonWaitingForPlayers, game.ReplicatedStorage:FindFirstChild("DungeonWaitingForPlayers"))
end

return {
	setupInterface = setupInterface,
	rootComponent = rootComponent,
	rootWaitingComponent = require(script.WaitingForPlayers),
	dungeonQueueSettingsMenu = DungeonQueueSettingsMenu,
	buffSelector = buffSelector,
	buffList = buffList
}