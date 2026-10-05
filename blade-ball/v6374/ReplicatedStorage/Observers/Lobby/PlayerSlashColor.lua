local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local hex = Color3.new(0, 0, 0):ToHex()

local function getOriginalValue(instance, p: string)
	local formatted = `Original{p}`
	local attribute = instance:GetAttribute(formatted)

	if attribute then
		return attribute
	end

	local success, result = pcall(function()
		return instance[p]
	end)

	if success then
		instance:SetAttribute(formatted, result)
		return result
	else
		error((`Unable to fetch value of {p}!`))
	end
end

local v = {
	ParticleEmitter = function(p, color: Color3, flag: boolean)
		local originalValue = getOriginalValue(p, "Brightness")
		local originalValue2 = getOriginalValue(p, "LightInfluence")
		p.Color = ColorSequence.new(color)
		p.Brightness = flag and 0 or originalValue
		p.LightInfluence = flag and 0 or originalValue2
	end,
	Beam = function(p, color: Color3, flag: boolean)
		local originalValue = getOriginalValue(p, "Brightness")
		local originalValue2 = getOriginalValue(p, "LightInfluence")
		p.Color = ColorSequence.new(color)
		p.Brightness = flag and 0 or originalValue
		p.LightInfluence = flag and 0 or originalValue2
	end
}
local v2 = { "BasePart", "Light" }

local function registerDescendant(descendant, slashColor: Color3, flag: boolean)
	if not descendant:HasTag("TesterSword") then
		return
	end

	local flag2 = false

	for _, className in v2 do
		if not descendant:IsA(className) then
			continue
		end

		flag2 = true
		break
	end

	if flag2 then
		descendant.Color = slashColor
		return
	end

	local v4 = v[descendant.ClassName]

	if v4 then
		v4(descendant, slashColor, flag)
	end
end

return Observers.observeTag("PlayerSlashColor", function(folder)
	local parent = folder.Parent

	if not parent then
		return
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

	if not playerFromCharacter then
		return
	end

	local function recolorSword()
		local slashColor = playerFromCharacter:GetAttribute("SlashColor")

		if not slashColor then
			return
		end

		local v3 = slashColor:ToHex() == hex

		for _, descendant in ipairs(folder:GetDescendants()) do
			registerDescendant(descendant, slashColor, v3)
		end
	end

	task.defer(recolorSword)
	local ancestryChangedConnection = folder.AncestryChanged:Connect(recolorSword)
	local childAddedConnection = folder.ChildAdded:Connect(recolorSword)
	local descendantAddedConnection = folder.DescendantAdded:Connect(recolorSword)
	local slashColorChangedConnection = playerFromCharacter:GetAttributeChangedSignal("SlashColor"):Connect(recolorSword)
	return function()
		ancestryChangedConnection:Disconnect()
		childAddedConnection:Disconnect()
		descendantAddedConnection:Disconnect()
		slashColorChangedConnection:Disconnect()
	end
end, { workspace })