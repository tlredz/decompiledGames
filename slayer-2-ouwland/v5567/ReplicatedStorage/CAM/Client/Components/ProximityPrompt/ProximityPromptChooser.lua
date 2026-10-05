local RunService = game:GetService("RunService")
local faye = require(game.ReplicatedStorage.Packages.faye)
local modulesByName = {}
local modulesByName2 = {}

for _, moduleScript in script.Parent.CustomPrompts:QueryDescendants("ModuleScript"), nil, nil do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

for _, moduleScript in script.Parent.Indicators:QueryDescendants("ModuleScript"), nil, nil do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName2[name] = module
end

return function(instance, p, p2: number, p3)
	local v = faye.new()
	local v2 = p or workspace.Part:FindFirstChild("ProximityPrompt")
	local v3

	if v2 ~= nil then
		v3 = v:Create("BillboardGui")({
			AlwaysOnTop = true,
			Active = true,
			CleanDelay = 0.5,
			Name = v2 ~= nil and v2.Name,
			Size = UDim2.fromScale(10, 1.75),
			ClipsDescendants = false,
			Parent = instance,
			Adornee = v2.Parent
		})
	end

	if RunService:IsRunning() then
		instance = v3.Instance
	end

	local v4

	if (not RunService:IsRunning() and 1 or p2) == 1 then
		v4 = modulesByName[v2:GetAttribute("PromptStyle") or "Default"](
			instance,
			v2,
			p3 or Enum.ProximityPromptInputType.Keyboard,
			v
		)
	else
		v4 = modulesByName2[v2:GetAttribute("IndicatorStyle") or "Default"](instance, v2, v)
	end

	return function()
		if v4 ~= nil then
			v4()
			v4 = nil
		end

		v:Destroy()
	end
end