local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local v = Enum.RenderPriority.Camera.Value + 1
local v2 = nil
local count = 0
local flag = false
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getTargetCFrame(attachment)
	if attachment:IsA("Attachment") then
		return attachment.WorldCFrame
	end

	return attachment.CFrame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lockScriptableCamera(currentCamera, fieldOfView: number)
	if not flag then
		flag = true
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.FieldOfView = fieldOfView
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCameraIfOwned(cameraSnapshot)
	if flag then
		flag = false
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			currentCamera.CameraType = Enum.CameraType.Custom

			if cameraSnapshot then
				currentCamera.FieldOfView = cameraSnapshot.fieldOfView
				local cameraSubject = cameraSnapshot.cameraSubject

				if cameraSubject and cameraSubject.Parent and not (cameraSubject:IsA("Humanoid") and cameraSubject.Health <= 0) then
					currentCamera.CameraSubject = cameraSubject
				end

				currentCamera.CFrame = cameraSnapshot.cframe
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearResetWatch()
	if v3 then
		v3:Destroy()
		v3 = nil
	end
end

local function setRigsVisible(p, visibleRigs)
	for _, folder in visibleRigs do
		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
				continue
			end

			p.transparencies[descendant] = descendant.Transparency
			descendant.Transparency = descendant:IsA("BasePart") and (descendant.Name == "HumanoidRootPart" or descendant.Name == "RootPart") and 1 or 0
		end
	end
end

local function finish(state, flag2: boolean)
	if not state.isPlaying then
		return
	end

	state.isPlaying = false

	if v2 == state then
		v2 = nil
	end

	if state.completionThread and state.completionThread ~= coroutine.running() then
		pcall(task.cancel, state.completionThread)
	end

	state.completionThread = nil
	RunService:UnbindFromRenderStep(state.renderStepName)

	for _, connection in state.connections do
		connection:Disconnect()
	end

	table.clear(state.connections)

	for _, track in state.tracks do
		if track.IsPlaying then
			track:Stop(0)
		end

		track:Destroy()
	end

	table.clear(state.tracks)

	for instance, transparency in state.transparencies do
		if not (instance.Parent and (instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture"))) then
			continue
		end

		instance.Transparency = transparency
	end

	table.clear(state.transparencies)
	restoreCameraIfOwned(state.cameraSnapshot)
	clearResetWatch() -- equivalent call inferred; original call site unknown

	if state.onFinished then
		task.spawn(state.onFinished, flag2)
	end
end

local function bindResetWatch(p)
	clearResetWatch() -- equivalent call inferred; original call site unknown
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local character = localPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local characterRemovingConnection = localPlayer.CharacterRemoving:Connect(function()
		finish(p, false)
	end)
	local diedConnection

	if humanoid then
		diedConnection = humanoid.Died:Connect(function()
			finish(p, false)
		end)
	end

	local v4 = Janitor.new()
	v4:Add(characterRemovingConnection)

	if diedConnection then
		v4:Add(diedConnection)
	end

	v3 = v4
end

local Cutscenes = {}

function Cutscenes.play(data)
	if RunService:IsServer() then
		return nil
	end

	assert(#data.tracks > 0, "Cutscenes.play requires at least one track")

	if data.durationSeconds ~= nil then
		local v4

		if data.durationSeconds >= 0 then
			v4 = data.durationSeconds < 1e999
		else
			v4 = false
		end

		assert(v4, "Cutscenes.play requires a finite, non-negative durationSeconds")
	end

	if v2 then
		finish(v2, false)
	end

	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	count += 1
	local v4 = {
		name = data.name or `Cutscene{count}`,
		isPlaying = true,
		connections = {},
		tracks = {},
		transparencies = {},
		cameraSnapshot = {
			camera = currentCamera,
			cframe = currentCamera.CFrame,
			cameraType = currentCamera.CameraType,
			cameraSubject = currentCamera.CameraSubject,
			fieldOfView = currentCamera.FieldOfView
		},
		renderStepName = `AdminAbuseCutsceneCamera{count}`,
		onFinished = data.onFinished,
		completionThread = nil
	}
	v2 = v4

	if data.visibleRigs then
		setRigsVisible(v4, data.visibleRigs)
	end

	for _, track in data.tracks do
		local track2 = track.track
		track2.Looped = false
		table.insert(v4.tracks, track2)
	end

	if data.controlCamera ~= false then
		local fieldOfView = data.fieldOfView or 35
		lockScriptableCamera(currentCamera, fieldOfView) -- equivalent call inferred; original call site unknown
		RunService:BindToRenderStep(v4.renderStepName, v, function()
			if v4.isPlaying and data.cameraTarget.Parent and Workspace.CurrentCamera then
				local currentCamera2 = Workspace.CurrentCamera
				local targetCFrame = getTargetCFrame(data.cameraTarget) -- equivalent call inferred; original call site unknown
				currentCamera2.CFrame = targetCFrame
			end
		end)
		local targetCFrame = getTargetCFrame(data.cameraTarget) -- equivalent call inferred; original call site unknown
		currentCamera.CFrame = targetCFrame
	end

	if data.durationSeconds == nil then
		local count2 = #v4.tracks

		for _, track in v4.tracks do
			table.insert(v4.connections, track.Stopped:Connect(function()
				count2 -= 1

				if count2 == 0 then
					finish(v4, true)
				end
			end))
		end

		v4.completionThread = task.delay(30, function()
			finish(v4, false)
		end)
	else
		v4.completionThread = task.delay(data.durationSeconds, function()
			finish(v4, true)
		end)
	end

	for k, track in v4.tracks do
		local track2 = data.tracks[k]
		track:Play(track2.fadeTime or 0, track2.weight or 1, track2.speed or 1)
	end

	if data.controlCamera ~= false then
		bindResetWatch(v4)
	end

	return v4
end

function Cutscenes.stop(p)
	finish(p, false)
end

function Cutscenes.isPlaying()
	return v2 ~= nil and v2.isPlaying
end

function Cutscenes.cleanup()
	if v2 then
		finish(v2, false)
		return
	end

	restoreCameraIfOwned() -- equivalent call inferred; original call site unknown
	clearResetWatch() -- equivalent call inferred; original call site unknown
end

return Cutscenes