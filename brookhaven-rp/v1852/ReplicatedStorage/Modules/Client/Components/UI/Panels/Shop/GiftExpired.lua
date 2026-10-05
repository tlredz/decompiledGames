local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Promise = require(ReplicatedStorage.Packages.Promise)
local v = nil
local v2 = Component.new({
	Tag = "GiftExpired"
})
local v3 = nil

function v2.SetGiftData(_, p: number)
	v3 = p
end

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2.Start(p)
	local imageLabel = p.Instance:WaitForChild("OuterBox"):WaitForChild("Gift"):WaitForChild("ImageLabel")
	local v4 = v.WaitForPanel("MainGUIHandler", "GiftExpired")
	local v5 = Janitor.new()

	local function fn(_)
		if not v3 then
			v4:Close()
			return
		end

		imageLabel.Image = ""
		v5:AddPromise(Promise.new(function(callback, callback2, _)
			local v6, v7 = GetProductInfo(v3, Enum.InfoType.Product, 0)

			if v6 then
				callback(v7)
			else
				callback2()
			end
		end)):timeout(5):andThen(function(p2)
			imageLabel.Image = "rbxassetid://" .. tostring(p2.IconImageAssetId)
		end, function()
			imageLabel.Image = ""
		end)
	end

	v4:RegisterListener(p, v4.Events.Opening, fn)

	if v4:IsOpen() then
		fn()
	end

	v4:RegisterListener(p, v4.Events.Closing, function(_)
		v3 = nil
		imageLabel.Image = ""
		v5:Cleanup()
	end)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2