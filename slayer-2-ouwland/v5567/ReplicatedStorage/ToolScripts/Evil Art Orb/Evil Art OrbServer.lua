local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local EvilArtCores = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.EvilArtCores)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Item = require(ServerStorage.SAM.Services.Removers.Item)

-- equivalent calls inferred from this helper; original call sites unknown
local function muzanSays(p, text: string)
	SignalEvent.ToClient(p, "NpcNotify", {
		Icon = BunchaIcons.MuzanIcon,
		Text = text,
		Duration = MuzanSettings.GrantShoutDuration
	})
end

local EvilArtOrbServer = {}

function EvilArtOrbServer.MouseDown(p, p2, p3, value: string)
	if not (Checker.check(p) and p3.Thread == nil) then
		return
	end

	local data = Utility.GetData(p)

	if data == nil or Utility.HeldItem(data, value) == nil then
		return
	end

	if data.Powers.DemonArt.Value == "" then
		local function cancelSqueeze()
			if p3.Thread ~= nil then
				task.cancel(p3.Thread)
				p3.Thread = nil
				EffectsEvent.ToAllInRange(p2, "EvilArtSqueeze", p2, "Cancel")
			end
		end

		local v, v2 = ManuelCancel.new(p, 0.9333333333333333)
		v:Connect(cancelSqueeze)
		EffectsEvent.ToAllInRange(p2, "EvilArtSqueeze", p2)
		p3.Thread = task.spawn(function()
			task.wait(0.8833333333333333)
			p3.Thread = nil
			v2()

			if Checker.check_victim(script, p2, p2) == nil then
				return
			end

			local key = EvilArtCores.Key((value:gsub(" Orb$", "")))
			local canAddQuest, _, v3 = Quests.CanAddQuest(p, key)

			if canAddQuest == true then
				Quests.AddQuest(p, key)
				task.delay(1.1166666666666667, function()
					if p.Parent == nil or Item(p, value, nil, nil, "Consumed") then
						return
					end

					local data2 = Utility.GetData(p)

					if data2 == nil then
						return
					end

					for _, child in data2.Quests.Holder:GetChildren() do
						local questString = child:FindFirstChild("QuestString")

						if not (questString ~= nil and questString.Value == key) then
							continue
						end

						Quests.DeleteQuest(p, child)
						break
					end
				end)
			else
				muzanSays(p, v3 == nil and "Not now." or `Cancel '{v3}' first.`) -- equivalent call inferred; original call site unknown
			end
		end)
	else
		muzanSays(p, MuzanSettings.OrbHasArtText) -- equivalent call inferred; original call site unknown
	end
end

function EvilArtOrbServer.MouseUp(_, p, p2)
	if p2.Thread ~= nil then
		task.cancel(p2.Thread)
		p2.Thread = nil
		EffectsEvent.ToAllInRange(p, "EvilArtSqueeze", p, "Cancel")
	end
end

return EvilArtOrbServer