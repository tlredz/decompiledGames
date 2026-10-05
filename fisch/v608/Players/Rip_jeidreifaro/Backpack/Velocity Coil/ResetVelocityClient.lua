local createVector = vector.create
local parent = script.Parent

if parent and parent:IsA("Tool") then
	parent.Equipped:Connect(function()
		local humanoid = parent.Parent:FindFirstChildWhichIsA("Humanoid")

		if not humanoid or humanoid.SeatPart then
			return
		end

		local humanoidRootPart = parent.Parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") and not humanoidRootPart:IsGrounded() and humanoidRootPart.AssemblyLinearVelocity.Y > 0 then
			humanoidRootPart.AssemblyLinearVelocity *= createVector(1, 0.35, 1)
		end
	end)
end