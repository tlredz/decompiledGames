local v = {
	Atmosphere = { "Color", "Decay" },
	CanvasGroup = { "GroupColor" },
	DataModelMesh = { "VertexColor" },
	DraggerService = { "GeometrySnapColor" },
	HumanoidDescription = {
		"HeadColor",
		"LeftArmColor",
		"LeftLegColor",
		"RightArmColor",
		"RightLegColor",
		"TorsoColor"
	},
	BasePart = { "Color" },
	CornerWedgePart = { "Color" },
	TriangleMeshPart = { "Color" },
	TrussPart = { "Color" },
	VehicleSeat = { "Color" },
	MeshPart = { "Color" },
	PartOperation = { "Color" },
	Part = { "Color" },
	WedgePart = { "Color" },
	Platform = { "Color" },
	Seat = { "Color" },
	SpawnLocation = { "Color" },
	Beam = { "Color" },
	Light = { "Color" },
	PointLight = { "Color" },
	SpotLight = { "Color" },
	SurfaceLight = { "Color" },
	BillboardGui = {},
	BodyColors = {
		"HeadColor",
		"HeadColor3",
		"LeftArmColor",
		"LeftArmColor3",
		"LeftLegColor",
		"LeftLegColor3",
		"RightArmColor",
		"RightArmColor3",
		"RightLegColor",
		"RightLegColor3",
		"TorsoColor",
		"TorsoColor3"
	},
	BrickColorValue = { "Value" },
	Clothing = { "Color3" },
	Clouds = { "Color" },
	Color3Value = { "Value" },
	ColorCorrectionEffect = { "TintColor" },
	Constraint = { "Color" },
	Decal = { "Color3" },
	Fire = { "Color", "SecondaryColor" },
	Flag = { "TeamColor" },
	FlagStand = { "TeamColor" },
	GuiBase3d = { "Color3" },
	GuiObject = { "BackgroundColor3", "BorderColor3" },
	Highlight = { "FillColor", "OutlineColor" },
	Humanoid = { "HealthDisplayColor" },
	ImageButton = { "ImageColor3", "BackgroundColor3" },
	ImageLabel = { "ImageColor3", "BackgroundColor3" },
	Lighting = {
		"Ambient",
		"ColorShift_Bottom",
		"ColorShift_Top",
		"FogColor",
		"OutdoorAmbient"
	},
	ParticleEmitter = { "Color" },
	ScrollingFrame = { "ScrollBarImageColor3", "BackgroundColor3" },
	SelectionBox = { "SurfaceColor3" },
	SelectionSphere = { "SurfaceColor3" },
	ShirtGraphic = { "Color3" },
	Skin = { "SkinColor" },
	Smoke = { "Color" },
	Sparkles = { "SparkleColor" },
	Team = { "TeamColor" },
	Terrain = { "MaterialColors", "WaterColor" },
	MaterialVariant = { "ColorMap" },
	TextBox = { "PlaceholderColor3", "TextColor3", "TextStrokeColor3" },
	TextButton = { "TextColor3", "TextStrokeColor3" },
	TextLabel = { "TextColor3", "TextStrokeColor3" },
	Texture = { "Color3" },
	Trail = { "Color" },
	UIGradient = { "Color" },
	UIStroke = { "Color" },
	ViewportFrame = {
		"Ambient",
		"ImageColor3",
		"LightColor",
		"BackgroundColor3"
	},
	SpecialMesh = { "VertexColor" },
	FileMesh = { "VertexColor" },
	SurfaceAppearance = { "Color", "EmissiveTint" }
}
local v2 = {}

local function getColorPropertiesFor(instance)
	if v[instance.ClassName] == nil then
		return v2
	end

	return v[instance.ClassName]
end

return getColorPropertiesFor