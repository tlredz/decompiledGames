local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local C = FX:WaitForChild("Rocket").C
local _WorldOrigin = workspace._WorldOrigin
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local Util = require(game.ReplicatedStorage.Util)

local function DeleteImpactAfterDuration(folder)
	local v = 0

	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local max = emitter.Lifetime.Max
		v = math.max(v, max)
	end

	task.spawn(function()
		task.wait(v)
		folder:Destroy()
	end)
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function GroundRocks(cframe, folder, _, instance)
	for _ = 1, 5 do
		task.spawn(function()
			local clone = C.Rock:Clone()
			clone.Position = cframe.Position + Vector3.new(
				math.random(-25, 25) * 1.5,
				math.random(1, 15),
				math.random(-25, 25) * 1.5
			)
			clone.Size = Vector3.new(math.random(2, 5), math.random(3, 5) / 2, math.random(2, 5))
			clone.Material = instance.Material
			clone.Color = instance.Color
			clone.Parent = folder
			rocks:ApplyCollision(clone, nil, true)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.P = 3000
			bodyVelocity.Parent = clone
			bodyVelocity.Velocity = CFrame.new(
				clone.Position,
				(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					0,
					-30
				)).Position + Vector3.new(math.random(-10, 10) / 5, math.random(80, 250), math.random(-10, 10) / 5)
			).LookVector * math.random(70, 100) * 1
			task.delay(0.075, function()
				bodyVelocity:Destroy()
			end)
			clone.Attachment0.Orientation = Vector3.new(
				math.random(-90, 90),
				math.random(-90, 90),
				math.random(-90, 90)
			)
			local v = math.random(60, 120)
			local v2 = math.random(60, 120)
			local v3 = math.random(60, 120)
			local v4 = v / 10
			local v5 = v2 / 10
			local v6 = v3 / 10

			for _ = 1, 6 do
				v = math.clamp(v - v4, 0, 120)
				v2 = math.clamp(v2 - v5, 0, 120)
				v3 = math.clamp(v3 - v6, 0, 120)
				local tween = TweenService:Create(
					clone.Attachment0,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.Attachment0.CFrame * CFrame.Angles(math.rad(v), math.rad(v2), (math.rad(v3)))
					}
				)
				tween:Play()
				tween.Completed:Wait()
				tween:Destroy()
			end

			clone.AlignOrientation:Destroy()
			task.wait(3)
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
				{
					Size = createVector(0, 0, 0)
				}
			)
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end)
	end
end

return function(instance)
	local root = instance.Root
	local humanoid = instance.Humanoid
	local origin = instance.Origin
	local fireDir = instance.FireDir
	local mid = instance.Mid
	local goal = instance.Goal

	if localPlayer == game.Players:GetPlayerFromCharacter(instance.Root.Parent) then
		origin = root.Position
	end

	if (origin - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local filterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local cFrame = root.CFrame
	local cframe = CFrame.new(cFrame.Position, mid)
	root.CFrame = cframe
	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = false
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local cframe2 = CFrame.new(mid, mid + (mid - origin))
	TweenService:Create(root, TweenInfo.new(0.35), {
		CFrame = cframe2
	}):Play()
	local clone = C.Phase1.StartImpact:Clone()
	clone.CFrame = cframe
	clone.Parent = folder
	DeleteImpactAfterDuration(clone)

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

	local clone2 = C.Phase1.DashAura:Clone()
	clone2.CFrame = cframe
	clone2.Parent = folder
	clone2.Anchored = false
	clone2.Weld.Part0 = root

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	Util.Sound:Play("Phoenix1Appear", root, 15)
	task.wait(0.35)
	Util.Sound:Play("PhoenixKickStart", root, 15)
	local cframe3 = CFrame.new(mid, goal)
	root.CFrame = cframe3
	local v2 = math.min(3.5, root.Size.Y * 0.5 + humanoid.HipHeight)
	local cFrame2 = CFrame.new(goal, goal + (goal - mid)) + Vector3.new(0, v2, 0)
	local tween = TweenService:Create(root, TweenInfo.new(0.1), {
		CFrame = cFrame2
	})
	tween.Completed:Connect(function()
		root.CFrame = CFrame.new(goal, goal + fireDir * createVector(1, 0, 1)) + Vector3.new(0, v2, 0)

		if root.Parent == localPlayer.Character then
			root.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
	tween:Play()
	local clone3 = C.Phase1.DashImpact:Clone()
	clone3.CFrame = cframe3
	clone3.Parent = folder
	DeleteImpactAfterDuration(clone3)

	for _, emitter in pairs(clone3:GetDescendants()) do
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

	task.spawn(function()
		local raycastResult = workspace:Raycast(goal + createVector(0, 1, 0), createVector(-0, -30, -0), raycastParams)

		if raycastResult then
			local clone4 = C.Phase1.StartImpact2:Clone()
			clone4.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			clone4.Parent = folder

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	end)
	local clone4 = C.Phase1.DashTrail:Clone()
	clone4.CFrame = cframe3
	clone4.Parent = folder
	clone4.Anchored = false
	clone4.Weld.Part0 = root

	for _, effect in pairs(clone4:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local raycastResult = workspace:Raycast(goal + createVector(0, 1, 0), createVector(-0, -2, -0), raycastParams)

	if raycastResult then
		local v4 = Util.Sound:Play("BlackLegGround", raycastResult.Position, 20)
		local v5 = Util.Sound:Play("Ope.Explosion.SpikeDust", raycastResult.Position, 20)
		task.delay(0.5, function()
			Util.Sound:FadeOut(v4, 0.75)
			Util.Sound:FadeOut(v5, 0.75)
		end)
	end

	task.wait(0.1)

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	for _, effect in pairs(clone4:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	task.spawn(function()
		if raycastResult then
			local clone5 = C.Phase2.GroundImpact:Clone()
			clone5.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			clone5.Parent = folder

			if (raycastResult.Position - workspace.CurrentCamera.CFrame.p).Magnitude < 80 then
				Util.CameraShaker:ShakeOnce(10, 10, 0.2, 0.8)
			end

			DeleteImpactAfterDuration(clone5)

			for _, emitter in pairs(clone5:GetDescendants()) do
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

			local clone6 = C.Phase2.GroundImpact2:Clone()
			clone6.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			clone6.Parent = folder
			DeleteImpactAfterDuration(clone6)

			for _, emitter in pairs(clone6:GetDescendants()) do
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

			local clone7 = C.Phase2.GroundImpact3:Clone()
			clone7.CFrame = CFrame.new(raycastResult.Position, mid)
			clone7.Parent = folder

			for _, emitter in pairs(clone7:GetDescendants()) do
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

			local clone8 = C.Phase2.GroundImpact4:Clone()
			clone8.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			clone8.Parent = folder

			for _, emitter in pairs(clone8:GetDescendants()) do
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

			local clone9 = C.Phase2.GroundImpact5:Clone()
			clone9.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			clone9.Parent = folder
			DeleteImpactAfterDuration(clone9)

			for _, emitter in pairs(clone9:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			GroundRocks(CFrame.new(raycastResult.Position), folder, raycastResult.Position, raycastResult.Instance)
		end
	end)
	task.delay(5, function()
		folder:Destroy()
	end)
end