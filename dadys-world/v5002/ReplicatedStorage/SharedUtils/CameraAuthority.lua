local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local Players = game:GetService("Players")
local CameraAuthorityCore = require(script.Parent.CameraAuthorityCore)
local CameraAuthority = {}
local v = CameraAuthorityCore.new()
local owner = "none"
local now = 0
local v2 = false
local flag = false
local flag2 = false

local function debugEnabled()
	local localPlayer = Players.LocalPlayer
	return localPlayer ~= nil and localPlayer:GetAttribute("CameraAuthorityDebug") == true
end

local function log(formatString, ...)
	local localPlayer = Players.LocalPlayer
	local v3

	if localPlayer == nil then
		v3 = false
	else
		v3 = localPlayer:GetAttribute("CameraAuthorityDebug") == true
	end

	if v3 then
		print("[CameraAuthority] " .. string.format(formatString, ...) .. " | " .. CameraAuthorityCore.dump(v))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCamera()
	return workspace.CurrentCamera
end

local v3 = nil
local v4 = false

local function getCameraInput()
	if v3 then
		return v3
	end

	local success, result = pcall(function()
		local localPlayer = Players.LocalPlayer
		local playerScripts = localPlayer and localPlayer:FindFirstChild("PlayerScripts")
		local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
		local cameraModule = playerModule and playerModule:FindFirstChild("CameraModule")
		local cameraInput = cameraModule and cameraModule:FindFirstChild("CameraInput")
		return cameraInput and require(cameraInput) or nil
	end)

	if success and type(result) == "table" and type(result.setInputEnabled) == "function" then
		v3 = result
	elseif not v4 then
		v4 = true
		warn("[CameraAuthority] CameraInput not reachable yet; rotation gates are inert until it is")
	end

	return v3
end

local function applyRotationGate()
	local rotationEnabled = CameraAuthorityCore.rotationEnabled(v)

	if rotationEnabled and not v2 then
		return
	end

	local cameraInput = getCameraInput()

	if not cameraInput then
		return
	end

	if rotationEnabled then
		local camera = getCamera() -- equivalent call inferred; original call site unknown

		if camera and camera.CameraType ~= Enum.CameraType.Custom then
			v2 = false
			return
		end
	end

	pcall(cameraInput.setInputEnabled, rotationEnabled)
	v2 = not rotationEnabled
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reseatSubject(camera)
	local cameraSubject = camera.CameraSubject

	if cameraSubject and cameraSubject.Parent and cameraSubject:IsDescendantOf(game) then
		return
	end

	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		camera.CameraSubject = humanoid
	end
end

local function apply()
	local camera = getCamera() -- equivalent call inferred; original call site unknown

	if not camera then
		return
	end

	local scriptable = CameraAuthorityCore.desiredType(v) == "Scriptable" and Enum.CameraType.Scriptable or Enum.CameraType.Custom

	if camera.CameraType ~= scriptable then
		camera.CameraType = scriptable

		if scriptable == Enum.CameraType.Custom then
			reseatSubject(camera) -- equivalent call inferred; original call site unknown
		end
	end

	applyRotationGate()

	if not CameraAuthorityCore.rotationEnabled(v) then
		task.defer(applyRotationGate)
	end
end

local class = {}
class.__index = class

function class.isActive(p)
	return CameraAuthorityCore.isActive(v, p.id)
end

function class.release(p)
	if CameraAuthorityCore.release(v, p.id) then
		owner = p.owner
		now = os.clock()
		log("release %s#%d", p.owner, p.id)
		apply()
	end
end

function CameraAuthority.claim(owner2, p)
	local v5

	if type(owner2) == "string" then
		v5 = owner2 ~= ""
	else
		v5 = false
	end

	assert(v5, "CameraAuthority.claim needs an owner name")
	local priority = p and tonumber(p.priority) or nil
	local claim = CameraAuthorityCore.claim(v, owner2, priority)
	log("claim %s#%d", owner2, claim)
	apply()
	return (setmetatable({
		id = claim,
		owner = owner2
	}, class))
end

function CameraAuthority.releaseOwner(p)
	local v5 = CameraAuthorityCore.releaseOwner(v, p)

	if v5 > 0 then
		owner = p
		now = os.clock()
		log("releaseOwner %s (%d)", p, v5)
		apply()
	end

	return v5
end

function CameraAuthority.reassert()
	apply()
end

function CameraAuthority.resetAll(p)
	local v5 = CameraAuthorityCore.dump(v)
	local v6 = CameraAuthorityCore.clearAll(v)
	owner = "resetAll:" .. tostring(p)
	now = os.clock()
	print(string.format("[CameraAuthority] resetAll (%s): dropped %d claim(s); was %s", tostring(p), v6, v5))
	local camera = getCamera() -- equivalent call inferred; original call site unknown

	if camera then
		camera.CameraType = Enum.CameraType.Custom
		local localPlayer = Players.LocalPlayer
		local character = localPlayer and localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			camera.CameraSubject = humanoid
		end
	end

	apply()
end

function CameraAuthority.isClaimed()
	return CameraAuthorityCore.desiredType(v) == "Scriptable"
end

function CameraAuthority.activeOwner()
	local active = CameraAuthorityCore.active(v)
	return active and active.owner or nil
end

function CameraAuthority.setRotationEnabled(value, p)
	local v5

	if type(value) == "string" then
		v5 = value ~= ""
	else
		v5 = false
	end

	assert(v5, "CameraAuthority.setRotationEnabled needs an owner name")
	CameraAuthorityCore.gateRotation(v, value, p == true)
	log("rotation %s %s", value, p and "enabled" or "gated")
	applyRotationGate()

	if not CameraAuthorityCore.rotationEnabled(v) then
		task.defer(applyRotationGate)
	end
end

function CameraAuthority.isRotationEnabled()
	return CameraAuthorityCore.rotationEnabled(v)
end

local function describeLastOwner()
	if now == 0 then
		return "no owner has released yet"
	end

	return string.format("last release was %s %.1fs ago", owner, os.clock() - now)
end

local function heal(p)
	local camera = getCamera() -- equivalent call inferred; original call site unknown

	if not (camera and CameraAuthorityCore.reconcile(v, camera.CameraType.Name) == "stuck") then
		return
	end

	warn(string.format(
		"[CameraAuthority] camera was %s with no claim for %.0fs (%s; %s) — restoring Custom. Something wrote CameraType without claiming it; route it through CameraAuthority.",
		camera.CameraType.Name,
		2,
		p,
		describeLastOwner()
	))
	camera.CameraType = Enum.CameraType.Custom
	reseatSubject(camera) -- equivalent call inferred; original call site unknown
	applyRotationGate()
end

local function check(p)
	local camera = getCamera() -- equivalent call inferred; original call site unknown

	if not camera then
		return
	end

	local v5 = CameraAuthorityCore.reconcile(v, camera.CameraType.Name)

	if v5 == "stuck" then
		if flag2 then
			return
		end

		flag2 = true
		task.delay(2, function()
			flag2 = false
			heal(p)
		end)
	elseif v5 == "overridden" then
		warn(string.format(
			"[CameraAuthority] CameraType is %s while %s holds the camera (%s). Something wrote CameraType directly; re-asserting the owner's Scriptable.",
			camera.CameraType.Name,
			tostring(CameraAuthority.activeOwner()),
			p
		))
		apply()
	end
end

function CameraAuthority.startWatchdog()
	if flag then
		return
	end

	flag = true
	local cameraTypeChangedConnection = nil

	local function hookCamera()
		if cameraTypeChangedConnection then
			cameraTypeChangedConnection:Disconnect()
			cameraTypeChangedConnection = nil
		end

		local camera = getCamera() -- equivalent call inferred; original call site unknown

		if not camera then
			return
		end

		cameraTypeChangedConnection = camera:GetPropertyChangedSignal("CameraType"):Connect(function()
			task.defer(check, "CameraType changed")
		end)
	end

	hookCamera()
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		hookCamera()
		task.defer(check, "CurrentCamera replaced")
	end)
	local localPlayer = Players.LocalPlayer

	if localPlayer then
		localPlayer.CharacterAdded:Connect(function()
			task.defer(check, "CharacterAdded")
		end)
	end

	task.defer(check, "watchdog armed")
	log("watchdog armed")
end

function CameraAuthority.dump()
	return CameraAuthorityCore.dump(v)
end

return CameraAuthority