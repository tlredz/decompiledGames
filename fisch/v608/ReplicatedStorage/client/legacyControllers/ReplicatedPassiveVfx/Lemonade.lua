local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(ReplicatedStorage.shared.utils.assets)
require(ReplicatedStorage.shared.modules.SaneDebris)
local fx = require(ReplicatedStorage.shared.modules.fx)
local Lemonade = {}
local fishing = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing")
local resources = ReplicatedStorage:WaitForChild("resources")

function Lemonade.CreateFruitModel(p, _)
	local child = resources.models:FindFirstChild(p.LemonModelName)

	if not child then
		warn((`Failed to find model for falling fruit {p.LemonModelName}!`))
		return nil
	end

	local clone = child:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
			descendant.CastShadow = false
		elseif descendant:IsA("Light") then
			descendant.Enabled = false
		end
	end

	return clone
end

function Lemonade.PlaySound(childName: string?, p, p2, p3)
	if not (childName and p) then
		return
	end

	local child = fishing:FindFirstChild(childName)

	if not child then
		return
	end

	fx:PlaySound(child, p, p3 or false, "FishingSound", p2)
end

function Lemonade.SpawnFruit(_, _, p, data)
	local folder = Lemonade.CreateFruitModel(p, data)
	folder.Name = data.OwnerName
	local primaryPart = folder.PrimaryPart

	if not (folder and primaryPart) then
		return
	end

	local center = data.Center

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Transparency = 1
		TweenService:Create(part, TweenInfo.new(0.25), {
			Transparency = 0
		}):Play()
	end

	primaryPart.Anchored = true
	primaryPart.CFrame = CFrame.new(center.X + math.random(-7.5, 7.5), center.Y + 30, center.Z + math.random(-7.5, 7.5)) * CFrame.Angles(
		0,
		-3.141592653589793,
		(math.rad((math.random(-180, 180))))
	)
	local cframe = CFrame.new(primaryPart.Position.X, center.Y, primaryPart.Position.Z)
	local tween = TweenService:Create(
		primaryPart,
		TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			CFrame = CFrame.new(cframe.X, cframe.Y - 10, cframe.Z) * CFrame.Angles(
				0,
				3.141592653589793,
				3.141592653589793
			)
		}
	)
	tween.Completed:Once(function()
		folder:Destroy()
		tween:Destroy()
	end)
	tween:Play()
	folder.Parent = workspace.active.debrisfx
	task.delay(0.6, function()
		local clone = resources:WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):WaitForChild("Shockwave"):Clone()
		clone.Position = cframe.Position
		clone.Size = Vector3.new(3, clone.Size.Y, 3)
		clone.Parent = workspace.active.debrisfx
		Lemonade.PlaySound("bigsplash", clone, data.Owner, true)
		Lemonade.PlaySound("lemon", clone, data.Owner, true)
		local tween2 = TweenService:Create(clone, TweenInfo.new(2), {
			Size = Vector3.new(20, clone.Size.Y + 3, 20),
			Transparency = 1
		})
		tween2.Completed:Once(function()
			clone:Destroy()
			tween2:Destroy()
		end)
		tween2:Play()
	end)
end

function Lemonade.StartFruitRain(_, maid, p, p2, p3)
	local flag = false
	maid:Add(function()
		flag = true
	end)
	task.wait(0.35)

	if flag then
		return
	end

	while task.wait(0.25) and not flag do
		Lemonade.SpawnFruit(maid, p, p2, p3)
	end
end

return Lemonade