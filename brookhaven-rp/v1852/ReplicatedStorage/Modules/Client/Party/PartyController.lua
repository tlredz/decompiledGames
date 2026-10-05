local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local PartyInvited = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Party.PartyInvited)
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local RepeatableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.RepeatableDevProducts)
local PartyController = {
	HideInvites = false
}

function PartyController.FrameworkStart()
	local rBXSystem = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")
	local v, v2 = ABTest.GetExperimentVariables("house-cameras-rework"):timeout(5):await()
	Remotes.connect("PartyBroadcast", function(p, p2, p3)
		if not (v and v2.cameraEnabled) then
			rBXSystem:DisplaySystemMessage("<font color=\"#eba0e0\">[Server]: </font><font weight=\"SemiBold\" color=\"#fac519\">" .. p .. "</font> started a <font weight=\"SemiBold\">" .. p2 .. "</font> at house <font weight=\"SemiBold\">" .. p3 .. "</font>!")
			return
		end

		local v3 = LotUtil.GetById((tonumber(p3)))

		if not v3 then
			return
		end

		rBXSystem:DisplaySystemMessage("<font color=\"#eba0e0\">[Server]: </font><font weight=\"SemiBold\" color=\"#fac519\">" .. p .. "</font> started a <font weight=\"SemiBold\">" .. p2 .. "</font> at <font weight=\"SemiBold\">" .. v3:GetAttribute("Type") .. " #" .. v3:GetAttribute("ID") .. "</font>!")
	end)
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, p, p2)
		if not (p2 and RepeatableDevProducts.Exists(p)) then
			return
		end

		Players.LocalPlayer.PlayerGui.PurchaseSFX:Play()
	end)
	Remotes.connect("PartyInvited", function(p: number, p2: number, p3: string, p4: string, p5: string)
		if PartyController.HideInvites or PanelController.IsOpen("MainGUIHandler", "PartyInvited") then
			return
		end

		local playerByUserId = Players:GetPlayerByUserId(p)

		if playerByUserId == nil then
			return
		end

		PartyInvited.SetData(playerByUserId.Name, playerByUserId.UserId, p2, p3, p4, p5)
		PanelController.Open("MainGUIHandler", "PartyInvited")
	end)
	IntroController.OnPlayButtonPressed:Connect(function()
		Remotes.fireServer("PartyJoin")
	end)
end

return PartyController