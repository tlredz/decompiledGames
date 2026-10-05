local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local CraterHandler = require(modules.Effects.Craters.CraterHandler)
require(modules.Effects.BoatTween)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local ParticleBudget = require(modules.Effects.ParticleBudget)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

local function SwordTrail(instance, flag: boolean)
	local has_Blade = instance:FindFirstChild("Has_Blade", true)
	local blade

	if not (has_Blade == nil or has_Blade.Parent == nil) then
		blade = has_Blade.Parent:FindFirstChild("Blade")
	end

	if blade == nil then
		return
	end

	if flag == true or flag == nil then
		local clones = {}

		for _, child in pairs(script.Parent.SwordTrail:GetChildren()) do
			local clone = child:Clone()
			clone.Name = "bladetfftians##asd"
			clone.Enabled = not ParticleBudget.Muted(instance, clone)
			ParticleBudget.Rate(clone, instance)
			clone.Parent = blade
			table.insert(clones, clone)

			if not clone:IsA("Trail") then
				continue
			end

			clone.Attachment0 = blade:FindFirstChild("Sword_At_A")
			clone.Attachment1 = blade:FindFirstChild("Sword_At_B")
		end

		if clones ~= nil and clones[1] ~= nil then
			task.delay(5, function()
				if clones[1].Name ~= "--" then
					for _, v in ipairs(clones) do
						v:Destroy()
					end
				end
			end)
		end
	else
		local children = {}

		for _, child in pairs(blade:GetChildren()) do
			if child.Name ~= "bladetfftians##asd" then
				continue
			end

			child.Name = "--"
			child.Enabled = false
			table.insert(children, child)
		end

		if #children > 0 then
			task.delay(1.35, function()
				for _, v in ipairs(children) do
					v:Destroy()
				end
			end)
		end
	end
end

local OuwCraters = require(ReplicatedStorage2.CAM.Client.Modules.Effects.Craters.OuwCraters)
return function(instance, p, p2)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	local upperTorso = instance:FindFirstChild("UpperTorso")

	if humanoidRootPart == nil or upperTorso == nil or p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s Constant_Flux_Effects", instance.Name)
	local child = debree:FindFirstChild(name)

	if p == "Activate" then
		if child then
			child:SetAttribute("Active", false)
			child.Name = "_"
			DebrisModule:AddItem(child, 2)
		end

		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		DebrisModule:AddItem(folder, 8)
		folder:SetAttribute("Active", true)
		local clone = assets.Dragon:Clone()
		clone["Plane.003"].CFrame = humanoidRootPart.CFrame * CFrame.new(
			0.05541229248046875,
			-2.5835342407226562,
			8.55291748046875
		) * CFrame.fromEulerAnglesYXZ(-1.2545099202889484e-14, 3.141592502593994, -1.6292068494294654e-7)
		clone.Parent = folder
		vfxUtility.WeldConstraint(clone["Plane.003"], humanoidRootPart)
		TweenService:Create(clone.PrimaryPart, TweenInfo.new(2), {
			Transparency = 0
		}):Play()
		clone.AnimationController:LoadAnimation(assets.Dragon_Animation):Play()
		local clone2 = script.Sounds.PS2WBblitzDASH:Clone()
		clone2.Parent = clone.PrimaryPart
		clone2:Play()
		SwordTrail(instance)
		task.wait(1)

		if folder ~= nil and folder.Name ~= "_" then
			vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
			vfxUtility.TweenBeams(clone, {
				Time = 0.2
			})
			vfxUtility.TweenLight(clone, {
				Time = 0.2
			})
		end
	elseif p == "Slash" then
		if child == nil then
			return
		end

		local clone = assets.Slash:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = child
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "PS2WBconstantfluxSLASHtrue" .. p2, clone.PrimaryPart, true)
		local rotatingSlashes = clone.SlashBeams.RotatingSlashes
		local rotatingSlashesEnd = clone.SlashBeams.RotatingSlashesEnd
		TweenService:Create(rotatingSlashes, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
			CFrame = rotatingSlashesEnd.CFrame
		}):Play()

		for _, beam in pairs(clone:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			TweenService:Create(beam, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				TextureLength = 0.1,
				Width0 = 0,
				Width1 = 0
			}):Play()
		end

		local pointLight = clone.Swing.PointLightAttachment.PointLight
		local serializedMeshAnim = clone.SwirlEffect.SerializedMeshAnim
		local serializedMeshAnim2 = clone.WindMesh.SerializedMeshAnim
		TweenService:Create(serializedMeshAnim, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			Size = serializedMeshAnim:GetAttribute("EndPartSize"),
			Position = serializedMeshAnim.Position + serializedMeshAnim:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(serializedMeshAnim, TweenInfo.new(1.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Orientation = serializedMeshAnim.Orientation + createVector(0, -550, 0)
		}):Play()
		TweenService:Create(serializedMeshAnim2, TweenInfo.new(1.3, Enum.EasingStyle.Sine), {
			Size = serializedMeshAnim2:GetAttribute("EndPartSize"),
			Position = serializedMeshAnim2.Position + serializedMeshAnim2:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(serializedMeshAnim2, TweenInfo.new(1.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Orientation = serializedMeshAnim2.Orientation + createVector(0, -550, 0)
		}):Play()
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Range = 25,
			Brightness = 0
		}):Play()
		task.delay(0.1, function()
			TweenService:Create(serializedMeshAnim, TweenInfo.new(0.755, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			TweenService:Create(serializedMeshAnim2, TweenInfo.new(1.255, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
		end)
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
	elseif p == "Impact" then
		if child then
			child.Name = "_"
			DebrisModule:AddItem(child, 3)
			child:SetAttribute("Active", false)
			local dragon = child:FindFirstChild("Dragon")

			if dragon then
				DebrisModule:AddItem(dragon, 2)
				vfxUtility.EnableAll(dragon, false)
				vfxUtility.TweenBeams(dragon, {
					Time = 0.02,
					Off = true
				})
				vfxUtility.TweenLight(dragon, {
					Time = 0.2,
					Off = true
				})
				TweenService:Create(dragon.PrimaryPart, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end

			SwordTrail(instance, false)
		end

		local clone = assets.Impact:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -3.5, -6.5) * CFrame.Angles(0, 3.141592653589793, 0))
		clone.Parent = child
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		Cam_Shaker(clone.Smash.Position, "medium_shake_preset")
		DebrisModule:AddItem(clone, 3)
		vfxUtility.PlaySound(sounds, "PS2WBconstantfluxSLASHtrue3IMPACT", clone.PrimaryPart, true)
		local serializedMeshAnim = clone.SwirlEffect.SerializedMeshAnim
		TweenService:Create(serializedMeshAnim, TweenInfo.new(2, Enum.EasingStyle.Quad), {
			Size = serializedMeshAnim:GetAttribute("EndPartSize"),
			Position = serializedMeshAnim.Position + serializedMeshAnim:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(serializedMeshAnim, TweenInfo.new(2.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Orientation = serializedMeshAnim.Orientation + createVector(0, -300, 0)
		}):Play()
		local serializedMeshAnim2 = clone.WindMesh.SerializedMeshAnim
		TweenService:Create(serializedMeshAnim2, TweenInfo.new(1.3, Enum.EasingStyle.Sine), {
			Size = serializedMeshAnim2:GetAttribute("EndPartSize"),
			Position = serializedMeshAnim2.Position + serializedMeshAnim2:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(serializedMeshAnim2, TweenInfo.new(1.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Orientation = serializedMeshAnim2.Orientation + createVector(0, -550, 0)
		}):Play()
		local serializedMeshAnim3 = clone.BlueMesh.SerializedMeshAnim
		TweenService:Create(serializedMeshAnim3, TweenInfo.new(1.355, Enum.EasingStyle.Quad), {
			Position = serializedMeshAnim3.Position + serializedMeshAnim3:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(serializedMeshAnim3.Mesh, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
			Scale = serializedMeshAnim3:GetAttribute("EndMeshScale")
		}):Play()
		TweenService:Create(serializedMeshAnim3, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Orientation = serializedMeshAnim3.Orientation + createVector(0, -100, 0)
		}):Play()
		local serializedMeshAnim4 = clone.NewWindMesh.SerializedMeshAnim
		TweenService:Create(serializedMeshAnim4, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
			Position = serializedMeshAnim4.Position + serializedMeshAnim4:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(serializedMeshAnim4.Mesh, TweenInfo.new(1.3, Enum.EasingStyle.Linear), {
			Scale = serializedMeshAnim4:GetAttribute("EndMeshScale")
		}):Play()
		TweenService:Create(
			serializedMeshAnim4,
			TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				Orientation = serializedMeshAnim4.Orientation + createVector(0, -50, 0)
			}
		):Play()
		local serializedMeshAnim5 = clone.WindyMeshy.SerializedMeshAnim
		TweenService:Create(serializedMeshAnim5, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
			Position = serializedMeshAnim5.Position + serializedMeshAnim5:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(serializedMeshAnim5.Mesh, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
			Scale = serializedMeshAnim5:GetAttribute("EndMeshScale")
		}):Play()
		TweenService:Create(serializedMeshAnim5, TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Orientation = serializedMeshAnim5.Orientation + createVector(0, -75, 0)
		}):Play()
		local pointLight = clone.Root.Attachment.PointLight
		pointLight.Brightness = 8
		pointLight.Range = 25
		task.delay(0.1, function()
			TweenService:Create(serializedMeshAnim, TweenInfo.new(2, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			TweenService:Create(serializedMeshAnim2, TweenInfo.new(1.255, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			TweenService:Create(serializedMeshAnim3.Decal, TweenInfo.new(1.5, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			TweenService:Create(serializedMeshAnim4.Decal, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
			TweenService:Create(serializedMeshAnim5.Decal, TweenInfo.new(1.5, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			TweenService:Create(pointLight, TweenInfo.new(0.455, Enum.EasingStyle.Linear), {
				Range = 4,
				Brightness = 0
			}):Play()
			SwordTrail(instance, false)
		end)
		local center = CFrame.new(clone.Smash.Position) * CFrame.new(0, 5, 0)
		OuwCraters.Scales({
			Center = center
		})
		CraterHandler.new("Break", center, {
			PartCount = 15,
			BlockSize = { 0.5, 1.5 },
			Range = 30,
			Height = { 30, 90 },
			Radius = 15,
			HoldTime = 1.5
		})
	elseif p == "Cancel" then
		if child then
			child.Name = "_"
			DebrisModule:AddItem(child, 3)
			child:SetAttribute("Active", false)
		end

		if not child then
			return
		end

		local dragon = child:FindFirstChild("Dragon")

		if dragon then
			DebrisModule:AddItem(dragon, 2)
			vfxUtility.EnableAll(dragon, false)
			vfxUtility.TweenBeams(dragon, {
				Time = 0.02,
				Off = true
			})
			vfxUtility.TweenLight(dragon, {
				Time = 0.2,
				Off = true
			})
			TweenService:Create(dragon.PrimaryPart, TweenInfo.new(0.5), {
				Transparency = 1
			}):Play()
		end

		SwordTrail(instance, false)
	end
end