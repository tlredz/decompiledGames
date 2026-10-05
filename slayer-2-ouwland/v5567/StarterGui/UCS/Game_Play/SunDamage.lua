local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local SignalFunction = require(ReplicatedStorage:WaitForChild("Communication"):WaitForChild("ServerAndClient"):WaitForChild("Signals"):WaitForChild("SignalFunction"))
local Utility = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local MinigameSettings = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("MinigameSettings"))
local PlayerStatResolver = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("PlayerStatResolver"))
local Worlds = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Worlds"))
local v = Worlds.ById[game.PlaceId]

if v == nil or v.SunDamage ~= true then
	return
end

local localPlayer = Players.LocalPlayer
local race = Utility.GetData(localPlayer, true):WaitForChild("Race")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Map"), workspace.Terrain }
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function setInSun(flag: boolean)
	if flag == v2 then
		return
	end

	local success, result = pcall(SignalFunction.ToServer, "SunDamage", flag)

	if success and result == true then
		v2 = flag
	end
end

while true do
	if race.Value == "Demon" then
		task.wait(1)

		if race.Value == "Demon" then
			if MinigameSettings.Get("NoSunDamage") == true then
				if v2 ~= false then
					local success, result = pcall(SignalFunction.ToServer, "SunDamage", false)

					if success and result == true then
						v2 = false
					end
				end
			elseif localPlayer:GetAttribute("Situation") == "Sunless" or localPlayer:GetAttribute("SecondarySituation") == "Sunless" then
				if v2 ~= false then
					local success, result = pcall(SignalFunction.ToServer, "SunDamage", false)

					if success and result == true then
						v2 = false
					end
				end
			else
				local v3 = false
				local character = localPlayer.Character
				local humanoidRootPart

				if character ~= nil then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or nil
				end

				local head

				if character ~= nil then
					head = character:FindFirstChild("Head") or nil
				end

				local humanoid

				if character ~= nil then
					humanoid = character:FindFirstChildOfClass("Humanoid") or nil
				end

				if humanoidRootPart ~= nil and humanoid ~= nil and humanoid.Health > 0 and character:FindFirstChildOfClass("ForceField") == nil and PlayerStatResolver.GetStat(
					localPlayer,
					"Sun Immunity"
				) ~= true then
					local sunDirection = Lighting:GetSunDirection()

					if sunDirection.Y > 0 then
						local position = (head or humanoidRootPart).Position
						local v4 = workspace:Raycast(position, sunDirection * 20000, raycastParams) ~= nil

						if v4 then
							for _, part in CollectionService:GetTagged("Damaging_Trees") do
								if not (part:IsA("BasePart") and (part.Position - humanoidRootPart.Position).Magnitude <= 60) then
									continue
								end

								v4 = false
								break
							end
						end

						v3 = not v4
					end
				end

				setInSun(v3) -- equivalent call inferred; original call site unknown
			end
		end
	else
		if v2 ~= false then
			local success, result = pcall(SignalFunction.ToServer, "SunDamage", false)

			if success and result == true then
				v2 = false
			end
		end

		if v2 then
			task.wait(1)
		else
			race.Changed:Wait()
		end
	end
end