local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local flyingTridentPull = FX:WaitForChild("SpikeyTrident").FlyingTridentPull
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }
return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1400 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local v = flyingTridentPull
	local parent4 = _WorldOrigin
	local _ = data.projectileSpeed
	local _ = data.projectileDuration

	local function easeOutSine(p: number)
		return 1 - math.pow(1 - p, 3)
	end

	local function DestroyProjectile(folder, p)
		if folder == nil or folder.Parent == nil then
			return
		end

		folder:SetAttribute("Active", true)

		if p then
			folder.WorldPivot = folder:GetPivot().Rotation + folder.Handle.Position
			folder:PivotTo(folder:GetPivot().Rotation + p)
		end

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.Transparency = 1
		end

		local doughRope = folder:FindFirstChild("DoughRope")

		if doughRope then
			TweenService:Create(doughRope, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end

		destroyAfter(doughRope, 0.4)

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("Beam") then
				TweenService:Create(descendant, TweenInfo.new(0.3), {
					Width0 = 0,
					CurveSize0 = 0
				}):Play()
			elseif descendant:IsA("BasePart") then
				TweenService:Create(descendant, TweenInfo.new(0.4), {
					Transparency = 1
				}):Play()
			end
		end

		destroyAfter(folder, 2)
	end

	local function Projectile(parent2, parent3)
		local clone = v.DoughRope:Clone()
		clone.Attachment1 = parent2.RightHand.RightGripAttachment
		clone.Attachment0 = parent3.Handle.DoughAttachment
		clone.Parent = parent3
		destroyAfter(clone, 7)
		coroutine.wrap(function()
			local v3 = time()

			for _ = 1, 600 do
				if parent3.Handle.Transparency ~= 0 or time() - v3 > 10 then
					break
				end

				task.wait(0.15)
				local clone2 = v.ProjectileRing:Clone()
				clone2.CFrame = parent3.Handle.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 6.283185307179586, 0)
				clone2.Parent = parent4
				destroyAfter(clone2, 7)
				TweenService:Create(clone2, TweenInfo.new(0.34, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Size = createVector(22, 0, 22)
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.34), {
					Transparency = 1
				}):Play()
				task.delay(0.34, function()
					clone2:Destroy()
				end)
			end
		end)
	end

	local function EffectHandler(list)
		if list[2] == "Shoot" then
			Effect.new("Dough.Explosions.DripScatter"):replicate({
				CFrame = list[3].Handle.CFrame,
				Scale = 6,
				Gravity = 1,
				Distance = 60,
				Rate = 20,
				DropLifetime = 1.5,
				Influence = { 0.5, 1.5 },
				Time = random:NextNumber(0.3, 1.5),
				Force = true
			})
			Projectile(hrp.Parent, list[3])
		elseif list[2] == "DestroyProjectile" then
			DestroyProjectile(list[3], list[4])
		end
	end

	local clone = v.Projectile2:Clone()
	local victimRoot = data.victimRoot
	local pullTime = data.pullTime

	if victimRoot then
		local impactPos = data.impactPos
		local unit = (impactPos - hrp.Position).Unit
		clone:PivotTo((CFrame.lookAt(createVector(0, 0, 0), impactPos - hrp.Position) + impactPos - unit * 3) * inverse)
		clone.Handle.Anchored = true
		clone.Parent = _WorldOrigin
		destroyAfter(clone, 7)
		task.spawn(EffectHandler, { parent, "Shoot", clone })
		heartbeatLoopFor2(pullTime, function()
			clone:PivotTo(clone:GetPivot().Rotation + victimRoot.Position - unit * 3)
		end, function()
			DestroyProjectile(clone)
		end)
	else
		local impactPos = data.impactPos
		local _ = (impactPos - hrp.Position).Unit
		clone:PivotTo((CFrame.lookAt(createVector(0, 0, 0), impactPos - hrp.Position) + impactPos) * inverse)
		clone.Handle.Anchored = true
		clone.Parent = _WorldOrigin
		destroyAfter(clone, 7)
		task.spawn(EffectHandler, { parent, "Shoot", clone })
		task.delay(pullTime, function()
			DestroyProjectile(clone)
		end)
	end
end