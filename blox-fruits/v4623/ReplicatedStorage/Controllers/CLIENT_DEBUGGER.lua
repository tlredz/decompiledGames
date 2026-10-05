local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProfileLookup = require(ReplicatedStorage.Controllers.UI.PlayerProfileLookup)
local v = {
	[7734960460] = true,
	[7439880508] = true
}
return {
	OnStart = function(_)
		local RunService = game:GetService("RunService")

		if not RunService:IsClient() then
			return
		end

		local Net = require(ReplicatedStorage.Modules.Net)
		local remoteEvent = Net:RemoteEvent("_AdminCmdDialogue")
		local DialoguesList = require(game.ReplicatedStorage.DialoguesList)
		local DialogueController = require(game.ReplicatedStorage.DialogueController)
		local Notification = require(ReplicatedStorage.Notification)

		local function onOnClientEvent(p)
			if not p then
				Notification.new("name is nil", 3):Display()
				return
			end

			local v2 = nil
			local success, result = pcall(function(...)
				v2 = DialoguesList[p]
			end)

			if success and v2 then
				DialogueController.start(v2)
			elseif result then
				Notification.new(result, 3):Display()
			end
		end

		remoteEvent.OnClientEvent:Connect(onOnClientEvent)
		local v2 = {
			["/dog"] = "DoghouseSpike",
			["/laptop"] = "MysteriousScientist",
			["/cousin"] = "RandomFruitSeller"
		}

		local function process(text: string)
			if v2[text] then
				onOnClientEvent(v2[text])
			elseif text == "/skins" then
				local ModificationsMenu = require(game.ReplicatedStorage.Controllers.UI.ModificationsMenu)
				assert(ModificationsMenu.IsInitialized, "bad ModificationsController")
				local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
				ModificationsMenu:Open({
					Type = "MovesetSkin",
					MovesetType = "Fruit",
					AdorneeId = ItemConfig.match("Werewolf (Tiger)-Werewolf (Tiger)", "Moveset"):unwrap().Index.ItemId
				})
			elseif text == "/claim" then
				local GiftClaimWindow = require(game.ReplicatedStorage.Controllers.UI.GiftClaimWindow)
				GiftClaimWindow:Open()
			elseif text == "/note" then
				local NotesList = require(game.ReplicatedStorage:WaitForChild("NotesList"))
				DialogueController.showNote(NotesList.Test)
			elseif text == "/controller" then
				local UserInputService = game:GetService("UserInputService")
				print((`UserInputService.GamepadEnabled = {UserInputService.GamepadEnabled}`))
				local UserInputService2 = game:GetService("UserInputService")
				print("game.UserInputService:GetConnectedGamepads() =", UserInputService2:GetConnectedGamepads())
			elseif text == "/craft" then
				local Net2 = require(game.ReplicatedStorage.Modules.Net)
				Net2:RemoteFunction("UseMaterial"):InvokeServer("Wooden Plank", "Build Campfire")
			elseif text == "/valentinesbundle" then
				local BundleMenu = require(game.ReplicatedStorage.Controllers.UI.BundleMenu)
				local shop = game.Players.LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Shop")
				local header = shop:WaitForChild("Header")
				local scrollingFrame = shop:WaitForChild("MenuShop"):WaitForChild("ScrollingFrame")
				local v3 = header.AbsoluteSize.Y + scrollingFrame.AbsoluteSize.Y
				BundleMenu:Open(
					Vector2.new(header.AbsoluteSize.X, header.AbsoluteSize.Y + scrollingFrame.AbsoluteSize.Y),
					Vector2.new(header.AbsolutePosition.X, workspace.CurrentCamera.ViewportSize.Y * 0.5 - v3 * 0.5),
					"Valentines2026Bundle"
				)
			elseif text == "/bar" then
				local JuiceWindow = require(game.ReplicatedStorage.Controllers.UI.JuiceWindow)
				assert(JuiceWindow.IsInitialized, "bad JuiceWindow")
				JuiceWindow:Open({
					Window = "First",
					Mode = "Bartender"
				})
			elseif text == "/lookup" then
				assert(PlayerProfileLookup.IsInitialized, "bad player profile")
				PlayerProfileLookup:Open(false)
			elseif text == "/gacha" then
				local GachaWindow = require(game.ReplicatedStorage.Controllers.UI.GachaWindow)
				GachaWindow:Open("MagnetEventGacha26")
			elseif text == "/chromatic" then
				local GachaWindow = require(game.ReplicatedStorage.Controllers.UI.GachaWindow)
				GachaWindow:Open("PremiumChromaticMagnetGacha26")
			end
		end

		local RunService2 = game:GetService("RunService")

		if RunService2:IsStudio() or v[game.GameId] == true then
			local TextChatService = game:GetService("TextChatService")
			TextChatService.SendingMessage:Connect(function(p)
				process(p.Text)
			end)
		end

		local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
		local gacha = IrisLog.new("Gacha", nil, {
			Category = "Systems"
		})
		local GachaWindow = require(game.ReplicatedStorage.Controllers.UI.GachaWindow)
		gacha:AppendToTab("Windows", gacha:NewLine(), gacha:AuthorityButton("Tester", "Magnet", function()
			GachaWindow:Open("MagnetEventGacha26")
		end), gacha:NewLine(), gacha:AuthorityButton("Tester", "Chromatic Box", function()
			if v2["/chromatic"] then
				onOnClientEvent(v2["/chromatic"])
				return
			end

			local GachaWindow2 = require(game.ReplicatedStorage.Controllers.UI.GachaWindow)
			GachaWindow2:Open("PremiumChromaticMagnetGacha26")
		end))
	end
}