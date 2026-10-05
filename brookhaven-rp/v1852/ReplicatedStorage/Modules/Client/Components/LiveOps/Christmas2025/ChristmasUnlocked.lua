local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = nil
local v2 = Component.new({
	Tag = "ChristmasUnlocked"
})
local v3 = nil
local image = nil

function v2.SetData(_, p: string, p2: string)
	v3 = p
	image = p2
end

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2.Start(p)
	local contentBox = p.Instance:WaitForChild("OuterBox"):WaitForChild("ContentBox")
	local text = contentBox:WaitForChild("Text")
	local imageLabel = contentBox:WaitForChild("ItemPaddingBox"):WaitForChild("Item"):WaitForChild("ImageLabel")
	local v5 = v.WaitForPanel("MainGUIHandler", "ChristmasUnlocked")

	local function fn(_)
		if v3 == nil or image == nil then
			v5:Close()
			return
		end

		Players.LocalPlayer.PlayerGui.PurchaseSFX:Play()
		text.Text = v3 .. " unlocked!"
		imageLabel.Image = image
	end

	v5:RegisterListener(p, v5.Events.Opening, fn)

	if v5:IsOpen() then
		if v3 == nil or image == nil then
			v5:Close()
		else
			Players.LocalPlayer.PlayerGui.PurchaseSFX:Play()
			text.Text = v3 .. " unlocked!"
			imageLabel.Image = image
		end
	end

	v5:RegisterListener(p, v5.Events.Closing, function(_)
		image = nil
		v3 = nil
		imageLabel.Image = ""
		text.Text = ""
	end)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2