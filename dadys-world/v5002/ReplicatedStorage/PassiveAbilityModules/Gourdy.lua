local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GourdyGlobalBoosts = require(ReplicatedStorage.CharacterModules.GourdyGlobalBoosts)
local Gourdy = {}

function Gourdy.Initialize(p, _)
	GourdyGlobalBoosts.RegisterGourdy(p)
	local info = Workspace:FindFirstChild("Info")

	if not info then
		warn("Gourdy Passive: Info folder not found in workspace")
		return function()
			GourdyGlobalBoosts.UnregisterGourdy()
		end
	end

	local v = {}
	local floorActive = info:FindFirstChild("FloorActive")

	if floorActive then
		v.elevatorConnection = floorActive.Changed:Connect(function()
			if floorActive.Value == true then
				task.defer(function()
					GourdyGlobalBoosts.TryApplyElevatorBoost()
				end)
			end
		end)

		if floorActive.Value == true then
			task.spawn(GourdyGlobalBoosts.TryApplyElevatorBoost)
		end
	else
		warn("Gourdy Passive: FloorActive not found in Info")
	end

	local panic = info:FindFirstChild("Panic")

	if panic then
		v.panicConnection = panic.Changed:Connect(function()
			if panic.Value == true then
				task.spawn(function()
					GourdyGlobalBoosts.TryApplyPanicBoost()
				end)
			end
		end)
	else
		warn("Gourdy Passive: Panic not found in Info")
	end

	return function()
		for _, connection in pairs(v) do
			if connection then
				connection:Disconnect()
			end
		end

		GourdyGlobalBoosts.UnregisterGourdy(p)
	end
end

function Gourdy.Activate(_, _, _) end

function Gourdy.Deactivate(_, _) end

function Gourdy.Cleanup(_, _) end

return Gourdy