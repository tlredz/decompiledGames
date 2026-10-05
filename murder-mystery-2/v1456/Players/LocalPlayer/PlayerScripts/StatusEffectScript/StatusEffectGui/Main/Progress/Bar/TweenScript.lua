script.Parent:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 4)
task.wait(4)
script:FindFirstAncestor("TrapGUI"):Destroy()