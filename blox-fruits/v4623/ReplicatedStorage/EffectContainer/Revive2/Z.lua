local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Mouse = require(ReplicatedStorage:WaitForChild("Mouse"))
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local revive = FX:WaitForChild("Revive")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
end

local function putValueAsValueObject(parent, name: string, p, value: number)
	local v2 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance = parent:FindFirstChild(name)

	if instance == nil then
		instance = Instance.new(v2[typeof(p)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = p
	destroyAfter(instance, value or 60)
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function fireClientProjectile(p, p2, instance, callback, part, p3)
	local fn = p3 == nil and function(_)
		return CFrame.new()
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

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * fn(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p4)
		if instance:GetAttribute("ProjectileActive") == true or instance:GetAttribute("ImpactPos") == nil or not (instance:GetAttribute("DisabledInterp") < 0.9999) then
			part.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * fn(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

function EmitAll(items)
	local function Emit(folder)
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("EmitDelay") then
				local v = emitter
				task.delay(emitter:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	if typeof(items) ~= "table" then
		Emit(items)
		return
	end

	for _, item in items do
		Emit(item)
	end
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function QuadBezier(p, p2, p3, p4)
	local v = p2 + (p3 - p2) * p
	return v + (p3 + (p4 - p3) * p - v) * p
end

function AllVFX(items, enabled2, p2)
	local function Emit(folder, enabled, duration)
		for _, effect in ipairs(folder:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
				continue
			end

			effect.Enabled = enabled
		end

		if duration then
			task.delay(duration, function()
				for _, effect in ipairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end)
		end
	end

	if typeof(items) ~= "table" then
		Emit(items, enabled2, p2)
		return
	end

	for _, item in items do
		Emit(item, enabled2, p2)
	end
end

function LightOut(folder, duration)
	for _, light in ipairs(folder:GetDescendants()) do
		if light:IsA("PointLight") or light:IsA("SpotLight") then
			TweenService:Create(light, TweenInfo.new(duration), {
				Brightness = 0,
				Range = 0
			}):Play()
		end
	end
end

function LightUp(folder, duration, duration2)
	for _, light in ipairs(folder:GetDescendants()) do
		if not (light:IsA("PointLight") or light:IsA("SpotLight")) then
			continue
		end

		local brightness = light.Brightness
		local brightness2 = light.Brightness
		light.Brightness = 0
		light.Range = 0
		TweenService:Create(light, TweenInfo.new(duration), {
			Brightness = brightness,
			Range = brightness2
		}):Play()
	end

	if duration2 then
		task.delay(duration2, function()
			LightOut(folder, duration)
		end)
	end
end

function AutoBeam(folder, duration, duration2)
	for _, beam in ipairs(folder:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local width0 = beam.Width0
		local width1 = beam.Width1
		beam.Width0 = 0
		beam.Width1 = 0
		TweenService:Create(beam, TweenInfo.new(duration), {
			Width0 = width0,
			Width1 = width1
		}):Play()

		if not duration2 then
			continue
		end

		local v = beam
		task.delay(duration2, function()
			TweenService:Create(v, TweenInfo.new(duration), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end)
	end
end

function KillBeam(folder, duration)
	for _, beam in ipairs(folder:GetDescendants()) do
		if beam:IsA("Beam") then
			TweenService:Create(beam, TweenInfo.new(duration), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end
end

function Flipbook(p, list, p2: number)
	if p and list then
		task.spawn(function()
			for i = 1, #list do
				p.TextureId = list[i]
				task.wait(1 / p2)
			end
		end)
	end
end

local v = {
	"rbxassetid://13074433861",
	"rbxassetid://13074433559",
	"rbxassetid://13074433096",
	"rbxassetid://13074432714",
	"rbxassetid://13074432270",
	"rbxassetid://13074431988",
	"rbxassetid://13074431637",
	"rbxassetid://13074431344",
	"rbxassetid://13074430970",
	"rbxassetid://13074430662",
	"rbxassetid://13074430370",
	"rbxassetid://13074429998",
	"rbxassetid://13074429638",
	"rbxassetid://13074429320",
	"rbxassetid://13074428722",
	"rbxassetid://13074428270"
}

for k, v2 in pairs(v) do
	local Graphics = require(game.ReplicatedStorage.Util.Graphics)
	v[k] = Graphics.ScaleDown(v2)
end

local function haltUntilCondition(fn, value: number?)
	local v2 = value or 10
	local bindableEvent = Instance.new("BindableEvent")
	task.delay(v2, bindableEvent.Fire, bindableEvent)
	local connection = nil
	connection = heartbeatLoopFor2(v2, function()
		local success, result = pcall(fn)

		if success and result then
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		elseif not success then
			print("haltUntilCondition: Error in predicate function: ", result)
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
end

local function TimeScaleParticle(emitter, p)
	emitter.Drag *= p
	emitter.Speed = NumberRange.new(emitter.Speed.Min * p, emitter.Speed.Max * p)
	emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min / p, emitter.Lifetime.Max / p)
	emitter.Rate *= p
	emitter.RotSpeed = NumberRange.new(emitter.RotSpeed.Min * p, emitter.RotSpeed.Max * p)
	emitter.Acceleration *= p ^ 2

	if emitter:GetAttribute("EmitDelay") then
		emitter:SetAttribute("EmitDelay", emitter:GetAttribute("EmitDelay") / p)
	end
end

local function adjustDuration(p, p2)
	local v2 = math.max(0.01, p - p2)
	return v2, p2 - (p - v2)
end

return function(data)
	local player = data.player
	local TryGetColorFolderParent = require(game.ReplicatedStorage.Modules.TryGetColorFolderParent)
	local tryGetColorFolderParent = TryGetColorFolderParent(data)
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local v3 = Workspace:GetServerTimeNow() - data.Timestamp
	local _ = data.origin
	local _ = data.fireDir
	local parent2 = _WorldOrigin
	local flightTime = data.flightTime
	local v5 = math.max(0.01, flightTime - v3)
	local _ = v3 - (flightTime - v5)
	local windUpTime = data.windUpTime
	local duration = math.max(0.01, windUpTime - v3)
	v3 -= windUpTime - duration
	Effect.new("Revive2.Ghostify"):replicate({
		player = player,
		summoner = data.summoner,
		hrp = hrp,
		Duration = duration,
		Enabled = true,
		Z = true
	})
	sound:Play("Ghost.ReviveFruitZIntro", hrp.Position)
	local v7, v8

	if player == localPlayer then
		local v9 = Mouse.Hit.p - hrp.Position
		local v10

		if v9.Magnitude >= 1 then
			v10 = v9.Unit
		else
			v10 = hrp.CFrame.LookVector
		end

		v7 = Util.BodyMover.new(parent):Create("BodyGyro", {
			CFrame = CFrame.new(createVector(0, 0, 0), v10),
			Priority = 100,
			Duration = v5 + duration
		})
		v8 = Util.BodyMover.new(parent):Create("BodyVelocity", {
			Velocity = createVector(0, 0, 0),
			Priority = 100,
			Duration = v5 + duration
		})
		v8:SetForce(createVector(800000, 800000, 800000))
		v7:SetForce(createVector(800000, 800000, 800000))
	else
		v8 = nil
		v7 = nil
	end

	task.wait(duration)

	if player == localPlayer then
		local position = cFrame.Position
		local v9 = 7 or 8
		local v10 = 12 or 14
		local v11 = 0.2
		local v12 = 0.6 or 0.7

		if (999 or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
			Util.CameraShaker:ShakeOnce(v9, v10, v11, v12)
		end
	end

	local clone = revive.Possession:Clone()
	clone:PivotTo(hrp.CFrame * CFrame.new(0, 0, -10))
	local v9 = data.flightSpeed / 200
	local v10 = true

	for _, emitter in ipairs(clone.Main:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			TimeScaleParticle(emitter, v9)
		end
	end

	local windBackLeft = clone.WindBackLeft
	local windBackRight = clone.WindBackRight
	local ray = Util.Ray
	local position = hrp.CFrame.Position
	local TargetFolders = { Workspace.Characters, Workspace.NPCs }
	local v11, v12, v13 = ray(position, createVector(-0, -10, -0), TargetFolders)

	if v11 then
		local v14 = Util.Misc.AlignCFrame(
			CFrame.new(createVector(0, 0, 0), clone.PrimaryPart.CFrame.LookVector) + v12,
			v13
		) + v13 * 7.5
		local objectSpace = clone.PrimaryPart.CFrame:ToObjectSpace(windBackLeft.CFrame)
		local objectSpace2 = clone.PrimaryPart.CFrame:ToObjectSpace(windBackRight.CFrame)
		windBackLeft.CFrame = v14 * objectSpace
		windBackRight.CFrame = v14 * objectSpace2
	else
		windBackLeft:Destroy()
		windBackRight:Destroy()
	end

	Util.SetParentOverrideWithColor(clone, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	destroyAfter(clone, 7)
	AllVFX(clone, true)

	if v11 then
		destroyAfter(windBackLeft, 0.4)
		destroyAfter(windBackRight, 0.4)
		TweenService:Create(windBackLeft, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
			Transparency = 1,
			CFrame = windBackLeft.CFrame * CFrame.new(-30, 0, 0)
		}):Play()
		TweenService:Create(windBackRight, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
			Transparency = 1,
			CFrame = windBackRight.CFrame * CFrame.new(-30, 0, 0)
		}):Play()
	end

	local clone2 = revive["Possession Wind"].BackWind:Clone()
	clone2.CFrame = hrp.CFrame * CFrame.new(0, 2, 25) * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone2.Size /= 2
	Util.SetParentOverrideWithColor(clone2, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	destroyAfter(clone2, 7)
	local clone3 = revive["Possession Wind"].MiddleWind:Clone()
	clone3.CFrame = hrp.CFrame * CFrame.new(0, 2, 10) * CFrame.Angles(1.5707963267948966, 3.141592653589793, 0)
	clone3.Size /= 2
	Util.SetParentOverrideWithColor(clone3, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	destroyAfter(clone3, 7)
	local clone4 = revive["Possession Wind"].BrightFrontWind:Clone()
	clone4.CFrame = hrp.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(1.5707963267948966, -3.141592653589793, 0)
	clone4.Size /= 2
	Util.SetParentOverrideWithColor(clone4, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	destroyAfter(clone4, 7)
	local size = clone2.Size
	local transparency = clone2.Transparency
	local size2 = clone3.Size
	local transparency2 = clone3.Transparency
	local size3 = clone4.Size
	local transparency3 = clone4.Transparency
	task.defer(function()
		local v14 = time()

		for _ = 1, 600 do
			if not v10 or time() - v14 > 10 then
				break
			end

			Flipbook(clone.MainSpiral.Mesh, v, 16)
			Flipbook(clone.FrontSpiral.Mesh, v, 16)
			task.wait(1)
		end
	end)
	local unit

	if player == localPlayer then
		local unit2 = (Mouse.Hit.p - hrp.Position).Unit

		if unit2.Magnitude >= 1 then
			unit = unit2.Unit
		else
			unit = hrp.CFrame.LookVector
		end
	else
		unit = nil
	end

	local v14 = sound:Play("Ghost.ReviveFruitZAmb", clone.PrimaryPart)
	local lastTime = tick()
	local cFrame2 = hrp.CFrame
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(_)
		if clone ~= nil and clone.Parent ~= nil and not (v5 < tick() - lastTime) then
			clone:PivotTo(hrp.CFrame * CFrame.new(0, 0, -10))
			clone2.CFrame *= CFrame.Angles(0, 0.20943951023931956, 0)
			clone3.CFrame *= CFrame.Angles(0, -0.15707963267948966, 0)
			clone4.CFrame *= CFrame.Angles(0, 0.24434609527920614, 0)
			clone["Front Spike"].CFrame *= CFrame.Angles(0, 0.3490658503988659, 0)
			clone.MainSpiral.CFrame *= CFrame.Angles(0, 0.17453292519943295, 0)
			clone.FrontSpiral.CFrame *= CFrame.Angles(0, 0.17453292519943295, 0)

			if player == localPlayer then
				local v19 = Mouse.Hit.p - hrp.Position
				local v20

				if v19.Magnitude >= 1 then
					v20 = v19.Unit
				else
					v20 = hrp.CFrame.LookVector
				end

				unit = CFrame.lookAt(createVector(0, 0, 0), unit):Lerp(
					CFrame.lookAt(createVector(0, 0, 0), v20),
					data.turnSpeed
				).LookVector
				v8:Set(unit * data.flightSpeed)
				v7:Set(CFrame.lookAt(createVector(0, 0, 0), unit) + hrp.Position)
			end

			cFrame2 = hrp.CFrame
			return
		end

		heartbeatConnection:Disconnect()
	end)
	task.spawn(function()
		haltUntilCondition(function()
			return data.skillZActive.Value == false or v5 < tick() - lastTime
		end)
		sound:FadeOut(v14, 0.5)
		sound:Play("Ghost.ReviveFruitZIntro", hrp.Position, nil, 2.5)
		v10 = false
		heartbeatConnection:Disconnect()
		destroyAfter(clone, 2)
		destroyAfter(clone2, 0.25)
		destroyAfter(clone3, 0.25)
		destroyAfter(clone4, 0.25)
		clone["Front Spike"]:Destroy()
		AllVFX(clone, false)

		for _, descendant in clone:GetDescendants() do
			if not (descendant:IsA("MeshPart") or descendant:IsA("Decal") or descendant:IsA("BasePart")) then
				continue
			end

			TweenService:Create(descendant, TweenInfo.new(0.05), {
				Transparency = 1
			}):Play()
		end

		hrp.Velocity = Vector3.new()
		hrp.RotVelocity = Vector3.new()
		hrp.CFrame = cFrame2
		Effect.new("Revive2.Ghostify"):replicate({
			player = player,
			summoner = data.summoner,
			hrp = hrp,
			Duration = 0.5,
			Enabled = false,
			Z = false
		})

		if v8 then
			v8:Destroy()
		end

		if v7 then
			v7:Destroy()
		end
	end)
	local v15 = nil
	task.spawn(function()
		local v16 = time()

		for _ = 1, 600 do
			if not v10 or time() - v16 > 10 then
				break
			end

			clone2.CFrame = hrp.CFrame * CFrame.new(0, 2, 25) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone3.CFrame = hrp.CFrame * CFrame.new(0, 2, 10) * CFrame.Angles(1.5707963267948966, 3.141592653589793, 0)
			clone4.CFrame = hrp.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(1.5707963267948966, -3.141592653589793, 0)
			clone2.Size = size
			clone2.Transparency = transparency
			clone3.Size = size2
			clone3.Transparency = transparency2
			clone4.Size = size3
			clone4.Transparency = transparency3
			v15 = TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = clone2.Size * 2
			})
			v15:Play()
			v15:Destroy()
			v15 = TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = clone3.Size * 2
			})
			v15:Play()
			v15:Destroy()
			v15 = TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = clone4.Size * 2
			})
			v15:Play()
			v15:Destroy()
			task.wait(0.25)
		end
	end)
end