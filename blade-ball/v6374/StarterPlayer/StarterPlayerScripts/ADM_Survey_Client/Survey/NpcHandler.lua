local createVector = vector.create
local NpcHandler = {}
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ConversationHandler = require(script.Parent:WaitForChild("ConversationHandler"))
local folder = nil
local v = {}
local v2 = {}
local v3 = {}
local v4 = game.Players.LocalPlayer.UserId == 3339860557 or game.Players.LocalPlayer.UserId == 7658109668

local function devPrint(...)
	if v4 then
		print("[AdMonitor DEV]", ...)
	end
end

local function devWarn(...)
	if RunService:IsStudio() or v4 then
		warn(...)
	end
end

local v5 = {
	Character = function(cframe: CFrame, data, parent)
		if not data.humanoidDescriptionProperties then
			return
		end

		local R15

		if data.rigType then
			R15 = Enum.HumanoidRigType[data.rigType]
		else
			R15 = Enum.HumanoidRigType.R15
		end

		local humanoidDescription = Instance.new("HumanoidDescription")

		for k, humanoidDescriptionProperty in data.humanoidDescriptionProperties do
			if type(humanoidDescriptionProperty) == "table" and humanoidDescriptionProperty.Color3 then
				humanoidDescription[k] = Color3.fromRGB(unpack(humanoidDescriptionProperty.value))
			else
				humanoidDescription[k] = humanoidDescriptionProperty
			end
		end

		local humanoidModelFromDescription = Players:CreateHumanoidModelFromDescription(humanoidDescription, R15)
		local humanoid = humanoidModelFromDescription:WaitForChild("Humanoid")
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.NameDisplayDistance = 0
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoidModelFromDescription.Parent = parent
		humanoidModelFromDescription.HumanoidRootPart.Anchored = true

		if data.characterHeight then
			humanoidModelFromDescription:PivotTo(cframe + Vector3.new(0, data.characterHeight / 2, 0))
		else
			local _, v6 = humanoidModelFromDescription:GetBoundingBox()
			humanoidModelFromDescription:PivotTo(cframe + Vector3.new(0, v6.Y / 2, 0))
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = "http://www.roblox.com/asset/?id=507770239"
		local track = humanoid.Animator:LoadAnimation(animation)
		track.Looped = true
		track:Play()
	end,
	ProximityPrompt = function(cframe: CFrame, p, p2, p3, p4, parent)
		if not p.offset then
			return
		end

		local part = Instance.new("Part")
		part.Name = "SurveyProximityPromptHolder"
		part.Transparency = 1
		part.CanCollide = false
		part.Anchored = true
		part.Size = createVector(0.1, 0.1, 0.1)
		part.CFrame = cframe * CFrame.new((Vector3.new(unpack(p.offset))))
		local v6 = cframe * CFrame.new((Vector3.new(unpack(p4.cameraVectorOffset))))
		local v7 = cframe * CFrame.new((Vector3.new(unpack(p4.lookVectorOffset))))
		local cframe2 = CFrame.new(v6.Position, v7.Position)
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Triggered:Connect(function()
			ConversationHandler.startDialog(v3[p2], p3, cframe2)
		end)
		proximityPrompt.ActionText = "Talk"
		proximityPrompt.ObjectText = p3.name
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Parent = part
		ConversationHandler.addProximityPrompt(proximityPrompt)
		part.Parent = parent
		return proximityPrompt
	end,
	NpcCircle = function(cframe: CFrame, p, parent)
		if not p.offset then
			return
		end

		local npcCircle = script:FindFirstChild("NpcCircle")

		if not npcCircle then
			devWarn("[AdMonitor]: Missing 'NpcCircle'. Please update your adtech installer and re-install adtech!")
			return
		end

		local clone = npcCircle:Clone()
		clone.CFrame = cframe * CFrame.new((Vector3.new(unpack(p.offset)))) * CFrame.Angles(0, 0, 4.71238898038469)
		clone.Parent = parent
	end,
	MasterWu = function(cframe: CFrame, p, parent)
		if not p.offset then
			p.offset = { 0, 0, 0 }
		end

		local masterWu = script:FindFirstChild("MasterWu")

		if not masterWu then
			devWarn("[AdMonitor]: Missing 'MasterWu' inside the survey scripts!")
			return
		end

		local clone = masterWu:Clone()
		local animator = clone:WaitForChild("AnimationController"):WaitForChild("Animator")
		local v6 = cframe * CFrame.new((Vector3.new(unpack(p.offset)))) * CFrame.Angles(0, -1.5707963267948966, 0)
		clone.Parent = parent
		clone:PivotTo(v6)
		local masterWuAnimation = script.Parent.Parent:GetAttribute("MasterWuAnimation")

		if not masterWuAnimation or masterWuAnimation == "" or masterWuAnimation == "rbxassetid://" then
			devWarn("No animation ID in MasterWu's attribute 'MasterWuAnimation' for the survey!")
			return
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = masterWuAnimation
		local track = animator:LoadAnimation(animation)
		track.Looped = true
		track:Play()
	end
}

local function getShuffledNpcNames()
	local result = {}

	for k in v2 do
		table.insert(result, k)
	end

	for i = #result, 2, -1 do
		local v6 = math.random(i)
		local v7 = result[v6]
		local v8 = result[i]
		result[i] = v7
		result[v6] = v8
	end

	return result
end

local function createLocationObject(cframe: CFrame, characterInformation, p, cameraInformation, p2: string, folder2)
	if not characterInformation then
		return
	end

	for _, item in characterInformation do
		if item.objectType == "ProximityPrompt" then
			v5[item.objectType](cframe, item, p2, p, cameraInformation, folder2)
		elseif v5[item.objectType] then
			v5[item.objectType](cframe, item, folder2)
		else
			devWarn("[AdMonitor]: Unsupported object type when creating survey NPC")
		end
	end
end

local function handleLocationData(instance, info, questionSetUuid, shuffledNpcName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "AdMonitor-SurveyNpcs"
		folder.Parent = workspace
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(info.character_appearance)
	end)

	if not success then
		devWarn("[AdMonitor]: Invalid json object when handling NPC character_appearance", result)
		return
	end

	if not result.characterInformation then
		devWarn("[AdMonitor]: Missing characterInformation inside the NPCs character_appearance")
		return
	end

	if not result.cameraInformation then
		devWarn("[AdMonitor]: Missing cameraInformation inside the NPCs character_appearance")
		return
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = info.name
	folder2.Parent = folder
	createLocationObject(instance.CFrame - Vector3.new(0, instance.Size.Y / 2, 0), result.characterInformation, {
		name = info.name,
		uuid = shuffledNpcName
	}, result.cameraInformation, questionSetUuid, folder2)
	return folder2
end

local function locationAdded(instance)
	devPrint("Location Added!")
	local location = instance:GetAttribute("Location") or instance:GetAttribute("location") or ""
	instance.Transparency = 1
	local addedNpcs, object, npcUuid = NpcHandler.addedNpcs({
		[instance] = {
			location = location
		}
	})
	v[instance] = {
		location = location,
		object = object,
		npcUuid = npcUuid
	}
	devPrint("Location successfully handled:", addedNpcs)

	if addedNpcs then
	end
end

function NpcHandler.addedNpcs(p)
	devPrint("Running addedNpcs")

	for k, v6 in p or v do
		if v6.object then
			devPrint("Location already has an object")
		else
			local shuffledNpcNames = getShuffledNpcNames()
			devPrint("About to iterate NPCs to see if any are compatible with", v6.location)

			for _, shuffledNpcName in shuffledNpcNames do
				local v8 = v2[shuffledNpcName]
				devPrint("Checking", v8.info.location)

				if (v8.info.location or "") == v6.location then
					devPrint("Got a valid npc location")
					local object = handleLocationData(k, v8.info, v8.questionSetUuid, shuffledNpcName)

					if p then
						devPrint("Just handling the one.")
						return true, object, shuffledNpcName
					end

					v6.object = object
					v6.npcUuid = shuffledNpcName
					break
				else
					devPrint("Skipping", v8.info.location or "")
				end
			end
		end
	end
end

function NpcHandler.addQuestionSet(p)
	v3[p.uuid] = p
end

function NpcHandler.addNpc(p, info, questionSetUuid)
	v2[p] = {
		info = info,
		questionSetUuid = questionSetUuid
	}
end

function NpcHandler.destroyAllNpcsWithUuid(p: string)
	for k, v6 in v do
		if not (v6.object and v6.npcUuid == p) then
			continue
		end

		v6.object:Destroy()
		v[k] = nil
	end
end

function NpcHandler.init()
	ConversationHandler.init(NpcHandler.destroyAllNpcsWithUuid)

	for _, v6 in CollectionService:GetTagged("SurveyLocation-ADM") do
		locationAdded(v6)
	end

	CollectionService:GetInstanceAddedSignal("SurveyLocation-ADM"):Connect(locationAdded)
end

return NpcHandler