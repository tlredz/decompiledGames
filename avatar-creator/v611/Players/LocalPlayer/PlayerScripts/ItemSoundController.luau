local localPlayer = game.Players.LocalPlayer
local soundGroup = Instance.new("SoundGroup")
soundGroup.Name = "LocalMutedItemSounds"
soundGroup.Volume = 0
soundGroup.Parent = game:GetService("SoundService")
local v = {}

local function isItem(instance)
	if instance.Name == "PassBoombox" or instance.Name == "BackgroundMusic" then
		return false
	end

	local parent = instance.Parent

	while parent and parent ~= game do
		if parent:IsA("Tool") and parent:GetAttribute("GamepassTool") == "Boombox" then
			return false
		end

		if parent:IsA("Accessory") or parent:IsA("Tool") then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function update(state, p)
	if not state.Parent then
		return
	end

	if localPlayer:GetAttribute("MuteItemSounds") == true and isItem(state) then
		if state.SoundGroup ~= soundGroup then
			p.original = state.SoundGroup
			state.SoundGroup = soundGroup
		end
	elseif state.SoundGroup == soundGroup then
		local original = p.original

		if not (original and original.Parent and original) then
			original = nil
		end

		state.SoundGroup = original
	end
end

local function track(sound)
	if not sound:IsA("Sound") or v[sound] then
		return
	end

	local v2 = {
		original = sound.SoundGroup,
		connections = {}
	}
	v[sound] = v2
	table.insert(v2.connections, sound:GetPropertyChangedSignal("SoundGroup"):Connect(function()
		update(sound, v2)
	end))
	table.insert(v2.connections, sound.AncestryChanged:Connect(function()
		update(sound, v2)
	end))
	table.insert(v2.connections, sound.Destroying:Connect(function()
		v[sound] = nil

		for _, connection in v2.connections do
			connection:Disconnect()
		end
	end))
	update(sound, v2)
end

for _, folder in ipairs({ workspace, localPlayer:WaitForChild("PlayerGui"), localPlayer:WaitForChild("Backpack") }) do
	folder.DescendantAdded:Connect(track)

	for _, descendant in folder:GetDescendants() do
		track(descendant)
	end
end

localPlayer.ChildAdded:Connect(function(backpack)
	if backpack:IsA("Backpack") then
		backpack.DescendantAdded:Connect(track)

		for _, descendant in backpack:GetDescendants() do
			track(descendant)
		end
	end
end)
localPlayer:GetAttributeChangedSignal("MuteItemSounds"):Connect(function()
	for k, v2 in pairs(v) do
		update(k, v2)
	end
end)