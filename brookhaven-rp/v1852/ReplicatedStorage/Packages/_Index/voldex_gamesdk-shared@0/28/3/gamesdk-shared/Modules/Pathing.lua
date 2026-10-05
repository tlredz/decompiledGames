local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent.Parent
local Promise = require(parent.Promise)
local localPlayer = Players.LocalPlayer
local Pathing = {
	_remote = nil,
	_fetchRemote = nil,
	_recordTask = nil,
	_playTask = nil,
	_initialized = false
}

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(p)
	error("[GameSdk - Pathing] " .. p)
end

local function _assertInitialized(flag: boolean, p: string)
	if Pathing._initialized ~= flag then
		erroro(p) -- equivalent call inferred; original call site unknown
	end
end

local function createAsyncPathTask(p: number, p2: number, callback)
	return task.spawn(function()
		local now = os.clock()
		local v = {
			characterPosition = {},
			cameraCFrame = {}
		}

		for i = 1, math.max(1, (math.floor(p2 / p))) do
			local position = localPlayer.Character:GetPivot().Position
			local cFrame = workspace.CurrentCamera.CFrame
			table.insert(v.characterPosition, position)
			table.insert(v.cameraCFrame, cFrame)
			local v2 = now + i * p - os.clock()

			if v2 > 0 then
				task.wait(v2)
			end
		end

		callback(v)
	end)
end

local function onClientPathRemote(pathName: string, interval: number, p3: number)
	if Pathing._recordTask == nil then
		local function fn(p4)
			Pathing._recordTask = nil
			Pathing._remote:FireServer({
				data = p4,
				pathName = pathName,
				interval = interval
			})
		end

		Pathing._recordTask = task.spawn(function()
			local now = os.clock()
			local v = {
				characterPosition = {},
				cameraCFrame = {}
			}

			for i = 1, math.max(1, (math.floor(p3 / interval))) do
				local position = localPlayer.Character:GetPivot().Position
				local cFrame = workspace.CurrentCamera.CFrame
				table.insert(v.characterPosition, position)
				table.insert(v.cameraCFrame, cFrame)
				local v2 = now + i * interval - os.clock()

				if v2 > 0 then
					task.wait(v2)
				end
			end

			fn(v)
		end)
	else
		task.cancel(Pathing._recordTask)
		Pathing._recordTask = nil
	end
end

local function onClientPathPlayRemote(p: number, p2)
	if Pathing._playTask == nil then
		local character = localPlayer.Character

		if character == nil then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return
		end

		local currentCamera = workspace.CurrentCamera
		Pathing._playTask = task.spawn(function()
			humanoidRootPart.Anchored = true
			local cameraType = currentCamera.CameraType
			currentCamera.CameraType = Enum.CameraType.Scriptable
			local now = os.clock()

			for i = 1, math.min(#p2.characterPosition, #p2.cameraCFrame) do
				local v = p2.characterPosition[i]
				local cFrame = p2.cameraCFrame[i]
				localPlayer.Character:PivotTo(CFrame.new(v))
				currentCamera.CFrame = cFrame
				local v3 = now + i * p - os.clock()

				if v3 > 0 then
					task.wait(v3)
				end
			end

			humanoidRootPart.Anchored = false
			currentCamera.CameraType = cameraType
			Pathing._playTask = nil
		end)
	else
		task.cancel(Pathing._playTask)
		Pathing._playTask = nil
	end
end

function Pathing.Init()
	if Pathing._initialized ~= false then
		error("[GameSdk - Pathing] Already initialized")
	end

	Pathing._remote = ReplicatedStorage:WaitForChild("GameSdkPathingRemoteEvent", 20)

	if Pathing._remote == nil then
		error("[GameSdk - Pathing] Failed to find remote event")
	end

	Pathing._remote.OnClientEvent:Connect(onClientPathRemote)
	Pathing._pathPlayRemote = ReplicatedStorage:WaitForChild("GameSdkPathingPlayRemoteEvent", 20)

	if Pathing._pathPlayRemote == nil then
		error("[GameSdk - Pathing] Failed to find remote event")
	end

	Pathing._pathPlayRemote.OnClientEvent:Connect(onClientPathPlayRemote)
	Pathing._fetchRemote = ReplicatedStorage:WaitForChild("GameSdkPathingRemoteFunction", 20)

	if Pathing._fetchRemote == nil then
		error("[GameSdk - Pathing] Failed to find remote function")
	end

	Pathing._initialized = true
end

function Pathing.ListPaths()
	return Promise.new(function(callback, _)
		callback(Pathing._fetchRemote:InvokeServer())
	end)
end

return Pathing