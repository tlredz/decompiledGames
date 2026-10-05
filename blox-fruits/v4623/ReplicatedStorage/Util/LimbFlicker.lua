local frozen = table.freeze({
	{
		partName = "RightLowerArm",
		jointName = "RightElbow",
		offset = 0.005
	},
	{
		partName = "LeftLowerArm",
		jointName = "LeftElbow",
		offset = -0.005
	},
	{
		partName = "RightLowerLeg",
		jointName = "RightKnee",
		offset = 0.005
	},
	{
		partName = "LeftLowerLeg",
		jointName = "LeftKnee",
		offset = -0.005
	}
})
return {
	JOINT_FIXES = frozen,
	fix = function(instance)
		for _, v in frozen do
			local child = instance:FindFirstChild(v.partName)
			local motor6D = child and child:FindFirstChild(v.jointName)

			if not (motor6D and motor6D:IsA("Motor6D")) then
				continue
			end

			if not (motor6D.C0.X * math.sign(v.offset) < math.abs(v.offset)) then
				continue
			end

			motor6D.C0 *= CFrame.new(v.offset, 0, 0)
		end
	end
}