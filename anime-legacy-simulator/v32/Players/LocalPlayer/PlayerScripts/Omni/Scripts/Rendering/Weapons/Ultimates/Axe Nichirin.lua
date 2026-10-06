local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local maps = workspace:WaitForChild("Client"):WaitForChild("Maps")
local color = Color3.fromRGB(255, 214, 170)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { maps, workspace.Terrain }
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true

-- equivalent calls inferred from this helper; original call sites unknown
local function CanShowEffects()
	return not (module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"])
end

local function GetGround(player, vector2: Vector3)
	local raycastResult = workspace:Raycast(vector2 + createVector(0, 4, 0), createVector(0, -50, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position + createVector(0, 0.03, 0)
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	return vector2 - Vector3.new(0, (humanoid and humanoid.HipHeight or 2) + player.HRP.Size.Y / 2, 0)
end

local function PrepareEffect(instance)
	local clone = instance:Clone()
	module.Utils.Particles:DisableAll(clone)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	return clone
end

local function StopCamera(p)
	if p.ActiveShake then
		p.ActiveShake:Stop()
		p.ActiveShake = nil
	end

	for _, v in { "ImpactEffect", "BlurEffect" } do
		local v2 = p[v]

		if not v2 then
			continue
		end

		v2:Destroy()
		p[v] = nil
	end

	p.CameraStarted = nil
end

local function ClearEffects(p, flag: boolean?)
	StopCamera(p)

	for _, v in { "JumpEffect", "HitEffect" } do
		local v2 = p[v]

		if not v2 then
			continue
		end

		p[v] = nil
		module.Utils.Particles:DisableAll(v2)

		if flag and CanShowEffects() then
			module.Services.Debris:AddItem(v2, 3)
		else
			v2:Destroy()
		end
	end
end

local function UpdateCamera(state, p: number)
	if not state.CameraStarted then
		return
	end

	local v = p - state.CameraStarted

	if state.ImpactEffect then
		local v2 = math.clamp(1 - math.max(0, v - 0.035) / 0.15, 0, 1) * state.CameraFalloff
		state.ImpactEffect.TintColor = Color3.new(1, 1, 1):Lerp(color, v2)
		state.ImpactEffect.Brightness = 0.3 * v2
		state.ImpactEffect.Contrast = 0.4 * v2

		if v2 <= 0 then
			state.ImpactEffect:Destroy()
			state.ImpactEffect = nil
		end
	end

	if state.BlurEffect then
		local v2

		if v < 0.03 then
			v2 = v / 0.03
		else
			v2 = math.clamp(1 - math.max(0, v - 0.05) / 0.18, 0, 1)
		end

		state.BlurEffect.Size = 8 * v2 * state.CameraFalloff

		if v2 <= 0 and v > 0.03 then
			state.BlurEffect:Destroy()
			state.BlurEffect = nil
		end
	end
end

local function StartCamera(state, position: Vector3, elapsed: number)
	state.ActiveShake = module.Utils.CameraShake:Play({
		Position = position,
		Amplitude = 1.5,
		Frequency = 0.05,
		FadeOutTime = 0.3
	})
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local falloff = module.Utils.Math.Falloff((currentCamera.CFrame.Position - position).Magnitude, 80)

	if falloff <= 0 then
		return
	end

	state.CameraFalloff = falloff
	state.CameraStarted = elapsed
	state.ImpactEffect = Instance.new("ColorCorrectionEffect")
	state.ImpactEffect.Name = "AxeImpact"
	state.ImpactEffect.Parent = currentCamera
	state.BlurEffect = Instance.new("BlurEffect")
	state.BlurEffect.Name = "AxeBlur"
	state.BlurEffect.Size = 0
	state.BlurEffect.Parent = currentCamera
	UpdateCamera(state, elapsed)
end

local AxeNichirin = {}

function AxeNichirin:Setup()
	self.Stage = 0
	table.insert(self.Resources, function()
		ClearEffects(self)
	end)

	if module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"] then
		return
	end

	local axeNichirin = module.Assets.Effects.Weapons:FindFirstChild("Axe Nichirin")
	local skill = axeNichirin and axeNichirin:FindFirstChild("Skill")
	local jump = skill and skill:FindFirstChild("Jump")
	local hit = skill and skill:FindFirstChild("Hit")

	if not (jump and hit and jump:IsA("BasePart") and hit:IsA("BasePart")) then
		return
	end

	local cframe = CFrame.lookAt(createVector(0, 0, 0), self.Direction)
	local ground = GetGround(self, self.Origin)
	local ground2 = GetGround(self, self.Origin + self.Direction * 8.16)
	local cache = workspace:FindFirstChild("Cache") or workspace
	local clone = jump:Clone()
	module.Utils.Particles:DisableAll(clone)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	self.JumpEffect = clone
	self.JumpEffect.CFrame = cframe + ground
	self.JumpEffect.Parent = cache
	local clone2 = hit:Clone()
	module.Utils.Particles:DisableAll(clone2)
	clone2.Anchored = true
	clone2.CanCollide = false
	clone2.CanTouch = false
	clone2.CanQuery = false
	self.HitEffect = clone2
	self.HitEffect.CFrame = cframe + ground2
	self.HitEffect.Parent = cache
end

function AxeNichirin:Update()
	if module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"] then
		ClearEffects(self)
		return
	end

	if not (self.JumpEffect and self.HitEffect) then
		return
	end

	local elapsed = self.Elapsed

	for i = 1, self.Index - 1 do
		elapsed += self.Skill.Phases[i].Duration
	end

	if elapsed >= 0.2833333333333333 and self.Stage < 1 then
		self.Stage = 1

		if elapsed - 0.2833333333333333 < 0.2 then
			module.Utils.Particles:Emit(self.JumpEffect)
		end
	end

	if elapsed >= 1.4 and self.Stage < 2 then
		self.Stage = 2

		if elapsed - 1.4 < 0.2 then
			module.Utils.Particles:Emit(self.HitEffect)
			StartCamera(self, self.HitEffect.Position, elapsed)
		end
	end

	UpdateCamera(self, elapsed)
end

function AxeNichirin.Clear(player)
	ClearEffects(
		player,
		player.Completed and player.Character:IsDescendantOf(workspace) and (not player.Player or player.Player.Character == player.Character)
	)
end

return AxeNichirin