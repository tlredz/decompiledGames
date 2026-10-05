local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local peltTrader = Client.Interface.PeltTrader
local v = nil
local v2 = {
	Spear = "rbxassetid://127047861000561",
	["Good Sack"] = "rbxassetid://83708762101645",
	["Giant Sack"] = "rbxassetid://102273840222335",
	["Old Flashlight"] = "rbxassetid://79129184361840",
	["Good Axe"] = "rbxassetid://117925380063610",
	["Strong Axe"] = "rbxassetid://92360193951402",
	Rifle = "rbxassetid://97407984311273",
	MedKit = "rbxassetid://132118624530569",
	["Strong Flashlight"] = "rbxassetid://129922478165831",
	["Iron Body"] = "rbxassetid://115430545971918",
	["Leather Body"] = "rbxassetid://92676976356069",
	Revolver = "rbxassetid://89120083538699",
	["Rifle Ammo"] = "rbxassetid://72492670646523",
	["Revolver Ammo"] = "rbxassetid://102249139930370",
	["Old Rod"] = "rbxassetid://111464687054036",
	["Old Taming Flute"] = "rbxassetid://135492355443512",
	["Pelt Trader Egg"] = "rbxassetid://83012657610225"
}
local v3 = {
	["Bunny Foot"] = "rbxassetid://117362208530862",
	["Wolf Pelt"] = "rbxassetid://89903166344518",
	["Alpha Wolf Pelt"] = "rbxassetid://106205251189894",
	["Bear Pelt"] = "rbxassetid://131709597137934"
}
local v4 = {
	Good = Color3.fromRGB(70, 136, 55),
	Strong = Color3.fromRGB(170, 39, 39),
	Giant = Color3.fromRGB(58, 134, 200),
	Iron = Color3.fromRGB(154, 154, 154)
}

local function ColourToHex(data)
	return string.format(
		"#%02X%02X%02X",
		math.round(data.R * 255),
		math.round(data.G * 255),
		(math.round(data.B * 255))
	)
end

function FormatItemName(value)
	return (value:gsub("%S+", function(p)
		local v5 = v4[p]

		if v5 then
			return string.format(
				"<font color=\"%s\">%s</font>",
				string.format("#%02X%02X%02X", math.round(v5.R * 255), math.round(v5.G * 255), (math.round(v5.B * 255))),
				p
			)
		end

		return p
	end))
end

local v5 = {
	Spear = "",
	["Good Sack"] = "",
	["Giant Sack"] = "",
	["Old Flashlight"] = "",
	["Good Axe"] = "",
	["Strong Axe"] = "",
	Rifle = "",
	MedKit = "",
	["Strong Flashlight"] = "",
	["Iron Body"] = "",
	["Leather Body"] = "",
	Revolver = "",
	["Rifle Ammo"] = "",
	["Revolver Ammo"] = "",
	["Old Rod"] = "",
	["Old Taming Flute"] = "",
	["Pelt Trader Egg"] = ""
}
local v6 = nil
local v7 = {}

function makeBbg(instance)
	local attribute = instance:GetAttribute("ItemRequested_" .. localPlayer.UserId)
	local thoughtBubble = instance.HumanoidRootPart.ThoughtBubble

	if not attribute then
		return
	end

	if instance:FindFirstChild("DashedLine") then
		instance.DashedLine.SurfaceGui.Enabled = true
	end

	thoughtBubble.ImageLabel.ImageLabel.Image = v3[attribute]
	thoughtBubble.ImageLabel.TextLabel.Text = attribute
	thoughtBubble.Enabled = true
	v7[instance] = false
	v = thoughtBubble
end

function PeltTraderAdded(instance)
	local touchZone = instance:WaitForChild("TouchZone")
	task.delay(2, function()
		makeBbg(instance)
	end)
	v6 = instance
	v7[instance] = false
	touchZone.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if parent and parent.Parent == workspace.Items and not v7[instance] and (instance:GetAttribute("ItemRequested_" .. localPlayer.UserId) == parent.Name or parent:GetAttribute("PeltTraderRewards")) and (parent:GetAttribute("Owner") or parent:GetAttribute("LastOwner")) == localPlayer.UserId then
			v7[instance] = true
			local parent2 = parent.Parent
			parent.Parent = game.ReplicatedStorage.TempStorage

			if v then
				v.Enabled = false
			end

			if instance:FindFirstChild("DashedLine") then
				instance.DashedLine.SurfaceGui.Enabled = false
			end

			local v8 = Client.Events.RequestGiveItemToNPC:InvokeServer(instance, parent)

			if not (v8 and v8.Success) then
				parent.Parent = parent2
			end
		end
	end)
end

Client.Utility.ForAllTagged("PeltTrader", PeltTraderAdded)
local connections = {}
local count = 0

function SetUpUI(list)
	if not v6 then
		return
	end

	local itemsContent = peltTrader.ItemsContent
	local v8 = false

	for i = 1, #list do
		local text = list[i]
		local v10 = itemsContent["Pelt" .. i]
		v10.Visible = true
		v10.ItemIconFrame.ImageLabel.Image = v2[text] or "rbxassetid://117925380063610"
		v10.ItemName.Text = text
		v10.DescriptionLabel.Text = v5[text] or ""
		table.insert(connections, v10.SelectButton_Lower.SelectButton.MouseButton1Down:Connect(function()
			if not v8 then
				v8 = true
				Client.Sound.Play("KeyPress", {
					Duplicate = true
				})
				task.spawn(function()
					wait(1)
					Client.PopUpUI.AddPopUp("received " .. text)
				end)
				Client.Events.ClaimPeltItem:FireServer(v6, text)
				peltTrader.Visible = false
			end
		end))
	end

	if #list < 4 then
		for i = #list + 1, 4 do
			itemsContent["Pelt" .. i].Visible = false
		end
	end

	peltTrader.Visible = true
	count += 1
	local v9 = count
	task.spawn(function()
		wait(35)

		if v9 == count then
			peltTrader.Visible = false
		end
	end)
end

Client.Events.PeltTraderUI:Connect(function(p, p2)
	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	if p then
		SetUpUI(p2)
	else
		peltTrader.Visible = false
	end
end)
Client.Events.PeltTraderRefresh:Connect(function()
	if v6 then
		task.spawn(function()
			wait(2)
			makeBbg(v6)
		end)
	end
end)
return {}