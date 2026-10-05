local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local modules = ReplicatedStorage.shared.modules
require(modules.SharedTerrapinExpansion)
local module = require("../LocalDataState")
local v = Component.new({
	Tag = "DeleteOnInitialAreaUnlock",
	Ancestors = { workspace }
})

function v:Construct()
	self.DataObserver = module:observe(function(p)
		if not p then
			return
		end

		if p.HasUnlockedInitialHiddenArea then
			self:OnCollected()
		end
	end, true)
end

function v:Stop()
	if self.DataObserver then
		self.DataObserver()
		self.DataObserver = nil
	end
end

function v:OnCollected()
	local v2 = CollectionService:GetTagged("InitialAreaPedestal")[1]

	if v2 then
		local success, result = pcall(function()
			TweenService:Create(v2.Root.Lever, TweenInfo.new(0.5), {
				C1 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, -0.6108652381980153)
			}):Play()
			v2.PrimaryPart.Toggle:Play()
			local instance = self.Instance
			local tween = TweenService:Create(instance, TweenInfo.new(2), {
				CFrame = instance.CFrame * CFrame.new(0, 20, 0)
			})
			tween.Completed:Once(function()
				instance:Destroy()
				instance.Rumbling:Stop()
			end)
			tween:Play()
			instance.Rumbling:Play()
		end)

		if not success then
			warn("Error playing initial area unlock animation: " .. result)
			self.Instance:Destroy()
		end
	else
		warn("No lever found for initial area unlock!")
		self.Instance:Destroy()
	end
end

return v