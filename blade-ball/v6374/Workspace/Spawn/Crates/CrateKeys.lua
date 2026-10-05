local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage.Remotes
local v = {
	NormalExplosionCrate = "Explosion",
	PremiumExplosionCrate = "PremiumExplosion",
	NormalSwordCrate = "Sword",
	PremiumSwordCrate = "PremiumSword",
	HalloweenSwordCrate = "Sword"
}
local models = {}

for _, model in script.Parent:GetChildren() do
	local v2 = v[model.Name]

	if model:IsA("Model") and v2 then
		models[v2] = model
	end
end

local function updateCrateKeys(p)
	for k, v2 in models do
		local crateKeys = v2.PrimaryPart:FindFirstChild("CrateKeys")

		if not crateKeys then
			crateKeys = script.CrateKeys:Clone()
			crateKeys.Adornee = v2.PrimaryPart
			crateKeys.Parent = v2.PrimaryPart
		end

		local v3 = p[k] or 0

		if v3 <= 0 then
			crateKeys.Enabled = false
		else
			crateKeys.Enabled = true
			crateKeys.TextLabel.Text = `OPEN {v3} FREE!`
		end
	end
end

remotes.Store.UpdateCrateKeys.OnClientEvent:Connect(updateCrateKeys)