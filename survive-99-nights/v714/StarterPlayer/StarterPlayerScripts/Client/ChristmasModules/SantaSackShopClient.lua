local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
game:GetService("CollectionService")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local santaSack = Client.Interface.SantaSack
local v = {
	["Ice Skates"] = "IceSkates"
}
local SantaSackShopClient = {
	OpenShop = function()
		santaSack.Visible = true
		Client.Sound.Play("ChristmasHit2")
	end
}

function BuyItem(instance)
	local coins = localPlayer:GetAttribute("Coins") or 0
	local name = instance.Name

	if not instance:FindFirstChild("BuyButton") then
		return
	end

	local text = tonumber(instance.BuyButton.PriceLabel.Text)

	if coins < text then
		Client.PopUpUI.AddPopUp("not enough coins", "warning")
		return
	end

	Client.Events.RequestBuySantaSack:FireServer(name)
	Client.Sound.Play("ChristmasHit1", {
		Duplicate = true
	})
	Client.PopUpUI.AddPopUp("purchased " .. instance.Name)
	instance.BuyButton.ImageColor3 = Color3.fromRGB(255, 255, 255)

	if coins - text < text then
		TweenService:Create(instance.BuyButton, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ImageColor3 = Color3.fromRGB(145, 145, 145)
		}):Play()
	else
		TweenService:Create(instance.BuyButton, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ImageColor3 = Color3.fromRGB(255, 191, 0)
		}):Play()
	end
end

function InitializeButtons()
	santaSack.CloseButton.Activated:Connect(function()
		santaSack.Visible = false
		Client.Sound.Play("CloseButton")
	end)

	for _, button in pairs(santaSack.ButtonHolder:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		if localPlayer:GetAttribute("Class") == "Santa's Helper" then
			local _ = (localPlayer:GetAttribute("ClassLevel") or 1) >= 2
		end

		local v2 = button
		button.BuyButton.Activated:Connect(function()
			BuyItem(v2)
		end)
		local v3 = button
		button.Activated:Connect(function()
			BuyItem(v3)
		end)
	end
end

function UpdateBuyButtons()
	local coins = localPlayer:GetAttribute("Coins") or 0

	for _, button in pairs(santaSack.ButtonHolder:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local name = button.Name
		local attribute = ReplicatedStorage.Shops.SantaSack:GetAttribute(v[name] or name)

		if localPlayer:GetAttribute("Class") == "Santa's Helper" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 2 then
			local v2 = v[name] or name
			local v3 = v2 .. "Sale"
			attribute = ReplicatedStorage.Shops.SantaSack:GetAttribute(v3)
			ReplicatedStorage.Shops.SantaSack:SetAttribute(v2, attribute)
		end

		local text = attribute or 20
		button.BuyButton.PriceLabel.Text = text

		if text < coins then
			button.BuyButton.ImageColor3 = Color3.fromRGB(255, 191, 0)
		else
			button.BuyButton.ImageColor3 = Color3.fromRGB(145, 145, 145)
		end
	end
end

function SantaSackShopClient.Init()
	InitializeButtons()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setCoins(coins)
		santaSack.Frame.CoinAmount.PriceLabel.Text = coins or 0
		UpdateBuyButtons()
	end

	local coins = localPlayer:GetAttribute("Coins") or 0
	setCoins(coins) -- equivalent call inferred; original call site unknown
	localPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
		local coins2 = localPlayer:GetAttribute("Coins") or 0
		setCoins(coins2) -- equivalent call inferred; original call site unknown
	end)
end

return SantaSackShopClient