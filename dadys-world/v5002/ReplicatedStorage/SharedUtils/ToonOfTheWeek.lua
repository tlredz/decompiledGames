local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local isServer = RunService:IsServer()
local toonMissions = ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("ToonMissions")
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
local SimulatedTime = require(ReplicatedStorage.SharedUtils.SimulatedTime)
local ReplicaCache = isServer and require(ServerScriptService.Modules.ReplicaCache) or {}
local TOTWSchedule = require(ReplicatedStorage.SharedData.TOTWSchedule)
local editData = ReplicatedStorage:WaitForChild("editData")

-- equivalent calls inferred from this helper; original call sites unknown
local function getReplica(p)
	return p and ReplicaCache[p.UserId]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetReplicaValue(p, p2, p3)
	local replica = getReplica(p) -- equivalent call inferred; original call site unknown

	if replica then
		replica:SetValue(p2, p3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReplicaArrayInsert(p, p2, p3)
	local replica = getReplica(p) -- equivalent call inferred; original call site unknown

	if replica then
		replica:ArrayInsert(p2, p3)
	end
end

local ToonOfTheWeek = {
	GetToon = function(self)
		local unixTimestamp = SimulatedTime.now().UnixTimestamp
		local toon = nil
		local v = nil
		local v2 = nil

		for k, v4 in pairs(TOTWSchedule) do
			local unixTimestamp2 = v4.Start.UnixTimestamp
			local unixTimestamp3 = v4.End and v4.End.UnixTimestamp or unixTimestamp2 + 604800

			if unixTimestamp < unixTimestamp2 or unixTimestamp3 <= unixTimestamp then
				continue
			end

			toon = v4.Toon or k
			v2 = unixTimestamp3
			v = unixTimestamp2
			break
		end

		if toon and v then
			workspace:SetAttribute("ToTW_StartTS", string.format("%s,%d,%d", toon, v, v2))
			return toon
		else
			workspace:SetAttribute("ToTW_StartTS", nil)
		end
	end
}
local modules = {}

function ToonOfTheWeek:AttemptRewardClaim(p, p2)
	if not isServer then
		return false, "ToTW Reward Claim can only be called from the server."
	end

	if not p2 then
		return false, "rewardIndex is required"
	end

	local toon = self:GetToon()
	local v = toon and toon .. "Missions"
	local v2 = v and modules[v]

	if not v2 then
		return false, "Unable to find initialized ToTW mission data module"
	end

	local v3 = tonumber(p2)

	if not v3 or typeof(v3) ~= "number" or not (v3 > 0 and v2.Rewards and v3 <= #v2.Rewards) then
		return false, "Invalid reward index"
	end

	local v4 = false
	local v5 = "N/A"
	editData:Invoke(p, function(p3)
		if p3 and p3.Data then
			if p3.Data.TOTW and p3.Data.TOTW.Missions then
				if p3.Data.TOTW.Missions[v] then
					local mission = p3.Data.TOTW.Missions[v]

					if not mission.Redeemed or type(mission.Redeemed) ~= "table" then
						mission.Redeemed = {}
						SetReplicaValue(p, string.format("TOTW.Missions.%s.Redeemed", v), {}) -- equivalent call inferred; original call site unknown
					end

					local missions = p3.Data.TOTW.Missions
					local count = 0
					local flag = true
					local v6 = "N/A"

					for _, v8 in pairs(v2.List) do
						local v9, v10 = table.unpack(v8.Path:split("."))

						if v9 and v10 then
							if missions[v9] and missions[v9][v10] and not ((missions[v9][v10].Progress or 0) < v8.Requirement) then
								count += 1
							end
						else
							v6 = "Missing parent or child string from path: " .. v8.Path
							flag = false
							break
						end
					end

					if flag then
						if count < v3 then
							v4 = false
							v5 = "Not enough completed quests to claim reward " .. v3
						else
							local reward = v2.Rewards[v3]

							if reward then
								if reward.Type == "Skin" then
									local v8 = {}

									for _, skin in pairs(p3.Data.Skins) do
										if skin then
											table.insert(v8, skin[1])
										end
									end

									if table.find(v8, reward.Value) then
										print("User already has skin!")
									else
										ReplicaArrayInsert(p, "Skins", { reward.Value, "Default" }) -- equivalent call inferred; original call site unknown
										print("Successfully rewarded " .. p.Name .. " with " .. reward.Value .. "!")
									end
								elseif reward.Type == "Sticker" then
									if table.find(p3.Data.StickersOwned, reward.Value) then
										print("User already has sticker!")
									else
										ReplicaArrayInsert(p, "StickersOwned", reward.Value) -- equivalent call inferred; original call site unknown
										print("Successfully rewarded " .. p.Name .. " with sticker " .. reward.Value .. "!")
									end
								elseif reward.Type == "Title" then
									if p3.Data.Titles[reward.Value] then
										print("User already has title!")
									else
										local unixTimestamp = DateTime.now().UnixTimestamp
										p3.Data.Titles[reward.Value] = unixTimestamp
										SetReplicaValue(p, "Titles." .. reward.Value, unixTimestamp) -- equivalent call inferred; original call site unknown
										print("Successfully rewarded " .. p.Name .. " with title " .. reward.Value .. "!")

										if reward.BonusIchor then
											p3.Data.Coin += reward.BonusIchor
											SetReplicaValue(p, "Coin", p3.Data.Coin) -- equivalent call inferred; original call site unknown
											print("Successfully rewarded " .. p.Name .. " with " .. reward.BonusIchor .. " bonus ichor!")
										end
									end
								end
							end

							mission.Redeemed[v3] = true
							SetReplicaValue(p, string.format("TOTW.Missions.%s.Redeemed", v), mission.Redeemed) -- equivalent call inferred; original call site unknown
							v4 = true
						end
					else
						v4 = false
						v5 = "Failed validity check: " .. v6
					end
				else
					v4 = false
					v5 = "Missing TOTW.Missions." .. v
				end
			else
				v4 = false
				v5 = "Missing TOTW.Missions inside profile.Data"
			end
		else
			v4 = false
			v5 = "Missing profile data"
		end
	end)
	return v4, v5
end

function ToonOfTheWeek:init()
	if not isServer or script:GetAttribute("Initialized") then
		return
	end

	script:SetAttribute("Initialized", true)

	local function toonChange()
		local toTW_StartTS = workspace:GetAttribute("ToTW_StartTS")

		if not toTW_StartTS then
			return
		end

		local v, v2 = table.unpack(toTW_StartTS:split(","))

		if not (v and v2 and tonumber(v2)) then
			return
		end

		tonumber(v2)
		local v3 = v and v .. "Missions"
		local child = v3 and toonMissions:FindFirstChild(v3)
		local module = child and require(child)

		if not module then
			return
		end

		modules[v3] = module

		if not Universe:IsGame() then
			return
		end

		for k, v4 in pairs(module.List) do
			if typeof(v4) == "table" then
				if v4.GameSetup then
					if v4.Path then
						if v4.Requirement then
							local success, result = pcall(v4.GameSetup, v4)

							if not success then
								print("MISSION SETUP FAILED FOR: " .. v .. " at index " .. k .. ", errmsg: " .. tostring(result))
							end
						else
							print("Mission for " .. v .. " at index " .. k .. " is missing the Requirement variable!")
						end
					else
						print("Mission for " .. v .. " at index " .. k .. " is missing the Path variable!")
					end
				else
					print("Mission for " .. v .. " at index " .. k .. " is missing the GameSetup function!")
				end
			else
				print("Mission for " .. v .. " at index " .. k .. " is not a table!")
			end
		end
	end

	workspace:GetAttributeChangedSignal("ToTW_StartTS"):Connect(toonChange)
	SimulatedTime:Subscribe(function()
		self:GetToon()
	end)
end

return ToonOfTheWeek