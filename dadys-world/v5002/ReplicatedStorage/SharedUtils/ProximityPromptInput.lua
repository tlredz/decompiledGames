local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local InputConfig = require(ReplicatedStorage.SharedData.InputConfig)
local v = InputConfig.Actions.Interact.Bindings.Keyboard[1]
local flag = false
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function syncManaged(p)
	local boundKeyCode = InputService:GetBoundKeyCode("Interact", "Keyboard")

	if boundKeyCode then
		p.KeyboardKeyCode = boundKeyCode
	end

	local boundKeyCode2 = InputService:GetBoundKeyCode("Interact", "Gamepad")

	if boundKeyCode2 then
		p.GamepadKeyCode = boundKeyCode2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forceRedraw(instance)
	if not instance.Enabled then
		return
	end

	instance.Enabled = false
	task.spawn(function()
		RunService.Heartbeat:Wait()
		RunService.Heartbeat:Wait()

		if not instance.Parent then
			return
		end

		instance.Enabled = true
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function consider(proximityPrompt)
	if v2[proximityPrompt] then
		syncManaged(proximityPrompt) -- equivalent call inferred; original call site unknown
	else
		if proximityPrompt:GetAttribute("NoInputSync") == true then
			return
		end

		if proximityPrompt.KeyboardKeyCode == v then
			v2[proximityPrompt] = true
			syncManaged(proximityPrompt) -- equivalent call inferred; original call site unknown
		end
	end
end

local function sweep()
	for _, proximityPrompt in ipairs(Workspace:GetDescendants()) do
		if not proximityPrompt:IsA("ProximityPrompt") then
			continue
		end

		consider(proximityPrompt) -- equivalent call inferred; original call site unknown
	end
end

return {
	setup = function()
		if flag then
			return
		end

		flag = true
		sweep()
		Workspace.DescendantAdded:Connect(function(proximityPrompt)
			if proximityPrompt:IsA("ProximityPrompt") then
				consider(proximityPrompt) -- equivalent call inferred; original call site unknown
			end
		end)
		Workspace.DescendantRemoving:Connect(function(descendant)
			if v2[descendant] then
				v2[descendant] = nil
			end
		end)
		InputService.BindingChanged:Connect(function(p)
			if p == nil or p == "Interact" then
				for k in pairs(v2) do
					if not k.Parent then
						continue
					end

					syncManaged(k) -- equivalent call inferred; original call site unknown
					forceRedraw(k) -- equivalent call inferred; original call site unknown
				end
			end
		end)
	end
}