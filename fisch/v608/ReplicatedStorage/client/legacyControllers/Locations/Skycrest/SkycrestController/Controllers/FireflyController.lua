local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Net = require(ReplicatedStorage.packages.Net)
local v = {
	"Firefly",
	"Loopy Five Firefly",
	"Blue Ghost Firefly",
	"Gombak Bent-Winged Firefly"
}
local remoteEvent = Net:RemoteEvent("Skycrest/FireflySnapshot")
local remoteEvent2 = Net:RemoteEvent("Skycrest/CatchFirefly")
local fireflies = nil
local v2 = {}
local now = 0
local folder = Instance.new("Folder")
folder.Name = "SkycrestFireflies"

local function setVfxEnabled(state, flag: boolean)
	if state.VfxEnabled == flag then
		return
	end

	state.VfxEnabled = flag

	for _, emitter in state.Emitters do
		emitter.Enabled = flag
	end

	local light = state.Light

	if not light then
		return
	end

	if state.LightTween then
		state.LightTween:Cancel()
		state.LightTween = nil
	end

	if flag then
		light.Brightness = state.LightBrightness
		light.Enabled = true
	else
		local tween = TweenService:Create(light, TweenInfo.new(1.2), {
			Brightness = 0
		})
		state.LightTween = tween
		tween.Completed:Connect(function()
			if not state.VfxEnabled then
				light.Enabled = false
			end
		end)
		tween:Play()
	end
end

local function applyRarity(state, rarityIndex: number)
	if state.RarityIndex == rarityIndex then
		return
	end

	local objectText = v[rarityIndex]

	if not objectText then
		return
	end

	local part

	if fireflies then
		part = fireflies:FindFirstChild(objectText)
	end

	if not (part and part:IsA("BasePart")) then
		return
	end

	if state.Part then
		state.Prompt.Parent = nil
		state.Part:Destroy()
	end

	if state.LightTween then
		state.LightTween:Cancel()
		state.LightTween = nil
	end

	table.clear(state.Emitters)
	state.Light = nil
	state.LightBrightness = 0
	state.VfxEnabled = false
	state.RarityIndex = rarityIndex
	local clone = part:Clone()
	clone.Name = `Firefly_{state.Index}`
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CastShadow = false
	clone.Locked = true
	clone.CFrame = CFrame.new(state.CurrentPos)

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
			descendant:AddTag("IgnorePerformance")
			table.insert(state.Emitters, descendant)
		elseif descendant:IsA("PointLight") then
			state.LightBrightness = descendant.Brightness
			descendant.Enabled = false
			state.Light = descendant
		end
	end

	state.Prompt.ObjectText = objectText
	state.Prompt.Parent = clone
	clone.Parent = folder
	state.Part = clone
end

local function createVisual(i: number)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.ActionText = "Catch"
	proximityPrompt.ObjectText = v[1]
	proximityPrompt.HoldDuration = 0.35
	proximityPrompt.MaxActivationDistance = 14
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Enabled = false
	local v3 = {
		Index = i,
		Part = nil,
		Prompt = proximityPrompt,
		Emitters = {},
		Light = nil,
		LightBrightness = 0,
		LightTween = nil,
		VfxEnabled = false,
		RarityIndex = 0,
		StateId = 0,
		TargetPos = createVector(0, 0, 0),
		CurrentPos = createVector(0, 0, 0),
		PrevSnapshotPos = createVector(0, 0, 0),
		ServerVelocity = createVector(0, 0, 0),
		Initialized = false
	}
	proximityPrompt.Triggered:Connect(function()
		remoteEvent2:FireServer(i)
		proximityPrompt.Enabled = false
		task.delay(0.1, function()
			if proximityPrompt.Parent and v3.StateId ~= 0 then
				proximityPrompt.Enabled = true
			end
		end)
	end)
	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideAll()
	for _, v3 in v2 do
		v3.StateId = 0
		v3.Prompt.Enabled = false
		setVfxEnabled(v3, false)
	end
end

return {
	Start = function(_)
		folder.Parent = Workspace
		fireflies = script:WaitForChild("Fireflies", 5)
		remoteEvent.OnClientEvent:Connect(function(buf: buffer)
			now = os.clock()

			for i = 1, buffer.len(buf) // 14 do
				local v3 = (i - 1) * 14
				local v4 = v2[i]

				if not v4 then
					v4 = createVisual(i)
					v2[i] = v4
				end

				local vector2 = Vector3.new(
					buffer.readf32(buf, v3),
					buffer.readf32(buf, v3 + 4),
					(buffer.readf32(buf, v3 + 8))
				)
				local stateId = buffer.readu8(buf, v3 + 12)
				applyRarity(v4, buffer.readu8(buf, v3 + 13))

				if v4.Initialized and not ((vector2 - v4.CurrentPos).Magnitude > 25) then
					v4.ServerVelocity = (vector2 - v4.PrevSnapshotPos) / 0.125
					v4.PrevSnapshotPos = vector2
				else
					v4.CurrentPos = vector2
					v4.PrevSnapshotPos = vector2
					v4.ServerVelocity = createVector(0, 0, 0)
					v4.Initialized = true

					if v4.Part then
						v4.Part.CFrame = CFrame.new(vector2)
					end

					for _, emitter in v4.Emitters do
						emitter:Clear()
					end
				end

				v4.TargetPos = vector2
				v4.StateId = stateId
				v4.Prompt.Enabled = stateId ~= 0
				setVfxEnabled(v4, stateId ~= 0)
			end
		end)
		RunService.RenderStepped:Connect(function(dt)
			debug.profilebegin("FireflyController::Render")

			if now > 0 and os.clock() - now > 2 then
				hideAll() -- equivalent call inferred; original call site unknown
			end

			for _, v3 in v2 do
				local part = v3.Part

				if not (v3.Initialized and part and v3.StateId ~= 0) then
					continue
				end

				local v4 = v3.TargetPos - v3.CurrentPos
				local magnitude = v4.Magnitude
				local magnitude2 = v3.ServerVelocity.Magnitude

				if magnitude >= 0.01 then
					if magnitude2 < 0.01 then
						v3.CurrentPos = v3.CurrentPos:Lerp(v3.TargetPos, 1 - math.exp(-6 * dt))
					else
						local v5 = magnitude2 * dt
						local currentPos

						if magnitude <= v5 then
							currentPos = v3.TargetPos
						else
							currentPos = v3.CurrentPos + v4 / magnitude * v5
						end

						v3.CurrentPos = currentPos
					end
				end

				part.CFrame = CFrame.new(v3.CurrentPos)
			end

			debug.profileend()
		end)
	end
}