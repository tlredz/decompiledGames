local createVector = vector.create
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Effect = require(game.ReplicatedStorage.Effect)
local NPCList = require(game.ReplicatedStorage.NPCManager.NPCList)
local Util = require(game.ReplicatedStorage.Util)
local CannonIdle = require(game.ReplicatedStorage.Controllers.IslandController.CannonIdle)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local color = Color3.fromRGB(26, 30, 42)
local color2 = Color3.fromRGB(120, 190, 255)
local color3 = Color3.fromRGB(110, 255, 150)
local color4 = Color3.fromRGB(255, 95, 80)
local color5 = Color3.fromRGB(28, 28, 32)
local color6 = Color3.fromRGB(255, 105, 75)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local position = nil
local v5 = nil
local v6 = nil
local v7 = {}
local v8 = nil
local v9 = 18
local v10 = nil
local v11 = nil
local flag = false
local v12 = false
local v13 = 0
local v14 = 0
local v15 = false
local heartbeatConnection = nil
local renderSteppedConnection = nil
local now = 0
local flag2 = false
local v16 = {}
local v17 = nil

local function puffAway(instance)
	if not (instance and instance:IsDescendantOf(workspace)) then
		return
	end

	local pivot

	if instance:IsA("Model") then
		pivot = instance:GetPivot()
	elseif instance:IsA("BasePart") then
		pivot = instance.CFrame
	end

	if not pivot then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera and (currentCamera.CFrame.Position - pivot.Position).Magnitude > 300 then
		return
	end

	Effect.new("Chests.Despawn"):play({
		CFrame = pivot
	})
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true

-- equivalent calls inferred from this helper; original call sites unknown
local function flatDistance(position2: Vector3, vector2: Vector3)
	local v18 = position2.X - vector2.X
	local v19 = position2.Z - vector2.Z
	return (math.sqrt(v18 * v18 + v19 * v19))
end

local function refreshGroundFilter()
	local children = {}

	for _, childName in { "NPCs", "Characters", "Enemies" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	raycastParams.FilterDescendantsInstances = children
end

local function snapToGround(cframe: CFrame)
	refreshGroundFilter()
	local v18 = cframe.Position + createVector(0, 50, 0)
	local raycastResult = workspace:Raycast(v18, createVector(0, -300, 0), raycastParams)

	if raycastResult then
		return CFrame.new(raycastResult.Position) * cframe.Rotation
	end

	return cframe
end

local function groundY(vector2: Vector3, p: number)
	refreshGroundFilter()
	local v18 = vector2 + createVector(0, 30, 0)
	local raycastResult = workspace:Raycast(v18, createVector(0, -150, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position.Y
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearRing()
	for _, v18 in v7 do
		v18:Destroy()
	end

	table.clear(v7)
	v8 = nil
	v10 = nil
	v11 = nil
end

local function buildRing(clone, vector2: Vector3, p: number)
	clearRing() -- equivalent call inferred; original call site unknown
	local folder = Instance.new("Folder")
	folder.Name = "HoistRing"
	folder.Parent = clone

	for i = 1, 36 do
		local v18 = (i - 1) / 36 * 3.141592653589793 * 2
		local vector3 = Vector3.new(math.cos(v18), 0, (math.sin(v18)))
		local v19 = vector2 + vector3 * p
		local X = v19.X
		local Y = vector2.Y
		refreshGroundFilter()
		local v20 = v19 + createVector(0, 30, 0)
		local raycastResult = workspace:Raycast(v20, createVector(0, -150, 0), raycastParams)

		if raycastResult then
			Y = raycastResult.Position.Y
		end

		local vector4 = Vector3.new(X, Y + 0.12, v19.Z)
		local vector5 = Vector3.new(-vector3.Z, 0, vector3.X)
		local part = Instance.new("Part")
		part.Name = `Dash{i}`
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = color2
		part.Transparency = 1
		part.Size = createVector(0.7, 0.15, 2.1)
		part.CFrame = CFrame.lookAt(vector4, vector4 + vector5, createVector(0, 1, 0))
		part.Parent = folder
		table.insert(v7, part)
	end

	v8 = vector2
	v9 = p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRing(color7: Color3, transparency: number)
	if v10 == color7 and v11 == transparency then
		return
	end

	v10 = color7
	v11 = transparency

	for _, v18 in v7 do
		v18.Color = color7
		v18.Transparency = transparency
	end
end

local function clearShells()
	for _, v18 in v16 do
		v18.Part:Destroy()
	end

	table.clear(v16)

	if v17 then
		v17:Destroy()
		v17 = nil
	end
end

local function shellContainer()
	local v18 = v17

	if v18 and v18.Parent then
		return v18
	end

	local folder = Instance.new("Folder")
	folder.Name = "FlagpoleShells"
	folder.Parent = workspace:FindFirstChild("_WorldOrigin") or workspace
	v17 = folder
	return folder
end

local function burstAt(impact: Vector3)
	local cframe = CFrame.new(impact)
	pcall(function()
		Util.Sound:Play("Explosion2", cframe)
	end)
	pcall(function()
		Effect.new("DustExplosion"):play({
			CFrame = cframe,
			Size = { 0, 34 },
			Duration = 1.2
		})
	end)
end

local function spawnFallbackShell(position2: Vector3, position3: Vector3, p: number)
	local v18 = math.random() * 3.141592653589793 * 2
	local cframe = CFrame.new(position2 + Vector3.new(math.cos(v18) * 220, 90, math.sin(v18) * 220))
	pcall(function()
		Util.Sound:Play("ShortExplosion", cframe)
	end)
	local part = Instance.new("Part")
	part.Name = "FlagpoleShell"
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Metal
	part.Color = color5
	part.Size = createVector(2.6, 2.6, 2.6)
	part.CFrame = CFrame.new(cframe.Position)
	local attachment = Instance.new("Attachment")
	attachment.Name = "TrailBack"
	attachment.Position = createVector(0, 0, 1.3)
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "TrailFront"
	attachment2.Position = createVector(0, 0, -1.3)
	attachment2.Parent = part
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Lifetime = 0.35
	trail.WidthScale = NumberSequence.new(1.6)
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) })
	trail.Color = ColorSequence.new(color6)
	trail.LightEmission = 0.4
	trail.FaceCamera = true
	trail.Parent = part
	local parent = v17

	if not (parent and parent.Parent) then
		parent = Instance.new("Folder")
		parent.Name = "FlagpoleShells"
		parent.Parent = workspace:FindFirstChild("_WorldOrigin") or workspace
		v17 = parent
	end

	part.Parent = parent
	table.insert(v16, {
		Part = part,
		Start = cframe.Position,
		Impact = position3,
		Flight = math.max(p, 0.1),
		Elapsed = 0
	})
end

local function spawnShell(position2: Vector3, chargeTime: number, value2: number)
	local cframe = CFrame.new(position2)
	refreshGroundFilter()
	local v18 = cframe.Position + createVector(0, 50, 0)
	local raycastResult = workspace:Raycast(v18, createVector(0, -300, 0), raycastParams)

	if raycastResult then
		cframe = CFrame.new(raycastResult.Position) * cframe.Rotation
	end

	local position3 = cframe.Position
	pcall(function()
		Effect.new("BossIndicatorV2"):play({
			Type = "Circle",
			OriginCF = CFrame.new(position3),
			Radius = value2,
			Color = color6,
			WarnTime = 0,
			ChargeTime = chargeTime,
			HoldTime = 0,
			FadeTime = 0.2
		})
	end)
	local v19 = false
	pcall(function()
		v19 = CannonIdle.bombard(position3, chargeTime) == true
	end)

	if not v19 then
		spawnFallbackShell(position2, position3, chargeTime)
	end
end

local function stepShells(dt: number)
	for i = #v16, 1, -1 do
		local v18 = v16[i]

		if v18.Part.Parent then
			v18.Elapsed = math.min(v18.Elapsed + dt, v18.Flight)
			local v19 = v18.Elapsed / v18.Flight
			local v20 = v18.Start:Lerp(v18.Impact, v19) + Vector3.new(0, v19 * 220 * (1 - v19), 0)
			local v21 = v20 - v18.Part.Position
			local part = v18.Part
			local cFrame

			if v21.Magnitude > 0.01 then
				cFrame = CFrame.lookAt(v20, v20 + v21)
			else
				cFrame = CFrame.new(v20)
			end

			part.CFrame = cFrame

			if v18.Elapsed >= v18.Flight then
				table.remove(v16, i)
				v18.Part:Destroy()
				burstAt(v18.Impact)
			end
		else
			table.remove(v16, i)
		end
	end
end

local function applyFlagFace(flag3)
	flag3.Color = color

	for _, decal in flag3:GetChildren() do
		if decal:IsA("Decal") then
			decal:Destroy()
		end
	end

	for _, face in { Enum.NormalId.Front, Enum.NormalId.Back } do
		local decal = Instance.new("Decal")
		decal.Name = `ParlusFace_{face.Name}`
		decal.Face = face
		decal.Texture = "rbxassetid://97583760304336"
		decal.Parent = flag3
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyProgress(p: number)
	local v18 = v4
	local v19 = position

	if v18 and v19 then
		v18.Position = Vector3.new(v19.X, 9.5 + (v19.Y - 9.5) * p, v19.Z)
	end
end

local function playRaisedAnimation(parent)
	local animationController = parent:FindFirstChildOfClass("AnimationController") or Instance.new("AnimationController")
	animationController.Parent = parent
	local animator = animationController:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent = animationController
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://103784618375485"
	animation.Parent = parent
	animator:LoadAnimation(animation):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disarmPrompt()
	if v5 then
		local parent = v5.Parent
		v5:Destroy()

		if parent and parent.Name == "FlagpolePrompt" then
			parent:Destroy()
		end

		v5 = nil
	end

	v6 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectLoops()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function cleanupAll()
	disconnectLoops() -- equivalent call inferred; original call site unknown
	disarmPrompt() -- equivalent call inferred; original call site unknown
	clearRing() -- equivalent call inferred; original call site unknown
	clearShells()
	v4 = nil
	position = nil
	v12 = false
	v13 = 0
	v14 = 0
	v15 = false

	if v2 then
		puffAway(v2)
		v2:Destroy()
		v2 = nil
	end

	if v3 then
		puffAway(v3)
		v3:Destroy()
		v3 = nil
	end

	for _, child in workspace:GetChildren() do
		if not ((child.Name == "FortressFlag" or child.Name == "FortressRope") and (child:IsA("Model") or child:IsA("BasePart"))) then
			continue
		end

		puffAway(child)
		child:Destroy()
	end
end

local function armPrompt(object, clone, vector2: Vector3)
	disarmPrompt() -- equivalent call inferred; original call site unknown
	local part = Instance.new("Part")
	part.Name = "FlagpolePrompt"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(vector2 + createVector(0, 5, 0))
	part.Parent = clone
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ObjectText = "Flagpole"
	proximityPrompt.ActionText = "Raise the Flag"
	proximityPrompt.HoldDuration = 0.6
	proximityPrompt.MaxActivationDistance = 16
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = part
	proximityPrompt.Triggered:Connect(function()
		if v ~= object or v12 or object.Completed then
			return
		end

		object:FireServer("Hoist")
	end)
	v5 = proximityPrompt
	v6 = false
end

local function armLoops(object)
	disconnectLoops() -- equivalent call inferred; original call site unknown
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if v ~= object then
			return
		end

		local character = Players.LocalPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		local v18 = v3

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") and object.Active and not object.Completed and not flag and v18 and v18.Parent and (humanoidRootPart.Position - v18.Position).Magnitude <= 12 and os.clock() - now >= 2 then
			now = os.clock()
			object:FireServer("TakeRope")
		end

		local enabled = object.Active and flag and not (v12 or object.Completed) and v5 ~= nil

		if v5 and v6 ~= enabled then
			v6 = enabled
			v5.Enabled = enabled
		end
	end)
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if v ~= object then
			return
		end

		stepShells(dt)

		if not (v2 and v2.Parent) then
			return
		end

		local v18 = v8

		if v18 and #v7 > 0 then
			if object.Active and flag and not object.Completed then
				if v12 then
					local character = Players.LocalPlayer.Character
					local humanoidRootPart

					if character then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					end

					local v19

					if humanoidRootPart == nil then
						v19 = false
					else
						v19 = humanoidRootPart:IsA("BasePart")

						if v19 then
							v19 = flatDistance(humanoidRootPart.Position, v18) <= v9
						end
					end

					local v20 = math.sin(os.clock() * 5) * 0.5 + 0.5
					local color7

					if v19 then
						color7 = color3
					else
						color7 = color4
					end

					local transparency = v20 * 0.35 + 0.1

					if v10 ~= color7 or v11 ~= transparency then
						v10 = color7
						v11 = transparency

						for _, v23 in v7 do
							v23.Color = color7
							v23.Transparency = transparency
						end
					end
				else
					applyRing(color2, 0.55) -- equivalent call inferred; original call site unknown
				end
			else
				applyRing(color2, 1) -- equivalent call inferred; original call site unknown
			end
		end

		local v19 = 1 - math.exp(-7 * dt)
		v14 += (v13 - v14) * v19

		if math.abs(v13 - v14) < 0.001 then
			v14 = v13
		end

		applyProgress(v14) -- equivalent call inferred; original call site unknown

		if not v15 and v14 >= 0.999 then
			v15 = true
			playRaisedAnimation(v2)
		end
	end)
end

local function spawnFlag(p, cframe: CFrame?, p2: number)
	if v2 and v2.Parent then
		return
	end

	local flagRigged = script:WaitForChild("FlagRigged", 5)

	if not (flagRigged and flagRigged:IsA("Model")) then
		return
	end

	local clone = flagRigged:Clone()
	clone.Name = "FortressFlag"

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
		elseif descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end

	local flag3 = clone:FindFirstChild("Flag")

	if flag3 and flag3:IsA("BasePart") then
		applyFlagFace(flag3)
	end

	v4 = nil
	position = nil
	local rootPart = clone:FindFirstChild("RootPart")
	local controller

	if rootPart then
		controller = rootPart:FindFirstChild("Controller")
	end

	if controller and controller:IsA("Bone") then
		v4 = controller
		position = controller.Position
	end

	local v18 = nil

	for _, part in clone:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local v19 = part.Position.Y - part.Size.Y / 2

		if not v18 or v19 < v18 then
			v18 = v19
		end
	end

	local v19 = not v18 and 0 or clone:GetPivot().Position.Y - v18

	if cframe then
		refreshGroundFilter()
		local v20 = cframe.Position + createVector(0, 50, 0)
		local raycastResult = workspace:Raycast(v20, createVector(0, -300, 0), raycastParams)

		if raycastResult then
			cframe = CFrame.new(raycastResult.Position) * cframe.Rotation
		end

		clone:PivotTo(cframe * CFrame.new(0, v19, 0))
	end

	clone.Parent = workspace
	v2 = clone
	local position2 = clone:GetPivot().Position
	local v20 = position2.Y - v19
	applyProgress(v14) -- equivalent call inferred; original call site unknown
	local vector2 = Vector3.new(position2.X, v20, position2.Z)
	armPrompt(p, clone, vector2)
	buildRing(clone, vector2, p2)
end

local function spawnRope(cframe: CFrame?)
	if v3 and v3.Parent then
		return
	end

	local rope = script:WaitForChild("Rope", 5)

	if not (rope and rope:IsA("BasePart")) then
		return
	end

	local clone = rope:Clone()
	clone.Name = "FortressRope"
	clone.Anchored = true

	if cframe then
		refreshGroundFilter()
		local v18 = cframe.Position + createVector(0, 50, 0)
		local raycastResult = workspace:Raycast(v18, createVector(0, -300, 0), raycastParams)

		if raycastResult then
			cframe = CFrame.new(raycastResult.Position) * cframe.Rotation
		end

		clone.CFrame = cframe * CFrame.new(0, clone.Size.Y / 2, 0)
	end

	clone.Parent = workspace
	v3 = clone
end

local function nextOptionSlot(p)
	local v18 = 1

	while p["Option" .. v18] ~= nil do
		v18 += 1
	end

	return "Option" .. v18
end

local function buildPitch(object)
	return {
		Text = {
			"Bro. BRO. You seen that flagpole out in the front of the island? It'd be SOOO funny if I could get my face on there LOL.",
			"I got a whole flag custom made... with my BEAUTIFUL face on it Bro. We need to work together to get my flag on that pole and humiliate those marines.",
			"BUTTT BRO. Everytime I try to do it, those marines just pull it off. I need a strong rope that'll hold the flag in place.",
			"There's some rope hidden around here, go find it, and use it to tie my flag onto the pole. LOOOL I can't imagine the look on those Marine's faces."
		},
		NoCancelButton = true,
		Option1 = {
			Label = "I'll raise your flag",
			JumpTo = function()
				object:FireServer("Start")
				return {
					Text = { "AYO THAT'S MY HOMIE. Look around for that rope. YOU GOT THIS." },
					Option1 = {
						Label = "On it."
					}
				}
			end
		},
		Option2 = {
			Label = "Absolutely not."
		}
	}
end

local function appendFlagOptions(p)
	local v18 = v

	if not v18 or typeof(p) ~= "table" or v18.Completed then
		return p
	end

	if v18.Active then
		if v12 then
			local v19 = 1

			while p["Option" .. v19] ~= nil do
				v19 += 1
			end

			p["Option" .. v19] = {
				Label = "About your flag...",
				JumpTo = function()
					return {
						Text = { "WHY ARE YOU TALKIN' TO ME, BRO. GET BACK IN THAT RING." }
					}
				end
			}
			return p
		elseif flag then
			local v19 = 1

			while p["Option" .. v19] ~= nil do
				v19 += 1
			end

			p["Option" .. v19] = {
				Label = "Got your rope",
				JumpTo = function()
					return {
						Text = { "THEN GO TIE IT ON! Get in that ring and STAY in it 'til my face is up top, bro." }
					}
				end
			}
			return p
		else
			local v19 = 1

			while p["Option" .. v19] ~= nil do
				v19 += 1
			end

			p["Option" .. v19] = {
				Label = "What am I doing again?",
				JumpTo = function()
					return {
						Text = { "BRO You're supposed to be finding some rope to then tie my flag up on that pole out front. CMON KEEP LOOKING!" }
					}
				end
			}
			return p
		end
	else
		local v19 = 1

		while p["Option" .. v19] ~= nil do
			v19 += 1
		end

		p["Option" .. v19] = {
			Label = "Flagpole",
			JumpTo = function()
				return (buildPitch(v18))
			end
		}
		return p
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function installParlus()
	if flag2 then
		return
	end

	flag2 = true
	task.spawn(function()
		local list = NPCList.List

		while not list.Parlus do
			task.wait(1)
		end

		local parlus = list.Parlus
		local dialogueCallback = parlus.DialogueCallback

		function parlus.DialogueCallback(...)
			local v18 = dialogueCallback(...)

			if typeof(v18) ~= "table" or typeof(v18.Get) ~= "function" then
				return v18
			end

			if v then
				return {
					Title = v18.Title,
					InternalQuestName = v18.InternalQuestName,
					Get = function(self)
						local v19 = v18:Get()
						return (appendFlagOptions(typeof(v19) ~= "table" and {
							Text = { "...? Speak." }
						} or v19))
					end
				}
			end

			return v18
		end
	end)
end

local FortressFlagpole = {}
FortressFlagpole.DataName = script.Name
FortressFlagpole.LoadWhenCompleted = true

function FortressFlagpole.OnLoad(object)
	v = object
	flag = false
	v12 = false
	v13 = 0
	v14 = 0
	v15 = false
	cleanupAll()
	armLoops(object)
	installParlus() -- equivalent call inferred; original call site unknown
	object:FireServer("Init")
	task.delay(4, function()
		if v == object and not v2 then
			object:FireServer("Init")
		end
	end)
end

FortressFlagpole.RemoteEvents = {
	Setup = function(p, p2, p3, p4, p5, value, p6, value2)
		if p5 == true then
			flag = true
		end

		if p.Completed then
			v13 = 1
			v14 = 1
			v15 = true
		elseif typeof(value) == "number" then
			v13 = value
			v14 = value
		end

		v12 = p6 == true

		if typeof(p2) ~= "CFrame" then
			p2 = nil
		end

		if typeof(value2) ~= "number" then
			value2 = v9
		end

		spawnFlag(p, p2, value2)

		if p.Completed then
			if v2 then
				playRaisedAnimation(v2)
			end

			disarmPrompt() -- equivalent call inferred; original call site unknown
			clearRing() -- equivalent call inferred; original call site unknown
		elseif not flag and (p4 == true or typeof(p3) == "CFrame") then
			if typeof(p3) ~= "CFrame" then
				p3 = nil
			end

			spawnRope(p3)
		end
	end,
	Started = function(_, p)
		if typeof(p) ~= "CFrame" then
			p = nil
		end

		spawnRope(p)
	end,
	RopeTaken = function(_)
		flag = true
		local v18 = v3
		v3 = nil

		if v18 then
			puffAway(v18)
			v18:Destroy()
		end
	end,
	Hoist = function(_, value, p)
		if typeof(value) == "number" then
			v13 = math.clamp(value, 0, 1)
		end

		v12 = p == true
	end,
	Shell = function(_, p, chargeTime, value2)
		if typeof(p) ~= "Vector3" or (typeof(chargeTime) ~= "number" or chargeTime ~= chargeTime or typeof(value2) ~= "number") then
			return
		end

		spawnShell(p, chargeTime, value2)
	end,
	Shelled = function(_)
		local v18 = {
			7,
			14,
			0.05,
			0.9
		}
		pcall(function()
			Effect.new("ShakeCam"):play(v18)
		end)
	end
}

function FortressFlagpole.OnComplete(_, p, p2)
	v12 = false
	disarmPrompt() -- equivalent call inferred; original call site unknown
	clearShells()

	if p2 then
		cleanupAll()
	elseif p then
		v13 = 1
		clearRing() -- equivalent call inferred; original call site unknown
	end
end

return FortressFlagpole