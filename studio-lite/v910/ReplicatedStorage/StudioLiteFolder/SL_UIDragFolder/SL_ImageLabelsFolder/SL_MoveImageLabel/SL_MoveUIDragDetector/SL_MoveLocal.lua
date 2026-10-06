local value = script:WaitForChild("SL_MoveUIDragObjectValue").Value
local parent = value.Parent.Parent.Parent
local parent2 = parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sL_SelectedValue = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("SL_UIDragFolder"):WaitForChild("SL_SelectedValue")
local propertiesPanel = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui"):WaitForChild("PropertiesPanel")
wait(0.5)
local box = nil

for _, child in pairs(propertiesPanel:WaitForChild("List", 9):GetChildren()) do
	if child:WaitForChild("name"):WaitForChild("locked").Text ~= "Position" then
		continue
	end

	box = child:WaitForChild("edit"):WaitForChild("box")
	break
end

while not parent2:IsA("GuiObject") and parent2.ClassName ~= "SurfaceGui" do
	parent2 = parent2.Parent

	if parent2 == game then
		return
	end
end

if parent.ClassName == "ScrollingFrame" then
	value.Parent.Position = UDim2.new()
end

local v2 = nil

local function UpdatePosition(p)
	local absoluteSize = parent2.AbsoluteSize

	if parent2.ClassName == "ScrollingFrame" then
		absoluteSize = parent2.AbsoluteCanvasSize
	end

	local v3 = parent.AbsolutePosition + parent.AbsoluteSize * parent.AnchorPoint + p - v2 - parent2.AbsolutePosition
	parent.Position = UDim2.new(v3.X / absoluteSize.X, 0, v3.Y / absoluteSize.Y, 0)

	if sL_SelectedValue.Value then
		sL_SelectedValue.Value.Position = parent.Position

		if box then
			local position = parent.Position
			box.Text = "{" .. math.floor(position.X.Scale * 1000) / 1000 .. ", " .. math.floor(position.X.Offset * 1000) / 1000 .. "}, {" .. math.floor(position.Y.Scale * 1000) / 1000 .. ", " .. math.floor(position.Y.Offset * 1000) / 1000 .. "}"
		else
			print("Position property not found.")
		end
	end

	v2 = p
end

value.DragStart:Connect(function(p)
	v2 = p
	parent.Position = UDim2.new(
		parent.Position.X.Scale + parent.Position.X.Offset / parent2.AbsoluteSize.X,
		0,
		parent.Position.Y.Scale + parent.Position.Y.Offset / parent2.AbsoluteSize.Y,
		0
	)
end)
value.DragContinue:Connect(UpdatePosition)
value.DragEnd:Connect(UpdatePosition)