local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local v = Enum.RenderPriority.Camera.Value + 2
local object = setmetatable({}, {
	__mode = "k"
})
local count = 0
local v2 = false
local v3 = nil
local v4 = nil
local fieldOfView = nil
local v5 = nil

local function FOVMatches(p: number, p2: number)
	return math.abs(p - p2) <= 0.0001
end

local function GetRecord(p)
	local v6 = object[p]

	if v6 then
		return v6
	end

	local v7 = {
		CameraPart = nil,
		Alpha = 0,
		AlphaActive = false,
		FOV = nil,
		FOVActive = false,
		Order = 0,
		StudioCamera = nil,
		StudioBaseCFrame = nil,
		LastStudioCFrame = nil,
		StudioBaseFOV = nil,
		LastStudioFOV = nil
	}
	object[p] = v7
	return v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HasAlphaRecords()
	for _, v6 in object do
		if v6.AlphaActive then
			return true
		end
	end

	return false
end

local function FindActiveRecord()
	local v6 = nil
	local v7 = nil

	for k, v8 in object do
		local cameraPart = v8.CameraPart

		if not v8.AlphaActive or v8.Alpha <= 0 or not cameraPart or cameraPart.Parent ~= k then
			continue
		end

		if not (cameraPart.Name == "Camera" and (not v6 or v8.Order > v6.Order)) then
			continue
		end

		v7 = k
		v6 = v8
	end

	return v7, v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ResetRuntimeFOV(p)
	if v3 and v3 == p and fieldOfView and v5 and math.abs(v3.FieldOfView - v5) <= 0.0001 then
		v3.FieldOfView = fieldOfView
	end

	v3 = nil
	v4 = nil
	fieldOfView = nil
	v5 = nil
end

local function ApplyRuntimeFOV(currentCamera, p, data)
	local FOV = data.FOV

	if data.FOVActive and FOV then
		if v3 == currentCamera then
			if v5 and not (math.abs(currentCamera.FieldOfView - v5) <= 0.0001) then
				fieldOfView = currentCamera.FieldOfView
			end
		else
			ResetRuntimeFOV(nil) -- equivalent call inferred; original call site unknown
			v3 = currentCamera
			fieldOfView = currentCamera.FieldOfView
		end

		local v6 = fieldOfView or currentCamera.FieldOfView
		local fieldOfView2 = v6 + (FOV - v6) * data.Alpha
		currentCamera.FieldOfView = fieldOfView2
		v4 = p
		v5 = fieldOfView2
	else
		ResetRuntimeFOV(currentCamera) -- equivalent call inferred; original call site unknown
	end
end

local function RenderCamera()
	local currentCamera = Workspace.CurrentCamera
	local v6, v7 = FindActiveRecord()

	if currentCamera and v6 and v7 then
		local cameraPart = v7.CameraPart
		currentCamera.CFrame = currentCamera.CFrame:Lerp(cameraPart.CFrame, v7.Alpha)
		ApplyRuntimeFOV(currentCamera, v6, v7)
	else
		ResetRuntimeFOV(currentCamera) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateRenderStepBinding()
	local alphaRecords = HasAlphaRecords() -- equivalent call inferred; original call site unknown

	if alphaRecords == v2 then
		return
	end

	v2 = alphaRecords

	if alphaRecords then
		RunService:BindToRenderStep("OrchestratorCutsceneCamera", v, RenderCamera)
		return
	end

	RunService:UnbindFromRenderStep("OrchestratorCutsceneCamera")
	ResetRuntimeFOV(Workspace.CurrentCamera) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PrepareStudioRecord(state, currentCamera)
	if state.StudioCamera == currentCamera then
		return
	end

	state.StudioCamera = currentCamera
	state.StudioBaseCFrame = nil
	state.LastStudioCFrame = nil
	state.StudioBaseFOV = nil
	state.LastStudioFOV = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RestoreStudioCFrame(state)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera and currentCamera == state.StudioCamera and state.StudioBaseCFrame and (not state.LastStudioCFrame or currentCamera.CFrame == state.LastStudioCFrame) then
		currentCamera.CFrame = state.StudioBaseCFrame
	end

	state.StudioBaseCFrame = nil
	state.LastStudioCFrame = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RestoreStudioFOV(state)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera and currentCamera == state.StudioCamera and state.StudioBaseFOV and state.LastStudioFOV and math.abs(currentCamera.FieldOfView - state.LastStudioFOV) <= 0.0001 then
		currentCamera.FieldOfView = state.StudioBaseFOV
	end

	state.StudioBaseFOV = nil
	state.LastStudioFOV = nil
end

local function ApplyStudioCamera(state)
	if not state.AlphaActive then
		return
	end

	local currentCamera = Workspace.CurrentCamera
	local cameraPart = state.CameraPart

	if not (currentCamera and cameraPart) then
		return
	end

	PrepareStudioRecord(state, currentCamera) -- equivalent call inferred; original call site unknown

	if not state.StudioBaseCFrame or state.LastStudioCFrame and currentCamera.CFrame ~= state.LastStudioCFrame then
		state.StudioBaseCFrame = currentCamera.CFrame
	end

	local lerped = state.StudioBaseCFrame:Lerp(cameraPart.CFrame, state.Alpha)
	currentCamera.CFrame = lerped
	state.LastStudioCFrame = lerped
	local FOV = state.FOV

	if state.FOVActive and FOV then
		if not state.StudioBaseFOV or state.LastStudioFOV and not (math.abs(currentCamera.FieldOfView - state.LastStudioFOV) <= 0.0001) then
			state.StudioBaseFOV = currentCamera.FieldOfView
		end

		local studioBaseFOV = state.StudioBaseFOV
		local v6 = studioBaseFOV + (FOV - studioBaseFOV) * state.Alpha
		currentCamera.FieldOfView = v6
		state.LastStudioFOV = v6
	else
		RestoreStudioFOV(state) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveUnusedRecord(p, p2)
	if not (p2.AlphaActive or p2.FOVActive) then
		object[p] = nil
	end
end

local CutsceneCameraController = {}

function CutsceneCameraController.GetCameraPart(instance)
	local camera = instance:FindFirstChild("Camera")

	if camera and camera:IsA("BasePart") then
		return camera
	end

	return nil
end

function CutsceneCameraController.SetAlpha(p, cameraPart, alpha: number)
	local v6 = object[p]

	if not v6 then
		v6 = {
			CameraPart = nil,
			Alpha = 0,
			AlphaActive = false,
			FOV = nil,
			FOVActive = false,
			Order = 0,
			StudioCamera = nil,
			StudioBaseCFrame = nil,
			LastStudioCFrame = nil,
			StudioBaseFOV = nil,
			LastStudioFOV = nil
		}
		object[p] = v6
	end

	count += 1
	v6.CameraPart = cameraPart
	v6.Alpha = alpha
	v6.AlphaActive = true
	v6.Order = count

	if not RunService:IsRunning() then
		ApplyStudioCamera(v6)
		return
	end

	UpdateRenderStepBinding() -- equivalent call inferred; original call site unknown
end

function CutsceneCameraController.ClearAlpha(p)
	local v6 = object[p]

	if not v6 then
		return
	end

	v6.AlphaActive = false

	if RunService:IsRunning() then
		if v4 == p then
			ResetRuntimeFOV(Workspace.CurrentCamera) -- equivalent call inferred; original call site unknown
		end

		local alphaRecords = HasAlphaRecords() -- equivalent call inferred; original call site unknown

		if alphaRecords ~= v2 then
			v2 = alphaRecords

			if alphaRecords then
				RunService:BindToRenderStep("OrchestratorCutsceneCamera", v, RenderCamera)
			else
				RunService:UnbindFromRenderStep("OrchestratorCutsceneCamera")
				ResetRuntimeFOV(Workspace.CurrentCamera) -- equivalent call inferred; original call site unknown
			end
		end
	else
		RestoreStudioCFrame(v6) -- equivalent call inferred; original call site unknown
		RestoreStudioFOV(v6) -- equivalent call inferred; original call site unknown
	end

	RemoveUnusedRecord(p, v6) -- equivalent call inferred; original call site unknown
end

function CutsceneCameraController.SetFOV(p, FOV: number)
	local v6 = object[p]

	if not v6 then
		v6 = {
			CameraPart = nil,
			Alpha = 0,
			AlphaActive = false,
			FOV = nil,
			FOVActive = false,
			Order = 0,
			StudioCamera = nil,
			StudioBaseCFrame = nil,
			LastStudioCFrame = nil,
			StudioBaseFOV = nil,
			LastStudioFOV = nil
		}
		object[p] = v6
	end

	v6.FOV = FOV
	v6.FOVActive = true

	if not RunService:IsRunning() then
		ApplyStudioCamera(v6)
	end
end

function CutsceneCameraController.ClearFOV(p)
	local v6 = object[p]

	if not v6 then
		return
	end

	v6.FOV = nil
	v6.FOVActive = false

	if RunService:IsRunning() then
		if v4 == p then
			ResetRuntimeFOV(Workspace.CurrentCamera) -- equivalent call inferred; original call site unknown
		end
	else
		RestoreStudioFOV(v6) -- equivalent call inferred; original call site unknown
	end

	RemoveUnusedRecord(p, v6) -- equivalent call inferred; original call site unknown
end

return CutsceneCameraController