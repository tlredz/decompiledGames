local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

local FX = require(ReplicatedStorage.FX)
local R_FLASH = FX:WaitForChild("YetiEffects").R_FLASH
Util.ResizeModel(R_FLASH.particle, 1.8)
return function(data)
	local player = data.player or game.Players:GetPlayerFromCharacter(data.Root.Parent)
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local parent = data.Root.Parent
		local yetiRig = parent and parent:FindFirstChild("YetiRig")
		local yetiRig2 = yetiRig and yetiRig:FindFirstChild("YetiRig")

		if not yetiRig2 then
			return
		end

		local clone = yetiRig2:Clone()
		clone.Name = "YetiClone_" .. parent.Name .. data.ID
		clone.AnimationController.Animator:Destroy()
		local transformsByName = {}

		for _, bone in ipairs(yetiRig2.RootPart:GetDescendants()) do
			if bone:IsA("Bone") then
				transformsByName[bone.Name] = bone.Transform
			end
		end

		for _, bone in ipairs(clone.RootPart:GetDescendants()) do
			if bone:IsA("Bone") then
				bone.Transform = transformsByName[bone.Name]
			end
		end

		for _, child in clone:GetChildren() do
			if child:IsA("Folder") then
				child:Destroy()
			elseif child:IsA("MeshPart") then
				local surfaceAppearance = child:FindFirstChildWhichIsA("SurfaceAppearance")

				if surfaceAppearance then
					surfaceAppearance:Destroy()
				end

				child.CanCollide = false
				child.CanQuery = false
				child.Material = "Neon"
				child.Color = Util.WrapColor3Constructor(Color3.fromRGB(101, 143, 193), player, "YetiFruitVFXColor")
				child.TextureID = ""
			elseif child:IsA("Part") and child.Name ~= "RootPart" then
				child:Destroy()
			end
		end

		local _ = data.StartCFrame
		local clone2 = R_FLASH.particle:Clone()
		clone2.CanCollide = false
		clone2.Anchored = true
		clone2.CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 7.5, 5)
		clone2.Size = createVector(18, 15, 10.5)
		Util.SetParentOverrideWithColor(clone2, clone, player, "YetiFruitVFXColor")
		clone.PrimaryPart.Anchored = true
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 6)
		emitAll(clone.particle.Impact2)
		Util.Sound:Play("YETI_Flashstep", clone:GetPivot().Position)
		task.wait(3)
		local child

		if clone.Name == "DESTROYING" or not clone then
			child = _WorldOrigin:FindFirstChild("YetiClone_" .. parent.Name .. data.ID)
		else
			child = clone
		end

		if child then
			child.Name = "DESTROYING"
			Util.Sound:Play("YETI_FlashstepBoom", clone:GetPivot().Position)
			emitAll(clone.particle.Impact2)

			for _, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	elseif stage == 2 then
		if data.Root.Parent == game.Players.LocalPlayer.Character then
			task.spawn(function()
				local clone = script.DOF:Clone()
				Util.SetParentOverrideWithColor(clone, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone, 0.5)
				TweenService:Create(clone, TweenInfo.new(0.433, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					FarIntensity = 0,
					FocusDistance = 0,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
			end)
		end

		local endCFrame = data.EndCFrame
		local clone = R_FLASH.FlashStep:Clone()
		clone.CFrame = endCFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 3.5)
		emitAll(clone)
	elseif stage == 3 then
		local child = _WorldOrigin:FindFirstChild("YetiClone_" .. data.Root.Parent.Name .. data.ID)

		if child then
			child.Name = "DESTROYING"
			local particle = child.particle
			Util.Sound:Play("YETI_FlashstepBoom", child:GetPivot().Position)
			emitAll(child.particle.Impact2)

			for _, part in pairs(child:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			for _, emitter in pairs(particle:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	end
end