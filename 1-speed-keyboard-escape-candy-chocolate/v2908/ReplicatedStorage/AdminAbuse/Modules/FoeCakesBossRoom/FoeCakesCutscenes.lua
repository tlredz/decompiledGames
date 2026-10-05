local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local foeCakesBossRoom = ReplicatedStorage.AdminAbuse.FoeCakesBossRoom
local FoeCakesCutscenes = {}
local FoeCakesBossAnimIds = require(script.Parent:WaitForChild("FoeCakesBossAnimIds"))
local localPlayer = Players.LocalPlayer

local function newState()
	return {
		active = false,
		tracks = {},
		cleanups = {},
		cachedBossCFrame = nil,
		cachedWalkSpeed = nil,
		cachedJumpPower = nil,
		cachedJumpHeight = nil,
		savedUiStates = {},
		playerParts = {},
		playerDecals = {},
		revealedRigParts = {},
		playerRigRef = nil
	}
end

local v = newState()
local count = 0
local v2 = nil

local function getLiveMap()
	local adminAbuse = workspace:FindFirstChild("AdminAbuse")
	local map = adminAbuse and adminAbuse:FindFirstChild("Map")

	if not map then
		return nil
	end

	for _, model in map:GetChildren() do
		if model:IsA("Model") and model:GetAttribute("AdminAbuseLiveMap") then
			return model
		end
	end

	return nil
end

local function getBossRig()
	local liveMap = getLiveMap()
	local bossRig = liveMap and liveMap:FindFirstChild("BossRig")

	if bossRig and bossRig:IsA("Model") then
		return bossRig
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCutsceneContainer()
	local liveMap = getLiveMap()
	local scriptables = liveMap and liveMap:FindFirstChild("Scriptables")
	return scriptables and scriptables:FindFirstChild("FoeCakesCutscene")
end

local function getCameraRig()
	local cutsceneContainer = getCutsceneContainer() -- equivalent call inferred; original call site unknown
	local cameraRig = cutsceneContainer and cutsceneContainer:FindFirstChild("CameraRig")

	if cameraRig and cameraRig:IsA("Model") then
		return cameraRig
	end

	return nil
end

local function getPlayerRig()
	local cutsceneContainer = getCutsceneContainer() -- equivalent call inferred; original call site unknown
	local playerRig = cutsceneContainer and cutsceneContainer:FindFirstChild("PlayerRig")

	if playerRig and playerRig:IsA("Model") then
		return playerRig
	end

	return nil
end

local function getPlayerRigAnchor()
	local cutsceneContainer = getCutsceneContainer() -- equivalent call inferred; original call site unknown
	local playerRigAnchor = cutsceneContainer and cutsceneContainer:FindFirstChild("PlayerRigAnchor")

	if playerRigAnchor and playerRigAnchor:IsA("BasePart") then
		return playerRigAnchor
	end

	return nil
end

local function getPlayerRigTemplate()
	local assets = foeCakesBossRoom:FindFirstChild("Assets")
	local playerRig = assets and assets:FindFirstChild("PlayerRig")

	if playerRig and playerRig:IsA("Model") then
		return playerRig
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPostEndCutsceneContainer()
	local liveMap = getLiveMap()
	local scriptables = liveMap and liveMap:FindFirstChild("Scriptables")
	return scriptables and scriptables:FindFirstChild("PostEndCutscene")
end

local function hideTaggedUI()
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return
	end

	table.clear(v.savedUiStates)

	for _, frame in CollectionService:GetTagged("UI") do
		if not (frame:IsA("Frame") and frame:IsDescendantOf(playerGui)) then
			continue
		end

		v.savedUiStates[frame] = frame.Visible
		frame.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreTaggedUI()
	for k, savedUiState in v.savedUiStates do
		if k and k.Parent then
			k.Visible = savedUiState
		end
	end

	table.clear(v.savedUiStates)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function freezeLocalPlayer()
	local character = localPlayer and localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	v.cachedWalkSpeed = humanoid.WalkSpeed
	v.cachedJumpPower = humanoid.JumpPower
	v.cachedJumpHeight = humanoid.JumpHeight
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unfreezeLocalPlayer()
	local character = localPlayer and localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		if v.cachedWalkSpeed then
			humanoid.WalkSpeed = v.cachedWalkSpeed
		end

		if v.cachedJumpPower then
			humanoid.JumpPower = v.cachedJumpPower
		end

		if v.cachedJumpHeight then
			humanoid.JumpHeight = v.cachedJumpHeight
		end
	end

	v.cachedWalkSpeed = nil
	v.cachedJumpPower = nil
	v.cachedJumpHeight = nil
end

local function hideAllRealPlayers()
	table.clear(v.playerParts)
	table.clear(v.playerDecals)

	for _, v3 in Players:GetPlayers() do
		local character = v3.Character

		if not character then
			continue
		end

		for _, descendant in character:GetDescendants() do
			if descendant:IsA("BasePart") then
				table.insert(v.playerParts, {
					part = descendant,
					transparency = descendant.Transparency,
					localTransparencyModifier = descendant.LocalTransparencyModifier
				})
				descendant.LocalTransparencyModifier = 1
			elseif descendant:IsA("Decal") then
				table.insert(v.playerDecals, {
					decal = descendant,
					transparency = descendant.Transparency
				})
				descendant.Transparency = 1
			end
		end
	end
end

local function restoreAllRealPlayers()
	for _, playerPart in v.playerParts do
		if playerPart.part and playerPart.part.Parent then
			playerPart.part.LocalTransparencyModifier = playerPart.localTransparencyModifier
		end
	end

	for _, playerDecal in v.playerDecals do
		if playerDecal.decal and playerDecal.decal.Parent then
			playerDecal.decal.Transparency = playerDecal.transparency
		end
	end

	table.clear(v.playerParts)
	table.clear(v.playerDecals)
end

local function revealCutsceneRig(folder)
	v.playerRigRef = folder

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			local __CutsceneOriginalTransparency = descendant:GetAttribute("__CutsceneOriginalTransparency")
			local transparency = typeof(__CutsceneOriginalTransparency) ~= "number" and 0 or __CutsceneOriginalTransparency
			table.insert(v.revealedRigParts, {
				partInst = descendant,
				decalInst = nil,
				hiddenT = descendant.Transparency
			})
			descendant.Transparency = transparency
		elseif descendant:IsA("Decal") then
			local __CutsceneOriginalTransparency = descendant:GetAttribute("__CutsceneOriginalTransparency")
			local transparency = typeof(__CutsceneOriginalTransparency) ~= "number" and 0 or __CutsceneOriginalTransparency
			table.insert(v.revealedRigParts, {
				partInst = nil,
				decalInst = descendant,
				hiddenT = descendant.Transparency
			})
			descendant.Transparency = transparency
		end
	end
end

local function rehideCutsceneRig()
	for _, revealedRigPart in v.revealedRigParts do
		if revealedRigPart.partInst and revealedRigPart.partInst.Parent then
			revealedRigPart.partInst.Transparency = revealedRigPart.hiddenT
		elseif revealedRigPart.decalInst and revealedRigPart.decalInst.Parent then
			revealedRigPart.decalInst.Transparency = revealedRigPart.hiddenT
		end
	end

	table.clear(v.revealedRigParts)
	local playerRigRef = v.playerRigRef

	if playerRigRef and playerRigRef.Parent then
		for _, descendant in playerRigRef:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = false
			elseif descendant:IsA("Decal") then
				descendant.Transparency = 1
			end
		end
	end

	v.playerRigRef = nil
end

local function hideBossBar()
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
	local foeCakesBossHud = playerGui and playerGui:FindFirstChild("FoeCakesBossHud")

	if not (foeCakesBossHud and foeCakesBossHud:IsA("ScreenGui")) then
		return
	end

	local enabled = foeCakesBossHud.Enabled
	foeCakesBossHud.Enabled = false
	table.insert(v.cleanups, function()
		if foeCakesBossHud and foeCakesBossHud.Parent then
			foeCakesBossHud.Enabled = enabled
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheBossCFrame()
	local liveMap = getLiveMap()
	local bossRig = liveMap and liveMap:FindFirstChild("BossRig")

	if not (bossRig and bossRig:IsA("Model")) then
		bossRig = nil
	end

	local humanoidRootPart = bossRig and bossRig:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		v.cachedBossCFrame = humanoidRootPart.CFrame
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreBossCFrame()
	local liveMap = getLiveMap()
	local bossRig = liveMap and liveMap:FindFirstChild("BossRig")

	if not (bossRig and bossRig:IsA("Model")) then
		bossRig = nil
	end

	local cachedBossCFrame = v.cachedBossCFrame

	if bossRig and cachedBossCFrame then
		pcall(function()
			bossRig:PivotTo(cachedBossCFrame)
		end)
	end

	v.cachedBossCFrame = nil
end

local function bindCameraToRig(cameraRig)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return function() end
	end

	local cam = cameraRig:FindFirstChild("cam")

	if not (cam and cam:IsA("BasePart")) then
		warn("[FoeCakesCutscenes] CameraRig.cam BasePart not found")
		return function() end
	end

	currentCamera.FieldOfView = 50
	currentCamera.CameraSubject = cam
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = cam.CFrame
	RunService:BindToRenderStep("FoeCakesCutsceneLock", Enum.RenderPriority.Camera.Value + 2, function()
		if cam.Parent then
			currentCamera.CFrame = cam.CFrame
		end
	end)
	return function()
		RunService:UnbindFromRenderStep("FoeCakesCutsceneLock")
		currentCamera.FieldOfView = 70
		currentCamera.CameraType = Enum.CameraType.Custom
		local character = localPlayer and localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			currentCamera.CameraSubject = humanoid
		end
	end
end

local function playMarkerSound(childName: string)
	local cutscene_SFX_FoeCakes = foeCakesBossRoom:FindFirstChild("Cutscene_SFX_FoeCakes")

	if not cutscene_SFX_FoeCakes then
		return
	end

	local sound = cutscene_SFX_FoeCakes:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		local clone = sound:Clone()
		clone.Parent = workspace
		clone:Play()
		clone.Ended:Once(function()
			clone:Destroy()
		end)
	end
end

local function resolveEasingStyle(p: string?)
	if not p or p == "" then
		return Enum.EasingStyle.Quad
	end

	local v3 = tonumber(p)

	if v3 then
		for _, v4 in Enum.EasingStyle:GetEnumItems() do
			if v4.Value == v3 then
				return v4
			end
		end

		return Enum.EasingStyle.Quad
	else
		local success, result = pcall(function()
			return Enum.EasingStyle[p]
		end)

		if success and typeof(result) == "EnumItem" then
			return result
		end

		return Enum.EasingStyle.Quad
	end
end

local function resolveEasingDirection(p: string?)
	if not p or p == "" then
		return Enum.EasingDirection.InOut
	end

	local v3 = tonumber(p)

	if v3 then
		for _, v4 in Enum.EasingDirection:GetEnumItems() do
			if v4.Value == v3 then
				return v4
			end
		end

		return Enum.EasingDirection.InOut
	else
		local success, result = pcall(function()
			return Enum.EasingDirection[p]
		end)

		if success and typeof(result) == "EnumItem" then
			return result
		end

		return Enum.EasingDirection.InOut
	end
end

local function makeTI(duration: number, p: number, p2: number)
	return TweenInfo.new(duration, resolveEasingStyle(tostring(p)), (resolveEasingDirection(tostring(p2))))
end

local function handleEventMarker(p: string)
	if p == "portal_on" or p == "portal_off" then
		pcall(function()
			local cutsceneContainer = getCutsceneContainer() -- equivalent call inferred; original call site unknown
			local portalCutscene = cutsceneContainer and cutsceneContainer:FindFirstChild("PortalCutscene")
			local main = portalCutscene and portalCutscene:FindFirstChild("Portal") and portalCutscene.Portal:FindFirstChild("Main")

			if not main then
				return
			end

			local enabled = p == "portal_on"

			for _, emitter in main:GetChildren() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = enabled
				end
			end
		end)
	elseif p == "energy_staff" then
		task.spawn(function()
			pcall(function()
				local liveMap = getLiveMap()
				local bossRig = liveMap and liveMap:FindFirstChild("BossRig")

				if not (bossRig and bossRig:IsA("Model")) then
					bossRig = nil
				end

				local staffHand = bossRig and bossRig:FindFirstChild("StaffHand")

				if not staffHand then
					return
				end

				local plane = staffHand:FindFirstChild("Plane")
				local handle = staffHand:FindFirstChild("Handle")
				local pointLight = handle and handle:FindFirstChild("PointLight")
				local energyToStaff = plane and plane:FindFirstChild("EnergyToStaff")

				if energyToStaff then
					energyToStaff:Emit(20)
				end

				if pointLight then
					pointLight.Brightness = 0
					pointLight.Enabled = true
					TweenService:Create(
						pointLight,
						TweenInfo.new(1.6, resolveEasingStyle(tostring(3)), (resolveEasingDirection(tostring(2)))),
						{
							Brightness = 10
						}
					):Play()
				end

				task.wait(1.7)

				if plane then
					TweenService:Create(
						plane,
						TweenInfo.new(0.4, resolveEasingStyle(tostring(3)), (resolveEasingDirection(tostring(2)))),
						{
							Color = Color3.fromRGB(170, 159, 121)
						}
					):Play()
				end

				if pointLight then
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.5, resolveEasingStyle(tostring(3)), (resolveEasingDirection(tostring(2)))),
						{
							Brightness = 0
						}
					):Play()
				end
			end)
		end)
	elseif p == "staff_off" then
		pcall(function()
			local liveMap = getLiveMap()
			local bossRig = liveMap and liveMap:FindFirstChild("BossRig")

			if not (bossRig and bossRig:IsA("Model")) then
				bossRig = nil
			end

			local staffHand = bossRig and bossRig:FindFirstChild("StaffHand")
			local plane = staffHand and staffHand:FindFirstChild("Plane")

			if plane then
				plane.Color = Color3.fromRGB(79, 74, 66)
			end
		end)
	elseif p == "staff_hit" then
		task.spawn(function()
			pcall(function()
				local liveMap = getLiveMap()
				local bossRig = liveMap and liveMap:FindFirstChild("BossRig")

				if not (bossRig and bossRig:IsA("Model")) then
					bossRig = nil
				end

				local staffHand = bossRig and bossRig:FindFirstChild("StaffHand")
				local staffNone = bossRig and bossRig:FindFirstChild("StaffNone")
				local plane = staffHand and staffHand:FindFirstChild("Plane")
				local plane2 = staffNone and staffNone:FindFirstChild("Plane")

				if plane then
					plane.Transparency = 1
				end

				if plane2 then
					plane2.Transparency = 0
				end

				task.wait(0.5)

				if plane2 then
					TweenService:Create(
						plane2,
						TweenInfo.new(0.5, resolveEasingStyle(tostring(0)), (resolveEasingDirection(tostring(0)))),
						{
							Color = Color3.fromRGB(79, 74, 66)
						}
					):Play()
				end
			end)
		end)
	end
end

local function handleFovMarker(value: string)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v3 = string.split(value, ",")
	local fieldOfView = tonumber(v3[1])

	if not fieldOfView then
		return
	end

	if v2 then
		v2:Cancel()
		v2:Destroy()
		v2 = nil
	end

	local v5 = tonumber(v3[2]) or 0

	if v5 <= 0 then
		currentCamera.FieldOfView = fieldOfView
		return
	end

	local easingStyle = resolveEasingStyle(v3[3])
	local easingDirection = resolveEasingDirection(v3[4])
	local tween = TweenService:Create(currentCamera, TweenInfo.new(v5, easingStyle, easingDirection), {
		FieldOfView = fieldOfView
	})
	v2 = tween
	tween:Play()
	tween.Completed:Once(function()
		if v2 == tween then
			v2 = nil
		end

		tween:Destroy()
	end)
end

local function ensureAnimator(parent)
	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")

		if animator then
			return animator
		end

		local animator2 = Instance.new("Animator")
		animator2.Parent = humanoid
		return animator2
	else
		local animationController = parent:FindFirstChildOfClass("AnimationController")

		if animationController then
			local animator = animationController:FindFirstChildOfClass("Animator")

			if animator then
				return animator
			end

			local animator2 = Instance.new("Animator")
			animator2.Parent = animationController
			return animator2
		else
			local animationController2 = Instance.new("AnimationController")
			animationController2.Parent = parent
			local animator = Instance.new("Animator")
			animator.Parent = animationController2
			return animator
		end
	end
end

local function loadOnRig(rig, id: string)
	local animator = ensureAnimator(rig)

	if not animator then
		warn("[FoeCakesCutscenes] No Animator/AnimationController found on " .. rig.Name)
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = id
	local track = animator:LoadAnimation(animation)
	track.Looped = false
	track.Priority = Enum.AnimationPriority.Action4
	return track
end

local function connectMarkers(object)
	local connection = object:GetMarkerReachedSignal("Sound"):Connect(function(p)
		playMarkerSound(tostring(p))
	end)
	local connection2 = object:GetMarkerReachedSignal("Event"):Connect(function(p)
		handleEventMarker(tostring(p))
	end)
	local connection3 = object:GetMarkerReachedSignal("fov"):Connect(function(p)
		handleFovMarker(tostring(p))
	end)
	table.insert(v.cleanups, function()
		connection:Disconnect()
	end)
	table.insert(v.cleanups, function()
		connection2:Disconnect()
	end)
	table.insert(v.cleanups, function()
		connection3:Disconnect()
	end)
end

local function createBlackScreen()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoeCakesCutsceneBlack"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local frame = Instance.new("Frame")
	frame.Name = "Black"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 100
	frame.Parent = screenGui
	screenGui.Parent = playerGui
	return screenGui
end

local function fadeBlackScreen(instance, backgroundTransparency: number)
	local black = instance:FindFirstChild("Black")

	if not black then
		return
	end

	local tween = TweenService:Create(black, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		BackgroundTransparency = backgroundTransparency
	})
	tween:Play()
	tween.Completed:Wait()
	tween:Destroy()
end

local function showFakeAnnouncement(p: string)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local notificationFrame = ReplicatedStorage:FindFirstChild("NotificationFrame")

	if not notificationFrame then
		warn("[FoeCakesCutscenes] showFakeAnnouncement: NotificationFrame template missing")
		return
	end

	local clone = notificationFrame:Clone()
	local avatar = clone:FindFirstChild("Avatar")

	if avatar and avatar:IsA("ImageLabel") then
		local success, result = pcall(function()
			return Players:GetUserThumbnailAsync(156, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)

		if success and result then
			avatar.Image = result
		end

		avatar.ImageColor3 = Color3.new(0, 0, 0)
	end

	local text = clone:FindFirstChild("Text")

	if text and text:IsA("TextLabel") then
		text.RichText = true
		text.Text = "<font color=\"rgb(225,20,255)\"><b>???</b></font> : " .. p
	end

	local v3 = {}
	local v4 = {}

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("UIStroke") then
			table.insert(v3, {
				obj = descendant,
				prop = "Transparency"
			})
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			table.insert(v3, {
				obj = descendant,
				prop = "TextTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(v3, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			table.insert(v3, {
				obj = descendant,
				prop = "ImageTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(v3, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
			table.insert(v3, {
				obj = descendant,
				prop = "BackgroundTransparency"
			})
		end

		if descendant:IsA("UIGradient") then
			table.insert(v4, {
				obj = descendant,
				original = descendant.Transparency
			})
		end
	end

	if clone:IsA("Frame") and clone.BackgroundTransparency < 1 then
		table.insert(v3, {
			obj = clone,
			prop = "BackgroundTransparency"
		})
	end

	local v5 = {}

	for i, v6 in ipairs(v3) do
		v5[i] = v6.obj[v6.prop]
		v6.obj[v6.prop] = 1
	end

	local numberSequence = NumberSequence.new(1)

	for _, v6 in ipairs(v4) do
		v6.obj.Transparency = numberSequence
	end

	local adminAnnounce = playerGui:FindFirstChild("AdminAnnounce")
	local mainFrame = adminAnnounce and adminAnnounce:FindFirstChild("MainFrame")
	local screenGui = nil

	if mainFrame then
		clone.Parent = mainFrame
	else
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FakeAnnounceFoeCakes"
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 110
		screenGui.Parent = playerGui
		clone.Parent = screenGui
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://98797174600699"
	sound.Volume = 0.4
	sound.Parent = localPlayer
	sound:Play()
	task.delay(5, function()
		if sound and sound.Parent then
			sound:Destroy()
		end
	end)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for i, v6 in ipairs(v3) do
		TweenService:Create(v6.obj, tweenInfo, {
			[v6.prop] = v5[i]
		}):Play()
	end

	for _, v6 in ipairs(v4) do
		v6.obj.Transparency = v6.original
	end

	task.delay(3.5, function()
		local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, v6 in ipairs(v3) do
			TweenService:Create(v6.obj, tweenInfo2, {
				[v6.prop] = 1
			}):Play()
		end

		for _, v6 in ipairs(v4) do
			v6.obj.Transparency = numberSequence
		end

		task.delay(0.5, function()
			if clone and clone.Parent then
				clone:Destroy()
			end

			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end)
end

local function showCredits()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoeCakesCredits"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(0.8, 0.4)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Text = [[
Host - Secret_Lokii & LuckyMatg
Producer - Chichine
Scripter - FoeCakes
Cutscenes - Kenami
Builder - Nextune_Dev
Music - X3LL3N
]]
	textLabel.TextTransparency = 1
	textLabel.Parent = frame
	TweenService:Create(textLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()
	task.wait(6.5)
	local tween = TweenService:Create(textLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1
	})
	tween:Play()
	tween.Completed:Once(function()
		screenGui:Destroy()
	end)
end

local function teardown()
	for _, track in v.tracks do
		local v3 = track
		pcall(function()
			v3:Stop(0)
		end)
	end

	table.clear(v.tracks)

	for i = #v.cleanups, 1, -1 do
		pcall(v.cleanups[i])
	end

	table.clear(v.cleanups)
	restoreTaggedUI() -- equivalent call inferred; original call site unknown
	unfreezeLocalPlayer() -- equivalent call inferred; original call site unknown
	restoreAllRealPlayers()
	rehideCutsceneRig()
	restoreBossCFrame() -- equivalent call inferred; original call site unknown

	if v2 then
		v2:Cancel()
		v2:Destroy()
		v2 = nil
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.FieldOfView = 70
	end

	v.active = false
end

local function playTracks(items)
	local length = 0

	for _, item in items do
		local v3 = loadOnRig(item.rig, item.id)

		if not v3 then
			continue
		end

		connectMarkers(v3)
		table.insert(v.tracks, v3)
		v3:Play(0)

		if length < v3.Length then
			length = v3.Length
		end
	end

	return length
end

function FoeCakesCutscenes.playOpening(_)
	FoeCakesCutscenes.stopAll()
	count += 1
	local v3 = count
	v = newState()
	v.active = true
	local liveMap = getLiveMap()
	local bossRig = liveMap and liveMap:FindFirstChild("BossRig")

	if not (bossRig and bossRig:IsA("Model")) then
		bossRig = nil
	end

	local cutsceneContainer = getCutsceneContainer() -- equivalent call inferred; original call site unknown
	local cameraRig = cutsceneContainer and cutsceneContainer:FindFirstChild("CameraRig")

	if not (cameraRig and cameraRig:IsA("Model")) then
		cameraRig = nil
	end

	if bossRig and cameraRig then
		hideTaggedUI()
		hideBossBar()
		freezeLocalPlayer() -- equivalent call inferred; original call site unknown
		cacheBossCFrame() -- equivalent call inferred; original call site unknown
		table.insert(v.cleanups, (bindCameraToRig(cameraRig)))
		local opening = playTracks({
			{
				rig = bossRig,
				id = FoeCakesBossAnimIds.Cutscenes.Opening.BossRig
			},
			{
				rig = cameraRig,
				id = FoeCakesBossAnimIds.Cutscenes.Opening.CameraRig
			}
		})

		if opening <= 0 then
			opening = FoeCakesBossAnimIds.CutsceneDurations.Opening
		end

		task.wait(opening)

		if v3 ~= count or not v.active then
			return
		end

		task.wait(4.75)

		if v3 ~= count or not v.active then
			return
		end

		local blackScreen = createBlackScreen()
		fadeBlackScreen(blackScreen, 0)

		if v.active then
			teardown()
		end

		fadeBlackScreen(blackScreen, 1)
		pcall(function()
			blackScreen:Destroy()
		end)
	else
		warn("[FoeCakesCutscenes] Opening: missing BossRig or CameraRig — bailing")
		v.active = false
	end
end

function FoeCakesCutscenes.playEnding(_, callback)
	FoeCakesCutscenes.stopAll()
	count += 1
	local v3 = count
	v = newState()
	v.active = true
	local liveMap = getLiveMap()
	local bossRig = liveMap and liveMap:FindFirstChild("BossRig")

	if not (bossRig and bossRig:IsA("Model")) then
		bossRig = nil
	end

	local cutsceneContainer = getCutsceneContainer() -- equivalent call inferred; original call site unknown
	local cameraRig = cutsceneContainer and cutsceneContainer:FindFirstChild("CameraRig")

	if not (cameraRig and cameraRig:IsA("Model")) then
		cameraRig = nil
	end

	if bossRig and cameraRig then
		hideTaggedUI()
		hideBossBar()
		freezeLocalPlayer() -- equivalent call inferred; original call site unknown
		cacheBossCFrame() -- equivalent call inferred; original call site unknown
		hideAllRealPlayers()
		task.spawn(function()
			ContentProvider:PreloadAsync({ "rbxassetid://70635271190744" })
		end)
		local cutsceneContainer2 = getCutsceneContainer() -- equivalent call inferred; original call site unknown
		local playerRigAnchor = cutsceneContainer2 and cutsceneContainer2:FindFirstChild("PlayerRigAnchor")

		if not (playerRigAnchor and playerRigAnchor:IsA("BasePart")) then
			playerRigAnchor = nil
		end

		local assets = foeCakesBossRoom:FindFirstChild("Assets")
		local playerRig = assets and assets:FindFirstChild("PlayerRig")

		if not (playerRig and playerRig:IsA("Model")) then
			playerRig = nil
		end

		local clone = nil

		if playerRig then
			local cFrame

			if playerRigAnchor then
				cFrame = playerRigAnchor.CFrame
			else
				cFrame = CFrame.identity
			end

			clone = playerRig:Clone()
			clone.Parent = workspace
			clone:PivotTo(cFrame)
			local character = localPlayer and (localPlayer.Character or localPlayer.CharacterAdded:Wait())
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local humanoid2 = clone:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid2 then
				local success, result = pcall(function()
					return Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
				end)

				if success and result then
					local success2, result2 = pcall(function()
						humanoid2:ApplyDescriptionAsync(result)
					end)

					if not success2 then
						warn("[FoeCakesCutscenes] ApplyDescriptionAsync failed: " .. tostring(result2))
					end
				else
					warn("[FoeCakesCutscenes] GetHumanoidDescriptionFromUserId failed")
				end
			end

			for _, part in clone:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.CollisionGroup = "FoeCakesBossRig"
			end

			table.insert(v.cleanups, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
		else
			warn("[FoeCakesCutscenes] Ending: PlayerRig template missing from Assets — player rig skipped")
		end

		table.insert(v.cleanups, (bindCameraToRig(cameraRig)))
		local v4 = {
			{
				rig = bossRig,
				id = FoeCakesBossAnimIds.Cutscenes.Ending.BossRig
			},
			{
				rig = cameraRig,
				id = FoeCakesBossAnimIds.Cutscenes.Ending.CameraRig
			}
		}

		if clone then
			table.insert(v4, {
				rig = clone,
				id = FoeCakesBossAnimIds.Cutscenes.Ending.PlayerRig
			})
		end

		local ending = playTracks(v4)

		if ending <= 0 then
			ending = FoeCakesBossAnimIds.CutsceneDurations.Ending
		end

		local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
		local foeCakesCutsceneBlack = playerGui and playerGui:FindFirstChild("FoeCakesCutsceneBlack")

		if foeCakesCutsceneBlack and foeCakesCutsceneBlack:IsA("ScreenGui") then
			fadeBlackScreen(foeCakesCutsceneBlack, 1)
			pcall(function()
				foeCakesCutsceneBlack:Destroy()
			end)
		end

		task.wait(ending)

		if v3 ~= count or not v.active then
			return
		end

		task.wait(4.75)

		if v3 ~= count or not v.active then
			return
		end

		local blackScreen = createBlackScreen()
		fadeBlackScreen(blackScreen, 0)
		local screenGui = nil
		local postEndCutsceneContainer = getPostEndCutsceneContainer() -- equivalent call inferred; original call site unknown
		local cameras = postEndCutsceneContainer and postEndCutsceneContainer:FindFirstChild("Cameras")
		local _1 = cameras and cameras:FindFirstChild("1")
		local _2 = cameras and cameras:FindFirstChild("2")
		local currentCamera = workspace.CurrentCamera

		if currentCamera and _1 then
			RunService:UnbindFromRenderStep("FoeCakesCutsceneLock")
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CFrame = _1.CFrame
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "FoeCakesEndImage"
			screenGui.IgnoreGuiInset = true
			screenGui.ResetOnSpawn = false
			screenGui.DisplayOrder = 200
			screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Size = UDim2.fromScale(0.5, 0.5)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = "rbxassetid://70635271190744"
			imageLabel.ImageTransparency = 1
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Parent = screenGui
			local track = nil
			local chichineRig = postEndCutsceneContainer and postEndCutsceneContainer:FindFirstChild("ChichineRig")

			if chichineRig and chichineRig:IsA("Model") then
				local animator = ensureAnimator(chichineRig)

				if animator then
					local animation = Instance.new("Animation")
					animation.AnimationId = "rbxassetid://81644450019918"
					track = animator:LoadAnimation(animation)
					track.Looped = true
					track.Priority = Enum.AnimationPriority.Action
					track:Play(0.3)
				end
			end

			fadeBlackScreen(blackScreen, 1)
			task.wait(1)
			showFakeAnnouncement("Just as planned.")

			if _2 and v3 == count and v.active then
				local tween = TweenService:Create(
					currentCamera,
					TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						CFrame = _2.CFrame
					}
				)
				tween:Play()
				tween.Completed:Wait()
				tween:Destroy()
			end

			if v3 == count and v.active then
				showFakeAnnouncement("Let's see what those brothers got in store..")
				local sanoRig = postEndCutsceneContainer and postEndCutsceneContainer:FindFirstChild("SanoRig")

				if sanoRig then
					local catHandle = sanoRig:FindFirstChild("CatHandle", true)

					if catHandle and catHandle:IsA("BasePart") then
						local sound = Instance.new("Sound")
						sound.SoundId = "rbxassetid://114631512807844"
						sound.Parent = workspace
						task.wait(1)
						sound:Play()
						sound.Ended:Once(function()
							sound:Destroy()
						end)
						TweenService:Create(catHandle, TweenInfo.new(2), {
							CFrame = catHandle.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
						}):Play()
					end
				end

				task.wait(5)
			end

			TweenService:Create(imageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				ImageTransparency = 0
			}):Play()
			fadeBlackScreen(blackScreen, 0)

			if track then
				track:Stop(0)
			end
		else
			warn("[FoeCakesCutscenes] PostEndCutscene.Cameras.1 missing — skipping post-ending")
		end

		task.wait(3)
		pcall(function()
			if screenGui then
				screenGui:Destroy()
			end
		end)

		if v.active then
			teardown()
		end

		if callback then
			pcall(callback)
		end

		task.spawn(showCredits)
		fadeBlackScreen(blackScreen, 1)
		pcall(function()
			blackScreen:Destroy()
		end)
	else
		warn("[FoeCakesCutscenes] Ending: missing BossRig or CameraRig — bailing")
		v.active = false
	end
end

function FoeCakesCutscenes.stopAll()
	count += 1

	if v.active then
		teardown()
	end
end

return FoeCakesCutscenes