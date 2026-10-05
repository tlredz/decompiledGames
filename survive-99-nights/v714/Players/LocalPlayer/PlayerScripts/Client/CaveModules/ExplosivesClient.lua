local createVector = vector.create
local ExplosivesClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Map.ExplodableModels }
local TweenService = game:GetService("TweenService")
local random = Random.new()
local v = {}

function Range(p, p2)
	return p + (p2 - p) * random:NextNumber()
end

function v:MetalGate(p)
	local parent = self.Parent
	self.Parent = game.ReplicatedStorage.TempStorage
	local pivot = self:GetPivot()
	local v2 = p + -self:GetPivot().LookVector * 10
	local children = game.ReplicatedStorage.Assets.Caves.MetalGate:GetChildren()
	local stakeLong = game.ReplicatedStorage.Assets.Caves.MetalGate.StakeLong
	Client.Sound.Play("ExplodeMetalGate", {
		Position = pivot.Position
	})
	local clones = {}

	for i = 1, 22 do
		local clone = children[random:NextInteger(1, #children)]:Clone()

		if i > 12 then
			clone = stakeLong:Clone()
		end

		table.insert(clones, clone)
		task.delay(Range(5, 8), function()
			clone:Destroy()
		end)
		local range = Range
		clone:ScaleTo(range(0.4, 0.8))
		local v3 = Range(-7.5, 7.5)
		local v4 = Range(-5, 5)
		local v5 = pivot * CFrame.new(v3, v4, 0)
		clone:PivotTo(v5)

		for _, child in pairs(clone:GetChildren()) do
			child.CollisionGroup = "Particles"
			child.Anchored = false
		end

		clone.Parent = workspace.Particles
		local unit = (v5.Position - v2).Unit
		clone.PrimaryPart:ApplyImpulse(unit * clone.PrimaryPart.AssemblyMass * 70)
	end

	local function undo()
		for _, v3 in pairs(clones) do
			v3:Destroy()
		end

		self.Parent = parent
	end

	return undo
end

function v:CrackedWall(p)
	local parent = self.Parent
	self.Parent = game.ReplicatedStorage.TempStorage
	local pivot = self:GetPivot()
	local v2 = p + -self:GetPivot().LookVector * 10
	local clones = {}

	for _ = 1, 12 do
		local clone = game.ReplicatedStorage.Assets.Caves.Rock:Clone()
		table.insert(clones, clone)
		task.delay(Range(5, 8), function()
			clone:Destroy()
		end)
		clone:ScaleTo(Range(0.4, 0.8))
		local v4 = Range(-7.5, 7.5)
		local v5 = Range(-5, 5)
		local v6 = pivot * CFrame.new(v4, v5, 0)
		clone:PivotTo(v6)

		for _, child in pairs(clone:GetChildren()) do
			child.CollisionGroup = "Particles"
		end

		clone.Parent = workspace.Particles
		local unit = (v6.Position - v2).Unit
		clone.PrimaryPart:ApplyImpulse(unit * clone.PrimaryPart.AssemblyMass * 50)
	end

	local function undo()
		for _, v3 in pairs(clones) do
			v3:Destroy()
		end

		self.Parent = parent
	end

	return undo
end

function ExplosionParticles(position, _)
	Client.Sound.Play("GenericExplosion", {
		Position = position,
		Volume = 0.3
	})
	Client.Utility.SpawnParticles("GenericExplosion", CFrame.new(position))
end

Client.Events.ExplosionParticles:Connect(ExplosionParticles)

function ExplosivesClient.LightTNT(instance, explosionTime: number)
	if instance:GetAttribute("Ignited") then
		return
	end

	instance:SetAttribute("Ignited", true)

	if instance.PrimaryPart and instance.PrimaryPart:FindFirstChild("ProximityAttachment") then
		instance.PrimaryPart.ProximityAttachment:Destroy()
	end

	for _, descendant in pairs(instance.Fuse:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
			descendant.Enabled = true
		end
	end

	local projectileId = Client.ProjectileClass.GetProjectileId()
	local dynamiteFuse = instance.PrimaryPart:FindFirstChild("DynamiteFuse")

	if dynamiteFuse then
		dynamiteFuse:Play()
	end

	if not explosionTime then
		local v2 = Client.Events.RequestIgniteTNT:InvokeServer(instance, projectileId)

		if v2 and v2.Success then
			explosionTime = v2.ExplosionTime
		else
			return
		end
	end

	local v2 = math.clamp(explosionTime - workspace:GetServerTimeNow(), 0, 10)
	TweenService:Create(instance.Fuse.FuseAttachment, TweenInfo.new(v2), {
		Position = instance.Fuse.FuseEnd.CFrame.Position
	}):Play()
	task.wait(v2)
	local pivot = instance:GetPivot()

	if dynamiteFuse then
		dynamiteFuse:Stop()
	end

	Client.Events.RequestDetonateTNT:FireServer(pivot, instance, projectileId)
	Explosion(localPlayer, pivot.Position, instance:GetAttribute("ExplosionRadius"), projectileId)
end

function Explosion(_, p, p2, p3)
	ExplosionParticles(p, p2)

	if localPlayer.Character then
		local magnitude = (p - localPlayer.Character:GetPivot().Position).Magnitude

		if magnitude <= p2 then
			Client.ToolModule.ApplyKnockback(p, {
				Vertical = 25,
				Horizontal = 20
			})
		end

		local v2 = p2 * 3

		if magnitude <= v2 then
			local v3 = 1 - math.clamp(magnitude / v2, 0.3, 1)
			Client.CamShake.ShakeOnce(v3 * 5, 25, 0.07, 0.25)
		end
	end

	local partBoundsInRadius = workspace:GetPartBoundsInRadius(p, p2, overlapParams)
	local v2 = {}

	for _, v3 in pairs(partBoundsInRadius) do
		local parent = v3.Parent

		if parent:HasTag("ExplodableModel") and parent:GetAttribute("ExplosionAnimated") == nil then
			v2[parent] = true
		end
	end

	for k in pairs(v2) do
		local explosionEffect = k:GetAttribute("ExplosionEffect")

		if not (explosionEffect and v[explosionEffect]) then
			continue
		end

		local v3 = v[explosionEffect](k, p)
		k:SetAttribute("ExplosionAnimated", true)
		local v4 = Client.Events.RequestExplodeModel:InvokeServer(k, p3)

		if v4 and v4.Success then
			continue
		end

		local v5 = v3
		local v6 = k
		task.delay(0.5, function()
			v5()
			v6:SetAttribute("ExplosionAnimated", nil)
		end)
	end
end

ExplosivesClient.Explosion = Explosion

function DynamiteAdded(instance)
	if instance:GetAttribute("Ignited") then
		return
	end

	local proximityAttachment = instance.PrimaryPart:FindFirstChild("ProximityAttachment")
	local proximityInteraction = proximityAttachment and proximityAttachment:FindFirstChild("ProximityInteraction")

	if not proximityInteraction then
		return
	end

	local flag = false
	proximityInteraction.PromptHidden:Connect(function()
		flag = false
	end)
	proximityInteraction.PromptShown:Connect(function()
		flag = true

		while flag do
			proximityAttachment.WorldCFrame = instance:GetPivot() + createVector(0, 4, 0)
			task.wait()
		end
	end)
end

function ExplosivesClient.Init()
	Client.Utility.ForAllTagged("Dynamite", DynamiteAdded)
end

return ExplosivesClient