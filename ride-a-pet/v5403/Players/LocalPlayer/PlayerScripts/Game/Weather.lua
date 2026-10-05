local Weather = require(script.Weather)
local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local HttpService = game:GetService("HttpService")
local v = {}
local v2 = nil
local v3 = {}
local flag = false
local revision = -1
local flag2 = false
local v4 = false
local now = -1e999
local lastTime = os.clock()

local function ReconcileWeather()
	if flag2 then
		v4 = true
		return
	end

	flag2 = true

	while true do
		v4 = false
		local v5, v6 = xpcall(function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local v7 = {}

			for k, v8 in pairs(v) do
				if serverTimeNow < v8.EndsAt then
					v7[k] = v8
				end
			end

			if v2 and (not v2.EndsAt or serverTimeNow < v2.EndsAt) and not v7[v2.Type] then
				v7[v2.Type] = v2
			end

			local flag3 = false

			for k, v8 in pairs(v3) do
				local v9 = v7[k]
				local v10 = Weather[k]
				local v11 = not v10 or not v10.IsHealthy or v10.IsHealthy()

				if not (not v9 or v9.Variant ~= v8.Variant or v9.AppearanceId ~= v8.AppearanceId or not v11) then
					continue
				end

				if v10 and v10.Remove then
					v10.Remove()
				end

				v3[k] = nil
				flag3 = true
			end

			if flag3 then
				for k in pairs(v3) do
					local v8 = Weather[k]

					if v8 and v8.Ambience then
						v8.Ambience()
					end
				end
			end

			for k, v8 in pairs(v7) do
				local v9 = Weather[k]

				if not v9 or v3[k] then
					continue
				end

				v9.Spawn(v8.Variant, os.clock() - lastTime < 10)
				v3[k] = {
					Variant = v8.Variant,
					AppearanceId = v8.AppearanceId
				}
			end
		end, debug.traceback)

		if not v5 and os.clock() - now >= 60 then
			now = os.clock()
			warn("[WeatherClient] weather reconciliation failed; retrying: " .. tostring(v6))
		end

		if v4 then
			continue
		end

		flag2 = false
		break
	end
end

game2:WaitForChild("AddWeather").OnClientEvent:Connect(function(value, variant, value2)
	if type(value) ~= "string" then
		return
	end

	if type(value2) == "number" then
		if flag then
			return
		else
			v[value] = {
				Type = value,
				Variant = variant,
				EndsAt = value2
			}
		end
	else
		v2 = {
			Type = value,
			Variant = variant
		}
	end

	ReconcileWeather()
end)
game2:WaitForChild("ClearWeather").OnClientEvent:Connect(function(p)
	if p then
		if flag then
			return
		else
			v[p] = nil
		end
	else
		v2 = nil
	end

	ReconcileWeather()
end)
task.spawn(function()
	game2:WaitForChild("PrivateWeather").OnClientEvent:Connect(function(p, variant, endsAt)
		v2 = p and {
			Type = p,
			Variant = variant,
			EndsAt = endsAt
		} or nil
		ReconcileWeather()
	end)
end)
local serverData = game.ReplicatedStorage:WaitForChild("ServerData")

local function ReadWeatherSnapshot()
	local weatherSnapshotV2 = serverData:GetAttribute("WeatherSnapshotV2")
	local v5 = type(weatherSnapshotV2) == "string"

	if not v5 then
		if flag then
			return
		else
			weatherSnapshotV2 = serverData:GetAttribute("ActiveWeathers")
		end
	end

	if type(weatherSnapshotV2) ~= "string" then
		return
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, weatherSnapshotV2)

	if not success or type(result) ~= "table" then
		return
	end

	if v5 then
		if type(result.Revision) ~= "number" or type(result.Weathers) ~= "table" or result.Revision < revision then
			return
		end

		revision = result.Revision
		flag = true
		result = result.Weathers
	end

	local v6 = {}

	for _, v7 in pairs(result) do
		if not (type(v7) == "table" and type(v7.Type) == "string" and type(v7.EndsAt) == "number") then
			continue
		end

		v6[v7.Type] = v7
	end

	v = v6
	ReconcileWeather()
end

serverData:GetAttributeChangedSignal("WeatherSnapshotV2"):Connect(ReadWeatherSnapshot)
serverData:GetAttributeChangedSignal("ActiveWeathers"):Connect(ReadWeatherSnapshot)
ReadWeatherSnapshot()
task.spawn(function()
	while true do
		task.wait(5)
		ReadWeatherSnapshot()
	end
end)
local PetRenderer = require(script.Parent:WaitForChild("Pets"):WaitForChild("PetRenderer"))
local General = require(game.ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("General"))
local Mutations = require(game.ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))
local activeEggs = game.ReplicatedStorage:WaitForChild("ServerData"):WaitForChild("ActiveEggs")
local GameSettings = require(game.ReplicatedStorage:WaitForChild("GameSettings"))
local mutationsByInstance = {}
local childAddedConnection = nil
local thread = nil
local thread2 = nil

local function BlanketMode()
	return GameSettings.MUTATEALLEGGSONWEATHER ~= false
end

local random = Random.new()

local function LookingAt(position)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local v5 = position - humanoidRootPart.Position

	if v5.Magnitude > 100 then
		return false
	end

	local vector = Vector3.new(v5.X, 0, v5.Z)

	if vector.Magnitude < 0.001 then
		return true
	end

	local currentCamera = workspace.CurrentCamera
	local lookVector = currentCamera and currentCamera.CFrame.LookVector or humanoidRootPart.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	return not (vector2.Magnitude < 0.001) and vector2.Unit:Dot(vector.Unit) >= 0.7
end

local function Paint(instance, mutation)
	if not instance:GetAttribute("Egg") then
		return false
	end

	if Mutations.FactorFor(instance:GetAttribute("Mutation")) < Mutations.FactorFor(mutation) then
		instance:SetAttribute("Mutation", mutation)
		mutationsByInstance[instance] = mutation
		return true
	else
		return false
	end
end

local function StrikeOne(p, p2, p3, p4)
	local count = 0
	local count2 = 0
	local children = {}
	local count3 = 0
	local v5 = nil

	for _, child in activeEggs:GetChildren() do
		if not child:GetAttribute("Egg") then
			continue
		end

		count += 1

		if typeof(child:GetAttribute("Position")) == "Vector3" then
			if Mutations.FactorFor(child:GetAttribute("Mutation")) >= Mutations.FactorFor(p) then
				count2 += 1
			else
				table.insert(children, child)

				if p3 and child.Name == p3 then
					v5 = child
				end
			end
		else
			count3 += 1
		end
	end

	if #children == 0 then
		warn(string.format(
			"[EggIllusion] nothing to strike - eggs=%d noPosition=%d notImprovable=%d mutation=%s",
			count,
			count3,
			count2,
			(tostring(p))
		))
		return
	end

	if p4 and not v5 then
		return
	end

	local v6 = v5 or children[random:NextInteger(1, #children)]
	local position = v6:GetAttribute("Position")

	if Paint(v6, p) then
		warn(string.format(
			"[EggIllusion] struck %s at %s (variant=%s, priority=%s)",
			tostring(v6:GetAttribute("Egg")),
			tostring(position),
			tostring(p2),
			(tostring(v5 ~= nil))
		))
		local success, result = pcall(Weather.Storm.Strike, position, p2, true)

		if not success then
			warn("[EggIllusion] the bolt itself failed: " .. tostring(result))
		end
	else
		warn("[EggIllusion] Paint refused " .. tostring(v6:GetAttribute("Egg")))
	end
end

game2:WaitForChild("OnboardingEggIllusion").OnClientEvent:Connect(function(p, p2, childName, p3)
	warn(string.format(
		"[EggIllusion] remote: mutation=%s variant=%s priority=%s blanket=%s",
		tostring(p),
		tostring(p2),
		tostring(childName),
		(tostring(GameSettings.MUTATEALLEGGSONWEATHER ~= false))
	))

	if p then
		if GameSettings.MUTATEALLEGGSONWEATHER ~= false and not p3 then
			for _, child in activeEggs:GetChildren() do
				Paint(child, p)
			end

			childAddedConnection = activeEggs.ChildAdded:Connect(function(child)
				task.defer(Paint, child, p)
			end)
		else
			if not p3 then
				thread = task.spawn(function()
					while true do
						task.wait(random:NextNumber(3, 10))
						StrikeOne(p, p2, nil)
					end
				end)
			end

			if childName then
				thread2 = task.spawn(function()
					while true do
						task.wait(0.25)
						local child = activeEggs:FindFirstChild(childName)
						local position = child and child:GetAttribute("Position")

						if not child or typeof(position) ~= "Vector3" then
							break
						end

						if not LookingAt(position) then
							continue
						end

						StrikeOne(p, p2, childName, p3)
						break
					end
				end)
			end
		end
	else
		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		if thread2 then
			task.cancel(thread2)
			thread2 = nil
		end

		for k, v5 in mutationsByInstance do
			if k.Parent and k:GetAttribute("Mutation") == v5 then
				k:SetAttribute("Mutation", nil)
			end
		end

		table.clear(mutationsByInstance)
	end
end)
game2:WaitForChild("LightningStrike").OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" then
		return
	end

	local variant = data.Variant
	local position = nil
	local v5 = false

	if data.Kind == "Pet" then
		local v6

		if data.Mutation then
			v6 = PetRenderer.ApplyMutation(tonumber(data.Owner), data.PetKey, data.Mutation)
		else
			v6 = PetRenderer.Get(tonumber(data.Owner), data.PetKey)
		end

		if v6 and v6.Model and v6.Model.Parent then
			position = v6.Model:GetPivot().Position
		else
			return
		end
	elseif data.Kind == "Ridden" then
		local playerByUserId = game.Players:GetPlayerByUserId((tonumber(data.Owner)))
		local character = playerByUserId and playerByUserId.Character

		if not character then
			return
		end

		position = character:GetPivot().Position
	elseif data.Kind == "CarriedEgg" then
		local playerByUserId = game.Players:GetPlayerByUserId((tonumber(data.Owner)))
		local character = playerByUserId and playerByUserId.Character

		if not character then
			return
		end

		local displayEgg = character:FindFirstChild("DisplayEgg", true) or character:FindFirstChild("HeldEggDisplay")

		if not displayEgg then
			return
		end

		position = displayEgg:GetPivot().Position
		v5 = true
	elseif data.Kind == "NestEgg" then
		local playerByUserId = game.Players:GetPlayerByUserId((tonumber(data.Owner)))
		local plot = playerByUserId and General:GetPlot(playerByUserId)
		local eggs = plot and plot:FindFirstChild("Eggs")
		local v6 = nil

		if eggs then
			for _, child in eggs:GetChildren() do
				if child:GetAttribute("EggKey") ~= data.EggKey then
					continue
				end

				v6 = child
				break
			end
		end

		if not v6 then
			return
		end

		v6:SetAttribute("Mutation", data.Mutation)
		position = v6:GetPivot().Position
		v5 = true
	elseif typeof(data.Position) == "Vector3" then
		position = data.Position

		if data.Exact == true then
			v5 = true
		else
			v5 = false
		end
	end

	if not position then
		return
	end

	task.spawn(Weather.Storm.Strike, position, variant, v5)
end)