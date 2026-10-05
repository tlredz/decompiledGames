local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage.CAM.Client.Modules
local _ = Players.LocalPlayer
local assets = script:FindFirstChild("Assets")
local debree = workspace.Debree
local sounds = script:FindFirstChild("Sounds")
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage.CAM.DebrisModule)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local _ = game.Players.LocalPlayer
local _ = workspace.CurrentCamera
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
return function(instance, p, _, list)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local name = string.format("%s_%s_Effects", instance.Name, script.Name)

	if p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Start" then
		if not debree:FindFirstChild(name) then
			local folder = Instance.new("Folder")
			folder.Name = name
			folder.Parent = debree
			DebrisModule:AddItem(folder, 12)
		end

		local child = debree:FindFirstChild(name)
		child:SetAttribute("Active", true)
		local clone = assets.Startup:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = child
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "PS2thunderbreathGODSPEEDlaunch", humanoidRootPart, true)
		local clone2 = assets.GodSpeed_Trail:Clone()
		clone2.CFrame = humanoidRootPart.CFrame
		clone2.Parent = child
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 8)
		local v2 = vfxUtility.PlaySound(sounds, "PS2thunderbreathGODSPEEDloopTRUE", humanoidRootPart)
		child.AttributeChanged:Connect(function()
			if child:GetAttribute("Active") then
				return
			end

			if v2.Parent == humanoidRootPart then
				v2:Destroy()
			end
		end)
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 2,
			Count = 10,
			OffsetMargin = 10,
			Radius = 12
		})
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		local clone3 = assets.Direction:Clone()
		clone3.Parent = child
		local v3 = nil
		local v4 = true

		while child ~= nil and child.Parent ~= nil and child:GetAttribute("Active") do
			v4 = not v4
			local cFrame = humanoidRootPart.CFrame
			local cframe = humanoidRootPart.CFrame * CFrame.new(v4 and -15 or 15, 0, -10)
			clone3.CFrame = cFrame
			vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))

			if (cFrame.Position - cframe.Position).Magnitude < 40 then
				local raycastResult = workspace:Raycast(
					cFrame.Position,
					(cframe.Position - cFrame.Position).Unit * ((cFrame.Position - cframe.Position).Magnitude + 1),
					RaycastHelper.Crater
				)

				if raycastResult then
					cframe = CFrame.new(raycastResult.Position)
				end
			end

			v3 = TweenService:Create(clone2, TweenInfo.new(0.15), {
				Position = cframe.Position
			})
			v3:Play()
			task.wait(0.15)
		end

		if v3 then
			v3:Pause()
			TweenService:Create(clone2, TweenInfo.new(0.05), {
				CFrame = humanoidRootPart.CFrame
			}):Play()
			task.delay(0.05, function()
				vfxUtility.EnableAll(clone2, false)
			end)
		end

		DebrisModule:AddItem(clone2, 2)
		DebrisModule:AddItem(clone3, 2)
	elseif p == "Success" then
		local clones = {}

		for _, adornee in ipairs(list) do
			local lowerTorso = adornee:FindFirstChild("LowerTorso")

			if lowerTorso == nil then
				continue
			end

			local clone = script.Assets.StunVFX:Clone()
			clone:PivotTo(lowerTorso.CFrame)
			clone.Parent = lowerTorso
			clone.WeldConstraint.Part1 = lowerTorso
			Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
			local clone2 = script.Assets.YellowHighlight:Clone()
			clone2.Parent = clone
			clone2.Adornee = adornee
			table.insert(clones, clone2)
			table.insert(clones, clone)
			DebrisModule:AddItem(clone, 4)
		end

		local child = debree:FindFirstChild(name)
		local v2 = humanoidRootPart.CFrame * CFrame.new(0, -1.75, 0) * CFrame.Angles(0, 3.141592653589793, 0)

		if child then
			child:SetAttribute("Active", nil)
			child.Name = "_"
			DebrisModule:AddItem(child, 3)
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -30,
			RaycastHelper.Crater
		)
		local cFrame, color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			cFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 1, 0)
			color = raycastResult.Instance.Color
		end

		local folder = Instance.new("Folder", workspace.Debree)
		folder.Name = script.Parent.Name .. " - final"
		DebrisModule:AddItem(folder, 3.5)
		local clone = script.Assets.ImpactStartup:Clone()
		clone:PivotTo(v2)

		if cFrame ~= nil then
			clone.Startup.CFrame = cFrame
		end

		clone.Parent = folder
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))
		local clone2 = script.Sounds.PS2thunderblitzNEWCONNECT:Clone()
		clone2.Parent = humanoidRootPart
		clone2:Play()
		DebrisModule:AddItem(clone2, clone2.TimeLength)
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 1,
			Count = 7,
			ScaleMult = 0.5,
			Radius = 5
		})
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		task.wait(1.01)
		local clone3 = script.Assets.LightningSlash:Clone()
		clone3:PivotTo(v2)
		clone3.Parent = folder

		if cFrame ~= nil then
			clone3.SlashVFXEmit.Startup.CFrame = cFrame
			clone3.SlashVFXEmit.GroundFX.CFrame = cFrame
		end

		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 1,
			Count = 7,
			ScaleMult = 0.9,
			Radius = 7
		})
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))
		task.wait(0.3899999999999999)

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

		local clone4 = script.Assets.SlashEndEmit:Clone()
		clone4:PivotTo(v2)
		clone4.Parent = folder

		if cFrame ~= nil then
			clone4.SlashVFXEmit.Startup.CFrame = cFrame
			clone4.SlashVFXEmit.GroundFX.CFrame = cFrame
		end

		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 2,
			Count = 10,
			Radius = 12
		})
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		Ouwmit.Emit(clone4, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))
	elseif p == "Cancel" then
		local child = debree:FindFirstChild(name)

		if child then
			child:SetAttribute("Active", nil)
			child.Name = "_"
			DebrisModule:AddItem(child, 3)
		end

		vfxUtility.PlaySound(sounds, "PS2thunderbreathGODSPEEDstopmoving", humanoidRootPart, true)
	end
end