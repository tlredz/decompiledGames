local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker2 = require(modules.Effects.Cam_Shaker)
local vfxUtility = require(modules.Effects.vfxUtility)
local DebrisModule = require(CAM.DebrisModule)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local assets = script.Assets
local sounds = script:FindFirstChild("Sounds")
local debree = workspace.Debree
return function(instance, p, p2: string?, childName: string?)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local head = instance:FindFirstChild("Head")

	if not humanoidRootPart or not head or p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s_%s_Effects", p2 or instance.Name, script.Name)

	if p == "Ground" then
		if debree:FindFirstChild(name) then
			debree:FindFirstChild(name):Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		folder:SetAttribute("Active", true)
		DebrisModule:AddItem(folder, 8)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			RaycastHelper.Crater
		)
		local clone = assets.Jump:Clone()

		if raycastResult then
			clone.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0)) * humanoidRootPart.CFrame.Rotation
		else
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.9, 0)
		end

		clone.Parent = folder
		vfxUtility.EmitAll(
			clone,
			vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		DebrisModule:AddItem(clone, 3)
		Cam_Shaker2(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		vfxUtility.PlaySound(sounds, "PS2yetiHEATWAVEjump", humanoidRootPart, true)
		local clone2 = assets.HeadVFX:Clone()
		clone2.CFrame = head.CFrame
		clone2.Parent = folder
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		vfxUtility.WeldConstraint(clone2, head)
	elseif p == "LandEffect" then
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			RaycastHelper.Crater
		)
		local cFrame = humanoidRootPart.CFrame

		if raycastResult ~= nil and raycastResult.Instance ~= nil then
			cFrame = CFrame.new(raycastResult.Position) * cFrame.Rotation * CFrame.new(0, 10, 0)
		end

		local clone = script.Assets.Landing:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(cFrame)
		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		vfxUtility.PlaySound(sounds, "PS2yetiHEATWAVEland", humanoidRootPart, true)
	elseif p == "Shoot" then
		task.wait(0.01)
		local child = workspace.Debree:FindFirstChild(childName)

		if child == nil then
			return
		end

		local child2 = debree:FindFirstChild(name)

		if child2 == nil then
			return
		end

		vfxUtility.EnableAll(child2, false)
		DebrisModule:AddItem(child2, 3)

		if child2.Parent == nil or child2:GetAttribute("Active") == nil then
			return
		end

		local clone = assets.Emit:Clone()
		clone:PivotTo(head.CFrame)
		clone.Parent = child2
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2.5)
		local clone2 = assets.Beam_VFX:Clone()
		clone2:PivotTo(head.CFrame)
		clone2.Parent = child2
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		vfxUtility.PlaySound(sounds, "PS2yetiHEATWAVEshoot", clone2.EyeBeam, true)
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if clone2.Parent == nil or child2.Parent == nil or child2:GetAttribute("Active") == nil then
				heartbeatConnection:Disconnect()
			else
				clone2.EyeBeam.CFrame = CFrame.new(head.Position, clone2.End_Beam.Position)
			end
		end)
		local end_Beam = clone2.End_Beam
		end_Beam.CFrame = child.CFrame
		local lastTime = os.clock()
		local clone3 = assets.Beam_Trail:Clone()
		clone3.Parent = child2
		local flag = false

		while child2.Parent ~= nil and child2:GetAttribute("Active") ~= nil and os.clock() - lastTime < 1 do
			if humanoidRootPart.Parent == nil then
				return
			end

			local raycastResult = workspace:Raycast(
				child.CFrame * CFrame.new(0, 0, 4).Position,
				child.CFrame.LookVector * 10,
				RaycastHelper.Crater
			)
			local cFrame = child.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)

			if raycastResult then
				cFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone3.CFrame = cFrame * CFrame.new(0, 0.5, 0)

				if not flag then
					vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
					flag = true
				end
			elseif flag then
				vfxUtility.EnableAll(clone3, false)
				flag = false
			end

			end_Beam.CFrame = cFrame
			RunService.Heartbeat:Wait()
		end

		heartbeatConnection:Disconnect()
		vfxUtility.EnableAll(clone3, false)
		vfxUtility.EnableAll(clone2, false)
		vfxUtility.TweenBeams(clone2, {
			Time = 0.15,
			Off = true
		})
		DebrisModule:AddItem(clone2, 3)
		child2.Name = "--"
		DebrisModule:AddItem(child2, 3)
		child2:SetAttribute("Active", nil)
	else
		local child = p == "Cancel" and debree:FindFirstChild(name)

		if child then
			child.Name = "--"
			child:SetAttribute("Active", nil)
			vfxUtility.EnableAll(child, false, nil, true)
			DebrisModule:AddItem(child, 3)
		end
	end
end