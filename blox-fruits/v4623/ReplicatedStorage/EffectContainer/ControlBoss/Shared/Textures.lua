local Textures = {
	Aura = {
		"rbxassetid://98603377270574",
		"rbxassetid://134156024713430",
		"rbxassetid://100683529741640",
		"rbxassetid://128445746851596",
		"rbxassetid://128637930161405",
		"rbxassetid://78216277466814",
		"rbxassetid://100259853805735",
		"rbxassetid://119088828864788",
		"rbxassetid://123818662089392",
		"rbxassetid://119097453747893",
		"rbxassetid://82675821499836",
		"rbxassetid://72796410805233",
		"rbxassetid://106540627318166",
		"rbxassetid://109672212102506",
		"rbxassetid://89780758039695",
		"rbxassetid://77886277664271"
	},
	BeamsTextures = {
		"rbxassetid://97338094677203",
		"rbxassetid://124301655655675",
		"rbxassetid://73159539248951",
		"rbxassetid://84646719966635",
		"rbxassetid://137950740680433",
		"rbxassetid://77663945032119",
		"rbxassetid://84646719966635"
	},
	Important = { "rbxassetid://90005570945359", "rbxassetid://121437454930013" },
	HexTrailBeam = {
		"rbxassetid://120417510386592",
		"rbxassetid://106461438709876",
		"rbxassetid://130407155018078",
		"rbxassetid://97688208282859",
		"rbxassetid://103901493719690",
		"rbxassetid://116203210865345",
		"rbxassetid://84320172776059",
		"rbxassetid://90955793702341",
		"rbxassetid://112948360842069",
		"rbxassetid://73490124092811",
		"rbxassetid://116637664669294",
		"rbxassetid://73865665563069",
		"rbxassetid://99008809536907",
		"rbxassetid://133599882695763",
		"rbxassetid://75478549984290",
		"rbxassetid://116860870561795"
	},
	WindBeam = {
		"rbxassetid://127453101828399",
		"rbxassetid://81281526607188",
		"rbxassetid://76241150337683",
		"rbxassetid://70927224798086",
		"rbxassetid://129303818690715",
		"rbxassetid://116949404950640",
		"rbxassetid://116669815659801",
		"rbxassetid://89942388708697",
		"rbxassetid://89032023728927",
		"rbxassetid://115448402401268",
		"rbxassetid://108563817743033",
		"rbxassetid://78354380944489",
		"rbxassetid://135322305957054",
		"rbxassetid://134596093671946",
		"rbxassetid://73769096945810",
		"rbxassetid://122712610002420",
		"rbxassetid://124917710688450"
	}
}
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	return Textures
end

local part = Instance.new("Part")
part.Position = vector.create(0, 10000000, 0)
part.Anchored = true
part.Parent = workspace.Camera

for _, v in Textures do
	for _, texture in v do
		local decal = Instance.new("Decal", part)
		decal.Texture = texture
	end
end

local ContentProvider = game:GetService("ContentProvider")
ContentProvider:PreloadAsync(part:GetChildren())
return Textures