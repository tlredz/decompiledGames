local v = { "UpperTorso", "LowerTorso" }

-- equivalent calls inferred from this helper; original call sites unknown
local function processDescendant(part)
	if part:IsA("BasePart") and table.find(v, part.Name) then
		part.CanCollide = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disableCollisions(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		processDescendant(descendant) -- equivalent call inferred; original call site unknown
	end
end

while task.wait(0.4) do
	disableCollisions(script.Parent) -- equivalent call inferred; original call site unknown
end