local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local Network = require(ReplicatedStorage.Modules.Network)
local Items = require(ReplicatedStorage.Assets.Data.Store.Items)
local Skins = require(ReplicatedStorage.Assets.Data.Store.Skins)
local Titles = require(ReplicatedStorage.Assets.Data.Store.Titles)
local Gamepasses = require(ReplicatedStorage.Assets.Data.Store.Gamepasses)
local Encoder = require(ReplicatedStorage.Modules.Encoder)
local Date = require(ReplicatedStorage.Modules.Date)
local UI = require(ReplicatedStorage.Modules.UI)
local AdjustHandlerUtil = require(script["AdjustHandler/Util"])
local parent = script.Parent
local parent2 = parent.Parent
local pages = parent.Pages
local hotbar = parent.Hotbar
local textPrompt = parent2.TextPrompt
local contentContainer = textPrompt.ContentContainer
local buttons = contentContainer.Buttons
local itemsList = pages.ItemsList
local skinsList = pages.SkinsList
local titlesList = pages.TitlesList
local valuesList = pages.ValuesList
local passesList = pages.PassesList
local profileList = pages.ProfileList
local warningsList = pages.WarningsList
local itemList = warningsList.WarningsCategory.ItemList
local inputContainer = warningsList.IssueWarnCategory.ItemList.InputContainer
local confirm = inputContainer.Confirm
local textBox = inputContainer.TextboxContainer.TextBox
local itemList2 = profileList.ProfileCategory.ItemList
local itemList3 = profileList.CommentsCategory.ItemList
local accountAge = itemList2.AccountAge
local descriptionExample = itemList2.DescriptionExample
local displayName = itemList2.DisplayName
local username = itemList2.Username
local headshotExample = itemList2.HeadshotExample
local textBox2 = hotbar.SearchBar.Search.TextBox
local confirm2 = hotbar.Confirm
local header = parent.Header
local close = textPrompt.Close
local cancel = buttons.Cancel
local confirm3 = buttons.Confirm
local textBox3 = contentContainer.InputContainer.TextboxContainer.TextBox
local title = contentContainer.TitleDivider.Title
local TEMPDIM = parent2.TEMPDIM
local categoryTemplate = script.CategoryTemplate
local itemExample = script.ItemExample
local skinExample = script.SkinExample
local titleExample = script.TitleExample
local valueExample = script.ValueExample
local passExample = script.PassExample
local warningExample = script.WarningExample
local commentExample = script.ProfileTemplates.CommentExample
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = { "Credits", "Points", "Playtime" }
local v6 = {
	{
		Name = "Items",
		Label = "item",
		Source = Items,
		Folder = "Inventory",
		Page = itemsList,
		Template = itemExample,
		GetCategory = function(p)
			return AdjustHandlerUtil:GetItemCategory(p)
		end,
		GetOrder = function(p, p2: number)
			if p.Group and p.Group.Order then
				return p.Group.Order
			end

			return p2
		end,
		ShouldSkip = function(p)
			return p.DisableAdjustment == true
		end
	},
	{
		Name = "Skins",
		Label = "skin",
		Source = Skins,
		Folder = "Skins",
		Page = skinsList,
		Template = skinExample,
		GetCategory = function(p)
			return AdjustHandlerUtil:GetSkinCategory(p)
		end,
		GetOrder = function(p, p2: number)
			return p.Order or p2
		end
	},
	{
		Name = "Titles",
		Label = "title",
		Source = Titles,
		Folder = "Titles",
		Page = titlesList,
		Template = titleExample,
		GetCategory = function(p)
			return AdjustHandlerUtil:GetTitleCategory(p)
		end,
		GetOrder = function(p, p2: number)
			return p.Order or p2
		end
	},
	{
		Name = "Gamepasses",
		Label = "gamepass",
		Source = Gamepasses,
		Folder = "Gamepasses",
		Page = passesList,
		Template = passExample,
		GetCategory = function(_)
			return "Gamepasses", 0
		end,
		GetOrder = function(p, p2: number)
			return p.Order or p2
		end
	}
}
local v7 = {}
local v8 = {}
local v9 = {}
local clones = {}
local connections = {}
local usernames = {}
local emptyChanges = AdjustHandlerUtil:CreateEmptyChanges()

-- equivalent calls inferred from this helper; original call sites unknown
local function trackGenerated(clone)
	table.insert(v9, clone)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function registerSearchable(clone, value: string, value2: string?)
	table.insert(v7, {
		Element = clone,
		DisplayNameLower = value:lower(),
		CategoryNameLower = not value2 and "" or value2:lower()
	})
end

local function applySearchFilter()
	local text = textBox2.Text:lower()

	for _, v10 in v7 do
		if text == "" then
			v10.Element.Visible = true
		else
			v10.Element.Visible = v10.DisplayNameLower:find(text, 1, true) ~= nil or v10.CategoryNameLower:find(
				text,
				1,
				true
			) ~= nil
		end
	end

	for _, v10 in v8 do
		local v11 = v10.DisplayNameLower:find(text, 1, true) ~= nil
		local v12 = false

		for _, v14 in v10.Children do
			if not v14.Visible then
				continue
			end

			v12 = true
			break
		end

		if text == "" then
			v10.Element.Visible = true
		else
			v10.Element.Visible = v11 or v12
		end
	end
end

local function createCategory(parent3, value: string)
	local clone = categoryTemplate:Clone()
	clone.Name = AdjustHandlerUtil:GetSanitizedName(value)
	clone.Visible = true
	trackGenerated(clone) -- equivalent call inferred; original call site unknown
	AdjustHandlerUtil:SetCategoryTitle(clone, value)
	local itemList4 = clone:FindFirstChild("ItemList")

	if not (itemList4 and itemList4:IsA("GuiObject")) then
		itemList4 = clone
	end

	AdjustHandlerUtil:HideTemplateChildren(itemList4)
	local collapse = clone:FindFirstChild("Collapse")
	local v10 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCollapsed()
		itemList4.Visible = not v10

		if collapse then
			local chevron = collapse:FindFirstChild("Chevron")

			if chevron and chevron:IsA("GuiObject") then
				chevron.Rotation = v10 and -90 or 0
			end
		end
	end

	if collapse then
		AdjustHandlerUtil:ConnectGuiButton(collapse, function()
			v10 = not v10
			updateCollapsed() -- equivalent call inferred; original call site unknown
		end)
	end

	clone.Parent = parent3
	local v11 = {
		Element = clone,
		ItemList = itemList4,
		DisplayNameLower = value:lower(),
		Children = {},
		Count = 0
	}
	table.insert(v8, v11)
	updateCollapsed() -- equivalent call inferred; original call site unknown
	AdjustHandlerUtil:SetCategoryCount(v11)
	return v11
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearWarnings()
	for _, v10 in clones do
		if v10.Parent then
			v10:Destroy()
		end
	end

	table.clear(clones)
end

local function clearLists()
	for _, v10 in v9 do
		if v10.Parent then
			v10:Destroy()
		end
	end

	table.clear(v9)
	clearWarnings() -- equivalent call inferred; original call site unknown

	for _, v10 in {
		itemsList,
		skinsList,
		titlesList,
		valuesList,
		passesList
	} do
		v10.CanvasPosition = Vector2.zero
		AdjustHandlerUtil:HideTemplateChildren(v10)
	end

	table.clear(v7)
	table.clear(v8)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDataChild(childName: string)
	if v then
		return v:FindFirstChild(childName)
	end

	return nil
end

local function getNumericValueObject(childName: string)
	local dataChild = getDataChild(childName) -- equivalent call inferred; original call site unknown

	if not dataChild then
		return nil
	end

	if dataChild:IsA("NumberValue") or dataChild:IsA("IntValue") then
		return dataChild
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function doesOwn(folder: string)
	return function(childName: string)
		local dataChild = getDataChild(folder) -- equivalent call inferred; original call site unknown
		return dataChild ~= nil and dataChild:FindFirstChild(childName) ~= nil
	end
end

local function createToggleRow(template, itemList4, displayName2: string, categoryName: string?)
	local clone = template:Clone()
	clone.Name = AdjustHandlerUtil:GetSanitizedName(displayName2)
	clone.Visible = true
	trackGenerated(clone) -- equivalent call inferred; original call site unknown
	AdjustHandlerUtil:SetTemplateTitle(clone, displayName2)
	AdjustHandlerUtil:SetTemplateSelected(clone, false)
	clone.Parent = itemList4
	registerSearchable(clone, displayName2, categoryName) -- equivalent call inferred; original call site unknown
	return clone
end

local function createValueRow(value: string, value2: number)
	local clone = valueExample:Clone()
	clone.Name = AdjustHandlerUtil:GetSanitizedName(value)
	clone.Visible = true
	trackGenerated(clone) -- equivalent call inferred; original call site unknown
	AdjustHandlerUtil:SetTemplateTitle(clone, value)
	clone.Parent = valuesList
	local textBox4 = AdjustHandlerUtil:GetTextBox(clone)

	if textBox4 then
		textBox4.Text = tostring(value2)
	end

	registerSearchable(clone, value, false) -- equivalent call inferred; original call site unknown
	return clone, textBox4
end

local function getOrCreateCategory(categories, parent3, p2: string)
	local v10 = categories[p2]

	if v10 then
		return v10
	end

	local category = createCategory(parent3, p2)
	categories[p2] = category
	return category
end

local function makeToggleList(data)
	local emptyChange = emptyChanges[data.Name]
	local v10 = doesOwn(data.Folder) -- equivalent call inferred; original call site unknown
	local v11 = {}

	for k, v12 in data.Source do
		if data.ShouldSkip and data.ShouldSkip(v12) then
			continue
		end

		local category, categoryOrder = data.GetCategory(v12)
		table.insert(v11, {
			Key = k,
			DisplayName = v12.Display or k,
			CategoryName = category,
			CategoryOrder = categoryOrder,
			ItemOrder = data.GetOrder(v12, categoryOrder)
		})
	end

	table.sort(v11, function(a, b)
		return AdjustHandlerUtil:SortToggleEntries(a, b)
	end)
	local v12 = {}

	for _, v13 in v11 do
		local page = data.Page
		local categoryName = v13.CategoryName
		local v14 = v12[categoryName]

		if not v14 then
			v14 = createCategory(page, categoryName)
			v12[categoryName] = v14
		end

		local toggleRow = createToggleRow(data.Template, v14.ItemList, v13.DisplayName, v13.CategoryName)
		local v15 = v10(v13.Key)
		local v16 = v15
		-- equivalent calls inferred from this helper; original call sites unknown
		local v19 = v13

		local function update()
			AdjustHandlerUtil:SetTemplateSelected(toggleRow, v15)

			if v15 == v16 then
				emptyChange[v19.Key] = nil
			else
				emptyChange[v19.Key] = v15
			end
		end

		update() -- equivalent call inferred; original call site unknown
		AdjustHandlerUtil:AddRowToCategory(v14, toggleRow)
		local v20 = toggleRow
		local v21 = v16
		local v22 = v13
		AdjustHandlerUtil:ConnectGuiButton(toggleRow, function()
			v15 = not v15
			update() -- equivalent call inferred; original call site unknown
		end)
	end
end

local function makeValuesList()
	for _, v10 in v5 do
		local dataChild = getDataChild(v10) -- equivalent call inferred; original call site unknown

		if dataChild then
			if not (dataChild:IsA("NumberValue") or dataChild:IsA("IntValue")) then
				dataChild = nil
			end
		else
			dataChild = nil
		end

		if not dataChild then
			continue
		end

		local value = dataChild.Value
		local _, v11 = createValueRow(v10, value)

		if not v11 then
			continue
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local v12 = v11
		local v13 = v10
		local v14 = value

		local function update()
			local text = tonumber(v12.Text)

			if not text then
				emptyChanges.Values[v13] = nil
			elseif text == v14 then
				emptyChanges.Values[v13] = nil
			else
				emptyChanges.Values[v13] = text
			end
		end

		v11:GetPropertyChangedSignal("Text"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end
end

local function resolveTargetUserId()
	if v2 then
		return v2.UserId
	end

	if type(v3) == "number" then
		return v3
	end

	if type(v3) ~= "string" then
		return nil
	end

	local success, result = pcall(function()
		return Players:GetUserIdFromNameAsync(v3)
	end)

	if success then
		return result
	end

	return nil
end

local function getTargetNames(p: number?)
	if v2 then
		return v2.Name, v2.DisplayName
	end

	if not p then
		return "unknown", "Unknown"
	end

	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({ p })
	end)

	if success and result[1] then
		return result[1].Username, result[1].DisplayName
	end

	local success2, result2 = pcall(function()
		return Players:GetNameFromUserIdAsync(p)
	end)
	local selected = not success2 and "unknown" or result2
	return selected, selected
end

local function makeProfile()
	if not v then
		return
	end

	local profile = v:FindFirstChild("Profile")
	local targetNames, text = getTargetNames(v4)
	local avatarDecal

	if v2 then
		avatarDecal = UI:GetAvatarDecal(v2)
	else
		avatarDecal = `rbxthumb://type=AvatarHeadShot&id={v4 or 0}&w=150&h=150`
	end

	local bio = v:FindFirstChild("Bio")
	headshotExample.InfoContainer.HeadshotContainer.ImageLabel.Image = avatarDecal
	username.InfoContainer.Amount.Text = `@{targetNames}`
	displayName.InfoContainer.Amount.Text = text
	descriptionExample.InfoContainer.DetailContainer.Description.Text = not bio and "" or bio.Value

	if v2 then
		local joinDate = v:FindFirstChild("JoinDate")
		accountAge.InfoContainer.Amount.Text = not joinDate and "Unknown" or `Joined {Date:FormatDate(joinDate.Value)}`
	end

	if not profile then
		return
	end

	local comments = profile:FindFirstChild("Comments")

	if not comments then
		return
	end

	local parent3 = itemList3.Parent
	local children = comments:GetChildren()

	for k, v11 in children do
		local clone = commentExample:Clone()
		trackGenerated(clone) -- equivalent call inferred; original call site unknown
		clone.InfoContainer.DetailContainer.Description.Text = v11.Content.Value
		clone.InfoContainer.DetailContainer.Title.Text = v11.Username.Value
		clone.LayoutOrder = k
		clone.Parent = parent3
		clone.Visible = true
		local v12 = v11
		clone.InfoContainer.Delete.Activated:Once(function()
			if Network:invoke("Comment/DeleteComment", v2, v12.Name) then
				clone:Destroy()
			end
		end)
	end
end

local function getModeratorName(mod: number?)
	if not mod then
		return "Unknown"
	end

	if usernames[mod] then
		return usernames[mod]
	end

	local username2 = "Unknown"
	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({ mod })
	end)

	if success and result[1] then
		username2 = result[1].Username
	else
		local success2, result2 = pcall(function()
			return Players:GetNameFromUserIdAsync(mod)
		end)

		if success2 then
			username2 = result2
		end
	end

	usernames[mod] = username2
	return username2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatWarningDate(time: number?)
	if type(time) ~= "number" then
		return "an unknown date"
	end

	local success, result = pcall(function()
		return DateTime.fromUnixTimestamp(time):FormatLocalTime("LL", "en-us")
	end)

	if success then
		return result
	end

	return "an unknown date"
end

local makeWarnings

makeWarnings = function()
	clearWarnings() -- equivalent call inferred; original call site unknown
	AdjustHandlerUtil:HideTemplateChildren(itemList)
	local v10 = v4

	if not v10 then
		return
	end

	local success, result = pcall(function()
		return Network:invoke("GetWarnings", v10)
	end)

	if not success or type(result) ~= "table" then
		return
	end

	for k, v11 in result do
		local clone = warningExample:Clone()
		clone.Name = `Warning{k}`
		clone.Visible = true
		clone.LayoutOrder = k
		local detailContainer = clone.InfoContainer.DetailContainer
		detailContainer.Title.Text = v11.Reason or "No reason provided."
		local description = detailContainer.Description
		local moderatorName = getModeratorName(v11.Mod)
		local v13 = formatWarningDate(v11.Time) -- equivalent call inferred; original call site unknown
		description.Text = `Warned by {moderatorName} on {v13}`
		clone.Parent = itemList
		table.insert(clones, clone)
		local v14 = k
		clone.InfoContainer.Delete.Activated:Once(function()
			local success2, result2 = pcall(function()
				return Network:invoke("DeleteWarning", v10, v14)
			end)

			if success2 and result2 then
				makeWarnings()
			end
		end)
	end
end

local function buildLog()
	local result = {}

	for _, v10 in v6 do
		for display, v11 in emptyChanges[v10.Name] do
			local v12 = v10.Source[display]

			if v12 and v12.Display then
				display = v12.Display
			end

			if v11 then
				table.insert(result, (`Added "{display}" {v10.Label} to account`))
			else
				table.insert(result, (`Removed "{display}" {v10.Label} from account`))
			end
		end
	end

	for k, value in emptyChanges.Values do
		local dataChild = getDataChild(k) -- equivalent call inferred; original call site unknown

		if dataChild then
			if not (dataChild:IsA("NumberValue") or dataChild:IsA("IntValue")) then
				dataChild = nil
			end
		else
			dataChild = nil
		end

		if not dataChild then
			continue
		end

		local value2 = dataChild.Value

		if value2 < value then
			table.insert(result, (`Increased "{k}" by {value - value2} ({value2} -> {value})`))
		else
			table.insert(result, (`Decreased "{k}" by {value2 - value} ({value2} -> {value})`))
		end
	end

	return result
end

local function resetTemplateDefaults()
	AdjustHandlerUtil:SetTemplateSelected(categoryTemplate, false)
	AdjustHandlerUtil:SetTemplateSelected(itemExample, false)
	AdjustHandlerUtil:SetTemplateSelected(skinExample, false)
	AdjustHandlerUtil:SetTemplateSelected(titleExample, false)
	AdjustHandlerUtil:SetTemplateSelected(valueExample, false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPromptVisible(visible: boolean)
	textPrompt.Visible = visible
	TEMPDIM.Visible = visible
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectPromptConnections()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end

local function showReasonPrompt(submitAdjustment)
	disconnectPromptConnections() -- equivalent call inferred; original call site unknown
	title.Text = "Adjustment Reason"
	textBox3.Text = ""
	parent.Visible = false
	setPromptVisible(true) -- equivalent call inferred; original call site unknown
	pcall(function()
		textBox3:CaptureFocus()
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function closePrompt(flag: boolean)
		disconnectPromptConnections() -- equivalent call inferred; original call site unknown
		setPromptVisible(false) -- equivalent call inferred; original call site unknown

		if flag and v then
			parent.Visible = true
		end
	end

	table.insert(connections, confirm3.MouseButton1Click:Connect(function()
		local text = textBox3.Text
		closePrompt(false) -- equivalent call inferred; original call site unknown
		submitAdjustment(text)
	end))
	table.insert(connections, cancel.MouseButton1Click:Connect(function()
		disconnectPromptConnections() -- equivalent call inferred; original call site unknown
		setPromptVisible(false) -- equivalent call inferred; original call site unknown

		if v then
			parent.Visible = true
		end
	end))
	table.insert(connections, close.MouseButton1Click:Connect(function()
		disconnectPromptConnections() -- equivalent call inferred; original call site unknown
		setPromptVisible(false) -- equivalent call inferred; original call site unknown

		if v then
			parent.Visible = true
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeAdjustments()
	disconnectPromptConnections() -- equivalent call inferred; original call site unknown
	setPromptVisible(false) -- equivalent call inferred; original call site unknown
	textBox2.Text = ""
	clearLists()

	if v then
		v:Destroy()
		v = nil
	end

	v2 = nil
	v3 = nil
	v4 = nil
	emptyChanges = AdjustHandlerUtil:CreateEmptyChanges()
	parent.Visible = false
end

local function submitAdjustment(p: string)
	if not v then
		return
	end

	local log = buildLog()
	Network:fire("AccountAdjusted", v2, emptyChanges, log, p, v3)
	closeAdjustments() -- equivalent call inferred; original call site unknown
end

local function adjustAccount(p, p2, p3)
	closeAdjustments() -- equivalent call inferred; original call site unknown
	local folder = Encoder:Decode(p2)

	if typeof(folder) ~= "Instance" or not folder:IsA("Folder") then
		return
	end

	v2 = p
	v3 = p3
	local result

	if v2 then
		result = v2.UserId
	elseif type(v3) == "number" then
		result = v3
	elseif type(v3) == "string" then
		local success
		success, result = pcall(function()
			return Players:GetUserIdFromNameAsync(v3)
		end)

		if not success then
			result = nil
		end
	end

	v4 = result
	v = folder

	for _, v10 in v6 do
		makeToggleList(v10)
	end

	makeValuesList()
	makeProfile()
	makeWarnings()
	local textLabel = AdjustHandlerUtil:GetTextLabel(header, "Title")

	if textLabel then
		local text

		if p then
			text = `Adjusting {p.Name} [{p.UserId}]`
		else
			text = `Adjusting {p3}`
		end

		textLabel.Text = text
	end

	parent.Visible = true
end

descriptionExample.InfoContainer.Delete.Activated:Connect(function()
	if not v2 then
		return
	end

	Network:fire("DeleteBio", v2)
	descriptionExample.InfoContainer.DetailContainer.Description.Text = ""
end)
header.Close.MouseButton1Click:Connect(closeAdjustments)
confirm2.MouseButton1Click:Connect(function()
	showReasonPrompt(submitAdjustment)
end)
confirm.MouseButton1Click:Connect(function()
	local v10 = v4

	if not v10 then
		return
	end

	local text = textBox.Text

	if #text < 4 then
		return
	end

	local success, result = pcall(function()
		return Network:invoke("IssueWarning", v10, text)
	end)

	if success and result then
		textBox.Text = ""
		makeWarnings()
	end
end)
textBox2:GetPropertyChangedSignal("Text"):Connect(applySearchFilter)
resetTemplateDefaults()
setPromptVisible(false) -- equivalent call inferred; original call site unknown
Network:listen("AdjustAccount", adjustAccount)
parent.Visible = false
UI:RegisterConstantUIScale(script.Parent.UIScale, {
	PC = 2.4,
	Mobile = 1.2,
	Tablet = 1
})