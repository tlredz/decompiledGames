local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
require(script.Parent.Parent.Types)
return {
	DisplayName = "Codes",
	Permission = "cui.admin.codes",
	Order = 40,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Redeemable codes")
		end)
		object:AddText(function(object2)
			object2:SetAutoResize(true):SetText("Create, edit and revoke the codes players redeem in game.")
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Open codes panel"):SetYSize(22):SetButtonCallback(function()
				local CodesMenu = require(ReplicatedStorage.Cmdr.Menus.CodesMenu)
				CodesMenu.Open()
			end)
		end)
	end
}