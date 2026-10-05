local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local module = require("../../HudController")
local module2 = require("../../EmoteWheelController")
local Crews = require(ReplicatedStorage.client.modules.ui.Crews)
local level = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("level")
local v = {
	Settings = {
		Icon = "rbxassetid://87064530090778",
		Open = function()
			local safeZone = module:GetSafeZone()
			safeZone.menu2.Visible = true
		end
	},
	["Personal Aquarium"] = {
		Icon = "rbxassetid://74351406318503",
		IsUnlocked = function()
			return level.Value >= 25
		end,
		Open = function()
			local safeZone = module:GetSafeZone()
			safeZone.PersonalAquarium.Visible = true
		end
	},
	Inventory = {
		Icon = "rbxassetid://74401374766433",
		Open = function()
			local backpackGui = module:GetBackpackGui()
			backpackGui.inventory.Visible = true
		end
	},
	Shop = {
		Icon = "rbxassetid://73922482364412",
		Open = function()
			local safeZone = module:GetSafeZone()
			safeZone.shop.Visible = true
		end
	},
	["Admin Panel"] = {
		Icon = "rbxassetid://124168254725106",
		IsUnlocked = function()
			return module:GetPlayerGui():FindFirstChild("adminUI") ~= nil
		end,
		Open = function()
			if module:GetPlayerGui():FindFirstChild("adminUI") then
				local playerGui = module:GetPlayerGui()
				playerGui.adminUI.Visible = true
			else
				ReplicatedStorage.events.anno_localthought:Fire("You do not have access to the Admin Panel.")
			end
		end
	},
	["Server Browser"] = {
		Icon = "rbxassetid://108045940279299",
		IsUnlocked = function()
			return level.Value >= 25
		end,
		Open = function()
			if FischUtils.IsTradePlaza() then
				local safeZone = module:GetSafeZone()
				safeZone.serverbrowser.Visible = true
			else
				ReplicatedStorage.events.anno_localthought:Fire("You can only open the Server Browser in the Trade Plaza.")
			end
		end
	},
	["Emote Wheel"] = {
		Icon = "rbxassetid://120214273780107",
		Open = function()
			module2.OpenWheel()
		end
	},
	Crews = {
		Icon = "rbxassetid://96898346237041",
		IsUnlocked = function()
			local v2 = playerDataReplicator:TryIndex({ "Crews", "CrewId" })
			return v2 ~= nil and v2 ~= ""
		end,
		Open = function()
			Crews.openMenu()
		end
	}
}
local Menu = {}

function Menu.GetOptions()
	local result = {}

	for k, v2 in v do
		if not v2.IsUnlocked or v2.IsUnlocked() then
			table.insert(result, k)
		end
	end

	return result
end

function Menu.Select(p: string)
	local v2 = v[p]

	if v2 then
		v2.Open()
	end
end

function Menu.GetDisplay(p: string)
	local v2 = v[p]

	if v2 and v2.Icon and v2.Icon ~= "" then
		return "IconSmall", v2.Icon
	end

	return "Text", p
end

function Menu.GetDescription(p: string)
	return (`Open {p}`)
end

return Menu