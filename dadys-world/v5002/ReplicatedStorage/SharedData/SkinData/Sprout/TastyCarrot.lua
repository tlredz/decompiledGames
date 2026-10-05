local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TastyCarrot = {}
TastyCarrot.Name = "Tasty Carrot"
TastyCarrot.TowerName = "Sprout"
TastyCarrot.Description = "No description yet"
TastyCarrot.Mastery = false
TastyCarrot.Cost = 600
TastyCarrot.Unlocks = require(ReplicatedStorage2.SharedData.ReleaseTimes).Easter2026_W2
TastyCarrot.Easter = true
TastyCarrot.HolidaySkin = true
TastyCarrot.RightHandBone = "R_hand"
TastyCarrot.OverwriteAnimations = {
	Run = "rbxassetid://105417185988959",
	Walk = "rbxassetid://134394210693462",
	Idle = "rbxassetid://79306898969576",
	Quirk = "rbxassetid://113317570655112",
	Ability = "rbxassetid://94917137297989",
	Decode = "rbxassetid://74093932068149"
}
TastyCarrot.FaceTextures = {
	Normal = "rbxassetid://112708958100267",
	Blink = "rbxassetid://94879507495429",
	Hurt = "rbxassetid://97798841535993"
}
TastyCarrot.USE_SKIN_MODEL = true

function TastyCarrot.ApplySkin(_) end

function TastyCarrot.UseAbility(_, _, p, p2)
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

return TastyCarrot