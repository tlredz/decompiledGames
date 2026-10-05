return function(player)
	local rightHand = player.Character.RightHand
	local hold = player.Hold

	if rightHand ~= nil then
		if hold then
			if (rightHand.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 150 then
				return
			end

			local clone = script.gravprticle:Clone()
			clone.CFrame = rightHand.CFrame
			clone.Parent = rightHand
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Name = "gravprticleweldpart"
			weldConstraint.Parent = rightHand
			weldConstraint.Part0 = rightHand
			weldConstraint.Part1 = clone
		else
			if rightHand:FindFirstChild("gravprticle") then
				rightHand.gravprticle:Destroy()
			end

			if rightHand:FindFirstChild("gravprticleweldpart") then
				rightHand.gravprticleweldpart:Destroy()
			end
		end
	end
end