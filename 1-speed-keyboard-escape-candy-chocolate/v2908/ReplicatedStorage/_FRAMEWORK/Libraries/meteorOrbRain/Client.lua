local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Config)
local floatingOrbWins = require(script.Parent.Parent.floatingOrbWins)
require(script.Parent.Types)
local color = Color3.fromRGB(255, 45, 45)
local color2 = Color3.fromRGB(255, 140, 50)

local function anchorEverything(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end

	if folder:IsA("BasePart") then
		folder.Anchored = true
		folder.CanCollide = false
		folder.CanTouch = false
		folder.CanQuery = false
	end
end

local function createFallbackMeteor()
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = color2
	part.Size = createVector(6, 6, 6)
	return part
end

local function createMeteorVisual(instance)
	local selected

	if instance then
		selected = instance:Clone()
	else
		selected = Instance.new("Part")
		selected.Shape = Enum.PartType.Ball
		selected.Material = Enum.Material.Neon
		selected.Color = color2
		selected.Size = createVector(6, 6, 6)
	end

	selected.Name = "MeteorOrbRainMeteor"
	anchorEverything(selected)
	return selected
end

local function createDisc(name: string, vector2: Vector3, p: number, transparency: number)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = transparency
	part.Size = Vector3.new(0.1, p, p)
	part.CFrame = CFrame.new(vector2 + createVector(0, 0.6, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	return part
end

local function createExplosion(vector2: Vector3, impactRadiusStuds: number)
	local part = Instance.new("Part")
	part.Name = "MeteorOrbRainExplosion"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.CFrame = CFrame.new(vector2 + createVector(0, 1, 0))
	local part2 = Instance.new("Part")
	part2.Name = "Flash"
	part2.Shape = Enum.PartType.Ball
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.Material = Enum.Material.Neon
	part2.Color = color2
	part2.Transparency = 0.05
	part2.Size = createVector(1, 1, 1) * impactRadiusStuds * 0.4
	part2.CFrame = part.CFrame
	part2.Parent = part
	TweenService:Create(part2, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = createVector(1, 1, 1) * impactRadiusStuds * 1.6,
		Transparency = 1
	}):Play()
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color2
	pointLight.Brightness = 8
	pointLight.Range = impactRadiusStuds * 2.5
	pointLight.Shadows = false
	pointLight.Parent = part2
	TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		Brightness = 0
	}):Play()
	local disc = createDisc("Shockwave", vector2, impactRadiusStuds * 0.3, 0.2)
	disc.Color = color2
	disc.Parent = part
	TweenService:Create(disc, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, impactRadiusStuds * 2.6, impactRadiusStuds * 2.6),
		Transparency = 1
	}):Play()
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new(color2)
	particleEmitter.LightEmission = 0.8
	particleEmitter.LightInfluence = 0
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, impactRadiusStuds * 0.12),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.35, 0.7)
	particleEmitter.Speed = NumberRange.new(impactRadiusStuds * 1.5, impactRadiusStuds * 3.5)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Drag = 5
	particleEmitter.Acceleration = createVector(0, -70, 0)
	particleEmitter.Rate = 0
	particleEmitter.Enabled = false
	particleEmitter.Parent = part
	particleEmitter:Emit(40)
	return part
end

return {
	start = function(data)
		local resolved = Config.resolve(data.config)
		local parent = data.parent or Workspace
		local v = {}
		local v2 = {}
		local flag = false
		local meteorTemplate = data.meteorTemplate

		if not (meteorTemplate and (meteorTemplate:IsA("BasePart") or meteorTemplate:IsA("Model"))) then
			meteorTemplate = nil
		end

		if data.logger and not meteorTemplate then
			data.logger:warn("meteorOrbRain: meteor template missing or not a BasePart/Model — using a plain sphere")
		end

		local v3 = floatingOrbWins.startClient({
			config = resolved.orbs,
			requestCollect = function(id: string)
				data.send({
					kind = "meteorOrbCollect",
					id = id
				})
			end,
			parent = data.parent,
			logger = data.logger
		})

		-- equivalent calls inferred from this helper; original call sites unknown
		local function track(p)
			p.Parent = parent
			table.insert(v, p)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function release(instance)
			local index = table.find(v, instance)

			if index then
				table.remove(v, index)
			end

			instance:Destroy()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function explode(vector2: Vector3)
			local explosion = createExplosion(vector2, resolved.impactRadiusStuds)
			track(explosion) -- equivalent call inferred; original call site unknown
			task.delay(2.5, function()
				release(explosion) -- equivalent call inferred; original call site unknown
			end)
		end

		local function dropMeteor(position: Vector3, impactAt: number)
			local v4 = math.random() * 3.141592653589793 * 2
			local v5 = Vector3.new(math.cos(v4), 0, (math.sin(v4))) * resolved.fallDriftStuds
			local v6 = meteorTemplate
			local v7

			if v6 then
				v7 = v6:Clone()
			else
				v7 = Instance.new("Part")
				v7.Shape = Enum.PartType.Ball
				v7.Material = Enum.Material.Neon
				v7.Color = color2
				v7.Size = createVector(6, 6, 6)
			end

			v7.Name = "MeteorOrbRainMeteor"
			anchorEverything(v7)
			local pivot = v7:GetPivot()
			local v8

			if v7:IsA("Model") then
				v8 = v7:GetBoundingBox()
			else
				v8 = v7.CFrame
			end

			local v9 = CFrame.new(position - (v8.Position - pivot.Position)) * pivot.Rotation
			local v10 = v9 + Vector3.new(0, resolved.fallHeightStuds, 0) + v5
			local v11 = math.max(0.01, impactAt - Workspace:GetServerTimeNow())
			local v12 = math.clamp(1 - v11 / resolved.fallDurationSeconds, 0, 1)
			local lerped = v10:Lerp(v9, v12 * v12)
			v7:PivotTo(lerped)
			track(v7) -- equivalent call inferred; original call site unknown
			local v13 = resolved.impactRadiusStuds * 2
			local disc = createDisc("Boundary", position, v13, 0.82)
			local disc2 = createDisc("Fill", position, 0.1, 0.35)
			track(disc) -- equivalent call inferred; original call site unknown
			track(disc2) -- equivalent call inferred; original call site unknown
			TweenService:Create(disc2, TweenInfo.new(v11, Enum.EasingStyle.Linear), {
				Size = Vector3.new(0.1, v13, v13)
			}):Play()
			local cFrameValue = Instance.new("CFrameValue")
			cFrameValue.Value = lerped
			local valueChangedConnection = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
				v7:PivotTo(cFrameValue.Value)
			end)
			local tween = TweenService:Create(
				cFrameValue,
				TweenInfo.new(v11, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Value = v9
				}
			)
			v2[tween] = true
			tween.Completed:Once(function()
				v2[tween] = nil
				valueChangedConnection:Disconnect()
				cFrameValue:Destroy()
				release(v7) -- equivalent call inferred; original call site unknown
				release(disc) -- equivalent call inferred; original call site unknown
				release(disc2) -- equivalent call inferred; original call site unknown

				if not flag then
					explode(position) -- equivalent call inferred; original call site unknown
				end
			end)
			tween:Play()
		end

		return {
			stop = function()
				flag = true

				for k in v2 do
					k:Cancel()
				end

				table.clear(v2)
				v3.stop()
				local clone = table.clone(v)
				table.clear(v)

				for _, v4 in clone do
					v4:Destroy()
				end
			end,
			handleMessage = function(data2)
				if flag then
					return
				end

				if data2.kind == "meteorDrop" then
					dropMeteor(data2.position, data2.impactAt)
				elseif data2.kind == "meteorOrbSpawn" then
					v3.handleSpawn(data2.id, data2.position)
				elseif data2.kind == "meteorOrbDespawn" then
					v3.handleDespawn(data2.id)
				end
			end
		}
	end
}