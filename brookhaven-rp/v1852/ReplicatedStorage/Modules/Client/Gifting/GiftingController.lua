local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local GiftExpired = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Shop.GiftExpired)
local GiftReceived = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Shop.GiftReceived)
local GiftSent = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Shop.GiftSent)
local PopupQueue = require(ReplicatedStorage.Modules.Client.UI.PopupQueue)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = nil
local GiftingController = {}

function GiftingController.FrameworkInit()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function GiftingController.FrameworkStart()
	local rBXSystem = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")
	Remotes.connect("GiftBroadcast", function(p, p2, p3)
		rBXSystem:DisplaySystemMessage("<font color=\"#eba0e0\">[Server]: </font><font weight=\"SemiBold\" color=\"#fac519\">" .. p .. "</font> gifted " .. p2 .. " <font weight=\"SemiBold\">" .. p3 .. "</font>!")
	end)
	Remotes.connect("GiftSent", function(p, p2, p3)
		if v.IsOpen("MainGUIHandler", "GiftSent") then
			return
		end

		GiftSent:SetGiftData(p, p2, p3)
		v.OpenPanelByContext("MainGUIHandler", "GiftSent")
	end)
	PopupQueue.RegisterHandler("MainGUIHandler", "GiftReceived", function(...)
		GiftReceived:SetGiftData(...)
	end)
	Remotes.connect("GiftReceived", function(p, p2, p3, p4, p5)
		PopupQueue.Dispatch("MainGUIHandler", "GiftReceived", p, p2, p3, p4, p5)
	end)
	PopupQueue.RegisterHandler("MainGUIHandler", "GiftExpired", function(...)
		GiftExpired:SetGiftData(...)
	end)
	Remotes.connect("GiftExpired", function(p)
		PopupQueue.Dispatch("MainGUIHandler", "GiftExpired", p)
	end)
end

function GiftingController.ShowError(value: string?, targetPanel: string?)
	local outsideBox = Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftFailed"):WaitForChild("OutsideBox")
	local giftingTitle = outsideBox:WaitForChild("GiftingTitle")
	giftingTitle.Text = value or "Sorry, but there was an error processing your gift."
	local giftButton = outsideBox:WaitForChild("GiftButton")

	if targetPanel == nil then
		giftButton:RemoveTag("TogglePanelButton")
		giftButton:SetAttribute("TargetPanel", nil)
	else
		giftButton:AddTag("TogglePanelButton")
		giftButton:SetAttribute("TargetPanel", targetPanel)
	end

	v.OpenPanelByContext("MainGUIHandler", "GiftFailed")
end

return GiftingController