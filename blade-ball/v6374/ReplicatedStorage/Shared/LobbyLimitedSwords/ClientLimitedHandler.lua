local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Players")
game:GetService("RunService")
require3(ReplicatedStorage2.Shared.UseNewLobby)
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Shared.LimitedSwordEvent)
local limitedSwordsStands = ReplicatedStorage2.Misc.LimitedSwordsStands
local v4 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v5 = require3(ReplicatedStorage2.Controllers.UI.NewShowcaseController)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Controllers.AnalyticsController)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
workspace:GetAttribute("IS_TESTING_PLACE")
return function(instance)
	workspace:WaitForChild("Spawn", 1000000)
	local v6 = v.Client:WaitReplion("Data")

	for k, event in v3.Events do
		local v7 = k
		local v8 = event
		task.spawn(function()
			if not (v7 == "SwordPacks" and (instance:WaitForChild(v7, 5) or limitedSwordsStands:WaitForChild(v7, 5))) then
				return
			end

			local children = {}

			for k2, v9 in { instance, limitedSwordsStands } do
				for i, child in v9:GetChildren() do
					if child.Name == v7 then
						table.insert(children, child)
					end
				end
			end

			local v9 = v2.new()

			for k2, v10 in children do
				local maid = v9:Extend()
				local swordName = v8.Swords.Single.SwordName
				local swordName2 = swordName

				if v8.Swords.Dual then
					swordName2 = v8.Swords.Dual.SwordName
				elseif v8.Swords.Better then
					swordName2 = v8.Swords.Better.SwordName
				end

				local stand = v10:WaitForChild("Stand")
				local proximityPrompt = stand:WaitForChild("Purchase"):WaitForChild("ProximityPrompt")
				local textPart = stand:WaitForChild("TextPart")
				maid:Add(proximityPrompt.Triggered:Connect(function()
					local windowName = "LimitedSword_SwordPacks"

					if windowName == v5.LegacyWindowName then
						windowName = v5:GetWindowName()
					end

					v4:Open(windowName, "SwordPacks", true)
				end))

				-- equivalent calls inferred from this helper; original call sites unknown
				local function updateOwnsLimited()
					local v14 = #client:FindItems("Sword", swordName2) > 0

					if v8.HideGiftButton then
						v14 = false
					end

					proximityPrompt.ObjectText = v8.PromptText or `{v14 and "Gift" or "Buy"} {swordName}`
					textPart.SurfaceGui.TextFrame.Common.Text = v14 and "GIFT" or "BUY"
				end

				updateOwnsLimited() -- equivalent call inferred; original call site unknown
				maid:Add(v6:OnChange("SwordSkins", updateOwnsLimited))
			end
		end)
	end
end