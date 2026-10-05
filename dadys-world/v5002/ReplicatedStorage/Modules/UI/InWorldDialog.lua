local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SimpleZone = require(ReplicatedStorage.Modules:WaitForChild("SimpleZone"))
local dialogueEvent = ReplicatedStorage:FindFirstChild("StoryEvents") and ReplicatedStorage.StoryEvents:FindFirstChild("DialogueEvent")
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local Maid = require(ReplicatedStorage.SharedUtils.Maid)

local function resolveDialogId(instance, p)
	local id = p.id

	if type(id) == "string" and id ~= "" then
		return id
	end

	local dialogId = instance:GetAttribute("DialogId")

	if type(dialogId) == "string" and dialogId ~= "" then
		return dialogId
	end

	return nil
end

local function resolveTriggerId(instance, list, dialogModule)
	local dialogId = instance:GetAttribute("DialogId")

	if type(dialogId) == "string" and dialogId ~= "" then
		return dialogId
	end

	for _, v in ipairs(list) do
		if type(v.id) == "string" and v.id ~= "" then
			return v.id
		end
	end

	return dialogModule.Name
end

local function resolveDialogModule(instance)
	local moduleScript = instance:FindFirstChildWhichIsA("ModuleScript")

	if not moduleScript then
		local dialogModule = instance:GetAttribute("DialogModule")

		if type(dialogModule) == "string" and dialogModule ~= "" then
			local dialogueModules = ReplicatedStorage:FindFirstChild("DialogueModules")
			moduleScript = dialogueModules and dialogueModules:FindFirstChild(dialogModule)

			if not (moduleScript and moduleScript:IsA("ModuleScript")) then
				warn(("[InWorldDialog] %s names DialogModule '%s' but ReplicatedStorage.%s has no ModuleScript by that name; trigger ignored"):format(
					instance:GetFullName(),
					dialogModule,
					"DialogueModules"
				))
				return nil
			end
		end
	end

	if not moduleScript then
		warn(("[InWorldDialog] %s is tagged %s but has neither a ModuleScript child nor a DialogModule attribute; trigger ignored"):format(
			instance:GetFullName(),
			"StoryTrigger"
		))
		return nil
	end

	local success, result = pcall(require, moduleScript)

	if not success or type(result) ~= "table" then
		warn(("[InWorldDialog] %s could not load dialogue module %s: %s; trigger ignored"):format(
			instance:GetFullName(),
			moduleScript:GetFullName(),
			(tostring(result))
		))
		return nil
	end

	for i, v in ipairs(result) do
		if not (type(v) ~= "table" or type(v.character) ~= "string" or type(v.dialogue) ~= "string") then
			continue
		end

		warn(("[InWorldDialog] %s entry #%d is not {character = <Toon>, dialogue = <line>}; trigger ignored"):format(
			moduleScript:GetFullName(),
			i
		))
		return nil
	end

	if #result == 0 then
		warn(("[InWorldDialog] %s carries no dialogue entries; %s will record visits but play no line"):format(
			moduleScript:GetFullName(),
			instance:GetFullName()
		))
	end

	return moduleScript, result
end

local function resolveZonePart(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if not instance:IsA("Model") then
		warn(("[InWorldDialog] %s is tagged %s but is a %s; only a BasePart or a Model can be a trigger"):format(
			instance:GetFullName(),
			"StoryTrigger",
			instance.ClassName
		))
		return nil
	end

	local primaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)

	if primaryPart then
		print(("[InWorldDialog] %s is a tagged Model; its zone is %s (tag a BasePart directly to control the zone bounds)"):format(
			instance:GetFullName(),
			primaryPart:GetFullName()
		))
		return primaryPart
	end

	warn(("[InWorldDialog] %s is a tagged Model with no BasePart to build a zone from; trigger ignored"):format(instance:GetFullName()))
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function recordFoundDialog(p, id: string)
	local success, result = pcall(function()
		local ServerStorage = game:GetService("ServerStorage")
		require(ServerStorage.SharedModules.StatisticsManager):SetMapKey(p, "FoundDialog", id, os.time())
	end)

	if not success then
		warn("[InWorldDialog] Failed to record found dialog '" .. tostring(id) .. "': " .. tostring(result))
	end
end

local function getPlayerCharacterName(player)
	if not (player and player.Character) then
		return nil
	end

	local toonName = player.Character:GetAttribute("ToonName")

	if toonName then
		return toonName
	end

	local config = player.Character:FindFirstChild("Config")

	if config and config:FindFirstChild("ModuleName") then
		return config.ModuleName.Value
	end

	return nil
end

local function isPowered()
	local info = workspace:FindFirstChild("Info")
	local blackOut = info and info:FindFirstChild("BlackOut")
	return not blackOut or blackOut.Value ~= true
end

local v = {}

local function addZonePart(instance)
	if not instance:IsDescendantOf(workspace) then
		task.wait(5)

		if not instance:IsDescendantOf(workspace) then
			return
		end
	end

	local zonePart = resolveZonePart(instance)

	if not zonePart then
		return
	end

	local dialogModule, v2 = resolveDialogModule(instance)

	if not dialogModule then
		return
	end

	local function getDialogueForCharacter(toonName)
		local v3 = nil

		for _, v4 in ipairs(v2) do
			if v4.character ~= toonName then
				continue
			end

			if v3 then
				table.insert(v3, v4)
			else
				v3 = { v4 }
			end
		end

		if not v3 then
			return nil
		end

		if #v3 == 1 then
			return v3[1]
		end

		return v3[math.random(1, #v3)]
	end

	local duration = instance:GetAttribute("Duration") or 3
	local v3 = SimpleZone.fromPart(zonePart)
	local maid = Maid.new()
	local v4 = {}
	local v5 = {}
	v3.ItemEntered:Connect(function(player)
		if not player:IsA("Player") then
			return
		end

		local toonName

		if player and player.Character then
			toonName = player.Character:GetAttribute("ToonName")

			if not toonName then
				local config = player.Character:FindFirstChild("Config")

				if config and config:FindFirstChild("ModuleName") then
					toonName = config.ModuleName.Value
				else
					toonName = nil
				end
			end
		else
			toonName = nil
		end

		if not toonName then
			return
		end

		local dialogueForCharacter = getDialogueForCharacter(toonName)
		local v6 = player.UserId .. "_" .. toonName

		if v4[v6] then
			return
		end

		if not v5[v6] then
			v5[v6] = task.spawn(function()
				task.wait(duration)
				v5[v6] = nil

				if not (player and player.Parent) then
					return
				end

				if instance:GetAttribute("RequiresPower") then
					local info = workspace:FindFirstChild("Info")
					local blackOut = info and info:FindFirstChild("BlackOut")

					if blackOut and blackOut.Value == true then
						return
					end
				end

				v4[v6] = true
				local id

				if dialogueForCharacter then
					if dialogueEvent then
						dialogueEvent:Fire(
							player.Character,
							dialogueForCharacter.character,
							dialogueForCharacter.dialogue,
							3
						)
					end

					local v7 = instance
					id = dialogueForCharacter.id

					if type(id) ~= "string" or id == "" then
						id = v7:GetAttribute("DialogId")

						if type(id) ~= "string" or id == "" then
							id = nil
						end
					end

					ActionEvent:Record(
						player,
						"TriggerDialog",
						id or dialogueForCharacter.dialogue,
						dialogueForCharacter.character,
						dialogueForCharacter.dialogue
					)

					if id then
						recordFoundDialog(player, id) -- equivalent call inferred; original call site unknown
					end
				end

				local triggerId = resolveTriggerId(instance, v2, dialogModule)
				print(("[InWorldDialog] VisitStoryTrigger id=%s player=%s toon=%s linePlayed=%s trigger=%s"):format(
					triggerId,
					player.Name,
					toonName,
					tostring(dialogueForCharacter ~= nil),
					instance:GetFullName()
				))
				ActionEvent:Record(player, "VisitStoryTrigger", triggerId, id)
			end)
		end
	end)
	v3.ItemExited:Connect(function(player)
		if not player:IsA("Player") then
			return
		end

		local toonName

		if player and player.Character then
			toonName = player.Character:GetAttribute("ToonName")

			if not toonName then
				local config = player.Character:FindFirstChild("Config")

				if config and config:FindFirstChild("ModuleName") then
					toonName = config.ModuleName.Value
				else
					toonName = nil
				end
			end
		end

		if not toonName then
			return
		end

		local v6 = player.UserId .. "_" .. toonName

		if v5[v6] then
			task.cancel(v5[v6])
			v5[v6] = nil
		end
	end)
	v3:BindToHeartbeat()
	table.insert(v, v3)
	maid:GiveTask(instance.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			v3:UnbindFromHeartbeat()
			maid:Destroy()
			table.clear(v)
			table.clear(v4)

			for _, v6 in pairs(v5) do
				if v6 then
					task.cancel(v6)
				end
			end

			table.clear(v5)
		end
	end))
end

local InWorldDialog = {
	_init = function(self)
		CollectionService:GetInstanceAddedSignal("StoryTrigger"):Connect(addZonePart)
	end
}

if not RunService:IsServer() then
	return InWorldDialog
end

if script:GetAttribute("Initialized") then
	return
end

script:SetAttribute("Initialized", true)
InWorldDialog:_init()
return InWorldDialog