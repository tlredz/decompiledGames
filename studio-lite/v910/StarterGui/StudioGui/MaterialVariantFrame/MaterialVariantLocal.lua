local getSelection = script.Parent.Parent:WaitForChild("ExplorerPanel"):WaitForChild("GetSelection")
local propertiesPanel = script.Parent.Parent:WaitForChild("PropertiesPanel")
local materialVariantFrame = script.Parent.Parent:WaitForChild("MaterialVariantFrame")

function ButtonPressed(material, p)
	local v = getSelection:Invoke()

	if not v or typeof(v) ~= "table" then
		materialVariantFrame.Visible = false
		return
	end

	for _, v2 in pairs(v) do
		v2.Material = material
		v2.MaterialVariant = p
	end

	for _, child in pairs(propertiesPanel:WaitForChild("List", 9):GetChildren()) do
		if child:WaitForChild("name"):WaitForChild("locked").Text == "Material" then
			local locked = child:WaitForChild("edit"):WaitForChild("locked")
			locked.Text = material.Name
		elseif child:WaitForChild("name"):WaitForChild("locked").Text == "MaterialVariant" then
			local locked_2 = child:WaitForChild("edit"):WaitForChild("locked")
			locked_2.Text = p
		end
	end
end

for _, child in pairs(materialVariantFrame:WaitForChild("ScrollingFrame"):GetChildren()) do
	if child.ClassName ~= "TextButton" then
		continue
	end

	local v = child
	child.MouseButton1Click:Connect(function()
		local match = v.Text:match("^%s*(.*)")
		ButtonPressed(v:GetAttribute("Material"), match)
	end)
end