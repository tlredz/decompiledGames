game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponData"))
local v = WeaponData[script.Name]
local Sound = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("Sound"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local flintlock_M1 = FX:WaitForChild("Gun_M1").Flintlock_M1
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

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

return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local HRP = data.HRP
	local parent = HRP.Parent
	local child = HRP.Parent:FindFirstChild("EquippedWeapon") and HRP.Parent.EquippedWeapon:FindFirstChild(
		data.ShootAttachment,
		true
	)

	if not child then
		return
	end

	local projectileSpeed = data.ProjectileSpeed
	local targetPosition = data.TargetPosition
	local folder = Instance.new("Folder")
	folder.Name = "GunM1Effect"
	folder.Parent = _WorldOrigin
	local clone = flintlock_M1.Shoot:Clone()
	clone.CFrame = HRP.CFrame * CFrame.new(0, 0, -3)
	clone.Position = child and child.WorldPosition or clone.Position
	clone.Parent = folder

	if parent == game.Players.LocalPlayer.Character then
		task.wait()
		task.wait()
	end

	local fireSound = v.FireSound

	if fireSound then
		Sound:Play("GunsV3." .. script.Name .. "." .. fireSound, clone.Position)
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local clone2 = flintlock_M1.Projectile:Clone()
	clone2.CFrame = CFrame.lookAt(clone.Position, targetPosition)
	clone2.Parent = folder
	local targetPosition2 = data.TargetPosition
	task.wait(0.05)
	local v2 = (targetPosition2 - clone2.Position).Magnitude / projectileSpeed
	TweenService:Create(clone2, TweenInfo.new(v2, Enum.EasingStyle.Linear), {
		Position = targetPosition2
	}):Play()
	task.wait(v2)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if data.HitMap or data.HitLimb then
		local clone3 = flintlock_M1.Impact:Clone()
		clone3.Position = targetPosition2
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	task.wait(4)
	folder:Destroy()
end