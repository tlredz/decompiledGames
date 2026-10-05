local ToolTraderClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()
local toolSmith = Client.Interface.ToolSmith
local coinAmount = Client.Interface.CoinAmount
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
Client.InteractionHandler.RegisterInteraction("OpenToolTrader", function(_)
	print("view tool trader")
	Client.CompassClient.ShopFound("ToolSmith")
	Client.Sound.Play("CloseButton")
	toolSmith.Visible = not toolSmith.Visible

	if toolSmith.Visible and UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
		GamepadService:EnableGamepadCursor(toolSmith)
	end
end)
local v = {}

function SetupCoinInterface()
	toolSmith:GetPropertyChangedSignal("Visible"):Connect(function()
		coinAmount.TextLabel.Text = localPlayer:GetAttribute("Coins") or 0
		coinAmount.Visible = toolSmith.Visible
	end)
	coinAmount:GetPropertyChangedSignal("Visible"):Connect(function()
		if toolSmith.Visible and not coinAmount.Visible then
			coinAmount.Visible = true
		end
	end)
end

local flag = true
ContextActionService:BindActionAtPriority("CloseToolTrader", function(_, p, _)
	if not toolSmith.Visible or p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	toolSmith.Visible = false
	GamepadService:DisableGamepadCursor()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonB)

function DoErrorMessage(p, p2)
	if flag then
		Client.PopUpUI.AddPopUp(p2, "warning")
		flag = false
		task.spawn(function()
			for _ = 1, 3 do
				p.TextColor3 = Color3.fromRGB(255, 0, 0)
				wait(0.3)
				p.TextColor3 = Color3.fromRGB(255, 255, 255)
				wait(0.3)
			end

			p.TextColor3 = Color3.fromRGB(255, 0, 0)
		end)
		task.spawn(function()
			wait(2.1)
			p.TextColor3 = Color3.fromRGB(255, 255, 255)
			flag = true
		end)
	end
end

function AttemptPurchase(p, p2)
	if Client.PingClient.PingActive then
		return
	end

	if v[p] then
		Client.PopUpUI.AddPopUp("you already bought this", "warning")
	end

	if not (localPlayer:GetAttribute("Coins") >= 20) then
		DoErrorMessage(toolSmith.Materials.Frame.CoinAmount, "not enough coins")
		return
	end

	Client.Sound.Play("BuyItem")
	localPlayer:SetAttribute("Coins", localPlayer:GetAttribute("Coins") - 20)
	Client.Events.RequestPurchaseTool:FireServer(p)
	v[p] = true
	p2.CraftButton.Visible = false
	p2.PurchasedLabel.Visible = true
end

Client.Events.RejectToolSmith:Connect(function(childName)
	v[childName] = false
	local child = toolSmith.ItemList:FindFirstChild(childName)

	if child then
		child.CraftButton.Visible = true
		child.PurchasedLabel.Visible = false
	end
end)
local bandageCount = 0
local hammerPurchased = false
local v2 = {}
local v3 = {
	Hammer = true,
	Bandage = true
}

function GetBandagePrice()
	return bandageCount * 25 + 25
end

function SetExtraCraftPrice(p, p2)
	p.CraftButton.TextLabel.Text = tostring(p2) .. " Coins"
end

function AttemptPurchaseExtra(p, p2, p3)
	if Client.PingClient.PingActive then
		return
	end

	if localPlayer:GetAttribute("Coins") < p3 then
		DoErrorMessage(toolSmith.Materials.Frame.CoinAmount, "not enough coins")
		return
	end

	Client.Sound.Play("BuyItem")
	localPlayer:SetAttribute("Coins", localPlayer:GetAttribute("Coins") - p3)
	v2[p] = p3
	p2.CraftButton.Visible = false
	p2.PurchasedLabel.Visible = true
	Client.Events.RequestPurchaseExtra:FireServer(p)
end

Client.Events.RejectExtra:Connect(function(childName)
	local child = toolSmith.ExtrasFrame:FindFirstChild(childName)

	if not child then
		return
	end

	if v2[childName] then
		localPlayer:SetAttribute("Coins", localPlayer:GetAttribute("Coins") + v2[childName])
		v2[childName] = nil
	end

	child.CraftButton.Visible = true
	child.PurchasedLabel.Visible = false
end)
Client.Events.ApproveExtra:Connect(function(p)
	v2[p] = nil
end)
Client.Events.BandagePurchased:Connect(function(p, p2)
	bandageCount = p2
	local bandage = toolSmith.ExtrasFrame.Bandage

	if p == localPlayer then
		v2.Bandage = nil
		task.spawn(function()
			wait(1)

			if bandageCount >= 5 then
				bandage.CraftButton.Visible = false
				bandage.PurchasedLabel.Visible = true
			else
				SetExtraCraftPrice(bandage, GetBandagePrice())
				bandage.PurchasedLabel.Visible = false
				bandage.CraftButton.Visible = true
			end
		end)
	elseif bandageCount >= 5 then
		bandage.CraftButton.Visible = false
		bandage.PurchasedLabel.Visible = true
	else
		SetExtraCraftPrice(bandage, GetBandagePrice())
	end
end)

function SetupExtras()
	local hammer = toolSmith.ExtrasFrame.Hammer
	local bandage = toolSmith.ExtrasFrame.Bandage
	SetExtraCraftPrice(hammer, 25)
	SetExtraCraftPrice(bandage, GetBandagePrice())
	hammer.CraftButton.Activated:Connect(function()
		if not v3.Hammer then
			return
		end

		v3.Hammer = false
		AttemptPurchaseExtra("Hammer", hammer, 25)
		task.spawn(function()
			wait(1)
			v3.Hammer = true
		end)
	end)
	bandage.CraftButton.Activated:Connect(function()
		if not v3.Bandage then
			return
		end

		v3.Bandage = false
		AttemptPurchaseExtra("Bandage", bandage, GetBandagePrice())
		task.spawn(function()
			wait(1)
			v3.Bandage = true
		end)
	end)
	task.spawn(function()
		local v4 = Client.Events.GetExtraState:InvokeServer()

		if not v4 then
			return
		end

		bandageCount = v4.BandageCount or 0
		hammerPurchased = v4.HammerPurchased or false
		SetExtraCraftPrice(bandage, GetBandagePrice())

		if bandageCount >= 5 then
			bandage.CraftButton.Visible = false
			bandage.PurchasedLabel.Visible = true
		end

		if hammerPurchased then
			hammer.CraftButton.Visible = false
			hammer.PurchasedLabel.Visible = true
		end
	end)
end

function SetupButtons()
	local v4 = true
	local v5 = true
	toolSmith.CloseButton.Activated:Connect(function()
		Client.Sound.Play("CloseButton")
		toolSmith.Visible = false
	end)
	local itemList = toolSmith.ItemList
	itemList["Old Rod"].CraftButton.Activated:Connect(function()
		if not v4 then
			return
		end

		v4 = false
		AttemptPurchase("Old Rod", itemList["Old Rod"])
		task.spawn(function()
			wait(1)
			v4 = true
		end)
	end)
	itemList["Old Taming Flute"].CraftButton.Activated:Connect(function()
		if not v5 then
			return
		end

		v5 = false
		AttemptPurchase("Old Taming Flute", itemList["Old Taming Flute"])
		task.spawn(function()
			wait(1)
			v5 = true
		end)
	end)
end

function ToolTraderClient.Init()
	task.spawn(function()
		SetupCoinInterface()
		SetupButtons()
		SetupExtras()
	end)
	task.spawn(function()
		localPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
			toolSmith.Materials.Frame.CoinAmount.Text = localPlayer:GetAttribute("Coins") or 0
		end)
		toolSmith.Materials.Frame.CoinAmount.Text = localPlayer:GetAttribute("Coins") or "0"
	end)
end

return ToolTraderClient