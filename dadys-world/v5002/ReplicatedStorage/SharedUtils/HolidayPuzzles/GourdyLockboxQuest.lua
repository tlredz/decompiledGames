local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local sharedUtils = ReplicatedStorage:WaitForChild("SharedUtils")
local Network = require(sharedUtils:WaitForChild("Network"))
local Universe = require(sharedUtils:WaitForChild("Universe"))
local GourdyLockboxQuestCore = require(script.Parent:WaitForChild("GourdyLockboxQuestCore"))

local function loadContext()
	local holidayCollectionHunting = sharedUtils:FindFirstChild("HolidayCollectionHunting")
	local success, result = pcall(require, holidayCollectionHunting)

	if not (holidayCollectionHunting and success) then
		warn("[GourdyQuest] HolidayCollectionHunting unavailable — quest disabled")
		return nil
	end

	local collection = result.GetCollection()
	local gourdyQuest = collection and collection.GourdyQuest

	if not gourdyQuest then
		warn("[GourdyQuest] no GourdyQuest block on the registered collection — quest disabled")
		return nil
	end

	local collectableEntry = result.GetCollectableEntry(gourdyQuest.Collectable)

	if not collectableEntry then
		warn(("[GourdyQuest] collectable %q is not in the roster — quest disabled"):format((tostring(gourdyQuest.Collectable))))
		return nil
	end

	local index, v = GourdyLockboxQuestCore.buildIndex(gourdyQuest.Parts, collectableEntry.Pieces)

	for _, v2 in ipairs(v) do
		warn("[GourdyQuest] " .. v2)
	end

	return {
		hunting = result,
		collection = collection,
		quest = gourdyQuest,
		index = index,
		roster = collectableEntry.Pieces,
		statePath = ("Seasonal.%s.%s"):format(collection.HolidayKey, gourdyQuest.StateKey)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function propAnchor(model)
	if model:IsA("BasePart") then
		return model
	end

	if model:IsA("Model") and model.PrimaryPart then
		return model.PrimaryPart
	end

	return model:FindFirstChildWhichIsA("BasePart", true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function interactRange(p, kind: string)
	local kind2 = p.Kinds[kind]
	return kind2 and kind2.InteractRange or p.InteractRange
end

local function propStep(p, instance)
	local attribute = instance:GetAttribute(p.quest.StepAttribute)

	if type(attribute) == "string" and p.index.steps[attribute] then
		return attribute
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function partOfKind(p, p2: string)
	for _, v in ipairs(p.index.partOrder) do
		if p.index.parts[v].kind == p2 then
			return v
		end
	end

	return nil
end

local function watchProps(propTag: string, callback, callback2)
	local function consider(instance)
		if instance:IsDescendantOf(workspace) then
			callback(instance)
			return
		end

		local ancestryChangedConnection = nil
		ancestryChangedConnection = instance.AncestryChanged:Connect(function()
			if instance:IsDescendantOf(workspace) then
				ancestryChangedConnection:Disconnect()
				callback(instance)
			end
		end)
	end

	for _, v in ipairs(CollectionService:GetTagged(propTag)) do
		if v:IsDescendantOf(workspace) then
			callback(v)
		else
			local ancestryChangedConnection = nil
			local v2 = v
			ancestryChangedConnection = v.AncestryChanged:Connect(function()
				if v2:IsDescendantOf(workspace) then
					ancestryChangedConnection:Disconnect()
					callback(v2)
				end
			end)
		end
	end

	CollectionService:GetInstanceAddedSignal(propTag):Connect(consider)

	if callback2 then
		CollectionService:GetInstanceRemovedSignal(propTag):Connect(callback2)
	end
end

local function _Server(data)
	local quest = data.quest
	local index = data.index
	local roster = data.roster
	local collection = data.collection
	local hunting = data.hunting
	local finalReveal = quest.FinalReveal
	local v = {}
	local gourdyLockboxSecrets = ServerStorage:FindFirstChild("SharedModules") and ServerStorage.SharedModules:FindFirstChild("GourdyLockboxSecrets")

	if gourdyLockboxSecrets then
		local success, result = pcall(require, gourdyLockboxSecrets)
		v = success and result or v
	end

	if not gourdyLockboxSecrets then
		warn("[GourdyQuest] ServerStorage.SharedModules.GourdyLockboxSecrets missing — typewriter and lore TV disabled")
	end

	local function loreVideo()
		local loreVideoId = v.LoreVideoId

		if loreVideoId == nil or loreVideoId == "" then
			return nil
		end

		local v2 = tostring(loreVideoId)

		if not string.match(v2, "^rbxassetid://") then
			return "rbxassetid://" .. v2
		end

		return v2
	end

	local function typewriterCode()
		local typewriterCode2 = v.TypewriterCode

		if type(typewriterCode2) ~= "string" or typewriterCode2 == "" or not typewriterCode2 then
			typewriterCode2 = nil
		end

		return typewriterCode2
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isKindReady(kind: string)
		if kind == "LoreTV" then
			local loreVideoId = v.LoreVideoId
			local v2

			if not (loreVideoId == nil or loreVideoId == "") then
				v2 = tostring(loreVideoId)

				if not string.match(v2, "^rbxassetid://") then
					v2 = "rbxassetid://" .. v2
				end
			end

			return v2 ~= nil
		else
			if kind ~= "Typewriter" then
				return true
			end

			local typewriterCode2 = v.TypewriterCode

			if type(typewriterCode2) ~= "string" or typewriterCode2 == "" or not typewriterCode2 then
				typewriterCode2 = nil
			end

			return typewriterCode2 ~= nil
		end
	end

	watchProps(quest.PropTag, function(model)
		local v2 = data
		local attribute = model:GetAttribute(v2.quest.StepAttribute)

		if type(attribute) ~= "string" or not v2.index.steps[attribute] then
			attribute = nil
		end

		if not attribute then
			warn(("[GourdyQuest] %s has a missing or unknown %s attribute — it does nothing"):format(
				model:GetFullName(),
				quest.StepAttribute
			))
			return
		end

		-- equivalent call inferred; original call site unknown
		if not propAnchor(model) then
			warn(("[GourdyQuest] %s has no BasePart to hold its prompt"):format(model:GetFullName()))
		end

		if model:IsA("Model") then
			model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		end

		local readyAttribute = quest.ReadyAttribute
		local kindReady = isKindReady(index.steps[attribute].kind) -- equivalent call inferred; original call site unknown
		model:SetAttribute(readyAttribute, kindReady)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function replicate(p, statePath: string, p2)
		local modules = ServerScriptService:FindFirstChild("Modules")
		local replicaUpdater = modules and modules:FindFirstChild("ReplicaUpdater")

		if replicaUpdater then
			local module = require(replicaUpdater)
			module:UpdateValue(p, statePath, p2)
		end
	end

	local function notify(player, p: string)
		local events = ReplicatedStorage:FindFirstChild("Events")

		if Universe:IsGame() then
			local textEvent = events and events:FindFirstChild("TextEvent")

			if textEvent then
				textEvent:FireClient(player, p)
			end
		else
			local messageUser = events and events:FindFirstChild("MessageUser")

			if messageUser then
				messageUser:FireClient(player, p, "success", 4)
			end
		end
	end

	local presentation = quest.Presentation
	local v2 = presentation.EmergeTime + presentation.ToHeadTime + presentation.SpinTime + presentation.FlyInTime

	local function liveCharacter(player)
		local character = player.Character

		if Universe:IsGame() then
			local inGamePlayers = workspace:FindFirstChild("InGamePlayers")
			character = inGamePlayers and inGamePlayers:FindFirstChild(player.Name)
		end

		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then
			return character
		end

		return nil
	end

	local function views(p, p2)
		local seasonal = p and p.Data and p.Data.Seasonal
		local v3 = seasonal and seasonal[collection.HolidayKey]

		if p2 and type(seasonal) == "table" then
			v3 = hunting.EnsureHolidayData(seasonal, p2)
		end

		if type(v3) ~= "table" then
			return nil, nil, nil
		end

		local v4 = v3[collection.CollectablesKey]
		local v5 = type(v4) ~= "table" and {} or v4[quest.Collectable] or {}
		return v3, type(v5) == "table" and v5 or {}, GourdyLockboxQuestCore.normalizeState(v3[quest.StateKey], index)
	end

	local function withProfile(p, fn)
		local editData = ReplicatedStorage:FindFirstChild("editData")

		if not editData then
			warn("[GourdyQuest] editData BindableFunction not found")
			return false
		end

		local v3 = false
		local success, result = pcall(function()
			editData:Invoke(p, function(p2)
				fn(p2)
				v3 = true
			end)
		end)

		if not success then
			warn(("[GourdyQuest] profile edit failed for %s: %s"):format(p.Name, (tostring(result))))
		end

		return success and v3
	end

	local function kindRefusal(kind: string, instance, p)
		local v3 = quest.Kinds[kind] or {}

		if kind == "Plush" then
			if instance:GetAttribute("MonsterName") == v3.MonsterName then
				return nil
			end

			return "WRONG_CHARACTER"
		else
			if kind ~= "Typewriter" then
				return nil
			end

			local code

			if type(p) == "table" then
				code = p.code
			else
				code = false
			end

			if type(code) ~= "string" then
				return "WRONG_CODE"
			end

			local v4 = string.gsub(code, "%D", "")
			local typewriterCode2 = v.TypewriterCode

			if type(typewriterCode2) ~= "string" or typewriterCode2 == "" or not typewriterCode2 then
				typewriterCode2 = nil
			end

			if v4 == typewriterCode2 then
				return nil
			end

			return "WRONG_CODE"
		end
	end

	local function deliverFinalReveal(instance)
		local child = ServerStorage:FindFirstChild(finalReveal.ServerModelName)
		local playerGui = instance:FindFirstChildOfClass("PlayerGui")

		if not (child and playerGui) then
			return false
		end

		if playerGui:FindFirstChild("GourdyLockboxReveal") then
			return true
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "GourdyLockboxReveal"
		screenGui.ResetOnSpawn = false
		screenGui.Enabled = false
		local clone = child:Clone()
		clone.Parent = screenGui
		screenGui.Parent = playerGui
		return true
	end

	local v3 = {}
	Players.PlayerRemoving:Connect(function(player)
		v3[player] = nil
	end)

	local function interact(p, primaryPart, p2)
		if typeof(primaryPart) ~= "Instance" or not (CollectionService:HasTag(primaryPart, quest.PropTag) and primaryPart:IsDescendantOf(workspace)) then
			return {
				ok = false,
				reason = "BAD_PROP"
			}
		end

		local v4 = data
		local attribute = primaryPart:GetAttribute(v4.quest.StepAttribute)

		if type(attribute) ~= "string" or not v4.index.steps[attribute] then
			attribute = nil
		end

		if not attribute then
			return {
				ok = false,
				reason = "UNKNOWN_STEP"
			}
		end

		local kind = index.steps[attribute].kind

		-- equivalent call inferred; original call site unknown
		if not isKindReady(kind) then
			return {
				ok = false,
				reason = "NOT_READY"
			}
		end

		local v5 = liveCharacter(p)

		if not primaryPart:IsA("BasePart") then
			if primaryPart:IsA("Model") and primaryPart.PrimaryPart then
				primaryPart = primaryPart.PrimaryPart
			else
				primaryPart = primaryPart:FindFirstChildWhichIsA("BasePart", true)
			end
		end

		if not (v5 and primaryPart) then
			return {
				ok = false,
				reason = "CANNOT_INTERACT"
			}
		end

		local magnitude = (v5:GetPivot().Position - primaryPart.Position).Magnitude

		if interactRange(quest, kind) * 2 < magnitude then
			return {
				ok = false,
				reason = "TOO_FAR"
			}
		end

		local reason = kindRefusal(kind, v5, p2)

		if reason then
			return {
				ok = false,
				reason = reason
			}
		end

		local v8 = {
			ok = false,
			reason = "NO_PROFILE"
		}

		if not withProfile(p, function(p3)
			if not p3 or type(p3.Data) ~= "table" then
				return
			end

			local tutorialProgress = p3.Data.TutorialProgress

			if not hunting.MeetsTutorialGate(tutorialProgress and tutorialProgress.CurrentStep, quest.Collectable) then
				v8.reason = "TUTORIAL_GATE"
				return
			end

			local v9, v10, v11 = views(p3, p)

			if not v9 then
				return
			end

			local canAttemptStep, reason2 = GourdyLockboxQuestCore.canAttemptStep(index, v11, v10, attribute)

			if not canAttemptStep then
				v8.reason = reason2
				return
			end

			local now = os.time()
			local v13, v14 = GourdyLockboxQuestCore.applyStep(index, v11, v10, attribute, now)
			local v15 = v13 and GourdyLockboxQuestCore.milestoneCompletedBy(
				quest.StepMilestones,
				v11.Steps,
				attribute,
				v14
			)
			local milestoneMessage

			if v15 then
				local piece = index.steps[attribute].piece
				local v17 = index.pieces[piece].required - GourdyLockboxQuestCore.countStepsDone(
					index,
					v11.Steps,
					piece
				)
				milestoneMessage = v15.Message:format(#v15.Steps, v17)
			end

			local piece2

			if v14 then
				piece2 = hunting.GrantSpecialPieceInProfile(p3, p, v14) and v14 or nil
				v10 = v9[collection.CollectablesKey][quest.Collectable]
			end

			GourdyLockboxQuestCore.stampCompletion(v11, roster, v10, now)
			v9[quest.StateKey] = v11
			replicate(p, data.statePath, v11) -- equivalent call inferred; original call site unknown
			v8 = {
				ok = true,
				step = attribute,
				piece = piece2,
				milestoneMessage = milestoneMessage,
				held = GourdyLockboxQuestCore.countHeld(roster, v10),
				total = #roster,
				complete = GourdyLockboxQuestCore.isSetComplete(roster, v10)
			}
		end) then
			return {
				ok = false,
				reason = "EDIT_FAILED"
			}
		end

		if not v8.ok then
			return v8
		end

		if kind == "LoreTV" then
			local loreVideoId = v.LoreVideoId
			local video

			if not (loreVideoId == nil or loreVideoId == "") then
				video = tostring(loreVideoId)

				if not string.match(video, "^rbxassetid://") then
					video = "rbxassetid://" .. video
				end
			end

			v8.video = video
		end

		if v8.milestoneMessage then
			local kind2 = quest.Kinds[kind]
			task.delay(kind2 and kind2.FadeTime or 0, notify, p, v8.milestoneMessage)
		end

		if v8.piece then
			task.delay(v2, notify, p, quest.CompletionMessage:format(v8.held, v8.total))
		end

		if v8.complete then
			task.spawn(function()
				local success, result = pcall(function()
					local AchievementGiver = require(ServerStorage:WaitForChild("SharedModules"):WaitForChild("AchievementGiver"))
					AchievementGiver:UpdateKey(p, "ID_64_LockedAway26", true, 1)
				end)

				if not success then
					warn(("[GourdyQuest] Locked Away medal failed for %s: %s"):format(p.Name, (tostring(result))))
				end
			end)

			if Universe:IsLobby() then
				deliverFinalReveal(p)
			end
		end

		return v8
	end

	Network:AddAction("GourdyQuestInteract", function(p, p2, p3)
		if v3[p] then
			return {
				ok = false,
				reason = "BUSY"
			}
		end

		v3[p] = true
		local success, result = pcall(interact, p, p2, p3)
		v3[p] = nil

		if success then
			return result
		end

		warn("[GourdyQuest] interaction failed: " .. tostring(result))
		return {
			ok = false,
			reason = "ERROR"
		}
	end)
	Network:AddAction("GourdyQuestBeatSeen", function(p, p2: string?)
		if not Universe:IsLobby() or p2 ~= GourdyLockboxQuestCore.BEAT_INTRO and p2 ~= GourdyLockboxQuestCore.BEAT_FINAL or p2 == GourdyLockboxQuestCore.BEAT_FINAL and not ServerStorage:FindFirstChild(finalReveal.ServerModelName) then
			return
		end

		withProfile(p, function(p3)
			local v4, v5, v6 = views(p3)

			if not v4 then
				return
			end

			local now = os.time()

			if GourdyLockboxQuestCore.markBeatSeen(v6, p2, roster, v5, now) then
				GourdyLockboxQuestCore.stampCompletion(v6, roster, v5, now)
				v4[quest.StateKey] = v6
				replicate(p, data.statePath, v6) -- equivalent call inferred; original call site unknown
			end
		end)
	end)
	Network:AddAction("GourdyQuestLoreVideo", function(p)
		local v5 = partOfKind(data, "LoreTV") -- equivalent call inferred; original call site unknown
		local v6 = false
		withProfile(p, function(p2)
			local v7, v8 = views(p2)
			v6 = v7 ~= nil and v5 ~= nil and GourdyLockboxQuestCore.isPartComplete(index, v8, v5)
		end)
		local v7

		if not v6 then
			return v7
		end

		local loreVideoId = v.LoreVideoId
		local v8

		if not (loreVideoId == nil or loreVideoId == "") then
			v8 = tostring(loreVideoId)

			if not string.match(v8, "^rbxassetid://") then
				v8 = "rbxassetid://" .. v8
			end
		end

		return v8 or nil
	end)
	Network:AddAction("GourdyQuestFinalReveal", function(p)
		if not Universe:IsLobby() then
			return false
		end

		local v4 = false
		withProfile(p, function(p2)
			local v5, v6 = views(p2)
			v4 = v5 ~= nil and GourdyLockboxQuestCore.isSetComplete(roster, v6)
		end)
		return v4 and deliverFinalReveal(p)
	end)
end

local function pivotTween(instance, cframe: CFrame, duration: number, p)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = instance:GetPivot()
	local valueChangedConnection = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		if instance.Parent then
			instance:PivotTo(cFrameValue.Value)
		end
	end)
	local tween = TweenService:Create(
		cFrameValue,
		TweenInfo.new(duration, p or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Value = cframe
		}
	)
	tween.Completed:Once(function()
		valueChangedConnection:Disconnect()
		cFrameValue:Destroy()
	end)
	tween:Play()
	return tween
end

local function visualsOf(folder, ancestor)
	local instances = {}

	local function consider(instance)
		if ancestor and (instance == ancestor or instance:IsDescendantOf(ancestor)) then
			return
		end

		if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
			table.insert(instances, instance)
		end
	end

	consider(folder)

	for _, descendant in ipairs(folder:GetDescendants()) do
		consider(descendant)
	end

	return instances
end

local function _Client(data)
	local quest = data.quest
	local index = data.index
	local roster = data.roster
	local collection = data.collection
	local hunting = data.hunting
	local kinds = quest.Kinds
	local presentation = quest.Presentation
	local localPlayer = Players.LocalPlayer
	local GourdyTypewriterNumpad = require(script.Parent:WaitForChild("GourdyTypewriterNumpad"))
	local state = GourdyLockboxQuestCore.normalizeState(nil, index)
	local v = {}
	local v2 = 0
	local v3 = {}
	local v4 = {}
	local transparencies = {}
	local video = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function remember(p)
		if transparencies[p] == nil then
			transparencies[p] = p.Transparency
		end
	end

	local function fadeTo(p, transparency: number, duration: number)
		if duration <= 0 then
			p.Transparency = transparency
		else
			TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = transparency
			}):Play()
		end
	end

	local function setShown(list, flag: boolean, p: number, flag2: boolean?)
		for _, v5 in ipairs(list) do
			remember(v5) -- equivalent call inferred; original call site unknown
			local v6 = transparencies[v5]
			local v7 = flag2 and v6 >= 1 and 0 or v6
			fadeTo(v5, flag and v7 or 1, p)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isDone(p)
		return v3[p.step] == true or GourdyLockboxQuestCore.isStepDone(index, state.Steps, v, p.step)
	end

	local function isGourdy()
		local character = localPlayer.Character
		return character ~= nil and character:GetAttribute("MonsterName") == kinds.Plush.MonsterName
	end

	local function isLocalCharacterLive()
		local character = localPlayer.Character

		if Universe:IsGame() then
			local inGamePlayers = workspace:FindFirstChild("InGamePlayers")
			character = inGamePlayers and inGamePlayers:FindFirstChild(localPlayer.Name)
		end

		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		return humanoid ~= nil and humanoid.Health > 0
	end

	local function applyLantern(p, enabled: boolean, fadeTime: number)
		local lantern = kinds.Lantern

		for _, descendant in ipairs(p.prop:GetDescendants()) do
			if descendant:IsA("PointLight") then
				descendant.Enabled = enabled
			elseif descendant.Name == lantern.GlowName and descendant:IsA("BasePart") then
				local litColor = enabled and lantern.LitColor or lantern.UnlitColor

				if fadeTime <= 0 then
					descendant.Color = litColor
				else
					TweenService:Create(descendant, TweenInfo.new(fadeTime), {
						Color = litColor
					}):Play()
				end

				for _, descendant2 in ipairs(descendant:GetDescendants()) do
					if not (descendant2:IsA("ParticleEmitter") or descendant2:IsA("Fire") or descendant2:IsA("Light")) then
						continue
					end

					descendant2.Enabled = enabled
				end
			end
		end
	end

	local function posterGlow(state2)
		local decals = {}

		for _, decal in ipairs(state2.prop:GetDescendants()) do
			if decal:IsA("Decal") and decal.Name == kinds.Poster.GlowDecalName then
				table.insert(decals, decal)
			end
		end

		return decals
	end

	local function applyPoster(state2, flag: boolean, straightenTime: number)
		local poster = kinds.Poster
		local prop = state2.prop
		state2.straightPivot = state2.straightPivot or prop:GetPivot()
		local straightPivot = flag and state2.straightPivot or state2.straightPivot * CFrame.Angles(
			0,
			0,
			(math.rad(poster.CrookedAngle))
		)
		local v5 = posterGlow(state2)

		if state2.tween then
			state2.tween:Cancel()
			state2.tween = nil
		end

		if straightenTime <= 0 then
			prop:PivotTo(straightPivot)
			setShown(v5, flag, 0)
		elseif flag then
			local tween = pivotTween(prop, straightPivot, straightenTime, Enum.EasingStyle.Back)
			state2.tween = tween
			tween.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed then
					if state2.busy then
						setShown(v5, true, poster.GlowTime)
					elseif isDone(state2) then
						setShown(v5, true, poster.GlowTime)
					end
				end
			end)
		else
			setShown(v5, false, 0)
			state2.tween = pivotTween(prop, straightPivot, straightenTime)
		end
	end

	local function applyLoreTV(state2, flag: boolean)
		local videoFrame = state2.prop:FindFirstChildWhichIsA("VideoFrame", true)

		if videoFrame then
			state2.staticVideo = state2.staticVideo or videoFrame.Video
			local video2 = flag and video or state2.staticVideo

			if videoFrame.Video ~= video2 then
				videoFrame.Video = video2
				videoFrame.Looped = true
				videoFrame:Play()
			end
		elseif not state2.warned then
			state2.warned = true
			warn(("[GourdyQuest] %s has no VideoFrame"):format(state2.prop:GetFullName()))
		end
	end

	local function applyPlush(state2, flag: boolean, swapTime: number)
		local child = state2.prop:FindFirstChild(kinds.Plush.HappyVariantName, true)

		if child then
			setShown(visualsOf(child), flag, swapTime, true)
			setShown(visualsOf(state2.prop, child), not flag, swapTime)
		elseif not state2.warned then
			state2.warned = true
			warn(("[GourdyQuest] %s has no %s child — the plush cannot change"):format(
				state2.prop:GetFullName(),
				kinds.Plush.HappyVariantName
			))
		end
	end

	local function applyLook(p, enabled: boolean, flag2: boolean)
		local kind = p.kind

		if kind == "Lantern" then
			applyLantern(p, enabled, flag2 and kinds.Lantern.FadeTime or 0)
		elseif kind == "Poster" then
			applyPoster(p, enabled, flag2 and kinds.Poster.StraightenTime or 0)
		elseif kind == "PhotoHalf" then
			setShown(visualsOf(p.prop), not enabled, flag2 and kinds.PhotoHalf.HideTime or 0)
		elseif kind == "Plush" then
			applyPlush(p, enabled, flag2 and kinds.Plush.SwapTime or 0)
		elseif kind == "LoreTV" then
			if enabled and not video then
				task.spawn(function()
					local success, result = pcall(Network.Get, Network, "GourdyQuestLoreVideo")

					if success and type(result) == "string" then
						video = result
						applyLoreTV(p, isDone(p))
					end
				end)
			else
				applyLoreTV(p, enabled)
			end
		end
	end

	local fn

	local function isOffered(data2)
		if data2.busy or v3[data2.step] == true or GourdyLockboxQuestCore.isStepDone(index, state.Steps, v, data2.step) or not isLocalCharacterLive() then
			return false
		end

		if not (data2.prop:GetAttribute(quest.ReadyAttribute) == true and hunting.MeetsTutorialGate(
			v2,
			quest.Collectable
		)) then
			return false
		end

		if not GourdyLockboxQuestCore.canAttemptStep(index, state, v, data2.step) then
			return false
		end

		if data2.kind ~= "Plush" then
			return true
		end

		local character = localPlayer.Character
		local v5

		if character == nil then
			v5 = false
		else
			v5 = character:GetAttribute("MonsterName") == kinds.Plush.MonsterName
		end

		return not not v5
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setPrompt(state2, flag: boolean)
		if flag and not state2.prompt then
			local prop = state2.prop

			if not prop:IsA("BasePart") then
				if prop:IsA("Model") and prop.PrimaryPart then
					prop = prop.PrimaryPart
				else
					prop = prop:FindFirstChildWhichIsA("BasePart", true)
				end
			end

			if not prop then
				return
			end

			local v5 = kinds[state2.kind] or {}
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.Name = "GourdyQuestPrompt"
			proximityPrompt.ActionText = v5.ActionText or "Interact"
			proximityPrompt.ObjectText = v5.ObjectText or ""
			proximityPrompt.MaxActivationDistance = interactRange(quest, state2.kind)
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.HoldDuration = 0
			proximityPrompt.Triggered:Connect(function()
				fn(state2)
			end)
			proximityPrompt.Parent = prop
			state2.prompt = proximityPrompt
		elseif not flag and state2.prompt then
			state2.prompt:Destroy()
			state2.prompt = nil
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function render(p)
		local done = isDone(p) -- equivalent call inferred; original call site unknown

		if p.shownDone ~= done then
			local v5 = p.shownDone ~= nil
			p.shownDone = done
			applyLook(p, done, v5)
		end

		setPrompt(p, isOffered(p))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function renderAll()
		for _, v5 in pairs(v4) do
			render(v5) -- equivalent call inferred; original call site unknown
		end
	end

	local CollectPresentation = require(script.Parent:WaitForChild("CollectPresentation"))
	local beatHolds = GourdyLockboxQuestCore.newBeatHolds()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playCollect(prop)
		local v5 = beatHolds.acquire()
		local success, result = pcall(CollectPresentation.play, presentation, prop)
		v5()

		if not success then
			warn("[GourdyQuest] collect presentation failed: " .. tostring(result))
		end
	end

	local v5 = false
	local v6 = {}
	local v7 = nil
	local pivot = nil
	local v8 = false
	local v9 = false
	local quietClock = GourdyLockboxQuestCore.newQuietClock()

	local function screenControllers()
		local CameraController = require(sharedUtils:WaitForChild("CameraController"))
		return CameraController, require(sharedUtils:WaitForChild("PlayerMovementController"))
	end

	local function lobbyShot(childName: string)
		local firstPieceCutscene = collection.FirstPieceCutscene
		local child = workspace:FindFirstChild(collection.DecorFolder)
		local child2 = child and firstPieceCutscene and child:FindFirstChild(firstPieceCutscene.CameraFolder)
		local part = child2 and child2:FindFirstChild(childName)

		if not (part and part:IsA("BasePart") and part) then
			part = nil
		end

		return part
	end

	local function firstHeldPiece()
		local v10 = 1e999
		local v11 = nil

		for _, v12 in ipairs(roster) do
			local v13

			if type(v) == "table" then
				v13 = v[v12]
			else
				v13 = false
			end

			if not (type(v13) == "number" and v13 < v10) then
				continue
			end

			v11 = v12
			v10 = v13
		end

		return v11
	end

	local function revealParts(instance)
		local pVInstance = instance:FindFirstChild(quest.FinalReveal.LidName)
		local pVInstance2 = instance:FindFirstChild(quest.FinalReveal.LidOpenName)

		if pVInstance and pVInstance:IsA("PVInstance") and pVInstance2 and pVInstance2:IsA("PVInstance") then
			return pVInstance, pVInstance2
		end

		return nil, nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function revealContainer()
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		return playerGui and playerGui:FindFirstChild("GourdyLockboxReveal")
	end

	local function awaitRevealModel()
		if v7 and v7:IsDescendantOf(workspace) then
			return v7
		end

		local gourdyLockboxRevealModel = v7

		if not gourdyLockboxRevealModel then
			local gourdyLockboxReveal = revealContainer() -- equivalent call inferred; original call site unknown

			if not gourdyLockboxReveal then
				local success, result = pcall(Network.Get, Network, "GourdyQuestFinalReveal")

				if success and result then
					gourdyLockboxReveal = localPlayer:WaitForChild("PlayerGui"):WaitForChild("GourdyLockboxReveal", 10)
				else
					v9 = true
					warn(("[GourdyQuest] no %s in the Lobby's ServerStorage — the final reveal waits for it"):format(quest.FinalReveal.ServerModelName))
					return nil
				end
			end

			gourdyLockboxRevealModel = gourdyLockboxReveal and gourdyLockboxReveal:FindFirstChildWhichIsA("Model")

			if not gourdyLockboxRevealModel then
				return nil
			end

			local pVInstance = gourdyLockboxRevealModel:FindFirstChild(quest.FinalReveal.LidName)
			local pVInstance2 = gourdyLockboxRevealModel:FindFirstChild(quest.FinalReveal.LidOpenName)

			if not (pVInstance and pVInstance:IsA("PVInstance") and pVInstance2 and pVInstance2:IsA("PVInstance")) then
				pVInstance = nil
				pVInstance2 = nil
			end

			if pVInstance and pVInstance2 then
				pivot = pVInstance:GetPivot()

				for _, part in ipairs((visualsOf(pVInstance2))) do
					part.Transparency = 1

					if not part:IsA("BasePart") then
						continue
					end

					part.CanCollide = false
					part.CanQuery = false
				end
			else
				v9 = true
				warn(("[GourdyQuest] %s needs %s and %s — no final reveal"):format(
					gourdyLockboxRevealModel.Name,
					quest.FinalReveal.LidName,
					quest.FinalReveal.LidOpenName
				))
				return nil
			end
		end

		gourdyLockboxRevealModel.Parent = workspace:FindFirstChild(collection.DecorFolder) or workspace
		v7 = gourdyLockboxRevealModel
		return gourdyLockboxRevealModel
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stowRevealModel()
		local v10 = v7
		local parent = revealContainer() -- equivalent call inferred; original call site unknown

		if not v10 or not parent or v10.Parent == parent then
			return
		end

		local pVInstance = v10:FindFirstChild(quest.FinalReveal.LidName)
		local pVInstance2 = v10:FindFirstChild(quest.FinalReveal.LidOpenName)

		if not (pVInstance and pVInstance:IsA("PVInstance") and pVInstance2 and pVInstance2:IsA("PVInstance")) then
			pVInstance = nil
		end

		if pVInstance and pivot then
			pVInstance:PivotTo(pivot)
		end

		v10.Parent = parent
	end

	local function playFinalReveal()
		local v10 = awaitRevealModel()

		if not v10 then
			return false
		end

		local pVInstance = v10:FindFirstChild(quest.FinalReveal.LidName)
		local pVInstance2 = v10:FindFirstChild(quest.FinalReveal.LidOpenName)

		if not (pVInstance and pVInstance:IsA("PVInstance") and pVInstance2 and pVInstance2:IsA("PVInstance")) then
			pVInstance = nil
			pVInstance2 = nil
		end

		if not (pVInstance and pVInstance2) then
			return false
		end

		if state.FinalRevealSeen or v6[GourdyLockboxQuestCore.BEAT_FINAL] then
			pVInstance:PivotTo(pVInstance2:GetPivot())
			return false
		end

		local v11 = lobbyShot(collection.FirstPieceCutscene.LockboxCamName)

		if v11 then
			local CameraController = require(sharedUtils:WaitForChild("CameraController"))
			local PlayerMovementController = require(sharedUtils:WaitForChild("PlayerMovementController"))

			if CameraController:IsActive() or PlayerMovementController:IsLocked() then
				return false
			end

			local finalReveal = quest.FinalReveal
			local v12 = visualsOf(v10, pVInstance2)
			PlayerMovementController:Lock("Halloween26_GourdyLockboxReveal")
			local success, result = pcall(function()
				setShown(v12, false, 0)
				CameraController:TweenTo(v11.CFrame, finalReveal.ToShrineTime)
				task.wait(finalReveal.ToShrineTime + finalReveal.SettleTime)
				setShown(v12, true, finalReveal.AppearTime)
				task.wait(finalReveal.AppearTime)
				pivotTween(pVInstance, pVInstance2:GetPivot(), finalReveal.OpenTime, Enum.EasingStyle.Back)
				task.wait(finalReveal.OpenTime + finalReveal.HoldTime)
			end)
			CameraController:Reset()
			PlayerMovementController:Unlock("Halloween26_GourdyLockboxReveal")
			setShown(v12, true, 0)
			pVInstance:PivotTo(pVInstance2:GetPivot())

			if success then
				return true
			end

			warn("[GourdyQuest] final reveal failed: " .. tostring(result))
			return false
		else
			v9 = true
			warn("[GourdyQuest] the final reveal needs the LockboxCam shot — the lockbox waits closed")
			return false
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function loadingScreenShown()
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		local loadingScreen = playerGui and playerGui:FindFirstChild("LoadingScreen")

		if loadingScreen then
			return not loadingScreen:IsA("ScreenGui") or loadingScreen.Enabled
		end

		return false
	end

	local function characterReady()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		return humanoid ~= nil and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart") ~= nil
	end

	local function tryLobbyBeats()
		if not Universe:IsLobby() or v5 then
			return
		end

		local CameraController = require(sharedUtils:WaitForChild("CameraController"))
		local PlayerMovementController = require(sharedUtils:WaitForChild("PlayerMovementController"))
		local v10

		if localPlayer:GetAttribute("InLobby") == true then
			v10 = true
		else
			local v11 = loadingScreenShown() -- equivalent call inferred; original call site unknown
			v10 = v11 or CameraController:IsActive() or PlayerMovementController:IsLocked()
		end

		local v11 = quietClock.observe(v10, os.clock())

		if localPlayer:GetAttribute("InLobby") == true then
			return
		end

		local lobbyLetsBeatStart = GourdyLockboxQuestCore.lobbyLetsBeatStart(
			v2,
			v11,
			quest.LobbyBeatTutorialSettleTime or 0,
			quest.LobbyBeatHoldTutorialSteps
		)
		local canStartLobbyBeat = GourdyLockboxQuestCore.canStartLobbyBeat
		local held = beatHolds.isHeld()
		local v12 = loadingScreenShown() -- equivalent call inferred; original call site unknown
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local v13

		if humanoid == nil or not (humanoid.Health > 0) then
			v13 = false
		else
			v13 = character:FindFirstChild("HumanoidRootPart") ~= nil
		end

		if not canStartLobbyBeat(held, v12, v13, lobbyLetsBeatStart) then
			return
		end

		local setComplete = GourdyLockboxQuestCore.isSetComplete(roster, v)

		if not setComplete then
			stowRevealModel() -- equivalent call inferred; original call site unknown
		end

		if state.ShrineIntroSeen then
			v6[GourdyLockboxQuestCore.BEAT_INTRO] = nil
		end

		if state.FinalRevealSeen then
			v6[GourdyLockboxQuestCore.BEAT_FINAL] = nil
		end

		local pendingLobbyBeat = GourdyLockboxQuestCore.pendingLobbyBeat(state, roster, v)

		if pendingLobbyBeat and v6[pendingLobbyBeat] then
			pendingLobbyBeat = nil
		end

		local v14 = setComplete and (state.FinalRevealSeen ~= nil or v6[GourdyLockboxQuestCore.BEAT_FINAL])

		if v14 then
			v14 = not (v7 and v7:IsDescendantOf(workspace))
		end

		if pendingLobbyBeat == GourdyLockboxQuestCore.BEAT_INTRO and v8 or (pendingLobbyBeat == GourdyLockboxQuestCore.BEAT_FINAL or not pendingLobbyBeat and v14) and v9 then
			return
		end

		if pendingLobbyBeat or v14 then
			v5 = true
			task.spawn(function()
				local v15 = false

				if pendingLobbyBeat == GourdyLockboxQuestCore.BEAT_INTRO then
					local v16 = firstHeldPiece()
					local firstPieceCutscene = collection.FirstPieceCutscene

					if firstPieceCutscene and lobbyShot(firstPieceCutscene.LockboxCamName) and lobbyShot(firstPieceCutscene.DandyCamName) then
						if v16 then
							v15 = hunting._playFirstPieceCutscene(v16) == true
						end
					else
						v8 = true
						warn("[GourdyQuest] the shrine introduction needs the LockboxCam and DandyCam shots")
					end
				elseif pendingLobbyBeat == GourdyLockboxQuestCore.BEAT_FINAL then
					v15 = playFinalReveal()
				else
					playFinalReveal()
				end

				if v15 then
					v6[pendingLobbyBeat] = true
					Network:Post("GourdyQuestBeatSeen", pendingLobbyBeat)
				end

				quietClock.disturb(os.clock())
				v5 = false
			end)
		end
	end

	local function onSuccess(p, p2)
		v3[p.step] = true

		if type(p2.video) == "string" then
			video = p2.video
		end

		render(p) -- equivalent call inferred; original call site unknown

		if p2.piece then
			task.spawn(function()
				playCollect(p.prop) -- equivalent call inferred; original call site unknown
				tryLobbyBeats()
			end)
		end
	end

	local function request(state2, p)
		local v10 = beatHolds.acquire()
		local success, result = pcall(Network.Get, Network, "GourdyQuestInteract", state2.prop, p)

		if not success or type(result) ~= "table" or not result then
			result = nil
		end

		state2.busy = false

		if result and result.ok then
			local success2, result2 = pcall(onSuccess, state2, result)

			if not success2 then
				warn("[GourdyQuest] interaction reply failed: " .. tostring(result2))
			end
		end

		v10()
		tryLobbyBeats()
		return result
	end

	fn = function(state2)
		if state2.busy then
			return
		end

		if state2.kind == "Typewriter" then
			local typewriter = kinds.Typewriter
			GourdyTypewriterNumpad.Open({
				title = typewriter.ObjectText,
				length = typewriter.CodeLength,
				groupSize = typewriter.CodeGroupSize,
				onSubmit = function(code: string)
					local v10 = request(state2, {
						code = code
					})

					if v10 and v10.ok then
						return true
					end

					local v11 = false

					if v10 and v10.reason == "WRONG_CODE" then
						return false, "Wrong code."
					end

					return v11, "Nothing happens..."
				end
			})
			local v11 = interactRange(quest, state2.kind) * 2
			task.spawn(function()
				while GourdyTypewriterNumpad.IsOpen() do
					local prop = state2.prop

					if not prop:IsA("BasePart") then
						if prop:IsA("Model") and prop.PrimaryPart then
							prop = prop.PrimaryPart
						else
							prop = prop:FindFirstChildWhichIsA("BasePart", true)
						end
					end

					local character = localPlayer.Character

					if not (prop and prop:IsDescendantOf(workspace)) then
						GourdyTypewriterNumpad.Close()
						break
					end

					if character and v11 < (character:GetPivot().Position - prop.Position).Magnitude then
						GourdyTypewriterNumpad.Close()
						break
					end

					task.wait(0.25)
				end
			end)
		else
			state2.busy = true
			setPrompt(state2, false) -- equivalent call inferred; original call site unknown

			if state2.kind == "Poster" or state2.kind == "Lantern" then
				state2.shownDone = true
				applyLook(state2, true, true)
			end

			task.spawn(function()
				local v10 = request(state2, nil)

				if not (v10 and v10.ok) then
					render(state2) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end

	local function unregister(instance)
		local v10 = v4[instance]

		if not v10 then
			return
		end

		v4[instance] = nil

		for _, connection in ipairs(v10.connections) do
			connection:Disconnect()
		end

		if v10.tween then
			v10.tween:Cancel()
		end

		if v10.prompt then
			v10.prompt:Destroy()
		end
	end

	local function register(instance)
		if v4[instance] then
			return
		end

		local v10 = data
		local attribute = instance:GetAttribute(v10.quest.StepAttribute)

		if type(attribute) ~= "string" or not v10.index.steps[attribute] then
			attribute = nil
		end

		if not attribute then
			return
		end

		local v11 = {
			prop = instance,
			step = attribute,
			kind = index.steps[attribute].kind,
			connections = {}
		}
		v4[instance] = v11
		table.insert(v11.connections, instance:GetAttributeChangedSignal(quest.ReadyAttribute):Connect(function()
			render(v11) -- equivalent call inferred; original call site unknown
		end))
		table.insert(v11.connections, instance.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") and not v11.prompt then
				render(v11) -- equivalent call inferred; original call site unknown
			end
		end))
		table.insert(v11.connections, instance.Destroying:Once(function()
			unregister(instance)
		end))
		render(v11) -- equivalent call inferred; original call site unknown
	end

	local _getDataController = hunting._getDataController()

	if _getDataController then
		_getDataController:onReplicaReady(function(object)
			local collectablesPath = hunting.GetCollectablesPath()
			local tutorialStepPath = hunting.GetTutorialStepPath()

			local function readState(p)
				local clone

				if type(p) == "table" then
					clone = table.clone(p)
					local steps

					if type(p.Steps) == "table" then
						steps = table.clone(p.Steps) or nil
					end

					clone.Steps = steps
				end

				state = GourdyLockboxQuestCore.normalizeState(clone, index)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function readFound(p)
				local v10

				if type(p) == "table" then
					v10 = p[quest.Collectable]
				else
					v10 = false
				end

				v = type(v10) == "table" and v10 or {}
			end

			readState(_getDataController:getDataFromPath(data.statePath))
			readFound(_getDataController:getDataFromPath(collectablesPath)) -- equivalent call inferred; original call site unknown
			v2 = tonumber(_getDataController:getDataFromPath(tutorialStepPath)) or 0

			local function refresh()
				for k in pairs(v3) do
					if not GourdyLockboxQuestCore.isStepDone(index, state.Steps, v, k) then
						v3[k] = nil
					end
				end

				renderAll() -- equivalent call inferred; original call site unknown
				tryLobbyBeats()
			end

			object:ListenToChange(data.statePath, function(p)
				readState(p)
				refresh()
			end)
			object:ListenToChange(collectablesPath, function(p)
				readFound(p) -- equivalent call inferred; original call site unknown
				refresh()
			end)
			object:ListenToChange(tutorialStepPath, function(p)
				local v10 = tonumber(p) or 0

				if v10 ~= v2 then
					v2 = v10
					quietClock.disturb(os.clock())
				end

				renderAll() -- equivalent call inferred; original call site unknown
			end)

			local function watchCharacter(character)
				if not character then
					return
				end

				character:GetAttributeChangedSignal("MonsterName"):Connect(renderAll)
				task.spawn(function()
					local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild(
						"Humanoid",
						10
					)

					if humanoid then
						humanoid.Died:Connect(renderAll)
						renderAll() -- equivalent call inferred; original call site unknown
					end
				end)
				renderAll() -- equivalent call inferred; original call site unknown
			end

			localPlayer.CharacterAdded:Connect(watchCharacter)
			watchCharacter(localPlayer.Character)
			watchProps(quest.PropTag, register, unregister)

			if Universe:IsLobby() then
				local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

				if playerGui then
					playerGui.ChildRemoved:Connect(function(child)
						if child.Name == "LoadingScreen" then
							tryLobbyBeats()
						end
					end)
				end

				task.spawn(function()
					while true do
						tryLobbyBeats()
						task.wait(4)
					end
				end)
			end
		end)
	else
		warn("[GourdyQuest] no data controller in this place — quest disabled")
	end
end

local flag = false
return {
	Start = function()
		if flag then
			return
		end

		flag = true
		local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)

		if not HolidayEventConfig.ENABLED then
			return
		end

		local v = loadContext()

		if not v then
			return
		end

		if RunService:IsServer() then
			_Server(v)
		else
			_Client(v)
		end
	end
}