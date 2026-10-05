local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DebrisModule

if RunService:IsClient() then
	DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
else
	DebrisModule = nil
end

local PopUpCreator

if RunService:IsClient() then
	PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
else
	PopUpCreator = nil
end

local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local DeliverAction = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DeliverAction)

local function playSound(childName: string)
	local child = ReplicatedStorage.Assets.Sounds.Misc:FindFirstChild(childName)

	if child == nil or DebrisModule == nil then
		return
	end

	local clone = child:Clone()
	clone.Parent = script
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength)
end

local flag = false

local function selectionCount(p)
	local total = 0

	if typeof(p.SellSelection) == "table" then
		for _, v in p.SellSelection do
			total += v
		end
	end

	return total
end

local MerchantActions = {}
MerchantActions.DeliverJewelryBoxToGinzo = DeliverAction(
	"Ill find the jewelry box(Lv 45)",
	"Return to Ginzo",
	"Ginzo_Thanks",
	"Ginzo_NoBox"
)

function MerchantActions.GinzoReview(_, p)
	local total = 0

	if typeof(p.SellSelection) == "table" then
		for _, v in p.SellSelection do
			total += v
		end
	end

	if total < 1 then
		return "Ginzo_Nothing"
	end

	return "Ginzo_Confirm"
end

function MerchantActions.GinzoSell(_, p)
	if flag then
		return "Ginzo_Confirm"
	end

	local total = 0

	if typeof(p.SellSelection) == "table" then
		for _, v in p.SellSelection do
			total += v
		end
	end

	if total < 1 then
		return "Ginzo_Nothing"
	end

	flag = true
	local v

	if PopUpCreator ~= nil then
		v = PopUpCreator.new({
			Type = "LoadingFull"
		}) or nil
	end

	local server = SignalFunction.ToServer("SellItems", p.SellSelection)

	if v ~= nil then
		v:Destroy()
	end

	flag = false
	p.SellSelection = nil

	if typeof(server) ~= "table" or next(server) == nil then
		playSound("denied_old")
		return "Ginzo_NoSale"
	end

	p.SoldFor = server
	playSound("Money_Kaching")
	return "Ginzo_Sold"
end

return MerchantActions