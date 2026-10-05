local parent = script.Parent
local cog1 = parent:WaitForChild("Cog1")
local cog2 = parent:WaitForChild("Cog2")

while true do
	if script.Parent.Visible then
		task.wait()
		cog1.Rotation += 0.5
		cog2.Rotation -= 0.5
	else
		script.Parent:GetPropertyChangedSignal("Visible"):Wait()
	end
end