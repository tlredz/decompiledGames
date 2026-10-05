local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local TweenService = game:GetService("TweenService")
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
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

return function(adornee, p: string, cFrame, cFrame2: CFrame, part)
	if adornee == nil or p == nil then
		return
	end

	local formatted = `{adornee.Name} - {script.Name}`
	local humanoidRootPart = adornee:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or p ~= "Cancel" and vector.magnitude(currentCamera.CFrame.Position - humanoidRootPart.Position) >= 250 then
		return
	end

	local child = workspace.Debree:FindFirstChild(formatted)

	if (p == "Cancel" or p == "Release") and child ~= nil then
		child.Name = "--"
		DebrisModule:AddItem(child, 2)
		local orbRiceSpirit = child:FindFirstChild("OrbRiceSpirit")

		if orbRiceSpirit ~= nil then
			Ouwmit.Emit(orbRiceSpirit.GroundVFX.PointLight, Ouwmit.Owned(adornee))
		end

		Ouwmit.Enable(child, false)
		local casterHighlight = child:FindFirstChild("CasterHighlight")

		if casterHighlight ~= nil then
			TweenService:Create(casterHighlight, TweenInfo.new(0.5), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
		end
	end

	if p == "Init" then
		if child ~= nil then
			child:Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Name = formatted
		folder.Parent = workspace.Debree
		DebrisModule:AddItem(folder, 7)
		local clone = script.NewAssets.YellowHighlight:Clone()
		clone.Parent = folder
		TweenService:Create(clone, TweenInfo.new(0.5), {
			FillTransparency = 1.35,
			OutlineTransparency = 0
		}):Play()
		clone.Name = "CasterHighlight"
		clone.Adornee = adornee
		local clone2 = script.NewAssets.OrbRiceSpirit:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.6, 0))
		local v = tonumber(cFrame)

		if v ~= nil and v > 1 then
			clone2:ScaleTo((math.min(v, 3.5)))
		end

		clone2.Parent = folder
		local clone3 = script.Sounds.Initiate:Clone()
		clone3.Parent = clone2.GroundVFX
		clone3:Play()
		local clone4 = script.Sounds.LoopedThunder:Clone()
		clone4.Parent = clone2.GroundVFX
		clone4:Play()
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -30,
			RaycastHelper.Crater
		)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			local cFrame4 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 1, 0)
			clone2.Beams:PivotTo(cFrame4)
			clone2.GroundVFX.CFrame = cFrame4
			color = raycastResult.Instance.Color
		end

		Ouwmit.Enable(clone2, nil, Ouwmit.Owned(adornee, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks" }
		} or nil) or nil))
		local pivot = clone2.Beams:GetPivot()
		local cFrame3 = clone2.GroundVFX.CFrame
		local cam_Shaker = Cam_Shaker(humanoidRootPart, {
			FadeInTime = 0,
			Frequency = 0.07,
			Amplitude = 0.25,
			SustainTime = 5,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
		local v3

		if v == nil or not (v > 1) then
			v3 = 0.05
		else
			v3 = 0.2
		end

		while folder ~= nil and folder.Name ~= "--" and folder.Parent ~= nil do
			local scale = clone2:GetScale()

			if scale < 3.5 then
				clone2:ScaleTo(scale + v3)
				clone2.Beams:PivotTo(pivot)
				clone2.GroundVFX.CFrame = cFrame3
				clone2.GroundVFX.PointLight.Range += 0.1
			end

			task.wait(0.1)
		end

		TweenService:Create(clone4, TweenInfo.new(0.5), {
			Volume = 0
		}):Play()
		cam_Shaker:Destroy()
	elseif p == "Cancel" then
		local child2 = workspace.Debree:FindFirstChild(formatted .. " - TP CONTENT")

		if child2 ~= nil then
			child2.Name = "--"
			Ouwmit.Enable(child2, false)
		end
	elseif p == "Disappear" then
		local clone = script.NewAssets.DepartureEffect:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0))
		clone.Parent = workspace.Debree
		local clone2 = script.Sounds.Disappear:Clone()
		clone2.Parent = clone.Startup
		clone2:Play()
		DebrisModule:AddItem(clone, 2)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -25,
			RaycastHelper.Crater
		)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			local cFrame3 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 0.25, 0)
			clone.Startup.CFrame = cFrame3
			color = raycastResult.Instance.Color
			clone.Startup.SpawnEmit.WorldCFrame = humanoidRootPart.CFrame
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(adornee, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks" },
			ColorBlacklist = "GroundShatter"
		} or nil) or nil))
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 1,
			Count = 7,
			ScaleMult = 0.5,
			Radius = 5
		})
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
	elseif p == "ReAppear" then
		local clone = script.NewAssets.ReturnEffect:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0))
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 2)
		local clone2 = script.Sounds.ReAppear:Clone()
		clone2.Parent = clone.Startup
		clone2:Play()
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -25,
			RaycastHelper.Crater
		)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			local cFrame3 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 0.25, 0)
			clone.Startup.CFrame = cFrame3
			color = raycastResult.Instance.Color
			clone.Startup.SpawnEmit.WorldCFrame = humanoidRootPart.CFrame
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(adornee, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks" },
			ColorBlacklist = "GroundShatter"
		} or nil) or nil))
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 1,
			Count = 8
		})
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
	elseif p == "TP" then
		if cFrame == nil or cFrame2 == nil or part == nil then
			return
		end

		local parent = workspace.Debree:FindFirstChild(formatted .. " - TP CONTENT")

		if parent == nil then
			parent = Instance.new("Folder", workspace.Debree)
			parent.Name = formatted .. " - TP CONTENT"
			DebrisModule:AddItem(parent, 4)
		end

		if cFrame ~= nil and cFrame2 ~= nil then
			local clone = script.NewAssets.TetherBeam:Clone()
			clone.StartPart.CFrame = cFrame
			clone.EndPart.CFrame = cFrame2
			clone.Parent = parent
			Ouwmit.Emit(clone, Ouwmit.Owned(adornee))
		end

		local clone = script.NewAssets.StunVFX:Clone()
		clone:PivotTo(cFrame2 * CFrame.new(0, -3, 0))
		clone.Parent = parent
		clone.EnableStun.WeldConstraint.Part1 = part
		local clone2 = script.Sounds.TpToVictim:Clone()
		clone2.Parent = clone.EnableStun
		clone2:Play()
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -25,
			RaycastHelper.Crater
		)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			color = raycastResult.Instance.Color
		end

		Ouwmit.Emit(clone.HitEmit, Ouwmit.Owned(adornee, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))
		Ouwmit.Enable(clone.EnableStun, true, Ouwmit.Owned(adornee, {
			Duration = 3
		}))
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "FinalHit" then
		local clone = script.NewAssets["AOE(Emit)"]:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -3, 0))
		clone.Parent = workspace.Debree
		Ouwmit.Emit(clone, Ouwmit.Owned(adornee))
		DebrisModule:AddItem(clone, 3)
		local child2 = workspace.Debree:FindFirstChild(formatted .. " - TP CONTENT")

		if child2 ~= nil then
			child2.Name = "--"
			Ouwmit.Enable(child2, false)
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -25,
			RaycastHelper.Crater
		)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			local cFrame3 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 0.25, 0)
			clone.GroundFX.CFrame = cFrame3
			clone.Startup.CFrame = cFrame3
			color = raycastResult.Instance.Color
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(adornee, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))
		Cam_Shaker(humanoidRootPart.Position, "medium_shake_preset")
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 1,
			Count = 12,
			Radius = 20,
			ScaleMult = 3
		})

		if adornee == game.Players.LocalPlayer.Character or vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) < 30 then
			LTN()
		end

		local clone2 = script.Sounds.Explode:Clone()
		clone2.Parent = clone.Startup
		clone2:Play()
	elseif child ~= nil then
		child:Destroy()
	end
end