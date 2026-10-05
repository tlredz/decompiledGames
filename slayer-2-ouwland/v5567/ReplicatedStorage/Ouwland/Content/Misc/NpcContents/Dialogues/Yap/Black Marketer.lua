local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local TimedVendor = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.TimedVendor)
local Shop

if RunService:IsClient() then
	Shop = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Shop)
else
	Shop = nil
end

return {
	["Black Marketer"] = {
		Text = "You look like someone who understands the [true value]<Color=(.8,.7,1)> of things.",
		Answers = true,
		IfTrue = "Black Marketer_2"
	},
	["Black Marketer_2"] = {
		OnShow = function(_, p)
			p.CartShopNode = "Black Marketer_2"
		end,
		Content = Shop ~= nil and function(p, p2, p3, p4)
			return Shop(TimedVendor.GetStockNames("Black Marketer"))(p, p2, p3, p4)
		end or nil,
		Text = "See anything you like? I don't [stay long]<Style=Fade,Color=(1,.3,.3)>.",
		Answers = {
			["Buy the selection"] = "ReviewCartPurchase",
			Farewell = "Black Marketer_Farewell"
		}
	},
	["Black Marketer_Farewell"] = {
		Text = `Keep your coin [#]<img={BunchaIcons.WenRaw}> ready… I move on [before anyone asks questions.]<Style=Fade,Color=(.8,.7,1)>`,
		Answers = 1
	}
}