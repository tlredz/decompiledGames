local createVector = vector.create
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { workspace.Map }
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local Util = require(game.ReplicatedStorage.Util)
return function(player)
	local humanoidRootPart = player.Character.HumanoidRootPart

	if player.Hold then
		if (humanoidRootPart.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		Util.Sound:Play("GroundCrash", humanoidRootPart)
		local clone = script.Rock:Clone()
		clone.Name = "RockGravF"

		if player.Hit then
			clone.Color = player.Hit.Color
			clone.Material = player.Hit.Material
		end

		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -4.5, 0)
		clone.Orientation += createVector(-90, 180, 0)
		clone.Parent = humanoidRootPart
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "Rockholdthweggg"
		weldConstraint.Parent = humanoidRootPart
		weldConstraint.Part0 = humanoidRootPart
		weldConstraint.Part1 = clone
		local clone2 = script.Part:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
		clone2.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(clone2, 2)
		local raycastResult = workspace:Raycast(
			clone2.CFrame * CFrame.new(0, 0, 0).Position,
			createVector(0, -15, 0),
			raycastParams
		)

		if raycastResult then
			local instance = raycastResult.Instance
			local position = raycastResult.Position
			local clone3 = script.Smoke_tang_ting_kaboom:Clone()
			clone3.CFrame = CFrame.new(position)
			clone3.Orientation += createVector(0, -180, 0)
			clone.Color = instance.Color
			clone.Material = instance.Material
			clone3.Grass2.Color = ColorSequence.new(instance.Color)
			clone3.Smoke.Color = ColorSequence.new(instance.Color)
			clone3.Parent = workspace._WorldOrigin
			clone3.Smoke:Emit(12)
			clone3.Grass2:Emit(12)
			Util.Debris:AddItem(clone3, 3)
		end
	else
		if humanoidRootPart:FindFirstChild("RockGravF") then
			local rockGravF = humanoidRootPart.RockGravF
			Util.Sound:Play("SetFire", humanoidRootPart)
			TweenService:Create(rockGravF, tweenInfo, {
				Size = createVector(0, 0, 0)
			}):Play()

			for _, emitter in pairs(rockGravF:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.delay(0.8, function()
				rockGravF:Destroy()
			end)
		end

		if humanoidRootPart:FindFirstChild("Rockholdthweggg") then
			humanoidRootPart.Rockholdthweggg:Destroy()
		end
	end
end