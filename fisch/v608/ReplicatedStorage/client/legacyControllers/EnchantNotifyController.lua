local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.modules.library.SharedEnchants)
local enchants = require(ReplicatedStorage.shared.modules.library.rods.enchants)
local EnchantNotifyController = {
	DefaultLibrary = enchants,
	Libraries = {
		rod = enchants,
		spear = require(ReplicatedStorage.shared.modules.library.spears.spearEnchants),
		harpoon = require(ReplicatedStorage.shared.modules.library.harpoonGuns.harpoonEnchants)
	}
}

function EnchantNotifyController.GetLibrary(value: string?)
	return EnchantNotifyController.Libraries[value or "rod"] or EnchantNotifyController.DefaultLibrary
end

function EnchantNotifyController.GetEnchantData(p: string?, p2: string?)
	local library = EnchantNotifyController.GetLibrary(p2)

	if p then
		return library.Enchants[p]
	end

	return nil
end

function EnchantNotifyController.Play(childName: string, p)
	local moduleScript = script:FindFirstChild(childName)

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		warn((`Unknown enchant anim type "{childName}"`))
		return
	end

	if typeof(p) ~= "table" then
		warn((`Enchant anim "{childName}" received no data`))
		return
	end

	local module = require(moduleScript)
	local library = EnchantNotifyController.GetLibrary(p.toolKind)
	local success, result = pcall(module.Play, p, library)

	if not success then
		warn((`Enchant anim "{childName}" failed: {result}`))
	end
end

function EnchantNotifyController.Start(_)
	Net:RemoteEvent("EnchantNotify", -1).OnClientEvent:Connect(EnchantNotifyController.Play)
end

return EnchantNotifyController