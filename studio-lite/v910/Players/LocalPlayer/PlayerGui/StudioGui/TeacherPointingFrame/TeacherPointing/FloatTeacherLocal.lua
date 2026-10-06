gui = script.Parent
s = 0
inc = 1

while true do
	if s == 0 then
		inc = 1
	elseif s == 1 then
		inc = -1
	end

	s += inc
	gui.Size = UDim2.new(1, s, 1, s)
	gui.Position = UDim2.new(0, math.random(0, 1), 0, math.random(0, 1))
	task.wait(0.9)
end