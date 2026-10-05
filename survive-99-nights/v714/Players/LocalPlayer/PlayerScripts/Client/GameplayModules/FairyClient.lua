local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local FairyClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local flower = Client.Interface.Flower
local flower2 = nil
local v = {
	Chillis = "CHILLI",
	Strawberries = "STRAWBERRY",
	Fireflies = "FIREFLY",
	Flowers = "FLOWER",
	["Brightwood Trees"] = "TREES"
}
local v2 = {
	Chillis = "chillies grant a temporary speed boost",
	Strawberries = "berries restore hunger",
	Fireflies = "fireflies restore flashlight battery",
	Roses = "roses mark the location of some traps in the forest",
	["Brightwood Trees"] = "a better type of tree that is easier to chop down"
}
local clonesByInstance = {}
local clonesByInstance2 = {}
Random.new()
FairyClient.AlreadyFound = false
local v3 = nil

function FairyClient.GetFairy()
	if v3 then
		return v3
	end

	local tagged = CollectionService:GetTagged("FairyNPC")

	for _, v4 in pairs(tagged) do
		if v4:IsDescendantOf(workspace) then
			v3 = v4
		end
	end

	return v3
end

function FairyClient.ToggleShop(_)
	if not FairyClient.AlreadyFound then
		FairyClient.AlreadyFound = true
		Client.CompassClient.ShopFound("Fairy")
	end

	if flower2.Visible then
		flower2.Visible = false
	else
		flower2.Visible = true
	end
end

local flag = true

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

function AttemptPurchase(instance)
	if Client.PingClient.PingActive then
		return
	end

	if (instance:GetAttribute("Price") or 10) > Client.FlowerAndCoinsClient.FlowerAmount then
		DoErrorMessage(flower.FlowerAmount, "not enough flowers!")
		return
	end

	if instance:GetAttribute("Purchased") then
		return
	end

	Client.Sound.Play("BuyItem", {
		Duplicate = true
	})
	local v4 = Client.Events.BuyBox:InvokeServer(instance)
	flower2.Visible = false

	if not (v4 and v4.Success) then
		task.spawn(function()
			wait(0.5)
			instance:SetAttribute("Purchased", false)
		end)
	end
end

local v4 = nil

function RenderButton(instance)
	local price = instance:GetAttribute("Price") or 10
	local v5 = v[instance.Name] or instance.Name
	local description = instance:GetAttribute("Description") or v2[instance.Name] or "Find this anywhere on the map"
	local isHalloween = instance:GetAttribute("IsHalloween") or false
	local slot = instance:GetAttribute("Slot") or 1
	local clone = clonesByInstance[instance]

	if not clone then
		instance:SetAttribute("Purchased", false)
		clone = flower.BlueprintHolder.Template:Clone()
		clonesByInstance[instance] = clone
		clone.Parent = flower.BlueprintHolder
		clone.CraftButton.Activated:Connect(function()
			AttemptPurchase(instance)
		end)
	end

	clone.Name = instance.Name
	clone.ItemName.Text = string.upper(v5)
	clone.ItemDescription.Text = description
	clone.PriceFrame.FlowerFrame.FlowerAmount.Text = price

	if Client.Databases.FairyPlants[instance.Name] then
		clone.ImageLabel.Image = Client.Databases.FairyPlants[instance.Name].boxImage or Client.Databases.FairyPlants.Berries.boxImage
	else
		clone.ImageLabel.Image = ""
	end

	clone.LayoutOrder = slot
	clone.Bats.Visible = isHalloween

	if isHalloween then
		clone.Frame.BackgroundColor3 = Color3.fromRGB(255, 123, 7)
		clone.BackgroundColor3 = Color3.fromRGB(38, 34, 34)
		clone.ItemDescription.TextColor3 = Color3.fromRGB(238, 238, 238)
	else
		clone.Frame.BackgroundColor3 = Color3.fromRGB(161, 161, 161)
		clone.BackgroundColor3 = Color3.fromRGB(208, 208, 208)
		clone.ItemDescription.TextColor3 = Color3.fromRGB(84, 84, 84)
	end

	if instance:GetAttribute("Purchased") then
		if not v4 then
			v4 = instance
			local oR = clone.Parent:FindFirstChild("OR")
			oR.Visible = false

			for _, v6 in pairs(clonesByInstance) do
				v6.Visible = false
			end
		end

		clone.Visible = false

		if not clonesByInstance2[instance] then
			clonesByInstance2[instance] = flower.BlueprintHolder.TempFrame:Clone()
			local v6 = clonesByInstance2[instance]
			v6.LayoutOrder = clone.LayoutOrder
			v6.Parent = clone.Parent
		end

		clonesByInstance2[instance].Visible = true
	elseif not v4 or v4 == instance then
		if v4 and v4 == instance then
			for _, v6 in pairs(clonesByInstance) do
				v6.Visible = true
			end

			local oR_2 = clone.Parent:FindFirstChild("OR")
			oR_2.Visible = true
			v4 = nil
		end

		if clonesByInstance2[instance] then
			clonesByInstance2[instance].Visible = false
		end

		clone.Visible = true
	end
end

function SetupShopFolders()
	local fairy = ReplicatedStorage.Shops.Fairy

	for _, folder in pairs(fairy:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		RenderButton(folder)
		local v5 = folder
		folder.AttributeChanged:Connect(function(p)
			RenderButton(v5)
		end)
	end

	fairy.ChildAdded:Connect(function(folder)
		if not folder:IsA("Folder") then
			return
		end

		RenderButton(folder)
		folder.AttributeChanged:Connect(function(_)
			RenderButton(folder)
		end)
	end)
	fairy.ChildRemoved:Connect(function(child)
		if clonesByInstance2[child] then
			clonesByInstance2[child]:Destroy()
		end

		if clonesByInstance[child] then
			clonesByInstance[child]:Destroy()
		end
	end)
end

function FairyClient.Init()
	task.spawn(function()
		flower2 = Client.Interface.Flower
		flower2.CloseButton.MouseButton1Down:Connect(function()
			Client.Sound.Play("CloseButton")
			flower2.Visible = false
		end)
		SetupShopFolders()
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://138827584957195"
		local animation2 = Instance.new("Animation")
		animation2.AnimationId = "rbxassetid://86126823872918"
		local animation3 = Instance.new("Animation")
		animation3.AnimationId = "rbxassetid://82965505988437"
		UtilityAlec.preload({ animation, animation2, animation3 })
	end)
end

return FairyClient