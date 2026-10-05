local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local DreamPebble = {
	Name = "Star-Time Pebble",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://94118610964552"
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://71342802770833"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://94118610964552"
		blinkTexture.Texture = "rbxassetid://132766043150769"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local v = nil

		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("MeshPart") then
				if CollectionService:HasTag(part, "EyePart") then
					v = part
				end

				local weld = Instance.new("Weld")
				part.Parent = folder:WaitForChild(part.Name)
				weld.Parent = part
				weld.Part0 = part
				weld.Part1 = folder:WaitForChild(part.Name)
				part.Anchored = false
				local waitForChild = folder:WaitForChild(part.Name)
				waitForChild.Transparency = 1
			end

			if part.Name == "Eyes" then
				part.Transparency = 1
			end
		end

		if folder:FindFirstChild("Eyes") then
			folder.Eyes.Transparency = 1
		end

		if folder:FindFirstChild("BlinkingParts") and v then
			folder.BlinkingParts.Eyes.Value = v
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

function DreamPebble.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance:WaitForChild("Stats"):WaitForChild("Skin")
	local v = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
	local clone = game.ReplicatedStorage:WaitForChild("Parts"):WaitForChild("Poof"):Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
	local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	local tweenInfo3 = TweenInfo.new(0.33, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	Debris:AddItem(clone, 5)
	task.spawn(function()
		task.wait(0.1)
		local tween = TweenService:Create(clone, tweenInfo3, {
			Color = Color3.fromRGB(179, 179, 179)
		})
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(clone, tweenInfo3, {
			Color = Color3.fromRGB(157, 141, 83)
		})
		tween2:Play()
		tween2.Completed:Wait()
	end)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(45, 0.25, 45)
	}):Play()
	TweenService:Create(clone, tweenInfo2, {
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return DreamPebble