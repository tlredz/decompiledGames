local createVector = vector.create
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local gameData = ReplicatedStorage:WaitForChild("GameData")
local Volcano = require(gameData:WaitForChild("Volcano"))
local General = require(gameData:WaitForChild("General"))
local PetRigService = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetRigService"))
local ForgeVFX = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("ForgeVFX"))
local assets = ReplicatedStorage:WaitForChild("Assets")
local eggs = assets:WaitForChild("Eggs")
local SFX = SoundService:WaitForChild("SFX")

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function Ease(p: number)
	return p * p * (3 - p * 2)
end

local v = {
	{
		Start = 0,
		Length = 0.5,
		Cycles = 1,
		Degrees = 14,
		Pulse = 0.08
	},
	{
		Start = 0.95,
		Length = 0.55,
		Cycles = 1,
		Degrees = 22,
		Pulse = 0.15
	},
	{
		Start = 1.9,
		Length = 0.7,
		Cycles = 3.75,
		Degrees = 30,
		Swell = 0.12,
		Crescendo = true
	}
}
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 110, 30)),
	ColorSequenceKeypoint.new(0.35, Color3.fromRGB(235, 25, 10)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 0, 0))
})
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.05),
	NumberSequenceKeypoint.new(0.6, 0.45),
	NumberSequenceKeypoint.new(1, 1)
})
local numberSequence2 = NumberSequence.new(1, 0.15)
local color = Color3.fromRGB(255, 41, 41)
local color2 = Color3.fromRGB(255, 255, 255)
ForgeVFX.init()

-- equivalent calls inferred from this helper; original call sites unknown
local function NewSound(name: string, p: number, volume: number)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = `rbxassetid://{p}`
	sound.Volume = volume
	return sound
end

local newSound = NewSound("VolcanoSplash", 126105529228330, 1) -- equivalent call inferred; original call site unknown
local newSound2 = NewSound("VolcanoTease", 110476620796113, 1) -- equivalent call inferred; original call site unknown
local newSound3 = NewSound("VolcanoWoosh", 135595810064855, 1) -- equivalent call inferred; original call site unknown
task.spawn(function()
	pcall(ContentProvider.PreloadAsync, ContentProvider, { newSound, newSound2, newSound3 })
end)

local function GameSound(...)
	local sound = SFX

	for _, childName in { ... } do
		sound = sound and sound:FindFirstChild(childName)
	end

	if sound and sound:IsA("Sound") then
		return sound
	end

	return nil
end

local function PlayOn(instance, parent)
	if not (instance and parent and parent.Parent) then
		return
	end

	local clone = instance:Clone()
	clone.RollOffMode = Enum.RollOffMode.InverseTapered
	clone.RollOffMinDistance = 40
	clone.RollOffMaxDistance = 400
	clone.Parent = parent
	clone:Play()
	Debris:AddItem(
		clone,
		not (clone.TimeLength > 0) and 8 or clone.TimeLength / math.max(clone.PlaybackSpeed, 0.1) + 0.5
	)
end

local function VisualsFolder()
	local currentCamera = workspace.CurrentCamera
	local volcanoVisuals = currentCamera:FindFirstChild("VolcanoVisuals")

	if volcanoVisuals then
		return volcanoVisuals
	end

	local folder = Instance.new("Folder")
	folder.Name = "VolcanoVisuals"
	folder.Parent = currentCamera
	return folder
end

local function BuildEgg(egg: string)
	local child = eggs:FindFirstChild(egg)

	if not child then
		return nil
	end

	local clone = child:Clone()
	local model = Instance.new("Model")
	model.Name = egg

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Parent = model
	end

	clone:Destroy()

	if model:FindFirstChildWhichIsA("BasePart") then
		model.WorldPivot = model:GetBoundingBox()
		return model
	end

	model:Destroy()
	return nil
end

local function BiggestPart(folder)
	local v5 = nil

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and (v5 == nil or part.Size.Magnitude > v5.Size.Magnitude)) then
			continue
		end

		v5 = part
	end

	return v5
end

local function AddTrail(instance, p: number)
	local parent = BiggestPart(instance)

	if not parent then
		return
	end

	local pivot = instance:GetPivot()
	local v6 = p * 0.7
	local attachment = Instance.new("Attachment")
	attachment.Name = "VolcanoTrailTop"
	attachment.CFrame = parent.CFrame:ToObjectSpace(pivot * CFrame.new(0, v6, 0))
	attachment.Parent = parent
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "VolcanoTrailBottom"
	attachment2.CFrame = parent.CFrame:ToObjectSpace(pivot * CFrame.new(0, -v6, 0))
	attachment2.Parent = parent
	local trail = Instance.new("Trail")
	trail.Name = "VolcanoTrail"
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Color = colorSequence
	trail.Transparency = numberSequence
	trail.WidthScale = numberSequence2
	trail.Lifetime = 0.5
	trail.FaceCamera = true
	trail.LightEmission = 0.8
	trail.LightInfluence = 0
	trail.Parent = parent
end

local function QuadraticBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	return vector2:Lerp(vector3, p):Lerp(vector3:Lerp(vector4, p), p)
end

local function ActiveBeat(p: number)
	for _, v5 in v do
		if v5.Start <= p and p < v5.Start + v5.Length then
			return v5, (p - v5.Start) / v5.Length
		end
	end

	return nil, 0
end

local function BeatAngle(data, p: number)
	local v5

	if data.Crescendo then
		v5 = p
	else
		v5 = math.sin(3.141592653589793 * p)
	end

	return math.rad(data.Degrees) * v5 * math.sin(6.283185307179586 * data.Cycles * p)
end

local v5 = v[#v]
local v6 = v5.Crescendo and 1 or 1.2246467991473532e-16
local v7 = math.rad(v5.Degrees) * v6 * math.sin(6.283185307179586 * v5.Cycles * 1)
local swell = v5.Swell or 0

-- equivalent calls inferred from this helper; original call sites unknown
local function WiggleAngle(p: number)
	local v8, v9 = ActiveBeat(p)

	if not v8 then
		return 0
	end

	local v10

	if v8.Crescendo then
		v10 = v9
	else
		v10 = math.sin(3.141592653589793 * v9)
	end

	return math.rad(v8.Degrees) * v10 * math.sin(6.283185307179586 * v8.Cycles * v9)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TeaseScale(p: number)
	local v8, v9 = ActiveBeat(p)

	if not v8 then
		return 1
	end

	if v8.Pulse then
		return 1 + v8.Pulse * math.sin(3.141592653589793 * v9 ^ 0.6)
	end

	if v8.Swell then
		return 1 + v8.Swell * v9 * v9
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PopScale(p: number)
	if p < 0.12 then
		local v8 = p / 0.12
		return 1 + swell + (0.35 - swell) * (1 - (1 - v8) ^ 2)
	end

	if p < 0.6 then
		local v8 = (p - 0.12) / 0.48
		return (1 - v8) ^ 2 * 0.35 * math.cos(4.71238898038469 * v8) + 1
	else
		return 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RollAxis()
	local currentCamera = workspace.CurrentCamera
	local v8 = currentCamera and currentCamera.CFrame.LookVector * createVector(1, 0, 1)

	if v8 and v8.Magnitude > 0.001 then
		return v8.Unit
	end

	return createVector(0, 0, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ArcControl(vector2: Vector3, vector3: Vector3, p: number)
	local v8 = math.max(p, ((vector3 - vector2) * createVector(1, 0, 1)).Magnitude * Volcano.ArcLiftPerStud)
	local lerped = vector2:Lerp(vector3, 0.5)
	return (Vector3.new(lerped.X, math.max(vector2.Y, vector3.Y) + v8, lerped.Z))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Phase(p: number, p2: number, p3: number)
	if p3 <= 0 then
		return 1
	end

	return (math.clamp((p - p2) / p3, 0, 1))
end

local function Emit(name: string, position: Vector3, color3: Color3?)
	local effects = assets:FindFirstChild("Effects")
	local instance = effects and effects:FindFirstChild(name)

	if not instance then
		return
	end

	local parent

	if instance:IsA("Model") and instance:FindFirstChildWhichIsA("BasePart", true) then
		parent = instance:Clone()

		for _, part in parent:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end

		parent:PivotTo(CFrame.new(position))
	else
		parent = Instance.new("Part")
		parent.Name = name
		parent.Anchored = true
		parent.CanCollide = false
		parent.CanQuery = false
		parent.CanTouch = false
		parent.CastShadow = false
		parent.Transparency = 1
		parent.Size = createVector(1, 1, 1)
		parent.CFrame = CFrame.new(position)

		if instance:IsA("Attachment") then
			local clone = instance:Clone()
			clone.Parent = parent
		else
			for _, child in instance:GetChildren() do
				local clone_2 = child:Clone()
				clone_2.Parent = parent
			end
		end
	end

	if color3 then
		local colorSequence2 = ColorSequence.new(color3)

		for _, emitter in parent:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Color = colorSequence2
			end
		end
	end

	local currentCamera = workspace.CurrentCamera
	local parent2 = currentCamera:FindFirstChild("VolcanoVisuals")

	if not parent2 then
		parent2 = Instance.new("Folder")
		parent2.Name = "VolcanoVisuals"
		parent2.Parent = currentCamera
	end

	parent.Parent = parent2
	ForgeVFX.emit(parent)
	Debris:AddItem(parent, 6)
end

local function PlayAt(p, landing: Vector3)
	local part = Instance.new("Part")
	part.Name = `Volcano{p.Name}`
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(landing)
	local currentCamera = workspace.CurrentCamera
	local parent = currentCamera:FindFirstChild("VolcanoVisuals")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "VolcanoVisuals"
		parent.Parent = currentCamera
	end

	part.Parent = parent
	PlayOn(p, part)
	Debris:AddItem(part, 10)
end

local function OverheadPoint(owner: number, p: number)
	local playerByUserId = Players:GetPlayerByUserId(owner)
	local character = playerByUserId and playerByUserId.Character
	local head = character and character:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		return head.Position + Vector3.new(0, head.Size.Y / 2 + p + 0.15, 0)
	end

	return nil
end

local v8 = {}

local function FlightKey(p: number, p2: number)
	return (`{p}:{p2}`)
end

return table.freeze({
	Play = function(self)
		if typeof(self.From) ~= "Vector3" or typeof(self.Landing) ~= "Vector3" or type(self.Egg) ~= "string" or type(self.StartedAt) ~= "number" or type(self.RevealAt) ~= "number" or type(self.ArriveAt) ~= "number" then
			return
		end

		if workspace:GetServerTimeNow() >= self.ArriveAt then
			return
		end

		local parent = BuildEgg(self.Egg)

		if not parent then
			return
		end

		local worldEggScaleFor = General.WorldEggScaleFor(tonumber(self.Weight) or 1)
		local v10 = worldEggScaleFor * Volcano.FlightScale
		parent:ScaleTo(worldEggScaleFor)
		local _, v11 = parent:GetBoundingBox()
		local v12 = v11.Y / 2
		local v13 = v12 * Volcano.FlightScale
		local eggAuraBoost = PetRigService.EggAuraBoost(parent)
		local v14 = OverheadPoint(self.Owner, v12) or self.From
		local landing = self.Landing
		local v15 = landing - Vector3.new(0, Volcano.SinkDepth + v13, 0)
		local v16 = landing + Vector3.new(0, Volcano.RiseHeight + v13, 0)
		local arcControl = ArcControl(v14, landing, Volcano.TossArcHeight) -- equivalent call inferred; original call site unknown
		local v18 = self.StartedAt + Volcano.TossSeconds
		local v19 = v18 + Volcano.SinkSeconds
		local v20 = v19 + Volcano.ShakeSeconds
		local v21 = v13 * 2 * Volcano.ShakeAmount
		local v22 = v20 + Volcano.RiseSeconds
		local revealAt = self.RevealAt
		local v23 = revealAt + Volcano.HoverSeconds
		local arriveAt = self.ArriveAt

		local function ScaleAt(serverTimeNow: number)
			if serverTimeNow < v18 then
				local v25 = v10 - worldEggScaleFor
				local phase = Phase(serverTimeNow, self.StartedAt, Volcano.TossSeconds) -- equivalent call inferred; original call site unknown
				return worldEggScaleFor + v25 * Ease(phase)
			else
				if serverTimeNow < v22 then
					return v10
				end

				if serverTimeNow < revealAt then
					local teaseScale = TeaseScale(serverTimeNow - v22) -- equivalent call inferred; original call site unknown
					return v10 * teaseScale
				elseif serverTimeNow < v23 then
					local popScale = PopScale(serverTimeNow - revealAt) -- equivalent call inferred; original call site unknown
					return v10 * popScale
				else
					local v25 = worldEggScaleFor - v10
					local phase = Phase(serverTimeNow, v23, arriveAt - v23) -- equivalent call inferred; original call site unknown
					return v10 + v25 * Ease(phase)
				end
			end
		end

		if self.PreviousMutation then
			PetRigService.ApplyMutationAura(parent, self.PreviousMutation, eggAuraBoost)
		end

		if self.SpawnMutation then
			parent:SetAttribute("SpawnMutation", self.SpawnMutation)
			parent:AddTag("SpawnMutationCarrier")
		end

		local success = self.Success

		if success then
			if self.Mutation == nil then
				success = false
			else
				success = self.Mutation ~= self.PreviousMutation
			end
		end

		local parent2 = BiggestPart(parent)
		local v25 = {
			{
				At = self.StartedAt,
				Sounds = { GameSound("Pop"), newSound3 }
			}
		}

		for _, v26 in v do
			if v26.Pulse then
				table.insert(v25, {
					At = v22 + v26.Start,
					Sounds = { newSound2 }
				})
			end
		end

		local count = 0
		local v26 = false
		local v27 = false
		local v28 = v14
		local renderSteppedConnection = nil
		local formatted = `{self.Owner}:{self.StartedAt}`

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Stop()
			renderSteppedConnection:Disconnect()
			parent:Destroy()
			v8[formatted] = nil
		end

		local function Cancel()
			if parent.Parent then
				Emit("LavaEggBurst", parent:GetBoundingBox().Position, color2)
			end

			Stop() -- equivalent call inferred; original call site unknown
		end

		local function Finish()
			Stop() -- equivalent call inferred; original call site unknown
			local serverTimeNow = workspace:GetServerTimeNow()

			if arriveAt <= serverTimeNow and serverTimeNow - arriveAt <= 0.5 then
				local playerByUserId = Players:GetPlayerByUserId(self.Owner)
				local head = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChild("Head")
				local gameSound = GameSound("Pop")

				if not (head and head:IsA("BasePart")) then
					head = nil
				end

				PlayOn(gameSound, head)
			end
		end

		local function Step()
			local serverTimeNow = workspace:GetServerTimeNow()

			if arriveAt <= serverTimeNow or not parent.Parent then
				Finish()
				return
			end

			while count < #v25 and v25[count + 1].At <= serverTimeNow do
				count += 1
				local v29 = v25[count]

				if not (serverTimeNow - v29.At <= 0.5) then
					continue
				end

				for _, sound in v29.Sounds do
					PlayOn(sound, parent2)
				end
			end

			if not v26 and v18 <= serverTimeNow then
				v26 = true

				if serverTimeNow - v18 <= 0.5 then
					Emit("LavaSplash", landing)
					PlayAt(newSound, landing)
				end
			end

			if not v27 and revealAt <= serverTimeNow then
				v27 = true

				if serverTimeNow - revealAt <= 0.5 then
					local position = parent:GetBoundingBox().Position
					local v31

					if success then
						v31 = color
					else
						v31 = color2
					end

					Emit("LavaEggBurst", position, v31)
					local v33

					if success then
						v33 = GameSound("RNGReveal", "Reveal")
					else
						v33 = GameSound("Game", "CartoonFail")
					end

					PlayOn(v33, parent2)
				end

				if success then
					PetRigService.ApplyMutationAura(parent, self.Mutation, eggAuraBoost)
				end
			end

			local identity = CFrame.identity
			local v29

			if serverTimeNow < v18 then
				local phase = Phase(serverTimeNow, self.StartedAt, Volcano.TossSeconds) -- equivalent call inferred; original call site unknown
				local arcControl2 = arcControl
				v29 = v14:Lerp(arcControl2, phase):Lerp(arcControl2:Lerp(landing, phase), phase)
			elseif serverTimeNow < v19 then
				local phase = Phase(serverTimeNow, v18, Volcano.SinkSeconds) -- equivalent call inferred; original call site unknown
				v29 = landing:Lerp(v15, Ease(phase)) + Vector3.new(0, math.sin(serverTimeNow * 9) * 0.6 * phase, 0)
			elseif serverTimeNow < v20 then
				local v31 = Phase(serverTimeNow, v19, Volcano.ShakeSeconds) ^ 2 * 0.65 + 0.35
				local v32 = v21 * v31
				v29 = v15 + Vector3.new(
					math.noise(serverTimeNow * 14, 1.7) * 2 * v32,
					math.noise(serverTimeNow * 14, 5.3) * v32,
					math.noise(serverTimeNow * 14, 9.1) * 2 * v32
				)
				identity = CFrame.Angles(
					math.noise(serverTimeNow * 11, 3.2) * 0.5 * v31,
					0,
					math.noise(serverTimeNow * 11, 7.4) * 0.5 * v31
				)
			elseif serverTimeNow < v22 then
				local phase = Phase(serverTimeNow, v20, Volcano.RiseSeconds) -- equivalent call inferred; original call site unknown
				v29 = v15:Lerp(v16, 1 - (1 - phase) ^ 2)
			elseif serverTimeNow < revealAt then
				v29 = v16 + Vector3.new(0, math.sin(serverTimeNow * 9) * 0.6, 0)
				local rollAxis = RollAxis() -- equivalent call inferred; original call site unknown
				local wiggleAngle = WiggleAngle(serverTimeNow - v22) -- equivalent call inferred; original call site unknown
				identity = CFrame.fromAxisAngle(rollAxis, wiggleAngle)
			elseif serverTimeNow < v23 then
				v29 = v16 + Vector3.new(0, math.sin(serverTimeNow * 9) * 0.6, 0)
				local v30 = math.clamp((serverTimeNow - revealAt) / 0.35, 0, 1)
				identity = CFrame.fromAxisAngle(RollAxis(), v7 * (1 - v30) ^ 3)
			else
				v28 = OverheadPoint(self.Owner, v12) or v28
				local phase = Phase(serverTimeNow, v23, arriveAt - v23) -- equivalent call inferred; original call site unknown
				local ease = Ease(phase)
				local arcControl2 = ArcControl(v16, v28, Volcano.ReturnArcHeight) -- equivalent call inferred; original call site unknown
				local v38 = v28
				v29 = v16:Lerp(arcControl2, ease):Lerp(arcControl2:Lerp(v38, ease), ease)
			end

			local scaleAt = ScaleAt(serverTimeNow)

			if math.abs(scaleAt - parent:GetScale()) > 0.001 then
				parent:ScaleTo(scaleAt)
			end

			parent:PivotTo(CFrame.new(v29) * identity * CFrame.Angles(
				0,
				serverTimeNow * 6.283185307179586 % 6.283185307179586,
				0
			))
		end

		parent:PivotTo(CFrame.new(v14))
		AddTrail(parent, v12)

		if self.Owner == Players.LocalPlayer.UserId then
			local highlight = Instance.new("Highlight")
			highlight.Name = "VolcanoOutline"
			highlight.FillTransparency = 1
			highlight.OutlineColor = Color3.new(1, 1, 1)
			highlight.OutlineTransparency = 0
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = parent
		end

		local currentCamera = workspace.CurrentCamera
		local parent3 = currentCamera:FindFirstChild("VolcanoVisuals")

		if not parent3 then
			parent3 = Instance.new("Folder")
			parent3.Name = "VolcanoVisuals"
			parent3.Parent = currentCamera
		end

		parent.Parent = parent3
		renderSteppedConnection = RunService.RenderStepped:Connect(Step)
		v8[formatted] = Cancel
		Step()
	end,
	Cancel = function(p: number, p2: number)
		local v9 = v8[`{p}:{p2}`]

		if v9 then
			v9()
		end
	end
})