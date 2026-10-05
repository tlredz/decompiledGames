local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Write(instance, enabled)
	if instance.Enabled == enabled then
		v3[instance] = nil
		return
	end

	v3[instance] = enabled
	instance.Enabled = enabled
end

local function Track(proximityPrompt)
	if v[proximityPrompt] ~= nil then
		return
	end

	v[proximityPrompt] = proximityPrompt.Enabled
	v2[proximityPrompt] = proximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(function()
		local v4 = v3[proximityPrompt]
		v3[proximityPrompt] = nil

		if v4 ~= nil and proximityPrompt.Enabled == v4 then
			return
		end

		v[proximityPrompt] = proximityPrompt.Enabled
	end)
	Write(proximityPrompt, false) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Forget(p)
	local connection = v2[p]

	if connection then
		connection:Disconnect()
		v2[p] = nil
	end

	v[p] = nil
	v3[p] = nil
end

local v4 = { "Occluded", "InDialogue" }

for _, proximityPrompt in workspace:GetDescendants() do
	if proximityPrompt:IsA("ProximityPrompt") then
		Track(proximityPrompt)
	end
end

workspace.DescendantAdded:Connect(function(proximityPrompt)
	if proximityPrompt:IsA("ProximityPrompt") then
		task.defer(Track, proximityPrompt)
	end
end)
workspace.DescendantRemoving:Connect(function(proximityPrompt)
	if proximityPrompt:IsA("ProximityPrompt") then
		Forget(proximityPrompt) -- equivalent call inferred; original call site unknown
	end
end)
local v5 = {
	"OfflineEarnings",
	"Products",
	"Shop",
	"Index",
	"Rebirth"
}

local function IsHatchMenuOpen()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	local playerGuiMain = playerGui and playerGui:FindFirstChild("Main")

	if not playerGuiMain then
		return false
	end

	for _, childName in v5 do
		local parent = playerGuiMain:FindFirstChild(childName)

		if not (parent and parent:IsA("GuiObject")) then
			continue
		end

		local v6 = true

		while parent and parent ~= playerGui do
			if parent:IsA("GuiObject") and not parent.Visible or parent:IsA("ScreenGui") and not parent.Enabled then
				v6 = false
				break
			else
				parent = parent.Parent
			end
		end

		if v6 and parent == playerGui then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PositionOf(k)
	local parent = k.Parent

	if not parent then
		return nil
	end

	if parent:IsA("BasePart") then
		return parent.Position
	end

	if parent:IsA("Attachment") then
		return parent.WorldPosition
	end

	return nil
end

task.spawn(function()
	while true do
		task.wait(0.2)
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local hatchMenuOpen = IsHatchMenuOpen()

		for k in v do
			if k.Parent then
				if k.Enabled and not v[k] then
					v[k] = true
				end

				local hatchPromptAvailable = k:GetAttribute("HatchPromptAvailable")

				if typeof(hatchPromptAvailable) == "boolean" then
					v[k] = hatchPromptAvailable
				end

				local fusionPromptAvailable = k:GetAttribute("FusionPromptAvailable")

				if typeof(fusionPromptAvailable) == "boolean" then
					v[k] = fusionPromptAvailable
				end

				local enabled = false

				if humanoidRootPart and v[k] and (hatchPromptAvailable == nil or not hatchMenuOpen) then
					local position = PositionOf(k) -- equivalent call inferred; original call site unknown

					if position then
						enabled = (position - humanoidRootPart.Position).Magnitude <= k.MaxActivationDistance + 8
						local maxHorizontalActivationDistance = k:GetAttribute("MaxHorizontalActivationDistance")

						if enabled and typeof(maxHorizontalActivationDistance) == "number" then
							enabled = ((position - humanoidRootPart.Position) * createVector(1, 0, 1)).Magnitude <= maxHorizontalActivationDistance
						end
					end
				end

				if enabled then
					for _, attributeName in v4 do
						if k:GetAttribute(attributeName) ~= true then
							continue
						end

						enabled = false
						break
					end
				end

				if k.Enabled ~= enabled then
					if k.Enabled == enabled then
						v3[k] = nil
					else
						v3[k] = enabled
						k.Enabled = enabled
					end
				end
			else
				Forget(k) -- equivalent call inferred; original call site unknown
			end
		end
	end
end)