local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Gas").Passive.Assets
local _ = workspace._WorldOrigin
game:GetService("TweenService")
game:GetService("RunService")
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace._WorldOrigin, workspace.Enemies }
return function(player)
	local character = player.Character
	local v = player.Backpack == nil
	local folder = Instance.new("Folder")
	folder.Parent = workspace._WorldOrigin
	local humanoidRootPart = character.HumanoidRootPart
	local cFrame = humanoidRootPart.CFrame
	local clone = assets.Phase1.GasAura:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	clone.Anchored = false
	local weldConstraint = clone.WeldConstraint
	weldConstraint.Part1 = humanoidRootPart
	local flag = true

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local clone2 = assets.Phase1.GroundGas:Clone()
	clone2.Parent = folder
	local emittersByEmitter = {}

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emittersByEmitter[emitter] = emitter
		emitter.Enabled = false
	end

	local v2 = Sound:Play("BF_GASFRUIT_Untransformed_Idle_01", humanoidRootPart)
	local v3 = false

	while (v or player.Backpack) and (v or player.Backpack:FindFirstChild("Gas-Gas") or character:FindFirstChild("Gas-Gas")) and humanoidRootPart:IsDescendantOf(workspace) do
		local v4 = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000

		if character:FindFirstChild("GasRig") then
			v4 = true

			if flag then
				if v2 then
					Sound:FadeOut(v2, 0.3)
					v2 = nil
				end

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			flag = false
		else
			if not flag then
				v2 = v2 or Sound:Play("BF_GASFRUIT_Untransformed_Idle_01", humanoidRootPart)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end

			flag = true
		end

		local raycastResult

		if v4 == false then
			raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 1, 0),
				createVector(-0, -5, -0),
				raycastParams
			)
		else
			raycastResult = false
		end

		if raycastResult then
			clone2.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.1
			clone2.CFrame *= CFrame.new(0, clone2.Size.Y / 2, 0)

			if v3 == false then
				v3 = true

				for _, v5 in pairs(emittersByEmitter) do
					v5.Enabled = true
				end
			end
		elseif v3 == true then
			v3 = false

			for _, v5 in pairs(emittersByEmitter) do
				v5.Enabled = false
			end
		end

		task.wait(0.07)
	end

	for _, v4 in pairs(emittersByEmitter) do
		v4.Enabled = false
	end

	weldConstraint.Enabled = false
	clone.Anchored = true

	if v2 then
		Sound:FadeOut(v2, 0.3)
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.wait(3)
	folder:Destroy()
end