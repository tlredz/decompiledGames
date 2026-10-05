local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
local alwaysOnTop = false
local inventory = nil

local function PlayerOwnsRod()
	if not inventory then
		return false
	end

	for _, child in pairs(inventory:GetChildren()) do
		if child:GetAttribute("ToolName") == "Fishing Rod" then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyToHotspot(instance)
	if not instance.Parent then
		return
	end

	local surfaceGui = instance:FindFirstChild("SurfaceGui")

	if surfaceGui then
		surfaceGui.AlwaysOnTop = alwaysOnTop
	end
end

local function NewHotspot(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	v[instance] = true
	local surfaceGui = instance.Parent and instance:FindFirstChild("SurfaceGui")

	if surfaceGui then
		surfaceGui.AlwaysOnTop = alwaysOnTop
	end

	instance.ChildAdded:Connect(function(surfaceGui2)
		if surfaceGui2.Name == "SurfaceGui" and surfaceGui2:IsA("SurfaceGui") then
			surfaceGui2.AlwaysOnTop = alwaysOnTop
		end
	end)
end

local function RemovedHotspot(p)
	v[p] = nil
end

local function RefreshAll()
	for k in pairs(v) do
		if k.Parent then
			ApplyToHotspot(k) -- equivalent call inferred; original call site unknown
		else
			v[k] = nil
		end
	end
end

local function OnInventoryChanged()
	local playerOwnsRod = PlayerOwnsRod()

	if playerOwnsRod ~= alwaysOnTop then
		alwaysOnTop = playerOwnsRod
		RefreshAll()
	end
end

return {
	Init = function()
		task.spawn(function()
			inventory = localPlayer:WaitForChild("Inventory")
			alwaysOnTop = PlayerOwnsRod()
			Client.Utility.ForAllTagged("FishHotspot", NewHotspot, RemovedHotspot)
			inventory.ChildAdded:Connect(OnInventoryChanged)
			inventory.ChildRemoved:Connect(OnInventoryChanged)
		end)
	end
}