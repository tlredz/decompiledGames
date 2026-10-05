local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local Amount

if isClient then
	Amount = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Amount)
end

local PopUpCreator

if isClient then
	PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
else
	PopUpCreator = nil
end

local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local AcceptCost = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.AcceptCost)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local textplus = require(game.ReplicatedStorage.Packages.textplus)

for k, v in pairs(require(script.TextPlusIDs)) do
	textplus.RegisterId(k, v)
end

local v = nil
local v2 = 0
local wenCostOnAccept = nil
local v3 = nil
local v4 = nil
local flag = false
local Dialogue = {
	AttemptDialogue = simplesignal.new(),
	OpenDialogue = simplesignal.new(),
	Storage = {},
	CurrentDialogue = {
		Current = nil,
		Cancel = simplesignal.new()
	},
	Functions = {
		["Success-sound"] = function()
			local clone = game.ReplicatedStorage.Assets.Sounds.Misc.success:Clone()
			clone.Parent = script
			clone:Play()
			DebrisModule:AddItem(clone, clone.TimeLength)
		end,
		AddQuest = function(p)
			local v5 = Quests.Holder[p]
			local data = Utility.GetData(Players.LocalPlayer)

			if v5 ~= nil and v5.Requirements and not ItemRequirements.Passes(data, v5.Requirements) then
				v4 = ItemRequirements.Describe(v5.Requirements)
				return "RequirementNotMet"
			end

			if v5 ~= nil and v5.WenCostOnAccept and data ~= nil and data.Wen.Value < v5.WenCostOnAccept then
				wenCostOnAccept = v5.WenCostOnAccept
				return "NotEnoughWen"
			end

			if v5 ~= nil and v5.ItemCostOnAccept then
				local v6, name, count = AcceptCost.Check(data, v5.ItemCostOnAccept)

				if data ~= nil and not v6 then
					v3 = {
						Name = name,
						Count = count
					}
					return "NotEnoughItems"
				end
			end

			local canAddQuest, v6, v7 = Quests.CanAddQuest(p)

			if canAddQuest then
				SignalEvent.ToServer("AddQuest", p)
				return
			end

			v = v7
			v2 = math.max(Quests.QuestCD, v5 == nil and 0 or v5.AcceptCooldown or 0)

			if v6 == 2 then
				return "QuestAlreadyCompleted"
			elseif v6 == 1 then
				return "AlreadyDoingQuest"
			end

			if v6 then
				return "NoQuest"
			end

			return "NoQuestMaximumReached"
		end,
		ProceedWithPurchase = function(_, state)
			local shopPrompt = state.ShopPrompt
			local buyItemName = state.BuyItemName

			if not buyItemName then
				if shopPrompt == nil then
					buyItemName = nil
				else
					buyItemName = shopPrompt.ObjectText or nil
				end
			end

			if buyItemName == nil then
				return "PurchaseFail"
			end

			local v5 = Shop.SanitizeAmount(state.Amount)
			local canBuy, purchaseReason = Shop.CanBuy(Players.LocalPlayer, buyItemName, nil, v5)

			if canBuy then
				local clone = game.ReplicatedStorage.Assets.Sounds.Misc.Money_Kaching:Clone()
				clone.Parent = script
				clone:Play()
				DebrisModule:AddItem(clone, clone.TimeLength)
				SignalEvent.ToServer("PurchaseFromShop", buyItemName, v5)
				return shopPrompt:GetAttribute("SuccessDialogue") or "PurchaseSuccess"
			else
				state.PurchaseReason = purchaseReason
				local clone = game.ReplicatedStorage.Assets.Sounds.Misc.denied_old:Clone()
				clone.Parent = script
				clone:Play()
				DebrisModule:AddItem(clone, clone.TimeLength)
				return shopPrompt:GetAttribute("FailDialogue") or "PurchaseFail"
			end
		end,
		BackToShop = function(_, p)
			return p.CartShopNode or ""
		end,
		ReviewCartPurchase = function(_, p)
			local _, v5 = Shop.GetCartTotals(p.BuySelection)

			if v5 < 1 and #Shop.GetCartDeferred(p.BuySelection) < 1 then
				return "CartNothing"
			end

			local canBuyCart, purchaseReason = Shop.CanBuyCart(Players.LocalPlayer, p.BuySelection)

			if canBuyCart then
				return "CartConfirm"
			end

			p.PurchaseReason = purchaseReason
			local clone = game.ReplicatedStorage.Assets.Sounds.Misc.denied_old:Clone()
			clone.Parent = script
			clone:Play()
			DebrisModule:AddItem(clone, clone.TimeLength)
			return "PurchaseFail"
		end,
		ProceedWithCartPurchase = function(_, p)
			if flag then
				return "CartConfirm"
			end

			local _, v5 = Shop.GetCartTotals(p.BuySelection)

			if v5 < 1 and #Shop.GetCartDeferred(p.BuySelection) < 1 then
				return "CartNothing"
			end

			flag = true
			local v6

			if PopUpCreator ~= nil then
				v6 = PopUpCreator.new({
					Type = "LoadingFull"
				}) or nil
			end

			local server = SignalFunction.ToServer("PurchaseSelection", p.BuySelection)

			if v6 ~= nil then
				v6:Destroy()
			end

			flag = false
			p.BuySelection = nil
			local clone = game.ReplicatedStorage.Assets.Sounds.Misc[server and "Money_Kaching" or "denied_old"]:Clone()
			clone.Parent = script
			clone:Play()
			DebrisModule:AddItem(clone, clone.TimeLength)

			if server then
				return "CartPurchaseSuccess"
			end

			return "CartPurchaseFail"
		end
	},
	Diagloues = {
		ShopDialogue = {
			BeforeRun = function(p)
				local objectText = p.ObjectText

				if Shop.itemsforsale[objectText] == nil then
					return
				else
					return "BuyItem"
				end
			end,
			Text = "[Invalid Item!]<Color=rgb(255,0,0)>",
			Answers = true
		},
		BuyItem = {
			Text = function(shopPrompt, p)
				p.ShopPrompt = shopPrompt
				local buyItemName = p.BuyItemName or shopPrompt.ObjectText
				local price = Shop.GetPrice(buyItemName, true)
				return (`Would you like to purchase ['{buyItemName}']<{gameSettings.RichTextPopularConfigs.SoroundColor}> for [{price}]<style=Rainbow,color=(1,1,1)> each?`)
			end,
			Content = Amount,
			Answers = {
				Buy = "ProceedWithPurchase",
				Cancel = false
			}
		},
		PurchaseSuccess = {
			Text = "[Thanks for the business!]<Style=Rainbow,Color=(1,1,1)>",
			Answers = 1
		},
		CartConfirm = {
			Text = function(_, p)
				local cartTotals, v5 = Shop.GetCartTotals(p.BuySelection)
				local count = #Shop.GetCartDeferred(p.BuySelection)

				if v5 < 1 then
					return (`{count} Robux item(s) then. Roblox will ask you to confirm each one. Deal?`)
				end

				if count > 0 then
					return (`{v5} piece(s) then. That will be {Shop.FormatTotalsTextPlus(cartTotals)} for the lot, and Roblox will ask you about {count} Robux item(s) on top. Deal?`)
				end

				return (`{v5} piece(s) then. That will be {Shop.FormatTotalsTextPlus(cartTotals)} for the lot. Deal?`)
			end,
			Answers = {
				Deal = "ProceedWithCartPurchase",
				["Let me look again"] = "BackToShop"
			}
		},
		CartNothing = {
			Text = "You have not picked anything out yet.",
			Answers = true,
			IfTrue = function(_, p)
				return p.CartShopNode
			end
		},
		CartPurchaseSuccess = {
			Text = "[Thanks for the business!]<Style=Rainbow,Color=(1,1,1)>",
			Answers = {
				["Buy more"] = "BackToShop",
				Close = ""
			}
		},
		CartPurchaseFail = {
			Text = "[The purchase fell through. Check your coin and try again.]<Color=(1,.3,.3)>",
			Answers = true,
			IfTrue = function(_, p)
				return p.CartShopNode
			end
		},
		PurchaseFail = {
			Text = function(_, p)
				return (`[Purchase failed due not having {p.PurchaseReason}]<Color=(1,.3,.3)>`)
			end,
			Answers = 1
		},
		NoQuest = {
			Text = function()
				return (`[Unable to accept this quest at the moment, wait [{v2 - math.floor(Utility.Tick() - Utility.GetData(Players.LocalPlayer).Quests.LastTime.Value)}s]<Color=rgb(255,255,255)> then try again!]<Color=rgb(255,0,0)>`)
			end,
			Answers = true
		},
		NoQuestMaximumReached = {
			Text = function()
				if v == nil then
					return "[You are already doing a quest of this category, cancel it and retry.]<Color=rgb(255,0,0)>"
				end

				return (`[Abandon Quest ['{v}']<{gameSettings.RichTextPopularConfigs.SoroundColor}> first!]<Color=rgb(255,0,0)>`)
			end,
			Answers = true
		},
		AlreadyDoingQuest = {
			Text = "[You are already doing this quest!]<Color=rgb(255,150,75)>",
			Answers = true
		},
		QuestAlreadyCompleted = {
			Text = "[You have already completed this quest!]<Color=rgb(255,150,75)>",
			Answers = true
		},
		NotEnoughWen = {
			Text = function()
				return (`[You need [{Utility.addCommasToNumber(wenCostOnAccept or 0)} Wen]<Color=(1,1,1)> for this Quest!]<Color=(1,.3,.3)>`)
			end,
			Answers = true
		},
		RequirementNotMet = {
			Text = function()
				return (`[You need to be [{v4 or "?"}]<Color=rgb(161,199,230)> for this Quest!]<Color=(1,.3,.3)>`)
			end,
			Answers = true
		},
		NotEnoughItems = {
			Text = function()
				local v5 = v3 or {
					Name = "?",
					Count = 0
				}
				return (`[You need [{Utility.addCommasToNumber(v5.Count)} {v5.Name}]<Color=(1,.85,.3)> for this Quest!]<Color=(1,.3,.3)>`)
			end,
			Answers = true
		}
	}
}

for _, moduleScript in script:GetChildren() do
	if not (moduleScript:IsA("ModuleScript") and moduleScript.Name ~= "TextPlusIDs") then
		continue
	end

	local success, result = pcall(require, moduleScript)

	if success and type(result) == "table" then
		for k, v5 in result do
			Dialogue.Diagloues[k] = v5
		end
	else
		warn((`Dialogue: sibling module "{moduleScript.Name}" did not load, its nodes are missing: {result}`))
	end
end

function Dialogue.ResetStorage()
	table.clear(Dialogue.Storage)
	return Dialogue.Storage
end

return Dialogue