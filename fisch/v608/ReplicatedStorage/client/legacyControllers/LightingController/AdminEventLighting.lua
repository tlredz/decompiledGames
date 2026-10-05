local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("../LightingController")
local module2 = require("../SettingsController")
local module3 = require("../DataController")
local playerDataReplicator = module3.PlayerDataReplicator
local Trove = require(ReplicatedStorage.packages.Trove)
return {
	ZoneTrove = Trove.new(),
	Start = function(_)
		playerDataReplicator:WaitForLoaded()
		task.wait(0.1)
		local admin_event = ReplicatedStorage:WaitForChild("world"):WaitForChild("admin_event")
		local lighting = ReplicatedStorage:WaitForChild("resources"):WaitForChild("adminEvents"):WaitForChild("lighting")

		local function applyZoneLighting(p)
			local child = admin_event:GetAttribute("ActiveLighting") and lighting:FindFirstChild(admin_event:GetAttribute("ActiveLighting"))

			if child == nil then
				return p
			end

			debug.profilebegin("AdminEventLighting")

			for className, v in p do
				debug.profilebegin(className)
				local firstChildOfClass = child:FindFirstChildOfClass(className)

				if firstChildOfClass then
					for k, _ in v do
						v[k] = firstChildOfClass[k]
					end
				end

				debug.profileend()
			end

			debug.profilebegin("clouds")
			local clouds = child:FindFirstChild("clouds")

			if clouds then
				for attributeName, _ in p.Clouds do
					local attribute = clouds:GetAttribute(attributeName)

					if attribute ~= nil then
						p.Clouds[attributeName] = attribute
					end
				end
			end

			debug.profileend()
			debug.profilebegin("lightingProperties")
			local lightingProperties = child:FindFirstChild("lightingProperties")

			if lightingProperties then
				for attributeName, _ in p.Lighting do
					local attribute = lightingProperties:GetAttribute(attributeName)

					if attribute ~= nil then
						p.Lighting[attributeName] = attribute
					end
				end
			end

			debug.profileend()
			debug.profileend()
			return p
		end

		module.HookLighting:BindAtPriority(5000, function(p)
			if admin_event:GetAttribute("ActiveLighting") and module2:GetSettingValue("adminEventVfx") then
				applyZoneLighting(p)
			end
		end)
		admin_event:GetAttributeChangedSignal("ActiveLighting"):Connect(function()
			module.UpdateLighting(1)
		end)
		module2:GetSettingChangedSignal("adminEventVfx"):Connect(function()
			if admin_event:GetAttribute("ActiveLighting") then
				module.UpdateLighting(0)
			end
		end)
	end
}