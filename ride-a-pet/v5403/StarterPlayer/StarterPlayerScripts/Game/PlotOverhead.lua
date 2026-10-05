local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local services = replicatedStorage:WaitForChild("Services")
local Player = require(services:WaitForChild("Player"))
local plotOverhead = replicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards"):WaitForChild("PlotOverhead")
local plots = workspace:WaitForChild("Plots")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearOverhead(instance)
	local v2 = v[instance]

	if v2 then
		v[instance] = nil
		v2:Destroy()
	end
end

local function UpdateOverhead(instance)
	ClearOverhead(instance) -- equivalent call inferred; original call site unknown
	local data = instance:FindFirstChild("Data")
	local owner = data and data:FindFirstChild("Owner")
	local baseplate = instance:FindFirstChild("Baseplate")
	local value = owner and owner.Value

	if not (value and baseplate) then
		return
	end

	local clone = plotOverhead:Clone()
	local displayName = clone:WaitForChild("DisplayName")
	displayName.Text = value == localPlayer and "Your Ranch" or string.format("%s's Ranch", value.DisplayName)

	if value == localPlayer then
		local profileHolder = clone:FindFirstChild("ProfileHolder")

		if profileHolder and not profileHolder:FindFirstChildOfClass("UIStroke") then
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = Color3.fromRGB(255, 85, 0)
			uIStroke.Thickness = 2
			uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uIStroke.Parent = profileHolder
		end
	end

	clone.Adornee = baseplate
	clone.Parent = localPlayer:WaitForChild("PlayerGui")
	v[instance] = clone
	task.spawn(function()
		local PFP = clone:FindFirstChild("PFP", true)
		local playerPFP = Player:FetchPlayerPFP(value.UserId)

		if PFP and clone.Parent and typeof(playerPFP) == "string" then
			PFP.Image = playerPFP
		end
	end)
end

local function WatchPlot(instance)
	local data = instance:WaitForChild("Data", 10)
	local owner = data and data:WaitForChild("Owner", 10)
	local baseplate = instance:WaitForChild("Baseplate", 10)

	if not (owner and baseplate) then
		return
	end

	owner.Changed:Connect(function()
		UpdateOverhead(instance)
	end)
	instance.ChildAdded:Connect(function(adornee)
		if adornee.Name == "Baseplate" then
			local v2 = v[instance]

			if v2 then
				v2.Adornee = adornee
			else
				UpdateOverhead(instance)
			end
		end
	end)
	UpdateOverhead(instance)
end

for _, child in plots:GetChildren() do
	task.spawn(WatchPlot, child)
end

plots.ChildAdded:Connect(WatchPlot)