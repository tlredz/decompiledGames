local createVector = vector.create
local _ = game.Players.LocalPlayer
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local phase1 = FX:WaitForChild("Rocket").Z.Phase1
local _WorldOrigin = workspace._WorldOrigin
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

return function(data)
	local root = data.Root
	local position = data.Position

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	if data.Holding then
		local holding = data.Holding
		local clone = phase1.Rocket:Clone()
		clone.Size *= 0.8
		clone.Anchored = false
		clone.CFrame = root.Parent.RightHand.CFrame
		local weld = Instance.new("Weld", clone)
		weld.Part0 = clone
		weld.Part1 = root.Parent.RightHand
		weld.C0 = CFrame.new(0, 0, 1.2) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = root.Parent
		TweenService:Create(clone, TweenInfo.new(0.1), {
			Size = clone.Size * 2
		}):Play()

		while holding:IsDescendantOf(workspace) and holding.Value do
			wait()
		end

		task.wait(0.07)
		clone:Destroy()
	else
		Util.Sound:Play("Mera_FireFlies_Launch", root.Position)
		local cFrame = CFrame.new(root.Position, position) * CFrame.new(0, 0, -3)
		local magnitude = (position - root.Position).Magnitude
		local v2 = magnitude / 250
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		local clone = phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		DeleteImpactAfterDuration(clone)

		for _, emitter in pairs(clone:GetDescendants()) do
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

		local clone2 = phase1.Projectile:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local raycastParams = RaycastParams.new()
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local ray = Ray.new(
			cFrame.Position,
			CFrame.new(cFrame.Position, cFrame * CFrame.new(0, 0, -magnitude).Position).LookVector * magnitude
		)
		local _, v4 = workspace:FindPartOnRayWithIgnoreList(
			ray,
			{ workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		)
		local magnitude2 = (cFrame.Position - v4).Magnitude
		local cFrame2 = clone2.CFrame * CFrame.new(0, 0, -magnitude2)
		local clone3 = phase1.StartImpact2:Clone()
		clone3.CFrame = cFrame2
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local v6 = magnitude2 / magnitude * v2
		local clone4 = phase1.Rocket:Clone()
		clone4.Size *= 1.8
		clone4.CFrame = cFrame * CFrame.new(0, 0, -3)
		clone4.Parent = folder
		local tween = TweenService:Create(
			clone4,
			TweenInfo.new(v6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = cFrame2 * CFrame.new(0, 0, -3)
			}
		)
		tween.Completed:Connect(function()
			clone4:Destroy()
		end)
		tween:Play()
		local tween2 = TweenService:Create(
			clone2,
			TweenInfo.new(v6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = cFrame2
			}
		)
		tween2:Play()
		tween2.Completed:Wait()

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Util.Sound:Play("Explosion2", clone2.CFrame, 20)

		if (clone2.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude < 80 then
			Util.CameraShaker:ShakeOnce(10, 10, 0.2, 0.8)
		end

		local clone5 = phase1.Explosion:Clone()
		clone5.CFrame = clone2.CFrame
		clone5.Parent = folder
		DeleteImpactAfterDuration(clone5)

		for _, emitter in pairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			coroutine.wrap(function()
				if v7:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v7:GetAttribute("EmitDelay"))
				end

				v7:Emit(v7:GetAttribute("EmitCount"))
			end)()
		end

		task.spawn(function()
			local raycastResult = workspace:Raycast(
				clone5.Position + createVector(0, 1, 0),
				CFrame.new(clone5.Position).UpVector * -15,
				raycastParams
			)

			if raycastResult then
				local clone6 = phase1.GroundImpact:Clone()
				clone6.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
				clone6.Parent = folder
				DeleteImpactAfterDuration(clone6)

				for _, emitter in pairs(clone6:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end
		end)
		task.delay(15, function()
			folder:Destroy()
		end)
	end
end