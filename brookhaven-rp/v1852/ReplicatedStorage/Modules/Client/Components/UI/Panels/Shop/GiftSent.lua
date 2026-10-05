local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AddFriendButton = require(ReplicatedStorage.Modules.Client.Components.UI.AddFriendButton)
local v = nil
local v2 = Component.new({
	Tag = "GiftSent"
})
local v3 = nil
local v4 = nil
local v5 = nil

function v2.SetGiftData(_, p: number, p2: string, flag: boolean)
	v3 = p
	v4 = p2
	v5 = flag
end

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2.Start(p)
	local imageLabel = p.Instance:WaitForChild("OuterBox"):WaitForChild("Avatar"):WaitForChild("ImageLabel")
	local contentBox = p.Instance:WaitForChild("OuterBox"):WaitForChild("ContentBox")
	local addFriendButton = contentBox:WaitForChild("Buttons"):WaitForChild("AddFriendButton")
	local giftingTitle = contentBox:WaitForChild("GiftingTitle")
	local v6 = v.WaitForPanel("MainGUIHandler", "GiftSent")

	local function fn(_)
		if not v3 or v4 == nil or v5 == nil then
			v6:Close()
			return
		end

		Players.LocalPlayer.PlayerGui.PurchaseSFX:Play()

		if v5 then
			addFriendButton.Visible = false
			AddFriendButton:FromInstance(addFriendButton):SetTargetPlayerId(nil)
		else
			addFriendButton.Visible = true
			AddFriendButton:FromInstance(addFriendButton):SetTargetPlayerId(v3)
		end

		giftingTitle.Text = "<font weight=\"SemiBold\" color=\"#0030FF\">" .. v4 .. "</font> has received your gift!"
		imageLabel.Image = ""
		local headShot = Enum.ThumbnailType.HeadShot
		local size60x60 = Enum.ThumbnailSize.Size60x60
		local userThumbnailAsync, v7 = Players:GetUserThumbnailAsync(v3, headShot, size60x60)

		if v7 then
			imageLabel.Image = userThumbnailAsync
		else
			imageLabel.Image = ""
		end
	end

	v6:RegisterListener(p, v6.Events.Opening, fn)

	if v6:IsOpen() then
		fn()
	end

	v6:RegisterListener(p, v6.Events.Closing, function(_)
		v3 = nil
		v4 = nil
		v5 = nil
		addFriendButton.Visible = true
		imageLabel.Image = ""
	end)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2