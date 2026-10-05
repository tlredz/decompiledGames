local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Points = {
		createVector(-679.3, 1243.2, -1011.4),
		createVector(-613, 1242.5, -944),
		createVector(-542, 1242.5, -980.9),
		createVector(-500.6, 1242.5, -969.1),
		createVector(-590.1, 1242.5, -1031.1),
		createVector(-627.1, 1242.5, -1098),
		createVector(-558, 1242.5, -1133),
		createVector(-531, 1243.2, -1186.5),
		createVector(-521, 1243.2, -1265),
		createVector(-588.7, 1243.2, -1353.3),
		createVector(-536, 1243.2, -1328.5),
		createVector(-444, 1241, -938),
		createVector(-707, 1243.2, -929),
		createVector(-746.8, 1257, -1214.2),
		createVector(-799, 1259.2, -1222),
		createVector(-790.5, 1259.4, -1165.6),
		createVector(-692, 1258.5, -1202.9),
		createVector(-751.1, 1258.5, -1130),
		createVector(-656.1, 1248.5, -1156.5),
		createVector(-693, 1258.5, -1074),
		createVector(-760, 1258.5, -1067)
	},
	Center = createVector(-687, 1260.5, -1103),
	Models = ReplicatedStorage.Assets.Npcs.Civilians:GetChildren(),
	DespawnDistance = 350,
	SpawnTime = 5
}