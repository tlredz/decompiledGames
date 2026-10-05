local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local parent2 = workspace.Debree:FindFirstChild(game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd")

if parent2 == nil then
	parent2 = Instance.new("Folder", workspace.Debree)
	parent2.Name = game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd"
end

local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterHandler)
require(modules.Effects.BoatTween)
local OuwCraters = require(ReplicatedStorage2.CAM.Client.Modules.Effects.Craters.OuwCraters)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local ParticleBudget = require(modules.Effects.ParticleBudget)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

local function SwordTrail(parent, flag: boolean)
	local has_Blade = parent:FindFirstChild("Has_Blade", true)
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
			clone.Enabled = not ParticleBudget.Muted(parent, clone)
			ParticleBudget.Rate(clone, parent)
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
					for _, v2 in ipairs(clones) do
						v2:Destroy()
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
				for _, v2 in ipairs(children) do
					v2:Destroy()
				end
			end)
		end
	end
end

return function(parent, p, p2, cframe: CFrame)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart") or parent.PrimaryPart
	local upperTorso = parent:FindFirstChild("UpperTorso")

	if humanoidRootPart == nil or upperTorso == nil or p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Start" then
		local clone = assets.Startup:Clone()
		clone.Parent = parent2
		clone.CFrame = humanoidRootPart.CFrame
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(parent))
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "Hold", humanoidRootPart, true)
		local clone2 = assets.StartHighlight:Clone()
		clone2.Parent = parent
		TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			OutlineTransparency = 1,
			FillTransparency = 1
		}):Play()
		DebrisModule:AddItem(clone2, 2)
		SwordTrail(parent)
	elseif p == "Release" then
		local clone = assets.WhirlPoolVFX:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = parent2
		DebrisModule:AddItem(clone, 2)
		vfxUtility.EmitAll(clone.JumpVFX, vfxUtility.Owned(parent))
		vfxUtility.EmitAll(clone.BeamParticlesEmit, vfxUtility.Owned(parent))
		vfxUtility.TweenLight(clone, {
			Time = 0.2,
			Del = 0.1,
			DelayTimer = 0.455
		})
		vfxUtility.PlaySound(sounds, "Release", humanoidRootPart, true)
		task.delay(0.455, function()
			SwordTrail(parent, false)
		end)
		Cam_Shaker(clone.Root.Position, "medium_shake_preset")
		TweenService:Create(clone.SlashBeam, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
			Orientation = clone.SlashBeam.Orientation + createVector(0, 350, 0)
		}):Play()

		for _, beam in clone:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local width0 = beam.Width0
			local width1 = beam.Width1
			local textureLength = beam.TextureLength
			beam.Width0 = 0
			beam.Width1 = 0
			local tween = TweenService:Create(
				beam,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
				{
					Width0 = width0 + 5,
					Width1 = width1 + 5
				}
			)
			tween:Play()
			local v2 = beam
			tween.Completed:Connect(function()
				TweenService:Create(v2, TweenInfo.new(0.325, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0,
					TextureLength = textureLength / 3
				}):Play()
			end)
		end

		local meshes = clone.Meshes
		TweenService:Create(meshes.Swirl, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Orientation = meshes.Swirl.Orientation + createVector(0, 350, 0)
		}):Play()
		TweenService:Create(meshes.Swirl, TweenInfo.new(0.755, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = meshes.SwirlEnd.Size,
			Position = meshes.SwirlEnd.Position
		}):Play()
		task.delay(0.1, function()
			TweenService:Create(meshes.Swirl, TweenInfo.new(0.455, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
		end)
	elseif p == "Basin Start" then
		local clone = assets.WAterFallBasinStartup:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = parent2
		vfxUtility.EmitAll(clone, vfxUtility.Owned(parent))
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "PS2WBwaterbasinSTARTSWING", clone.PrimaryPart, true)
		local serializedMeshAnim = clone.SwirlEffect.SerializedMeshAnim
		local serializedMeshAnim2 = clone.Shockwave.SerializedMeshAnim
		local pointLight = clone.Startup.PointLight
		pointLight.Brightness = 6
		pointLight.Range = 3
		vfxUtility.EmitAll(clone.Startup, vfxUtility.Owned(parent))
		TweenService:Create(serializedMeshAnim, TweenInfo.new(0.755, Enum.EasingStyle.Quad), {
			Size = serializedMeshAnim:GetAttribute("EndPartSize"),
			Position = serializedMeshAnim.Position + serializedMeshAnim:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(serializedMeshAnim, TweenInfo.new(1.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Orientation = serializedMeshAnim.Orientation + createVector(0, 550, 0)
		}):Play()
		TweenService:Create(serializedMeshAnim2, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
			Size = serializedMeshAnim2:GetAttribute("EndPartSize"),
			Position = serializedMeshAnim2.Position + serializedMeshAnim2:GetAttribute("CFrameDiff").Position
		}):Play()
		TweenService:Create(serializedMeshAnim2, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Orientation = serializedMeshAnim2.Orientation + createVector(0, 550, 0)
		}):Play()
		task.delay(0.1, function()
			TweenService:Create(serializedMeshAnim, TweenInfo.new(0.755, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			TweenService:Create(serializedMeshAnim2, TweenInfo.new(0.655, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				Brightness = 0,
				Range = 25
			}):Play()
		end)
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")
	elseif p == "Basin Slam" then
		OuwCraters.Scales({
			TweenInInfo = TweenInfo.new(0.25),
			ScaleMult = 1.15,
			Count = 8,
			Duration = 1.5,
			Center = humanoidRootPart.CFrame * CFrame.new(0, 0, -10)
		})
		local v2 = cframe * CFrame.new(0, 0, 13)
		local clone = assets.WaterFallBasinEnabling:Clone()
		clone:PivotTo(v2)
		clone.Parent = parent2
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(parent, 0.3))
		DebrisModule:AddItem(clone, 3)
		local clone2 = assets.WaterFallBasinEmit:Clone()
		clone2:PivotTo(v2)
		clone2.Parent = parent2
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(parent))
		DebrisModule:AddItem(clone2, 3)
		vfxUtility.PlaySound(sounds, "PS2WBwaterbasinBASIN" .. p2, clone2.PrimaryPart, true)
		vfxUtility.TweenBeams(clone2, {
			Time = 0.2,
			Del = 0.2,
			DelayTimer = 0.25
		})
		vfxUtility.TweenLight(clone2, {
			Time = 1.5,
			Del = 0.35
		})
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")

		if p2 == 2 then
			SwordTrail(parent, false)
		end
	elseif p == "Cancel" then
		SwordTrail(parent, false)
	end
end