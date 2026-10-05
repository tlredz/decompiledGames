game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Raycast = require(ReplicatedStorage:WaitForChild("Modules").World.Raycast)
local CombatUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CombatUtil"))
local WeaponData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponData"))
local v = WeaponData[script.Name]
local Sound = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("Sound"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local magmaM1 = FX:WaitForChild("MagmaGun").MagmaM1
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local RunService = game:GetService("RunService")
local v2 = RunService:IsStudio() and false
local currentCamera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

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
	if (currentCamera.CFrame.p - data.origin).Magnitude > 800 then
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

	local worldPosition = child.WorldPosition or data.origin
	local cframe = CFrame.lookAt(worldPosition, data.TargetPosition)
	local parent = HRP.Parent
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { _WorldOrigin, parent }
	local folder = Instance.new("Folder")
	folder.Name = "EffectsFolder"
	folder.Parent = _WorldOrigin
	local clone = magmaM1.Shot:Clone()
	clone.CFrame = cframe
	clone.Parent = folder
	local fireSound = v.FireSound

	if fireSound then
		Sound:Play("Guns." .. fireSound, clone.Position)
	end

	task.spawn(ParticleState, clone)
	task.spawn(function()
		local v3 = data.Angles ~= nil
		local angles = data.Angles or CombatUtil:CreateShootAngles({
			BulletSpreadCount = v.BulletSpreadCount,
			BulletSpreadDegree = v.BulletSpreadDegree,
			Range = v.Range,
			Origin = worldPosition,
			TargetPosition = CombatUtil:GetTargetPosition(HRP.Position, data.TargetPosition, v.Range),
			Seed = data.Seed
		})

		for i = 1, #angles do
			local v4 = cframe * angles[i].Angle
			local direction = (v4 * CFrame.new(0, 0, -v.Range)).Position - v4.Position
			local raycast = Raycast({
				visualize = v2 and {
					lineColor = v3 and Color3.fromRGB(0, 255, 21) or Color3.fromRGB(255, 0, 4),
					lineExpires = 3
				},
				raycastParams = raycastParams,
				origin = v4,
				direction = direction
			})
			local position

			if raycast then
				position = raycast.Position
			else
				position = v4.Position + direction
			end

			local clone2 = magmaM1.Projectile:Clone()
			clone2.CFrame = v4
			clone2.Parent = folder
			local v7 = (position - v4.Position).Magnitude / data.ProjectileSpeed
			TweenService:Create(clone2, TweenInfo.new(v7, Enum.EasingStyle.Linear), {
				Position = position
			}):Play()
			task.delay(v7, function()
				local folder2 = clone2

				for i2, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				if raycast then
					local clone3 = magmaM1.Hit:Clone()
					clone3.Position = clone2.Position
					clone3.Parent = folder

					for i2, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end
			end)
		end
	end)
	task.delay(4, function()
		folder:Destroy()
	end)
end