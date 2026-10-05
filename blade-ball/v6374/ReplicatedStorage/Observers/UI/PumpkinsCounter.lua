local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Policy = require(game.ReplicatedStorage.Shared.Policy)
local Replion = require(ReplicatedStorage.Packages.Replion)
local module = require("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local name = module.SeasonData.Currency.Name
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("UI_PumpkinsCounter", function(instance)
	local maid = Utils.Maid.new()
	local v = Replion.Client:WaitReplion("Data")
	local add = instance:FindFirstChild("Add")
	local amount = instance:WaitForChild("Amount")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		amount.Text = tostring(v:Get(name) or 0)
	end

	update() -- equivalent call inferred; original call site unknown
	maid.ReplionChange = v:OnChange(name, update)

	if add then
		add.Visible = false
		maid.buyActivated = add.Activated:Connect(function()
			local _ = Policy:GetPolicyInfo().ArePaidRandomItemsRestricted
		end)
		add:AddTag("UI_ButtonHoverAnimation2")
	end

	return function()
		maid:Destroy()
	end
end)