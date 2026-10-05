local createVector = vector.create
local AnimationClipProvider = game:GetService("AnimationClipProvider")
local ContentProvider = game:GetService("ContentProvider")
local frozen = table.freeze({
	ExpressionAnimationName = "LookoutDynamicExpression",
	ExpressionBlendTime = 0.15,
	ExpressionHoldTime = 5,
	HeadLoadTimeout = 5,
	EyebrowAnimationName = "LookoutEyebrowRaise",
	EyebrowRaiseTime = 0.35,
	EyebrowHoldTime = 5,
	Faces = {
		["1211"] = {
			HeadAssetId = 14483837205,
			EyebrowAccessoryId = 14483847230,
			MoodAssetId = 14483843681,
			MoodAnimationId = 104928178330034,
			FallbackChannels = {
				LeftInnerBrowRaiser = 0.65,
				RightInnerBrowRaiser = 0.65,
				JawDrop = 0.45
			}
		},
		["1164"] = {
			HeadAssetId = 13692956122,
			EyebrowAccessoryId = 13693113765,
			MoodAssetId = 13692993253,
			MoodAnimationId = 136330056147687,
			FallbackChannels = {
				LeftBrowLowerer = 0.35,
				RightInnerBrowRaiser = 0.45,
				RightOuterBrowRaiser = 0.7
			}
		},
		["171354436203665"] = {
			HeadAssetId = 111385667345306,
			MoodAssetId = 91878717569774,
			MoodAnimationId = 97843494660370,
			FallbackChannels = {
				MouthRight = 0.15,
				RightCheekRaiser = 0.2,
				RightDimpler = 0.55,
				RightEyeClosed = 0.12,
				RightLipCornerPuller = 0.75
			}
		},
		["240277183139860"] = {
			HeadAssetId = 108904425571417,
			MoodAssetId = 124258266581596,
			MoodAnimationId = 77379285024453,
			FallbackChannels = {
				LeftInnerBrowRaiser = 0.65,
				RightInnerBrowRaiser = 0.65,
				JawDrop = 0.4
			}
		},
		["178138757474440"] = {
			HeadAssetId = 136941665802161,
			MoodAssetId = 72329268435782,
			MoodAnimationId = 120981350769748,
			FallbackChannels = {
				LeftInnerBrowRaiser = 0.25,
				RightInnerBrowRaiser = 0.25,
				LeftLipCornerPuller = 0.4,
				RightLipCornerPuller = 0.4,
				JawDrop = 0.15
			}
		}
	}
})
local object = setmetatable({}, {
	__mode = "k"
})

local function getAnimator(instance)
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return nil
	end

	local animator = humanoid:FindFirstChildWhichIsA("Animator")

	if animator then
		return animator
	end

	local animator2 = Instance.new("Animator")
	animator2.Parent = humanoid
	return animator2
end

local function optimizeVisual(folder)
	local descendants = { folder }

	for _, descendant in folder:GetDescendants() do
		table.insert(descendants, descendant)
	end

	for _, part in descendants do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Massless = true
		part.AssemblyLinearVelocity = createVector(0, 0, 0)
		part.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

local function findBodyAttachment(folder, ancestor, name: string)
	for _, attachment in folder:GetDescendants() do
		if attachment:IsA("Attachment") and attachment.Name == name and not attachment:IsDescendantOf(ancestor) and attachment.Parent and attachment.Parent:IsA("BasePart") then
			return attachment
		end
	end

	return nil
end

local function hasValidAccessoryWeld(item, parent)
	local handle = item:FindFirstChild("Handle")

	if not (handle and handle:IsA("BasePart")) then
		return false
	end

	local accessoryWeld = handle:FindFirstChild("AccessoryWeld")
	local v2

	if accessoryWeld == nil then
		return false
	else
		v2 = accessoryWeld:IsA("Weld")

		if v2 then
			if accessoryWeld.Part0 == handle and accessoryWeld.Part1 ~= nil then
				return (accessoryWeld.Part1:IsDescendantOf(parent))
			else
				return false
			end
		end
	end

	return v2
end

local function createFallbackAccessoryWeld(item, parent)
	local handle = item:FindFirstChild("Handle")

	if not (handle and handle:IsA("BasePart")) then
		return false
	end

	local attachment = handle:FindFirstChildWhichIsA("Attachment")

	if not attachment then
		return false
	end

	local bodyAttachment = findBodyAttachment(parent, item, attachment.Name)

	if not (bodyAttachment and bodyAttachment.Parent and bodyAttachment.Parent:IsA("BasePart")) then
		return false
	end

	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0 = handle
	weld.Part1 = bodyAttachment.Parent
	weld.C0 = attachment.CFrame
	weld.C1 = bodyAttachment.CFrame
	weld.Parent = handle
	return true
end

local function reattachAccessories(humanoid, items)
	local parent = humanoid.Parent

	if not (parent and parent:IsA("Model")) then
		return
	end

	for _, folder in items do
		for _, weld in folder:GetDescendants() do
			if weld:IsA("Weld") and weld.Name == "AccessoryWeld" then
				weld:Destroy()
			end
		end

		if not pcall(humanoid.AddAccessory, humanoid, folder) then
			folder.Parent = parent
		end
	end

	pcall(humanoid.BuildRigFromAttachments, humanoid)

	for _, item in items do
		if hasValidAccessoryWeld(item, parent) then
			continue
		end

		item.Parent = parent

		if not createFallbackAccessoryWeld(item, parent) then
			warn((`[Lookout] Could not reattach accessory {item.Name}`))
		end
	end
end

local function createFacialCurve(folder, name: string, item: number, p: number, p2: number)
	local floatCurve = Instance.new("FloatCurve")
	floatCurve.Name = name
	floatCurve:InsertKey(FloatCurveKey.new(0, 0, Enum.KeyInterpolationMode.Linear))
	floatCurve:InsertKey(FloatCurveKey.new(p, item, Enum.KeyInterpolationMode.Linear))
	floatCurve:InsertKey(FloatCurveKey.new(p2, item, Enum.KeyInterpolationMode.Constant))
	floatCurve.Parent = folder
end

local function createLocalFacialTrack(parent, name: string, items, p: number, p2: number, priority)
	local faceControls = parent:FindFirstChildWhichIsA("FaceControls", true)
	local humanoid = parent:FindFirstChildWhichIsA("Humanoid")
	local v2

	if humanoid then
		v2 = humanoid:FindFirstChildWhichIsA("Animator")

		if not v2 then
			v2 = Instance.new("Animator")
			v2.Parent = humanoid
		end
	end

	if not (faceControls and v2) then
		return nil
	end

	local curveAnimation = Instance.new("CurveAnimation")
	curveAnimation.Name = name
	curveAnimation.Loop = false
	curveAnimation.Priority = priority
	local folder = Instance.new("Folder")
	folder.Name = faceControls.Name
	folder.Parent = curveAnimation

	for k, item in items do
		createFacialCurve(folder, k, item, p, p2)
	end

	curveAnimation.Parent = parent
	local success, result = pcall(
		AnimationClipProvider.RegisterActiveAnimationClip,
		AnimationClipProvider,
		curveAnimation
	)

	if not success then
		curveAnimation:Destroy()
		return nil
	end

	local animation = Instance.new("Animation")
	animation.Name = name
	animation.AnimationId = result
	animation.Parent = parent
	local success2, result2 = pcall(v2.LoadAnimation, v2, animation)

	if success2 then
		result2.Looped = false
		result2.Priority = priority
		return result2
	else
		animation:Destroy()
		curveAnimation:Destroy()
		return nil
	end
end

local function preloadExpressions(parent)
	local v2 = {}

	for k, face in frozen.Faces do
		local animation = Instance.new("Animation")
		animation.Name = `{frozen.ExpressionAnimationName}Preload_{k}`
		animation.AnimationId = `rbxassetid://{face.MoodAnimationId}`
		animation.Parent = parent
		table.insert(v2, animation)
	end

	task.spawn(function()
		for _, v3 in v2 do
			v3:Destroy()
		end
	end)
end

local function preloadAnimation(animation)
	local v2 = nil
	return pcall(ContentProvider.PreloadAsync, ContentProvider, { animation }, function(_, p)
		v2 = p
	end) and (v2 == nil or v2 == Enum.AssetFetchStatus.Success)
end

local function applyDescriptionWithTimeout(humanoid, appliedDescription)
	local v2 = false
	local v3 = false
	task.spawn(function()
		v3 = pcall(humanoid.ApplyDescriptionAsync, humanoid, appliedDescription)
		v2 = true
	end)
	local v4 = os.clock() + frozen.HeadLoadTimeout

	while not v2 and os.clock() < v4 do
		task.wait()
	end

	return v2 and v3
end

return table.freeze({
	applyHead = function(instance, dynamicHeadBundleId: string)
		local face = frozen.Faces[dynamicHeadBundleId]
		local headAssetId = face and face.HeadAssetId
		local humanoid = instance:FindFirstChildWhichIsA("Humanoid")
		local parent = instance.Parent

		if not headAssetId or not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 or not parent then
			return false
		end

		local clone = instance:Clone()
		clone.Name = "LookoutDynamicHeadStaging"
		clone:PivotTo(instance:GetPivot() - createVector(0, 500, 0))
		clone.Parent = parent
		local humanoid2 = clone:FindFirstChildWhichIsA("Humanoid")
		local head = clone:FindFirstChild("Head", true)

		if not (humanoid2 and head and head:IsA("BasePart")) then
			clone:Destroy()
			return false
		end

		local appliedDescription = humanoid2:GetAppliedDescription()

		for _, child in appliedDescription:GetChildren() do
			if child:IsA("BodyPartDescription") and child.BodyPart == Enum.BodyPart.Head then
				child:Destroy()
			elseif child:IsA("AccessoryDescription") and child.Name == "LookoutDynamicEyebrow" then
				child:Destroy()
			end
		end

		appliedDescription.Face = 0
		appliedDescription.Head = 0
		appliedDescription.MoodAnimation = face.MoodAssetId
		local bodyPartDescription = Instance.new("BodyPartDescription")
		bodyPartDescription.Name = "LookoutDynamicHead"
		bodyPartDescription.BodyPart = Enum.BodyPart.Head
		bodyPartDescription.AssetId = headAssetId
		bodyPartDescription.Color = head.Color
		bodyPartDescription.Parent = appliedDescription

		if face.EyebrowAccessoryId then
			local accessoryDescription = Instance.new("AccessoryDescription")
			accessoryDescription.Name = "LookoutDynamicEyebrow"
			accessoryDescription.AccessoryType = Enum.AccessoryType.Eyebrow
			accessoryDescription.AssetId = face.EyebrowAccessoryId
			accessoryDescription.IsLayered = true
			accessoryDescription.Order = 1
			accessoryDescription.Parent = appliedDescription
		end

		local v2 = applyDescriptionWithTimeout(humanoid2, appliedDescription)
		appliedDescription:Destroy()

		if not v2 then
			clone:Destroy()
			return false
		end

		local head2 = clone:FindFirstChild("Head", true)
		local v3

		if head2 then
			v3 = head2:FindFirstChildWhichIsA("FaceControls", true)
		end

		if not (head2 and head2:IsA("BasePart") and v3) then
			clone:Destroy()
			return false
		end

		local v4 = nil

		for _, accessory in clone:GetChildren() do
			if not accessory:IsA("Accessory") then
				continue
			end

			if not (accessory.AccessoryType == Enum.AccessoryType.Eyebrow or string.find(
				string.lower(accessory.Name),
				"brow",
				1,
				true
			)) then
				continue
			end

			v4 = accessory
			break
		end

		if face.EyebrowAccessoryId and not v4 then
			warn("[Lookout] The dynamic follower head loaded without its eyebrow accessory")
		end

		head2.Parent = nil

		if v4 then
			v4.Parent = nil
		end

		clone:Destroy()
		local v6 = {}

		for _, accessory in instance:GetChildren() do
			if not accessory:IsA("Accessory") then
				continue
			end

			accessory.Parent = nil
			table.insert(v6, accessory)
		end

		if humanoid:ReplaceBodyPartR15(Enum.BodyPartR15.Head, head2) then
			if v4 then
				table.insert(v6, v4)
			end

			reattachAccessories(humanoid, v6)
			optimizeVisual(head2)

			if v4 then
				optimizeVisual(v4)
			end

			for _, decal in head2:GetDescendants() do
				if decal:IsA("Decal") then
					decal:Destroy()
				end
			end

			instance:SetAttribute("DynamicHeadBundleId", dynamicHeadBundleId)
			local v7 = instance:FindFirstChildWhichIsA("FaceControls", true) ~= nil

			if v7 then
				preloadExpressions(instance)
			end

			return v7
		else
			head2:Destroy()

			if v4 then
				v4:Destroy()
			end

			reattachAccessories(humanoid, v6)
			return false
		end
	end,
	playExpression = function(parent, dynamicExpressionBundleId: string)
		local face = frozen.Faces[dynamicExpressionBundleId]
		local faceControls = parent:FindFirstChildWhichIsA("FaceControls", true)
		local humanoid = parent:FindFirstChildWhichIsA("Humanoid")
		local v2

		if humanoid then
			v2 = humanoid:FindFirstChildWhichIsA("Animator")

			if not v2 then
				v2 = Instance.new("Animator")
				v2.Parent = humanoid
			end
		end

		if not (face and faceControls and v2) then
			return false
		end

		local animation = Instance.new("Animation")
		animation.Name = `{frozen.ExpressionAnimationName}_{dynamicExpressionBundleId}`
		animation.AnimationId = `rbxassetid://{face.MoodAnimationId}`
		animation.Parent = parent
		local v3 = nil

		if preloadAnimation(animation) then
			local success, result = pcall(v2.LoadAnimation, v2, animation)

			if success then
				v3 = result
			end
		end

		if not v3 then
			animation:Destroy()
			v3 = createLocalFacialTrack(
				parent,
				`{frozen.ExpressionAnimationName}Fallback_{dynamicExpressionBundleId}`,
				face.FallbackChannels,
				frozen.ExpressionBlendTime,
				frozen.ExpressionHoldTime,
				Enum.AnimationPriority.Action
			)
		end

		if not v3 then
			return false
		end

		local v4 = object[parent]

		if v4 then
			v4:Stop(0.15)
			object[parent] = nil
		end

		v3.Looped = true
		v3.Priority = Enum.AnimationPriority.Action
		v3:Play(frozen.ExpressionBlendTime)
		object[parent] = v3
		parent:SetAttribute("DynamicExpressionBundleId", dynamicExpressionBundleId)
		return true
	end,
	playEyebrowRaise = function(parent)
		local localFacialTrack = createLocalFacialTrack(parent, frozen.EyebrowAnimationName, {
			RightInnerBrowRaiser = 0.8,
			RightOuterBrowRaiser = 1
		}, frozen.EyebrowRaiseTime, frozen.EyebrowHoldTime, Enum.AnimationPriority.Action4)

		if not localFacialTrack then
			return false
		end

		localFacialTrack:Play(0)
		return true
	end
})