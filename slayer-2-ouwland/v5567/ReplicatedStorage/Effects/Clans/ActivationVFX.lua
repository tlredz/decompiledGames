local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
return function(instance, childName: string?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local highlight = script:FindFirstChild("Highlight")
	local v

	if highlight == nil then
		v = Instance.new("Highlight")
	else
		v = highlight:Clone()
	end

	v.FillTransparency = -1
	v.OutlineTransparency = -5
	v.Adornee = instance
	v.Parent = instance
	DebrisModule:AddItem(v, 0.6)
	TweenService:Create(v, tweenInfo, {
		FillTransparency = 1,
		OutlineTransparency = 1
	}):Play()
	local v2

	if childName ~= nil then
		v2 = childName .. "Sound" or nil
	end

	local v3 = (v2 == nil or script:FindFirstChild(v2) == nil) and "PS2clanskillsAURAACTIVATION" or v2
	vfxUtility.PlaySound(script, v3, humanoidRootPart, true)
	local model = childName ~= nil and script.Effects:FindFirstChild(childName) or script.Effects.Default

	if model == nil or model:IsA("Model") then
		if model ~= nil then
			local clone = model:Clone()
			clone.Parent = workspace.Debree
			clone:PivotTo(humanoidRootPart.CFrame)
			DebrisModule:AddItem(clone, 3)
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)
			local v4 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, v4))
		end
	else
		for _, child in model:GetChildren() do
			local clone = child:Clone()
			clone.Parent = humanoidRootPart
			DebrisModule:AddItem(clone, 3)
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		end
	end

	Cam_Shaker(humanoidRootPart.Position, "activate_shake")
end