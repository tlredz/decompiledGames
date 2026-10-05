local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.CAM.Client.Modules
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterHandler)
require(modules.Effects.Craters.CraterEffects)
local _ = Players.LocalPlayer
local assets = script:FindFirstChild("Assets")
local debree = workspace.Debree
local sounds = script:FindFirstChild("Sounds")
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage.CAM.DebrisModule)
require(modules.Effects.BoatTween)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local _ = game.Players.LocalPlayer
local _ = workspace.CurrentCamera
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.FilterDescendantsInstances = { workspace.Map }

local function SpawnSwordAura(instance)
	local sword_At_A = instance:FindFirstChild("Sword_At_A", true)

	if sword_At_A == nil then
		return
	end

	local parent = sword_At_A.Parent
	local clone = script.Parent.SwordAura:Clone()
	clone.CFrame = parent.CFrame
	clone.Parent = debree
	vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
	vfxUtility.WeldConstraint(clone, parent)
	DebrisModule:AddItem(clone, 10)
	return clone
end

local function Random_Number(p, p2)
	return Random.new():NextNumber(p, p2)
end

return function(instance, p, _)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local name = string.format("%s_%s_Effects", instance.Name, script.Name)
	local magnitude = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
	local v2 = magnitude > 250 and p == "End" and "Cancel" or p

	if v2 ~= "Cancel" and magnitude > 250 then
		return
	end

	local pS2insectCEHbrrgloop = humanoidRootPart:FindFirstChild("PS2insectCEHbrrgloop")

	if pS2insectCEHbrrgloop ~= nil then
		pS2insectCEHbrrgloop:Destroy()
	end

	if v2 == "Loop" then
		vfxUtility.PlaySound(sounds, "PS2insectCEHbrrg", humanoidRootPart, true)
		local clone = script.Sounds.PS2insectCEHbrrgloop:Clone()
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, 7)

		if debree:FindFirstChild(name) then
			local child = debree:FindFirstChild(name)
			child.Name = "_"
			DebrisModule:AddItem(child, 2)
			child:SetAttribute("Active", nil)
			vfxUtility.EnableAll(child, false)
		end

		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		DebrisModule:AddItem(folder, 12)
		folder:SetAttribute("Active", true)
		folder:SetAttribute("BarrageShake", true)
		local spawnSwordAura = SpawnSwordAura(instance)
		spawnSwordAura.Parent = folder
		local clone2 = assets.BARRAGE:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame)
		clone2.Parent = folder
		vfxUtility.TweenLight(clone2, {
			Time = 0.2
		})
		vfxUtility.WeldConstraint(clone2.PrimaryPart, humanoidRootPart)
		local raycastResult = workspace:Raycast(
			clone2.PrimaryPart.Position + createVector(0, 1, 0),
			createVector(0, -10, 0),
			vfxUtility.RayParams.Map
		)

		if raycastResult then
			for _, emitter in clone2.GroundVFX:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") or emitter.Name:match("grass") or emitter.Parent.Name == "keep" then
					continue
				end

				emitter.Color = ColorSequence.new(raycastResult.Instance.Color, raycastResult.Instance.Color)
			end
		else
			clone2.GroundVFX:Destroy()
		end

		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		local cam_Shaker = Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.082,
			Amplitude = 0.12,
			SustainTime = 6,
			FadeOutTime = 0.15,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(0.4, 0.4, 0.4)
		})

		while humanoidRootPart:IsDescendantOf(workspace) and folder:IsDescendantOf(workspace) and folder:GetAttribute("Active") and folder:GetAttribute("BarrageShake") do
			task.wait(0.15)
		end

		cam_Shaker:Destroy()
	elseif v2 == "End" then
		local parent = debree:FindFirstChild(name)
		vfxUtility.PlaySound(sounds, "PS2insectCEHbrrgstop", humanoidRootPart, true)

		if parent == nil then
			parent = Instance.new("Folder")
			parent.Name = name
			parent.Parent = debree
			DebrisModule:AddItem(parent, 4)
			parent:SetAttribute("Active", true)
		end

		if not parent:GetAttribute("Active") then
			return
		end

		parent:SetAttribute("BarrageShake", nil)
		local BARRAGE = parent:FindFirstChild("BARRAGE")

		if BARRAGE then
			vfxUtility.EnableAll(BARRAGE, false)
			DebrisModule:AddItem(BARRAGE, 3)
			vfxUtility.TweenLight(BARRAGE, {
				Time = 0.2,
				Off = true
			})
		end

		local clone = assets.END_STARTUP:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
		clone.Parent = parent
		DebrisModule:AddItem(clone, 2)
		local raycastResult = workspace:Raycast(
			(BARRAGE or instance).PrimaryPart.Position + createVector(0, 1, 0),
			createVector(0, -10, 0),
			vfxUtility.RayParams.Map
		)

		if raycastResult then
			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") or emitter.Name:match("grass") or emitter.Parent.Name == "keep" then
					continue
				end

				emitter.Color = ColorSequence.new(raycastResult.Instance.Color, raycastResult.Instance.Color)
			end
		else
			clone.raycastdust:Destroy()
			clone.raycastdust2:Destroy()
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		task.wait(0.2)

		if not parent:GetAttribute("Active") or humanoidRootPart == nil then
			return
		end

		Cam_Shaker(humanoidRootPart.Position, "medium_shake_preset")
		vfxUtility.PlaySound(sounds, "PS2insectCEHthrustdash", humanoidRootPart, true)
		local clone2 = assets.DASH_EMIT:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame)
		clone2.Parent = parent
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 2)

		if raycastResult then
			for _, emitter in clone2.GroundFX:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") or emitter.Name:match("grass") or emitter.Parent.Name == "keep" then
					continue
				end

				emitter.Color = ColorSequence.new(raycastResult.Instance.Color, raycastResult.Instance.Color)
			end
		else
			clone2.GroundFX.raycastdust:Destroy()
			clone2.GroundFX.raycastdust2:Destroy()
		end

		local clone3 = assets.DASH:Clone()
		clone3:PivotTo(humanoidRootPart.CFrame)
		clone3.Parent = parent
		vfxUtility.TweenLight(clone3, {
			Time = 0.2,
			Del = 0.4
		})
		vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
		vfxUtility.WeldConstraint(clone3.PrimaryPart, humanoidRootPart)
		DebrisModule:AddItem(clone3, 10)
		task.wait(0.4)
		local swordAura = parent:FindFirstChild("SwordAura")

		if swordAura then
			vfxUtility.EnableAll(swordAura, false)
			DebrisModule:AddItem(swordAura, 2)
		end

		if parent then
			parent.Name = "_"
			DebrisModule:AddItem(parent, 2)
			parent:SetAttribute("Active", nil)
			vfxUtility.EnableAll(parent, false)
		end
	else
		local child = v2 == "Cancel" and debree:FindFirstChild(name)

		if child then
			child.Name = "_"
			DebrisModule:AddItem(child, 2)
			child:SetAttribute("Active", nil)
			vfxUtility.EnableAll(child, false)
			vfxUtility.TweenLight(child, {
				Time = 0.01,
				Off = true
			})
		end
	end
end