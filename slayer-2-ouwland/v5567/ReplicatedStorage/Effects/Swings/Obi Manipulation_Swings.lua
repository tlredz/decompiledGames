local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
local v = {
	[99] = 0.265,
	[1] = 0.135
}
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Combat_Swings = require(script.Parent:WaitForChild("Combat_Swings"))
return function(instance, p, p2)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) >= 100 then
		return
	end

	local v2 = p2 and 99 or p

	if v2 == 6 then
		Combat_Swings(instance, 6, p2)
		return
	end

	local clone = script.Swing:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	game.Debris:AddItem(clone, clone.TimeLength)
	task.wait(v[v2] or 0.125)
	local clone2 = (script:FindFirstChild("Swing" .. v2) or script:FindFirstChild("Swing1")):Clone()
	clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, -3)
	clone2.Parent = workspace.Debree
	game.Debris:AddItem(clone2, 3)
	local attachment = clone2.Attachment
	attachment.WorldCFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -2)
	local raycastResult = workspace:Raycast(
		clone2.Position + createVector(0, 2, 0),
		createVector(0, -10, 0),
		RaycastHelper.Crater
	)

	if raycastResult ~= nil and raycastResult.Instance ~= nil then
		clone2.Dust.Color = ColorSequence.new(raycastResult.Instance.Color)

		if v2 == 5 then
			clone2.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, clone2.Size.Y / 2, 0)) * clone2.CFrame.Rotation * CFrame.Angles(
				0,
				-0.3141592653589793,
				0
			)
			clone2.Dust.Acceleration += humanoidRootPart.CFrame.RightVector * -80
		else
			clone2.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, clone2.Size.Y / 2, 0)) * clone2.CFrame.Rotation
		end

		vfxUtility.EmitAll(clone2)
	end

	vfxUtility.EmitAll(attachment)
end