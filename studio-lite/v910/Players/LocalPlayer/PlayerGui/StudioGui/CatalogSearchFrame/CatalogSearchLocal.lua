local AvatarEditorService = game:GetService("AvatarEditorService")
local parent = script.Parent
local assetTypeDropDownScrollingFrame = parent:WaitForChild("AssetTypeDropDownScrollingFrame")
local assetTypeDropDownChoiceTextButton = assetTypeDropDownScrollingFrame:WaitForChild("AssetTypeDropDownChoiceTextButton")
local catalogSearchParmsFrame = parent:WaitForChild("CatalogSearchParmsFrame")
local assetTypeButton = catalogSearchParmsFrame:WaitForChild("AssetTypeButton")
local keywordSearchTextBox = catalogSearchParmsFrame:WaitForChild("KeywordSearchTextBox")
local catalogSearchResultsScrollingFrame = parent:WaitForChild("CatalogSearchResultsScrollingFrame")
local oneImagesFrameTemplate = parent:WaitForChild("OneImagesFrameTemplate")
oneImagesFrameTemplate:WaitForChild("ImageButton1")
oneImagesFrameTemplate:WaitForChild("TextButton1")
local autoReplaceTextLabel = catalogSearchParmsFrame:WaitForChild("AutoReplaceTextLabel")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverFunctions = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("ServerFunctions")
local explorerPanel = script.Parent.Parent:WaitForChild("ExplorerPanel")
local enumItems = Enum.AvatarAssetType:GetEnumItems()
local catalogSearchParams = CatalogSearchParams.new()
catalogSearchParams.Limit = 120
catalogSearchParams.AssetTypes = { Enum.AvatarAssetType.HairAccessory }
BundledHeads = {
	{ 11702751287, "Harper-Head by Roblox" },
	{ 12853000475, "Summer-Head by Roblox" },
	{ 6494064291, "Linlin-Head by Roblox" },
	{ 7229684030, "KSI-Head by Roblox" },
	{ 3669152260, "Vanessa-Head by Roblox" },
	{ 91825487614253, "Preppy Girl Head 2.0 Recolor Dynamic Head by portfolio_paulm" },
	{ 137300151198649, "Smoky Eye Siren Face Ajusted Dynamic Head by ryzieisq" }
}

function GetEquippedAssetByTypeFromHumanoid()
	local ids = {}
	local v = explorerPanel.GetSelection:Invoke()[1]

	if v then
		local humanoid = v:FindFirstChild("Humanoid") or v.Parent and (v.Parent:FindFirstChild("Humanoid") or v.Parent.Parent and (v.Parent.Parent:FindFirstChild("Humanoid") or v.Parent.Parent.Parent and v.Parent.Parent.Parent:FindFirstChild("Humanoid")))

		if humanoid then
			local text = assetTypeButton.Text
			local v2 = text == "Hat" and "HatAccessory" or text == "TShirt" and "GraphicTShirt" or text
			local appliedDescription = humanoid:GetAppliedDescription()
			local success, _ = pcall(function()
				if typeof(appliedDescription[v2]) == "number" then
					ids = { (tostring(appliedDescription[v2])) }
				else
					ids = appliedDescription[v2]:split(",")
				end
			end)

			if not success then
				local success2, result = pcall(function()
					if v2:sub(-9) == "Accessory" then
						v2 = v2:sub(1, -10)
					end

					local accessories = appliedDescription:GetAccessories(false)

					for _, accessory in pairs(accessories) do
						if accessory.AccessoryType == Enum.AccessoryType[v2] then
							table.insert(ids, accessory.Id or accessory.AssetId)
						end
					end
				end)

				if not success2 then
					warn(result)
				end
			end
		else
			warn("(1)Select a rig, or build one.")
		end
	else
		warn("(2)Select a rig, or build one.")
	end

	return ids
end

function ApplyDesc(instance, p)
	local humanoidDescription = instance:FindFirstChild("HumanoidDescription")

	if humanoidDescription and humanoidDescription.Torso > 0 then
		local textureIDsByName = {}

		if humanoidDescription.Head == 3064931584 then
			for _, child in pairs(instance.Parent:GetChildren()) do
				if child.ClassName == "MeshPart" then
					textureIDsByName[child.Name] = child.TextureID
				end
			end
		end

		instance:ApplyDescriptionReset(p)

		if humanoidDescription.Head == 3064931584 then
			for _, child in pairs(instance.Parent:GetChildren()) do
				if child.ClassName == "MeshPart" and textureIDsByName[child.Name] then
					child.TextureID = textureIDsByName[child.Name]
				end
			end
		end
	else
		instance:ApplyDescription(p)
	end
end

function RemoveAssetTypeFromHumanoid()
	local v = explorerPanel.GetSelection:Invoke()[1]

	if not v then
		warn("(4)Select a rig, or build one.")
		return
	end

	local humanoid = v:FindFirstChild("Humanoid") or v.Parent and (v.Parent:FindFirstChild("Humanoid") or v.Parent.Parent and (v.Parent.Parent:FindFirstChild("Humanoid") or v.Parent.Parent.Parent and v.Parent.Parent.Parent:FindFirstChild("Humanoid")))

	if not humanoid then
		warn("(3)Select a rig, or build one.")
		return
	end

	local text = assetTypeButton.Text
	local v2 = text == "Hat" and "HatAccessory" or text == "TShirt" and "GraphicTShirt" or text
	local appliedDescription = humanoid:GetAppliedDescription()
	local success, _ = pcall(function()
		if typeof(appliedDescription[v2]) == "number" then
			appliedDescription[v2] = 0
		else
			appliedDescription[v2] = ""
		end

		ApplyDesc(humanoid, appliedDescription)
	end)

	if not success then
		local success2, result = pcall(function()
			if v2:sub(-9) == "Accessory" then
				v2 = v2:sub(1, -10)
			end

			local accessories = appliedDescription:GetAccessories(false)

			for k, accessory in pairs(accessories) do
				if accessory.AccessoryType == Enum.AccessoryType[v2] then
					table.remove(accessories, k)
				end
			end

			appliedDescription:SetAccessories(accessories, false)
			ApplyDesc(humanoid, appliedDescription)
		end)

		if not success2 then
			warn(result)
		end
	end
end

function RemoveAssetIdFromHumanoid(p)
	local v = explorerPanel.GetSelection:Invoke()[1]

	if not v then
		warn("(6)Select a rig, or build one.")
		return
	end

	local humanoid = v:FindFirstChild("Humanoid") or v.Parent and (v.Parent:FindFirstChild("Humanoid") or v.Parent.Parent and (v.Parent.Parent:FindFirstChild("Humanoid") or v.Parent.Parent.Parent and v.Parent.Parent.Parent:FindFirstChild("Humanoid")))

	if not humanoid then
		warn("(5)Select a rig, or build one.")
		return
	end

	local text = assetTypeButton.Text
	local v2 = text == "Hat" and "HatAccessory" or text == "TShirt" and "GraphicTShirt" or text
	local appliedDescription = humanoid:GetAppliedDescription()
	local success, _ = pcall(function()
		if typeof(appliedDescription[v2]) == "number" then
			appliedDescription[v2] = 0
		else
			local v3 = appliedDescription
			local v4 = v2
			local v5, _ = appliedDescription[v2]:gsub(p, "")
			v3[v4] = v5
		end

		ApplyDesc(humanoid, appliedDescription)
	end)

	if not success then
		local success2, result = pcall(function()
			if v2:sub(-9) == "Accessory" then
				v2 = v2:sub(1, -10)
			end

			local accessories = appliedDescription:GetAccessories(false)

			for k, accessory in pairs(accessories) do
				if accessory.AssetId == p or accessory.Id == p then
					table.remove(accessories, k)
				end
			end

			appliedDescription:SetAccessories(accessories, false)
			ApplyDesc(humanoid, appliedDescription)
		end)

		if not success2 then
			warn(result)
		end
	end
end

function AddAssetToHumanoid(assetId)
	local v = explorerPanel.GetSelection:Invoke()[1]

	if not v then
		warn("(8)Select a rig, or build one.")
		return
	end

	local humanoid = v:FindFirstChild("Humanoid") or v.Parent and (v.Parent:FindFirstChild("Humanoid") or v.Parent.Parent and (v.Parent.Parent:FindFirstChild("Humanoid") or v.Parent.Parent.Parent and v.Parent.Parent.Parent:FindFirstChild("Humanoid")))

	if not humanoid then
		warn("(7)Select a rig, or build one.")
		return
	end

	local flag = false
	local text = assetTypeButton.Text
	local v2 = text == "Hat" and "HatAccessory" or text == "TShirt" and "GraphicTShirt" or text
	local appliedDescription = humanoid:GetAppliedDescription()
	local success, _ = pcall(function()
		if typeof(appliedDescription[v2]) == "number" or autoReplaceTextLabel.Text == "AutoReplace" then
			appliedDescription[v2] = assetId
		else
			appliedDescription[v2] ..= "," .. assetId
		end

		ApplyDesc(humanoid, appliedDescription)
		flag = true
	end)

	if not success then
		local success2, result = pcall(function()
			if v2:sub(-9) == "Accessory" then
				v2 = v2:sub(1, -10)
			end

			local accessories = appliedDescription:GetAccessories(false)
			local v3 = {
				Order = 1,
				AssetId = assetId,
				Puffiness = 0.5,
				AccessoryType = Enum.AccessoryType[v2],
				IsLayered = true
			}

			for k, accessory in pairs(accessories) do
				if not (accessory.AccessoryType == Enum.AccessoryType[v2] and (autoReplaceTextLabel.Text == "AutoReplace" or accessory.Id == assetId or accessory.AssetId == assetId)) then
					continue
				end

				table.remove(accessories, k)
			end

			table.insert(accessories, v3)
			appliedDescription:SetAccessories(accessories, false)
			ApplyDesc(humanoid, appliedDescription)
			flag = true
		end)

		if not success2 then
			warn(result)
		end
	end

	if flag then
		serverFunctions:InvokeServer("LoadMeshToRuntimeMeshes", assetId)

		if autoReplaceTextLabel.Text == "AutoReplace" then
			for _, child in pairs(catalogSearchResultsScrollingFrame:GetChildren()) do
				if child.ClassName == "Frame" and child.LayoutOrder == 0 then
					child:Destroy()
				end
			end
		end

		local clone = oneImagesFrameTemplate:Clone()
		clone.LayoutOrder = 0
		clone.ImageButton1.Image = "rbxthumb://type=Asset&id=" .. assetId .. "&w=150&h=150"
		clone.TextButton1.Text = "   REMOVE"
		clone.TextButton1.TextSize = 18
		clone.Parent = catalogSearchResultsScrollingFrame
		clone.Visible = true
		clone.ImageButton1.Activated:Connect(function()
			RemoveAssetIdFromHumanoid(assetId)
			clone:Destroy()
		end)
		clone.TextButton1.Activated:Connect(function()
			RemoveAssetIdFromHumanoid(assetId)
			clone:Destroy()
		end)
	end
end

function GetAssetsIcons()
	for _, child in pairs(catalogSearchResultsScrollingFrame:GetChildren()) do
		if child.ClassName == "Frame" then
			child:Destroy()
		end
	end

	for _, v in pairs(GetEquippedAssetByTypeFromHumanoid()) do
		if not (v and tonumber(v)) then
			continue
		end

		local clone = oneImagesFrameTemplate:Clone()
		clone.LayoutOrder = 0
		clone.ImageButton1.Image = "rbxthumb://type=Asset&id=" .. v .. "&w=150&h=150"
		clone.TextButton1.Text = "   REMOVE"
		clone.TextButton1.TextSize = 18
		clone.Parent = catalogSearchResultsScrollingFrame
		clone.Visible = true
		local v2 = v
		clone.ImageButton1.Activated:Connect(function()
			RemoveAssetIdFromHumanoid(v2)
			clone:Destroy()
		end)
		local v4 = v
		local v5 = clone
		clone.TextButton1.Activated:Connect(function()
			RemoveAssetIdFromHumanoid(v4)
			v5:Destroy()
		end)
	end

	if assetTypeButton.Text == "LeftShoeAccessory" or assetTypeButton.Text == "RightShoeAccessory" then
		catalogSearchParams.Limit = 60
	else
		catalogSearchParams.Limit = 120
	end

	local success, result = pcall(function()
		return AvatarEditorService:SearchCatalog(catalogSearchParams)
	end)

	if success then
		local currentPage = result:GetCurrentPage()

		for _, v in currentPage do
			if assetTypeButton.Text == "LeftShoeAccessory" then
				v.Id = game.AssetService:GetBundleDetailsAsync(v.Id).Items[1].Id
			elseif assetTypeButton.Text == "RightShoeAccessory" then
				v.Id = game.AssetService:GetBundleDetailsAsync(v.Id).Items[2].Id
			end

			local clone = oneImagesFrameTemplate:Clone()
			clone.ImageButton1.Image = "rbxthumb://type=Asset&id=" .. v.Id .. "&w=150&h=150"
			clone.TextButton1.Text = v.Name:sub(1, 22) .. "  Sell:" .. tostring(v.Price)
			clone.Parent = catalogSearchResultsScrollingFrame
			clone.Visible = true
			local v2 = v
			clone.ImageButton1.Activated:Connect(function()
				AddAssetToHumanoid(v2.Id)
			end)
			local v3 = v
			clone.TextButton1.Activated:Connect(function()
				AddAssetToHumanoid(v3.Id)
			end)
		end

		if assetTypeButton.Text == "Head" then
			for _, v in pairs(BundledHeads) do
				local clone = oneImagesFrameTemplate:Clone()
				clone.ImageButton1.Image = "rbxthumb://type=Asset&id=" .. v[1] .. "&w=150&h=150"
				clone.TextButton1.Text = v[2] .. "  Sell:" .. tostring(v.Price)
				clone.Parent = catalogSearchResultsScrollingFrame
				clone.Visible = true
				local v2 = v
				clone.ImageButton1.Activated:Connect(function()
					AddAssetToHumanoid(v2[1])
				end)
				local v3 = v
				clone.TextButton1.Activated:Connect(function()
					AddAssetToHumanoid(v3[1])
				end)
			end
		end
	else
		warn(result)
	end
end

for _, enumItem in ipairs(enumItems) do
	if enumItem.Value >= 19 and enumItem.Value <= 31 or enumItem.Value >= 48 and enumItem.Value <= 61 or enumItem.Value > 72 then
		continue
	end

	local clone = assetTypeDropDownChoiceTextButton:Clone()
	clone.Name = enumItem.Name
	clone.Text = enumItem.Name
	clone.Parent = assetTypeDropDownScrollingFrame
	clone.Visible = true
	local v = enumItem
	clone.Activated:Connect(function()
		if v.Name:sub(-13) == "ShoeAccessory" then
			catalogSearchParams.AssetTypes = {}
			catalogSearchParams.BundleTypes = { Enum.BundleType.Shoes }
		else
			catalogSearchParams.AssetTypes = { Enum.AvatarAssetType[clone.Text] }
			catalogSearchParams.BundleTypes = {}
		end

		assetTypeButton.Text = clone.Text
		assetTypeDropDownScrollingFrame.Visible = false

		if v.Name:sub(-9) == "Accessory" or v.Name == "Hat" then
			autoReplaceTextLabel.Text = "AutoReplace"
			assetTypeDropDownChoiceTextButton.Visible = false
		else
			assetTypeDropDownChoiceTextButton.Visible = true
		end

		GetAssetsIcons()
	end)
end

assetTypeDropDownScrollingFrame.CanvasSize = UDim2.new(
	0,
	0,
	0,
	#assetTypeDropDownScrollingFrame:GetChildren() * assetTypeDropDownChoiceTextButton.AbsoluteSize.Y
)
keywordSearchTextBox.FocusLost:Connect(function()
	catalogSearchParams.SearchKeyword = keywordSearchTextBox.text
	GetAssetsIcons()
end)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		GetAssetsIcons()
	end
end)