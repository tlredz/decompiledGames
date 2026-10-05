local createVector = vector.create
local ContentProvider = game:GetService("ContentProvider")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local services = game.ReplicatedStorage:WaitForChild("Services")
local Tweens = require(services:WaitForChild("Tweens"))
local LoadingData = require(script:WaitForChild("LoadingData"))
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local main = playerGui:WaitForChild("Main")
main.Enabled = false
local reusable = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Reusable")
local currentCamera = workspace.CurrentCamera

while not currentCamera do
	task.wait()
	currentCamera = workspace.CurrentCamera
end

local v = {
	Animals = 0.4,
	Lobby = 0.25,
	Ranch = 0.2,
	Data = 0.15
}
local v2 = {}
local flag = false
local inputBeganConnection = nil
local thread = nil
local renderSteppedConnection = nil
local renderSteppedConnection2 = nil
local clone = nil
local v3 = {
	AnimSaves = true,
	InitialPoses = true
}
local v4 = {
	MeshPart = true,
	SpecialMesh = true,
	FileMesh = true,
	Decal = true,
	Texture = true,
	SurfaceAppearance = true,
	ParticleEmitter = true,
	Beam = true,
	Trail = true,
	Sound = true,
	Animation = false,
	ImageLabel = true,
	ImageButton = true,
	Sky = true,
	Shirt = true,
	Pants = true,
	ShirtGraphic = true
}

for k in v do
	v2[k] = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Report(p, value)
	if v[p] == nil then
		warn(string.format("LoadingHandler: no weight registered for step %q", (tostring(p))))
	else
		v2[p] = math.clamp(value, 0, 1)
	end
end

local function TotalProgress()
	local total = 0

	for k, v5 in v do
		total += v2[k] * v5
	end

	return (math.clamp(total, 0, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AllStepsDone()
	for k in v do
		if (v2[k] or 0) < 1 then
			return false
		end
	end

	return true
end

local function DataDone()
	return (v2.Data or 0) >= 1
end

local v5 = true
local enabledChangedConnection = nil

local function LockBackpack()
	task.spawn(function()
		local backpackGui = playerGui:FindFirstChild("BackpackGui") or playerGui:WaitForChild("BackpackGui", 30)

		if backpackGui and v5 then
			backpackGui.Enabled = false
			enabledChangedConnection = backpackGui:GetPropertyChangedSignal("Enabled"):Connect(function()
				if v5 and backpackGui.Enabled then
					backpackGui.Enabled = false
				end
			end)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReleaseBackpack()
	v5 = false
	task.spawn(function()
		if enabledChangedConnection then
			enabledChangedConnection:Disconnect()
			enabledChangedConnection = nil
		end

		local backpackGui = playerGui:FindFirstChild("BackpackGui") or playerGui:WaitForChild("BackpackGui", 30)

		if backpackGui then
			backpackGui.Enabled = true
		end
	end)
end

task.spawn(function()
	local backpackGui = playerGui:FindFirstChild("BackpackGui") or playerGui:WaitForChild("BackpackGui", 30)

	if backpackGui and v5 then
		backpackGui.Enabled = false
		enabledChangedConnection = backpackGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			if v5 and backpackGui.Enabled then
				backpackGui.Enabled = false
			end
		end)
	end
end)
task.spawn(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	local tutorial = remotes and remotes:WaitForChild("Tutorial", 30)
	local step = tutorial and tutorial:WaitForChild("Step", 10)

	if step then
		step:FireServer(0)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function EnableMainUI()
	ReleaseBackpack() -- equivalent call inferred; original call site unknown
	task.spawn(function()
		local playerGuiMain = playerGui:FindFirstChild("Main") or playerGui:WaitForChild("Main", 20)

		if playerGuiMain then
			playerGuiMain.Enabled = true
		end
	end)
end

function Loaded()
	if flag == true then
		return
	end

	flag = true

	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end

	if thread then
		task.cancel(thread)
		thread = nil
	end

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if renderSteppedConnection2 then
		renderSteppedConnection2:Disconnect()
		renderSteppedConnection2 = nil
	end

	currentCamera.CameraType = Enum.CameraType.Custom
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		currentCamera.CameraSubject = humanoid
	end

	currentCamera.FieldOfView = 100
	TweenService:Create(currentCamera, TweenInfo.new(5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		FieldOfView = 70
	}):Play()
	EnableMainUI() -- equivalent call inferred; original call site unknown
	Tweens:FadeOut(clone, {
		FadeOutTime = 1
	})
	reusable.GameLoaded:FireServer()
	task.delay(1, function()
		localPlayer:SetAttribute("GameLoaded", true)
	end)
end

local function FindSpawn()
	for _, spawnLocation in workspace:GetDescendants() do
		if spawnLocation:IsA("SpawnLocation") and spawnLocation.Enabled then
			return spawnLocation
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartOrbit()
	local spawn = FindSpawn()
	local position = spawn and spawn.Position or createVector(144.864, 40313.293, 920.473)
	local v7 = position + createVector(0, 10, 0)
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 100
	local total = 0
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
		if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			currentCamera.CameraType = Enum.CameraType.Scriptable
		end

		total += dt / 60 * 3.141592653589793 * 2
		local vector2 = Vector3.new(math.cos(total) * 120, 55, math.sin(total) * 120)
		currentCamera.CFrame = CFrame.lookAt(position + vector2, v7)
	end)
end

local Collect

Collect = function(instance, children)
	for _, child in instance:GetChildren() do
		if v3[child.Name] then
			continue
		end

		if v4[child.ClassName] then
			table.insert(children, child)
		end

		Collect(child, children)
	end
end

local function LoadAnimals()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	local assets = game.ReplicatedStorage:FindFirstChild("Assets")
	local v6 = {}

	for _, childName in { "Pets" } do
		local child = assets and assets:FindFirstChild(childName)

		if child then
			Collect(child, v6)
		end
	end

	local animals = SoundService:FindFirstChild("Animals")

	if animals then
		Collect(animals, v6)
	end

	local pets = assets and assets:FindFirstChild("Pets")

	for i = #v6, 1, -1 do
		local animation = v6[i]

		if animation:IsA("Animation") and pets and animation:IsDescendantOf(pets) then
			table.remove(v6, i)
		end
	end

	if #v6 == 0 then
		if v.Animals == nil then
			warn(string.format("LoadingHandler: no weight registered for step %q", (tostring("Animals"))))
		else
			v2.Animals = 1
		end
	else
		local count = 0
		local success, result = pcall(function()
			ContentProvider:PreloadAsync(v6, function()
				count += 1
				Report("Animals", count / #v6) -- equivalent call inferred; original call site unknown
			end)
		end)

		if not success then
			warn("[Loading] animal preload failed: " .. tostring(result))
		end

		if v.Animals == nil then
			warn(string.format("LoadingHandler: no weight registered for step %q", (tostring("Animals"))))
		else
			v2.Animals = 1
		end
	end
end

local function LoadLobby()
	local spawn = FindSpawn()

	if not spawn then
		local v7 = os.clock() + 20

		repeat
			task.wait(0.1)
			spawn = FindSpawn()
		until spawn or v7 < os.clock()
	end

	local position = spawn and spawn.Position or createVector(144.864, 40313.293, 920.473)
	pcall(function()
		localPlayer:RequestStreamAroundAsync(position, 20)
	end)

	if v.Lobby == nil then
		warn(string.format("LoadingHandler: no weight registered for step %q", (tostring("Lobby"))))
	else
		v2.Lobby = 0.25
	end

	local overlapParams = OverlapParams.new()
	overlapParams.MaxParts = 20000
	local total = 0
	local total2 = 0
	local v7 = -1

	while total < 1.5 and total2 < 45 do
		task.wait(0.2)
		total2 += 0.2
		local count = #workspace:GetPartBoundsInRadius(position, 200, overlapParams)

		if v7 < count then
			v7 = count
			total = 0
		else
			total += 0.2
		end

		Report("Lobby", math.min(total / 1.5, 1) * 0.75 + 0.25) -- equivalent call inferred; original call site unknown
	end

	if v.Lobby == nil then
		warn(string.format("LoadingHandler: no weight registered for step %q", (tostring("Lobby"))))
	else
		v2.Lobby = 1
	end
end

local function LoadData()
	local noSaveData = localPlayer:WaitForChild("NoSaveData", 30)
	local dataLoaded = noSaveData and noSaveData:WaitForChild("DataLoaded", 30)

	if dataLoaded then
		if v.Data == nil then
			warn(string.format("LoadingHandler: no weight registered for step %q", (tostring("Data"))))
		else
			v2.Data = 0.5
		end

		while not dataLoaded.Value do
			dataLoaded.Changed:Wait()
		end
	end

	if v.Data == nil then
		warn(string.format("LoadingHandler: no weight registered for step %q", (tostring("Data"))))
	else
		v2.Data = 1
	end
end

local function LoadRanch()
	local v6 = os.clock() + 30
	local baseplate = nil

	while true do
		local plots = workspace:FindFirstChild("Plots")

		for _, v8 in plots and plots:GetChildren() or {} do
			local data = v8:FindFirstChild("Data")
			local owner = data and data:FindFirstChild("Owner")

			if not (owner and owner.Value == localPlayer) then
				continue
			end

			baseplate = v8:FindFirstChild("Baseplate")
			break
		end

		if not baseplate then
			task.wait(0.25)
		end

		if not (baseplate or v6 < os.clock()) then
			continue
		end

		if baseplate then
			local position = baseplate.Position
			pcall(function()
				localPlayer:RequestStreamAroundAsync(position, 20)
			end)

			if v.Ranch == nil then
				warn(string.format("LoadingHandler: no weight registered for step %q", (tostring("Ranch"))))
			else
				v2.Ranch = 0.25
			end

			local overlapParams = OverlapParams.new()
			overlapParams.MaxParts = 20000
			local total = 0
			local total2 = 0
			local v9 = -1

			while total < 1.5 and total2 < 45 do
				task.wait(0.2)
				total2 += 0.2
				local count = #workspace:GetPartBoundsInRadius(position, 200, overlapParams)

				if v9 < count then
					v9 = count
					total = 0
				else
					total += 0.2
				end

				Report("Ranch", math.min(total / 1.5, 1) * 0.75 + 0.25) -- equivalent call inferred; original call site unknown
			end

			if v.Ranch == nil then
				warn(string.format("LoadingHandler: no weight registered for step %q", (tostring("Ranch"))))
			else
				v2.Ranch = 1
			end

			break
		else
			if v.Ranch == nil then
				warn(string.format("LoadingHandler: no weight registered for step %q", (tostring("Ranch"))))
			else
				v2.Ranch = 1
			end

			break
		end
	end
end

function InitiateLoading()
	clone = script:WaitForChild("Loading"):Clone()
	local clickToSkipReminder = clone:WaitForChild("ClickToSkipReminder")
	local facts = clone:WaitForChild("Facts")
	local position = facts.Position
	local v6 = false
	local flag2 = false

	local function ShowDataWait()
		if flag2 then
			return
		end

		flag2 = true

		if thread then
			task.cancel(thread)
			thread = nil
		end

		facts.Text = "Still loading your save... your pets and items are safe."
		TweenService:Create(facts, TweenInfo.new(0.5), {
			TextTransparency = 0,
			Position = position
		}):Play()
		Tweens:FadeOut(clickToSkipReminder, {
			FadeOutTime = 0.3
		})
	end

	local v7 = nil

	for _, frame in clone:GetChildren() do
		if frame.Name == "Progress" and frame:IsA("Frame") then
			v7 = frame
		end
	end

	local bar = v7 and v7:WaitForChild("Bar")
	local phoenix = clone:WaitForChild("Phoenix")
	local position2 = phoenix.Position
	local frame1 = phoenix:FindFirstChild("Frame1")
	local v8 = nil
	local v9 = 0

	for _, image in clone:GetChildren() do
		if image:IsA("ImageLabel") and image.ZIndex >= 10 then
			v8 = image
		end
	end

	if frame1 and v8 then
		v9 = v8.Position.X.Scale - frame1.Position.X.Scale
	end

	local v10 = not bar and 0 or bar.Size.X.Scale or 0
	local v11 = not bar and 1 or bar.Size.Y.Scale or 1
	thread = task.spawn(function()
		local clone2 = table.clone(LoadingData.Facts)

		while true do
			if #clone2 == 0 then
				clone2 = table.clone(LoadingData.Facts)
			end

			local v12 = math.random(1, #clone2)
			facts.Text = table.remove(clone2, v12)
			TweenService:Create(facts, TweenInfo.new(0.5), {
				TextTransparency = 0,
				Position = position
			}):Play()
			task.wait(5)
			TweenService:Create(facts, TweenInfo.new(0.5), {
				TextTransparency = 1,
				Position = position + UDim2.new(0, 0, 0.03, 0)
			}):Play()
			task.wait(0.6)
		end
	end)
	task.delay(1, function()
		if flag then
			return
		end

		Tweens:FadeIn(clickToSkipReminder, {
			FadeInTime = 1
		})
		inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed == true then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v6 = true
			end
		end)
	end)
	clone.Parent = playerGui
	StartOrbit() -- equivalent call inferred; original call site unknown
	local total = 0
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local total2 = 0

		for k, v12 in v do
			total2 += v2[k] * v12
		end

		local v12 = math.clamp(total2, 0, 1)
		total += (v12 - total) * math.min(dt * 3, 1)

		if bar then
			bar.Size = UDim2.new(math.max(total, v10), 0, v11, 0)
		end

		phoenix.Position = position2 + UDim2.new(v9 * total, 0, 0, 0)
	end)
	task.spawn(LoadAnimals)
	task.spawn(LoadLobby)
	task.spawn(LoadData)
	task.spawn(LoadRanch)
	task.spawn(function()
		local total2 = 0

		while not flag do
			local allStepsDone = AllStepsDone() -- equivalent call inferred; original call site unknown

			if allStepsDone and total2 >= 7 then
				task.wait(0.45)
				break
			end

			if v6 or total2 >= 45 then
				if (v2.Data or 0) >= 1 or total2 >= 240 then
					break
				else
					ShowDataWait()
				end
			end

			total2 += task.wait(0.1)
		end

		Loaded()
	end)
end

if TeleportService:GetLocalPlayerTeleportData() then
	reusable.GameLoaded:FireServer()
	localPlayer:SetAttribute("GameLoaded", true)
	v5 = false
	task.spawn(function()
		if enabledChangedConnection then
			enabledChangedConnection:Disconnect()
			enabledChangedConnection = nil
		end

		local backpackGui = playerGui:FindFirstChild("BackpackGui") or playerGui:WaitForChild("BackpackGui", 30)

		if backpackGui then
			backpackGui.Enabled = true
		end
	end)
	task.spawn(function()
		local playerGuiMain = playerGui:FindFirstChild("Main") or playerGui:WaitForChild("Main", 20)

		if playerGuiMain then
			playerGuiMain.Enabled = true
		end
	end)
else
	InitiateLoading()
end