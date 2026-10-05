local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local m1Outside = FX:WaitForChild("ControlRework").M1Outside

local function TweenScaleModel(clone, p: number, p2: number)
	if not clone.PrimaryPart then
		return
	end

	local scale = clone:GetScale()
	local v = scale * p
	local total = 0

	while total < p2 do
		total += RunService.Heartbeat:Wait()
		local v2 = math.clamp(total / p2, 0, 1)
		clone:ScaleTo(scale + (v - scale) * v2)
	end

	clone:ScaleTo(v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder, _)
	task.spawn(function()
		if not folder then
			return
		end

		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		local v2 = v <= 0 and 0.25 or v
		task.wait(v2)

		if folder and folder.Parent then
			folder:Destroy()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClawSlash(cFrame: CFrame, p, p2, value: number?, instance, instance2)
	task.spawn(function()
		local clone

		if instance then
			clone = instance:Clone()
		else
			clone = m1Outside.Phase1.SlashModel:Clone()
		end

		clone.PrimaryPart.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, p, p2, "ControlFruitVFXColor")
		clone.PrimaryPart.CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(1.7453292519943295, 0, 0)
		local cFrame2

		if instance2 and instance2.Parent then
			cFrame2 = instance2.CFrame:ToObjectSpace(clone.PrimaryPart.CFrame)
		else
			cFrame2 = clone.PrimaryPart.CFrame
		end

		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = CFrame.new()
		local cframe = CFrame.new()
		cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			cframe = cFrameValue.Value
		end)
		local flag = true

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyWorldCF()
			if not clone.Parent then
				flag = false
			elseif instance2 and instance2.Parent then
				clone.PrimaryPart.CFrame = instance2.CFrame * cFrame2 * cframe
			else
				clone.PrimaryPart.CFrame = cFrame2 * cframe
			end
		end

		task.spawn(function()
			while flag do
				RunService.Heartbeat:Wait()
				applyWorldCF() -- equivalent call inferred; original call site unknown
			end

			cFrameValue:Destroy()
		end)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			TweenScaleModel(clone, 1.25, 0.15)
		end)
		task.spawn(function()
			task.wait(value or 0.115)

			for _, beam in pairs(clone:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local v = (beam:GetAttribute("EndDelay") or 0) / 2
				local tween = TweenService:Create(
					beam,
					TweenInfo.new(v, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				local v3 = beam
				task.spawn(function()
					tween.Completed:Wait()

					if v3 and v3.Parent then
						v3:Destroy()
					end
				end)
			end
		end)
		task.spawn(function()
			local v = 0.125 * math.random() + 0.1

			for _ = 1, 3 do
				local v2 = cFrameValue.Value * CFrame.Angles(-1.3089969389957472, 0, 0)
				local tween = TweenService:Create(
					cFrameValue,
					TweenInfo.new(v / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Value = v2
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end

			local v2 = cFrameValue.Value * CFrame.Angles(-1.3089969389957472, 0, 0)
			local tween = TweenService:Create(
				cFrameValue,
				TweenInfo.new(v * 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Value = v2
				}
			)
			tween:Play()
			tween.Completed:Wait()
			flag = false
		end)
	end)
end

return function(data)
	if typeof(data.Player) == "Instance" and data.Player:IsA("Player") and not data.Player:FindFirstChild("PlayerGui") and data.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", data.Player)
		folder.Name = "PlayerGui"
	end

	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character and data.Player.Character.PrimaryPart and data.Player.Character.PrimaryPart.Position or data.player and data.player.Character and data.player.Character.PrimaryPart and data.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: " .. script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local combo = data.Combo
	local model = Instance.new("Model")
	model.Name = "ControlM1FX"
	model.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(model, 5)
	local player = data.Player
	local root = data.Root or data.hrp or player and player.Character and (player.Character.PrimaryPart or player.Character:FindFirstChild("HumanoidRootPart"))

	local function GetStartCFrame()
		return data.Root and data.Root.CFrame or data.StartCFrame or root and root.CFrame or CFrame.new(origin)
	end

	local cFrame = data.Root and data.Root.CFrame or data.StartCFrame or root and root.CFrame or CFrame.new(origin)
	local child = workspace._WorldOrigin:FindFirstChild("ControlDaggers" .. player.Name)

	if child then
		Util.Anims:Get(child.LeftDagger, "ControlM1_" .. tostring(data.Combo))
		Util.Anims:Get(child.RightDagger, "ControlM1_" .. tostring(data.Combo))
	end

	if combo == 1 then
		Util.Sound:Play("M1_Side_Slash_01", root)
		local cFrame2 = cFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(0, 0, 0.3490658503988659)
		ClawSlash(cFrame2, model, player, nil, nil, root) -- equivalent call inferred; original call site unknown
		local clone = m1Outside.Phase1.HitImpact:Clone()
		clone.CFrame = cFrame2 * CFrame.new(0, 0, -13)
		Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")

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
		local clone2 = m1Outside.Phase1.GroundImpactSpark:Clone()
		clone2.CFrame = cFrame * CFrame.new(-9, -3, -2)
		Util.SetParentOverrideWithColor(clone2, model, player, "ControlFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
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

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
	elseif combo == 2 then
		Util.Sound:Play("M1_Side_Slash_02", root)
		local cFrame2 = cFrame * CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.Angles(0, 0, -0.017453292519943295)
		ClawSlash(cFrame2, model, player, nil, nil, root) -- equivalent call inferred; original call site unknown
		local clone = m1Outside.Phase1.HitImpact:Clone()
		clone.CFrame = cFrame2 * CFrame.new(0, 0, -13)
		Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")

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
	elseif combo == 3 then
		Util.Sound:Play("M1_OverheadSlash_01", root)
		ClawSlash(
			cFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(0, 0, 0.8726646259971648),
			model,
			player,
			nil,
			nil,
			root
		) -- equivalent call inferred; original call site unknown
		local clone = m1Outside.Phase1.GroundHit:Clone()
		clone.CFrame = cFrame * CFrame.new(1, -3, -14) * CFrame.Angles(-0.2617993877991494, 0, 0)
		Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")

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
	elseif combo == 4 then
		Util.Sound:Play("M1_FinalSlash_0" .. tostring(math.random(1, 3)), root)
		task.spawn(function()
			ClawSlash(
				cFrame * CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.Angles(0, 0, -0.2617993877991494),
				model,
				player,
				nil,
				nil,
				root
			) -- equivalent call inferred; original call site unknown
		end)
		ClawSlash(
			cFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(0, 0, 0.2617993877991494),
			model,
			player,
			nil,
			nil,
			root
		) -- equivalent call inferred; original call site unknown
		task.wait(0.05)
		local cFrame2 = data.Root and data.Root.CFrame or data.StartCFrame or root and root.CFrame or CFrame.new(origin)
		local clone = m1Outside.Phase1.CrossSlash:Clone()
		clone.CFrame = cFrame2 * CFrame.new(1, 0, -15)
		Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")

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
	end
end