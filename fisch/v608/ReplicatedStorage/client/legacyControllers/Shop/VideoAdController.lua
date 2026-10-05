local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("@self/utility")
require("@self/debugEnum")
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local localPlayer = Players.LocalPlayer
local remoteFunction = Net:RemoteFunction("VideoAds/Play", -1)
local flag = false
local shop = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("shop")
local v = {}
local VideoAdController = {}

function VideoAdController:Add(instance, ancestorName: string, flag2: boolean?, callbackFn)
	local v2 = {}

	if flag then
		instance.Visible = flag2 or false
		v2._activationConnection = instance.Activated:Connect(function()
			instance.Active = false
			module.checkForAdsAsync(function(p)
				if p then
					remoteFunction:InvokeServer()
				else
					instance.Visible = false
				end
			end):await()
			task.wait(3)
			instance.Active = true
		end)

		if callbackFn then
			v2._callbackFn = callbackFn
		end

		local firstAncestor = instance:FindFirstAncestor(ancestorName)
		v2._ancestorVisibilityConnection = firstAncestor:GetPropertyChangedSignal("Visible"):Connect(function()
			if firstAncestor.Visible then
				module.checkForAdsAsync(function(p)
					instance.Visible = p or false
				end)
			end
		end)
		v[instance] = v2
	else
		warn("Ads are not allowed to be shown for this user.")
		instance.Visible = false
	end
end

function VideoAdController.Remove(_, p)
	local v2 = v[p]

	if v2 then
		if v2._activationConnection then
			v2._activationConnection:Disconnect()
		end

		if v2._ancestorVisibilityConnection then
			v2._ancestorVisibilityConnection:Disconnect()
		end
	end

	v[p] = nil
end

function VideoAdController:Start()
	local v2 = 0
	module.areImmersiveAdsAllowedAsync():andThen(function(p)
		if p then
			flag = true
			DataController.PlayerDataReplicator:Observe({ "VideoAds" }, function(p2)
				if not p2 then
					return
				end

				local remaining = module.getRemaining(p2)
				v2 = remaining

				for k, v3 in v do
					if v3._callbackFn then
						v3._callbackFn(k, remaining)
					end
				end
			end)
		end
	end):await()

	if not flag then
		return
	end

	self:Add(shop.Products.Views.Main.Featured.Template.VideoAd, "shop", true, function(p, p2)
		p.Text = module.toStandardStringFormat(p2)

		if p2 == 0 then
			p.Visible = false
		end
	end)
end

return VideoAdController