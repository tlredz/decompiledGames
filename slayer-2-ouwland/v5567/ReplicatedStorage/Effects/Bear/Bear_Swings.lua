local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
return function(instance, p, _, _, flag: boolean?)
	if instance == nil or instance:FindFirstChild("HumanoidRootPart") == nil then
		return
	end

	local child = (flag and script:FindFirstChild("Cub") or script):FindFirstChild("Swing" .. p)

	if child ~= nil then
		local clone = child:Clone()
		clone.Parent = workspace.Debree
		local humanoidRootPart = instance.HumanoidRootPart
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")
		local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -2)
		local isA = clone:IsA("BasePart")

		if isA then
			clone.CFrame = cFrame
		else
			clone:PivotTo(cFrame)
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local dustRaycast = (raycastResult == nil or raycastResult.Instance == nil) and clone:FindFirstChild(
			"DustRaycast",
			true
		)

		if dustRaycast then
			dustRaycast:Destroy()
		end

		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		DebrisModule:AddItem(clone, 3)
		local child2 = script.Sounds:FindFirstChild("Swing" .. p)

		if child2 ~= nil then
			if p == 3 then
				local children = child2:GetChildren()
				child2 = children[math.random(1, #children)]
			end

			local clone2 = child2:Clone()
			clone2.Parent = isA and clone or clone.PrimaryPart

			if flag then
				clone2.PlaybackSpeed = 1.2
			end

			clone2:Play()
		end
	end
end