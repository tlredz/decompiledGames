local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local _ = workspace.CurrentCamera
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
return function(instance, p: string, parent, p2)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "StartUp" then
		vfxUtility.PlaySound(script.Sounds, "PS2soundBURSTINGBLOOMinit", humanoidRootPart, true)
		local clone = script.StartupFX:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 2)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "Teleport" then
		vfxUtility.PlaySound(script.Sounds, "PS2soundBURSTINGBLOOMdash", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		local configuration = Instance.new("Configuration")
		configuration.Parent = Workspace.Debree
		configuration.Name = script.Name
		DebrisModule:AddItem(configuration, 3)
		local clone = script.TrailForChar:Clone()
		clone.Parent = configuration
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone
		weld.Parent = clone
		local clone2 = script.DashFX:Clone()
		local cframe = typeof(p2) == "CFrame" and p2 or humanoidRootPart.CFrame
		local vector2 = Vector3.new(cframe.LookVector.X, 0, cframe.LookVector.Z)

		if vector2.Magnitude > 0.001 then
			cframe = CFrame.lookAlong(cframe.Position, vector2.Unit)
		end

		clone2:PivotTo(cframe)
		clone2.Parent = configuration
		local raycastResult = workspace:Raycast(cframe.Position, cframe.upVector * -20, RaycastHelper.Crater)
		local v

		if raycastResult then
			v = vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		end

		local groundRaycast = clone2:FindFirstChild("GroundRaycast")

		if raycastResult ~= nil and groundRaycast ~= nil and groundRaycast:IsA("BasePart") then
			groundRaycast.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.25, 0)) * groundRaycast.CFrame.Rotation
		end

		local middleDashBeams = clone2.FXDash.MiddleDashBeams
		middleDashBeams.Parent = workspace.Debree
		local windBeams = clone2.WindBeams
		windBeams.Parent = workspace.Debree

		for _, beam in {
			windBeams.Attachment.FrontSet.Back.BigRightBeam,
			windBeams.Attachment.FrontSet.Back.Right,
			windBeams.Attachment.FrontSet.Back2.BigRightBeam,
			windBeams.Attachment.FrontSet.Back2.Right
		} do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			TweenService:Create(beam, TweenInfo.new(1.5, Enum.EasingStyle.Quint), {
				TextureLength = 0.1,
				TextureSpeed = 0.1
			}):Play()
			local v2 = beam
			task.delay(0.155, function()
				TweenService:Create(v2, TweenInfo.new(0.855, Enum.EasingStyle.Sine), {
					Brightness = 0,
					LightEmission = 1
				}):Play()
			end)
		end

		Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v))
		middleDashBeams.Parent = clone2

		for _, child in middleDashBeams.A0:GetChildren() do
			child.Enabled = true
			TweenService:Create(child, TweenInfo.new(0.455, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			TweenService:Create(child, TweenInfo.new(0.555, Enum.EasingStyle.Sine), {
				TextureLength = 0.1,
				TextureSpeed = 0.1
			}):Play()
		end

		windBeams.Parent = clone2
		task.wait(0.15)
		local clone3 = script.LandFX:Clone()
		clone3.CFrame = parent * CFrame.new(0, -2.5, 0)
		clone3.Parent = configuration
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance, v))
		task.wait(0.2)
		clone.A02.Trail.Enabled = false
	elseif p == "Hit" then
		if parent == nil then
			return
		end

		for _, child in ipairs(script.VictimExplosion:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = parent
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			DebrisModule:AddItem(clone, 2)
		end
	end
end