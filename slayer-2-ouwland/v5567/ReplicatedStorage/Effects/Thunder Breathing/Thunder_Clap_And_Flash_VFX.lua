local createVector = vector.create
local Debris = game:GetService("Debris")
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.CAM.Client.Modules
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local CraterEffects = require(modules.Effects.Craters.CraterEffects)
local debree = workspace.Debree
local sounds = script:FindFirstChild("Sounds")
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage.CAM.DebrisModule)
local Ouwmit = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

local function LTN()
	local clone = script.NewAssets.ColorCorrection:Clone()
	clone.Parent = workspace.Camera
	TweenService:Create(clone, tweenInfo, {
		TintColor = Color3.fromRGB(255, 255, 255)
	}):Play()
	TweenService:Create(clone, tweenInfo2, {
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	}):Play()
	DebrisModule:AddItem(clone, 0.2)
end

return function(instance, p, list)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local name = string.format("%s_%s_Effects", instance.Name, script.Name)

	if p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		if p ~= "DashOrCancel" then
			return
		end

		p = "Cancel"
	end

	local v2 = p == "DashOrCancel" and "Dash" or p

	if v2 == "Startup" then
		if debree:FindFirstChild(name) then
			local child = debree:FindFirstChild(name)
			child.Name = "_"
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 3)
			vfxUtility.EnableAll(child, false)
			vfxUtility.TweenLight(child, {
				Time = 0.1,
				Off = true
			})
		end

		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		Debris:AddItem(folder, 8)
		folder:SetAttribute("Active", true)
		local v3 = vfxUtility.PlaySound(sounds, "PS2thunderbreathTCaFholdloop", humanoidRootPart)
		local clone = script.NewAssets.ThunderDashStartUp:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = folder
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "PS2thunderbreathTCaFstart", humanoidRootPart, true)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			createVector(0, -50, 0),
			RaycastHelper.Crater
		)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		local color

		if raycastResult then
			local v4 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			color = raycastResult.Instance.Color
			clone.Startup.raycastdust.WorldCFrame = v4
			clone.Startup.GroundCracks.WorldCFrame = v4
			clone.GroundFX.CFrame = v4
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Dust", "Rocks" }
		} or nil) or nil))
		CraterEffects.new("RisingRocks", instance, {
			Iterations = "Held",
			BlockSize = { 0.5, 3 },
			Radius = 10,
			Height = { 8, 60 },
			AnimationSpeed = 4,
			IterationName = "CSI_" .. instance.Name,
			Range = 30,
			PartCount = 1,
			delayTime = 0.025
		})
		task.spawn(function()
			while folder ~= nil and folder.Parent ~= nil and folder:GetAttribute("Active") do
				task.wait(0.05)
			end

			if v3.Parent == humanoidRootPart then
				v3:Destroy()
			end
		end)
		local clone2 = script.NewAssets.ZenitsuthunderclapHighlight:Clone()
		clone2.Parent = folder
		clone2.Adornee = instance
		clone2.Name = "Zenitsu_Highlight"
		TweenService:Create(clone2, TweenInfo.new(0.25), {
			OutlineTransparency = 0
		}):Play()
		local clone3 = script.NewAssets.HoldCharge:Clone()
		clone3:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.2, 0))
		clone3.Parent = folder
		Ouwmit.Enable(clone3, true, Ouwmit.Owned(instance))
	elseif v2 == "Dash" then
		local v3, v4 = table.unpack(list)
		local v5 = CFrame.new(v3.Position) * v4.Rotation
		local parent = debree:FindFirstChild(name)

		if parent == nil then
			parent = Instance.new("Folder")
			parent.Name = name
			parent.Parent = debree
			Debris:AddItem(parent, 4)
		else
			parent.Name = "_"
			DebrisModule:AddItem(parent, 4)

			if parent:GetAttribute("Active") then
				parent:SetAttribute("Active", false)
			end

			local holdCharge = parent:FindFirstChild("HoldCharge")

			if holdCharge then
				DebrisModule:AddItem(holdCharge, 2)
				Ouwmit.Enable(holdCharge, false)
			end
		end

		local clone = script.NewAssets.Startup:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
		clone.Parent = parent
		TweenService:Create(clone.PointLight, TweenInfo.new(0.2), {
			Brightness = 0,
			Range = 0
		}):Play()
		CraterEffects.endConnection(instance, "CSI_" .. instance.Name)
		local zenitsu_Highlight = parent:FindFirstChild("Zenitsu_Highlight")

		if zenitsu_Highlight ~= nil then
			TweenService:Create(zenitsu_Highlight, TweenInfo.new(0.15), {
				FillTransparency = 1.5
			}):Play()
			task.delay(0.35, function()
				if zenitsu_Highlight then
					TweenService:Create(zenitsu_Highlight, TweenInfo.new(0.15), {
						OutlineTransparency = 1
					}):Play()
					DebrisModule:AddItem(zenitsu_Highlight, 0.15)
				end
			end)
		end

		local raycastResult = workspace:Raycast(v5.Position, v5.UpVector * -50, RaycastHelper.Crater)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		local color

		if raycastResult and raycastResult.Instance then
			local v7 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			color = raycastResult.Instance.Color
			clone.raycastdust.WorldCFrame = v7
			clone.GroundCracks.CFrame = v7
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))
		task.wait(0.1)
		Cam_Shaker(humanoidRootPart.Position, "medium_shake_preset")
		local clone2 = script.NewAssets.TpBeams:Clone()
		local cframe = CFrame.new(0, 3, -13)
		clone2.PartBeam1.CFrame = v4 * cframe
		clone2.PartBeam2.CFrame = v5 * cframe
		clone2.Parent = parent
		DebrisModule:AddItem(clone2, 2)
		local clone3 = script.NewAssets.EndEmit:Clone()
		clone3:PivotTo(v4 * CFrame.new(0, 2, 3))
		clone3.Parent = parent
		task.spawn(function()
			local clone4 = script.NewAssets.DashBeams:Clone()
			clone4:PivotTo(CFrame.new(v5.Position, v4.Position) * CFrame.new(
				0,
				2,
				-vector.magnitude(v4.Position - v5.Position) + 25.5
			))
			clone4.Parent = parent
			local dash2StartBeam = clone4.Dash2StartBeam
			local dash2EndBeam = clone4.Dash2EndBeam
			local beam = dash2StartBeam.A1.Set1.Beam
			local lightning2 = dash2StartBeam.A1.Set1.Lightning2
			task.wait(0.033)
			TweenService:Create(
				dash2EndBeam,
				TweenInfo.new(0.183, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = dash2EndBeam.CFrame * CFrame.new(0, 0, -50)
				}
			):Play()
			TweenService:Create(beam, TweenInfo.new(0.815), {
				TextureLength = 0
			}):Play()
			task.wait(0.35)
			TweenService:Create(lightning2, TweenInfo.new(0.067), {
				TextureLength = 0,
				Width0 = 0,
				Width1 = 0
			}):Play()
			TweenService:Create(
				dash2StartBeam,
				TweenInfo.new(0.467, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					CFrame = dash2StartBeam.CFrame * CFrame.new(0, 0, -46.576)
				}
			):Play()
			task.wait(0.05)
			TweenService:Create(beam, TweenInfo.new(0.067), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end)
		task.delay(0.2, function()
			TweenService:Create(
				clone2.PartBeam1.FrontSet.Left,
				TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					TextureSpeed = 0
				}
			):Play()
			TweenService:Create(
				clone2.PartBeam1.FrontSet.Right,
				TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					TextureSpeed = 0
				}
			):Play()
			TweenService:Create(
				clone2.PartBeam1.FrontSet.Left,
				TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					TextureLength = 0
				}
			):Play()
			TweenService:Create(
				clone2.PartBeam1.FrontSet.Right,
				TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					TextureLength = 0
				}
			):Play()
			task.wait(0.2)
			vfxUtility.TweenBeamTransparency(clone2.PartBeam2, 1, 0.2)
			vfxUtility.TweenBeamTransparency(clone2.PartBeam1, 1, 0.5)
		end)
		local raycastResult2 = workspace:Raycast(v4.Position + v4.upVector * 5, v4.upVector * -50, RaycastHelper.Crater)
		local color2

		if not (raycastResult2 == nil or raycastResult2.Instance == nil) then
			local v7 = CFrame.new(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			color2 = raycastResult2.Instance.Color
			clone3.Startup.CFrame = v7 * CFrame.Angles(3.141592653589793, 0, 0)
			clone3.DashEnd.GroundVFX.CFrame = v7 * CFrame.new(0, 1.5, 0)
		end

		TweenService:Create(clone3.Root.PointLight, TweenInfo.new(0.2), {
			Brightness = 0,
			Range = 0
		}):Play()
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance, color2 ~= nil and ({
			Color = color2,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))

		if instance == game.Players.LocalPlayer.Character or vector.magnitude(workspace.CurrentCamera.CFrame.Position - v4.Position) < 30 then
			LTN()
		end

		vfxUtility.PlaySound(sounds, "PS2thunderbreathTCaFlaunch", humanoidRootPart, true)
	elseif v2 == "LastSlash" then
		local _, v3 = table.unpack(list)
		local folder = Instance.new("Folder")
		folder.Name = name .. "-Final"
		folder.Parent = workspace.Debree
		DebrisModule:AddItem(folder, 3)
		local clone = script.NewAssets.WindupSlash:Clone()
		clone.Startup.CFrame = v3 * CFrame.new(0, 0, 0)
		clone.Parent = folder
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")
		local clone2 = script.NewAssets.ZenitsuthunderclapHighlight:Clone()
		clone2.Parent = instance
		clone2.Adornee = instance
		clone2.Name = "Zenitsu_Highlight"
		TweenService:Create(clone2, TweenInfo.new(0.25), {
			OutlineTransparency = 0
		}):Play()
		local clone3 = script.Sounds.PS2thunderclapflashSECONDSLASH:Clone()
		clone3.Parent = clone.Startup
		clone3:Play()
		task.wait(0.55)
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		local clone4 = script.NewAssets.LightningSlash:Clone()
		clone4:PivotTo(v3)
		clone4.Parent = folder
		Ouwmit.Emit(clone4, Ouwmit.Owned(instance))
		TweenService:Create(clone2, TweenInfo.new(0.5), {
			FillTransparency = 1.5
		}):Play()
		task.wait(0.55)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.65,
			SustainTime = 0.14,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})

		if clone4 ~= nil then
			clone4:Destroy()
		end

		local raycastResult = workspace:Raycast(v3.Position + v3.upVector * 5, v3.upVector * -50, RaycastHelper.Crater)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			color = raycastResult.Instance.Color
		end

		local clone5 = script.NewAssets.LightningSlashEndEmit:Clone()
		clone5:PivotTo(v3)
		clone5.Parent = folder
		Ouwmit.Emit(clone5, Ouwmit.Owned(instance, color ~= nil and {
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "dusteffasd" }
		} or false))
		TweenService:Create(clone2, TweenInfo.new(1), {
			OutlineTransparency = 1,
			FillTransparency = 1
		}):Play()
		DebrisModule:AddItem(clone2, 1)
	elseif v2 == "DamageHit" then
		if list == nil then
			return
		end

		if list ~= nil then
			for _, v3 in ipairs(list) do
				local primaryPart = v3.PrimaryPart

				if primaryPart == nil then
					continue
				end

				local clone = script.NewAssets.EmitStun:Clone()
				clone.Parent = primaryPart
				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
				DebrisModule:AddItem(clone, 0.6)
				local clone2 = script.Sounds.PS2thunderclapflashSECONDSLASHvictimexplode:Clone()
				clone2.Parent = clone
				clone2:Play()
			end
		end
	elseif v2 == "WindUpvictimEFfect" then
		if list == nil then
			return
		end

		local clones = {}

		if list ~= nil then
			for _, adornee in ipairs(list) do
				local lowerTorso = adornee:FindFirstChild("LowerTorso")

				if lowerTorso == nil then
					continue
				end

				local clone = script.NewAssets.StunVFX:Clone()
				clone:PivotTo(lowerTorso.CFrame)
				clone.Parent = lowerTorso
				clone.WeldConstraint.Part1 = lowerTorso
				local clone2 = script.Sounds.PS2thunderclapflashSECONDSLASHvictimstun:Clone()
				clone2.Parent = clone
				clone2:Play()
				Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
				local clone3 = script.NewAssets.YellowHighlight:Clone()
				clone3.Parent = clone
				clone3.Adornee = adornee
				table.insert(clones, clone3)
				table.insert(clones, clone)
				DebrisModule:AddItem(clone, 4)
			end
		end

		task.delay(2.5, function()
			for _, highlight in ipairs(clones) do
				if highlight:IsA("Highlight") then
					TweenService:Create(highlight, TweenInfo.new(1), {
						FillTransparency = 1,
						OutlineTransparency = 1
					}):Play()
				else
					Ouwmit.Enable(highlight, false)
				end
			end
		end)
	elseif v2 == "Cancel" then
		local child = debree:FindFirstChild(name)

		if child == nil then
			return
		end

		if child then
			child.Name = "_"
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 3)
			Ouwmit.Enable(child, false)
			vfxUtility.TweenLight(child, {
				Time = 0.1,
				Off = true
			})
		end

		local zenitsu_Highlight = child:FindFirstChild("Zenitsu_Highlight")

		if zenitsu_Highlight then
			TweenService:Create(zenitsu_Highlight, TweenInfo.new(0.15), {
				OutlineTransparency = 1,
				FillTransparency = 1
			}):Play()
			DebrisModule:AddItem(zenitsu_Highlight, 0.15)
		end

		CraterEffects.endConnection(instance, "CSI_" .. instance.Name)
	end
end