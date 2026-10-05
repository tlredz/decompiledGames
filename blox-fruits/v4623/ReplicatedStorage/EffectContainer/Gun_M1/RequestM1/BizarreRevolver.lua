local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponData"))
local v = WeaponData[script.Name]
local Sound = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Sound"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local bizarre_M1 = FX:WaitForChild("Gun_M1").Bizarre_M1
local laser = bizarre_M1.Laser
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

local function findTool(parent)
	for _, tool in pairs(parent:GetChildren()) do
		if tool:IsA("Tool") and tool.Name == "Bizarre Revolver" then
			return tool
		end
	end
end

local Util = require(game.ReplicatedStorage.Util)
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
	local tool = findTool(parent)
	local v2 = tool and tool:GetAttribute("LocalShotsLeft") == 1 and 2 or 1
	local folder = Instance.new("Folder")
	folder.Name = "GunM1Effect"
	folder.Parent = _WorldOrigin
	local cFrame = CFrame.lookAt(child and child.WorldPosition or HRP.Position, targetPosition) * CFrame.new(0, 0, -3)

	if parent == game.Players.LocalPlayer.Character then
		task.wait()
		task.wait()
	end

	if v2 == 1 then
		local clone = bizarre_M1.Shoot:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local fireSound = v.FireSound

		if fireSound then
			Sound:Play(fireSound .. tostring(math.random(1, 4)), clone.Position)
		end

		local targetPosition2 = data.TargetPosition
		local magnitude = (cFrame.Position - targetPosition2).Magnitude
		local cFrame2 = cFrame * CFrame.new(0, 0, -magnitude)
		local clone2 = bizarre_M1.PartBeam:Clone()
		clone2.Size = createVector(1, 1, 0)
		clone2.CFrame = cFrame
		clone2.FirstPart.CFrame = cFrame
		clone2.SecondPart.CFrame = cFrame
		clone2.Parent = folder
		TweenService:Create(clone2, TweenInfo.new(magnitude / projectileSpeed, Enum.EasingStyle.Linear), {
			Size = Vector3.new(1, 1, magnitude),
			CFrame = cFrame * CFrame.new(0, 0, -magnitude / 2)
		}):Play()
		TweenService:Create(clone2.SecondPart, TweenInfo.new(magnitude / projectileSpeed, Enum.EasingStyle.Linear), {
			CFrame = cFrame2
		}):Play()
		task.wait(magnitude / projectileSpeed)
		TweenService:Create(
			clone2.FirstPart,
			TweenInfo.new(magnitude / projectileSpeed + 0.1, Enum.EasingStyle.Linear),
			{
				CFrame = cFrame2
			}
		):Play()

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		for _, descendant in clone2:GetDescendants() do
			if descendant:IsA("Beam") then
				TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextureSpeed = 1.5
				}):Play()
				local v5 = descendant
				task.delay(0.2, function()
					TweenService:Create(v5, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			elseif descendant:IsA("Attachment") then
				TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = createVector(0, 0, 0)
				}):Play()
			end
		end

		if data.HitLimb or data.HitMap then
			local clone3 = bizarre_M1.Impact:Clone()
			clone3.CFrame = cFrame2
			clone3.Parent = folder

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.wait(0.1)
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(0.3)
		local clone3 = bizarre_M1.ShotSpark:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(5)
		folder:Destroy()
	else
		local targetPosition2 = data.TargetPosition
		local magnitude = (cFrame.Position - targetPosition2).Magnitude
		local _ = cFrame * CFrame.new(0, 0, -magnitude)
		local clone = laser.PartBeam:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, -magnitude / 2)
		clone.Size = Vector3.new(2, 2, magnitude)
		local part1 = clone.Part1
		local part2 = clone.Part2
		part1.Position = cFrame.Position
		part2.Position = targetPosition2
		local clone2 = laser.ApearBeam:Clone()
		clone2.Position = part1.Position
		clone2.Parent = folder
		local beamPart2 = clone2.BeamPart2
		beamPart2.Position = part2.Position
		beamPart2.Parent = folder

		for _, beam in clone2.Beams:GetChildren() do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0,
					CurveSize0 = 0,
					CurveSize1 = 0
				}):Play()
			end
		end

		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if v.FireSound then
			Sound:Play("BF_WPN_M1_Click_Fire_3RdShot_01", cFrame.Position)
		end

		for _, beam in part1:GetChildren() do
			if not beam:IsA("Beam") then
				continue
			end

			TweenService:Create(beam, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				TextureSpeed = 0
			}):Play()
			local v4 = beam
			task.delay(0.2, function()
				TweenService:Create(v4, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
		end

		if data.HitMap or data.HitLimb then
			local rayMap, v4, v5 = Util.RayMap(cFrame.p, (targetPosition2 - cFrame.p) * 1.001)
			local clone3 = laser.Explode:Clone()

			if rayMap then
				clone3.CFrame = CFrame.lookAt(v4, v4 + v5)
			else
				clone3.CFrame = CFrame.new(targetPosition2)
				clone3.Attachment.Floor:Destroy()
			end

			clone3.Parent = folder

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Sound:Play("BF_WPN_M1_Click_Fire_3RdShot_Impact_01", clone3.Position)
		end

		local clone3 = laser.Shoot:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.delay(clone3.Activate1.Portal.Lifetime.Min, function()
			local clone4 = laser.Disapear:Clone()
			clone4.CFrame = clone3.CFrame
			clone4.Parent = folder

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		task.wait(0.4)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(5)
		folder:Destroy()
	end
end