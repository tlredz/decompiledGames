local createVector = vector.create
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Data.Assets)
local directory = Assets.Directory
require(ReplicatedStorage.Shared.Globals.Constants)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local EggRenderer = require(ReplicatedStorage.Shared.Eggs.EggRenderer)
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Message = require(ReplicatedStorage.Client.Message)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Sakura = require(ReplicatedStorage.Data.Sakura)
local SakuraFX = require(ReplicatedStorage.Client.SakuraFX)
local SakuraSignals = require(ReplicatedStorage.Client.SakuraSignals)
local Sakura2 = require(ReplicatedStorage.Shared.Types.Sakura)
local Save = require(ReplicatedStorage.Shared.Save)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Emit = require(ReplicatedStorage.UserGenerated.VFX.Emit)
return {
	Start = function()
		if not GameFlags.GreatBloomEnabled:Get() then
			return
		end

		local color = Color3.fromRGB(255, 120, 200)
		local color2 = Color3.fromRGB(255, 0, 0)
		local v = { 1.5, 9 }
		local color3 = Color3.fromRGB(235, 154, 200)
		local color4 = Color3.fromRGB(255, 200, 232)
		local color5 = Color3.fromRGB(255, 240, 248)
		local localPlayer = Players.LocalPlayer
		local currentCamera = Workspace.CurrentCamera
		local world = Workspace:WaitForChild("World")
		local build = world:WaitForChild("Build")
		local incubatorAnchor = world:WaitForChild("Areas"):WaitForChild("CherryBlossom"):WaitForChild("IncubatorAnchor")
		assert(incubatorAnchor:IsA("BasePart"), "CherryBlossom.IncubatorAnchor must be a BasePart")
		local sakura = ReplicatedStorage.Assets.Models.Sakura
		local incubatorDead = sakura.IncubatorDead
		local incubatorBloomed = sakura.IncubatorBloomed
		local craneSign = sakura.CraneSign
		local cutscene = sakura.Cutscene
		local cameraRig = cutscene.CameraRig
		local craneRig = cutscene.CraneRig
		local playerRig = cutscene.PlayerRig
		local leafCover = cutscene.LeafCover
		local leafRing = cutscene.LeafRing
		local blossomEffect = cutscene.BlossomEffect
		local floor = cutscene.Floor
		local cutscene2 = script:WaitForChild("Cutscene")
		assert(cutscene2:IsA("Sound"), "SakuraIncubator.Cutscene must be a Sound")
		assert(
			blossomEffect:IsA("BasePart") and floor:IsA("BasePart"),
			"Sakura cutscene BlossomEffect and Floor must be BaseParts"
		)
		assert(
			incubatorDead.PrimaryPart and incubatorBloomed.PrimaryPart,
			"Sakura incubator templates need PrimaryParts"
		)
		assert(craneSign:IsA("Model") and craneSign.PrimaryPart, "Sakura.CraneSign must be a Model with a PrimaryPart")
		assert(
			cameraRig.PrimaryPart and craneRig.PrimaryPart and playerRig.PrimaryPart,
			"Sakura cutscene rigs need PrimaryParts"
		)
		assert(leafCover.PrimaryPart, "Sakura cutscene LeafCover needs a PrimaryPart")
		assert(leafRing.PrimaryPart, "Sakura cutscene LeafRing needs a PrimaryPart")
		local cameraAnimation = cameraRig.CameraAnimation
		local craneAnimation = craneRig.CraneAnimation
		local playerAnimation = playerRig.PlayerAnimation
		assert(
			cameraAnimation:IsA("Animation") and craneAnimation:IsA("Animation") and playerAnimation:IsA("Animation"),
			"Sakura cutscene rigs need their Animation children"
		)
		local incubatorBillboard = sakura.IncubatorBillboard
		assert(incubatorBillboard:IsA("BillboardGui"), "Sakura.IncubatorBillboard must be a BillboardGui")
		local maid = Trove.new()
		local v2 = nil
		local v3 = nil
		local v4 = nil
		local v5 = nil
		local flag = false
		local refresh

		-- equivalent calls inferred from this helper; original call sites unknown
		local function notifyError(text: string)
			Toast.Show({
				Text = text,
				Color = color2,
				Seconds = 3
			})
		end

		local function isUnlocked()
			local v6 = Save.Await()
			return v6 ~= nil and v6.Sakura.Unlocked
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function spawnVisual(instance, cframe: CFrame)
			local clone = instance:Clone()
			clone:PivotTo(cframe)
			clone.Parent = Workspace
			return clone
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rigCFrame(instance)
			local rootOffset = instance:GetAttribute("RootOffset")
			assert(typeof(rootOffset) == "CFrame", (`{instance.Name} needs a RootOffset CFrame attribute`))
			return incubatorAnchor.CFrame * rootOffset
		end

		local function makePrompt(parent, actionText: string, objectText: string, maxActivationDistance: number)
			local attachment = Instance.new("Attachment")
			attachment.Name = "PromptAttachment"
			attachment.Position = createVector(0, 3, 0)
			attachment.Parent = parent
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
			proximityPrompt.ActionText = actionText
			proximityPrompt.ObjectText = objectText
			proximityPrompt.HoldDuration = 0
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.MaxActivationDistance = maxActivationDistance
			proximityPrompt.Parent = attachment
			return proximityPrompt
		end

		local function getChargePercent()
			local v6 = Save.Await()

			if v6 == nil or v6.Sakura.Egg == false then
				return 0, false
			end

			return Sakura.GetChargePercent(v6.Sakura.Deposited, Sakura.GetRequiredCrystals()), true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getNextBloomAt(serverTimeNow: number)
			local intervalSeconds = Sakura.Bloom.IntervalSeconds
			return serverTimeNow + intervalSeconds - (serverTimeNow + Sakura.Bloom.OffsetSeconds) % intervalSeconds
		end

		local function getBloomStatusText()
			local serverTimeNow = Workspace:GetServerTimeNow()
			local attribute = Workspace:GetAttribute(Sakura.Bloom.EndsAtAttribute)

			if typeof(attribute) == "number" and serverTimeNow < attribute then
				return "The Great Bloom is live!"
			end

			local v6 = math.max(0, getNextBloomAt(serverTimeNow) - serverTimeNow)
			return (`Next Great Bloom in {math.floor(v6 / 60)}:{string.format("%02d", (math.floor(v6 % 60)))}`)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function syncBillboardEnabled()
			local v6 = v2

			if v6 then
				v6.Enabled = not flag
			end
		end

		local function renderBillboard()
			local v6 = v2

			if v6 == nil then
				return
			end

			v6.Enabled = not flag
			local countdown = v6.Countdown
			local progress = v6.Progress
			assert(
				countdown:IsA("TextLabel") and progress:IsA("Frame"),
				"IncubatorBillboard needs Countdown and Progress"
			)
			local bar = progress.Bar
			assert(bar:IsA("Frame"), "IncubatorBillboard.Progress.Bar must be a Frame")
			local v7 = Save.Await()
			local v8

			if v7 == nil then
				v8 = false
			else
				v8 = v7.Sakura.Unlocked
			end

			if v8 then
				local v9 = Save.Await()
				local flag2, v10

				if v9 == nil or v9.Sakura.Egg == false then
					flag2 = false
					v10 = 0
				else
					v10 = Sakura.GetChargePercent(v9.Sakura.Deposited, Sakura.GetRequiredCrystals())
					flag2 = true
				end

				if flag2 then
					countdown.Text = getBloomStatusText()
					progress.Visible = true
					TweenService:Create(bar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.fromScale(math.clamp(v10 / Sakura.Incubator.MaxChargePercent, 0, 1), 1)
					}):Play()
					local v11 = v3

					if v11 then
						TweenService:Create(v11, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Brightness = math.clamp(v10 / Sakura.Incubator.MaxChargePercent, 0, 1) * 3
						}):Play()
					end
				else
					countdown.Text = getBloomStatusText()
					progress.Visible = false
				end
			else
				countdown.Text = "Return a Crane pet to unlock Great Bloom"
				progress.Visible = false
			end
		end

		local function buildTree(flag2: boolean)
			maid:Clean()
			local v6

			if flag2 then
				v6 = incubatorBloomed
			else
				v6 = incubatorDead
			end

			local clone2 = spawnVisual(v6, incubatorAnchor.CFrame) -- equivalent call inferred; original call site unknown
			maid:Add(clone2)
			v4 = clone2
			v5 = flag2

			if flag2 then
				local door = clone2:WaitForChild("Door")
				door.CanCollide = false
				door.CanTouch = false
				door.CanQuery = false
				TweenService:Create(door, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end

			local radius = v6:GetAttribute("Radius")
			local height = v6:GetAttribute("Height")
			local primaryPart = clone2.PrimaryPart
			clone2:AddTag("MainSakuraTree")
			local clone = incubatorBillboard:Clone()
			clone.StudsOffsetWorldSpace = Vector3.new(0, height * 0.65, 0)
			clone.Enabled = not flag
			clone.Parent = primaryPart
			v2 = clone
			v3 = nil

			if flag2 then
				local attachment = Instance.new("Attachment")
				attachment.Name = "ChargeGlow"
				attachment.Position = Vector3.new(0, height * 0.6, 0)
				attachment.Parent = primaryPart
				local pointLight = Instance.new("PointLight")
				pointLight.Color = color
				pointLight.Brightness = 0
				pointLight.Range = 50
				pointLight.Parent = attachment
				v3 = pointLight
			end

			maid:Add(function()
				v2 = nil
				v3 = nil
			end)
			renderBillboard()

			if flag2 then
				local maxActivationDistance = radius + 8
				local attachment = Instance.new("Attachment")
				attachment.Name = "PromptAttachment"
				attachment.Position = createVector(0, 3, 0)
				attachment.Parent = primaryPart
				local proximityPrompt = Instance.new("ProximityPrompt")
				proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
				proximityPrompt.ActionText = "Open Incubator"
				proximityPrompt.ObjectText = "Sakura Incubator"
				proximityPrompt.HoldDuration = 0
				proximityPrompt.RequiresLineOfSight = false
				proximityPrompt.MaxActivationDistance = maxActivationDistance
				proximityPrompt.Parent = attachment
				maid:Add(proximityPrompt.Triggered:Connect(function()
					Tabs.Activate("SakuraEggCharge")
				end))
			elseif not flag then
				local maid2 = maid
				local v10 = rigCFrame(craneSign) -- equivalent call inferred; original call site unknown
				maid2:Add(spawnVisual(craneSign, v10))
				local maxActivationDistance = radius + 8
				local attachment = Instance.new("Attachment")
				attachment.Name = "PromptAttachment"
				attachment.Position = createVector(0, 3, 0)
				attachment.Parent = primaryPart
				local proximityPrompt = Instance.new("ProximityPrompt")
				proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
				proximityPrompt.ActionText = "Hatch and Return Crane pet"
				proximityPrompt.ObjectText = "Dormant Sakura Tree"
				proximityPrompt.HoldDuration = 0
				proximityPrompt.RequiresLineOfSight = false
				proximityPrompt.MaxActivationDistance = maxActivationDistance
				proximityPrompt.Parent = attachment
				maid:Add(proximityPrompt.Triggered:Connect(function()
					proximityPrompt.Enabled = false
					local v12, v13 = Remotes.Bloomery.AskCraneReturn:InvokeServer()

					if not v12 then
						notifyError(typeof(v13) ~= "string" and "The tree sleeps... bring it a Crane pet" or v13) -- equivalent call inferred; original call site unknown
						proximityPrompt.Enabled = true
					end
				end))
			end
		end

		local function emitPetals(folder, p: number)
			for _, emitter in ipairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(p)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function playTrack(animator, animation)
			local track = animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Action4
			track.Looped = false
			track:Play(0)
			return track
		end

		local function getAnimator(instance)
			local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")
			assert(humanoid, (`{instance.Name} needs a Humanoid or AnimationController`))
			local animator = humanoid:FindFirstChildOfClass("Animator")
			assert(animator, (`{instance.Name} needs an Animator`))
			return animator
		end

		local function cloneCharacterRig()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if character == nil or humanoid == nil or character.PrimaryPart == nil then
				local v8 = rigCFrame(playerRig) -- equivalent call inferred; original call site unknown
				return spawnVisual(playerRig, v8)
			else
				local archivable = character.Archivable
				character.Archivable = true
				local clone = character:Clone()
				character.Archivable = archivable
				clone.Name = "SakuraCutscenePlayer"

				for _, child in ipairs(clone:GetChildren()) do
					if not (child:IsA("LocalScript") or child:IsA("Script") or child:IsA("Tool")) then
						continue
					end

					child:Destroy()
				end

				local humanoid2 = clone:FindFirstChildOfClass("Humanoid")
				assert(humanoid2, "Cloned character lost its Humanoid")
				humanoid2.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

				if humanoid2:FindFirstChildOfClass("Animator") == nil then
					local animator = Instance.new("Animator")
					animator.Parent = humanoid2
				end

				for _, part in ipairs(clone:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.Anchored = part == clone.PrimaryPart
					part.CanCollide = false
					part.CanQuery = false
					part.CanTouch = false
					part.LocalTransparencyModifier = 0
				end

				clone:PivotTo(rigCFrame(playerRig))
				clone.Parent = Workspace
				return clone
			end
		end

		local function hideCharacter(maid2)
			local character = localPlayer.Character

			if character == nil then
				return
			end

			local v6 = {}

			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant:IsA("BasePart") then
					v6[descendant] = descendant.LocalTransparencyModifier
					descendant.LocalTransparencyModifier = 1
				elseif descendant:IsA("Decal") then
					v6[descendant] = descendant.Transparency
					descendant.Transparency = 1
				end
			end

			maid2:Add(function()
				for instance, v7 in v6 do
					if not instance.Parent then
						continue
					end

					if instance:IsA("BasePart") then
						instance.LocalTransparencyModifier = v7
					elseif instance:IsA("Decal") then
						instance.Transparency = v7
					end
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function emitEffect(instance)
			local clone = instance:Clone()
			clone.CFrame = rigCFrame(instance)
			clone.Parent = Workspace
			Debris:AddItem(clone, Emit(clone) + 1)
		end

		local function playBloom(object)
			buildTree(true)
			local v6 = v4
			local pointLight = Instance.new("PointLight")
			pointLight.Color = color
			pointLight.Brightness = 6
			pointLight.Range = 60
			pointLight.Parent = v6.PrimaryPart
			object:Add(pointLight)
			TweenService:Create(pointLight, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Brightness = 0
			}):Play()
			emitEffect(blossomEffect) -- equivalent call inferred; original call site unknown
			emitEffect(floor) -- equivalent call inferred; original call site unknown
			emitPetals(v6, 80)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function partKeys(p)
			local parts = {}
			local walk

			walk = function(instance, p2: string)
				local v6 = {}

				for _, part in ipairs(instance:GetChildren()) do
					local v7 = (v6[part.Name] or 0) + 1
					v6[part.Name] = v7
					local formatted = `{p2}/{part.Name}#{v7}`

					if part:IsA("BasePart") then
						parts[formatted] = part
					end

					walk(part, formatted)
				end
			end

			walk(p, "")
			return parts
		end

		local function tweenTreeToBloomed(duration: number)
			local v6 = v4

			if v6 == nil or v5 then
				return
			end

			local parts = partKeys(incubatorBloomed) -- equivalent call inferred; original call site unknown
			local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			local parts2 = partKeys(v6) -- equivalent call inferred; original call site unknown

			for k, v9 in parts2 do
				local v10 = parts[k]

				if v10 and v10.Color ~= v9.Color then
					TweenService:Create(v9, tweenInfo, {
						Color = v10.Color
					}):Play()
				end
			end
		end

		local function playLeafCover(maid2)
			local folder = spawnVisual(leafCover, incubatorAnchor.CFrame) -- equivalent call inferred; original call site unknown
			maid2:Add(folder)
			local parts = {}

			for _, part in ipairs(folder:GetDescendants()) do
				if part:IsA("BasePart") and part ~= folder.PrimaryPart then
					table.insert(parts, part)
				end
			end

			table.sort(parts, function(a, b)
				return a.Position.Y < b.Position.Y
			end)
			local sizes = {}

			for _, v7 in parts do
				sizes[v7] = v7.Size
				v7.Size = createVector(0.05, 0.05, 0.05)
				v7.Transparency = 1
			end

			local highlight = Instance.new("Highlight")
			highlight.FillColor = color3
			highlight.OutlineColor = color4
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = folder
			local v7 = true
			maid2:Add(function()
				v7 = false
			end)

			local function sweep(p: number, accelerating, fn)
				local v8 = #parts
				local lastTime = os.clock()

				for k, v9 in parts do
					local v10 = p * accelerating((k - 1) / math.max(v8 - 1, 1)) - (os.clock() - lastTime)

					if v10 > 0 then
						task.wait(v10)
					end

					if not v7 or folder.Parent == nil then
						break
					end

					fn(v9)
				end
			end

			local function accelerating(p: number)
				return 1 - (1 - p) ^ 2
			end

			local function linear(p: number)
				return p
			end

			local fieldOfView = currentCamera.FieldOfView
			maid2:Add(function()
				currentCamera.FieldOfView = fieldOfView
			end)
			local colors = {}
			local v8 = false

			for _, v9 in parts do
				colors[v9] = v9.Color
			end

			task.spawn(function()
				local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				tweenTreeToBloomed(3.669999999999998)
				sweep(3.069999999999998, accelerating, function(p)
					p.Transparency = 0
					TweenService:Create(p, tweenInfo, {
						Size = sizes[p]
					}):Play()
				end)
				task.wait(0.6)

				if not v7 or v8 then
					return
				end

				local tweenInfo2 = TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				TweenService:Create(highlight, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					OutlineTransparency = 0
				}):Play()
				TweenService:Create(currentCamera, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FieldOfView = fieldOfView - 12
				}):Play()
				task.spawn(sweep, 1.25, linear, function(p)
					TweenService:Create(p, tweenInfo2, {
						Size = sizes[p] * 0.8
					}):Play()
				end)
				local lastTime = os.clock()
				local total = 0
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
					if not v7 or v8 then
						heartbeatConnection:Disconnect()
						return
					end

					local v9 = math.clamp((os.clock() - lastTime) / 2.5, 0, 1)
					local v10 = v[1] + (v[2] - v[1]) * v9 ^ 2
					total += dt * v10 * 3.141592653589793 * 2
					local v11 = (math.sin(total) + 1) * 0.5 * (v9 * 0.65 + 0.35)
					highlight.FillTransparency = 1 - v11 * 0.85

					for _, v12 in parts do
						v12.Color = colors[v12]:Lerp(color5, v11)
					end
				end)
				maid2:Add(heartbeatConnection)
			end)

			local function flashScreen()
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "SakuraExplosionFlash"
				screenGui.IgnoreGuiInset = true
				screenGui.DisplayOrder = 1000
				screenGui.ResetOnSpawn = false
				local frame = Instance.new("Frame")
				frame.Size = UDim2.fromScale(1, 1)
				frame.BackgroundColor3 = color5
				frame.BorderSizePixel = 0
				frame.Parent = screenGui
				screenGui.Parent = localPlayer.PlayerGui
				maid2:Add(screenGui)
				TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1
				}):Play()
				task.delay(0.6, function()
					screenGui:Destroy()
				end)
			end

			local function explode()
				if v8 or not v7 then
					return
				end

				v8 = true
				flashScreen()
				local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					FillColor = color5,
					OutlineColor = color5,
					FillTransparency = 1,
					OutlineTransparency = 1
				}):Play()
				local tween = TweenService:Create(
					currentCamera,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = fieldOfView + 14
					}
				)
				tween.Completed:Once(function()
					TweenService:Create(
						currentCamera,
						TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							FieldOfView = fieldOfView
						}
					):Play()
				end)
				tween:Play()
				task.spawn(sweep, 0.25, linear, function(p)
					TweenService:Create(p, tweenInfo, {
						Size = sizes[p] * 1.8,
						Transparency = 1
					}):Play()
				end)
				task.delay(0.55, function()
					folder:Destroy()
				end)
			end

			return {
				Model = folder,
				Explode = explode
			}
		end

		local function setEmitters(folder, enabled: boolean)
			local v6 = 0

			for _, emitter in ipairs(folder:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = enabled
				v6 = math.max(v6, emitter.Lifetime.Max)
			end

			return v6
		end

		local function playLeafRing(maid2)
			local v8 = rigCFrame(leafRing) -- equivalent call inferred; original call site unknown
			local clone = spawnVisual(leafRing, v8) -- equivalent call inferred; original call site unknown
			maid2:Add(clone)
			setEmitters(clone, true)
			return function()
				local v10 = setEmitters(clone, false)
				task.delay(v10, function()
					clone:Destroy()
				end)
			end
		end

		local function setTrails(folder, enabled: boolean)
			for _, trail in ipairs(folder:GetDescendants()) do
				if trail:IsA("Trail") then
					trail.Enabled = enabled
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function playCutsceneSound(maid2)
			local clone = cutscene2:Clone()
			clone.Parent = SoundService
			maid2:Add(clone)
			clone:Play()
		end

		local function runUnlockCutscene(maid2)
			buildTree(false)
			local v8 = rigCFrame(cameraRig) -- equivalent call inferred; original call site unknown
			local clone = spawnVisual(cameraRig, v8) -- equivalent call inferred; original call site unknown
			local v12 = rigCFrame(craneRig) -- equivalent call inferred; original call site unknown
			local clone2 = spawnVisual(craneRig, v12) -- equivalent call inferred; original call site unknown
			maid2:Add(clone)
			maid2:Add(clone2)
			local torso = clone:FindFirstChild("Torso")
			assert(torso and torso:IsA("BasePart"), "CameraRig needs a Torso part")
			local characterRig = cloneCharacterRig()
			maid2:Add(characterRig)
			hideCharacter(maid2)
			ContentProvider:PreloadAsync({ cameraAnimation, craneAnimation, playerAnimation })
			local track = playTrack(getAnimator(clone), cameraAnimation) -- equivalent call inferred; original call site unknown
			local track2 = playTrack(getAnimator(clone2), craneAnimation) -- equivalent call inferred; original call site unknown
			local track3 = playTrack(getAnimator(characterRig), playerAnimation) -- equivalent call inferred; original call site unknown
			local v17 = { track, track2, track3 }
			maid2:Add(function()
				for _, v18 in v17 do
					v18:Stop(0)
					v18:Destroy()
				end
			end)
			local v18 = nil

			local function startOnce()
				if v18 then
					return
				end

				v18 = playLeafCover(maid2)
			end

			local v19 = nil

			local function spellOnce()
				if v19 then
					return
				end

				v19 = playLeafRing(maid2)
			end

			local flag2 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function bloomOnce()
				if flag2 then
					return
				end

				flag2 = true
				local v20 = v18

				if v20 then
					v20.Explode()
				end

				local v21 = v19

				if v21 then
					v21()
				end

				task.spawn(playBloom, maid2)
			end

			maid2:Add(track:GetMarkerReachedSignal("Start"):Connect(startOnce))
			maid2:Add(track:GetMarkerReachedSignal("Explosion"):Connect(bloomOnce))
			maid2:Add(track2:GetMarkerReachedSignal("Spell"):Connect(spellOnce))
			setTrails(clone2, true)
			playCutsceneSound(maid2) -- equivalent call inferred; original call site unknown
			currentCamera.CameraType = Enum.CameraType.Scriptable
			maid2:Add(function()
				RunService:UnbindFromRenderStep("SakuraUnlockCamera")
				currentCamera.CameraType = Enum.CameraType.Custom
			end)
			RunService:BindToRenderStep("SakuraUnlockCamera", Enum.RenderPriority.Camera.Value + 1, function()
				currentCamera.CFrame = torso.CFrame
			end)
			task.wait(25)
			bloomOnce() -- equivalent call inferred; original call site unknown
		end

		local function playUnlockCutscene()
			if flag then
				return
			end

			flag = true
			syncBillboardEnabled() -- equivalent call inferred; original call site unknown
			Tabs.Deactivate({
				instant = true
			})
			local v6 = HiddenUIHandler.Acquire()
			local v7 = Trove.new()
			local success, result = pcall(runUnlockCutscene, v7)
			v7:Clean()
			v6()
			flag = false
			refresh()

			if not success then
				error(result)
			end
		end

		local function runMutateReveal(maid2, data)
			local decoded = EggRecords.Decode(data.Egg)
			local v6 = directory[decoded.AssetCategory]
			assert(v6 ~= nil, (`Missing asset config {decoded.AssetCategory}`))
			local v7 = Mutations.Get(data.Mutation)
			local tint

			if v7 then
				tint = v7.Tint
			else
				tint = color
			end

			local cFrame = incubatorAnchor.CFrame
			local v8 = cFrame * CFrame.new(0, 0, -incubatorBloomed:GetAttribute("Radius") - 4)
			local visual = EggRenderer.RenderVisual({
				OwnerUserId = localPlayer.UserId,
				UID = data.Uid,
				ModelName = "SakuraRevealEgg",
				Record = decoded
			}, Workspace)
			local model = visual.Model
			maid2:Add(model)

			for _, part in ipairs(model:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
			end

			local Y = visual.Config and EggRenderer.GetVisibleBounds(decoded).Y or 4
			local cframe = CFrame.new(v8.Position + Vector3.new(0, Y / 2 + 1.5, 0))
			model:PivotTo(cframe)
			local scale = model:GetScale()
			model:ScaleTo((math.max(0.05, scale * 0.05)))
			local pointLight = Instance.new("PointLight")
			pointLight.Color = tint
			pointLight.Brightness = 0
			pointLight.Range = 30
			pointLight.Parent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
			maid2:Add(pointLight)
			local v9 = math.max(Y * 2.2, 9)
			local lookVector = cFrame.LookVector
			local cframe2 = CFrame.lookAt(
				cframe.Position + lookVector * v9 * 1.6 + Vector3.new(0, Y * 0.9, 0),
				cframe.Position
			)
			local cframe3 = CFrame.lookAt(
				cframe.Position + (lookVector * 0.85 + cFrame.RightVector * 0.5).Unit * v9 + Vector3.new(0, Y * 0.4, 0),
				cframe.Position
			)
			currentCamera.CameraType = Enum.CameraType.Scriptable
			maid2:Add(function()
				RunService:UnbindFromRenderStep("SakuraMutateReveal")
				currentCamera.CameraType = Enum.CameraType.Custom
			end)
			local total = 0
			RunService:BindToRenderStep("SakuraMutateReveal", Enum.RenderPriority.Camera.Value + 1, function(p: number)
				total += p
				currentCamera.CFrame = cframe2:Lerp(
					cframe3,
					(TweenService:GetValue(
						math.clamp(total / 3.2, 0, 1),
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.Out
					))
				)
				local value2 = TweenService:GetValue(
					math.clamp(total / 0.9, 0, 1),
					Enum.EasingStyle.Back,
					Enum.EasingDirection.Out
				)
				model:ScaleTo((math.max(0.05, scale * value2)))
				model:PivotTo(cframe * CFrame.Angles(0, total * 1.2, 0))
			end)
			SakuraFX.EmitBurst("Bloom", cframe.Position, 80, Y * 2)
			SakuraFX.PlayCue("Bloom", localPlayer, 0.8, 1.15)
			TweenService:Create(pointLight, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Brightness = 5
			}):Play()
			task.wait(0.9)
			SakuraFX.PlayCue("Mutate", localPlayer, 1)
			SakuraFX.EmitBurst("Pickup", cframe.Position, 40, Y * 1.5)
			task.wait(2.3000000000000003)
			return v6.Egg.DisplayName, tint, v6.Egg.Icon
		end

		local function playMutateReveal(p)
			if flag then
				return
			end

			flag = true
			syncBillboardEnabled() -- equivalent call inferred; original call site unknown
			Tabs.Deactivate({
				instant = true
			})
			local v6 = HiddenUIHandler.Acquire()
			local v7 = Trove.new()
			local success, result, v8, image = pcall(runMutateReveal, v7, p)
			v7:Clean()
			v6()
			flag = false
			refresh()

			if not success then
				error(result)
			end

			Message.Notice(`Your {result} is now <font color="#{v8:ToHex()}">{Mutations.LabelOf(p.Mutation)}</font>!`, {
				Image = image,
				LeaveClosed = true
			})
		end

		refresh = function()
			if flag then
				return
			end

			if build:GetAttribute("DragonEventMap") == true or build:GetAttribute("CherryBlossomZoneRevealed") ~= true then
				maid:Clean()
				v4 = nil
				v5 = nil
			else
				local v6 = Save.Await()
				local unlocked

				if v6 == nil then
					unlocked = false
				else
					unlocked = v6.Sakura.Unlocked
				end

				if v5 ~= unlocked then
					buildTree(unlocked)
				end

				renderBillboard()
			end
		end

		Remotes.Bloomery.CutsceneOpened.OnClientEvent:Connect(function()
			task.spawn(playUnlockCutscene)
		end)
		SakuraSignals.Reveal:Connect(function(p)
			assert(Sakura2.MutateResult(p), "Sakura mutate reveal needs a valid result")
			task.spawn(playMutateReveal, p)
		end)
		Save.WatchFields("Sakura", refresh)
		build:GetAttributeChangedSignal("DragonEventMap"):Connect(refresh)
		build:GetAttributeChangedSignal("CherryBlossomZoneRevealed"):Connect(refresh)
		Save.Loaded:Connect(function(p)
			if p == localPlayer then
				refresh()
			end
		end)

		if Save.IsLoaded() then
			refresh()
		end

		task.spawn(function()
			while true do
				task.wait(1)

				if not v2 then
					continue
				end

				local v6 = Save.Await()
				local v7

				if v6 == nil then
					v7 = false
				else
					v7 = v6.Sakura.Unlocked
				end

				if v7 then
					renderBillboard()
				end
			end
		end)
		task.spawn(function()
			ContentProvider:PreloadAsync({ cameraAnimation, craneAnimation, playerAnimation })
		end)
	end
}