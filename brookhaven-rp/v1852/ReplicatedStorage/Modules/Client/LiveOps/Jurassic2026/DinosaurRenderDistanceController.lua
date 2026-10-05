local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local v = {
	"Brachiosaurus",
	"Triceratops",
	"Tyrannosaurus",
	"Velociraptor"
}
local localPlayer = Players.LocalPlayer
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getCharacterRootPosition()
	local character = localPlayer.Character

	if character == nil then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or humanoidRootPart:IsA("BasePart") == false then
		return nil
	end

	return humanoidRootPart.Position
end

local function hide(p)
	if v3[p] ~= nil then
		return
	end

	local parent = p.Parent

	if parent == nil or parent == Lighting then
		return
	end

	v3[p] = parent
	p.Parent = Lighting
end

-- equivalent calls inferred from this helper; original call sites unknown
local function show(k)
	local parent = v3[k]

	if parent == nil then
		return
	end

	v3[k] = nil

	if parent.Parent == nil and parent ~= Workspace then
		k.Parent = Workspace
	else
		k.Parent = parent
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function untrack(p)
	v2[p] = nil
	v3[p] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function track(model)
	if v2[model] == true then
		return
	end

	v2[model] = true
	model.Destroying:Once(function()
		untrack(model) -- equivalent call inferred; original call site unknown
	end)
end

local function watchTag(tag: string)
	for _, model in CollectionService:GetTagged(tag) do
		if not model:IsA("Model") then
			continue
		end

		track(model) -- equivalent call inferred; original call site unknown
	end
end

local function scan()
	local characterRootPosition = getCharacterRootPosition() -- equivalent call inferred; original call site unknown

	if characterRootPosition == nil then
		return
	end

	for k in v2 do
		local vector = k:GetPivot().Position - characterRootPosition

		if vector:Dot(vector) > 62500 then
			if v3[k] == nil then
				local parent = k.Parent

				if parent ~= nil and parent ~= Lighting then
					v3[k] = parent
					k.Parent = Lighting
				end
			end
		else
			show(k) -- equivalent call inferred; original call site unknown
		end
	end
end

return {
	FrameworkStart = function()
		for _, v4 in v do
			watchTag(v4)
		end

		task.spawn(function()
			while true do
				task.wait(2)
				scan()
			end
		end)
	end
}