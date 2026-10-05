local mover = script.Parent.mover

-- equivalent calls inferred from this helper; original call sites unknown
local function map(magnitude)
	return 0 + -0.0125 * (math.clamp(magnitude, 10, 90) - 90)
end

script.Parent.Parent.Parent.Enabled = false
workspace.Alive.ChildAdded:Connect(function(child)
	if child == game.Players.LocalPlayer.Character then
		script.Parent.Parent.Parent.Enabled = true
		local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

		while game.Players.LocalPlayer.Character.Parent == workspace.Alive and humanoidRootPart do
			local children = workspace.Balls:GetChildren()

			for _, v in pairs(children) do
				if not ((humanoidRootPart.Position - (v.Position + v.AssemblyLinearVelocity * 0.55)).Magnitude < 300) then
					continue
				end

				local v2 = map((humanoidRootPart.Position - v.Position).Magnitude) -- equivalent call inferred; original call site unknown
				mover:TweenPosition(UDim2.new(v2, 0, 0.5, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.1, true)
			end

			task.wait(0.05)
		end
	end
end)
workspace.Dead.ChildAdded:Connect(function(child)
	if child == game.Players.LocalPlayer.Character then
		script.Parent.Parent.Parent.Enabled = false
	end
end)