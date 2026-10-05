local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local t = require(ReplicatedStorage.Packages.t)
local Player = require(ReplicatedStorage.Shared.Player)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local TreadmillFlags = require(ReplicatedStorage.Shared.Flags.TreadmillFlags)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
local playerScripts = localPlayer:WaitForChild("PlayerScripts")
local PlayerModule = require(playerScripts.PlayerModule)
local cameras = PlayerModule:GetCameras()
local v = nil
local v2 = nil
local v3 = nil
local count = 0
local v4 = {}
local v5 = {}
local TreadmillCharacterPresentationController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreSnapshot(p)
	for k, partState in pairs(p.PartStates) do
		if k.Parent ~= nil then
			k.Transparency = partState
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreActiveSnapshot()
	local v6 = v2
	v2 = nil

	if v6 == nil then
		return
	end

	v6.DescendantTrove:Destroy()
	restoreSnapshot(v6) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreBillboardAlwaysOnTop(state, alwaysOnTop: boolean)
	if v4[state] ~= alwaysOnTop then
		return
	end

	v4[state] = nil

	if state.Parent ~= nil and state.AlwaysOnTop == false then
		state.AlwaysOnTop = alwaysOnTop
	end
end

local function setBillboardNotAlwaysOnTop(localBaseSign)
	t.strict(t.instanceIsA("BillboardGui"))(localBaseSign)
	local maid = v

	if maid == nil or v4[localBaseSign] ~= nil then
		return
	end

	local alwaysOnTop = localBaseSign.AlwaysOnTop
	v4[localBaseSign] = alwaysOnTop
	localBaseSign.AlwaysOnTop = false
	maid:Connect(localBaseSign:GetPropertyChangedSignal("AlwaysOnTop"), function()
		if localBaseSign.AlwaysOnTop ~= false then
			v4[localBaseSign] = nil
		end
	end)
	maid:Add(function()
		restoreBillboardAlwaysOnTop(localBaseSign, alwaysOnTop) -- equivalent call inferred; original call site unknown
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreHumanoidDisplayDistanceType(state, displayDistanceType)
	if v5[state] ~= displayDistanceType then
		return
	end

	v5[state] = nil

	if state.Parent ~= nil and state.DisplayDistanceType == Enum.HumanoidDisplayDistanceType.None then
		state.DisplayDistanceType = displayDistanceType
	end
end

local function hideVisibleHumanoidDisplayDistance(humanoid)
	t.strict(t.instanceIsA("Humanoid"))(humanoid)
	local maid = v

	if maid == nil or v5[humanoid] ~= nil then
		return
	end

	local displayDistanceType = humanoid.DisplayDistanceType

	if displayDistanceType == Enum.HumanoidDisplayDistanceType.None then
		return
	end

	v5[humanoid] = displayDistanceType
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	maid:Connect(humanoid:GetPropertyChangedSignal("DisplayDistanceType"), function()
		if humanoid.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
			v5[humanoid] = nil
		end
	end)
	maid:Add(function()
		restoreHumanoidDisplayDistanceType(humanoid, displayDistanceType) -- equivalent call inferred; original call site unknown
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCameraTransparency(magnitude: number)
	if magnitude <= 5 then
		return 1
	end

	return (math.clamp(1 - (magnitude - 5) / 8, 0, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackCharacterPart(p, part)
	if not (part:IsA("BasePart") and part:FindFirstAncestorWhichIsA("Tool") == nil and p.PartStates[part] == nil) then
		return
	end

	p.PartStates[part] = part.Transparency
end

local function bindCharacter(folder)
	local v6 = v

	if v6 == nil then
		return
	end

	restoreActiveSnapshot() -- equivalent call inferred; original call site unknown
	local v7 = {
		Character = folder,
		DescendantTrove = v6:Extend(),
		PartStates = {}
	}
	v2 = v7

	for _, descendant in ipairs(folder:GetDescendants()) do
		trackCharacterPart(v7, descendant) -- equivalent call inferred; original call site unknown
	end

	v7.DescendantTrove:Connect(folder.DescendantAdded, function(part)
		trackCharacterPart(v7, part) -- equivalent call inferred; original call site unknown
	end)
end

local function updateCharacterTransparency()
	local currentCamera = Workspace.CurrentCamera
	local head = Player.FindHead(localPlayer)

	if currentCamera == nil or head == nil then
		return
	end

	local v6 = v2
	local parent = head.Parent

	if v6 == nil or parent ~= v6.Character then
		return
	end

	local cameraTransparency = getCameraTransparency((currentCamera.CFrame.Position - head.Position).Magnitude) -- equivalent call inferred; original call site unknown

	for k, partState in pairs(v6.PartStates) do
		if k.Parent == nil then
			v6.PartStates[k] = nil
		else
			k.Transparency = math.max(partState, cameraTransparency)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveCurrentTransparency()
	local currentCamera = Workspace.CurrentCamera
	local head = Player.FindHead(localPlayer)

	if currentCamera == nil or head == nil then
		return nil
	end

	local v6 = v2

	if v6 == nil or head.Parent ~= v6.Character then
		return nil
	end

	local magnitude = (currentCamera.CFrame.Position - head.Position).Magnitude

	if magnitude <= 5 then
		return 1
	end

	return (math.clamp(1 - (magnitude - 5) / 8, 0, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreAutoCameraState()
	local currentCamera = Workspace.CurrentCamera

	if currentCamera ~= nil and currentCamera.CameraType == Enum.CameraType.Scriptable then
		currentCamera.CameraType = Enum.CameraType.Custom
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function commitAutoCameraDistance(cframe: CFrame)
	cameras:CommitCameraCFrame(cframe, Enum.CameraType.Custom)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function completeAutoCameraState(cframe: CFrame)
	local v6 = v3
	v3 = nil

	if v6 == nil then
		return
	end

	commitAutoCameraDistance(cframe) -- equivalent call inferred; original call site unknown
	restoreAutoCameraState() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearAutoCameraState()
	local v6 = v3
	v3 = nil

	if v6 == nil then
		return
	end

	restoreAutoCameraState() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveAutoCameraFocusPoint(rootPart, focusOffset: Vector3)
	return rootPart.CFrame:PointToWorldSpace(focusOffset)
end

local function resolveAutoCameraTargetCFrame(instance, vector2: Vector3)
	local v6 = instance.Position - vector2

	if v6.Magnitude <= 0.001 then
		v6 = -instance.CFrame.LookVector
	end

	local v7 = vector2 - v6.Unit * 1.8
	return CFrame.lookAt(v7, instance.Position + createVector(0, 0.12, 0), createVector(0, 1, 0))
end

local function updateAutoCamera()
	local v6 = v3

	if v6 == nil then
		return
	end

	local currentCamera = Workspace.CurrentCamera
	local head = Player.FindHead(localPlayer)
	local rootPart = Player.FindRootPart(localPlayer)
	local videoScreenPart = v6.VideoScreenPart

	if currentCamera == nil or head == nil or rootPart == nil or videoScreenPart == nil then
		return
	end

	if videoScreenPart.Parent == nil then
		clearAutoCameraState() -- equivalent call inferred; original call site unknown
	else
		local autoCameraFocusPoint = resolveAutoCameraFocusPoint(rootPart, v6.FocusOffset) -- equivalent call inferred; original call site unknown
		local v7 = videoScreenPart.Position - autoCameraFocusPoint

		if v7.Magnitude <= 0.001 then
			v7 = -videoScreenPart.CFrame.LookVector
		end

		local v8 = autoCameraFocusPoint - v7.Unit * 1.8
		local cframe = CFrame.lookAt(v8, videoScreenPart.Position + createVector(0, 0.12, 0), createVector(0, 1, 0))
		local v9 = math.clamp((os.clock() - v6.StartedAt) / 0.35, 0, 1)
		currentCamera.CFrame = v6.InitialCameraCFrame:Lerp(
			cframe,
			TweenService:GetValue(v9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		)

		if v9 >= 1 then
			completeAutoCameraState(cframe) -- equivalent call inferred; original call site unknown
		end
	end
end

local function findActiveTreadmill(p: string)
	for _, v6 in CollectionService:GetTagged("ActiveTreadmill") do
		if v6:GetAttribute("ActiveTreadmillId") == p then
			return v6
		end
	end

	return nil
end

local function bindAutoCameraScreen(p: string, p2: number)
	local activeTreadmill = findActiveTreadmill(p)
	assert(activeTreadmill ~= nil, (`No active treadmill is bound for "{p}"`))
	assert(activeTreadmill:IsA("Tool"), (`Runtime treadmill "{p}" must be a Tool`))
	local v6 = v3

	if v6 == nil or v6.Token ~= p2 then
		return
	end

	local videoFeedScreenPart = TreadmillUtil.FindVideoFeedScreenPart(activeTreadmill)

	if videoFeedScreenPart ~= nil then
		v6.VideoScreenPart = videoFeedScreenPart
		return
	end

	clearAutoCameraState() -- equivalent call inferred; original call site unknown
end

local function bindPlayerDisplayDistance(player)
	t.strict(t.instanceIsA("Player"))(player)
	local v6 = v

	if v6 == nil then
		return
	end

	local humanoid = Player.FindHumanoid(player)

	if humanoid ~= nil then
		hideVisibleHumanoidDisplayDistance(humanoid)
	end

	local function bindPlayerCharacterDisplayDistance(character)
		t.strict(t.instanceIsA("Model"))(character)
		local humanoid2 = Player.FindHumanoid(player)

		if humanoid2 ~= nil then
			hideVisibleHumanoidDisplayDistance(humanoid2)
		end

		v6:Connect(character.ChildAdded, function(humanoid3)
			if humanoid3:IsA("Humanoid") then
				hideVisibleHumanoidDisplayDistance(humanoid3)
			end
		end)
	end

	if player.Character ~= nil then
		bindPlayerCharacterDisplayDistance(player.Character)
	end

	v6:Connect(player.CharacterAdded, bindPlayerCharacterDisplayDistance)
end

local function bindHumanoidDisplayPresentation()
	local v6 = v

	if v6 == nil then
		return
	end

	for _, v7 in ipairs(Players:GetPlayers()) do
		task.defer(bindPlayerDisplayDistance, v7)
	end

	v6:Connect(Players.PlayerAdded, bindPlayerDisplayDistance)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindYourBaseBillboardPresentation()
	local maid = v

	if maid == nil then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindCurrentPlot()
		local localBaseSign = PlotState.FindLocalBaseSign()

		if localBaseSign ~= nil then
			setBillboardNotAlwaysOnTop(localBaseSign)
		end
	end

	bindCurrentPlot() -- equivalent call inferred; original call site unknown
	maid:Add(PlotState.LocalPlotChanged:Connect(bindCurrentPlot))
end

function TreadmillCharacterPresentationController.Stop()
	count += 1
	clearAutoCameraState() -- equivalent call inferred; original call site unknown
	local v6 = v
	v = nil

	if v6 ~= nil then
		v6:Destroy()
		return
	end

	restoreActiveSnapshot() -- equivalent call inferred; original call site unknown
end

function TreadmillCharacterPresentationController.StopCameraTransparency()
	TreadmillCharacterPresentationController.Stop()
end

function TreadmillCharacterPresentationController.Start(p: string)
	t.strict(t.string)(p)
	TreadmillCharacterPresentationController.Stop()
	count += 1
	local token = count
	local v7 = Trove.new()
	v = v7
	local currentCamera = Workspace.CurrentCamera
	local rootPart = Player.FindRootPart(localPlayer)
	local cameraSubjectPosition = cameras:GetCameraSubjectPosition(Enum.CameraType.Custom)

	if currentCamera ~= nil and cameraSubjectPosition ~= nil and rootPart ~= nil and not TreadmillFlags.CameraAutoFrameDisabled:Get() then
		v3 = {
			FocusOffset = rootPart.CFrame:PointToObjectSpace(cameraSubjectPosition),
			InitialCameraCFrame = currentCamera.CFrame,
			StartedAt = os.clock(),
			Token = token,
			VideoScreenPart = nil
		}
		task.spawn(bindAutoCameraScreen, p, token)
	end

	local character = localPlayer.Character

	if character ~= nil then
		bindCharacter(character)
	end

	v7:Connect(localPlayer.CharacterAdded, bindCharacter)
	v7:BindToRenderStep("TreadmillCameraAutoFrame", Enum.RenderPriority.Camera.Value + 1, updateAutoCamera)
	v7:BindToRenderStep(
		"TreadmillCameraTransparency",
		Enum.RenderPriority.Camera.Value + 2,
		updateCharacterTransparency
	)
	bindHumanoidDisplayPresentation()
	bindYourBaseBillboardPresentation() -- equivalent call inferred; original call site unknown
	v7:Add(restoreActiveSnapshot)
	v7:Add(clearAutoCameraState)
end

function TreadmillCharacterPresentationController.StartCameraTransparency(p: string)
	TreadmillCharacterPresentationController.Start(p)
end

function TreadmillCharacterPresentationController.IsLocalCharacterFullyTransparent()
	local currentTransparency = resolveCurrentTransparency() -- equivalent call inferred; original call site unknown
	return currentTransparency ~= nil and currentTransparency >= 1
end

TreadmillFlags.CameraAutoFrameDisabled.Changed:Connect(function(flag: boolean)
	if flag then
		clearAutoCameraState() -- equivalent call inferred; original call site unknown
	end
end)
return TreadmillCharacterPresentationController