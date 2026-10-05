local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Gas").Transformed.M1.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

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

local function BasicSlash(folder)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
				task.wait(v2)
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)
		end
	end)
	local tween = TweenService:Create(
		folder.Weld,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
				-2.6179938779914944,
				0,
				0
			)
		}
	)
	tween:Play()
	tween.Completed:Wait()
	folder.Weld.Enabled = false
	folder.Anchored = true
	TweenService:Create(folder, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = folder.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
	}):Play()
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
Util.ResizeModel(assets.Phase1.Slash, 1.95)
Util.ResizeModel(assets.Phase1.SlashHit, 1.95)
Util.ResizeModel(assets.Phase2.Slash, 1.95)
Util.ResizeModel(assets.Phase2.SlashHit, 1.95)
Util.ResizeModel(assets.Phase2.GrabImpact, 1.95)
Util.ResizeModel(assets.Phase2.StartImpact, 1.95)
Util.ResizeModel(assets.Phase2.Explosion, 1.3)
Util.ResizeModel(assets.Phase2.ThrowImpact, 1.6)
return function(player)
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	local index = player.Index
	local cFrame = player.CFrame

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 900 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 5)
	local v = cFrame * CFrame.new(0, 0, -5)

	if index == 1 then
		local cframe = CFrame.Angles(0, 0, -1.3089969389957472)
		local cframe2 = CFrame.Angles(-3.490658503988659, 0, 0)
		local cFrame2 = v * cframe
		local cFrame3 = v * CFrame.new(0, 0, -70) * cframe
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder
		Util.Sound:Play("BF_GASFRUIT_TSFM_BasicSlashes_01", humanoidRootPart)

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

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = assets.Phase1.Slash:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * cframe * cframe2
		clone2.Anchored = false
		clone2.Weld.Part0 = humanoidRootPart
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame)
		clone2.Parent = folder
		BasicSlash(clone2)
		local clone3 = assets.Phase1.SlashHit:Clone()
		clone3.CFrame = cFrame3
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
	elseif index == 2 then
		local cframe = CFrame.Angles(0, 0, 1.3962634015954636)
		local cframe2 = CFrame.Angles(-3.9269908169872414, 0, 0)
		local cFrame2 = v * cframe
		local cFrame3 = v * CFrame.new(0, 0, -70) * cframe
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder
		Util.Sound:Play("BF_GASFRUIT_TSFM_BasicSlashes_02", humanoidRootPart)

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

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = assets.Phase1.Slash:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * cframe * cframe2
		clone2.Anchored = false
		clone2.Weld.Part0 = humanoidRootPart
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame)
		clone2.Parent = folder
		BasicSlash(clone2)
		local clone3 = assets.Phase1.SlashHit:Clone()
		clone3.CFrame = cFrame3
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
	elseif index == 3 then
		local cframe = CFrame.Angles(0, 0, -2.2689280275926285)
		local cframe2 = CFrame.Angles(-3.490658503988659, 0, 0)
		local cFrame2 = v * cframe
		local cFrame3 = v * CFrame.new(0, 0, -70) * cframe
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder
		Util.Sound:Play("BF_GASFRUIT_TSFM_BasicSlashes_03", humanoidRootPart)

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

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = assets.Phase1.Slash:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * cframe * cframe2
		clone2.Anchored = false
		clone2.Weld.Part0 = humanoidRootPart
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame)
		clone2.Parent = folder
		BasicSlash(clone2)
		local clone3 = assets.Phase1.SlashHit:Clone()
		clone3.CFrame = cFrame3
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
	elseif index == 4 then
		local cframe = CFrame.Angles(0, 0, 1.7453292519943295)
		local cframe2 = CFrame.Angles(-3.490658503988659, 0, 0)
		local cFrame2 = v * cframe
		local cFrame3 = v * CFrame.new(0, 0, -70) * cframe
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder
		Util.Sound:Play("BF_GASFRUIT_TSFM_BasicSlashes_04", humanoidRootPart)

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

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = assets.Phase1.Slash:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * cframe * cframe2
		clone2.Anchored = false
		clone2.Weld.Part0 = humanoidRootPart
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame)
		clone2.Parent = folder
		BasicSlash(clone2)
		local clone3 = assets.Phase1.SlashHit:Clone()
		clone3.CFrame = cFrame3
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
	elseif index == 5 then
		task.spawn(function()
			local cframe = CFrame.Angles(0, 0, 0.8726646259971648)
			local cframe2 = CFrame.Angles(-2.6179938779914944, 0, 0)
			local cFrame2 = v * cframe
			local cFrame3 = v * CFrame.new(0, 0, -70) * cframe
			local clone = assets.Phase2.StartImpact:Clone()
			clone.CFrame = cFrame2
			clone.Parent = folder
			Util.Sound:Play("BF_GASFRUIT_TSFM_Slash5_ExplosiveGas_02", humanoidRootPart)

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

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			local clone2 = assets.Phase2.Slash:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * cframe * cframe2
			clone2.Anchored = false
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame)
			clone2.Parent = folder
			BasicSlash(clone2)
			local clone3 = assets.Phase2.SlashHit:Clone()
			clone3.CFrame = cFrame3
			clone3.Parent = folder

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		end)
		task.wait(0.25)
		v = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
		local cFrame4 = v * CFrame.new(0, 0, -70)
		local clone = assets.Phase2.GrabImpact:Clone()
		clone.CFrame = cFrame4
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		task.wait(0.25)
		v = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
		local cFrame5 = v * CFrame.new(0, 0, -70)
		local clone2 = assets.Phase2.Explosion:Clone()
		clone2.CFrame = cFrame5
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		task.wait(0.1)
		v = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
		local cFrame6 = v * CFrame.new(0, 0, -70)
		local clone3 = assets.Phase2.ThrowImpact:Clone()
		clone3.CFrame = cFrame6
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
	end
end