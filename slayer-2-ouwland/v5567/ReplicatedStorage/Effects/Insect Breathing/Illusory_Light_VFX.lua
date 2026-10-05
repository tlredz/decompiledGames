local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.CAM.Client.Modules
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterHandler)
require(modules.Effects.Craters.CraterEffects)
local ImpactFrames = require(modules.Effects.ImpactFrames)
local localPlayer = Players.LocalPlayer
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

	if p == "Hold" then
		if debree:FindFirstChild(name) then
			debree:FindFirstChild(name):Destroy()
		end

		vfxUtility.PlaySound(sounds, "PS2insectILstart", humanoidRootPart, true)
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		folder:SetAttribute("Active", true)
		DebrisModule:AddItem(folder, 12)
		Cam_Shaker(humanoidRootPart.Position, "activate_shakelessaggresive")
		local child = debree:FindFirstChild(name)
		local spawnSwordAura = SpawnSwordAura(instance)
		spawnSwordAura.Parent = child
		local clone = assets.StartupEmit:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0.10357666015625, -1.1841049194335938, -0.58538818359375) * CFrame.fromEulerAnglesYXZ(
			1.2218952178955078e-6,
			3.141592264175415,
			-3.2782460834823723e-7
		))
		clone.Parent = child
		local v2 = vfxUtility.CheckForGround(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		vfxUtility.ChangeDustColor(v2, clone.Startup.raycastdust)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
	elseif p == "Thrust" then
		local child = debree:FindFirstChild(name)

		if child == nil then
			return
		end

		local cFrame = humanoidRootPart.CFrame
		Cam_Shaker(cFrame.Position, "Medium_tiny_shake_preset")
		vfxUtility.PlaySound(sounds, "PS2insectULTjab", humanoidRootPart, true)
		local clone = script.Assets.EndEmit:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, -1.5707963267948966, 0)
		clone.Parent = child
		DebrisModule:AddItem(clone, 3)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		local raycastResult = workspace:Raycast(
			cFrame * CFrame.new(0, 2, 0).Position,
			cFrame.UpVector * -20,
			vfxUtility.RayParams.Map
		)
		local cFrame2 = cFrame * CFrame.new(0, -2.7, 0)
		local clone2 = script.Assets.GroundFX:Clone()
		clone2.Parent = child

		if raycastResult == nil or raycastResult.Instance == nil then
			clone2.CFrame = cFrame2
			vfxUtility.EmitAll(clone2.raycastdust2.grass_blade14, vfxUtility.Owned(instance))
		else
			clone2.CFrame = CFrame.new(raycastResult.Position) * cFrame2.Rotation
			vfxUtility.EmitAll(clone2.raycastdust.Attachment, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color
			}))
			vfxUtility.EmitAll(clone2.raycastdust2, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorBlacklist = "grass_blade14"
			}))
		end

		vfxUtility.EmitAll(clone2.keep, vfxUtility.Owned(instance))
		vfxUtility.EmitAll(clone2.raycastdust.Debree, vfxUtility.Owned(instance))

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
	elseif p == "Cutscene" then
		local v2, v3, v4 = unpack(list)

		if v2 == nil or v3 == nil or v4 == nil then
			return
		end

		local parent2 = debree:FindFirstChild(name)

		if not parent2 then
			parent2 = Instance.new("Folder")
			parent2.Name = name
			parent2.Parent = debree
			parent2:SetAttribute("Active", true)
			DebrisModule:AddItem(parent2, 5)
		end

		local v6 = {}
		local child = debree:FindFirstChild(v2)
		local clone = nil

		if child then
			local bone = child:FindFirstChild("Bone")

			if bone then
				clone = assets.VFX.CameraVFX:Clone()
				clone:PivotTo(bone.CFrame)
				clone.Parent = parent2

				for _, child2 in clone:GetChildren() do
					if child2 ~= clone.PrimaryPart then
						vfxUtility.WeldConstraint(child2, bone)
					end
				end

				DebrisModule:AddItem(clone, v3 + 2)
			end
		end

		if clone then
			vfxUtility.EmitAll(clone.CameraVFXZoom, vfxUtility.Owned(instance))
		end

		local clone2 = assets["Insect Ultimate PS2"]:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.00006103515625, -1.9204254150390625, 0.04986572265625) * CFrame.fromEulerAnglesYXZ(
			-1.4923540447853156e-7,
			-3.141592502593994,
			1.119348951306165e-7
		))
		clone2.Parent = parent2
		DebrisModule:AddItem(clone2, v3)
		clone2.AnimationController:LoadAnimation(assets.Butterfly):Play()
		vfxUtility.PlaySound(sounds, "PS2insectILcinematic", humanoidRootPart, true)
		task.wait(0.05)

		if not parent2:GetAttribute("Active") then
			return
		end

		local clone3 = assets.VFX.Thrust1:Clone()
		clone3:PivotTo(SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.Thrust1.PrimaryPart))
		clone3.Parent = parent2
		DebrisModule:AddItem(clone3, 2)
		local v7 = vfxUtility.CheckForGround(
			clone3.PrimaryPart.Position + createVector(0, 2, 0),
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		vfxUtility.ChangeDustColor(v7, clone3.GroundFX)
		vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
		task.wait(0.483)

		if not parent2:GetAttribute("Active") then
			return
		end

		local clone4 = assets.VFX.LandFX:Clone()
		clone4.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.LandFX)
		clone4.Parent = parent2
		local v8 = vfxUtility.CheckForGround(
			clone4.Position + createVector(0, 2, 0),
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		vfxUtility.ChangeDustColor(v8, { clone4.raycastdust, clone4.raycastdust2 })
		vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone4, 2)
		task.wait(0.234)

		if not parent2:GetAttribute("Active") then
			return
		end

		local clone5 = assets.VFX.JumpTest1:Clone()
		clone5:PivotTo(SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.JumpTest1.PrimaryPart))
		clone5.Parent = parent2
		local v9 = vfxUtility.CheckForGround(
			clone5.PrimaryPart.Position + createVector(0, 2, 0),
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		vfxUtility.ChangeDustColor(v9, { clone5.LandFX.raycastdust, clone5.LandFX.raycastdust2 })
		vfxUtility.EmitAll(clone5, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone5, v3)
		local clone6 = assets.VFX.Dashtrail:Clone()
		clone6.CFrame = upperTorso.CFrame
		clone6.Parent = parent2
		vfxUtility.WeldConstraint(clone6, upperTorso)
		vfxUtility.EmitAll(clone6, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone6, v3)
		clone6.A0.bodytrail1.Enabled = true
		task.delay(0.3, function()
			if clone6 then
				clone6.A0.bodytrail1.Enabled = false
			end
		end)

		if clone then
			vfxUtility.EmitAll(clone.CameraVFX, vfxUtility.Owned(instance))
			vfxUtility.EmitAll(clone.CameraVFX2, vfxUtility.Owned(instance))
		end

		task.wait(0.216)

		if not parent2:GetAttribute("Active") then
			return
		end

		if clone then
			vfxUtility.EmitAll(clone.ButterFlies, vfxUtility.Owned(instance))
		end

		local v10 = table.find(v4, localPlayer.Character) ~= nil

		if v10 then
			local clone7 = assets.VFX.spotlight:Clone()
			clone7.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.spotlight)
			clone7.Parent = parent2
			vfxUtility.EmitAll(clone7, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone7, 3)
		end

		task.wait(0.067)

		if not parent2:GetAttribute("Active") then
			return
		end

		local clone7 = assets.VFX.CapriceCharge:Clone()
		clone7.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.CapriceCharge)
		clone7.Parent = parent2
		vfxUtility.EmitAll(clone7, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone7, 2)
		task.wait(1.017)

		if not parent2:GetAttribute("Active") then
			return
		end

		if clone then
			vfxUtility.EmitAll(clone.ButterFlies2, vfxUtility.Owned(instance))
		end

		local clone8 = assets.VFX.BodyEmit:Clone()
		clone8.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.BodyEmit)
		clone8.Parent = parent2
		vfxUtility.EmitAll(clone8, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone8, 3)
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))

		for _, v11 in v4 do
			if localPlayer.Character ~= v11 then
				continue
			end

			local clone9 = assets.VFX.backdrop:Clone()
			clone9.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.backdrop)
			clone9.Parent = parent2
			vfxUtility.EmitAll(clone9, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone9, 3)
			break
		end

		if v10 then
			local clone9 = assets.VFX.backdrop:Clone()
			clone9.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.backdrop)
			clone9.Parent = parent2
			vfxUtility.EmitAll(clone9, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone9, 3)
		end

		task.wait(0.766)

		if not parent2:GetAttribute("Active") then
			return
		end

		if clone then
			vfxUtility.EmitAll(clone.CameraVFXZoom2, vfxUtility.Owned(instance))
		end

		task.wait(0.784)

		if not parent2:GetAttribute("Active") then
			return
		end

		local clone9 = assets.VFX.Flap1:Clone()
		clone9.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.Flap1)
		clone9.Parent = parent2
		vfxUtility.EmitAll(clone9, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone9, 3)
		task.wait(0.883)

		if not parent2:GetAttribute("Active") then
			return
		end

		local clone10 = assets.VFX.Flap2:Clone()
		clone10.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.Flap2)
		clone10.Parent = parent2
		vfxUtility.EmitAll(clone10, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone10, 3)
		task.wait(0.133)

		if not parent2:GetAttribute("Active") then
			return
		end

		local sword_At_A = instance:FindFirstChild("Sword_At_A", true)

		if sword_At_A ~= nil then
			local parent = sword_At_A.Parent

			if parent2:FindFirstChild("SwordAura") then
				vfxUtility.EnableAll(parent2:FindFirstChild("SwordAura"), false)
			end

			local clone11 = assets.VFX.SwordAura2:Clone()
			clone11.CFrame = parent.CFrame
			clone11.Parent = parent2
			vfxUtility.EnableAll(clone11, true, vfxUtility.Owned(instance))
			vfxUtility.WeldConstraint(clone11, parent)
			DebrisModule:AddItem(clone11, v3)
		end

		task.wait(0.55)

		if not parent2:GetAttribute("Active") then
			return
		end

		if table.find(v4, localPlayer.Character) then
			task.delay(0.11666666666666667, function()
				if not parent2:GetAttribute("Active") then
					return
				end

				local v11 = ImpactFrames.PlaySet({
					FrameRate = 0.02857142857142857,
					FramesSetName = "Illusory_Light"
				})
				local attributeChangedConnection = nil
				local thread = task.delay(3, function()
					if attributeChangedConnection and attributeChangedConnection.Connected then
						attributeChangedConnection:Disconnect()
					end
				end)
				attributeChangedConnection = parent2.AttributeChanged:Connect(function(_: string)
					if parent2:GetAttribute("Active") then
						return
					end

					v11()
					attributeChangedConnection:Disconnect()
					task.cancel(thread)
				end)
			end)
		end

		local clone11 = assets.VFX.EndImpact1:Clone()
		clone11.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.EndImpact1)
		clone11.Parent = parent2
		vfxUtility.EmitAll(clone11, vfxUtility.Owned(instance))
		local v11 = vfxUtility.CheckForGround(
			clone11.Position + createVector(0, 2, 0),
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		vfxUtility.ChangeDustColor(v11, { clone11.raycastdust, clone11.raycastdust2 })
		DebrisModule:AddItem(clone11, 6)
		local clone12 = assets.VFX.RockAtlasModule.RockDebree1:Clone()
		clone12:PivotTo(SetPartCFrame(
			humanoidRootPart,
			assets.VFX.Root,
			assets.VFX.RockAtlasModule.RockDebree1.PrimaryPart
		))
		clone12.Parent = parent2
		DebrisModule:AddItem(clone12, 6)
		task.spawn(function()
			for _, child2 in clone12:GetChildren() do
				if child2 == clone12.PrimaryPart then
					continue
				end

				local raycastResult = workspace:Raycast(
					child2.Position + createVector(0, 5, 0),
					createVector(0, -15, 0),
					vfxUtility.RayParams.Map
				)

				if raycastResult then
					child2.Color = raycastResult.Instance.Color
					child2.Transparency = raycastResult.Instance.Transparency
					child2.Material = raycastResult.Instance.Material
					child2.Reflectance = raycastResult.Instance.Reflectance

					for _, child3 in raycastResult.Instance:GetChildren() do
						if not (child3:IsA("Decal") or child3:IsA("Texture")) then
							continue
						end

						local clone = child3:Clone()
						clone.Parent = child2
					end
				end

				child2.Position += createVector(0, -20, 0)
				TweenService:Create(child2, TweenInfo.new(Random.new():NextNumber(0.2, 0.4), Enum.EasingStyle.Sine), {
					Position = child2.Position + createVector(0, 20, 0)
				}):Play()
				table.insert(v6, child2)
			end
		end)
		task.wait(0.567)

		if not parent2:GetAttribute("Active") then
			return
		end

		local clone13 = assets.VFX.EndImpact2:Clone()
		clone13.CFrame = SetPartCFrame(humanoidRootPart, assets.VFX.Root, assets.VFX.EndImpact2)
		clone13.Parent = parent2
		local v12 = vfxUtility.CheckForGround(
			clone13.Position + createVector(0, 2, 0),
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		vfxUtility.ChangeDustColor(v12, clone13.raycastdust)
		vfxUtility.EmitAll(clone13, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone13, 6)

		if clone then
			vfxUtility.EmitAll(clone.FinalCameraZoom, vfxUtility.Owned(instance))
		end

		local clone14 = assets.VFX.RockAtlasModule.Main_Rocks:Clone()
		clone14:PivotTo(SetPartCFrame(
			humanoidRootPart,
			assets.VFX.Root,
			assets.VFX.RockAtlasModule.Main_Rocks.PrimaryPart
		))
		clone14.Parent = parent2
		DebrisModule:AddItem(clone14, 6)
		task.spawn(function()
			for _, part in clone14:GetDescendants() do
				if not (part ~= clone14.PrimaryPart and part:IsA("Part")) then
					continue
				end

				local raycastResult = workspace:Raycast(
					part.Position + createVector(0, 5, 0),
					createVector(0, -15, 0),
					vfxUtility.RayParams.Map
				)

				if raycastResult then
					part.Color = raycastResult.Instance.Color
					part.Transparency = raycastResult.Instance.Transparency
					part.Material = raycastResult.Instance.Material
					part.Reflectance = raycastResult.Instance.Reflectance

					for _, child2 in raycastResult.Instance:GetChildren() do
						if not (child2:IsA("Decal") or child2:IsA("Texture")) then
							continue
						end

						local clone = child2:Clone()
						clone.Parent = part
					end
				end

				part.Position += createVector(0, -20, 0)
				TweenService:Create(part, TweenInfo.new(Random.new():NextNumber(0.2, 0.4), Enum.EasingStyle.Sine), {
					Position = part.Position + createVector(0, 20, 0)
				}):Play()
				table.insert(v6, part)
			end
		end)
		task.wait(0.017)

		if not parent2:GetAttribute("Active") then
			return
		end

		for _, v13 in v6 do
			vfxUtility.EnableAll(v13, true, vfxUtility.Owned(instance))
		end

		task.wait(1.067)

		if not parent2:GetAttribute("Active") then
			return
		end

		for _, v13 in v6 do
			vfxUtility.EnableAll(v13, false)
			local v14 = v13
			task.delay(1.5, function()
				TweenService:Create(v14, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					Position = v14.Position + createVector(0, -15, 0)
				}):Play()
				DebrisModule:AddItem(v14, 0.3)
			end)
		end

		if clone2 then
			clone2:Destroy()
		end

		if parent2 then
			parent2.Name = "_"
			DebrisModule:AddItem(parent2, 6)
			parent2:SetAttribute("Active", nil)
			vfxUtility.EnableAll(parent2, false)
			vfxUtility.TweenLight(parent2, {
				Time = 0.01,
				Off = true
			})
		end
	elseif p == "Cancel" then
		local child = debree:FindFirstChild(name)
		local pS2insectILcinematic = humanoidRootPart:FindFirstChild("PS2insectILcinematic")

		if pS2insectILcinematic ~= nil then
			pS2insectILcinematic:Destroy()
		end

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