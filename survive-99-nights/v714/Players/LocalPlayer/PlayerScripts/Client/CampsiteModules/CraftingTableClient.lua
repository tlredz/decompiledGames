local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local ContentProvider = game:GetService("ContentProvider")
local localPlayer = game.Players.LocalPlayer
local _ = localPlayer.PlayerGui
local Client = require(localPlayer.PlayerScripts.Client)
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local CraftingDatabase = require(ReplicatedStorage.Databases.CraftingDatabase)
local StarterGui = game:GetService("StarterGui")
local craftingTable = nil
local v = nil
local craftingTable2 = Client.Interface.CraftingTable
local scrollingFrame = craftingTable2.ScrollingFrame
local uIListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
local previewFrame = craftingTable2.PreviewFrame
local scale = scrollingFrame.CanvasSize.Y.Scale
local v2 = nil
local campground = nil
local CraftingTableClient = {
	CraftingTableLevel = 1
}

function CloseCraftingBench()
	Client.Sound.Play("CloseButton")
	craftingTable2.Visible = false
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
end

craftingTable2.CloseButton.MouseButton1Click:Connect(function()
	CloseCraftingBench()
end)

function CraftingTableClient.OpenCraftingBench()
	craftingTable2.Visible = true
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

	if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
		GamepadService:EnableGamepadCursor(craftingTable2)
	end
end

ContextActionService:BindActionAtPriority("CloseCraftingTable", function(_, p, _)
	if not craftingTable2.Visible or p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	CloseCraftingBench()
	GamepadService:DisableGamepadCursor()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonB)
Client.Events.CloseBlueprintMenu:Connect(function()
	craftingTable2.Visible = false
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
end)
local v3 = true
Client.Events.BlacksmithExtraScrap:Connect(function(p)
	if not (v3 and campground:FindFirstChild("Scrapper")) then
		return
	end

	if p ~= localPlayer then
		v3 = false
	end

	task.spawn(function()
		wait(2)
		v3 = true
	end)
	campground.Scrapper.DashedLine.StartAttachment.Sparks:Emit(9)
	campground.Scrapper.DashedLine.StartAttachment.HammerComplete:Play()
end)
Client.Events.EngineerParticles:Connect(function(_)
	local pivot = campground.Scrapper.DashedLine:GetPivot()
	Client.Utility.SpawnParticles("EngineerGrindEffect", pivot)
	campground.Scrapper.DashedLine.StartAttachment.HammerComplete:Play()
end)
local v4 = false

function IsBlacksmithClass()
	if localPlayer:GetAttribute("Class") ~= "Blacksmith" and not Client.Utility.HasTalent(localPlayer, "CraftingSale") or v4 then
		return localPlayer:GetAttribute("Class") == "Blacksmith"
	end

	v4 = true

	if localPlayer:GetAttribute("ClassLevel") >= 2 or Client.Utility.HasTalent(localPlayer, "CraftingSale") then
		for _, child in pairs(craftingTable:GetChildren()) do
			if child:GetAttribute("SaleScrapPrice") then
				child:SetAttribute("ScrapPrice", child:GetAttribute("SaleScrapPrice"))
			end

			if child:GetAttribute("SaleWoodPrice") then
				child:SetAttribute("WoodPrice", child:GetAttribute("SaleWoodPrice"))
			end
		end
	end

	return localPlayer:GetAttribute("Class") == "Blacksmith"
end

local v5 = { "rbxassetid://140146629194138", "rbxassetid://120793301339342", "rbxassetid://89862238279115" }
local v6 = {}
local clonesByName = {}

function GetEntryFromName(childName)
	local child = craftingTable:FindFirstChild(childName)

	if child then
		return child
	end
end

function GetButtonFromName(p)
	if clonesByName[p] then
		return clonesByName[p]
	end
end

function CreatePreview(text, _)
	local v7 = GetEntryFromName(text)
	local tier = v7:GetAttribute("Tier")

	if not v7 then
		previewFrame.Visible = false
		return
	end

	local scrapPrice = v7:GetAttribute("ScrapPrice")
	local woodPrice = v7:GetAttribute("WoodPrice")
	local gemPrice = v7:GetAttribute("GemPrice")
	local greenGemPrice = v7:GetAttribute("GreenGemPrice")
	v7:GetAttribute("Limited")
	v7:GetAttribute("Toys")
	local _ = v7:GetAttribute("EventSkin") and localPlayer:GetAttribute("EventSkins")
	previewFrame.PreviewLabel.Image = v7:GetAttribute("BiggerImage") or v7:GetAttribute("Image") or v5[tier]

	if table.find(CraftingDatabase.AllowDuplicates, text) then
		local limit = v7:GetAttribute("Limit")

		if limit then
			previewFrame.PreviewLabel.Infinity.LimitCountFrame.Visible = true
			previewFrame.PreviewLabel.Infinity.LimitCountFrame.TextLabel.Text = "x" .. limit

			if limit == 0 then
				previewFrame.PreviewLabel.Infinity.Visible = false
			end
		else
			previewFrame.PreviewLabel.Infinity.LimitCountFrame.Visible = false
		end

		previewFrame.PreviewLabel.Infinity.Visible = true
	else
		previewFrame.PreviewLabel.Infinity.Visible = false
	end

	previewFrame.TitleFrame.TextLabel.Text = text
	previewFrame.DescriptionLabel.Text = v7:GetAttribute("Description")

	if scrapPrice then
		previewFrame.Price.ScrapFrame.ScrapAmount.Text = scrapPrice
		previewFrame.Price.ScrapFrame.Visible = true
	else
		previewFrame.Price.ScrapFrame.Visible = false
	end

	if woodPrice then
		previewFrame.Price.WoodFrame.WoodAmount.Text = woodPrice
		previewFrame.Price.WoodFrame.Visible = true
	else
		previewFrame.Price.WoodFrame.Visible = false
	end

	if gemPrice then
		previewFrame.Price.GemFrame.GemAmount.Text = gemPrice
		previewFrame.Price.GemFrame.Visible = true
	else
		previewFrame.Price.GemFrame.Visible = false
	end

	if greenGemPrice then
		previewFrame.Price.GreenGemFrame.GreenGemAmount.Text = greenGemPrice
		previewFrame.Price.GreenGemFrame.Visible = true
	else
		previewFrame.Price.GreenGemFrame.Visible = false
	end

	local craftingTableTier = craftingTable:GetAttribute("CraftingTableTier")

	if IsBlacksmithClass(localPlayer) or Client.Utility.HasTalent(localPlayer, "BonusCrafting") then
		craftingTableTier += 1
	end

	if craftingTableTier < tier or craftingTableTier == 5 and craftingTable:GetAttribute("CraftingTableTier") == 4 and tier == 5 then
		previewFrame.SoldOut.Visible = false
		previewFrame.CraftButton.Visible = false
		previewFrame.Locked.Visible = true
	else
		if v7:GetAttribute("SoldOut") then
			previewFrame.SoldOut.Visible = true
			previewFrame.CraftButton.Visible = false
		else
			previewFrame.SoldOut.Visible = false
			previewFrame.CraftButton.Visible = true
		end

		previewFrame.Locked.Visible = false
	end

	previewFrame.Visible = true
end

function SelectButton(p, p2)
	if (p and v and v ~= p or v and not p) and v and v.Parent and v:FindFirstChild("UIStroke") then
		v.UIStroke.Thickness = 0.02

		if v:GetAttribute("Limited") then
			v.UIStroke.Transparency = 0.55
			v.UIStroke.Color = Color3.fromRGB(255, 38, 38)
		else
			v.UIStroke.Transparency = 0.85
			v.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		end
	end

	if p and p2 then
		v = p
		v.UIStroke.Transparency = 0
		v.UIStroke.Thickness = 0.04
		v.UIStroke.Color = Color3.fromRGB(255, 234, 0)
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

-- equivalent calls inferred from this helper; original call sites unknown
local function timesDivisibleBy3(p)
	return math.floor(p / 2) * 2 / 2
end

function CalculatePileAmounts(p, p2)
	local v7 = math.clamp(timesDivisibleBy3(p), 0, 40)
	local v8 = (p == 1 or p == 2) and 1 or p == 0 and 0 or v7
	local v9 = math.clamp(timesDivisibleBy3(p2), 0, 40)

	if p2 == 1 or p2 == 2 then
		return v8, 1
	end

	return v8, p2 == 0 and 0 or v9
end

function UpdateGemAmount(instance, p)
	local gemPile = instance:FindFirstChild("GemPile")

	if not gemPile then
		return
	end

	local v7 = math.min(10, p)
	local gems = gemPile:GetAttribute("Gems")

	if gems and gems ~= v7 then
		gemPile:SetAttribute("Gems", v7)

		for _, part in pairs(gemPile:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Transparency = 1
		end

		for i = 1, math.min(v7, 10) do
			local child = gemPile:FindFirstChild(i)

			if not child then
				continue
			end

			for _, part in pairs(child:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = true
				part.Transparency = 0
			end
		end
	end
end

function UpdateGreenGemAmount(instance, p)
	local greenGemPile = instance:FindFirstChild("GreenGemPile")

	if not greenGemPile then
		return
	end

	local v7 = math.min(6, p)
	local greenGems = greenGemPile:GetAttribute("GreenGems")

	if greenGems and greenGems ~= v7 then
		greenGemPile:SetAttribute("GreenGems", v7)

		for _, part in pairs(greenGemPile:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Transparency = 1
		end

		for i = 1, math.min(v7, 10) do
			local folder = greenGemPile:FindFirstChild(i)

			if not folder then
				continue
			end

			for _, part in pairs(folder:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = true
				part.Transparency = 0

				if part.Name == "Main" then
					part.Transparency = 0.2
				end
			end
		end
	end
end

function CreatePiles(parent, piles, piles2)
	local piles3 = parent:WaitForChild("PileMetal1"):GetAttribute("Piles")
	local piles4 = parent:WaitForChild("PileWood1"):GetAttribute("Piles")

	if piles < piles3 then
		for i = piles3, piles + 1, -1 do
			if i == 1 then
				local pileMetal1 = parent:FindFirstChild("PileMetal1")
				pileMetal1.Transparency = 1
			elseif parent:FindFirstChild("PileMetal" .. i) then
				parent:FindFirstChild("PileMetal" .. i):Destroy()
			end
		end
	elseif piles3 < piles then
		for i = piles3 + 1, piles do
			if i == 1 then
				local pileMetal1_2 = parent:FindFirstChild("PileMetal1")
				pileMetal1_2.Transparency = 0
			elseif i ~= 0 then
				local clone = parent.PileMetal1:Clone()
				clone.Parent = parent
				clone.Name = "PileMetal" .. i
				clone:PivotTo(parent:FindFirstChild("PileMetal1").CFrame * CFrame.new(0, (i - 1) * 0.38, 0))
			end
		end
	end

	if piles2 < piles4 then
		for i = piles4, piles2 + 1, -1 do
			if i == 1 then
				local pileWood1 = parent:FindFirstChild("PileWood1")
				pileWood1.Transparency = 1
			elseif parent:FindFirstChild("PileWood" .. i) then
				parent:FindFirstChild("PileWood" .. i):Destroy()
			end
		end
	elseif piles4 < piles2 then
		for i = piles4 + 1, piles2 do
			if i == 1 then
				local pileWood1_2 = parent:FindFirstChild("PileWood1")
				pileWood1_2.Transparency = 0
			elseif i ~= 0 then
				local clone = parent.PileWood1:Clone()
				clone.Parent = parent
				clone.Name = "PileWood" .. i
				clone:PivotTo(parent:FindFirstChild("PileWood1").CFrame * CFrame.new(0, (i - 1) * 0.38, 0))
			end
		end
	end

	parent.PileMetal1:SetAttribute("Piles", piles)
	parent.PileWood1:SetAttribute("Piles", piles2)
end

function UpdatePreviewPriceColor()
	local text = tonumber(previewFrame.Price.ScrapFrame.ScrapAmount.Text)
	local text2 = tonumber(previewFrame.Price.WoodFrame.WoodAmount.Text)
	local text3 = tonumber(previewFrame.Price.GemFrame.GemAmount.Text)
	local text4 = tonumber(previewFrame.Price.GreenGemFrame.GreenGemAmount.Text)

	if text and text2 and text3 and text4 then
		if text <= campground:GetAttribute("TotalScrap") then
			previewFrame.Price.ScrapFrame.ScrapAmount.TextColor3 = Color3.fromRGB(225, 225, 225)
		else
			previewFrame.Price.ScrapFrame.ScrapAmount.TextColor3 = Color3.fromRGB(255, 0, 0)
		end

		if text2 <= campground:GetAttribute("TotalWood") then
			previewFrame.Price.WoodFrame.WoodAmount.TextColor3 = Color3.fromRGB(225, 225, 225)
		else
			previewFrame.Price.WoodFrame.WoodAmount.TextColor3 = Color3.fromRGB(255, 0, 0)
		end

		if text3 <= campground:GetAttribute("TotalGems") then
			previewFrame.Price.GemFrame.GemAmount.TextColor3 = Color3.fromRGB(225, 225, 225)
		else
			previewFrame.Price.GemFrame.GemAmount.TextColor3 = Color3.fromRGB(255, 0, 0)
		end

		if text4 <= campground:GetAttribute("TotalGreenGems") then
			previewFrame.Price.GreenGemFrame.GreenGemAmount.TextColor3 = Color3.fromRGB(225, 225, 225)
		else
			previewFrame.Price.GreenGemFrame.GreenGemAmount.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
	end
end

function UpdateScrap()
	local totalScrap = campground:GetAttribute("TotalScrap") or 0
	local totalWood = campground:GetAttribute("TotalWood") or 0
	local totalGems = campground:GetAttribute("TotalGems") or 0
	local totalGreenGems = campground:GetAttribute("TotalGreenGems") or 0
	craftingTable2.Materials.ScrapAmount.Text = totalScrap
	craftingTable2.Materials.WoodAmount.Text = totalWood
	craftingTable2.Materials.GemAmount.Text = totalGems
	craftingTable2.Materials.GreenGemAmount.Text = totalGreenGems
	Client.Interface.AmmoCrate.Amount.ScrapAmount.Text = totalScrap
	local craftingBench = campground:WaitForChild("CraftingBench")
	local v7, v8 = CalculatePileAmounts(totalScrap, totalWood)

	if craftingBench:WaitForChild("ScrapSign") and craftingBench:WaitForChild("WoodSign") then
		craftingBench.ScrapSign.SurfaceGui.TextLabel.Text = totalScrap
		craftingBench.WoodSign.SurfaceGui.TextLabel.Text = "     " .. totalWood
	end

	UpdatePreviewPriceColor()

	if totalGems >= 0 then
		UpdateGemAmount(craftingBench, totalGems)
	end

	if totalGreenGems >= 0 then
		if totalGreenGems > 0 then
			craftingTable2.Materials.GreenGemAmount.Visible = true
			craftingTable2.Materials.GreenGemImage.Visible = true
		end

		UpdateGreenGemAmount(craftingBench, totalGreenGems)
	end

	CreatePiles(craftingBench, v7, v8)
end

function OnPurchaseBlueprint(p)
	GetButtonFromName(p)
	local v7 = GetEntryFromName(p)

	if not v7 or table.find(CraftingDatabase.AllowDuplicates, p) and (not table.find(
		CraftingDatabase.AllowDuplicates,
		p
	) or v7:GetAttribute("SoldOut")) then
		return
	end

	local limit = v7:GetAttribute("Limit")

	if limit then
		v7:SetAttribute("Limit", limit - 1)
	elseif not table.find(CraftingDatabase.AllowDuplicates, p) then
		v7:SetAttribute("SoldOut", true)
	end
end

Client.Events.ResetSoldOut:Connect(function(p, soldOut, limit)
	local v7 = GetEntryFromName(p)

	if not v7 then
		return
	end

	v7:SetAttribute("Limit", limit)
	v7:SetAttribute("SoldOut", soldOut)
end)

function CheckCanBuy(p)
	local v7 = GetEntryFromName(p)

	if not v7 then
		return
	end

	local totalWood = campground:GetAttribute("TotalWood")
	local totalScrap = campground:GetAttribute("TotalScrap")
	local totalGems = campground:GetAttribute("TotalGems")
	local totalGreenGems = campground:GetAttribute("TotalGreenGems")
	local woodPrice = v7:GetAttribute("WoodPrice")
	local scrapPrice = v7:GetAttribute("ScrapPrice")
	local gemPrice = v7:GetAttribute("GemPrice")
	local greenGemPrice = v7:GetAttribute("GreenGemPrice")
	local limit = v7:GetAttribute("Limit")

	if not table.find(CraftingDatabase.AllowDuplicates, p) and v7:GetAttribute("SoldOut") then
		return false
	end

	if (woodPrice and woodPrice <= totalWood or not woodPrice) and (gemPrice and gemPrice <= totalGems or not gemPrice) and (scrapPrice and scrapPrice <= totalScrap or not scrapPrice) and (greenGemPrice and greenGemPrice <= totalGreenGems or not greenGemPrice) then
		if table.find(CraftingDatabase.AllowDuplicates, p) then
			return true
		end

		if limit then
			if limit <= 0 then
				v7:SetAttribute("SoldOut", true)
			end
		else
			v7:SetAttribute("SoldOut", true)
		end

		return true
	else
		if scrapPrice and totalScrap < scrapPrice then
			DoErrorMessage(craftingTable2.Materials.ScrapAmount, "not enough scrap")
		elseif gemPrice and totalGems < gemPrice then
			DoErrorMessage(craftingTable2.Materials.GemAmount, "not enough cultist gems")
		elseif greenGemPrice and totalGreenGems < greenGemPrice then
			DoErrorMessage(craftingTable2.Materials.GreenGemAmount, "not enough forest gems")
		else
			DoErrorMessage(craftingTable2.Materials.WoodAmount, "not enough wood")
		end

		return false
	end
end

function FadeIcon(instance, p)
	local v7 = GetButtonFromName(instance.Name)
	local woodPrice = instance:GetAttribute("WoodPrice")
	local scrapPrice = instance:GetAttribute("ScrapPrice")
	local gemPrice = instance:GetAttribute("GemPrice")
	local greenGemPrice = instance:GetAttribute("GreenGemPrice")

	if p then
		v7.BackgroundTransparency = 0.9
		v7.ImageLabel.ImageTransparency = 0.8
		v7.ImageLabel.Infinity.ImageTransparency = 0.85
		v7.ImageLabel.Infinity.LimitCountFrame.TextLabel.TextTransparency = 0.85
		v7.ImageLabel.Infinity.LimitCountFrame.TextLabel.UIStroke.Transparency = 0.85
		v7.TitleLabel.TextTransparency = 0.6
		v7.ImageLabel.Image = instance:GetAttribute("Image") or ""

		if table.find(CraftingDatabase.AllowDuplicates, v7.Name) then
			v7.ImageLabel.Infinity.Visible = true
			local limit = instance:GetAttribute("Limit")

			if limit then
				v7.ImageLabel.Infinity.Image = "rbxassetid://100242403593887"
				v7.ImageLabel.Infinity.LimitCountFrame.Visible = true
				v7.ImageLabel.Infinity.LimitCountFrame.TextLabel.Text = "x" .. limit

				if limit == 0 then
					v7.ImageLabel.Infinity.Visible = false
				end
			else
				v7.ImageLabel.Infinity.LimitCountFrame.Visible = false
			end
		end

		v7.TitleLabel.Visible = true

		if gemPrice or greenGemPrice then
			if v7:FindFirstChild("PriceWithGems") then
				v7.Price:Destroy()
				v7.PriceWithGems.Name = "Price"
				v7.Price.Visible = true
			end

			if gemPrice then
				v7.Price.GemFrame.Visible = true
				v7.Price.GemFrame.GemAmount.Text = gemPrice
			else
				v7.Price.GemFrame.Visible = false
			end

			if greenGemPrice then
				v7.Price.GreenGemFrame.Visible = true
				v7.Price.GreenGemFrame.GreenGemAmount.Text = greenGemPrice
			else
				v7.Price.GreenGemFrame.Visible = false
			end
		end

		if scrapPrice then
			v7.Price.ScrapFrame.Visible = true
			v7.Price.ScrapFrame.ScrapAmount.Text = scrapPrice
		end

		if woodPrice then
			v7.Price.WoodFrame.Visible = true
			v7.Price.WoodFrame.WoodAmount.Text = woodPrice
		end

		v7.Price.ScrapFrame.ScrapAmount.TextTransparency = 0.7
		v7.Price.ScrapFrame.ScrapImage.ImageTransparency = 0.6
		v7.Price.WoodFrame.WoodAmount.TextTransparency = 0.7
		v7.Price.WoodFrame.WoodImage.ImageTransparency = 0.6

		if gemPrice then
			v7.Price.GemFrame.GemAmount.TextTransparency = 0.7
			v7.Price.GemFrame.GemImage.ImageTransparency = 0.6
		end

		if greenGemPrice then
			v7.Price.GreenGemFrame.GreenGemAmount.TextTransparency = 0.7
			v7.Price.GreenGemFrame.GreenGemImage.ImageTransparency = 0.6
		end
	else
		v7.ImageLabel.Image = instance:GetAttribute("Image") or ""
		v7.ImageLabel.Infinity.LimitCountFrame.TextLabel.TextTransparency = 0
		v7.ImageLabel.Infinity.LimitCountFrame.TextLabel.UIStroke.Transparency = 0

		if table.find(CraftingDatabase.AllowDuplicates, instance.Name) then
			local limit = instance:GetAttribute("Limit")
			v7.ImageLabel.Infinity.Visible = true

			if limit then
				v7.ImageLabel.Infinity.Image = "rbxassetid://100242403593887"
				v7.ImageLabel.Infinity.LimitCountFrame.Visible = true
				v7.ImageLabel.Infinity.LimitCountFrame.TextLabel.Text = "x" .. limit

				if limit == 0 then
					v7.ImageLabel.Infinity.Visible = false
				end
			else
				v7.ImageLabel.Infinity.LimitCountFrame.Visible = false
			end
		end

		v7.TitleLabel.Visible = true

		if gemPrice or greenGemPrice then
			if v7:FindFirstChild("PriceWithGems") then
				v7.Price:Destroy()
				v7.PriceWithGems.Name = "Price"
				v7.Price.Visible = true
			end

			if gemPrice then
				v7.Price.GemFrame.Visible = true
				v7.Price.GemFrame.GemAmount.Text = gemPrice
			else
				v7.Price.GemFrame.Visible = false
			end

			if greenGemPrice then
				v7.Price.GreenGemFrame.Visible = true
				v7.Price.GreenGemFrame.GreenGemAmount.Text = greenGemPrice
			else
				v7.Price.GreenGemFrame.Visible = false
			end
		end

		if scrapPrice then
			v7.Price.ScrapFrame.Visible = true
			v7.Price.ScrapFrame.ScrapAmount.Text = scrapPrice
		end

		if woodPrice then
			v7.Price.WoodFrame.Visible = true
			v7.Price.WoodFrame.WoodAmount.Text = woodPrice
		end

		v7.BackgroundTransparency = 0.45
		v7.ImageLabel.ImageTransparency = 0
		v7.ImageLabel.Infinity.ImageTransparency = 0
		v7.TitleLabel.TextTransparency = 0
		v7.Price.ScrapFrame.ScrapAmount.TextTransparency = 0
		v7.Price.ScrapFrame.ScrapImage.ImageTransparency = 0
		v7.Price.WoodFrame.WoodAmount.TextTransparency = 0
		v7.Price.WoodFrame.WoodImage.ImageTransparency = 0

		if gemPrice then
			v7.Price.GemFrame.GemAmount.TextTransparency = 0
			v7.Price.GemFrame.GemImage.ImageTransparency = 0
		end

		if greenGemPrice then
			v7.Price.GreenGemFrame.GreenGemAmount.TextTransparency = 0
			v7.Price.GreenGemFrame.GreenGemImage.ImageTransparency = 0
		end
	end
end

local function CreateGui(instance)
	local craftingTable3 = ReplicatedStorage["Crafting Table"]
	local craftingTableTier = ReplicatedStorage["Crafting Table"]:GetAttribute("CraftingTableTier")

	if (IsBlacksmithClass() or Client.Utility.HasTalent(localPlayer, "BonusCrafting")) and craftingTableTier < 4 then
		craftingTableTier += 1
	end

	local name = instance.Name
	local replacementName = instance:GetAttribute("ReplacementName") or instance.Name
	local tier = instance:GetAttribute("Tier")
	local image = instance:GetAttribute("Image")
	instance:GetAttribute("Description")
	local limit = instance:GetAttribute("Limit")
	local layoutOrder = instance:GetAttribute("LayoutOrder")
	local woodPrice = instance:GetAttribute("WoodPrice")
	local scrapPrice = instance:GetAttribute("ScrapPrice")
	local gemPrice = instance:GetAttribute("GemPrice")
	local greenGemPrice = instance:GetAttribute("GreenGemPrice")
	local soldOut = instance:GetAttribute("SoldOut")
	local limited = instance:GetAttribute("Limited")
	local toys = instance:GetAttribute("Toys")
	local v8 = instance:GetAttribute("EventSkin") and localPlayer:GetAttribute("EventSkins") and true or limited
	local hideOnUpgrade = instance:GetAttribute("HideOnUpgrade")
	local showOnUpgrade = instance:GetAttribute("ShowOnUpgrade")
	local workspaceId = instance:GetAttribute("WorkspaceId")

	if not name then
		return
	end

	local clone = clonesByName[name]
	local child = scrollingFrame:FindFirstChild("Tier" .. tier)

	if not clone then
		if not child then
			print("NO SCROLLING FRAME TIER FOUND")
			return
		end

		clone = child.Template:Clone()
		clone.LayoutOrder = layoutOrder
		clonesByName[name] = clone
		v6[name] = v6[name] or {}
		v6[name].click = clone.ImageButton.MouseButton1Down:Connect(function()
			craftingTableTier = ReplicatedStorage["Crafting Table"]:GetAttribute("CraftingTableTier")
			tier = instance:GetAttribute("Tier")

			if craftingTableTier < 4 and tier <= craftingTableTier + 1 or tier <= craftingTableTier then
				if Client.PingClient.PingActive then
					return
				end

				Client.Sound.Play("KeyPress", {
					Duplicate = true
				})
				SelectButton(clone, true)
				CreatePreview(name, tier)
			end
		end)
		clone.Visible = true
		clone.Parent = child
	end

	if v8 then
		clone:SetAttribute("Limited", true)
	end

	if toys then
		clone:SetAttribute("Toys", true)
	end

	local v9 = string.sub(name, 1, 8) == "Crafting"

	if v8 and v ~= clone then
		clone.UIStroke.Transparency = 0.55
		clone.UIStroke.Color = Color3.fromRGB(255, 38, 38)
	end

	if tier <= craftingTableTier then
		clone.ImageLabel.Image = image or v5[name]

		if v8 then
			clone.EventImage.Visible = true
		end
	else
		clone.ImageLabel.Image = "rbxassetid://139862783469180"
	end

	if table.find(CraftingDatabase.AllowDuplicates, name) then
		if tier <= craftingTableTier + 1 then
			clone.ImageLabel.Infinity.Visible = true

			if limit then
				clone.ImageLabel.Infinity.Image = "rbxassetid://100242403593887"
				clone.ImageLabel.Infinity.LimitCountFrame.Visible = true
				clone.ImageLabel.Infinity.LimitCountFrame.TextLabel.Text = "x" .. limit

				if limit == 0 then
					clone.ImageLabel.Infinity.Visible = false
				end
			else
				clone.ImageLabel.Infinity.LimitCountFrame.Visible = false
			end
		else
			clone.ImageLabel.Infinity.Visible = false
		end
	elseif layoutOrder then
		clone.LayoutOrder = layoutOrder
	else
		clone.LayoutOrder = 15
	end

	clone.TitleLabel.Text = replacementName or name
	clone.TitleLabel.Visible = true

	if craftingTableTier < tier then
		clone.TitleLabel.Visible = false
	end

	if tier <= craftingTableTier then
		if gemPrice or greenGemPrice then
			if clone:FindFirstChild("PriceWithGems") then
				clone.Price:Destroy()
				clone.PriceWithGems.Name = "Price"
				clone.Price.Visible = true
			end

			if gemPrice then
				clone.Price.GemFrame.Visible = true
				clone.Price.GemFrame.GemAmount.Text = gemPrice
			else
				clone.Price.GemFrame.Visible = true
			end

			if greenGemPrice then
				clone.Price.GreenGemFrame.Visible = true
				clone.Price.GreenGemFrame.GreenGemAmount.Text = greenGemPrice
			else
				clone.Price.GreenGemFrame.Visible = false
			end
		end

		if scrapPrice then
			clone.Price.ScrapFrame.Visible = true
			clone.Price.ScrapFrame.ScrapAmount.Text = scrapPrice
		end

		if woodPrice then
			clone.Price.WoodFrame.Visible = true
			clone.Price.WoodFrame.WoodAmount.Text = woodPrice
		end
	end

	if v9 then
		clone.BackgroundColor3 = Color3.fromRGB(255, 191, 0)
		clone.BackgroundTransparency = 0.45
	end

	if limit and limit <= 0 then
		instance:SetAttribute("SoldOut", true)
		clone.SoldOut.Visible = true
		clone.Price.Visible = false
		clone:AddTag("CantBuy")
	elseif limit and limit > 0 then
		instance:SetAttribute("SoldOut", false)
		clone.SoldOut.Visible = false
		clone.Price.Visible = true
		clone:RemoveTag("CantBuy")
	end

	if soldOut then
		instance:SetAttribute("SoldOut", true)
		clone.SoldOut.Visible = true
		clone.Price.Visible = false
		clone:AddTag("CantBuy")
	else
		instance:SetAttribute("SoldOut", false)
		clone.SoldOut.Visible = false
		clone.Price.Visible = true
		clone:RemoveTag("CantBuy")
	end

	if tier == craftingTableTier + 1 and craftingTableTier + 1 ~= 5 then
		FadeIcon(instance, true)
	elseif tier <= craftingTableTier then
		FadeIcon(instance, false)
	end

	if IsBlacksmithClass() or Client.Utility.HasTalent(localPlayer, "CraftingSale") then
		if (instance:GetAttribute("SaleScrapPrice") or instance:GetAttribute("SaleWoodPrice")) and localPlayer:GetAttribute("ClassLevel") >= 2 then
			clone.Sale.Visible = true
		else
			clone.Sale.Visible = false
		end
	end

	if v == clone then
		CreatePreview(name)
	end

	clone.Parent = child

	if hideOnUpgrade and craftingTable3:GetAttribute("UpgradeRecipe_" .. hideOnUpgrade) then
		clone.Visible = false
	elseif showOnUpgrade and craftingTable3:GetAttribute("UpgradeRecipe_" .. showOnUpgrade) == nil then
		clone.Visible = false
	elseif workspaceId and workspace:GetAttribute(workspaceId) == nil then
		clone.Visible = false
	else
		if showOnUpgrade and not clone:FindFirstChild("CraftingTableUpgraded") then
			local clone_2 = ReplicatedStorage.Assets.Billboards.CraftingTableUpgraded:Clone()
			clone_2.Parent = clone
			clone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end

		clone.Visible = true
	end

	clone.Name = name

	if v9 and (IsBlacksmithClass() or Client.Utility.HasTalent(localPlayer, "BonusCrafting")) and tier == ReplicatedStorage["Crafting Table"]:GetAttribute("CraftingTableTier") + 1 then
		clone.Visible = false
	end

	if instance:GetAttribute("Toys") and instance:GetAttribute("SoldOut") then
		clone.Visible = false
	end
end

function CaptureLayoutBaseline()
	v2 = {
		Padding = uIListLayout.Padding.Scale * scale,
		Sections = {}
	}

	for _, guiObject in pairs(scrollingFrame:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v7 = {
			Frame = guiObject,
			Height = guiObject.Size.Y.Scale * scale
		}
		local uIGridLayout = guiObject:FindFirstChildOfClass("UIGridLayout")

		if uIGridLayout then
			v7.Grid = uIGridLayout
			v7.CellHeight = uIGridLayout.CellSize.Y.Scale * v7.Height
			v7.CellPadding = uIGridLayout.CellPadding.Y.Scale * v7.Height
			v7.Columns = uIGridLayout.FillDirectionMaxCells

			if v7.Columns <= 0 then
				v7.Columns = math.floor((1 + uIGridLayout.CellPadding.X.Scale) / (uIGridLayout.CellSize.X.Scale + uIGridLayout.CellPadding.X.Scale) + 0.001)
			end

			v7.Columns = math.max(1, v7.Columns)
			v7.MinRows = math.max(
				1,
				(math.floor((v7.Height + v7.CellPadding) / (v7.CellHeight + v7.CellPadding) + 0.001))
			)
			v7.Slack = v7.Height - (v7.MinRows * v7.CellHeight + (v7.MinRows - 1) * v7.CellPadding)
		end

		table.insert(v2.Sections, v7)
	end
end

function UpdateScrollLayout()
	if not v2 then
		return
	end

	local total = 0
	local count = 0

	for _, section in pairs(v2.Sections) do
		if section.Grid then
			local count2 = 0

			for _, guiObject in pairs(section.Frame:GetChildren()) do
				if guiObject:IsA("GuiObject") and guiObject.Visible then
					count2 += 1
				end
			end

			local v7 = math.max(section.MinRows, (math.ceil(count2 / section.Columns)))
			section.Height = v7 * section.CellHeight + (v7 - 1) * section.CellPadding + section.Slack
		end

		if not section.Frame.Visible then
			continue
		end

		total += section.Height
		count += 1
	end

	local v7 = total + v2.Padding * math.max(0, count - 1)
	local v8 = math.max(scale, v7 + v2.Padding)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, v8, 0)
	uIListLayout.Padding = UDim.new(v2.Padding / v8, 0)

	for _, section in pairs(v2.Sections) do
		local size = section.Frame.Size
		section.Frame.Size = UDim2.new(size.X.Scale, size.X.Offset, section.Height / v8, 0)

		if not section.Grid then
			continue
		end

		local cellSize = section.Grid.CellSize
		local cellPadding = section.Grid.CellPadding
		section.Grid.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, section.CellHeight / section.Height, 0)
		section.Grid.CellPadding = UDim2.new(
			cellPadding.X.Scale,
			cellPadding.X.Offset,
			section.CellPadding / section.Height,
			0
		)
	end
end

function RefreshAll()
	local craftingTable3 = ReplicatedStorage["Crafting Table"]

	for _, folder in pairs(craftingTable:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		folder:GetAttribute("Limited")

		if not (not folder:GetAttribute("ShowOnUpgrade") or craftingTable3:GetAttribute("UpgradeRecipe_" .. folder:GetAttribute("ShowOnUpgrade")) ~= nil) then
			continue
		end

		if not (not folder:GetAttribute("WorkspaceId") or workspace:GetAttribute(folder:GetAttribute("WorkspaceId")) ~= nil) then
			continue
		end

		if not (not folder:GetAttribute("Toys") or localPlayer:GetAttribute("HasToy") ~= nil) then
			continue
		end

		CreateGui(folder)
	end

	UpdateScrollLayout()
end

local function FolderAttributeChanged(folder)
	local name = folder.Name
	v6 = v6 or {}
	v6[name] = v6[name] or {}
	v6[name].attributeChanged = folder.AttributeChanged:Connect(function(_)
		CreateGui(folder)
		UpdateScrollLayout()
	end)
end

function ListenForLimitedBlueprints()
	local craftingTable3 = ReplicatedStorage["Crafting Table"]

	for _, folder in pairs(craftingTable3:GetChildren()) do
		if folder:IsA("Folder") and folder:GetAttribute("Limited") then
			localPlayer:GetAttributeChangedSignal("Limited_" .. string.gsub(folder.Name, " ", "_")):Connect(function()
				RefreshAll()
			end)
		end
	end

	craftingTable3.AttributeChanged:Connect(function(value)
		if string.sub(value, 1, 14) == "UpgradeRecipe_" then
			print("recipe was upgraded")
			RefreshAll()
		end
	end)
	localPlayer:GetAttributeChangedSignal("EventSkins"):Connect(function()
		RefreshAll()
	end)
	workspace.AttributeChanged:Connect(function()
		RefreshAll()
	end)
end

function CraftingTableInitialize(_)
	local craftingTable3 = ReplicatedStorage["Crafting Table"]

	for _, folder in pairs(craftingTable3:GetChildren()) do
		if folder:IsA("Folder") then
			FolderAttributeChanged(folder)
		end
	end

	v6.childAdded = craftingTable3.ChildAdded:Connect(function(folder)
		if folder:IsA("Folder") then
			FolderAttributeChanged(folder)
		end
	end)

	if craftingTable:GetAttribute("CraftingTableTier") == 4 or craftingTable:GetAttribute("CraftingTableTier") == 5 then
		local scrollingFrame2 = Client.Interface.CraftingTable.ScrollingFrame
		scrollingFrame2.Break4.Visible = true
		scrollingFrame2.Tier5.Visible = true
	end

	craftingTable:GetAttributeChangedSignal("CraftingTableTier"):Connect(function()
		if craftingTable:GetAttribute("CraftingTableTier") == 4 or craftingTable:GetAttribute("CraftingTableTier") == 5 then
			local scrollingFrame2 = Client.Interface.CraftingTable.ScrollingFrame
			scrollingFrame2.Break4.Visible = true
			scrollingFrame2.Tier5.Visible = true
		end

		RefreshAll()
	end)
	RefreshAll()
end

function EngineerSetup()
	craftingTable2.Position = UDim2.new(0.4, 0, 0.5, 0)
	craftingTable2.EngineerShop.Visible = true
	local gears = localPlayer:GetAttribute("Gears") or 0
	localPlayer:GetAttributeChangedSignal("Gears"):Connect(function()
		gears = localPlayer:GetAttribute("Gears") or 0
	end)
	local engineerShop = craftingTable2.EngineerShop
	local text = 5
	task.spawn(function()
		local gearsAmount = engineerShop["Sentry Gun"].Price.GearsFrame.GearsAmount

		local function updatePrice()
			local turretsBought = localPlayer:GetAttribute("TurretsBought") or 0
			local turretPrices = Client.GlobalSettings.TurretPrices
			text = turretPrices[math.min(turretsBought + 1, #turretPrices)]
			gearsAmount.Text = text

			if gears < text then
				engineerShop.CraftButton.BackgroundColor3 = Color3.fromRGB(98, 18, 19)
			else
				engineerShop.CraftButton.BackgroundColor3 = Color3.fromRGB(124, 229, 55)
			end
		end

		updatePrice()
		localPlayer:GetAttributeChangedSignal("TurretsBought"):Connect(updatePrice)
		gears = localPlayer:GetAttribute("Gears") or 0
		engineerShop.GearsAmount.TextLabel.Text = gears
		localPlayer:GetAttributeChangedSignal("Gears"):Connect(function()
			gears = localPlayer:GetAttribute("Gears") or 0
			engineerShop.GearsAmount.TextLabel.Text = gears

			if gears < text then
				engineerShop.CraftButton.BackgroundColor3 = Color3.fromRGB(98, 18, 19)
			else
				engineerShop.CraftButton.BackgroundColor3 = Color3.fromRGB(124, 229, 55)
			end
		end)

		if gears < text then
			engineerShop.CraftButton.BackgroundColor3 = Color3.fromRGB(98, 18, 19)
		else
			engineerShop.CraftButton.BackgroundColor3 = Color3.fromRGB(124, 229, 55)
		end
	end)
	engineerShop.CraftButton.Activated:Connect(function()
		if not (text <= gears) then
			DoErrorMessage(engineerShop.GearsAmount.TextLabel, "not enough gears")
			return
		end

		print("PURCHASED TURRET")
		Client.Sound.Play("BuyItem", {
			Volume = 0.4
		})
		Client.PopUpUI.AddPopUp("purchased candy turret")
		Client.Events.RequestPurchaseTurret:FireServer()
	end)
end

Client.Events.FlashCraftingBenchOnUpgrade:Connect(function()
	local craftingBench = campground:FindFirstChild("CraftingBench")

	if craftingBench then
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 225, 0)
		highlight.OutlineTransparency = 1
		highlight.FillTransparency = 1
		highlight.Parent = craftingBench
		TweenService:Create(highlight, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FillTransparency = 0.15
		}):Play()
		task.spawn(function()
			wait(1)

			if highlight and highlight.Parent then
				TweenService:Create(highlight, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					FillTransparency = 1
				}):Play()
			end

			wait(2)

			if highlight and highlight.Parent then
				highlight.Adornee = nil
				highlight:Destroy()
			end
		end)
	end
end)

function CraftingTableClient.Init()
	task.spawn(function()
		craftingTable = ReplicatedStorage["Crafting Table"]
		localPlayer:GetAttributeChangedSignal("Class"):Connect(function()
			if IsBlacksmithClass() or Client.Utility.HasTalent(localPlayer, "BonusCrafting") or Client.Utility.HasTalent(
				localPlayer,
				"CraftingSale"
			) then
				RefreshAll()
			end
		end)
		campground = workspace:WaitForChild("Map"):WaitForChild("Campground")
		campground:GetAttributeChangedSignal("TotalScrap"):Connect(UpdateScrap)
		campground:GetAttributeChangedSignal("TotalWood"):Connect(UpdateScrap)
		campground:GetAttributeChangedSignal("TotalGems"):Connect(UpdateScrap)
		campground:GetAttributeChangedSignal("TotalGreenGems"):Connect(UpdateScrap)
		CaptureLayoutBaseline()
		CraftingTableInitialize(craftingTable)
		ListenForLimitedBlueprints()
		previewFrame.Price.ScrapFrame.ScrapAmount:GetPropertyChangedSignal("Text"):Connect(UpdatePreviewPriceColor)
		previewFrame.Price.WoodFrame.WoodAmount:GetPropertyChangedSignal("Text"):Connect(UpdatePreviewPriceColor)
		previewFrame.CraftButton.MouseButton1Down:Connect(function()
			if Client.PingClient.PingActive then
				return
			end

			if v and CheckCanBuy(v.Name) then
				Client.Sound.Play("BuyItem", {
					Volume = 0.4
				})

				if not Client.Events.CraftItem:InvokeServer(v.Name) then
					RefreshAll()
				end
			end
		end)
		task.spawn(UpdateScrap)
		task.spawn(function()
			localPlayer:GetAttributeChangedSignal("HasToy"):Connect(function()
				RefreshAll()
			end)
		end)
		local v7

		if localPlayer:GetAttribute("Class") == "Engineer" then
			EngineerSetup()
			v7 = true
		else
			v7 = false
		end

		localPlayer:GetAttributeChangedSignal("Class"):Connect(function()
			if localPlayer:GetAttribute("Class") == "Engineer" and not v7 then
				v7 = true
				EngineerSetup()
			end
		end)
		UtilityAlec.preload({
			"rbxassetid://125638505353872",
			"rbxassetid://130009604520646",
			"rbxassetid://130009604520646",
			"rbxassetid://77813533977621"
		})
		local images = {}

		for _, v8 in pairs(CraftingDatabase) do
			for _, v9 in pairs(v8) do
				if typeof(v9) ~= "table" then
					continue
				end

				for _, v10 in pairs(v9) do
					if v10.Image then
						table.insert(images, v10.Image)
					end
				end
			end
		end

		UtilityAlec.preload(images)
		task.spawn(function()
			for _, possibleBlueprint in pairs(CraftingDatabase.PossibleBlueprints) do
				for _, v8 in pairs(possibleBlueprint) do
					if not (v8.BiggerImage and v8.BiggerImage ~= "rbxassetid://") then
						continue
					end

					repeat
						task.wait(1)
					until ContentProvider.RequestQueueSize == 0

					UtilityAlec.preload({ v8.BiggerImage })
				end
			end
		end)
	end)
end

return CraftingTableClient