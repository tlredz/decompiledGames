return function(p, parent)
	local flag = false
	local connection = nil

	local function update()
		if flag then
			return
		end

		local child = game.ReplicatedStorage:FindFirstChild(p._UID)

		if child then
			connection:Disconnect()
			flag = true
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt:AddTag("ProximityPrompt")
			proximityPrompt.ObjectText = ""
			proximityPrompt.ActionText = "Hold to Claim"
			proximityPrompt.MaxActivationDistance = child:GetAttribute("CollectionRadius")
			proximityPrompt.MaxIndicatorDistance = proximityPrompt.MaxActivationDistance
			proximityPrompt.HoldDuration = assert(child:GetAttribute("HoldDuration"))
			proximityPrompt.Triggered:Connect(function()
				child:FireServer("Collect")
			end)
			proximityPrompt.PromptButtonHoldBegan:Connect(function()
				child:FireServer("Start")
			end)
			proximityPrompt.PromptButtonHoldEnded:Connect(function(_)
				proximityPrompt.Parent = nil
				proximityPrompt.Parent = parent
			end)
			proximityPrompt.Parent = parent
			proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.Parent = nil
			proximityPrompt.Parent = parent
		end
	end

	connection = p.Maid:Add(game.ReplicatedStorage.ChildAdded:Connect(update))
	update()
end