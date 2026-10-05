local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")

if not require3(ReplicatedStorage2.ServerInfo).isRhythmServer() then
	task.spawn(function()
		workspace:WaitForChild("Rhythm"):Destroy()
	end)
	return {}
end

local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Packages.Observers)
local v4 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v5 = require3(ReplicatedStorage2.Shared.SwordAPI)
local v6 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
local v7 = require3(ReplicatedStorage2.Shared.ReplicatedInstancesUtils)
local v8 = require3(ReplicatedStorage2.Shared.AnimationProfiles)
local v9 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Controllers.AnimationController)
local v10 = require3(script.Spring)
local v11 = require3(script.Parent.RhythmObstacleGenerator)
local v12 = require3(ReplicatedStorage2:WaitForChild("SongCharts"):WaitForChild("SongLibrary"))
local v13 = require3(ReplicatedStorage2.SongCharts.ChartDecoder)
local v14 = require3(ReplicatedStorage2.SongCharts.RhythmScoring)
local v15 = require3(ReplicatedStorage2.Packages.Net)
local v16 = require3(ReplicatedStorage2.Packages.Replion)
local v17 = require3(ReplicatedStorage2.Controllers.EncryptedAssetController)
local rhythm = workspace:WaitForChild("Rhythm")
local runtime = rhythm:WaitForChild("Runtime")
local cameraPart = rhythm:WaitForChild("CameraPart")
local obstacles = rhythm:WaitForChild("Obstacles")
local map = runtime.Map
map.Parent = nil
local pivot = rhythm.Pivot:GetPivot()
local v18 = {
	{
		ratio = 0.75,
		tier = "Perfect",
		error = 0
	},
	{
		ratio = 0.5,
		tier = "Great",
		error = 0.06
	},
	{
		ratio = 0.25,
		tier = "Good",
		error = 0.1
	},
	{
		ratio = 0,
		tier = "Ok",
		error = 0.14
	}
}
local v19 = {
	Distance = 9,
	ProbeSize = createVector(4.5, 4, 1),
	GroundClearance = 0.25,
	JumpVelocity = 36,
	Cooldown = 0.2
}
local _ = {
	StandTolerance = 0.4
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getRigOffset(instance)
	return CFrame.new(instance:GetPivot().Position - (instance.Torso.Position + createVector(0, -3, 0)))
end

local function moveRig(instance, cframe: CFrame, cframe2: CFrame)
	instance:PivotTo(cframe2 * cframe)
end

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
humanoidRootPart.Anchored = true
local humanoid = character:WaitForChild("Humanoid")
humanoid.WalkSpeed = 0
local RhythmLTMController = {}
local v20 = nil
local thread = nil
local clearHighScoreBanner

local function showBanner(text: string, textColor: Color3)
	clearHighScoreBanner()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RhythmHighScore"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 50
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(0.5, 0.075)
	textLabel.Position = UDim2.fromScale(0.5, 0.085)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.TextScaled = true
	textLabel.TextColor3 = textColor
	textLabel.TextStrokeTransparency = 0.35
	textLabel.TextTransparency = 1
	textLabel.Text = text
	textLabel.Parent = screenGui
	v20 = screenGui
	TweenService:Create(textLabel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()
	thread = task.delay(5, function()
		thread = nil
		local tween = TweenService:Create(
			textLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				TextTransparency = 1
			}
		)
		tween.Completed:Once(clearHighScoreBanner)
		tween:Play()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showHighScoreBanner(score: number)
	showBanner(`NEW HIGH SCORE: {math.round(score)}`, Color3.fromRGB(255, 226, 120))
end

clearHighScoreBanner = function()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	if v20 then
		v20:Destroy()
		v20 = nil
	end
end

local v21 = {}

local function probeSoundLoad(soundId: string)
	if not v21[soundId] and pcall(function()
		v17:RequestAsset(soundId)
	end) then
		v21[soundId] = true
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	local v22 = nil
	pcall(function()
		ContentProvider:PreloadAsync({ sound }, function(_, p)
			v22 = p
		end)
	end)
	sound:Destroy()
	return v22 == Enum.AssetFetchStatus.Success
end

local v22 = {}

function RhythmLTMController.OnSongUnavailable(_, callback)
	table.insert(v22, callback)
end

local v23 = nil
local v24 = nil
local v25 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function setMobileControlsVisible(enabled: boolean)
	if v25 then
		v25.Enabled = enabled
	end
end

local LOBBYCAMERA = rhythm:WaitForChild("LOBBYCAMERA")
local maid = v.new()
local flag = false
local flag2 = false
local v26 = nil
local v27 = nil
local v28 = nil

local function applyPreview()
	local v29

	if not flag2 then
		v29 = v26
	end

	if v29 == v27 then
		return
	end

	if v28 then
		local v30 = v28
		v28 = nil
		local tween = TweenService:Create(v30, TweenInfo.new(0.6), {
			Volume = 0
		})
		tween.Completed:Once(function()
			v30:Destroy()
		end)
		tween:Play()
	end

	v27 = v29

	if not v29 then
		return
	end

	local v30 = v12[v29]
	local soundId

	if typeof(v30) == "table" then
		soundId = v30.SoundId
	else
		soundId = nil
	end

	if typeof(soundId) ~= "string" or soundId == "" then
		v27 = nil
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "RhythmPreview"
	sound.Looped = true
	sound.Volume = 0
	sound.Parent = script
	v28 = sound
	task.spawn(function()
		pcall(function()
			v17:RequestAsset(soundId)
		end)

		if v28 ~= sound then
			return
		end

		sound.SoundId = soundId
		sound:Play()
		TweenService:Create(sound, TweenInfo.new(0.6), {
			Volume = 0.15
		}):Play()
	end)
end

function RhythmLTMController.SetPreviewSong(_, p: string?)
	v26 = p
	applyPreview()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCamera(p)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = p.CFrame
end

local function enterMode()
	if flag then
		return
	end

	flag = true
	local v29 = {
		Ambient = Color3.fromRGB(195, 191, 222),
		Brightness = 1.79,
		ColorShift_Bottom = Color3.fromRGB(177, 114, 255),
		ColorShift_Top = Color3.fromRGB(197, 201, 255),
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 1,
		GlobalShadows = false,
		OutdoorAmbient = Color3.fromRGB(109, 109, 171),
		PrioritizeLightingQuality = true,
		ClockTime = 10.286,
		GeographicLatitude = 34.582,
		ExposureCompensation = 0.26
	}
	local lightingStyle = Enum.LightingStyle

	if lightingStyle then
		v29.LightingStyle = lightingStyle.Soft
	end

	local v30 = {}

	for k, v31 in v29 do
		local v32 = k
		local success, result = pcall(function()
			return Lighting[v32]
		end)

		if not success then
			continue
		end

		local v33 = k
		local v34 = v31

		if pcall(function()
			Lighting[v33] = v34
		end) then
			v30[k] = result
		else
			warn("rhythm lighting: could not set", k)
		end
	end

	maid:Add(function()
		for k, v31 in v30 do
			local v32 = k
			local v33 = v31
			pcall(function()
				Lighting[v32] = v33
			end)
		end
	end)
	local lightingInstances = ReplicatedStorage2.SongCharts:FindFirstChild("LightingInstances")

	if lightingInstances then
		for _, child in Lighting:GetChildren() do
			if child:IsA("PostEffect") then
				if child.Enabled then
					child.Enabled = false
					local v31 = child
					maid:Add(function()
						if v31.Parent then
							v31.Enabled = true
						end
					end)
				end
			elseif child:IsA("Sky") or child:IsA("Atmosphere") then
				local parent = child.Parent
				child.Parent = nil
				local v31 = child
				maid:Add(function()
					pcall(function()
						v31.Parent = parent
					end)
				end)
			end
		end

		for _, child in lightingInstances:GetChildren() do
			local add = maid:Add(child:Clone())
			add.Parent = Lighting
		end
	else
		warn("rhythm lighting: SongCharts.LightingInstances is missing")
	end

	local v31 = {
		AFK = true,
		Boosts = true,
		Bottom = true,
		Bottom2 = true,
		Brackets = true,
		ClanButton = true,
		CyberButton = true,
		DailyQuestsPage = true,
		Emote = true,
		EmotePC = true,
		MiddleStack = true,
		QuestArrow = true,
		QuestTracker = true,
		ToBooth = true,
		Top = true,
		TradeButton = true,
		Vip = true,
		WelcomeBackButton = true
	}
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local HUD = playerGui:FindFirstChild("HUD")
	local rightHUD = playerGui:FindFirstChild("RightHUD")

	local function hide(guiObject)
		if not guiObject:IsA("GuiObject") then
			return
		end

		local visible = guiObject.Visible
		guiObject.Visible = false
		maid:Add(guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
			if guiObject.Visible then
				guiObject.Visible = false
			end
		end))
		maid:Add(function()
			guiObject.Visible = visible
		end)
	end

	if HUD then
		for _, descendant in HUD:GetDescendants() do
			if v31[descendant.Name] then
				hide(descendant)
			end
		end

		local rhythmSongSelector = playerGui:FindFirstChild("RhythmSongSelector")

		if rhythmSongSelector and rhythmSongSelector:IsA("ScreenGui") then
			local displayOrder = HUD.DisplayOrder
			HUD.DisplayOrder = rhythmSongSelector.DisplayOrder + 1
			maid:Add(function()
				HUD.DisplayOrder = displayOrder
			end)
		end
	else
		warn("hud trim: PlayerGui.HUD is missing")
	end

	local hotbar = playerGui:FindFirstChild("Hotbar")

	if hotbar and hotbar:IsA("ScreenGui") and hotbar.Enabled then
		hotbar.Enabled = false
		maid:Add(function()
			hotbar.Enabled = true
		end)
	end

	local emoteWheel = playerGui:FindFirstChild("EmoteWheel")

	if emoteWheel and emoteWheel:IsA("ScreenGui") and emoteWheel.Enabled then
		emoteWheel.Enabled = false
		maid:Add(function()
			emoteWheel.Enabled = true
		end)
	end

	pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.EmotesMenu, false)
	local rhythmSongSelector = playerGui:FindFirstChild("RhythmSongSelector")
	local inner = rhythmSongSelector and rhythmSongSelector:FindFirstChild("Inner")
	local button = inner and inner:FindFirstChild("Return")

	if button and button:IsA("GuiButton") then
		local flag3 = false
		maid:Add(button.Activated:Connect(function()
			if flag3 then
				return
			end

			flag3 = true
			button.Active = false
			v15:RemoteEvent("PlaceTeleport"):FireServer("Default")
		end))
		maid:Add(function()
			button.Active = true
		end)
	else
		warn("rhythm: RhythmSongSelector.Inner.Return not found")
	end

	maid:Add(v9:OnClose(function(p)
		if p and p.Name == "RhythmSongSelector" then
			return
		end

		task.defer(function()
			if flag2 or not flag or v9._currentGui then
				return
			end

			v9:Open("RhythmSongSelector", true)
		end)
	end))

	if rightHUD and rightHUD:IsA("ScreenGui") and rightHUD.Enabled then
		rightHUD.Enabled = false
		maid:Add(function()
			rightHUD.Enabled = true
		end)
	end

	maid:Add(function()
		v26 = nil
		v27 = nil

		if v28 then
			v28:Destroy()
			v28 = nil
		end
	end)
	local touchEnabled = not GuiService:IsTenFootInterface() and UserInputService.TouchEnabled
	print(
		"[rhythm mobile] touch:",
		UserInputService.TouchEnabled,
		"keyboard:",
		UserInputService.KeyboardEnabled,
		"tenfoot:",
		GuiService:IsTenFootInterface(),
		"-> pad:",
		touchEnabled
	)

	if touchEnabled then
		if not pcall(function()
			local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
			local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 5)
			assert(playerModule, "PlayerModule not found")
			local controls = require3(playerModule):GetControls()
			controls:Disable()
			maid:Add(function()
				pcall(function()
					controls:Enable()
				end)
			end)
		end) then
			warn("[rhythm mobile] PlayerModule route failed, TouchGui latch is the only cover")
		end

		task.spawn(function()
			local touchGui = playerGui:WaitForChild("TouchGui", 5)

			if not (touchGui and touchGui:IsA("ScreenGui")) then
				return
			end

			touchGui.Enabled = false
			maid:Add(touchGui:GetPropertyChangedSignal("Enabled"):Connect(function()
				if touchGui.Enabled and flag then
					touchGui.Enabled = false
				end
			end))
			maid:Add(function()
				touchGui.Enabled = true
			end)
		end)
		local parent = maid:Add(Instance.new("ScreenGui"))
		parent.Name = "RhythmMobileControls"
		parent.ResetOnSpawn = false
		parent.IgnoreGuiInset = true
		parent.DisplayOrder = 30
		parent.Enabled = false
		parent.Parent = playerGui
		v25 = parent
		local frame = Instance.new("Frame")
		frame.Name = "LaneControls"
		frame.AnchorPoint = Vector2.new(0, 1)
		frame.Position = UDim2.new(0, 28, 1, -28)
		frame.Size = UDim2.fromOffset(194, 88)
		frame.BackgroundTransparency = 1
		frame.Parent = parent
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.Padding = UDim.new(0, 18)
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		uIListLayout.Parent = frame

		local function makeArrow(name: string, rotation: number, p: number, layoutOrder: number)
			local imageButton = Instance.new("ImageButton")
			imageButton.Name = name
			imageButton.Size = UDim2.fromOffset(88, 88)
			imageButton.LayoutOrder = layoutOrder
			imageButton.BackgroundColor3 = Color3.fromRGB(105, 105, 105)
			imageButton.BackgroundTransparency = 0.35
			imageButton.AutoButtonColor = true
			imageButton.BorderSizePixel = 0
			imageButton.Image = ""
			imageButton.Parent = frame
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 16)
			uICorner.Parent = imageButton
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = Color3.fromRGB(220, 220, 220)
			uIStroke.Thickness = 2
			uIStroke.Transparency = 0.35
			uIStroke.Parent = imageButton
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Arrow"
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.Size = UDim2.fromScale(0.62, 0.62)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = "rbxassetid://131177832655029"
			imageLabel.ImageColor3 = Color3.fromRGB(235, 235, 235)
			imageLabel.Rotation = rotation
			imageLabel.Parent = imageButton
			imageButton.MouseButton1Down:Connect(function()
				if v23 then
					v23(p)
				end
			end)
		end

		makeArrow("Left", 0, -1, 1)
		makeArrow("Right", 180, 1, 2)
		local imageButton = Instance.new("ImageButton")
		imageButton.Name = "Jump"
		imageButton.AnchorPoint = Vector2.new(1, 1)
		imageButton.Position = UDim2.new(1, -28, 1, -28)
		imageButton.Size = UDim2.fromOffset(101, 101)
		imageButton.BackgroundColor3 = Color3.fromRGB(105, 105, 105)
		imageButton.BackgroundTransparency = 0.35
		imageButton.AutoButtonColor = true
		imageButton.BorderSizePixel = 0
		imageButton.Image = ""
		imageButton.Parent = parent
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = imageButton
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = Color3.fromRGB(220, 220, 220)
		uIStroke.Thickness = 2
		uIStroke.Transparency = 0.35
		uIStroke.Parent = imageButton
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Arrow"
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Size = UDim2.fromScale(0.58, 0.58)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://131177832655029"
		imageLabel.ImageColor3 = Color3.fromRGB(235, 235, 235)
		imageLabel.Rotation = 90
		imageLabel.Parent = imageButton
		imageButton.MouseButton1Down:Connect(function()
			if v24 then
				v24()
			end
		end)
	end

	setCamera(LOBBYCAMERA) -- equivalent call inferred; original call site unknown
end

function RhythmLTMController.EnterMode(_)
	enterMode()
end

function RhythmLTMController.ExitMode(_)
	if not flag then
		return
	end

	flag = false
	maid:Clean()
end

local maid2 = v.new()
local maid3 = maid2:Extend()

local function addSwordToNPC(parent, sword, p: number?)
	local instance = v7.getInstance("Swords", sword)

	if not instance then
		return warn("Can't find sword", sword)
	end

	if v4:GetSword(sword) then
		local v29 = maid3:Add(assert(v4:EquipSwordTo(
			parent,
			sword,
			p,
			parent:GetAttribute("IgnoreAccessory") or parent:GetAttribute("CurrentEmote") == "Emote711"
		)))
		v29:SetAttribute("Sword", sword)
		v29.Name = "EquippedSword"
		local v30 = nil

		for _, child in parent:GetChildren() do
			if not child:GetAttribute("_swordAccessory") then
				continue
			end

			v30 = child
			break
		end

		if v30 then
			maid3:Add(v3.observeChildren(v30, function(instance2)
				if not instance2:HasTag("AnimatedAccessory") then
					return nil
				end

				instance2:RemoveTag("AnimatedAccessory")
				local animator = instance2:FindFirstChildWhichIsA("Animator", true)
				local walk = animator and animator:FindFirstChild("Walk", true)

				if animator and walk then
					maid3:Add(animator:LoadAnimation(walk)):Play()
					local v32 = v8[sword]

					if v32 and v32.walk then
						local id = v32.walk[1].id
						local v33 = maid3:Add(Instance.new("Animation"))
						v33.AnimationId = id
						maid3:Add(parent.Humanoid.Animator:LoadAnimation(v33)):Play()
					end
				end

				return nil
			end))
		end
	else
		local clone = maid3:Clone(instance)
		clone.Name = "EquippedSword"
		clone:SetAttribute("Sword", sword)

		if p and p ~= 1 then
			clone:ScaleTo(clone:GetScale() * p)
		end

		clone:PivotTo(parent:GetPivot())
		local torso = parent.Torso

		for _, child in torso.SwordWelds:GetChildren() do
			local child2 = clone:FindFirstChild(child.Name, true)
			child.Part0 = torso
			child.Part1 = child2
			child.Enabled = true
		end

		clone.Parent = parent
	end
end

local maid4 = maid2:Extend()

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(parent, animation)
	return (maid4:Add(parent.Humanoid.Animator:LoadAnimation(animation)))
end

local function updateRigSword(parent)
	local sword = parent:GetAttribute("Sword")

	if sword ~= parent:GetAttribute("LastSword") then
		parent:SetAttribute("LastSword", sword)
		maid3:Clean()
		local v29

		if sword then
			local instance = v6:GetInstance(sword)

			if instance and not parent:GetAttribute("IgnoreAccessory") then
				local parent2 = maid3:Add(Instance.new("Folder"))
				parent2.Name = "SwordAccessories"
				parent2:SetAttribute("_swordAccessory", true)
				parent2:SetAttribute("Seed", Random.new():NextNumber(0, 100))
				local clone = maid3:Clone(instance)
				v2.Physics.ResizePart(clone, 1)
				v29 = sword

				for _, part in clone:GetChildren() do
					local child = parent:FindFirstChild(part.Name)

					if child and part:IsA("BasePart") then
						part:PivotTo(child:GetPivot())
						part.CanCollide = false
						part.Anchored = false
						part.CanQuery = false
						part.CanTouch = false
						part.Massless = true
						part.Transparency = 1
						maid3:Add(v2.Physics.CreateWeld(part, child))
					end

					part.Parent = parent2
				end

				maid3:Remove(clone)
				parent2.Parent = parent
			else
				v29 = sword
			end
		end

		if v29 then
			addSwordToNPC(parent, v29, 1)
		end
	end

	local sword2 = parent:GetAttribute("Slash") and sword and v4:GetSword(sword)

	if sword2 then
		maid4:Clean()
		local animationType = sword2.AnimationType or "SlashEffect"
		print("play", animationType)
		character:SetAttribute("ServerParryCount", (character:GetAttribute("ServerParryCount") or 0) + 1)
		local v29 = { "Parry", "SuccessParry" }
		local successParryVariantCount = v5:GetSuccessParryVariantCount(parent, sword2.AnimationType, sword2.SwordType)

		if successParryVariantCount then
			v29[2] = `SuccessParry{(character:GetAttribute("ServerParryCount") or 0) % successParryVariantCount + 1}`
		end

		local animations = v5:GetAnimations(parent, v29, sword2.AnimationType, sword2.SwordType)
		local v30 = table.create(#animations)

		for k, animation in animations do
			local animation2 = loadAnimation(parent, animation) -- equivalent call inferred; original call site unknown
			animation2.Looped = false
			v30[k] = animation2
		end

		for _, v31 in v30 do
			v31:Play(0)
		end

		local slashOrigin = parent:FindFirstChild("SlashOrigin") or parent.Torso
		ReplicatedStorage2.Remotes.ParrySuccessClient:Fire(v5:GetSlashName(sword, sword2.SlashName), slashOrigin, sword)
	end
end

function RhythmLTMController:Play(p: string, flag3: boolean, p2: string?, callback)
	maid2:Clean()
	clearHighScoreBanner()
	maid3 = maid2:Extend()
	maid4 = maid2:Extend()
	local v29 = v12[p]
	assert(v29, "Missing chart: " .. p)
	local resolved = v13.Resolve(v29, p2)
	assert(resolved.Notes, "Chart is missing Notes")
	local v30 = false
	local v31 = 0

	if not flag3 then
		local success, result = pcall(function()
			return v16.Client:WaitReplion("Data")
		end)

		if success and result then
			local v32 = result:Get({
				"RhythmLTM",
				"Songs",
				p,
				"Difficulties",
				resolved.Difficulty
			})

			if typeof(v32) == "number" then
				v31 = v32
			end
		end
	end

	local session = v14.NewSession(#resolved.Notes)
	local endless

	if flag3 then
		endless = nil
	else
		endless = resolved.Endless
	end

	local playbackSpeed = not endless and 1 or endless.StartRate or 1
	local BPM = resolved.BPM
	local basePulseBeats = resolved.BasePulseBeats or 2
	local generatorSettings = resolved.GeneratorSettings or {}
	local v33 = 60 / BPM
	local speed = 24 / (v33 * basePulseBeats)
	local v35 = 72 / speed
	local v36 = not resolved.Judgement and 0.15 or resolved.Judgement.Miss

	if resolved.Judgement then
		local _ = resolved.Judgement.Perfect
	end

	if resolved.Judgement then
		local _ = resolved.Judgement.Good
	end

	local hardSameLaneGapBeats = generatorSettings.HardSameLaneGapBeats or 0.75
	local v37 = v33 * hardSameLaneGapBeats
	print("Selected chart:", p)
	print("Chart mode:", generatorSettings.Mode or "unknown")
	print("Actual BPM:", BPM)
	print("Base pulse beats:", basePulseBeats)
	print("Beat seconds:", v33)
	print("Speed:", speed)
	print("Approach seconds:", v35)
	print("Force same lane gap beats:", hardSameLaneGapBeats)
	print("Chart notes:", #resolved.Notes)
	enterMode()
	setCamera(cameraPart) -- equivalent call inferred; original call site unknown
	flag2 = true
	applyPreview()
	setMobileControlsVisible(true) -- equivalent call inferred; original call site unknown
	local parent = maid2:Add(Instance.new("ScreenGui"))
	parent.Name = "RhythmLoading"
	parent.ResetOnSpawn = false
	parent.IgnoreGuiInset = true
	parent.DisplayOrder = 60
	parent.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	local rhythmSongSelector = Players.LocalPlayer.PlayerGui:FindFirstChild("RhythmSongSelector")
	local black = rhythmSongSelector and rhythmSongSelector:FindFirstChild("Black")
	local v40

	if black and black:IsA("Frame") then
		v40 = black:Clone()

		for _, child in v40:GetChildren() do
			child:Destroy()
		end
	else
		v40 = Instance.new("Frame")
		v40.Size = UDim2.fromScale(1.5, 1.5)
		v40.BackgroundColor3 = Color3.new(0, 0, 0)
		v40.BorderSizePixel = 0
	end

	v40.AnchorPoint = Vector2.new(0.5, 0.5)
	v40.Position = UDim2.fromScale(0.5, 0.5)
	v40.BackgroundTransparency = 0
	v40.Visible = true
	v40.ZIndex = 0
	v40.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(0.85, 0.16)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0.4
	textLabel.Text = "LOADING SONG"
	textLabel.ZIndex = 2
	textLabel.Parent = parent
	local collisionPart = rhythm:WaitForChild("CollisionPart")
	local v41 = maid2:Add(Players:GetHumanoidDescriptionFromUserIdAsync(Players.LocalPlayer.UserId))
	local v42 = maid2:Add(Players:CreateHumanoidModelFromDescriptionAsync(v41, Enum.HumanoidRigType.R6))
	maid2:Remove(v41)
	local rigOffset = getRigOffset(v42) -- equivalent call inferred; original call site unknown
	v42:PivotTo(pivot * rigOffset)
	v42.HumanoidRootPart.Anchored = true
	v42.Parent = runtime
	print("set rig")

	local function equippedSword()
		local localPlayer = Players.LocalPlayer
		local character2 = localPlayer.Character
		local currentlyEquippedSword = localPlayer:GetAttribute("CurrentlyEquippedSword")
		local currentlyEquippedSword2

		if character2 then
			currentlyEquippedSword2 = character2:GetAttribute("CurrentlyEquippedSword")
		end

		local v44

		if character2 then
			v44 = character2:GetAttribute("OriginalSword")
		end

		for _, v45 in { currentlyEquippedSword, currentlyEquippedSword2, v44 } do
			if typeof(v45) == "string" and v45 ~= "" and v4:GetSword(v45) then
				return v45
			end
		end

		return "Base Sword"
	end

	local function refreshRigSword()
		local v43 = equippedSword()
		v42:SetAttribute("Sword", v43)
		local success, result = pcall(updateRigSword, v42)

		if not success then
			warn("rhythm rig sword failed for", v43, "-", result)

			if v43 ~= "Base Sword" then
				v42:SetAttribute("Sword", "Base Sword")
				pcall(updateRigSword, v42)
			end
		end
	end

	refreshRigSword()
	print("Rhythm rig sword:", v42:GetAttribute("Sword"))
	maid2:Add(Players.LocalPlayer:GetAttributeChangedSignal("CurrentlyEquippedSword"):Connect(refreshRigSword))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchCharacter(character2)
		maid2:Add(character2:GetAttributeChangedSignal("CurrentlyEquippedSword"):Connect(refreshRigSword))
		refreshRigSword()
	end

	if Players.LocalPlayer.Character then
		watchCharacter(Players.LocalPlayer.Character) -- equivalent call inferred; original call site unknown
	end

	maid2:Add(Players.LocalPlayer.CharacterAdded:Connect(watchCharacter))
	maid2:Add(v42:GetAttributeChangedSignal("Slash"):Connect(function()
		updateRigSword(v42)
	end))
	local v43 = maid2:Add(Instance.new("Part"))
	v43.Name = "SlashOrigin"
	v43.Size = createVector(1, 1, 1)
	v43.Transparency = 1
	v43.Anchored = true
	v43.CanCollide = false
	v43.CanQuery = false
	v43.CanTouch = false
	v43.Parent = v42
	local animator = v42:WaitForChild("Humanoid"):WaitForChild("Animator")
	local maid5 = maid2:Extend()

	local function playSwordIdle()
		maid5:Clean()
		local sword = v42:GetAttribute("Sword")
		local sword2

		if typeof(sword) == "string" then
			sword2 = v4:GetSword(sword)
		else
			sword2 = nil
		end

		if not sword2 then
			return
		end

		local success, result = pcall(function()
			return v5:GetAnimations(v42, "Idle", sword2.AnimationType, sword2.SwordType)
		end)

		if not success or typeof(result) ~= "table" then
			return
		end

		for _, animation in result do
			local v44 = maid5:Add(animator:LoadAnimation(animation))
			v44.Looped = true
			v44.Priority = Enum.AnimationPriority.Idle
			v44:Play()
		end
	end

	playSwordIdle()
	maid2:Add(v42:GetAttributeChangedSignal("Sword"):Connect(playSwordIdle))
	local v44 = maid2:Add(animator:LoadAnimation(script:WaitForChild("Run")))
	v44:AdjustSpeed(speed / 36)
	v44:Play()
	local v45 = maid2:Add(animator:LoadAnimation(script:WaitForChild("Jump")))
	local v46 = maid2:Add(animator:LoadAnimation(script:WaitForChild("Fall")))
	local v47 = maid2:Add(map:Clone())
	v47.Parent = runtime
	local pivot2 = v47:GetPivot()
	local size = collisionPart.Size
	local transparency = collisionPart.Transparency
	collisionPart.Size = size - createVector(0.5, 0.9, 0.3)
	collisionPart.Transparency = 1
	maid2:Add(function()
		collisionPart.Size = size
		collisionPart.Transparency = transparency
	end)
	local v48 = -pivot2.LookVector
	local v49 = {}

	for _, v50 in {
		{
			Name = "Track",
			Jitter = { 0, 0, 0 }
		},
		{
			Name = "Buildings",
			Jitter = { 3, -3, -9 }
		}
	} do
		local name = v50.Name
		local child = v47.Decoration:FindFirstChild(name)

		if child then
			local segments = {}

			for i = 1, 3 do
				local model = Instance.new("Model")
				model.Name = `{name}_Segment{i}`
				local v52

				if i == 1 then
					v52 = child
				else
					v52 = child:Clone()
				end

				v52.Parent = model
				model.Parent = v47.Decoration
				segments[i] = model
			end

			local v52 = 1e999
			local v53 = -1e999

			for _, part in segments[1]:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				local objectSpace = pivot2:ToObjectSpace(part.CFrame)
				local v54 = math.abs(objectSpace.RightVector.Z) * part.Size.X / 2 + math.abs(objectSpace.UpVector.Z) * part.Size.Y / 2 + math.abs(objectSpace.LookVector.Z) * part.Size.Z / 2
				v52 = math.min(v52, objectSpace.Position.Z - v54)
				v53 = math.max(v53, objectSpace.Position.Z + v54)
			end

			local length = v53 - v52

			if length <= 0 then
				warn("carousel: could not measure", name)
			else
				table.insert(v49, {
					Segments = segments,
					Length = length,
					Jitter = v50.Jitter,
					BasePivot = segments[1]:GetPivot()
				})
			end
		else
			warn("carousel: Map.Decoration." .. name .. " is missing")
		end
	end

	local v50 = nil
	local pivot3 = pivot2

	local function updateScrollers(p3: number)
		if v50 then
			v50:PivotTo(pivot3 + v48 * -p3)
		end

		for _, v51 in v49 do
			local v52 = v51.Length * 3

			for k, segment in v51.Segments do
				local v53 = ((k - 1) * v51.Length - p3) % v52 - v51.Length
				local v54 = not v51.Jitter and 0 or v51.Jitter[k] or 0
				segment:PivotTo(v51.BasePivot + v48 * (v53 + v54))
			end
		end
	end

	updateScrollers(0)
	local sound = script:WaitForChild("Sound")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fetchSound()
		return (probeSoundLoad(resolved.SoundId))
	end

	local function abortSongLoad()
		warn(
			"rhythm: sound failed to load, aborting -",
			p,
			resolved.SoundId,
			"- check the asset's Experiences grant for THIS universe"
		)
		showBanner("ERROR LOADING SONG", Color3.fromRGB(255, 90, 90))

		for _, callback2 in v22 do
			task.spawn(callback2, p)
		end

		flag2 = false
		applyPreview()
		setMobileControlsVisible(false) -- equivalent call inferred; original call site unknown
		setCamera(LOBBYCAMERA) -- equivalent call inferred; original call site unknown
		maid2:Clean()
		callback()
	end

	local sound3 = fetchSound() -- equivalent call inferred; original call site unknown

	if not sound3 then
		warn("rhythm: sound fetch did not succeed, retrying -", p)
		task.wait(0.2)
		sound3 = probeSoundLoad(resolved.SoundId)
	end

	if not sound3 then
		abortSongLoad()
		return
	end

	sound.SoundId = resolved.SoundId
	sound.PlaybackSpeed = playbackSpeed
	local v52 = os.clock() + 3

	while not sound.IsLoaded and os.clock() < v52 do
		task.wait(0.05)
	end

	if not sound.IsLoaded then
		abortSongLoad()
		return
	end

	print("sound loaded")
	local timeLength = sound.TimeLength
	local v53 = not (timeLength > 0) and 0 or #resolved.Notes / timeLength
	local v54 = not (v53 > 0) and 0 or 1 / (v53 * 2)
	print("Average balls per second:", v53)
	print("Parry cooldown:", v54)
	local parent2 = maid2:Add(Instance.new("Folder"))
	parent2.Name = "ActiveBalls"
	parent2.Parent = runtime

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getHitOffsets(p3)
		if p3.HitOffsets then
			return p3.HitOffsets
		end

		return { 0 }
	end

	local function getNoteLastHitTime(p3)
		local v56 = 0

		if p3.HitOffsets then
			for _, hitOffset in p3.HitOffsets do
				if v56 < hitOffset then
					v56 = hitOffset
				end
			end
		end

		return p3.HitTime + v56
	end

	local function getFirstHitOffset(p3)
		local hitOffsets = getHitOffsets(p3) -- equivalent call inferred; original call site unknown
		local v56 = hitOffsets[1] or 0

		for _, hitOffset in hitOffsets do
			if hitOffset < v56 then
				v56 = hitOffset
			end
		end

		return v56
	end

	local function getFirstTargetTime(p3)
		local hitTime = p3.HitTime
		local hitOffsets = getHitOffsets(p3) -- equivalent call inferred; original call site unknown
		local v56 = hitOffsets[1] or 0

		for _, hitOffset in hitOffsets do
			if hitOffset < v56 then
				v56 = hitOffset
			end
		end

		return hitTime + v56
	end

	local function getSpawnTimeForNote(p3)
		local hitTime = p3.HitTime
		local hitOffsets = getHitOffsets(p3) -- equivalent call inferred; original call site unknown
		local v56 = hitOffsets[1] or 0

		for _, hitOffset in hitOffsets do
			if hitOffset < v56 then
				v56 = hitOffset
			end
		end

		return hitTime + v56 - v35
	end

	local function applyChartLaneSafety()
		table.sort(resolved.Notes, function(a, b)
			return a.HitTime < b.HitTime
		end)

		for i = 1, #resolved.Notes do
			local note = resolved.Notes[i]

			if note.Lane < -1 then
				note.Lane = -1
			elseif note.Lane > 1 then
				note.Lane = 1
			end

			if not (i > 1) then
				continue
			end

			local note2 = resolved.Notes[i - 1]
			local hitTime = note.HitTime
			local v56 = 0

			if note2.HitOffsets then
				for _, hitOffset in note2.HitOffsets do
					if v56 < hitOffset then
						v56 = hitOffset
					end
				end
			end

			if hitTime - (note2.HitTime + v56) <= v37 then
				note.Lane = note2.Lane
			end
		end
	end

	applyChartLaneSafety()
	v11.Generate({
		Chart = resolved,
		TemplatesFolder = obstacles,
		Pivot = pivot,
		Map = v47,
		MapStartPivot = pivot2,
		Speed = speed,
		LaneWidth = 6,
		MoveCooldown = 0.05,
		ProbeWidth = 4.5,
		JumpVelocity = 36,
		Gravity = 96,
		Trove = maid2,
		Debug = false
	})
	local generatedObstacles = v47:FindFirstChild("GeneratedObstacles")

	if generatedObstacles then
		local parent3 = maid2:Add(Instance.new("Model"))
		parent3.Name = "ObstacleCarrier"
		generatedObstacles.Parent = parent3
		parent3.Parent = v47
		v50 = parent3
		pivot3 = parent3:GetPivot()
	else
		warn("obstacles: GeneratedObstacles missing after Generate")
	end

	local function getEarliestSpawnTime()
		local v56 = 1e999

		for _, note in resolved.Notes do
			local hitTime = note.HitTime
			local hitOffsets = getHitOffsets(note) -- equivalent call inferred; original call site unknown
			local v57 = hitOffsets[1] or 0

			for _, hitOffset in hitOffsets do
				if hitOffset < v57 then
					v57 = hitOffset
				end
			end

			local v58 = hitTime + v57 - v35

			if v58 < v56 then
				v56 = v58
			end
		end

		if v56 == 1e999 then
			return 0
		end

		return v56
	end

	local v56 = 1e999

	for _, note in resolved.Notes do
		local hitTime = note.HitTime
		local hitOffsets = getHitOffsets(note) -- equivalent call inferred; original call site unknown
		local v57 = hitOffsets[1] or 0

		for _, hitOffset in hitOffsets do
			if hitOffset < v57 then
				v57 = hitOffset
			end
		end

		local v58 = hitTime + v57 - v35

		if v58 < v56 then
			v56 = v58
		end
	end

	local v57 = v56 == 1e999 and 0 or v56
	local v58 = math.max(0, -v57)
	print("Earliest spawn time:", v57)
	print("Music pre-roll seconds:", v58)
	local target = 0
	local v60 = -1e999
	local v61 = -1e999
	local v62 = 0
	local v63 = 0
	local v64 = 0
	local now = nil
	local v65 = v10.new(0)
	v65.Damper = 0.75
	v65.Speed = 21
	local v66 = {}
	local v67 = 1
	local flag4 = false
	local v68 = nil
	local flag5 = false
	local v69 = false
	local v70 = false
	local v71 = false
	local v72 = false
	local flag6 = false
	local flag7 = false
	local flag8 = false
	local v73 = nil
	local v74 = math.clamp(v33 * 0.5, math.min(v36, 0.5), 0.5)
	local error = math.min(v36, not (resolved.Judgement and resolved.Judgement.Ok) and 0.15 or resolved.Judgement.Ok)
	local v76 = v36 * 1.5
	local v77 = {
		tier = "Ok",
		error = error
	}
	local parent4 = maid2:Add(Instance.new("ScreenGui"))
	parent4.Name = "RhythmJudgement"
	parent4.ResetOnSpawn = false
	parent4.IgnoreGuiInset = true
	parent4.Parent = Players.LocalPlayer.PlayerGui
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.fromScale(0.4, 0.1)
	textLabel2.Position = UDim2.fromScale(0.5, 0.12)
	textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = Enum.Font.GothamBlack
	textLabel2.TextScaled = true
	textLabel2.TextStrokeTransparency = 0.4
	textLabel2.TextTransparency = 1
	textLabel2.Parent = parent4
	local clone = textLabel2:Clone()
	clone.Size = UDim2.fromScale(0.3, 0.06)
	clone.Position = UDim2.fromScale(0.5, 0.2)
	clone.TextColor3 = Color3.new(1, 1, 1)
	clone.Parent = parent4
	local v79 = {
		Perfect = Color3.fromRGB(120, 220, 255),
		Great = Color3.fromRGB(120, 255, 150),
		Good = Color3.fromRGB(255, 220, 110),
		Ok = Color3.fromRGB(255, 160, 90),
		Miss = Color3.fromRGB(255, 90, 90)
	}
	local v80 = nil

	local function showJudgement(value: string)
		textLabel2.Text = string.upper(value)
		textLabel2.TextColor3 = v79[value] or Color3.new(1, 1, 1)
		textLabel2.TextTransparency = 0
		clone.Text = not (session.combo > 1) and "" or `{session.combo}x`
		clone.TextTransparency = session.combo > 1 and 0 or 1

		if v80 then
			v80:Cancel()
		end

		v80 = TweenService:Create(textLabel2, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1
		})
		v80:Play()
	end

	local v81 = -1e999
	local flag9 = false
	local v82 = 0
	local v83 = -1e999
	local flag10 = false
	local instance = v7.getInstance("SwordFX", "ParticleShine")
	local parryAttempt = instance and instance:FindFirstChild("ParryAttempt")

	if not (parryAttempt and parryAttempt:IsA("Sound")) then
		parryAttempt = nil
	end

	local function clampParrySound(sound2)
		if sound2:IsA("Sound") then
			sound2.Volume = math.min(sound2.Volume, 0.05)
		end
	end

	maid2:Add(v42.Torso.ChildAdded:Connect(clampParrySound))
	maid2:Add(v43.ChildAdded:Connect(clampParrySound))

	local function playGrabSound()
		if not parryAttempt then
			return
		end

		local clone2 = parryAttempt:Clone()
		clone2.PlaybackSpeed = math.random(95, 120) * 0.01
		clone2.Parent = v42.Torso
		clone2:Play()
		maid2:Add(task.delay(2, function()
			clone2:Destroy()
		end))
	end

	local function playGrabAnimation()
		local sword = v42:GetAttribute("Sword")
		local sword2 = sword and v4:GetSword(sword)

		if not sword2 then
			return
		end

		for _, animation in v5:GetAnimations(v42, { "GrabParry" }, sword2.AnimationType, sword2.SwordType) do
			local track = v42.Humanoid.Animator:LoadAnimation(animation)
			track.Looped = false
			track:Play(0)
			maid2:Add(task.delay(v74 + 0.3, function()
				track:Stop()
				track:Destroy()
			end))
		end
	end

	local function clearParryHold(flag11: boolean)
		if flag9 and flag11 then
			v14.RegisterEmptyClick(session)
		end

		flag9 = false
		v81 = -1e999
	end

	local textLabel3 = nil
	local center = nil
	local enabled = false
	local text = ""
	local visible = true
	local visible2 = true
	local rhythmParryTutorialUI

	if flag3 then
		rhythmParryTutorialUI = Players.LocalPlayer.PlayerGui:FindFirstChild("RhythmParryTutorialUI")

		if rhythmParryTutorialUI then
			textLabel3 = rhythmParryTutorialUI:FindFirstChild("TextLabel")
			center = rhythmParryTutorialUI:FindFirstChild("Center")
			enabled = rhythmParryTutorialUI.Enabled

			if textLabel3 then
				text = textLabel3.Text
				visible = textLabel3.Visible
			end

			if center then
				visible2 = center.Visible
			end
		end
	else
		rhythmParryTutorialUI = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function restoreTutorialPrompt()
		if not rhythmParryTutorialUI then
			return
		end

		rhythmParryTutorialUI.Enabled = enabled

		if textLabel3 then
			textLabel3.Text = text
			textLabel3.Visible = visible
		end

		if center then
			center.Visible = visible2
		end
	end

	local function showTutorialPrompt(p3: string)
		if not (rhythmParryTutorialUI and textLabel3) then
			return
		end

		rhythmParryTutorialUI.Enabled = true
		textLabel3.Visible = true
		textLabel3.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2">{p3}</stroke>`

		if center then
			center.Visible = false
		end
	end

	local function updateTutorialPrompt()
		if not flag3 or flag7 then
			return
		end

		if v68 then
			if v68.Note.Lane == target then
				if rhythmParryTutorialUI then
					if not textLabel3 then
						return
					end

					rhythmParryTutorialUI.Enabled = true
					textLabel3.Visible = true
					textLabel3.Text = "<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"2\">HIT THE BALL!</stroke>"

					if center then
						center.Visible = false
					end
				end
			elseif rhythmParryTutorialUI then
				if not textLabel3 then
					return
				end

				rhythmParryTutorialUI.Enabled = true
				textLabel3.Visible = true
				textLabel3.Text = "<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"2\">MOVE TO THE BALL'S LANE + HIT IT!</stroke>"

				if center then
					center.Visible = false
				end
			end
		elseif v72 and not v69 then
			if rhythmParryTutorialUI then
				if not textLabel3 then
					return
				end

				rhythmParryTutorialUI.Enabled = true
				textLabel3.Visible = true
				textLabel3.Text = "<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"2\">JUMP OVER THE OBSTACLE!</stroke>"

				if center then
					center.Visible = false
				end
			end
		elseif flag5 then
			if not v69 and rhythmParryTutorialUI then
				if not textLabel3 then
					return
				end

				rhythmParryTutorialUI.Enabled = true
				textLabel3.Visible = true
				textLabel3.Text = "<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"2\">JUMP OVER THE OBSTACLE!</stroke>"

				if center then
					center.Visible = false
				end
			end
		elseif rhythmParryTutorialUI then
			if not textLabel3 then
				return
			end

			rhythmParryTutorialUI.Enabled = true
			textLabel3.Visible = true
			textLabel3.Text = "<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"2\">MOVE TO THE BALL'S LANE + HIT IT!</stroke>"

			if center then
				center.Visible = false
			end
		end
	end

	local flag11 = false
	local lastTime = os.clock()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getPredictedChartTime()
		return os.clock() - lastTime - v58
	end

	local function maybeStartMusic()
		if flag11 then
			return
		end

		if getPredictedChartTime() >= 0 then
			sound.TimePosition = 0
			sound:Play()
			flag11 = true
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getChartTime()
		if flag11 then
			return sound.TimePosition - 0
		end

		return getPredictedChartTime() - 0
	end

	local function getInputTime()
		local chartTime = getChartTime() -- equivalent call inferred; original call site unknown
		return chartTime + 0.14
	end

	local function getMapDistanceForChartTime(p3: number)
		if p3 <= 0 then
			return 0
		end

		return p3 * speed
	end

	local function stop()
		if flag8 then
			return
		end

		flag8 = true
		flag9 = false
		v81 = -1e999

		if not flag3 then
			local summary = v14.Summary(session)
			local v84 = string.lower((tostring(resolved.Difficulty))) == "endless"
			v15:RemoteEvent("Rhythm/IncreasePlayCount"):FireServer(p)

			if v30 or v84 then
				v15:RemoteEvent("Rhythm/SetBestScore"):FireServer(p, resolved.Difficulty, summary.Score)

				if v31 < summary.Score then
					showHighScoreBanner(summary.Score) -- equivalent call inferred; original call site unknown
				end
			end

			if v30 and not v84 then
				v15:RemoteEvent("Rhythm/SongCompleted"):FireServer(p, resolved.Difficulty)
			end
		end

		if v73 then
			maid2:Remove(v73)
			v73 = nil
		end

		flag2 = false
		applyPreview()
		setMobileControlsVisible(false) -- equivalent call inferred; original call site unknown
		restoreTutorialPrompt() -- equivalent call inferred; original call site unknown
		sound:Stop()
		setCamera(LOBBYCAMERA) -- equivalent call inferred; original call site unknown
		maid2:Add(task.delay(1, function()
			maid2:Clean()
			callback()
		end))
	end

	local function completeTutorial()
		if flag7 then
			return
		end

		flag7 = true
		v15:RemoteEvent("Rhythm/TutorialCompleted"):FireServer()
		local volume = sound.Volume
		maid2:Add(function()
			sound.Volume = volume
		end)
		local tween = TweenService:Create(sound, TweenInfo.new(1), {
			Volume = 0
		})
		tween.Completed:Once(function()
			if sound.Playing then
				sound:Pause()
			end
		end)
		tween:Play()
		local parent3 = maid2:Add(Instance.new("ScreenGui"))
		parent3.Name = "RhythmTutorialOutro"
		parent3.ResetOnSpawn = false
		parent3.IgnoreGuiInset = true
		parent3.DisplayOrder = 45
		parent3.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		local rhythmSongSelector2 = Players.LocalPlayer.PlayerGui:FindFirstChild("RhythmSongSelector")
		local black2 = rhythmSongSelector2 and rhythmSongSelector2:FindFirstChild("Black")
		local v85

		if black2 and black2:IsA("Frame") then
			v85 = black2:Clone()

			for _, child in v85:GetChildren() do
				child:Destroy()
			end
		else
			v85 = Instance.new("Frame")
			v85.Size = UDim2.fromScale(1.5, 1.5)
			v85.BackgroundColor3 = Color3.new(0, 0, 0)
			v85.BorderSizePixel = 0
		end

		v85.AnchorPoint = Vector2.new(0.5, 0.5)
		v85.Position = UDim2.fromScale(0.5, 0.5)
		v85.BackgroundTransparency = 1
		v85.Visible = true
		v85.ZIndex = 0
		v85.Parent = parent3
		local textLabel4 = Instance.new("TextLabel")
		textLabel4.Size = UDim2.fromScale(0.85, 0.2)
		textLabel4.Position = UDim2.fromScale(0.5, 0.5)
		textLabel4.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel4.BackgroundTransparency = 1
		textLabel4.Font = Enum.Font.GothamBlack
		textLabel4.TextScaled = true
		textLabel4.TextColor3 = Color3.new(1, 1, 1)
		textLabel4.TextStrokeTransparency = 0.4
		textLabel4.TextTransparency = 1
		textLabel4.Text = "TUTORIAL COMPLETED!"
		textLabel4.ZIndex = 2
		textLabel4.Parent = parent3
		TweenService:Create(v85, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		}):Play()
		TweenService:Create(textLabel4, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
		maid2:Add(task.delay(1.5, function()
			TweenService:Create(textLabel4, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1
			}):Play()
			maid2:Add(task.delay(0.5, stop))
		end))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function die(p3: string)
		if flag3 or flag4 then
			return
		end

		flag4 = true
		warn("dead:", p3)
		stop()
	end

	local v84 = 100
	local now2 = -1e999
	local frame = Instance.new("Frame")
	frame.Name = "Health"
	frame.Size = UDim2.fromScale(0.26, 0.026)
	frame.Position = UDim2.fromScale(0.5, 0.045)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.Parent = parent4
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.4
	uIStroke.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "Fill"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = Color3.fromRGB(90, 230, 120)
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	uICorner:Clone().Parent = frame2
	local textLabel4 = Instance.new("TextLabel")
	textLabel4.Size = UDim2.fromScale(1, 1)
	textLabel4.BackgroundTransparency = 1
	textLabel4.Font = Enum.Font.GothamBold
	textLabel4.TextScaled = true
	textLabel4.TextColor3 = Color3.new(1, 1, 1)
	textLabel4.TextStrokeTransparency = 0.3
	textLabel4.ZIndex = 2
	textLabel4.Parent = frame
	local color = Color3.fromRGB(90, 230, 120)
	local color2 = Color3.fromRGB(255, 190, 60)
	local color3 = Color3.fromRGB(255, 70, 70)
	local v85 = nil

	local function setHealth(value: number)
		v84 = math.clamp(value, 0, 100)
		local v86 = v84 / 100
		textLabel4.Text = tostring((math.floor(v84)))
		local backgroundColor

		if v86 > 0.5 then
			backgroundColor = color2:Lerp(color, (v86 - 0.5) * 2)
		else
			backgroundColor = color3:Lerp(color2, v86 * 2)
		end

		if v85 then
			v85:Cancel()
		end

		v85 = TweenService:Create(frame2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(v86, 1),
			BackgroundColor3 = backgroundColor
		})
		v85:Play()

		if v84 <= 0 then
			die("out of health") -- equivalent call inferred; original call site unknown
		end
	end

	local function damage(p3: number)
		uIStroke.Color = Color3.fromRGB(255, 80, 80)
		uIStroke.Thickness = 4
		uIStroke.Transparency = 0
		TweenService:Create(uIStroke, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Color = Color3.new(0, 0, 0),
			Thickness = 2,
			Transparency = 0.4
		}):Play()
		setHealth(v84 - p3)
	end

	setHealth(100)
	local v86 = maid2:Add(Instance.new("Highlight"))
	v86.Name = "RhythmDamage"
	v86.FillColor = Color3.fromRGB(255, 40, 40)
	v86.OutlineColor = Color3.fromRGB(255, 130, 130)
	v86.FillTransparency = 1
	v86.OutlineTransparency = 1
	v86.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	v86.Adornee = v42
	v86.Parent = v42
	local v87 = nil

	local function flashDamage()
		if v87 then
			v87:Cancel()
		end

		v86.FillTransparency = 0.4
		v86.OutlineTransparency = 0
		v87 = TweenService:Create(v86, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FillTransparency = 1,
			OutlineTransparency = 1
		})
		v87:Play()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function boom(position: Vector3)
		local explosion = Instance.new("Explosion")
		explosion.Position = position
		explosion.BlastPressure = 0
		explosion.DestroyJointRadiusPercent = 0
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Parent = workspace
		Debris:AddItem(explosion, 1)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getTargetTime(data)
		local note = data.Note
		local hitOffset = data.HitOffsets[data.NextHitIndex]
		return note.HitTime + hitOffset
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeBall(p3)
		local index = table.find(v66, p3)

		if index then
			table.remove(v66, index)
		end

		if p3.Part then
			maid2:Remove(p3.Part)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBallVisual(data)
		local chartTime = getChartTime() -- equivalent call inferred; original call site unknown
		local note = data.Note
		local targetTime = getTargetTime(data) -- equivalent call inferred; original call site unknown
		local v88 = note.Lane * 6
		local v89 = (chartTime - targetTime) * speed
		data.Part.CFrame = pivot * CFrame.new(v88, 4, v89)
	end

	local function createBallPart(data)
		local v88 = maid2:Add(Instance.new("Part"))
		v88.Name = "Ball_" .. tostring(data.Type)
		v88.Shape = Enum.PartType.Ball
		v88.Size = createVector(2.8, 2.8, 2.8)
		v88.Anchored = true
		v88.CanCollide = false
		v88.Material = Enum.Material.Neon

		if data.Type == "blue" then
			v88.Color = Color3.fromRGB(70, 170, 255)
		else
			v88.Color = Color3.fromRGB(255, 70, 70)
		end

		v88:SetAttribute("HitTime", data.HitTime)
		local hitTime = data.HitTime
		local hitOffsets = getHitOffsets(data) -- equivalent call inferred; original call site unknown
		local v89 = hitOffsets[1] or 0

		for _, hitOffset in hitOffsets do
			if hitOffset < v89 then
				v89 = hitOffset
			end
		end

		v88:SetAttribute("FirstTargetTime", hitTime + v89)
		local hitTime2 = data.HitTime
		local hitOffsets2 = getHitOffsets(data) -- equivalent call inferred; original call site unknown
		local v91 = hitOffsets2[1] or 0

		for _, hitOffset in hitOffsets2 do
			if hitOffset < v91 then
				v91 = hitOffset
			end
		end

		v88:SetAttribute("SpawnTime", hitTime2 + v91 - v35)
		v88:SetAttribute("ApproachSeconds", v35)
		v88:SetAttribute("Lane", data.Lane)
		v88:SetAttribute("Type", data.Type)
		v88:SetAttribute("Bar", data.Bar or -1)
		v88:SetAttribute("Beat", data.Beat or -1)
		v88.Parent = parent2
		return v88
	end

	local function spawnBall(note)
		local v88 = {
			Note = note,
			Part = createBallPart(note),
			NextHitIndex = 1,
			HitOffsets = getHitOffsets(note)
		}
		table.insert(v66, v88)
		updateBallVisual(v88) -- equivalent call inferred; original call site unknown
	end

	local function spawnDueBalls(p3: number)
		while v67 <= #resolved.Notes do
			local note = resolved.Notes[v67]
			local hitTime = note.HitTime
			local hitOffsets = getHitOffsets(note) -- equivalent call inferred; original call site unknown
			local v88 = hitOffsets[1] or 0

			for _, hitOffset in hitOffsets do
				if hitOffset < v88 then
					v88 = hitOffset
				end
			end

			if hitTime + v88 - v35 - v35 * (playbackSpeed - 1) <= p3 then
				spawnBall(note)
				v67 += 1
			else
				break
			end
		end
	end

	local function printNoteTimingDebug(_, _: string) end

	local function registerBallHit(state, p3: string)
		local v88 = v68 == state
		v42:SetAttribute("Slash", true)
		maid2:Add(task.delay(0.1, function()
			v42:SetAttribute("Slash", false)
		end))
		local note = state.Note

		if p3 ~= "TUTORIAL_CORRECTION" then
			showJudgement(p3)
		end

		if flag3 and not flag5 and note.Lane ~= 0 then
			flag5 = true
			updateTutorialPrompt()
		end

		state.NextHitIndex += 1

		if state.NextHitIndex > #state.HitOffsets then
			removeBall(state) -- equivalent call inferred; original call site unknown
		else
			state.GraceSince = nil

			if note.Type == "blue" then
				state.Part.Size = createVector(3.3, 3.3, 3.3)
				state.Part.Color = Color3.fromRGB(120, 220, 255)
			end

			updateBallVisual(state) -- equivalent call inferred; original call site unknown
		end

		if v88 then
			v68 = nil
			restoreTutorialPrompt() -- equivalent call inferred; original call site unknown

			if flag11 then
				sound:Resume()
			end
		end
	end

	local function missBall(data, _: string)
		if flag3 then
			if not v68 then
				v68 = data

				if sound.Playing then
					sound:Pause()
				end
			end

			updateTutorialPrompt()
		else
			v14.Register(session, nil, resolved.Judgement)
			showJudgement("Miss")
			damage(5)
			flashDamage()

			if data.Part then
				boom(data.Part.Position) -- equivalent call inferred; original call site unknown
			end

			v61 = getTargetTime(data)
			removeBall(data) -- equivalent call inferred; original call site unknown
		end
	end

	local function resolveParryHold(p3: number)
		if not flag9 then
			return
		end

		if v68 then
			flag9 = false
			v81 = -1e999
		else
			local v88 = 1e999
			local v89 = nil

			for _, v90 in v66 do
				if not (v90.Part and v90.Note.Lane == target) then
					continue
				end

				local v91 = math.abs(p3 - getTargetTime(v90))

				if not (v91 <= v36 and v91 < v88) then
					continue
				end

				v89 = v90
				v88 = v91
			end

			if v89 then
				flag9 = false
				v81 = -1e999
				local judge = v14.Judge(error, resolved.Judgement)
				v14.Register(session, error, resolved.Judgement)
				registerBallHit(v89, judge)
				flag10 = true
			elseif v81 <= p3 then
				if flag9 then
					v14.RegisterEmptyClick(session)
				end

				flag9 = false
				v81 = -1e999
			end
		end
	end

	local function tryHitBall()
		if flag3 and v68 and v68.Part then
			flag9 = false
			v81 = -1e999

			if v68.Note.Lane == target then
				registerBallHit(v68, "TUTORIAL_CORRECTION")
				return true
			end

			updateTutorialPrompt()
			return false
		else
			local chartTime = getChartTime() -- equivalent call inferred; original call site unknown
			local v88 = chartTime + 0.14
			local v89 = 1e999
			local v90 = nil

			for _, v91 in v66 do
				if not (v91.Part and v91.Note.Lane == target) then
					continue
				end

				local v92 = math.abs(v88 - getTargetTime(v91))

				if not (v92 <= v36 and v92 < v89) then
					continue
				end

				v90 = v91
				v89 = v92
			end

			if v90 then
				if flag9 then
					v14.RegisterEmptyClick(session)
				end

				flag9 = false
				v81 = -1e999
				local judge = v14.Judge(v89, resolved.Judgement)
				v14.Register(session, v89, resolved.Judgement)
				registerBallHit(v90, judge)
				return true
			else
				if flag9 then
					v14.RegisterEmptyClick(session)
				end

				flag9 = false
				v81 = -1e999
				flag9 = true
				v81 = v88 + v74
				playGrabAnimation()
				playGrabSound()
				return false
			end
		end
	end

	sound.TimePosition = 0
	spawnDueBalls(getChartTime())
	local children = v47.Decoration.VisualizerParts:GetChildren()
	local v88 = 1
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = generatedObstacles and { generatedObstacles } or {}
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = generatedObstacles and { generatedObstacles } or {}
	local now3 = -1e999
	local instance2 = nil

	local function getGroundHeight()
		local position = (pivot * CFrame.new(v65.Position * 6, v63 + 24, 0)).Position
		local raycastResult = workspace:Raycast(position, createVector(0, -64, 0), raycastParams)

		if not raycastResult then
			instance2 = nil
			return 0
		end

		local v89 = raycastResult.Position.Y - pivot.Position.Y

		if v63 + 1 < v89 then
			instance2 = nil
			return 0
		end

		instance2 = raycastResult.Instance
		return v89
	end

	local function getObstacleAhead()
		local v89 = v63 + 0.25 + 2
		local v90 = pivot * CFrame.new(v65.Position * 6, v89, 0)
		local v91 = pivot.LookVector * 9
		return workspace:Blockcast(v90, createVector(4.5, 4, 1), v91, raycastParams)
	end

	local function getObstacleContact()
		collisionPart.CFrame = pivot * CFrame.new(v65.Position * 6, v63 + 0.5 + collisionPart.Size.Y / 2, 0)
		getGroundHeight()
		local instanceModel

		if instance2 then
			instanceModel = instance2:FindFirstAncestorOfClass("Model") or instance2
		end

		for _, v89 in workspace:GetPartsInPart(collisionPart, overlapParams) do
			if not (not instanceModel or v89 ~= instanceModel and not v89:IsDescendantOf(instanceModel)) then
				continue
			end

			local objectSpace = pivot:ToObjectSpace(v89.CFrame)
			local v90 = math.abs(objectSpace.RightVector.Y) * v89.Size.X / 2 + math.abs(objectSpace.UpVector.Y) * v89.Size.Y / 2 + math.abs(objectSpace.LookVector.Y) * v89.Size.Z / 2

			if not (v63 >= objectSpace.Position.Y + v90 - 0.4) then
				return v89
			end
		end

		return nil
	end

	local function tryStartObstacleJump()
		if v64 ~= 0 or os.clock() - now3 < 0.2 then
			return
		end

		local probeSize = v19.ProbeSize
		local v89 = v63 + v19.GroundClearance + probeSize.Y / 2
		local v90 = pivot * CFrame.new(v65.Position * 6, v89, 0)
		local v91 = pivot.LookVector * v19.Distance

		if not workspace:Blockcast(v90, probeSize, v91, raycastParams) then
			return
		end

		now3 = os.clock()
		v64 = 36
		now = now3
		v70 = true
		v71 = false
		v44:Stop()
		v46:Stop()
		v45:Play()
	end

	local function updateVerticalMovement(dt: number)
		local obstacleContact = getObstacleContact()

		if obstacleContact and os.clock() - now2 >= 1 then
			now2 = os.clock()
			v71 = true
			boom(obstacleContact.Position) -- equivalent call inferred; original call site unknown

			if flag3 then
				if rhythmParryTutorialUI and textLabel3 then
					rhythmParryTutorialUI.Enabled = true
					textLabel3.Visible = true
					textLabel3.Text = "<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"2\">MOVE OUT OF THE WAY!</stroke>"

					if center then
						center.Visible = false
					end
				end
			else
				damage(25)
				flashDamage()
			end
		end

		if flag3 then
			local probeSize = v19.ProbeSize
			local v89 = v63 + v19.GroundClearance + probeSize.Y / 2
			local v90 = pivot * CFrame.new(v65.Position * 6, v89, 0)
			local v91 = pivot.LookVector * v19.Distance
			local v92 = workspace:Blockcast(v90, probeSize, v91, raycastParams) ~= nil

			if v92 ~= v72 then
				v72 = v92
				updateTutorialPrompt()
			end

			if v92 and not flag6 and not v69 and v64 == 0 then
				flag6 = true

				if sound.Playing then
					sound:Pause()
				end

				updateTutorialPrompt()
			end
		end

		v63 += v64 * dt
		local groundHeight = getGroundHeight()

		if v63 - groundHeight <= 0 and v64 <= 0 then
			if now then
				v45:Stop()
				v46:Stop()
				v44:Play()

				if flag3 and v70 then
					v70 = false

					if not (v71 or v69) then
						v69 = true
						updateTutorialPrompt()
					end
				end
			end

			now = nil
			v64 = 0
			v63 = groundHeight
		else
			if not now then
				now = os.clock()
				v44:Stop()
			end

			local v89 = v64
			v64 -= dt * 96

			if v89 >= 0 and v64 < 0 then
				v45:Stop()
				v46:Play()
			end
		end
	end

	local function moveLane(p3: number)
		if flag6 then
			return
		end

		local v89 = target + p3

		if v89 < -1 or v89 > 1 then
			return
		end

		local now4 = os.clock()

		if now4 - v82 < 0.05 then
			return
		end

		v82 = now4
		target = v89
		v60 = getChartTime() -- equivalent call inferred; original call site unknown
		v65.Target = target

		if v68 then
			updateTutorialPrompt()
		end
	end

	v23 = moveLane
	maid2:Add(function()
		v23 = nil
	end)

	local function tryJump()
		if v64 ~= 0 then
			return
		end

		if flag6 then
			flag6 = false

			if flag11 and not v68 then
				sound:Resume()
			end
		end

		local probeSize = v19.ProbeSize
		local v89 = v63 + v19.GroundClearance + probeSize.Y / 2
		local v90 = pivot * CFrame.new(v65.Position * 6, v89, 0)
		local v91 = pivot.LookVector * v19.Distance

		if workspace:Blockcast(v90, probeSize, v91, raycastParams) then
			v70 = true
			v71 = false
		end

		v64 = 36
		now = os.clock()
		v44:Stop()
		v46:Stop()
		v45:Play()
	end

	v24 = tryJump
	maid2:Add(function()
		v24 = nil
	end)
	parent:Destroy()
	v73 = maid2:Add(RunService.Heartbeat:Connect(function(dt)
		if flag4 or flag7 then
			return
		end

		if not flag11 and getPredictedChartTime() >= 0 then
			sound.TimePosition = 0
			sound:Play()
			flag11 = true
		end

		if flag11 and not (sound.Playing or v68 or flag6) then
			if endless then
				flag9 = false
				v81 = -1e999
				playbackSpeed = math.min(playbackSpeed + (endless.RateStep or 0.06), endless.MaxRate or 1.6)
				sound.PlaybackSpeed = playbackSpeed
				sound.TimePosition = 0
				sound:Play()
				v67 = 1
			else
				if flag3 then
					completeTutorial()
					return
				end

				v30 = true
				maid2:Add(task.defer(stop))
			end
		else
			local chartTime = getChartTime() -- equivalent call inferred; original call site unknown

			if flag3 and flag5 and v69 then
				completeTutorial()
				return
			end

			v62 = chartTime <= 0 and 0 or chartTime * speed
			updateScrollers(v62)
			local v89 = sound.PlaybackLoudness * 0.001 + 1

			for _, v90 in children do
				v90.Size *= Vector3.new(1, v89 / v88, 1)
			end

			v88 = v89
			spawnDueBalls(chartTime)
			local chartTime2 = getChartTime() -- equivalent call inferred; original call site unknown
			resolveParryHold(chartTime2 + 0.14)

			for i = #v66, 1, -1 do
				local v91 = v66[i]

				if not (v91 and v91.Part) then
					continue
				end

				updateBallVisual(v91) -- equivalent call inferred; original call site unknown
				local targetTime = getTargetTime(v91) -- equivalent call inferred; original call site unknown

				if targetTime <= chartTime then
					if v91.Note.Lane == target then
						local v92

						if v91.GraceSince then
							v92 = v77
						else
							local v93 = math.clamp(targetTime - v61, 0.15, 1.5)
							local v94 = math.clamp((targetTime - v60) / v93, 0, 1)
							v92 = v18[#v18]

							for _, v96 in v18 do
								if not (v96.ratio <= v94) then
									continue
								end

								v92 = v96
								break
							end
						end

						v14.Register(session, v92.error, resolved.Judgement)
						registerBallHit(v91, v92.tier)
						v61 = targetTime
					else
						if not flag3 then
							if not v91.GraceSince then
								v91.GraceSince = targetTime
							end

							if chartTime <= v91.GraceSince + v76 then
								continue
							end
						end

						missBall(v91, "wrong_lane")
						v61 = targetTime
					end
				else
					local chartTime3 = getChartTime() -- equivalent call inferred; original call site unknown
					local v92 = chartTime3 + 0.14

					if targetTime + v36 < v92 then
						missBall(v91, "missed_input")

						if v68 then
							break
						end
					end
				end
			end

			updateVerticalMovement(dt)
			local position = v65.Position
			collisionPart.CFrame = pivot * CFrame.new(position * 6, v63 + 0.5 + collisionPart.Size.Y / 2, 0)
			v42:PivotTo(pivot * CFrame.new(position * 6, v63, 0) * rigOffset)
			v43.CFrame = CFrame.new(v42.Torso.Position)
		end
	end))
	maid2:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if flag4 or flag7 then
			return
		end

		if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
			if UserInputService:GetFocusedTextBox() then
				return
			end
		elseif gameProcessed then
			return
		end

		local now4 = os.clock()

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonR1 then
			if not v68 then
				return
			end

			if v68 then
				flag10 = false
			elseif flag10 then
				flag10 = false
			elseif now4 - v83 < v54 then
				return
			end

			v83 = now4

			if tryHitBall() then
				flag10 = true
			end
		elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
			tryJump()
		elseif input.KeyCode == Enum.KeyCode.A then
			if flag6 then
				return
			end

			local v89 = target + -1

			if not (v89 < -1) then
				if v89 > 1 then
					return
				end

				local now5 = os.clock()

				if now5 - v82 < 0.05 then
					return
				end

				v82 = now5
				target = v89
				v60 = getChartTime() -- equivalent call inferred; original call site unknown
				v65.Target = target

				if v68 then
					updateTutorialPrompt()
				end
			end
		elseif input.KeyCode == Enum.KeyCode.D then
			if flag6 then
				return
			end

			local v89 = target + 1

			if not (v89 < -1) then
				if v89 > 1 then
					return
				end

				local now5 = os.clock()

				if now5 - v82 < 0.05 then
					return
				end

				v82 = now5
				target = v89
				v60 = getChartTime() -- equivalent call inferred; original call site unknown
				v65.Target = target

				if v68 then
					updateTutorialPrompt()
				end
			end
		end
	end))
end

function RhythmLTMController.Start(_)
	enterMode()
	local success, result = pcall(function()
		return v16.Client:WaitReplion("Data")
	end)
	local v29

	if success and result then
		v29 = result:Get({ "RhythmLTM", "TutorialDone" }) == true
	else
		v29 = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function openSelectorSoon()
		task.defer(function()
			for _ = 1, 5 do
				if flag2 or not flag or v9._currentGui then
					break
				end

				v9:Open("RhythmSongSelector", true)
				task.wait(0.2)
			end
		end)
	end

	if v29 then
		openSelectorSoon() -- equivalent call inferred; original call site unknown
		return
	end

	local rainingTacos = v12.RainingTacos or v12.Rainingtacos
	local soundId

	if typeof(rainingTacos) == "table" then
		soundId = rainingTacos.SoundId
	end

	local v30

	if typeof(soundId) == "string" and soundId ~= "" then
		v30 = probeSoundLoad(soundId)

		if not v30 then
			task.wait(0.2)
			v30 = probeSoundLoad(soundId)
		end
	else
		v30 = false
	end

	if v30 then
		RhythmLTMController:Play("RainingTacos", true, "easy", function()
			v9:Open("RhythmSongSelector", true)
		end)
		return
	end

	warn("rhythm: tutorial song audio unavailable this session, deferring tutorial -", (tostring(soundId)))
	openSelectorSoon() -- equivalent call inferred; original call site unknown
end

return RhythmLTMController