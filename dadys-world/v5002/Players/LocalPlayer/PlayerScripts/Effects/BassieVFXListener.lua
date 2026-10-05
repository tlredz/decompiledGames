local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage:FindFirstChild("Modules")
local data = modules and modules:FindFirstChild("Data")
local bassieVFXClient = data and data:FindFirstChild("BassieVFXClient") or modules and modules:FindFirstChild("BassieVFXClient")

if not bassieVFXClient then
	warn("BassieVFXListener: BassieVFXClient not found - Bassie's chunk attack will render no telegraph")
	return
end

local success, result = pcall(require, bassieVFXClient)

if not success then
	warn("BassieVFXListener: Failed to require BassieVFXClient:", result)
	return
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connectToEvent(remoteEvent)
	remoteEvent.OnClientEvent:Connect(function(p)
		if type(p) ~= "table" or not p.action then
			return
		end

		local success2, result2 = pcall(result.HandleEvent, p)

		if not success2 then
			warn("BassieVFXListener: Error handling", p.action, "—", result2)
		end
	end)
	print("BassieVFXListener: Connected to BassieVFX event")
end

local events = ReplicatedStorage:FindFirstChild("Events")

if not events then
	return
end

local bassieVFX = events:FindFirstChild("BassieVFX")

if bassieVFX then
	bassieVFX.OnClientEvent:Connect(function(p)
		if type(p) ~= "table" or not p.action then
			return
		end

		local success2, result2 = pcall(result.HandleEvent, p)

		if not success2 then
			warn("BassieVFXListener: Error handling", p.action, "—", result2)
		end
	end)
	print("BassieVFXListener: Connected to BassieVFX event")
else
	local childAddedConnection = nil
	childAddedConnection = events.ChildAdded:Connect(function(remoteEvent)
		if remoteEvent.Name == "BassieVFX" and remoteEvent:IsA("RemoteEvent") then
			childAddedConnection:Disconnect()
			connectToEvent(remoteEvent) -- equivalent call inferred; original call site unknown
		end
	end)
end