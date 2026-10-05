local createVector = vector.create
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local CrateOpeningSpinner = require(ReplicatedStorage.Client.UI.CrateOpeningSpinner)
local EggScaling = require(ReplicatedStorage.Shared.Util.EggScaling)
local EggToolDisplay = require(ReplicatedStorage.Shared.Eggs.EggToolDisplay)
local Emit = require(ReplicatedStorage.UserGenerated.VFX.Emit)
local GUI = require(ReplicatedStorage.Client.GUI)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Message = require(ReplicatedStorage.Client.Message)
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local MonsterParasite2 = require(ReplicatedStorage.Shared.Types.MonsterParasite)
require(ReplicatedStorage.Packages.Networking)
local ParasiteVisual = require(ReplicatedStorage.Shared.Eggs.ParasiteVisual)
local PlayVFX = require(ReplicatedStorage.UserGenerated.VFX.PlayVFX)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local rarities = Rarity.Rarities
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VisualTransform = require(ReplicatedStorage.Shared.Utils.VisualTransform)
return {
	Start = function()
		local monsterParasite = Remotes.MonsterParasite
		local fader = VisualTransform.Fader
		local random = Random.new()
		local localPlayer = Players.LocalPlayer
		local maid = Trove.new()
		local extended = maid:Extend()
		local v = {}
		local v2 = {}
		local v3 = nil
		local v4 = nil
		local v5 = nil
		local clone = MonsterParasite2.DefaultState()
		local active = false
		local v6 = false
		local v7 = false
		local flag = false
		local v8 = false
		local v9 = nil
		local v10 = nil
		local v11 = 0
		local v12 = 0
		local data = {}
		local v13 = nil
		local v14 = nil
		local v15 = nil
		local renderSteppedConnection = nil
		local v16 = nil
		local v17 = CameraShaker.new(Enum.RenderPriority.Camera.Value + 2, function(cframe: CFrame)
			local currentCamera = Workspace.CurrentCamera

			if currentCamera then
				currentCamera.CFrame *= cframe
			end
		end)

		local function runMotion(p: number, fn)
			local v18 = 0

			while v18 < p do
				v18 = math.min(v18 + RunService.PreRender:Wait(), p)

				if fn(v18 / p) then
					return false
				end
			end

			return true
		end

		local function playSound(childName: string, p)
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local sounds

			if assets then
				sounds = assets:FindFirstChild("Sounds")
			end

			local child

			if sounds then
				child = sounds:FindFirstChild(MonsterParasite.SoundFolderName)
			end

			local sound

			if child then
				sound = child:FindFirstChild(childName)
			end

			if sound and sound:IsA("Sound") then
				Audio.Play(sound, p)
			end
		end

		local function resolveChestTemplate()
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local models

			if assets then
				models = assets:FindFirstChild("Models")
			end

			local child

			if models then
				child = models:FindFirstChild(MonsterParasite.AssetsFolderName)
			end

			local model

			if child then
				model = child:FindFirstChild(MonsterParasite.ChestModelName)
			end

			if model and model:IsA("Model") and model.PrimaryPart then
				return model
			end

			return nil
		end

		local function resolveVfxTemplate(childName: string)
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local VFX

			if assets then
				VFX = assets:FindFirstChild("VFX")
			end

			local child

			if VFX then
				child = VFX:FindFirstChild(MonsterParasite.VfxFolderName)
			end

			local attachment

			if child then
				attachment = child:FindFirstChild(childName)
			end

			if attachment and attachment:IsA("Attachment") then
				return attachment
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveEnergyBurstTemplate()
			return (resolveVfxTemplate(MonsterParasite.EnergyBurstVfxName))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveSwapPoofTemplate()
			return (resolveVfxTemplate(MonsterParasite.SwapPoofVfxName))
		end

		local function preloadMonsterAssets()
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local models

			if assets then
				models = assets:FindFirstChild("Models")
			end

			local child

			if models then
				child = models:FindFirstChild(MonsterParasite.AssetsFolderName)
			else
				child = nil
			end

			if child == nil then
				return
			end

			local v18 = {}

			local function enqueueModel(childName: string)
				local folder = child:FindFirstChild(childName)

				if folder == nil then
					return
				end

				table.insert(v18, folder)

				for _, part in folder:GetDescendants() do
					if part:IsA("MeshPart") then
						table.insert(v18, part)
					end
				end
			end

			for _, monsterModelName in MonsterParasite.MonsterModelNames do
				enqueueModel(monsterModelName)
			end

			enqueueModel(MonsterParasite.ChestModelName)
			local v19 = {}

			for _, v20 in MonsterParasite.MonsterAnimationIdsByIndex do
				local burps = { v20.Idle, v20.Yank }
				local burp = v20.Burp

				if burp ~= nil then
					table.insert(burps, burp)
				end

				for _, v21 in burps do
					local animation = Instance.new("Animation")
					animation.AnimationId = `rbxassetid://{v21}`
					table.insert(v19, animation)
					table.insert(v18, animation)
				end
			end

			local particles

			if assets then
				particles = assets:FindFirstChild("Particles")
			end

			local child2

			if particles then
				child2 = particles:FindFirstChild(MonsterParasite.GroundHitParticlesName)
			end

			if child2 ~= nil then
				table.insert(v18, child2)
			end

			pcall(function()
				ContentProvider:PreloadAsync(v18)
			end)

			for _, v20 in v19 do
				v20:Destroy()
			end
		end

		local function getMonsterModelIndex(instance)
			local attribute = instance:GetAttribute(MonsterParasite.MonsterModelIndexAttributeName)

			if typeof(attribute) == "number" then
				return attribute
			end

			return nil
		end

		local function getMonsterAnimationIds(instance)
			local attribute = instance:GetAttribute(MonsterParasite.MonsterModelIndexAttributeName)

			if typeof(attribute) ~= "number" then
				attribute = nil
			end

			if attribute == nil then
				return nil
			end

			return MonsterParasite.MonsterAnimationIdsByIndex[attribute]
		end

		local function waitForAnimator(instance)
			local animator = instance:FindFirstChildWhichIsA("Animator", true)

			if animator ~= nil then
				return animator
			end

			local v18 = os.clock() + 5

			while true do
				task.wait()

				if instance.Parent == nil then
					break
				end

				local animator2 = instance:FindFirstChildWhichIsA("Animator", true)

				if not (animator2 ~= nil or v18 <= os.clock()) then
					continue
				end

				if animator2 == nil then
					warn((`[MonsterParasite] Missing Animator in {instance:GetFullName()}`))
				end

				return animator2
			end

			return nil
		end

		local function loadAnimationTrack(instance, p: number)
			local animator = waitForAnimator(instance)

			if animator == nil then
				return nil
			end

			local animation = Instance.new("Animation")
			animation.AnimationId = `rbxassetid://{p}`
			local success, result = pcall(function()
				return animator:LoadAnimation(animation)
			end)
			animation:Destroy()

			if success then
				return result
			end

			warn((`[MonsterParasite] Failed to load animation {p}: {result}`))
			return nil
		end

		local function playAnimationAndWait(object, instance, callback)
			local flag2 = false
			local bindableEvent = Instance.new("BindableEvent")
			local maid2 = Trove.new()
			maid2:Add(bindableEvent)

			local function finish()
				if flag2 then
					return
				end

				flag2 = true
				bindableEvent:Fire()
			end

			maid2:Connect(object.Ended, finish)
			maid2:Connect(object.Stopped, finish)
			maid2:Connect(instance.Destroying, finish)
			object:Play(0.1)
			maid2:Add(Timer.Simple(math.max(object.Length + 1, 5), finish))

			if callback then
				callback()
			end

			if not flag2 then
				bindableEvent.Event:Wait()
			end

			maid2:Destroy()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function pauseIdle(instance)
			local v18 = v2[instance]

			if v18 and v18.IsPlaying then
				v18:Stop(0.1)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resumeIdle(p)
			local v18 = v2[p]

			if v18 and p.Parent and not v18.IsPlaying then
				v18:Play(0.1)
			end
		end

		local v18 = {
			[2] = { "Tongue3" },
			[4] = { "root", "BackLeg1.L", "BackLeg1.R" }
		}
		local v19 = {}

		local function getPoseInfo(p: number)
			local v20 = v19[p]

			if v20 ~= nil then
				return v20
			end

			local success, result = pcall(function()
				local cFramesByName = {}
				local v21 = {}
				local scan

				scan = function(object)
					local name = object.Name
					local vector2 = cFramesByName[name]

					if vector2 == nil then
						cFramesByName[name] = object.CFrame
					elseif not (v21[name] or vector2:FuzzyEq(object.CFrame, 0.001)) then
						v21[name] = true
					end

					for _, v22 in object:GetSubPoses() do
						scan(v22)
					end
				end

				for _, v22 in KeyframeSequenceProvider:GetKeyframeSequenceAsync((`rbxassetid://{p}`)):GetKeyframes() do
					for _, pose in v22:GetChildren() do
						if pose:IsA("Pose") then
							scan(pose)
						end
					end
				end

				local result2 = {}

				for k in cFramesByName do
					result2[k] = {
						constant = not v21[k]
					}
				end

				return result2
			end)

			if not success then
				return nil
			end

			v19[p] = result
			return result
		end

		local function collectStrayBones(instance, data2, p: number)
			local idle = data2.Idle
			local result = v19[idle]

			if result == nil then
				local success
				success, result = pcall(function()
					local cFramesByName = {}
					local v20 = {}
					local scan

					scan = function(object)
						local name = object.Name
						local vector2 = cFramesByName[name]

						if vector2 == nil then
							cFramesByName[name] = object.CFrame
						elseif not (v20[name] or vector2:FuzzyEq(object.CFrame, 0.001)) then
							v20[name] = true
						end

						for _, v21 in object:GetSubPoses() do
							scan(v21)
						end
					end

					for _, v21 in KeyframeSequenceProvider:GetKeyframeSequenceAsync((`rbxassetid://{idle}`)):GetKeyframes() do
						for _, pose in v21:GetChildren() do
							if pose:IsA("Pose") then
								scan(pose)
							end
						end
					end

					local result2 = {}

					for k in cFramesByName do
						result2[k] = {
							constant = not v20[k]
						}
					end

					return result2
				end)

				if success then
					v19[idle] = result
				else
					result = nil
				end
			end

			if result == nil then
				return {}
			end

			local burps = { data2.Yank }
			local burp = data2.Burp

			if burp ~= nil then
				table.insert(burps, burp)
			end

			local v20 = {}

			for _, v21 in burps do
				local result2 = v19[v21]

				if result2 == nil then
					local success
					local v22 = v21
					success, result2 = pcall(function()
						local cFramesByName = {}
						local v23 = {}
						local scan

						scan = function(object)
							local name = object.Name
							local vector2 = cFramesByName[name]

							if vector2 == nil then
								cFramesByName[name] = object.CFrame
							elseif not (v23[name] or vector2:FuzzyEq(object.CFrame, 0.001)) then
								v23[name] = true
							end

							for k, v24 in object:GetSubPoses() do
								scan(v24)
							end
						end

						for k, v24 in KeyframeSequenceProvider:GetKeyframeSequenceAsync((`rbxassetid://{v22}`)):GetKeyframes() do
							for i, pose in v24:GetChildren() do
								if pose:IsA("Pose") then
									scan(pose)
								end
							end
						end

						local result3 = {}

						for k in cFramesByName do
							result3[k] = {
								constant = not v23[k]
							}
						end

						return result3
					end)

					if success then
						v19[v21] = result2
					else
						result2 = nil
					end
				end

				if result2 == nil then
					continue
				end

				for k in result2 do
					if result[k] == nil then
						v20[k] = true
					end
				end
			end

			for _, v21 in v18[p] or {} do
				local v22 = result[v21]

				if v22 == nil or v22.constant then
					v20[v21] = true
				end
			end

			local bones = {}

			for childName in v20 do
				local bone = instance:FindFirstChild(childName, true)

				if bone and bone:IsA("Bone") then
					table.insert(bones, bone)
				end
			end

			return bones
		end

		local function guardStrayBones(instance, p, p2, attribute: number, maid2)
			if instance.Parent == nil then
				return
			end

			local v20 = collectStrayBones(instance, p2, attribute)

			if #v20 == 0 then
				return
			end

			local transforms = {}
			local v21 = 0
			maid2:Connect(RunService.PostSimulation, function(p3: number)
				if p.IsPlaying then
					if v21 <= 0 then
						for _, v22 in v20 do
							transforms[v22] = v22.Transform
						end
					end

					v21 = math.min(v21 + p3, 0.18)
					local v22 = v21 / 0.18

					for _, v23 in v20 do
						local v24 = transforms[v23]
						local transform

						if v24 == nil or v22 >= 1 then
							transform = CFrame.identity
						else
							transform = v24:Lerp(CFrame.identity, v22)
						end

						v23.Transform = transform
					end
				else
					v21 = 0
					table.clear(transforms)
				end
			end)
		end

		local function startIdle(folder, maid2)
			local attribute = folder:GetAttribute(MonsterParasite.MonsterModelIndexAttributeName)

			if typeof(attribute) ~= "number" then
				attribute = nil
			end

			local v20

			if attribute == nil then
				v20 = nil
			else
				v20 = MonsterParasite.MonsterAnimationIdsByIndex[attribute]
			end

			local attribute2 = folder:GetAttribute(MonsterParasite.MonsterModelIndexAttributeName)

			if typeof(attribute2) ~= "number" then
				attribute2 = nil
			end

			if v20 == nil or attribute2 == nil then
				return
			end

			local v21 = false
			maid2:Add(function()
				v21 = true
			end)
			task.spawn(function()
				local v22 = loadAnimationTrack(folder, v20.Idle)

				if v22 == nil then
					return
				end

				if v21 or folder.Parent == nil then
					v22:Destroy()
					return
				end

				v22.Looped = true
				v22.Priority = Enum.AnimationPriority.Idle
				v2[folder] = v22
				maid2:Add(v22)
				maid2:Add(function()
					v2[folder] = nil
				end)
				v22:Play(0.1)
				guardStrayBones(folder, v22, v20, attribute2, maid2)
			end)
		end

		local function getEquippedEggTool()
			local character = localPlayer.Character

			if character == nil then
				return nil
			end

			for _, tool in character:GetChildren() do
				if tool:IsA("Tool") and EggToolDisplay.IsEggTool(tool) then
					return tool
				end
			end

			return nil
		end

		local function getEquippedEggHandle()
			local equippedEggTool = getEquippedEggTool()
			local handle

			if equippedEggTool then
				handle = equippedEggTool:FindFirstChild("Handle")
			end

			if handle and handle:IsA("BasePart") then
				return handle
			end

			return nil
		end

		local function getEquippedEggModel()
			local equippedEggTool = getEquippedEggTool()

			if equippedEggTool == nil then
				return nil
			end

			local toolUid = EggToolDisplay.GetToolUid(equippedEggTool)
			local model

			if toolUid then
				model = equippedEggTool:FindFirstChild((`{localPlayer.UserId}_{toolUid}`))
			end

			if model == nil or not model:IsA("Model") then
				return equippedEggTool:FindFirstChildOfClass("Model")
			end

			return model
		end

		local function getWorldCFrame(instance)
			if instance == nil then
				return nil
			end

			if instance:IsA("BasePart") then
				return instance.CFrame
			end

			if instance:IsA("Attachment") or instance:IsA("Bone") then
				return instance.WorldCFrame
			end

			return nil
		end

		local v20 = {
			ScaleTweenDelaySeconds = 0.2,
			PickupFadeStart = 0.55,
			PickupFadeEnd = 1,
			PickupMinScale = 0.001,
			PickupTargetHeight = 1.5,
			MouthTargetNames = { "MouthCenter1", "ParasiteEatTarget", "Tongue3" },
			MouthBiteStuds = 2.2,
			SeizeSeconds = 0.1,
			MouthPull = 0.85,
			SwallowSeconds = 0.2,
			HandPoseName = "toolnone",
			HandPoseReleaseSeconds = 0.4,
			SwallowDepth = 0.9,
			SwallowScale = 0.05,
			MinScale = 0.001
		}

		local function getAnimatedWorldCFrame(instance)
			if instance == nil then
				return nil
			end

			if instance:IsA("Attachment") then
				local parent = instance.Parent

				if parent == nil or not parent:IsA("Bone") then
					return instance.WorldCFrame
				end

				return parent.TransformedWorldCFrame * instance.CFrame
			else
				if instance:IsA("Bone") then
					return instance.TransformedWorldCFrame
				end

				if instance == nil then
					return nil
				end

				if instance:IsA("BasePart") then
					return instance.CFrame
				end

				if instance:IsA("Attachment") or instance:IsA("Bone") then
					return instance.WorldCFrame
				end

				return nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveGrabTarget(instance)
			return instance:FindFirstChild("ParasiteGrabber", true) or instance:FindFirstChild(
				MonsterParasite.TongueTipName,
				true
			) or instance:FindFirstChild(MonsterParasite.ParasiteEatTargetPartName, true)
		end

		local function resolveMouthTarget(instance)
			for _, childName in v20.MouthTargetNames do
				local child = instance:FindFirstChild(childName, true)

				if child ~= nil then
					return child
				end
			end

			return instance.PrimaryPart
		end

		local function resolveChestOrigin(instance)
			for _, childName in MonsterParasite.ChestOriginNames do
				local child = instance:FindFirstChild(childName, true)

				if child ~= nil then
					return child
				end
			end

			return nil
		end

		local function buildGroundProbeParams(instance)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.IgnoreWater = true
			local filterDescendantsInstances = { instance }

			if v4 then
				table.insert(filterDescendantsInstances, v4)
			end

			local child = Workspace:FindFirstChild(MonsterParasite.MarkerFolderName, true)

			if child then
				table.insert(filterDescendantsInstances, child)
			end

			for _, v22 in Players:GetPlayers() do
				local character = v22.Character

				if character then
					table.insert(filterDescendantsInstances, character)
				end
			end

			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			return raycastParams
		end

		local function monsterForward(instance, cframe: CFrame)
			local v21 = instance:GetPivot().LookVector * createVector(1, 0, 1)

			if v21.Magnitude < 0.05 then
				v21 = cframe.LookVector * createVector(1, 0, 1)
			end

			if v21.Magnitude > 0.001 then
				return v21.Unit
			end

			return createVector(0, 0, -1)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function probeGround(vector2: Vector3, p)
			return Workspace:Raycast(
				vector2 + createVector(0, 1, 0) * MonsterParasite.ChestGroundProbeHeight,
				createVector(0, 1, 0) * -MonsterParasite.ChestGroundProbeDepth,
				p
			)
		end

		local function resolveGroundLanding(instance, cframe: CFrame)
			local v21 = instance:GetPivot().LookVector * createVector(1, 0, 1)

			if v21.Magnitude < 0.05 then
				v21 = cframe.LookVector * createVector(1, 0, 1)
			end

			local v22 = not (v21.Magnitude > 0.001) and createVector(0, 0, -1) or v21.Unit
			local position = cframe.Position
			local groundProbeParams = buildGroundProbeParams(instance)
			local chestThrowDistanceMin = MonsterParasite.ChestThrowDistanceMin
			local v23 = math.max(MonsterParasite.ChestThrowDistanceMax - chestThrowDistanceMin, 0)
			local chestThrowSpreadDegrees = math.rad(MonsterParasite.ChestThrowSpreadDegrees)
			local chestThrowStraightJitterDegrees = math.rad(MonsterParasite.ChestThrowStraightJitterDegrees)
			local v24 = math.max(MonsterParasite.ChestThrowAttempts, 1)
			local v25 = math.max(math.floor(v24 / 2), 1)

			local function candidate(vector2: Vector3)
				local v26 = position + vector2 * (chestThrowDistanceMin + random:NextNumber() * v23)
				local raycastResult = Workspace:Raycast(position, v26 - position, groundProbeParams)

				if raycastResult ~= nil then
					v26 = raycastResult.Position - vector2 * 1.5

					if ((v26 - position) * createVector(1, 0, 1)).Magnitude < chestThrowDistanceMin then
						return nil, nil
					end
				end

				local v28 = probeGround(v26, groundProbeParams) -- equivalent call inferred; original call site unknown

				if v28 == nil then
					return nil, nil
				end

				return
					CFrame.new(v28.Position) * CFrame.Angles(0, random:NextNumber() * 3.141592653589793 * 2, 0),
					v28.Normal
			end

			for i = 1, v24 do
				local v26 = math.floor(i / 2)
				local v27

				if v26 == 0 then
					v27 = (random:NextNumber() * 2 - 1) * chestThrowStraightJitterDegrees
				else
					v27 = (i % 2 == 0 and 1 or -1) * chestThrowSpreadDegrees * math.min(v26 / v25, 1)
				end

				local v28, v29 = candidate(CFrame.fromAxisAngle(createVector(0, 1, 0), v27) * v22)

				if v28 ~= nil and v29 ~= nil then
					return v28, v29
				end
			end

			local v26 = position + v22 * chestThrowDistanceMin
			local raycastResult = Workspace:Raycast(position, v26 - position, groundProbeParams)

			if raycastResult ~= nil then
				v26 = raycastResult.Position - v22 * 1.5
			end

			local v27 = probeGround(v26, groundProbeParams) -- equivalent call inferred; original call site unknown
			local v28

			if v27 then
				v28 = v27.Position
			else
				v28 = Vector3.new(v26.X, instance:GetPivot().Position.Y, v26.Z)
			end

			local v29 = CFrame.new(v28) * CFrame.Angles(0, random:NextNumber() * 3.141592653589793 * 2, 0)

			if v27 then
				return v29, v27.Normal
			end

			return v29, createVector(0, 1, 0)
		end

		local function resolveEffectParent()
			local transient = Workspace:FindFirstChild("Transient")

			if transient and transient:IsA("Folder") then
				return transient
			end

			return Workspace
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearChest()
			if v4 then
				v4:Destroy()
				v4 = nil
			end
		end

		local function createChest(cframe: CFrame)
			local chestTemplate = resolveChestTemplate()

			if chestTemplate == nil then
				return nil
			end

			clearChest() -- equivalent call inferred; original call site unknown
			local clone2 = chestTemplate:Clone()

			for _, part in clone2:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
			end

			clone2:PivotTo(cframe)
			local transient = Workspace:FindFirstChild("Transient")

			if not (transient and transient:IsA("Folder")) then
				transient = Workspace
			end

			clone2.Parent = transient
			v4 = clone2
			return clone2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopPendingYankFollow()
			local connection = renderSteppedConnection
			renderSteppedConnection = nil

			if connection ~= nil then
				connection:Disconnect()
			end
		end

		local function prepareEggYankClone(equippedEggModel)
			if equippedEggModel.PrimaryPart == nil then
				return nil
			end

			local clone2 = equippedEggModel:Clone()

			local function inside(instance)
				return instance ~= nil and instance:IsDescendantOf(clone2)
			end

			for _, descendant in clone2:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Anchored = true
					descendant.CanCollide = false
					descendant.CanQuery = false
					descendant.CanTouch = false
					descendant.Massless = true
				elseif descendant:IsA("BillboardGui") then
					descendant:Destroy()
				elseif descendant:IsA("Motor6D") or descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
					local part0 = descendant.Part0
					local v21

					if part0 == nil then
						v21 = false
					else
						v21 = part0:IsDescendantOf(clone2)
					end

					if v21 then
						local part1 = descendant.Part1
						local v22

						if part1 == nil then
							v22 = false
						else
							v22 = part1:IsDescendantOf(clone2)
						end

						if v22 then
							continue
						end
					end

					descendant:Destroy()
				end
			end

			local transient = Workspace:FindFirstChild("Transient")

			if not (transient and transient:IsA("Folder")) then
				transient = Workspace
			end

			clone2.Parent = transient
			clone2:PivotTo(equippedEggModel:GetPivot())
			local model = equippedEggModel:FindFirstChild(MonsterParasite.ParasiteVisualName, true)
			local model2 = clone2:FindFirstChild(MonsterParasite.ParasiteVisualName, true)

			if model ~= nil and model2 ~= nil and model:IsA("Model") and model2:IsA("Model") then
				local v21 = ParasiteVisual.PoseDrift(model) - ParasiteVisual.PoseDrift(model2)

				if v21.Magnitude > 0.001 then
					model2:PivotTo(model2:GetPivot() + v21)
				end
			end

			return clone2
		end

		local function holdHandPose()
			if v16 ~= nil then
				return
			end

			local character = localPlayer.Character

			if character == nil then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local animator

			if humanoid == nil then
				animator = nil
			else
				animator = humanoid:FindFirstChildOfClass("Animator")
			end

			if animator == nil then
				return
			end

			local animate = character:FindFirstChild("Animate")
			local child

			if animate ~= nil then
				child = animate:FindFirstChild(v20.HandPoseName)
			end

			local animation

			if child == nil then
				animation = nil
			else
				animation = child:FindFirstChildOfClass("Animation")
			end

			if animation == nil then
				return
			end

			local action = Enum.AnimationPriority.Action

			for _, v22 in animator:GetPlayingAnimationTracks() do
				local animation2 = v22.Animation

				if not (animation2 ~= nil and animation2.AnimationId == animation.AnimationId) then
					continue
				end

				action = v22.Priority
				break
			end

			local success, result = pcall(function()
				return animator:LoadAnimation(animation)
			end)

			if not success then
				warn((`[MonsterParasite] Failed to hold the egg pose: {result}`))
				return
			end

			result.Looped = true
			result.Priority = action
			result:Play(0)
			v16 = result
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function releaseHandPose()
			local v21 = v16
			v16 = nil

			if v21 == nil then
				return
			end

			v21:Stop(v20.HandPoseReleaseSeconds)
			task.delay(v20.HandPoseReleaseSeconds, function()
				v21:Destroy()
			end)
		end

		local function captureEquippedEgg()
			if v13 ~= nil then
				return
			end

			local equippedEggModel = getEquippedEggModel()

			if equippedEggModel == nil then
				return
			end

			local v21 = prepareEggYankClone(equippedEggModel)

			if v21 == nil then
				return
			end

			local v22 = fader()
			v22:Hide(v21, 1)
			v13 = v21
			v15 = v22
			v14 = equippedEggModel
			holdHandPose()
			local v23 = nil
			local v24 = false
			stopPendingYankFollow() -- equivalent call inferred; original call site unknown
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if v21.Parent == nil then
					return
				end

				local character = localPlayer.Character
				local rightHand

				if character ~= nil then
					rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm") or character:FindFirstChild("HumanoidRootPart")
				end

				if rightHand == nil or not rightHand:IsA("BasePart") then
					rightHand = nil
				end

				if equippedEggModel:IsDescendantOf(Workspace) then
					if rightHand ~= nil then
						v23 = rightHand.CFrame:ToObjectSpace(equippedEggModel:GetPivot())
					end

					v21:PivotTo(equippedEggModel:GetPivot())
				else
					if not v24 then
						v24 = true
						v22:Hide(v21, 0)
					end

					if rightHand ~= nil and v23 ~= nil then
						v21:PivotTo(rightHand.CFrame * v23)
					end
				end
			end)
		end

		local function takeCapturedEgg()
			captureEquippedEgg()
			stopPendingYankFollow() -- equivalent call inferred; original call site unknown
			local v21 = v13
			local v22 = v15
			local v23 = v14
			v13 = nil
			v15 = nil
			v14 = nil

			if v21 == nil or v21.Parent == nil then
				releaseHandPose() -- equivalent call inferred; original call site unknown
				return nil
			else
				if v23 ~= nil and v23:IsDescendantOf(Workspace) then
					v21:PivotTo(v23:GetPivot())
					fader():Hide(v23, 1)
				end

				if v22 ~= nil then
					v22:Hide(v21, 0)
				end

				local character = localPlayer.Character

				if character ~= nil then
					ParasiteVisual.Clear(character)
				end

				releaseHandPose() -- equivalent call inferred; original call site unknown
				return v21
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function discardPendingYank()
			stopPendingYankFollow() -- equivalent call inferred; original call site unknown
			releaseHandPose() -- equivalent call inferred; original call site unknown

			if v13 ~= nil then
				v13:Destroy()
				v13 = nil
			end

			v15 = nil
			v14 = nil
		end

		local function carryEgg(instance, instance2)
			local boundingBox = instance:GetBoundingBox()
			local v21 = createVector(1, 1, 1) * (v20.MouthBiteStuds * instance2:GetScale())
			local scale = instance:GetScale()
			return {
				Model = instance,
				StartScale = scale,
				FitScale = math.min(scale, EggScaling.FitInside(instance, v21)),
				CenterOffset = instance:GetPivot():PointToObjectSpace(boundingBox.Position)
			}
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function placeCarriedEgg(data2, cframe: CFrame, p: number)
			local model = data2.Model
			model:ScaleTo(p)
			model:PivotTo(cframe * CFrame.new(-data2.CenterOffset * (p / data2.StartScale)))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function swallowEgg(p, instance, p2, vector2: Vector3, cframe: CFrame, p3: number)
			local model = p.Model
			local v21 = 0
			local preRenderConnection = nil
			preRenderConnection = RunService.PreRender:Connect(function(dt: number)
				v21 = math.min(v21 + dt, v20.SwallowSeconds)
				local v22 = model.Parent == nil or instance.Parent == nil

				if not v22 then
					local animatedWorldCFrame = getAnimatedWorldCFrame(p2)
					local position

					if animatedWorldCFrame == nil then
						position = cframe.Position
					else
						position = animatedWorldCFrame.Position + instance:GetPivot():VectorToWorldSpace(vector2) * (v20.SwallowDepth * instance:GetScale())
					end

					local value = TweenService:GetValue(
						v21 / v20.SwallowSeconds,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.In
					)
					placeCarriedEgg(
						p,
						CFrame.new(cframe.Position:Lerp(position, value)) * cframe.Rotation,
						math.max(v20.MinScale, (math.lerp(p3, p3 * v20.SwallowScale, value)))
					) -- equivalent call inferred; original call site unknown
				end

				if v22 or v21 >= v20.SwallowSeconds then
					preRenderConnection:Disconnect()
					model:Destroy()
				end
			end)
		end

		local function animateEggYank(instance)
			local primaryPart = instance.PrimaryPart

			if primaryPart == nil then
				discardPendingYank() -- equivalent call inferred; original call site unknown
			else
				local model2 = takeCapturedEgg()

				if model2 == nil then
					return
				end

				local mouthTarget = resolveMouthTarget(instance)
				local v22 = carryEgg(model2, instance)
				local v23 = model2:GetPivot() * CFrame.new(v22.CenterOffset)
				runMotion(MonsterParasite.YankDuration, function(p: number)
					if model2.Parent == nil or instance.Parent == nil then
						return true
					end

					local v24 = getAnimatedWorldCFrame(mouthTarget) or primaryPart.CFrame
					local value = TweenService:GetValue(p, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					placeCarriedEgg(
						v22,
						CFrame.new(v23.Position:Lerp(v24.Position, value)) * v23.Rotation,
						math.lerp(v22.StartScale, v22.FitScale, value)
					) -- equivalent call inferred; original call site unknown
					return nil
				end)

				if model2.Parent == nil or instance.Parent == nil then
					model2:Destroy()
					return
				end

				local v24 = model2:GetPivot() * CFrame.new(v22.CenterOffset * (v22.FitScale / v22.StartScale))
				local fitScale = v22.FitScale
				local model = v22.Model
				local v25 = 0
				local preRenderConnection = nil
				local v26 = createVector(0, 0, 1)
				preRenderConnection = RunService.PreRender:Connect(function(dt: number)
					v25 = math.min(v25 + dt, v20.SwallowSeconds)
					local v27 = model.Parent == nil or instance.Parent == nil

					if not v27 then
						local animatedWorldCFrame = getAnimatedWorldCFrame(mouthTarget)
						local position

						if animatedWorldCFrame == nil then
							position = v24.Position
						else
							position = animatedWorldCFrame.Position + instance:GetPivot():VectorToWorldSpace(v26) * (v20.SwallowDepth * instance:GetScale())
						end

						local value = TweenService:GetValue(
							v25 / v20.SwallowSeconds,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.In
						)
						placeCarriedEgg(
							v22,
							CFrame.new(v24.Position:Lerp(position, value)) * v24.Rotation,
							math.max(v20.MinScale, (math.lerp(fitScale, fitScale * v20.SwallowScale, value)))
						) -- equivalent call inferred; original call site unknown
					end

					if v27 or v25 >= v20.SwallowSeconds then
						preRenderConnection:Disconnect()
						model:Destroy()
					end
				end)
			end
		end

		local function animateEggGrab(instance, p)
			if not p.IsPlaying then
				animateEggYank(instance)
				return
			end

			local model = takeCapturedEgg()

			if model == nil then
				return
			end

			local grabTarget = resolveGrabTarget(instance) -- equivalent call inferred; original call site unknown
			local mouthTarget = resolveMouthTarget(instance)
			local animatedWorldCFrame = getAnimatedWorldCFrame(grabTarget)
			local animatedWorldCFrame2 = getAnimatedWorldCFrame(mouthTarget)

			if animatedWorldCFrame == nil or animatedWorldCFrame2 == nil then
				model:Destroy()
				return
			end

			local v22 = carryEgg(model, instance)
			local v23 = model:GetPivot() * CFrame.new(v22.CenterOffset)
			local rotation = v23.Rotation
			local v24 = v23.Position - animatedWorldCFrame.Position
			local v25 = animatedWorldCFrame.Position - animatedWorldCFrame2.Position
			local magnitude = v25.Magnitude
			local v26 = not (magnitude > 0.01) and createVector(0, 0, 1) or instance:GetPivot():VectorToObjectSpace(-v25.Unit)
			local total = 0
			local v27 = 0
			local renderSteppedConnection2 = nil
			renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt: number)
				if model.Parent == nil or instance.Parent == nil then
					renderSteppedConnection2:Disconnect()
					model:Destroy()
				else
					local animatedWorldCFrame3 = getAnimatedWorldCFrame(grabTarget)
					local animatedWorldCFrame4 = getAnimatedWorldCFrame(mouthTarget)

					if animatedWorldCFrame3 == nil or animatedWorldCFrame4 == nil then
						return
					end

					total += dt
					local v28

					if magnitude > 1 then
						v28 = 1 - (animatedWorldCFrame3.Position - animatedWorldCFrame4.Position).Magnitude / magnitude
					else
						v28 = total / MonsterParasite.YankDuration
					end

					v27 = math.clamp(math.max(v27, v28), 0, 1)
					local value = TweenService:GetValue(
						math.clamp(total / v20.SeizeSeconds, 0, 1),
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					)
					local value2 = TweenService:GetValue(v27, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local v29 = CFrame.new(animatedWorldCFrame3.Position:Lerp(
						animatedWorldCFrame4.Position,
						value2 * v20.MouthPull
					) + v24 * (1 - value)) * rotation
					local v30 = math.lerp(
						v22.StartScale,
						v22.FitScale,
						TweenService:GetValue(v27, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
					)
					placeCarriedEgg(v22, v29, v30) -- equivalent call inferred; original call site unknown

					if not p.IsPlaying then
						renderSteppedConnection2:Disconnect()
						swallowEgg(v22, instance, mouthTarget, v26, v29, v30) -- equivalent call inferred; original call site unknown
					end
				end
			end)
		end

		local function pulseMonsterScale(instance)
			local scale = instance:GetScale()
			runMotion(0.12, function(p: number)
				if instance.Parent == nil then
					return true
				end

				local value = TweenService:GetValue(p, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				instance:ScaleTo((math.lerp(scale, scale * 1.08, value)))
				return nil
			end)

			if instance.Parent == nil then
				return
			end

			runMotion(0.4, function(p: number)
				if instance.Parent == nil then
					return true
				end

				local value = TweenService:GetValue(p, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
				instance:ScaleTo((math.lerp(scale * 1.08, scale, value)))
				return nil
			end)

			if instance.Parent then
				instance:ScaleTo(scale)
			end
		end

		local v21 = {}
		local v22 = 0
		local count = 0

		local function wrapAngle(p: number)
			return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
		end

		local function getMonsterRestCFrame(instance)
			local v23 = v21[instance]

			if v23 ~= nil then
				return v23
			end

			local primaryPart = instance.PrimaryPart

			if primaryPart == nil then
				return nil
			end

			v21[instance] = primaryPart.CFrame
			return primaryPart.CFrame
		end

		local function applyFacingYaw(instance, p: number)
			local primaryPart = instance.PrimaryPart
			local cFrame = v21[instance]

			if cFrame == nil then
				local primaryPart2 = instance.PrimaryPart

				if primaryPart2 == nil then
					cFrame = nil
				else
					v21[instance] = primaryPart2.CFrame
					cFrame = primaryPart2.CFrame
				end
			end

			if primaryPart == nil or cFrame == nil then
				return
			end

			primaryPart.CFrame = cFrame * CFrame.fromEulerAnglesYXZ(0, p, 0)
		end

		local function adoptMonsterFacing(instance)
			local primaryPart = instance.PrimaryPart

			if primaryPart == nil then
				return
			end

			v21[instance] = primaryPart.CFrame

			if math.abs(v22) > 0.001 then
				local v23 = v22
				local primaryPart2 = instance.PrimaryPart
				local cFrame = v21[instance]

				if cFrame == nil then
					local primaryPart3 = instance.PrimaryPart

					if primaryPart3 == nil then
						cFrame = nil
					else
						v21[instance] = primaryPart3.CFrame
						cFrame = primaryPart3.CFrame
					end
				end

				if primaryPart2 ~= nil then
					if cFrame == nil then
						return
					else
						primaryPart2.CFrame = cFrame * CFrame.fromEulerAnglesYXZ(0, v23, 0)
					end
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function holdMonsterFacing(instance, p: number, p2: number)
			local v23 = math.min(p2 * 16, 1)
			v22 += ((p - v22 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * v23
			local v24 = v22
			local primaryPart = instance.PrimaryPart
			local cFrame = v21[instance]

			if cFrame == nil then
				local primaryPart2 = instance.PrimaryPart

				if primaryPart2 == nil then
					cFrame = nil
				else
					v21[instance] = primaryPart2.CFrame
					cFrame = primaryPart2.CFrame
				end
			end

			if primaryPart ~= nil then
				if cFrame == nil then
					return
				else
					primaryPart.CFrame = cFrame * CFrame.fromEulerAnglesYXZ(0, v24, 0)
				end
			end
		end

		local function releaseMonsterFacing()
			count += 1
			local v23 = count
			local v24 = v22

			if math.abs(v24) < 0.001 then
				v22 = 0
				return
			end

			runMotion(0.45, function(p: number)
				if count ~= v23 then
					return true
				end

				v22 = v24 * (1 - TweenService:GetValue(p, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
				local v25 = v3

				if v25 == nil or v25.Parent == nil then
					return nil
				end

				local v26 = v22
				local primaryPart = v25.PrimaryPart
				local cFrame = v21[v25]

				if cFrame == nil then
					local primaryPart2 = v25.PrimaryPart

					if primaryPart2 == nil then
						cFrame = nil
					else
						v21[v25] = primaryPart2.CFrame
						cFrame = primaryPart2.CFrame
					end
				end

				if primaryPart ~= nil and cFrame ~= nil then
					primaryPart.CFrame = cFrame * CFrame.fromEulerAnglesYXZ(0, v26, 0)
				end

				return nil
			end)

			if count ~= v23 then
				return
			end

			v22 = 0
			local v25 = v3

			if v25 ~= nil and v25.Parent ~= nil then
				local primaryPart = v25.PrimaryPart
				local cFrame = v21[v25]

				if cFrame == nil then
					local primaryPart2 = v25.PrimaryPart

					if primaryPart2 == nil then
						cFrame = nil
					else
						v21[v25] = primaryPart2.CFrame
						cFrame = primaryPart2.CFrame
					end
				end

				if primaryPart ~= nil then
					if cFrame == nil then
						return
					else
						primaryPart.CFrame = cFrame * CFrame.fromEulerAnglesYXZ(0, 0, 0)
					end
				end
			end
		end

		local function playYankAnimation(feedMonster)
			local primaryPart = feedMonster.PrimaryPart

			if primaryPart == nil then
				discardPendingYank() -- equivalent call inferred; original call site unknown
			else
				local attribute = feedMonster:GetAttribute(MonsterParasite.MonsterModelIndexAttributeName)

				if typeof(attribute) ~= "number" then
					attribute = nil
				end

				local v23

				if attribute ~= nil then
					v23 = MonsterParasite.MonsterAnimationIdsByIndex[attribute]
				end

				local v24

				if v23 then
					v24 = loadAnimationTrack(feedMonster, v23.Yank)
				else
					v24 = nil
				end

				if v24 == nil then
					playSound(MonsterParasite.YankSoundName, primaryPart)
					animateEggYank(feedMonster)
				else
					local maid2 = Trove.new()
					maid2:Add(v24)
					maid2:Add(function()
						if feedMonster.Parent then
							resumeIdle(feedMonster) -- equivalent call inferred; original call site unknown
						end
					end)
					count += 1
					maid2:Connect(RunService.RenderStepped, function(p: number)
						if feedMonster.Parent == nil then
							return
						end

						local equippedEggTool = getEquippedEggTool()
						local handle

						if equippedEggTool then
							handle = equippedEggTool:FindFirstChild("Handle")
						end

						if not (handle and handle:IsA("BasePart")) then
							handle = nil
						end

						if handle == nil then
							return
						end

						local v25 = feedMonster
						local cFrame = v21[v25]

						if cFrame == nil then
							local primaryPart2 = v25.PrimaryPart

							if primaryPart2 == nil then
								cFrame = nil
							else
								v21[v25] = primaryPart2.CFrame
								cFrame = primaryPart2.CFrame
							end
						end

						if cFrame == nil then
							return
						end

						local vector2 = Vector3.new(handle.Position.X, cFrame.Position.Y, handle.Position.Z)

						if (vector2 - cFrame.Position).Magnitude <= 0.001 then
							return
						end

						local _, v26 = cFrame:ToOrientation()
						local _, v27 = CFrame.lookAt(cFrame.Position, vector2):ToOrientation()
						holdMonsterFacing(
							feedMonster,
							(v27 - v26 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793,
							p
						) -- equivalent call inferred; original call site unknown
					end)
					local flag2 = false

					-- equivalent calls inferred from this helper; original call sites unknown
					local function grabNow()
						if flag2 then
							return
						end

						flag2 = true

						if feedMonster.Parent ~= nil then
							animateEggGrab(feedMonster, v24)
						end
					end

					maid2:Connect(v24:GetMarkerReachedSignal(MonsterParasite.GrabMarkerName), grabNow)
					pauseIdle(feedMonster) -- equivalent call inferred; original call site unknown
					playSound(MonsterParasite.YankSoundName, primaryPart)
					v24.Looped = false
					v24.Priority = Enum.AnimationPriority.Action4
					playAnimationAndWait(v24, feedMonster, nil)

					if not flag2 then
						warn((`[MonsterParasite] Yank animation did not reach the {MonsterParasite.GrabMarkerName} marker`))
						grabNow() -- equivalent call inferred; original call site unknown
					end

					maid2:Destroy()
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function emitEnergyBurst(parent, object)
			local energyBurstTemplate = resolveEnergyBurstTemplate() -- equivalent call inferred; original call site unknown

			if energyBurstTemplate == nil then
				return
			end

			local clone2 = energyBurstTemplate:Clone()
			clone2.Parent = parent
			object:Add(clone2)
			Emit(clone2)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function animateMonsterRoar(instance, object)
			local pivot = instance:GetPivot()
			local v23 = 0
			local preRenderConnection = nil
			preRenderConnection = RunService.PreRender:Connect(function(dt: number)
				if instance.Parent == nil then
					preRenderConnection:Disconnect()
					return
				end

				v23 = math.min(v23 + dt, MonsterParasite.RoarDuration)
				local v24 = v23 / MonsterParasite.RoarDuration
				local v25 = math.sin(v24 * 3.141592653589793)
				local v26 = math.sin(v24 * 3.141592653589793 * 3) * 0.15707963267948966 * v25
				local v27 = math.sin(v24 * 3.141592653589793) * 0.4
				instance:PivotTo(pivot * CFrame.new(0, v27, 0) * CFrame.Angles(v26, 0, v26 * -0.35))

				if v24 >= 1 then
					instance:PivotTo(pivot)
					preRenderConnection:Disconnect()
				end
			end)
			object:Add(preRenderConnection)
		end

		local function upAlignedCFrame(position: Vector3, vector2: Vector3)
			local vector3 = not (vector2.Magnitude > 0.001) and createVector(0, 1, 0) or vector2.Unit
			local cross = (math.abs(vector3.Y) > 0.99 and createVector(1, 0, 0) or createVector(0, 1, 0)):Cross(vector3)
			local v23 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
			local unit = vector3:Cross(v23).Unit
			return CFrame.fromMatrix(position, v23, vector3, -unit)
		end

		local function resolveImpactParticles()
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local particles

			if assets then
				particles = assets:FindFirstChild("Particles")
			end

			local emitter

			if particles then
				emitter = particles:FindFirstChild(MonsterParasite.GroundHitParticlesName)
			end

			if emitter == nil then
				return nil
			end

			if emitter:IsA("ParticleEmitter") or emitter:FindFirstChildWhichIsA("ParticleEmitter", true) ~= nil then
				return emitter
			end

			return nil
		end

		local function emitGroundHit(cFrame: CFrame)
			local impactParticles = resolveImpactParticles()

			if impactParticles == nil then
				return
			end

			local part = Instance.new("Part")
			part.Name = "MonsterChestGroundHit"
			part.Size = createVector(1, 1, 1)
			part.CFrame = cFrame
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Transparency = 1
			local transient = Workspace:FindFirstChild("Transient")

			if not (transient and transient:IsA("Folder")) then
				transient = Workspace
			end

			part.Parent = transient
			local clone2 = impactParticles:Clone()

			if not pcall(PlayVFX, part, cFrame, clone2) then
				clone2:Destroy()
			end

			Debris:AddItem(part, 3)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function shakeCamera(position: Vector3, chestImpactShakeMagnitude: number)
			local currentCamera = Workspace.CurrentCamera

			if currentCamera == nil then
				return
			end

			local chestImpactShakeRange = MonsterParasite.ChestImpactShakeRange
			local magnitude = (currentCamera.CFrame.Position - position).Magnitude

			if chestImpactShakeRange <= magnitude then
				return
			end

			v17:ShakeOnce(
				chestImpactShakeMagnitude * (1 - magnitude / chestImpactShakeRange),
				MonsterParasite.ChestImpactShakeRoughness,
				MonsterParasite.ChestImpactShakeFadeIn,
				MonsterParasite.ChestImpactShakeFadeOut
			)
		end

		local function animateChestLaunch(instance, p)
			local DISTANCE_EPSILON = 0.001
			local primaryPart = instance.PrimaryPart
			assert(primaryPart ~= nil, "Monster model requires a PrimaryPart")
			local v23 = getAnimatedWorldCFrame(p) or primaryPart.CFrame
			local chest = createChest(v23)

			if chest == nil then
				return
			end

			local scale = chest:GetScale()
			local v24 = scale * MonsterParasite.ChestLaunchStartScale
			local groundLanding, v25 = resolveGroundLanding(instance, v23)
			local position = groundLanding.Position
			chest:PivotTo(groundLanding)
			local boundingBox, v26 = chest:GetBoundingBox()
			local v27 = groundLanding + createVector(0, 1, 0) * (position.Y - (boundingBox.Position.Y - v26.Y * 0.5))
			chest:PivotTo(v23)
			chest:ScaleTo(v24)
			local position2 = v23.Position
			local position3 = v27.Position
			local v28 = (position3 - position2) * createVector(1, 0, 1)
			local unit

			if v28.Magnitude > DISTANCE_EPSILON then
				unit = v28.Unit
			else
				local v29 = instance:GetPivot().LookVector * createVector(1, 0, 1)

				if v29.Magnitude < 0.05 then
					v29 = v23.LookVector * createVector(1, 0, 1)
				end

				unit = not (v29.Magnitude > DISTANCE_EPSILON) and createVector(0, 0, -1) or v29.Unit
			end

			local v29 = math.max(position2.Y, position3.Y) + MonsterParasite.ChestLaunchHeight
			local v30 = v28.Magnitude * 0.55
			local vector2 = Vector3.new(
				position2.X + unit.X * v30,
				v29 * 2 - (position2.Y + position3.Y) * 0.5,
				position2.Z + unit.Z * v30
			)

			local function curve(p2: number)
				return position2:Lerp(vector2, p2):Lerp(vector2:Lerp(position3, p2), p2)
			end

			local cross = (createVector(0, 1, 0)):Cross(unit)
			local v31 = not (cross.Magnitude > DISTANCE_EPSILON) and createVector(1, 0, 0) or cross.Unit
			local v32 = MonsterParasite.ChestLaunchSpins * 3.141592653589793 * 2
			local rotation = v23.Rotation
			local rotation2 = v27.Rotation
			runMotion(MonsterParasite.ChestLaunchDuration, function(p2: number)
				if chest.Parent == nil then
					return true
				end

				local value = TweenService:GetValue(p2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				chest:PivotTo(CFrame.new(curve(p2)) * CFrame.fromAxisAngle(v31, v32 * value) * rotation:Lerp(
					rotation2,
					value
				))
				chest:ScaleTo((math.lerp(v24, scale, p2)))
				return nil
			end)

			if chest.Parent == nil then
				return
			end

			chest:ScaleTo(scale)
			chest:PivotTo(v27)
			local primaryPart2 = chest.PrimaryPart or primaryPart
			playSound(MonsterParasite.ChestLandingSoundName, primaryPart2)
			emitGroundHit(upAlignedCFrame(position, v25))
			shakeCamera(position, MonsterParasite.ChestImpactShakeMagnitude) -- equivalent call inferred; original call site unknown
			runMotion(MonsterParasite.ChestBounceDuration, function(p2: number)
				if v4 ~= chest then
					return true
				end

				local v33 = 1 - p2
				local v34 = math.sin(p2 * 3.141592653589793) * v33 * MonsterParasite.ChestBounceHeight
				local v35 = math.sin(p2 * 3.141592653589793 * 4) * v33 * 0.20943951023931956
				chest:PivotTo(CFrame.new(position3 + createVector(0, 1, 0) * v34) * rotation2 * CFrame.Angles(0, 0, v35))
				return nil
			end)

			if chest.Parent then
				chest:PivotTo(v27)
			end

			task.wait(MonsterParasite.ChestGroundRestDuration)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function arcApex(vector2: Vector3, vector3: Vector3)
			local v23 = math.clamp((vector3 - vector2).Magnitude * 0.6, 2, 36) + MonsterParasite.ChestPickupRise
			return vector2:Lerp(vector3, 0.5) + createVector(0, 1, 0) * v23
		end

		local function animateChestPickup(instance)
			local character = localPlayer.Character
			local primaryPart

			if character then
				primaryPart = character.PrimaryPart
			else
				primaryPart = nil
			end

			if primaryPart == nil then
				return
			end

			local pivot = instance:GetPivot()
			local position = pivot.Position
			local scale = instance:GetScale()
			local v23 = fader()
			local v24 = math.max(v20.PickupFadeEnd - v20.PickupFadeStart, 0.001)
			runMotion(MonsterParasite.ChestPickupDuration, function(p: number)
				if instance.Parent == nil then
					return true
				end

				local v25 = primaryPart.Position + createVector(0, 1, 0) * v20.PickupTargetHeight
				local v27 = arcApex(position, v25) -- equivalent call inferred; original call site unknown
				local value = TweenService:GetValue(p, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				local lerped = position:Lerp(v27, value):Lerp(v27:Lerp(v25, value), value)
				local vector2 = Vector3.new(v25.X, lerped.Y, v25.Z)
				local v29

				if (lerped - vector2).Magnitude < 0.001 then
					v29 = CFrame.new(lerped) * pivot.Rotation
				else
					v29 = CFrame.lookAt(lerped, vector2)
				end

				instance:PivotTo(v29)
				local value2 = TweenService:GetValue(
					math.clamp((p - v20.PickupFadeStart) / v24, 0, 1),
					Enum.EasingStyle.Exponential,
					Enum.EasingDirection.In
				)
				v23:Hide(instance, value2)
				instance:ScaleTo((math.max(v20.PickupMinScale, scale * (1 - value2))))
				return nil
			end)
		end

		local function playBurpAnimation(instance, p, onBurpBeat)
			local attribute = instance:GetAttribute(MonsterParasite.MonsterModelIndexAttributeName)

			if typeof(attribute) ~= "number" then
				attribute = nil
			end

			local v23

			if attribute ~= nil then
				v23 = MonsterParasite.MonsterAnimationIdsByIndex[attribute]
			end

			local burp

			if v23 then
				burp = v23.Burp
			end

			local v24

			if burp then
				v24 = loadAnimationTrack(instance, burp)
			else
				v24 = nil
			end

			local flag2 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function beatNow()
				if flag2 then
					return
				end

				flag2 = true
				playSound(MonsterParasite.BurpSoundName, p)
				onBurpBeat()
			end

			if v24 == nil then
				beatNow() -- equivalent call inferred; original call site unknown
				task.wait(MonsterParasite.BurpBeatDuration)
			else
				local maid2 = Trove.new()
				maid2:Add(v24)
				maid2:Add(function()
					if instance.Parent then
						resumeIdle(instance) -- equivalent call inferred; original call site unknown
					end
				end)
				maid2:Connect(v24:GetMarkerReachedSignal(MonsterParasite.BurpMarkerName), beatNow)
				pauseIdle(instance) -- equivalent call inferred; original call site unknown
				v24.Looped = false
				v24.Priority = Enum.AnimationPriority.Action3
				playAnimationAndWait(v24, instance, function()
					local chestLaunchBeatFallback = MonsterParasite.ChestLaunchBeatFallback

					if v24.Length > 0 then
						chestLaunchBeatFallback = math.min(chestLaunchBeatFallback, (math.max(v24.Length - 0.1, 0.05)))
					end

					maid2:Add(Timer.Simple(chestLaunchBeatFallback, function()
						if flag2 then
							return
						end

						warn((`[MonsterParasite] Burp animation did not reach the {MonsterParasite.BurpMarkerName} marker`))
						beatNow() -- equivalent call inferred; original call site unknown
					end))
				end)
				beatNow() -- equivalent call inferred; original call site unknown
				maid2:Destroy()
			end
		end

		local function animateFullCharge(feedMonster)
			local primaryPart = feedMonster.PrimaryPart

			if primaryPart == nil then
				return false
			end

			local v23 = resolveChestOrigin(feedMonster) or primaryPart
			local maid2 = Trove.new()
			v5 = feedMonster
			maid2:Add(function()
				if v5 == feedMonster then
					v5 = nil
				end
			end)
			local thread = nil
			local v24 = false

			local function onBurpBeat()
				thread = task.spawn(function()
					if MonsterParasite.ChestLaunchDelay > 0 then
						task.wait(MonsterParasite.ChestLaunchDelay)
					end

					local success, result = pcall(animateChestLaunch, feedMonster, v23)
					v24 = true

					if not success then
						warn((`[MonsterParasite] Chest launch failed: {result}`))
					end
				end)
				local success, result = pcall(function()
					playSound(MonsterParasite.RoarSoundName, primaryPart)
					playSound(MonsterParasite.EnergyBurstSoundName, v23)
					emitEnergyBurst(v23, maid2) -- equivalent call inferred; original call site unknown
					animateMonsterRoar(feedMonster, maid2) -- equivalent call inferred; original call site unknown
				end)

				if not success then
					warn((`[MonsterParasite] Full charge dressing failed: {result}`))
				end
			end

			playBurpAnimation(feedMonster, v23, onBurpBeat)

			while thread ~= nil and not v24 and coroutine.status(thread) ~= "dead" do
				task.wait()
			end

			maid2:Destroy()
			return v24
		end

		local function getPrompt(childName: string)
			local v23 = v3

			if v23 == nil then
				return nil
			end

			local proximityPrompt = v23:FindFirstChild(childName, true)

			if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
				return proximityPrompt
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setPromptEnabled(proximityPrompt, enabled: boolean)
			if proximityPrompt and proximityPrompt.Enabled ~= enabled then
				proximityPrompt.Enabled = enabled
			end
		end

		local function isHoldingParasiteEgg()
			local character = localPlayer.Character
			local v23 = Save.Await()

			if character == nil or v23 == nil then
				return false
			end

			for _, tool in character:GetChildren() do
				if not (tool:IsA("Tool") and EggToolDisplay.IsEggTool(tool)) then
					continue
				end

				local toolUid = EggToolDisplay.GetToolUid(tool)
				local v24

				if toolUid then
					v24 = v23.EggInventory[toolUid]
				end

				if v24 ~= nil and v24.HasParasite == true then
					return true
				end
			end

			return false
		end

		local function refreshPrompts()
			local talkPromptName = MonsterParasite.TalkPromptName
			local v23 = v3
			local proximityPrompt

			if v23 ~= nil then
				proximityPrompt = v23:FindFirstChild(talkPromptName, true)

				if not (proximityPrompt and proximityPrompt:IsA("ProximityPrompt")) then
					proximityPrompt = nil
				end
			end

			local feedPromptName = MonsterParasite.FeedPromptName
			local v24 = v3
			local proximityPrompt2

			if v24 ~= nil then
				proximityPrompt2 = v24:FindFirstChild(feedPromptName, true)

				if not (proximityPrompt2 and proximityPrompt2:IsA("ProximityPrompt")) then
					proximityPrompt2 = nil
				end
			end

			local chestPromptName = MonsterParasite.ChestPromptName
			local v25 = v3
			local proximityPrompt3

			if v25 ~= nil then
				proximityPrompt3 = v25:FindFirstChild(chestPromptName, true)

				if not (proximityPrompt3 and proximityPrompt3:IsA("ProximityPrompt")) then
					proximityPrompt3 = nil
				end
			end

			local viewRewardsPromptName = MonsterParasite2.ViewRewardsPromptName
			local v26 = v3
			local proximityPrompt4

			if v26 ~= nil then
				proximityPrompt4 = v26:FindFirstChild(viewRewardsPromptName, true)

				if not (proximityPrompt4 and proximityPrompt4:IsA("ProximityPrompt")) then
					proximityPrompt4 = nil
				end
			end

			local v27 = flag or v6 or v7 or v8 or v11 > 0
			local enabled = active and not v27 and isHoldingParasiteEgg()
			setPromptEnabled(proximityPrompt2, enabled) -- equivalent call inferred; original call site unknown
			setPromptEnabled(proximityPrompt3, false) -- equivalent call inferred; original call site unknown
			setPromptEnabled(proximityPrompt, not (enabled or v27)) -- equivalent call inferred; original call site unknown
			setPromptEnabled(proximityPrompt4, not v27) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function renderState()
			if clone.PendingChests <= 0 and v11 <= 0 and v4 then
				v4:Destroy()
				v4 = nil
			end

			refreshPrompts()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function storeState(p)
			clone = table.clone(p)

			if v3 then
				v3:SetAttribute("Charge", p.Charge)
				v3:SetAttribute("PendingChests", p.PendingChests)
			end
		end

		local function applyState(p)
			local v23

			if p.PendingChests > clone.PendingChests and p.Charge < clone.Charge then
				v23 = clone.Charge + MonsterParasite.ChargePerFeed >= MonsterParasite.MaxCharge
			else
				v23 = false
			end

			storeState(p) -- equivalent call inferred; original call site unknown

			if v23 then
				v11 += 1
				v12 += 1
				refreshPrompts()
			elseif not flag and v11 <= 0 and not v8 then
				renderState() -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showError(p: string)
			task.spawn(Message.Warn, p)
		end

		local function acknowledgeChest(openingId: string)
			local message = nil

			for i = 1, 3 do
				local success, result = pcall(function()
					return monsterParasite.AskChestRevealComplete:InvokeServer(openingId)
				end)

				if success and MonsterParasite2.RevealResultSchema(result) then
					if result.Success then
						return true, nil
					else
						message = result.Message
					end
				else
					message = success and "The reward confirmation was invalid." or tostring(result)
				end

				if i < 3 then
					task.wait(0.4)
				end
			end

			return false, message
		end

		local function beginChestReveal(data2)
			local openingId = data2.OpeningId

			if openingId == nil or data2.Reward == nil then
				v8 = false
				renderState() -- equivalent call inferred; original call site unknown
				showError("The Monster Chest reward was invalid.") -- equivalent call inferred; original call site unknown
			else
				if v9 == openingId or v10 == openingId or v9 ~= nil then
					return
				end

				v9 = openingId
				v8 = true
				refreshPrompts()
				local character = localPlayer.Character
				local primaryPart

				if character then
					primaryPart = character.PrimaryPart
				end

				local v23 = v4
				local v24 = v3

				if v23 and v23.PrimaryPart then
					primaryPart = v23.PrimaryPart
				elseif not primaryPart then
					if v24 then
						primaryPart = v24.PrimaryPart
					else
						primaryPart = nil
					end
				end

				if primaryPart then
					playSound(MonsterParasite.ChestSoundName, primaryPart)
				end

				clearChest() -- equivalent call inferred; original call site unknown
				task.spawn(function()
					local success, result = pcall(CrateOpeningSpinner.Play, data2)

					if not success then
						warn((`[MonsterParasite] Crate opening presentation failed: {result}`))
					end

					local v25, v26 = acknowledgeChest(openingId)

					if not v25 then
						task.spawn(Message.Warn, v26 or "The Monster Chest reveal is still finishing.")
					end

					v10 = openingId
					v9 = nil
					v8 = false
					clone.PendingChests = data2.PendingChests or 0
					refreshPrompts()
					renderState() -- equivalent call inferred; original call site unknown
				end)
			end
		end

		local function requestFeed()
			if not active then
				showError("The Monster Parasite event is not active.") -- equivalent call inferred; original call site unknown
				return
			end

			if v6 or flag or v7 or v11 > 0 or v8 or v9 ~= nil then
				return
			end

			v6 = true
			refreshPrompts()
			captureEquippedEgg()
			task.spawn(function()
				local success, result = pcall(function()
					return monsterParasite.AskFeed:InvokeServer()
				end)

				if success and MonsterParasite2.FeedResultSchema(result) then
					if not result.Success then
						v6 = false
						refreshPrompts()
						discardPendingYank() -- equivalent call inferred; original call site unknown
						showError(result.Message) -- equivalent call inferred; original call site unknown
					end
				else
					v6 = false
					refreshPrompts()
					discardPendingYank() -- equivalent call inferred; original call site unknown
					showError(success and "The monster did not understand that request." or tostring(result)) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local function requestChest()
			if v7 or v6 or flag or v11 > 0 or v8 or v9 ~= nil then
				return
			end

			v7 = true
			v8 = true
			refreshPrompts()
			local GUID = HttpService:GenerateGUID(false)
			task.spawn(function()
				local v23 = nil
				local v24 = nil

				for i = 1, 3 do
					local success, result = pcall(function()
						return monsterParasite.AskChestClaim:InvokeServer(GUID)
					end)

					if success and MonsterParasite2.ChestResultSchema(result) then
						if result.Success or result.Message ~= "Another Monster Parasite action is still finishing." then
							v23 = result
							break
						else
							v23 = result
						end
					elseif success then
						v24 = "The Monster Chest could not be opened."
					else
						v24 = tostring(result)
					end

					if v9 == GUID or v10 == GUID then
						break
					end

					if i < 3 then
						task.wait(0.4)
					end
				end

				v7 = false
				refreshPrompts()

				if v9 == GUID or v10 == GUID then
					return
				end

				if v23 == nil then
					v8 = false
					renderState() -- equivalent call inferred; original call site unknown
					task.spawn(Message.Warn, v24 or "The Monster Chest could not be opened.")
				elseif v23.Success then
					beginChestReveal(v23)
				elseif v9 == nil then
					v8 = false
					renderState() -- equivalent call inferred; original call site unknown
					showError(v23.Message) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local function requestTakeChest()
			local success, result = pcall(function()
				return monsterParasite.AskChestTake:InvokeServer()
			end)

			if success and MonsterParasite2.TakeResultSchema(result) then
				if result.Success then
					clearChest() -- equivalent call inferred; original call site unknown
				else
					showError(result.Message) -- equivalent call inferred; original call site unknown
				end
			else
				showError(success and "The Monster Chest could not be picked up." or tostring(result)) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function deliverChestTool()
			local v23 = v4

			if v23 and v23.Parent then
				animateChestPickup(v23)
			end

			requestTakeChest()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isChestTool(instance)
			return instance:GetAttribute("ItemType") == MonsterParasite.ChestToolItemType
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindChestTool(tool)
			extended:Connect(tool.Activated, requestChest)
		end

		local v23 = {
			Accessor = "MonsterChestRewards",
			RarityGradients = {
				["BEST REWARD"] = "Prismatic"
			},
			PlateDim = 0.36,
			PanelAspect = 1.18,
			MaxRowAspect = 6,
			MinRowHeight = 30,
			RowGapFraction = 0.09,
			ScrollerSize = Vector2.new(0.972, 0.862),
			ScrollerCenter = Vector2.new(0.5, 0.5465),
			PadXFraction = 0.012,
			PadYFraction = 0.012,
			RowPadFraction = 0.11,
			SlotGapFraction = 0.3,
			PillHeightFraction = 0.52,
			PillPadFraction = 0.34,
			GlowScale = 1.15,
			IconScale = 0.76,
			NameTextCap = 0.44,
			ChanceTextCap = 0.34,
			NoteTextCap = 0.28,
			PillCharWidth = 0.62,
			NoteCharWidth = 0.62,
			FlowSeconds = 6,
			RainbowHueSpan = 0.3,
			Cards = {},
			Flowing = {},
			Motion = nil,
			Sizing = nil
		}

		local function dimColor(value: Color3, plateDim: number)
			return Color3.new(value.R * plateDim, value.G * plateDim, value.B * plateDim)
		end

		local function sampleStops(list, p: number)
			for i = 1, #list - 1 do
				local v24 = list[i]
				local v25 = list[i + 1]

				if not (v24.Time <= p and p <= v25.Time) then
					continue
				end

				local v26 = v25.Time - v24.Time
				return v24.Value:Lerp(v25.Value, v26 <= 0 and 0 or (p - v24.Time) / v26)
			end

			return list[#list].Value
		end

		local function rolledPalette(dimmed, p: number)
			local v24 = sampleStops(dimmed, -p % 1)
			local colorSequenceKeypoints = { ColorSequenceKeypoint.new(0, v24) }

			for i = 1, #dimmed - 1 do
				local v25 = (dimmed[i].Time + p) % 1

				if v25 > 0 and v25 < 1 then
					table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v25, dimmed[i].Value))
				end
			end

			table.sort(colorSequenceKeypoints, function(a, b)
				return a.Time < b.Time
			end)
			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(1, v24))
			return ColorSequence.new(colorSequenceKeypoints)
		end

		local function isRainbow(p)
			local keypoints = p.Color.Keypoints
			local value = keypoints[1].Value
			local value2 = keypoints[#keypoints].Value

			if math.abs(value.R - value2.R) + math.abs(value.G - value2.G) + math.abs(value.B - value2.B) > 0.02 then
				return false
			end

			local v24 = 1
			local v25 = 0

			for _, keypoint in keypoints do
				local HSV = Color3.toHSV(keypoint.Value)
				v24 = math.min(v24, HSV)
				v25 = math.max(v25, HSV)
			end

			return v25 - v24 >= v23.RainbowHueSpan
		end

		local function paintRewardCard(clone2, rarityGradient)
			local keypoints = rarityGradient.Color.Keypoints
			local colorSequenceKeypoints = table.create(#keypoints)

			for k, keypoint in keypoints do
				colorSequenceKeypoints[k] = ColorSequenceKeypoint.new(
					keypoint.Time,
					dimColor(keypoint.Value, v23.PlateDim)
				)
			end

			local uIGradient = clone2:FindFirstChildOfClass("UIGradient")

			if uIGradient ~= nil then
				uIGradient.Color = ColorSequence.new(colorSequenceKeypoints)
				uIGradient.Rotation = isRainbow(rarityGradient) and 0 or 90
			end

			local value = keypoints[1].Value
			clone2.UIStrokeClr.Color = value
			clone2.Glow.ImageColor3 = value

			if uIGradient ~= nil and isRainbow(rarityGradient) then
				table.insert(v23.Flowing, {
					Plate = uIGradient,
					Rim = clone2.UIStrokeClr,
					Glow = clone2.Glow,
					Dimmed = colorSequenceKeypoints,
					Bright = keypoints
				})
			end
		end

		local function startRewardFlow(p)
			if v23.Motion ~= nil then
				v23.Motion:Disconnect()
				v23.Motion = nil
			end

			if #v23.Flowing == 0 then
				return
			end

			v23.Motion = RunService.RenderStepped:Connect(function()
				if p.Enabled then
					local v24 = os.clock() % v23.FlowSeconds / v23.FlowSeconds

					for _, v25 in v23.Flowing do
						v25.Plate.Color = rolledPalette(v25.Dimmed, v24)
						local v26 = sampleStops(v25.Bright, -v24 % 1)
						v25.Rim.Color = v26
						v25.Glow.ImageColor3 = v26
					end
				elseif v23.Motion ~= nil then
					v23.Motion:Disconnect()
					v23.Motion = nil
				end
			end)
		end

		local function buildRewardRow(clone2)
			local frame = Instance.new("Frame")
			frame.Name = "Slot"
			frame.AnchorPoint = Vector2.new(0, 0.5)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = 0.55
			frame.ZIndex = 2
			frame.Parent = clone2
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0.16, 0)
			uICorner.Parent = frame
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = Color3.fromHex("#131624")
			uIStroke.Thickness = 2
			uIStroke.Parent = frame
			clone2.Glow.AnchorPoint = Vector2.new(0.5, 0.5)
			clone2.Glow.Position = UDim2.fromScale(0.5, 0.5)
			clone2.Glow.ZIndex = 3
			clone2.Glow.Parent = frame
			clone2.Icon.AnchorPoint = Vector2.new(0.5, 0.5)
			clone2.Icon.Position = UDim2.fromScale(0.5, 0.5)
			clone2.Icon.ZIndex = 4
			clone2.Icon.Parent = frame
			clone2.RewardName.AnchorPoint = Vector2.new(0, 0.5)
			clone2.RewardName.TextXAlignment = Enum.TextXAlignment.Left
			clone2.Note.AnchorPoint = Vector2.new(0, 0.5)
			clone2.Note.TextXAlignment = Enum.TextXAlignment.Left
			clone2.Chance.AnchorPoint = Vector2.new(0, 0.5)
			local v24 = clone2.Chance:FindFirstChildOfClass("UICorner")

			if v24 == nil then
				v24 = Instance.new("UICorner")
				v24.Parent = clone2.Chance
			end

			v24.CornerRadius = UDim.new(0.5, 0)
			clone2.Chance.BackgroundColor3 = Color3.fromHex("#1B1B24")
			clone2.Chance.BackgroundTransparency = 0
			clone2.Chance.ZIndex = 2
			local v25 = clone2.Chance:FindFirstChildOfClass("UIStroke")

			if v25 == nil then
				v25 = Instance.new("UIStroke")
				v25.Parent = clone2.Chance
			end

			v25.Color = Color3.fromHex("#131624")
			v25.Thickness = 2
			clone2.Chance.Value.TextColor3 = Color3.new(1, 1, 1)
			clone2.Chance.Value.ZIndex = 3
		end

		local function layoutRewardCards(scrollingFrame)
			local absoluteSize = scrollingFrame.AbsoluteSize
			local count2 = #v23.Cards

			if absoluteSize.X <= 0 or absoluteSize.Y <= 0 or count2 == 0 then
				return
			end

			local v24 = math.round(absoluteSize.X * v23.PadXFraction)
			local v25 = math.round(absoluteSize.Y * v23.PadYFraction)
			local v26 = absoluteSize.X - v24 * 2
			local v27 = absoluteSize.Y - v25 * 2
			local v28 = math.floor((math.clamp(
				v27 / (count2 + (count2 - 1) * v23.RowGapFraction),
				v23.MinRowHeight,
				v26 / v23.MaxRowAspect
			)))
			local v29 = math.round(v28 * v23.RowGapFraction)
			local v30 = v28 * count2 + v29 * (count2 - 1)
			local scrollingEnabled = v27 < v30
			scrollingFrame.ScrollingEnabled = scrollingEnabled
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
			local canvasSize

			if scrollingEnabled then
				canvasSize = UDim2.fromOffset(0, v30 + v25 * 2)
			else
				canvasSize = UDim2.new()
			end

			scrollingFrame.CanvasSize = canvasSize

			if not scrollingEnabled then
				v25 += (v27 - v30) / 2
			end

			local maxTextSize = math.max(1, (math.round(v28 * v23.NameTextCap)))
			local maxTextSize2 = math.max(1, (math.round(v28 * v23.ChanceTextCap)))
			local maxTextSize3 = math.max(1, (math.round(v28 * v23.NoteTextCap)))
			local textSize = scrollingFrame.Template.Note.TextSize
			local v36 = math.round(v28 * v23.RowPadFraction)
			local v37 = v28 - v36 * 2
			local v38 = math.round(v37 * v23.GlowScale)
			local v39 = math.round(v37 * v23.IconScale)
			local v40 = math.round(v28 * v23.PillHeightFraction)
			local v41 = math.round(v28 * v23.PillPadFraction)

			for k, card in v23.Cards do
				card.AnchorPoint = Vector2.new(0, 0)
				card.Size = UDim2.fromOffset(v26, v28)
				card.Position = UDim2.fromOffset(v24, v25 + (k - 1) * (v28 + v29))
				local slot = card.Slot
				slot.Size = UDim2.fromOffset(v37, v37)
				slot.Position = UDim2.fromOffset(v36, v28 / 2)
				slot.Glow.Size = UDim2.fromOffset(v38, v38)
				slot.Icon.Size = UDim2.fromOffset(v39, v39)
				local v42 = math.round(#card.Chance.Value.Text * maxTextSize2 * v23.PillCharWidth + v41 * 2)
				card.Chance.Size = UDim2.fromOffset(v42, v40)
				card.Chance.Position = UDim2.fromOffset(v26 - v36 - v42, v28 / 2)
				local v43 = v36 + v37 + math.round(v28 * v23.SlotGapFraction)
				local v44 = v26 - v36 * 2 - v42 - v43

				if card.Note.Visible then
					card.RewardName.Size = UDim2.fromOffset(v44, (math.round(v28 * 0.42)))
					card.RewardName.Position = UDim2.fromOffset(v43, (math.round(v28 * 0.36)))
					card.Note.Size = UDim2.fromOffset(v44, (math.round(v28 * 0.26)))
					card.Note.Position = UDim2.fromOffset(v43, (math.round(v28 * 0.71)))
					local v45 = #card.Note.Text * textSize * v23.NoteCharWidth
					local note = card.Note
					local textSize2

					if v44 < v45 then
						textSize2 = math.max(1, (math.floor(textSize * v44 / v45)))
					else
						textSize2 = textSize
					end

					note.TextSize = textSize2
				else
					card.RewardName.Size = UDim2.fromOffset(v44, (math.round(v28 * 0.56)))
					card.RewardName.Position = UDim2.fromOffset(v43, v28 / 2)
				end

				card.RewardName.UITextSizeConstraint.MaxTextSize = maxTextSize
				card.Chance.Value.UITextSizeConstraint.MaxTextSize = maxTextSize2
				card.Note.UITextSizeConstraint.MaxTextSize = maxTextSize3
			end
		end

		local function renderRewardsPanel()
			local v24 = GUI.Get(v23.Accessor)
			local scrollingFrame = v24.Frame.ScrollingFrame
			local uIGridLayout = scrollingFrame:FindFirstChildOfClass("UIGridLayout")

			if uIGridLayout ~= nil then
				uIGridLayout:Destroy()
			end

			local uIAspectRatioConstraint = v24.Frame:FindFirstChildOfClass("UIAspectRatioConstraint")

			if uIAspectRatioConstraint ~= nil then
				uIAspectRatioConstraint.AspectRatio = v23.PanelAspect
			end

			scrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			scrollingFrame.Size = UDim2.fromScale(v23.ScrollerSize.X, v23.ScrollerSize.Y)
			scrollingFrame.Position = UDim2.fromScale(v23.ScrollerCenter.X, v23.ScrollerCenter.Y)
			local template = scrollingFrame.Template

			for _, guiObject in scrollingFrame:GetChildren() do
				if guiObject:IsA("GuiObject") and guiObject ~= template then
					guiObject:Destroy()
				end
			end

			table.clear(v23.Cards)
			table.clear(v23.Flowing)
			local total = 0

			for _, reward in MonsterParasite.Rewards do
				total += MonsterParasite.GetRewardWeight(reward.Id)
			end

			for k, reward in MonsterParasite.Rewards do
				local clone2 = template:Clone()
				clone2.Name = `Reward_{reward.Id}`
				clone2.LayoutOrder = k
				clone2.Visible = true
				clone2.RewardName.Text = string.upper(reward.DisplayName)
				clone2.Icon.Image = reward.Icon or template:GetAttribute("FallbackIcon")
				local displayNote = reward.DisplayNote
				clone2.Note.Visible = displayNote ~= nil

				if displayNote ~= nil then
					clone2.Note.Text = string.upper(displayNote)
				end

				local v25 = math.floor(MonsterParasite.GetRewardWeight(reward.Id) / total * 100 * 10 + 0.5) / 10
				clone2.Chance.Value.Text = `{v25}%`
				local rarity = rarities[v23.RarityGradients[reward.Rarity] or reward.Rarity]

				if rarity ~= nil and rarity.RarityGradient ~= nil then
					paintRewardCard(clone2, rarity.RarityGradient)
				end

				buildRewardRow(clone2)
				table.insert(v23.Cards, clone2)
				clone2.Parent = scrollingFrame
			end

			if v23.Sizing ~= nil then
				v23.Sizing:Disconnect()
			end

			v23.Sizing = scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				layoutRewardCards(scrollingFrame)
			end)
			layoutRewardCards(scrollingFrame)
			startRewardFlow(v24)
		end

		local v24 = {
			Gui = nil,
			Release = nil
		}

		local function hideTutorial()
			local gui = v24.Gui

			if gui == nil or not gui.Enabled then
				return
			end

			gui.Enabled = false
			local release = v24.Release
			v24.Release = nil

			if release ~= nil then
				release()
			end
		end

		local function showTutorial()
			local gui = v24.Gui

			if gui == nil then
				gui = GUI.MonsterEventTutorialFrame()
				local monsterEventTutorialFrame = gui.MonsterEventTutorialFrame
				assert(
					monsterEventTutorialFrame:IsA("Frame"),
					"MonsterEventTutorialFrame.MonsterEventTutorialFrame must be a Frame"
				)
				local ok = monsterEventTutorialFrame.Ok
				assert(ok:IsA("ImageButton"), "MonsterEventTutorialFrame.Ok must be an ImageButton")
				GUI.OnActivated(ok, hideTutorial)
				ButtonFX(ok)
				v24.Gui = gui
			end

			if gui.Enabled then
				return
			end

			v24.Release = HiddenUIHandler.Acquire()
			gui.Enabled = true
		end

		local function bindPrompt(object, proximityPrompt)
			if proximityPrompt.Name == MonsterParasite.TalkPromptName then
				object:Connect(proximityPrompt.Triggered, showTutorial)
			elseif proximityPrompt.Name == MonsterParasite.FeedPromptName then
				object:Connect(proximityPrompt.Triggered, requestFeed)
			elseif proximityPrompt.Name == MonsterParasite2.ViewRewardsPromptName then
				object:Connect(proximityPrompt.Triggered, function()
					renderRewardsPanel()
					Tabs.Toggle(v23.Accessor)
				end)
			end

			refreshPrompts()
		end

		local function hideModel(folder)
			for _, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 1
				end
			end
		end

		local v25 = {
			CleanupSeconds = 2,
			ParticleScale = 2.6,
			EmitScale = 2.25,
			SuppressSeconds = 1
		}
		local _ = {
			ReferenceDiameter = 8.4,
			MinScale = 0.7,
			MaxScale = 2.2
		}
		local now = -1e999

		local function scaleNumberSequence(size, p: number)
			local numberSequenceKeypoints = table.create(#size.Keypoints)

			for k, keypoint in size.Keypoints do
				numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(
					keypoint.Time,
					keypoint.Value * p,
					keypoint.Envelope * p
				)
			end

			return NumberSequence.new(numberSequenceKeypoints)
		end

		local function isSwapVeilActive()
			return os.clock() - now < 1
		end

		local function playSwapVeil(instance)
			if instance == nil or instance.Parent == nil then
				return
			end

			local boundingBox, v26 = instance:GetBoundingBox()
			local position = boundingBox.Position
			local part = Instance.new("Part")
			part.Name = "MonsterSwapVeil"
			part.Size = createVector(1, 1, 1)
			part.CFrame = CFrame.new(position)
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Transparency = 1
			local transient = Workspace:FindFirstChild("Transient")

			if not (transient and transient:IsA("Folder")) then
				transient = Workspace
			end

			part.Parent = transient
			Debris:AddItem(part, 2)
			now = os.clock()
			local energyBurstTemplate = resolveEnergyBurstTemplate() -- equivalent call inferred; original call site unknown

			if energyBurstTemplate ~= nil then
				local clone2 = energyBurstTemplate:Clone()

				for _, emitter in clone2:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Size = scaleNumberSequence(emitter.Size, 2.6)
					emitter.Speed = NumberRange.new(emitter.Speed.Min * 2.6, emitter.Speed.Max * 2.6)
					local emitCount = emitter:GetAttribute("EmitCount")

					if type(emitCount) == "number" then
						emitter:SetAttribute("EmitCount", (math.ceil(emitCount * 2.25)))
					end
				end

				clone2.CFrame = CFrame.identity
				clone2.Parent = part
				Emit(clone2)
			end

			local swapPoofTemplate = resolveSwapPoofTemplate() -- equivalent call inferred; original call site unknown

			if swapPoofTemplate ~= nil then
				local clone2 = swapPoofTemplate:Clone()
				local v27 = math.clamp(math.max(v26.X, v26.Y, v26.Z) / 8.4, 0.7, 2.2)

				for _, emitter in clone2:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Size = scaleNumberSequence(emitter.Size, v27)
					emitter.Speed = NumberRange.new(emitter.Speed.Min * v27, emitter.Speed.Max * v27)
					emitter.Acceleration *= v27
					emitter.ZOffset *= v27
				end

				clone2.CFrame = CFrame.identity
				clone2.Parent = part
				Emit(clone2)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isRetiring(instance)
			return instance:GetAttribute(MonsterParasite.MonsterRetiringAttributeName) == true
		end

		local v26 = {
			Path = { "Stands", "Pads", MonsterParasite.PadName },
			FadeSeconds = 0.35,
			Instance = nil,
			Dim = nil,
			Alpha = 1,
			Lit = false,
			Step = nil
		}
		local child = Workspace

		for _, childName in v26.Path do
			if child == nil then
				child = nil
			else
				child = child:FindFirstChild(childName)
			end
		end

		if child ~= nil then
			local dim = fader()
			dim:Hide(child, 1)
			v26.Instance = child
			v26.Dim = dim
		end

		local function refreshPad()
			local instance = v26.Instance
			local dim = v26.Dim

			if instance == nil or dim == nil then
				return
			end

			local v27 = v3
			local lit

			if v27 == nil or v27.Parent == nil then
				lit = false
			else
				local retiring = isRetiring(v27) -- equivalent call inferred; original call site unknown
				lit = not retiring
			end

			if lit == v26.Lit then
				return
			end

			v26.Lit = lit
			local step = v26.Step

			if step ~= nil then
				step:Disconnect()
				v26.Step = nil
			end

			local alpha = v26.Alpha
			local alpha2 = lit and 0 or 1
			local v30 = 0
			local preRenderConnection = nil
			preRenderConnection = RunService.PreRender:Connect(function(dt: number)
				v30 = math.min(v30 + dt, v26.FadeSeconds)
				local value = TweenService:GetValue(
					v30 / v26.FadeSeconds,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				)
				v26.Alpha = alpha + (alpha2 - alpha) * value
				dim:Hide(instance, v26.Alpha)

				if v30 >= v26.FadeSeconds then
					preRenderConnection:Disconnect()
					v26.Alpha = alpha2
					dim:Hide(instance, alpha2)
					v26.Step = nil
				end
			end)
			v26.Step = preRenderConnection
		end

		local v27 = {
			Arrow = require(ReplicatedStorage.Client.WorldFX.ArrowPointer3D),
			Zones = require(ReplicatedStorage.Client.WorldFX.Pads),
			Pointer = nil,
			Step = nil,
			Dim = nil,
			Surface = nil,
			Origin = nil,
			Alpha = 1,
			Fading = false,
			Shown = false,
			Retired = false,
			PollSeconds = 0.2,
			FadeSeconds = 0.35,
			Config = {
				Color = MonsterParasite.ParasiteHighlightColor,
				ProximityThreshold = 5,
				Radius = 5,
				Amplitude = 2
			}
		}

		function v27.Finished()
			if v27.Retired then
				return true
			end

			local v28 = Save.Await()
			local monsterParasite2

			if v28 ~= nil then
				monsterParasite2 = v28.MonsterParasite
			end

			if (monsterParasite2 == nil and 0 or monsterParasite2.TotalFeeds) > 0 or clone.TotalFeeds > 0 then
				v27.Retired = true
			end

			return v27.Retired
		end

		function v27.Root()
			local character = localPlayer.Character
			local humanoidRootPart

			if character ~= nil then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
				return nil
			end

			return humanoidRootPart
		end

		function v27.Wanted()
			return v26.Lit and not (v27.Shown or v27.Finished()) and not flag and isHoldingParasiteEgg()
		end

		function v27.Ease(alpha: number, callback)
			local pointer = v27.Pointer
			local dim = v27.Dim

			if pointer == nil or dim == nil then
				return
			end

			local step = v27.Step

			if step ~= nil then
				step:Disconnect()
				v27.Step = nil
			end

			local model = pointer.model
			local alpha2 = v27.Alpha
			local v28 = 0
			local preRenderConnection = nil
			preRenderConnection = RunService.PreRender:Connect(function(dt: number)
				v28 = math.min(v28 + dt, v27.FadeSeconds)
				local value = TweenService:GetValue(
					v28 / v27.FadeSeconds,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				)
				v27.Alpha = alpha2 + (alpha - alpha2) * value
				dim:Hide(model, v27.Alpha)

				if v28 >= v27.FadeSeconds then
					preRenderConnection:Disconnect()
					v27.Alpha = alpha
					dim:Hide(model, alpha)
					v27.Step = nil

					if callback ~= nil then
						callback()
					end
				end
			end)
			v27.Step = preRenderConnection
		end

		function v27.Raise(p, origin)
			local arrow = v27.Arrow.new(p, origin, v27.Config)
			v27.Pointer = arrow
			v27.Origin = origin
			v27.Dim = fader()
			v27.Alpha = 1
			v27.Dim:Hide(arrow.model, 1)
			arrow:Start()
			v27.Ease(0)
		end

		function v27.Drop()
			local pointer = v27.Pointer

			if pointer == nil or v27.Fading then
				return
			end

			v27.Fading = true
			v27.Ease(1, function()
				pointer:Destroy()

				if v27.Pointer == pointer then
					v27.Pointer = nil
					v27.Origin = nil
					v27.Dim = nil
				end

				v27.Fading = false
			end)
		end

		function v27.Refresh()
			if v27.Fading then
				return
			end

			local root = v27.Root()
			local surface = v27.Surface

			if surface == nil or root == nil or not v27.Wanted() then
				v27.Drop()
			elseif v27.Pointer == nil then
				v27.Raise(surface, root)
			elseif v27.Origin ~= root then
				local pointer = v27.Pointer
				pointer:PointFrom(root)
				v27.Origin = root
				pointer:Start()
			end
		end

		function v27.Enter()
			if not v27.Wanted() then
				return
			end

			v27.Shown = true
			showTutorial()
			v27.Drop()
		end

		task.spawn(function()
			local instance = v26.Instance

			if instance ~= nil and instance:IsA("BasePart") then
				v27.Surface = instance
				maid:Add(v27.Zones.Track(instance, {
					Entered = v27.Enter
				}))
			end

			while task.wait(v27.PollSeconds) do
				v27.Refresh()

				if v27.Finished() and v27.Pointer == nil and not v27.Fading then
					break
				end
			end
		end)

		local function bindModel(folder)
			if v[folder] or folder:GetAttribute("OwnerUserId") == nil then
				return
			end

			if folder:GetAttribute("OwnerUserId") ~= localPlayer.UserId then
				folder:Destroy()
				return
			end

			if isRetiring(folder) then
				hideModel(folder)
				return
			end

			local v28 = Trove.new()
			local v29 = v3
			v[folder] = v28
			v3 = folder

			if v29 ~= nil and v29 ~= folder and v29.Parent ~= nil and v5 ~= v29 then
				hideModel(v29)
			end

			v28:Connect(folder:GetAttributeChangedSignal(MonsterParasite.MonsterRetiringAttributeName), function()
				if folder:GetAttribute(MonsterParasite.MonsterRetiringAttributeName) ~= true then
					return
				end

				task.defer(refreshPad)

				if v5 == folder then
					task.spawn(function()
						while v5 == folder and folder.Parent ~= nil do
							task.wait()
						end

						if folder.Parent ~= nil then
							hideModel(folder)
						end
					end)
				else
					hideModel(folder)
				end
			end)
			local primaryPart = folder.PrimaryPart

			if primaryPart ~= nil then
				v21[folder] = primaryPart.CFrame

				if math.abs(v22) > 0.001 then
					local v30 = v22
					local primaryPart2 = folder.PrimaryPart
					local cFrame = v21[folder]

					if cFrame == nil then
						local primaryPart3 = folder.PrimaryPart

						if primaryPart3 == nil then
							cFrame = nil
						else
							v21[folder] = primaryPart3.CFrame
							cFrame = primaryPart3.CFrame
						end
					end

					if primaryPart2 ~= nil and cFrame ~= nil then
						primaryPart2.CFrame = cFrame * CFrame.fromEulerAnglesYXZ(0, v30, 0)
					end
				end
			end

			startIdle(folder, v28)

			if flag and folder.PrimaryPart ~= nil and not (os.clock() - now < v25.SuppressSeconds) then
				emitEnergyBurst(folder.PrimaryPart, v28) -- equivalent call inferred; original call site unknown
			end

			v28:Connect(folder.Destroying, function()
				v[folder] = nil
				v21[folder] = nil

				if v3 == folder then
					v3 = nil
					clearChest() -- equivalent call inferred; original call site unknown
					task.defer(refreshPad)
				end

				v28:Destroy()
			end)

			for _, proximityPrompt in folder:GetDescendants() do
				if proximityPrompt:IsA("ProximityPrompt") then
					bindPrompt(v28, proximityPrompt)
				end
			end

			v28:Connect(folder.DescendantAdded, function(proximityPrompt)
				if proximityPrompt:IsA("ProximityPrompt") then
					bindPrompt(v28, proximityPrompt)
				end
			end)
			applyState(clone)
			refreshPad()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function inspectInstance(model)
			if model:IsA("Model") then
				bindModel(model)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindWorldFolder(folder)
			for _, child2 in folder:GetChildren() do
				inspectInstance(child2) -- equivalent call inferred; original call site unknown
			end

			maid:Connect(folder.ChildAdded, inspectInstance)
		end

		local function inspectWorldChild(folder)
			if folder.Name == MonsterParasite.WorldFolderName and folder:IsA("Folder") then
				bindWorldFolder(folder) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function markParasiteSwallowed()
			localPlayer:SetAttribute(MonsterParasite2.ChargeGainAttributeName, os.clock())
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function releaseFullChargeModel(p)
			playSwapVeil(p)
			monsterParasite.AskFullChargeReset:FireServer()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isFullChargeResult(p)
			return (p.PreviousCharge or 0) > (p.Charge or 0)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isSculptChange(p)
			local monsterModelIndex = MonsterParasite.GetMonsterModelIndex(p.PreviousCharge or 0)
			return MonsterParasite.GetMonsterModelIndex(p.Charge or 0) ~= monsterModelIndex
		end

		local function waitForThread(thread: thread?)
			while thread ~= nil and coroutine.status(thread) ~= "dead" do
				task.wait()
			end
		end

		local function getFeedMonster()
			local v28 = os.clock() + 2
			local v29

			while true do
				v29 = v3

				if v29 ~= nil and v29.PrimaryPart ~= nil then
					break
				end

				task.wait()

				if v28 <= os.clock() then
					return v3
				end
			end

			return v29
		end

		local function playFeedSequence(p)
			local feedMonster = getFeedMonster()
			local primaryPart

			if feedMonster then
				primaryPart = feedMonster.PrimaryPart
			end

			if feedMonster == nil or primaryPart == nil then
				discardPendingYank() -- equivalent call inferred; original call site unknown
				markParasiteSwallowed() -- equivalent call inferred; original call site unknown
				monsterParasite.AskGrowthSwap:FireServer()

				if isFullChargeResult(p) then
					monsterParasite.AskFullChargeReset:FireServer()
					deliverChestTool() -- equivalent call inferred; original call site unknown
				end
			else
				playYankAnimation(feedMonster)
				local v28 = feedMonster:FindFirstChild(MonsterParasite.ParasiteEatTargetPartName, true) or feedMonster:FindFirstChild(
					MonsterParasite.TongueTipName,
					true
				) or primaryPart
				playSound(MonsterParasite.ChompSoundName, v28)
				markParasiteSwallowed() -- equivalent call inferred; original call site unknown
				task.wait(v20.ScaleTweenDelaySeconds)
				local thread

				if feedMonster.Parent then
					thread = task.spawn(pulseMonsterScale, feedMonster)
					task.wait(0.12)
				end

				if isSculptChange(p) and not isFullChargeResult(p) then
					playSwapVeil(feedMonster)
				end

				monsterParasite.AskGrowthSwap:FireServer()

				if isFullChargeResult(p) then
					task.spawn(releaseMonsterFacing)
					task.wait(MonsterParasite.FullChargeHoldDuration)

					if feedMonster.Parent == nil then
						feedMonster = getFeedMonster()
					end

					if feedMonster == nil or feedMonster.Parent == nil then
						warn("[MonsterParasite] Full charge had no live monster to burp from")
					else
						feedMonster:SetAttribute(MonsterParasite2.ChargeDrainAttributeName, os.clock())
						task.wait(MonsterParasite2.ChargeDrainDuration)

						if feedMonster.Parent == nil then
							feedMonster = getFeedMonster()
						end

						if feedMonster == nil or feedMonster.Parent == nil then
							warn("[MonsterParasite] Full charge lost its monster during the drain")
						elseif not animateFullCharge(feedMonster) then
							warn("[MonsterParasite] Full charge ended without launching a chest")
						end

						playSwapVeil(feedMonster)
					end

					monsterParasite.AskFullChargeReset:FireServer()
					deliverChestTool() -- equivalent call inferred; original call site unknown
				else
					releaseMonsterFacing()
					waitForThread(thread)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startFeedSequence()
			if flag then
				return
			end

			flag = true
			refreshPrompts()
			task.spawn(function()
				while #data > 0 do
					local v28 = table.remove(data, 1)
					assert(v28 ~= nil, "Feed sequence queue changed unexpectedly")
					local fullChargeResult = isFullChargeResult(v28) -- equivalent call inferred; original call site unknown
					local success, result = pcall(function()
						playFeedSequence(v28)
						return true
					end)

					if fullChargeResult then
						v11 = math.max(0, v11 - 1)
					end

					if success then
						continue
					end

					discardPendingYank() -- equivalent call inferred; original call site unknown
					markParasiteSwallowed() -- equivalent call inferred; original call site unknown
					task.spawn(releaseMonsterFacing)
					v5 = nil
					warn((`[MonsterParasite] Feed sequence failed: {result}`))

					if not fullChargeResult then
						continue
					end

					releaseFullChargeModel(v3) -- equivalent call inferred; original call site unknown
					requestTakeChest()
				end

				flag = false
				renderState() -- equivalent call inferred; original call site unknown
			end)
		end

		monsterParasite.StateShifted.OnClientEvent:Connect(function(p)
			if MonsterParasite2.StateSchema(p) then
				applyState(p)
			end
		end)
		monsterParasite.EventStateShifted.OnClientEvent:Connect(function(p)
			if MonsterParasite2.EventStateSchema(p) then
				active = p.Active
				refreshPrompts()
			end
		end)
		monsterParasite.FeedSettled.OnClientEvent:Connect(function(data2)
			if not MonsterParasite2.FeedResultSchema(data2) then
				return
			end

			v6 = false
			captureEquippedEgg()

			if isFullChargeResult(data2) then
				if v12 > 0 then
					v12 -= 1
				else
					v11 += 1
				end
			end

			local charge

			if data2.Charge == nil then
				charge = clone.Charge
			else
				charge = data2.Charge
			end

			local pendingChests

			if data2.PendingChests == nil then
				pendingChests = clone.PendingChests
			else
				pendingChests = data2.PendingChests
			end

			storeState({
				Charge = charge,
				PendingChests = pendingChests,
				TotalFeeds = clone.TotalFeeds,
				PendingReward = clone.PendingReward
			}) -- equivalent call inferred; original call site unknown
			table.insert(data, data2)
			startFeedSequence() -- equivalent call inferred; original call site unknown
		end)
		monsterParasite.ChestOpened.OnClientEvent:Connect(function(p)
			if not (MonsterParasite2.ChestResultSchema(p) and p.Success) then
				return
			end

			beginChestReveal(p)
		end)
		v17:Start()
		maid:Add(function()
			v17:Stop()
		end)
		task.spawn(preloadMonsterAssets)
		maid:Connect(Workspace.ChildAdded, inspectWorldChild)
		local folder = Workspace:FindFirstChild(MonsterParasite.WorldFolderName)

		if folder and folder:IsA("Folder") then
			bindWorldFolder(folder)
		end

		local function bindCharacter(character)
			extended:Clean()
			extended:Connect(character.ChildAdded, function(tool)
				if tool:IsA("Tool") then
					refreshPrompts()

					if isChestTool(tool) then
						bindChestTool(tool) -- equivalent call inferred; original call site unknown
					end
				end
			end)
			extended:Connect(character.ChildRemoved, function(tool)
				if tool:IsA("Tool") then
					refreshPrompts()
				end
			end)

			for _, tool in character:GetChildren() do
				if not (tool:IsA("Tool") and isChestTool(tool)) then
					continue
				end

				bindChestTool(tool) -- equivalent call inferred; original call site unknown
			end

			refreshPrompts()
		end

		maid:Connect(localPlayer.CharacterAdded, bindCharacter)
		local character = localPlayer.Character

		if character then
			bindCharacter(character)
		end

		maid:Connect(Save.Watch("EggInventory"), refreshPrompts)
		maid:Connect(Save.Watch("MonsterParasite"), refreshPrompts)
		task.spawn(function()
			local success, result = pcall(function()
				return monsterParasite.AskSnapshot:InvokeServer()
			end)

			if not (success and MonsterParasite2.SnapshotSchema(result)) then
				return
			end

			active = result.Event.Active
			applyState(result.State)
			local pendingReward = result.State.PendingReward

			if pendingReward ~= nil and v9 == nil then
				beginChestReveal({
					Success = true,
					Message = `You received {pendingReward.Reward.DisplayName}!`,
					OpeningId = pendingReward.OpeningId,
					Reward = pendingReward.Reward,
					PendingChests = result.State.PendingChests
				})
			end

			refreshPrompts()
		end)
	end
}