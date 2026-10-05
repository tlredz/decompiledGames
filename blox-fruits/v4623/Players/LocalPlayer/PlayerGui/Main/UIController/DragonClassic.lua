local classicDragon = script.Parent.Parent.ClassicDragon
local children = {}
local v = false
local v2 = {}

for _, child in pairs(classicDragon.Container.List.Container:GetChildren()) do
	local match = child.Name:match("Option(%d)")

	if not match then
		continue
	end

	local v3 = child

	local function Update()
		if v3:GetAttribute("Selected") then
			v3.BorderColor3 = Color3.fromRGB(255, 197, 20)
			v3.SelectedGlow.Visible = true
		else
			v3.BorderColor3 = Color3.fromRGB(0, 0, 0)
			v3.SelectedGlow.Visible = false
		end

		if v3:GetAttribute("Hovered") then
			local visible = classicDragon.Confirm.Visible
		end
	end

	child:GetAttributeChangedSignal("Selected"):Connect(Update)
	child:GetAttributeChangedSignal("Hovered"):Connect(Update)
	classicDragon.Confirm:GetPropertyChangedSignal("Visible"):Connect(Update)
	local v4 = child
	child.MouseEnter:Connect(function()
		for k, v5 in pairs(children) do
			v5:SetAttribute("Hovered", v5 == v4)
		end
	end)
	local v5 = child
	child.MouseLeave:Connect(function()
		v5:SetAttribute("Hovered", false)
	end)
	local v6 = child
	local v7 = match
	child.Activated:Connect(function()
		if classicDragon.Confirm.Visible then
			return
		end

		for k, v8 in pairs(children) do
			v8:SetAttribute("Selected", v8 == v6)
		end

		v = tonumber(v7)
	end)
	table.insert(children, child)
end

local v3 = {}
classicDragon:GetPropertyChangedSignal("Visible"):Connect(function()
	for _, v4 in pairs(children) do
		v4:SetAttribute("Hovered", false)
		v4:SetAttribute("Selected", false)
	end

	v = false

	for _, connection in pairs(v3) do
		connection:Disconnect()
	end

	v3 = {}
end)

local function fn(p)
	warn(p)

	for _, connection in pairs(v3) do
		connection:Disconnect()
	end

	v3 = {}
	local connections = {}
	local v4 = p == "Activate" and {} or {
		false,
		"Fruit",
		"Gamepass",
		"Swordsman"
	}

	if p == "Permanent" then
		classicDragon.Container.Visible = true
		classicDragon.Title.Visible = true
		classicDragon.Info.Visible = true
		classicDragon.Confirm.Visible = false
		classicDragon.Confirm.BackgroundTransparency = 0
		classicDragon.Info.Cancel.TextLabel.Text = "Cancel"
		table.insert(connections, classicDragon.Info.Cancel.Activated:Connect(function()
			classicDragon.Visible = false
		end))
	elseif p == "Physical" then
		classicDragon.Container.Visible = false
		classicDragon.Title.Visible = false
		classicDragon.Info.Visible = false
		classicDragon.Confirm.Visible = true
		classicDragon.Confirm.BackgroundTransparency = 1
		classicDragon.Confirm.Container.Content.TextLabel.Text = "Would you like to convert this to a random <font color=\"#ffff00\">Mythical Fruit</font>?"
		table.insert(connections, classicDragon.Confirm.Container.Bottom.Cancel.Activated:Connect(function()
			classicDragon.Visible = false
		end))
	else
		classicDragon.Container.Visible = false
		classicDragon.Title.Visible = false
		classicDragon.Info.Visible = false
		classicDragon.Confirm.Visible = true
		classicDragon.Confirm.BackgroundTransparency = 1
		local _ = game.Players.LocalPlayer.Data.DevilFruit.Value
		local _ = (game.Players.LocalPlayer:GetAttribute("ClassicDragonFruits") or 0) < 1
		classicDragon.Confirm.Container.Content.TextLabel.Text = [[
Would you like to equip <font color="#fee447">&lt;Dragon Fruit&gt;</font>?

<font color="#ff0000">THIS WILL REPLACE YOUR CURRENT FRUIT!</font>]]
		table.insert(connections, classicDragon.Confirm.Container.Bottom.Cancel.Activated:Connect(function()
			classicDragon.Visible = false
		end))
	end

	for i = 1, 4 do
		local child = classicDragon.Container.List.Container:FindFirstChild("Option" .. i)
		local v5 = v4[i]

		if v5 then
			child.Visible = true
			v2[i] = v5
		else
			child.Visible = false
		end
	end

	classicDragon.Visible = true
	classicDragon.Info.Cancel.Visible = false
	table.insert(connections, classicDragon.Confirm.Container.Bottom.Cancel.Activated:Connect(function()
		classicDragon.Confirm.Visible = false
	end))
	local v5 = nil
	table.insert(connections, classicDragon.Confirm.Container.Bottom.Confirm.Activated:Connect(function()
		classicDragon.Confirm.Visible = false
		classicDragon.Visible = false
		game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ClassicDragonConvert", p, v5)
	end))
	table.insert(connections, classicDragon.Info.Confirm.Activated:Connect(function()
		if not v then
			return
		end

		if v2[v] == "Upgrade" then
			local v6 = v
			classicDragon.Visible = false
			game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ClassicDragonConvert", p, v2[v6])
		else
			v5 = v2[v]
			classicDragon.Confirm.Container.Content.TextLabel.Text = "You have chosen to convert your " .. p .. " Dragon to " .. v2[v] .. " items.\nTHIS CAN'T BE UNDONE!"
			classicDragon.Confirm.Visible = true
		end
	end))
	task.wait()
	v3 = connections
end

local permanentDragonRolls = game.Players.LocalPlayer:GetAttribute("PermanentDragonRolls")

if permanentDragonRolls == nil then
	return fn
elseif permanentDragonRolls == false then
	return fn
end

task.spawn(function()
	while game.Players.LocalPlayer:GetAttribute("PermanentDragonRolls") ~= false do
		task.wait()

		if classicDragon.Visible then
			continue
		end

		print("hello hell")
		fn("Permanent")
	end

	classicDragon.Visible = false
end)
return fn