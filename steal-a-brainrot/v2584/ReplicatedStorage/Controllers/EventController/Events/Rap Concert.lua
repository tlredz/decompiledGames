local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local EncryptedAssetsController = require(ReplicatedStorage.Controllers.EncryptedAssetsController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local LightingController = require(ReplicatedStorage.Controllers.LightingController)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local VFX = require(ReplicatedStorage.Shared.VFX)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local name = script.Name
local rapConcert = workspace.Sounds.RapConcert
local maid = Trove.new()
local v = nil
local RapConcert = {}

function RapConcert.OnStart(_)
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

	local function createStage()
		maid:Add(LightingController:Push("RapConcert", {
			Ambient = Color3.new(0, 0, 0),
			OutdoorAmbient = Color3.fromRGB(100, 100, 100),
			EnvironmentDiffuseScale = 0,
			EnvironmentSpecularScale = 0
		}))
		maid:Add(function()
			rapConcert:Stop()
		end)
		maid:Add(task.spawn(function()
			EncryptedAssetsController:WaitForAssetId("rbxassetid://124977112693561")
			rapConcert.SoundId = ""
			rapConcert.SoundId = "rbxassetid://124977112693561"

			while not rapConcert.IsLoaded do
				task.wait(1)
			end

			rapConcert.TimePosition = math.max(
				rapConcert.TimePosition,
				workspace:GetServerTimeNow() - (activeEventData.startedAt + 5)
			)
			rapConcert:Play()
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
		maid:Add(Observers.observeTag("HideInRapConcert", function(p)
			local parent = p.Parent
			p.Parent = script
			return function()
				pcall(function()
					p.Parent = parent
				end)
			end
		end, { workspace, script }))
		local v9 = maid:Add(Instance.new("Color3Value"))
		v9.Value = Color3.fromRGB(0, 0, 0)
		local v10 = true
		maid:Add(function()
			v10 = false
		end)

		for _, v11 in children2 do
			v11.Enabled = false
		end

		maid:Add((createEventScheduler(10, 15, function(callback)
			VFX.enable(clone3)
			local v11 = 1
			local v12 = 0
			local v13 = 0
			local v14 = 0
			local v15 = 0
			local v16 = {}
			local color = Color3.new(0, 0, 0)
			local colorSequence = ColorSequence.new(color)
			task.delay(callback(), function()
				for _, v17 in children2 do
					v17.Enabled = true
				end
			end)
			maid:Add(function()
				workspace.Gravity = 196.2
			end)
			local vFXDisco = clone3.VFXDisco
			local pivot = vFXDisco:GetPivot()
			local v17 = 0
			maid:Add(RunService.PostSimulation:Connect(function(dt)
				debug.profilebegin("Rap Concert:Update")
				workspace.Gravity = 29.429999999999996
				v17 -= dt
				v13 -= dt
				v12 -= dt
				v15 -= dt
				v14 -= dt
				local timePosition = rapConcert.TimePosition
				local v18 = math.clamp((rapConcert.PlaybackLoudness - 100) / 900, 0, 1)

				for _, v19 in descendants do
					v19.TimeScale = math.clamp(v18 / 0.05, 1, 2) * timeScalesByDescendant[v19]
				end

				if v2 then
					v2:AdjustSpeed((math.clamp(v18 / 0.2, 0.5, 1.1)))
				end

				if v18 >= 0.11 and v14 <= 0 and callback() <= 0 then
					v14 = 0.3
					v11 = v11 % #v3 + 1
					CreateTween(v9, TweenInfo.new(0.2), {
						Value = v3[v11]
					})
				end

				vFXDisco:PivotTo(pivot * CFrame.Angles(0, workspace:GetServerTimeNow() - activeEventData.startedAt, 0))
				Spr.target(vFXDisco, 1, 2, {
					Scale = 1
				})

				if v17 <= 0 and v18 > 0.05 then
					v17 = 0.1
					Spr.target(vFXDisco, 1, 10, {
						Scale = v18 + 1
					})
				end

				local value = v9.Value
				local colorSequence2 = ColorSequence.new(value)

				for _, v19 in v7 do
					local color2

					if v16[v19] then
						color2 = colorSequence
					else
						color2 = colorSequence2
					end

					v19.Color = color2
				end

				for _, v19 in descendants2 do
					local color2

					if v16[v19] then
						color2 = color
					else
						color2 = value
					end

					v19.Color = color2
				end

				local v19 = dt * math.clamp(v18 / 0.25, 0.05, 1)

				for _, v20 in children do
					local v21 = v5[v20] or 0
					local v22 = v6[v20] or 0
					local v23 = math.clamp((v4[v20] or 0) + v19, 0, 1)
					v4[v20] = v23

					if v23 >= 1 then
						v4[v20] = 0
						v5[v20] = v22
						v6[v20] *= -1
					else
						local v24 = math.rad((math.lerp(v21, v22, v23)))
						v20:PivotTo(pivots[v20] * CFrame.Angles(0, v24, not flag and 0 or v24))

						if flag then
							for _, child in v20.Rotate.Neon:GetChildren() do
								if child.Name == "CustomAttachment_-1" or child.Name == "2" or child.Name == "CustomAttachment_2" then
									child.Position = Vector3.new(
										child.Position.X,
										math.sin(v23 * 3.141592653589793) * 100,
										300
									)
								end
							end
						end
					end
				end

				if timePosition >= 25 and not v8 then
					v8 = true

					for _, v20 in children do
						local _1 = v20.Rotate.Neon["1"]
						local _2 = v20.Rotate.Neon["2"]
						local clone4 = _2:Clone()
						clone4.Name = "CustomAttachment_1"
						clone4.Parent = v20.Rotate.Neon
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
							child.Parent = v20.Rotate.Neon
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

					for _, v20 in children do
						local _1 = v20.Rotate.Neon["1"]
						local _2 = v20.Rotate.Neon["2"]
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
							clone4.Parent = v20.Rotate.Neon
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
								child.Parent = v20.Rotate.Neon
								table.insert(children2, child)
								table.insert(v7, child)
							end

							clone5:Destroy()
						end
					end
				end

				if v18 >= 0.2 and v12 <= 0 then
					v12 = 0.1
					CameraController:Fov((v18 - 0.2) * 15 + 70, 0.1)
				end

				debug.profileend()
			end))
		end)))

		for _, descendant in clone2:GetDescendants() do
			if descendant:IsDescendantOf(clone3.VFXDisco) then
				continue
			end

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
			CreateTween(v9, TweenInfo.new(callback()), {
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
	maid:Add(task.delay(math.max(activeEventData.startedAt + 15 - workspace:GetServerTimeNow(), 0), function()
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
					debug.profilebegin("Rap Concert:Player:Dance")
					workspace:GetServerTimeNow()

					if math.max(activeEventData.startedAt + 75 - workspace:GetServerTimeNow(), 0) > 0 then
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

function RapConcert.OnStop(_)
	maid:Destroy()
	v = nil
end

function RapConcert.OnLoad(_)
	task.spawn(function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	task.spawn(function()
		EncryptedAssetsController:WaitForAssetId("rbxassetid://124977112693561")
		rapConcert.SoundId = "rbxassetid://124977112693561"
		ContentProvider:PreloadAsync({ rapConcert })
	end)
end

return RapConcert