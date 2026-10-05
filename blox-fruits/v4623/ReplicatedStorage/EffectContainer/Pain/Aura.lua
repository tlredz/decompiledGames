local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").Aura.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
local _ = {
	"rbxassetid://130452828882944",
	"rbxassetid://71120275331630",
	"rbxassetid://137605552289098",
	"rbxassetid://83529237502062",
	"rbxassetid://101597828079212",
	"rbxassetid://89359982828229",
	"rbxassetid://128504348629671",
	"rbxassetid://123584584840567"
}
Random.new()

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end

		if not (emitter.Lifetime.Max <= max) then
			max = emitter.Lifetime.Max
		end
	end

	return max
end

return function(player)
	local player2 = player.Player
	local origin = player.Origin
	local stage = player.Stage
	local character = player.Character

	if stage ~= 0 and (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	if stage == 0 then
		local child = _WorldOrigin:FindFirstChild("PainAura" .. player.Character.Name)

		if child then
			child:SetAttribute("Tier", 0)
			child.Name = "DESTROYING"
			task.wait(3)
			child:Destroy()
		end
	elseif stage == 1 then
		local parent = _WorldOrigin:FindFirstChild("PainAura" .. player.Character.Name)

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "PainAura" .. player.Character.Name
			Util.SetParentOverrideWithColor(parent, workspace._WorldOrigin, player2, "PainFruitVFXColor", true)
			Util.SyncColorsOnChange(parent, player2, "PainFruitVFXColor", true)
		end

		parent:SetAttribute("Tier", 1)
		local head = character:WaitForChild("Head")
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local v2 = humanoidRootPart:GetAttribute("PainSkin") and humanoidRootPart:GetAttribute("PainSkin") == "PAINSKINsuperspirit"
		local v3 = Util.Sound:Play("Passive_FirstAura_01_V1", humanoidRootPart)
		local clone

		if v2 then
			clone = assets.PainAuraSSJDefault:Clone()
		else
			clone = assets.PainAuraDefault:Clone()
		end

		clone:ScaleTo(character:GetScale())
		local cryEffect = clone.CryEffect

		for _, beam in cryEffect:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			local width0 = beam.Width0
			local width1 = beam.Width1
			beam.Width0 = 0
			beam.Width1 = 0
			TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Width0 = width0,
				Width1 = width1
			}):Play()
		end

		cryEffect.Weld.Part0 = head

		if v2 then
			cryEffect.Parent = parent
		else
			Util.SetParentOverrideWithColor(cryEffect, parent, player2, "PainFruitVFXColor", true)
			Util.SyncColorsOnChange(cryEffect, player2, "PainFruitVFXColor", true)
		end

		local aura = clone.Aura
		aura.Weld.Part0 = humanoidRootPart

		if v2 then
			aura.Parent = parent
		else
			Util.SetParentOverrideWithColor(aura, parent, player2, "PainFruitVFXColor", true)
			Util.SyncColorsOnChange(aura, player2, "PainFruitVFXColor", true)
		end

		clone:Destroy()

		repeat
			task.wait()
		until not parent:IsDescendantOf(workspace) or parent:GetAttribute("Tier") ~= stage or character:FindFirstChild("PainTransformed")

		if not character:FindFirstChild("PainTransformed") then
			parent.Name = "Destroying"
			Util.Debris:AddItem(parent, 10)
		end

		if v3 then
			Util.Sound:FadeOut(v3, 0.2)
		end

		for _, beam in cryEffect:GetDescendants() do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		local particleState = ParticleState(aura, false)
		task.delay(particleState, aura.Destroy, aura)
		local particleState2 = ParticleState(cryEffect, false)
		task.delay(particleState2 + 0.3, cryEffect.Destroy, cryEffect)
	elseif stage == 2 then
		local parent = _WorldOrigin:FindFirstChild("PainAura" .. player.Character.Name)

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "PainAura" .. player.Character.Name
			Util.SetParentOverrideWithColor(parent, workspace._WorldOrigin, player2, "PainFruitVFXColor", true)
			Util.SyncColorsOnChange(parent, player2, "PainFruitVFXColor", true)
		end

		parent:SetAttribute("Tier", 2)
		character:WaitForChild("Head")
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local v2 = humanoidRootPart:GetAttribute("PainSkin") and humanoidRootPart:GetAttribute("PainSkin") == "PAINSKINsuperspirit"
		humanoidRootPart.Anchored = true
		Util.Sound:Play("Passive_AuraTransition_01", humanoidRootPart)

		if player.Player then
			local player3 = player.Player
			local Players = game:GetService("Players")

			if player3 == Players.LocalPlayer then
				task.spawn(function()
					local folder = Instance.new("Folder", workspace._WorldOrigin)
					Util.Debris:AddItem(folder, 5)
					local clone = assets.CameraFocus:Clone()
					Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor", true)
					Util.SyncColorsOnChange(clone, player2, "PainFruitVFXColor", true)
					task.delay(0.3, function()
						Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.8)
						local Effect = require(game.ReplicatedStorage.Effect)
						Effect.new("ColorCorrection"):replicate({
							TintColor = Color3.fromRGB(255, 125, 125),
							Brightness = 0.3,
							Saturation = 0.1,
							Contrast = 0.1,
							FadeIn = 0,
							FadeOut = 0.1,
							Lifetime = 0.1
						})
					end)
					local renderSteppedConnection = RunService.RenderStepped:Connect(function()
						clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, 0, 0)
					end)

					for _, emitter in pairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						if emitter:GetAttribute("ENABLE") == true then
							local v3 = emitter
							task.spawn(function()
								v3.Enabled = true
								task.wait(0.3)
								v3.Lifetime = NumberRange.new(v3.Lifetime.Min * 0.1, v3.Lifetime.Max * 0.1)
								v3.Enabled = false
							end)
						else
							local v3 = emitter
							task.spawn(function()
								if v3:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v3:GetAttribute("EmitDelay"))
								end

								v3:Emit(v3:GetAttribute("EmitCount"))
							end)
						end
					end

					local screenColorPV = assets.Phase1.ScreenColorPV
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					colorCorrectionEffect.Name = screenColorPV.Name
					colorCorrectionEffect.Parent = game.Lighting
					TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.25), {
						Brightness = screenColorPV.Brightness,
						Contrast = screenColorPV.Contrast,
						Saturation = screenColorPV.Saturation,
						TintColor = screenColorPV.TintColor
					}):Play()
					task.delay(0.35, function()
						local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(1), {
							TintColor = Color3.fromRGB(255, 255, 255),
							Brightness = 0,
							Contrast = 0,
							Saturation = 0
						})
						tween:Play()
						tween.Completed:Wait()
						colorCorrectionEffect:Destroy()
					end)
					task.delay(0.3, function()
						local screenColorPV2 = assets.Phase1.ScreenColorPV2
						local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect2.Name = screenColorPV2.Name
						colorCorrectionEffect2.Parent = game.Lighting
						TweenService:Create(colorCorrectionEffect2, TweenInfo.new(0.025), {
							Brightness = screenColorPV2.Brightness,
							Contrast = screenColorPV2.Contrast,
							Saturation = screenColorPV2.Saturation,
							TintColor = screenColorPV2.TintColor
						}):Play()
						task.delay(0.025, function()
							local tween = TweenService:Create(colorCorrectionEffect2, TweenInfo.new(0.01), {
								TintColor = Color3.fromRGB(255, 255, 255),
								Brightness = 0,
								Contrast = 0,
								Saturation = 0
							})
							tween:Play()
							tween.Completed:Wait()
							colorCorrectionEffect2:Destroy()
						end)
					end)
					task.wait(0.5)
					renderSteppedConnection:Disconnect()
					clone:Destroy()
				end)
			end
		end

		local highlight = Instance.new("Highlight")
		highlight.FillColor = Util.WrapColor3Constructor(Color3.new(0, 0, 0), player2, "PainFruitVFXColor", true)
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 1
		Util.SetParentOverrideWithColor(highlight, character, player2, "PainFruitVFXColor", true)
		Util.SyncColorsOnChange(highlight, player2, "PainFruitVFXColor", true)
		TweenService:Create(highlight, TweenInfo.new(0.3), {
			FillTransparency = 0.5
		}):Play()
		task.delay(1.3, function()
			humanoidRootPart.Anchored = false
		end)
		task.wait(0.3)
		local clone = assets.Explosion:Clone()

		if player.NoFace then
			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant.Name == "FaceExplosion" then
					descendant:Destroy()
				end
			end
		end

		Util.ResizeModel(clone, 0.45)
		clone.CFrame = humanoidRootPart.CFrame
		Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "PainFruitVFXColor", true)
		Util.SyncColorsOnChange(clone, player2, "PainFruitVFXColor", true)
		Util.Debris:AddItem(clone, 2)

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

		local v3 = Util.Sound:Play("Passive_SecondAura_01_V1", humanoidRootPart)
		local clone2

		if v2 then
			clone2 = assets.PainAuraSSJMode:Clone()
		else
			clone2 = assets.PainAura2:Clone()
		end

		clone2:ScaleTo(character:GetScale())
		local clones = {}

		for _, child in clone2.BodyParticles:GetChildren() do
			for _, part in character:GetChildren() do
				if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
					continue
				end

				local clone3 = child:Clone()
				table.insert(clones, clone3)

				if v2 then
					clone3.Parent = part
				else
					Util.SetParentOverrideWithColor(clone3, part, player2, "PainFruitVFXColor", true)
					Util.SyncColorsOnChange(clone3, player2, "PainFruitVFXColor", true)
				end
			end
		end

		local aura = clone2.Aura
		aura.Weld.Part0 = humanoidRootPart

		if v2 then
			aura.Parent = parent
		else
			Util.SetParentOverrideWithColor(aura, parent, player2, "PainFruitVFXColor", true)
			Util.SyncColorsOnChange(aura, player2, "PainFruitVFXColor", true)
		end

		clone2:Destroy()

		repeat
			task.wait()
		until not parent:IsDescendantOf(workspace) or parent:GetAttribute("Tier") ~= stage

		Util.Debris:AddItem(parent, 15)

		if v3 then
			Util.Sound:FadeOut(v3, 0.2)
		end

		local particleState = ParticleState(aura, false)
		task.delay(particleState, aura.Destroy, aura)

		for _, v5 in clones do
			v5.Enabled = false
			task.delay(v5.Lifetime.Max, v5.Destroy, v5)
		end

		highlight:Destroy()
	elseif stage == 3 then
		local v = _WorldOrigin:FindFirstChild("PainAura" .. player.Character.Name)

		if not v then
			v = Instance.new("Folder")
			v.Name = "PainAura" .. player.Character.Name
			Util.SetParentOverrideWithColor(v, workspace._WorldOrigin, player2, "PainFruitVFXColor", true)
			Util.SyncColorsOnChange(v, player2, "PainFruitVFXColor", true)
		end

		v.Name = "Destroying"
		v:SetAttribute("Tier", 3)
		Util.Debris:AddItem(v, 15)
		character:WaitForChild("Head")
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		Util.Sound:Play("Passive_EnergyLevelReduce_02_V1", humanoidRootPart)
		local v2 = Util.Sound:Play("Passive_FirstAura_02_V1", humanoidRootPart)
		local clone = assets.PainAura:Clone()
		clone:ScaleTo(character:GetScale())
		local clones = {}

		for _, child in clone.BodyParticles:GetChildren() do
			for _, part in character:GetChildren() do
				if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
					continue
				end

				local clone2 = child:Clone()
				table.insert(clones, clone2)
				Util.SetParentOverrideWithColor(clone2, part, player2, "PainFruitVFXColor", true)
				Util.SyncColorsOnChange(clone2, player2, "PainFruitVFXColor", true)
			end
		end

		local aura = clone.Aura
		aura.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(aura, v, player2, "PainFruitVFXColor", true)
		Util.SyncColorsOnChange(aura, player2, "PainFruitVFXColor", true)
		clone:Destroy()

		repeat
			task.wait()
		until not v:IsDescendantOf(workspace) or v:GetAttribute("Tier") ~= stage or character:GetAttribute("AuraOff")

		if character and character:GetAttribute("AuraOff") then
			task.wait(0.2)
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		local particleState = ParticleState(aura, false)
		task.delay(particleState, aura.Destroy, aura)

		for _, v4 in clones do
			v4.Enabled = false
			task.delay(v4.Lifetime.Max, v4.Destroy, v4)
		end
	elseif stage == 4 then
		local _ = player.Player
		local enemyRoot = player.EnemyRoot
		local clone = assets.EnemyAura:Clone()
		clone.CFrame = enemyRoot.CFrame
		Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "PainFruitVFXColor", true)
		Util.SyncColorsOnChange(clone, player2, "PainFruitVFXColor", true)
		clone.Weld.Part0 = enemyRoot
		Util.Sound:Play("V_Hit_Tick_Damage_0" .. tostring(math.random(1, 3)) .. "_V1", enemyRoot)
		ParticleState(clone)
		Util.Debris:AddItem(clone, 1)
	end
end