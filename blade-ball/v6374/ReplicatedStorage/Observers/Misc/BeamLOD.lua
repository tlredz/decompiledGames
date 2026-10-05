local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local currentCamera = workspace.CurrentCamera
local v = {}
local gameSettings = UserSettings().GameSettings

local function updateBeams()
	if #v == 0 then
		return
	end

	local cFrame = currentCamera.CFrame
	local v2 = math.clamp(gameSettings.SavedQualityLevel.Value / 10, 0, 1)

	for k, v3 in v do
		local attachment0 = k.Attachment0
		local attachment1 = k.Attachment1

		if attachment0 and attachment1 then
			k.Segments = v3 // math.clamp(
				(1 - (math.max(
					(cFrame.Position - attachment0.WorldPosition).Magnitude,
					(cFrame.Position - attachment1.WorldPosition).Magnitude
				) - 200) / 800) * v2,
				0.1,
				1
			) + 1
		end
	end
end

Utils.Thread.Every(0.05, updateBeams)
return Observers.observeTag("BeamLOD", function(instance)
	v[instance] = instance:GetAttribute("Segments") or instance.Segments
	local segmentsChangedConnection = instance:GetAttributeChangedSignal("Segments"):Connect(function()
		v[instance] = instance:GetAttribute("Segments") or instance.Segments
	end)
	return function()
		segmentsChangedConnection:Disconnect()
		v[instance] = nil
	end
end, { workspace })