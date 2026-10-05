local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
game:GetService("ReplicatedStorage")
local animals = SoundService:WaitForChild("Animals")

local function GetNoiseSounds(petName)
	local instance = animals:FindFirstChild(petName)

	if not instance then
		return nil
	end

	if instance:IsA("Sound") then
		return { instance }
	end

	local noise = instance:IsA("Folder") and instance:FindFirstChild("Noise")

	if not noise then
		return nil
	end

	local sounds = {}

	for _, sound in noise:GetChildren() do
		if sound:IsA("Sound") then
			table.insert(sounds, sound)
		end
	end

	if #sounds > 0 then
		return sounds
	end

	return nil
end

local v = {}

local function WatchPet(model)
	if not model:IsA("Model") or v[model] or (not model:IsDescendantOf(workspace) or model:GetAttribute("OwnerUserId") == nil) then
		return
	end

	local petName = model:GetAttribute("PetName") or model.Name
	local noiseSounds = GetNoiseSounds(petName)

	if not noiseSounds then
		return
	end

	v[model] = true
	task.spawn(function()
		local v3 = os.clock() + 10

		while true do
			local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

			if not primaryPart and model.Parent then
				task.wait(0.1)
			end

			if not (primaryPart or not model.Parent or v3 < os.clock()) then
				continue
			end

			if not primaryPart then
				v[model] = nil
				break
			end

			local clones = {}

			for _, v4 in noiseSounds do
				local clone = v4:Clone()
				clone.Parent = primaryPart
				table.insert(clones, clone)
			end

			while model.Parent do
				task.wait(math.random(5, 15))

				if not model.Parent then
					break
				end

				if not model:IsDescendantOf(workspace) then
					continue
				end

				local v4 = clones[math.random(#clones)]

				if v4.Parent then
					v4:Play()
				end
			end

			v[model] = nil
			break
		end
	end)
end

CollectionService:GetInstanceAddedSignal("Pet"):Connect(function(p)
	task.defer(WatchPet, p)
end)

for _, v2 in CollectionService:GetTagged("Pet") do
	WatchPet(v2)
end