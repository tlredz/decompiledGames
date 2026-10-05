local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DialogueController = require(ReplicatedStorage.DialogueController)
local FX = require(ReplicatedStorage.FX)
local Maid = require(ReplicatedStorage.Util.Maid)
require(ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Util = require(ReplicatedStorage.Util)
local color = Color3.new(1, 1, 0.498)
local color2 = Color3.fromRGB(70, 70, 70)
local color3 = Color3.new(1, 1, 0.15)
local v = {
	[3] = Vector2.new(1, 2),
	[4] = Vector2.new(4, 2)
}
local v2 = {
	WallBreak = {
		"rbxassetid://79710038601188",
		"rbxassetid://118006490347259",
		"rbxassetid://100850779992798",
		"rbxassetid://70619075115688",
		"rbxassetid://127067546080450",
		"rbxassetid://127292241774238"
	},
	LightShimmer = { "rbxassetid://74856364091218", "rbxassetid://104710647884236", "rbxassetid://89586657125457" },
	CrystalBounce = {
		"rbxassetid://101403894480191",
		"rbxassetid://116115494551742",
		"rbxassetid://83017213353132",
		"rbxassetid://86397771059879",
		"rbxassetid://84747058459560",
		"rbxassetid://101186387268674",
		"rbxassetid://93789372415640"
	},
	RockSlide = { "rbxassetid://137679784470233", "rbxassetid://124108306911919", "rbxassetid://140315524187500" }
}
local v3 = {
	playSound = function(list, position: Vector3, volume: number, flag: boolean?, timePosition: number?)
		if #list == 0 then
			return nil
		end

		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.Position = position
		part.Parent = workspace
		local sound = Instance.new("Sound")
		sound.SoundId = list[math.random(#list)]
		sound.Volume = volume
		sound.Looped = flag == true
		sound.Parent = part

		if not sound.Looped then
			sound.Ended:Once(function()
				part:Destroy()
			end)
			task.delay(10, function()
				if part.Parent ~= nil then
					part:Destroy()
				end
			end)
		end

		sound:Play()

		if timePosition ~= nil then
			sound.TimePosition = timePosition
		end

		return sound
	end,
	taperSoundAsync = function(state, p: number, p2: number)
		local volume = state.Volume
		local total = 0

		while total < p2 do
			if state.Parent == nil then
				return
			end

			local v4

			if total < p then
				v4 = total / p
			else
				v4 = 1 - (total - p) / (p2 - p)
			end

			state.Volume = volume * math.clamp(v4, 0, 1)
			total += task.wait()
		end

		local parent = state.Parent

		if parent ~= nil then
			parent:Destroy()
		end
	end,
	createBeam = function()
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.Parent = workspace
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		local attachment2 = Instance.new("Attachment")
		attachment2.Parent = part
		local beam = Instance.new("Beam")
		beam.Attachment0 = attachment
		beam.Attachment1 = attachment2
		beam.Texture = "rbxassetid://243664672"
		beam.TextureLength = 40
		beam.TextureMode = Enum.TextureMode.Wrap
		beam.TextureSpeed = 1.5
		beam.Color = ColorSequence.new(color)
		beam.LightEmission = 1
		beam.FaceCamera = true
		beam.Segments = 1
		beam.CurveSize0 = 0
		beam.CurveSize1 = 0
		beam.Width0 = 5
		beam.Width1 = 5
		beam.ZOffset = 0.1
		beam.Enabled = false
		beam.Parent = part
		local beam2 = Instance.new("Beam")
		beam2.Attachment0 = attachment
		beam2.Attachment1 = attachment2
		beam2.Color = ColorSequence.new(color)
		beam2.LightEmission = 1
		beam2.FaceCamera = true
		beam2.Segments = 1
		beam2.CurveSize0 = 0
		beam2.CurveSize1 = 0
		beam2.Width0 = 0.75
		beam2.Width1 = 0.75
		beam2.Transparency = NumberSequence.new(0.4)
		beam2.Enabled = false
		beam2.Parent = part
		return {
			part = part,
			origin = attachment,
			target = attachment2,
			beam = beam,
			solid = beam2
		}
	end,
	setBeam = function(data, worldPosition: Vector3, worldPosition2: Vector3)
		data.origin.WorldPosition = worldPosition
		data.target.WorldPosition = worldPosition2
		data.beam.Enabled = true
		data.solid.Enabled = true
	end,
	tweenModelPivotAsync = function(instance, cframe: CFrame)
		local pivot = instance:GetPivot()
		local total = 0

		while total < 0.5 do
			total += task.wait()
			instance:PivotTo(pivot:Lerp(
				cframe,
				(TweenService:GetValue(math.min(total / 0.5, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
			))
		end

		instance:PivotTo(cframe)
	end,
	intensifyBeam = function(p)
		p.beam.Width0 = 9
		p.beam.Width1 = 9
		p.beam.Brightness = 3
		p.solid.Width0 = 1.35
		p.solid.Width1 = 1.35
		p.solid.Transparency = NumberSequence.new(0)
	end,
	getPillarCrystal = function(p, p2: number, instance)
		local crystal = p.crystals[p2]

		if crystal ~= nil then
			return crystal
		end

		local crystal2 = instance:FindFirstChild("crystal", true)

		if crystal2 == nil then
			return nil
		end

		local surfaceAppearance = crystal2:FindFirstChildWhichIsA("SurfaceAppearance")

		if surfaceAppearance ~= nil then
			p.crystals[p2] = surfaceAppearance
		end

		return surfaceAppearance
	end,
	chargeDoorCrystalAsync = function(instance, p: number)
		local surfaceAppearance = instance:FindFirstChildWhichIsA("SurfaceAppearance")
		local cFrame = instance.CFrame
		local random = Random.new()
		local total = 0

		while total < p do
			total += task.wait()
			local v4 = total / p
			local v5 = v4 * 0.2
			instance.CFrame = cFrame * CFrame.new(
				random:NextNumber(-v5, v5),
				random:NextNumber(-v5, v5),
				random:NextNumber(-v5, v5)
			)

			if surfaceAppearance ~= nil then
				surfaceAppearance.Color = color2:Lerp(color3, v4)
			end
		end

		instance.CFrame = cFrame

		if surfaceAppearance ~= nil then
			surfaceAppearance.Color = color3
		end
	end,
	showPuzzleDialogueAsync = function()
		local v4 = DialogueController.new()
		v4:setTitle("???")
		v4:addPage(function(object)
			object:addText("Looks like there's a soft energy emitting from this crystal. Maybe it could be magnified?")
			object:advanceAfterDelay(4)
			object:noCancel()
		end):build()
		DialogueController.start(v4)
	end,
	findInstance = function()
		for _, folder in CollectionService:GetTagged("FishmanKarateMoment") do
			if folder:IsA("Folder") and folder:IsDescendantOf(workspace) then
				return folder
			end
		end

		return nil
	end
}

function v3.runPuzzleAsync(object, state)
	local instance = state.instance
	local v4 = {}

	while not state.cancelled do
		task.wait(0.03333333333333333)
		local flag = true

		for i = 1, 4 do
			local beam = state.beams[i]

			if beam then
				beam.beam.Enabled = false
				beam.solid.Enabled = false
			end

			local child = instance:FindFirstChild((`Pillar{i}`))

			if child == nil then
				continue
			end

			local pillarCrystal = v3.getPillarCrystal(state, i, child)

			if pillarCrystal ~= nil then
				pillarCrystal.Color = color2
			end
		end

		local raycastParams = RaycastParams.new()
		raycastParams.IncludeInstances = { instance.Parent }
		local v5 = {}

		for i = 1, 4 do
			local child = instance:FindFirstChild((`Pillar{i}`))

			if child == nil then
				continue
			end

			local pillarCrystal = v3.getPillarCrystal(state, i, child)

			if pillarCrystal ~= nil then
				pillarCrystal.Color = color
			end

			local position = child.Forward.Position
			local v6 = child.Forward.CFrame.LookVector * 300
			local raycastResult = workspace:Raycast(position, v6, raycastParams)
			local beam = state.beams[i]

			if beam then
				v3.setBeam(beam, position, raycastResult and raycastResult.Position or position + v6)
			end

			local child2 = instance:FindFirstChild((`Pillar{i + 1}`))
			local forward

			if child2 ~= nil then
				forward = child2:FindFirstChild("Forward")
			end

			local instance2

			if raycastResult ~= nil then
				instance2 = raycastResult.Instance
			end

			local v7

			if instance2 == nil or forward == nil then
				v7 = false
			else
				v7 = instance2 == forward
			end

			local v8

			if instance2 == nil then
				v8 = false
			else
				v8 = instance2.Name == "Goal"
			end

			if v7 or v8 then
				v5[i] = true
			else
				flag = false
				break
			end
		end

		for k in v5 do
			if v4[k] then
				continue
			end

			local child = instance:FindFirstChild((`Pillar{k}`))

			if child ~= nil then
				v3.playSound(v2.CrystalBounce, child.Forward.Position, 0.6)
			end
		end

		if flag then
			break
		else
			v4 = v5
		end
	end

	if state.cancelled then
		return
	end

	state.solved = true
	local door = instance:FindFirstChild("Door")

	if door ~= nil then
		local position = door:GetPivot().Position
		local bF_doorCrystal = door:FindFirstChild("BF_doorCrystal")
		local crystal = bF_doorCrystal and bF_doorCrystal:FindFirstChild("crystal")

		if crystal ~= nil and crystal:IsA("BasePart") then
			v3.chargeDoorCrystalAsync(crystal, 1.2)
		end

		local clone = door:Clone()
		local random = Random.new()

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = false
			part.CanCollide = false
			part.AssemblyLinearVelocity = random:NextUnitVector() * 50
			part.AssemblyAngularVelocity = random:NextUnitVector() * 25
		end

		clone.Parent = workspace.CurrentCamera
		door:TranslateBy(createVector(-0, -100, -0))
		v3.playSound(v2.WallBreak, position, 2)

		if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 400 then
			Util.CameraShaker:ShakeOnce(8, 6, 0.1, 0.6)
		end
	end

	local pillar4 = instance:FindFirstChild("Pillar4")

	if pillar4 ~= nil then
		local raycastParams = RaycastParams.new()
		raycastParams.IncludeInstances = { instance.Parent }
		local position = pillar4.Forward.Position
		local v5 = pillar4.Forward.CFrame.LookVector * 300
		local raycastResult = workspace:Raycast(position, v5, raycastParams)
		local beam = state.beams[4]

		if beam then
			v3.setBeam(beam, position, raycastResult and raycastResult.Position or position + v5)
		end
	end

	v3.intensifyBeam(state.skyBeam)

	for _, beam in state.beams do
		v3.intensifyBeam(beam)
	end

	object:InvokeServer("Complete")
end

function v3.buildPuzzle(p, state)
	local instance = state.instance

	for i = 1, 4 do
		local child = instance:FindFirstChild((`Pillar{i}`))

		if child ~= nil then
			child.Forward.Size = createVector(0.2, 0.2, 0.2)
		end
	end

	for i = 3, 4 do
		local child = instance:FindFirstChild((`Pillar{i}`))

		if child == nil then
			continue
		end

		local v4 = false
		local v5 = false
		local v6 = child
		local v7 = i
		state.maid:GiveTask(child.Root.Touched:Connect(function(otherPart)
			if v4 or v5 then
				return
			end

			v4 = true

			if otherPart:IsDescendantOf(Players.LocalPlayer.Character) then
				local root = v6.Root
				local pivot = Players.LocalPlayer.Character:GetPivot()
				local v8 = root.Position - pivot.Position
				local X = 0
				local Z = 0

				if math.abs(v8.X) >= math.abs(v8.Z) then
					X = math.sign(v8.X)
				else
					Z = math.sign(v8.Z)
				end

				local position = v6:GetAttribute("Position")
				local vector2 = Vector2.new(math.clamp(position.X + X, 1, 6), (math.clamp(position.Y + Z, 1, 6)))
				local child2 = instance.Grid:FindFirstChild((`{vector2.X}_{vector2.Y}`))
				local v9 = CFrame.new(child2.Position.X, v6:GetPivot().Y, child2.Position.Z) * v6:GetPivot().Rotation
				v6:SetAttribute("Position", vector2)
				local v10 = v3.playSound(v2.RockSlide, root.Position, 1, false, 0.5)

				if v10 ~= nil then
					task.spawn(v3.taperSoundAsync, v10, 0.025, 0.5)
				end

				v3.tweenModelPivotAsync(v6, v9)
				local v11 = v[v7]

				if v11 ~= nil and vector2 == v11 then
					v5 = true
				end
			end

			v4 = false
		end))
	end

	local pillar1 = instance:FindFirstChild("Pillar1")

	if pillar1 ~= nil then
		local position = pillar1.Forward.Position
		local rightVector = pillar1.Forward.CFrame.RightVector
		local vector2 = Vector3.new(rightVector.X, 0, rightVector.Z)
		local v4 = position - ((vector2.Magnitude < 0.001 and createVector(0, 0, 1) or vector2).Unit - createVector(
			0,
			1,
			0
		)).Unit * 900
		v3.setBeam(state.skyBeam, v4, position)
		state.maid:GiveTask(task.spawn(function()
			local lightEffects = FX:WaitForChild("LightEffects")
			local F = lightEffects and lightEffects:FindFirstChild("F")
			local trailPart = F and F:FindFirstChild("TrailPart")

			if trailPart ~= nil and not state.cancelled then
				local clone = trailPart:Clone()

				if clone:IsA("BasePart") then
					clone.Anchored = true
				end

				for _, descendant in clone:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.Anchored = true
					elseif descendant:IsA("ParticleEmitter") then
						descendant.Rate *= 28
						descendant.Lifetime = NumberRange.new(descendant.Lifetime.Min * 2, descendant.Lifetime.Max * 2)
					end
				end

				clone:PivotTo(CFrame.new(v4))
				clone.Parent = workspace
				state.sunEffect = clone
			end
		end))
		local v5 = v3.playSound(v2.LightShimmer, position, 0.2, true)

		if v5 ~= nil then
			state.maid:GiveTask(v5.Parent)
		end

		state.maid:GiveTask(task.spawn(function()
			while not state.cancelled do
				task.wait(0.1)
				local character = Players.LocalPlayer.Character

				if not (character ~= nil and (character:GetPivot().Position - position).Magnitude <= 50) then
					continue
				end

				task.spawn(v3.showPuzzleDialogueAsync)
				break
			end
		end))
	end

	local door = instance:FindFirstChild("Door")
	local bF_doorCrystal = door and door:FindFirstChild("BF_doorCrystal")
	local crystal = bF_doorCrystal and bF_doorCrystal:FindFirstChild("crystal")
	local surfaceAppearance = crystal and crystal:FindFirstChildWhichIsA("SurfaceAppearance")

	if surfaceAppearance ~= nil then
		surfaceAppearance.Color = color2
	end

	state.maid:GiveTask(task.spawn(v3.runPuzzleAsync, p, state))
end

function v3.waitForInstanceAsync()
	local instance = v3.findInstance()

	if instance ~= nil then
		return instance
	end

	local v4 = os.clock() + 20

	repeat
		task.wait(0.2)
		instance = v3.findInstance()
	until instance ~= nil or v4 < os.clock()

	return instance
end

function v3.openSolvedDoorAsync()
	local v4 = v3.waitForInstanceAsync()

	if v4 == nil then
		return
	end

	local door = v4:FindFirstChild("Door")

	if door ~= nil and door:IsA("Model") and door:GetAttribute("_SolvedDoorOpened") ~= true then
		door:SetAttribute("_SolvedDoorOpened", true)
		door:TranslateBy(createVector(-0, -100, -0))
	end
end

function v3.keepDoorOpenAsync(maid)
	maid:GiveTask(CollectionService:GetInstanceAddedSignal("FishmanKarateMoment"):Connect(function(folder)
		if folder:IsA("Folder") and folder:IsDescendantOf(workspace) then
			task.spawn(v3.openSolvedDoorAsync)
		end
	end))
	v3.openSolvedDoorAsync()
end

function v3.startAsync(maid)
	local instance = v3.waitForInstanceAsync()

	if instance == nil then
		return
	end

	local fishmanKarateState = {
		maid = Maid.new(),
		instance = instance,
		beams = table.create(4),
		skyBeam = v3.createBeam(),
		crystals = {},
		sunEffect = nil,
		solved = false,
		cancelled = false
	}
	fishmanKarateState.beams[1] = v3.createBeam()
	fishmanKarateState.beams[2] = v3.createBeam()
	fishmanKarateState.beams[3] = v3.createBeam()
	fishmanKarateState.beams[4] = v3.createBeam()
	maid.MiscData._fishmanKarateState = fishmanKarateState
	maid:GiveTask(fishmanKarateState.maid)
	fishmanKarateState.maid:GiveTask(function()
		fishmanKarateState.cancelled = true

		if not fishmanKarateState.solved then
			for _, beam in fishmanKarateState.beams do
				beam.part:Destroy()
			end

			fishmanKarateState.skyBeam.part:Destroy()
		end

		if fishmanKarateState.sunEffect ~= nil then
			fishmanKarateState.sunEffect:Destroy()
			fishmanKarateState.sunEffect = nil
		end
	end)
	v3.buildPuzzle(maid, fishmanKarateState)
end

local FishmanKarate = {}
FishmanKarate.DataName = script.Name
FishmanKarate.Repeatable = false
FishmanKarate.LoadWhenCompleted = true

function FishmanKarate.OnLoad(object)
	if object.Completed then
		v3.keepDoorOpenAsync(object)
	elseif object:InvokeServer("Initialize") == true then
		v3.startAsync(object)
	else
		v3.keepDoorOpenAsync(object)
	end
end

function FishmanKarate.OnComplete(p)
	local _fishmanKarateState = p.MiscData._fishmanKarateState

	if _fishmanKarateState ~= nil then
		_fishmanKarateState.maid:DoCleaning()
		p.MiscData._fishmanKarateState = nil
	end
end

return FishmanKarate