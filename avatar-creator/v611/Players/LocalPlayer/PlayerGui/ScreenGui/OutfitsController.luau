local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local _ = script.Parent
local wearingGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("WearingGui")
local loader = wearingGui.Root.Panel.Loader
local username = loader.Username
local status = loader.Status
local results = loader.Results
local search = loader.Search
local more = loader.More
local outfitSearch = game.ReplicatedStorage:WaitForChild("OutfitSearch")
local outfitLoaderAction = game.ReplicatedStorage:WaitForChild("OutfitLoaderAction")
local flag = false

local function outfitAction(p, id)
	if flag then
		return
	end

	flag = true
	status.Text = p == "Wear" and "Applying outfit..." or "Checking outfit items..."
	local success, result = pcall(function()
		return outfitLoaderAction:InvokeServer(p, {
			id = id
		})
	end)
	flag = false
	status.Text = (not success or type(result) ~= "table") and "Could not load this outfit. Please try again." or result.error or result.message or "Could not load this outfit. Please try again."
end

local flag2 = false
local v = ""
local v2 = ""
local v3 = {}
local count = 0

local function search2(p)
	if flag2 then
		return
	end

	local v4 = p and v2 or username.Text:match("^%s*(.-)%s*$"):gsub("^@", "")

	if v4 == "" then
		status.Text = "Enter a Roblox username to get started."
		return
	end

	flag2 = true
	search.Text = "Searching..."
	MenuFade.Set(more, "Visible", false)
	status.Text = "Loading saved outfits..."

	if not p then
		for _, guiObject in results:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		v3 = {}
		count = 0
		v = ""
		v2 = v4
	end

	local success, result = pcall(function()
		return outfitSearch:InvokeServer(v4, p and v or nil)
	end)
	flag2 = false
	search.Text = "Search"

	if success and type(result) == "table" and not result.error then
		for _, outfit in ipairs(result.outfits) do
			if v3[outfit.id] then
				continue
			end

			v3[outfit.id] = true
			count += 1
			local frame = Instance.new("Frame")
			frame.Name = "Outfit_" .. outfit.id
			frame.BackgroundColor3 = Color3.fromRGB(38, 40, 49)
			frame.BorderSizePixel = 0
			frame.LayoutOrder = count
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 12)
			uICorner.Parent = frame
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.BackgroundTransparency = 1
			imageLabel.Size = UDim2.new(1, -8, 1, -76)
			imageLabel.Position = UDim2.fromOffset(4, 0)
			imageLabel.Image = "rbxthumb://type=Outfit&id=" .. outfit.id .. "&w=420&h=420"
			imageLabel.Parent = frame
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.new(1, -8, 0, 28)
			textLabel.Position = UDim2.new(0, 4, 1, -74)
			textLabel.Text = "Outfit " .. count
			textLabel.Font = Enum.Font.GothamMedium
			textLabel.TextSize = 14
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.Parent = frame

			for i, v5 in ipairs({ "Wear", "BuyAll" }) do
				local textButton = Instance.new("TextButton")
				textButton.Name = v5 == "Wear" and "Wear" or "Buy"
				textButton.Text = v5 == "Wear" and "Wear" or "Buy"
				textButton.Size = UDim2.new(0.5, -9, 0, 32)
				textButton.Position = UDim2.new((i - 1) * 0.5, 5, 1, -38)
				textButton.BackgroundColor3 = Color3.fromRGB(113, 85, 220)
				textButton.TextColor3 = Color3.new(1, 1, 1)
				textButton.Font = Enum.Font.GothamMedium
				textButton.TextSize = 14
				textButton.BorderSizePixel = 0
				local uICorner2 = Instance.new("UICorner")
				uICorner2.CornerRadius = UDim.new(0, 8)
				uICorner2.Parent = textButton
				textButton.Parent = frame
				local v6 = v5
				local v7 = outfit
				textButton.Activated:Connect(function()
					outfitAction(v6, v7.id)
				end)
			end

			frame.Parent = results
		end

		local nextToken = type(result.nextToken) == "string" and result.nextToken or ""
		v = nextToken == v and "" or nextToken
		more.Visible = v ~= ""
		status.Text = count == 0 and "No saved outfits are available for this account." or count .. " saved outfits loaded"
	else
		status.Text = (not success or type(result) ~= "table") and "Search failed. Please try again." or result.error or "Search failed. Please try again."

		if success and type(result) == "table" and result.code == "InventoryPrivate" then
			for _, guiObject in results:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject:Destroy()
				end
			end

			v3 = {}
			count = 0
			v = ""
		end

		more.Visible = v ~= ""
	end
end

search.Activated:Connect(function()
	search2(false)
end)
username.FocusLost:Connect(function(p)
	if p then
		search2(false)
	end
end)
more.Activated:Connect(function()
	search2(true)
end)
local _ = results.UIGridLayout

-- equivalent calls inferred from this helper; original call sites unknown
local function resize()
	local OutfitHubLayout = require(game.ReplicatedStorage.OutfitHubLayout)
	OutfitHubLayout.Apply(wearingGui)
end

results:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
resize() -- equivalent call inferred; original call site unknown