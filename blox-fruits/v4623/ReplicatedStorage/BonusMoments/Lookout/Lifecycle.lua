local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Controllers.BonusMomentsController.Types)
local DialogueRegistry = require(ReplicatedStorage.Controllers.BonusMomentsController.DialogueRegistry)
local Finale = require(script.Parent.Finale)
local Observation = require(script.Parent.Observation)
local Lookout = require(ReplicatedStorage.DialoguesList.NPCs.Lookout)
local v = nil
local flag = false
local v2 = {}
local v3 = {}

function v2:addLookoutOption(label: string)
	local v4 = 1

	while self[`Option{v4}`] ~= nil do
		v4 += 1
	end

	self[`Option{v4}`] = {
		Label = label,
		JumpTo = function()
			local v5 = v

			if v5 and Lookout.getDialogueOffer(v5) then
				return Lookout
			end

			return nil
		end
	}
end

function v2.wrapDialogue(object)
	return {
		Title = object.Title,
		InternalQuestName = object.InternalQuestName,
		Get = function(self)
			local v4 = object:Get()
			local v5 = v
			local v6

			if v5 then
				v6 = Lookout.getDialogueOffer(v5)
			end

			if v6 and typeof(v4) == "table" then
				v2.addLookoutOption(v4, v6.Label)
			end

			return v4
		end
	}
end

function v3.installDialogue()
	if flag then
		return
	end

	flag = true
	DialogueRegistry.register("Experienced Captain", "Lookout", 100, function(p)
		local v4 = v

		if typeof(p) == "table" and typeof(p.Get) == "function" and v4 and not v4.Completed and v4.Player:GetAttribute("CurrentLocation") == "Middle Town" then
			return v2.wrapDialogue(p)
		end

		return nil
	end)
end

function v3.onLoad(maid)
	if maid.Completed then
		Observation.cancel(maid)

		if not Finale.isActiveFor(maid) then
			Finale.cancel(maid)
		end
	else
		v = maid
		v3.installDialogue()
		local diedConnection = nil
		local count = 0
		local v4 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function invalidateDeathBinding()
			count += 1

			if diedConnection then
				diedConnection:Disconnect()
				diedConnection = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindDeath(character)
			invalidateDeathBinding() -- equivalent call inferred; original call site unknown

			if not character then
				return
			end

			local v5 = count
			task.spawn(function()
				local humanoid = character:FindFirstChildWhichIsA("Humanoid") or character:WaitForChild("Humanoid", 5)

				if v4 or v5 ~= count or maid.Player.Character ~= character or not (humanoid and humanoid:IsA("Humanoid")) then
					return
				end

				diedConnection = humanoid.Died:Connect(function()
					if v5 ~= count or maid.Player.Character ~= character then
						return
					end

					Observation.cancel(maid)
					Finale.cancel(maid)
				end)
			end)
		end

		local character = maid.Player.Character
		invalidateDeathBinding() -- equivalent call inferred; original call site unknown

		if character then
			local v5 = count
			task.spawn(function()
				local humanoid = character:FindFirstChildWhichIsA("Humanoid") or character:WaitForChild("Humanoid", 5)

				if v4 or v5 ~= count or maid.Player.Character ~= character or not (humanoid and humanoid:IsA("Humanoid")) then
					return
				end

				diedConnection = humanoid.Died:Connect(function()
					if v5 ~= count or maid.Player.Character ~= character then
						return
					end

					Observation.cancel(maid)
					Finale.cancel(maid)
				end)
			end)
		end

		maid:GiveTask(maid.Player.CharacterAdded:Connect(function(character2)
			Observation.cancel(maid)
			Finale.cancel(maid)
			bindDeath(character2) -- equivalent call inferred; original call site unknown
		end))
		maid:GiveTask(maid.Player:GetAttributeChangedSignal("CurrentLocation"):Connect(function()
			if maid.Player:GetAttribute("CurrentLocation") ~= "Middle Town" then
				Observation.cancel(maid)
				Finale.cancel(maid)
			end
		end))
		maid:GiveTask(function()
			v4 = true
			invalidateDeathBinding() -- equivalent call inferred; original call site unknown
			Observation.handleMomentCleanup(maid)
			Finale.handleMomentCleanup(maid)
		end)
	end
end

function v3.create()
	return {
		DataName = "Lookout",
		Repeatable = false,
		startObservation = function(p, p2)
			return Observation.start(p, p2)
		end,
		cancelObservation = function(p)
			Observation.cancel(p)
		end,
		playFinaleCutscene = function(p, p2, callback)
			return Finale.play(p, p2, callback)
		end,
		OnLoad = v3.onLoad,
		RemoteEvents = {
			IntroductionCooldownElapsed = function(p)
				Lookout.closeCooldownDialogue(p)
			end,
			CancelObservation = function(p)
				Observation.cancel(p)
			end,
			DebugFinale = function(object, p, p2)
				local function finishFinale()
					task.spawn(function()
						pcall(function()
							object:InvokeServer("FinishFinale", p2)
						end)
					end)
				end

				local v4, v5 = Finale.play(object, p, finishFinale)

				if not v4 then
					task.spawn(function()
						pcall(function()
							object:InvokeServer("FinishFinale", p2)
						end)
					end)
					warn((`[Lookout] Debug finale was rejected: {tostring(v5)}`))
				end
			end
		},
		OnComplete = function(p)
			Finale.handleMomentComplete(p)
			Observation.handleMomentComplete(p)

			if v == p then
				v = nil
			end
		end
	}
end

return table.freeze(v3)