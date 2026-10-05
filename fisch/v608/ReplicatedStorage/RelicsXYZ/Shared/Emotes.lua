local createVector = vector.create
local parent = script.Parent
local Attachments = require(parent.Attachments)
local Marketplace = require(parent.Marketplace)
local RunContext = require(parent.RunContext)
local GamePasses = require(parent.GamePasses)
local Migration = require(parent.Migration)
local Ownership = require(parent.Ownership)
local JointTree = require(parent.JointTree)
local Promise = require(parent.Promise)
local Recents = require(parent.Recents)
local Bundles = require(parent.Bundles)
local Signal = require(parent.Signal)
local UserId = require(parent.UserId)
local Trove = require(parent.Trove)
local Auras = require(parent.Auras)
local Tags = require(parent.Tags)
local Guid = require(parent.Guid)
local AssetService = game:GetService("AssetService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local count = 0
local _cache = script:FindFirstChild("_cache")
local emoteAdded = Signal.new()
local emoteRemoved = Signal.new()
local ownerAdded = Signal.new()
local ownerRemoved = Signal.new()
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}

local function bindModelByNamedAttachments(ancestor, instance)
	local result = {}
	local identities = {}

	for _, attachment2 in instance:QueryDescendants("Attachment") do
		if attachment2:IsDescendantOf(ancestor) then
			continue
		end

		local attachment = ancestor:QueryDescendants((`Attachment #{attachment2.Name}`))[1]

		if not (attachment and attachment:IsA("Attachment")) then
			continue
		end

		local rigidConstraint = Instance.new("RigidConstraint")
		rigidConstraint.Attachment0 = attachment
		rigidConstraint.Attachment1 = attachment2
		rigidConstraint.Parent = attachment
		table.insert(result, rigidConstraint)
	end

	local v13, v14 = JointTree.Build(ancestor)
	identities[v14] = CFrame.identity
	JointTree.Solve(v13, identities)

	for _, parent2 in ancestor:QueryDescendants("BasePart") do
		if identities[parent2] then
			continue
		end

		local attachment = v14:FindFirstChildWhichIsA("Attachment")
		local attachment2 = Instance.new("Attachment")
		attachment2.Parent = parent2

		if not attachment or attachment == attachment2 then
			local primaryPart = instance.PrimaryPart
			attachment = primaryPart and primaryPart:FindFirstChildWhichIsA("Attachment")
		end

		if not attachment then
			continue
		end

		local rigidConstraint = Instance.new("RigidConstraint")
		rigidConstraint.Attachment0 = attachment
		rigidConstraint.Attachment1 = attachment2
		attachment2.WorldCFrame = attachment.WorldCFrame
		rigidConstraint.Parent = attachment2
		table.insert(result, rigidConstraint)
	end

	return result
end

local function onGroupDanceAdded(instance)
	local v13 = {
		InstrumentNames = {},
		InstrumentData = {}
	}

	for _, child in instance:GetChildren() do
		table.insert(v13.InstrumentNames, child.Name)
		v13.InstrumentData[child.Name] = {
			Sound = child:FindFirstChildOfClass("Sound"),
			Model = child:FindFirstChildOfClass("Model"),
			Animation = child:FindFirstChildOfClass("Animation")
		}
	end

	v11[instance.Name] = v13
end

local function onGroupDancerAdded(model)
	if not model:IsA("Model") then
		return
	end

	local relicsDanceGroup = model:GetAttribute("RelicsDanceGroup")
	local relicsDanceName = model:GetAttribute("RelicsDanceName")

	if type(relicsDanceGroup) ~= "string" or type(relicsDanceName) ~= "string" then
		return
	end

	local v13 = v11[relicsDanceName]
	local v14 = v12[relicsDanceGroup]

	if not v14 then
		v14 = {
			StartTime = os.clock(),
			DanceName = relicsDanceName,
			ActiveRoles = {}
		}
		v12[relicsDanceGroup] = v14
	end

	local name = nil

	for _, instrumentName in v13.InstrumentNames do
		if v14.ActiveRoles[instrumentName] then
			continue
		end

		name = instrumentName
		break
	end

	if name then
		local v17 = v13.InstrumentData[name]
		local maid = Trove.new()
		maid:AttachToInstance(model)
		v14.ActiveRoles[name] = maid
		maid:Connect(model.AncestryChanged, function()
			if not model.Parent then
				maid:Clean()
			end
		end)
		maid:Add(function()
			v14.ActiveRoles[name] = nil

			if not next(v14.ActiveRoles) then
				v12[relicsDanceGroup] = nil
			end
		end)
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		local animation = v17.Animation
		local track

		if animation and animator then
			track = animator:LoadAnimation(animation)
			local assert_2 = assert(track)
			assert_2.Priority = Enum.AnimationPriority.Action
			track.Looped = true
			track:Play()
			maid:Add(track)
		else
			track = nil
		end

		local sound = v17.Sound

		if sound then
			local clone = sound:Clone()
			clone:SetAttribute("SyncGroup", relicsDanceGroup)
			clone:AddTag("AudioSync")
			clone.Archivable = false
			local timeLength

			if clone.PlaybackRegionsEnabled then
				timeLength = clone.PlaybackRegion.Max - clone.PlaybackRegion.Min
			else
				timeLength = clone.TimeLength
			end

			local v18 = not clone.PlaybackRegionsEnabled and 0 or clone.PlaybackRegion.Min
			clone.TimePosition = (os.clock() - v14.StartTime) % timeLength + v18 + 0.005
			clone.Parent = model.PrimaryPart
			clone:Play()

			if track then
				local RunService2 = game:GetService("RunService")
				maid:Connect(RunService2.Heartbeat, function()
					track:AdjustSpeed(clone.PlaybackLoudness / 100)
				end)
			end

			maid:Add(clone)
		end

		local model2 = v17.Model

		if model2 then
			local clone = model2:Clone()
			clone.Name = name
			clone.Archivable = false

			for _, v18 in bindModelByNamedAttachments(clone, model) do
				maid:Add(v18)
			end

			clone.Parent = model
			maid:Add(clone)
		end
	end
end

local function getEmotes()
	return table.clone(v5)
end

local function getEmoteByAnimation(p)
	local v13 = tonumber(p.AnimationId:match("%d+$"))

	if v13 then
		return v6[v13]
	end

	return nil
end

local function getEmoteByAnimationId(value)
	if type(value) == "string" then
		value = tonumber(value:match("%d+$"))
	end

	if value then
		return v6[value]
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEmoteById(p: number, p2)
	return v8[Ownership.KeyOf(p, p2)]
end

local function getEmoteBySongId(value)
	if typeof(value) == "Content" then
		local uri = value.Uri
		return uri and v7[uri]
	end

	if type(value) == "number" then
		return v7[`rbxassetid://{value}`]
	end

	return v7[value]
end

local function attachEffectToCharacter(effect, parent2, userId: number?)
	local model = Instance.new("Model")
	model:SetAttribute("UserId", userId)
	model:SetAttribute("EmoteEffect", true)
	model.Name = "EffectModel"
	effect.Parent = model
	model.PrimaryPart = effect
	bindModelByNamedAttachments(model, parent2)
	model:ScaleTo(parent2:GetScale())
	model.Parent = parent2
	return model
end

local function setupEffect(effect, _: number?)
	if not (effect and effect.Archivable) then
		return nil
	end

	local clone = effect:Clone()
	local parent2

	if clone:IsA("Model") then
		local boundingBox, size = clone:GetBoundingBox()
		parent2 = Instance.new("Part")
		parent2.Name = "Primary"
		parent2.Size = size
		parent2.CFrame = boundingBox
		parent2.Anchored = true
		parent2.Massless = true
		parent2.CanQuery = false
		parent2.CanTouch = false
		parent2.CanCollide = false
		parent2.AudioCanCollide = false
		parent2.EnableFluidForces = false
		local attachment = Instance.new("Attachment")
		attachment.Name = "PrimaryMount"
		attachment.Parent = parent2

		for _, parent3 in clone:QueryDescendants("BasePart") do
			local attachment2 = Instance.new("Attachment")
			attachment2.Name = `EffectMount_{parent3.Name}`
			attachment2.Parent = parent3
			attachment2.WorldCFrame = parent2.CFrame
			local rigidConstraint = Instance.new("RigidConstraint")
			rigidConstraint.Attachment0 = attachment
			rigidConstraint.Attachment1 = attachment2
			rigidConstraint.Parent = parent2
		end
	else
		parent2 = clone
	end

	if not parent2:IsA("BasePart") then
		return
	end

	parent2:SetAttribute("EmoteEffect", true)
	return parent2
end

local function playEmoteLocal(data, p)
	if not data then
		warn("Failed to play emote song! No emote given.")
		return
	end

	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character
	local animate = character and character:FindFirstChild("Animate")
	local playEmote = animate and animate:FindFirstChild("PlayEmote")

	if playEmote and playEmote:IsA("BindableFunction") then
		if data.SongId then
			local connection = nil
			local v13 = Guid.Create()
			local formatted = `rbxassetid://{data.SongId}`
			playEmote:Invoke(data.Animation)
			p.AddSongOverride(v13, {
				Song = formatted,
				Priority = 1000,
				SongTitle = data.SongTitle,
				SongArtist = data.SongArtist
			})
			localPlayer:SetAttribute("RELICSxyz_EmoteSong", formatted)
			connection = localPlayer:GetAttributeChangedSignal("RELICSxyz_EmoteSong"):Connect(function()
				if localPlayer:GetAttribute("RELICSxyz_EmoteSong") ~= formatted then
					p.RemoveSongOverride(v13)
					connection:Disconnect()
				end
			end)
			Recents.PushRecentEmote(data.Name)
		else
			playEmote:Invoke(data.Animation)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEffect(animation, songId: number?)
	local effect = animation and animation:FindFirstChild("Effect")

	if effect and effect.Archivable then
		return setupEffect(effect, songId)
	end
end

if RunContext.IsServer or RunContext.IsEdit then
	local function onCharacterAdded(humanoidModelFromUserIdAsync)
		local userId = nil

		if RunContext.IsEdit then
			userId = UserId.Get()
		else
			local playerFromCharacter = Players:GetPlayerFromCharacter(humanoidModelFromUserIdAsync)

			if playerFromCharacter then
				userId = playerFromCharacter.UserId
			end
		end

		local humanoid = humanoidModelFromUserIdAsync:FindFirstChildOfClass("Humanoid")

		if not userId then
			return
		end

		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		local v13 = v9[userId]

		if v13 then
			v13:Clean()
		end

		local v14 = Trove.new()
		v9[userId] = v14

		if humanoid and animator then
			v14:Connect(animator.AnimationPlayed, function(p)
				local v15 = tonumber(p.Animation.AnimationId:match("%d+$"))
				local v16 = v15 and v6[v15]
				local rootPart = humanoid.RootPart

				if v16 and rootPart then
					local v17 = v10[userId]

					if v17 then
						v17:Clean()
					end

					local maid = Trove.new()
					local animation = v16.Animation
					local effect = getEffect(animation, v16.SongId) -- equivalent call inferred; original call site unknown

					if effect then
						attachEffectToCharacter(effect, humanoidModelFromUserIdAsync, userId)
						Auras.BindEffect(effect)
						effect.Parent = humanoidModelFromUserIdAsync
						maid:Add(effect)
					end

					local playerByUserId = Players:GetPlayerByUserId(userId)
					local songId2 = v16.SongId

					if playerByUserId then
						if songId2 then
							playerByUserId:SetAttribute("RELICSxyz_EmoteSong", (`rbxassetid://{songId2}`))
						end

						playerByUserId:SetAttribute("RELICSxyz_EmoteAnimation", animation.AnimationId)
					end

					rootPart:SetAttribute("RelicsEmoteName", v16.Name)
					rootPart:AddTag("RelicsEmoteNode")
					v10[userId] = maid
					maid:Add(function()
						local relicsEmoteSync = humanoidModelFromUserIdAsync:FindFirstChild("RelicsEmoteSync")

						if relicsEmoteSync then
							relicsEmoteSync:Destroy()
						end

						rootPart:SetAttribute("RelicsEmoteName", nil)
						rootPart:RemoveTag("RelicsEmoteNode")
						v10[userId] = nil
					end)
					maid:Add(p.Stopped:Once(function()
						if rootPart:GetAttribute("RelicsEmoteName") == v16.Name and playerByUserId then
							if songId2 then
								playerByUserId:SetAttribute("RELICSxyz_EmoteSong", nil)
							end

							playerByUserId:SetAttribute("RELICSxyz_EmoteAnimation", nil)
							maid:Clean()
						end
					end))
				end
			end)
		end
	end

	local function onPlayerAdded(player)
		if RunContext.IsEdit then
			local humanoidModelFromUserIdAsync = Players:CreateHumanoidModelFromUserIdAsync((UserId.Get()))
			task.spawn(onCharacterAdded, humanoidModelFromUserIdAsync)
		else
			local character = player.Character
			player.CharacterAdded:Connect(onCharacterAdded)

			if character and character.Parent then
				task.spawn(onCharacterAdded, character)
			end
		end

		for _, v13 in Bundles.GetBundles() do
			if v13.Type ~= "PurchaseBundle" then
				continue
			end

			for _, item in v13.Items do
				local assetId = Bundles.ResolveAssetId(item)
				local v14 = v8[Ownership.KeyOf(assetId.Id, assetId.InfoType)]

				if v14 then
					v14.Animation:SetAttribute(`Owner{player.UserId}`, true)
				end
			end
		end
	end

	local function onPlayerRemoving(p)
		local formatted = `Owner{p.UserId}`

		if not _cache then
			return
		end

		for _, child in _cache:GetChildren() do
			child:SetAttribute(formatted, nil)
		end
	end

	local function onPurchaseFinished(p, p2: number, p3)
		local emoteById = getEmoteById(p2, p3) -- equivalent call inferred; original call site unknown

		if emoteById then
			emoteById.Animation:SetAttribute(`Owner{p.UserId}`, true)
		end

		if Bundles.IsUnlockingAssetId(p2) then
			for _, item in Bundles.GetBundleByAssetId(p2).Items do
				local assetId = Bundles.ResolveAssetId(item)
				local v13 = v8[Ownership.KeyOf(assetId.Id, assetId.InfoType)]

				if v13 then
					v13.Animation:SetAttribute(`Owner{p.UserId}`, true)
				end
			end
		end
	end

	if RunContext.IsEdit then
		local v13 = UserId.Get()
		task.spawn(function()
			onCharacterAdded(Players:CreateHumanoidModelFromUserIdAsync(v13))
		end)
	else
		for _, v13 in Players:GetPlayers() do
			task.spawn(onPlayerAdded, v13)
		end

		Players.PlayerAdded:Connect(onPlayerAdded)
		Players.PlayerRemoving:Connect(onPlayerRemoving)
		Tags.Bind("RelicsGroupDance", onGroupDanceAdded)
		Tags.BindWithMaid("RelicsGroupDancer", onGroupDancerAdded)
	end

	Marketplace.PromptPurchaseFinished:Connect(onPurchaseFinished)
	Tags.BindWithMaid(GamePasses.ContentTag, function(instance, object)
		local gamePass = GamePasses.FindGamePassFromContent(instance)

		if not gamePass or gamePass.RelicsAssetType ~= "EMOTE" then
			return
		end

		Promise.new(function(callback, callback2)
			if instance:IsA("Animation") then
				instance:RemoveTag("RelicsEmote")
				callback(instance)
			elseif instance:IsA("Configuration") then
				local emoteId = instance:GetAttribute("EmoteId")
				local animationId = instance:GetAttribute("AnimationId")

				if animationId then
					local animation = Instance.new("Animation")
					animation.Name = instance.Name
					animation.Parent = instance

					if type(animationId) == "string" then
						animation.AnimationId = animationId
					elseif typeof(animationId) == "Content" then
						animation.AnimationContent = animationId
					elseif type(animationId) == "number" then
						animation.AnimationId = `rbxassetid://{animationId}`
					end

					callback(animation)
				elseif type(emoteId) == "number" then
					local assetAsync = AssetService:LoadAssetAsync(emoteId)
					local animation = assetAsync and assetAsync:FindFirstChildOfClass("Animation")

					if animation then
						callback(animation)
					end
				else
					callback2("No valid animation found for emote content.", instance:GetFullName())
				end
			end
		end):andThen(function(parent2)
			local songId = instance:GetAttribute("SongId")
			local songTitle = instance:GetAttribute("SongTitle")
			local songArtist = instance:GetAttribute("SongArtist")
			local effectName = instance:GetAttribute("EffectName")
			local v13 = type(effectName) == "string" and game:QueryDescendants((`.RelicsModel #{effectName}`))[1]

			if v13 then
				local clone = v13:Clone()
				clone:RemoveTag("RelicsModel")
				clone.Name = "Effect"
				clone.Parent = parent2
			end

			parent2:SetAttribute("ProductId", gamePass.ProductId)
			parent2:SetAttribute("ProductType", gamePass.ProductType)

			if songId then
				parent2:SetAttribute("SongId", songId)
			end

			if songTitle then
				parent2:SetAttribute("SongTitle", songTitle)
			end

			if songArtist then
				parent2:SetAttribute("SongArtist", songArtist)
			end

			if gamePass.LegacyIds and #gamePass.LegacyIds > 0 then
				local v14 = {}

				for _, legacyId in gamePass.LegacyIds do
					table.insert(v14, (`{legacyId.Id}:{legacyId.InfoType.Name}`))
				end

				parent2:SetAttribute("LegacyIds", table.concat(v14, ","))
			else
				parent2:SetAttribute("LegacyIds", nil)
			end

			local basePart = parent2:FindFirstChildWhichIsA("BasePart")

			if basePart then
				local auraMount = basePart:FindFirstChild("AuraMount")

				if auraMount and auraMount:IsA("Attachment") then
					auraMount.Name = "RootAttachment"
				end

				local attachment3 = Attachments.FindFirstCharacterAttachment(basePart)

				if not attachment3 then
					attachment3 = Instance.new("Attachment")
					attachment3.CFrame = basePart.PivotOffset
					attachment3.Name = "RootAttachment"
					attachment3.Parent = basePart
				end

				for _, descendant in basePart:GetDescendants() do
					if descendant:IsA("WeldConstraint") then
						descendant:Destroy()
					elseif descendant:IsA("JointInstance") then
						local attachment = Instance.new("Attachment")
						attachment.CFrame = descendant.C0
						attachment.Parent = descendant.Part0
						local attachment2 = Instance.new("Attachment")
						attachment2.CFrame = descendant.C1
						attachment2.Parent = descendant.Part1
						local v15

						if descendant:IsA("Motor6D") then
							v15 = Instance.new("AnimationConstraint")
							v15.IsKinematic = true
						else
							v15 = Instance.new("RigidConstraint")
						end

						v15.Name = descendant.Name
						v15.Attachment0 = attachment
						v15.Attachment1 = attachment2
						v15.Parent = descendant.Part1
						descendant:Destroy()
					elseif (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Bone")) and not descendant:HasTag("NoAuraVFX") then
						if type((descendant:GetAttribute("Class"))) ~= "string" then
							descendant:SetAttribute("Class", "Loudness")
						end

						descendant:AddTag("RelicsAuraFx")
					end
				end

				local v15, v16 = JointTree.Build(basePart, basePart)
				local v17 = {
					[v16] = CFrame.identity
				}
				basePart.Name = "Effect"
				JointTree.Solve(v15, v17)

				for _, parent3 in basePart:QueryDescendants("BasePart") do
					if v17[parent3] or Attachments.FindFirstCharacterAttachment(parent3) or not attachment3 then
						continue
					end

					local attachment = Instance.new("Attachment")
					attachment.Parent = parent3
					attachment.WorldCFrame = attachment3.WorldCFrame
					local rigidConstraint = Instance.new("RigidConstraint")
					rigidConstraint.Attachment0 = attachment3
					rigidConstraint.Attachment1 = attachment
					rigidConstraint.Parent = attachment
				end
			end

			parent2.Name = gamePass.Name
			parent2:SetAttribute("LimitedInfo", gamePass.Id)
			parent2:AddTag("RelicsEmote")
			object:Add(parent2)
		end)
	end)
elseif RunContext.IsClient then
	local localPlayer = Players.LocalPlayer

	local function onCharacterAdded(instance)
		local animate = instance:WaitForChild("Animate", 5)
		local playEmote = animate and animate:WaitForChild("PlayEmote", 5)

		if not (playEmote and playEmote:IsA("BindableFunction")) then
			return
		end

		local humanoid = instance:WaitForChild("Humanoid", 5)

		if not (humanoid and humanoid:IsA("Humanoid")) then
			return
		end

		local animator = humanoid and humanoid:WaitForChild("Animator", 5)

		if not (animator and animator:IsA("Animator")) then
			return
		end

		local function onPlayEmote(animation)
			local v13 = tonumber(animation.AnimationId:match("%d+$"))
			local v14 = v13 and v6[v13]
			local lifeAgnostic, manualCancel, tankControls, allowWalk, walkSpeed

			if v14 then
				lifeAgnostic = v14.LifeAgnostic or false
				manualCancel = v14.ManualCancel or false
				tankControls = v14.TankControls or false
				allowWalk = v14.AllowWalk or false
				walkSpeed = v14.WalkSpeed or 1
			else
				lifeAgnostic = false
				allowWalk = false
				manualCancel = false
				tankControls = false
				walkSpeed = 1
			end

			task.spawn(function()
				local formatted = `Emote_{v13}`
				local rELICSxyz_EmoteMutex = localPlayer:GetAttribute("RELICSxyz_EmoteMutex")

				if rELICSxyz_EmoteMutex then
					localPlayer:SetAttribute("RELICSxyz_EmoteMutex", nil)

					if rELICSxyz_EmoteMutex == formatted then
						return
					else
						task.wait()
					end
				end

				local track = animator:LoadAnimation(animation)
				track.Priority = Enum.AnimationPriority.Action
				track:Play()
				local diedConnection = humanoid.Died:Once(function()
					if localPlayer:GetAttribute("RELICSxyz_EmoteMutex") == formatted then
						localPlayer:SetAttribute("RELICSxyz_EmoteMutex", nil)

						if lifeAgnostic then
							localPlayer:SetAttribute("RELICSxyz_EmoteRestore", v13)
						end
					end
				end)
				RunService:BindToRenderStep(formatted, Enum.RenderPriority.Input.Value + 1, function(p: number)
					local rELICSxyz_EmoteMutex2 = localPlayer:GetAttribute("RELICSxyz_EmoteMutex")
					local v15 = not humanoid:IsDescendantOf(game)
					local v16 = rELICSxyz_EmoteMutex2 ~= formatted or v15
					local v17

					if allowWalk then
						v17 = humanoid:GetState() ~= Enum.HumanoidStateType.Running and not manualCancel or v16
					else
						v17 = not manualCancel and humanoid:GetMoveVelocity().Magnitude > 0.01 or v16
					end

					if v17 then
						if rELICSxyz_EmoteMutex2 == formatted then
							localPlayer:SetAttribute("RELICSxyz_EmoteMutex", nil)
						end

						RunService:UnbindFromRenderStep(formatted)
						diedConnection:Disconnect()
						track:Stop()
					else
						local moveDirection = humanoid.MoveDirection

						if tankControls then
							local rootPart = humanoid.RootPart
							local cFrame = rootPart and rootPart.CFrame
							local vector2 = not cFrame and createVector(0, 0, 1) or cFrame.LookVector
							local cross = vector2:Cross(not cFrame and createVector(0, 1, 0) or cFrame.UpVector)

							if moveDirection.Magnitude > 0 then
								local dot = moveDirection:Dot(cross)
								local v18 = math.min(math.abs(dot), p * 4) * math.sign(dot)
								moveDirection = (CFrame.lookAlong(createVector(0, 0, 0), vector2) * CFrame.Angles(
									0,
									-v18,
									0
								)).LookVector
							end
						end

						if walkSpeed and moveDirection.Magnitude > 0 then
							moveDirection = moveDirection.Unit * walkSpeed
						end

						humanoid:Move(moveDirection)
					end
				end)
				localPlayer:SetAttribute("RELICSxyz_EmoteMutex", formatted)
			end)
			return true
		end

		local rELICSxyz_EmoteRestore = localPlayer:GetAttribute("RELICSxyz_EmoteRestore")
		localPlayer:SetAttribute("RELICSxyz_EmoteRestore", nil)

		for i = 0, 3, 0.25 do
			task.delay(i, function()
				playEmote.OnInvoke = onPlayEmote
			end)
		end

		if rELICSxyz_EmoteRestore then
			local v13 = v6[rELICSxyz_EmoteRestore]
			local animation = v13 and v13.Animation

			if animation then
				task.spawn(onPlayEmote, animation)
			end
		end
	end

	if localPlayer.Character then
		task.spawn(onCharacterAdded, localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(onCharacterAdded)
end

Tags.BindWithMaid("RelicsEmote", function(animation, maid)
	if not animation:IsA("Animation") then
		return
	end

	local asset = Enum.InfoType.Asset
	local infoType = animation:GetAttribute("InfoType") or animation:GetAttribute("ProductType")

	if typeof(infoType) == "EnumItem" and infoType:IsA("InfoType") then
		asset = infoType
	end

	local emoteId = tonumber(animation:GetAttribute("EmoteId") or animation:GetAttribute("ProductId"))
	local v13 = tonumber(animation.AnimationId:match("%d+$"))
	local assetId = tonumber(animation:GetAttribute("AssetId"))
	local gamePass = tonumber(animation:GetAttribute("GamePass"))
	local legacyIds = animation:GetAttribute("LegacyIds")
	local songId = animation:GetAttribute("SongId")
	local songTitle = animation:GetAttribute("SongTitle")
	local songArtist = animation:GetAttribute("SongArtist")
	local songId2 = nil

	if type(songTitle) ~= "string" then
		songTitle = nil
	end

	if type(songArtist) ~= "string" then
		songArtist = nil
	end

	if type(songId) == "string" then
		songId2 = tonumber(songId:match("%d+$"))
	elseif type(songId) == "number" then
		songId2 = songId
	end

	if v13 and v6[v13] then
		warn((`Duplicate emote animation ID detected: {v13} -> {v6[v13].Animation:GetFullName()} while trying to register emote {animation:GetFullName()}`))
		return
	end

	if songId2 and not animation:GetAttribute("SongIsEncrypted") then
		local sound = Instance.new("Sound")
		sound.Name = "_preload"
		sound.Archivable = false
		sound.AudioContent = Content.fromAssetId(songId2)
		sound.Parent = animation.Parent
	end

	local allowWalk = animation:GetAttribute("AllowWalk")
	local tankControls = animation:GetAttribute("TankControls")
	local manualCancel = animation:GetAttribute("ManualCancel")
	local walkSpeed = tonumber(animation:GetAttribute("WalkSpeed"))
	local lifeAgnostic = animation:GetAttribute("LifeAgnostic")
	local firstTagged = Tags.FindFirstTagged("RelicsEmoteConfig")

	if firstTagged then
		if type(allowWalk) ~= "boolean" then
			allowWalk = firstTagged:GetAttribute("AllowWalk") and true or false
		end

		if type(tankControls) ~= "boolean" then
			tankControls = firstTagged:GetAttribute("TankControls") and true or false
		end

		if type(manualCancel) ~= "boolean" then
			manualCancel = firstTagged:GetAttribute("ManualCancel") and true or false
		end

		if type(walkSpeed) ~= "number" then
			walkSpeed = tonumber(firstTagged:GetAttribute("WalkSpeed"))
		end

		if type(lifeAgnostic) ~= "boolean" then
			lifeAgnostic = firstTagged:GetAttribute("LifeAgnostic") and true or false
		end
	end

	local name = animation.Name

	if not (emoteId and v13) then
		return
	end

	local v15 = nil
	animation.AnimationId = `rbxassetid://{v13}`

	if type(legacyIds) == "string" or type(legacyIds) == "number" then
		local legacyIds2 = Migration.ParseLegacyIds(legacyIds)

		if #legacyIds2 > 0 then
			v15 = legacyIds2
		end
	end

	local legacyIds3 = not v15 and assetId and assetId > 0 and gamePass and gamePass > 0 and {
		{
			Id = gamePass,
			InfoType = Enum.InfoType.GamePass
		}
	} or v15
	local v17 = {
		Name = name,
		ProductId = emoteId,
		ProductType = asset,
		Animation = animation,
		Order = count,
		SongId = songId2,
		SongTitle = songTitle,
		SongArtist = songArtist,
		AssetId = assetId,
		GamePass = gamePass,
		LegacyIds = legacyIds3,
		AllowWalk = allowWalk,
		WalkSpeed = walkSpeed,
		ManualCancel = manualCancel,
		TankControls = tankControls,
		LifeAgnostic = lifeAgnostic,
		Owners = {}
	}
	local v18 = {}

	for _, v19 in Ownership.Get(v17) do
		local key = Ownership.KeyOf(v19.Id, v19.InfoType)
		v8[key] = v17
		table.insert(v18, key)
	end

	local function onAttributeChanged(attributeName: string)
		local v19 = attributeName:sub(1, 5) == "Owner" and tonumber(attributeName:sub(6))

		if v19 then
			local v20 = v19 // 1

			if animation:GetAttribute(attributeName) then
				v17.Owners[v20] = true
				ownerAdded:Fire(v17, v20)
			else
				v17.Owners[v20] = nil
				ownerRemoved:Fire(v17, v20)
			end
		end
	end

	maid:Connect(animation.AttributeChanged, onAttributeChanged)

	if RunContext.IsServer then
		local function checkOwnership(p, _: number?)
			local v19 = Ownership.Get(v17)

			if #v19 == 0 then
				return
			end

			Marketplace.BulkResolveOwnership(p, v19):andThen(function(list)
				for _, v20 in ipairs(list) do
					if not v20 then
						continue
					end

					animation:SetAttribute(`Owner{p.UserId}`, true)
					onAttributeChanged(`Owner{p.UserId}`)
					break
				end
			end)
		end

		for _, v19 in Players:GetPlayers() do
			checkOwnership(v19)
		end

		maid:Connect(Players.PlayerAdded, function(p)
			checkOwnership(p)
		end)
	end

	maid:Add(function()
		v5[name] = nil
		v6[v13] = nil

		for _, v19 in v18 do
			v8[v19] = nil
		end

		if songId2 then
			local formatted = `rbxassetid://{songId2}`
			v7[formatted] = nil
		end
	end)
	v5[name] = v17
	v6[v13] = v17

	for _, v19 in v18 do
		v8[v19] = v17
	end

	if songId2 then
		local formatted = `rbxassetid://{songId2}`
		v7[formatted] = v17
	end

	emoteAdded:FireDeferred(v17)
	count += 1
end)
return table.freeze({
	GetEmotes = getEmotes,
	GetEmoteById = getEmoteById,
	GetEmoteBySongId = getEmoteBySongId,
	GetEmoteByAnimation = getEmoteByAnimation,
	GetEmoteByAnimationId = getEmoteByAnimationId,
	AttachEffectToCharacter = attachEffectToCharacter,
	BindModelByNamedAttachments = bindModelByNamedAttachments,
	EmoteAdded = emoteAdded,
	EmoteRemoved = emoteRemoved,
	OwnerAdded = ownerAdded,
	OwnerRemoved = ownerRemoved,
	SetupEffect = setupEffect,
	PlayEmoteLocal = playEmoteLocal,
	Mutex = "RELICSxyz_EmoteMutex"
})