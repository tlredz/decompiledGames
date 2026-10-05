local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
require(ReplicatedStorage.shared.utils.assets)
require(ReplicatedStorage.shared.modules.SaneDebris)
require(ReplicatedStorage.shared.modules.fx)
local BoneLanceSkelefish = {}
local resources = ReplicatedStorage:WaitForChild("resources")

function BoneLanceSkelefish.CreateProjectileModel(p)
	local child = resources.replicated.instances.general:FindFirstChild(p.FishModelName)

	if child then
		return (child:Clone())
	end

	warn((`Failed to find model for projectile {p.FishModelName}!`))
	return nil
end

function BoneLanceSkelefish.SkelefishAttack(_, _, _, data)
	local folder = BoneLanceSkelefish.CreateProjectileModel(data)
	folder.Name = data.OwnerName
	local primaryPart = folder.PrimaryPart

	if not (folder and primaryPart) then
		return
	end

	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { primaryPart })
	local startPos = data.StartPos
	local unit = (data.FishPos - startPos).Unit
	primaryPart.Anchored = true
	primaryPart.CFrame = CFrame.lookAlong(startPos, unit)
	local cframe = CFrame.lookAlong(data.FishPos, unit)
	local tween = TweenService:Create(
		primaryPart,
		TweenInfo.new(data.MoveTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			CFrame = cframe
		}
	)
	tween.Completed:Once(function()
		tween:Destroy()

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			end
		end

		for _, descendant in primaryPart.explode:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant:Emit(descendant:GetAttribute("EmitCount"))
			elseif descendant:IsA("Sound") then
				descendant:Play()
			end
		end

		task.wait(5)
		folder:Destroy()
	end)
	tween:Play()
	folder.Parent = workspace.active.debrisfx

	for _, descendant in primaryPart.spawn:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant:Emit(descendant:GetAttribute("EmitCount") or 1)
		elseif descendant:IsA("Sound") then
			descendant:Play()
		end
	end
end

return BoneLanceSkelefish