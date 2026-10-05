local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local remoteEvent = Net:RemoteEvent("SunhatStarfish/Arms")
local color = Color3.fromRGB(213, 107, 160)
local v = {}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheOriginal(p)
	if v2[p] then
		return
	end

	v2[p] = {
		Material = p.Material,
		Color = p.Color
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setArmLit(part, flag: boolean)
	if flag then
		cacheOriginal(part) -- equivalent call inferred; original call site unknown
		part.Material = Enum.Material.Neon
		part.Color = color
	else
		local v3 = v2[part]

		if v3 then
			part.Material = v3.Material
			part.Color = v3.Color
		end
	end
end

local function applyArms(p, p2: number)
	local activeCompanion = CompanionController.GetActiveCompanion(p)

	if not activeCompanion or activeCompanion.CompanionType ~= "Sunhat Starfish" then
		return
	end

	local model = activeCompanion.Model

	if not (model and model.Parent) then
		return
	end

	for i = 1, 5 do
		local part = model:FindFirstChild((`Arm{i}`))

		if not (part and part:IsA("BasePart")) then
			continue
		end

		setArmLit(part, i <= p2) -- equivalent call inferred; original call site unknown
	end
end

return {
	Start = function()
		remoteEvent.OnClientEvent:Connect(function(p, p2: number)
			v[p] = p2
			applyArms(p, p2)
		end)
		CompanionController.CompanionSpawned:Connect(function(p, p2: string)
			if p2 ~= "Sunhat Starfish" then
				return
			end

			applyArms(p, v[p] or 0)
		end)
		Players.PlayerRemoving:Connect(function(player)
			v[player] = nil
		end)
	end
}