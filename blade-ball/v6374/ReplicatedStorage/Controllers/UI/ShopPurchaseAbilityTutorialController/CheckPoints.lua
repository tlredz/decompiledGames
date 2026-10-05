local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Controllers.UI.ShopController)
local v4 = require3(script.Parent)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local CheckPoints = {}

function CheckPoints.Start(maid)
	local character = localPlayer.Character
	maid:Add(TweenService:Create(
		maid:Add(v4:CreateArrowOnElement(
			playerGui:WaitForChild("HUD"):WaitForChild("LeftFrame"):WaitForChild("Middle"):WaitForChild("ShopPage"),
			properties
		)),
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, -1, true),
		{
			Position = UDim2.fromScale(1.05, 0.73)
		}
	)):Play()
	maid:Add(v2:OnGuiOpen("Shop", function()
		v4:SetTutorialCheckPoint("AbilityShopOpened")
	end))
	maid:Add(character.AncestryChanged:Connect(function(_, parent)
		if parent == workspace.Alive then
			v4:SetTutorialCheckPoint("RoundStarted")
		end
	end))
end

function CheckPoints.AbilityShopOpened(maid)
	local holder = playerGui:WaitForChild("Shop"):WaitForChild("Holder")
	local pages = holder:WaitForChild("Pages")
	local ability = pages:WaitForChild("Ability")
	local invisibility = ability:WaitForChild("Unowned"):WaitForChild("Invisibility")
	holder:WaitForChild("InfoBG"):WaitForChild("BuyButton")
	v.Client:WaitReplion("Data")
	v3:GoTo("Ability", true)
	maid:Add(TweenService:Create(maid:Add(v4:CreateArrowOnElement(invisibility, {
		Rotation = 0,
		Position = UDim2.fromScale(0.5, -0.2)
	})), TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, -1, true), {
		Position = UDim2.fromScale(0.5, 0.1)
	})):Play()
	local v7 = invisibility.AbsolutePosition.Y - invisibility.AbsoluteSize.Y - ability.AbsolutePosition.Y
	pages.Abilities.CanvasPosition += Vector2.new(0, v7)
	maid:Add(v3.itemSelected:Connect(function(p)
		if p.name == "Invisibility" then
			v4:SetTutorialCheckPoint("AbilitySelected")
		end
	end))
	maid:Add(client:OnChange("Ability", function(_: number, _: string)
		v4:SetTutorialCheckPoint("BoughtDifferentAbility")
	end))
end

function CheckPoints.AbilitySelected(maid)
	local buyButton = playerGui:WaitForChild("Shop"):WaitForChild("Holder"):WaitForChild("InfoBG"):WaitForChild("BuyButton")
	maid:Add(TweenService:Create(maid:Add(v4:CreateArrowOnElement(buyButton, {
		Rotation = 180,
		Position = UDim2.fromScale(0.5, 2.2),
		Size = UDim2.fromScale(1, 1)
	})), TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, -1, true), {
		Position = UDim2.fromScale(0.5, 1.7)
	})):Play()
	maid:Add(buyButton.Activated:Connect(function()
		v4:SetTutorialCheckPoint("EquipAbility")
	end))
end

function CheckPoints.EquipAbility(maid)
	local buyButton = playerGui:WaitForChild("Shop"):WaitForChild("Holder"):WaitForChild("InfoBG"):WaitForChild("BuyButton")
	maid:Add(TweenService:Create(maid:Add(v4:CreateArrowOnElement(buyButton, {
		Rotation = 180,
		Position = UDim2.fromScale(0.5, 2.2),
		Size = UDim2.fromScale(1, 1)
	})), TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, -1, true), {
		Position = UDim2.fromScale(0.5, 1.7)
	})):Play()
	maid:Add(v3.itemSelected:Connect(function(p)
		if p.name ~= "Invisibility" then
			v4:SetTutorialCheckPoint("FinishedDidNotEquip")
		end
	end))
	maid:Add(v2:OnGuiClose("Shop", function()
		v4:SetTutorialCheckPoint("FinishedDidNotEquip")
	end))
	maid:Add(buyButton.Activated:Connect(function()
		v4:SetTutorialCheckPoint("Finished")
	end))
end

return CheckPoints