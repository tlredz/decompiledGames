return {
	Start = function(p)
		local name = p.Instance.Name
		local parent = p.Instance.Parent

		local function loadAndPlayAnim(instance)
			local sharkBite = instance:FindFirstChild("SharkBite", true)
			local animator = sharkBite and instance:FindFirstChildWhichIsA("Animator", true)

			if animator then
				local track = animator:LoadAnimation(sharkBite)
				p._trove:Add(track)

				while task.wait(20) and sharkBite.Parent do
					track:Play()
					task.wait(track.Length)
				end
			end
		end

		local child = p.Instance:FindFirstChild(name)

		if child then
			loadAndPlayAnim(child)
			return
		end

		local v = nil

		while p.Instance.Parent and not v do
			for _, model in parent:GetChildren() do
				if not (model.Name == name and model:IsA("Model")) then
					continue
				end

				v = model
				break
			end

			task.wait(0.1)
		end

		if p.Instance.Parent and v then
			loadAndPlayAnim(v)
		end
	end
}