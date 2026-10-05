local UserInputService = game:GetService("UserInputService")
local whitePaper = script.Parent:WaitForChild("WhitePaper")
local clearButton = script.Parent:WaitForChild("ClearButton")
local pointer = whitePaper:WaitForChild("Pointer")
local paint2 = whitePaper:WaitForChild("Paint"):WaitForChild("Paint")
game.Players.LocalPlayer:GetMouse()
local v = false
local v2 = false

for _, child in pairs(paint2:GetChildren()) do
	if not child:isA("ImageButton") then
		continue
	end

	local v3 = child
	child.MouseButton1Click:connect(function()
		if v == false then
			v = true
			local brickColor = BrickColor.new(v3.Color.Value)
			local color = brickColor.Color
			pointer.BackgroundColor3 = brickColor.Color
			wait(0.2)
			v = false
		end
	end)
end

function paint(p, p2)
	local X = whitePaper.AbsolutePosition.X
	local Y = whitePaper.AbsolutePosition.Y
	local vector = Vector2.new(math.abs(p - X), (math.abs(p2 - Y - 36)))
	pointer.Position = UDim2.new(0, vector.X, 0, vector.Y)

	if v2 == false then
		return
	end

	local clone = pointer:Clone()
	clone.Name = "Pixel"
	clone.Parent = whitePaper
end

function clear()
	local children = whitePaper:GetChildren()

	for _, v3 in pairs(children) do
		if v3.Name == "Pixel" then
			v3:Destroy()
		end
	end
end

function showPointer()
	pointer.Visible = true
end

function hidePointer()
	pointer.Visible = false
end

function inputBegan(p)
	if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
		v2 = true
	end
end

function inputEnded(p)
	if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
		v2 = false
	end
end

clearButton.MouseButton1Click:Connect(clear)
UserInputService.InputBegan:Connect(inputBegan)
UserInputService.InputEnded:Connect(inputEnded)
whitePaper.MouseMoved:Connect(paint)
whitePaper.MouseEnter:Connect(showPointer)
whitePaper.MouseLeave:Connect(hidePointer)