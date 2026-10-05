local parent = script.Parent
local parent2 = parent.Parent
local v = 0

while true do
	if parent.Visible and parent2.Visible then
		v = v / 30 % 4 == 0 and 0 or v
		parent.Rotation += 5
	end

	task.wait()
end