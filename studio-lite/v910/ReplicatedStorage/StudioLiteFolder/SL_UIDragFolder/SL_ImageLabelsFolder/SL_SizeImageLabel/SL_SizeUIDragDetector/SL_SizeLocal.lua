local value = script:WaitForChild("SL_SizeUIDragObjectValue").Value
local parent = value.Parent.Parent.Parent
local parent2 = parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sL_SelectedValue = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("SL_UIDragFolder"):WaitForChild("SL_SelectedValue")
local propertiesPanel = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui"):WaitForChild("PropertiesPanel")
wait(0.5)
local box = nil

for _, child in pairs(propertiesPanel:WaitForChild("List", 9):GetChildren()) do
	if child:WaitForChild("name"):WaitForChild("locked").Text ~= "Size" then
		continue
	end

	box = child:WaitForChild("edit"):WaitForChild("box")
	break
end

while not parent2:IsA("GuiObject") and parent2.ClassName ~= "SurfaceGui" do
	parent2 = parent2.Parent

	if parent2 ~= game then
		continue
	end

	warn("Gui Dragger only works on anscestors of StarterGui and SurfaceGui.")
	return
end

if parent.ClassName == "ScrollingFrame" then
	value.Parent.Position = UDim2.new(1, -15, 0, parent.AbsoluteSize.Y)
end

local v2 = nil

local function UpdateSizeOfParent(p)
	local absoluteSize = parent2.AbsoluteSize

	if parent2.ClassName == "ScrollingFrame" then
		absoluteSize = parent2.AbsoluteCanvasSize
	end

	parent.Size = UDim2.new(
		(parent.AbsoluteSize.X + p.X - v2.X) / absoluteSize.X,
		0,
		(parent.AbsoluteSize.Y + p.Y - v2.Y) / absoluteSize.Y,
		0
	)

	if parent.ClassName == "ScrollingFrame" then
		value.Parent.Position = UDim2.new(1, -15, 0, parent.AbsoluteSize.Y)
	end

	if sL_SelectedValue.Value then
		sL_SelectedValue.Value.Size = parent.Size

		if box then
			local size = parent.Size
			box.Text = "{" .. math.floor(size.X.Scale * 1000) / 1000 .. ", " .. math.floor(size.X.Offset * 1000) / 1000 .. "}, {" .. math.floor(size.Y.Scale * 1000) / 1000 .. ", " .. math.floor(size.Y.Offset * 1000) / 1000 .. "}"
		else
			print("Size property not found.")
		end
	end

	v2 = p
end

value.DragStart:Connect(function(p)
	v2 = p
	UpdateSizeOfParent(p)
end)
value.DragContinue:Connect(UpdateSizeOfParent)
value.DragEnd:Connect(UpdateSizeOfParent)