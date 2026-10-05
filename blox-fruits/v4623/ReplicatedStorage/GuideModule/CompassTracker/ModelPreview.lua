local createVector = vector.create
require(script.Parent.Types)
return {
	set = function(state, instance, options)
		if state.PreviewModel then
			state.PreviewModel:Destroy()
			state.PreviewModel = nil
		end

		state.Ui.WorldModel:ClearAllChildren()

		if not instance then
			state.Ui.ViewportFrame.CurrentCamera = nil
			return
		end

		local clone = instance:Clone()
		clone:PivotTo(CFrame.new(createVector(0, -2.5, -2.25), createVector(0, -2.5, 0)))
		state.PreviewModel = clone
		clone.Parent = state.Ui.WorldModel

		for _, v in ipairs(options or {}) do
			local animator = clone:FindFirstChild("Animator", true)

			if animator then
				animator:LoadAnimation(v.Animation):Play()
			end
		end

		for _, childName in ipairs({
			"QuestBBG",
			"NPCName",
			"QUEST",
			"SHOP",
			"INVENTORY",
			"MISC",
			"Talk"
		}) do
			local child = clone:FindFirstChild(childName, true)

			if child then
				child:Destroy()
			end
		end

		local camera = Instance.new("Camera")
		state.Ui.ViewportFrame.CurrentCamera = camera
		task.spawn(function()
			local head = clone:FindFirstChild("Head", true) or clone:FindFirstChild("UpperTorso", true) or clone:FindFirstChild(
				"HumanoidRootPart",
				true
			)

			while state.PreviewModel == clone and camera == state.Ui.ViewportFrame.CurrentCamera do
				if head then
					camera.CFrame = head.CFrame * CFrame.new(0, 0.2, -2.5) * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(
						0,
						0,
						0
					)
				end

				task.wait(0.01)
			end
		end)
	end
}