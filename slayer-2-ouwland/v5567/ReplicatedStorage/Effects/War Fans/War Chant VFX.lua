local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script:FindFirstChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills["War Fans"]["War Chant"].Config)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local function fadeAura(instance)
	vfxUtility.EnableAll(instance, false)
	local pointLight = instance:FindFirstChild("PointLight")

	if pointLight and pointLight:IsA("PointLight") then
		TweenService:Create(pointLight, tweenInfo, {
			Brightness = 0,
			Range = 0
		}):Play()
	end

	DebrisModule:AddItem(instance, 1)
end

return function(instance, p: string, _)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	local upperTorso = instance:FindFirstChild("UpperTorso") or instance:FindFirstChild("Torso") or humanoidRootPart
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

	if p == "Start" then
		local cFrame = humanoidRootPart.CFrame
		Cam_Shaker(cFrame.Position, "activate_shake")
		Ouwmit.Emit(
			vfxUtility.cloneAsset(assets, workspace.Debree, "BuddhaComeUp", cFrame, 5),
			Ouwmit.Owned(instance, v)
		)
		vfxUtility.PlaySound(sounds, "PS2warfansWARCHANTrelease", humanoidRootPart, true)
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 8
		blurEffect.Parent = Lighting
		DebrisModule:AddItem(blurEffect, 0.2)
	elseif p == "Buff" then
		local warChantAura = upperTorso:FindFirstChild("WarChantAura")

		if warChantAura then
			fadeAura(warChantAura)
		end

		local clone = assets.Aura:Clone()
		clone.Name = "WarChantAura"
		clone.Parent = upperTorso
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance, v))
		DebrisModule:AddItem(clone, Config.BUFF_DURATION + 1)
		task.delay(Config.BUFF_DURATION - 0.5, function()
			if clone.Parent ~= nil then
				fadeAura(clone)
			end
		end)
	elseif p == "Counter" then
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset2")
		Ouwmit.Emit(
			vfxUtility.cloneAsset(assets, workspace.Debree, "Hit", humanoidRootPart.CFrame, 5),
			Ouwmit.Owned(instance, v)
		)
		vfxUtility.PlaySound(sounds, "PS2warfansWARCHANTcounter", humanoidRootPart, true)
	end
end