local SpectateService1 = {}
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrentRoundClient = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = { Enum.KeyCode.Q, Enum.KeyCode.ButtonL1 }
local v2 = { Enum.KeyCode.E, Enum.KeyCode.ButtonR1 }
local children = {}
local flag = false
local v3 = 1
local v4 = nil
SpectateService1.SpectateStarted = script:WaitForChild("SpectateStarted")
SpectateService1.SpectateCancelled = script:WaitForChild("SpectateCancelled")
SpectateService1.SpectateTargetChanged = script:WaitForChild("SpectateTargetChanged")

-- equivalent calls inferred from this helper; original call sites unknown
local function isAlive()
	return CurrentRoundClient.PlayerData[localPlayer.Name] and CurrentRoundClient.PlayerData[localPlayer.Name].Dead ~= true
end

local function focusCamera(player)
	if not player.Character then
		return false
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return false
	end

	v4 = player
	currentCamera.CameraSubject = humanoid
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindSpectateKeybind()
	ContextActionService:UnbindAction("SpectateLeft")
	ContextActionService:UnbindAction("SpectateRight")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelSpectate()
	flag = false
	local localPlayer2 = localPlayer
	local humanoid = localPlayer2.Character and localPlayer2.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		v4 = localPlayer2
		currentCamera.CameraSubject = humanoid
	end

	unbindSpectateKeybind() -- equivalent call inferred; original call site unknown
	SpectateService1.SpectateCancelled:Fire()
end

function SpectateService1.CancelSpectate(_)
	cancelSpectate() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCameraFocus()
	local v5 = children[v3]

	if v5 and flag then
		local humanoid = v5.Character and v5.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			v4 = v5
			currentCamera.CameraSubject = humanoid
		end

		SpectateService1.SpectateTargetChanged:Fire(v5)
	else
		cancelSpectate() -- equivalent call inferred; original call site unknown
	end
end

local function updateSpectatablePlayers()
	children = {}

	for childName, v5 in CurrentRoundClient.PlayerData do
		if childName == localPlayer.Name then
			continue
		end

		local child = game.Players:FindFirstChild(childName)

		if child and v5.Dead ~= true then
			table.insert(children, child)
		end
	end
end

function SpectateService1:NavigateSpectate(p: number)
	v3 += p

	if v3 > #children then
		v3 = 1
	elseif v3 < 1 then
		v3 = #children
	end

	updateCameraFocus() -- equivalent call inferred; original call site unknown
end

local function onSpectateKeybind(p: string, p2, _)
	if p2 ~= Enum.UserInputState.Begin then
		return
	end

	if p == "SpectateLeft" then
		SpectateService1:NavigateSpectate(-1)
	else
		SpectateService1:NavigateSpectate(1)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindSpectateKeybinds()
	ContextActionService:BindAction("SpectateLeft", onSpectateKeybind, false, unpack(v))
	ContextActionService:BindAction("SpectateRight", onSpectateKeybind, false, unpack(v2))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function beginSpectate()
	flag = true
	v3 = 1
	SpectateService1.SpectateStarted:Fire()
	updateSpectatablePlayers()
	updateCameraFocus() -- equivalent call inferred; original call site unknown
	bindSpectateKeybinds() -- equivalent call inferred; original call site unknown
end

function SpectateService1.ToggleSpectate(_)
	if flag or isAlive() then
		cancelSpectate() -- equivalent call inferred; original call site unknown
	else
		beginSpectate() -- equivalent call inferred; original call site unknown
	end
end

local function onPlayerDataUpdated()
	if isAlive() then
		cancelSpectate() -- equivalent call inferred; original call site unknown
	end

	updateSpectatablePlayers()

	while children[v3] == nil and v3 > 1 do
		v3 -= 1
	end

	if flag then
		updateCameraFocus() -- equivalent call inferred; original call site unknown
	end
end

updateSpectatablePlayers()
CurrentRoundClient.PlayerDataChanged.Event:Connect(onPlayerDataUpdated)
return SpectateService1