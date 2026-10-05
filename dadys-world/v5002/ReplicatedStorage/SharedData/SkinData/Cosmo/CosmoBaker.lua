local CosmoBaker = {
	Name = "Caramel Drizzle",
	Cost = 600,
	DandyStore = true,
	OverwriteAnimations = {
		Walk = "rbxassetid://95597558305842",
		Run = "rbxassetid://71584405037730",
		Quirk = "rbxassetid://71701359955259",
		Idle = "rbxassetid://97099524343316",
		Decode = "rbxassetid://119699386728294",
		Ability = "rbxassetid://98874686617515"
	},
	FaceTextures = {
		Normal = "rbxassetid://136495726694146",
		Blink = "rbxassetid://119982819240308",
		Hurt = "rbxassetid://77701163105153"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
game:GetService("TweenService")

function CosmoBaker.UseAbility(_, _, p, p2)
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(204, 153, 102)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(153, 102, 51)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 204, 153))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(204, 153, 102)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 229, 204))
		})
	end

	local _ = p2.Position

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

return CosmoBaker