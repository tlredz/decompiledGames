local RunService = game:GetService("RunService")
return {
	Mount = function(maid, instance)
		local v = true
		maid:Add(function()
			v = false
		end)
		task.spawn(function()
			local primaryPart = instance.PrimaryPart or instance:WaitForChild("RootPart", 5)
			local riderFollow = primaryPart and primaryPart:WaitForChild("RiderFollow", 5)

			if not v or primaryPart == nil or riderFollow == nil then
				return
			end

			local followBone = riderFollow:GetAttribute("FollowBone")
			local child

			if typeof(followBone) == "string" then
				child = primaryPart:FindFirstChild(followBone, true)
			else
				child = nil
			end

			if child == nil then
				return
			end

			local v2 = primaryPart.CFrame:ToObjectSpace(child.WorldCFrame):Inverse() * riderFollow.C0 * riderFollow.C1:Inverse()
			maid:Connect(RunService.PreSimulation, function()
				if instance.Parent == nil or riderFollow.Parent ~= primaryPart then
					return
				end

				local v3 = child.TransformedWorldCFrame * v2
				riderFollow.Transform = riderFollow.C0:Inverse() * primaryPart.CFrame:ToObjectSpace(v3) * riderFollow.C1
			end)
		end)
	end
}