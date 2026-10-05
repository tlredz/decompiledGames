local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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

local v = {
	FadeInTime = 0,
	Frequency = 0.055,
	Amplitude = 0.5,
	SustainTime = 0.14,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(3.5, 3.5, 3.5)
}
return function(instance, p, list)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local rightHand = instance:FindFirstChild("RightHand")

	if not humanoidRootPart then
		return
	end

	local name = string.format("%s_%s_Effects", instance.Name, script.Name)

	if p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local child = game.Workspace.Debree:FindFirstChild(name)

	if p == "Hold" then
		if child ~= nil then
			child:Destroy()
		end

		vfxUtility.PlaySound(sounds, "PS2insectTFstart", humanoidRootPart, true)
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		folder:SetAttribute("Active", true)
		DebrisModule:AddItem(folder, 5)
		local spawnSwordAura = SpawnSwordAura(instance)
		spawnSwordAura.Parent = folder
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		local instance2

		if raycastResult then
			instance2 = raycastResult.Instance
		end

		local clone = assets.StartupEmit:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0.5, 0))
		clone.Parent = debree
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		vfxUtility.ChangeDustColor(instance2, clone.Startup.raycastdust)
		vfxUtility.TweenLight(clone, {
			Time = 0.25,
			Del = 0.4
		})
		DebrisModule:AddItem(clone, 2)
		local clone2 = assets.FakeRightHand:Clone()
		clone2.CFrame = rightHand.CFrame
		clone2.Parent = debree
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		vfxUtility.WeldConstraint(clone2, rightHand)
		DebrisModule:AddItem(clone2, 2)
	elseif child == nil and p ~= "Explosion" then
		return
	end

	if p == "Dash" then
		local v3, cFrame = unpack(list)

		if child then
			child:SetAttribute("Active", false)
			child.Name = "_"
		end

		vfxUtility.PlaySound(sounds, "PS2insectTFthrust", humanoidRootPart, true)
		local clone = assets.Wind_Beams:Clone()
		clone:PivotTo(CFrame.new(v3.Position, cFrame.Position))
		clone.Parent = child
		DebrisModule:AddItem(clone, 1)
		clone.EndRootPart:PivotTo(clone.StartRootPart.StartRootStuff.CFrame)
		TweenService:Create(clone.EndRootPart.EndRootStuff, TweenInfo.new(0.13, Enum.EasingStyle.Quint), {
			CFrame = cFrame
		}):Play()
		vfxUtility.TweenBeams(clone, {
			Time = 0.12
		})
		vfxUtility.TweenBeamTransparency(clone, 1, 1)

		for _, descendant in clone:GetDescendants() do
			if descendant.ClassName == "Beam" then
				TweenService:Create(descendant, TweenInfo.new(1.1), {
					TextureSpeed = 0
				}):Play()
			end
		end

		local raycastResult = workspace:Raycast(
			CFrame.new(v3.Position, cFrame.Position).Position,
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		local instance2

		if raycastResult then
			instance2 = raycastResult.Instance
		end

		local clone2 = assets.DashStart:Clone()
		clone2:PivotTo(CFrame.new(v3.Position, cFrame.Position))
		clone2.Parent = child
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		vfxUtility.ChangeDustColor(instance2, { clone2.GroundVFX.raycastdust, clone2.GroundVFX.raycastdust2 })
		DebrisModule:AddItem(clone2, 3)
		vfxUtility.TweenLight(clone2, {
			Time = 0.2,
			Del = 0.3,
			DelayTimer = 0.15
		})
		vfxUtility.TweenBeams(clone2, {
			Time = 0.05
		})
		local clone3 = assets.Thrust:Clone()
		clone3:PivotTo(CFrame.new(v3.Position, cFrame.Position))
		clone3.Parent = child
		vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
		Cam_Shaker(humanoidRootPart.Position, v)
		local meshes = clone3.Meshes
		local glowMesh = meshes.GlowMesh
		local ring = meshes.Ring
		local twirl = meshes.Twirl
		local skinnyMesh = meshes.SkinnyMesh
		glowMesh.Main.Decal.Transparency = 0
		TweenService:Create(glowMesh.Main, TweenInfo.new(0.75, Enum.EasingStyle.Quint), {
			CFrame = glowMesh.End_Values.CFrame
		}):Play()
		TweenService:Create(glowMesh.Main.Mesh, TweenInfo.new(0.75, Enum.EasingStyle.Quint), {
			Scale = glowMesh.Main.Mesh.Scale
		}):Play()
		ring.SerializedMeshAnim.Transparency = 0.75
		TweenService:Create(ring.SerializedMeshAnim, TweenInfo.new(0.355, Enum.EasingStyle.Quad), {
			Size = ring.SerializedMeshAnim:GetAttribute("EndPartSize"),
			CFrame = ring.SerializedMeshAnim.CFrame * ring.SerializedMeshAnim:GetAttribute("CFrameDiff")
		}):Play()
		skinnyMesh.SerializedMeshAnim.Transparency = 0
		TweenService:Create(skinnyMesh.SerializedMeshAnim, TweenInfo.new(0.155, Enum.EasingStyle.Quad), {
			Size = skinnyMesh.SerializedMeshAnim:GetAttribute("EndPartSize"),
			CFrame = skinnyMesh.SerializedMeshAnim.CFrame * skinnyMesh.SerializedMeshAnim:GetAttribute("CFrameDiff")
		}):Play()
		twirl.SerializedMeshAnim.Transparency = 0.45
		TweenService:Create(twirl.SerializedMeshAnim, TweenInfo.new(0.955, Enum.EasingStyle.Quad), {
			Size = twirl.SerializedMeshAnim:GetAttribute("EndPartSize"),
			Position = twirl.SerializedMeshAnim.Position + twirl.SerializedMeshAnim:GetAttribute("CFrameDiff").Position
		}):Play()
		task.delay(0.1, function()
			TweenService:Create(glowMesh.Main.Decal, TweenInfo.new(0.155, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
			TweenService:Create(ring.SerializedMeshAnim, TweenInfo.new(0.125, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(skinnyMesh.SerializedMeshAnim, TweenInfo.new(0.125, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(twirl.SerializedMeshAnim, TweenInfo.new(0.855, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			DebrisModule:AddItem(clone3, 1)
		end)
		local v5 = (v3.Position - cFrame.Position).Magnitude + 5
		local v6 = 12 * (v5 / 30)
		local distance = math.clamp(v5, 0, v5)
		CraterHandler.new("Path", CFrame.lookAt(v3.Position, cFrame.Position), {
			BlockSize = { 2, 2 },
			Distance = distance,
			Width = { 5, 5 },
			StepSize = distance * (1 / v6),
			HoldTime = 0.7,
			IterateSpeed = {
				Entrance = "Stepped",
				EntranceDivision = "Iterate",
				EntranceSpeed = 0.1 / v6
			},
			FlourishTypes = {
				Exit = "Melt",
				ExitDivision = "Iterate",
				ExitSpeed = 1
			}
		})
		vfxUtility.TweenBeams(clone2, {
			Time = 0.4,
			Off = true
		})
		task.wait(0.1)
		local raycastResult2 = workspace:Raycast(cFrame.Position, createVector(0, -20, 0), vfxUtility.RayParams.Map)
		local instance3

		if raycastResult2 then
			instance3 = raycastResult2.Instance
		end

		local clone4 = assets.DashEnd:Clone()
		clone4:PivotTo(cFrame)
		clone4.Parent = child
		vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone4, 3)
		vfxUtility.TweenLight(clone4, {
			Time = 0.05,
			Del = 0.1,
			DelayTimer = 0.15
		})
		vfxUtility.ChangeDustColor(
			instance3,
			{ clone4.GroundVFX.raycastdust, clone4.GroundVFX.raycastdust2, clone4.GroundVFX.raycastdust3 }
		)

		if child then
			vfxUtility.EnableAll(child, false)
			DebrisModule:AddItem(child, 2)
		end
	elseif p == "Explosion" then
		local v3 = unpack(list)
		workspace:Raycast(v3.Position, createVector(0, -20, 0), vfxUtility.RayParams.Map)
		local clone = assets.PoisonExplosion:Clone()
		clone:PivotTo(v3)
		clone.Parent = workspace.Debree
		vfxUtility.PlaySound(sounds, "PS2insectTFpop", clone.PrimaryPart, true)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
		vfxUtility.TweenLight(clone, {
			Time = 0.2,
			Del = 0.3
		})
	elseif p == "Uppercut" then
		if child then
			child.Name = "_"
			vfxUtility.EnableAll(child, false)
			DebrisModule:AddItem(child, 2)
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		local instance2

		if raycastResult then
			instance2 = raycastResult.Instance
		end

		vfxUtility.PlaySound(sounds, "PS2insectTFuppercut", humanoidRootPart, true)
		local clone = assets.Uppercut:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = child
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		vfxUtility.TweenLight(clone, {
			Time = 0.2,
			Del = 0.3
		})
		DebrisModule:AddItem(clone, 2)
		vfxUtility.ChangeDustColor(instance2, { clone.Jump.raycastdust, clone.Jump.raycastdust2 })
		Cam_Shaker(humanoidRootPart.Position, v)
		local meshes = clone.Thrust.Meshes
		local glowMesh = meshes.GlowMesh
		local ring = meshes.Ring
		local twirl = meshes.Twirl
		local skinnyMesh = meshes.SkinnyMesh
		glowMesh.Main.Decal.Transparency = 0
		skinnyMesh.SerializedMeshAnim.Transparency = 0
		twirl.SerializedMeshAnim.Transparency = 0.45
		ring.SerializedMeshAnim.Transparency = 0.75
		TweenService:Create(glowMesh.Main, TweenInfo.new(0.75, Enum.EasingStyle.Quint), {
			CFrame = glowMesh.End_Values.CFrame
		}):Play()
		TweenService:Create(glowMesh.Main.Mesh, TweenInfo.new(0.75, Enum.EasingStyle.Quint), {
			Scale = glowMesh.End_Values.Mesh.Scale
		}):Play()
		TweenService:Create(ring.SerializedMeshAnim, TweenInfo.new(0.255, Enum.EasingStyle.Quad), {
			Size = ring.SerializedMeshAnim:GetAttribute("EndPartSize"),
			CFrame = ring.SerializedMeshAnim.CFrame * ring.SerializedMeshAnim:GetAttribute("CFrameDiff")
		}):Play()
		TweenService:Create(skinnyMesh.SerializedMeshAnim, TweenInfo.new(0.155, Enum.EasingStyle.Quad), {
			Size = skinnyMesh.SerializedMeshAnim:GetAttribute("EndPartSize"),
			CFrame = skinnyMesh.SerializedMeshAnim.CFrame * skinnyMesh.SerializedMeshAnim:GetAttribute("CFrameDiff")
		}):Play()
		TweenService:Create(twirl.SerializedMeshAnim, TweenInfo.new(0.855, Enum.EasingStyle.Quad), {
			Size = twirl.SerializedMeshAnim:GetAttribute("EndPartSize"),
			Position = twirl.SerializedMeshAnim.Position + twirl.SerializedMeshAnim:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(twirl.SerializedMeshAnim, TweenInfo.new(1.85, Enum.EasingStyle.Quint), {
			CFrame = ring.SerializedMeshAnim.CFrame * ring.SerializedMeshAnim:GetAttribute("CFrameDiff").Rotation * CFrame.Angles(
				0,
				2.827433388230814,
				0
			)
		}):Play()
		task.delay(0.1, function()
			TweenService:Create(glowMesh.Main.Decal, TweenInfo.new(0.255, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
			TweenService:Create(ring.SerializedMeshAnim, TweenInfo.new(0.125, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(twirl.SerializedMeshAnim, TweenInfo.new(0.655, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
		end)
	elseif p == "Cancel" and child then
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