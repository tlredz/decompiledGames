local createVector = vector.create
local _ = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").ZHeld.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(ReplicatedStorage:WaitForChild("Util"))
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

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
end

local LightningBoltShafi = require(game.ReplicatedStorage.Util.LightningBoltShafi)

local function ShafiBolt(player, ...)
	local v = LightningBoltShafi.new(...)
	v.MinRadius = 0
	v.MaxRadius = 5
	v.Frequency = 0.35
	v.AnimationSpeed = 5
	local maxThicknessMultiplier = math.random(1, 2)
	v.MinThicknessMultiplier = 0.35
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = math.random(5, 7)
	v.PulseLength = 10000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.45098, 0.992157, 1), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 5
	return v
end

return function(player)
	local character = player.Character
	local holding = player.Holding
	local player2 = player.player
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	if not player.Proxy then
		workspace._WorldOrigin:FindFirstChild("LightningZHeld_" .. character.Name)
	end

	local cFrame = humanoidRootPart.CFrame

	if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 500 then
		return
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "LightningFruitVFXColor")
	local clone = assets.Phase0A.HoldAuraModel:Clone()
	local primaryPart = clone.PrimaryPart
	primaryPart.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player2, "LightningFruitVFXColor")

	for _, emitter in pairs(primaryPart:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local clone2 = assets.Phase0A.StartImpact0:Clone()
	clone2.CFrame = cFrame * CFrame.new(0, 0, -3)
	Util.SetParentOverrideWithColor(clone2, folder, player2, "LightningFruitVFXColor")
	local v = Util.Sound:Play("BF_Thunder_Z_Tier01_01", humanoidRootPart)
	DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

	for _, emitter in pairs(clone2:GetDescendants()) do
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

	local holdOrb = primaryPart.HoldOrb
	clone2.Weld.Part1 = holdOrb
	clone2.Anchored = false
	local lastTime = tick()
	local v2 = 0
	task.spawn(function()
		if not workspace._WorldOrigin:FindFirstChild("LightningZHeld_" .. character.Name) then
			repeat
				task.wait()
			until workspace._WorldOrigin:FindFirstChild("LightningZHeld_" .. character.Name) or holding.Value == false
		end

		local child = workspace._WorldOrigin:FindFirstChild("LightningZHeld_" .. character.Name)

		if not (child and child:IsDescendantOf(workspace)) then
			return
		end

		repeat
			task.wait()
		until child:GetAttribute("Absorbed") == 1

		if not (holding.Value ~= false and primaryPart.Parent) then
			return
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
			v = nil
		end

		v = Util.Sound:Play("BF_Thunder_Z_Tier02_01", humanoidRootPart)
		local clone3 = assets.Phase0A.OrbHeldA1:Clone()
		clone3.CFrame = holdOrb.CFrame
		Util.SetParentOverrideWithColor(clone3, holdOrb, player2, "LightningFruitVFXColor")
		clone3.Anchored = false
		clone3.Weld.Part1 = holdOrb
		local scale = clone:GetScale()
		local v3 = scale * 1.85

		for i = scale * 100, v3 * 100, 10 do
			clone:ScaleTo(i / 100)
			v2 -= 0.2
			task.wait(0.005)
		end

		v2 = -2
	end)
	local v3 = false
	local clone3 = nil
	local clone4 = nil
	local clone5 = nil
	local clone6 = nil
	local v4 = false
	task.spawn(function()
		if not workspace._WorldOrigin:FindFirstChild("LightningZHeld_" .. character.Name) then
			repeat
				task.wait()
			until workspace._WorldOrigin:FindFirstChild("LightningZHeld_" .. character.Name) or holding.Value == false
		end

		local child = workspace._WorldOrigin:FindFirstChild("LightningZHeld_" .. character.Name)

		if not (child and child:IsDescendantOf(workspace)) then
			return
		end

		repeat
			task.wait()
		until child:GetAttribute("Absorbed") == 2

		if not (holding.Value ~= false and primaryPart.Parent) then
			return
		end

		if player.Hidden then
			v4 = true
			return
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
			v = nil
		end

		v = Util.Sound:Play("BF_Thunder_Z_Tier03_01", humanoidRootPart)
		Util.Sound:Play("BF_Thunder_Z_2To3_Transition_01", humanoidRootPart.Position)
		TweenService:Create(v, TweenInfo.new(0.4), {
			Volume = 1
		}):Play()
		holdOrb.Aura:Destroy()
		clone4 = holdOrb:Clone()
		clone4.Anchored = true
		clone4.CFrame = holdOrb.CFrame * CFrame.new(5, 0, 0)
		Util.SetParentOverrideWithColor(clone4, folder, player2, "LightningFruitVFXColor")
		TweenService:Create(holdOrb, TweenInfo.new(0.15), {
			CFrame = cFrame * CFrame.new(-10, 0, -5)
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.15), {
			CFrame = cFrame * CFrame.new(10, 0, -5)
		}):Play()
		v3 = true
		clone5 = assets.Phase0A.Trail:Clone()
		clone5.CFrame = holdOrb.CFrame
		Util.SetParentOverrideWithColor(clone5, folder, player2, "LightningFruitVFXColor")
		clone5.Anchored = false
		clone5.Weld.Part1 = holdOrb
		clone6 = assets.Phase0A.Trail:Clone()
		clone6.CFrame = clone4.CFrame
		Util.SetParentOverrideWithColor(clone6, folder, player2, "LightningFruitVFXColor")
		clone6.Anchored = false
		clone6.Weld.Part1 = clone4
		task.wait(0.15)

		if not (holding.Value ~= false and primaryPart.Parent) then
			return
		end

		local clone7 = assets.Phase0A.RotatePart:Clone()
		clone7.CFrame = cFrame * CFrame.new(0, 0, -5)
		Util.SetParentOverrideWithColor(clone7, folder, player2, "LightningFruitVFXColor")
		holdOrb.Anchored = false
		clone4.Anchored = false
		clone7.Weld1.Part1 = holdOrb
		clone7.Weld2.Part1 = clone4
		TweenService:Create(clone7.Weld1, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C1 = CFrame.new(0, 0, 10)
		}):Play()
		TweenService:Create(clone7.Weld2, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C1 = CFrame.new(0, 0, 10)
		}):Play()
		task.spawn(function()
			for _ = 1, 7 do
				local tween = TweenService:Create(
					clone7,
					TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone7.CFrame * CFrame.Angles(0, 0, 0.8726646259971648)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end
		end)
		task.wait(0.35)

		if not (holding.Value ~= false and primaryPart.Parent) then
			return
		end

		holdOrb:Destroy()
		clone4:Destroy()

		if clone5 then
			clone5:Destroy()
			clone5 = nil
		end

		if clone6 then
			clone6:Destroy()
			clone6 = nil
		end

		local v5 = humanoidRootPart:GetAttribute("LightningSkin") and humanoidRootPart:GetAttribute("LightningSkin") == "Purple"
		local clone8 = assets.Phase0A.StartImpact1:Clone()
		clone8.CFrame = cFrame * CFrame.new(0, 0, -15)
		Util.SetParentOverrideWithColor(clone8, folder, player2, "LightningFruitVFXColor")
		DeleteImpactAfterDuration(clone8) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone8:GetDescendants()) do
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

		clone3 = assets.Phase0A.DragonModel:Clone()
		local primaryPart2 = clone3.PrimaryPart
		primaryPart2.Anchored = false
		primaryPart2.Weld.Part1 = humanoidRootPart
		primaryPart2.Weld.C1 = CFrame.new(0, 0, -15)
		Util.SetParentOverrideWithColor(clone3, folder, player2, "LightningFruitVFXColor")

		if v5 then
			pcall(function()
				primaryPart2.DragonHead["Body.005"].Color = Color3.fromRGB(190, 106, 250)
				primaryPart2.DragonHead["Body.010"].Color = Color3.fromRGB(109, 69, 159)
				primaryPart2.Aura.Attachment.Particle_.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
				primaryPart2.Aura.Attachment.Particle_1.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
				primaryPart2.Aura.Attachment.Particle_2.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
				primaryPart2.Aura.Attachment1.Particle_.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
				primaryPart2.Aura.Attachment1.Particle_1.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
				primaryPart2.Aura.Attachment1.Particle_2.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
			end)
		end

		local clone9 = assets.Phase0A.StartExplosion:Clone()
		clone9.CFrame = cFrame * CFrame.new(0, 0, -10)
		Util.SetParentOverrideWithColor(clone9, folder, player2, "LightningFruitVFXColor")
		DeleteImpactAfterDuration(clone9) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone9:GetDescendants()) do
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
	end)
	local now = tick()
	local v5 = {}
	local v6 = {}

	while true do
		cFrame = humanoidRootPart.CFrame
		primaryPart.CFrame = character.RightHand.CFrame

		if v3 == false then
			holdOrb.CFrame = cFrame * CFrame.new(0.5, 1, v2 + -5)
		end

		if tick() - lastTime >= 0.35 then
			task.spawn(function()
				if tick() - lastTime >= 0.6 then
					return
				end

				if now - tick() <= 0 then
					now = tick() + 0.125

					for _ = 1, math.random(1, 2) do
						task.spawn(function()
							local position = character.RightHand.Position
							local clone7 = FX:WaitForChild("Lightning2").ZHeld.Part:Clone()
							clone7.CFrame = CFrame.new(position) * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							)
							Util.SetParentOverrideWithColor(clone7, folder, player2, "LightningFruitVFXColor")
							math.random(1, 4)
							local v7 = holdOrb
							clone7.Attach1.WorldPosition = v7.Position
							local shafiBolt = ShafiBolt(
								player2,
								clone7.Attach0,
								clone7.Attach1,
								7,
								0.25,
								folder,
								math.random(-5, 5) / 2,
								math.random(-5, 5) / 2
							)
							v5[clone7.Attach1] = v7
							v6[shafiBolt] = shafiBolt
							task.wait(0.15 + math.random() * 0.2)
							v5[clone7.Attach1] = nil

							if v6 == nil then
								return
							end

							v6[shafiBolt] = nil
							shafiBolt:Destroy()
						end)
					end
				end

				for k, v7 in pairs(v5) do
					k.WorldPosition = v7.Position
				end

				for _, v7 in pairs(v6) do
					v7.CurveSize0 *= 1.02
					v7.CurveSize1 *= 1.02
				end
			end)
		end

		task.wait()

		if not (holding.Value == false or v4 == true) then
			continue
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		task.delay(7, function()
			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			folder:Destroy()
		end)
		primaryPart:Destroy()

		if clone4 then
			clone4:Destroy()
		end

		if clone5 then
			clone5:Destroy()
			clone5 = nil
		end

		if clone6 then
			clone6:Destroy()
			clone6 = nil
		end

		cFrame = humanoidRootPart.CFrame

		if not v3 or clone3 == nil then
			break
		end

		local clone7 = assets.Phase0A.DragonGrow:Clone()
		clone7.CFrame = clone3.PrimaryPart.CFrame
		Util.SetParentOverrideWithColor(clone7, folder, player2, "LightningFruitVFXColor")

		for _, emitter in pairs(clone7:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		for i = 75, 125, 10 do
			clone3:ScaleTo(i / 100)
			local weld = clone3.PrimaryPart.Weld
			weld.C1 = clone3.PrimaryPart.Weld.C1 * CFrame.new(0, 0, -0.75)
			task.wait(0.016666666666666666)
		end

		for _, emitter in pairs(clone7:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone3:Destroy()
		break
	end
end