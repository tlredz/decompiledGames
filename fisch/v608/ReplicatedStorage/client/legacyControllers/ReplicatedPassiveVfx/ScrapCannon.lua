local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
require(ReplicatedStorage.shared.utils.assets)
require(ReplicatedStorage.shared.modules.SaneDebris)
local fx = require(ReplicatedStorage.shared.modules.fx)
local ScrapCannon = {}
local fishing = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing")
local resources = ReplicatedStorage:WaitForChild("resources")

function ScrapCannon.CreateProjectileModel(_, p)
	local child = resources.replicated.instances.general:FindFirstChild(p.ProjectileModelName)

	if child then
		return (child:Clone())
	end

	warn((`Failed to find model for projectile {p.ProjectileModelName}!`))
	return nil
end

function ScrapCannon:PlaySound(p, p2, p3)
	if not (self and p) then
		return
	end

	local child = fishing:FindFirstChild(self)

	if not child then
		return
	end

	fx:PlaySound(child, p, p3 or false, "FishingSound", p2)
end

function ScrapCannon.ThrowChunk(_, _, _, p, data)
	local folder = ScrapCannon.CreateProjectileModel(p, data)
	folder.Name = data.OwnerName
	local primaryPart = folder.PrimaryPart

	if not (folder and primaryPart) then
		return
	end

	task.spawn(
		ContentProvider.PreloadAsync,
		ContentProvider,
		{ script.explosion.explode, script.explosion.BillboardGui.VIOLENTEXPLOSION }
	)
	local startPos = data.StartPos
	local unit = (data.FishPos - startPos).Unit
	primaryPart.Anchored = true
	primaryPart.CFrame = CFrame.lookAlong(startPos, unit)
	local cframe = CFrame.lookAlong(data.FishPos, unit)
	local tween = TweenService:Create(
		primaryPart,
		TweenInfo.new(p.AnimTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{
			CFrame = cframe
		}
	)
	tween.Completed:Once(function()
		tween:Destroy()

		if data.ProjectileModelName == "MetalChunk" then
			folder:Destroy()
			local clone = script.explosion:Clone()
			clone.CFrame = cframe
			clone.Parent = workspace.active.debrisfx
			clone.explode:Play()
			local VIOLENTEXPLOSION = clone.BillboardGui.VIOLENTEXPLOSION
			VIOLENTEXPLOSION.Visible = true

			for i = 1, 203, 101 do
				for i2 = 1, 362, 72 do
					VIOLENTEXPLOSION.ImageRectOffset = Vector2.new(i2, i)
					task.wait(0.025)
				end
			end

			VIOLENTEXPLOSION.Visible = false
			task.wait(2)
			clone:Destroy()
		else
			for _, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			if primaryPart:FindFirstChild("ImpactSound") then
				primaryPart.ImpactSound:Play()
			end

			task.wait(5)
			folder:Destroy()
		end
	end)
	tween:Play()
	folder.Parent = workspace.active.debrisfx

	if primaryPart:FindFirstChild("ThrowSound") then
		primaryPart.ThrowSound:Play()
	end
end

return ScrapCannon