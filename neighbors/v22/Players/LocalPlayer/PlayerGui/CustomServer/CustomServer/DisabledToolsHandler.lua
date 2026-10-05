local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Items = require(ReplicatedStorage.Assets.Data.Store.Items)
local Stats = require(game.ReplicatedStorage.Modules.Stats)
require(ReplicatedStorage.Modules.FormatTable)
local CurrentCustomServerData = require(script.Parent.CustomServerHandler.CurrentCustomServerData)
local UI = require(game.ReplicatedStorage.Modules.UI)
local playerGui = Players.LocalPlayer.PlayerGui
local customServerDisabledTools = playerGui:WaitForChild("Prompts"):WaitForChild("CustomServerDisabledTools")
local items = playerGui:WaitForChild("Neighbors").Shop.Pages.Items
local disableTools = script:FindFirstAncestor("CustomServer").Pages.Main.List.DisableTools

while task.wait() and not (CurrentCustomServerData.Data and CurrentCustomServerData.Data.DisabledTools) do

end

local clone = not CurrentCustomServerData.Data.DisabledTools and {} or table.clone(CurrentCustomServerData.Data.DisabledTools) or {}
local flag = false

function tablesAreIdentical(items2, items3)
	if items2 == items3 then
		return true
	end

	if type(items2) ~= "table" or type(items3) ~= "table" then
		return items2 == items3
	end

	for k, item in items2 do
		if not tablesAreIdentical(item, items3[k]) then
			return false
		end
	end

	for k in items3 do
		if items2[k] == nil then
			return false
		end
	end

	return true
end

local function update()
	local v = clone

	if not v then
		return
	end

	for childName, _ in Items do
		local index = table.find(v, childName)
		local child = customServerDisabledTools.List:FindFirstChild(childName)

		if child then
			child.Disabled.Visible = index
		end

		local child2 = items:FindFirstChild(childName:gsub(" ", "_"):lower(), true)

		if child2 then
			child2.Disabled.Visible = index
		end
	end

	disableTools.Title.Text = `Disabled Tools <font weight="Regular">({#clone})</font>`
	customServerDisabledTools.Buttons.Confirm.Blocked.Visible = tablesAreIdentical(
		CurrentCustomServerData.Data and CurrentCustomServerData.Data.DisabledTools or clone,
		clone
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function open()
	clone = CurrentCustomServerData.Data and table.clone(CurrentCustomServerData.Data.DisabledTools) or clone
	update()
	flag = true
	customServerDisabledTools.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function close()
	update()
	flag = false
	customServerDisabledTools.Visible = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleUI()
	if flag then
		close() -- equivalent call inferred; original call site unknown
	else
		open() -- equivalent call inferred; original call site unknown
	end
end

local function updateSearch()
	local text = customServerDisabledTools.Search.Text:lower()

	for _, frame in customServerDisabledTools.List:GetChildren() do
		if frame:IsA("Frame") and frame.Name ~= "Template" then
			frame.Visible = frame.Name:lower():match(text)
		end
	end
end

local function registerItem(item)
	if customServerDisabledTools.List:FindFirstChild(item.Name) then
		return
	end

	local clone2 = customServerDisabledTools.List.Template:Clone()
	clone2.Icon.Image = item.RoundIcon or item.Icon
	clone2.Title.Text = item.Display
	clone2.Name = item.Name
	clone2.Parent = customServerDisabledTools.List
	clone2.Visible = true
	UI:Bind(clone2.Button)
	UI:AddShadowOnHover(clone2.Button)
	clone2.Button.Activated:Connect(function()
		if table.find(clone, item.Name) then
			table.remove(clone, table.find(clone, item.Name))
			clone2.Disabled.Visible = false
		else
			table.insert(clone, item.Name)
			clone2.Disabled.Visible = true
		end

		customServerDisabledTools.Buttons.Confirm.Blocked.Visible = tablesAreIdentical(
			CurrentCustomServerData.Data and CurrentCustomServerData.Data.DisabledTools or clone,
			clone
		)
	end)
end

customServerDisabledTools.Visible = false
customServerDisabledTools.Position = UDim2.fromScale(0.5, 0.5)
close() -- equivalent call inferred; original call site unknown

for _, item in Items do
	if not item.Offsale then
		registerItem(item)
	end
end

if RunService:IsStudio() then
	disableTools.Visible = true
end

Stats.CustomServer:GetPropertyChangedSignal("Data"):Connect(update)
disableTools.Value.Button.MouseButton1Click:Connect(function()
	toggleUI() -- equivalent call inferred; original call site unknown
end)
UI:Bind(customServerDisabledTools.Buttons.Confirm.Button)
UI:Bind(customServerDisabledTools.Buttons.Cancel.Button)
UI:AddShadowOnHover(customServerDisabledTools.Buttons.Confirm.Button)
UI:AddShadowOnHover(customServerDisabledTools.Buttons.Cancel.Button)
customServerDisabledTools.Buttons.Confirm.Button.MouseButton1Click:Connect(function()
	if CurrentCustomServerData.Data then
		CurrentCustomServerData.Data.DisabledTools = table.clone(clone)
	end

	close() -- equivalent call inferred; original call site unknown
end)
customServerDisabledTools.Buttons.Cancel.Button.MouseButton1Click:Connect(function()
	clone = CurrentCustomServerData.Data.DisabledTools and table.clone(CurrentCustomServerData.Data.DisabledTools) or {}
	close() -- equivalent call inferred; original call site unknown
end)
customServerDisabledTools.Search:GetPropertyChangedSignal("Text"):Connect(updateSearch)
update()