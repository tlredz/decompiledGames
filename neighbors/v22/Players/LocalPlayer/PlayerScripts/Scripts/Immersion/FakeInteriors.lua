local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local Windows = require(ReplicatedStorage.Modules.Windows)
local v = Windows.Setup(1000, "Normal")
local v2 = {}
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsWindowsEnabled()
	return Players.LocalPlayer:GetAttribute("EnableFakeInteriors") and false
end

local function WindowAdded(instance)
	if not IsWindowsEnabled() then
		return
	end

	local v3 = v:AddWindow(instance, 5)
	v3:ToggleRunning(false)
	v3:SetTransparency(1)

	local function UpdateVisibility()
		local child = workspace.Places:FindFirstChild(Players.LocalPlayer:GetAttribute("CurrentInternalMap") or "")

		if child and instance:IsDescendantOf(child) then
			v3:SetTransparency(1)
			task.delay(0.1, function()
				v3:ToggleRunning(false)
			end)
		else
			v3:SetTransparency(0.25)
			v3:ToggleRunning(true)
		end
	end

	task.delay(0.1, UpdateVisibility)
	table.insert(connections, Players.LocalPlayer:GetAttributeChangedSignal("CurrentInternalMap"):Connect(function()
		UpdateVisibility()
	end))
	table.insert(v2, v3)
end

Players.LocalPlayer:GetAttributeChangedSignal("EnableFakeInteriors"):Connect(function()
	if IsWindowsEnabled() then
		for _, v3 in CollectionService:GetTagged("FakeInterior") do
			WindowAdded(v3)
		end
	else
		for _, connection in v2 do
			connection:Disconnect()
		end

		for _, connection in connections do
			connection:Disconnect()
		end
	end
end)

for _, v3 in CollectionService:GetTagged("FakeInterior") do
	WindowAdded(v3)
end

CollectionService:GetInstanceAddedSignal("FakeInterior"):Connect(WindowAdded)