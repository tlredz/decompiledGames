local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Party = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Party.Party)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local v = nil
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v2 = nil
local v3 = Component.new({
	Tag = "PartyInvited"
})
local v4 = nil
local senderID = nil
local lot = nil
local houseID = nil
local partyID = nil
local v9 = nil

function v3.SetData(p: string, p2: number, p3: number, p4: string, p5: string, p6: string)
	v4 = p
	senderID = p2
	lot = p3
	v9 = nil

	for _, v10 in Party.All do
		if v10.Id == p4 then
			v9 = v10
		end
	end

	houseID = p5
	partyID = p6
end

function v3:Construct()
	self._Janitor = Janitor.new()
	local PartyController = require(ReplicatedStorage.Modules.Client.Party.PartyController)
	v = PartyController
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v2 = PanelController
end

function v3:Start()
	local outerBox = self.Instance:WaitForChild("OuterBox")
	local v10 = v2.WaitForPanel("MainGUIHandler", "PartyInvited")
	local box = outerBox:WaitForChild("HideInvites"):WaitForChild("Box")
	local frame = outerBox:WaitForChild("Items"):WaitForChild("Frame")
	local teleport = frame:WaitForChild("Teleport")
	local decline = frame:WaitForChild("Decline")
	self._Janitor:Add(box.Activated:Connect(function()
		v.HideInvites = not v.HideInvites

		if v.HideInvites then
			box:AddTag("Checked")
		else
			box:RemoveTag("Checked")
		end
	end))
	self._Janitor:Add(teleport.Activated:Connect(function()
		local v11, v12 = Remotes.invokeServer("PartyAcceptedInvite", senderID)

		if v11 then
			v2.Close("MainGUIHandler", "PartyInvited")
			TelemetryController.SendClientInteraction("partyInviteAnswer", {
				partyType = v9.Id,
				houseID = houseID,
				lot = lot,
				partyID = partyID,
				senderID = senderID,
				answer = "Teleport",
				hideInvites = v.HideInvites
			})
		end

		if v12 ~= nil then
			NotificationController.Notify(v12)
		end
	end))
	self._Janitor:Add(decline.Activated:Connect(function()
		v2.Close("MainGUIHandler", "PartyInvited")
		TelemetryController.SendClientInteraction("partyInviteAnswer", {
			partyType = v9.Id,
			houseID = houseID,
			lot = lot,
			partyID = partyID,
			senderID = senderID,
			answer = "Decline",
			hideInvites = v.HideInvites
		})
	end))

	local function fn(_)
		if #v2.GetOpenPanelsByGroup("FamilyInviteBlocking") > 0 then
			v10:Close()
			return
		end

		if v4 == nil or lot == nil or v9 == nil or senderID == nil then
			v10:Close()
			return
		end

		if v.HideInvites then
			box:AddTag("Checked")
		else
			box:RemoveTag("Checked")
		end

		local label = frame:WaitForChild("Label")
		label.Text = `{v4} has invited you to their {v9.Name}!`
	end

	v10:RegisterListener(self, v10.Events.Opening, fn)

	if v10:IsOpen() then
		fn()
	end

	self._Janitor:Add(v2.OnPanelOpened:Connect(function(_, p2)
		if p2 == self.Instance.Name then
			return
		end

		if #v2.GetOpenPanelsByGroup("FamilyInviteBlocking") > 0 and v2.IsOpen("MainGUIHandler", "PartyInvited") then
			v2.Close("MainGUIHandler", "PartyInvited")
		end
	end))
end

function v3:Stop()
	self._Janitor:Destroy()
end

return v3