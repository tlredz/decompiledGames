workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(player)
	local rig = player.Rig
	local hold = player.Hold
	local character = player.Character
	local hum = player.Hum
	spawn(function()
		local count = 0

		while not (count >= 15) do
			wait(1)
			count += 1

			if rig then
				break
			end
		end

		local animationController = rig:WaitForChild("AnimationController", 30)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 30)

		if animationController and humanoidRootPart then
			wait(0.25)
			animationController:LoadAnimation(rig.VenomFormEnter)
			animationController:LoadAnimation(rig.VenomFormExit)
			local track = animationController:LoadAnimation(rig.VenomFormIdle)
			local track2 = animationController:LoadAnimation(rig.VenomFormWalk)
			local track3 = animationController:LoadAnimation(rig.VenomFormJump)
			local track4 = animationController:LoadAnimation(rig.VenomFormFall)
			local track5 = animationController:LoadAnimation(rig.VenomFormRun)

			local function stopAllExcept(track6)
				local playingAnimationTracks = animationController:GetPlayingAnimationTracks()

				for _, playingAnimationTrack in pairs(playingAnimationTracks) do
					if playingAnimationTrack.Animation ~= track6.Animation and playingAnimationTrack.Animation.Name ~= "Animation" then
						playingAnimationTrack:Stop(0.2)
					end
				end

				track6:Play(0.2)
			end

			local _ = humanoidRootPart.Position.Y
			tick()

			local function legal()
				return character.Parent and rig and rig:IsDescendantOf(character) and hum.Parent and hum and hum.Health > 0
			end

			local v = "None"

			while character.Parent and rig and rig:IsDescendantOf(character) and hum.Parent and hum and hum.Health > 0 do
				if hold.Value == true then
					v = v ~= "Casting" and "Casting" or v
					RunService.RenderStepped:Wait()
				else
					if rig == nil then
						break
					end

					if humanoidRootPart.Velocity.Y > 5 then
						if v ~= "Jumping" then
							stopAllExcept(track3)
							v = "Jumping"
						end
					elseif humanoidRootPart.Velocity.Y < -5 then
						if v ~= "Falling" then
							if humanoidRootPart then
								local _ = humanoidRootPart.Position.Y
							end

							stopAllExcept(track4)
							v = "Falling"
						end
					elseif math.abs(humanoidRootPart.Velocity.X) > 18 or math.abs(humanoidRootPart.Velocity.Z) > 18 then
						if v ~= "Running" then
							stopAllExcept(track5)
							v = "Running"
						end
					elseif math.abs(humanoidRootPart.Velocity.X) > 0.1 or math.abs(humanoidRootPart.Velocity.Z) > 0.1 then
						if v ~= "Walking" then
							stopAllExcept(track2)
							track2:AdjustSpeed(1)
							v = "Walking"
						end
					elseif math.abs(humanoidRootPart.Velocity.X) < 0.1 and math.abs(humanoidRootPart.Velocity.Z) < 0.1 and v ~= "Idle" then
						stopAllExcept(track)
						v = "Idle"
					end

					wait(0.1)
				end
			end
		end
	end)
end