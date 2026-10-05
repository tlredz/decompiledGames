local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local CatalogSearchController = {}
local v = {
	quickLinks = nil
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getCatalogFrames(childName)
	local margin = GameContext.Gui.SelectionFrame:FindFirstChild("Margin")
	local catalogFrame = margin and margin:FindFirstChild("CatalogFrame")
	return catalogFrame and catalogFrame:FindFirstChild(childName)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSearchText(catalogFrames)
	if not catalogFrames then
		return ""
	end

	local searchBar = catalogFrames:FindFirstChild("SearchBar")
	local searchBar2 = searchBar and searchBar:FindFirstChild("SearchBar")
	return searchBar2 and searchBar2.Text or ""
end

local v2 = {
	Template = true,
	ToonTemplate = true
}
local v3 = {
	Template = true,
	TrinketTemplate = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldShowToon(button, p)
	if v2[button.Name] then
		return false
	end

	if p == "" then
		return true
	end

	local displayName = button:GetAttribute("DisplayName")

	if displayName then
		return string.find(string.lower(displayName), p, 1, true) ~= nil
	end

	return false
end

local function shouldShowTrinket(button, p)
	if v3[button.Name] then
		return false
	end

	if p == "" then
		return true
	end

	local displayName = button:GetAttribute("DisplayName")
	local codeName = button:GetAttribute("CodeName")

	if displayName and string.find(string.lower(displayName), p, 1, true) then
		return true
	end

	if codeName and string.find(string.lower(codeName), p, 1, true) then
		return true
	end

	if string.find(string.lower(button.Name), p, 1, true) then
		return true
	end

	return false
end

function CatalogSearchController.updateToons()
	local catalogFrames = getCatalogFrames("Toons") -- equivalent call inferred; original call site unknown
	local toonsCatalog = catalogFrames and catalogFrames:FindFirstChild("ToonsCatalog")

	if not toonsCatalog then
		return
	end

	toonsCatalog.CanvasPosition = Vector2.new(0, 0)
	local searchText = getSearchText(catalogFrames) -- equivalent call inferred; original call site unknown
	local v4 = string.lower(searchText)

	for _, button in pairs(toonsCatalog:GetChildren()) do
		if not button:IsA("GuiButton") then
			continue
		end

		local visible = shouldShowToon(button, v4) -- equivalent call inferred; original call site unknown
		button.Visible = visible
	end
end

function CatalogSearchController.updateTrinkets()
	local catalogFrames = getCatalogFrames("Trinkets") -- equivalent call inferred; original call site unknown
	local trinketsCatalog = catalogFrames and catalogFrames:FindFirstChild("TrinketsCatalog")

	if not trinketsCatalog then
		return
	end

	trinketsCatalog.CanvasPosition = Vector2.new(0, 0)
	local searchText = getSearchText(catalogFrames) -- equivalent call inferred; original call site unknown
	local v4 = string.lower(searchText)

	for _, button in pairs(trinketsCatalog:GetChildren()) do
		if button:IsA("GuiButton") then
			button.Visible = shouldShowTrinket(button, v4)
		end
	end
end

function CatalogSearchController.setupTabSearchBars()
	local catalogFrames = getCatalogFrames("Toons") -- equivalent call inferred; original call site unknown

	if catalogFrames then
		local searchBar = catalogFrames:FindFirstChild("SearchBar")
		local searchBar2 = searchBar and searchBar:FindFirstChild("SearchBar")

		if searchBar2 then
			searchBar2:GetPropertyChangedSignal("Text"):Connect(CatalogSearchController.updateToons)
		end
	end

	local catalogFrames2 = getCatalogFrames("Trinkets") -- equivalent call inferred; original call site unknown

	if catalogFrames2 then
		local searchBar = catalogFrames2:FindFirstChild("SearchBar")
		local searchBar2 = searchBar and searchBar:FindFirstChild("SearchBar")

		if searchBar2 then
			searchBar2:GetPropertyChangedSignal("Text"):Connect(CatalogSearchController.updateTrinkets)
		end
	end
end

function CatalogSearchController.setupQuickLinkBridges()
	local gui = GameContext.Gui
	local quickLinks = v.quickLinks

	if quickLinks then
		local toonSearchBar = quickLinks:FindFirstChild("ToonSearchBar")

		if toonSearchBar and toonSearchBar.Value then
			toonSearchBar.Value.Changed:Connect(CatalogSearchController.updateToons)
		end

		local trinketSearchBar = quickLinks:FindFirstChild("TrinketSearchBar")

		if trinketSearchBar and trinketSearchBar.Value then
			trinketSearchBar.Value.Changed:Connect(CatalogSearchController.updateTrinkets)
		end
	else
		local searchBear = gui.SelectionFrame:FindFirstChild("SearchBear")

		if searchBear then
			searchBear.Changed:Connect(CatalogSearchController.updateToons)
		end

		local trinketsFrame = gui.SelectionFrame:FindFirstChild("TrinketsFrame")
		local trinketFrame = trinketsFrame and trinketsFrame:FindFirstChild("TrinketFrame")
		local searchBear2 = trinketFrame and trinketFrame:FindFirstChild("SearchBear")

		if searchBear2 then
			searchBear2.Changed:Connect(CatalogSearchController.updateTrinkets)
		end
	end
end

function CatalogSearchController.init(p)
	v = p or {
		quickLinks = nil
	}
	CatalogSearchController.setupQuickLinkBridges()
end

return CatalogSearchController