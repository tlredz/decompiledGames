local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local EncryptedAssetsController = require(ReplicatedStorage.Controllers.EncryptedAssetsController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local LightingController = require(ReplicatedStorage.Controllers.LightingController)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local name = script.Name
local concert = workspace.Sounds.Concert
local remoteEvent = Net:RemoteEvent("EventService/Concert/Shoot")
local maid = Trove.new()
local v = nil
local Concert = {}

function Concert.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

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
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = ReplicatedStorage
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.Atmosphere)
	clone_2.Parent = Lighting
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = ReplicatedStorage
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local v2 = nil
	local clone = maid:Clone(Instance.new("ColorCorrectionEffect"))
	clone.Parent = currentCamera

	-- equivalent calls inferred from this helper; original call sites unknown
	local function loadAnimation(p, animation)
		local track = p.AnimationController.Animator:LoadAnimation(animation)
		maid:Add(track, "Stop")
		maid:Add(track)
		return track
	end

	local function createStage()
		maid:Add(LightingController:Push("Concert", {
			Ambient = Color3.new(0, 0, 0),
			OutdoorAmbient = Color3.fromRGB(100, 100, 100),
			EnvironmentDiffuseScale = 0,
			EnvironmentSpecularScale = 0
		}))
		maid:Add(function()
			concert:Stop()
		end)
		maid:Add(task.spawn(function()
			EncryptedAssetsController:WaitForAssetId("rbxassetid://126264638776020")
			concert.SoundId = ""
			concert.SoundId = "rbxassetid://126264638776020"

			while not concert.IsLoaded do
				task.wait()
			end

			concert.TimePosition = math.max(
				concert.TimePosition,
				workspace:GetServerTimeNow() - (activeEventData.startedAt + 5)
			)
			concert:Play()
		end))
		local v3 = {
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(255, 128, 0),
			Color3.fromRGB(255, 255, 0),
			Color3.fromRGB(128, 255, 0),
			Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 255, 128),
			Color3.fromRGB(0, 255, 255),
			Color3.fromRGB(0, 0, 255),
			Color3.fromRGB(128, 0, 255),
			Color3.fromRGB(255, 0, 255),
			Color3.fromRGB(255, 0, 128),
			Color3.fromRGB(255, 0, 255),
			Color3.fromRGB(0, 128, 255)
		}
		local clone = maid:Clone(script.Night_Sky)
		clone.Parent = Lighting
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

		local smokeStage = clone3.SmokeStage
		maid:Add(smokeStage)
		smokeStage.Parent = workspace
		clone3.Parent = clone2
		VFX.disable(clone3)
		local children = clone2.SpotLights:GetChildren()
		local _ = #children
		local pivots = {}
		local v4 = {}
		local v5 = {}
		local v6 = {}
		local children2 = {}
		local descendants = {}
		local timeScalesByDescendant = {}
		local v7 = {}
		local descendants2 = {}
		local flag = false
		local v8 = false

		for _, v9 in children do
			pivots[v9] = v9:GetPivot()
			v4[v9] = 0
			v5[v9] = 0
			v6[v9] = 25
			v9.Rotate.Neon["1"].LightBeam:Destroy()
			local clone4 = script.lightbeambig.Beams:Clone()

			for _, child in clone4:GetChildren() do
				child.Attachment0 = v9.Rotate.Neon["1"]
				child.Attachment1 = v9.Rotate.Neon["2"]
				child.Parent = v9.Rotate.Neon
				table.insert(children2, child)
			end

			clone4:Destroy()
		end

		clone2.Parent = workspace
		maid:Add(Observers.observeTag("HideInConcert", function(p)
			local parent = p.Parent
			p.Parent = script
			return function()
				pcall(function()
					p.Parent = parent
				end)
			end
		end, { workspace, script }))
		local v9 = { clone2.Rigs.Tralalero, clone2.Rigs.Chimpanzini, clone2.Rigs.Chimpanzini2 }
		local v10 = {}

		for _, v11 in v9 do
			v10[v11] = {
				Throw = loadAnimation(v11, v11.Throw),
				Shuffle = loadAnimation(v11, v11.Shuffle)
			}
		end

		local v11 = maid:Add(Instance.new("Color3Value"))
		v11.Value = Color3.fromRGB(0, 0, 0)

		for _, v12 in v10 do
			v12.Shuffle:Play()
		end

		local v12 = true
		maid:Add(function()
			v12 = false
		end)
		maid:Add(remoteEvent.OnClientEvent:Connect(function(p: number, p2: string, p3: number)
			local v13 = v9[p] or v9[1]

			if not v13 then
				return
			end

			v10[v13].Throw:Play()
			task.wait(0.25)

			if not v12 then
				return
			end

			local worldPosition = v13:FindFirstChild("SHOOT", true).WorldPosition
			task.spawn(function()
				SoundController:PlaySound(ReplicatedStorage.Sounds.Events.Concert.Shoot, worldPosition)
			end)
			local clone4 = script.DiscoProjectile:Clone()
			clone4.Part.CFrame = CFrame.new(worldPosition)
			clone4.Parent = workspace
			local preRenderConnection = nil
			preRenderConnection = RunService.PreRender:Connect(function()
				debug.profilebegin("Concert Disco Shoot")
				local animalPosition = ClientEventUtils.getAnimalPosition(p2)
				local v14 = worldPosition + (animalPosition - worldPosition) * 0.5 + createVector(0, 90, 0)
				local v15 = 1 - (p3 + 3 - workspace:GetServerTimeNow()) / 3
				local quadBezier = MathUtils.quadBezier(math.clamp(v15, 0, 1), worldPosition, v14, animalPosition)
				clone4.Part.CFrame = CFrame.new(quadBezier)

				if v15 >= 1 then
					preRenderConnection:Disconnect()
					clone4:Destroy()
					ClientEventUtils.playBurst(
						script.DiscoExplosion,
						p2,
						{ ReplicatedStorage.Sounds.Events.Concert.Hit }
					)
				end

				debug.profileend()
			end)
		end))

		for _, v13 in children2 do
			v13.Enabled = false
		end

		maid:Add((createEventScheduler(10, 15, function(callback)
			VFX.enable(clone3)
			local v13 = 1
			local v14 = 0
			local v15 = 0
			local v16 = 0
			local v17 = 0
			local v18 = {}
			local color = Color3.new(0, 0, 0)
			local colorSequence = ColorSequence.new(color)
			task.delay(callback(), function()
				for _, v19 in children2 do
					v19.Enabled = true
				end
			end)
			maid:Add(function()
				workspace.Gravity = 196.2
			end)
			maid:Add(RunService.PostSimulation:Connect(function(dt)
				debug.profilebegin("Concert:Update")
				workspace.Gravity = 29.429999999999996
				v15 -= dt
				v14 -= dt
				v17 -= dt
				v16 -= dt
				local timePosition = concert.TimePosition
				local v19

				if timePosition >= 20 and timePosition <= 25 then
					v19 = true
				elseif timePosition >= 70 then
					v19 = timePosition <= 94.5
				else
					v19 = false
				end

				local v20 = math.clamp((concert.PlaybackLoudness - 100) / 900, 0, 1)

				for _, v21 in descendants do
					v21.TimeScale = math.clamp(v20 / 0.05, 1, 2) * timeScalesByDescendant[v21]
				end

				for _, v21 in v10 do
					v21.Shuffle:AdjustSpeed((math.clamp(v20 / 0.13, 0.5, 1.5)))
				end

				if v2 then
					v2:AdjustSpeed(v19 and 3 or math.clamp(v20 / 0.06, 1, 3))
				end

				local v21

				if timePosition >= 70 and timePosition <= 94.5 then
					v21 = timePosition >= 85 and 0.05 or math.lerp(0.5, 0.2, (math.min((timePosition - 70) / 12, 1)))
				else
					v21 = v19 and 0.1 or 0.3
				end

				if (v20 >= 0.11 or v19) and v16 <= 0 and callback() <= 0 then
					v16 = v21
					v13 = v13 % #v3 + 1
					CreateTween(v11, TweenInfo.new(0.2), {
						Value = v3[v13]
					})
				end

				local value = v11.Value

				if timePosition >= 94.3 and timePosition <= 97.7 then
					value = color
				end

				local colorSequence2 = ColorSequence.new(value)

				for _, v22 in v7 do
					local color2

					if v18[v22] then
						color2 = colorSequence
					else
						color2 = colorSequence2
					end

					v22.Color = color2
				end

				for _, v22 in descendants2 do
					local color2

					if v18[v22] then
						color2 = color
					else
						color2 = value
					end

					v22.Color = color2
				end

				local v22 = dt * (v19 and 1.5 or math.clamp(v20 / 0.25, 0.05, 1))

				for _, v23 in children do
					local v24 = v5[v23] or 0
					local v25 = v6[v23] or 0
					local v26 = math.clamp((v4[v23] or 0) + v22, 0, 1)
					v4[v23] = v26

					if v26 >= 1 then
						v4[v23] = 0
						v5[v23] = v25
						v6[v23] *= -1
					else
						local v27 = math.rad((math.lerp(v24, v25, v26)))
						v23:PivotTo(pivots[v23] * CFrame.Angles(0, v27, not flag and 0 or v27))

						if flag then
							for _, child in v23.Rotate.Neon:GetChildren() do
								if child.Name == "CustomAttachment_-1" or child.Name == "2" or child.Name == "CustomAttachment_2" then
									child.Position = Vector3.new(
										child.Position.X,
										math.sin(v26 * 3.141592653589793) * 100,
										300
									)
								end
							end
						end
					end
				end

				if v19 and v15 <= 0 then
					local v23 = math.random(100, 200)
					v15 = v23 / 1000
					local v24 = {}

					for _, v25 in children2 do
						v24[v25] = true
						v25.Width0 = math.max(v25.Width0 - 0.5, 0.5)
						v25.Width1 = math.max(v25.Width1 - 2.5, 1)
						v25.Brightness = math.min(v25.Brightness + 0.5, 13)
						v25.Enabled = false
						local v26 = v25
						task.delay(math.random(50, v23) / 1000, function()
							v26.Enabled = true
						end)
					end

					for _, v25 in v7 do
						if v24[v25] then
							continue
						end

						v18[v25] = true
						local v26 = v25
						task.delay(math.random(50, v23) / 1000, function()
							v18[v26] = nil
						end)
					end

					for _, v25 in descendants2 do
						v18[v25] = true
						local v26 = v25
						task.delay(math.random(50, v23) / 1000, function()
							v18[v26] = nil
						end)
					end
				end

				if timePosition >= 25 and not v8 then
					v8 = true

					for _, v23 in children do
						local _1 = v23.Rotate.Neon["1"]
						local _2 = v23.Rotate.Neon["2"]
						local clone4 = _2:Clone()
						clone4.Name = "CustomAttachment_1"
						clone4.Parent = v23.Rotate.Neon
						CreateTween(_2, TweenInfo.new(5), {
							Position = _2.Position + createVector(15, 0, 0)
						})
						CreateTween(clone4, TweenInfo.new(5), {
							Position = _2.Position - createVector(15, 0, 0)
						})
						local clone5 = script.lightbeambig.Beams:Clone()

						for _, child in clone5:GetChildren() do
							child.Width0 = 0.5
							child.Width1 = 1
							child.Brightness = 13
							child.Attachment0 = _1
							child.Attachment1 = clone4
							child.Parent = v23.Rotate.Neon
							table.insert(children2, child)
							table.insert(v7, child)
						end

						clone5:Destroy()
					end
				end

				if timePosition >= 71 and not flag then
					VFX.enable(smokeStage)
					task.delay(5, function()
						VFX.disable(smokeStage)
					end)
					flag = true

					for _, v23 in children do
						local _1 = v23.Rotate.Neon["1"]
						local _2 = v23.Rotate.Neon["2"]
						local position = _2.Position - createVector(15, 0, 0)
						CreateTween(_2, TweenInfo.new(5), {
							Position = position
						})

						for i = -2, 2 do
							if i == 0 then
								continue
							end

							local clone4 = _2:Clone()
							clone4.Name = `CustomAttachment_{i}`
							clone4.Parent = v23.Rotate.Neon
							CreateTween(clone4, TweenInfo.new(5), {
								Position = position + Vector3.new(i * 30, 0, 0)
							})
							local clone5 = script.lightbeambig.Beams:Clone()

							for _, child in clone5:GetChildren() do
								child.Width0 = 0.5
								child.Width1 = 1
								child.Brightness = 13
								child.Attachment0 = _1
								child.Attachment1 = clone4
								child.Parent = v23.Rotate.Neon
								table.insert(children2, child)
								table.insert(v7, child)
							end

							clone5:Destroy()
						end
					end
				end

				if (v20 >= 0.2 or v19) and v14 <= 0 then
					v14 = v19 and 0.2 or 0.1
					CameraController:Fov((v20 - 0.2) * 15 + 70, 0.1)
				end

				debug.profileend()
			end))
		end)))

		for _, descendant in clone2:GetDescendants() do
			if descendant:IsA("BasePart") and descendant.Name == "Neon" or descendant:IsA("SpotLight") then
				table.insert(descendants2, descendant)
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				table.insert(v7, descendant)

				if descendant:IsA("ParticleEmitter") then
					timeScalesByDescendant[descendant] = descendant.TimeScale
					table.insert(descendants, descendant)
				end
			end
		end

		maid:Add((createEventScheduler(10, 15, function(callback)
			CreateTween(v11, TweenInfo.new(callback()), {
				Value = v3[1]
			})
		end)))
	end

	maid:Add((createEventScheduler(0, 5, function(callback)
		CreateTween(clone, TweenInfo.new(callback(), Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Brightness = -1.2
		})
		task.delay(callback(), createStage)
		EffectController:Run("ConcertEvent", "GrassRecolor")
		maid:Add(function()
			EffectController:Stop("ConcertEvent", "GrassRecolor")
		end)
		EffectController:Run("ConcertEvent", "WallRecolor")
		maid:Add(function()
			EffectController:Stop("ConcertEvent", "WallRecolor")
		end)
		EffectController:Run("ConcertEvent", "WallBottomRecolor")
		maid:Add(function()
			EffectController:Stop("ConcertEvent", "WallBottomRecolor")
		end)
	end)))
	maid:Add((createEventScheduler(10, 15, function(callback)
		CreateTween(clone, TweenInfo.new(callback(), Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Brightness = -0.05
		})
	end)))
	maid:Add(task.delay(math.max(activeEventData.startedAt + 24.5 - workspace:GetServerTimeNow(), 0), function()
		maid:Add(Signal.new())
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
				v2 = track
				local total = 0
				maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
					debug.profilebegin("Concert:Player:Dance")
					workspace:GetServerTimeNow()

					if math.max(activeEventData.startedAt + 84.5 - workspace:GetServerTimeNow(), 0) > 0 then
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
					v2 = nil
				end)
			end))
			return maid2:WrapClean()
		end))
	end))
	CycleController:Update()
	SoundController:UpdateOST()
end

function Concert.OnStop(_)
	maid:Destroy()
	v = nil
end

function Concert.OnLoad(_)
	task.spawn(function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	task.spawn(function()
		EncryptedAssetsController:WaitForAssetId("rbxassetid://126264638776020")
		concert.SoundId = "rbxassetid://126264638776020"
		ContentProvider:PreloadAsync({ concert })
	end)
end

return Concert