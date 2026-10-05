local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
return function(instance)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	local configuration = Instance.new("Configuration", workspace.Debree)
	configuration.Name = "BoulderSplitEffects"
	DebrisModule:AddItem(configuration, 15)
	local clone = script.EnvironementEffects:Clone()
	local clone2 = script.PS2trainingBOULDCUTcinematic:Clone()
	clone2.Parent = clone.Root
	clone2:Play()
	clone.Parent = configuration
	clone:PivotTo(cFrame)
	Ouwmit.Emit(clone, Ouwmit.Owned(instance))
	task.wait(3.95)
	local clone3 = script.Jump:Clone()
	clone3.Parent = configuration
	local v = cFrame * CFrame.new(0, 0, -4.5)
	clone3:PivotTo(v)
	local raycastResult = workspace:Raycast(
		v.Position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	Ouwmit.Emit(
		clone3,
		Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
	)
	task.wait(0.33999999999999986)
	local clone4 = script.Slash:Clone()
	clone4.Parent = configuration
	clone4:PivotTo(cFrame)
	Ouwmit.Emit(clone4, Ouwmit.Owned(instance))
	task.wait(0.15)
	local clone5 = script.Dissapear:Clone()
	clone5.Parent = configuration
	clone5.CFrame = cFrame * CFrame.new(0, 0, 6.5)
	Ouwmit.Emit(clone5, Ouwmit.Owned(instance))
end