local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
local Gamemodes = require(modules.Neighbors.Gamemodes)
local UI = require(modules.UI)
local Network = require(modules.Network)
local _ = Players.LocalPlayer
local container = script.Parent.Container
local dropdownButton = container.DropdownButton
local options = container.Options
local dropdown = container.Dropdown

local function selectOption()
	local gamemodeOption = workspace:GetAttribute("GamemodeOption")

	for childName, _ in Gamemodes do
		for _, button in container:FindFirstChild(childName):GetChildren() do
			if not button:IsA("TextButton") then
				continue
			end

			local defaultColor = button:WaitForChild("DefaultColor")
			local activeColor = button:WaitForChild("ActiveColor")
			defaultColor.Enabled = tonumber(button.Name) ~= gamemodeOption
			activeColor.Enabled = tonumber(button.Name) == gamemodeOption
		end
	end
end

local function selectGamemode()
	local currentGamemode = workspace:GetAttribute("CurrentGamemode") or "Default"
	dropdownButton.Frame.TextLabel.Text = currentGamemode
	dropdown.Visible = false

	for _, button in dropdown:GetChildren() do
		if button:IsA("TextButton") then
			button.Visible = button.Name ~= currentGamemode
		end
	end

	for childName, _ in Gamemodes do
		local findFirstChild = container:FindFirstChild(childName)
		findFirstChild.Visible = workspace:GetAttribute("CurrentGamemode") == childName
	end
end

local clones = {}

for k, gamemode in Gamemodes do
	local clone = dropdown.Template:Clone()
	local clone2 = options:Clone()
	clone.Text = k
	clone.Name = k
	clone.Parent = dropdown
	clone.Visible = true
	local v = k
	clone.MouseButton1Click:Connect(function()
		dropdown.Visible = not dropdown.Visible
		Network:fire("CustomServerGamemodes", "SetGamemode", v)

		for childName, gamemode2 in Gamemodes do
			local findFirstChild = container:FindFirstChild(childName)
			findFirstChild.Visible = false
		end
	end)
	clone2.Name = k
	clone2.Parent = container
	UI:Bind(clone)
	UI:AddShadowOnHover(clone)
	table.insert(clones, clone2)

	for k2, v2 in gamemode do
		local clone3 = script.Template:Clone()
		clone3.Text = v2.Display
		clone3.Name = tostring(k2)
		clone3.Parent = clone2
		clone3.Visible = true
		UI:Bind(clone3)
		UI:AddShadowOnHover(clone3)
		local v3 = k2
		clone3.MouseButton1Click:Connect(function()
			Network:fire("CustomServerGamemodes", "SetOption", v3)
		end)
	end
end

dropdown.Template:Destroy()
dropdownButton.MouseButton1Click:Connect(function()
	dropdown.Visible = not dropdown.Visible
end)
dropdown:GetPropertyChangedSignal("Visible"):Connect(function()
	dropdownButton.Frame.Arrow.Rotation = dropdown.Visible and 0 or 90

	for _, v in clones do
		v.Visible = not dropdown.Visible
	end
end)
UI:Bind(dropdownButton)
UI:AddShadowOnHover(dropdownButton)
selectGamemode()
selectOption()
workspace:GetAttributeChangedSignal("CurrentGamemode"):Connect(selectGamemode)
workspace:GetAttributeChangedSignal("GamemodeOption"):Connect(selectOption)