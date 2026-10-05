game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("IgneousImpale")
local module = require("./PassiveHandler")
local IgneousRupturer = {
	Morph = function(_, p, object)
		object:Preload(script:GetChildren())
		task.spawn(function()
			local playerbar = p.playerbar
			local backgroundColor3 = playerbar.BackgroundColor3
			object.trove:Add(remoteEvent.OnClientEvent:Connect(function(p2)
				if p2 ~= object.base_seed then
					return
				end

				object:AddProgress(12)
				playerbar.BackgroundColor3 = Color3.fromRGB(255, 127, 41)
				GeneralUtils.fastTween(playerbar, TweenInfo.new(1.5), {
					BackgroundColor3 = backgroundColor3
				})
			end))
		end)
	end
}
setmetatable(IgneousRupturer, module)
return IgneousRupturer