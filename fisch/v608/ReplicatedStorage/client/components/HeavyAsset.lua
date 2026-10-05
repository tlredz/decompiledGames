local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local v = Component.new({
	Tag = "HeavyAsset"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local function UpdatePerformance()
		if SettingsController:GetSettingValue("shownVfx") == "HideAll" then
			if not p.Instance:GetAttribute("DefaultTransparency") then
				p.Instance:SetAttribute("DefaultTransparency", p.Instance.Transparency)
			end

			if not p.Instance:GetAttribute("DefaultCollide") then
				p.Instance:SetAttribute("DefaultCollide", p.Instance.CanCollide)
			end

			p.Instance.Transparency = 1
			p.Instance.CanCollide = false
		else
			p.Instance.Transparency = p.Instance:GetAttribute("DefaultTransparency") or 0
			p.Instance.CanCollide = p.Instance:GetAttribute("DefaultCollide") or true
		end
	end

	UpdatePerformance()
	p.trove:Add(SettingsController:GetSettingChangedSignal("shownVfx"):Connect(UpdatePerformance))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v