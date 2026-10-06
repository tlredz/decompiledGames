local module = require("@game/ReplicatedStorage/Omni")
local module2 = require("./../General/Interactable/Callback")
local proximityPrompts = workspace:WaitForChild("Server"):WaitForChild("ProximityPrompts")
local modulesByName = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCallbackTable(instance)
	local callback = instance:GetAttribute("Callback") or instance.Name
	local callback2 = instance.Parent and (instance.Parent:GetAttribute("Callback") or instance.Parent.Name)
	return module2[callback] or callback2 and module2[callback2]
end

module.Services.ProximityPromptService.PromptShown:Connect(function(instance)
	if instance.Style ~= Enum.ProximityPromptStyle.Custom then
		return
	end

	local style = instance:GetAttribute("Style") or "Default"
	local v = modulesByName[style]

	if v then
		v.Create(instance)
	end

	local callbackTable = GetCallbackTable(instance) -- equivalent call inferred; original call site unknown
	local shown = callbackTable and callbackTable.Shown

	if shown then
		shown(instance)
	end
end)
module.Services.ProximityPromptService.PromptHidden:Connect(function(instance)
	if instance.Style ~= Enum.ProximityPromptStyle.Custom then
		return
	end

	local style = instance:GetAttribute("Style") or "Default"
	local v = modulesByName[style]

	if v then
		v.Destroy(instance)
	end
end)
module.Utils.Instance:ObserveDescendants(proximityPrompts, function(instance)
	if instance:IsA("BasePart") then
		instance.Transparency = 1
		instance.Material = Enum.Material.Plastic
	elseif instance:IsA("ProximityPrompt") then
		if not instance.Parent or instance.Style ~= Enum.ProximityPromptStyle.Custom then
			return
		end

		local callback = instance:GetAttribute("Callback") or instance.Name
		local callback2 = instance.Parent:GetAttribute("Callback") or instance.Parent.Name
		local v = module2[callback] or module2[callback2]
		local promptSetup = v and v.PromptSetup

		if promptSetup then
			promptSetup(instance)
		end

		instance.RequiresLineOfSight = false
	end
end)

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module3 = require(moduleScript)
	modulesByName[name] = module3
end

return {}