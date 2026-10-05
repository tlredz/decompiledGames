local Sync = {
	Item = require(script:WaitForChild("Item"))
}
Sync.Weapons = Sync.Item
Sync.Pets = require(script:WaitForChild("Pets"))
Sync.Effects = require(script:WaitForChild("Effects"))
Sync.Emotes = require(script:WaitForChild("Emotes"))
Sync.Perks = require(script:WaitForChild("Perks"))
Sync.Radios = require(script:WaitForChild("Radios"))
Sync.Materials = require(script:WaitForChild("Materials"))
Sync.Toys = require(script:WaitForChild("Toys"))
Sync.Rarity = require(script:WaitForChild("Rarity"))
Sync.Rarities = require(script:WaitForChild("Rarities"))
Sync.ItemPacks = require(script:WaitForChild("ItemPacks"))
Sync.Shop = require(script:WaitForChild("Shop"))
Sync.MysteryBox = require(script:WaitForChild("MysteryBox"))
Sync.Eggs = require(script:WaitForChild("Eggs"))
Sync.EliteRewards = require(script:WaitForChild("EliteRewards"))
Sync.Featured = require(script:WaitForChild("Featured"))
Sync.XboxFeatured = require(script:WaitForChild("XboxFeatured"))
Sync.Recipes = require(script:WaitForChild("Recipes"))
Sync.SalvageRewards = require(script:WaitForChild("SalvageRewards"))
Sync.DevProducts = require(script:WaitForChild("DevProducts"))
Sync.Badge = require(script:WaitForChild("Badge"))
Sync.Codes = require(script:WaitForChild("Codes"))
Sync.Currencies = require(script:WaitForChild("Currencies"))
Sync.NameTags = require(script:WaitForChild("NameTags"))
Sync.SlotInfo = require(script:WaitForChild("SlotInfo"))
Sync.GameModes = require(script:WaitForChild("GameModes"))
Sync.NewShop = require(script:WaitForChild("NewShop"))

for _, child in script:GetChildren() do
	if not Sync[child.Name] then
		warn("Sync data type not registered:" .. child.Name)
	end
end

Sync.OnDataChanged = Instance.new("BindableEvent")
return Sync