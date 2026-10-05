local SpectateService = {}
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrentRoundClient = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = { Enum.KeyCode.Q }
local v2 = { Enum.KeyCode.E }
local v3 = {}
local v4 = nil
SpectateService.SpectateStarted = script:WaitForChild("SpectateStarted")
SpectateService.SpectateCancelled = script:WaitForChild("SpectateCancelled")
SpectateService.SpectateTargetChanged = script:WaitForChild("SpectateTargetChanged")

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerRoundData(p)
	return CurrentRoundClient.PlayerData[p.Name]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playerIsAlive(p)
	local playerRoundData = getPlayerRoundData(p) -- equivalent call inferred; original call site unknown

	if playerRoundData then
		return playerRoundData.Dead ~= true
	end

	return false
end

local function isPlayerSpectatable(player)
	if not (player ~= nil and player.Parent ~= nil and player.Character and player.Character:FindFirstChildOfClass("Humanoid")) then
		return false
	end

	-- equivalent call inferred; original call site unknown
	if playerIsAlive(player) then
		return true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetCamera()
	if not localPlayer.Character then
		currentCamera.CameraSubject = nil
		return
	end

	local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		currentCamera.CameraSubject = humanoid
	else
		currentCamera.CameraSubject = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindSpectateKeybind()
	ContextActionService:UnbindAction("SpectateLeft")
	ContextActionService:UnbindAction("SpectateRight")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelSpectate()
	isSpectating = false
	resetCamera() -- equivalent call inferred; original call site unknown
	unbindSpectateKeybind() -- equivalent call inferred; original call site unknown
	SpectateService.SpectateCancelled:Fire()
end

local function updateCameraFocus()
	if not isSpectating then
		return
	end

	if v4 == nil then
		cancelSpectate() -- equivalent call inferred; original call site unknown
	elseif v4.Character then
		local humanoid = v4.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			currentCamera.CameraSubject = humanoid
			SpectateService.SpectateTargetChanged:Fire(v4)
		else
			cancelSpectate() -- equivalent call inferred; original call site unknown
		end
	else
		cancelSpectate() -- equivalent call inferred; original call site unknown
	end
end

function SpectateService.CancelSpectate(_)
	cancelSpectate() -- equivalent call inferred; original call site unknown
end

function SpectateService:NavigateSpectate(p: number)
	local index = table.find(v3, v4)

	if index then
		local v5 = index + p
		local v6 = #v3 < v5 and 1 or v5 < 1 and #v3 or v5
		local v7 = v3[v6]

		if v7 then
			v4 = v7
			updateCameraFocus()
		else
			cancelSpectate() -- equivalent call inferred; original call site unknown
		end
	else
		cancelSpectate() -- equivalent call inferred; original call site unknown
	end
end

local function onSpectateKeybind(p: string, p2, _)
	if p2 ~= Enum.UserInputState.Begin then
		return
	end

	if p == "SpectateLeft" then
		SpectateService:NavigateSpectate(-1)
	else
		SpectateService:NavigateSpectate(1)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindSpectateKeybinds()
	ContextActionService:BindAction("SpectateLeft", onSpectateKeybind, false, unpack(v))
	ContextActionService:BindAction("SpectateRight", onSpectateKeybind, false, unpack(v2))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function beginSpectate()
	isSpectating = true
	SpectateService.SpectateStarted:Fire()

	if v4 == nil then
		v4 = v3[1]
	end

	bindSpectateKeybinds() -- equivalent call inferred; original call site unknown
	updateCameraFocus()
end

function SpectateService.ToggleSpectate(_)
	if not isSpectating then
		-- equivalent call inferred; original call site unknown
		if not playerIsAlive(localPlayer) then
			beginSpectate() -- equivalent call inferred; original call site unknown
			return
		end
	end

	cancelSpectate() -- equivalent call inferred; original call site unknown
end

function SpectateService.SetSpectating(_, flag: boolean)
	local humanoid

	if isSpectating then
		isSpectating = false

		if localPlayer.Character then
			humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				currentCamera.CameraSubject = humanoid
			else
				currentCamera.CameraSubject = nil
			end
		else
			currentCamera.CameraSubject = nil
		end

		unbindSpectateKeybind() -- equivalent call inferred; original call site unknown
		SpectateService.SpectateCancelled:Fire()
	else
		local v6 = playerIsAlive(localPlayer) -- equivalent call inferred; original call site unknown

		if v6 or not flag then
			isSpectating = false

			if localPlayer.Character then
				humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					currentCamera.CameraSubject = humanoid
				else
					currentCamera.CameraSubject = nil
				end
			else
				currentCamera.CameraSubject = nil
			end

			unbindSpectateKeybind() -- equivalent call inferred; original call site unknown
			SpectateService.SpectateCancelled:Fire()
		else
			beginSpectate() -- equivalent call inferred; original call site unknown

			if v4 == nil then
				return
			else
				return true
			end
		end
	end
end

local function onPlayerDataUpdated()
	-- equivalent call inferred; original call site unknown
	if playerIsAlive(localPlayer) then
		cancelSpectate() -- equivalent call inferred; original call site unknown
	end

	v3 = {}

	for _, v6 in game.Players:GetPlayers() do
		local v7

		if v6 == nil or v6.Parent == nil or not (v6.Character and v6.Character:FindFirstChildOfClass("Humanoid")) then
			v7 = false
		else
			local v8 = playerIsAlive(v6) -- equivalent call inferred; original call site unknown
			v7 = v8 and true or false
		end

		if v7 then
			table.insert(v3, v6)
		end
	end

	if v4 ~= nil and not table.find(v3, v4) then
		if #v3 > 0 then
			v4 = v3[math.random(1, #v3)]
		else
			v4 = nil
		end
	end

	updateCameraFocus()
end

for _, v5 in game.Players:GetPlayers() do
	local v6

	if v5 == nil or v5.Parent == nil or not (v5.Character and v5.Character:FindFirstChildOfClass("Humanoid")) then
		v6 = false
	else
		local v7 = playerIsAlive(v5) -- equivalent call inferred; original call site unknown
		v6 = v7 and true or false
	end

	if v6 then
		table.insert(v3, v5)
	end
end

CurrentRoundClient.PlayerDataChanged.Event:Connect(onPlayerDataUpdated)
return SpectateService