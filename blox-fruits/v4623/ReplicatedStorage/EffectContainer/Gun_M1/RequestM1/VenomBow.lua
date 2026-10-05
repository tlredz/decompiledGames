local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local WeaponData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponData"))
local v = WeaponData[script.Name]
local Sound = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("Sound"))
local TweenService = game:GetService("TweenService")
local random = Random.new()
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local serpentBow = FX:WaitForChild("SerpentBow")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

-- equivalent calls inferred from this helper; original call sites unknown
local function EmitDescendants(emitter)
	coroutine.wrap(function()
		if emitter:IsA("ParticleEmitter") then
			local emitCount = emitter:GetAttribute("EmitCount") or 1
			local emitDelay = emitter:GetAttribute("EmitDelay") or nil

			if emitDelay then
				task.wait(emitDelay)
			end

			emitter:Emit(emitCount)
		else
			for _, emitter2 in pairs(emitter:GetDescendants()) do
				if not emitter2:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter2
				task.spawn(function()
					local emitCount = v2:GetAttribute("EmitCount") or 1
					local emitDelay = v2:GetAttribute("EmitDelay") or nil

					if emitDelay then
						task.wait(emitDelay)
					end

					v2:Emit(emitCount)
				end)
			end
		end
	end)()
end

local function DisableDescendantParticles(emitter)
	if emitter:IsA("ParticleEmitter") then
		emitter.Enabled = false
		return
	end

	for _, emitter2 in pairs(emitter:GetDescendants()) do
		if emitter2:IsA("ParticleEmitter") then
			emitter2.Enabled = false
		end
	end
end

local function Random1(p, p2)
	return random:NextInteger(p * 100, p2 * 100) / 100
end

return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
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

	local worldPosition = child.WorldPosition
	local targetPosition = data.TargetPosition
	local v2 = HRP.CFrame * CFrame.new(0, 0, -4)
	local folder = Instance.new("Folder")
	folder.Name = "GunM1Effect"
	folder.Parent = _WorldOrigin
	local clone = serpentBow.ShootVFX:Clone()
	clone.CFrame = CFrame.lookAt(v2.Position, targetPosition)
	clone.Parent = folder
	EmitDescendants(clone) -- equivalent call inferred; original call site unknown
	Util.Debris:AddItem(clone, 2)
	local targetPosition2 = data.TargetPosition
	local clone2 = serpentBow.M1_Hydra:Clone()
	clone2.CFrame = CFrame.lookAt(v2.Position, targetPosition2)
	clone2.Parent = folder
	local fireSound = v.FireSound

	if fireSound then
		Sound:Play(fireSound .. tostring(math.random(1, 3)), clone2.Position)
	end

	EmitDescendants(clone2) -- equivalent call inferred; original call site unknown
	task.wait()
	local v3 = (targetPosition2 - worldPosition).Magnitude / data.ProjectileSpeed
	TweenService:Create(clone2, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
		CFrame = CFrame.lookAt(targetPosition2, targetPosition2 + clone2.CFrame.LookVector)
	}):Play()
	task.wait(v3)
	EmitDescendants(clone2) -- equivalent call inferred; original call site unknown
	clone2.Transparency = 1
	DisableDescendantParticles(clone2)
	Util.Debris:AddItem(clone2, 2)

	if data.HitMap or data.HitLimb then
		local clone3 = serpentBow.Hit:Clone()
		clone3.Position = targetPosition2
		clone3.Parent = folder
		EmitDescendants(clone3) -- equivalent call inferred; original call site unknown
		Util.Debris:AddItem(clone3, 2)
		Sound:Play("BF_WPN_VenomBow_M1_Fire_ArrowHit_0" .. tostring(math.random(1, 4)), clone3.Position)

		for _ = 1, 4 do
			local clone4 = serpentBow.Shockwave:Clone()
			clone4.CFrame = clone3.CFrame * CFrame.Angles(
				math.rad(random:NextInteger(-18000, 18000) / 100),
				math.rad(random:NextInteger(-18000, 18000) / 100),
				(math.rad(random:NextInteger(-18000, 18000) / 100))
			)
			clone4.Mesh.Scale = createVector(0, 0, -0)
			clone4.Parent = folder
			Util.Debris:AddItem(clone4, 3)
			task.spawn(function()
				local Animate = require(script.Animate)
				Animate(1 / math.random(24, 40), clone4)
			end)
			local v5 = random:NextInteger(120, 140) / 100
			TweenService:Create(clone4.Mesh, TweenInfo.new(v5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Scale = createVector(8, 8, -8) * (random:NextInteger(50, 120) / 100)
			}):Play()
			TweenService:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = clone4.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
		end
	end

	local model = data.HitLimb and data.HitLimb:FindFirstAncestorOfClass("Model")

	if model then
		local upperTorso = model:FindFirstChild("UpperTorso") or model.Parent:FindFirstChild("UpperTorso")
		local total = 1.2

		if upperTorso then
			if upperTorso.Size.Magnitude > (createVector(1.811, 1.946, 1.013)).Magnitude then
				total += upperTorso.Size.Magnitude / (createVector(1.811, 1.946, 1.013)).Magnitude
			end

			local clone3 = serpentBow.PoisonParticles:Clone()
			clone3.CFrame = upperTorso.CFrame
			Util.ResizeModel(clone3, total, clone3.Position)
			clone3.Weld.Part0 = upperTorso
			clone3.Parent = folder
			task.delay(data.EffectDuration, function()
				DisableDescendantParticles(clone3)
			end)
		end
	end

	task.wait(2 + data.EffectDuration)

	if folder then
		folder:Destroy()
	end
end