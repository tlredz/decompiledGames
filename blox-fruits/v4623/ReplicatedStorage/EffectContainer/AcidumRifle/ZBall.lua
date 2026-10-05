game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage.FX)
local acid_Z = FX:WaitForChild("AcidumRifle").Acid_Z
local _WorldOrigin = workspace._WorldOrigin
local random = Random.new()

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end
	end
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

Util.ResizeModel(acid_Z.Explosion, 1.35, acid_Z.Explosion.Position)
return function(data)
	local origin = data.origin
	local _ = data.dir

	if (currentCamera.CFrame.p - origin).Magnitude > 900 then
		return
	end

	if data.stage == 1 then
		local projectileSpeed = data.projectileSpeed
		local folder = Instance.new("Folder")
		folder.Name = "AcidProjectile" .. tostring(data.iteration) .. "_" .. tostring(data.userId)
		folder.Parent = _WorldOrigin
		local startCFrame = data.startCFrame
		local clone = acid_Z.Shoot:Clone()
		clone.CFrame = startCFrame
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("BF_WPN_AcidiumRifle_SpikyBombFire_0" .. tostring(math.random(1, 3)) .. "_V2", clone.Position)
		local clone2 = acid_Z.Projectile:Clone()
		clone2.CFrame = startCFrame
		clone2.Parent = folder
		local follow = data.follow

		while follow and follow:IsDescendantOf(workspace) do
			local v = task.wait()
			local destroying = follow:GetAttribute("Destroying")

			if destroying == 1 then
				clone2.CFrame = follow.CFrame
				clone2.Anchored = false
				local weld = Instance.new("Weld")
				weld.Parent = clone2
				weld.Part0 = follow
				weld.Part1 = clone2
				break
			elseif destroying == 2 then
				clone2.CFrame = follow.CFrame
			else
				clone2.CFrame *= CFrame.new(0, 0, -projectileSpeed * v)
			end
		end

		if follow:IsDescendantOf(workspace) then
			Util.Debris:AddItem(folder, 15)
			return
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(3)
		folder:Destroy()
	elseif data.stage == 2 then
		local explosionTimer = data.explosionTimer
		local parent = _WorldOrigin:FindFirstChild("AcidProjectile" .. tostring(data.iteration) .. "_" .. tostring(data.userId))
		local projectile

		if parent then
			parent.Name = "AcidProjectile"
			projectile = parent.Projectile
		else
			parent = Instance.new("Folder")
			parent.Name = "AcidProjectile"
			parent.Parent = _WorldOrigin
			projectile = acid_Z.Projectile:Clone()
			projectile.CFrame = data.startCFrame
			projectile.Parent = parent
		end

		local clone = acid_Z.Explosion:Clone()
		clone.Parent = parent
		clone.Position = data.follow.Position
		local windUp = projectile.WindUp

		for _, emitter in pairs(windUp:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local lastTime = os.clock()

		repeat
			task.spawn(function()
				local clone2 = acid_Z.Bezier:Clone()
				local position2 = projectile.Position + Vector3.new(
					random:NextNumber(-20, 20),
					random:NextNumber(0, 20),
					random:NextNumber(-20, 20)
				)
				local v3 = projectile.Position + Vector3.new(
					random:NextNumber(-20, 20),
					random:NextNumber(-10, 20),
					random:NextNumber(-20, 20)
				)
				local v4 = projectile.Position + Vector3.new(
					random:NextNumber(-20, 20),
					random:NextNumber(-10, 20),
					random:NextNumber(-20, 20)
				)
				local position = projectile.Position
				clone2.Position = position2
				clone2.Parent = parent
				clone2.Trail.Lifetime = random:NextNumber(0.07, 0.13)
				local lastTime2 = tick()

				while tick() - lastTime2 < 0.15 do
					local v5 = (tick() - lastTime2) / 0.15
					local v6 = position2 + (v3 - position2) * v5
					local v7 = v3 + (v4 - v3) * v5
					local v8 = v4 + (position - v4) * v5
					local v9 = v6 + (v7 - v6) * v5
					clone2.Position = v9 + (v7 + (v8 - v7) * v5 - v9) * v5
					task.wait()
				end
			end)
			task.wait(random:NextNumber(0.02, 0.05))
			local v2 = os.clock() - lastTime
		until explosionTimer - 0.15 <= v2

		projectile:Destroy()

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("BF_WPN_AcidiumRifle_Z_Explosion_0" .. tostring(math.random(1, 5)) .. "_V2", clone.Position)
		projectile:Destroy()
		task.wait(5)
		parent:Destroy()
	end
end