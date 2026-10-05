local LazyLoadModelController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraLazyLoadUtil = require(ReplicatedStorage.Modules.Shared.World.CameraLazyLoadUtil)
local CountDownLatch = require(ReplicatedStorage.Modules.Shared.Async.CountDownLatch)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- equivalent calls inferred from this helper; original call sites unknown
local function getWorldPosition(pVInstance)
	if pVInstance:IsA("PVInstance") then
		return pVInstance:GetPivot().Position
	end

	local basePart = pVInstance:FindFirstChildWhichIsA("BasePart", true)

	if basePart == nil then
		return nil
	end

	return basePart.Position
end

local function sortFarthestFirst(children, position: Vector3)
	local v = {}

	for _, v2 in children do
		local worldPosition = getWorldPosition(v2) -- equivalent call inferred; original call site unknown

		if worldPosition == nil then
			v[v2] = 1e999
		else
			local vector = worldPosition - position
			v[v2] = vector:Dot(vector)
		end
	end

	table.sort(children, function(a, b)
		return v[a] > v[b]
	end)
end

local v = {}
local v2 = {}
local v3 = {}
local v4 = nil
local v5 = nil
LazyLoadModelController.OnModelReceived = Signal.new()
LazyLoadModelController.OnModelDestroyed = Signal.new()

local function refreshDebugOverlay()
	if v5 == nil then
		return
	end

	if #v3 == 0 then
		v5.Text = "Lazy Loaded (0)"
		return
	end

	local names = { (`Lazy Loaded ({#v3})`) }

	for _, v6 in v3 do
		table.insert(names, v6.name)
	end

	v5.Text = table.concat(names, "\n")
end

local function addDebugLoaded(guid: string, fullName: string)
	for _, v6 in v3 do
		if v6.guid == guid then
			return
		end
	end

	table.insert(v3, 1, {
		guid = guid,
		name = fullName
	})
	refreshDebugOverlay()
end

local function removeDebugLoaded(p: string)
	for k, v6 in v3 do
		if v6.guid ~= p then
			continue
		end

		table.remove(v3, k)
		break
	end

	refreshDebugOverlay()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyDebugOverlay()
	if v4 ~= nil then
		v4:Destroy()
		v4 = nil
		v5 = nil
	end
end

local function createDebugOverlay()
	if v4 ~= nil then
		return
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LazyLoadDebug"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 1000
	screenGui.Parent = playerGui
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "LoadedModels"
	textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	textLabel.BackgroundTransparency = 0.45
	textLabel.TextColor3 = Color3.new(1, 1, 0)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Font = Enum.Font.Code
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.TextSize = 14
	textLabel.Position = UDim2.fromOffset(8, 8)
	textLabel.Size = UDim2.fromOffset(640, 0)
	textLabel.AutomaticSize = Enum.AutomaticSize.Y
	textLabel.TextWrapped = true
	textLabel.ZIndex = 1000
	textLabel.Parent = screenGui
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0, 6)
	uIPadding.PaddingBottom = UDim.new(0, 6)
	uIPadding.PaddingLeft = UDim.new(0, 8)
	uIPadding.PaddingRight = UDim.new(0, 8)
	uIPadding.Parent = textLabel
	v4 = screenGui
	v5 = textLabel
	refreshDebugOverlay()
end

local function destroyModelOverTime(instance)
	local children = instance:GetChildren()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart ~= nil and humanoidRootPart:IsA("BasePart") then
		sortFarthestFirst(children, humanoidRootPart.Position)
	end

	local total = 0

	for _, folder in children do
		if instance.Parent == nil then
			return
		end

		if folder.Parent == nil then
			continue
		end

		local v6 = #folder:GetDescendants() + 1

		if total > 0 and total + v6 > 200 then
			task.wait(0.1)

			if instance.Parent == nil then
				return
			else
				total = 0
			end
		end

		folder:Destroy()
		total += v6

		if not (total >= 200) then
			continue
		end

		task.wait(0.1)
		total = 0
	end

	if instance.Parent ~= nil then
		instance:Destroy()
	end
end

function LazyLoadModelController.SetDebugEnabled(flag: boolean)
	if flag == true then
		createDebugOverlay()
		return
	end

	destroyDebugOverlay() -- equivalent call inferred; original call site unknown
end

function LazyLoadModelController.FrameworkInit() end

local function processLazyLoadModel(child)
	if child.Name ~= "ToLoad" then
		return
	end

	task.defer(function()
		child.Parent = workspace
	end)
	local lazyLoadModelGuid = child:GetAttribute("lazyLoadModelGuid")

	if v[lazyLoadModelGuid] then
		v2[lazyLoadModelGuid] = child
		v[lazyLoadModelGuid].Destroying:Once(function()
			v[lazyLoadModelGuid] = nil
			child:Destroy()
		end)
	else
		local onModelReceivedConnection = nil
		local thread = task.delay(60, function()
			if onModelReceivedConnection then
				onModelReceivedConnection:Disconnect()
			end

			if child.Parent then
				child:Destroy()
			end
		end)
		onModelReceivedConnection = LazyLoadModelController.OnModelReceived:Connect(function(instance, p: string)
			if p == lazyLoadModelGuid then
				if onModelReceivedConnection then
					onModelReceivedConnection:Disconnect()
					onModelReceivedConnection = nil
				end

				v2[lazyLoadModelGuid] = child
				instance.Destroying:Once(function()
					v[lazyLoadModelGuid] = nil

					if child.Parent then
						child:Destroy()
					end
				end)
				task.cancel(thread)
			end
		end)
		child.Destroying:Once(function()
			if onModelReceivedConnection then
				onModelReceivedConnection:Disconnect()
				onModelReceivedConnection = nil
			end

			task.cancel(thread)
		end)
	end
end

function LazyLoadModelController.GetLazyModel(p: string)
	return v[p]
end

function LazyLoadModelController.GetGuidForInstance(instance)
	for k, ancestor in v do
		if instance == ancestor or instance:IsDescendantOf(ancestor) then
			return k
		end
	end

	return nil
end

function LazyLoadModelController.SetForcedCameraWindow(p, p2: number)
	Remotes.fireServer(CameraLazyLoadUtil.SET_FORCED_CAMERA_LAZY_LOAD, p, p2)
end

function LazyLoadModelController.ClearForcedCameraWindow()
	Remotes.fireServer(CameraLazyLoadUtil.SET_FORCED_CAMERA_LAZY_LOAD, CameraLazyLoadUtil.SOURCE_NONE)
end

function LazyLoadModelController.SetFreecamPosition(vector: Vector3)
	Remotes.fireServer(CameraLazyLoadUtil.SET_FREECAM_LAZY_LOAD, vector)
end

function LazyLoadModelController.ClearFreecamPosition()
	Remotes.fireServer(CameraLazyLoadUtil.SET_FREECAM_LAZY_LOAD, nil)
end

function LazyLoadModelController.FrameworkStart()
	Remotes.connect("LazyLoadModelToClient", function(instance, guid: string)
		v[guid] = instance
		addDebugLoaded(guid, instance:GetFullName())
		instance.Destroying:Once(function()
			removeDebugLoaded(guid)
		end)
		LazyLoadModelController.OnModelReceived:Fire(instance, guid)
	end)
	Remotes.connect("CleanLazyLoadModel", function(p: string)
		removeDebugLoaded(p)
		local v6 = v2[p]
		v2[p] = nil
		LazyLoadModelController.OnModelDestroyed:Fire(p)

		if v6 ~= nil and v6.Parent ~= nil then
			task.spawn(destroyModelOverTime, v6)
		end
	end)
	Remotes.onInvoke("EnsureLazyLoaded", function(p: string)
		for k, v6 in v do
			if v6.Name == p and v2[k] ~= nil then
				return true
			end
		end

		local v6 = CountDownLatch.new(1)
		local onModelReceivedConnection = LazyLoadModelController.OnModelReceived:Connect(function(p2, _)
			if p2.Name == p then
				v6:countDown()
			end
		end)
		local v7 = v6:await(5)
		onModelReceivedConnection:Disconnect()
		return v7
	end)
	local lazyLoadedModels = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("LazyLoadedModels")
	lazyLoadedModels.ChildAdded:Connect(function(child)
		processLazyLoadModel(child)
	end)

	for _, child in lazyLoadedModels:GetChildren() do
		processLazyLoadModel(child)
	end
end

return LazyLoadModelController