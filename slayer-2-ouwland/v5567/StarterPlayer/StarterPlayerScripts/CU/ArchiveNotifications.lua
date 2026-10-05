local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local WorldBosses = require(ReplicatedStorage.CAM.Client.Modules.WorldBosses)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local centerNotification = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("CnC"):WaitForChild("Notifications"):WaitForChild("CenterNotification")
local regionIcon = BunchaIcons.RegionIcon

-- equivalent calls inferred from this helper; original call sites unknown
local function toast(name: string, icon: string?)
	centerNotification:Fire("NewItem", {
		Name = name,
		Icon = icon,
		Amount = 1,
		IsNew = true
	})
end

Archives.Connect("Bosses", function(list)
	if #list ~= 1 then
		return
	end

	local v = WorldBosses.ByCode(list[1])

	if v == nil then
		return
	end

	toast(v.Name, v.Icon) -- equivalent call inferred; original call site unknown
end)
Archives.Connect("Regions", function(list)
	if #list ~= 1 then
		return
	end

	toast(list[1], regionIcon) -- equivalent call inferred; original call site unknown
end)