local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local ProfileFlags = require(ReplicatedStorage.Modules.Shared.PlayerData.ProfileFlags)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local children = script.Parent:FindFirstChild("Configs"):GetChildren()
local modulesByName = {}
local BrookhavenIntegrationTest = {}

for _, moduleScript in children do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

function BrookhavenIntegrationTest.GetConfig(p: string)
	return assert(modulesByName[p], "unknown config: " .. p)
end

function BrookhavenIntegrationTest.ReconcileProfile(data, p)
	if data.Gamepasses ~= nil then
		for _, gamepass in data.Gamepasses do
			p.__globalReplicated.gamepasses[tostring(Gamepasses.GetId(gamepass))] = 1
		end
	end

	if data.DevProducts ~= nil then
		for _, devProduct in data.DevProducts do
			p.__globalReplicated.devProducts[tostring(DevProducts.GetId(devProduct))] = 1
		end
	end

	p.__replicated.flags[ProfileFlags.GetKey(ProfileFlags.FACES_UNLOCKED_COMPENSATION_03102026)] = true
	return TableUtil.Reconcile(data.PlayerProfileData or {}, p)
end

return BrookhavenIntegrationTest