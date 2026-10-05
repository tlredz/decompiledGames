local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Ghost = require(script:WaitForChild("Ghost"))
game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").Z.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local lightningBolt2 = Util.LightningBolt2
local tweenModelAnubis = Util.TweenModelAnubis
local debris = Util.Debris
Random.new()
local _ = {
	"rbxassetid://84826934758074",
	"rbxassetid://123495671243198",
	"rbxassetid://84401775257866",
	"rbxassetid://108358775861003",
	"rbxassetid://90555369855432",
	"rbxassetid://82115875581168",
	"rbxassetid://134814314638063",
	"rbxassetid://117018419921630",
	"rbxassetid://110202092656383",
	"rbxassetid://129646876724710",
	"rbxassetid://92267248856711",
	"rbxassetid://84009824510668"
}
local _ = {
	"rbxassetid://130452828882944",
	"rbxassetid://71120275331630",
	"rbxassetid://83529237504062",
	"rbxassetid://89359982828229",
	"rbxassetid://119164541102628",
	"rbxassetid://128504348629671",
	"rbxassetid://123584584840567"
}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
local random = Random.new()

local function areShiftedColorsEqual(instance, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return false
	end

	local shifted = child:FindFirstChild("Shifted")

	if shifted == nil then
		return false
	end

	local shifted_Color1 = shifted:GetAttribute("Shifted_Color1")
	local shifted_Color2 = shifted:GetAttribute("Shifted_Color2")
	local shifted_Color3 = shifted:GetAttribute("Shifted_Color3")

	if shifted_Color1 == nil or shifted_Color2 == nil or shifted_Color3 == nil then
		return false
	end

	return color == shifted_Color1 and color2 == shifted_Color2 and color3 == shifted_Color3
end

local function getColorHSVDistance(color: Color3, color2: Color3)
	local v = math.max(1, color2.R, color2.G, color2.B)
	local v2 = math.floor(color2.R / v * 255) % 256
	local v3 = math.floor(color2.G / v * 255) % 256
	local v4 = math.floor(color2.B / v * 255) % 256
	local color3 = Color3.fromRGB(v2, v3, v4)
	local HSV, _, _ = color:ToHSV()
	local HSV2, _, _ = color3:ToHSV()
	local v5 = math.abs(HSV2 - HSV)
	return (math.min(v5, 1 - v5))
end

local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
	if getColorHSVDistance(color, Color3.new(1, 1, 0)) > 0.05555555555555555 then
		return color
	end

	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + p) % 1
	local v8 = math.clamp(v5 * p2, 0, 1)
	local v9 = math.clamp(v6 * p3, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

local random2 = Random.new()

local function generateOffset(value: number, vector2: Vector3)
	local v = value or 0
	return vector2 or Vector3.new(random2:NextNumber(-1, 1), random2:NextNumber(-1, 1), random2:NextNumber(-1, 1)) * Vector3.new(
		random2:NextNumber(0, v),
		random2:NextNumber(0, v),
		random2:NextNumber(0, v)
	)
end

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end

		if not (emitter.Lifetime.Max <= max) then
			max = emitter.Lifetime.Max
		end
	end

	return max
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function infinityPath(p, p2)
	local v = 6.283185307179586 * p
	local v2 = math.sin(v)
	local v3 = math.sin(v) * math.cos(v)
	return Vector3.new(v2, math.sin(3.141592653589793 * (p % 1)), v3) * p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function fireClientProjectile(p, p2, fXContainer, fn, fn2, part, p3, fn3, fn4)
	local fn5 = fn2 == nil and function(_, _)
		return CFrame.indentity
	end or fn2
	local fn6 = p3 == nil and function(_)
		return CFrame.identity
	end or p3

	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(p2, p2, p2) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(fn(0.001), fn(0.002)) * CFrame.new(fn5(0.001, 0.001)) * fn6(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local heatSeek = fXContainer:GetAttribute("HeatSeek")
	local cFrame = part.CFrame
	local v2 = false
	local connection = nil
	local now = tick()
	connection = heartbeatLoopFor2(p, function(p4, p5, p6)
		local now2 = tick()

		if fXContainer:GetAttribute("ProjectileActive") == true or fXContainer:GetAttribute("ImpactPos") == nil or not (fXContainer:GetAttribute("DisabledInterp") < 0.9999) then
			local v3

			if typeof(heatSeek) == "number" then
				if heatSeek < now2 - now then
					v3 = true
				elseif typeof(heatSeek) == "boolean" then
					v3 = heatSeek
				else
					v3 = false
				end
			elseif typeof(heatSeek) == "boolean" then
				v3 = heatSeek
			else
				v3 = false
			end

			local v4, unit

			if v3 and fXContainer:GetAttribute("Tracked") then
				v4 = fn3(p5)
				unit = (v4 - cFrame.Position).Unit
			else
				v4 = fn(p6)
				unit = fn(p6 + 0.001) - fn(p6)
			end

			local cFrame2 = CFrame.new(createVector(0, 0, 0), unit) * CFrame.new(fn5(p6, p4)) * fn6(p6) + v4
			part.CFrame = cFrame2
			cFrame = cFrame2

			if fn4 then
				fn4(part.CFrame, p6, p5)
			end
		else
			connection:Disconnect()
			connection = nil
			snapProjectileToFinalPos(part, fXContainer:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
			bindableEvent:Fire(fXContainer:GetAttribute("ImpactPos"), "Impact")
			v2 = true
		end
	end, function()
		if v2 == true then
			warn("Prevented")
			return
		end

		snapProjectileToFinalPos(part, fn(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(fn(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function explode(player, data)
	local random3 = Random.new()
	local stage = data.Stage
	local origin = data.Origin
	local vector2 = data.Vector

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local clone

	if stage == 1 then
		clone = assets.ExplosionBig:Clone()
	else
		clone = assets.Explosion:Clone()
	end

	clone.CFrame = CFrame.new(origin)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		player,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone, function(_, p)
			return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
		end)
	end

	debris:AddItem(clone, ParticleState(clone.E1) + 0.02 + 0.25)

	for i = 1, stage == 1 and 2 or 1 do
		local v2 = i
		tweenModelAnubis(assets.WindRing, {
			Color = Util.WrapColor3Constructor(Color3.new(1, 1, 1), player, "PainFruitVFXColor"),
			CFrame = clone.CFrame * CFrame.Angles(
				3.141592653589793 * random3:NextNumber(-1, 1),
				3.141592653589793 * random3:NextNumber(-1, 1),
				3.141592653589793 * random3:NextNumber(-1, 1)
			),
			Size = createVector(1, 1, 1),
			Scale = 50
		}, {
			Color = Util.WrapColor3Constructor(Color3.new(1, 0.4, 0.4), player, "PainFruitVFXColor"),
			Custom = function(p)
				return {
					CFrame = CFrame.Angles(0, (v2 % 2 == 0 and 1 or -1) * 2 * 3.141592653589793 * p, 0)
				}
			end,
			Scale = stage ~= 1 and 75 or i == 1 and 95 or 110,
			Size = createVector(1, 0, 1),
			Transparency = 1,
			Tween = {
				Time = stage == 1 and 0.5 or 0.45,
				Style = "circ",
				Direction = "out"
			}
		})
	end

	for i = 1, stage == 1 and 4 or 2 do
		local v2 = i % 2 == 0 and 1 or -1
		local v3 = stage == 1 and random3:NextNumber(45, 65) or random3:NextNumber(20, 40) * 0.75
		local v4 = lightningBolt2.new({
			WorldPosition = clone.CFrame * generateOffset(v3),
			WorldAxis = random3:NextInteger(1, 2) == 1 and createVector(1, 0, 0) or createVector(0, 1, 0)
		}, {
			WorldPosition = clone.CFrame * (Vector3.new(
				random3:NextNumber(-0.75, 0.75),
				random3:NextNumber(-0.5, 0.5),
				random3:NextNumber(0.5, 1.5)
			) * v3),
			WorldAxis = random3:NextInteger(1, 2) == 1 and createVector(1, 0, 0) or createVector(0, 1, 0)
		}, 12)
		v4.Thickness = random3:NextNumber(v3 * 0.04, v3 * 0.075)
		local curveSize = v2 * 1.125 * v3
		local curveSize2 = -v2 * 1.125 * v3
		v4.CurveSize0 = curveSize
		v4.CurveSize1 = curveSize2
		v4.PulseSpeed = random3:NextNumber(6, 12)
		v4.PulseLength = random3:NextNumber(0.5, 1.5)
		v4.FadeLength = 0.1
		v4.MaxRadius = random3:NextNumber(8, 12)
		v4.Color = Util.WrapColor3Constructor(Color3.fromRGB(85, 0, 0), player, "PainFruitVFXColor"):Lerp(
			Util.WrapColor3Constructor(Color3.new(1, 0.75, 0.75), player, "PainFruitVFXColor"),
			random3:NextNumber(0.4, 0.6)
		)
	end

	task.delay(0.05, ParticleState, clone.Later)

	if (currentCamera.CFrame.p - origin).Magnitude < (stage == 1 and 350 or 306.25) then
		local rayCastWhitelist, v2, v3 = Util.RayCastWhitelist(
			origin - vector2 * 0.5,
			vector2 * ((stage == 1 and 75 or 50) / 2 + 1),
			{ workspace:FindFirstChild("Map") }
		)

		if not rayCastWhitelist then
			rayCastWhitelist, v2, v3 = Util.RayCastWhitelist(
				origin + createVector(0, 0.5, 0),
				createVector(-0, -1, -0) * ((stage == 1 and 75 or 50) / 2 + 1),
				{ workspace:FindFirstChild("Map") }
			)
		end

		if rayCastWhitelist then
			local v4 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), createVector(0, 0, 1)) + v2, v3) + v3 * 0.01
			local clone2 = assets.FloorSmudge:Clone()
			clone2.CFrame = v4 * CFrame.Angles(0, random3:NextNumber(-1, 1) * 3.141592653589793, 0)
			clone2.Attachment.ParticleEmitter.Size = NumberSequence.new(stage == 1 and 50 or 25)
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "PainFruitVFXColor")

			if areShiftedColorsEqual(
				player,
				"PainFruitVFXColor",
				Color3.fromRGB(255, 252, 55),
				Color3.fromRGB(95, 95, 14),
				Color3.fromRGB(255, 255, 112)
			) then
				Util.AdjustObjectDescendantsColors(clone2, function(_, p)
					return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
				end)
			end

			debris:AddItem(clone2, ParticleState(clone2) + 0.02 + 0.25)

			if (currentCamera.CFrame.p - origin).Magnitude < (stage == 1 and 262.5 or 218.75) then
				for _ = 1, stage == 1 and 5 or 3 do
					local v6 = random3:NextNumber(-1, 1) * 3.141592653589793
					local v7 = 30 * random3:NextNumber(0.5, 1)
					local v8 = (stage == 1 and 12 or 6) * random3:NextNumber(0.5, 1)
					local number = random3:NextNumber(0.25, 0.5)
					local unit = Vector3.new(
						math.sin(random3:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
						random3:NextNumber(0, 1) * 1.25,
						math.cos(random3:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
					).Unit
					local rock = Util.Rock2.new({
						Type = "Flying",
						FadeOut = { number / 2, number },
						FadeIn = { number / 2, number },
						Lifetime = { number / 2, number },
						Size = Vector3.new(
							random3:NextNumber(0.5, 1.5),
							random3:NextNumber(0.5, 1.5),
							random3:NextNumber(0.5, 1.5)
						),
						Scale = { v8 / 3, v8 / 2 }
					})
					rock:Spawn(v4 * CFrame.Angles(0, v6, 0) * CFrame.new(0, 0, -v7 / 2))
					rock:Eject({
						Velocity = Util.Misc.Physics.Velocity(
							Vector3.new(),
							unit * random3:NextNumber(v8 * (stage == 1 and 8 or 6), v8 * (stage == 1 and 10 or 8)),
							Vector3.new(0, -workspace.Gravity * random3:NextNumber(0.125, 1.125), 0),
							0.25 + random3:NextNumber(0.5, 1)
						),
						AngularVelocity = Vector3.new(
							random3:NextNumber(-1, 1),
							random3:NextNumber(-1, 1),
							random3:NextNumber(-1, 1)
						) * 2 * 3.141592653589793 * (1 / rock.Scale)
					})
				end
			end
		end
	end

	local v2 = math.min(1, (currentCamera.CFrame.p - origin).Magnitude / (stage == 1 and 100 or 80))

	if v2 < 1 then
		Effect.new("ShakeCam"):replicate({
			Magnitude = stage == 1 and 8 or 6,
			Roughness = stage == 1 and 8 or 6,
			FadeIn = stage == 1 and 0.4 or 0.3,
			FadeOut = 0.7,
			PosInfluence = createVector(0.15, 0.15, 0.15),
			RotInfluence = createVector(0, 0, 1),
			Power = (1 - v2) * 0.9 * 1.5 + 0.1
		})
	end
end

local function fireProjectile(player, data)
	local random3 = Random.new()
	local stage = data.Stage
	local _ = data.Stage
	local origin = data.Origin
	local _ = data.Target
	local _ = data.MidPointA
	local _ = data.MidPointB
	local swayVector = data.SwayVector
	local periods = data.Periods
	local flightPeriods = data.FlightPeriods
	local spread = data.Spread
	local angleOffset = data.AngleOffset
	local lifetime = data.Lifetime
	local v = Util.MasterClock:GetTime() - data.ServerTime

	local function fn(p, p2)
		local v2 = math.sin(3.141592653589793 * p)
		return swayVector * math.cos(periods * 2 * 3.141592653589793 * p2) * v2
	end

	local fn2 = stage == 3 and function(p)
		return origin + angleOffset * infinityPath(p * flightPeriods, spread)
	end or nil
	local fn3

	if stage == 3 then
		stage = 2

		fn3 = function(p)
			local speed = data.FXContainer:GetAttribute("Speed")
			local cFrame = data.FXContainer:GetAttribute("CFrame")
			local target = data.FXContainer:FindFirstChild("Target")
			local value = target and target.Value

			if value then
				local v2 = value.CFrame.Position - cFrame.Position
				return cFrame.Position + v2.Unit * speed * p
			end

			local lookVector = cFrame.LookVector
			return cFrame.Position + lookVector.Unit * speed * p
		end
	end

	local cframe = CFrame.new(fn2(0), fn2(0.0001))
	local v2 = Ghost.new(player, {
		Stage = stage
	})

	if stage == 1 then
		v2:scale(1.75)
	end

	v2:spawn(player, cframe)
	local v3 = 0.016666666666666666
	local now = tick()
	fireClientProjectile(lifetime - v, 1, data.FXContainer, fn2, fn, v2, nil, fn3, function(p, _, p2)
		v3 = p2
		local now2 = tick()

		if (p.Position - currentCamera.CFrame.Position).Magnitude > 1400 then
			return
		end

		v2:update(p, p2)

		if now2 - now > 0.13333333333333333 then
			if (p.Position - currentCamera.CFrame.Position).Magnitude < 350 then
				for i = 1, stage == 1 and 2 or 1 do
					local v4 = i % 2 == 0 and 1 or -1
					local number = random3:NextNumber(12.5, 25)
					local v5 = lightningBolt2.new({
						WorldPosition = v2.CFrame * (Vector3.new(
							random3:NextNumber(-0.75, 0.75),
							random3:NextNumber(-0.5, 0.5),
							random3:NextNumber(-0.5, 0.5)
						) * number),
						WorldAxis = createVector(1, 0, 0)
					}, {
						WorldPosition = v2.CFrame * (Vector3.new(
							random3:NextNumber(-0.75, 0.75),
							random3:NextNumber(-0.5, 0.5),
							random3:NextNumber(-0.5, 0.5)
						) * number),
						WorldAxis = createVector(1, 0, 0)
					}, 5)
					v5.Thickness = random3:NextNumber(number * 0.03, number * 0.075)
					local curveSize = v4 * 1.125 * number
					local curveSize2 = -v4 * 1.125 * number
					v5.CurveSize0 = curveSize
					v5.CurveSize1 = curveSize2
					v5.PulseSpeed = random3:NextNumber(8, 16)
					v5.PulseLength = random3:NextNumber(0.5, 1.5)
					v5.FadeLength = 0.1
					v5.MaxRadius = random3:NextNumber(8, 12)
					v5.Color = Util.WrapColor3Constructor(Color3.fromRGB(85, 0, 0), player, "PainFruitVFXColor"):Lerp(
						Util.WrapColor3Constructor(Color3.new(1, 0.75, 0.75), player, "PainFruitVFXColor"),
						random3:NextNumber(0.25, 0.75)
					)
				end
			end

			now = now2
		end
	end).Event:Once(function(origin2)
		local lookVector = v2.CFrame.LookVector
		v2:update(v2.CFrame - v2.CFrame.Position + origin2, v3)
		v2:destroy()
		task.spawn(explode, player, {
			Stage = stage,
			Origin = origin2,
			Vector = lookVector
		})
	end)
end

return function(data)
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local stage = data.Stage
	local player = data.Player

	if stage == 1 then
		local speed = data.Speed
		local lifetime = data.Lifetime
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, workspace._WorldOrigin, player, "PainFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local skillType = data.SkillType or "Single"

		if data.Id and data.Id == 1 then
			local folder2 = Instance.new("Folder")
			folder2.Name = "PainZStarted"
			Util.SetParentOverrideWithColor(folder2, data.Root, player, "PainFruitVFXColor")
			Util.Debris:AddItem(folder2, 2)
		end

		local clone = assets.ShootEffect:Clone()
		clone.CFrame = data.StartCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		local particleState = ParticleState(clone)
		task.delay(particleState, clone.Destroy, clone)
		local clone2

		if skillType == "Single" then
			Util.Sound:Play("Z_Tap_Fire_0" .. tostring(math.random(1, 3)) .. "_V1", clone.Position)
			clone2 = assets.GhostPartBig:Clone()
		else
			Util.Sound:Play("Z_Hold_Fire_0" .. tostring(math.random(1, 3)) .. "_V1", clone.Position)
			clone2 = assets.GhostPart:Clone()
		end

		clone2.Particles:Destroy()
		clone2.CFrame = data.GhostStartCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone2, function(_, p)
				return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		local clone3 = assets.GhostModel:Clone()
		clone3:PivotTo(clone2.CFrame)
		Util.SetParentOverrideWithColor(clone3, clone2, player, "PainFruitVFXColor")
		local raycastResult = nil
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			raycastResult = workspace:Raycast(clone2.Position, clone2.CFrame.LookVector * speed * dt, raycastParams)

			if not raycastResult and not (lifetime <= os.clock() - lastTime) then
				clone2.CFrame *= CFrame.new(0, 0, -speed * dt)
				clone3:PivotTo(clone2.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(1.5707963267948966, 0, 0))

				if not (os.clock() - lastTime2 >= 0.025) then
					return
				end

				lastTime2 = os.clock()
				local clone4

				if skillType == "Spam" then
					clone4 = assets.TrailEffect:Clone()
				else
					clone4 = assets.TrailEffectBig:Clone()
				end

				local position = clone2.Position
				local vector2 = Vector3.new(
					random:NextNumber(-28, 28),
					random:NextNumber(-28, 28),
					random:NextNumber(-28, 28)
				)
				local vector3 = Vector3.new(
					random:NextNumber(-28, 28),
					random:NextNumber(-28, 28),
					random:NextNumber(-28, 28)
				)

				if skillType == "Spam" then
					vector2 = Vector3.new(
						random:NextNumber(-18, 18),
						random:NextNumber(-18, 18),
						random:NextNumber(-18, 18)
					)
					vector3 = Vector3.new(
						random:NextNumber(-18, 18),
						random:NextNumber(-18, 18),
						random:NextNumber(-18, 18)
					)
				end

				local _ = position + vector2
				local _ = position + vector3
				clone4.Position = position
				Util.SetParentOverrideWithColor(clone4, folder, player, "PainFruitVFXColor")

				if areShiftedColorsEqual(
					player,
					"PainFruitVFXColor",
					Color3.fromRGB(255, 252, 55),
					Color3.fromRGB(95, 95, 14),
					Color3.fromRGB(255, 255, 112)
				) then
					Util.AdjustObjectDescendantsColors(clone4, function(_, p)
						return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
					end)
				end

				for i = 0, 1, RunService.Heartbeat:Wait() / 0.2 do
					local v3 = clone2.Position + vector2
					local v4 = clone2.Position + vector3
					local position2 = clone2.Position
					local v5 = position + (v3 - position) * i
					local v6 = v3 + (v4 - v3) * i
					local v7 = v4 + (position2 - v4) * i
					local v8 = v5 + (v6 - v5) * i
					clone4.Position = v8 + (v6 + (v7 - v6) * i - v8) * i
					RunService.Heartbeat:Wait()
				end

				local particleState2 = ParticleState(clone4, false)
				task.delay(particleState2 + 0.3, clone4.Destroy, clone4)
				return
			end

			heartbeatConnection:Disconnect()
			clone2.Position = raycastResult and raycastResult.Position or clone2.Position
			clone3:PivotTo(clone2.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(1.5707963267948966, 0, 0))
			local particleState3 = ParticleState(clone2, false)
			task.delay(particleState3, clone2.Destroy, clone2)
			clone3:Destroy()
			explode(player, {
				Stage = skillType == "Spam" and 2 or 1,
				Origin = clone2.Position,
				Vector = clone2.CFrame.LookVector
			})
			Util.Sound:Play("Z_Explode_0" .. tostring(math.random(1, 4)) .. "_V1", clone2.Position)
		end)
	elseif stage == 2 then
		local victimChar = data.VictimChar
		local victimRoot = data.VictimRoot

		if not victimChar:FindFirstChild("Head") then
			return
		end

		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, workspace._WorldOrigin, player, "PainFruitVFXColor")
		Util.Debris:AddItem(folder, 5)
		local cframe = CFrame.new(victimRoot.Position)
		local clone = assets.HitImpact:Clone()
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, folder, player, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		ParticleState(clone)
		task.spawn(function()
			local bubbleModule = Util.BubbleModule
			task.spawn(function()
				bubbleModule.CreateBubble(
					player,
					cframe * CFrame.new(0, 0.5, 0),
					createVector(10, 10, 10),
					6,
					createVector(20, 20, 20),
					0.15,
					folder
				)
			end)
			task.spawn(function()
				bubbleModule.CreateBubble(
					player,
					cframe * CFrame.new(0, 0.5, 0),
					createVector(30, 30, 30),
					115,
					createVector(0, 0, 0),
					0.125,
					folder
				)
			end)
		end)
	elseif stage == 3 then
		fireProjectile(player, data)
	end
end