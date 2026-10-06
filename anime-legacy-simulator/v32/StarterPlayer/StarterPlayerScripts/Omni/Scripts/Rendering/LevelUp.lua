local module = require("@game/ReplicatedStorage/Omni")
local v = nil
local heartbeatConnection = nil
local LevelUp = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsHidden()
	local settings = module.Data and module.Data.Settings
	return not settings or settings["Hide Effects"] == true or settings["Low Mode"] == true
end

local function Step()
	local v2 = v

	if not v2 then
		return
	end

	local now = os.clock()

	if IsHidden() or v2.Character ~= module.Instance.Character or not v2.Root:IsDescendantOf(workspace) or not v2.Model.Parent or v2.ExpiresAt <= now then
		LevelUp.Clear()
		return
	end

	for _, emitter in v2.Emitters do
		if not emitter.Started and emitter.StartsAt <= now then
			emitter.Started = true

			if emitter.Count > 0 then
				emitter.Emitter:Emit(emitter.Count)
			end

			emitter.Emitter.Enabled = now < emitter.StopsAt
		end

		if emitter.Started and emitter.StopsAt <= now then
			emitter.Emitter.Enabled = false
		end
	end
end

function LevelUp.Clear()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v then
		v.Model:Destroy()
		v = nil
	end
end

function LevelUp.Play()
	LevelUp.Clear()

	if IsHidden() then
		return
	end

	local character = module.Instance.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local effects = module.Assets:FindFirstChild("Effects")
	local levelUp = effects and effects:FindFirstChild("LevelUp")

	if not (humanoidRootPart and levelUp and levelUp:IsA("Model") and levelUp.PrimaryPart) then
		return
	end

	local clone = levelUp:Clone()
	local primaryPart = clone.PrimaryPart
	local now = os.clock()
	local expiresAt = now
	local emitters = {}

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.Massless = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		elseif descendant:IsA("ParticleEmitter") then
			local v4 = math.max(0, descendant:GetAttribute("EmitDelay") or 0)
			local v5 = math.max(0, descendant:GetAttribute("EmitDuration") or 0)
			local count = math.max(0, descendant:GetAttribute("EmitCount") or descendant.Rate)
			descendant.Enabled = false
			expiresAt = math.max(expiresAt, now + v4 + v5 + descendant.Lifetime.Max + 0.1)
			table.insert(emitters, {
				Emitter = descendant,
				Count = count,
				StartsAt = now + v4,
				StopsAt = now + v4 + v5,
				Started = false
			})
		end
	end

	clone:PivotTo(humanoidRootPart.CFrame * primaryPart.CFrame:Inverse() * clone:GetPivot())
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = humanoidRootPart
	weldConstraint.Part1 = primaryPart
	weldConstraint.Parent = primaryPart
	clone.Parent = workspace.Cache
	v = {
		Model = clone,
		Root = humanoidRootPart,
		Character = character,
		Emitters = emitters,
		ExpiresAt = expiresAt
	}
	heartbeatConnection = module.Services.RunService.Heartbeat:Connect(Step)
	Step()
end

script.Destroying:Connect(LevelUp.Clear)
return LevelUp