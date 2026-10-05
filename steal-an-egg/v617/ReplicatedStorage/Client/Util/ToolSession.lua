local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolCooldown = require(ReplicatedStorage.Shared.Util.ToolCooldown)
local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function accepted(p, tool)
	return tool:IsA("Tool") and table.find(p.accepts, (tool:GetAttribute("GearName"))) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function loosen(p)
	local grip = p.grip

	if grip then
		grip:Clean()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stow(p)
	loosen(p) -- equivalent call inferred; original call site unknown
	p.grip = nil
	local onUnequipped = p.hooks.onUnequipped

	if onUnequipped then
		onUnequipped()
	end

	p.held = nil
end

local function wield(state, tool)
	loosen(state) -- equivalent call inferred; original call site unknown
	state.grip = Trove.new()
	state.held = tool
	ToolCooldown.PrimeTool(tool)
	local onEquipped = state.hooks.onEquipped

	if onEquipped then
		onEquipped(tool)
	end

	local grip = state.grip

	if grip then
		if state.hooks.onActivated then
			grip:Add(tool.Activated:Connect(function()
				local onActivated = state.hooks.onActivated

				if onActivated and ToolGameplayGuard.AllowsLocalUse(tool) then
					onActivated(tool)
				end
			end))
		end

		grip:Add(localPlayer.CharacterRemoving:Connect(function()
			loosen(state) -- equivalent call inferred; original call site unknown
		end))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onGearChange(p, tool, callback)
	if accepted(p, tool) then
		callback(p, tool)
	end
end

local ToolSession = {}

function ToolSession.GearNameOf(instance)
	if instance then
		return (instance:GetAttribute("GearName"))
	end

	return nil
end

function ToolSession.Follow(p, instance)
	instance.ChildAdded:Connect(function(child)
		onGearChange(p, child, wield) -- equivalent call inferred; original call site unknown
	end)
	instance.ChildRemoved:Connect(function(tool)
		local v = p

		if accepted(v, tool) then
			stow(v) -- equivalent call inferred; original call site unknown
		end
	end)
	local tool = instance:FindFirstChildWhichIsA("Tool")

	if tool and accepted(p, tool) then
		wield(p, tool)
	end
end

function ToolSession.Shut(p)
	p.spawns:Clean()
	loosen(p) -- equivalent call inferred; original call site unknown
end

return ToolSession