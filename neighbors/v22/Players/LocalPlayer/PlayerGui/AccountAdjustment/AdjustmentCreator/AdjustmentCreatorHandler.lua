game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local Items = require(ReplicatedStorage.Assets.Data.Store.Items)
local Skins = require(ReplicatedStorage.Assets.Data.Store.Skins)
local Titles = require(ReplicatedStorage.Assets.Data.Store.Titles)
local Encoder = require(ReplicatedStorage.Modules.Encoder)
local parent = script.Parent
local items = parent.AdjustmentsList.Items
local skins = parent.AdjustmentsList.Skins
local titles = parent.AdjustmentsList.Titles
local values = parent.AdjustmentsList.Values
local search = parent.Search
parent.Close.MouseButton1Click:Connect(function()
	parent.Visible = false
end)
parent.Visible = false
local v = nil
local v2 = {
	Items = 0,
	Titles = 0,
	Skins = 0,
	Values = 0
}
v2.Items = {}
v2.Titles = {}
v2.Skins = {}
v2.Values = {}
local v3 = {}
local v4 = false
local v5 = false
local v6 = false
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local bindableEvent3 = Instance.new("BindableEvent")
items.Title.MouseButton1Click:Connect(function()
	v4 = not v4
	bindableEvent:Fire()
end)
skins.Title.MouseButton1Click:Connect(function()
	v5 = not v5
	bindableEvent2:Fire()
end)
titles.Title.MouseButton1Click:Connect(function()
	v6 = not v6
	bindableEvent3:Fire()
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnItem(childName: string)
	return v:FindFirstChild("Inventory"):FindFirstChild(childName) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnSkin(childName: string)
	return v:FindFirstChild("Skins"):FindFirstChild(childName) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnTitle(childName: string)
	return v:FindFirstChild("Titles"):FindFirstChild(childName) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateToggleCheckbox(display: string)
	local clone = items.List.ToggleTemplate:Clone()
	clone.Visible = true
	clone.Label.Text = display
	clone.Name = display:lower():gsub(" ", "")
	return clone
end

local function CreateTextbox(text: string, text2: number)
	local clone = items.List.TextboxTemplate:Clone()
	clone.Visible = true
	clone.Label.Text = text
	clone.Value.Text = text2
	clone.Name = text:lower():gsub(" ", "")
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RegisterSearchable(element, displayName: string)
	table.insert(v3, {
		Element = element,
		DisplayName = displayName
	})
end

local function ApplySearchFilter()
	local text = search.Text:lower()

	for _, v7 in v3 do
		if text == "" then
			v7.Element.Visible = true
		else
			v7.Element.Visible = v7.DisplayName:lower():find(text, 1, true) ~= nil
		end
	end
end

local function ClearLists()
	for _, v7 in {
		items.List,
		skins.List,
		titles.List,
		values.List
	} do
		for _, guiObject in v7:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Visible then
				guiObject:Destroy()
			end
		end
	end

	table.clear(v3)
end

local function MakeItemsList()
	for k, item in Items do
		if item.DisableAdjustment then
			continue
		end

		local element = CreateToggleCheckbox(item.Display) -- equivalent call inferred; original call site unknown
		element.Parent = items.List
		RegisterSearchable(element, item.Display) -- equivalent call inferred; original call site unknown
		local doesOwnItem = DoesOwnItem(k) -- equivalent call inferred; original call site unknown
		local v9 = doesOwnItem
		-- equivalent calls inferred from this helper; original call sites unknown
		local v12 = k

		local function Update()
			element.Checkbox.BackgroundTransparency = doesOwnItem and 0 or 1

			if doesOwnItem == v9 then
				v2.Items[v12] = nil
			else
				v2.Items[v12] = doesOwnItem
			end
		end

		Update() -- equivalent call inferred; original call site unknown
		local element2 = element
		local v14 = v9
		local v15 = k
		element.Button.MouseButton1Click:Connect(function()
			doesOwnItem = not doesOwnItem
			Update() -- equivalent call inferred; original call site unknown
		end)
		local element3 = element
		local v17 = v9
		local v18 = k
		local connection = bindableEvent.Event:Connect(function()
			doesOwnItem = v4
			Update() -- equivalent call inferred; original call site unknown
		end)
		element.Destroying:Once(function()
			connection:Disconnect()
		end)
	end
end

local function MakeSkinsList()
	for k, skin in Skins do
		local element = CreateToggleCheckbox(skin.Display) -- equivalent call inferred; original call site unknown
		element.Parent = skins.List
		RegisterSearchable(element, skin.Display) -- equivalent call inferred; original call site unknown
		local doesOwnSkin = DoesOwnSkin(k) -- equivalent call inferred; original call site unknown
		local v9 = doesOwnSkin
		-- equivalent calls inferred from this helper; original call sites unknown
		local v12 = k

		local function Update()
			element.Checkbox.BackgroundTransparency = doesOwnSkin and 0 or 1

			if doesOwnSkin == v9 then
				v2.Skins[v12] = nil
			else
				v2.Skins[v12] = doesOwnSkin
			end
		end

		Update() -- equivalent call inferred; original call site unknown
		local element2 = element
		local v14 = v9
		local v15 = k
		element.Button.MouseButton1Click:Connect(function()
			doesOwnSkin = not doesOwnSkin
			Update() -- equivalent call inferred; original call site unknown
		end)
		local element3 = element
		local v17 = v9
		local v18 = k
		local connection = bindableEvent2.Event:Connect(function()
			doesOwnSkin = v5
			Update() -- equivalent call inferred; original call site unknown
		end)
		element.Destroying:Once(function()
			connection:Disconnect()
		end)
	end
end

local function MakeTitlesList()
	for k, title in Titles do
		local element = CreateToggleCheckbox(title.Display) -- equivalent call inferred; original call site unknown
		element.Parent = titles.List
		RegisterSearchable(element, title.Display) -- equivalent call inferred; original call site unknown
		local doesOwnTitle = DoesOwnTitle(k) -- equivalent call inferred; original call site unknown
		local v9 = doesOwnTitle
		-- equivalent calls inferred from this helper; original call sites unknown
		local v12 = k

		local function Update()
			element.Checkbox.BackgroundTransparency = doesOwnTitle and 0 or 1

			if doesOwnTitle == v9 then
				v2.Titles[v12] = nil
			else
				v2.Titles[v12] = doesOwnTitle
			end
		end

		Update() -- equivalent call inferred; original call site unknown
		local element2 = element
		local v14 = v9
		local v15 = k
		element.Button.MouseButton1Click:Connect(function()
			doesOwnTitle = not doesOwnTitle
			Update() -- equivalent call inferred; original call site unknown
		end)
		local element3 = element
		local v17 = v9
		local v18 = k
		local connection = bindableEvent3.Event:Connect(function()
			doesOwnTitle = v6
			Update() -- equivalent call inferred; original call site unknown
		end)
		element.Destroying:Once(function()
			connection:Disconnect()
		end)
	end
end

local function MakeValuesList()
	for _, childName in { "Credits", "Points", "Playtime" } do
		local instance = v:FindFirstChild(childName)

		if not (instance and (instance:IsA("NumberValue") or instance:IsA("IntValue"))) then
			continue
		end

		local text = instance.Value
		local v7 = text
		local text2 = text
		local clone = items.List.TextboxTemplate:Clone()
		clone.Visible = true
		clone.Label.Text = childName
		clone.Value.Text = text2
		clone.Name = childName:lower():gsub(" ", "")
		clone.Parent = values.List
		RegisterSearchable(clone, childName) -- equivalent call inferred; original call site unknown
		-- equivalent calls inferred from this helper; original call sites unknown
		local v10 = childName

		local function Update()
			if text == v7 then
				v2.Values[v10] = nil
			else
				v2.Values[v10] = tonumber(text)
			end
		end

		Update() -- equivalent call inferred; original call site unknown
		local v12 = v7
		local v13 = childName
		clone.Value:GetPropertyChangedSignal("Text"):Connect(function()
			text = tonumber(clone.Value.Text) or v12
			clone.Value.Text = text
			Update() -- equivalent call inferred; original call site unknown
		end)
	end
end

local function MakeEnglishLog()
	local result = {}

	for k, v7 in pairs(v2) do
		if k == "Values" then
			continue
		end

		local lower = k:sub(1, #k - 1):lower()

		for k2, v8 in v7 do
			if v8 then
				table.insert(result, (`Added "{k2}" {lower} to account`))
			else
				table.insert(result, (`Removed "{k2}" {lower} from account`))
			end
		end
	end

	for childName, value in v2.Values do
		if not value then
			continue
		end

		local instance = v:FindFirstChild(childName)

		if not (instance and (instance:IsA("NumberValue") or instance:IsA("IntValue"))) then
			continue
		end

		local value2 = instance.Value

		if value2 < value then
			table.insert(result, (`Increased "{childName}" by {value - value2} ({value2} -> {value})`))
		else
			table.insert(result, (`Decreased "{childName}" by {value2 - value} ({value2} -> {value})`))
		end
	end

	return result
end

local function AdjustAccount(p, p2, p3)
	search.Text = ""
	ClearLists()
	parent.Reason.Text = ""
	v2 = {
		Items = {},
		Titles = {},
		Skins = {},
		Values = {}
	}
	v = Encoder:Decode(p2)
	MakeItemsList()
	MakeSkinsList()
	MakeTitlesList()
	MakeValuesList()
	local description = parent.Description
	local text

	if p then
		text = `Adjusting Account: {p.Name} [{p.UserId}]`
	else
		text = `Adjusting Account: {p3}`
	end

	description.Text = text
	parent.Visible = true
	local mouseButton1ClickConnection = parent.Submit.MouseButton1Click:Once(function()
		Network:fire("AccountAdjusted", p, v2, MakeEnglishLog(), parent.Reason.Text, p3)

		if v then
			v:Destroy()
		end

		parent.Visible = false
	end)
	parent.Close.MouseButton1Click:Once(function()
		mouseButton1ClickConnection:Disconnect()
	end)
end

search:GetPropertyChangedSignal("Text"):Connect(function()
	ApplySearchFilter()
end)
Network:listen("AdjustAccount", function(p, p2, p3: string)
	AdjustAccount(p, p2, p3)
end)