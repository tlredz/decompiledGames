local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local CraterExtension = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.CraterExtension)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills.Wind["Mountain Wind"].Config)
return function(instance, p: string, cframe, cFrame)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Start" then
		vfxUtility.PlaySound(script.Sound, "PS2windGENERALinitiate", humanoidRootPart, true)
		local clone = script.Parent["Purifying ClawsVFX"].Startup:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 3)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -11,
			RaycastHelper.Crater
		)
		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		Cam_Shaker(humanoidRootPart.Position, "activate_shakelessaggresive")
	elseif p == "Up" then
		vfxUtility.PlaySound(script.Sound, "PS2windMOUNTAINWINDswing", humanoidRootPart, true)
		local raycastResult = workspace:Raycast(cframe.Position, createVector(-0, -11, -0), RaycastHelper.Crater)
		local clone = script.UpwardsSlash:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(cframe)
		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		DebrisModule:AddItem(clone, 3)
		Cam_Shaker(cframe.Position, "activate_shake")
	elseif p == "PreSlash" then
		task.wait(0.2)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
			return
		end

		vfxUtility.PlaySound(script.Sound, "PS2windMOUNTAINWINDswing2", humanoidRootPart, true)
	elseif p == "Slash" then
		local raycastResult = workspace:Raycast(cframe.Position, createVector(-0, -11, -0), RaycastHelper.Crater)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local clone = script.SlashEnd:Clone()
		clone:PivotTo(cframe)
		clone.Parent = workspace.Debree
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		DebrisModule:AddItem(clone, 3)
		local clone2 = script.WindGust:Clone()
		clone2:PivotTo(cframe)
		clone2.Parent = workspace.Debree
		Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v))
		DebrisModule:AddItem(clone2, Config.GUST_TRAVEL_TIME + 2)
		local tween = TweenService:Create(
			clone2.Root,
			TweenInfo.new(Config.GUST_TRAVEL_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				CFrame = cFrame
			}
		)
		tween.Completed:Once(function()
			if clone2.Parent ~= nil then
				Ouwmit.Enable(clone2, false)
			end
		end)
		tween:Play()
		Cam_Shaker(cframe.Position, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 0.6,
			SustainTime = 0.3,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.6, 0.6, 0.6),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
	elseif p == "Impact" then
		local raycastResult = workspace:Raycast(
			cframe.Position + cframe.UpVector * 5,
			cframe.UpVector * -25,
			RaycastHelper.Crater
		)

		if raycastResult ~= nil and raycastResult.Instance ~= nil then
			cframe = CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
		end

		local clone = script.GroundImpact:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(cframe)
		local emit = Ouwmit.Emit
		local owned = Ouwmit.Owned
		local v

		if raycastResult then
			v = vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		end

		emit(clone, owned(instance, v))
		DebrisModule:AddItem(clone, 3)

		if raycastResult ~= nil and raycastResult.Instance ~= nil then
			local folder = Instance.new("Folder")
			folder.Name = "MountainWindImpact"
			folder.Parent = workspace.Debree
			DebrisModule:AddItem(folder, 4)
			vfxUtility.ShootRocks(raycastResult, cframe, folder, 7)
		end

		CraterExtension.Cascade(cframe, 5.5, createVector(1.5, 2, 2), nil, 3, false, 2)
		Cam_Shaker(cframe.Position, "activate_shake")
	end
end