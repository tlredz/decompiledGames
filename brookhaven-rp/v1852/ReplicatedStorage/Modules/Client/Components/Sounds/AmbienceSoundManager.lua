local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AmbienceSoundManager"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local looped = self.Instance:WaitForChild("Looped")
	local random = self.Instance:WaitForChild("Random")
	local randomSoundFatigueSkips = self.Instance:GetAttribute("RandomSoundFatigueSkips")
	local v2 = (typeof(randomSoundFatigueSkips) ~= "number" or not (randomSoundFatigueSkips >= 1)) and 3 or math.floor(randomSoundFatigueSkips)

	for _, child in looped:GetChildren() do
		local sound = child:FindFirstChildWhichIsA("Sound")

		if not sound then
			continue
		end

		sound.Looped = true
		sound:Play()
	end

	local v3 = {}

	local function tickFatigue()
		for k, v4 in pairs(v3) do
			if k.Parent == nil then
				v3[k] = nil
			else
				local v5 = v4 - 1

				if v5 <= 0 then
					v3[k] = nil
				else
					v3[k] = v5
				end
			end
		end
	end

	local function collectRandomSounds()
		local sounds = {}

		for _, child in random:GetChildren() do
			local sound = child:FindFirstChildWhichIsA("Sound")

			if sound ~= nil then
				table.insert(sounds, sound)
			end
		end

		return sounds
	end

	self._Janitor:Add(task.spawn(function()
		while self.Instance.Parent ~= nil do
			tickFatigue()
			local v4 = collectRandomSounds()

			if #v4 == 0 then
				task.wait(1)
			else
				local v5 = {}

				for _, v6 in v4 do
					if v3[v6] == nil then
						table.insert(v5, v6)
					end
				end

				if #v5 > 0 then
					local v6 = v5[math.random(1, #v5)]
					v6:Play()
					v3[v6] = v2
				end

				task.wait(math.random(1, 10))
			end
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v