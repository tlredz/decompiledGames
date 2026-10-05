local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Blade").C.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

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

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function FireProjectile(folder, data, player)
	local clone = assets.Phase1.SpinModel:Clone()
	clone.PrimaryPart = clone.Spin
	local primaryPart = clone.PrimaryPart
	primaryPart.CFrame = data.StartCFrame * CFrame.Angles(0, 0, 1.5707963267948966)
	Util.SetParentOverrideWithColor(clone, folder, player, "BladeFruitVFXColor")
	primaryPart:SetAttribute("Active", true)
	local emittersByEmitter = {}

	for _, emitter in primaryPart:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emittersByEmitter[emitter] = emitter
		emitter.Enabled = true
	end

	local tween = TweenService:Create(
		primaryPart,
		TweenInfo.new(data.TimeToTravel, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			CFrame = data.EndCFrame * CFrame.Angles(0, 0, 1.5707963267948966)
		}
	)
	tween:Play()
	task.spawn(function()
		tween.Completed:Wait()
		task.spawn(function()
			local lastTime = tick()
			local v = 0.15 + data.TimeToTravel / 7

			while tick() - lastTime < v do
				clone:ScaleTo(1 + (tick() - lastTime) / v * 0.7)
				RunService.Heartbeat:Wait()
			end

			clone:ScaleTo(1.7)
		end)
		tween = TweenService:Create(primaryPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = data.EndCFrame * CFrame.Angles(0, 0, 1.5707963267948966)
		})
		tween:Play()
		local clone2 = assets.Phase1.ReturnAura:Clone()
		clone2.CFrame = primaryPart.CFrame
		clone2.Anchored = false
		clone2.WeldConstraint.Part1 = primaryPart
		Util.SetParentOverrideWithColor(clone2, folder, player, "BladeFruitVFXColor")
		task.wait(0.05)
		tween = TweenService:Create(primaryPart, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = data.EndCFrame * CFrame.new(0, 0, 25) * CFrame.Angles(0, 0, 1.5707963267948966)
		})
		tween:Play()
		task.wait(0.1)
		tween = TweenService:Create(
			primaryPart,
			TweenInfo.new(data.TimeToTravel / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = data.StartCFrame * CFrame.Angles(0, 0, 1.5707963267948966)
			}
		)
		tween:Play()
		task.wait(data.TimeToTravel / 3.5)
		primaryPart:SetAttribute("Active", false)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local clone2 = assets.Phase1.GroundSpark:Clone()
	clone2.CFrame = data.StartCFrame
	Util.SetParentOverrideWithColor(clone2, folder, player, "BladeFruitVFXColor")

	for _, trail in clone2:GetDescendants() do
		if trail:IsA("Trail") then
			trail.Color = Util.WrapColorSequenceConstructor(
				ColorSequence.new(trail.Color.Keypoints),
				player,
				"BladeFruitVFXColor"
			)
		end
	end

	local emittersByEmitter2 = {}

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emittersByEmitter2[emitter] = emitter
		end
	end

	local v = tick() + 0.05
	local v2 = tick() + 0.05

	while true do
		if v - tick() <= 0 then
			v = tick() + 0.05

			for _, v3 in pairs(emittersByEmitter) do
				v3:Emit(1)
			end
		end

		task.spawn(function()
			local raycastResult = workspace:Raycast(
				primaryPart.Position,
				primaryPart.CFrame.RightVector * -25,
				raycastParams
			)
			local lookVector = primaryPart.CFrame.LookVector

			if raycastResult then
				clone2.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
				clone2.CFrame = CFrame.new(clone2.Position, clone2.Position + lookVector)

				if v2 - tick() <= 0 then
					v2 = tick() + 0.025

					for _, v3 in pairs(emittersByEmitter2) do
						v3:Emit(v3:GetAttribute("EmitCount"))
					end
				end
			end
		end)
		clone.Slash.Weld.C0 = clone.Slash.Weld.C0 * CFrame.Angles(0, 0.2617993877991494, 0)
		RunService.Heartbeat:Wait()

		if primaryPart:GetAttribute("Active") == true then
			continue
		end

		for _, v3 in pairs(emittersByEmitter) do
			v3:Destroy()
		end

		emittersByEmitter2 = nil
		clone:Destroy()
		break
	end
end

require(script.Parent.Modules.CreateBlade)
return function(data)
	local root = data.Root
	local player = data.player

	if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 7)
	local cFrame = data.CFrame or root.CFrame

	if data.Stage == 2 then
		local clone = assets.Phase2.Dash:Clone()
		clone.CFrame = root.CFrame
		clone.Anchored = false
		clone.Weld.Part1 = root
		Util.SetParentOverrideWithColor(clone, folder, player, "BladeFruitVFXColor")
		local emittersByEmitter = {}

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emittersByEmitter[emitter] = emitter
			emitter.Enabled = true
		end

		local dashDuration = data.DashDuration
		task.spawn(function()
			local lastTime = tick()

			while true do
				for _, v in pairs(emittersByEmitter) do
					v:Emit(1)
				end

				task.wait(0.015)
				local v = tick() - lastTime

				if not (dashDuration * 0.9 <= v) then
					continue
				end

				for _, v2 in pairs(emittersByEmitter) do
					v2.Enabled = false
				end

				break
			end
		end)
		root.Anchored = true
		local endCFrame = data.EndCFrame
		local magnitude = (endCFrame.p - cFrame.p).Magnitude
		local lastTime = os.clock()

		while os.clock() - lastTime < dashDuration do
			local v = (os.clock() - lastTime) / dashDuration
			root.CFrame = endCFrame * CFrame.new(0, 0, magnitude * (1 - v ^ 0.8))
			RunService.PreSimulation:Wait()
		end

		root.CFrame = endCFrame
		root.Anchored = false
		local clone2 = assets.Phase2.CrossSlash:Clone()
		clone2.CFrame = root.CFrame * CFrame.new(0, 0, -3)
		Util.SetParentOverrideWithColor(clone2, folder, player, "BladeFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
	else
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "BladeFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		root.Anchored = true
		root.CFrame = cFrame
		task.delay(data.ProjectileDuration - 0.03333333333333333, function()
			root.Anchored = false
		end)
		Util.Sound:Play("Slice.SawShredderFire", root)
		FireProjectile(folder, {
			StartCFrame = cFrame,
			EndCFrame = cFrame * CFrame.new(0, 0, -data.Distance),
			TimeToTravel = data.ProjectileDuration
		}, player)
	end
end