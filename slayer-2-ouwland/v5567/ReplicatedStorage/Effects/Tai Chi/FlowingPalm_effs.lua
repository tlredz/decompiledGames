local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Stats")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage2.CAM
local modules = CAM.Client.Modules
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local DebrisModule2 = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local Ouwmit = require(modules.Effects.Ouwmit)
local vfxUtility = require(modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local script2 = script
local currentCamera = workspace.CurrentCamera

local function blurEffect(value: number?)
	local blurEffect2 = Instance.new("BlurEffect")
	blurEffect2.Size = 8
	blurEffect2.Parent = game.Lighting
	DebrisModule2:AddItem(blurEffect2, value or 0.08333333333333333)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

return function(instance, p: string)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	if p == "Cancel" then
		local pS2taichiFLOWINGPALMconnect = humanoidRootPart:FindFirstChild("PS2taichiFLOWINGPALMconnect")

		if pS2taichiFLOWINGPALMconnect ~= nil then
			pS2taichiFLOWINGPALMconnect:Destroy()
		end
	else
		if (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude >= 250 then
			return
		end

		if p == "Dash" then
			local asset = vfxUtility.cloneAsset(
				script2,
				workspace.Debree,
				"Dash",
				humanoidRootPart.CFrame * CFrame.new(0, 0, 4),
				3
			)

			if asset then
				Ouwmit.Emit(asset, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.4,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})
			vfxUtility.PlaySound(script.Sounds, "PS2taichiFLOWINGPALMteleport", humanoidRootPart, true)
			local blurEffect2 = Instance.new("BlurEffect")
			blurEffect2.Size = 8
			blurEffect2.Parent = game.Lighting
			DebrisModule2:AddItem(blurEffect2, 0.2)
		elseif p == "Hit" then
			local asset = vfxUtility.cloneAsset(script2, workspace.Debree, "Initial", humanoidRootPart.CFrame, 3)

			if asset then
				Ouwmit.Emit(asset, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.5,
				SustainTime = 0.3,
				FadeOutTime = 0.3,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(3, 3, 3)
			})
		elseif p == "HandThing" then
			local rightHand = instance:FindFirstChild("RightHand")

			if rightHand then
				local clone = script.HandInirial.Attachment:Clone()
				clone.Parent = rightHand
				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
				DebrisModule2:AddItem(clone, 3)
			end

			local clone = script.Sounds.PS2taichiFLOWINGPALMconnect:Clone()
			clone.Parent = humanoidRootPart
			clone:Play()
			DebrisModule:AddItem(clone, clone.TimeLength)
		elseif p == "FinalHit" then
			local asset = vfxUtility.cloneAsset(
				script2,
				workspace.Debree,
				"Final Hit",
				humanoidRootPart.CFrame * CFrame.new(0, 0, 4),
				5
			)

			if asset then
				Ouwmit.Emit(asset, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.15,
				Amplitude = 0.8,
				SustainTime = 0.4,
				FadeOutTime = 0.4,
				RotationInfluence = createVector(0.4, 0.4, 0.4),
				PositionInfluence = createVector(4, 4, 4)
			})
			local blurEffect2 = Instance.new("BlurEffect")
			blurEffect2.Size = 8
			blurEffect2.Parent = game.Lighting
			DebrisModule2:AddItem(blurEffect2, 0.3)
		end
	end
end