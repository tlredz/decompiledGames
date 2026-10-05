local v = {
	Common = 10,
	Uncommon = 20,
	Rare = 30,
	Royalty = 40,
	Unique = 50,
	["???"] = 60,
	Collectible = 70
}
local Util = {}

function Util.CreateEmptyChanges(_)
	return {
		Items = {},
		Titles = {},
		Skins = {},
		Gamepasses = {},
		Values = {}
	}
end

function Util:GetTextLabel(folder, p: string)
	for _, label in folder:GetDescendants() do
		if label.Name == p and label:IsA("TextLabel") then
			return label
		end
	end

	return nil
end

function Util.GetTextBox(_, folder)
	for _, textBox in folder:GetDescendants() do
		if textBox:IsA("TextBox") then
			return textBox
		end
	end

	return nil
end

function Util.GetSanitizedName(_, value: string)
	local v2 = value:lower():gsub("[^%w]+", "")

	if v2 == "" then
		return "entry"
	end

	return v2
end

function Util:SetTextLabelBold(p)
	if not pcall(function()
		p.FontFace = Font.new(p.FontFace.Family, Enum.FontWeight.Bold, p.FontFace.Style)
	end) then
		p.Font = Enum.Font.GothamBold
	end
end

function Util:SetTemplateTitle(p, text: string)
	local textLabel = self:GetTextLabel(p, "Title")

	if not textLabel then
		return
	end

	textLabel.Text = text
end

function Util:SetCategoryTitle(instance, text: string)
	local collapse = instance:FindFirstChild("Collapse")
	local infoContainer = collapse and collapse:FindFirstChild("InfoContainer")

	if infoContainer then
		local title = infoContainer:FindFirstChild("Title")

		if title and title:IsA("TextLabel") then
			title.Text = text
			self:SetTextLabelBold(title)
			return
		end
	end

	local textLabel = self:GetTextLabel(instance, "Title")

	if textLabel then
		textLabel.Text = text
		self:SetTextLabelBold(textLabel)
	end
end

function Util.SetTemplateSelected(_, folder, visible: boolean)
	for _, guiObject in folder:GetDescendants() do
		if guiObject.Name == "Enabled" and guiObject:IsA("GuiObject") then
			guiObject.Visible = visible
		end
	end
end

function Util.ConnectGuiButton(_, button, onMouseButton1Click)
	if button:IsA("GuiButton") then
		return button.MouseButton1Click:Connect(onMouseButton1Click)
	end

	local button2 = button:FindFirstChild("Button", true)

	if button2 and button2:IsA("GuiButton") then
		return button2.MouseButton1Click:Connect(onMouseButton1Click)
	end

	return nil
end

function Util.HideTemplateChildren(_, instance)
	for _, guiObject in instance:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Name:find("Example") then
			guiObject.Visible = false
		end
	end
end

function Util:SetCategoryCount(p)
	local textLabel = self:GetTextLabel(p.Element, "Badge")

	if not textLabel then
		return
	end

	textLabel.Text = tostring(p.Count)
end

function Util:AddRowToCategory(state, p)
	state.Count += 1
	table.insert(state.Children, p)
	self:SetCategoryCount(state)
end

function Util.GetItemCategory(_, data)
	if data.LimitedTime then
		return "Limited Time", 0
	end

	if data.Offsale then
		return "Offsale", 1
	end

	local group = data.Group

	if group and group.Name then
		return group.Name, (group.Order or 100) + 10
	end

	return "Other", 1000
end

function Util.GetSkinCategory(_, data)
	if data.LimitedTime then
		return "Limited Time", 0
	end

	if data.Price == 1e999 then
		return "Offsale", 1
	end

	if data.Rarity then
		return data.Rarity, v[data.Rarity] or 100
	end

	return "Other", 1000
end

function Util.GetTitleCategory(_, p)
	if p.Category then
		return p.Category, p.Order or 1000
	end

	return "Other", p.Order or 1000
end

function Util.SortToggleEntries(_, data, data2)
	if data.CategoryOrder ~= data2.CategoryOrder then
		return data.CategoryOrder < data2.CategoryOrder
	end

	if data.CategoryName ~= data2.CategoryName then
		return data.CategoryName < data2.CategoryName
	end

	if data.ItemOrder == data2.ItemOrder then
		return data.DisplayName < data2.DisplayName
	end

	return data.ItemOrder < data2.ItemOrder
end

return Util