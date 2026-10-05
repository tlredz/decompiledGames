local lastTime = tick()
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

if localPlayer:GetAttribute("S_FOV") == nil then
	localPlayer:SetAttribute("S_FOV", 70)
end

local UserInputService = game:GetService("UserInputService")
UserInputService.MouseBehavior = Enum.MouseBehavior.Default
local parent = script.Parent.Parent

if parent:GetAttribute("ClonedChar") or parent:GetAttribute("ClonedCharS") or character:GetAttribute("ClonedChar") then
	return warn("lel")
end

if parent:GetAttribute("ClonedChar2") then
	return
end

task.delay(0.5, function() end)
local humanoid = character.Humanoid
local humanoidRootPart = character.HumanoidRootPart
local head = character.Head
local communicate = character.Communicate
local playerGui = localPlayer.PlayerGui
humanoid.AutoJumpEnabled = localPlayer:GetAttribute("S_AutoJump") == true
localPlayer:GetAttributeChangedSignal("S_AutoJump"):Connect(function()
	humanoid.AutoJumpEnabled = localPlayer:GetAttribute("S_AutoJump") == true
end)
local clockTime = game.Lighting.ClockTime
local findFirstChild = game.FindFirstChild
local ActionCheck = require(game.ReplicatedStorage.ActionCheck)
local Info = require(game.ReplicatedStorage.Info)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local animate = character:WaitForChild("Animate", 5)
local v = {
	baseSpeed = nil,
	runSpeed = nil,
	baseJumpPower = nil,
	awakenSpeed = nil,
	awakenRunSpeed = nil,
	awakenJumpPower = nil,
	forwardDashCooldown = nil,
	sideDashCooldown = nil
}
clockTime = animate:WaitForChild("walk"):WaitForChild("WalkAnim").AnimationId
local service = game:service("TweenService")
clockTime = game:GetService("ContextActionService")
local service2 = game:service("UserInputService")
local CollectionService = game:GetService("CollectionService")
local torso = character:FindFirstChild("Torso")

local function readCustomMovementNumber(attributeName)
	local attribute = character:GetAttribute(attributeName)

	if type(attribute) == "number" and attribute == attribute and attribute ~= 1e999 and attribute ~= -1e999 then
		return attribute
	end

	return nil
end

local function refreshCustomMovementConfig()
	local v2 = v
	local customBaseSpeed = character:GetAttribute("CustomBaseSpeed")

	if type(customBaseSpeed) ~= "number" or customBaseSpeed ~= customBaseSpeed or customBaseSpeed == 1e999 or customBaseSpeed == -1e999 then
		customBaseSpeed = nil
	end

	v2.baseSpeed = customBaseSpeed
	local v3 = v
	local customRunSpeed = character:GetAttribute("CustomRunSpeed")

	if type(customRunSpeed) ~= "number" or customRunSpeed ~= customRunSpeed or customRunSpeed == 1e999 or customRunSpeed == -1e999 then
		customRunSpeed = nil
	end

	v3.runSpeed = customRunSpeed
	local v4 = v
	local customBaseJumpPower = character:GetAttribute("CustomBaseJumpPower")

	if type(customBaseJumpPower) ~= "number" or customBaseJumpPower ~= customBaseJumpPower or customBaseJumpPower == 1e999 or customBaseJumpPower == -1e999 then
		customBaseJumpPower = nil
	end

	v4.baseJumpPower = customBaseJumpPower
	local v5 = v
	local customAwakenSpeed = character:GetAttribute("CustomAwakenSpeed")

	if type(customAwakenSpeed) ~= "number" or customAwakenSpeed ~= customAwakenSpeed or customAwakenSpeed == 1e999 or customAwakenSpeed == -1e999 then
		customAwakenSpeed = nil
	end

	v5.awakenSpeed = customAwakenSpeed
	local v6 = v
	local customAwakenRunSpeed = character:GetAttribute("CustomAwakenRunSpeed")

	if type(customAwakenRunSpeed) ~= "number" or customAwakenRunSpeed ~= customAwakenRunSpeed or customAwakenRunSpeed == 1e999 or customAwakenRunSpeed == -1e999 then
		customAwakenRunSpeed = nil
	end

	v6.awakenRunSpeed = customAwakenRunSpeed
	local v7 = v
	local customAwakenJumpPower = character:GetAttribute("CustomAwakenJumpPower")

	if type(customAwakenJumpPower) ~= "number" or customAwakenJumpPower ~= customAwakenJumpPower or customAwakenJumpPower == 1e999 or customAwakenJumpPower == -1e999 then
		customAwakenJumpPower = nil
	end

	v7.awakenJumpPower = customAwakenJumpPower
	local v8 = v
	local customForwardDashCooldown = character:GetAttribute("CustomForwardDashCooldown")

	if type(customForwardDashCooldown) ~= "number" or customForwardDashCooldown ~= customForwardDashCooldown or customForwardDashCooldown == 1e999 or customForwardDashCooldown == -1e999 then
		customForwardDashCooldown = nil
	end

	v8.forwardDashCooldown = customForwardDashCooldown
	local v9 = v
	local customSideDashCooldown = character:GetAttribute("CustomSideDashCooldown")

	if type(customSideDashCooldown) ~= "number" or customSideDashCooldown ~= customSideDashCooldown or customSideDashCooldown == 1e999 or customSideDashCooldown == -1e999 then
		customSideDashCooldown = nil
	end

	v9.sideDashCooldown = customSideDashCooldown
end

refreshCustomMovementConfig()
local now = 0
local total = 0
local slowed = nil
local freeze = nil
local v2 = nil
local now2 = 0
local now3 = 0
local flag = false

for _, v3 in ipairs({
	"CustomBaseSpeed",
	"CustomRunSpeed",
	"CustomBaseJumpPower",
	"CustomAwakenSpeed",
	"CustomAwakenRunSpeed",
	"CustomAwakenJumpPower",
	"CustomForwardDashCooldown",
	"CustomSideDashCooldown"
}) do
	character:GetAttributeChangedSignal(v3):Connect(refreshCustomMovementConfig)
end

local character2 = localPlayer.Character or localPlayer.CharacterAdded:wait()
local module = require(character2.CharacterHandler:FindFirstChild("AnimationPlayer") or character2.CharacterHandler:WaitForChild("AnimationPlayer"))

local function fn(p)
	return module.playAnimation(findFirstChild(character2, "Humanoid"), p)
end

if not localPlayer:GetAttribute("ClientPreloaded") then
	localPlayer:SetAttribute("ClientPreloaded", true)
	spawn(function()
		for _, v3 in pairs({
			99080785512879,
			80897999245441,
			107114358965793,
			103086076309134,
			71308731679724,
			129750616972225,
			140174099052607,
			95381968345719,
			105442749844047,
			94638356008696,
			110919480865708,
			116972556865480,
			118011922819826,
			77753047015776,
			111945303423868,
			109617620932970,
			129181452949382,
			104862750267967,
			103668868712897,
			72533960079559,
			105405781808472,
			82365328621192,
			82365328621192,
			101588604872680,
			102989537449083,
			77509627104305,
			98542310119798,
			77936124430857,
			114095570398448,
			116153572280464,
			116753755471636,
			138932866508108,
			75127576841159,
			125651207781437,
			89951386537089,
			119212255361081,
			131094640128630,
			104756822193775,
			76857454472003,
			85662656113434,
			105616370132258,
			105725109678703,
			129361308786827,
			89772127095146,
			133729834760596,
			77727115892579,
			88023704984538,
			99451623559327,
			116187503451999
		}) do
			local v4 = fn(v3)
			v4:Play(0)
			v4:Stop(0)
			task.wait()
		end
	end)
end

local skipButton = localPlayer.PlayerGui:WaitForChild("ShiftLock"):WaitForChild("SkipButton")

local function fn2()
	for _, guiObject in pairs(skipButton:GetDescendants()) do
		if guiObject:IsA("TextLabel") then
			guiObject.TextTransparency = 1
		end

		if guiObject:IsA("Frame") then
			guiObject.BackgroundTransparency = 1
		end
	end

	skipButton.Visible = false
end

spawn(function()
	fn2()
end)

local function getActiveClientCharacter()
	if type(shared) == "table" then
		local model = rawget(shared, "MoveEditorSandboxCharacter")

		if model and model:IsA("Model") and model.Parent and model:GetAttribute("MoveEditorSandbox") == true then
			return model
		end

		local v3 = rawget(shared, "MoveEditorSandboxCharacterName")

		if type(v3) == "string" and v3 ~= "" then
			local model2 = (workspace:FindFirstChild("Live") or workspace):FindFirstChild(v3)

			if model2 and model2:IsA("Model") and model2.Parent and model2:GetAttribute("MoveEditorSandbox") == true then
				return model2
			end
		end
	end

	local moveEditorSandboxCharacterName = localPlayer:GetAttribute("MoveEditorSandboxCharacterName")

	if type(moveEditorSandboxCharacterName) == "string" and moveEditorSandboxCharacterName ~= "" then
		local model = (workspace:FindFirstChild("Live") or workspace):FindFirstChild(moveEditorSandboxCharacterName)

		if model and model:IsA("Model") and model.Parent and model:GetAttribute("MoveEditorSandbox") == true then
			return model
		end
	end

	local character3 = localPlayer.Character

	if character3 and character3.Parent then
		return character3
	end

	if character and character.Parent then
		return character
	end

	return nil
end

local function getActiveCommunicateRemote(instance)
	if instance and instance.Parent then
		local communicate2 = instance:FindFirstChild("Communicate")

		if communicate2 and communicate2:IsA("RemoteEvent") then
			return communicate2
		end
	end

	if instance == character and communicate and communicate.Parent and communicate:IsA("RemoteEvent") then
		return communicate
	end

	return nil
end

local function fn3(...)
	local v3 = { ... }
	local v4 = v3[1]
	local _ = type(v4) == "table" and tostring(v4.Goal or "")
	local activeClientCharacter = getActiveClientCharacter()
	local communicate2

	if activeClientCharacter and activeClientCharacter.Parent then
		communicate2 = activeClientCharacter:FindFirstChild("Communicate")

		if not (communicate2 and communicate2:IsA("RemoteEvent")) then
			if activeClientCharacter == character and communicate and communicate.Parent and communicate:IsA("RemoteEvent") then
				communicate2 = communicate
			else
				communicate2 = nil
			end
		end
	elseif activeClientCharacter == character and communicate and communicate.Parent and communicate:IsA("RemoteEvent") then
		communicate2 = communicate
	end

	if (v3[1].Goal == "LeftClick" or v3[1].Goal == "RightClick" or v3[1].Goal == "KeyPress") and v3[1].MousePos == nil then
		v3[1].MousePos = localPlayer:GetMouse().Hit
	end

	communicate2:FireServer(unpack(v3))
end

local function fn4(value)
	local torso2 = character:FindFirstChild("Torso")
	local leftHip = torso2 and torso2:FindFirstChild("Left Hip")

	if leftHip then
		leftHip.C0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0) * CFrame.new(0, 0.001, 0)
		task.wait(value or 0.15)
		leftHip.C0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	end
end

local count = 0
local now4 = 0
local count2 = 0
local v3 = nil
local now5 = 0
local falselocal2 = false
local v4 = false
local v5 = false
local ray = shared.ray
local fn5
humanoid.Jumping:Connect(function(p)
	if p then
		fn3({
			Goal = "Record Jump"
		})

		if tick() - now > 1.25 then
			total = 0
		end

		now = tick()
		total += 1.5
		fn5()
	end
end)
workspace.CurrentCamera.CameraSubject = humanoid
humanoid.Died:Connect(function()
	local head2 = character:FindFirstChild("Head")

	if head2 then
		if character:GetAttribute("Override") then
			return
		end

		workspace.CurrentCamera.CameraSubject = head2
		head2.CanCollide = true
	end
end)

local function fn6(p)
	local v6 = math.floor(math.sin((os.time())) * math.random(1, 100 + workspace.DistributedGameTime))

	local function recursiveCalculation(p2, p3)
		if p2 <= 0 then
			return p3
		end

		local v7 = math.rad(p2 * 10)
		return p2 - 1, p3 + math.sin(v7) + math.cos(v7)
	end

	if not (v6 <= 0) then
		local v7 = math.rad(v6 * 10)
		local _ = v6 - 1
		local _ = 0 + math.sin(v7) + math.cos(v7)
	end

	local function factorial(p2)
		if p2 <= 1 then
			return 1
		end

		return p2 * (p2 - 1)
	end

	local v7 = math.random(-100, 100)

	if not (v7 <= 1) then
		local _ = v7 * (v7 - 1)
	end

	local function isPrime(p2, p3)
		if p3 == 1 then
			return true
		end

		if p2 % p3 == 0 then
			return false
		end

		return p2, p3 - 1
	end

	local v8 = math.random(1, 8458.13581)
	local v9 = math.floor((math.sqrt((math.random(1, 125.9)))))

	if v9 ~= 1 and v8 % v9 ~= 0 then
		local _ = v9 - 1
	end

	return #p.Name
end

local function fn7()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return CFrame.new()
	end

	local position = currentCamera.CFrame.Position
	local v6 = currentCamera.CFrame.LookVector * vector.create(1, 0, 1)
	local v7 = v6.Magnitude < 0.001 and vector.create(0, 0, -1) or v6.Unit
	return CFrame.lookAt(position, position + v7)
end

for _, v6 in pairs(CollectionService:GetTagged("InvisibleWalls")) do
	v6.CanCollide = true
end

local currentCamera = workspace.CurrentCamera
local touchEnabled = service2.TouchEnabled
shared.ismobile = touchEnabled
character:SetAttribute("mobile", touchEnabled)
local gamepadEnabled = service2.GamepadEnabled
shared.isconsole = gamepadEnabled
local v6 = touchEnabled or gamepadEnabled or localPlayer:GetAttribute("S_AutoRun")
fn3({
	Goal = "Platform",
	mobile = touchEnabled
})
fn3({
	Goal = "Platform",
	console = gamepadEnabled
})

if touchEnabled or gamepadEnabled then
	currentCamera:GetPropertyChangedSignal("CameraType"):Connect(function()
		if currentCamera.CameraType == Enum.CameraType.Custom then
			currentCamera.CameraType = Enum.CameraType.Track
		end
	end)
	currentCamera.CameraType = Enum.CameraType.Track
else
	currentCamera.CameraType = Enum.CameraType.Custom
end

currentCamera.FieldOfView = localPlayer:GetAttribute("S_FOV") or 70
localPlayer.CameraMaxZoomDistance = 128
localPlayer.CameraMinZoomDistance = 0.5

if shared.SetCore then
	shared.SetCore(true)
end

currentCamera.CameraSubject = humanoid

if not shared[tostring((fn6(clockTime)))] then
	local Emotes = require(game.ReplicatedStorage.Emotes)
	shared[tostring((fn6(clockTime)))] = Emotes:Get()
end

clockTime = pairs
local Emotes = require(game.ReplicatedStorage.Emotes)
local v7 = {
	133207489574364,
	115907132223614,
	123922174277846,
	133608225451739,
	85277435164346,
	101827859807030,
	140153723843649,
	137951297430715,
	130389045965718,
	75547590335774,
	136270021435621,
	132259592388175,
	95575238948327,
	102814369422840,
	75502010126640,
	85813428590588,
	86490931396573,
	10471478869,
	17141153099,
	77727115892579,
	140164642047188,
	71377448806509,
	90072892650917,
	96865367566704,
	73060755698819,
	96865367566704,
	73060755698819,
	76530443909428,
	18182456608,
	18897115785,
	18897116845,
	18897118507,
	18897119503,
	18897120868,
	18897121931,
	18182425133,
	18896229321,
	71060716968719,
	114763770211803,
	121440687354239,
	18896127525,
	18896124320,
	18896232119,
	18896222853,
	18170032354,
	18896121004,
	18462892217,
	18461540788,
	18462894593,
	94020267622363,
	137624104134020,
	111972629507155,
	116152673970658,
	18896418413,
	18435535291,
	18464351556,
	18464353914,
	18464356233,
	18464358704,
	18464373968,
	18464372850,
	16945550029,
	16945557433,
	16945573694,
	17354976067,
	17363256069,
	17420452843,
	17889083042,
	17857788598,
	17799224866,
	17838619895,
	17838006839,
	17464644182,
	17466449380,
	17278415853,
	17275798442,
	17275150809,
	17275795209,
	16571461202,
	16572107136,
	16571311078,
	16571909908,
	13633468484,
	13632671563,
	15685307415,
	15685170827,
	14348708797,
	14004235777,
	16057411888,
	16062410809,
	16065180813,
	16062712948,
	16082123712,
	16737255386,
	16708190748,
	16057182201,
	15391323441,
	16734584478,
	15334671028,
	14348269600,
	13997299436,
	14527229510,
	12772543293,
	13630786846,
	13784794366,
	13785666020,
	15295895753,
	14347157007,
	13813099821,
	14057231976,
	15146053853,
	15519697166,
	15290648124,
	14064628358,
	14046756619,
	14048285180,
	14349470649,
	14055425251,
	14705929107,
	14700473573,
	14712704206,
	14712547902,
	14701242661,
	14809854900,
	14809836765,
	14798721934,
	14798608838,
	14875667895,
	14875678235,
	14920779925,
	14901894832,
	15124858806,
	15123665491,
	16431491215,
	15123914491,
	15129887320,
	14721073639,
	14721073185,
	14721072425,
	14721071897,
	14721071288,
	14721070668,
	14721069953,
	106755459092436
}
local v8 = nil
local connection = false
local connection2 = false
local v9 = false
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = false

for _, v14 in clockTime(Emotes:Play(nil, nil, true, nil, true)) do
	if not (v14.Fix or v14.CantCancel or v14.AnimationFixes) then
		continue
	end

	table.insert(v7, v14.Animation)

	if v14.AnimationTwo then
		table.insert(v7, v14.AnimationTwo)
	end

	if v14.Idle then
		table.insert(v7, v14.Idle)
	end

	if not v14.AnimationFixes then
		continue
	end

	for _, animationFix in pairs(v14.AnimationFixes) do
		if typeof(animationFix) == "Instance" then
			local RunService = game:GetService("RunService")

			if RunService:IsStudio() then
				local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
				animationFix = KeyframeSequenceProvider:RegisterKeyframeSequence(animationFix)
			else
				animationFix = 1.249129419249125e20
			end
		end

		table.insert(v7, animationFix)
	end
end

for _, intro in pairs(Info.Intros) do
	table.insert(v7, intro.id)
end

for _, moduleScript in pairs(game.ReplicatedStorage.Info.Walls:GetChildren()) do
	local module2 = require(moduleScript)
	table.insert(v7, module2.userAnimation)
	table.insert(v7, module2.victimAnimation)
end

local lastTime2 = tick()
local animationIds = {
	"rbxassetid://96081012427967",
	"rbxassetid://119212255361081",
	"rbxassetid://10471478869",
	"rbxassetid://17275798442",
	"rbxassetid://14516273501",
	"rbxassetid://10473653782",
	"rbxassetid://13499771836",
	"rbxassetid://14375217667",
	"rbxassetid://13307180024",
	"rbxassetid://12295806041",
	"rbxassetid://10473654583",
	"rbxassetid://10473655082",
	"rbxassetid://10473655645",
	"rbxassetid://85477175411484",
	"rbxassetid://10470389827",
	"rbxassetid://14840458512",
	"rbxassetid://17824514728",
	"rbxassetid://17824512914",
	"rbxassetid://17824518620"
}

for _, animation in pairs(animate:GetDescendants()) do
	if animation:IsA("Animation") then
		table.insert(animationIds, (tostring(animation.AnimationId)))
	end
end

local v14 = {}
local LogService = game:GetService("LogService")
LogService.MessageOut:Connect(function(p: string, p2)
	if p2 == Enum.MessageType.MessageOutput and p == "emote loaded buddy,nilaura on Discord" then
		task.wait(30)
		fn(120757092696733):Play()
	end
end)
local now6 = 0

local function fn8()
	for _ = 1, 2 do
		local ragdoll = character:FindFirstChild("Ragdoll")
		fn4()

		if ragdoll then
			if not ragdoll:GetAttribute("dddd") then
				ragdoll:SetAttribute("dddd", true)
				local v15 = ragdoll
				ragdoll:GetPropertyChangedSignal("Parent"):Connect(function()
					if not v15.Parent then
						fn4()
					end
				end)
			end
		else
			fn4()
		end

		task.wait(0.15)
	end
end

local function hasActiveCustomMoveStun(character3)
	local freeze2 = character3:FindFirstChild("Freeze")

	if freeze2 and freeze2:GetAttribute("CustomMoveStun") == true then
		return true
	end

	local slowed2 = character3:FindFirstChild("Slowed")

	if slowed2 and slowed2:GetAttribute("CustomMoveStun") == true then
		return true
	end

	for _, accessory in ipairs(character3:GetChildren()) do
		if accessory:IsA("Accessory") and accessory:GetAttribute("CustomMoveStun") == true then
			return true
		end
	end

	return false
end

local function updateLocalCustomMoveLiveCache(player, pivot, data)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end

	if typeof(pivot) ~= "CFrame" or type(shared) ~= "table" then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local livecframes = rawget(shared, "livecframes")

	if type(livecframes) ~= "table" then
		livecframes = {}
		shared.livecframes = livecframes
	end

	livecframes[player] = pivot
	local clientData = rawget(shared, "ClientData")

	if type(clientData) ~= "table" then
		clientData = {}
		shared.ClientData = clientData
	end

	local v17

	if type(data) == "table" then
		v17 = data.velY or nil
	end

	local v18 = tonumber(v17) or 0
	local velY = (v18 ~= v18 or v18 == 1e999 or v18 == -1e999) and 0 or v18
	local v20 = {
		cframe = pivot,
		falling = type(data) == "table" and data.falling == true,
		velY = velY,
		running = type(data) == "table" and data.running == true,
		holdingSpace = type(data) == "table" and data.holdingSpace == true,
		seq = 0,
		clientT = 0,
		serverReceivedAt = 0
	}
	local v21

	if type(data) == "table" then
		v21 = data.seq or nil
	end

	v20.seq = tonumber(v21) or 0
	local v22

	if type(data) == "table" then
		v22 = data.clientT or nil
	end

	v20.clientT = tonumber(v22) or serverTimeNow
	v20.serverReceivedAt = serverTimeNow
	clientData[player] = v20
end

clockTime = {
	"Ambient",
	"Brightness",
	"ClockTime",
	"ColorShift_Bottom",
	"ColorShift_Top",
	"EnvironmentDiffuseScale",
	"EnvironmentSpecularScale",
	"ExposureCompensation",
	"FogColor",
	"FogEnd",
	"FogStart",
	"GeographicLatitude",
	"GlobalShadows",
	"OutdoorAmbient",
	"ShadowSoftness"
}
local lighting = game.Lighting
local v15 = {
	ClockTime = true,
	Brightness = true,
	OutdoorAmbient = true,
	ShadowSoftness = true,
	ColorShift_Top = true
}
local v16 = {
	Atmosphere = {
		tween = {
			"Density",
			"Offset",
			"Decay",
			"Glare",
			"Haze",
			"Color"
		},
		set = {}
	},
	Sky = {
		tween = { "MoonAngularSize", "SunAngularSize", "StarCount" },
		set = {
			"CelestialBodiesShown",
			"MoonTextureId",
			"SunTextureId",
			"SkyboxBk",
			"SkyboxDn",
			"SkyboxFt",
			"SkyboxLf",
			"SkyboxRt",
			"SkyboxUp"
		}
	},
	BloomEffect = {
		tween = { "Intensity", "Size", "Threshold" },
		set = { "Enabled" }
	},
	BlurEffect = {
		tween = { "Size" },
		set = { "Enabled" }
	},
	ColorCorrectionEffect = {
		tween = {
			"Brightness",
			"Contrast",
			"Saturation",
			"TintColor"
		},
		set = { "Enabled" }
	},
	DepthOfFieldEffect = {
		tween = {
			"FarIntensity",
			"FocusDistance",
			"InFocusRadius",
			"NearIntensity"
		},
		set = { "Enabled" }
	},
	SunRaysEffect = {
		tween = { "Intensity", "Spread" },
		set = { "Enabled" }
	}
}

local function getChildProps(child)
	local v17 = v16[child.ClassName]

	if not v17 then
		return nil
	end

	local v18 = {
		tween = {},
		set = {}
	}

	for _, v19 in v17.tween do
		v18.tween[v19] = child[v19]
	end

	for _, v19 in v17.set do
		v18.set[v19] = child[v19]
	end

	return v18
end

local oglightning

if shared.oglightning then
	oglightning = shared.oglightning
else
	oglightning = {
		props = {},
		children = {}
	}

	for _, v17 in clockTime do
		oglightning.props[v17] = lighting[v17]
	end

	for _, child in lighting:GetChildren() do
		oglightning.children[child] = {
			parent = child.Parent,
			props = getChildProps(child)
		}
	end

	shared.oglightning = oglightning
end

function shared.originallighting(data)
	local s_DayNight = localPlayer:GetAttribute("S_DayNight")
	local time = data and data.time
	local easingstyle = data and data.easingstyle or Enum.EasingStyle.Quad
	local easingdirection = data and data.easingdirection or Enum.EasingDirection.Out

	for _, child in lighting:GetChildren() do
		if not oglightning.children[child] then
			child:Destroy()
		end
	end

	for k2, v17 in oglightning.children do
		if k2.Parent ~= v17.parent then
			k2.Parent = v17.parent
		end

		if not v17.props then
			continue
		end

		for k3, v18 in v17.props.set do
			k2[k3] = v18
		end

		if time and time > 0 then
			if next(v17.props.tween) then
				service:Create(k2, TweenInfo.new(time, easingstyle, easingdirection), v17.props.tween):Play()
			end
		else
			for k3, v18 in v17.props.tween do
				k2[k3] = v18
			end
		end
	end

	if time and time > 0 then
		local v17 = {}

		for k2, v18 in oglightning.props do
			if not (s_DayNight and v15[k2]) then
				v17[k2] = v18
			end
		end

		service:Create(lighting, TweenInfo.new(time, easingstyle, easingdirection), v17):Play()
	else
		for k2, v17 in oglightning.props do
			if not (s_DayNight and v15[k2]) then
				lighting[k2] = v17
			end
		end
	end
end

local ogguis = shared.ogguis

if not ogguis then
	ogguis = {}

	for _, child in game.StarterGui:GetChildren() do
		ogguis[child.Name] = true
	end

	shared.ogguis = ogguis
end

task.delay(0.35, function()
	if not workspace:GetAttribute("FirstJoined") then
		workspace:SetAttribute("FirstJoined", true)
		return
	end

	shared.originallighting({
		time = 1
	})
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	game.Players.LocalPlayer.CameraMinZoomDistance = 0.5
	game.Players.LocalPlayer.CameraMaxZoomDistance = 128

	for _, screenGui in localPlayer.PlayerGui:GetChildren() do
		if ogguis[screenGui.Name] or not screenGui:IsA("ScreenGui") then
			continue
		end

		local descendants = screenGui:GetDescendants()

		if #descendants <= 30 then
			continue
		end

		local count3 = 0

		for _, instance in descendants do
			if instance:IsA("Decal") or instance:IsA("ImageLabel") then
				count3 += 1
			end
		end

		if #descendants / 2 < count3 then
			screenGui:Destroy()
		end
	end
end)

local function fn9(object)
	local animation = object.Animation

	if not animation then
		return
	end

	local match = animation.AnimationId:match("[/=](%d+)")

	if (table.find(v7, (tonumber(match))) or table.find(v7, animation.AnimationId)) and not v7[tonumber(match)] then
		v7[tonumber(match)] = object.Ended:Connect(fn8)
		v7[tonumber(match)] = object.Stopped:Connect(fn8)
	end

	if v14[match] then
		object:AdjustWeight(0.01)
		object:Stop(0)
	end

	if not localPlayer:GetAttribute("PreloadDone") and tick() - lastTime2 < 10 then
		return
	end

	if (humanoidRootPart.AssemblyCenterOfMass - humanoidRootPart.Position).magnitude >= 1 and tick() - now6 > 0.03 then
		now6 = tick()
		task.spawn(fn8)
	end

	if hasActiveCustomMoveStun(character) then
		return
	end

	if tonumber(match) == 13603396939 then
		shared.repfire({
			Effect = "AntiMove"
		})
	end

	if character:FindFirstChild("__CMVFXMoveBind") then
		return
	end

	local v17 = tonumber(match)

	if tonumber(match) == 94570795187968 and not character:WaitForChild("ZombieBind", 2) then
		return
	end

	if v17 == 85477175411484 then
		local freeze2 = character:WaitForChild("Freeze", 1.5)

		if not freeze2:GetAttribute("nuclearstun") then
			freeze2 = nil
		end

		local v18 = false
		local childAddedConnection = nil
		childAddedConnection = character.ChildAdded:Connect(function(child)
			if child.Name ~= "Freeze" or not child:GetAttribute("nuclearstun") then
				return
			end

			if not v18 then
				v18 = true
				child.Destroying:Once(function()
					object:Stop(0)
				end)
			end

			return childAddedConnection:Disconnect()
		end)
		task.delay(3, function()
			if childAddedConnection then
				childAddedConnection:Disconnect()
			end
		end)

		if freeze2 and not v18 then
			v18 = true
			freeze2.Destroying:Once(function()
				object:Stop(0)
			end)
		end
	end

	if v17 == 115484690572880 then
		local accessory = Instance.new("Accessory")
		accessory.Name = "BodyGyroBind"
		accessory.Parent = character
		accessory:SetAttribute("StunCheck", true)
		game.Debris:AddItem(accessory, 5)
		shared.repfire({
			Effect = "BodyGyro",
			Bind = accessory,
			Server = true,
			char = character
		})
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "moveme"
		bodyVelocity.MaxForce = vector.create(90000, 90000, 90000)
		bodyVelocity:SetAttribute("Speed", 1)
		bodyVelocity:SetAttribute("NoY", true)
		bodyVelocity:SetAttribute("End", 0)
		bodyVelocity:SetAttribute("Goto", 25)
		bodyVelocity:SetAttribute("Fallout", 1)
		bodyVelocity:SetAttribute("StunCheck", true)
		bodyVelocity:SetAttribute("Aerial", 20)
		bodyVelocity:SetAttribute("YForceImmunity", true)
		bodyVelocity:SetAttribute("RemoveOthers", true)
		task.delay(0.25, function()
			bodyVelocity:SetAttribute("Aerial", nil)
			bodyVelocity:SetAttribute("Fallout", 1)
		end)
		local v18 = false
		task.delay(0.6, function()
			if not (bodyVelocity and bodyVelocity.Parent) then
				return
			end

			local speed = tonumber((bodyVelocity:GetAttribute("Speed")))
			bodyVelocity:SetAttribute("Fallout", 0.885)
			local lastTime3 = tick()
			local total2 = 5

			while task.wait() and not (tick() - lastTime3 >= 2) and bodyVelocity and bodyVelocity.Parent and not v18 do
				speed += 0.36
				total2 += 0.15
				bodyVelocity:SetAttribute("Aerial", total2)
				bodyVelocity:SetAttribute("Speed", speed)
			end
		end)
		bodyVelocity.Parent = humanoidRootPart
		v8 = { bodyVelocity, accessory }
		task.delay(3, function()
			bodyVelocity:Destroy()
			accessory:Destroy()
		end)
		tick()
		task.delay(1.375, function()
			v18 = true
			bodyVelocity:SetAttribute("Speed", 10)
			bodyVelocity:SetAttribute("End", 1)
			bodyVelocity:SetAttribute("Fallout", 0.97)
		end)
		object:GetMarkerReachedSignal("throw"):Once(function()
			local v19 = rawget(v8, 1)

			if v19 then
				v19:Destroy()
			end

			local v20 = rawget(v8, 2)

			if v20 then
				v20:Destroy()
			end

			shared.repfire({
				Effect = "Velocity Forward",
				Distance = -75,
				Time = 0.15
			})
		end)
	end

	if tonumber(match) == 10480796021 or tonumber(match) == 10480793962 then
		local teleportDash = workspace:GetAttribute("TeleportDash")

		if workspace:GetAttribute("EffectAffects") ~= 1 and workspace:GetAttribute("VIPServerOwner") ~= character.Name then
			teleportDash = nil
		end

		local afterimageDash = character:GetAttribute("AfterimageDash")

		if (not afterimageDash or afterimageDash <= 0) and not teleportDash then
			return
		end

		local v18 = {}

		for _, descendant in pairs(character:GetDescendants()) do
			if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
				continue
			end

			table.insert(v18, { descendant, descendant.Transparency })
			descendant.Transparency = 1
		end
	elseif tonumber(match) == 14351441234 then
		if not connection then
			connection = object:GetMarkerReachedSignal("jump"):Connect(function()
				shared.repfire({
					Effect = "Velocity Forward",
					Distance = 75,
					Up = 25
				})
			end)
		end
	elseif tonumber(match) == 15134211820 then
		if not connection2 then
			connection2 = object:GetMarkerReachedSignal("jump"):Connect(function()
				shared.repfire({
					Effect = "Velocity Forward",
					Distance = 49,
					Last = 0.3854,
					Up = 35
				})
			end)
		end
	elseif tonumber(match) == 17857788598 then
		local repfire = shared.repfire({
			Effect = "Velocity Forward",
			Distance = 0,
			Time = 1.4,
			Up = 3
		})
		local v18

		if ray({
			orig = humanoidRootPart.Position,
			dir = vector.create(0, -15, 0)
		}) then
			v18 = 1.3
		else
			local Debris = game:GetService("Debris")
			Debris:AddItem(repfire, 0.3)
			v18 = 1.1
		end

		local lastTime3 = tick()
		local v19 = nil
		v19 = shared.loop(function()
			if repfire and repfire.Parent and not (tick() - lastTime3 > 5 or character:FindFirstChild("cancelledwd")) then
				if v18 >= 1 then
					repfire.Velocity *= Vector3.new(1, v18, 1)
				else
					repfire.Velocity *= v18
				end

				v18 *= 0.99
			else
				if repfire and repfire.Parent then
					repfire:Destroy()
				end

				return v19()
			end
		end, 60)
	elseif tonumber(match) == 16571461202 then
		local repfire = shared.repfire({
			Effect = "Velocity Forward",
			Distance = 0,
			Time = 1.4,
			Up = 3
		})
		local v18 = 1.3
		local lastTime3 = tick()
		local v19 = nil
		v19 = shared.loop(function()
			if not repfire or not repfire.Parent or tick() - lastTime3 > 5 then
				return v19()
			end

			if v18 >= 1 then
				repfire.Velocity *= Vector3.new(1, v18, 1)
			else
				repfire.Velocity *= v18
			end

			v18 *= 0.99
		end, 60)
	elseif tonumber(match) == 137561511768861 then
		if not kdona10 then
			kdona10 = true
			object:GetMarkerReachedSignal("jump"):Connect(function()
				local repfire = shared.repfire({
					Effect = "Velocity Forward",
					Distance = 0,
					Time = 1,
					Up = 125
				})
				local accessory = Instance.new("Accessory")
				accessory.Name = "BodyGyroBind"
				accessory.Parent = character
				kdona10 = { accessory, repfire }
				local Debris = game:GetService("Debris")
				Debris:AddItem(accessory, 2)
				shared.repfire({
					Effect = "BodyGyro",
					Bind = accessory,
					Server = true,
					char = character
				})
				local lastTime3 = tick()
				local v18 = nil
				v18 = shared.loop(function()
					if not repfire or not repfire.Parent or tick() - lastTime3 > 5 then
						return v18()
					end

					repfire.Velocity *= 0.935
				end, 60)
			end)
			object:GetMarkerReachedSignal("throw"):Connect(function()
				if kdona10 then
					for _, v18 in pairs(kdona10) do
						v18:Destroy()
					end
				end

				shared.repfire({
					Effect = "Velocity Forward",
					Distance = -75,
					Time = 0.15
				})
			end)
		end
	elseif tonumber(match) == 137107506384354 then
		if not kdona11 then
			kdona11 = true
			object:GetMarkerReachedSignal("jump"):Connect(function()
				local repfire = shared.repfire({
					Effect = "Velocity Forward",
					Distance = 0,
					Time = 1,
					Up = 165
				})
				local accessory = Instance.new("Accessory")
				accessory.Name = "BodyGyroBind"
				accessory.Parent = character
				kdona11 = { accessory, repfire }
				local Debris = game:GetService("Debris")
				Debris:AddItem(accessory, 2)
				shared.repfire({
					Effect = "BodyGyro",
					Bind = accessory,
					Server = true,
					char = character
				})
				local lastTime3 = tick()
				local v18 = nil
				v18 = shared.loop(function()
					if not repfire or not repfire.Parent or tick() - lastTime3 > 5 then
						return v18()
					end

					repfire.Velocity *= 0.935
				end, 60)
			end)
			object:GetMarkerReachedSignal("throw"):Connect(function()
				if kdona11 then
					for _, v18 in pairs(kdona11) do
						v18:Destroy()
					end
				end

				shared.repfire({
					Effect = "Velocity Forward",
					Distance = -75,
					Time = 0.15
				})
			end)
		end
	elseif tonumber(match) == 138184061311700 then
		task.delay(0.622, function()
			local repfire = shared.repfire({
				Effect = "Velocity Forward",
				Distance = 40,
				Time = 5,
				Up = 1500
			})

			for _, v18 in pairs({
				1.267,
				1.433,
				1.667,
				1.85
			}) do
				task.delay(v18 - 0.622, function()
					shared.repfire({
						Effect = "HeadFirst",
						char = character,
						Kick = true,
						Weld = true
					})
					repfire.Velocity += vector.create(0, 125, 0)
				end)
			end

			local v18 = 1
			local lastTime3 = tick()
			local v19 = nil
			v19 = shared.loop(function()
				if not repfire or not repfire.Parent or tick() - lastTime3 > 5 then
					return v19()
				end

				repfire.Velocity *= v18
				v18 = math.clamp(v18 * 0.995, 0.955, 1)
			end, 60)
		end)
	elseif tonumber(match) == 91353107056596 then
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "moveme"
		bodyVelocity:SetAttribute("StunCheck", true)
		bodyVelocity.MaxForce = vector.create(90000, 0, 90000)
		bodyVelocity:SetAttribute("Speed", 95)
		bodyVelocity:SetAttribute("End", 1)
		bodyVelocity:SetAttribute("Fallout", 0.94)
		bodyVelocity.Parent = humanoidRootPart
		game.Debris:AddItem(bodyVelocity, 2)
		local bodyVelocity2 = Instance.new("BodyVelocity")
		bodyVelocity2:SetAttribute("StunCheck", true)
		bodyVelocity2.Velocity = vector.create(0, 50, 0)
		bodyVelocity2.MaxForce = vector.create(0, 90000, 0)
		bodyVelocity2.Parent = character.Torso
		local Debris = game:GetService("Debris")
		Debris:AddItem(bodyVelocity2, 0.15)
		blbv = { bodyVelocity, bodyVelocity2 }
	elseif tonumber(match) == 140620736290884 then
		local bodyVelocity = Instance.new("BodyVelocity")
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		bodyVelocity.MaxForce = vector.create(40000, 40000, 40000)
		bodyVelocity.Velocity = assemblyLinearVelocity
		bodyVelocity.Parent = character.Torso
		local v18 = 125
		local lastTime3 = tick()
		local v19 = nil
		v19 = shared.loop(function()
			if bodyVelocity and bodyVelocity.Parent and not (tick() - lastTime3 > 5) and object.IsPlaying then
				assemblyLinearVelocity *= 0.94
				v18 *= 0.92
				bodyVelocity.Velocity = assemblyLinearVelocity + Vector3.new(0, v18, 0)
			else
				if bodyVelocity.Parent then
					bodyVelocity:Destroy()
				end

				return v19()
			end
		end, 60)
	elseif tonumber(match) == 99798123383608 and not ninjaburstdone then
		ninjaburstdone = true
		object:GetMarkerReachedSignal("clones"):Connect(function()
			shared.repfire({
				Effect = "Camshake",
				Intensity = 1
			})
			local bodyVelocity = Instance.new("BodyVelocity")
			game.Debris:AddItem(bodyVelocity, 3)
			bodyVelocity.Name = "moveme"
			bodyVelocity.MaxForce = vector.create(2000000000, 0, 2000000000)
			bodyVelocity.Velocity = humanoidRootPart.CFrame.lookVector
			bodyVelocity.Parent = humanoidRootPart
			bodyVelocity:SetAttribute("Speed", 35)
			bodyVelocity:SetAttribute("End", 2)
			bodyVelocity:SetAttribute("Fallout", 1)
			task.spawn(function()
				local lastTime3 = tick()
				local v18 = lastTime3

				while true do
					task.wait()

					if character:FindFirstChild("byeclone") then
						break
					end

					local now7 = tick()
					local v19 = now7 - v18
					bodyVelocity:SetAttribute("Speed", bodyVelocity:GetAttribute("Speed") + 55 * v19)

					if tick() - lastTime3 > 2 or bodyVelocity:GetAttribute("Speed") >= 80 or not bodyVelocity.Parent then
						bodyVelocity:SetAttribute("Fallout", 0.93)
						return
					else
						v18 = now7
					end
				end

				bodyVelocity:Destroy()
			end)
		end)
	elseif tonumber(match) == 125939352094096 and not bladeburstdone then
		bladeburstdone = true
		local v18 = nil
		local stoppedConnection = nil
		object:GetMarkerReachedSignal("return"):Connect(function()
			if stoppedConnection then
				stoppedConnection:Disconnect()
			end

			if v18 and v18.Parent then
				v18:SetAttribute("Fallout", 0.715)
			end
		end)
		object:GetMarkerReachedSignal("step"):Connect(function()
			if v18 and v18.Parent then
				v18:Destroy()
			end

			v18 = nil
			local bodyVelocity = Instance.new("BodyVelocity")
			v18 = bodyVelocity
			bodyVelocity.Name = "moveme"
			bodyVelocity.MaxForce = vector.create(100000, 0, 100000)
			game.Debris:AddItem(bodyVelocity, 1)
			bodyVelocity:SetAttribute("RemoveOthers", true)
			bodyVelocity:SetAttribute("Speed", 120)
			bodyVelocity:SetAttribute("Goto", 90)
			bodyVelocity:SetAttribute("End", 1)
			bodyVelocity:SetAttribute("Fallout", 0.835)
			bodyVelocity.Parent = humanoidRootPart
			stoppedConnection = object.Stopped:Once(function()
				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity:Destroy()
				end
			end)
			task.delay(0.4, function()
				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity:SetAttribute("Goto", nil)
				end
			end)
		end)
	elseif tonumber(match) == 76676838298555 then
		local v18 = nil
		task.delay(0.795, function()
			if v18 and v18.Parent then
				v18:SetAttribute("Fallout", 0.8075)
			end
		end)
		object:GetMarkerReachedSignal("start"):Once(function()
			local bodyVelocity = Instance.new("BodyVelocity")
			object.Stopped:Once(function()
				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity:Destroy()
				end
			end)
			v18 = bodyVelocity
			bodyVelocity.Name = "moveme"
			bodyVelocity.MaxForce = vector.create(100000, 0, 100000)
			game.Debris:AddItem(bodyVelocity, 1)
			bodyVelocity:SetAttribute("RemoveOthers", true)
			bodyVelocity:SetAttribute("Speed", 8)
			bodyVelocity:SetAttribute("Goto", 3)
			bodyVelocity:SetAttribute("End", 1)
			bodyVelocity:SetAttribute("Fallout", 1)
			bodyVelocity.Parent = humanoidRootPart
			task.spawn(function()
				local lastTime3 = tick()

				repeat
					task.wait()
					bodyVelocity:SetAttribute("Speed", bodyVelocity:GetAttribute("Speed") + 5)
				until tick() - lastTime3 > 10 or bodyVelocity:GetAttribute("Speed") > 180 or not bodyVelocity.Parent or overrr

				bodyVelocity:SetAttribute("Fallout", 0.925)
			end)
		end)
		task.delay(0.24, function()
			if not object.IsPlaying then
				return
			end

			game:GetService("TweenService")
			game:GetService("RunService")
			game:GetService("Debris")
			local _ = {
				AMPLITUDE = 7,
				HEIGHT = 0,
				DEPTH = 0,
				CYCLES = 1,
				DURATION = 0.525,
				PHASE = 0,
				SMOOTH = true
			}

			local function cameraWave(character3)
				local TweenService = game:GetService("TweenService")
				local Debris = game:GetService("Debris")
				local v19 = character3:FindFirstChild("cameraoffsetadjustment")

				if not v19 then
					v19 = Instance.new("Vector3Value")
					v19.Name = "cameraoffsetadjustment"
					v19.Parent = character3
				end

				Debris:AddItem(v19, 1.6)
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				local function tweenTo(p, p2)
					local tween = TweenService:Create(
						v19,
						TweenInfo.new(
							p2 and 0.11320754716981132 or 0.13636363636363635,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							Value = p
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				object.Stopped:Once(function()
					if v19 and v19.Parent then
						v19:Destroy()
					end
				end)
				task.spawn(function()
					if not v19.Parent then
						return
					end

					tweenTo(vector.create(6, 0, 0))

					if not v19.Parent then
						return
					end

					tweenTo(vector.create(0, 0, 0), true)

					if not v19.Parent then
						return
					end

					tweenTo(vector.create(-8.5, 0, 0))

					if not v19.Parent then
						return
					end

					tweenTo(vector.create(0, 0, 0), true)

					if v19.Parent then
						v19:Destroy()
					end
				end)
				return v19
			end

			cameraWave(character)
			local thrown = workspace:FindFirstChild("Thrown")
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local resources = ReplicatedStorage2:FindFirstChild("Resources")

			if resources then
				local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
				resources = ReplicatedStorage3.Resources:FindFirstChild("WaterPalm")
			end

			if thrown and resources and character and character.PrimaryPart then
				local function build()
					local clone = resources:Clone()
					task.delay(5, function()
						if clone and clone.Parent then
							clone:Destroy()
						end
					end)
					clone.Anchored = true
					clone.CanCollide = false
					clone.CanQuery = false
					clone.CanTouch = false
					clone.Massless = true
					clone.Parent = thrown
					return clone
				end

				local clone = resources:Clone()
				task.delay(5, function()
					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
				clone.Anchored = true
				clone.CanCollide = false
				clone.CanQuery = false
				clone.CanTouch = false
				clone.Massless = true
				clone.Parent = thrown
				local clone2 = resources:Clone()
				task.delay(5, function()
					if clone2 and clone2.Parent then
						clone2:Destroy()
					end
				end)
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.CanQuery = false
				clone2.CanTouch = false
				clone2.Massless = true
				clone2.Parent = thrown
				local cameraoffsetadjustment = character:FindFirstChild("cameraoffsetadjustment")
				local lastTime3 = tick()
				local heartbeatConnection = nil

				local function teardown()
					if heartbeatConnection then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.delay(5, function()
						if clone and clone.Parent then
							clone:Destroy()
						end

						if clone2 and clone2.Parent then
							clone2:Destroy()
						end
					end)
				end

				local RunService = game:GetService("RunService")
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					if tick() - lastTime3 > 0.8 or not (character.PrimaryPart and clone.Parent and clone2.Parent) then
						return teardown()
					end

					local v19 = not (cameraoffsetadjustment and cameraoffsetadjustment.Parent) and 0 or cameraoffsetadjustment.Value.X
					local cFrame = character.PrimaryPart.CFrame
					clone.CFrame = cFrame * CFrame.new(v19 * 1.4, 0, -3)
					clone2.CFrame = cFrame * CFrame.new(v19 * 1, 0, -3)
				end)

				if object and object.Stopped then
					object.Stopped:Once(teardown)
				end
			end
		end)
	elseif tonumber(match) == 105329679752836 then
		local v18 = nil
		local v19 = false
		local now7 = tick()
		local flag2 = false
		object:GetMarkerReachedSignal("blast"):Once(function()
			now7 = tick()

			if v18 and v18.Parent then
				v18:Destroy()
			end

			flag2 = false
			v19 = false
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = vector.create(0, 20, 0)
			bodyVelocity.MaxForce = vector.create(0, 90000, 0)
			bodyVelocity.Parent = character.Torso
			v18 = bodyVelocity
			game.Debris:AddItem(bodyVelocity, 1)
			local lastTime3 = tick()
			task.spawn(function()
				local lastTime4 = tick()

				repeat
					task.wait()
					local intensity = math.min(0.2 + (tick() - lastTime4) / 0.4 * 0.2, 0.4)
					shared.repfire({
						Effect = "Camshake",
						Intensity = intensity
					})
				until tick() - lastTime4 > 0.47 or v19
			end)
			local v20 = nil
			v20 = shared.loop(function()
				if object and (not object or object.IsPlaying) and bodyVelocity and bodyVelocity.Parent and not (tick() - lastTime3 > 5) then
					local v21 = math.clamp((tick() - lastTime3) / 0.6, 0, 1)
					local v22 = math.clamp(v21 + 0, 0, 1) ^ 2.35 * 370 + 20
					bodyVelocity.Velocity = Vector3.new(0, v22, 0)

					if v21 >= 1 then
						bodyVelocity.Velocity = vector.create(0, 390, 0)
						return v20()
					end
				else
					flag2 = true

					if bodyVelocity and bodyVelocity.Parent then
						bodyVelocity:Destroy()
					end

					return v20()
				end
			end, 60)
		end)
		object:GetMarkerReachedSignal("jump"):Once(function()
			if flag2 then
				return
			end

			v19 = true
			shared.repfire({
				Effect = "Camshake",
				Intensity = 5
			})

			if v18 and v18.Parent then
				v18:Destroy()
			end

			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "moveme"
			bodyVelocity.MaxForce = vector.create(0, 90000, 0)
			bodyVelocity.Velocity = vector.create(0, 0, 0)
			bodyVelocity:SetAttribute("Speed", 0)
			bodyVelocity:SetAttribute("Fallout", 0.9)
			bodyVelocity:SetAttribute("Aerial", 180)
			bodyVelocity.Parent = humanoidRootPart
			game.Debris:AddItem(bodyVelocity, 3)
		end)
	elseif tonumber(match) == 127386796069137 and not batterburstdone then
		batterburstdone = true
		local v18 = nil
		local v19 = false
		local flag2 = false
		local v20 = {}
		object:GetMarkerReachedSignal("swingend"):Connect(function()
			task.delay(0.035, function()
				if flag2 then
					return
				end

				task.delay(0.0365, function()
					v19 = true
				end)
				task.delay(0.35, function()
					if v18 and v18.Parent then
						v18:Destroy()
					end
				end)

				if v18 and v18.Parent then
					v18:SetAttribute("Goto", nil)
					v18:SetAttribute("Fallout", 0.9125)
				end
			end)
		end)
		object:GetMarkerReachedSignal("velocity"):Connect(function()
			task.wait(0.0125)
			v19 = false
			flag2 = false
			object.Stopped:Once(function()
				flag2 = true

				for _, v21 in pairs(v20) do
					v21:Destroy()
				end
			end)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "moveme"
			game.Debris:AddItem(bodyVelocity, 2)
			bodyVelocity.MaxForce = vector.create(40000, 0, 40000)
			bodyVelocity:SetAttribute("Speed", 87)
			bodyVelocity:SetAttribute("Goto", 20)
			bodyVelocity:SetAttribute("End", 1)
			bodyVelocity:SetAttribute("Fallout", 0.96)
			bodyVelocity.Parent = humanoidRootPart
			table.insert(v20, bodyVelocity)
			task.delay(0.4, function()
				if flag2 then
					game.Debris:AddItem(bodyVelocity, 0)
					return
				end

				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity:Destroy()
				end

				bodyVelocity = Instance.new("BodyVelocity")
				v18 = bodyVelocity
				bodyVelocity.Name = "moveme"
				table.insert(v20, bodyVelocity)
				bodyVelocity.MaxForce = vector.create(40000, 0, 40000)
				game.Debris:AddItem(bodyVelocity, 2)
				bodyVelocity:SetAttribute("Speed", 135)
				bodyVelocity:SetAttribute("Goto", 20)
				bodyVelocity:SetAttribute("End", 1)
				bodyVelocity:SetAttribute("Fallout", 0.94)
				bodyVelocity.Parent = humanoidRootPart
			end)
			task.spawn(function()
				local lastTime3 = tick()

				repeat
					task.wait()
					local v21 = math.min(0.55 + (tick() - lastTime3) / 0.6 * 1.5, 1.5)
					shared.repfire({
						Effect = "Camshake",
						Intensity = v21 / 1.2
					})
				until tick() - lastTime3 > 1 or v19 or flag2
			end)
		end)
	elseif tonumber(match) == 105616370132258 and not mechliftdone then
		mechliftdone = true
		object:GetMarkerReachedSignal("lift"):Connect(function()
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = vector.create(0, 200, 0)
			bodyVelocity.MaxForce = vector.create(0, 90000, 0)
			bodyVelocity.Parent = character.Torso
			game.Debris:AddItem(bodyVelocity, 5)
			local lastTime3 = tick()
			local v18 = nil
			v18 = shared.loop(function()
				if not bodyVelocity or not bodyVelocity.Parent or tick() - lastTime3 > 5 then
					return v18()
				end

				local v19 = math.clamp(bodyVelocity.Velocity.Y * 0.975, -100, 100)
				bodyVelocity.Velocity = Vector3.new(0, v19, 0)

				if v19 <= 0.1 then
					bodyVelocity:Destroy()
				end
			end, 60)
		end)
	elseif tonumber(match) == 71852503410610 then
		if blbv then
			for _, v18 in pairs(blbv) do
				v18:Destroy()
			end
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = vector.create(0, 75, 0)
		bodyVelocity.MaxForce = vector.create(0, 90000, 0)
		bodyVelocity.Parent = character.Torso
		bodyVelocity:SetAttribute("StunCheck", true)
		game.Debris:AddItem(bodyVelocity, 4)
		local lastTime3 = tick()
		local v18 = 0.94

		local function fn10()
			for _, child in pairs(character:GetChildren()) do
				if tostring(child) == "Freeze" and not child:GetAttribute("Allowed") then
					return true
				end
			end
		end

		local accessory = Instance.new("Accessory")
		accessory.Name = "BodyGyroBind"
		accessory:SetAttribute("StunCheck", true)
		accessory.Parent = character
		local v19 = nil
		v19 = shared.loop(function()
			if not bodyVelocity or not bodyVelocity.Parent or tick() - lastTime3 > 5 then
				return v19()
			end

			if character:FindFirstChild("Ragdoll") or fn10() then
				if bodyVelocity then
					bodyVelocity:Destroy()
				end

				if accessory then
					accessory:Destroy()
				end

				for _, v20 in pairs(blbv) do
					v20:Destroy("")
				end

				return v19()
			else
				local v20 = math.clamp(bodyVelocity.Velocity.Y * v18, -100, 100)

				if v20 <= 2 then
					v18 = 1
					v20 -= 0.4
				end

				bodyVelocity.Velocity = Vector3.new(0, v20, 0)
			end
		end, 60)
		task.delay(5, function()
			if v19 then
				v19()
			end
		end)
		shared.repfire({
			Effect = "BodyGyro",
			Bind = accessory,
			Server = true,
			char = character
		})
		local blfired = character:WaitForChild("blfired", 3.765)
		bodyVelocity:Destroy()
		accessory:Destroy()

		if blfired then
			warn("no")
			local repfire = shared.repfire({
				Effect = "Velocity Forward",
				Distance = -125,
				Time = 0.15,
				StunCheck = true
			})
			repfire.MaxForce = vector.create(40000, 20000, 40000)
			table.insert(blbv, repfire)
		end
	elseif tonumber(match) == 17860467628 then
		local accessory = Instance.new("Accessory")
		accessory.Name = "BodyGyroBind"
		accessory.Parent = character
		shared.repfire({
			Effect = "BodyGyro",
			Bind = accessory,
			Server = true,
			char = character
		})
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "moveme"
		bodyVelocity.MaxForce = vector.create(90000, 90000, 90000)
		bodyVelocity:SetAttribute("Speed", 1)
		bodyVelocity:SetAttribute("End", 0)
		bodyVelocity:SetAttribute("Goto", 1)
		bodyVelocity:SetAttribute("Fallout", 0.98)
		bodyVelocity.Parent = humanoidRootPart
		v8 = { bodyVelocity, accessory }
		task.delay(10, function()
			bodyVelocity:Destroy()
			accessory:Destroy()
		end)

		if not kdone512 then
			kdone512 = true
			object:GetMarkerReachedSignal("fly"):Connect(function()
				v8[1]:SetAttribute("Speed", 250)
				v8[1]:SetAttribute("Goto", 120)
				v8[1]:SetAttribute("alrdone", true)
			end)
			object:GetMarkerReachedSignal("stop"):Connect(function()
				v8[1]:SetAttribute("Goto", nil)
				v8[1]:SetAttribute("Fallout", 0.945)
				v8[1]:SetAttribute("End", 15)
				v8[1]:GetPropertyChangedSignal("Parent"):Connect(function()
					v8[2]:Destroy()
				end)
			end)
			character:GetAttributeChangedSignal("EPReset3"):Connect(function()
				if v8 then
					local v18 = rawget(v8, 1)

					if v18 and not v18:GetAttribute("alrdone") then
						v18:SetAttribute("Speed", 250)
						v18:SetAttribute("Goto", 120)
					end
				end
			end)
			character:GetAttributeChangedSignal("EPReset2"):Connect(function()
				local v18 = v8 and rawget(v8, 1)

				if v18 then
					if v18:GetAttribute("Speed") <= 120 then
						v18:SetAttribute("Speed", 120)
					end

					v18:SetAttribute("Fallout", 0.925)
					v18:SetAttribute("Goto", nil)
				end
			end)
			character:GetAttributeChangedSignal("EPReset"):Connect(function()
				if v8 then
					local v18 = rawget(v8, 1)

					if v18 then
						v18:Destroy()
					end

					local v19 = rawget(v8, 2)

					if v19 then
						v19:Destroy()
					end
				end
			end)
		end
	elseif tonumber(match) == 16597322398 then
		local accessory = Instance.new("Accessory")
		accessory.Name = "BodyGyroBind"
		accessory.Parent = character
		shared.repfire({
			Effect = "BodyGyro",
			Bind = accessory,
			Server = true,
			char = character
		})
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "moveme"
		bodyVelocity.MaxForce = vector.create(90000, 90000, 90000)
		bodyVelocity:SetAttribute("Speed", 25)
		bodyVelocity:SetAttribute("End", 0)
		bodyVelocity:SetAttribute("Goto", 25)
		bodyVelocity:SetAttribute("Fallout", 0.98)
		bodyVelocity.Parent = humanoidRootPart
		v8 = { bodyVelocity, accessory }
		task.delay(2, function()
			bodyVelocity:Destroy()
			accessory:Destroy()
		end)

		if not v9 then
			v9 = true
			object:GetMarkerReachedSignal("boost"):Connect(function()
				v8[1]:SetAttribute("Speed", 135)
				v8[1]:SetAttribute("Goto", nil)
			end)
			character:GetAttributeChangedSignal("EPReset2"):Connect(function()
				local v18 = v8 and rawget(v8, 1)

				if v18 then
					v18:SetAttribute("Fallout", 0.85)
				end
			end)
			character:GetAttributeChangedSignal("EPReset"):Connect(function()
				if v8 then
					local v18 = rawget(v8, 1)

					if v18 then
						v18:Destroy()
					end

					local v19 = rawget(v8, 2)

					if v19 then
						v19:Destroy()
					end
				end
			end)
		end
	elseif tonumber(match) == 16737255386 then
		local bodyVelocity = humanoidRootPart:FindFirstChildOfClass("BodyVelocity")

		if bodyVelocity then
			bodyVelocity:Destroy()
		end

		v10 = shared.repfire({
			Effect = "Velocity Forward",
			Distance = 0,
			Time = 5,
			Alternate = torso,
			Up = 0
		})

		if not v11 then
			v11 = true
			object:GetMarkerReachedSignal("fly"):Connect(function()
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = humanoidRootPart.CFrame
				local valueChangedConnection = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
					local v18 = { humanoidRootPart.CFrame:GetComponents() }
					v18[1] = cFrameValue.Value.X
					v18[2] = cFrameValue.Value.Y
					v18[3] = cFrameValue.Value.Z
					character:SetPrimaryPartCFrame(CFrame.new(unpack(v18)))
				end)
				service:Create(cFrameValue, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Value = humanoidRootPart.CFrame * CFrame.new(0, 44, 0)
				}):Play()
				task.delay(0.85, function()
					cFrameValue:Destroy()
					valueChangedConnection:Disconnect()
				end)
			end)
			character:GetAttributeChangedSignal("MeteorCheck"):Connect(function()
				if v10 then
					v10:Destroy()
					v10 = nil
				end
			end)
		end
	elseif tonumber(match) == 17799224866 then
		if not v12 then
			v12 = true
			local v18 = nil
			object:GetMarkerReachedSignal("hit1"):Connect(function()
				local bodyVelocity = humanoidRootPart:FindFirstChildOfClass("BodyVelocity")

				if bodyVelocity then
					local Debris = game:GetService("Debris")
					Debris:AddItem(bodyVelocity, 0)
					bodyVelocity:Destroy()
				end

				v18 = shared.repfire({
					Effect = "Velocity Forward",
					Distance = 57,
					Time = 0.4,
					Up = 35
				})
				local v19 = v18
				local lastTime3 = tick()
				local v20 = nil
				v20 = shared.loop(function()
					if not v19 or not v19.Parent or tick() - lastTime3 > 5 then
						return v20()
					end

					v19.Velocity *= 0.875
				end, 60)
			end)
			object:GetMarkerReachedSignal("hit2"):Connect(function()
				if v18 then
					v18:Destroy()
				end

				v18 = shared.repfire({
					Effect = "Velocity Forward",
					Distance = 57,
					Last = 0.15,
					Up = 105
				})
				local v19 = v18
				local lastTime3 = tick()
				local v20 = nil
				v20 = shared.loop(function()
					if not v19 or not v19.Parent or tick() - lastTime3 > 5 then
						return v20()
					end

					v19.Velocity *= 0.875
				end, 60)
			end)
			object:GetMarkerReachedSignal("hit3"):Connect(function()
				if v18 then
					v18:Destroy()
				end

				v18 = shared.repfire({
					Effect = "Velocity Forward",
					Distance = 19,
					Time = 1,
					Up = 40
				})
				local v19 = v18
				local lastTime3 = tick()
				local v20 = nil
				v20 = shared.loop(function()
					if not v19 or not v19.Parent or tick() - lastTime3 > 5 then
						return v20()
					end

					v19.Velocity *= 0.96
				end, 60)
			end)
			object:GetMarkerReachedSignal("hit4"):Connect(function()
				if v18 then
					v18:Destroy()
				end

				v18 = shared.repfire({
					Effect = "Velocity Forward",
					Distance = 0,
					Time = 0.15,
					Up = 100
				})
				local v19 = v18
				local lastTime3 = tick()
				local v20 = nil
				v20 = shared.loop(function()
					if not v19 or not v19.Parent or tick() - lastTime3 > 5 then
						return v20()
					end

					v19.Velocity *= 0.875
				end, 60)
			end)
		end
	elseif tonumber(match) == 15145462680 and not v13 then
		v13 = true
		local v18 = nil
		object:GetMarkerReachedSignal("hit1"):Connect(function()
			local bodyVelocity = humanoidRootPart:FindFirstChildOfClass("BodyVelocity")

			if bodyVelocity then
				local Debris = game:GetService("Debris")
				Debris:AddItem(bodyVelocity, 0)
				bodyVelocity:Destroy()
			end

			v18 = shared.repfire({
				Effect = "Velocity Forward",
				Distance = 57,
				Last = 0.15,
				Up = 105
			})
			local v19 = v18
			local lastTime3 = tick()
			local v20 = nil
			v20 = shared.loop(function()
				if not v19 or not v19.Parent or tick() - lastTime3 > 5 then
					return v20()
				end

				v19.Velocity *= 0.875
			end, 60)
		end)
		object:GetMarkerReachedSignal("hit2"):Connect(function()
			if v18 then
				v18:Destroy()
			end

			v18 = shared.repfire({
				Effect = "Velocity Forward",
				Distance = 57,
				Last = 0.15,
				Up = 105
			})
			local v19 = v18
			local lastTime3 = tick()
			local v20 = nil
			v20 = shared.loop(function()
				if not v19 or not v19.Parent or tick() - lastTime3 > 5 then
					return v20()
				end

				v19.Velocity *= 0.875
			end, 60)
		end)
		object:GetMarkerReachedSignal("hit3"):Connect(function()
			if v18 then
				v18:Destroy()
			end

			v18 = shared.repfire({
				Effect = "Velocity Forward",
				Distance = 19,
				Time = 1,
				Up = 40
			})
			local v19 = v18
			local lastTime3 = tick()
			local v20 = nil
			v20 = shared.loop(function()
				if not v19 or not v19.Parent or tick() - lastTime3 > 5 then
					return v20()
				end

				v19.Velocity *= 0.96
			end, 60)
		end)
		object:GetMarkerReachedSignal("final"):Connect(function()
			if v18 then
				v18:Destroy()
			end

			v18 = shared.repfire({
				Effect = "Velocity Forward",
				Distance = 0,
				Time = 0.15,
				Up = 100
			})
			local v19 = v18
			local lastTime3 = tick()
			local v20 = nil
			v20 = shared.loop(function()
				if not v19 or not v19.Parent or tick() - lastTime3 > 5 then
					return v20()
				end

				v19.Velocity *= 0.875
			end, 60)
		end)
	end
end

for _, v17 in pairs(humanoid:GetPlayingAnimationTracks()) do
	fn9(v17)
end

humanoid.AnimationPlayed:connect(fn9)
local v17 = fn(7815618175)
local realzombie2 = nil
local value = 131585091153240
local v18 = false
local v19 = false

function realzombie()
	local v20 = {
		Axe = 131585091153240,
		Deagles = 79741533269101
	}
	local overlapRunAxe = character:FindFirstChild("OverlapRunAxe")

	if overlapRunAxe then
		v18 = true
		v20.Axe = 84022163849541
		v17 = fn(84022163849541)

		if not v19 then
			v19 = true
			overlapRunAxe:GetPropertyChangedSignal("Parent"):Once(function()
				v19 = false
				local v21 = v17
				realzombie2()

				if v21.IsPlaying then
					v21:Stop()
				end
			end)
		end
	else
		local currentWeapon = character:FindFirstChild("CurrentWeapon")

		if currentWeapon and currentWeapon.Value then
			local v21

			if v18 and not overlapRunAxe then
				v18 = false
				v21 = true
			else
				v21 = false
			end

			if value ~= currentWeapon.Value or v21 then
				value = currentWeapon.Value

				if v20[currentWeapon.Value] then
					v17 = fn(v20[currentWeapon.Value])
				end
			end
		end
	end
end

if character:GetAttribute("Character") == "Zombie" then
	realzombie2 = realzombie
	v17 = fn(131585091153240)
end

animate.walk.WalkAnim.AnimationId = "rbxassetid://7807831448"
animate:WaitForChild("toolnone", 5)
task.delay(0.01, function()
	for _, child in pairs(animate.idle:GetChildren()) do
		child.AnimationId = "rbxassetid://14516273501"
	end
end)
local v20 = shared[tostring((fn6({
	Name = "ModifyBodyMoverSpeed"
}))) .. ""]

local function fn10(W, p, index)
	local v21 = 0
	local v22 = falselocal2
	local v23 = 5
	falselocal2 = false

	if character:FindFirstChild("RootAnchor") and not index then
		return
	end

	local v24 = character:GetAttribute("InMech") and true or false
	local v25 = fn(10480793962)

	if count2 == 3 then
		count2 = 0
		v3 = nil
	elseif tick() - now4 >= 3.65 then
		count2 = 0
		v3 = nil
	end

	task.delay(0, function()
		for _, child in pairs(character:GetChildren()) do
			if tostring(child) == "RootAnchor" and child:GetAttribute("maulme") then
				game.Debris:AddItem(child, 0)
			end
		end
	end)
	count2 += 1
	now4 = tick()

	if W == Enum.KeyCode.W then
		return
	end

	if W == Enum.KeyCode.A then
		v25 = fn(10480796021)
		v21 = 90
	elseif W == Enum.KeyCode.D then
		v21 = -90
	elseif W == Enum.KeyCode.S then
		v25 = fn(10491993682)
		v23 = 10
		v21 = 180
	end

	if v24 then
		local mechDash = character:FindFirstChild("MechDash")

		if mechDash then
			mechDash:Destroy()
		end

		local v26 = math.random(1, 100000)
		local accessory = Instance.new("Accessory")
		accessory.Name = "MechDash"
		accessory.Parent = character
		game.Debris:AddItem(accessory, 2)
		local attachment = Instance.new("Attachment")
		attachment.Parent = humanoidRootPart
		attachment.CFrame = CFrame.new(0, 7, 0)
		local attachment2 = Instance.new("Attachment")
		attachment2.Parent = humanoidRootPart
		attachment2.CFrame = CFrame.new(0, -2, 0)

		for _, v27 in pairs({ attachment, attachment2 }) do
			game.Debris:AddItem(v27, 1)
		end

		local sfxes = {}

		local function fn11(data)
			local sfx = shared.sfx({
				SoundId = data.id,
				Volume = data.vol + 0.5,
				Parent = data.parent,
				CFrame = data.CFrame
			})
			sfx:Play("")
			table.insert(sfxes, sfx)
		end

		if W == Enum.KeyCode.S then
			accessory:SetAttribute("Back", true)
			fn11({
				id = "rbxassetid://121758982890874",
				vol = 3,
				parent = attachment
			})
			fn11({
				id = "rbxassetid://74019640117878",
				vol = 2.5,
				CFrame = attachment2.WorldCFrame
			})
		else
			local v27 = { "rbxassetid://139335409107836", "rbxassetid://135591863841898" }

			if W == Enum.KeyCode.A then
				local v28 = v3 == Enum.KeyCode.A
				fn11({
					id = v28 and "rbxassetid://81840980411048" or "rbxassetid://134999341555398",
					vol = 3,
					parent = attachment
				})
				fn11({
					id = v28 and v27[math.random(1, 2)] or "rbxassetid://139335409107836",
					vol = 2.5,
					CFrame = attachment2.WorldCFrame
				})
			else
				local v28 = v3 == Enum.KeyCode.D
				fn11({
					id = v28 and "rbxassetid://134999341555398" or "rbxassetid://81840980411048",
					vol = 3,
					parent = attachment
				})
				fn11({
					id = v28 and v27[math.random(1, 2)] or "rbxassetid://135591863841898",
					vol = 2.5,
					CFrame = attachment2.WorldCFrame
				})
			end
		end

		v3 = W
		task.spawn(function()
			local name = W == Enum.KeyCode.A and "Left" or W == Enum.KeyCode.D and "Right" or "Back"
			shared.repfire({
				Name = name,
				Type = "MechDashMovement",
				Char = character,
				bind = accessory
			})
		end)
		shared.addshake(3.5)
		local animationController = character:FindFirstChild("Mech"):FindFirstChildOfClass("AnimationController")
		local v27 = {
			[Enum.KeyCode.D] = 113231675639558,
			[Enum.KeyCode.S] = 111851029692251,
			[Enum.KeyCode.A] = 80674820534179
		}

		for _, v28 in pairs(animationController:GetPlayingAnimationTracks()) do
			v28:Stop()
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. tostring(v27[W])
		game.Debris:AddItem(animation, 1)
		local track = animationController:LoadAnimation(animation)
		local bodyVelocity = humanoidRootPart:FindFirstChildOfClass("BodyVelocity")

		if bodyVelocity then
			bodyVelocity:Destroy()
		end

		local v28 = { accessory, (Instance.new("BodyVelocity")) }

		for _, v29 in pairs(v28) do
			v29:SetAttribute("seed", v26)
			v29:SetAttribute("Direction", W == Enum.KeyCode.A and "Left" or "Right")
		end

		local bodyVelocity2 = Instance.new("BodyVelocity")
		bodyVelocity2:SetAttribute("Ohio", true)
		bodyVelocity2.Name = "moveme"
		bodyVelocity2.MaxForce = vector.create(40000, 0, 40000)
		task.delay(2, function()
			if bodyVelocity2 and bodyVelocity2.Parent then
				bodyVelocity2:Destroy()
			end
		end)
		track:Play()
		track:AdjustSpeed(1.1)
		bodyVelocity2:SetAttribute("Speed", 162.5)
		bodyVelocity2:SetAttribute("Fallout", 0.98)
		bodyVelocity2:SetAttribute("End", 5)
		bodyVelocity2:SetAttribute("Inverted", W == Enum.KeyCode.S)
		bodyVelocity2:SetAttribute("Direction", W == Enum.KeyCode.A and "Left" or "Right")
		task.delay(0.315, function()
			if track.IsPlaying then
				bodyVelocity2:SetAttribute("Fallout", 0.9)
			end
		end)
		bodyVelocity2.Parent = humanoidRootPart
		local destroyingConnection = nil
		local flag2 = false

		local function fn12()
			if flag2 then
				return
			end

			flag2 = true

			if not chan then
				for _, v31 in pairs(sfxes) do
					if not (v31 and v31.Parent) then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(v31, TweenInfo.new(0.325), {
						Volume = 0
					}):Play()
				end
			end

			if destroyingConnection then
				destroyingConnection:Disconnect()
			end

			for _, v32 in pairs({ bodyVelocity2, accessory }) do
				game.Debris:AddItem(v32, 0)
			end
		end

		destroyingConnection = accessory.Destroying:Once(function()
			fn12()

			if track then
				track:Stop(0)
			end
		end)
		local v31 = false
		task.delay(0.5, function()
			if not (accessory and accessory.Parent) then
				return warn("noholder")
			end

			v31 = true
			track:Stop(0.2)

			if shared.mechidle then
				shared.mechidle:Play()
			end

			task.wait()

			if destroyingConnection then
				destroyingConnection:Disconnect()
			end

			if bodyVelocity2 and bodyVelocity2.Parent then
				bodyVelocity2:Destroy()
			end

			if accessory and accessory.Parent then
				accessory:Destroy("")
			end
		end)
		bodyVelocity2:GetPropertyChangedSignal("MaxForce"):Once(function()
			if track and track.IsPlaying and not v31 then
				track:Stop(0)
			end
		end)
		spawn(function()
			local lastTime3 = tick()

			while task.wait() and not (tick() - lastTime3 >= 2) and bodyVelocity2 do
				if not bodyVelocity2.Parent then
					break
				end

				local v32 = workspace.Camera.CFrame.lookVector * vector.create(1, 0, 1)
				humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v32)
			end
		end)
	else
		local walkSpeed = humanoid.WalkSpeed
		local v26 = character:FindFirstChild("DoingEmote") and 16 or walkSpeed

		if v22 then
			v26 -= 9
		end

		local v27 = v26 * 2.5
		local v28 = math.clamp(p or v27, 0, 40) * (v23 == 10 and 4 or 5)

		if not character:GetAttribute("Ulted") then
			v28 -= 60 * (1 - humanoid.Health / humanoid.MaxHealth)
		end

		local v29 = { v28 }
		local v30 = { v29[1] }
		character:SetAttribute("_JustDashed", tick())
		local bodyVelocity = humanoidRootPart:FindFirstChildOfClass("BodyVelocity")

		if bodyVelocity then
			bodyVelocity:Destroy()
		end

		local bodyVelocity2 = Instance.new("BodyVelocity")
		bodyVelocity2.Name = "dodgevelocity"
		bodyVelocity2.MaxForce = vector.create(50000, 0, 50000)

		if character:FindFirstChild("Slowed") then
			bodyVelocity2.MaxForce = vector.create(10000, 0, 10000)
		end

		bodyVelocity2.Parent = humanoidRootPart
		v25:Play()
		local stoppedConnection = nil

		if v25 then
			tick()
			local v31 = nil
			local thread = task.delay(0.49, function()
				if v31 and bodyVelocity2 and bodyVelocity2.Parent then
					bodyVelocity2:Destroy()
				end
			end)
			stoppedConnection = v25.Stopped:Once(function()
				local dashRetain = character:FindFirstChild("DashRetain")

				if dashRetain then
					local falloutSpeed = dashRetain:GetAttribute("FalloutSpeed")
					v31 = true
					bodyVelocity2:SetAttribute("Fallout", falloutSpeed or 0.8)
					return stoppedConnection:Disconnect()
				else
					if thread then
						task.cancel(thread)
					end

					bodyVelocity2:Destroy()
					return stoppedConnection:Disconnect()
				end
			end)
		end

		local v31 = nil
		v31 = shared.loop(function()
			v20(bodyVelocity2, v31, humanoidRootPart, communicate, v29, v21, v23, v30)
		end)
	end
end

fn(13379404053)
local SoundService = game:GetService("SoundService")
local sounds = SoundService.Sounds
local now7 = 0
local v21 = nil
humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
local lastTime3 = nil
local position = nil
local cameraType = currentCamera.CameraType
local cameraSubject = currentCamera.CameraSubject
local lastTime4 = nil
local cameraOffset = nil
local v22 = nil

fn5 = function(instance)
	if not localPlayer:GetAttribute("cameramode") and not localPlayer:GetAttribute("NoShiftlock") and (currentCamera.CameraType == Enum.CameraType.Scriptable or currentCamera.CameraSubject ~= humanoid) and not character:FindFirstChild("Freeze") and not character:FindFirstChild("Slowed") and humanoid.Health > 0 then
		if position then
			if (humanoidRootPart.Position - position).Magnitude >= 5 and tick() - lastTime3 >= 2 then
				position = nil
				lastTime3 = nil
				currentCamera.CameraType = cameraType
				currentCamera.CameraSubject = cameraSubject
				currentCamera.FieldOfView = localPlayer:GetAttribute("S_FOV") or 70
				shared.SetCore(true, 3)
			end
		else
			position = humanoidRootPart.Position
			lastTime3 = tick()
		end
	end

	local _ = currentCamera.CameraSubject

	if humanoid.CameraOffset ~= vector.create(0, 0, 0) and not (localPlayer:GetAttribute("cameramode") or localPlayer:GetAttribute("NoShiftlock")) then
		if lastTime4 and humanoid.CameraOffset == cameraOffset then
			if tick() - lastTime4 >= 3 then
				character:SetAttribute("NoHeadLerp", false)
				humanoid.CameraOffset = vector.create(0, 0, 0)
				lastTime4 = nil
				cameraOffset = nil
			end
		else
			cameraOffset = humanoid.CameraOffset
			lastTime4 = tick()
		end
	end

	if tick() - now7 > 5 then
		now7 = tick()
		task.spawn(function()
			local ranked = ReplicatedStorage:FindFirstChild("Ranked")
			local pingRoundTrip = ranked and ranked:FindFirstChild("PingRoundTrip")

			if not pingRoundTrip then
				return
			end

			local lastTime5 = tick()

			if not pcall(function()
				pingRoundTrip:InvokeServer()
			end) then
				return
			end

			fn3({
				Goal = "ReportPing",
				ms = (tick() - lastTime5) * 1000
			})
		end)
	end

	if instance == "OverlapRunAxe" then
		realzombie2()
	end

	if instance == "JustEvasived" then
		now5 = tick()

		if localPlayer.Name == "22freshfrenchfries" then
			warn("UPDATED TO ACTUAL CD")
		end
	end

	if instance == "SideDashDisable" and character:GetAttribute("SideDashDisable") == true then
		character:SetAttribute("SideDashDisable", tick())
	end

	local awakenSpeed = character:GetAttribute("Ulted") and v.awakenSpeed or v.baseSpeed or 16
	local awakenJumpPower = character:GetAttribute("Ulted") and v.awakenJumpPower or v.baseJumpPower or 50

	if v22 then
		awakenSpeed = v22
	end

	local wSDecrease = character:GetAttribute("WSDecrease")
	local walkSpeed

	if wSDecrease then
		local v24 = awakenSpeed - wSDecrease
		walkSpeed = v24 < 0 and 0 or v24
	else
		walkSpeed = awakenSpeed
	end

	v6 = touchEnabled or gamepadEnabled or localPlayer:GetAttribute("S_AutoRun")
	slowed = character:FindFirstChild("Slowed")
	freeze = character:FindFirstChild("Freeze")
	local v24 = false
	local speedUp = character:FindFirstChild("SpeedUp")

	if speedUp and speedUp:GetAttribute("CustomMoveSpeedUp") == true then
		local freeze2 = character:FindFirstChild("Freeze")

		if freeze2 and freeze2:GetAttribute("CustomMoveStun") == true then
			local v25 = false

			for _, child in pairs(character:GetChildren()) do
				if child == freeze2 then
					continue
				end

				local name = child.Name

				if not (name == "Freeze" or name == "Slowed" or name == "RootAnchor" or name == "Ragdoll") then
					continue
				end

				v25 = true
				break
			end

			v24 = not v25
		elseif not (character:FindFirstChild("Slowed") or character:FindFirstChild("RootAnchor") or character:FindFirstChild("Ragdoll")) then
			v24 = true
		end
	end

	if instance == "LastDamageDone" then
		total = 0
	end

	if total > 0 and not workspace:GetAttribute("NoFatigue") then
		awakenJumpPower = math.max(awakenJumpPower - total * 1, 27)
	end

	if not touchEnabled then
		pcall(game.StarterGui.SetCoreGuiEnabled, game.StarterGui, Enum.CoreGuiType.PlayerList, false)
	end

	game.StarterGui:SetCoreGuiEnabled(2, false)
	local tool = character:FindFirstChildOfClass("Tool")

	if not (v24 or ActionCheck:Check(character, { "Run" })) or character:FindFirstChild("StopRunning") or tool and tool:FindFirstChild("Handle") or character:FindFirstChild("CrabCamera") or humanoid:GetState() == Enum.HumanoidStateType.Climbing then
		falselocal2 = falselocal
		local tool2 = character:FindFirstChildOfClass("Tool")

		if not (v24 or ActionCheck:Check(character, { "Run" })) or character:FindFirstChild("StopRunning") or tool2 and tool2:FindFirstChild("Handle") or character:FindFirstChild("CrabCamera") or humanoid:GetState() == Enum.HumanoidStateType.Climbing then
			falselocal2 = false
		end
	end

	if falselocal2 then
		local awakenRunSpeed = character:GetAttribute("Ulted") and v.awakenRunSpeed or v.runSpeed

		if character:GetAttribute("Ulted") or character:FindFirstChild("Counter") then
			walkSpeed += 7
		end

		local speedMultiplier = workspace:GetAttribute("SpeedMultiplier") or 1
		local v25 = workspace:GetAttribute("EffectAffects") ~= 1 and workspace:GetAttribute("VIPServerOwner") ~= character.Name and 1 or speedMultiplier

		if character:GetAttribute("Ulted") and type(v.awakenRunSpeed) == "number" then
			walkSpeed += math.max(v.awakenRunSpeed - walkSpeed, 0) * v25
		elseif type(awakenRunSpeed) == "number" then
			walkSpeed += math.max(awakenRunSpeed - awakenSpeed, 0) * v25
		else
			walkSpeed += 9 * v25
		end
	end

	local v25 = falselocal2

	if character:FindFirstChild("Mech") and character:GetAttribute("InMech") and tostring(instance) == "Freeze" and instance:GetAttribute("MechStun") then
		local exception = instance:GetAttribute("Exception")
		local v26 = exception and typeof(exception) == "number" and { "rbxassetid://" .. tostring(exception) } or {
			"rbxassetid://73536157885878",
			"rbxassetid://107470574646661",
			"rbxassetid://128263166320457"
		}

		for _, v27 in pairs(character.Mech.AnimationController:GetPlayingAnimationTracks()) do
			if not table.find(v26, v27.Animation.AnimationId) then
				v27:Stop()
			end
		end
	end

	if v4 ~= v25 then
		v4 = v25

		if humanoid:GetState() == Enum.HumanoidStateType.Climbing then
			v25 = false
		end

		character:SetAttribute("Running", v25)

		if v25 then
			if realzombie2 then
				realzombie2()
			end

			v17:Play()
		else
			v17:Stop()
		end
	end

	local v26 = character:GetAttribute("WeaponHolding") == "Ninjato" and 13379404053 or character:GetAttribute("WeaponHolding") == "Katana" and 15146348738 or 14357924814
	local grabWeapon = character:FindFirstChild("GrabWeapon")

	if grabWeapon and grabWeapon:GetAttribute("Temporary") then
		grabWeapon = nil
	end

	local v27

	if character:GetAttribute("WeaponHolding") == "Bat" then
		v27 = true
		grabWeapon = not grabWeapon
	else
		v27 = false
	end

	if not (v27 or character:GetAttribute("IceBoss")) then
		if v25 then
			if grabWeapon then
				local v28 = fn(v26)

				if not v28.IsPlaying then
					v28:Play(not v27 and 0.25)
				end
			else
				fn(v26):Stop()
			end
		else
			fn(v26):Stop()
		end
	end

	if character:GetAttribute("Blocking") then
		walkSpeed /= 2
		awakenJumpPower = 0
	end

	if v21 then
		local slowed2 = character:FindFirstChild("Slowed")

		if character:FindFirstChild("Freeze") or character:FindFirstChild("Ragdoll") or character:FindFirstChild("RootAnchor") or not slowed2 or slowed2 ~= v21.sl then
			v21.cancel()
			v21 = nil
		end
	end

	local canWalk = character:FindFirstChild("CanWalk")
	local slowed2 = character:FindFirstChild("Slowed")

	if slowed2 then
		local tween = slowed2:GetAttribute("Tween")
		local start = slowed2:GetAttribute("Start")
		local attribute = slowed2:GetAttribute("End")

		if tween and start and attribute and not (canWalk or character:FindFirstChild("Freeze") or character:FindFirstChild("Ragdoll") or character:FindFirstChild("RootAnchor")) then
			if not v21 then
				local flag2 = false
				v21 = {
					sl = slowed2,
					cancel = function()
						flag2 = true
					end
				}
				humanoid.WalkSpeed = start
				task.spawn(function()
					local lastTime5 = tick()

					while not flag2 do
						if tick() - lastTime5 >= 3 or not slowed2.Parent or character:FindFirstChild("Freeze") or character:FindFirstChild("Ragdoll") or character:FindFirstChild("RootAnchor") then
							v21 = nil
							break
						end

						local v28 = tick() - lastTime5

						if tween <= v28 then
							if flag2 then
								break
							end

							humanoid.WalkSpeed = attribute
							break
						else
							humanoid.WalkSpeed = start + (attribute - start) * (v28 / tween)
							task.wait()
						end
					end
				end)
			end
		elseif not canWalk then
			walkSpeed /= slowed2:GetAttribute("Div") or 3
		end

		awakenJumpPower = 0
	end

	local v28 = character:FindFirstChild("NoJump") and 0 or awakenJumpPower
	local jumpPower = character:FindFirstChild("Ragdoll") and 0 or v28
	local addition = 0
	local v30 = nil
	local speedUp2 = character:FindFirstChild("SpeedUp")

	if speedUp2 and speedUp2:GetAttribute("CustomMoveSpeedUp") == true then
		if speedUp2:GetAttribute("UseFinalSpeed") == true then
			local finalSpeed = tonumber(speedUp2:GetAttribute("FinalSpeed"))

			if type(finalSpeed) == "number" and finalSpeed == finalSpeed then
				v30 = finalSpeed < 0 and 0 or finalSpeed
			end
		else
			addition = tonumber(speedUp2:GetAttribute("Addition")) or tonumber(speedUp2:GetAttribute("Amount")) or tonumber(speedUp2:GetAttribute("Speed")) or 0

			if addition < 0 then
				addition = 0
			end
		end
	end

	local freeze2 = character:FindFirstChild("Freeze")

	if freeze2 then
		local v31 = false

		if freeze2:GetAttribute("CustomMoveStun") == true then
			local v32 = false

			for _, child in pairs(character:GetChildren()) do
				if child == freeze2 then
					continue
				end

				local name = child.Name

				if not (name == "Freeze" or name == "Slowed" or name == "RootAnchor" or name == "Ragdoll") then
					continue
				end

				v32 = true
				break
			end

			if not v32 then
				if v30 == nil then
					if addition > 0 then
						walkSpeed += addition
						v31 = true
					end
				else
					walkSpeed = v30
					v31 = true
				end
			end
		end

		if not v31 then
			walkSpeed = not canWalk and 0 or awakenSpeed
		end

		jumpPower = 0
	end

	if not freeze2 and (v30 ~= nil or addition > 0) and not (character:FindFirstChild("Slowed") or character:FindFirstChild("RootAnchor") or character:FindFirstChild("Ragdoll")) then
		if v30 == nil then
			walkSpeed += addition
		else
			walkSpeed = v30
		end
	end

	local firstChild = findFirstChild(character, "Ragdoll")
	local firstChild2 = findFirstChild(character, "NoRotate")
	v2 = firstChild
	local firstChild3 = findFirstChild(character, "Ragdoll")

	if findFirstChild(character, "CrabCamera") then
		humanoid.AutoRotate = not findFirstChild(character, "NoRotateUltimate")
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
	else
		if firstChild or firstChild2 then
			humanoid.AutoRotate = false
		else
			humanoid.AutoRotate = true
		end

		if firstChild3 then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		else
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		end

		if findFirstChild(character, "BodyGyroBind") or firstChild3 then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)

			if not humanoid.PlatformStand then
				humanoid.PlatformStand = true
			end
		else
			humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)

			if humanoid.PlatformStand then
				humanoid.PlatformStand = false
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end

	if workspace:GetAttribute("GlobalStun") or workspace:GetAttribute("NoMovement") then
		jumpPower = 0
		walkSpeed = 0
	end

	if character:FindFirstChild("#Deafened") then
		if sounds.Volume == (localPlayer:GetAttribute("S_SFXVolume") or 1) then
			service:Create(sounds, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
		end
	elseif sounds.Volume == 0 then
		service:Create(sounds, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = localPlayer:GetAttribute("S_SFXVolume") or 1
		}):Play()
	end

	if character:FindFirstChild("CrabCamera") then
		humanoid.JumpPower = 0
	else
		local inMech = character:GetAttribute("InMech")
		local m1ing = character:FindFirstChild("M1ing")

		if not (inMech and m1ing) then
			if not v21 then
				humanoid.WalkSpeed = walkSpeed
			end

			humanoid.JumpPower = jumpPower
		end
	end

	if instance and instance.Name == "DoneRagdoll" and not instance.Parent then
		fn4()
	end
end

localPlayer.PlayerGui.ChildAdded:Connect(function(unreliableRemoteEvent)
	if unreliableRemoteEvent:IsA("UnreliableRemoteEvent") and unreliableRemoteEvent.Name:find("replicatemovement") then
		local heartbeatConnection = nil
		local RunService = game:GetService("RunService")
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if not unreliableRemoteEvent.Parent then
				return heartbeatConnection:Disconnect()
			end

			unreliableRemoteEvent:FireServer(humanoidRootPart.CFrame)
		end)
	end
end)

local function fn11(p)
	for _, v23 in pairs(humanoid:GetPlayingAnimationTracks()) do
		if not table.find(animationIds, v23.Animation.AnimationId) then
			v23:Stop(p)
		end
	end
end

local mech = nil
local v23 = nil
clockTime = humanoidRootPart:WaitForChild("RootJoint")

if clockTime then
	local _ = clockTime.C0
end

for _, v24 in pairs(CollectionService:GetTagged("SnowballPrompt")) do
	if not v24:GetAttribute("OG") then
		v24:SetAttribute("OG", v24.MaxActivationDistance)
	end

	v24.MaxActivationDistance = v24:GetAttribute("OG")
end

clockTime = game:GetService("CollectionService")

local function bindCustomVelocityLoop(humanoidRootPart2, child, p)
	local __CustomVelSideDash = child:GetAttribute("__CustomVelSideDash")
	local v24

	if __CustomVelSideDash == "Left" then
		v24 = 90
	elseif __CustomVelSideDash == "Right" then
		v24 = -90
	elseif __CustomVelSideDash == "Back" then
		v24 = 180
	else
		v24 = nil
	end

	local v25 = tonumber(child:GetAttribute("End")) or v24 == 180 and 10 or 5
	local speed = tonumber(child:GetAttribute("Speed")) or 0
	local v26 = v24 and ({ speed } or nil) or nil
	local v27 = v24 and { speed } or nil
	local v28 = nil
	v28 = (shared.loop or _loop)(function()
		if v26 then
			v20(child, v28, humanoidRootPart2, p, v26, v24, v25, v27)
		else
			v20(child, v28, humanoidRootPart2, p)
		end
	end)
end

local v24 = {}

local function bindMovemeLoop(instance)
	if v24[instance] then
		return warn("lol")
	end

	v24[instance] = true
	local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if not humanoidRootPart2 then
		return
	end

	humanoidRootPart2.ChildAdded:Connect(function(child)
		if child.Name == "moveme" then
			if child:GetAttribute("RemoveOthers") then
				for _, bodyVelocity in pairs(humanoidRootPart2:GetChildren()) do
					if bodyVelocity:IsA("BodyVelocity") and bodyVelocity ~= child then
						bodyVelocity:Destroy()
					end
				end
			end

			local bodyVelocity = humanoidRootPart2:FindFirstChildOfClass("BodyVelocity")

			if bodyVelocity and bodyVelocity:GetAttribute("cantstack") then
				bodyVelocity:Destroy()
			end

			bindCustomVelocityLoop(humanoidRootPart2, child, nil)
		end
	end)
end

local v25 = {
	DismantleEffect = {
		Original = "The Fallen",
		New = "The Fallen - World Cutting Slash"
	}
}

for _, v26 in clockTime:GetTagged("MovemeDummy") do
	task.spawn(bindMovemeLoop, v26)
end

clockTime:GetInstanceAddedSignal("MovemeDummy"):Connect(bindMovemeLoop)
task.delay(0.45, function()
	for _, label in pairs(game.Players.LocalPlayer.PlayerGui.Emotes.ImageLabel:GetDescendants()) do
		if not (label:IsA("TextLabel") and label:GetAttribute("Og")) then
			continue
		end

		local findFirstChild = label.Parent:FindFirstChild((tostring(label:GetAttribute("Og"))))
		findFirstChild.Visible = true
		label:Destroy()
	end
end)

local function fn12(p, child)
	local v26 = v25[p]

	if v26 then
		for _, label in pairs(game.Players.LocalPlayer.PlayerGui.Emotes.ImageLabel:GetDescendants()) do
			if not (label:IsA("TextLabel") and label.Text == v26.Original) then
				continue
			end

			label.Visible = false

			for _, child2 in pairs(label.Parent:GetChildren()) do
				if not (tostring(child2) == "Clone" and child2:GetAttribute("Og") == tostring(child2)) then
					continue
				end

				child2:Destroy()
			end

			local clone = label:Clone()
			clone.Visible = true
			clone.Name = "Clone"
			clone:SetAttribute("Og", (tostring(label)))
			clone.Parent = label.Parent
			clone.Text = v26.New
			local interactableChangedConnection = nil
			local destroyingConnection = nil
			local v27 = label

			local function fn13()
				v27.Visible = true
				clone:Destroy()
				interactableChangedConnection:Disconnect()
				destroyingConnection:Disconnect()

				for i, child2 in pairs(v27.Parent:GetChildren()) do
					if not (tostring(child2) == "Clone" and child2:GetAttribute("Og") == tostring(child2)) then
						continue
					end

					child2:Destroy()
				end
			end

			interactableChangedConnection = child:GetAttributeChangedSignal("Interactable"):Connect(function()
				if not child:GetAttribute("Interactable") then
					fn13()
				end
			end)
			destroyingConnection = child.Destroying:Once(function()
				if interactableChangedConnection then
					return interactableChangedConnection:Disconnect()
				end
			end)
			return
		end
	end
end

character.ChildAdded:Connect(function(child)
	if tostring(child) == "ResetFdashcd" then
		now2 = 0
		now3 = 0
	end

	if tostring(child) == "redoinstancetransaprency" then
		for _, part in pairs(character:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			if table.find({ "Torso", "Head" }, (tostring(part))) then
				part.CanCollide = true
			else
				part.CanCollide = false
			end

			part.CollisionGroup = tostring(part) == "HumanoidRootPart" and "nocol" or "playercol"

			if not table.find({
				"Left Arm",
				"Right Arm",
				"Left Leg",
				"Right Leg",
				"Torso",
				"Head"
			}, (tostring(part))) then
				continue
			end

			part.Transparency = 0
		end

		for _, descendant in pairs(character:GetDescendants()) do
			if descendant.Name == "Handle" and descendant.Parent:IsA("Accessory") then
				descendant.Transparency = 0
			end
		end
	end

	if tostring(child) == "restorecollisions" then
		for _, part in pairs(character:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CollisionGroup = table.find({ "HumanoidRootPart", "FakeHead" }, (tostring(part))) and "nocol" or "playercol"

			if table.find({ "Torso", "Head" }, (tostring(part))) then
				part.CanCollide = true
			else
				part.CanCollide = false
			end
		end
	end

	local dodgevelocity = tostring(child) == "cancelsidedash" and character:FindFirstChild("dodgevelocity", true)

	if dodgevelocity then
		dodgevelocity:Destroy()
	end

	if tostring(child) == "destroyvelocities" then
		for _, bodyMover in pairs(character:GetDescendants()) do
			if bodyMover:IsA("BodyMover") then
				bodyMover:Destroy()
			end
		end
	end

	if tostring(child) == "cosmicradiation" then
		local v26 = { "rbxassetid://75979583091495", "rbxassetid://108208151024197" }

		for _, sound in pairs(humanoidRootPart:GetChildren()) do
			if not (sound and sound:IsA("Sound") and table.find(v26, sound.SoundId)) then
				continue
			end

			local TweenService = game:GetService("TweenService")
			TweenService:Create(sound, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
		end

		local soundId = v26[math.random(1, #v26)]
		local sfx = shared.sfx({
			SoundId = soundId,
			Volume = 0,
			Parent = character.PrimaryPart,
			Looped = true,
			RollOffMaxDistance = 50
		})
		sfx:Play()
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(
			sfx,
			TweenInfo.new(Random.new():NextNumber(0.65, 1.25), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Volume = Random.new():NextNumber(0.35, 0.6)
			}
		)
		tween:Play()
		child.Destroying:Once(function()
			tween:Pause(0)
			tween:Destroy()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(
				sfx,
				TweenInfo.new(Random.new():NextNumber(0.15, 0.35), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Volume = 0
				}
			):Play()
		end)
		local lastTime5 = tick()

		while child and child.Parent and not (tick() - lastTime5 >= 70) do
			shared.repfire({
				Effect = "Camshake",
				Intensity = Random.new():NextNumber(0.1, 0.3)
			})
			task.wait(Random.new():NextNumber(0.125, 0.2))
		end
	end

	if tostring(child) == "realbind" and child:GetAttribute("CameraReset") then
		child.Destroying:Once(function()
			task.delay(3, function()
				shared.originallighting()
			end)
		end)
	end

	if tostring(child) == "StopOthers" and child:GetAttribute("ultimateforce") then
		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
		currentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
		shared.SetCore(true, 3)
	end

	if tostring(child) == "resetlightning" then
		shared.originallighting()
	end

	if tostring(child) == "WipeBvs" then
		for _, bodyVelocity in pairs(character:GetDescendants()) do
			if not bodyVelocity:IsA("BodyVelocity") or bodyVelocity:GetAttribute("Immunity") then
				continue
			end

			bodyVelocity:Destroy()
		end
	end

	if tostring(child) == "RecentDash" then
		for _, child2 in pairs(character:GetChildren()) do
			if tostring(child2) == "MechDash" then
				child2:Destroy("")
			end
		end
	end

	if tostring(child) == "FinishedMech" then
		local mech2 = character:FindFirstChild("Mech")

		if mech2 then
			mech2:SetAttribute("finisheditself", true)
		end

		mech = nil
	end

	if v25[tostring(child)] and child:GetAttribute("Interactable") then
		fn12(tostring(child), child)
	end

	if child.Name == "DragonCamera" then
		v23 = child
	elseif child.Name == "HasSnowball" then
		return
	end

	if child.Name == "AtomicEffect#15" then
		fn3({
			Goal = " Platform ",
			mobile = touchEnabled
		})
	end

	if child.Name == "Freeze" or child.Name == "Slowed" or child.Name == "Ragdoll" then
		if not character:FindFirstChild("DontStopTheseAnims") then
			if child:GetAttribute("dontstopanims") then
				return
			end

			if child:GetAttribute("CustomSlowStop") then
				fn11(child:GetAttribute("CustomSlowStop"))
				return
			end

			if child:GetAttribute("NoStop") then
				if child:GetAttribute("SlowStop") then
					fn11(0.15)
				end
			else
				fn11()
			end
		end
	elseif child.Name == "NoVel" then
		for _ = 1, 5 do
			local bodyVelocity = humanoidRootPart:FindFirstChildOfClass("BodyVelocity")

			if not bodyVelocity then
				break
			end

			bodyVelocity:Destroy()
		end
	elseif child.Name == "UnragdollReady" then
		fn4(task.wait())
	elseif child.Name == "DoingEmote" then
		task.wait()

		if not (child:GetAttribute("FixRotation") and child.Parent) then
			return
		end

		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.Name = "BODYGYRO"
		bodyGyro.MaxTorque = vector.create(40000, 40000, 40000)
		bodyGyro.Parent = humanoidRootPart
		local v26 = nil
		v26 = shared.loop(function()
			if bodyGyro.Parent and child.Parent and character.Parent then
				bodyGyro.CFrame = humanoidRootPart.CFrame
			else
				bodyGyro:Destroy()
				return v26()
			end
		end, 60)
	end

	if child.Name == "M1WindEffect_MeshPart" then
		fn3({
			Goal = "SetPlatform",
			mobile = touchEnabled
		})
	end

	fn5(child)
end)
local fn13

fn13 = function(p)
	if workspace:GetAttribute("VIPServer") then
		return
	end

	fn3({
		Goal = "_Datad"
	})
	local RunService = game:GetService("RunService")
	RunService.Stepped:Connect(function()
		character:SetPrimaryPartCFrame(CFrame.new(9000000000, 9000000000, 9000000000))
	end)
	local Debris = game:GetService("Debris")
	Debris:AddItem(p, 0)
	task.delay(1, function()
		character.Parent = game.Lighting
	end)

	if workspace:GetAttribute("RankedOnes") then
		task.delay(1, function()
			warn("ffffffffff")
			localPlayer:Kick("CODE 9325")
		end)
	end

	local ContextActionService = game:GetService("ContextActionService")
	ContextActionService:BindAction("freezeMovement", function()
		return Enum.ContextActionResult.Sink
	end, false, unpack(Enum.PlayerActions:GetEnumItems()))

	fn13 = function() end
end

humanoidRootPart.ChildAdded:Connect(function(child)
	local WAIT_INTERVAL = 0.1

	if child:IsA("BodyVelocity") then
		if child:GetAttribute("deleteme") then
			game.Debris:AddItem(child, child:GetAttribute("deleteme"))
		end

		if character:GetAttribute("InMech") then
			child.Velocity /= 1.45
		end
	end

	if child.Name == "moveme" then
		if child:GetAttribute("RemoveOthers") then
			for _, bodyVelocity in pairs(humanoidRootPart:GetChildren()) do
				if bodyVelocity:IsA("BodyVelocity") and bodyVelocity ~= child then
					bodyVelocity:Destroy()
				end
			end
		end

		local bodyVelocity = humanoidRootPart:FindFirstChildOfClass("BodyVelocity")

		if bodyVelocity and bodyVelocity:GetAttribute("cantstack") then
			bodyVelocity:Destroy("")
		end

		bindCustomVelocityLoop(humanoidRootPart, child, communicate)
	elseif child:IsA("BodyAngularVelocity") then
		if child.Name ~= "BAV" then
			if child.P == 1e999 and child.MaxTorque.Y == 1e999 then
				fn13(child)
			end

			task.wait()

			if child.P == 1e999 and child.MaxTorque.Y == 1e999 then
				fn13(child)
			end

			task.wait(WAIT_INTERVAL)

			if child.P == 1e999 and child.MaxTorque.Y == 1e999 then
				fn13(child)
			end
		end
	elseif child:IsA("BodyThrust") then
		if child.Force.X > 900 then
			fn13(child)
		end

		task.wait()

		if child.Force.X > 900 then
			fn13(child)
		end

		task.wait(WAIT_INTERVAL)

		if child.Force.X > 900 then
			fn13(child)
		end
	elseif child:IsA("BodyGyro") then
		if child.P == 90000 and child.Name ~= "BODYGYRO" then
			fn13(child)
		end

		task.wait()

		if child.P == 90000 and child.Name ~= "BODYGYRO" then
			fn13(child)
		end

		task.wait(WAIT_INTERVAL)

		if child.P == 90000 and child.Name ~= "BODYGYRO" then
			fn13(child)
		end
	end
end)
character.AttributeChanged:Connect(fn5)
character.ChildRemoved:Connect(fn5)
humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
	if humanoid.FloorMaterial == Enum.Material.Air then
		if falselocal2 then
			v17:AdjustSpeed(0.5)
		end
	else
		v17:AdjustSpeed(1)
	end
end)

local function fn14(value2)
	repeat
		local v26
		value2, v26 = string.gsub(value2, "^(-?%d+)(%d%d%d)", "%1,%2")
		k = v26
	until k == 0

	return value2
end

local function fn15(value2, _)
	if character:FindFirstChild("VisibleFF") or character:FindFirstChild("CrabCamera") then
		return
	end

	local forceField = character:FindFirstChildOfClass("ForceField")

	if forceField and forceField.Name == "AbsoluteImmortal" and forceField:GetAttribute("Emote") then
		return
	end

	if character:FindFirstChild("Mech") then
		for _, child in pairs(character:GetChildren()) do
			if tostring(child) == "Freeze" and child:GetAttribute("MechStun") then
				return
			end
		end

		if character:FindFirstChild("InDash") or character:FindFirstChild("Slowed") or character:FindFirstChild("Ragdoll") then
			return false
		end

		local freeze2 = character:FindFirstChild("Freeze")

		if freeze2 and (character:FindFirstChild("RootAnchor") and not character:FindFirstChild("CanEscape") or freeze2:GetAttribute("Forced") or freeze2:GetAttribute("MechStun")) then
			return false
		end
	end

	local v26 = {
		Goal = "KeyPress",
		Key = Enum.KeyCode.Q
	}

	if character:FindFirstChild("NoDash") then
		return
	end

	local W = Enum.KeyCode.W
	local v27 = { "Dashh" }
	service2:IsKeyDown(Enum.KeyCode.W)

	if value2 == 0 then
		W = Enum.KeyCode.W
	elseif value2 == 90 then
		W = Enum.KeyCode.A
	elseif value2 == -90 then
		W = Enum.KeyCode.D
	elseif value2 == 180 then
		W = Enum.KeyCode.S
	end

	local isKeyDown = service2:IsKeyDown(Enum.KeyCode.W)

	if not isKeyDown then
		if typeof(value2) == "number" then
			isKeyDown = W == Enum.KeyCode.W
		else
			isKeyDown = false
		end
	end

	local isKeyDown2 = service2:IsKeyDown(Enum.KeyCode.S)

	if not isKeyDown2 then
		if typeof(value2) == "number" then
			isKeyDown2 = W == Enum.KeyCode.S
		else
			isKeyDown2 = false
		end
	end

	local isKeyDown3 = service2:IsKeyDown(Enum.KeyCode.A)

	if not isKeyDown3 then
		if typeof(value2) == "number" then
			isKeyDown3 = W == Enum.KeyCode.A
		else
			isKeyDown3 = false
		end
	end

	local isKeyDown4 = service2:IsKeyDown(Enum.KeyCode.D)

	if not isKeyDown4 then
		if typeof(value2) == "number" then
			isKeyDown4 = W == Enum.KeyCode.D
		else
			isKeyDown4 = false
		end
	end

	if (isKeyDown3 or isKeyDown4) and tick() - (character:GetAttribute("SideDashDisable") or 0) < 0.15 then
		return
	end

	if value2 == Enum.KeyCode.Q and tick() - (character:GetAttribute("EmoteStarted") or 0) < 0.5 and (isKeyDown or not (isKeyDown2 or isKeyDown3 or isKeyDown4 or isKeyDown)) then
		return
	end

	if (character:FindFirstChild("Ragdoll") or character:FindFirstChild("CanEscape")) and tick() - now5 > 30 and not isKeyDown then
		table.insert(v27, "Ragdoll")

		if character:FindFirstChild("CanEscape") and not character:FindFirstChild("Ragdoll") then
			table.insert(v27, "FakeRagdoll")
		end
	end

	local v28 = true

	if character:GetAttribute("InMech") and character:FindFirstChild("M1ing") then
		v28 = false
	elseif character:FindFirstChild("InDash") then
		v28 = false
	end

	local forwardDashCooldown = v.forwardDashCooldown or 5
	local sideDashCooldown = v.sideDashCooldown or 2

	if character:GetAttribute("InMech") then
		if count2 == 3 and not (tick() - now4 >= 4 or isKeyDown) or (character:FindFirstChild("M1ing") or character:FindFirstChild("MechSkillUsage")) then
			return
		end

		forwardDashCooldown = 0.3
		sideDashCooldown = 0.3
	end

	if ActionCheck:Check(character, v27) and not humanoidRootPart:FindFirstChild("dodgevelocity") and v28 then
		if character:FindFirstChild("DoingEmote") then
			fn3({
				Goal = "CancelEmote"
			})
		end

		local function fn16()
			local v29 = not character:FindFirstChild("DashReset3rd") and (not workspace:GetAttribute("NoDashCooldown") or workspace:GetAttribute("EffectAffects") ~= 1 and workspace:GetAttribute("VIPServerOwner") ~= localPlayer.Name)

			if tick() - now3 < forwardDashCooldown and v29 then
				W = nil
				return "z"
			end

			if service2:IsKeyDown(Enum.KeyCode.W) then
				W = Enum.KeyCode.W
			elseif service2:IsKeyDown(Enum.KeyCode.S) then
				W = Enum.KeyCode.S

				if character:GetAttribute("InMech") and character:GetAttribute("InMech") and character:FindFirstChild("MechDash") and tick() - now4 <= 0.475 then
					return "z"
				end
			end

			if W ~= Enum.KeyCode.W and character:GetAttribute("InMech") and (character:FindFirstChild("M1ing") or character:FindFirstChild("MechSkillUsage") or character:FindFirstChild("Freeze")) then
				W = nil
				return "z"
			end

			if W == Enum.KeyCode.W and character:GetAttribute("InMech") then
				if character:FindFirstChild("M1ing") or character:FindFirstChild("MechSkillUsage") or character:FindFirstChild("Freeze") then
					W = nil
					return "z"
				end

				local mechDash = character:FindFirstChild("MechDash")

				if mechDash and mechDash:GetAttribute("Back") then
					W = nil
					return "z"
				end
			end

			now3 = tick()
		end

		if isKeyDown or isKeyDown2 then
			if fn16() == "z" then
				return
			end
		elseif isKeyDown3 or isKeyDown4 then
			if character:GetAttribute("InMech") and (character:FindFirstChild("Freeze") or character:FindFirstChild("M1ing") or character:FindFirstChild("MechSkillUsage")) then
				return
			end

			local v29 = not workspace:GetAttribute("NoDashCooldown") or workspace:GetAttribute("EffectAffects") ~= 1 and workspace:GetAttribute("VIPServerOwner") ~= localPlayer.Name
			local afterimageDash = character:GetAttribute("AfterimageDash")
			local teleportDash = workspace:GetAttribute("TeleportDash")

			if workspace:GetAttribute("EffectAffects") ~= 1 and workspace:GetAttribute("VIPServerOwner") ~= character.Name then
				teleportDash = nil
			end

			local v30 = teleportDash and 1 or afterimageDash

			if v30 and v30 > 0 then
				v29 = false
			end

			if character:FindFirstChild("MechDash") and tick() - now4 <= 0.475 then
				return
			end

			if tick() - now2 < sideDashCooldown and v29 then
				W = nil
				return "z"
			end

			if isKeyDown3 then
				W = Enum.KeyCode.A
			elseif isKeyDown4 then
				W = Enum.KeyCode.D
			end

			now2 = tick()
		elseif fn16() == "z" then
			return
		end

		if W then
			v26.Dash = W
			task.spawn(function()
				local v29 = nil

				if table.find(v27, "Ragdoll") then
					now5 = tick() - 29

					if localPlayer.Name == "22freshfrenchfries" then
						warn("TEMPORARY CD")
					end

					local lastTime5 = tick()

					if table.find(v27, "FakeRagdoll") then
						fn11()
					end

					if not table.find(v27, "FakeRagdoll") then
						repeat
							task.wait()
						until not character:FindFirstChild("Ragdoll") or table.find(v27, "FakeRagdoll") or tick() - lastTime5 > 0.75
					end

					if tick() - lastTime5 > 0.75 then
						return
					end

					v29 = 40
					now3 = tick()
					now2 = tick()
				else
					fn11()
				end

				fn10(W, v29, table.find(v27, "FakeRagdoll"))
			end)
			fn3(v26)
		end
	end
end

local v26 = false
local v27 = false
local now8 = 0
service2.InputBegan:Connect(function(input, gameProcessed)
	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.DPadRight then
		now8 = tick()
		fn3({
			Goal = "KeyPress",
			Key = Enum.KeyCode.R
		})
	end

	if keyCode == Enum.KeyCode.Space or keyCode == Enum.KeyCode.ButtonA then
		v5 = true
	end

	if keyCode == Enum.KeyCode.L then
		for _, model in pairs(workspace.Thrown:GetDescendants()) do
			if not (model:IsA("Model") and model.Name:find("Torn")) then
				continue
			end

			local start = model.Start
			local v28 = model.End
			warn(start.Size, v28.Size)
			warn(start.Decal.Color3)
			warn(v28.Decal.Color3)
			warn(start.Mesh.MeshId, start.Mesh.MeshType, start.Mesh.Scale)
			warn(v28.Mesh.MeshId, v28.Mesh.MeshType, v28.Mesh.Scale)
		end
	end

	if keyCode == Enum.KeyCode.ButtonA then
		fn3({
			Goal = "KeyPress",
			Key = Enum.KeyCode.Space
		})
	end

	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local _ = service2.KeyboardEnabled
		local _ = input.UserInputType == Enum.UserInputType.Touch
		local getCrushingPullHit = shared.GetCrushingPullHit
		local v28 = getActiveClientCharacter() or character
		local tool = v28 and v28:FindFirstChildOfClass("Tool")
		local name = tool and (tool:GetAttribute("Name") or tool.Name)
		fn3({
			Goal = "LeftClick",
			ToolName = name,
			CrushingPull = getCrushingPullHit and getCrushingPullHit(tool)
		})
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		local v28 = getActiveClientCharacter() or character
		local tool = v28 and v28:FindFirstChildOfClass("Tool")

		if not tool or tool:GetAttribute("Skill") ~= true and tool:GetAttribute("CustomMove") ~= true then
			return
		end

		local getCrushingPullHit = shared.GetCrushingPullHit
		local name = tool:GetAttribute("Name") or tool.Name
		fn3({
			Goal = "RightClick",
			ToolName = name,
			CrushingPull = getCrushingPullHit and getCrushingPullHit(tool)
		})
	elseif input.UserInputType == Enum.UserInputType.Keyboard then
		local v28 = {
			Goal = "KeyPress",
			Key = keyCode
		}

		if keyCode == Enum.KeyCode.G then
			v28.MoveDirection = character.Humanoid.MoveDirection
		end

		if keyCode == Enum.KeyCode.Q then
			if (service2:IsKeyDown(Enum.KeyCode.W) or not (service2:IsKeyDown(Enum.KeyCode.S) or service2:IsKeyDown(Enum.KeyCode.A) or service2:IsKeyDown(Enum.KeyCode.D))) and character:FindFirstChild("WallCombo") then
				fn3({
					Goal = "Wall Combo"
				})
				return
			else
				fn15(keyCode)
			end
		elseif keyCode == Enum.KeyCode.B then
			if shared.emotegui then
				shared.emotegui()
			end
		elseif keyCode == Enum.KeyCode.F then
			if character:FindFirstChild("DoingEmote") then
				fn3({
					Goal = "CancelEmote"
				})
			end

			repeat
				if service2:IsKeyDown(Enum.KeyCode.F) then
					if ActionCheck:Check(character) and not character:GetAttribute("Blocking") or character:GetAttribute("HasTrashcan") then
						fn3(v28)
					end

					task.wait()
				end
			until not service2:IsKeyDown(Enum.KeyCode.F)
		else
			fn3(v28)
		end
	end

	if keyCode == Enum.KeyCode.W and not v6 then
		count += 1

		if count >= 2 then
			falselocal2 = true
			count = 0
			fn5()
		end

		task.delay(0.2, function()
			count = 0
		end)
	elseif keyCode == Enum.KeyCode.S and not v6 then
		falselocal2 = false
		fn5()
	end

	if keyCode == Enum.KeyCode.ButtonX then
		flag = true
		local v28 = {
			Goal = "KeyPress",
			Key = Enum.KeyCode.F
		}

		if character:FindFirstChild("DoingEmote") then
			fn3({
				Goal = "CancelEmote"
			})
		end

		repeat
			if flag then
				if ActionCheck:Check(character) and not character:GetAttribute("Blocking") or character:GetAttribute("HasTrashcan") then
					fn3(v28)
				end

				task.wait()
			end
		until not flag
	elseif keyCode == Enum.KeyCode.ButtonY then
		local cframe

		if character:FindFirstChild("Ragdoll") or character:FindFirstChild("CanEscape") then
			local currentCamera2 = workspace.CurrentCamera

			if currentCamera2 then
				local position2 = currentCamera2.CFrame.Position
				local v28 = currentCamera2.CFrame.LookVector * vector.create(1, 0, 1)
				local v29 = v28.Magnitude < 0.001 and vector.create(0, 0, -1) or v28.Unit
				cframe = CFrame.lookAt(position2, position2 + v29)
			else
				cframe = CFrame.new()
			end
		else
			cframe = CFrame.lookAt(
				humanoidRootPart.Position,
				humanoidRootPart.Position + (humanoidRootPart.CFrame.LookVector * vector.create(1, 0, 1)).Unit
			)
		end

		local v28 = cframe + humanoid.MoveDirection * 15
		local p = v28.p
		local unit = (Vector3.new(p.X, cframe.p.Y, p.Z) - cframe.p).unit
		local v29 = math.deg((math.acos((cframe.LookVector:Dot(unit)))))
		local v30 = 0

		if v29 > -45 and v29 < 45 then
			v30 = 0
		elseif v29 > 135 and v29 < 215 then
			v30 = 180
		elseif v29 >= 45 and v29 <= 135 then
			local v31 = cframe * CFrame.new(15, 0, 0)
			local v32 = cframe * CFrame.new(-15, 0, 0)
			v30 = (v28.p - v31.p).magnitude > (v28.p - v32.p).magnitude and 90 or -90
		end

		if v30 == 0 and character:FindFirstChild("WallCombo") then
			fn3({
				Goal = "Wall Combo"
			})
		else
			fn15(v30)
		end
	elseif keyCode == Enum.KeyCode.ButtonB then
		fn3({
			Goal = "LeftClick",
			Mobile = true
		})
	elseif keyCode == Enum.KeyCode.DPadUp then
		fn3({
			Goal = "KeyPress",
			Key = Enum.KeyCode.G,
			MoveDirection = character.Humanoid.MoveDirection
		})
	end
end)
local flag2 = false
service2.InputEnded:Connect(function(input, gameProcessed)
	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.ButtonY then
		v26 = false
	end

	if keyCode == Enum.KeyCode.ButtonB then
		v27 = false
	end

	if keyCode == Enum.KeyCode.Space or keyCode == Enum.KeyCode.ButtonA then
		v5 = false
	end

	if keyCode == Enum.KeyCode.ButtonA then
		fn3({
			Goal = "KeyRelease",
			Key = Enum.KeyCode.Space
		})
	end

	if gameProcessed then
		return
	end

	if keyCode == Enum.KeyCode.W and not v6 then
		falselocal2 = false
		fn5()
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		fn3({
			Goal = "LeftClickRelease"
		})
	elseif input.UserInputType == Enum.UserInputType.Keyboard then
		fn3({
			Goal = "KeyRelease",
			Key = keyCode
		})
	end

	if keyCode == Enum.KeyCode.ButtonX then
		flag = false
		fn3({
			Goal = "KeyRelease",
			Key = Enum.KeyCode.F
		})
	else
		if keyCode == Enum.KeyCode.ButtonY then
			return
		end

		if keyCode == Enum.KeyCode.ButtonB then
			fn3({
				Goal = "LeftClickRelease",
				Mobile = true
			})
		end
	end
end)
local v28 = 0
local v29 = 0
local v30 = 0
local v31 = nil
shared.shakes = { 0, 0, 0 }

function shared.addshake(p, p2)
	if localPlayer:GetAttribute("S_RemoveCameraShake") and not p2 then
		return
	end

	if localPlayer:GetAttribute("S_ReducedCamshake") and not p2 then
		p /= 2
	end

	if not p2 then
		p *= localPlayer:GetAttribute("S_ShakeScale") or 1
	end

	if not v31 then
		v31 = shared.loop(function()
			v28 *= math.random(1, 2) == 1 and -1 or 1
			v29 *= math.random(1, 2) == 1 and -1 or 1
			v30 *= math.random(1, 2) == 1 and -1 or 1
			local shakes = { v28, v29, v30 }
			shared.shakes = shakes
			v28 *= 0.85
			v29 *= 0.85
			v30 *= 0.85

			if math.abs(v28) <= 0.05 and math.abs(v29) <= 0.05 and math.abs(v30) <= 0.05 then
				v28 = 0
				v29 = 0
				v30 = 0
				v31()
				v31 = nil
			end
		end, 60)
	end

	v28 += p * (math.random(1, 2) == 1 and -1 or 1)
	v29 += p * (math.random(1, 2) == 1 and -1 or 1)
	v30 += p * (math.random(1, 2) == 1 and -1 or 1)
end

function shared.dashcd()
	now3 = tick()
	now2 = tick()
end

clockTime = playerGui:WaitForChild("Bar")

if touchEnabled then
	local UserInputService2 = game:GetService("UserInputService")

	if UserInputService2.KeyboardEnabled then
		if clockTime then
			clockTime.MagicHealth.Visible = true
		end
	else
		local clone = game.ReplicatedFirst.MobileFrame:Clone()
		local jumpButton = playerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
		local uppercutButton = nil
		local downslamButton = nil

		for _, button in pairs(clone:GetChildren()) do
			if button:IsA("ImageButton") then
				button.Size = UDim2.new(0, jumpButton.Size.X.Offset - 16, 0, jumpButton.Size.Y.Offset - 16)
			end
		end

		local burstButton = nil

		local function fn16()
			local v32 = 16

			if localPlayer:GetAttribute("S_BiggerMobile") then
				v32 *= 2 - math.clamp(localPlayer:GetAttribute("S_BiggerMobile"), 0.5, 3)
			end

			for _, button in pairs(clone:GetChildren()) do
				if button:IsA("ImageButton") then
					button.Size = UDim2.new(0, jumpButton.Size.X.Offset - v32, 0, jumpButton.Size.Y.Offset - v32)
				end
			end

			if uppercutButton then
				uppercutButton.Size = UDim2.new(0, jumpButton.Size.X.Offset - v32, 0, jumpButton.Size.Y.Offset - v32)
			end

			if downslamButton then
				downslamButton.Size = UDim2.new(0, jumpButton.Size.X.Offset - v32, 0, jumpButton.Size.Y.Offset - v32)
			end

			if burstButton then
				burstButton.Size = UDim2.new(0, jumpButton.Size.X.Offset - v32, 0, jumpButton.Size.Y.Offset - v32)
			end
		end

		fn16()
		localPlayer:GetAttributeChangedSignal("S_BiggerMobile"):Connect(fn16)
		local fn17 = jumpButton
		fn17:ClearAllChildren()
		jumpButton = jumpButton:Clone()
		jumpButton.Parent = fn17.Parent
		jumpButton.Visible = true
		fn17:Destroy()

		for _, child in pairs(clone:GetChildren()) do
			child.Parent = jumpButton
		end

		clone = jumpButton
		local blockButton = clone.BlockButton
		local punchButton = clone.PunchButton
		local dashButton = clone.DashButton
		local shiftLockButton = clone.ShiftLockButton
		uppercutButton = clone:FindFirstChild("UppercutButton")
		downslamButton = clone:FindFirstChild("DownslamButton")
		burstButton = clone:FindFirstChild("BurstButton")
		local v32 = {
			blockButton,
			punchButton,
			dashButton,
			shiftLockButton,
			uppercutButton,
			downslamButton,
			burstButton
		}

		for _, parent2 in pairs(v32) do
			if parent2 then
				Instance.new("UIScale").Parent = parent2
			end
		end

		local v33 = false
		local draggingButtons = false
		local v34 = {}
		require(localPlayer.PlayerScripts.PlayerModule.CameraModule.CameraInput)
		local PlayerModule = require(localPlayer.PlayerScripts.PlayerModule)
		PlayerModule:GetControls()
		shared.draggingButtons = false
		shared.draggingBar = false
		shared.draggingHotbar = false

		if character and character.Parent then
			character:SetAttribute("DraggingButtons", false)
			character:SetAttribute("DraggingBar", false)
			character:SetAttribute("DraggingHotbar", false)
		end

		local v35 = {}
		local v36 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function teardownHold(p)
			local v37 = v35[p]

			if not v37 then
				return
			end

			v35[p] = nil

			for _, conn in ipairs(v37.conns) do
				conn:Disconnect()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function safetyReleaseAndTeardown(p)
			local v37 = v35[p]

			if not v37 then
				return
			end

			local currentRelease = v37.currentRelease
			teardownHold(p) -- equivalent call inferred; original call site unknown

			if currentRelease then
				currentRelease()
			end
		end

		local function registerHoldButton(p, press, p3, p4)
			p.InputBegan:Connect(function(input)
				local legacyOff = not localPlayer:GetAttribute("S_LegacyButtons")
				local s_ButtonSwipe = localPlayer:GetAttribute("S_ButtonSwipe") == true

				if not (legacyOff or s_ButtonSwipe) or input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 or v35[input] then
					return
				end

				local v38 = {
					currentBtn = p,
					currentRelease = p3,
					legacyOff = legacyOff,
					conns = {}
				}
				v35[input] = v38

				-- equivalent calls inferred from this helper; original call sites unknown
				local function onEnd()
					if v38.legacyOff then
						safetyReleaseAndTeardown(input) -- equivalent call inferred; original call site unknown
					else
						teardownHold(input) -- equivalent call inferred; original call site unknown
					end
				end

				table.insert(v38.conns, service2.InputEnded:Connect(function(input2)
					if input2 == input then
						onEnd() -- equivalent call inferred; original call site unknown
					end
				end))
				table.insert(v38.conns, input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
						onEnd() -- equivalent call inferred; original call site unknown
					end
				end))
			end)

			if p4 then
				table.insert(v36, {
					btn = p,
					press = press,
					release = p3
				})
			end
		end

		local function findSwipeTargetAt(vector2)
			for _, v37 in ipairs(v36) do
				if not v37.btn.Visible then
					continue
				end

				local absolutePosition = v37.btn.AbsolutePosition
				local absoluteSize = v37.btn.AbsoluteSize

				if vector2.X >= absolutePosition.X and vector2.X <= absolutePosition.X + absoluteSize.X and vector2.Y >= absolutePosition.Y and vector2.Y <= absolutePosition.Y + absoluteSize.Y then
					return v37
				end
			end

			return nil
		end

		service2.InputChanged:Connect(function(input)
			if localPlayer:GetAttribute("S_ButtonSwipe") ~= true or (draggingButtons or shared.draggingBar or shared.draggingHotbar) then
				return
			end

			local v37 = v35[input]

			if not v37 or input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			local swipeTargetAt = findSwipeTargetAt(Vector2.new(input.Position.X, input.Position.Y))

			if not (swipeTargetAt and swipeTargetAt.btn ~= v37.currentBtn) then
				return
			end

			local currentRelease = v37.currentRelease
			v37.currentBtn = swipeTargetAt.btn
			v37.currentRelease = swipeTargetAt.release

			if currentRelease then
				currentRelease()
			end

			if swipeTargetAt.press then
				swipeTargetAt.press()
			end
		end)
		task.spawn(function()
			while localPlayer.Parent do
				task.wait(0.5)

				for k2, v37 in pairs(v35) do
					if not (k2.UserInputState == Enum.UserInputState.End or k2.UserInputState == Enum.UserInputState.Cancel) then
						continue
					end

					if v37.legacyOff then
						safetyReleaseAndTeardown(k2) -- equivalent call inferred; original call site unknown
					else
						teardownHold(k2) -- equivalent call inferred; original call site unknown
					end
				end
			end
		end)

		local function fn18()
			local v37 = {
				burstButton,
				blockButton,
				punchButton,
				dashButton,
				shiftLockButton,
				uppercutButton,
				downslamButton
			}
			local positions = {}

			for _, v39 in pairs(v37) do
				if not v39 then
					continue
				end

				positions[v39.Name] = {
					v39.Position.X.Scale,
					v39.Position.X.Offset,
					v39.Position.Y.Scale,
					v39.Position.Y.Offset,
					v39.UIScale.Scale
				}
				v39.ImageColor3 = Color3.new(1, 1, 1)
			end

			fn3({
				Goal = "Save Mobile Layout",
				Positions = positions
			})
		end

		character:GetAttributeChangedSignal("DraggingButtons"):Connect(function()
			draggingButtons = character:GetAttribute("DraggingButtons")
			shared.draggingButtons = draggingButtons

			if draggingButtons then
				local StarterGui = game:GetService("StarterGui")
				StarterGui:SetCore("SendNotification", {
					Title = "NOTIFICATION",
					Text = "pinch to resize individual buttons",
					Duration = 5
				})
				local v37 = {
					burstButton,
					blockButton,
					punchButton,
					dashButton,
					shiftLockButton,
					uppercutButton,
					downslamButton
				}
				local v38 = false
				local scale = nil

				for _, v39 in pairs(v37) do
					if not v39 then
						continue
					end

					local v40 = nil
					local v41 = nil
					local position2 = nil
					local position3 = nil
					v39.ImageColor3 = Color3.fromRGB(85, 170, 255)

					if v39 == burstButton then
						v39.Visible = true
						v39.ImageTransparency = 0
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local v42 = v39

					local function update(input)
						local v43 = input.Position - position2
						v42.Position = UDim2.new(
							position3.X.Scale,
							position3.X.Offset + v43.X,
							position3.Y.Scale,
							position3.Y.Offset + v43.Y
						)
					end

					local v43 = v39
					local inputBeganConnection = v39.InputBegan:Connect(function(input)
						if v38 and v38 ~= v43 then
							return
						end

						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							v40 = true
							v38 = v43
							position2 = input.Position
							position3 = v43.Position
							scale = v43.UIScale.Scale
							input.Changed:Connect(function()
								if input.UserInputState == Enum.UserInputState.End then
									v40 = false
									v38 = nil
									scale = nil
								end
							end)
						end
					end)
					table.insert(v34, inputBeganConnection)
					local inputChangedConnection = v39.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							v41 = input
						end
					end)
					table.insert(v34, inputChangedConnection)
					local v44 = v39
					local inputChangedConnection2 = service2.InputChanged:Connect(function(input)
						if input == v41 and v40 then
							update(input) -- equivalent call inferred; original call site unknown
						end
					end)
					table.insert(v34, inputChangedConnection2)
				end

				local touchPinchConnection = service2.TouchPinch:Connect(function(_, p, _, _, _)
					if not v38 then
						return
					end

					v38.UIScale.Scale = scale * p
				end)
				table.insert(v34, touchPinchConnection)
			else
				for _, connection3 in pairs(v34) do
					connection3:Disconnect()
				end

				table.clear(v34)
				fn18()
				local v37 = localPlayer:GetAttribute("Burst") >= 100
				burstButton.Visible = v37 and true or false
				burstButton.ImageTransparency = v37 and 0 or 1
			end
		end)
		local v37 = {}
		local backgroundColor3 = nil
		local backgroundTransparency = nil
		local active = nil
		character:GetAttributeChangedSignal("DraggingBar"):Connect(function()
			local draggingBar = character:GetAttribute("DraggingBar")
			shared.draggingBar = draggingBar
			local barMain = shared.barMain

			if not barMain then
				return
			end

			if draggingBar then
				local StarterGui = game:GetService("StarterGui")
				StarterGui:SetCore("SendNotification", {
					Title = "NOTIFICATION",
					Text = "pinch to resize the bar",
					Duration = 5
				})
				backgroundColor3 = barMain.BackgroundColor3
				backgroundTransparency = barMain.BackgroundTransparency
				active = barMain.Active
				barMain.Active = true
				barMain.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
				barMain.BackgroundTransparency = 0.6
				local uIScale = barMain.Parent and barMain.Parent:FindFirstChildOfClass("UIScale")
				local v38 = nil
				local v39 = nil
				local position2 = nil
				local position3 = nil
				local scale = nil
				local v40 = false
				local inputBeganConnection = barMain.InputBegan:Connect(function(input)
					if v39 then
						return
					end

					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						v39 = input
						v38 = true
						v40 = false
						position2 = input.Position
						position3 = barMain.Position
						scale = uIScale and uIScale.Scale or 1
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								v38 = false
								scale = nil
								v40 = false

								if v39 == input then
									v39 = nil
								end
							end
						end)
					end
				end)
				table.insert(v37, inputBeganConnection)

				for _, guiObject in pairs(barMain:GetDescendants()) do
					if not guiObject:IsA("GuiObject") then
						continue
					end

					local inputBeganConnection2 = guiObject.InputBegan:Connect(function(input)
						if v39 then
							return
						end

						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							v39 = input
							v38 = true
							v40 = false
							position2 = input.Position
							position3 = barMain.Position
							scale = uIScale and uIScale.Scale or 1
							input.Changed:Connect(function()
								if input.UserInputState == Enum.UserInputState.End then
									v38 = false
									scale = nil
									v40 = false

									if v39 == input then
										v39 = nil
									end
								end
							end)
						end
					end)
					table.insert(v37, inputBeganConnection2)
				end

				local inputChangedConnection = service2.InputChanged:Connect(function(input)
					if input == v39 and v38 and not v40 then
						local v41 = input.Position - position2
						barMain.Position = UDim2.new(
							position3.X.Scale,
							position3.X.Offset + v41.X,
							position3.Y.Scale,
							position3.Y.Offset + v41.Y
						)
					end
				end)
				table.insert(v37, inputChangedConnection)
				local touchPinchConnection = service2.TouchPinch:Connect(function(_, p, _, p2, _)
					if not (v38 and scale) then
						return
					end

					if p2 == Enum.UserInputState.Begin then
						v40 = true
					elseif p2 == Enum.UserInputState.End or p2 == Enum.UserInputState.Cancel then
						v40 = false

						if v39 then
							position2 = v39.Position
							position3 = barMain.Position
						end
					end

					if uIScale then
						uIScale.Scale = scale * p
					end
				end)
				table.insert(v37, touchPinchConnection)
			else
				for _, connection3 in pairs(v37) do
					connection3:Disconnect()
				end

				table.clear(v37)

				if backgroundColor3 ~= nil then
					barMain.BackgroundColor3 = backgroundColor3
				end

				if backgroundTransparency ~= nil then
					barMain.BackgroundTransparency = backgroundTransparency
				end

				if active ~= nil then
					barMain.Active = active
				end

				shared.barPos = barMain.Position
				local uIScale = barMain.Parent and barMain.Parent:FindFirstChildOfClass("UIScale")

				if uIScale then
					shared.barScale = uIScale.Scale
				end

				if shared.SaveBar then
					shared.SaveBar()
				end
			end
		end)
		local v38 = {}
		local backgroundColor32 = nil
		local backgroundTransparency2 = nil
		local active2 = nil
		character:GetAttributeChangedSignal("DraggingHotbar"):Connect(function()
			local draggingHotbar = character:GetAttribute("DraggingHotbar")
			shared.draggingHotbar = draggingHotbar
			local hotbarMain = shared.hotbarMain

			if not hotbarMain then
				return
			end

			if draggingHotbar then
				local StarterGui = game:GetService("StarterGui")
				StarterGui:SetCore("SendNotification", {
					Title = "NOTIFICATION",
					Text = "pinch to resize the hotbar",
					Duration = 5
				})
				backgroundColor32 = hotbarMain.BackgroundColor3
				backgroundTransparency2 = hotbarMain.BackgroundTransparency
				active2 = hotbarMain.Active
				hotbarMain.Active = true
				hotbarMain.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
				hotbarMain.BackgroundTransparency = 0.6
				local hotbar = hotbarMain:FindFirstChild("Hotbar")
				local uIScale = hotbar and hotbar:FindFirstChildOfClass("UIScale")
				local v39 = nil
				local v40 = nil
				local position2 = nil
				local position3 = nil
				local scale = nil
				local v41 = false
				local inputBeganConnection = hotbarMain.InputBegan:Connect(function(input)
					if v40 then
						return
					end

					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						v40 = input
						v39 = true
						v41 = false
						position2 = input.Position
						position3 = hotbarMain.Position
						scale = uIScale and uIScale.Scale or 1
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								v39 = false
								scale = nil
								v41 = false

								if v40 == input then
									v40 = nil
								end
							end
						end)
					end
				end)
				table.insert(v38, inputBeganConnection)

				for _, guiObject in pairs(hotbarMain:GetDescendants()) do
					if not guiObject:IsA("GuiObject") then
						continue
					end

					local inputBeganConnection2 = guiObject.InputBegan:Connect(function(input)
						if v40 then
							return
						end

						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							v40 = input
							v39 = true
							v41 = false
							position2 = input.Position
							position3 = hotbarMain.Position
							scale = uIScale and uIScale.Scale or 1
							input.Changed:Connect(function()
								if input.UserInputState == Enum.UserInputState.End then
									v39 = false
									scale = nil
									v41 = false

									if v40 == input then
										v40 = nil
									end
								end
							end)
						end
					end)
					table.insert(v38, inputBeganConnection2)
				end

				local inputChangedConnection = service2.InputChanged:Connect(function(input)
					if input == v40 and v39 and not v41 then
						local v42 = input.Position - position2
						hotbarMain.Position = UDim2.new(
							position3.X.Scale,
							position3.X.Offset + v42.X,
							position3.Y.Scale,
							position3.Y.Offset + v42.Y
						)
					end
				end)
				table.insert(v38, inputChangedConnection)
				local touchPinchConnection = service2.TouchPinch:Connect(function(_, p, _, p2, _)
					if not (v39 and scale) then
						return
					end

					if p2 == Enum.UserInputState.Begin then
						v41 = true
					elseif p2 == Enum.UserInputState.End or p2 == Enum.UserInputState.Cancel then
						v41 = false

						if v40 then
							position2 = v40.Position
							position3 = hotbarMain.Position
						end
					end

					if uIScale then
						uIScale.Scale = scale * p
					end
				end)
				table.insert(v38, touchPinchConnection)
			else
				for _, connection3 in pairs(v38) do
					connection3:Disconnect()
				end

				table.clear(v38)

				if backgroundColor32 ~= nil then
					hotbarMain.BackgroundColor3 = backgroundColor32
				end

				if backgroundTransparency2 ~= nil then
					hotbarMain.BackgroundTransparency = backgroundTransparency2
				end

				if active2 ~= nil then
					hotbarMain.Active = active2
				end

				shared.hotbarPos = hotbarMain.Position
				warn("set??")
				local hotbar = hotbarMain:FindFirstChild("Hotbar")
				local uIScale = hotbar and hotbar:FindFirstChildOfClass("UIScale")

				if uIScale then
					shared.hotbarScale = uIScale.Scale
				end

				if shared.SaveHotbar then
					shared.SaveHotbar()
				end
			end
		end)
		jumpButton.ImageRectSize = Vector2.new(0, 0)
		jumpButton.ImageRectOffset = Vector2.new(0, 0)
		jumpButton.Image = "rbxassetid://12253837933"
		jumpButton.MouseButton1Down:Connect(function()
			if draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			v33 = true
			local v39 = {
				Goal = "KeyPress",
				Key = Enum.KeyCode.Space
			}
			jumpButton.Image = "rbxassetid://12253844033"
			fn3(v39)
			task.spawn(function()
				repeat
					task.wait()

					if humanoid.JumpPower > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				until not v33
			end)
		end)

		fn17 = function()
			if draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			v33 = false
			local v39 = {
				Goal = "KeyRelease",
				Key = Enum.KeyCode.Space
			}
			jumpButton.Image = "rbxassetid://12253837933"
			fn3(v39)
		end

		jumpButton.MouseButton1Up:Connect(fn17)
		registerHoldButton(jumpButton, nil, fn17, false)
		dashButton.MouseButton1Down:Connect(function()
			if draggingButtons then
				return
			end

			local cFrame = humanoidRootPart.CFrame

			if shared.ismobile and localPlayer:GetAttribute("S_DirectionalDash") then
				local success, result = pcall(fn7)

				if success and typeof(result) == "CFrame" then
					cFrame = result
				end
			end

			local v39 = cFrame + humanoid.MoveDirection * 15
			local p = v39.p
			local unit = (Vector3.new(p.X, cFrame.p.Y, p.Z) - cFrame.p).unit
			local v40 = math.deg((math.acos((cFrame.LookVector:Dot(unit)))))
			dashButton.Image = "rbxassetid://12253813495"
			local v41 = 0

			if v40 > -45 and v40 < 45 then
				v41 = 0
			elseif v40 > 135 and v40 < 215 then
				v41 = 180
			elseif v40 >= 45 and v40 <= 135 then
				local v42 = cFrame * CFrame.new(15, 0, 0)
				local v43 = cFrame * CFrame.new(-15, 0, 0)
				v41 = (v39.p - v42.p).magnitude > (v39.p - v43.p).magnitude and 90 or -90
			end

			if v41 == 0 and character:FindFirstChild("WallCombo") then
				fn3({
					Goal = "Wall Combo"
				})
				return
			end

			local _ = "dash firing with angle " .. tostring(v41)
			fn15(v41)
		end)
		dashButton.MouseButton1Up:Connect(function()
			if draggingButtons then
				return
			end

			dashButton.Image = "rbxassetid://12252434969"
		end)

		fn17 = function()
			if draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			local v39 = {
				Goal = "LeftClick",
				Mobile = true,
				CrushingPull = shared.GetCrushingPullHit(character:FindFirstChildOfClass("Tool"))
			}
			punchButton.Image = "rbxassetid://12253807149"
			fn3(v39)
		end

		punchButton.MouseButton1Down:Connect(fn17)

		local function onMouseButton1Up()
			if draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			punchButton.Image = "rbxassetid://12252402662"
			fn3({
				Goal = "LeftClickRelease",
				Mobile = true
			})
		end

		punchButton.MouseButton1Up:Connect(onMouseButton1Up)
		registerHoldButton(punchButton, fn17, onMouseButton1Up, true)

		fn17 = function()
			flag2 = true

			if draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			local v39 = {
				Goal = "KeyPress",
				Key = Enum.KeyCode.F
			}

			if character:FindFirstChild("DoingEmote") then
				fn3({
					Goal = "CancelEmote"
				})
			end

			blockButton.Image = "rbxassetid://12253793254"

			while true do
				if flag2 then
					if ActionCheck:Check(character) and not character:GetAttribute("Blocking") or character:GetAttribute("HasTrashcan") then
						fn3(v39)
					end

					task.wait()
				end

				if flag2 then
					continue
				end

				blockButton.Image = "rbxassetid://12252418253"
				break
			end
		end

		blockButton.MouseButton1Down:connect(fn17)

		onMouseButton1Up = function()
			flag2 = false

			if draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			local v39 = {
				Goal = "KeyRelease",
				Key = Enum.KeyCode.F
			}
			blockButton.Image = "rbxassetid://12252418253"
			fn3(v39)
		end

		blockButton.MouseButton1Up:connect(onMouseButton1Up)
		registerHoldButton(blockButton, fn17, onMouseButton1Up, true)
		shiftLockButton.MouseButton1Down:connect(function()
			if draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			localPlayer:SetAttribute("ShiftLockOn", not localPlayer:GetAttribute("ShiftLockOn"))
			shiftLockButton.Image = shiftLockButton.Image == "rbxassetid://79664771265271" and "rbxassetid://79605996519245" or "rbxassetid://79664771265271"
		end)
		localPlayer:GetAttributeChangedSignal("S_ShiftLocks"):Connect(function()
			shiftLockButton.Visible = localPlayer:GetAttribute("S_ShiftLocks")
		end)
		shiftLockButton.Visible = localPlayer:GetAttribute("S_ShiftLocks")

		if localPlayer:GetAttribute("ShiftLockOn") then
			shiftLockButton.Image = "rbxassetid://79605996519245"
		else
			shiftLockButton.Image = "rbxassetid://79664771265271"
		end

		if burstButton then
			burstButton.Visible = false
			burstButton.ImageTransparency = 1
			local image = burstButton.Image
			local v39 = false
			localPlayer:GetAttributeChangedSignal("Burst"):Connect(function()
				if localPlayer:GetAttribute("Burst") >= 100 then
					burstButton.Visible = true
					local TweenService = game:GetService("TweenService")
					TweenService:Create(
						burstButton,
						TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							ImageTransparency = 0
						}
					):Play()
					v39 = true
				else
					burstButton.Visible = false
					v39 = false
					local TweenService = game:GetService("TweenService")
					TweenService:Create(
						burstButton,
						TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							ImageTransparency = 1
						}
					):Play()
				end
			end)

			local function onMouseButton1Down()
				if not v39 then
					return
				end

				fn3({
					Goal = "KeyPress",
					Key = Enum.KeyCode.R
				})
				burstButton.Image = "rbxassetid://79747949535014"
			end

			burstButton.MouseButton1Down:Connect(onMouseButton1Down)

			local function onMouseButton1Up2()
				burstButton.Image = image
				fn3({
					Goal = "KeyRelease",
					Key = Enum.KeyCode.R
				})
			end

			burstButton.MouseButton1Up:Connect(onMouseButton1Up2)
			registerHoldButton(burstButton, onMouseButton1Down, onMouseButton1Up2, true)
		end

		if uppercutButton then
			uppercutButton.Image = "rbxassetid://87790504437867"
			local v39 = false

			local function onMouseButton1Down()
				local combo = character:GetAttribute("Combo")

				if draggingButtons or shared.draggingBar or shared.draggingHotbar or character:GetAttribute("Combo") and combo ~= 4 then
					return
				end

				if combo == 4 and workspace:GetServerTimeNow() - (character:GetAttribute("ComboTimer") or 0) > 1 then
					return
				end

				v39 = true
				fn3({
					Goal = "KeyPress",
					Key = Enum.KeyCode.Space
				})
				uppercutButton.Image = "rbxassetid://91334818474792"
				fn3({
					Goal = "LeftClick",
					Mobile = true,
					CrushingPull = shared.GetCrushingPullHit(character:FindFirstChildOfClass("Tool"))
				})
			end

			uppercutButton.MouseButton1Down:Connect(onMouseButton1Down)

			local function onMouseButton1Up2()
				if draggingButtons or shared.draggingBar or shared.draggingHotbar or not v39 then
					return
				end

				v39 = false

				if not v33 then
					fn3({
						Goal = "KeyRelease",
						Key = Enum.KeyCode.Space
					})
				end

				uppercutButton.Image = "rbxassetid://87790504437867"
				fn3({
					Goal = "LeftClickRelease",
					Mobile = true
				})
			end

			uppercutButton.MouseButton1Up:Connect(onMouseButton1Up2)
			registerHoldButton(uppercutButton, onMouseButton1Down, onMouseButton1Up2, true)
			localPlayer:GetAttributeChangedSignal("S_UppercutButton"):Connect(function()
				uppercutButton.Visible = localPlayer:GetAttribute("S_UppercutButton") == true
			end)
			uppercutButton.Visible = localPlayer:GetAttribute("S_UppercutButton") == true
		end

		if downslamButton then
			downslamButton.Image = "rbxassetid://98502571890413"
			local v39 = false

			local function onMouseButton1Down()
				local combo = character:GetAttribute("Combo")

				if draggingButtons or shared.draggingBar or shared.draggingHotbar or character:GetAttribute("Combo") and combo ~= 4 then
					return
				end

				if combo == 4 and workspace:GetServerTimeNow() - (character:GetAttribute("ComboTimer") or 0) > 1 then
					return
				end

				if not v39 then
					tick()

					repeat
						task.wait()
					until not (character:FindFirstChild("M1ing") or character:FindFirstChild("NoJump"))
				end

				v39 = true

				if humanoid.JumpPower > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end

				downslamButton.Image = "rbxassetid://99120518167666"
				task.delay(0.22, function()
					v39 = false
					fn3({
						Goal = "LeftClick",
						Mobile = true,
						CrushingPull = shared.GetCrushingPullHit(character:FindFirstChildOfClass("Tool"))
					})
				end)
			end

			downslamButton.MouseButton1Down:Connect(onMouseButton1Down)

			local function onMouseButton1Up2()
				if draggingButtons or shared.draggingBar or shared.draggingHotbar or not v39 then
					return
				end

				v39 = false
				downslamButton.Image = "rbxassetid://98502571890413"
				fn3({
					Goal = "LeftClickRelease",
					Mobile = true
				})
			end

			downslamButton.MouseButton1Up:Connect(onMouseButton1Up2)
			registerHoldButton(downslamButton, onMouseButton1Down, onMouseButton1Up2, true)
			localPlayer:GetAttributeChangedSignal("S_DownslamButton"):Connect(function()
				downslamButton.Visible = localPlayer:GetAttribute("S_DownslamButton") == true
			end)
			downslamButton.Visible = localPlayer:GetAttribute("S_DownslamButton") == true
		end

		if clockTime then
			if shared.barScale == nil then
				clockTime.UIScale.Scale = 0.6
			else
				clockTime.UIScale.Scale = shared.barScale
			end

			if shared.barPos == nil then
				clockTime.MagicHealth.Position = UDim2.new(0.5, 0, 1, -150)
			else
				clockTime.MagicHealth.Position = shared.barPos
			end
		end

		function shared.SaveBar()
			local barPos = shared.barPos or UDim2.new(0.5, 0, 1, -150)
			fn3({
				Goal = "Save Bar Layout",
				Position = {
					barPos.X.Scale,
					barPos.X.Offset,
					barPos.Y.Scale,
					barPos.Y.Offset
				},
				Scale = shared.barScale or 0.6
			})
		end

		function shared.SaveHotbar()
			warn("uhm?")
			local hotbarPos = shared.hotbarPos or UDim2.new(0, 0, 0, 0)
			fn3({
				Goal = "Save Hotbar Layout",
				Position = {
					hotbarPos.X.Scale,
					hotbarPos.X.Offset,
					hotbarPos.Y.Scale,
					hotbarPos.Y.Offset
				},
				Scale = shared.hotbarScale or 1
			})
		end

		local v39 = jumpButton
		shared.MobileButtons = {}
		shared.MobileSave = fn18
		local v40 = {
			burstButton,
			dashButton,
			punchButton,
			blockButton,
			shiftLockButton
		}

		for _, v41 in pairs(v40) do
			v41.Position = v39.Position
			local v42 = v39
			v39 = v41
			local offset = v39.Size.X.Offset + 10

			if v42 == jumpButton then
				offset = jumpButton.Size.X.Offset
				v41.Position = UDim2.new(0.5, 0, 0.5, 0)
			end

			v41.Position = UDim2.new(0.5, 0, 0.5, v41.Position.Y.Offset - offset)
			table.insert(shared.MobileButtons, { v41, v41.Position })
		end

		if uppercutButton then
			for _, child in pairs(jumpButton.Parent:GetChildren()) do
				if child.Name == "UppercutButton" and child ~= uppercutButton then
					child:Destroy()
				end
			end

			uppercutButton.Parent = jumpButton.Parent
			uppercutButton.Position = UDim2.new(0, 80, 0.38, 0)
			table.insert(shared.MobileButtons, { uppercutButton, uppercutButton.Position })
		end

		if downslamButton then
			for _, child in pairs(jumpButton.Parent:GetChildren()) do
				if child.Name == "DownslamButton" and child ~= downslamButton then
					child:Destroy()
				end
			end

			downslamButton.Parent = jumpButton.Parent
			downslamButton.Position = UDim2.new(0, 80, 0.38, jumpButton.Size.Y.Offset + 10)
			table.insert(shared.MobileButtons, { downslamButton, downslamButton.Position })
		end

		if burstButton then
			for _, child in pairs(jumpButton.Parent:GetChildren()) do
				if child.Name == "BurstButton" and child ~= burstButton then
					child:Destroy()
				end
			end

			burstButton.Parent = jumpButton.Parent
			burstButton.Position = UDim2.new(0, 140, 0.38, jumpButton.Size.Y.Offset + -14)
			table.insert(shared.MobileButtons, { burstButton, burstButton.Position })
		end

		fn16()
		task.spawn(function()
			if not localPlayer:GetAttribute("MobileLayout") then
				local lastTime5 = tick()

				repeat
					task.wait()
				until tick() - lastTime5 > 6 or localPlayer:GetAttribute("MobileLayout")
			end

			local mobileLayout = localPlayer:GetAttribute("MobileLayout")

			if mobileLayout and mobileLayout ~= "[]" then
				local jSONDecode = game:service("HttpService"):JSONDecode(mobileLayout)
				local v41 = {
					burstButton,
					dashButton,
					punchButton,
					blockButton,
					shiftLockButton,
					uppercutButton,
					downslamButton
				}

				for _, v42 in pairs(v41) do
					if not (v42 and jSONDecode[v42.Name]) then
						continue
					end

					v42.Position = UDim2.new(
						jSONDecode[v42.Name][1],
						jSONDecode[v42.Name][2],
						jSONDecode[v42.Name][3],
						jSONDecode[v42.Name][4]
					)
					v42.UIScale.Scale = jSONDecode[v42.Name][5] or 1
				end
			end
		end)
	end
elseif clockTime then
	clockTime.MagicHealth.Visible = true
end

CollectionService:GetInstanceAddedSignal("Mech" .. localPlayer.Name):Connect(function(instance)
	mech = instance
	instance:GetPropertyChangedSignal("Parent"):Connect(function()
		if not instance.Parent and mech == instance then
			mech = nil
		end
	end)
end)
CollectionService:GetInstanceAddedSignal("EmoteSync"):Connect(function(instance)
	instance.MaxDistance = 500
	instance.Enabled = true
	instance.Frame.Size = UDim2.new(0, 0, 1, 0)
	local adornee = instance.Adornee
	local frame = instance:FindFirstChild("Frame")

	if instance.PlayerToHideFrom == localPlayer then
		local Debris = game:GetService("Debris")
		return Debris:AddItem(instance, 0)
	end

	local v32 = nil

	while task.wait(0.075) and instance and instance.Parent and instance.Parent.Parent and adornee and adornee.Parent and adornee.Parent.Parent and adornee.Parent.Parent.Parent do
		local primaryPart = character.PrimaryPart
		local v33 = primaryPart and (primaryPart.Position - adornee.Position).magnitude <= 22 and true or false

		if not (v32 ~= v33 and frame) then
			continue
		end

		service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = v33 and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)
		}):Play()
		service:Create(frame.TextButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			TextTransparency = v33 and 0 or 1.5
		}):Play()
		v32 = v33
	end
end)
local v32 = false
local rankedOnes = workspace:GetAttribute("RankedOnes")
local noHoldingX = workspace:GetAttribute("NoHoldingX")
local averageFPS = nil
local now9 = tick()
local now10 = tick()
local v33 = false
local tagged = CollectionService:GetTagged("SingleTree")

if rankedOnes or workspace:GetAttribute("RankedTwos") or workspace:GetAttribute("RankedThrees") then
	CollectionService:GetInstanceAddedSignal("CharacterSelection"):Connect(function(instance)
		task.defer(function()
			if not (instance and instance.Parent) then
				return
			end

			local CAN = instance:GetAttribute("CAN")

			if CAN and not tostring(CAN):find(tostring(localPlayer.UserId), 1, true) then
				instance:Destroy()
			end
		end)
	end)
	workspace:GetAttributeChangedSignal("CantSwitch"):Once(function()
		if character:GetAttribute("Character") ~= "Ninja" then
			return
		end

		v32 = true
		task.delay(0.5, function()
			v32 = false
		end)
	end)
	task.spawn(function()
		for _, v34 in pairs(CollectionService:GetTagged("CharacterSelection")) do
			local v35 = v34
			task.defer(function()
				if not (v35 and v35.Parent) then
					return
				end

				local CAN = v35:GetAttribute("CAN")

				if CAN and not tostring(CAN):find(tostring(localPlayer.UserId), 1, true) then
					v35:Destroy()
				end
			end)
		end

		local lastTime5 = tick()

		repeat
			task.wait()
		until shared.AverageFPS or tick() - lastTime5 > 60

		averageFPS = shared.AverageFPS
	end)
end

local v34 = false

if character:GetAttribute("Character") == "Ninja" then
	v32 = true
	task.delay(0.5, function()
		v32 = false
	end)
else
	v32 = false
end

local flag3 = true
local donationLeaderboard = workspace.Thrown:FindFirstChild("Donation Leaderboard")

if donationLeaderboard then
	donationLeaderboard = donationLeaderboard:FindFirstChild("a") or nil
end

local v35 = false
local v36 = false
local now11 = 0
local v37 = nil
local v38 = nil
local v39 = {
	0,
	0,
	0,
	0,
	0,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	0,
	0,
	0,
	0,
	0
}
local v40 = {
	165,
	165,
	165,
	165,
	165,
	255,
	215,
	230,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	245,
	230,
	215,
	255,
	165,
	165,
	165,
	165,
	165
}
local v41 = {
	255,
	255,
	255,
	255,
	255,
	255,
	110,
	135,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	215,
	135,
	110,
	255,
	255,
	255,
	255,
	255,
	255
}
local v42 = nil
local v43 = nil
local v44 = nil
local v45 = nil
task.delay(2, function()
	v35 = true
end)
local v46 = nil
local aurora = workspace.Thrown:FindFirstChild("Aurora")

if aurora then
	aurora.Destroying:Once(function()
		local lastTime5 = tick()

		while task.wait() and not (tick() - lastTime5 >= 2) do
			warn("DESTROYE ARUROR")
		end
	end)
end

if not aurora then
	warn("[CRITICAL NO AURORA FOUND O AURAORA FOUND]")
end

local v47 = false
local v48 = false
local v49 = humanoid
local cframe = CFrame.new(149.56, 440.756, 29.743)
local v50 = false
task.delay(2, function()
	if workspace:GetAttribute("VIPServer") or workspace:GetAttribute("RankedOnes") then
		local RunService = game:GetService("RunService")

		if RunService:IsStudio() then
			v50 = vector.create(149.56, 440.756, 29.743)
		end
	else
		v50 = vector.create(149.56, 440.756, 29.743)
	end
end)
local lastTime5 = tick()
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local RunService2 = game:GetService("RunService")
RunService2.Heartbeat:Connect(function(dt)
	if character:FindFirstChild("zombiereviveforcefully") then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		humanoid:ChangeState(Enum.HumanoidStateType.Running, true)
	end

	if character:FindFirstChild("Redeath") then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	end

	if isStudio then
		if service2:IsKeyDown(Enum.KeyCode.E) then
			v22 = 100
		else
			v22 = nil
		end
	end

	if character:GetAttribute("Character") == "Zombie" and realzombie2 == nil then
		realzombie2 = realzombie
		v17 = fn(131585091153240)
	end

	if v50 then
		if (humanoidRootPart.Position - v50).magnitude >= 30000 and not character:FindFirstChild("MovingExclusion") then
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = vector.create(2000000000, 2000000000, 2000000000)
			bodyVelocity.Velocity = vector.create(0.1, 0.1, 0.1)
			bodyVelocity.Parent = head
			local Debris = game:GetService("Debris")
			Debris:AddItem(bodyVelocity, 0.25)
			humanoidRootPart.Velocity = vector.create(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = vector.create(0, 0, 0)
			local v51 = cframe
			character:PivotTo((CFrame.lookAlong(v51.Position, v51.LookVector * vector.create(1, 0, 1))))
		elseif humanoidRootPart.Position.Y >= 433 and humanoidRootPart.Position.Y <= 450 then
			cframe = humanoidRootPart.CFrame
		end
	end

	if humanoidRootPart.RotVelocity.magnitude > 1000 then
		humanoidRootPart.RotVelocity = vector.create(0, 0, 0)
	end

	local v51 = character:GetAttribute("InMech") and character:FindFirstChild("Mech") and not character:FindFirstChild("Mech"):GetAttribute("finisheditself")

	if not mech and v51 then
		mech = character:FindFirstChild("Mech")
	end

	if (localPlayer:GetAttribute("Character") == "Monster" or character:FindFirstChild("CharExclusion")) and localPlayer:GetAttribute("Unreliable") and (humanoid:GetState() == Enum.HumanoidStateType.Freefall or localPlayer:GetAttribute("ForcedReliable")) then
		local pivot = character:GetPivot()

		if character:GetAttribute("rootcframesend") then
			pivot = humanoidRootPart.CFrame
		end

		if character:FindFirstChild("mousereceiver") then
			pivot = CFrame.new(mouse.Hit.Position) * CFrame.lookAt(humanoidRootPart.Position, mouse.Hit.Position).Rotation
		end

		game.ReplicatedStorage.UnreliableRemoteEvent:FireServer(pivot)
	end

	local freeze2 = character:FindFirstChild("Freeze")

	if freeze2 and freeze2:GetAttribute("CustomMoveStun") or tick() - lastTime5 <= 2 then
		lastTime5 = tick()
		shared._cmSeq = (shared._cmSeq or 0) + 1
		local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
		local humanoid2 = character:FindFirstChildOfClass("Humanoid")
		local Y = humanoidRootPart2 and humanoidRootPart2.AssemblyLinearVelocity.Y or 0
		local falling = (humanoid2 and humanoid2.FloorMaterial == Enum.Material.Air) == true
		local pivot = character:GetPivot()
		local v53 = {
			cframe = pivot,
			falling = falling,
			velY = Y,
			running = falselocal2 == true,
			holdingSpace = v5 == true or (service2:IsKeyDown(Enum.KeyCode.Space) or service2:IsKeyDown(Enum.KeyCode.ButtonA)),
			seq = shared._cmSeq,
			clientT = workspace:GetServerTimeNow()
		}
		updateLocalCustomMoveLiveCache(localPlayer, pivot, v53)
		game.ReplicatedStorage.UnreliableRemoteEvent:FireServer(v53, "CustomMoveStun")
	end

	if (v36 or game.Lighting.ClockTime ~= 12.302) and not localPlayer:GetAttribute("S_DayNight") and not localPlayer:GetAttribute("S_DayNight") and v47 then
		v47 = false
		v36 = false

		if aurora then
			for _, beam in pairs(aurora:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				service:Create(beam, TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Brightness = 0
				}):Play()
				beam.Enabled = false
			end
		end

		for _, v52 in pairs(CollectionService:GetTagged("daynightcloudgone")) do
			v52:Destroy()
		end

		v46 = nil
		v44 = false

		if shared.originallighting then
			shared.originallighting()
		end
	end

	if localPlayer:GetAttribute("S_DayNight") and currentCamera.CameraType ~= Enum.CameraType.Scriptable then
		v47 = true
		v36 = true

		if tick() - now11 > 0.01 then
			now11 = tick()
			game.Lighting.ClockTime = workspace.Terrain.Time.Value
			local clockTime2 = game.Lighting.ClockTime
			local v52

			if clockTime2 >= 18 and clockTime2 <= 24 then
				v52 = true
			elseif clockTime2 >= 0 then
				v52 = clockTime2 <= 5.65
			else
				v52 = false
			end

			v44 = v52

			if v46 ~= v44 then
				v46 = v44

				if v44 then
					local integer = Random.new(workspace.Terrain.Time:GetAttribute("Cycle")):NextInteger(1, 10)
					local folder = Instance.new("Folder")
					folder.Name = "Gone"
					folder:SetAttribute("Slow", true)
					folder:AddTag("daynightcloudgone")
					folder.Parent = workspace.Terrain.Clouds

					if integer == 1 then
						fn3({
							Goal = "Gaze"
						})
						service:Create(
							game.Lighting.Atmosphere,
							TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Density = 0.213
							}
						):Play()
						local aurora2 = workspace.Thrown:FindFirstChild("Aurora")

						if aurora2 then
							for _, beam in pairs(aurora2:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								beam.Brightness = 0
								beam.Enabled = true
								service:Create(
									beam,
									TweenInfo.new(
										Random.new():NextNumber(7, 14) * 2,
										Enum.EasingStyle.Quad,
										Enum.EasingDirection.InOut
									),
									{
										Brightness = beam:GetAttribute("Original")
									}
								):Play()
							end
						end
					end
				else
					for _, v53 in pairs(CollectionService:GetTagged("daynightcloudgone")) do
						v53:Destroy()
					end

					if workspace.Thrown:FindFirstChild("Aurora") and aurora:FindFirstChildWhichIsA("Beam", true).Brightness ~= 0 then
						service:Create(
							game.Lighting.Atmosphere,
							TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Density = 0.27
							}
						):Play()

						for _, beam in pairs(aurora:GetDescendants()) do
							if beam:IsA("Beam") then
								service:Create(
									beam,
									TweenInfo.new(
										Random.new():NextNumber(7, 14) * 1.5,
										Enum.EasingStyle.Quad,
										Enum.EasingDirection.InOut
									),
									{
										Brightness = 0
									}
								):Play()
							end
						end

						task.delay(21, function()
							if v44 then
								return
							end

							for _, beam in pairs(aurora:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								beam.Enabled = false
								beam.Brightness = 0
							end
						end)
					end
				end
			end

			game.Lighting.Brightness = math.cos(clockTime2 * 0.2617993877991494 + 3.141592653589793) * 0.1 + 2
			v37 = math.cos(clockTime2 * 0.2617993877991494 + 3.141592653589793) * 20 + 100
			game.Lighting.OutdoorAmbient = Color3.fromRGB(v37, v37, v37)
			game.Lighting.ShadowSoftness = math.cos(clockTime2 * 0.5235987755982988) * 0.2 + 0.8
			v38 = math.clamp(math.ceil(clockTime2), 1, 24)
			v42 = (v39[v38 % 24 + 1] - v39[v38]) * (clockTime2 - v38 + 1) + v39[v38]
			v43 = (v40[v38 % 24 + 1] - v40[v38]) * (clockTime2 - v38 + 1) + v40[v38]
			v45 = (v41[v38 % 24 + 1] - v41[v38]) * (clockTime2 - v38 + 1) + v41[v38]
			game.Lighting.ColorShift_Top = Color3.fromRGB(v42, v43, v45)
		end
	end

	local now12 = tick()

	if donationLeaderboard then
		if (humanoidRootPart.Position - donationLeaderboard.Position).magnitude > 15 then
			donationLeaderboard.CanQuery = false
		else
			donationLeaderboard.CanQuery = true
		end

		if flag3 then
			flag3 = false

			for _, button in pairs(donationLeaderboard.SurfaceGui.Holder.Frame:GetChildren()) do
				if not button:IsA("TextButton") then
					continue
				end

				local v52 = button
				button.MouseButton1Click:Connect(function()
					local text = v52.Text
					local MarketplaceService = game:GetService("MarketplaceService")
					MarketplaceService:PromptProductPurchase(
						localPlayer,
						Info.DonationProducts[string.sub(text, 5, #text)]
					)
				end)
			end
		end
	end

	if humanoidRootPart.Position.Y < -500 and v35 and humanoid.Health > 0 then
		warn("crep revive: client kill-plane fired y=" .. math.floor(humanoidRootPart.Position.Y))
		humanoid.Health = 0
	end

	if findFirstChild(character, "CrabCamera") then
		if humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

			if math.random(1, 2) == 1 then
				humanoid:ChangeState(Enum.HumanoidStateType.Running)
			else
				humanoid:ChangeState(Enum.HumanoidStateType.Landed)
			end
		end
	else
		if humanoid:GetState() == Enum.HumanoidStateType.FallingDown and not findFirstChild(character, "Ragdoll") then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end

		if humanoid:GetState() ~= Enum.HumanoidStateType.FallingDown and findFirstChild(character, "Ragdoll") then
			humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		end
	end

	local newMethod = character:FindFirstChild("NewMethod")
	local value2

	if newMethod then
		value2 = newMethod.Value
	end

	if value2 then
		workspace.CurrentCamera.CameraSubject = value2.Humanoid
	end

	local vector2 = Vector3.new(v28 + 0, v29 + -1.25 + (localPlayer:GetAttribute("S_CameraHeight") or 0), v30 + 0)
	local cameraoffsetadjustment = character:FindFirstChild("cameraoffsetadjustment")

	if cameraoffsetadjustment then
		vector2 += cameraoffsetadjustment.Value
	end

	local crabCamera = character:FindFirstChild("CrabCamera")

	if v23 and v23.Value and v23.Value.Parent then
		vector2 += humanoidRootPart.CFrame:toObjectSpace(v23.Value.RootPart.Root.UpperMouth["Bone.002"]["Bone.003"].WorldCFrame).Position
	elseif crabCamera and crabCamera.Value and crabCamera.Value.Parent then
		vector2 += humanoidRootPart.CFrame:toObjectSpace(crabCamera.Value.RootPart.Body.WorldCFrame).Position
	elseif mech and mech:GetAttribute("Ready") then
		vector2 += humanoidRootPart.CFrame:toObjectSpace(mech.RootPart.MasterBone.Root.UpperTorso.WorldCFrame).Position
	elseif head and head.Parent and torso and torso.Parent and not character:GetAttribute("BreakJointed") then
		if v32 or character:GetAttribute("NoHeadFollow") then
			vector2 += vector.create(0, 1.25, 0)
		elseif value2 then
			vector2 += value2.HumanoidRootPart.CFrame:toObjectSpace(value2.Head.CFrame).p
		else
			vector2 += humanoidRootPart.CFrame:toObjectSpace(head.CFrame).p
		end
	end

	if v23 and not v23.Parent then
		v23 = nil
	end

	if not (character:GetAttribute("NoHeadLerp") or localPlayer:GetAttribute("NoShiftlock")) then
		local clonedChar = character:GetAttribute("ClonedChar")
		local humanoid2 = humanoid
		local primaryPart

		if value2 then
			primaryPart = value2.PrimaryPart
		else
			primaryPart = humanoidRootPart
		end

		local newCam = character:FindFirstChild("NewCam")

		if newCam then
			local value3 = newCam.Value

			if typeof(value3) == "Instance" and value3:IsA("Model") and value3.Parent then
				humanoid2 = value3:FindFirstChildOfClass("Humanoid")
			else
				humanoid2 = nil
			end

			if humanoid2 then
				primaryPart = value3:FindFirstChild("HumanoidRootPart") or value3:FindFirstChild("UpperTorso") or value3:FindFirstChild("Torso")
				v49 = humanoid2
				local torso2 = value3:FindFirstChild("Torso") or value3:FindFirstChild("UpperTorso") or humanoid2 or primaryPart

				if torso2 and workspace.CurrentCamera.CameraSubject ~= torso2 and not (character:FindFirstChild("SkippedEmote") or v48) then
					v48 = true
					workspace.CurrentCamera.CameraSubject = torso2
				end
			else
				newCam:Destroy()
				clonedChar = nil
			end
		elseif not value2 and workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable and humanoid.Health > 0 and not localPlayer:GetAttribute("dontset") then
			workspace.CurrentCamera.CameraSubject = humanoid
		end

		local s_CameraTracking = localPlayer:GetAttribute("S_CameraTracking")
		local v52 = 1 - (1 - math.clamp(typeof(s_CameraTracking) ~= "number" and 0.11 or s_CameraTracking, 0, 1)) ^ (dt * 60)
		local vector3

		if value2 then
			vector3 = value2.Humanoid.CameraOffset:lerp(vector2, v52)
		else
			vector3 = humanoid.CameraOffset:lerp(vector2, v52)
		end

		local magnitude = (primaryPart.Position - (primaryPart.Position + vector3)).magnitude
		local v53 = primaryPart.CFrame * CFrame.new(vector.create(0, 1.5, 0) + vector3)

		if not clonedChar and not value2 and (vector3 ~= vector3 or magnitude > 1000 or (v53.Position - primaryPart.Position).magnitude > 1000) then
			vector3 = Vector3.new()
		end

		if value2 then
			value2.Humanoid.CameraOffset = vector3
		else
			humanoid.CameraOffset = vector3
		end

		if humanoid2.Health == 0 and not (character:FindFirstChild("0HpCamBp") or clonedChar or v34) then
			v34 = true
			local renderSteppedConnection = nil
			local RunService3 = game:GetService("RunService")
			renderSteppedConnection = RunService3.RenderStepped:Connect(function()
				if currentCamera.CameraType == Enum.CameraType.Scriptable or character:GetAttribute("LetGoOfCamera") or character:FindFirstChild("SkippedEmote") then
					return
				end

				if character:FindFirstChild("zombiebypass") then
					renderSteppedConnection:Disconnect()
					v34 = false
				else
					currentCamera.CFrame += v49.CameraOffset
				end
			end)
		end
	end

	if (slowed or freeze) and humanoid.FloorMaterial == Enum.Material.Air and not v2 then
		local v52 = character:FindFirstChild("DoingEmote") and 0.25 or 0.94
		humanoidRootPart.Velocity *= Vector3.new(v52, 1, v52)
	end

	if (not (touchEnabled or gamepadEnabled) or noHoldingX) and (rankedOnes and averageFPS and averageFPS > 30 or noHoldingX) and now12 - now9 > 1 and workspace.DistributedGameTime > 120 and not workspace.Thrown:FindFirstChild("DebrisggbbTf") then
		fn3({
			Goal = "FloorMaterial"
		})
	end

	now9 = now12

	if v6 then
		local dot = humanoid.MoveDirection:Dot(workspace.CurrentCamera.CFrame.LookVector)
		local dot2 = humanoid.MoveDirection:Dot(workspace.CurrentCamera.CFrame.RightVector)

		if humanoid.MoveDirection == Vector3.new() or not (math.abs(touchEnabled and 0 or dot2) < 0.85) or dot < -0.1 then
			if falselocal2 then
				falselocal2 = false
				fn5()
			end
		elseif not falselocal2 then
			falselocal2 = true
			fn5()
		end

		if humanoid:GetState() == Enum.HumanoidStateType.Climbing then
			falselocal2 = false
		end

		if falselocal2 and not v17.IsPlaying then
			if realzombie2 then
				realzombie2()
			end

			v17:Play()
		end
	end

	if (freeze or slowed) and not (character:FindFirstChild("DoingEmote") or freeze and freeze:GetAttribute("Endlag")) or v2 or rankedOnes then
		v33 = false
	elseif not (humanoidRootPart.Position.Y > 456.085 and humanoidRootPart.Position.Y < 490.147) then
		v33 = false
	elseif now12 - now10 > 2 then
		now10 = now12
		local v52 = false

		for _, v54 in pairs(tagged) do
			if (v54.Position - humanoidRootPart.Position).magnitude < 20 then
				v52 = true
				break
			else
				task.wait()
			end
		end

		if not v52 then
			v33 = false
			return
		end

		if not v33 then
			v33 = true
			return
		end

		fn3({
			Goal = "Tree Sava"
		})
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = vector.create(40000, 40000, 40000)
		bodyVelocity.Velocity = humanoidRootPart.CFrame.lookVector * -40
		bodyVelocity.Parent = humanoidRootPart
		game:service("Debris"):AddItem(bodyVelocity, 0.15)
		v33 = false
	end
end)
local totalKillsLeaderboard = workspace:FindFirstChild("Total Kills Leaderboard") or workspace.Map:FindFirstChild("Total Kills Leaderboard")

local function fn16()
	if not totalKillsLeaderboard then
		return
	end

	local kills = localPlayer:GetAttribute("Kills")
	local v51 = {}
	local v53 = 0

	for k2, v54 in pairs(totalKillsLeaderboard:GetAttributes()) do
		if string.sub(k2, 2, #k2) == "Minimumkills" then
			table.insert(v51, { k2, v54 })
		end
	end

	table.sort(v51, function(a, b)
		return a[2] < b[2]
	end)

	for _, v55 in pairs(v51) do
		if not (kills < v55[2]) then
			continue
		end

		v53 = v55[1]
		local _ = v55[2]
		break
	end

	local v55 = v53 ~= "cMinimumkills" and "RANK PROMOTION" or "A TITLE"
	local v56 = tonumber(totalKillsLeaderboard:GetAttribute(v53) or 0) + 1 - (localPlayer:GetAttribute("Kills") or 0)

	if v56 <= 0 then
		local goal = totalKillsLeaderboard:FindFirstChild("Goal", true)
		goal.Text = ""
		return
	end

	local v57 = fn14(v56)
	local goal_2 = totalKillsLeaderboard:FindFirstChild("Goal", true)
	goal_2.Text = string.format("<font color=\"rgb(197, 255, 143)\">%s</font> MORE KILLS FOR %s", v57, v55)
end

if totalKillsLeaderboard then
	totalKillsLeaderboard:GetAttributeChangedSignal("Update"):Connect(fn16)
end

localPlayer:GetAttributeChangedSignal("Kills"):Connect(fn16)
localPlayer:GetAttributeChangedSignal("CountdownRanked"):Connect(function()
	local clone = game.ReplicatedStorage.Countdown:Clone()
	clone.Parent = localPlayer.PlayerGui
	shared.sfx({
		SoundId = "rbxassetid://13356393533",
		Parent = workspace,
		Name = "Countdown",
		Volume = 2
	}):Play()

	for i = 1, 4 do
		local v51 = clone[i == 4 and "Go" or 4 - i or "Go"]
		local size = v51.Size
		v51.Size = UDim2.new(0, 0, 0, 0)

		if i < 4 then
			v51.Rotation = math.random(-55, 55)
		end

		v51.Visible = true
		v51.ZIndex += 1
		service:Create(
			v51,
			TweenInfo.new(0.3, i < 4 and Enum.EasingStyle.Back or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = size,
				Rotation = 0
			}
		):Play()
		local clone2

		if i == 4 then
			clone2 = v51:Clone()
			clone2.Size = UDim2.new(0, 0, 0, 0)
			clone2.Visible = true
			clone2.ZIndex -= 1
			clone2.Rotation = 0
			clone2.ImageLabel.ImageTransparency = 0.5
			clone2.Parent = v51.Parent
			service:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = size
			}):Play()
			service:Create(clone2.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(2, 0, 2, 0),
				ImageTransparency = 0.9
			}):Play()
		end

		wait(i == 4 and 0.625 or 1)

		if i == 4 then
			for _, v52 in pairs({ v51, clone2 }) do
				service:Create(v52, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = UDim2.new(0, 0, 0, 0)
				}):Play()
				local v53 = v52
				task.delay(0.15, function()
					v53:Destroy()
				end)
			end
		else
			v51:Destroy()
		end
	end
end)
pcall(function()
	if shared.lastxd then
		shared.lastxd()
		shared.lastxd = nil
	end

	fn16()
end)

if (localPlayer:GetAttribute("DiedTime") or 0) >= 1 then
	local clone = game.ReplicatedStorage.Resources.Vig:Clone()
	clone.Parent = localPlayer.PlayerGui.ShiftLock
	workspace:GetAttributeChangedSignal("FoundWinner"):Connect(function()
		service:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 1
		}):Play()
	end)
end

task.delay(0.1, function()
	if localPlayer:GetAttribute("Teammate") then
		while task.wait(0.25) do
			local hotbar = (localPlayer:GetAttribute("DiedTime") or 0) >= 2 and localPlayer.PlayerGui:FindFirstChild("Hotbar")

			if hotbar then
				hotbar.Enabled = false
			end

			fn3({
				Goal = "Camera CFrame",
				CFrame = workspace.CurrentCamera.CFrame
			})
		end
	end
end)
local introBind = character:FindFirstChild("IntroBind") or character:WaitForChild("IntroBind", 2)

if not introBind then
	return
end

task.delay(0, function()
	if not workspace:GetAttribute("zzz") then
		workspace:SetAttribute("zzz", true)
		print("CLIENT LOADED", tick() - lastTime)
	end
end)

if introBind then
	local lastTime6 = tick()
	local v51

	if introBind:GetAttribute("CustomSpawnIdle") == true then
		v51 = true
	else
		v51 = false
	end

	while true do
		if humanoid.WalkSpeed > 0 and humanoid.MoveDirection ~= Vector3.new() then
			fn3({
				Goal = "Disable Intro"
			})
		end

		task.wait()

		if not (not introBind.Parent or not v51 and tick() - lastTime6 > 2.5) then
			continue
		end

		if tostring(character) == "YungCrepetics" then
			return
		end

		local ExperienceNotificationService = game:GetService("ExperienceNotificationService")

		local function canPromptOptIn()
			local success, result = pcall(function()
				return ExperienceNotificationService:CanPromptOptInAsync()
			end)
			return success and result
		end

		if not canPromptOptIn() then
			break
		end

		local v53 = ExperienceNotificationService
		local _, _ = pcall(function()
			v53:PromptOptIn()
		end)
		break
	end
end

local fakeHead = character.FakeHead
fakeHead:GetPropertyChangedSignal("Transparency"):Connect(function()
	if fakeHead.Transparency ~= 1 then
		fakeHead.Transparency = 1
	end
end)