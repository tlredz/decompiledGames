local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local Brazil = {}
local EncryptedAssetsController = require(ReplicatedStorage.Controllers.EncryptedAssetsController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local LightingController = require(ReplicatedStorage.Controllers.LightingController)
local JumpLTMController = require(ReplicatedStorage.Controllers.JumpLTMController)
local SharedEventUtils = require(ReplicatedStorage.Shared.SharedEventUtils)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Shared.TweenPivot)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Packages.Spring)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local color = Color3.fromRGB(128, 255, 0)
local color2 = Color3.fromRGB(0, 255, 0)
local name = script.Name
local brazilEvent = workspace.Sounds.BrazilEvent
local fullMapFloorBigger

if ServerData.IsBiggerServer() then
	fullMapFloorBigger = workspace.Events.Brazil.FullMapFloorBigger
else
	fullMapFloorBigger = workspace.Events.Brazil.FullMapFloor
end

local renderedMovingAnimals = workspace.RenderedMovingAnimals
local remoteEvent = Net:RemoteEvent("EventService/Brazil/Focus")
local remoteEvent2 = Net:RemoteEvent("EventService/Brazil/Burst")
local maid = Trove.new()

local function getRandomPosition()
	return fullMapFloorBigger.Position + Vector3.new(
		fullMapFloorBigger.Size.X * 0.5 * (math.random(0, 1) * 2 - 1),
		0,
		fullMapFloorBigger.Size.Z * 0.5 * (math.random(0, 1) * 2 - 1)
	)
end

local function createLight(parent)
	local attachment = Instance.new("Attachment")
	attachment.Name = "Attachment"
	attachment.CFrame = CFrame.new(0, 3, 0)
	local pointLight = Instance.new("PointLight")
	pointLight.Name = "PointLight"
	pointLight.Brightness = 4
	pointLight.Color = Color3.fromRGB(255, 157, 0)
	pointLight.Range = 6
	pointLight.Parent = attachment
	attachment.Parent = parent
	return function()
		attachment:Destroy()
		pointLight:Destroy()
	end
end

function Brazil.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

	if ServerData.IsJumpLTMServer() then
		fullMapFloorBigger = workspace.Map:WaitForChild("MapFloor")
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateTimeLeft(p: number)
		return (math.max(activeEventData.startedAt + p - workspace:GetServerTimeNow(), 0))
	end

	local function createEventScheduler(p: number, p2: number, fn)
		local function fn2()
			return (math.max(activeEventData.startedAt + p2 - workspace:GetServerTimeNow(), 0))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function run()
			fn(fn2)
		end

		local thread = nil
		local timeLeft = calculateTimeLeft(p) -- equivalent call inferred; original call site unknown

		if timeLeft > 0 then
			thread = task.delay(timeLeft, run)
		else
			run() -- equivalent call inferred; original call site unknown
		end

		return function()
			if thread and coroutine.status(thread) == "suspended" then
				pcall(task.cancel, thread)
			end
		end
	end

	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
	end)
	maid:Add(remoteEvent2.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Brazil.Hit })
	end))
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = ReplicatedStorage
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone = maid:Clone(Instance.new("ColorCorrectionEffect"))
	clone.Parent = currentCamera
	local v = nil
	local clone2

	if ServerData.IsBiggerServer() then
		clone2 = maid:Clone(script.StageBigger)
	else
		clone2 = maid:Clone(script.Stage)
	end

	local clone3

	if ServerData.IsBiggerServer() then
		clone3 = maid:Clone(script.VFXBigger)
	else
		clone3 = maid:Clone(script.VFX)
	end

	local function initPlayerDance()
		maid:Add(task.delay(math.max(activeEventData.startedAt + 20 - workspace:GetServerTimeNow(), 0), function()
			maid:Add(Observers.observeCharacter(Players.LocalPlayer, function(_, instance)
				local maid2 = Trove.new()
				maid2:Add(task.spawn(function()
					local humanoid = instance:WaitForChild("Humanoid")

					if not humanoid then
						return
					end

					local animator = humanoid:WaitForChild("Animator")

					if not animator then
						return
					end

					local track = animator:LoadAnimation(script.Dance)
					track.Priority = Enum.AnimationPriority.Action
					v = track
					local total = 0
					maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
						debug.profilebegin("Brazil:Player:Dance")
						workspace:GetServerTimeNow()

						if math.max(activeEventData.startedAt + 55 - workspace:GetServerTimeNow(), 0) > 0 then
							if not track.IsPlaying then
								track:Play()
							end
						elseif humanoid.MoveDirection ~= createVector(0, 0, 0) or localPlayer:GetAttribute("Stealing") then
							total = 0

							if track.IsPlaying then
								track:Stop()
							end
						elseif total < 3 then
							total += dt
						elseif not track.IsPlaying then
							track:Play()
						end

						debug.profileend()
					end))
					maid2:Add(function()
						track:Stop()
						track:Destroy()
						v = nil
					end)
				end))
				return maid2:WrapClean()
			end))
		end))
	end

	local function createMovingSquare()
		local positionsByAttachment = {}
		local attachments = {}
		local attachments2 = {}

		for _, attachment in clone3.Square.Bottom:GetChildren() do
			if not attachment:IsA("Attachment") then
				continue
			end

			positionsByAttachment[attachment] = attachment.Position
			table.insert(attachments, attachment)
		end

		for _, attachment in clone3.Square.Top:GetChildren() do
			if not attachment:IsA("Attachment") then
				continue
			end

			positionsByAttachment[attachment] = attachment.Position
			table.insert(attachments2, attachment)
		end

		local v2 = createVector(9, 9, 9)

		for _, v3 in attachments do
			v3.Position = positionsByAttachment[v3] * createVector(1, 1, 1) * 9
		end

		for _, v3 in attachments2 do
			v3.Position = positionsByAttachment[v3] * createVector(1, 1, 1) * 9
		end

		maid:Add(Observers.observeTag("BrazilHitbox", function(parent)
			local maid2 = Trove.new()
			local v3 = nil
			local v4 = nil
			local v5 = 0
			local flag = false
			maid2:Add(RunService.PostSimulation:Connect(function(dt)
				debug.profilebegin("Brazil:Hitbox")
				local serverTimeNow = workspace:GetServerTimeNow()
				local cFrame = parent.CFrame
				local focused = parent:GetAttribute("Focused")
				local v6

				if v4 and focused and focused <= serverTimeNow then
					v6 = ClientEventUtils.getAnimalModel(v4)
				end

				if v4 and v6 then
					if not flag then
						flag = true
						local clone4 = ReplicatedStorage.Sounds.Events.Brazil.Cube:Clone()
						clone4.Parent = parent
						clone4:Play()
						clone4.Ended:Once(function()
							clone4:Destroy()
						end)
					end

					local v7 = math.clamp((serverTimeNow - focused) / 1, 0, 1)
					v5 = math.clamp((serverTimeNow - (focused + 1)) / 1, 0, 1)
					local vfxInstance = v6:FindFirstChild("VfxInstance")
					local animalCFrame = ClientEventUtils.getAnimalCFrame(v4)
					local v8

					if vfxInstance then
						v8 = vfxInstance.Size
					else
						v8 = v6:GetExtentsSize()
					end

					local min = (v8 * createVector(1.25, 1.5, 1.25)):Min(createVector(9, 18, 9))
					cFrame = CFrame.new(animalCFrame.X, cFrame.Y, animalCFrame.Z)

					if not v3 then
						v3 = v2
					end

					assert(v3)
					local lerped = v3:Lerp(min, v7)
					local lerped2 = v3:Lerp(Vector3.new(min.X, 0, min.Z), v7)
					v2 = lerped

					for _, v9 in attachments2 do
						v9.Position = (positionsByAttachment[v9] + Vector3.new(0, v5 * 1, 0)) * lerped
					end

					for _, v9 in attachments do
						v9.Position = positionsByAttachment[v9] * lerped2
					end
				else
					if flag then
						flag = false
					end

					local v7 = math.exp(-4 * dt)
					v2 = (createVector(9, 9, 9)):Lerp(v2, v7)
					v3 = v2
					v5 = math.lerp(0, v5, v7)

					for _, v8 in attachments2 do
						v8.Position = (positionsByAttachment[v8] + Vector3.new(0, v5 * 1, 0)) * v2
					end

					for _, v8 in attachments do
						v8.Position = positionsByAttachment[v8] * v2
					end
				end

				SharedEventUtils.pushPartCFrame(clone3.Square, cFrame)
				debug.profileend()
			end))
			maid2:Add(remoteEvent.OnClientEvent:Connect(function(p: string?)
				v3 = v2
				v4 = p
			end))
			return maid2:WrapClean()
		end, { workspace }))
	end

	local function createPlayerLights()
		maid:Add(Observers.observeCharacters(function(_, instance)
			local maid2 = Trove.new()
			maid2:Add(task.spawn(function()
				local upperTorso = instance:WaitForChild("UpperTorso")

				if not upperTorso then
					return
				end

				maid2:Add((createLight(upperTorso)))
			end))
			return maid2:WrapClean()
		end))
		maid:Add(Observers.observeChildren(renderedMovingAnimals, function(instance)
			local maid2 = Trove.new()
			maid2:Add(task.spawn(function()
				local rootPart = instance:WaitForChild("RootPart")

				if not rootPart then
					return
				end

				maid2:Add((createLight(rootPart)))
			end))
			return maid2:WrapClean()
		end))

		if ServerData.IsJumpLTMServer() then
			local v2 = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function lightEgg(k: string)
				local renderedEgg = JumpLTMController.RenderedEggs[k]
				local primaryPart

				if renderedEgg and renderedEgg.model then
					primaryPart = renderedEgg.model.PrimaryPart
				end

				if not primaryPart then
					return
				end

				local v3 = v2[k]

				if v3 then
					v3()
				end

				v2[k] = createLight(primaryPart)
			end

			for k in JumpLTMController.RenderedEggs do
				lightEgg(k) -- equivalent call inferred; original call site unknown
			end

			maid:Add(JumpLTMController.OnEggRendered:Connect(lightEgg))
			maid:Add(function()
				for _, v3 in v2 do
					v3()
				end

				table.clear(v2)
			end)
		end
	end

	local function createStage()
		maid:Add(LightingController:Push("Brazil", {
			Ambient = Color3.fromRGB(50, 50, 50),
			OutdoorAmbient = Color3.fromRGB(71, 71, 71)
		}))
		maid:Add(function()
			brazilEvent:Stop()
		end)
		maid:Add(task.spawn(function()
			EncryptedAssetsController:WaitForAssetId("rbxassetid://136243635275209")
			brazilEvent.SoundId = ""
			brazilEvent.SoundId = "rbxassetid://136243635275209"

			while not brazilEvent.IsLoaded do
				task.wait()
			end

			brazilEvent.TimePosition = workspace:GetServerTimeNow() - (activeEventData.startedAt + 5)
			brazilEvent:Play()
		end))
		local clone = maid:Clone(script.Night_Sky)
		clone.Parent = Lighting
		clone3.Parent = clone2
		VFX.disable(clone3)
		local v2 = maid:Add(Instance.new("Color3Value"))
		v2.Value = Color3.fromRGB(0, 0, 0)
		local v3 = maid:Add(Instance.new("Color3Value"))
		v3.Value = Color3.fromRGB(0, 0, 0)
		local descendants = {}
		local descendants2 = {}
		local descendants3 = {}
		local descendants4 = {}
		local timeScalesByDescendant = {}
		VFX.enable(clone3)
		VFX.disable(clone3.firestuff)
		local v4 = 1
		local v5 = 0
		local v6 = 0
		createPlayerLights()

		if not ServerData.IsJumpLTMServer() then
			createMovingSquare()
		end

		for _, descendant in clone2:GetDescendants() do
			if descendant:IsA("SpotLight") then
				table.insert(descendants3, descendant)
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				if descendant:IsDescendantOf(clone3.Square) or descendant:IsDescendantOf(clone3.bigbeams) then
					table.insert(descendants, descendant)
				else
					table.insert(descendants2, descendant)
				end

				if descendant:IsA("ParticleEmitter") then
					timeScalesByDescendant[descendant] = descendant.TimeScale
					table.insert(descendants4, descendant)
				end
			end
		end

		local v7 = {}
		local v8 = {}
		local att1s = {}
		local children = {}

		for _, child in clone3.initial:GetChildren() do
			local att1 = child.att1
			v7[att1] = getRandomPosition()
			v8[att1] = getRandomPosition()
			att1.WorldCFrame = CFrame.new(v8[att1])
			table.insert(att1s, att1)

			for _, child2 in att1:GetChildren() do
				table.insert(children, child2)
			end
		end

		local att1s2 = {}
		local Ys = {}
		local v9 = {}

		for _, child in clone3.thinbeams:GetChildren() do
			local att1 = child.att1
			v7[att1] = getRandomPosition()
			v8[att1] = getRandomPosition()
			att1.WorldCFrame = CFrame.new(v8[att1])
			table.insert(att1s2, att1)
			local children2 = {}

			for _, child2 in att1:GetChildren() do
				child2.Enabled = false
				table.insert(children2, child2)
			end

			Ys[children2] = child.Position.Y
			table.insert(v9, children2)
		end

		table.sort(v9, function(a, b)
			return Ys[a] < Ys[b]
		end)
		local v10 = false
		local v11 = false
		local v12 = 0
		maid:Add(RunService.PostSimulation:Connect(function(dt)
			debug.profilebegin("Brazil:Update")
			local serverTimeNow = workspace:GetServerTimeNow()
			v5 -= dt
			v6 -= dt
			local timePosition = brazilEvent.TimePosition
			local playbackLoudness = brazilEvent.PlaybackLoudness
			local v13 = math.clamp(playbackLoudness / 1000, 0, 1)

			for _, v14 in descendants4 do
				v14.TimeScale = math.clamp(v13 / 0.05, 1, 2) * timeScalesByDescendant[v14]
			end

			if playbackLoudness >= 320 and serverTimeNow - v12 >= 2 then
				v12 = serverTimeNow

				for k, _ in v7 do
					v7[k] = getRandomPosition()
				end
			end

			for _, v14 in { att1s2, att1s } do
				for _, v15 in v14 do
					local v16 = v8[v15]
					local v17 = v7[v15]
					local v18 = v17 - v16
					local v19 = vector.magnitude(v18)
					local v20 = math.lerp(35, 120, (math.clamp((playbackLoudness - 100) / 200, 0, 1))) * dt

					if v19 < v20 then
						v7[v15] = getRandomPosition()
					else
						v17 = v16 + vector.normalize(v18) * v20
					end

					v8[v15] = v17
					v15.WorldCFrame = CFrame.new(v17)
				end
			end

			if timePosition >= 17 then
				local v14 = math.max((timePosition - 17) // #v9, 2)

				if timePosition >= 82 then
					v14 += 10
				end

				for i = 1, math.min(v14, #v9) do
					for _, v15 in v9[i] do
						v15.Enabled = true
					end
				end
			end

			if timePosition >= 17 and not v10 then
				VFX.enable(clone3.firestuff)
				task.delay(5.5, function()
					VFX.disable(clone3.firestuff)
				end)
				v10 = true

				for _, v14 in children do
					v14.Enabled = false
				end
			end

			if timePosition >= 83 and not v11 then
				v11 = true
				VFX.enable(clone3.firestuff)
				task.delay(5.5, function()
					VFX.disable(clone3.firestuff)
				end)
			end

			if v13 >= 0.11 and v6 <= 0 and math.max(activeEventData.startedAt + 6 - workspace:GetServerTimeNow(), 0) <= 0 then
				v6 = 0.4
				v4 = v4 == 1 and 2 or 1
				local tweenInfo = TweenInfo.new(0.2)
				local v17

				if v4 == 1 then
					v17 = color
				else
					v17 = color2
				end

				CreateTween(v2, tweenInfo, {
					Value = v17
				})
				local tweenInfo2 = TweenInfo.new(0.2)
				local v21

				if v4 == 1 then
					v21 = color2
				else
					v21 = color
				end

				CreateTween(v3, tweenInfo2, {
					Value = v21
				})
			end

			if v then
				v:AdjustSpeed((math.clamp(v13 / 0.07, 0.8, 1.5)))
			end

			local color3 = v2.Value
			local value2 = v3.Value
			local colorSequence = ColorSequence.new(color3)
			local colorSequence2 = ColorSequence.new(value2)

			for _, v14 in descendants2 do
				v14.Color = colorSequence
			end

			for _, v14 in descendants do
				v14.Color = colorSequence2
			end

			for _, v14 in descendants3 do
				v14.Color = color3
			end

			if v13 >= 0.1 and v5 <= 0 then
				v5 = 0.1
				CameraController:Fov(v13 / 0.7 * 15 + 70, 0.1)
			end

			debug.profileend()
		end))
		maid:Add((createEventScheduler(5, 6, function(callback)
			CreateTween(v2, TweenInfo.new(callback()), {
				Value = color
			})
			CreateTween(v3, TweenInfo.new(callback()), {
				Value = color2
			})
		end)))

		if ServerData.IsJumpLTMServer() then
			VFX.disable(clone3.Square)
			clone3.Parent = workspace
		else
			clone2.Parent = workspace
		end

		maid:Add(Observers.observeTag("HideInBrazil", function(p)
			local parent = p.Parent
			p.Parent = script
			return function()
				pcall(function()
					p.Parent = parent
				end)
			end
		end, { workspace, script }))
	end

	maid:Add((createEventScheduler(0, 5, function(callback)
		CreateTween(clone, TweenInfo.new(callback(), Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Brightness = -1.2
		})
		EffectController:Run("BrazilEvent", "GrassRecolor")
		maid:Add(function()
			EffectController:Stop("BrazilEvent", "GrassRecolor")
		end)
		maid:Add(task.delay(callback(), function()
			createStage()
			CreateTween(
				clone,
				TweenInfo.new(
					math.max(activeEventData.startedAt + 6 - workspace:GetServerTimeNow(), 0),
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out
				),
				{
					Brightness = 0
				}
			)
		end))
	end)))
	maid:Add(task.delay(math.max(activeEventData.startedAt + 20 - workspace:GetServerTimeNow(), 0), function()
		maid:Add(Observers.observeCharacter(Players.LocalPlayer, function(_, instance)
			local maid2 = Trove.new()
			maid2:Add(task.spawn(function()
				local humanoid = instance:WaitForChild("Humanoid")

				if not humanoid then
					return
				end

				local animator = humanoid:WaitForChild("Animator")

				if not animator then
					return
				end

				local track = animator:LoadAnimation(script.Dance)
				track.Priority = Enum.AnimationPriority.Action
				v = track
				local total = 0
				maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
					debug.profilebegin("Brazil:Player:Dance")
					workspace:GetServerTimeNow()

					if math.max(activeEventData.startedAt + 55 - workspace:GetServerTimeNow(), 0) > 0 then
						if not track.IsPlaying then
							track:Play()
						end
					elseif humanoid.MoveDirection ~= createVector(0, 0, 0) or localPlayer:GetAttribute("Stealing") then
						total = 0

						if track.IsPlaying then
							track:Stop()
						end
					elseif total < 3 then
						total += dt
					elseif not track.IsPlaying then
						track:Play()
					end

					debug.profileend()
				end))
				maid2:Add(function()
					track:Stop()
					track:Destroy()
					v = nil
				end)
			end))
			return maid2:WrapClean()
		end))
	end))
	CycleController:Update()
	SoundController:UpdateOST()
end

function Brazil.OnStop(_)
	maid:Destroy()
end

function Brazil.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
end

return Brazil