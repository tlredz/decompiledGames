local createVector = vector.create
local PetUtil = {}
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local PetConstants = require(script.Parent.PetConstants)
local v = {}
local flag = false

local function ensureGroundIgnoreCache()
	if flag then
		return
	end

	flag = true
	local GROUND_IGNORE_TAG = PetConstants.GROUND_IGNORE_TAG

	for _, v2 in CollectionService:GetTagged(GROUND_IGNORE_TAG) do
		table.insert(v, v2)
	end

	CollectionService:GetInstanceAddedSignal(GROUND_IGNORE_TAG):Connect(function(p)
		table.insert(v, p)
	end)
	CollectionService:GetInstanceRemovedSignal(GROUND_IGNORE_TAG):Connect(function(p)
		local index = table.find(v, p)

		if index ~= nil then
			table.remove(v, index)
		end
	end)
end

local function getPetsAssetsSubfolder(childName: string)
	local assets = ServerStorage:FindFirstChild("Assets")
	local pets

	if assets == nil then
		pets = false
	else
		pets = assets:FindFirstChild("Pets")
	end

	local folder

	if pets == nil then
		folder = false
	else
		folder = pets:FindFirstChild(childName)
	end

	if folder == nil or not folder:IsA("Folder") then
		return nil
	end

	return folder
end

function PetUtil.GetCharacterWorldScale(instance)
	local scale = instance:GetScale()
	local v2 = (scale ~= scale or scale <= 0) and 1 or scale

	if v2 ~= 1 then
		return v2
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local bodyHeightScale = humanoid and humanoid:FindFirstChild("BodyHeightScale")

	if bodyHeightScale then
		local value = bodyHeightScale.Value

		if value == value and value > 0 then
			return value
		end
	end

	return 1
end

function PetUtil.GetPetModelTemplate(childName: string)
	local petsAssetsSubfolder = getPetsAssetsSubfolder("Pets")
	local model

	if petsAssetsSubfolder == nil then
		model = false
	else
		model = petsAssetsSubfolder:FindFirstChild(childName)
	end

	if model == nil or not model:IsA("Model") then
		return nil
	end

	return model
end

function PetUtil.GetPetInteractionModelTemplate(childName: string)
	local petsAssetsSubfolder = getPetsAssetsSubfolder("Models")
	local model

	if petsAssetsSubfolder == nil then
		model = false
	else
		model = petsAssetsSubfolder:FindFirstChild(childName)
	end

	if model == nil or not model:IsA("Model") then
		return nil
	end

	return model
end

function PetUtil.GetPetRootPart(instance)
	if instance.PrimaryPart == nil then
		return instance:FindFirstChildWhichIsA("BasePart")
	end

	return instance.PrimaryPart
end

function PetUtil.GetPetSound(p, childName: string)
	local petRootPart = PetUtil.GetPetRootPart(p)

	if petRootPart == nil then
		return nil
	end

	local sound = petRootPart:FindFirstChild(childName)

	if sound == nil or not sound:IsA("Sound") then
		return nil
	end

	return sound
end

function PetUtil.PlayPetSound(p, p2: string)
	local petSound = PetUtil.GetPetSound(p, p2)

	if petSound ~= nil then
		petSound:Play()
	end
end

function PetUtil.StopPetSound(p, p2: string)
	local petSound = PetUtil.GetPetSound(p, p2)

	if petSound ~= nil and petSound.IsPlaying then
		petSound:Stop()
	end
end

function PetUtil.GetPetHitboxPart(instance)
	return (instance:FindFirstChild("Hitbox"))
end

function PetUtil.GetPetHeartsEmitter(p)
	local petHitboxPart = PetUtil.GetPetHitboxPart(p)
	local emitter

	if petHitboxPart == nil then
		emitter = false
	else
		emitter = petHitboxPart:FindFirstChild(PetConstants.HEARTS_PARTICLE_NAME)
	end

	if emitter == nil or not emitter:IsA("ParticleEmitter") then
		return nil
	end

	return emitter
end

function PetUtil.ShowPetHearts(p, p2: number?)
	local petHeartsEmitter = PetUtil.GetPetHeartsEmitter(p)

	if petHeartsEmitter == nil then
		return
	end

	local v2 = p2 or PetConstants.HEARTS_PARTICLE_DURATION
	petHeartsEmitter.Enabled = true
	task.delay(v2, function()
		if petHeartsEmitter.Parent ~= nil then
			petHeartsEmitter.Enabled = false
		end
	end)
end

function PetUtil.SetPetDisplayName(p, text: string)
	local petRootPart = PetUtil.GetPetRootPart(p)
	local nameGUI = petRootPart and petRootPart:FindFirstChild("NameGUI")
	local nameTxt = nameGUI and nameGUI:FindFirstChild("NameTxt")

	if nameTxt and nameTxt:IsA("TextLabel") then
		nameTxt.Text = text
	end
end

function PetUtil.SetPetDisplayNameColor(p, p2: string)
	local success, result = pcall(BrickColor.new, p2)

	if not success or result == nil then
		return
	end

	local petRootPart = PetUtil.GetPetRootPart(p)
	local nameGUI = petRootPart and petRootPart:FindFirstChild("NameGUI")
	local nameTxt = nameGUI and nameGUI:FindFirstChild("NameTxt")

	if nameTxt and nameTxt:IsA("TextLabel") then
		nameTxt.TextColor3 = result.Color
	end
end

function PetUtil.GetPetsFolderName(p)
	return p.Name .. PetConstants.PETS_FOLDER_NAME_SUFFIX
end

function PetUtil.GetPlayerFromPetsFolder(instance)
	if instance.Parent ~= workspace then
		return nil
	end

	local PETS_FOLDER_NAME_SUFFIX = PetConstants.PETS_FOLDER_NAME_SUFFIX

	if instance.Name:sub(-#PETS_FOLDER_NAME_SUFFIX) ~= PETS_FOLDER_NAME_SUFFIX then
		return nil
	end

	local v2 = instance.Name:sub(1, #instance.Name - #PETS_FOLDER_NAME_SUFFIX)

	if v2 == "" then
		return nil
	end

	local Players2 = game:GetService("Players")
	return Players2:FindFirstChild(v2)
end

function PetUtil.GetFollowerOffset(p: number, p2: number)
	if p2 <= 1 then
		return createVector(-2, -1.5, -2)
	end

	local v2 = math.floor((p - 1) / 6)
	local v3 = (p - 1) % 6
	local v4 = math.min(p2 - v2 * 6, 6)
	local v5 = (v2 + 1) * 2.5
	local v6 = v3 / v4 * 3.141592653589793 * 2
	return (Vector3.new(math.sin(v6) * v5, -1.5, math.cos(v6) * v5))
end

function PetUtil.ComputeRootPartAboveBottom(instance, p)
	return p.Position.Y - instance:GetPivot().Position.Y
end

function PetUtil.BuildGroundRaycastExclude(items)
	ensureGroundIgnoreCache()
	local clone = table.clone(v)

	if items ~= nil then
		for _, item in items do
			table.insert(clone, item)
		end
	end

	for _, v2 in Players:GetPlayers() do
		local character = v2.Character

		if character ~= nil then
			table.insert(clone, character)
		end

		local child = workspace:FindFirstChild(PetUtil.GetPetsFolderName(v2))

		if child ~= nil then
			table.insert(clone, child)
		end
	end

	return clone
end

function PetUtil.GetGroundPartBelow(vector2: Vector3, p: number, p2: number, p3)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = PetUtil.BuildGroundRaycastExclude(p3)
	local v2 = vector2 + createVector(0, 1, 0)
	local v3 = p + 1 + p2
	local raycastResult = workspace:Raycast(v2, Vector3.new(0, -v3, 0), raycastParams)

	if raycastResult == nil then
		return nil
	end

	return raycastResult.Instance
end

function PetUtil.GroundPosition(vector2: Vector3, p: number, p2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = PetUtil.BuildGroundRaycastExclude(p2)
	local vector3 = Vector3.new(vector2.X, vector2.Y + PetConstants.GROUND_RAYCAST_START_OFFSET, vector2.Z)
	local raycastResult = workspace:Raycast(
		vector3,
		Vector3.new(0, -PetConstants.GROUND_RAYCAST_LENGTH, 0),
		raycastParams
	)

	if raycastResult == nil then
		return vector2
	end

	return (Vector3.new(vector2.X, raycastResult.Position.Y + p, vector2.Z))
end

function PetUtil.GetOwnerFlatCFrame(instance)
	local position = instance.Position
	local vector2 = Vector3.new(instance.CFrame.LookVector.X, 0, instance.CFrame.LookVector.Z)

	if vector2.Magnitude < 0.001 then
		return CFrame.new(position)
	end

	return CFrame.lookAt(position, position + vector2.Unit)
end

function PetUtil.GetOwnerFlatRotation(p)
	return PetUtil.GetOwnerFlatCFrame(p).Rotation
end

function PetUtil.ComputeFollowTargetPosition(p, p2: number, p3: number, p4: number, p5)
	local followerOffset = PetUtil.GetFollowerOffset(p2, p3)
	local v2 = PetUtil.GetOwnerFlatCFrame(p) * followerOffset
	return PetUtil.GroundPosition(v2, p4, p5)
end

function PetUtil.ComputePetInteractTarget(instance, vector2: Vector3, p: number, p2)
	local position = instance.Position
	local vector3 = Vector3.new(vector2.X - position.X, 0, vector2.Z - position.Z)

	if vector3.Magnitude < 0.001 then
		vector3 = Vector3.new(instance.CFrame.LookVector.X, 0, instance.CFrame.LookVector.Z)
	end

	local v2 = position + (not (vector3.Magnitude > 0.001) and createVector(0, 0, -1) or vector3.Unit) * PetConstants.PET_INTERACT_FORWARD_OFFSET
	local groundPosition = PetUtil.GroundPosition(v2, p, p2)
	local v3 = position - groundPosition
	return groundPosition, (Vector3.new(v3.X, 0, v3.Z))
end

function PetUtil.PlaceModelOnGround(instance, cframe: CFrame, p)
	instance:PivotTo(cframe)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = PetUtil.BuildGroundRaycastExclude(p)
	local vector2 = Vector3.new(
		cframe.Position.X,
		cframe.Position.Y + PetConstants.GROUND_RAYCAST_START_OFFSET,
		cframe.Position.Z
	)
	local raycastResult = workspace:Raycast(
		vector2,
		Vector3.new(0, -PetConstants.GROUND_RAYCAST_LENGTH, 0),
		raycastParams
	)
	local v2

	if raycastResult == nil then
		v2 = cframe.Position.Y
	else
		v2 = raycastResult.Position.Y
	end

	local v3 = CFrame.new(cframe.Position.X, v2, cframe.Position.Z) * cframe.Rotation
	instance:PivotTo(v3)
	return v3
end

function PetUtil.GetAnimationsFolder(instance)
	local animations = instance:FindFirstChild("Animations", true)

	if animations == nil or not animations:IsA("Folder") then
		return nil
	end

	return animations
end

function PetUtil.GetPlayerCarryAnimationId(p)
	local animationsFolder = PetUtil.GetAnimationsFolder(p)
	local child

	if animationsFolder == nil then
		child = false
	else
		child = animationsFolder:FindFirstChild(PetConstants.CARRY_ANIM_NAME)
	end

	if child ~= nil then
		local attribute = child:GetAttribute(PetConstants.ATTR_PLAYER_CARRY)

		if typeof(attribute) == "string" and attribute ~= "" then
			return attribute
		end
	end

	return PetConstants.PLAYER_CARRY_ANIMATION_ID
end

function PetUtil.GetFeedBowlOffset(p)
	local animationsFolder = PetUtil.GetAnimationsFolder(p)
	local child

	if animationsFolder == nil then
		child = false
	else
		child = animationsFolder:FindFirstChild(PetConstants.FEED_ANIM_NAME)
	end

	if child ~= nil then
		local attribute = child:GetAttribute(PetConstants.ATTR_FEED_BOWL_OFFSET)

		if typeof(attribute) == "Vector3" then
			return attribute
		end
	end

	return (Vector3.new(0, 0, PetConstants.FEED_BOWL_FORWARD_OFFSET))
end

function PetUtil.GetFeedBowlScale(p)
	local animationsFolder = PetUtil.GetAnimationsFolder(p)
	local child

	if animationsFolder == nil then
		child = false
	else
		child = animationsFolder:FindFirstChild(PetConstants.FEED_ANIM_NAME)
	end

	if child ~= nil then
		local attribute = child:GetAttribute(PetConstants.ATTR_FEED_BOWL_SCALE)

		if typeof(attribute) == "number" and attribute > 0 then
			return attribute
		end
	end

	return 1
end

function PetUtil.GetAnimator(instance)
	local animationController = instance:FindFirstChildWhichIsA("AnimationController", true)

	if animationController == nil then
		return nil
	end

	local animator = animationController:FindFirstChildWhichIsA("Animator", true)

	if animator == nil then
		return nil
	end

	return animator
end

local function waitForAnimationLoader(instance, p: number)
	local animator = PetUtil.GetAnimator(instance)

	if animator ~= nil then
		return animator
	end

	local v2 = os.clock() + p

	while os.clock() < v2 do
		task.wait()
		local animator2 = PetUtil.GetAnimator(instance)

		if animator2 ~= nil then
			return animator2
		end
	end

	return nil
end

function PetUtil.LoadPetAnimationTracks(instance)
	local v2 = PetUtil.GetAnimationsFolder(instance) or instance:WaitForChild("Animations", 5)

	if v2 == nil then
		warn((`PetUtil.LoadPetAnimationTracks: no Animations folder found for "{instance.Name}"`))
		return nil
	end

	local animator = waitForAnimationLoader(instance, 5)

	if animator == nil then
		warn((`PetUtil.LoadPetAnimationTracks: no animation loader found for "{instance.Name}"`))
		return nil
	end

	local function load(childName: string, looped: boolean)
		local animation = v2:FindFirstChild(childName) or v2:WaitForChild(childName, 5)

		if animation == nil or not animation:IsA("Animation") then
			warn((`PetUtil.LoadPetAnimationTracks: missing Animation "{childName}" on "{instance.Name}"`))
			return nil
		end

		local track = animator:LoadAnimation(animation)
		track.Looped = looped
		track.Priority = Enum.AnimationPriority.Movement
		return track
	end

	local v3 = {
		idle = load("IdleAnim", true),
		walk = load("WalkAnim", true),
		run = load("RunAnim", true)
	}

	if v3.idle == nil and v3.walk == nil and v3.run == nil then
		return nil
	end

	return v3
end

return PetUtil