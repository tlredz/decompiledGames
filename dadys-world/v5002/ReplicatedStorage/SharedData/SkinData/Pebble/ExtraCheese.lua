local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ExtraCheese = {}
ExtraCheese.Name = "Extra Cheese"
ExtraCheese.TowerName = "Pebble"
ExtraCheese.Description = "No description yet"
ExtraCheese.Mastery = false
ExtraCheese.Cost = 600
ExtraCheese.Halloween = true
ExtraCheese.HolidaySkin = true
ExtraCheese.HolidayYear = 2025
ExtraCheese.OverwriteAnimations = {
	Walk = "rbxassetid://122090536571188",
	Idle = "rbxassetid://118541078850171",
	Decode = "rbxassetid://92587848327965",
	Run = "rbxassetid://83551885753918",
	Quirk = "rbxassetid://136035361265819"
}
ExtraCheese.FaceTextures = {
	Normal = "rbxassetid://137874767125479",
	Blink = "rbxassetid://87257084243015",
	Hurt = "rbxassetid://87916170411153"
}
ExtraCheese.USE_SKIN_MODEL = true

function ExtraCheese.ApplySkin(_) end

function ExtraCheese.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local v = instance:WaitForChild("HumanoidRootPart").Size.Y / 2 + humanoid.HipHeight
	local clone = game.ReplicatedStorage:WaitForChild("Parts"):WaitForChild("PoofPebbleSkins"):Clone()
	clone.Color = Color3.fromRGB(242, 226, 80)
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
	local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(45, 0.25, 45)
	}):Play()
	TweenService:Create(clone, tweenInfo2, {
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return ExtraCheese