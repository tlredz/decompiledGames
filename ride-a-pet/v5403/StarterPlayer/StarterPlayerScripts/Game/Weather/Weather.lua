local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

if not atmosphere then
	atmosphere = script.Sets.Base.Atmosphere:Clone()
	atmosphere.Parent = Lighting
end

local clone = atmosphere:Clone()
local v = {
	Brightness = Lighting.Brightness,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ColorShift_Top = Lighting.ColorShift_Top
}
local v2 = {
	Cover = workspace.Terrain.Clouds.Cover,
	Density = workspace.Terrain.Clouds.Density
}
local globalWind = workspace.GlobalWind
local sunRaysEffect = Lighting:FindFirstChildOfClass("SunRaysEffect")
local v3 = sunRaysEffect and {
	Intensity = sunRaysEffect.Intensity,
	Spread = sunRaysEffect.Spread
}

local function TweenAtmosphere(p, tweenInfo)
	local v4 = {}

	for _, v5 in ipairs({
		"Density",
		"Offset",
		"Color",
		"Glare",
		"Decay",
		"Haze"
	}) do
		v4[v5] = p[v5]
	end

	TweenService:Create(atmosphere, tweenInfo, v4):Play()
end

local function DisableParti(folder)
	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

local v4 = nil
local v5 = nil
local now = -1e999

local function DestroyStormSession(state)
	if not state or state.Cleaned then
		return
	end

	state.Cleaned = true

	if v5 == state then
		v5 = nil
	end

	for _, object in ipairs(state.Objects) do
		local v6 = object
		pcall(function()
			v6:Destroy()
		end)
	end

	table.clear(state.Objects)
end

local function TrackStormObject(p, p2)
	table.insert(p.Objects, p2)
	return p2
end

local WindShake = require(script.WindShake)
WindShake:Init({
	MatchWorkspaceWind = true
})

local function SpawnSkyFollowers(effects, items)
	local clones = {}

	for _, childName in items do
		local part = effects:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		local clone2 = part:Clone()

		for _, emitter in clone2:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.LockedToPart = false
			end
		end

		clone2.Parent = workspace.Terrain
		table.insert(clones, clone2)
	end

	return clones
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FollowCamera(items, IsAlive)
	task.spawn(function()
		local now2 = os.clock()
		local v6 = createVector(0, 0, 0)

		while IsAlive() do
			local now3 = os.clock()
			local v7 = math.min(now3 - now2, 0.1)
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				local character = Players.LocalPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local v8 = not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and createVector(0, 0, 0) or humanoidRootPart.AssemblyLinearVelocity
				local v9 = Vector3.new(v8.X, 0, v8.Z) * 1.25

				if v9.Magnitude > 50 then
					v9 = v9.Unit * 50
				end

				v6 = v6:Lerp(v9 + Vector3.new(0, math.clamp(v8.Y * 0.5, -15, 15), 0), 1 - math.exp(v7 * -7))
				local position = currentCamera.CFrame.Position + v6 + createVector(0, 55, 0)
				now2 = now3

				for _, item in items do
					item.Position = position
				end
			else
				now2 = now3
			end

			RunService.RenderStepped:Wait()
		end

		for _, item in items do
			DisableParti(item)
			game.Debris:AddItem(item, 10)
		end
	end)
end

local function PlayStinger(effects, p)
	if p then
		return
	end

	local startSFX = effects:FindFirstChild("StartSFX")

	if startSFX and startSFX:IsA("Sound") then
		local clone2 = startSFX:Clone()
		clone2.Parent = game.SoundService
		clone2:Play()
		game.Debris:AddItem(clone2, 8)
	end
end

local function RunShimmers(effects, items, IsAlive, shimmerGapMin, shimmerGapMax, callback)
	local sounds = {}

	for _, childName in items do
		local sound = effects:FindFirstChild(childName)

		if sound and sound:IsA("Sound") then
			table.insert(sounds, sound)
		end
	end

	if #sounds == 0 then
		return
	end

	task.spawn(function()
		local random = Random.new()

		while IsAlive() do
			task.wait(random:NextNumber(shimmerGapMin, shimmerGapMax))

			if not IsAlive() then
				break
			end

			if not (not callback or callback()) then
				continue
			end

			local clone2 = sounds[random:NextInteger(1, #sounds)]:Clone()
			clone2.Parent = game.SoundService
			clone2:Play()
			game.Debris:AddItem(clone2, 12)
		end
	end)
end

v4 = {
	Base = {
		Spawn = function()
			TweenAtmosphere(clone, TweenInfo.new(1))
			TweenService:Create(workspace.Terrain.Clouds, TweenInfo.new(4), v2):Play()
			TweenService:Create(game.Lighting, TweenInfo.new(4), v):Play()
			workspace.GlobalWind = globalWind
			local sunRaysEffect2 = Lighting:FindFirstChildOfClass("SunRaysEffect")

			if sunRaysEffect2 and v3 then
				sunRaysEffect2.Intensity = v3.Intensity
				sunRaysEffect2.Spread = v3.Spread
			end
		end
	},
	Aurora = {
		Spawn = function()
			TweenAtmosphere(script.Sets.Aurora.Atmosphere, TweenInfo.new(4))
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(game.Lighting, TweenInfo.new(4), {
				ClockTime = 0,
				Brightness = 1,
				Ambient = Color3.fromRGB(128, 131, 152),
				OutdoorAmbient = Color3.fromRGB(78, 55, 255)
			}):Play()
			task.wait(2)
			local total = -2000
			local clones = {}
			local cframes = {}

			for i = 1, 8 do
				local cframe = CFrame.new(0, 400, total)
				total += 500
				clones[i] = script.Sets.Aurora.Effects.Aurora:Clone()
				clones[i].Parent = workspace
				local curveSize = math.random(1000, 1000)
				local curveSize2 = math.random(1000, 1000)

				for _, beam in pairs(clones[i]:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					beam.CurveSize0 = curveSize
					beam.CurveSize1 = curveSize2
					local width0 = beam.Width0
					local width1 = beam.Width1
					beam.Width0 = 0
					beam.Width1 = 0
					TweenService:Create(beam, TweenInfo.new(4), {
						Width0 = width0,
						Width1 = width1
					}):Play()
				end

				cframes[i] = cframe
			end

			v4.Aurora.Active = true
			task.spawn(function()
				while v4.Aurora.Active do
					for k, v6 in pairs(clones) do
						v6.Position = (CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position) * cframes[k]).Position
					end

					task.wait()
				end

				for k, _ in pairs(clones) do
					for _, effect in pairs(clones[k]:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.5), {
								Width0 = 0,
								Width1 = 0
							}):Play()
						elseif effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						end
					end
				end
			end)
		end,
		Remove = function()
			v4.Aurora.Active = false
			v4.Base.Spawn()
		end
	},
	Rain = {
		Spawn = function()
			TweenAtmosphere(script.Sets.Rain.Atmosphere, TweenInfo.new(4))
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(game.Lighting, TweenInfo.new(4), {
				Brightness = 1
			}):Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(game.Workspace.Terrain.Clouds, TweenInfo.new(4), {
				Cover = 0.75,
				Density = 0.9
			}):Play()
			v4.Rain.Active = true
			local clone2 = script.Sets.Rain.Effects.RainBlock:Clone()
			clone2.Parent = workspace.Terrain
			local clone3 = script.Sets.Rain.Effects.Wind:Clone()
			clone3.Parent = workspace.Terrain
			local clone4 = script.Sets.Rain.Effects.RainSFX:Clone()
			clone4.Parent = game.SoundService
			clone4:Play()
			clone4.Volume = 0
			local TweenService4 = game:GetService("TweenService")
			TweenService4:Create(clone4, TweenInfo.new(4), {
				Volume = 0.2
			}):Play()
			task.spawn(function()
				while v4.Rain.Active do
					clone2.Position = workspace.Camera.CFrame.Position + createVector(0, 55, 0)
					clone3.Position = workspace.Camera.CFrame.Position
					task.wait()
				end

				DisableParti(clone2)
				DisableParti(clone3)
				local TweenService5 = game:GetService("TweenService")
				TweenService5:Create(clone4, TweenInfo.new(4), {
					Volume = 0
				}):Play()
				game.Debris:AddItem(clone4, 2)
				game.Debris:AddItem(clone2, 4)
				game.Debris:AddItem(clone3, 4)
			end)
		end,
		Remove = function()
			print("Remove")
			v4.Rain.Active = false
			v4.Base.Spawn()
		end
	},
	Storm = {
		Spawn = function(value)
			local variant = value or "Thunder"
			DestroyStormSession(v5)
			local v7 = {
				Objects = {},
				Cleaned = false,
				Variant = variant
			}
			v5 = v7
			v4.Storm.Active = false
			local v8, v9 = xpcall(function()
				local effect = script.Sets.Storm.Effects[variant]
				assert(effect, "Missing storm effects: " .. tostring(variant))
				local clone2 = effect.RainBlock:Clone()
				table.insert(v7.Objects, clone2)
				local clone3 = effect.Wind:Clone()
				table.insert(v7.Objects, clone3)
				local clone4 = script.Sets.Storm.Effects.RainSFX:Clone()
				table.insert(v7.Objects, clone4)
				clone2.Parent = workspace.Terrain
				clone3.Parent = workspace.Terrain
				clone4.Parent = game.SoundService
				clone4.Volume = 0
				local currentCamera = workspace.CurrentCamera

				local function PositionEffects()
					currentCamera = workspace.CurrentCamera

					for _, v13 in { clone2, clone3 } do
						local terrain = currentCamera and workspace.Terrain or nil

						if v13.Parent ~= terrain then
							v13.Parent = terrain
						end
					end

					if currentCamera then
						clone2.Position = currentCamera.CFrame.Position + createVector(0, 55, 0)
						clone3.Position = currentCamera.CFrame.Position
					end
				end

				PositionEffects()
				TweenAtmosphere(effect.Atmosphere, TweenInfo.new(4))
				TweenService:Create(workspace.Terrain.Clouds, TweenInfo.new(4), {
					Cover = 0.85,
					Density = 0.4
				}):Play()
				TweenService:Create(Lighting, TweenInfo.new(4), {
					Brightness = 1,
					Ambient = Color3.fromRGB(190, 194, 225)
				}):Play()
				workspace.GlobalWind = createVector(20, 0, 0)
				clone4:Play()
				TweenService:Create(clone4, TweenInfo.new(4), {
					Volume = 0.1
				}):Play()
				v4.Storm.Active = true
				task.spawn(function()
					local v13, v14 = xpcall(function()
						while v5 == v7 and not v7.Cleaned do
							PositionEffects()
							task.wait()
						end
					end, debug.traceback)
					local v15 = v5 == v7
					DestroyStormSession(v7)

					if v15 then
						v4.Storm.Active = false
					end

					if not v13 and os.clock() - now >= 60 then
						now = os.clock()
						warn("[WeatherVisual] storm effects stopped; reconciliation will retry: " .. tostring(v14))
					end
				end)
			end, debug.traceback)

			if not v8 then
				DestroyStormSession(v7)
				v4.Storm.Active = false
				error(v9, 0)
			end
		end,
		IsHealthy = function()
			if not v5 or v5.Cleaned or not v4.Storm.Active then
				return false
			end

			for _, sound in ipairs(v5.Objects) do
				if sound.Parent == nil and (sound:IsA("Sound") or workspace.CurrentCamera ~= nil) then
					return false
				end
			end

			return true
		end,
		Strike = function(position, value, p)
			local spawnLocation = workspace:FindFirstChild("Spawn") and workspace.Spawn:FindFirstChild("SpawnLocation")
			local v6 = position or spawnLocation and spawnLocation.Position + Vector3.new(
				math.random(-200, 200),
				500,
				math.random(-200, 200)
			)

			if not v6 then
				return
			end

			local character = game.Players.LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (v6 - humanoidRootPart.Position).Magnitude > 700 then
				return
			end

			if not (p and position) then
				local raycastParams = RaycastParams.new()
				raycastParams.RespectCanCollide = true
				local raycastResult = workspace:Raycast(v6, createVector(0, -1000000, 0), raycastParams)
				position = raycastResult and raycastResult.Position
			end

			local v7 = value or "Thunder"

			if position then
				local clone2 = script.Sets.Storm.Variants[v7].Strike:Clone()
				clone2.Parent = workspace
				clone2.CFrame = CFrame.new(position)
				game.Debris:AddItem(clone2, 6)
				task.spawn(function()
					task.wait(0.15)
					local SFX = clone2:FindFirstChild("SFX")

					if SFX then
						SFX:Play()
					end
				end)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local clone3 = script.Sets.Storm.Variants[v7].Ground:Clone()
				clone3.Parent = workspace
				clone3.CFrame = CFrame.new(position)
				game.Debris:AddItem(clone3, 6)
				task.spawn(function()
					task.wait(0.15)
					local SFX = clone3:FindFirstChild("SFX")

					if SFX then
						SFX:Play()
					end
				end)

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end

			task.wait(0.15)
			local clone2 = script.Sets.Storm.Effects["Strike" .. math.random(1, 3)]:Clone()
			clone2.Parent = game.SoundService
			clone2:Play()
			game.Debris:AddItem(clone2, 6)
		end,
		Remove = function()
			v4.Storm.Active = false
			DestroyStormSession(v5)
			v4.Base.Spawn()
		end
	},
	Lucky = {
		Ambience = function()
			local lucky = script.Sets:FindFirstChild("Lucky")
			local atmosphere2 = lucky and lucky:FindFirstChild("Atmosphere")

			if atmosphere2 then
				TweenAtmosphere(atmosphere2, TweenInfo.new(4))
			else
				local clone2 = clone:Clone()
				clone2.Color = Color3.fromRGB(255, 214, 120)
				clone2.Decay = Color3.fromRGB(255, 186, 84)
				clone2.Glare = math.max(clone2.Glare, 0.5)
				TweenAtmosphere(clone2, TweenInfo.new(4))
				clone2:Destroy()
			end

			TweenService:Create(workspace.Terrain.Clouds, TweenInfo.new(4), {
				Cover = 0.45,
				Density = 0.2
			}):Play()
			TweenService:Create(game.Lighting, TweenInfo.new(4), {
				Brightness = math.max(v.Brightness, 2.4),
				Ambient = Color3.fromRGB(180, 168, 120),
				OutdoorAmbient = Color3.fromRGB(215, 196, 130),
				ColorShift_Top = Color3.fromRGB(255, 226, 140)
			}):Play()
			local sunRaysEffect2 = Lighting:FindFirstChildOfClass("SunRaysEffect")

			if sunRaysEffect2 and v3 then
				sunRaysEffect2.Intensity = math.max(v3.Intensity, 0.25)
				sunRaysEffect2.Spread = 1
			end
		end,
		Spawn = function(_, p)
			v4.Lucky.Active = true
			v4.Lucky.Generation = (v4.Lucky.Generation or 0) + 1
			local generation = v4.Lucky.Generation

			local function IsAlive()
				return v4.Lucky.Active and v4.Lucky.Generation == generation
			end

			v4.Lucky.Ambience()
			local lucky = script.Sets:FindFirstChild("Lucky")
			local effects = lucky and lucky:FindFirstChild("Effects")

			if not effects then
				warn("[Weather.Lucky] script.Sets.Lucky.Effects is missing - run tools/BuildLuckyWeatherSet.luau in Studio; running tint-only")
				return
			end

			local followers = SpawnSkyFollowers(effects, { "Clovers", "Sparkles" })
			v4.Lucky.Followers = followers
			PlayStinger(effects, p)
			FollowCamera(followers, IsAlive) -- equivalent call inferred; original call site unknown
			RunShimmers(effects, { "Shimmer1", "Shimmer2" }, IsAlive, v4.Lucky.ShimmerGapMin, v4.Lucky.ShimmerGapMax)
		end,
		ShimmerGapMin = 8,
		ShimmerGapMax = 14,
		Remove = function()
			v4.Lucky.Active = false
			v4.Lucky.Followers = nil
			v4.Base.Spawn()
		end
	},
	MutationMadness = {
		RainbowCycleSeconds = 4,
		WindVector = createVector(8, 0, 4),
		Ambience = function()
			local mutationMadness = script.Sets:FindFirstChild("MutationMadness")
			local atmosphere2 = mutationMadness and mutationMadness:FindFirstChild("Atmosphere")

			if atmosphere2 then
				TweenAtmosphere(atmosphere2, TweenInfo.new(4))
			else
				local clone2 = clone:Clone()
				clone2.Color = Color3.fromRGB(190, 160, 255)
				clone2.Decay = Color3.fromRGB(120, 210, 255)
				clone2.Glare = math.max(clone2.Glare, 0.5)
				TweenAtmosphere(clone2, TweenInfo.new(4))
				clone2:Destroy()
			end

			TweenService:Create(workspace.Terrain.Clouds, TweenInfo.new(4), {
				Cover = 0.5,
				Density = 0.25
			}):Play()
			TweenService:Create(game.Lighting, TweenInfo.new(4), {
				Brightness = math.max(v.Brightness, 2.2),
				Ambient = Color3.fromRGB(150, 140, 190),
				OutdoorAmbient = Color3.fromRGB(190, 175, 235),
				ColorShift_Top = Color3.fromRGB(235, 170, 255)
			}):Play()
			local sunRaysEffect2 = Lighting:FindFirstChildOfClass("SunRaysEffect")

			if sunRaysEffect2 and v3 then
				sunRaysEffect2.Intensity = math.max(v3.Intensity, 0.2)
				sunRaysEffect2.Spread = 1
			end

			workspace.GlobalWind = v4.MutationMadness.WindVector
		end,
		Spawn = function(_, p)
			v4.MutationMadness.Active = true
			v4.MutationMadness.Generation = (v4.MutationMadness.Generation or 0) + 1
			local generation = v4.MutationMadness.Generation

			-- equivalent calls inferred from this helper; original call sites unknown
			local function IsAlive()
				return v4.MutationMadness.Active and v4.MutationMadness.Generation == generation
			end

			v4.MutationMadness.Ambience()
			local mutationMadness = script.Sets:FindFirstChild("MutationMadness")
			local effects = mutationMadness and mutationMadness:FindFirstChild("Effects")

			if not effects then
				warn("[Weather.MutationMadness] script.Sets.MutationMadness.Effects is missing - run tools/BuildMutationMadnessSet.luau in Studio; running tint-only")
				return
			end

			local followers = SpawnSkyFollowers(effects, {
				"GoldSparks",
				"DiamondSparks",
				"RainbowSparks",
				"Wind"
			})
			v4.MutationMadness.Followers = followers
			PlayStinger(effects, p)
			FollowCamera(followers, IsAlive) -- equivalent call inferred; original call site unknown
			local emitters = {}

			for _, folder in followers do
				if folder.Name ~= "RainbowSparks" then
					continue
				end

				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						table.insert(emitters, emitter)
					end
				end
			end

			if #emitters > 0 then
				task.spawn(function()
					local rainbowCycleSeconds = v4.MutationMadness.RainbowCycleSeconds

					while IsAlive() do
						local v7 = os.clock() / rainbowCycleSeconds % 1
						local colorSequence = ColorSequence.new(Color3.fromHSV(v7, 0.85, 1))

						for _, v8 in emitters do
							if v8.Parent then
								v8.Color = colorSequence
							end
						end

						RunService.Heartbeat:Wait()
					end
				end)
			end

			RunShimmers(
				effects,
				{ "Shimmer1", "Shimmer2" },
				IsAlive,
				v4.MutationMadness.ShimmerGapMin,
				v4.MutationMadness.ShimmerGapMax,
				function()
					return not v4.Lucky.Active
				end
			)
		end,
		ShimmerGapMin = 9,
		ShimmerGapMax = 18,
		Remove = function()
			v4.MutationMadness.Active = false
			v4.MutationMadness.Followers = nil
			v4.Base.Spawn()
		end
	},
	Volcanic = {
		Spawn = function()
			TweenAtmosphere(script.Sets.Volcanic.Atmosphere, TweenInfo.new(4))
			v4.Volcanic.Active = true
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(game.Workspace.Terrain.Clouds, TweenInfo.new(4), {
				Cover = 0.85,
				Density = 0.4
			}):Play()
			workspace.GlobalWind = createVector(20, 0, 0)
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(game.Lighting, TweenInfo.new(4), {
				Brightness = 1,
				Ambient = Color3.fromRGB(225, 56, 26),
				OutdoorAmbient = Color3.fromRGB(225, 56, 26),
				ColorShift_Top = Color3.fromRGB(225, 56, 26)
			}):Play()
			local clone2 = script.Sets.Volcanic.Effects.Volc:Clone()
			clone2.Parent = workspace.Terrain
			local clone3 = script.Sets.Volcanic.Effects.RainSFX:Clone()
			clone3.Parent = game.SoundService
			clone3:Play()
			clone3.Volume = 0
			local TweenService4 = game:GetService("TweenService")
			TweenService4:Create(clone3, TweenInfo.new(4), {
				Volume = 0
			}):Play()
			task.spawn(function()
				while v4.Volcanic.Active do
					clone2.Position = workspace.Camera.CFrame.Position
					task.wait()
				end

				DisableParti(clone2)
				local TweenService5 = game:GetService("TweenService")
				TweenService5:Create(clone3, TweenInfo.new(4), {
					Volume = 0
				}):Play()
				game.Debris:AddItem(clone3, 2)
				game.Debris:AddItem(clone2, 4)
			end)
		end,
		Remove = function()
			v4.Volcanic.Active = false
			v4.Base.Spawn()
		end
	},
	SandStorm = {
		Spawn = function()
			v4.Storm.Active = true
			workspace.GlobalWind = createVector(20, 0, 0)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(game.Lighting, TweenInfo.new(2), {
				Brightness = 1,
				Ambient = Color3.fromRGB(225, 167, 133),
				OutdoorAmbient = Color3.fromRGB(225, 167, 133),
				ColorShift_Top = Color3.fromRGB(255, 198, 151)
			}):Play()
			task.wait(2)
			TweenAtmosphere(script.Sets.SandStorm.Atmosphere, TweenInfo.new(1))
			local clone2 = script.Sets.SandStorm.Effects.Sand:Clone()
			clone2.Parent = workspace.Terrain
			local clone3 = script.Sets.SandStorm.Effects.RainSFX:Clone()
			clone3.Parent = game.SoundService
			clone3:Play()
			clone3.Volume = 0
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(clone3, TweenInfo.new(4), {
				Volume = 0.5
			}):Play()
			task.spawn(function()
				while v4.Storm.Active do
					clone2.Position = workspace.Camera.CFrame.Position
					task.wait()
				end

				DisableParti(clone2)
				local TweenService4 = game:GetService("TweenService")
				TweenService4:Create(clone3, TweenInfo.new(4), {
					Volume = 0
				}):Play()
				game.Debris:AddItem(clone3, 2)
				game.Debris:AddItem(clone2, 4)
			end)
		end,
		Remove = function()
			v4.Storm.Active = false
			v4.Base.Spawn()
		end
	},
	Fog = {
		Spawn = function()
			TweenAtmosphere(script.Sets.Fog.Atmosphere, TweenInfo.new(4))
			v4.Fog.Active = true
			local clone2 = script.Sets.Fog.Effects.Fog:Clone()
			clone2.Parent = workspace.Terrain
			task.spawn(function()
				while v4.Fog.Active do
					clone2.Position = workspace.Camera.CFrame.Position
					task.wait()
				end

				DisableParti(clone2)
				game.Debris:AddItem(clone2, 4)
			end)
		end,
		Remove = function()
			v4.Fog.Active = false
			v4.Base.Spawn()
		end
	},
	Bloodmoon = {
		Spawn = function()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(game.Lighting, TweenInfo.new(4), {
				ClockTime = 0,
				Brightness = 1,
				Ambient = Color3.fromRGB(159, 0, 0),
				OutdoorAmbient = Color3.fromRGB(173, 118, 118)
			}):Play()
			TweenAtmosphere(script.Sets.BloodMoon.Atmosphere, TweenInfo.new(4))
			v4.Bloodmoon.Active = true
			game.Lighting["Sunless Blue Sky"].MoonTextureId = "rbxassetid://13713200424"
		end,
		Remove = function()
			v4.Bloodmoon.Active = false
			v4.Base.Spawn()
			task.wait(2)
			game.Lighting["Sunless Blue Sky"].MoonTextureId = "rbxassetid://1345054856"
		end
	},
	Night = {
		Spawn = function()
			TweenAtmosphere(script.Sets.Night.Atmosphere, TweenInfo.new(4))
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(game.Lighting, TweenInfo.new(4), {
				ClockTime = 0,
				Brightness = 1,
				Ambient = Color3.fromRGB(128, 131, 152)
			}):Play()
		end,
		Remove = function()
			v4.Base.Spawn()
		end
	},
	Frost = {
		Spawn = function()
			TweenAtmosphere(script.Sets.Frost.Atmosphere, TweenInfo.new(4))
			v4.Frost.Active = true
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(game.Workspace.Terrain.Clouds, TweenInfo.new(4), {
				Cover = 0.75,
				Density = 0.9
			}):Play()
			local clone2 = script.Sets.Frost.Effects.Snow:Clone()
			clone2.Parent = workspace.Terrain
			v4.Frost.Active = true
			local colors = {}

			for _, v6 in pairs(game.CollectionService:GetTagged("Grass")) do
				colors[v6] = v6.Color
				TweenService:Create(v6, TweenInfo.new(3), {
					Color = Color3.fromRGB(200, 200, 200)
				}):Play()
			end

			task.spawn(function()
				while v4.Frost.Active do
					clone2.Position = workspace.Camera.CFrame.Position
					task.wait()
				end

				DisableParti(clone2)
				game.Debris:AddItem(clone2, 4)

				for k, color in pairs(colors) do
					print(k)
					TweenService:Create(k, TweenInfo.new(3), {
						Color = color
					}):Play()
				end
			end)
		end,
		Remove = function()
			v4.Frost.Active = false
			v4.Base.Spawn()
		end
	}
}
v4.Base.Spawn()
return v4