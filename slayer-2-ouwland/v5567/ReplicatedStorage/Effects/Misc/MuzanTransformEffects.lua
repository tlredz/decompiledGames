local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

local function burst(folder, childName: string, cFrame: CFrame, p, instance)
	local child = script:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone = child:Clone()
	clone:PivotTo(cFrame)
	clone.Parent = folder
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, p))
end

local function igniteLimb(parent)
	local armParticles = script:FindFirstChild("ArmParticles")

	if armParticles == nil or parent == nil then
		return
	end

	local clones = {}

	for _, child in ipairs(armParticles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = parent
		table.insert(clones, clone)
		DebrisModule:AddItem(clone, 3)
	end

	Ouwmit.Emit(clones, Ouwmit.Owned(parent))
end

return function(instance)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = `MuzanTransform_{instance.Name}`
	folder.Parent = workspace.Debree
	DebrisModule:AddItem(folder, MuzanSettings.TransformLength + 3)
	local pS2demontransform = script:FindFirstChild("PS2demontransform")

	if pS2demontransform ~= nil then
		local clone = pS2demontransform:Clone()
		clone.Parent = humanoidRootPart
		clone.TimePosition = 0.4
		clone:Play()
		DebrisModule:AddItem(clone, math.max(MuzanSettings.TransformLength, clone.TimeLength) + 1)
	end

	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	local v

	if raycastResult == nil then
		v = nil
	else
		v = vfxUtility.GetDustColorSettings(raycastResult.Instance)
	end

	local v2 = {
		{ 0.43333333333333335, function()
				burst(folder, "Fall", humanoidRootPart.CFrame, v, instance)
			end },
		{ 1.2166666666666666, function()
				local highlight = script:FindFirstChild("Highlight")

				if highlight ~= nil then
					local clone = highlight:Clone()
					clone.Adornee = instance
					clone.Parent = instance
					Ouwmit.Emit(clone, Ouwmit.Owned(instance))
					DebrisModule:AddItem(clone, MuzanSettings.TransformLength - 1.2166666666666666)
				end

				igniteLimb(instance:FindFirstChild("RightHand"))
			end },
		{ 2.716666666666667, function()
				igniteLimb(instance:FindFirstChild("LeftHand"))
			end },
		{ MuzanSettings.TransformConvertAt, function()
				burst(folder, "Explosion", humanoidRootPart.CFrame, v, instance)
			end },
		{ 5.516666666666667, function()
				burst(folder, "GroundSlam", humanoidRootPart.CFrame, v, instance)
			end },
		{ 6.266666666666667, function()
				burst(folder, "FinalExplosion", humanoidRootPart.CFrame, v, instance)
			end }
	}
	task.spawn(function()
		local lastTime = os.clock()

		for _, v3 in ipairs(v2) do
			local v4 = v3[1] - (os.clock() - lastTime)

			if v4 > 0 then
				task.wait(v4)
			end

			if instance.Parent == nil then
				break
			else
				task.spawn(v3[2])
			end
		end
	end)
end