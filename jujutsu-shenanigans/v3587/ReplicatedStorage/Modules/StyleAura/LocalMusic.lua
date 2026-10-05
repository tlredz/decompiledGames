local parent = script.Parent
local humanoidRootPart

if parent then
	humanoidRootPart = parent:WaitForChild("HumanoidRootPart", 10) or nil
end

local styleMusic

if humanoidRootPart then
	styleMusic = humanoidRootPart:WaitForChild("StyleMusic", 10) or nil
end

local styleAura = parent and parent:WaitForChild("StyleAura", 10) or nil

if not (styleMusic and styleMusic.Parent and styleAura and styleAura.Parent) then
	return
end

local clone = styleMusic:Clone()
clone.Parent = humanoidRootPart
clone:Play()
styleMusic:Destroy()
styleAura.AncestryChanged:Once(function()
	if clone and clone.Parent then
		clone:Destroy()
	end

	script:Destroy()
end)