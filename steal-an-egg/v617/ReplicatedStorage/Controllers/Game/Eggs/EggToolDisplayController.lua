local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggState = require(ReplicatedStorage.Client.EggState)
local EggToolDisplay = require(ReplicatedStorage.Shared.Eggs.EggToolDisplay)
local Log = require(ReplicatedStorage.Packages.Log)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = Log.new()
local v2 = {}
return {
	Start = function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyActiveDisplay(state)
			state.ActiveDisplayVersion += 1

			if state.ActiveDisplay ~= nil then
				state.ActiveDisplay:Destroy()
				state.ActiveDisplay = nil
			end

			state.ActiveTool = nil
		end

		local function attachTool(state, activeTool)
			if state.ActiveTool == activeTool then
				return
			end

			destroyActiveDisplay(state) -- equivalent call inferred; original call site unknown
			local toolUid = EggToolDisplay.GetToolUid(activeTool)

			if toolUid == nil then
				v:AtError():Log((`Egg tool {activeTool:GetFullName()} is missing an egg UID`))
				return
			end

			local ownedEgg = EggState.ReadOwnedEgg(state.Owner.UserId, toolUid)

			if ownedEgg == nil and state.Owner == Players.LocalPlayer then
				ownedEgg = EggState.FetchEggRecord(toolUid)
			end

			if ownedEgg == nil then
				v:AtDebug():Log((`Egg tool {activeTool:GetFullName()} has no record for owner {state.Owner.UserId}`))
				return
			end

			state.ActiveTool = activeTool
			state.ActiveDisplayVersion += 1
			local activeDisplayVersion = state.ActiveDisplayVersion
			local activeDisplay = EggToolDisplay.new(activeTool, {
				OwnerUserId = state.Owner.UserId,
				UID = toolUid,
				ModelName = `{state.Owner.UserId}_{toolUid}`,
				Record = ownedEgg
			})

			if state.ActiveTool == activeTool and state.ActiveDisplayVersion == activeDisplayVersion and activeTool.Parent ~= nil then
				state.ActiveDisplay = activeDisplay
			else
				activeDisplay:Destroy()
			end
		end

		local function refreshActiveTool(state)
			local character = state.Owner.Character

			if character == nil then
				return
			end

			for _, child in ipairs(character:GetChildren()) do
				if not (child.ClassName == "Tool" and EggToolDisplay.IsEggTool(child)) then
					continue
				end

				attachTool(state, child)
				break
			end
		end

		local function bindCharacter(state, instance)
			if state.CharacterTrove ~= nil then
				state.CharacterTrove:Destroy()
			end

			destroyActiveDisplay(state) -- equivalent call inferred; original call site unknown
			local characterTrove = Trove.new()
			state.CharacterTrove = characterTrove
			characterTrove:Connect(instance.ChildAdded, function(instance2)
				if instance2.ClassName == "Tool" and EggToolDisplay.IsEggTool(instance2) then
					attachTool(state, instance2)
				end
			end)
			characterTrove:Connect(instance.ChildRemoved, function(p)
				if p == state.ActiveTool then
					destroyActiveDisplay(state) -- equivalent call inferred; original call site unknown
				end
			end)
			refreshActiveTool(state)
		end

		local function syncActiveParasite(data)
			local activeTool = data.ActiveTool
			local activeDisplay = data.ActiveDisplay

			if activeTool == nil or activeDisplay == nil then
				return
			end

			local toolUid = EggToolDisplay.GetToolUid(activeTool)

			if toolUid == nil then
				return
			end

			local ownedEgg = EggState.ReadOwnedEgg(data.Owner.UserId, toolUid)

			if ownedEgg == nil then
				return
			end

			activeDisplay:SyncParasite(ownedEgg.HasParasite)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyPlayerState(player)
			local v3 = v2[player]

			if v3 == nil then
				return
			end

			destroyActiveDisplay(v3) -- equivalent call inferred; original call site unknown

			if v3.CharacterTrove ~= nil then
				v3.CharacterTrove:Destroy()
			end

			v3.Trove:Destroy()
			v2[player] = nil
		end

		local function trackPlayer(player)
			destroyPlayerState(player) -- equivalent call inferred; original call site unknown
			local v3 = {
				Owner = player,
				Trove = Trove.new(),
				CharacterTrove = nil,
				ActiveTool = nil,
				ActiveDisplay = nil,
				ActiveDisplayVersion = 0
			}
			v2[player] = v3
			v3.Trove:Connect(player.CharacterAdded, function(p)
				bindCharacter(v3, p)
			end)
			v3.Trove:Connect(player.CharacterRemoving, function()
				destroyActiveDisplay(v3) -- equivalent call inferred; original call site unknown

				if v3.CharacterTrove ~= nil then
					v3.CharacterTrove:Destroy()
					v3.CharacterTrove = nil
				end
			end)

			if player.Character ~= nil then
				bindCharacter(v3, player.Character)
			end
		end

		Players.PlayerAdded:Connect(function(player)
			task.defer(trackPlayer, player)
		end)
		Players.PlayerRemoving:Connect(destroyPlayerState)

		for _, v3 in ipairs(Players:GetPlayers()) do
			task.defer(trackPlayer, v3)
		end

		EggState.OwnerRefreshed:Connect(function(p: number)
			for _, v3 in v2 do
				if v3.Owner.UserId ~= p then
					continue
				end

				if v3.Owner == Players.LocalPlayer then
					task.defer(syncActiveParasite, v3)
				else
					local activeTool = v3.ActiveTool
					local activeDisplay = v3.ActiveDisplay

					if activeTool ~= nil and activeDisplay ~= nil then
						local toolUid = EggToolDisplay.GetToolUid(activeTool)

						if toolUid ~= nil then
							local ownedEgg = EggState.ReadOwnedEgg(v3.Owner.UserId, toolUid)

							if ownedEgg ~= nil then
								activeDisplay:SyncParasite(ownedEgg.HasParasite)
							end
						end
					end
				end
			end
		end)
	end
}