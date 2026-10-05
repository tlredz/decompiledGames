local _ = script.Parent
local aura2 = script.Parent:WaitForChild("Aura2")
local TweenService = game:GetService("TweenService")
local parent = script.Parent.Parent

while task.wait(0.15) do
	if not parent:IsDescendantOf(workspace) then
		repeat
			parent.Parent.AncestryChanged:Wait()
		until parent:IsDescendantOf(workspace)
	end

	TweenService:Create(aura2.Motor, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		C0 = aura2.Motor.Part0.CFrame:ToObjectSpace(aura2.Motor.Part1.CFrame) * CFrame.Angles(0, 1.3089969389957472, 0)
	}):Play()
end