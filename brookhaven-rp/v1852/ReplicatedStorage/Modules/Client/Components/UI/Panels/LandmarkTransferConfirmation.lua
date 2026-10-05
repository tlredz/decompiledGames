local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local v = Component.new({
	Tag = "LandmarkTransferConfirmation"
})
local localPlayer = Players.LocalPlayer
local v2 = false
local v3 = nil

function v.IsHiddenForSession()
	return v2
end

function v.SetPending(requester, propertyId: string, displayName: string)
	v3 = {
		requester = requester,
		propertyId = propertyId,
		displayName = displayName
	}
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local v4 = PanelController.WaitForPanel("MainGUIHandler", "LandmarkTransferConfirmation")
	self._hideCheckbox = self.Instance.HideInvites.Box

	-- equivalent calls inferred from this helper; original call sites unknown
	local function respond(flag: boolean)
		local v5 = v3
		v3 = nil
		PanelController.Close("MainGUIHandler", "LandmarkTransferConfirmation")

		if v5 then
			Remotes.fireServer("Lot:RespondLandmarkSwap", v5.requester, v5.propertyId, flag)
		end
	end

	self._Janitor:Add(self.Instance.No.MouseButton1Click:Connect(function()
		respond(false) -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self.Instance.Yes.MouseButton1Click:Connect(function()
		respond(true) -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self._hideCheckbox.MouseButton1Click:Connect(function()
		local visible = not self._hideCheckbox.GreenCheckMark.Visible
		self._hideCheckbox.GreenCheckMark.Visible = visible
		v2 = visible
	end))

	local function openFunc()
		if not v3 then
			v4:Close()
			return
		end

		local playerBagInstance = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber")
		local v5

		if playerBagInstance and playerBagInstance.Value ~= 0 then
			v5 = LotUtil.GetPropertyRoot(playerBagInstance.Value)
		end

		local v6

		if v5 then
			v6 = v5:GetDisplayName()
		end

		if v6 == v3.displayName then
			self.Instance.Message.Text = `{v3.requester.Name} wants to take ownership of your {v3.displayName}!`
		else
			self.Instance.Message.Text = `{v3.requester.Name} wants to take ownership of your plot and spawn {v3.displayName}!`
		end
	end

	v4:RegisterListener(self, v4.Events.Opening, openFunc)

	if v4:IsOpen() then
		openFunc()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v