local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AddFriendButton = require(ReplicatedStorage.Modules.Client.Components.UI.AddFriendButton)
local Promise = require(ReplicatedStorage.Packages.Promise)
local v = nil
local v2 = Component.new({
	Tag = "GiftReceived"
})
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil

function v2.SetGiftData(_, p: number, p2: string, p3: number, flag: boolean, p4: string?)
	v3 = p
	v4 = p2
	v5 = p3
	v6 = flag
	v7 = p4
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
	local gamepassOuterBox = contentBox:WaitForChild("GamepassPaddingBox"):WaitForChild("GamepassOuterBox")
	local icon = gamepassOuterBox:WaitForChild("IconBox"):WaitForChild("Icon")
	local textLabel = gamepassOuterBox:WaitForChild("TextBox"):WaitForChild("TextLabel")
	local v8 = v.WaitForPanel("MainGUIHandler", "GiftReceived")
	local v9 = Janitor.new()

	local function fn(_)
		if not v3 or v4 == nil or not v5 or v6 == nil then
			v8:Close()
			return
		end

		if v6 then
			addFriendButton.Visible = false
			AddFriendButton:FromInstance(addFriendButton):SetTargetPlayerId(nil)
		else
			addFriendButton.Visible = true
			AddFriendButton:FromInstance(addFriendButton):SetTargetPlayerId(v3)
		end

		Players.LocalPlayer.PlayerGui.PurchaseSFX:Play()
		giftingTitle.Text = "<font weight=\"SemiBold\" color=\"#0030FF\">" .. v4 .. "</font> gifted you!"
		imageLabel.Image = ""
		v9:AddPromise(Promise.new(function(callback, callback2, _)
			local userThumbnailAsync, v10 = Players:GetUserThumbnailAsync(
				v3,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size60x60
			)

			if v10 then
				callback(userThumbnailAsync)
			else
				callback2()
			end
		end):timeout(3):andThen(function(image)
			imageLabel.Image = image
		end, function()
			imageLabel.Image = ""
		end))
		icon.Image = ""
		textLabel.Text = ""
		v9:AddPromise(Promise.try(function()
			return MarketplaceService:GetProductInfo(v5, Enum.InfoType.Product)
		end)):timeout(3):andThen(function(data)
			icon.Image = "rbxassetid://" .. tostring(data.IconImageAssetId)
			textLabel.Text = "<font weight=\"SemiBold\" size=\"16\">" .. (v7 or data.Name) .. "</font>\n" .. data.Description
		end, function()
			icon.Image = v7 or ""
			textLabel.Text = "Unable to load product description"
		end)
	end

	v8:RegisterListener(p, v8.Events.Opening, fn)

	if v8:IsOpen() then
		fn()
	end

	v8:RegisterListener(p, v8.Events.Closing, function(_)
		v3 = nil
		v4 = nil
		v5 = nil
		v6 = nil
		addFriendButton.Visible = true
		imageLabel.Image = ""
		icon.Image = ""
		textLabel.Text = ""
		v9:Cleanup()
	end)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2