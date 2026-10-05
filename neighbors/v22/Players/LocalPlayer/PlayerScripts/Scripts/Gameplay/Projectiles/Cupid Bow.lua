game:GetService("TweenService")
game:GetService("Debris")
return {
	Impact = function(p, p2, childName)
		p.Object.CanCollide = false
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Parent = p.Object
		weldConstraint.Part0 = p.Object
		p.Object.ArrowheadWeld.C0 = CFrame.new(0, 0, 1.225)
		p.Object.FeatherWeld.C0 = CFrame.new(-0.006, 0, -1.024)

		if p2.Instance.Parent:IsA("Accessory") then
			local child = workspace:FindFirstChild(childName)

			if child and child:FindFirstChild("Head") then
				weldConstraint.Part1 = child.Head
			end
		else
			weldConstraint.Part1 = p2.Instance
		end
	end
}