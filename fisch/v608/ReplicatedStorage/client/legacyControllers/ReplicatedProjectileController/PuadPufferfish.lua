local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MeteorFireball = require(ReplicatedStorage.client.modules.MeteorFireball)
local PuadPufferfish = {
	Tags = { "PuadPufferfish" },
	Objects = {},
	Data = {}
}
local debrisfx = workspace:WaitForChild("active"):WaitForChild("debrisfx")

function PuadPufferfish.Init()
	RunService.RenderStepped:Connect(function(dt: number)
		for k, object in PuadPufferfish.Objects do
			local v = PuadPufferfish.Data[k]

			if v.Velocity.Magnitude <= 0 then
				continue
			end

			local v2 = math.min(v.Velocity.Magnitude * dt, v.Projectile.MaxDistance - v.TraveledDistance)
			object:PivotTo(object:GetPivot() + v.Velocity.Unit * v2)
			v.TraveledDistance += v2

			if v.TraveledDistance >= v.Projectile.MaxDistance then
				v.Velocity = createVector(0, 0, 0)
			end
		end
	end)
end

function PuadPufferfish.ProjectileCreated(data)
	local clone = script.Pufferfish:Clone()
	clone:PivotTo(CFrame.lookAlong(data.Position.Position, data.Velocity))

	if data.Args.name == "Mustard" then
		clone:ScaleTo(clone:GetScale() * 8)
	end

	clone.Parent = debrisfx
	clone.Hitbox.Flying:Play()
	PuadPufferfish.Objects[data.Id] = clone
	PuadPufferfish.Data[data.Id] = data
end

local v = {
	Pufferfish = 16,
	["Flying Pufferfish"] = 32,
	Mustard = 64,
	["Carrot Pufferfish"] = 16
}

function PuadPufferfish.ProjectileStopped(data)
	local folder = PuadPufferfish.Objects[data.Id]
	PuadPufferfish.Objects[data.Id] = nil
	PuadPufferfish.Data[data.Id] = nil
	folder:PivotTo(CFrame.lookAlong(data.Position.Position, data.Velocity))

	if folder then
		local explosionEffects = folder:FindFirstChild("Hitbox") and folder.Hitbox:FindFirstChild("ExplosionEffects")

		if explosionEffects then
			for _, child in explosionEffects:GetChildren() do
				child:Emit(child.Rate)
			end
		end
	end

	if folder then
		MeteorFireball.Create(data.Position.Position, v[data.Args.name], 3, "PufferFireball")
		local hitbox = folder:FindFirstChild("Hitbox")

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light") or descendant:IsA("Smoke") then
				descendant.Enabled = false
			end
		end

		if hitbox then
			hitbox.Flying:Stop()
			hitbox.Explode.PlaybackSpeed = Random.new():NextNumber(0.5, 1.1)
			hitbox.Explode:Play()
			local explosion = Instance.new("Explosion")
			explosion.DestroyJointRadiusPercent = 0
			explosion.ExplosionType = Enum.ExplosionType.NoCraters

			if data.Args.name == "Flying Pufferfish" and data.Args.wl then
				explosion.BlastPressure = Players.LocalPlayer.Character.PrimaryPart.AssemblyMass * workspace.Gravity * 500
				explosion.BlastRadius = 16
			elseif data.Args.name == "Mustard" and data.Args.wl then
				explosion.BlastPressure = Players.LocalPlayer.Character.PrimaryPart.AssemblyMass * workspace.Gravity * 200
				explosion.DestroyJointRadiusPercent = 1
				explosion.BlastRadius = 32
			else
				explosion.BlastPressure = 0
				explosion.BlastRadius = 8
			end

			explosion.Parent = hitbox
			explosion.Position = hitbox.Position
			task.wait(10)
		end

		folder:Destroy()
	end
end

return PuadPufferfish