return function(p)
	local clone = script.Sparks:Clone()
	clone.Parent = workspace._WorldOrigin
	local weld = Instance.new("Weld", clone)
	weld.C0 = CFrame.new(0, 0, -16)
	weld.Part0 = p.Weld.Part1
	weld.Part1 = clone
	local parentChangedConnection = nil
	parentChangedConnection = p.Weld:GetPropertyChangedSignal("Parent"):Connect(function()
		if not p.Weld.Parent then
			clone:Destroy()
			parentChangedConnection:Disconnect()
		end
	end)
end