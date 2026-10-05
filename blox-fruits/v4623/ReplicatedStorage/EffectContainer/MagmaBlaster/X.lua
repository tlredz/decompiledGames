local Players = game:GetService("Players")
Players = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local magmaGunX = FX:WaitForChild("MagmaGun").MagmaGunX
require(ReplicatedStorage:WaitForChild("Effect"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			if emitter:GetAttribute("Color") == true then
				if p then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		else
			emitter.Enabled = enabled
		end
	end
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local random = Random.new()
return function(player)
	local shootPos = player.ShootPos
	local root = player.Root
	local distance = player.Distance
	local _ = player.Closest

	if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local mousePos = player.MousePos
	local duration = player.Duration
	local holding = player.Holding
	local equippedAttachment = Util.GetEquippedAttachment(player.Character, player.Attachment)
	local worldPosition

	if equippedAttachment then
		worldPosition = equippedAttachment.WorldPosition
	elseif shootPos then
		worldPosition = shootPos.WorldPosition
	else
		worldPosition = root.Position
	end

	local folder = Instance.new("Folder")
	folder.Name = "EffectsFolder"
	folder.Parent = workspace._WorldOrigin
	local clone = magmaGunX.BlazeStart:Clone()
	clone.CFrame = CFrame.lookAt(worldPosition, mousePos.Value) * CFrame.new(0, 0, -1)
	clone.Parent = folder
	Util.Sound:Play("BF_WPN_RefMusket_FlamethrowerActivate_01_V2", root.Position)
	local v = Util.Sound:Play("BF_WPN_RefMusket_MagmaticPressure_01", root.Position)
	TweenService:Create(v, TweenInfo.new(0.2), {
		Volume = 1
	}):Play()
	local lastTime = tick()

	while true do
		task.spawn(function()
			local worldPosition2

			if equippedAttachment then
				worldPosition2 = equippedAttachment.WorldPosition
			elseif shootPos then
				worldPosition2 = shootPos.WorldPosition
			else
				worldPosition2 = root.Position
			end

			worldPosition = worldPosition2
			local cFrame = CFrame.lookAt(worldPosition, mousePos.Value) * CFrame.new(0, 0, -3) * CFrame.Angles(
				math.rad((random:NextNumber(-8, 8))),
				math.rad((random:NextNumber(-8, 8))),
				0
			)
			local raycastResult = workspace:Raycast(cFrame.Position, cFrame.LookVector * distance, raycastParams)
			local value = mousePos.Value

			if distance <= (value - cFrame.Position).Magnitude then
				value = cFrame.Position + cFrame.LookVector * distance
			end

			local clone2 = magmaGunX.Start:Clone()
			local clone3 = magmaGunX.End:Clone()
			clone2.CFrame = cFrame
			clone3.CFrame = cFrame
			clone2.Parent = folder
			clone3.Parent = folder
			local clone4 = magmaGunX.BeamParticles:Clone()
			clone4.CFrame = cFrame
			clone4.Parent = folder
			local cframe = raycastResult and CFrame.lookAt(
				raycastResult.Position,
				raycastResult.Position + raycastResult.Normal
			) or CFrame.lookAt(value, cFrame.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			local magnitude2 = (cframe.Position - cFrame.Position).Magnitude
			TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = cFrame * CFrame.new(0, 0, -magnitude2 / 2),
				Size = clone4.Size + Vector3.new(0, 0, magnitude2)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = cframe
			}):Play()

			for _, beam in clone2:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Attachment0 = clone2.a
				beam.Attachment1 = clone3.b
				TweenService:Create(beam, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end

			task.spawn(function()
				for _ = 1, 3 do
					task.spawn(function()
						local clone5 = magmaGunX.Trail:Clone()
						local position = cFrame.Position
						local position2 = cFrame.Position
						local v3 = position2 + (cframe.Position - position2) * 0.3 + Vector3.new(
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20)
						)
						local position3 = cFrame.Position
						local v4 = position3 + (cframe.Position - position3) * 0.6 + Vector3.new(
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20)
						)
						local position4 = cframe.Position
						clone5.Position = position
						clone5.Parent = folder
						local lastTime2 = tick()

						while tick() - lastTime2 < 0.15 do
							local v5 = (tick() - lastTime2) / 0.15
							local v6 = position + (v3 - position) * v5
							local v7 = v3 + (v4 - v3) * v5
							local v8 = v4 + (position4 - v4) * v5
							local v9 = v6 + (v7 - v6) * v5
							clone5.Position = v9 + (v7 + (v8 - v7) * v5 - v9) * v5
							task.wait()
						end

						clone5.Position = position4
					end)
				end
			end)
			task.wait(0.15)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(0.05)

			if raycastResult then
				local clone5 = magmaGunX.FloorExplosion:Clone()
				clone5.CFrame = cframe
				clone5.Parent = folder
				ParticleState(clone5)
				Util.Sound:Play(
					"BF_WPN_Magmatic_Pressure_Wall_Hit_0" .. tostring(math.random(1, 10)) .. "_V3",
					cframe.Position,
					nil,
					math.random(10, 12) / 10
				)
			else
				local clone5 = magmaGunX.Explosion:Clone()
				clone5.CFrame = cframe
				clone5.Parent = folder
				ParticleState(clone5)
			end
		end)

		if equippedAttachment then
			worldPosition = equippedAttachment.WorldPosition
		elseif shootPos then
			worldPosition = shootPos.WorldPosition
		else
			worldPosition = root.Position
		end

		clone.CFrame = CFrame.lookAt(worldPosition, mousePos.Value) * CFrame.new(0, 0, -1)
		task.wait(0.1)

		if not (tick() - lastTime > 0.5 and (not holding:IsDescendantOf(workspace) or holding.Value == false or duration < tick() - lastTime)) then
			continue
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(3)
		folder:Destroy()
		break
	end
end