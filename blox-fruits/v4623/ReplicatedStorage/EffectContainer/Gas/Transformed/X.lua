local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Gas").Transformed.X.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function FireBeam(state, clone, clone2)
	local startCFrame = state.StartCFrame
	local beamBody2 = clone2.BeamBody2
	local position = startCFrame.Position
	local position2 = nil

	if state.TargetPart and state.TargetPart.Parent then
		position2 = state.TargetPart.Position
	elseif typeof(state.TargetPos) == "Vector3" then
		position2 = state.TargetPos
	end

	local lookVector

	if position2 then
		local v = position2 - position
		local magnitude = v.Magnitude

		if magnitude < 0.001 then
			lookVector = startCFrame.LookVector
			position2 = position + lookVector * (state.BeamRange or 5000)
		else
			lookVector = v / magnitude
		end
	else
		lookVector = startCFrame.LookVector
		local ray = Ray.new(position, lookVector * state.BeamRange)
		local _, v = workspace:FindPartOnRayWithIgnoreList(
			ray,
			{ workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		)
		position2 = v or position + lookVector * state.BeamRange
		local v2 = position2 - position
		local magnitude = v2.Magnitude

		if magnitude > 0.001 then
			lookVector = v2 / magnitude
		end
	end

	local magnitude = (position - position2).Magnitude

	if state.IsBoss == true then
		local bossTweenTime = state.BossTweenTime or 0.25
		local cframe = CFrame.new(position2, position2 + lookVector)
		local cFrame = CFrame.new(position, position2) * CFrame.new(0, 0, -magnitude / 3)
		local vector2 = Vector3.new(clone2.Size.X, clone2.Size.Y, magnitude / 1.3)
		local vector3 = Vector3.new(beamBody2.Size.X, beamBody2.Size.Y, magnitude / 1.3)
		TweenService:Create(
			clone.BeamEnd,
			TweenInfo.new(bossTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = cframe
			}
		):Play()
		TweenService:Create(clone2, TweenInfo.new(bossTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = vector2,
			CFrame = cFrame
		}):Play()
		TweenService:Create(
			beamBody2,
			TweenInfo.new(bossTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				Size = vector3,
				CFrame = cFrame
			}
		):Play()
	elseif state.ExplosionCFrame == nil then
		TweenService:Create(clone.BeamEnd, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(position2, position2 + lookVector)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = Vector3.new(clone2.Size.X, clone2.Size.Y, magnitude / 1.3),
			CFrame = CFrame.new(position, position2) * CFrame.new(0, 0, -magnitude / 3)
		}):Play()
		TweenService:Create(beamBody2, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = Vector3.new(beamBody2.Size.X, beamBody2.Size.Y, magnitude / 1.3),
			CFrame = CFrame.new(position, position2) * CFrame.new(0, 0, -magnitude / 3)
		}):Play()
	else
		TweenService:Create(clone.BeamEnd, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(position2, position2 + lookVector)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = Vector3.new(clone2.Size.X, clone2.Size.Y, magnitude / 1.3),
			CFrame = CFrame.new(position, position2) * CFrame.new(0, 0, -magnitude / 3)
		}):Play()
		TweenService:Create(beamBody2, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = Vector3.new(beamBody2.Size.X, beamBody2.Size.Y, magnitude / 1.3),
			CFrame = CFrame.new(position, position2) * CFrame.new(0, 0, -magnitude / 3)
		}):Play()
	end

	state.LastEndCFrame = CFrame.new(position, position2)
	state.ExplosionCFrame = CFrame.new(position2, position) * CFrame.new(0, 0, -(10 + math.random(0, 10)))
end

local function BeamExplosion(state, head, p)
	local v

	if state.IsBoss == true then
		v = state.TargetPart ~= nil
	else
		v = false
	end

	if v then
		local bossLaserExplosion = state.BossLaserExplosion

		if not (bossLaserExplosion and bossLaserExplosion.Parent) then
			bossLaserExplosion = assets.Phase2.Explosion:Clone()
			bossLaserExplosion.Parent = state.SkillVisuals
			state.BossLaserExplosion = bossLaserExplosion

			for _, emitter in ipairs(bossLaserExplosion:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local hit = Util.CameraShaker.Presets.Hit

			if type(hit) == "function" then
				hit = hit()
			end

			state.BossLaserShakeInstance = Util.CameraShaker:ShakeSustain(hit, 1)
			local holdTime = state.HoldTime or 0

			if holdTime > 0 then
				task.delay(holdTime + 0.1, function()
					if state.BossLaserShakeInstance then
						state.BossLaserShakeInstance:StartFadeOut(0.4)
						state.BossLaserShakeInstance = nil
					end

					local bossLaserExplosion2 = state.BossLaserExplosion

					if bossLaserExplosion2 and bossLaserExplosion2.Parent then
						for _, emitter in ipairs(bossLaserExplosion2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end
				end)
			end
		end

		bossLaserExplosion.CFrame = state.ExplosionCFrame

		if p then
			if state.BossLaserShakeInstance then
				pcall(function()
					state.BossLaserShakeInstance:StartFadeOut(0.4)
				end)
				state.BossLaserShakeInstance = nil
			end

			if state.BossLaserExplosion and state.BossLaserExplosion.Parent then
				for _, emitter in ipairs(state.BossLaserExplosion:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end
	else
		local clone = assets.Phase2.Explosion:Clone()
		clone.CFrame = state.ExplosionCFrame
		clone.Parent = state.SkillVisuals
		task.spawn(function()
			task.wait(0.15)

			if head:IsDescendantOf(game.Players.LocalPlayer.Character) or (workspace.CurrentCamera.CFrame.p - state.ExplosionCFrame.p).Magnitude < 200 then
				Util.CameraShaker:ShakeOnce(8, 10, 0.1, 0.6)
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end
		end)
	end
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
return function(data)
	local root = data.Root
	local range = data.Range or 150

	if (root.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 1100 then
		return
	end

	local head = data.RigRoot.Root.LowerTorso.UpperTorso.Head
	local _ = head.WorldCFrame
	local boss = data.Boss
	local holdTime = data.HoldTime
	local v = (root.CFrame.Rotation + head.WorldPosition) * CFrame.Angles(-0.4363323129985824, 0, 0)

	if data.Holding then
		Util.Sound:Play("BF_GASFRUIT_TSFM_BursingVapor_ChargeStart_01", root)
		local v2 = Util.Sound:Play("BF_GASFRUIT_TSFM_BurstingVapor_ChargeLoop_01", root)
		TweenService:Create(v2, TweenInfo.new(0.8), {
			Volume = 1
		}):Play()

		repeat
			task.wait()
		until not (data.Holding:IsDescendantOf(workspace) and data.Holding.Value)

		Util.Sound:FadeOut(v2, 0.2)
	else
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin

		if boss then
			Util.Debris:AddItem(folder, holdTime + 1)
		else
			Util.Debris:AddItem(folder, 7)
		end

		local v2 = v * CFrame.Angles(0, -1.5707963267948966, 0)
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = v2
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		Util.Sound:Play("BF_GASFRUIT_TSFM_BurstingVapor_Release_01", root)
		task.wait(0.05)
		local clone2 = assets.Phase1.BeamStart:Clone()
		clone2.CFrame = v2
		clone2.BeamEnd.CFrame = v2
		clone2.Parent = folder
		local numberValue = Instance.new("NumberValue")
		local spinStart, spinEnd, spinDuration

		if boss then
			spinStart = data.SpinStart or -70
			spinEnd = data.SpinEnd or 90
			spinDuration = data.SpinDuration or 0.7
		else
			spinStart = -70
			spinDuration = 0.3
			spinEnd = 90
		end

		numberValue.Value = spinStart
		numberValue.Parent = folder
		local flag = true
		task.spawn(function()
			while flag do
				clone2.CFrame = (root.CFrame.Rotation + head.WorldPosition) * CFrame.Angles(
					0,
					math.rad(numberValue.Value),
					0
				)
				task.wait()
			end
		end)
		local clone3 = assets.Phase1.BeamBody:Clone()
		clone3.CFrame = v2
		clone3.BeamBody2.CFrame = v2
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v3 = {
			StartCFrame = v2,
			BeamRange = range,
			IsBoss = boss,
			HoldTime = holdTime,
			SkillVisuals = folder,
			TargetPart = data.TargetPart,
			TargetPos = data.TargetPos,
			BossTweenTime = data.BossTweenTime
		}
		local clone4 = assets.Phase1.Slash:Clone()
		clone4.CFrame = v2
		clone4.Parent = folder

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				v4:Emit(v4:GetAttribute("EmitCount"))
			end)
		end

		FireBeam(v3, clone2, clone3)
		BeamExplosion(v3, head)
		task.spawn(function()
			task.wait(0.5)
			local raycastResult = workspace:Raycast(
				v2.Position + createVector(0, 1, 0),
				createVector(-0, -75, -0),
				raycastParams
			)

			if raycastResult then
				local cFrame = AlignCFrame(
					CFrame.new(createVector(0, 0, 0), v2.LookVector) + raycastResult.Position,
					raycastResult.Normal
				) + raycastResult.Normal * 0.1
				local clone5 = assets.Phase2.GroundBurn:Clone()
				clone5.CFrame = cFrame
				clone5.Parent = folder

				for _, emitter in pairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v6 = emitter
					task.spawn(function()
						if v6:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v6:GetAttribute("EmitDelay"))
						end

						v6:Emit(v6:GetAttribute("EmitCount"))
					end)
				end
			end
		end)
		task.wait(0.1)
		TweenService:Create(
			numberValue,
			TweenInfo.new(spinDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Value = spinEnd
			}
		):Play()
		local position = v3.ExplosionCFrame.Position
		local holdTime2 = not boss and 0.3 or holdTime or spinDuration + 0.2
		v3.HoldTime = holdTime2
		local v5 = tick() + holdTime2

		while true do
			v3.StartCFrame = (root.CFrame.Rotation + head.WorldPosition) * CFrame.Angles(
				0,
				math.rad(numberValue.Value),
				0
			)
			FireBeam(v3, clone2, clone3)

			if data.Boss and v3.TargetPart and (not v3.TargetPart.Parent or v3.TargetPart:GetAttribute("LaserCancelled")) then
				break
			end

			if v3.IsBoss and v3.TargetPart then
				BeamExplosion(v3, head)
			elseif not v3.IsBoss and (position - v3.ExplosionCFrame.Position).Magnitude > 30 then
				position = v3.ExplosionCFrame.Position
				BeamExplosion(v3, head)
			end

			task.wait(0.025)

			if v5 - tick() <= 0 then
				break
			end
		end

		if v3.IsBoss and v3.TargetPart then
			BeamExplosion(v3, head, true)
		end

		flag = false

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				TweenService:Create(effect, TweenInfo.new(0.5), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		task.wait(0.15)

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end
end