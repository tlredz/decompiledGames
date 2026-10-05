local localPlayer = game.Players.LocalPlayer
local soundData = require(game.ReplicatedStorage:WaitForChild("Data"):WaitForChild("Core"):WaitForChild("soundData"))

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(instance, timeLength, callback)
	task.delay(timeLength or instance.TimeLength, function()
		if callback then
			callback()
		end

		instance:Destroy()
	end)
	instance:Play()
end

local ClientUtil = {
	sound = function(p, p2, callback)
		local v = soundData[p]
		local sound = Instance.new("Sound")
		sound.TimePosition = v.TimePosition or 0
		sound.Volume = v.Volume or 1
		sound.SoundId = "rbxassetid://" .. v[1]
		sound.Parent = p2 or localPlayer

		if not sound.IsLoaded then
			sound.Loaded:Connect(function()
				playSound(sound, v.TimeLength, callback) -- equivalent call inferred; original call site unknown
			end)
			return sound
		end

		playSound(sound, v.TimeLength, callback) -- equivalent call inferred; original call site unknown
		return sound
	end
}

function ClientUtil.worldSound(cFrame, ...)
	local v = { ... }

	if #v == 0 then
		return
	end

	local part = Instance.new("Part")
	part.CanCollide = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Anchored = true
	part.ChildRemoved:Connect(function()
		if #part:GetChildren() > 0 then
			return
		end

		part:Destroy()
	end)

	for _, v2 in pairs(v) do
		ClientUtil.sound(v2, part)
	end

	part.Parent = workspace
	return part
end

return ClientUtil