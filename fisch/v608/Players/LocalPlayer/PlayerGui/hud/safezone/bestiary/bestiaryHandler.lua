local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local parent = script.Parent
local tabs = parent.tabs
local search = parent.fish.search
local WorldController = require(legacyControllers.WorldController)
local locations = require(modules.library.locations)
local Bestiaries = require(script.Bestiaries)
local FishInventory = require(script.FishInventory)
require(script.Types)
Bestiaries.currentBestiary = WorldController:GetCurrentWorldBestiary()
Bestiaries.lastCategoryLocation.Normal = Bestiaries.currentBestiary
Bestiaries.currentCategory = "Normal"
task.wait(2)

for _, v in { "Normal", "Limited" } do
	Bestiaries:CreateCategory(v)
end

for k, location in pairs(locations) do
	Bestiaries:CreateLocation(location.Limited == true and "Limited" or "Normal", k)
end

Bestiaries:LoadBestiaryCatagory()
FishInventory:LoadBestiary(Bestiaries.categories)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSearch(_: string?)
	local text = string.lower(search.Text)
	local currentCategory = Bestiaries.currentCategory
	local currentBestiary = Bestiaries.currentBestiary

	if currentCategory and currentBestiary then
		FishInventory:UpdateSearch(text, Bestiaries.categories, currentCategory, currentBestiary)
	end
end

local function setUpBestiary()
	if script.Parent.Visible then
		FishInventory.fishInventoryTrove:Connect(search:GetPropertyChangedSignal("Text"), function()
			string.lower(search.Text)
			local text = string.lower(search.Text)
			local currentCategory = Bestiaries.currentCategory
			local currentBestiary = Bestiaries.currentBestiary

			if currentCategory then
				if not currentBestiary then
					return
				end

				FishInventory:UpdateSearch(text, Bestiaries.categories, currentCategory, currentBestiary)
			end
		end)
		Bestiaries.bestiaryTrove:Add(Bestiaries.onCategoryChange:Connect(function()
			Bestiaries:LoadBestiaryEvent()
			updateSearch() -- equivalent call inferred; original call site unknown
			FishInventory.currentSelected = nil
		end))
		Bestiaries.bestiaryTrove:Add(Bestiaries.onLocationChange:Connect(function()
			Bestiaries:LoadBestiaryEvent()
			local text = string.lower(search.Text)
			local currentCategory = Bestiaries.currentCategory
			local currentBestiary = Bestiaries.currentBestiary

			if currentCategory then
				if not currentBestiary then
					return
				end

				FishInventory:UpdateSearch(text, Bestiaries.categories, currentCategory, currentBestiary)
			end
		end))
		updateSearch() -- equivalent call inferred; original call site unknown

		if FishInventory.currentSelected then
			local currentCategory = Bestiaries.currentCategory
			local currentBestiary = Bestiaries.currentBestiary

			if not (currentCategory and currentBestiary) then
				return
			end

			Bestiaries:LoadBestiaryEvent()
			local v = currentCategory and Bestiaries.categories[currentCategory]
			local v2 = (v and v.locations[currentBestiary]).bestiary[FishInventory.currentSelected]

			if not v2 then
				return
			end

			FishInventory:UpdateSelect(FishInventory.currentType, FishInventory.currentSelected, v2.frame, true)
		end
	else
		FishInventory.fishInventoryTrove:Clean()
		Bestiaries.bestiaryTrove:Clean()
		FishInventory:UpdateSearch(nil, Bestiaries.categories)
	end
end

local function updateBestiaryType(name)
	if FishInventory.currentType == name then
		return
	end

	FishInventory.currentType = name
	Bestiaries.currentType = FishInventory.currentType

	if Bestiaries.currentBestiary == "Limited" then
		Bestiaries.currentBestiary = "All"
	end

	setUpBestiary()
	FishInventory:UpdateSelect(name, "", nil, true)
	Bestiaries:LoadBestiaryCatagory()
	local normalCategory = script.Parent:FindFirstChild("NormalCategory")

	if normalCategory then
		local scroll = normalCategory.scroll
		local _1Limited = scroll:FindFirstChild("1 Limited")
		_1Limited.Visible = FishInventory.currentType == "rod"
		Bestiaries:UpdateCanvasSize(scroll, scroll.UIListLayout)
	end
end

setUpBestiary()
script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	setUpBestiary()
end)

for _, button in tabs:GetChildren() do
	if not button:IsA("GuiButton") then
		continue
	end

	local v = button
	button.MouseButton1Click:Connect(function()
		updateBestiaryType(v.Name)
	end)
end