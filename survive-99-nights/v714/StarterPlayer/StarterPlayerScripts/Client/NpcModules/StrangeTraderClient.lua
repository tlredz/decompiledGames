local StrangeTraderClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local module = require("@game/ReplicatedStorage/Modules/UtilityAlec")
Random.new()
local strangeTrader = Client.Interface.StrangeTrader
local strangeTraderOdds = Client.Interface.StrangeTraderOdds
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local v = nil
local flag = false
local v2 = {
	"rbxassetid://117109949371507",
	"rbxassetid://121319695354645",
	"rbxassetid://122146297116670",
	"rbxassetid://97801863499036",
	"rbxassetid://83361019228914",
	"rbxassetid://121922943114467",
	"rbxassetid://127005408240470",
	"rbxassetid://110509228445663",
	"rbxassetid://117537144957840",
	"rbxassetid://87025637991264",
	"rbxassetid://137423029519102",
	"rbxassetid://118696280348072"
}

function DoFireCycle()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local v3 = 1

		while wait(1) do
			strangeTrader.FlameImageShadow.FlameImage.Image = v2[v3]
			local v4 = v3 + 1
			v3 = #v2 < v4 and 1 or v4
		end
	end)
end

Client.InteractionHandler.RegisterInteraction("OpenStrangeTrader", function(p)
	Client.Sound.Play("CloseButton")
	strangeTrader.Visible = not strangeTrader.Visible

	if strangeTrader.Visible then
		DoFireCycle()
		Client.Interface.DiamondCount.Visible = true
	else
		Client.Interface.DiamondCount.Visible = false
	end

	v = p

	if strangeTrader.Visible and UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
		GamepadService:EnableGamepadCursor(strangeTrader)
	end
end)
ContextActionService:BindActionAtPriority("CloseStrangeTrader", function(_, p, _)
	if not strangeTrader.Visible or p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	strangeTrader.Visible = false
	GamepadService:DisableGamepadCursor()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonB)
local v3 = true

function CheckDiamonds()
	if not v3 then
		return
	end

	v3 = false
	task.spawn(function()
		wait(0.2)
		v3 = true
	end)
	Client.Sound.Play("KeyPress")

	if (localPlayer:GetAttribute("Diamonds") or 0) >= 10 then
		Client.Sound.Play("BuyItem")
		Client.Events.RequestPurchaseFireOffering:FireServer(v, "1_Gems")
	else
		Client.PopUpUI.AddPopUp("not enough diamonds", "warning")
	end
end

local v4 = nil

function SelectOdds(data)
	local frame = strangeTraderOdds.InspectOdds.Frame

	if v4 then
		v4.SelectedCornerDetails.Visible = false
	end

	if v4 == data then
		v4 = nil
		frame.Visible = false
	else
		v4 = data
		data.SelectedCornerDetails.Visible = true
		local inspectOdds = strangeTraderOdds.InspectOdds
		local absolutePosition = inspectOdds.AbsolutePosition
		local absoluteSize = inspectOdds.AbsoluteSize
		local absolutePosition2 = data.AbsolutePosition
		local absoluteSize2 = data.AbsoluteSize
		local v5 = (absolutePosition2.X + absoluteSize2.X / 2 - absolutePosition.X) / absoluteSize.X
		local v6 = (absolutePosition2.Y + absoluteSize2.Y / 2 - absolutePosition.Y) / absoluteSize.Y
		frame.Position = UDim2.fromScale(v5, v6)
		frame.TitleLabel.Text = data.TitleLabel.Text
		frame.DescLabel.Text = Client.SpecialFireClient.GetDescription(data.Name)
		frame.Visible = true
	end
end

local v5 = {
	"Blue Fire",
	"Halloween Carnival Flame",
	"Frog Flame",
	"Meteor Flame",
	"Alien Flame",
	"Chest Luck Flame"
}

function GenerateOddsButtons()
	local scrollingFrame = strangeTraderOdds.InspectOdds.Container.ScrollingFrame
	local count = 0
	local clones = {}

	for k, fireUpgrade in pairs(Client.Databases.RewardsDatabase.FireUpgrades) do
		if table.find(v5, k) then
			continue
		end

		count += 1
		local clone = scrollingFrame.Template:Clone()
		clone.Name = k

		if fireUpgrade.Image then
			clone.ItemIconFrame.ImageLabel.Image = fireUpgrade.Image
		else
			clone.ItemIconFrame.ImageLabel.Image = "rbxassetid://88700655810389"
			clone.ItemIconFrame.ImageLabel.ImageColor3 = fireUpgrade.Colour or Color3.fromRGB(255, 115, 0)
		end

		clone.Visible = true
		local text = string.gsub(k, "[Ff][Ll][Aa][Mm][Ee]", "Offering")
		clone.TitleLabel.Text = text
		clone.Activated:Connect(function()
			Client.Sound.Play("KeyPress")
			SelectOdds(clone)
		end)
		clone.Parent = scrollingFrame
		table.insert(clones, clone)
	end

	for _, v6 in pairs(clones) do
		v6.OddsLabel.Text = math.floor(100 / count * 10 + 0.5) / 10 .. "%"
	end

	strangeTrader.Description.Text = `{math.floor(100 / count * 10 + 0.5) / 10}% odds for any random offering (campfire upgrade)`
end

local v6 = true

function ConnectButtons()
	strangeTrader.Buttons.OneButton.Activated:Connect(function()
		CheckDiamonds()
	end)
	strangeTrader.Buttons.ThreeButton.Activated:Connect(function()
		if not v6 then
			return
		end

		v6 = false
		Client.Events.RequestPurchaseFireOffering:FireServer(v, "3_DevProduct")
		task.spawn(function()
			wait(1.5)
			v6 = true
		end)
	end)
	strangeTrader.CloseButton.Activated:Connect(function()
		strangeTrader.Visible = false
		Client.Sound.Play("CloseButton")
		Client.Interface.DiamondCount.Visible = false
	end)
	strangeTrader.OddsButton.Activated:Connect(function()
		Client.Interface.StrangeTraderOdds.Visible = not Client.Interface.StrangeTraderOdds.Visible
		Client.Sound.Play("CloseButton")
	end)
	strangeTraderOdds.InspectOdds.CloseButton.Activated:Connect(function()
		strangeTraderOdds.Visible = false
		Client.Sound.Play("CloseButton")
	end)
	strangeTrader.Buttons.OneButton.Amount.Text = 10
end

Client.Events.RequestPurchase3Offerings:Connect(function()
	Client.Sound.Play("OfferingsRobux")
	strangeTrader.Visible = false
	strangeTraderOdds.Visible = false
end)

function StrangeTraderClient.Init()
	ConnectButtons()
	GenerateOddsButtons()
	task.spawn(function()
		module.preload(v2)
	end)
end

return StrangeTraderClient