local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SugaryShortcake = {}
SugaryShortcake.Name = "Sugary Shortcake"
SugaryShortcake.TowerName = "Sprout"
SugaryShortcake.Description = "No description yet"
SugaryShortcake.Mastery = false
SugaryShortcake.Cost = 600
SugaryShortcake.Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0)
SugaryShortcake.Christmas = true
SugaryShortcake.HolidaySkin = true
SugaryShortcake.RightHandBone = "R_hand"
SugaryShortcake.OverwriteAnimations = {
	Run = "rbxassetid://80476003059470",
	Walk = "rbxassetid://117215076877386",
	Idle = "rbxassetid://100239648917653",
	Quirk = "rbxassetid://106731711231326",
	Ability = "rbxassetid://129610259322398",
	Decode = "rbxassetid://89432307410880"
}
SugaryShortcake.FaceTextures = {
	Normal = "rbxassetid://98279358822191",
	Blink = "rbxassetid://92246762087033",
	Hurt = "rbxassetid://80768235246374"
}
SugaryShortcake.USE_SKIN_MODEL = true

function SugaryShortcake.ApplySkin(_) end

function SugaryShortcake.UseAbility(_, _, p, p2)
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

return SugaryShortcake