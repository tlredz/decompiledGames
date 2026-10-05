local SpecialFireClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()
local mainFire = nil
local clones = {}
local count = 0

function RemoveFireCard(instance)
	local index = table.find(clones, instance)

	if index then
		table.remove(clones, index)
	end

	instance:Destroy()
	local fireUpgrade = #clones == 0 and mainFire and mainFire.PrimaryPart:FindFirstChild("FireUpgrade")

	if fireUpgrade then
		fireUpgrade.Enabled = false
	end
end

function SpecialFireClient.StartRemovingBbg() end

function SpecialFireClient.GetDescription(p)
	local fireUpgrade = Client.Databases.RewardsDatabase.FireUpgrades[p]

	if not fireUpgrade then
		return ""
	end

	local realDayCounter = workspace:GetAttribute("RealDayCounter") or 0
	local description = fireUpgrade.Description

	if realDayCounter >= 3 then
		description = description:gsub("day 3", "the next day")
	end

	if realDayCounter > 3 or realDayCounter == 3 and workspace:GetAttribute("State") == "Night" then
		description = description:gsub("night 3", "the next night")
	end

	return description
end

Client.Events.AddFireBillboardGui:Connect(function(value, p)
	Client.Interface.FireEquip.Visible = false
	local fireUpgrade = Client.Databases.RewardsDatabase.FireUpgrades[value]

	if not (fireUpgrade and mainFire) then
		return
	end

	local fireUpgrade2 = mainFire.PrimaryPart:WaitForChild("FireUpgrade")
	local container = fireUpgrade2:WaitForChild("Container")
	local entryTemplate = fireUpgrade2:WaitForChild("EntryTemplate")

	for _, v in pairs(clones) do
		v.GroupTransparency = 0.5
	end

	while #clones >= 6 do
		RemoveFireCard(clones[1])
	end

	local clone = entryTemplate:Clone()

	if fireUpgrade.Image then
		clone.ImageLabel.Image = fireUpgrade.Image
	else
		clone.ImageLabel.Image = "rbxassetid://88700655810389"
		clone.ImageLabel.ImageColor3 = fireUpgrade.Colour or Color3.fromRGB(255, 115, 0)
	end

	clone.TitleText.TextColor3 = fireUpgrade.Colour
	local v = string.gsub(value, "[Ff][Ll][Aa][Mm][Ee]", "Offering")
	clone.TitleText.Text = v .. " - " .. p.DisplayName
	clone.DescriptionText.Text = SpecialFireClient.GetDescription(value)
	clone.GroupTransparency = 0
	count += 1
	clone.LayoutOrder = count
	clone.Visible = true
	clone.Parent = container
	table.insert(clones, clone)
	fireUpgrade2.Enabled = true
	Client.Sound.Play("FireUpgrade", {
		Duplicate = true
	})
	task.delay(40, function()
		if clone.Parent then
			RemoveFireCard(clone)
		end
	end)
end)
Client.Events.ClearFireNotif:Connect(function()
	Client.Interface.FireEquip.Visible = false
end)

function UseButtonClicked()
	Client.Events.UseEquippedFire:FireServer()
	Client.Interface.FireEquip.Visible = false
end

function SpecialFireClient.Init()
	task.spawn(function()
		mainFire = workspace:WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire")
		local fireEquip = Client.Interface.FireEquip
		fireEquip.UseButton.MouseButton1Down:Connect(function()
			UseButtonClicked()
			Client.Sound.Play("CloseButton")
		end)
		fireEquip.CloseButton.MouseButton1Down:Connect(function()
			fireEquip.Visible = false
			Client.Sound.Play("CloseButton")
		end)
	end)
end

return SpecialFireClient