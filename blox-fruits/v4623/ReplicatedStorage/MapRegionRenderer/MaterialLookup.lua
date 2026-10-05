local materialLookup = {
	Plastic = Enum.Material.Plastic,
	SmoothPlastic = Enum.Material.SmoothPlastic,
	Neon = Enum.Material.Neon,
	Wood = Enum.Material.Wood,
	WoodPlanks = Enum.Material.WoodPlanks,
	Marble = Enum.Material.Marble,
	Basalt = Enum.Material.Basalt,
	Slate = Enum.Material.Slate,
	CrackedLava = Enum.Material.CrackedLava,
	Concrete = Enum.Material.Concrete,
	Limestone = Enum.Material.Limestone,
	Granite = Enum.Material.Granite,
	Pavement = Enum.Material.Pavement,
	Brick = Enum.Material.Brick,
	Pebble = Enum.Material.Pebble,
	Cobblestone = Enum.Material.Cobblestone,
	Rock = Enum.Material.Rock,
	Sandstone = Enum.Material.Sandstone,
	CorrodedMetal = Enum.Material.CorrodedMetal,
	DiamondPlate = Enum.Material.DiamondPlate,
	Foil = Enum.Material.Foil,
	Metal = Enum.Material.Metal,
	Grass = Enum.Material.Grass,
	LeafyGrass = Enum.Material.LeafyGrass,
	Sand = Enum.Material.Sand,
	Fabric = Enum.Material.Fabric,
	Snow = Enum.Material.Snow,
	Mud = Enum.Material.Mud,
	Ground = Enum.Material.Ground,
	Asphalt = Enum.Material.Asphalt,
	Salt = Enum.Material.Salt,
	Ice = Enum.Material.Ice,
	Glacier = Enum.Material.Glacier,
	Glass = Enum.Material.Glass,
	ForceField = Enum.Material.ForceField,
	Air = Enum.Material.Air,
	Water = Enum.Material.Water,
	Cardboard = Enum.Material.Cardboard,
	Carpet = Enum.Material.Carpet,
	CeramicTiles = Enum.Material.CeramicTiles,
	ClayRoofTiles = Enum.Material.ClayRoofTiles,
	RoofShingles = Enum.Material.RoofShingles,
	Leather = Enum.Material.Leather,
	Plaster = Enum.Material.Plaster,
	Rubber = Enum.Material.Rubber
}
local nameLookup = {}

for k, v3 in materialLookup do
	nameLookup[v3] = k
end

return {
	MaterialLookup = materialLookup,
	NameLookup = nameLookup
}