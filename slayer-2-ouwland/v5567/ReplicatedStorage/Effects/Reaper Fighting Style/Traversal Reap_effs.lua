local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local Ouwmit = require(modules.Effects.Ouwmit)
local vfxUtility = require(modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local script2 = script
local currentCamera = workspace.CurrentCamera

local function BlurEffect(value: number?)
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 5
	blurEffect.Parent = game.Lighting
	DebrisModule:AddItem(blurEffect, value or 0.08333333333333333)
end

local function folderName(p)
	return string.format("%s-ReaperSkill1", p.Name)
end

local function destroyFolder(p)
	local debree = workspace:FindFirstChild("Debree")
	local child = debree and debree:FindFirstChild(folderName(p))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false, nil, true)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(instance)
	destroyFolder(instance)
	local parent = workspace:FindFirstChild("Debree")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "Debree"
		parent.Parent = workspace
	end

	local folder = Instance.new("Folder")
	folder.Name = string.format("%s-ReaperSkill1", instance.Name)
	folder.Parent = parent
	DebrisModule:AddItem(folder, 10)
	return folder
end

return function(instance, p: string)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil or (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Initiate" then
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local asset = vfxUtility.cloneAsset(script2, workspace.Debree, "Jump", humanoidRootPart.CFrame, 5)

		if asset then
			Ouwmit.Emit(asset, Ouwmit.Owned(instance, v))
		end

		vfxUtility.PlaySound(script2.Sounds, "PS2reapingbladesTRAVERSALLEAPINITIATE", humanoidRootPart, true)
	elseif p == "Start" then
		local folder = createFolder(instance)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.4,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 5
		blurEffect.Parent = game.Lighting
		DebrisModule:AddItem(blurEffect, 0.2)
		vfxUtility.PlaySound(script2.Sounds, "PS2reapingbladesTRAVERSALLEAPBEGINSPIN", humanoidRootPart, true)
		local asset = vfxUtility.cloneAsset(script2, folder, "Loop", humanoidRootPart.CFrame, 7)

		if asset then
			Ouwmit.Emit(asset, Ouwmit.Owned(instance, v))
			local v2 = vfxUtility.PlaySound(script2.Sounds, "PS2reapingbladesTRAVERSALLEAPloop", asset.HumanoidRootPart)

			if v2 then
				v2.Looped = true
			end

			asset.HumanoidRootPart.Anchored = true

			for _, part in asset:GetDescendants() do
				if part:IsA("BasePart") then
					part.Anchored = true
				end
			end

			local postSimulationConnection = nil
			postSimulationConnection = RunService.PostSimulation:Connect(function()
				if asset.Parent == nil or humanoidRootPart.Parent == nil then
					postSimulationConnection:Disconnect()
				else
					asset:PivotTo(humanoidRootPart.CFrame)
				end
			end)
			asset.Destroying:Once(function()
				postSimulationConnection:Disconnect()
			end)
			local cam_Shaker = Cam_Shaker(humanoidRootPart, {
				FadeInTime = 0.1,
				Frequency = 0.3,
				Amplitude = 0.25,
				SustainTime = 8,
				FadeOutTime = 0.3,
				RotationInfluence = createVector(0.1, 0.1, 0.1),
				PositionInfluence = createVector(0.5, 0.5, 0.5)
			})
			task.spawn(function()
				while asset.Parent ~= nil and folder.Name ~= "--" do
					task.wait()
				end

				if cam_Shaker then
					cam_Shaker:Destroy()
				end
			end)
		end
	elseif p == "End" then
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local asset = vfxUtility.cloneAsset(script2, workspace.Debree, "Teleport", humanoidRootPart.CFrame, 5)

		if asset then
			Ouwmit.Emit(asset, Ouwmit.Owned(instance, v))
		end

		vfxUtility.PlaySound(script2.Sounds, "PS2reapingbladesTRAVERSALLEAPstop", humanoidRootPart, true)
		destroyFolder(instance)
	end
end