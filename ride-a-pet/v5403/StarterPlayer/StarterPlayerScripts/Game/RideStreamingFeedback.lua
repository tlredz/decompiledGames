local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not workspace.StreamingEnabled then
	return
end

local localPlayer = Players.LocalPlayer
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local game2 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local v = nil
local renderSteppedConnection = nil
local v2 = nil
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GraphicsBars()
	local success, result = pcall(function()
		return UserGameSettings.SavedQualityLevel.Value
	end)
	return success and result or 0
end

local function PressureFor(p, p2, p3, p4)
	if p2 == 0 then
		return 0
	end

	local v3 = p / p2

	if v3 >= 0.05 or p4 >= 0.15 or p3 >= 3 then
		return 2
	end

	if v3 >= 0.03571428571428571 or p4 >= 0.075 then
		return 1
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopReporting()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v2 = nil
end

local function UpdateReporting()
	if v then
		local character = localPlayer.Character
		local v3 = localPlayer:GetAttribute("IsRiding") == true or localPlayer:GetAttribute("IsPassenger") == true
		local graphicsBars = GraphicsBars() -- equivalent call inferred; original call site unknown
		v:FireServer(character, 0, graphicsBars)

		if graphicsBars ~= 10 and v3 and character then
			if renderSteppedConnection and v2 == character then
				return
			end

			StopReporting() -- equivalent call inferred; original call site unknown
			v2 = character
			local total = 0
			local count = 0
			local count2 = 0
			local v5 = 0
			local v6 = 0
			local v7 = 0
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				total += dt
				count += 1
				v5 = math.max(v5, dt)

				if dt >= 0.05 then
					count2 += 1
				end

				if total < 1 then
					return
				end

				local now = os.clock()
				local v8 = total
				local v9 = count
				local v10 = count2
				local v11 = v5
				local v12

				if v9 == 0 then
					v12 = 0
				else
					local v13 = v8 / v9
					v12 = (v13 >= 0.05 or v11 >= 0.15 or v10 >= 3) and 2 or (v13 >= 0.03571428571428571 or v11 >= 0.075) and 1 or 0
				end

				if v6 <= v12 then
					v6 = v12
					v7 = now + 1.5
				elseif v7 <= now then
					v6 = v12
				end

				v:FireServer(character, v6, GraphicsBars())
				total = 0
				count = 0
				count2 = 0
				v5 = 0
			end)
			return
		end
	end

	StopReporting() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshRemote()
	local rideStreamingLoad = game2:FindFirstChild("RideStreamingLoad")

	if rideStreamingLoad and not rideStreamingLoad:IsA("RemoteEvent") then
		rideStreamingLoad = nil
	end

	if rideStreamingLoad == v then
		return
	end

	StopReporting() -- equivalent call inferred; original call site unknown
	v = rideStreamingLoad
	UpdateReporting()
end

local function RemoteChanged(p)
	if p.Name == "RideStreamingLoad" then
		RefreshRemote() -- equivalent call inferred; original call site unknown
	end
end

table.insert(connections, game2.ChildAdded:Connect(RemoteChanged))
table.insert(connections, game2.ChildRemoved:Connect(RemoteChanged))
table.insert(connections, UserGameSettings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(UpdateReporting))
table.insert(connections, localPlayer:GetAttributeChangedSignal("IsRiding"):Connect(UpdateReporting))
table.insert(connections, localPlayer:GetAttributeChangedSignal("IsPassenger"):Connect(UpdateReporting))
table.insert(connections, localPlayer.CharacterAdded:Connect(UpdateReporting))
table.insert(connections, localPlayer.CharacterRemoving:Connect(StopReporting))
script.Destroying:Connect(function()
	StopReporting() -- equivalent call inferred; original call site unknown

	for _, connection in connections do
		connection:Disconnect()
	end
end)
RefreshRemote() -- equivalent call inferred; original call site unknown