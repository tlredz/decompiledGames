local createVector = vector.create
local _ = game.ReplicatedStorage.ReplicatedAssets
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local import = _G.import("event")
local import2 = _G.import("global")
_G.import("sync")
local import3 = _G.import("romodel")
local import4 = _G.import("signalUtil")
local import5 = _G.import("developerProductCollection")
local itemBillboard = _G.import("viewImports"):get("itemBillboard").ItemBillboard
_G.import("itemModules")

local function displayChair(instance)
	local name = instance.Name
	local chairId = import5:get("p" .. name).ChairId
	local productInfo = MarketplaceService:GetProductInfo(name, Enum.InfoType.Product)
	local v = instance.PrimaryPart.CFrame * CFrame.Angles(0, 0.3490658503988659, 0.3490658503988659) + createVector(
		0,
		2.5,
		0
	)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.ActionText = "Buy"
	proximityPrompt.Triggered:Connect(function(player)
		if import2.get("playerSave", player):has("Inventory", "Chair", chairId) then
			import.fire("openMenu", "Inventory", {
				PageId = "Chair"
			})
		else
			MarketplaceService:PromptProductPurchase(player, name)
		end
	end)
	proximityPrompt.Parent = instance.Parent
	import3.mount(import3.make(itemBillboard, {
		Robux = true,
		Cost = productInfo.PriceInRobux,
		Height = 7,
		ItemId = chairId,
		Prompt = proximityPrompt
	}), instance.PrimaryPart)
	RunService.RenderStepped:Connect(function()
		instance:SetPrimaryPartCFrame(v + Vector3.new(0, math.sin((os.clock())) * 0.75, 0))
	end)
end

return {
	Priority = 1,
	Run = function()
		import.connect("dataLoaded", function()
			import4.onTag("RobuxChair", displayChair)
		end)
	end
}