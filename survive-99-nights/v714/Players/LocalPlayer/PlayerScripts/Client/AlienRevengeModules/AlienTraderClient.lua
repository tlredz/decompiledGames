local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local alienTrader = Client.Interface.AlienTrader
local v = { "Alien Armour", "Laser Cannon", "Alien Shotgun" }
local v2 = {
	["Alien Armour"] = "rbxassetid://86901492973882",
	["Laser Cannon"] = "rbxassetid://133266877364781",
	["Alien Shotgun"] = "rbxassetid://93952004196636"
}
local v3 = {
	["Alien Armour"] = "Alien Armour",
	["Laser Cannon"] = "Laser Cannon",
	["Alien Shotgun"] = "Alien Shotgun"
}
local v4 = {
	["Item A"] = "",
	["Item B"] = "",
	["Item C"] = ""
}
local v5 = nil
local v6 = false
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyPrompt()
	if not v5 then
		return
	end

	local humanoidRootPart = v5:FindFirstChild("HumanoidRootPart")
	local proximityAttachment = humanoidRootPart and humanoidRootPart:FindFirstChild("ProximityAttachment")

	if proximityAttachment then
		proximityAttachment:Destroy()
	end

	v5:RemoveTag("Interaction")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CloseMenu()
	alienTrader.Visible = false
end

local function HasClaimed()
	local v7 = v6

	if not v7 then
		if v5 == nil then
			return false
		else
			return v5:GetAttribute("AlienTraderClaimed_" .. localPlayer.UserId) == true
		end
	end

	return v7
end

local function SetUpUI()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)
	local itemsContent = alienTrader.ItemsContent

	for i = 1, #v do
		local v7 = v[i]
		local v8 = itemsContent["Pelt" .. i]
		v8.Visible = true
		v8.ItemIconFrame.ImageLabel.Image = v2[v7] or ""
		v8.ItemName.Text = v3[v7] or v7
		v8.DescriptionLabel.Text = v4[v7] or ""
		table.insert(connections, v8.SelectButton_Lower.SelectButton.MouseButton1Down:Connect(function()
			local v10 = v6

			if not v10 then
				if v5 == nil then
					v10 = false
				else
					v10 = v5:GetAttribute("AlienTraderClaimed_" .. localPlayer.UserId) == true
				end
			end

			if v10 then
				return
			end

			v6 = true
			Client.Sound.Play("KeyPress", {
				Duplicate = true
			})
			CloseMenu() -- equivalent call inferred; original call site unknown
			local v11 = v5

			if Client.Events.ClaimAlienItem:InvokeServer(v11, v7) then
				DestroyPrompt() -- equivalent call inferred; original call site unknown
				Client.PopUpUI.AddPopUp("Claimed " .. v7)
			else
				v6 = false
				CloseMenu() -- equivalent call inferred; original call site unknown
			end
		end))
	end

	for i = #v + 1, 4 do
		itemsContent["Pelt" .. i].Visible = false
	end

	local closeButton = alienTrader:FindFirstChild("CloseButton")

	if closeButton then
		table.insert(connections, closeButton.MouseButton1Down:Connect(CloseMenu))
	end

	alienTrader.Visible = true
end

local AlienTraderClient = {}

function AlienTraderClient.OpenShop(p)
	v5 = p
	local v7 = v6

	if not v7 then
		if v5 == nil then
			v7 = false
		else
			v7 = v5:GetAttribute("AlienTraderClaimed_" .. localPlayer.UserId) == true
		end
	end

	if v7 then
		return
	end

	SetUpUI()
end

function AlienTraderClient.Init() end

return AlienTraderClient