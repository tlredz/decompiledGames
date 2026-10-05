local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local Ouwmit = require(modules.Effects.Ouwmit)
local vfxUtility = require(modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local script2 = script
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

return function(instance, p: string, cframe: CFrame?)
	if instance == nil then
		return
	end

	local child = p == "Tornado" and workspace.Debree:FindFirstChild(instance.Name .. "_ScytherVortex")

	if child then
		vfxUtility.EnableAll(child, false, nil, true)
		local model = child:FindFirstChild("Model")

		if model then
			Ouwmit.Enable(model, false)
		end

		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil or (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Tornado" then
		local v = typeof(cframe) == "CFrame" and cframe or humanoidRootPart.CFrame * CFrame.new(0, 0, -10)
		local cFrame = humanoidRootPart.CFrame
		local v2 = groundDust(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
		local folder = Instance.new("Folder")
		local name = instance.Name .. "_ScytherVortex"
		folder.Name = name
		folder.Parent = workspace.Debree
		DebrisModule:AddItem(folder, 6)
		local clone = script.Model:Clone()
		clone:PivotTo(v)
		clone.Parent = folder
		clone.Root.LoopSound:Play()
		clone.Root.PS2sicklesSCYTHERVORTEXstart:Play()
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v2))
		Cam_Shaker(v.Position, {
			FadeInTime = 0.3,
			Frequency = 0.18,
			Amplitude = 0.35,
			SustainTime = 3,
			FadeOutTime = 1.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(1, 1, 1)
		})
		task.delay(4, function()
			if not folder.Parent or folder.Name ~= name then
				return
			end

			clone.Root.LoopSound:Stop()
			clone.Root.PS2sicklesSCYTHERVORTEXdisperse:Play()
			local pivot = clone:GetPivot()
			Ouwmit.Emit(
				vfxUtility.cloneAsset(script2, workspace.Debree, "Explosion", pivot, 5),
				Ouwmit.Owned(instance, groundDust(pivot.Position))
			)
			Ouwmit.Emit(
				vfxUtility.cloneAsset(script2, workspace.Debree, "Teleport", cFrame, 5),
				Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position))
			)
		end)
	elseif p == "JumpBack" then
		local v = groundDust(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
		local folder = Instance.new("Folder", workspace.Debree)
		folder.Name = `{script.Name}-Final`
		DebrisModule:AddItem(folder, 4)
		local cFrame = humanoidRootPart.CFrame
		local clone = script.Loop:Clone()
		clone.Parent = folder
		clone:PivotTo(cFrame * CFrame.new(0, 0, 4))
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		vfxUtility.PlaySound(script.Sounds, "PS2sicklesSCYTHERVORTEXjumpback", humanoidRootPart, true)
		local clone2 = script.Jump:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, 4))
		clone2.Parent = folder
		Ouwmit.Emit(folder, Ouwmit.Owned(instance, v))
	end
end