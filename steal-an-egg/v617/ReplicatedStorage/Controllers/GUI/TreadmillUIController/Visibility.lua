local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Hud = require(ReplicatedStorage.Client.Hud)
local Player = require(ReplicatedStorage.Shared.Player)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Main = require(script.Parent.Parent.BackpackController.Main)
local topBar = GUI.OfflineMoneyInPlot().TopBar
local topBarStandard = GUI.TopBarStandard()
local backpack = GUI.Backpack()
local v = nil
local maid = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function IsBackpackVisibilityAllowed()
	return Main:GetBackpackEnabled() and not HiddenUIHandler.IsHidden()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UnequipTools()
	local humanoid = Player.FindHumanoid()

	if humanoid ~= nil then
		humanoid:UnequipTools()
	end
end

return {
	Apply = function(flag: boolean)
		if flag then
			if v == nil then
				v = {
					OfflineMoneyInPlotVisible = topBar.Visible,
					TopBarEnabled = topBarStandard.Enabled
				}
				local character = Player.FindCharacter()

				if character ~= nil then
					maid:Add(character.ChildAdded:Connect(function(tool)
						if tool:IsA("Tool") and not CollectionService:HasTag(tool, "PhoneTool") then
							UnequipTools() -- equivalent call inferred; original call site unknown
						end
					end))
				end
			end

			Main:SetTreadmillPhoneOnlyMode(true)
			Hud.SetTreadmillActive(true)
			topBar.Visible = false
			topBarStandard.Enabled = false
			UnequipTools() -- equivalent call inferred; original call site unknown
		else
			Hud.SetTreadmillActive(false)
			Main:SetTreadmillPhoneOnlyMode(false)
			local v2 = v

			if v2 == nil then
				maid:Clean()
				return
			end

			maid:Clean()
			topBarStandard.Enabled = v2.TopBarEnabled
			topBar.Visible = v2.OfflineMoneyInPlotVisible
			backpack.Enabled = IsBackpackVisibilityAllowed()
			v = nil
		end
	end
}