return function()
	for i = 1, 5 do
		local clone = script.Parent:Clone()
		clone.Parent = workspace.Effects
		clone.Name = "Attachment" .. i
		clone.CFrame = script.Parent.CFrame * CFrame.Angles(0, 6.283185307179586 * i / 5, 0) * CFrame.new(0, 0, -1)
		task.spawn(function()
			clone.Flames:Emit(10)
			clone.Flames.Enabled = true
			wait(0.1)

			if clone:FindFirstChild("Flames") then
				clone.Flames.Enabled = false
			end
		end)
		_G.PU:Dust(clone, 1)
	end
end