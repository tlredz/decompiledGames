local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
script:FindFirstChild("Rigs")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterExtension)
local token = modules.Effects.Token
local TokenKit = require(token.TokenKit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear)
local tweenInfo2 = TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
return function(instance, p: string, instance2)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart ~= nil and p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	instance:FindFirstChild("UpperTorso")
	local name = string.format("%s Obi_Field_Effects", instance.Name)
	local parent = debree:FindFirstChild(name)

	if p == "Start" then
		if parent ~= nil then
			parent:Destroy()
		end

		vfxUtility.PlaySound(sounds, "PS2FleshManiOBIFIELDstart", humanoidRootPart, true)
		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = debree
		DebrisModule:AddItem(parent, 12)
		parent:SetAttribute("Active", true)
		task.wait(0.3)

		if not parent:GetAttribute("Active") then
			return
		end

		vfxUtility.PlaySound(sounds, "PS2FleshManiOBIFIELDgroundslam", humanoidRootPart, true)
		local clone = assets.StarterHit:Clone()
		clone.Parent = parent
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.059, -2.2, 0.047)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v3))
		DebrisModule:AddItem(clone, 3)
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone2 = assets.DetectorAura:Clone()
		clone2.Parent = parent
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.059, -2.2, 0.047)
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		vfxUtility.EmitAll(clone2:GetDescendants(), vfxUtility.Owned(instance))
	elseif parent == nil then
		return
	end

	if p == "TrapSpawn" then
		task.wait(0.2)
		local primaryPart = instance2.PrimaryPart
		vfxUtility.PlaySound(sounds, "PS2FleshManiOBIFIELDobiappear", primaryPart, true)
		local clone = assets.Explosion:Clone()
		clone.Parent = parent
		clone.Position = primaryPart.Position
		Vector3.new(0, -1.45, 0)
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
		local clone2 = assets.Better:Clone()
		clone2.Parent = primaryPart
		clone2.CFrame = primaryPart.CFrame + createVector(0, -1.45, 0)
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		task.delay(3, function()
			vfxUtility.EnableAll(clone2, false)
			DebrisModule:AddItem(clone2, 3)
		end)
	end

	if p == "TrapMiss" then
		local primaryPart = instance2.PrimaryPart
		vfxUtility.PlaySound(sounds, "PS2FleshManiOBIFIELDregress", primaryPart, true)
		local clone = assets.Explosion:Clone()
		clone.Parent = parent
		clone.Position = primaryPart.Position
		Vector3.new(0, -1.45, 0)
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)

		for _, part in pairs(instance2:GetChildren()) do
			if part:IsA("MeshPart") then
				TweenService:Create(part, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		end

		TweenService:Create(primaryPart, tweenInfo, {
			CFrame = primaryPart.CFrame * CFrame.new(0, 7, 0)
		}):Play()
	end

	if p == "TrapHit" then
		local primaryPart = instance2.PrimaryPart
		vfxUtility.PlaySound(sounds, "PS2FleshManiOBIFIELDexplo", primaryPart, true)
		local better = primaryPart:WaitForChild("Better", 0.25)

		if not better then
			return
		end

		local clone = assets.Hits:Clone()
		clone.Parent = debree
		clone:PivotTo(CFrame.new(primaryPart.Position + createVector(0, -1.45, 0)))
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v3))
		OuwCraters.Scales({
			Center = clone.PrimaryPart.CFrame,
			Duration = 2.5,
			Radius = 9,
			ScaleMult = 0.75
		})
		task.spawn(function()
			TokenKit.GroundRocks({
				CF = clone.PrimaryPart.CFrame,
				InnerRadius = 1,
				OuterRadius = 8,
				Velocity = {
					Min = 20,
					Max = 70
				},
				Size = {
					Min = 1,
					Max = 2
				}
			})
		end)
		Cam_Shaker(clone.PrimaryPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})

		for _, part in pairs(instance2:GetChildren()) do
			if part:IsA("MeshPart") then
				TweenService:Create(part, tweenInfo2, {
					Transparency = 1
				}):Play()
			end
		end

		task.wait(0.5)
		vfxUtility.EnableAll(better, false)
	end

	if p == "Cancel" and parent ~= nil and parent.Parent ~= nil then
		vfxUtility.EnableAll(parent, false)
		parent.Name = "_"
		parent:SetAttribute("Active", false)
		DebrisModule:AddItem(parent, 4)
	end
end