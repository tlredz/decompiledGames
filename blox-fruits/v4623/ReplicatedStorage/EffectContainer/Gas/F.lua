local createVector = vector.create
local _WorldOrigin = workspace._WorldOrigin
local FX = require(game.ReplicatedStorage.FX)
local F = FX:WaitForChild("Gas").F
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
return function(data)
	local root = data.Root
	local hasTarget = data.HasTarget
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local cFrame = root.CFrame
	local emittersByEmitter = nil
	local clone = nil
	local renderSteppedConnection = nil
	local clone2 = nil

	if hasTarget then
		task.spawn(function()
			emittersByEmitter = {}
			clone2 = F.Extra.EnhanceDash:Clone()
			clone2.CFrame = root.CFrame
			clone2.Anchored = false
			clone2.Massless = true
			clone2.Weld.Part0 = root
			clone2.Parent = folder

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emittersByEmitter[emitter] = emitter
				emitter.Enabled = true
			end

			local currentCamera = workspace.CurrentCamera

			if game.Players.LocalPlayer.Character and root == game.Players.LocalPlayer.Character.HumanoidRootPart then
				clone = F.Extra.CameraFocus:Clone()
				clone.Parent = folder
				renderSteppedConnection = game["Run Service"].RenderStepped:Connect(function()
					clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
				end)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end
		end)
	end

	local clone3 = F.Phase1.Flight:Clone()
	clone3.CFrame = cFrame
	clone3.Parent = folder
	clone3.Anchored = false
	clone3.Weld.Part0 = root
	local v = Util.Sound:Play("BF_GASFRUIT_UNTR_TravelingGas_Flight_Loop_01", root)

	for _, effect in pairs(clone3:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local clone4 = F.Phase1.GroundGas:Clone()
	clone4.Parent = folder

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local lastTime = tick()
	local now = tick()
	local lastTime2 = tick()
	local v2 = false

	while true do
		local raycastResult

		if tick() - lastTime >= 0.5 then
			raycastResult = workspace:Raycast(root.Position, createVector(-0, -15, -0), raycastParams)
		end

		if raycastResult == nil then
			if v2 == true and tick() - lastTime >= 0.25 then
				v2 = false

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		elseif raycastResult then
			clone4.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.1

			if v2 == false then
				v2 = true

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end
		elseif v2 == true then
			v2 = false

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		if hasTarget then
			if tick() - lastTime2 > 1 or root.Parent:GetAttribute("GasFLoopBroken") then
				hasTarget = nil
			end

			if now - tick() <= 0 then
				now = tick() + 0.05

				for _, v3 in pairs(emittersByEmitter) do
					v3:Emit(1)
				end
			end
		else
			if emittersByEmitter ~= nil then
				for _, v3 in pairs(emittersByEmitter) do
					v3.Enabled = false
				end

				if clone then
					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				task.delay(1, function()
					if renderSteppedConnection then
						renderSteppedConnection:Disconnect()
					end

					if clone then
						clone:Destroy()
					end
				end)

				for _, effect in pairs(clone2:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end

				emittersByEmitter = nil
			end

			if not data.Holding or not data.Holding:IsDescendantOf(workspace) or data.Holding.Value == false then
				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				clone3.Weld.Enabled = false
				clone3.Anchored = true

				if v then
					Util.Sound:FadeOut(v, 0.2)
				end

				for _, effect in pairs(clone3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				if emittersByEmitter ~= nil then
					for _, v3 in pairs(emittersByEmitter) do
						v3.Enabled = false
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.delay(1, function()
						renderSteppedConnection:Disconnect()
						clone:Destroy()
					end)

					for _, effect in pairs(clone2:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
							continue
						end

						effect.Enabled = false
					end
				end

				task.delay(4, function()
					folder:Destroy()
				end)
				break
			end
		end

		task.wait()
	end
end