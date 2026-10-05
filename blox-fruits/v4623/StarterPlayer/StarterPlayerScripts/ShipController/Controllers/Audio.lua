local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local Audio = {}

function Audio.register(boat)
	local v = {
		Boat = boat
	}
	v.ModelSize = v.Boat:GetExtentsSize()
	v.VehicleSeat = v.Boat.VehicleSeat
	v.Sounds = {
		WaterLoop = {
			Object = nil,
			Type = "Generic",
			SpeedInfluence = 0,
			SpeedAlpha = 0
		}
	}
	v.PlayedRight = false
	v.PlayedLeft = false

	for _, folder in pairs(v.Boat:GetDescendants()) do
		if not (folder:IsA("Folder") and folder.Name:find("Sound/")) then
			continue
		end

		local name = folder.Name:sub(7, #folder.Name)
		local v3

		if folder.Parent.Name:find("Sound/") then
			v3 = folder.Parent.Name:sub(7, #folder.Parent.Name)
		end

		if v3 then
			v.Sounds[v3].PlayAfter = {
				Object = nil,
				Name = name,
				SpeedInfluence = folder:GetAttribute("SpeedInfluence"),
				DistanceInfluence = folder:GetAttribute("DistanceInfluence") or v.Sounds[v3].DistanceInfluence and 0,
				Delay = folder:GetAttribute("Delay")
			}
		else
			v.Sounds[name] = {
				Object = nil,
				Type = folder:GetAttribute("Type") or "Generic",
				SpeedInfluence = folder:GetAttribute("SpeedInfluence"),
				DistanceInfluence = folder:GetAttribute("DistanceInfluence"),
				SpeedAlpha = folder:GetAttribute("SpeedAlpha") or 0
			}
		end
	end

	return (setmetatable(v, {
		__index = Audio
	}))
end

function Audio:update(p: number, p2: number, p3: number)
	local positionOffset = self.VehicleSeat.BodyPosition:GetAttribute("PositionOffset")
	self.VehicleSeat.BodyPosition:GetAttribute("YOffset")
	local distanceAlpha = self.Boat:GetAttribute("DistanceAlpha")
	local v = positionOffset.Y > 0 and "Air" or "Water"

	if p > 0.5 then
		local v2 = p2 > 0.5 and "Left" or p2 < -0.5 and "Right" or false

		if v2 ~= "Left" then
		end

		local _ = 1.835 / (1.65 + 0.25 * (self.ModelSize.Magnitude / 123))
		local v3 = p2 * p3

		if v3 > 0.5 then
			if not self.PlayedLeft then
				self.PlayedLeft = true
			end
		elseif v3 < -0.5 then
			if not self.PlayedRight then
				self.PlayedRight = true
			end
		elseif math.abs(v3) < 0.1 then
			self.PlayedLeft = false
			self.PlayedRight = false
		end
	end

	for k, sound2 in pairs(self.Sounds) do
		local v2 = sound2.Type == v or sound2.Type == "Generic"
		local playAfter = sound2.PlayAfter

		if v2 and sound2.SpeedAlpha < p then
			if sound2.PlayedFully then
				if playAfter then
					if playAfter.Object then
						if not playAfter.PlaybackSpeed then
							playAfter.PlaybackSpeed = playAfter.Object.PlaybackSpeed
						end

						local playbackSpeed = playAfter.PlaybackSpeed

						if playAfter.SpeedInfluence then
							playbackSpeed += playAfter.SpeedInfluence * p
						end

						if playAfter.DistanceInfluence then
							playbackSpeed *= distanceAlpha + playAfter.DistanceInfluence * distanceAlpha * (1 - distanceAlpha)
						end

						playAfter.Object.PlaybackSpeed = playbackSpeed
					else
						playAfter.Object = sound:Play(playAfter.Name, self.VehicleSeat, 7)
					end
				end
			elseif sound2.Object then
				if not sound2.PlaybackSpeed then
					sound2.PlaybackSpeed = sound2.Object.PlaybackSpeed
				end

				local playbackSpeed = sound2.PlaybackSpeed

				if sound2.SpeedInfluence then
					playbackSpeed += sound2.SpeedInfluence * p
				end

				if sound2.DistanceInfluence then
					playbackSpeed *= distanceAlpha + sound2.DistanceInfluence * distanceAlpha * (1 - distanceAlpha)
				end

				sound2.Object.PlaybackSpeed = playbackSpeed
			elseif not sound2.Object then
				sound2.Object = sound:Play(k, self.VehicleSeat, 7)
				local v3 = sound2

				local function action()
					v3.PlayedFully = true
					v3.Object = nil
				end

				if playAfter and playAfter.Delay then
					task.delay(playAfter.Delay, action)
				elseif not sound2.Object.Looped then
					sound2.Object.Ended:Connect(action)
				end
			end
		else
			if not sound2.PlayedFully and sound2.Object and sound2.Object.Looped then
				sound:FadeOut(sound2.Object, 0.5)
				sound2.Object = nil
			end

			if playAfter and sound2.PlayedFully and playAfter.Object then
				sound:FadeOut(playAfter.Object, 0.5)
				playAfter.Object = nil
			end

			sound2.PlayedFully = false
		end
	end
end

return Audio