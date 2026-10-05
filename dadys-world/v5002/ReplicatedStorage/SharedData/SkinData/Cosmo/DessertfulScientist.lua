local DessertfulScientist = {}
DessertfulScientist.Name = "Dessertful Scientist"
DessertfulScientist.TowerName = "Cosmo"
DessertfulScientist.Description = "No description yet"
DessertfulScientist.Mastery = false
DessertfulScientist.Cost = 1200
DessertfulScientist.Requirement1 = { "Pumpkins", 1200 }
DessertfulScientist.Requirement2 = { "Coin", 1200 }
DessertfulScientist.Halloween = true
DessertfulScientist.HolidaySkin = true
DessertfulScientist.HolidayYear = 2025
DessertfulScientist.OverwriteAnimations = {
	Walk = "rbxassetid://71214108763301",
	Idle = "rbxassetid://118748655937261",
	Ability = "rbxassetid://116257730252534",
	Run = "rbxassetid://132855314567221",
	Quirk = "rbxassetid://102867336831639",
	Decode = "rbxassetid://110248569804268"
}
DessertfulScientist.FaceTextures = {
	Normal = "rbxassetid://134448086348191",
	Blink = "rbxassetid://80396267384288",
	Hurt = "rbxassetid://119686772105743"
}
DessertfulScientist.USE_SKIN_MODEL = true
DessertfulScientist.RightHandBone = "head.x"
DessertfulScientist.LatchedBoneOffset = CFrame.new(1.85, 1.85, 0) * CFrame.Angles(1.5707963267948966, 0, 0)

function DessertfulScientist.ApplySkin(_) end

function DessertfulScientist.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position
	local smokePart = clone:WaitForChild("SmokePart", 0.5)

	if smokePart then
		smokePart.Enabled = true
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

return DessertfulScientist