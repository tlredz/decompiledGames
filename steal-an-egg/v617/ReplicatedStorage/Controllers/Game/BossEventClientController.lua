local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local BossEventFlags = require(ReplicatedStorage.Shared.Flags.BossEventFlags)
local BossEvent = require(ReplicatedStorage.Data.BossEvent)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
local Notifications = require(ReplicatedStorage.Client.Notifications)
local Pads = require(ReplicatedStorage.Client.WorldFX.Pads)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local RiftEligibility = require(ReplicatedStorage.Shared.Util.RiftEligibility)
local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
local Save = require(ReplicatedStorage.Shared.Save)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local v = {
	ARENA_MODEL_NAME = "BossArena",
	PORTAL_MODEL_NAME = "BossArenaTeleport",
	FLOOR_NAME = "Floor",
	BOSS_MODEL_NAME = "Boss",
	OUTLINE_PART_NAME = "Cube.030",
	IN_ARENA_ATTRIBUTE = "InBossArena",
	ATTACKING_ATTRIBUTE = "Attacking",
	SPAWNING_ATTRIBUTE = "Spawning",
	LIGHTING_LAYER = "RiftBoss",
	LIGHTING_RANK = 150,
	LIGHTING_SPAN = 2,
	FLASH_COLOR = Color3.fromRGB(255, 0, 0),
	FLASH_INFO = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	BLACK_HOLE_COLOR = Color3.fromRGB(255, 40, 40),
	BLACK_HOLE_RADIUS = 20,
	BLACK_HOLE_THICKNESS = 2,
	BLACK_HOLE_HOVER = 0.15,
	BLACK_HOLE_TRANSPARENCY = 0.3,
	BLACK_HOLE_FADED_TRANSPARENCY = 0.8,
	BLACK_HOLE_PULSE = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	BLACK_HOLE_START_DELAY = 5,
	BLACK_HOLE_WINDUP_SECONDS = 4,
	BLACK_HOLE_RETRACT_SECONDS = 3,
	BLACK_HOLE_FOLLOW_SPEED_FRACTION = 0.4,
	BLACK_HOLE_HIT_INTERVAL = 1,
	VFX_FOLDER_NAME = "BossFightVFX",
	DEBRIS_FOLDER_NAME = "Transient",
	BLACK_HOLE_VFX_NAME = "BlackholeVFX",
	BLACK_HOLE_VFX_ROTATION = CFrame.Angles(0, 0, -1.5707963267948966),
	BLACK_HOLE_SPAWN_SOUND_NAME = "Blackhole Spawn",
	BLACK_HOLE_LOOP_SOUND_NAME = "Black Hole Loop Sound",
	BLACK_HOLE_LOOP_VOLUME = 2.5,
	GROUND_PROBE_HEIGHT = 50,
	TURN_SPEED = 3,
	MUSIC_NAME = "BossArenaMusic",
	MUSIC_VOLUME = 0.5,
	MUSIC_FADE_INFO = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	MUSIC_DEFEAT_FADE_INFO = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	UI_NAME = "BossFightUI",
	UI_WAIT_SECONDS = 5,
	COUNTDOWN_UI_NAME = "BossSpawningCountdown",
	COUNTDOWN_TEXT_FORMAT = "%s is spawning in: <font color=\"#C500FF\">%d</font>",
	BAR_INFO = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	PHANTOM_INFO = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.35),
	UI_FLASH_COLOR = Color3.new(1, 1, 1),
	UI_FLASH_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	UI_SHAKE_SECONDS = 0.3,
	UI_SHAKE_PIXELS = 6,
	BOSS_SPAWN_NAME = "BossSpawn",
	PHASE_TWO_AT_ATTRIBUTE = "PhaseTwoAt",
	HAND_BONE_NAME = "UpperHand1.R",
	HEALTH_GUI_NAME = "Health",
	ARM_HITS_ATTRIBUTE = "BossArmHits",
	ARM_BEAM_HIT_LIMIT = 5,
	EXTRA_FOLDER_NAME = "Extra",
	GUIDE_BEAM_NAME = "TutorialBeam",
	SHOP_STAND_NAME = "BossShopStand",
	SHOP_ZONE_NAME = "Zone",
	SHOP_TAB_NAME = "BossShop",
	SHOP_BEAM_LIFT = 4,
	CRYSTAL_FOLDER_NAME = "CrystalTowers",
	CRYSTAL_HITBOX_NAME = "Hitbox",
	CRYSTAL_HEALTH_ATTRIBUTE = "Health",
	CRYSTAL_HITS_ATTRIBUTE = "BossCrystalHits",
	CRYSTAL_BEAM_HIT_LIMIT = 5,
	CRYSTAL_HINT_DELAY = 60,
	CRYSTAL_HINT_MESSAGE = "Use your bat to destroy the crystals!",
	CRYSTAL_HINT_SECONDS = 5,
	CRYSTAL_HINT_COLOR = Color3.fromRGB(162, 0, 255),
	HAZARD_FOLDER_NAME = "BossHazards",
	HAZARD_COLOR = Color3.fromRGB(255, 40, 40),
	HAZARD_THICKNESS = 2,
	HAZARD_HOVER = 0.15,
	HAZARD_TRANSPARENCY = 0.2,
	HAZARD_TOUCH_PADDING = 2,
	HAZARD_JUMP_CLEARANCE = 4,
	HAZARD_REPORT_INTERVAL = 1,
	HAZARD_GAP_SECONDS = 2,
	HAZARD_START_DELAY_SECONDS = 5,
	HAZARD_INDICATOR_THICKNESS = 0.6,
	HAZARD_INDICATOR_TRANSPARENCY = 0.7,
	HAZARD_PULSE = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	X_KIND = "RotatingX",
	X_BAR_COUNT = 2,
	X_TELEGRAPH_SECONDS = 2,
	X_GROW_SECONDS = 1,
	X_ACTIVE_SECONDS = 15,
	X_DEGREES_PER_SECOND = 20,
	RING_KIND = "ExpandingRing",
	RING_SEGMENTS = 32,
	RING_COUNT = 5,
	RING_SPAWN_INTERVAL = 3,
	RING_SPEED = 40,
	RING_FADE_SECONDS = 0.75,
	HAZARD_MIN_LENGTH = 0.05
}
v.BLACK_HOLE_LOOP_RISE_INFO = TweenInfo.new(
	v.BLACK_HOLE_WINDUP_SECONDS,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)
v.BLACK_HOLE_LOOP_DRAIN_INFO = TweenInfo.new(
	v.BLACK_HOLE_RETRACT_SECONDS,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)
return {
	Start = function()
		local localPlayer = Players.LocalPlayer
		local child = script:WaitForChild(v.MUSIC_NAME, 10)
		local v2 = nil
		local child2 = ReplicatedStorage.Assets.Particles:WaitForChild(v.VFX_FOLDER_NAME)
		local child3 = Workspace:WaitForChild(v.DEBRIS_FOLDER_NAME)
		local attachment = child2:FindFirstChild(v.BLACK_HOLE_VFX_NAME)
		local v3

		if attachment == nil then
			v3 = false
		else
			v3 = attachment:IsA("Attachment")
		end

		assert(v3, (`{v.VFX_FOLDER_NAME} needs a {v.BLACK_HOLE_VFX_NAME} Attachment`))
		local beam = ReplicatedStorage.Assets:WaitForChild(v.EXTRA_FOLDER_NAME):FindFirstChild(v.GUIDE_BEAM_NAME)
		local v4

		if beam == nil then
			v4 = false
		else
			v4 = beam:IsA("Beam")
		end

		assert(v4, (`{v.EXTRA_FOLDER_NAME} needs a {v.GUIDE_BEAM_NAME} Beam`))
		local maid = Trove.new()
		local maid2 = Trove.new()
		local maid3 = Trove.new()
		local v5 = nil
		local v6 = {}
		local v7 = nil
		local v8 = nil
		local v9 = nil
		local v10 = nil
		local v11 = nil
		local v12 = nil
		local v13 = nil
		local v14 = nil
		local v15 = nil
		local v16 = -1
		local v17 = {}
		local v18 = {}
		local nows = {}
		local position = createVector(0, 0, 0)
		local v19 = nil
		local v20 = nil
		local v21 = nil
		local v22 = nil
		local v23 = nil
		local v24 = nil
		local v25 = nil
		local v26 = false
		local v27 = nil
		local v28 = nil
		local v29 = nil
		local v30 = 0
		local v31 = false
		local v32 = false
		local v33 = 0
		local v34 = 0
		local v35 = 0
		local serverTimeNow = 0
		local v36 = 0
		local v37 = 0
		local v38 = nil
		local v39 = nil
		local v40 = 1e999
		local closesAt = 0
		local v41 = nil
		local heartbeatConnection = nil
		local v42 = nil

		local function fadeMusic(volume: number, flag: boolean, p2)
			local v43 = v2

			if v43 ~= nil then
				v43:Cancel()
			end

			local tween = TweenService:Create(child, p2 or v.MUSIC_FADE_INFO, {
				Volume = volume
			})
			v2 = tween

			if flag then
				tween.Completed:Once(function(p3)
					if p3 == Enum.PlaybackState.Completed then
						child:Stop()
					end
				end)
			end

			tween:Play()
		end

		local function startMusic()
			if child.IsPlaying then
				return
			end

			local v43 = v2

			if v43 ~= nil then
				v43:Cancel()
				v2 = nil
			end

			child.Volume = v.MUSIC_VOLUME
			child:Play()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopMusic()
			if not child.IsPlaying then
				return
			end

			fadeMusic(0, true)
		end

		local function playVfx(childName: string, value)
			local child4 = child2:FindFirstChild(childName)
			assert(child4 ~= nil, (`{v.VFX_FOLDER_NAME} needs {childName}`))
			local clone = child4:Clone()

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			if clone:IsA("BasePart") then
				assert(typeof(value) == "CFrame", (`{childName} is a part and plays at a CFrame`))
				clone.Anchored = true
				clone.CanCollide = false
				clone.CanQuery = false
				clone.CanTouch = false
				clone.CFrame = value
				clone.Parent = child3
			elseif clone:IsA("Attachment") then
				assert(typeof(value) == "Instance", (`{childName} is an attachment and plays on a part`))
				clone.Parent = value
			else
				error((`{childName} must be a BasePart or an Attachment`))
			end

			VFX.Discard(clone, VFX.EmitTree(clone, true))
		end

		local function uiChild(instance, childName: string, className: string)
			local child4 = instance:FindFirstChild(childName)
			local v43

			if child4 == nil then
				v43 = false
			else
				v43 = child4:IsA(className)
			end

			assert(v43, (`{instance:GetFullName()} is missing the {className} {childName}`))
			return child4
		end

		local function findUi()
			local screenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild(v.UI_NAME, v.UI_WAIT_SECONDS)
			local v43

			if screenGui == nil then
				v43 = false
			else
				v43 = screenGui:IsA("ScreenGui")
			end

			assert(v43, (`PlayerGui is missing the {v.UI_NAME} ScreenGui`))
			local bossHPBar = screenGui:FindFirstChild("BossHPBar")
			local v44

			if bossHPBar == nil then
				v44 = false
			else
				v44 = bossHPBar:IsA("Frame")
			end

			assert(v44, (`{screenGui:GetFullName()} is missing the Frame BossHPBar`))
			local barHolder = bossHPBar:FindFirstChild("BarHolder")
			local v45

			if barHolder == nil then
				v45 = false
			else
				v45 = barHolder:IsA("Frame")
			end

			assert(v45, (`{bossHPBar:GetFullName()} is missing the Frame BarHolder`))
			local barBG = barHolder:FindFirstChild("BarBG")
			local v46

			if barBG == nil then
				v46 = false
			else
				v46 = barBG:IsA("CanvasGroup")
			end

			assert(v46, (`{barHolder:GetFullName()} is missing the CanvasGroup BarBG`))
			local bossName = bossHPBar:FindFirstChild("BossName")
			local v47

			if bossName == nil then
				v47 = false
			else
				v47 = bossName:IsA("TextLabel")
			end

			assert(v47, (`{bossHPBar:GetFullName()} is missing the TextLabel BossName`))
			bossName.Text = BossEvent.BossName
			local colorsByDescendant = {}
			local backgroundColor3sByDescendant = {}

			for _, descendant in screenGui:GetDescendants() do
				if descendant:IsA("UIStroke") and descendant.Color == Color3.new(0, 0, 0) then
					colorsByDescendant[descendant] = descendant.Color
				elseif descendant:IsA("Frame") and descendant.Name == "Line" then
					backgroundColor3sByDescendant[descendant] = descendant.BackgroundColor3
				end
			end

			local bar = barBG:FindFirstChild("Bar")
			local v49

			if bar == nil then
				v49 = false
			else
				v49 = bar:IsA("Frame")
			end

			assert(v49, (`{barBG:GetFullName()} is missing the Frame Bar`))
			local phantomBar = barBG:FindFirstChild("PhantomBar")
			local v50

			if phantomBar == nil then
				v50 = false
			else
				v50 = phantomBar:IsA("Frame")
			end

			assert(v50, (`{barBG:GetFullName()} is missing the Frame PhantomBar`))
			local healthAmount = barHolder:FindFirstChild("HealthAmount")
			local v51

			if healthAmount == nil then
				v51 = false
			else
				v51 = healthAmount:IsA("TextLabel")
			end

			assert(v51, (`{barHolder:GetFullName()} is missing the TextLabel HealthAmount`))
			local frame = bossHPBar:FindFirstChild("Frame")
			local v52

			if frame == nil then
				v52 = false
			else
				v52 = frame:IsA("Frame")
			end

			assert(v52, (`{bossHPBar:GetFullName()} is missing the Frame Frame`))
			local timerLabel = frame:FindFirstChild("TimerLabel")
			local v53

			if timerLabel == nil then
				v53 = false
			else
				v53 = timerLabel:IsA("TextLabel")
			end

			assert(v53, (`{frame:GetFullName()} is missing the TextLabel TimerLabel`))
			local bGDecor = bossHPBar:FindFirstChild("BGDecor")
			local v55

			if bGDecor == nil then
				v55 = false
			else
				v55 = bGDecor:IsA("Frame")
			end

			assert(v55, (`{bossHPBar:GetFullName()} is missing the Frame BGDecor`))
			return {
				Gui = screenGui,
				Bar = bar,
				PhantomBar = phantomBar,
				HealthAmount = healthAmount,
				TimerLabel = timerLabel,
				FightOnly = { barHolder, bossName, bGDecor },
				Shaker = bossHPBar,
				ShakerPosition = bossHPBar.Position,
				Strokes = colorsByDescendant,
				Lines = backgroundColor3sByDescendant
			}
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setHealth(p: number, p2: number, flag: boolean)
			local v43 = v38

			if v43 == nil or p2 <= 0 then
				return
			end

			v40 = p

			if p <= 0 and not v32 then
				v32 = true
				fadeMusic(0, true, v.MUSIC_DEFEAT_FADE_INFO)
			end

			local uDim = UDim2.fromScale(math.clamp(p / p2, 0, 1), 1)
			v43.HealthAmount.Text = `{math.max(math.ceil(p), 0)} / {math.ceil(p2)} HP`

			if flag then
				TweenService:Create(v43.Bar, v.BAR_INFO, {
					Size = uDim
				}):Play()
				TweenService:Create(v43.PhantomBar, v.PHANTOM_INFO, {
					Size = uDim
				}):Play()
			else
				v43.Bar.Size = uDim
				v43.PhantomBar.Size = uDim
			end
		end

		local function flashUi()
			local v43 = v38

			if v43 == nil then
				return
			end

			for k, stroke in v43.Strokes do
				k.Color = v.UI_FLASH_COLOR
				TweenService:Create(k, v.UI_FLASH_INFO, {
					Color = stroke
				}):Play()
			end

			for k, line in v43.Lines do
				k.BackgroundColor3 = v.UI_FLASH_COLOR
				TweenService:Create(k, v.UI_FLASH_INFO, {
					BackgroundColor3 = line
				}):Play()
			end

			local connection = v39

			if connection ~= nil then
				connection:Disconnect()
			end

			local v44 = 0
			local heartbeatConnection2 = nil
			heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt: number)
				v44 = math.min(v44 + dt, v.UI_SHAKE_SECONDS)

				if v44 >= v.UI_SHAKE_SECONDS then
					heartbeatConnection2:Disconnect()
					v43.Shaker.Position = v43.ShakerPosition
				else
					local v45 = v.UI_SHAKE_PIXELS * (1 - v44 / v.UI_SHAKE_SECONDS)
					v43.Shaker.Position = v43.ShakerPosition + UDim2.fromOffset(
						(math.random() - 0.5) * 2 * v45,
						(math.random() - 0.5) * 2 * v45
					)
				end
			end)
			v39 = heartbeatConnection2
		end

		local function findCountdownUi()
			local v43 = v42

			if v43 ~= nil then
				return v43.Gui, v43.Content
			end

			local screenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild(v.COUNTDOWN_UI_NAME, v.UI_WAIT_SECONDS)
			local v44

			if screenGui == nil then
				v44 = false
			else
				v44 = screenGui:IsA("ScreenGui")
			end

			assert(v44, (`PlayerGui is missing the {v.COUNTDOWN_UI_NAME} ScreenGui`))
			local main = screenGui:FindFirstChild("Main")
			local v45

			if main == nil then
				v45 = false
			else
				v45 = main:IsA("Frame")
			end

			assert(v45, (`{screenGui:GetFullName()} is missing the Frame Main`))
			local content = main:FindFirstChild("Content")
			local v46

			if content == nil then
				v46 = false
			else
				v46 = content:IsA("TextLabel")
			end

			assert(v46, (`{main:GetFullName()} is missing the TextLabel Content`))
			v42 = {
				Gui = screenGui,
				Content = content
			}
			return screenGui, content
		end

		local function stepCountdown()
			local countdownUi, v43 = findCountdownUi()
			local v44 = v41
			local v45 = v44 == nil and 0 or v44 - Workspace:GetServerTimeNow()

			if v45 <= 0 then
				countdownUi.Enabled = false
				v41 = nil
				local connection = heartbeatConnection

				if connection ~= nil then
					heartbeatConnection = nil
					connection:Disconnect()
				end
			else
				if HiddenUIHandler.IsHidden() then
					countdownUi.Enabled = false
					return
				end

				v43.Text = string.format(v.COUNTDOWN_TEXT_FORMAT, BossEvent.BossName, (math.ceil(v45)))
				countdownUi.Enabled = true
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setSpawnCountdown(bossSpawnsAt: number?)
			v41 = bossSpawnsAt

			if bossSpawnsAt ~= nil and heartbeatConnection == nil then
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					stepCountdown()
				end)
			end

			stepCountdown()
		end

		local function applySnapshot(data)
			closesAt = data.ClosesAt
			setSpawnCountdown(data.BossSpawnsAt) -- equivalent call inferred; original call site unknown
			local bossHealth = data.BossHealth
			local bossMaxHealth = data.BossMaxHealth

			if bossHealth ~= nil and bossMaxHealth ~= nil then
				local v43 = v38

				if v43 ~= nil then
					if bossMaxHealth <= 0 then
						return
					end

					v40 = bossHealth

					if bossHealth <= 0 and not v32 then
						v32 = true
						fadeMusic(0, true, v.MUSIC_DEFEAT_FADE_INFO)
					end

					local uDim = UDim2.fromScale(math.clamp(bossHealth / bossMaxHealth, 0, 1), 1)
					v43.HealthAmount.Text = `{math.max(math.ceil(bossHealth), 0)} / {math.ceil(bossMaxHealth)} HP`
					v43.Bar.Size = uDim
					v43.PhantomBar.Size = uDim
				end
			end
		end

		local function stepUi()
			local v43 = v38

			if v43 == nil then
				return
			end

			local v44 = v10
			local enabled = v32

			if not enabled then
				if v44 == nil then
					enabled = false
				else
					enabled = not v44.Model:GetAttribute(v.SPAWNING_ATTRIBUTE)
				end
			end

			if v43.Gui.Enabled ~= enabled then
				v43.Gui.Enabled = enabled
			end

			if not enabled then
				return
			end

			local visible = not v32

			for _, v47 in v43.FightOnly do
				if v47.Visible ~= visible then
					v47.Visible = visible
				end
			end

			if not (v32 or child.IsPlaying) then
				local v47 = v2

				if v47 ~= nil then
					v47:Cancel()
					v2 = nil
				end

				child.Volume = v.MUSIC_VOLUME
				child:Play()
			end

			local v47 = math.max(math.floor(closesAt - Workspace:GetServerTimeNow()), 0)
			v43.TimerLabel.Text = string.format("%02d:%02d", v47 // 60, v47 % 60)
		end

		local function showUi()
			local ui = findUi()
			v38 = ui
			maid:Add(function()
				local connection = v39

				if connection ~= nil then
					connection:Disconnect()
					v39 = nil
				end

				v38 = nil
				v40 = 1e999
				ui.Gui.Enabled = false

				for _, v43 in ui.FightOnly do
					v43.Visible = true
				end
			end)
			local v43 = Remotes.BossEvent.AskSnapshot:InvokeServer()
			closesAt = v43.ClosesAt
			setSpawnCountdown(v43.BossSpawnsAt) -- equivalent call inferred; original call site unknown
			local bossHealth = v43.BossHealth
			local bossMaxHealth = v43.BossMaxHealth

			if bossHealth ~= nil and bossMaxHealth ~= nil then
				setHealth(bossHealth, bossMaxHealth, false) -- equivalent call inferred; original call site unknown
			end

			stepUi()
			maid:Connect(Remotes.BossEvent.HealthShifted.OnClientEvent, function(p: number, p2: number)
				if p < v40 then
					flashUi()
				end

				setHealth(p, p2, true)
			end)
			maid:Connect(Remotes.BossEvent.StateShifted.OnClientEvent, applySnapshot)
		end

		local function findBoss(instance)
			local model = instance:WaitForChild(v.BOSS_MODEL_NAME, 10)

			if model == nil or not model:IsA("Model") then
				return nil
			end

			local part = model:WaitForChild(v.OUTLINE_PART_NAME, 10)
			local v43

			if part == nil then
				v43 = false
			else
				v43 = part:IsA("BasePart")
			end

			assert(v43, (`{v.BOSS_MODEL_NAME} needs its {v.OUTLINE_PART_NAME} outline part`))
			local primaryPart = model.PrimaryPart
			assert(primaryPart ~= nil, (`{v.BOSS_MODEL_NAME} needs a PrimaryPart`))
			local bone = model:FindFirstChild(v.HAND_BONE_NAME, true)
			local v44

			if bone == nil then
				v44 = false
			else
				v44 = bone:IsA("Bone")
			end

			assert(v44, (`{v.BOSS_MODEL_NAME} needs a {v.HAND_BONE_NAME} bone`))
			return {
				Model = model,
				Root = primaryPart,
				Outline = part,
				OutlineColor = part.Color,
				HandBone = bone
			}
		end

		local function flashOutline()
			local v43 = v10

			if v43 == nil then
				return
			end

			v43.Outline.Color = v.FLASH_COLOR
			TweenService:Create(v43.Outline, v.FLASH_INFO, {
				Color = v43.OutlineColor
			}):Play()
		end

		local function stopBlackHoleVfx()
			local folder = v11

			if folder == nil then
				return
			end

			for _, emitter in folder:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local v43 = v12

			if v43 ~= nil then
				TweenService:Create(v43, v.BLACK_HOLE_LOOP_DRAIN_INFO, {
					Volume = 0
				}):Play()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearBlackHole()
			local v43 = v11
			v11 = nil
			v12 = nil
			v13 = nil

			if v43 ~= nil then
				v43:Destroy()
			end
		end

		local function groundBelow(vector2: Vector3)
			local v43 = v9

			if v43 == nil then
				return vector2
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { v43 }
			local raycastResult = Workspace:Raycast(
				vector2 + createVector(0, 1, 0) * v.GROUND_PROBE_HEIGHT,
				createVector(0, 1, 0) * -(v.GROUND_PROBE_HEIGHT * 4),
				raycastParams
			)

			if raycastResult == nil then
				return (Vector3.new(vector2.X, v43.Position.Y + v43.Size.Y * 0.5, vector2.Z))
			end

			return raycastResult.Position
		end

		local function chasePlayer(p, part, humanoid, p2: number, p3: number)
			local target = p.Target
			local vector2 = Vector3.new(part.Position.X - target.X, 0, part.Position.Z - target.Z)
			local v43 = humanoid.WalkSpeed * v.BLACK_HOLE_FOLLOW_SPEED_FRACTION * p3 * p2

			if v43 < vector2.Magnitude then
				p.Target = target + vector2.Unit * v43
			else
				p.Target = Vector3.new(part.Position.X, target.Y, part.Position.Z)
			end
		end

		local function blackHolePart()
			local v43 = v11

			if v43 ~= nil then
				return v43
			end

			local part = Instance.new("Part")
			part.Name = "BossBlackHole"
			part.Shape = Enum.PartType.Cylinder
			part.Material = Enum.Material.Neon
			part.Color = v.BLACK_HOLE_COLOR
			part.Transparency = v.BLACK_HOLE_TRANSPARENCY
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			local clone = attachment:Clone()
			clone.CFrame = v.BLACK_HOLE_VFX_ROTATION * clone.CFrame
			clone.Parent = part
			part.Parent = Workspace
			v11 = part
			TweenService:Create(part, v.BLACK_HOLE_PULSE, {
				Transparency = v.BLACK_HOLE_FADED_TRANSPARENCY
			}):Play()
			BossEvent.PlaySound(v.BLACK_HOLE_SPAWN_SOUND_NAME, part)
			local v44 = BossEvent.PlaySound(v.BLACK_HOLE_LOOP_SOUND_NAME, part, {
				Looped = true,
				Volume = 0
			})

			if v44 ~= nil then
				TweenService:Create(v44, v.BLACK_HOLE_LOOP_RISE_INFO, {
					Volume = v.BLACK_HOLE_LOOP_VOLUME
				}):Play()
				v12 = v44
			end

			return part
		end

		local function faceTowards(p, target: Vector3, p2: number)
			local pivot = p.Model:GetPivot()
			local vector2 = Vector3.new(target.X, pivot.Position.Y, target.Z)

			if (vector2 - pivot.Position).Magnitude < 1 then
				return
			end

			local cframe = CFrame.lookAt(pivot.Position, vector2)
			p.Model:PivotTo(pivot:Lerp(cframe, (math.min(p2 * v.TURN_SPEED, 1))))
		end

		local function stepBlackHole(p: number)
			local v43 = v10
			local part = Player.FindRootPart(localPlayer)
			local humanoid = Player.FindHumanoid(localPlayer)
			local serverTimeNow2 = Workspace:GetServerTimeNow()

			if v43 ~= nil and v43.Model:GetAttribute(v.SPAWNING_ATTRIBUTE) then
				v36 = serverTimeNow2
			end

			if humanoid == nil or part == nil or not part:IsA("BasePart") then
				clearBlackHole() -- equivalent call inferred; original call site unknown
			else
				local v44

				if v43 == nil then
					v44 = false
				else
					v44 = not (v32 or v43.Model:GetAttribute(v.SPAWNING_ATTRIBUTE)) and not v43.Model:GetAttribute(v.ATTACKING_ATTRIBUTE) and serverTimeNow2 - math.max(
						serverTimeNow,
						v36
					) >= v.BLACK_HOLE_START_DELAY
				end

				local v45 = v13

				if v45 == nil then
					if not v44 then
						return
					end

					v45 = {
						Target = part.Position,
						StartedAt = serverTimeNow2,
						RetractingAt = nil
					}
					v13 = v45
				elseif not v44 and v45.RetractingAt == nil then
					v45.RetractingAt = serverTimeNow2
					stopBlackHoleVfx()
				end

				local retractingAt = v45.RetractingAt
				local v46

				if retractingAt == nil then
					v46 = 1
				else
					v46 = 1 - math.min((serverTimeNow2 - retractingAt) / v.BLACK_HOLE_RETRACT_SECONDS, 1)

					if v46 <= 0 then
						clearBlackHole() -- equivalent call inferred; original call site unknown
						return
					end
				end

				local v47 = math.min((serverTimeNow2 - v45.StartedAt) / v.BLACK_HOLE_WINDUP_SECONDS, 1)
				local v48 = v47 >= 1

				if v48 then
					chasePlayer(v45, part, humanoid, p, v46)
				end

				local target = v45.Target

				if v43 ~= nil and not v43.Model:GetAttribute(v.ATTACKING_ATTRIBUTE) then
					faceTowards(v43, target, p)
				end

				local v49 = v.BLACK_HOLE_RADIUS * v47 * v46
				local v50 = groundBelow(Vector3.new(target.X, part.Position.Y, target.Z))
				local v51 = blackHolePart()
				v51.Size = Vector3.new(v.BLACK_HOLE_THICKNESS, v49 * 2, v49 * 2)
				v51.CFrame = CFrame.new(v50 + createVector(0, 1, 0) * v.BLACK_HOLE_HOVER) * CFrame.Angles(
					0,
					0,
					1.5707963267948966
				)
				local vector2 = Vector3.new(part.Position.X - v50.X, 0, part.Position.Z - v50.Z)

				if v48 and vector2.Magnitude <= v49 and serverTimeNow2 - v37 >= v.BLACK_HOLE_HIT_INTERVAL then
					v37 = serverTimeNow2
					Remotes.BossEvent.BlackHoleHit:FireServer()
				end
			end
		end

		local function measureHazardCycle(part, position2: Vector3)
			local v43 = part.Size * 0.5
			local v44 = 0

			for _, v45 in { -v43.X, v43.X } do
				for _, v46 in { -v43.Z, v43.Z } do
					local position3 = (part.CFrame * CFrame.new(v45, 0, v46)).Position
					v44 = math.max(v44, Vector3.new(position3.X - position2.X, 0, position3.Z - position2.Z).Magnitude)
				end
			end

			v33 = v44 / v.RING_SPEED
			v34 = (v.RING_COUNT - 1) * v.RING_SPAWN_INTERVAL + v33 + v.RING_FADE_SECONDS
			v35 = v.X_TELEGRAPH_SECONDS + v.X_ACTIVE_SECONDS + v34 + v.HAZARD_GAP_SECONDS * 2
		end

		local function hazardFolder()
			local v43 = v14

			if v43 ~= nil then
				return v43
			end

			local folder = Instance.new("Folder")
			folder.Name = v.HAZARD_FOLDER_NAME
			folder.Parent = Workspace
			v14 = folder
			return folder
		end

		local function hazardPart(name: string, size: Vector3, transparency: number)
			local part = Instance.new("Part")
			part.Name = name
			part.Size = size
			part.Material = Enum.Material.Neon
			part.Color = v.HAZARD_COLOR
			part.Transparency = transparency
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			local parent = v14

			if parent == nil then
				parent = Instance.new("Folder")
				parent.Name = v.HAZARD_FOLDER_NAME
				parent.Parent = Workspace
				v14 = parent
			end

			part.Parent = parent
			return part
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearHazards()
			local v43 = v14
			v14 = nil
			v17 = {}
			v18 = {}

			if v43 ~= nil then
				v43:Destroy()
			end
		end

		local function overFloor(vector2: Vector3)
			local v43 = v9

			if v43 == nil then
				return false
			end

			local pointToObjectSpace = v43.CFrame:PointToObjectSpace(vector2)
			return math.abs(pointToObjectSpace.X) <= v43.Size.X * 0.5 and math.abs(pointToObjectSpace.Z) <= v43.Size.Z * 0.5
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function withinHazardHeight(p, p2: number)
			return math.abs(p.Position.Y - p2) <= v.HAZARD_JUMP_CLEARANCE
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reportHazardHit(p: string)
			local now = os.clock()

			if now - (nows[p] or 0) < v.HAZARD_REPORT_INTERVAL then
				return
			end

			nows[p] = now
			Remotes.BossEvent.HazardHit:FireServer(p)
		end

		local function stepRotatingX(flag: boolean, p: number, vector2: Vector3, p2: number, p3)
			local v43 = v9

			if v43 == nil then
				return
			end

			local v44 = math.max(v43.Size.X, v43.Size.Z)

			if #v17 == 0 then
				local HAZARD_INDICATOR_THICKNESS

				if flag then
					HAZARD_INDICATOR_THICKNESS = v.HAZARD_INDICATOR_THICKNESS
				else
					HAZARD_INDICATOR_THICKNESS = v.HAZARD_THICKNESS
				end

				for _ = 1, v.X_BAR_COUNT do
					local vector3 = Vector3.new(v.HAZARD_THICKNESS, HAZARD_INDICATOR_THICKNESS, v44)
					local HAZARD_INDICATOR_TRANSPARENCY

					if flag then
						HAZARD_INDICATOR_TRANSPARENCY = v.HAZARD_INDICATOR_TRANSPARENCY
					else
						HAZARD_INDICATOR_TRANSPARENCY = v.HAZARD_TRANSPARENCY
					end

					local part = Instance.new("Part")
					part.Name = flag and "XIndicator" or "XBar"
					part.Size = vector3
					part.Material = Enum.Material.Neon
					part.Color = v.HAZARD_COLOR
					part.Transparency = HAZARD_INDICATOR_TRANSPARENCY
					part.Anchored = true
					part.CanCollide = false
					part.CanQuery = false
					part.CanTouch = false
					part.CastShadow = false
					local parent = v14

					if parent == nil then
						parent = Instance.new("Folder")
						parent.Name = v.HAZARD_FOLDER_NAME
						parent.Parent = Workspace
						v14 = parent
					end

					part.Parent = parent

					if flag then
						TweenService:Create(part, v.HAZARD_PULSE, {
							Transparency = v.HAZARD_TRANSPARENCY
						}):Play()
					end

					table.insert(v17, part)
				end
			end

			if not flag then
				v44 *= math.clamp(p / v.X_GROW_SECONDS, 0, 1)
			end

			local v45 = math.rad((flag and 0 or math.max(p - v.X_GROW_SECONDS, 0)) * v.X_DEGREES_PER_SECOND)

			for k, v46 in v17 do
				v46.Size = Vector3.new(v46.Size.X, v46.Size.Y, (math.max(v44, v.HAZARD_MIN_LENGTH)))
				v46.CFrame = CFrame.new(vector2.X, p2, vector2.Z) * CFrame.Angles(
					0,
					v45 + (k - 1) * 3.141592653589793 * 0.5,
					0
				)

				if flag or p3 == nil or not withinHazardHeight(p3, p2) then
					continue
				end

				local pointToObjectSpace = v46.CFrame:PointToObjectSpace((Vector3.new(
					p3.Position.X,
					v46.Position.Y,
					p3.Position.Z
				)))

				if not (math.abs(pointToObjectSpace.X) <= v.HAZARD_THICKNESS * 0.5 + v.HAZARD_TOUCH_PADDING and math.abs(pointToObjectSpace.Z) <= v44 * 0.5) then
					continue
				end

				reportHazardHit(v.X_KIND) -- equivalent call inferred; original call site unknown
			end
		end

		local function newRing()
			local result = {}

			for _ = 1, v.RING_SEGMENTS do
				local vector2 = Vector3.new(v.HAZARD_THICKNESS, v.HAZARD_THICKNESS, v.HAZARD_MIN_LENGTH)
				local HAZARD_TRANSPARENCY = v.HAZARD_TRANSPARENCY
				local part = Instance.new("Part")
				part.Name = "RingSegment"
				part.Size = vector2
				part.Material = Enum.Material.Neon
				part.Color = v.HAZARD_COLOR
				part.Transparency = HAZARD_TRANSPARENCY
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				local parent = v14

				if parent == nil then
					parent = Instance.new("Folder")
					parent.Name = v.HAZARD_FOLDER_NAME
					parent.Parent = Workspace
					v14 = parent
				end

				part.Parent = parent
				table.insert(result, part)
			end

			return result
		end

		local function stepRings(p: number, vector2: Vector3, p2: number, p3)
			for i = 0, v.RING_COUNT - 1 do
				local v43 = p - i * v.RING_SPAWN_INTERVAL

				if v43 < 0 then
					continue
				end

				local v44 = v18[i] or newRing()
				v18[i] = v44
				local v45 = math.min(v43, v33) * v.RING_SPEED
				local v46 = math.clamp((v43 - v33) / v.RING_FADE_SECONDS, 0, 1)
				local v47 = v.HAZARD_TRANSPARENCY + (1 - v.HAZARD_TRANSPARENCY) * v46
				local v48 = math.max(6.283185307179586 * v45 / v.RING_SEGMENTS, v.HAZARD_MIN_LENGTH)

				for k, v49 in v44 do
					local v50 = (k - 1) / v.RING_SEGMENTS * 3.141592653589793 * 2
					local vector3 = Vector3.new(vector2.X + math.cos(v50) * v45, p2, vector2.Z + math.sin(v50) * v45)
					v49.Size = Vector3.new(v.HAZARD_THICKNESS, v.HAZARD_THICKNESS, v48)
					v49.CFrame = CFrame.new(vector3) * CFrame.Angles(0, -v50, 0)
					local v51 = v9
					local v52

					if v51 == nil then
						v52 = false
					else
						local pointToObjectSpace = v51.CFrame:PointToObjectSpace(vector3)

						if math.abs(pointToObjectSpace.X) <= v51.Size.X * 0.5 then
							v52 = math.abs(pointToObjectSpace.Z) <= v51.Size.Z * 0.5
						else
							v52 = false
						end
					end

					v49.Transparency = not v52 and 1 or v47
				end

				if p3 == nil or v46 >= 1 or not withinHazardHeight(p3, p2) then
					continue
				end

				if not (math.abs(Vector3.new(p3.Position.X - vector2.X, 0, p3.Position.Z - vector2.Z).Magnitude - v45) <= v.HAZARD_THICKNESS * 0.5 + v.HAZARD_TOUCH_PADDING) then
					continue
				end

				local position2 = p3.Position
				local v49 = v9
				local v50

				if v49 == nil then
					v50 = false
				else
					local pointToObjectSpace = v49.CFrame:PointToObjectSpace(position2)

					if math.abs(pointToObjectSpace.X) <= v49.Size.X * 0.5 then
						v50 = math.abs(pointToObjectSpace.Z) <= v49.Size.Z * 0.5
					else
						v50 = false
					end
				end

				if not v50 then
					continue
				end

				reportHazardHit(v.RING_KIND) -- equivalent call inferred; original call site unknown
			end
		end

		local function stepHazards()
			local v43 = v10
			local v44 = v9
			local attribute

			if not (v43 == nil or v32) then
				attribute = v43.Model:GetAttribute(v.PHASE_TWO_AT_ATTRIBUTE)
			end

			if v43 == nil or v44 == nil or typeof(attribute) ~= "number" or v35 <= 0 then
				if v15 ~= nil then
					v15 = nil
					clearHazards() -- equivalent call inferred; original call site unknown
				end
			else
				local v45 = Workspace:GetServerTimeNow() - attribute - v.HAZARD_START_DELAY_SECONDS

				if v45 < 0 then
					if v15 ~= nil then
						v15 = nil
						clearHazards() -- equivalent call inferred; original call site unknown
					end
				else
					local v46 = math.floor(v45 / v35)
					local v47 = v45 - v46 * v35
					local v48 = v.X_TELEGRAPH_SECONDS + v.X_ACTIVE_SECONDS
					local v49 = v48 + v.HAZARD_GAP_SECONDS
					local v50

					if v47 < v.X_TELEGRAPH_SECONDS then
						v50 = "XTelegraph"
					elseif v47 < v48 then
						v50 = "XActive"
					elseif v49 <= v47 and v47 < v49 + v34 then
						v50 = "Rings"
					else
						v50 = nil
					end

					if v50 ~= v15 or v46 ~= v16 then
						clearHazards() -- equivalent call inferred; original call site unknown
						v15 = v50
						v16 = v46
					end

					if v50 == nil then
						return
					end

					local part = Player.FindRootPart(localPlayer)
					local humanoid = Player.FindHumanoid(localPlayer)
					local v51 = nil

					if part ~= nil and part:IsA("BasePart") and humanoid ~= nil and humanoid.Health > 0 then
						v51 = part
					end

					local v52 = position
					local v53 = v44.Position.Y + v44.Size.Y * 0.5 + v.HAZARD_HOVER + v.HAZARD_THICKNESS * 0.5

					if v50 == "Rings" then
						stepRings(v47 - v49, v52, v53, v51)
					elseif v50 == "XTelegraph" then
						stepRotatingX(true, v47, v52, v53, v51)
					else
						stepRotatingX(false, v47 - v.X_TELEGRAPH_SECONDS, v52, v53, v51)
					end
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearArmBeam()
			local v43 = v19
			local v44 = v20
			v19 = nil
			v20 = nil

			if v43 ~= nil then
				v43:Destroy()
			end

			if v44 ~= nil then
				v44:Destroy()
			end
		end

		local function stepArmBeam()
			local v43 = v10

			if v43 == nil or v43.HandBone:FindFirstChild(v.HEALTH_GUI_NAME) == nil then
				v21 = nil
				clearArmBeam() -- equivalent call inferred; original call site unknown
			else
				local attribute = localPlayer:GetAttribute(v.ARM_HITS_ATTRIBUTE)
				local v44 = type(attribute) ~= "number" and 0 or attribute
				local v45 = v21 or v44
				v21 = v45
				local part = Player.FindRootPart(localPlayer)

				if part == nil or not part:IsA("BasePart") or v44 - v45 >= v.ARM_BEAM_HIT_LIMIT then
					clearArmBeam() -- equivalent call inferred; original call site unknown
				else
					local v46 = v19
					local v47 = v20

					if v46 ~= nil and v47 ~= nil and v47.Parent == part and v46.Attachment1 == v43.HandBone then
						return
					end

					clearArmBeam() -- equivalent call inferred; original call site unknown
					local attachment2 = Instance.new("Attachment")
					attachment2.Name = "BossArmBeamOrigin"
					attachment2.Parent = part
					v20 = attachment2
					local clone = beam:Clone()
					clone.Attachment0 = attachment2
					clone.Attachment1 = v43.HandBone
					clone.Parent = attachment2
					v19 = clone
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearCrystalBeam()
			local v43 = v27
			local v44 = v28
			local v45 = v29
			v27 = nil
			v28 = nil
			v29 = nil

			if v43 ~= nil then
				v43:Destroy()
			end

			if v44 ~= nil then
				v44:Destroy()
			end

			if v45 ~= nil then
				v45:Destroy()
			end
		end

		local function nearestCrystal(position2: Vector3)
			local v43 = v8
			local child4

			if v43 ~= nil then
				child4 = v43:FindFirstChild(v.CRYSTAL_FOLDER_NAME)
			end

			if child4 == nil then
				return nil
			end

			local v44 = 1e999
			local v45 = nil

			for _, child5 in child4:GetChildren() do
				local part = child5:FindFirstChild(v.CRYSTAL_HITBOX_NAME)

				if not (part ~= nil and part:IsA("BasePart")) then
					continue
				end

				local attribute = part:GetAttribute(v.CRYSTAL_HEALTH_ATTRIBUTE)

				if type(attribute) ~= "number" or attribute <= 0 then
					continue
				end

				local magnitude = (part.Position - position2).Magnitude

				if not (magnitude < v44) then
					continue
				end

				v45 = part
				v44 = magnitude
			end

			return v45
		end

		local function stepCrystalBeam()
			local v43 = v10
			local v44

			if v43 == nil then
				v44 = false
			else
				v44 = not (v32 or v43.Model:GetAttribute(v.SPAWNING_ATTRIBUTE)) and v43.Model:GetAttribute(v.PHASE_TWO_AT_ATTRIBUTE) == nil
			end

			if v44 then
				local serverTimeNow2 = Workspace:GetServerTimeNow()

				if v30 == 0 then
					v30 = serverTimeNow2
				end

				local attribute = localPlayer:GetAttribute(v.CRYSTAL_HITS_ATTRIBUTE)

				if (type(attribute) ~= "number" and 0 or attribute) >= v.CRYSTAL_BEAM_HIT_LIMIT then
					clearCrystalBeam() -- equivalent call inferred; original call site unknown
				else
					if not v31 and serverTimeNow2 - v30 >= v.CRYSTAL_HINT_DELAY then
						v31 = true
						Notifications.Toast.Show({
							Lane = "Banner",
							Text = v.CRYSTAL_HINT_MESSAGE,
							Seconds = v.CRYSTAL_HINT_SECONDS,
							Color = v.CRYSTAL_HINT_COLOR
						})
					end

					local part = Player.FindRootPart(localPlayer)
					local parent

					if not (part == nil or not part:IsA("BasePart")) then
						parent = nearestCrystal(part.Position)
					end

					if part == nil or not part:IsA("BasePart") or parent == nil then
						clearCrystalBeam() -- equivalent call inferred; original call site unknown
					else
						local v46 = v28
						local v47 = v29

						if v46 == nil or v47 == nil or v46.Parent ~= part then
							clearCrystalBeam() -- equivalent call inferred; original call site unknown
							local attachment2 = Instance.new("Attachment")
							attachment2.Name = "BossCrystalBeamOrigin"
							attachment2.Parent = part
							v28 = attachment2
							local attachment3 = Instance.new("Attachment")
							attachment3.Name = "BossCrystalBeamTarget"
							attachment3.Parent = parent
							v29 = attachment3
							local clone = beam:Clone()
							clone.Attachment0 = attachment2
							clone.Attachment1 = attachment3
							clone.Parent = attachment2
							v27 = clone
						elseif v47.Parent ~= parent then
							v47.Parent = parent
						end
					end
				end
			else
				v30 = 0
				clearCrystalBeam() -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearShopBeam()
			local v43 = v24
			local v44 = v25
			v24 = nil
			v25 = nil

			if v43 ~= nil then
				v43:Destroy()
			end

			if v44 ~= nil then
				v44:Destroy()
			end
		end

		local function bindShopStand(model)
			local part = model:WaitForChild(v.SHOP_ZONE_NAME, 5)
			local v43

			if part == nil then
				v43 = false
			else
				v43 = part:IsA("BasePart")
			end

			assert(v43, (`{v.SHOP_STAND_NAME} needs a {v.SHOP_ZONE_NAME} part`))
			v22 = model
			local attachment2 = Instance.new("Attachment")
			attachment2.Name = "BossShopBeamTarget"
			attachment2.Position = Vector3.new(0, v.SHOP_BEAM_LIFT, 0)
			attachment2.Parent = part
			v23 = attachment2
			maid:Add(attachment2)
			maid:Add(Pads.Track(part, {
				Entered = function()
					v26 = true
					clearShopBeam() -- equivalent call inferred; original call site unknown
					Tabs.Activate(v.SHOP_TAB_NAME)
				end,
				Left = function()
					if Tabs.Active() == v.SHOP_TAB_NAME then
						Tabs.Deactivate({
							instant = true
						})
					end
				end
			}))
		end

		local function stepShopStand()
			local v43 = v8
			local model

			if v43 ~= nil then
				model = v43:FindFirstChild(v.SHOP_STAND_NAME)
			end

			if model == nil or not model:IsA("Model") then
				return
			end

			if v22 ~= model then
				bindShopStand(model)
			end

			local attachment3 = v23
			local part = Player.FindRootPart(localPlayer)

			if attachment3 == nil or part == nil or not part:IsA("BasePart") or v26 then
				clearShopBeam() -- equivalent call inferred; original call site unknown
			else
				local v45 = v25

				if v24 ~= nil and v45 ~= nil and v45.Parent == part then
					return
				end

				clearShopBeam() -- equivalent call inferred; original call site unknown
				local attachment2 = Instance.new("Attachment")
				attachment2.Name = "BossShopBeamOrigin"
				attachment2.Parent = part
				v25 = attachment2
				local clone = beam:Clone()
				clone.Attachment0 = attachment2
				clone.Attachment1 = attachment3
				clone.Parent = attachment2
				v24 = clone
			end
		end

		local function watchBoss(model)
			maid2:Clean()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function bind()
				local boss = findBoss(model)

				if boss == nil then
					return
				end

				v10 = boss
				maid2:Add(function()
					v10 = nil
					clearBlackHole() -- equivalent call inferred; original call site unknown
				end)
			end

			bind() -- equivalent call inferred; original call site unknown

			if v10 == nil then
				maid2:Connect(model.ChildAdded, function(p)
					if p.Name == v.BOSS_MODEL_NAME and v10 == nil then
						task.defer(bind)
					end
				end)
			end
		end

		local function onEnterArena()
			maid:Clean()
			serverTimeNow = Workspace:GetServerTimeNow()
			v36 = 0
			v37 = 0
			LightingController.SetLayer(v.LIGHTING_LAYER, "RiftBoss", v.LIGHTING_RANK, v.LIGHTING_SPAN)
			maid:Add(function()
				LightingController.ClearLayer(v.LIGHTING_LAYER, v.LIGHTING_SPAN)
				maid2:Clean()
				clearBlackHole() -- equivalent call inferred; original call site unknown
				clearHazards() -- equivalent call inferred; original call site unknown
				clearArmBeam() -- equivalent call inferred; original call site unknown
				clearShopBeam() -- equivalent call inferred; original call site unknown
				clearCrystalBeam() -- equivalent call inferred; original call site unknown
				v30 = 0
				v31 = false
				v21 = nil
				v22 = nil
				v23 = nil
				v26 = false
				v32 = false

				if Tabs.Active() == v.SHOP_TAB_NAME then
					Tabs.Deactivate({
						instant = true
					})
				end

				v15 = nil
				v16 = -1
				v35 = 0
				v8 = nil
				v9 = nil
				local v43 = v2

				if v43 ~= nil then
					v43:Cancel()
				end

				local tween = TweenService:Create(child, v.MUSIC_FADE_INFO, {
					Volume = 0
				})
				v2 = tween
				tween:Play()
				SoundService.Music.GameMusic.Volume = 1
			end)

			if child.IsPlaying then
				local MUSIC_VOLUME = v.MUSIC_VOLUME
				local v43 = v2

				if v43 ~= nil then
					v43:Cancel()
				end

				local tween = TweenService:Create(child, v.MUSIC_FADE_INFO, {
					Volume = MUSIC_VOLUME
				})
				v2 = tween
				tween:Play()
			end

			SoundService.Music.GameMusic.Volume = 0
			maid:Connect(localPlayer.CharacterAdded, function()
				serverTimeNow = Workspace:GetServerTimeNow()
				clearBlackHole() -- equivalent call inferred; original call site unknown
			end)
			maid:Connect(Remotes.BossEvent.Vfx.OnClientEvent, playVfx)
			local model = Workspace:WaitForChild(v.ARENA_MODEL_NAME, 5)
			local v43

			if model == nil then
				v43 = false
			else
				v43 = model:IsA("Model")
			end

			assert(v43, (`Entered the Boss World but Workspace.{v.ARENA_MODEL_NAME} is missing`))

			if not localPlayer:GetAttribute(v.IN_ARENA_ATTRIBUTE) then
				maid:Clean()
				return
			end

			local part = model:WaitForChild(v.FLOOR_NAME, 5)
			local v44

			if part == nil then
				v44 = false
			else
				v44 = part:IsA("BasePart")
			end

			assert(v44, (`{v.ARENA_MODEL_NAME} needs a {v.FLOOR_NAME} part`))
			local part2 = model:WaitForChild(v.BOSS_SPAWN_NAME, 5)
			local v45

			if part2 == nil then
				v45 = false
			else
				v45 = part2:IsA("BasePart")
			end

			assert(v45, (`{v.ARENA_MODEL_NAME} needs a {v.BOSS_SPAWN_NAME} part`))
			v8 = model
			v9 = part
			position = part2.Position
			measureHazardCycle(part, part2.Position)
			watchBoss(model)
			showUi()

			if localPlayer:GetAttribute(v.IN_ARENA_ATTRIBUTE) then
				maid:Connect(RunService.Heartbeat, function(p: number)
					stepBlackHole(p)
					stepHazards()
					stepArmBeam()
					stepCrystalBeam()
					stepShopStand()
					stepUi()
				end)
			else
				maid:Clean()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onArenaStateChanged()
			if localPlayer:GetAttribute(v.IN_ARENA_ATTRIBUTE) then
				onEnterArena()
			else
				maid:Clean()
			end
		end

		local function recordPortalPiece(instance)
			if instance:IsA("BasePart") then
				v6[instance] = {
					Solidity = {
						CanCollide = instance.CanCollide,
						CanQuery = instance.CanQuery,
						CanTouch = instance.CanTouch
					}
				}
				return true
			end

			if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Light") or instance:IsA("BillboardGui") then
				v6[instance] = {
					Effect = instance.Enabled
				}
				return true
			end

			if not instance:IsA("Sound") then
				return false
			end

			v6[instance] = {
				Volume = instance.Volume
			}
			return true
		end

		local function applyPortalPiece(p, data, flag: boolean)
			local solidity = data.Solidity

			if solidity == nil then
				if data.Effect == nil then
					if data.Volume ~= nil then
						p.Volume = not flag and 0 or data.Volume
					end
				else
					local enabled

					if flag then
						enabled = data.Effect
					else
						enabled = false
					end

					p.Enabled = enabled
				end
			else
				p.LocalTransparencyModifier = flag and 0 or 1
				local canCollide

				if flag then
					canCollide = solidity.CanCollide
				else
					canCollide = false
				end

				p.CanCollide = canCollide
				local canQuery

				if flag then
					canQuery = solidity.CanQuery
				else
					canQuery = false
				end

				p.CanQuery = canQuery
				local canTouch

				if flag then
					canTouch = solidity.CanTouch
				else
					canTouch = false
				end

				p.CanTouch = canTouch
			end
		end

		local function refreshPortal()
			if v5 == nil then
				return
			end

			local v43 = Save.Await()
			local v44 = v43 == nil and 0 or v43.SpeedPower
			local v45 = v43 == nil and 0 or v43.LastLogout
			local v46 = BossEventFlags.ContentEnabled:Get() and RiftEligibility.IsRevealed(localPlayer, v44, v45)

			if v7 == v46 then
				return
			end

			v7 = v46

			for k, v47 in v6 do
				applyPortalPiece(k, v47, v46)
			end
		end

		local function adoptPortal(folder)
			maid3:Clean()
			v5 = folder
			v6 = {}
			v7 = nil
			maid3:Add(function()
				v5 = nil
				v6 = {}
				v7 = nil
			end)

			for _, descendant in folder:GetDescendants() do
				recordPortalPiece(descendant)
			end

			maid3:Connect(folder.DescendantAdded, function(p)
				if not recordPortalPiece(p) then
					return
				end

				local v43 = v7
				local v44 = v6[p]

				if v43 ~= nil and v44 ~= nil then
					applyPortalPiece(p, v44, v43)
				end
			end)
			maid3:Connect(folder.DescendantRemoving, function(p)
				v6[p] = nil
			end)
			refreshPortal()
		end

		Remotes.BossEvent.BossDamaged.OnClientEvent:Connect(flashOutline)
		Remotes.BossEvent.StateShifted.OnClientEvent:Connect(function(p)
			setSpawnCountdown(p.BossSpawnsAt) -- equivalent call inferred; original call site unknown

			if not p.Open then
				stopMusic() -- equivalent call inferred; original call site unknown
			end
		end)
		localPlayer:GetAttributeChangedSignal(v.IN_ARENA_ATTRIBUTE):Connect(onArenaStateChanged)
		onArenaStateChanged() -- equivalent call inferred; original call site unknown
		task.spawn(function()
			setSpawnCountdown(Remotes.BossEvent.AskSnapshot:InvokeServer().BossSpawnsAt) -- equivalent call inferred; original call site unknown
		end)
		Workspace.ChildAdded:Connect(function(model)
			if model.Name == v.PORTAL_MODEL_NAME and model:IsA("Model") then
				adoptPortal(model)
			end
		end)
		Workspace.ChildRemoved:Connect(function(child4)
			if child4 == v5 then
				maid3:Clean()
			end
		end)
		Save.WatchFields("SpeedPower", refreshPortal)
		RiftFlags.SpeedPowerRequirement.Changed:Connect(refreshPortal)
		BossEventFlags.ContentEnabled.Changed:Connect(refreshPortal)
		Workspace:GetAttributeChangedSignal(RiftEligibility.OpenAttribute):Connect(refreshPortal)
		localPlayer:GetAttributeChangedSignal(RiftEligibility.CutsceneSeenAttribute):Connect(refreshPortal)
		task.spawn(function()
			local model = Workspace:FindFirstChild(v.PORTAL_MODEL_NAME)

			if model ~= nil and model:IsA("Model") then
				adoptPortal(model)
			end

			Save.Await()
			refreshPortal()
		end)
	end
}