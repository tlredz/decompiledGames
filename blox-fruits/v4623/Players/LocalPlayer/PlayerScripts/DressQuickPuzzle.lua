local createVector = vector.create
game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local circleIsland = workspace:WaitForChild("Map"):WaitForChild("CircleIsland", 10)

if not circleIsland then
	return
end

local combo = circleIsland:WaitForChild("Lab"):WaitForChild("Combo")
local v = { Color3.new(1, 0, 0), Color3.new(0, 1, 0), (Color3.new(0, 0, 1)) }
local v2 = {
	Screen1 = 0,
	Screen2 = 0,
	Screen3 = 0,
	Screen4 = 0
}
local v3 = {}

function ee(parent)
	if v3[parent] then
		return
	end

	v3[parent] = true

	if parent.Name:find("Button") then
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Name = "ClickDetector"
		clickDetector.MaxActivationDistance = 30
		clickDetector.MouseClick:Connect(function(_)
			local child = combo:FindFirstChild("Screen" .. string.match(parent.Name, "%d"))
			v2[child.Name] = v2[child.Name] % 3 + 1
			child.Color = v[v2[child.Name]]

			if v2.Screen1 == 1 and v2.Screen2 == 3 and v2.Screen3 == 2 and v2.Screen4 == 3 then
				for _, child2 in pairs(combo:GetChildren()) do
					if child2.Name:find("Button") then
						child2.ClickDetector.MaxActivationDistance = 0
					end
				end

				combo.Parent.Doors.leftdoor:PivotTo(CFrame.new(createVector(-6483.659, 111.43, -5012.834)) * combo.Parent.Doors.leftdoor:GetPivot().Rotation)
				combo.Parent.Doors.rightdoor:PivotTo(CFrame.new(createVector(-6451.058, 111.43, -4994.015)) * combo.Parent.Doors.rightdoor:GetPivot().Rotation)
				combo.Parent.Doors.colormodel.Color = Color3.fromRGB(91, 213, 84)
			end
		end)
		clickDetector.Parent = parent
	end
end

combo.ChildAdded:Connect(ee)

for _, child in pairs(combo:GetChildren()) do
	ee(child)
end