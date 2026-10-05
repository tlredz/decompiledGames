local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BerryBeast = {}
BerryBeast.Name = "Berry Beast"
BerryBeast.TowerName = "Sprout"
BerryBeast.Description = "No description yet"
BerryBeast.Mastery = false
BerryBeast.Cost = 1200
BerryBeast.Requirement1 = { "Pumpkins", 1200 }
BerryBeast.Requirement2 = { "Coin", 1200 }
BerryBeast.Halloween = true
BerryBeast.HolidaySkin = true
BerryBeast.HolidayYear = 2025
BerryBeast.RightHandBone = "R_hand"
BerryBeast.OverwriteAnimations = {
	Run = "rbxassetid://140110233557034",
	Walk = "rbxassetid://117215076877386",
	Idle = "rbxassetid://97593483677962",
	Quirk = "rbxassetid://140688331739248",
	Ability = "rbxassetid://109638736632869",
	Decode = "rbxassetid://82369340687344"
}
BerryBeast.FaceTextures = {
	Normal = "rbxassetid://78402540625790",
	Hurt = "rbxassetid://115055815651949",
	Blink = "rbxassetid://95674360488410"
}
BerryBeast.USE_SKIN_MODEL = true

function BerryBeast.ApplySkin(_) end

function BerryBeast.UseAbility(_, _, p, p2)
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
	end

	local function chase()
		local position = clone.Position
		Movement.parabola(clone, position, p2, 20, 25, 0.5)
	end

	local position = clone.Position
	Movement.parabola(clone, position, p2, 20, 25, 0.5)

	if clone then
		clone.SmokePart.Enabled = false
		clone.Transparency = 1
		clone.HeartPart:Emit(10)

		if clone:FindFirstChild("Eat") then
			clone.Eat:Play()
		end
	end
end

return BerryBeast