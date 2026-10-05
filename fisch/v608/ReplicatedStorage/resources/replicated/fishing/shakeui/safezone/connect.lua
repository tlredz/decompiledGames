script.Parent.Changed:Connect(function()
	script.Parent.Size = UDim2.new(0.651, 0, 0.662, 0)
end)
task.wait(1)

if script.Parent.Size ~= UDim2.new(0.651, 0, 0.662, 0) then
	script.Parent.Size = UDim2.new(0.651, 0, 0.662, 0)
end