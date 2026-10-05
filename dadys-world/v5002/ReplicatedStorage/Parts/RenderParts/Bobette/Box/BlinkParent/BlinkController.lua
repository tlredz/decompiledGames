local parent = script.Parent
local normal = parent:WaitForChild("Normal")
local blink = parent:WaitForChild("Blink")
normal.Transparency = 0
blink.Transparency = 1
script.Parent.Parent.Changed:Connect(function()
	if script.Parent.Parent.Transparency == 1 then
		normal.Transparency = 1
		blink.Transparency = 1
	end
end)

while true do
	normal.Transparency = 1
	blink.Transparency = 0
	task.wait(0.1)
	normal.Transparency = 0
	blink.Transparency = 1
	task.wait(5)
end