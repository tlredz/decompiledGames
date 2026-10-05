local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local WinPadClient = {}
local connections = {}
local v = {}
local v2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function render(p)
	p.Text = Numbers.formatNumber(v2) .. " WINS"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function renderAll()
	for k in v do
		render(k) -- equivalent call inferred; original call site unknown
	end
end

function WinPadClient.start(p)
	WinPadClient.stop()
	local adminAbuseBossSync = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes"):WaitForChild("AdminAbuseBossSync")
	table.insert(connections, adminAbuseBossSync.OnClientEvent:Connect(function(value)
		if type(value) ~= "number" then
			return
		end

		v2 = value
		renderAll() -- equivalent call inferred; original call site unknown
	end))

	for _, label in CollectionService:GetTagged(p.WinPadLabelTag) do
		if not label:IsA("TextLabel") then
			continue
		end

		v[label] = true
		render(label) -- equivalent call inferred; original call site unknown
	end

	table.insert(connections, CollectionService:GetInstanceAddedSignal(p.WinPadLabelTag):Connect(function(label)
		if label:IsA("TextLabel") then
			v[label] = true
			render(label) -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(connections, CollectionService:GetInstanceRemovedSignal(p.WinPadLabelTag):Connect(function(p2)
		v[p2] = nil
	end))
end

function WinPadClient.stop()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	table.clear(v)
	v2 = 0
end

return WinPadClient