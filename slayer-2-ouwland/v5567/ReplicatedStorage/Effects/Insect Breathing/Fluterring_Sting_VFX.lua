local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.CAM.Client.Modules
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local CraterHandler = require(modules.Effects.Craters.CraterHandler)
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

-- equivalent calls inferred from this helper; original call sites unknown
local function SetPartCFrame(p, p2, p3)
	return p.CFrame * p2.CFrame:ToObjectSpace(p3.CFrame)
end

local function Random_Number(p, p2)
	return Random.new():NextNumber(p, p2)
end

return function(instance, p, list)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local upperTorso = instance:FindFirstChild("UpperTorso")

	if not (humanoidRootPart and upperTorso) then
		return
	end

	local name = string.format("%s_%s_Effects", instance.Name, script.Name)

	if p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local child = debree:FindFirstChild(name)

	if p == "Hold" then
		if child ~= nil then
			child:Destroy()
		end

		vfxUtility.PlaySound(sounds, "PS2insectFSstart", humanoidRootPart, true)
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		folder:SetAttribute("Active", true)
		DebrisModule:AddItem(folder, 5)
		local spawnSwordAura = SpawnSwordAura(instance)
		spawnSwordAura.Parent = folder
		local clone = assets.StartupEmit:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0.10357666015625, -1.1841049194335938, -0.58538818359375) * CFrame.fromEulerAnglesYXZ(
			1.2218952178955078e-6,
			3.141592264175415,
			-3.2782460834823723e-7
		))
		clone.Parent = folder
		local v2 = vfxUtility.CheckForGround(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		vfxUtility.ChangeDustColor(v2, clone.Startup.raycastdust)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
	elseif child == nil then
		return
	end

	if p == "Jump" then
		vfxUtility.PlaySound(sounds, "PS2insectFSjump", humanoidRootPart, true)
		local clone = assets.JumpVFX:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.17535400390625, -2.8259048461914062, -0.61297607421875) * CFrame.fromEulerAnglesYXZ(
			-0,
			0,
			0
		)
		clone.Parent = debree
		local v2 = vfxUtility.CheckForGround(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		vfxUtility.ChangeDustColor(v2, { clone.Raycast, clone.raycastdust })
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(humanoidRootPart.Position, "medium_shake_preset")
		CraterHandler.new("Orbit", CFrame.new(clone.Position) * CFrame.new(0, 5, 0), {
			BlockSize = { 2, 3.5 },
			Angle = { 45, 69 },
			Height = { -0.8, 0.1 },
			Tilt = { -10, 10 },
			PartCount = 10,
			Radius = 20,
			HoldTime = 1,
			IterateSpeed = {
				Entrance = "Stepped",
				EntranceDivision = "Iterate",
				EntanceSpeed = 0.3
			},
			FlourishTypes = {
				Exit = "Melt",
				ExitDivision = "Iterate",
				ExitSpeed = 1
			},
			Range = 30
		})
	else
		if p == "Landing" then
			return
		end

		if p == "Missed" then
			local child2 = debree:FindFirstChild(name)

			if child2 then
				child2.Name = "_"
				vfxUtility.EnableAll(child2, false)
				DebrisModule:AddItem(child2, 2)
			end
		elseif p == "Cutscene" then
			local child2 = debree:FindFirstChild(name)
			local v2, v3, v4 = table.unpack(list)

			if child2 then
				DebrisModule:AddItem(child2, 5)
				vfxUtility.PlaySound(sounds, "PS2insectFScutscene", humanoidRootPart, true)
				task.delay(v3, function()
					if child2 then
						child2.Name = "_"
						vfxUtility.EnableAll(child2, false)
						DebrisModule:AddItem(child2, 2)
					end
				end)
				local child3 = debree:FindFirstChild(v2)
				local butterFlies2ndEmit = nil

				if child3 then
					local bone = child3:FindFirstChild("Bone")

					if bone then
						local clone = assets.CameraVFX:Clone()
						clone:PivotTo(bone.CFrame)
						clone.Parent = child2

						for _, child4 in clone:GetChildren() do
							if child4 ~= clone.PrimaryPart then
								vfxUtility.WeldConstraint(child4, bone)
							end
						end

						for _, child4 in clone:GetChildren() do
							if child4.Name ~= "ButterFlies2ndEmit" then
								vfxUtility.EmitAll(child4, vfxUtility.Owned(instance))
							end
						end

						butterFlies2ndEmit = clone.ButterFlies2ndEmit
						DebrisModule:AddItem(clone, v3 + 1)
					end
				end

				local clone = assets.Dashtrail:Clone()
				clone.CFrame = upperTorso.CFrame
				clone.Parent = child2
				vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance, v3))
				vfxUtility.WeldConstraint(clone, upperTorso)
				DebrisModule:AddItem(clone, v3 + 2)
				local clone2 = assets.MAIN_VFX.spotlight:Clone()
				clone2.CFrame = SetPartCFrame(humanoidRootPart, assets.MAIN_VFX.PrimaryPart, assets.MAIN_VFX.spotlight)
				clone2.Parent = child2
				vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance, 1.25))
				DebrisModule:AddItem(clone2, 2.25)
				task.wait(0.117)

				if not child2:GetAttribute("Active") then
					return
				end

				local clone3 = assets.MAIN_VFX.Thrust1:Clone()
				clone3:PivotTo(SetPartCFrame(
					humanoidRootPart,
					assets.MAIN_VFX.PrimaryPart,
					assets.MAIN_VFX.Thrust1.PrimaryPart
				))
				clone3.Parent = debree
				local v5 = vfxUtility.CheckForGround(
					clone3.PrimaryPart.Position,
					createVector(0, -20, 0),
					vfxUtility.RayParams.Map
				)
				vfxUtility.ChangeDustColor(v5, clone3.GroundFX)
				vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone3, 2)
				task.wait(0.183)

				if not child2:GetAttribute("Active") then
					return
				end

				if v4 then
					for _, child4 in v4:GetChildren() do
						if child4.Value == nil then
							continue
						end

						local value = child4.Value

						for _, child5 in assets.FakeLimbs:GetChildren() do
							local part = value:FindFirstChild(child5.Name)

							if not (part ~= nil and part:IsA("BasePart")) then
								continue
							end

							local clone4 = child5:Clone()
							clone4.CFrame = part.CFrame
							clone4.Parent = child2
							vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
							vfxUtility.WeldConstraint(clone4, part)
							DebrisModule:AddItem(clone4, 2)
						end
					end
				end

				task.wait(0.617)

				if not child2:GetAttribute("Active") then
					return
				end

				local clone4 = assets.MAIN_VFX.LandFX:Clone()
				clone4.CFrame = SetPartCFrame(humanoidRootPart, assets.MAIN_VFX.PrimaryPart, assets.MAIN_VFX.LandFX)
				clone4.Parent = child2
				local v6 = vfxUtility.CheckForGround(clone4.Position, createVector(0, -20, 0), vfxUtility.RayParams.Map)
				vfxUtility.ChangeDustColor(v6, { clone4.raycastdust, clone4.raycastdust2 })
				vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone4, 2)
				task.wait(0.15)

				if not child2:GetAttribute("Active") then
					return
				end

				if butterFlies2ndEmit then
					vfxUtility.EmitAll(butterFlies2ndEmit, vfxUtility.Owned(instance))
				end

				local clone5 = assets.MAIN_VFX.PoisonExplosion:Clone()
				clone5:PivotTo(SetPartCFrame(
					humanoidRootPart,
					assets.MAIN_VFX.PrimaryPart,
					assets.MAIN_VFX.PoisonExplosion.PrimaryPart
				))
				clone5.Parent = child2
				local v7 = vfxUtility.CheckForGround(
					clone5.GroundFX.Position,
					createVector(0, -20, 0),
					vfxUtility.RayParams.Map
				)
				vfxUtility.ChangeDustColor(v7, clone5.GroundFX.raycastdust)
				vfxUtility.EmitAll(clone5, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone5, 2)
			end
		else
			local child2 = p == "Cancel" and debree:FindFirstChild(name)

			if child2 then
				child2.Name = "_"
				DebrisModule:AddItem(child2, 2)
				child2:SetAttribute("Active", nil)
				vfxUtility.EnableAll(child2, false)
				vfxUtility.TweenLight(child2, {
					Time = 0.01,
					Off = true
				})
			end
		end
	end
end