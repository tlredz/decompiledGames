local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
require(ReplicatedStorage.shared.modules.library.companions)
require(ReplicatedStorage.shared.modules.library.companions.skins)
require(ReplicatedStorage.shared.utils.NumberUtils)
require(ReplicatedStorage.shared.utils.assets)
require(ReplicatedStorage.client.legacyControllers.SettingsController)
local _ = script.Parent.Parent.UI
require("../Types")
local Bundle = {}

function Bundle.GetBoothButton(_, _)
	return nil
end

function Bundle.LoadScene(object, p, _)
	object:SetInfo({})

	for _, contain in p.Contains do
		local module = require(script.Parent:FindFirstChild(contain.Type))

		if module then
			module.LoadScene(object, contain, true)
		else
			warn((`Unknown item type "{contain}"`))
		end
	end
end

return Bundle