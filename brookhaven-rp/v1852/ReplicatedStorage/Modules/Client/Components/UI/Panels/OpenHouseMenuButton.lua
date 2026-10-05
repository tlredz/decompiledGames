local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "OpenHouseMenuButton"
})
local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
local _1Gettin1gHous1e = nil

function v:Construct()
	self._Janitor = Janitor.new()
	_1Gettin1gHous1e = ReplicatedStorage.RE:WaitForChild("1Gettin1gHous1e")
end

function v.Start(p)
	local instance = p.Instance
	_1Gettin1gHous1e.OnClientEvent:Connect(function(p2: string, _: number, p3: string)
		if p2 == "HouseSold" then
			instance:SetAttribute("TargetPanel", "MainNoHouseMenu")
		elseif p2 == "BuyHouseSetUpUI" then
			instance:SetAttribute("TargetPanel", HouseUtil.GetHouseMenu(p3))
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v