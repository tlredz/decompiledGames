local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local WeaponData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponData"))
local dragonstorm = WeaponData.Dragonstorm
local CombatUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CombatUtil"))
local Sound = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Sound"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local dragonstorm_M1 = FX:WaitForChild("Gun_M1").Dragonstorm_M1
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function ParticleState(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if effect:IsA("ParticleEmitter") then
				effect:Emit(effect:GetAttribute("EmitCount"))
			end
		else
			effect.Enabled = enabled
		end
	end
end

local random = Random.new()
return function(data)
	if (data.origin - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local HRP = data.HRP
	local child = HRP.Parent:FindFirstChild("EquippedWeapon") and HRP.Parent.EquippedWeapon:FindFirstChild(
		data.ShootAttachment,
		true
	)

	if not child then
		return
	end

	if data.OverheatTime then
		Sound:Play("DragonStorm_M1_Fire_Overheat_01", child.Parent)
		local clone = dragonstorm_M1.Overheat.Attachment.Smoke:Clone()
		clone.Parent = child
		task.delay(data.OverheatTime - 0.1, function()
			clone.Enabled = false
			Util.Debris:AddItem(clone, 1.5)
			Sound:Play("DragonStorm_M1_Fire_Cooldown_01", child.Parent)
		end)
	else
		local targetPosition = data.TargetPosition
		local worldPosition = child.WorldPosition or data.origin
		local cframe = CFrame.lookAt(worldPosition, targetPosition)
		local angle = (data.Angles or CombatUtil:CreateShootAngles({
			BulletSpreadCount = dragonstorm.BulletSpreadCount,
			BulletSpreadDegree = dragonstorm.BulletSpreadDegree,
			Range = dragonstorm.Range,
			Origin = worldPosition,
			TargetPosition = CombatUtil:GetTargetPosition(HRP.Position, data.TargetPosition, dragonstorm.Range),
			Seed = data.Seed
		}))[1].Angle
		local v = cframe * angle
		local projectileSpeed = data.ProjectileSpeed
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		folder.Parent = _WorldOrigin
		local clone = dragonstorm_M1.MuzzelFlash:Clone()
		clone.CFrame = CFrame.lookAt(child.WorldPosition, targetPosition)
		clone.Parent = folder
		Sound:Play("DragonStorm_M1_Fire_Shot_0" .. tostring(math.random(1, 9)), clone)
		task.spawn(function()
			local v2 = tick() + 0.2
			local v3 = false

			while tick() < v2 do
				clone.CFrame = CFrame.lookAt(child.WorldPosition, targetPosition)

				if v2 - 0.1 <= tick() and not v3 then
					v3 = true

					for _, effect in clone:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end

				task.wait()
			end
		end)
		local _ = dragonstorm.BulletSpreadDegree
		local clone2 = dragonstorm_M1["Crackle" .. random:NextInteger(1, 2)]:Clone()
		local number = random:NextNumber(0.2, 0.4)
		local v2 = -random:NextNumber(300, 500)
		local total = 0
		local total2 = 0
		local v3 = (random:NextInteger(0, 1) * 2 - 1) * random:NextNumber(500, 920)
		local total3 = 0
		local number2 = random:NextNumber(30, 50)
		local v4 = CFrame.lookAt((HRP.CFrame * CFrame.new(0, 0, -3)).Position, targetPosition) * angle
		clone2.CFrame = v4 * CFrame.new(
			math.sin((math.rad(total2))) * total3,
			math.cos((math.rad(total2))) * total3,
			total
		)
		clone2.Parent = folder
		Sound:Play("DragonStorm_M1_Fire_BlueFirecrackerSwirl_0" .. tostring(math.random(1, 7)), clone2)
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total2 += v3 * dt
			total += v2 * dt
			total3 += number2 * dt
			clone2.CFrame = v4 * CFrame.new(
				math.sin((math.rad(total2))) * total3,
				math.cos((math.rad(total2))) * total3,
				total
			)
		end)
		task.delay(number * random:NextNumber(0.8, 0.9), function()
			for _, effect in clone2:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			task.wait(number * 0.2)
			heartbeatConnection:Disconnect()
		end)
		local position = v * CFrame.new(0, 0, -(v.Position - data.TargetPosition).Magnitude).Position
		local clone3 = dragonstorm_M1.Bullet:Clone()
		clone3.CFrame = CFrame.lookAt(child.WorldPosition, position)
		clone3.Parent = folder
		task.wait()
		local v6 = (position - clone3.Position).Magnitude / projectileSpeed
		local tween = TweenService:Create(clone3, TweenInfo.new(v6, Enum.EasingStyle.Linear), {
			Position = position
		})
		tween:Play()
		tween.Completed:Wait()
		task.defer(function()
			for _, effect in clone3:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
		local hitMap = data.HitMap or data.HitLimb

		if hitMap then
			local clone4 = dragonstorm_M1.Explode:Clone()
			clone4.Position = position
			clone4.Parent = folder
			ParticleState(clone4)
			Sound:Play("DragonStorm_M1_Fire_BulletImpact_0" .. tostring(math.random(1, 5)), position)

			if data.HitMap then
				for _ = 1, random:NextInteger(1, 3) do
					local clone5 = dragonstorm_M1["MiniCrackle" .. random:NextInteger(1, 2)]:Clone()

					if hitMap ~= true then
						clone5.CFrame = CFrame.lookAt(hitMap.Position, hitMap.Position + hitMap.Normal) * CFrame.Angles(
							math.rad((random:NextNumber(-30, 30))),
							math.rad((random:NextNumber(-30, 30))),
							0
						)
					end

					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = clone5.CFrame.LookVector * random:NextNumber(120, 250)
					TweenService:Create(
						bodyVelocity,
						TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Velocity = bodyVelocity.Velocity * 0.8 + createVector(0, -45, 0)
						}
					):Play()
					bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
					bodyVelocity.Parent = clone5
					clone5.Parent = folder
					local folder2 = clone5
					task.delay(0.07, function()
						bodyVelocity:Destroy()
						task.wait(random:NextNumber(0.08, 0.2))

						for i, effect in folder2:GetDescendants() do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
				end
			end
		end

		task.wait(3)
		folder:Destroy()
	end
end