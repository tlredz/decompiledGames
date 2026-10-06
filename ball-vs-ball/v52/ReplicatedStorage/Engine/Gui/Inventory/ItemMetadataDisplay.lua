local function formatNumber(value: number)
	return (string.format("%d", (math.max(0, (math.floor(value))))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
		"^,",
		""
	))
end

local ItemMetadataDisplay = {}

function ItemMetadataDisplay.getKillCount(p)
	if typeof(p) ~= "table" then
		return nil
	end

	local metadata = p.metadata
	local killCount

	if typeof(metadata) == "table" then
		killCount = metadata.killCount
	else
		killCount = p.killCount
	end

	if typeof(killCount) == "number" then
		return killCount
	end

	return nil
end

function ItemMetadataDisplay.apply(instance, value: number?, value2: number?, flag: boolean?)
	local visible = typeof(value) == "number"
	local visible2 = typeof(value2) == "number"
	local label = instance:FindFirstChild("展示编号")

	if label and label:IsA("TextLabel") then
		label.Visible = visible

		if not flag then
			label.Text = typeof(value) ~= "number" and "" or "#" .. formatNumber(value)
		end
	end

	local guiObject = instance:FindFirstChild("统计标记")

	if guiObject and guiObject:IsA("GuiObject") then
		guiObject.Visible = visible2
	end

	local guiObject2 = instance:FindFirstChild("击杀数")

	if guiObject2 and guiObject2:IsA("GuiObject") then
		guiObject2.Visible = visible2
		local label2 = guiObject2:FindFirstChild("数值")

		if label2 and label2:IsA("TextLabel") then
			label2.Text = typeof(value2) ~= "number" and "" or formatNumber(value2)
		end
	end
end

return ItemMetadataDisplay