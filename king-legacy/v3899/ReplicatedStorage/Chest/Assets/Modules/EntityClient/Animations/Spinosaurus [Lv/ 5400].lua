game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return {
	Setup = function(_, state)
		local entity = state.Entity
		state._Events = state._Events or {}
		local humanoid = entity.Humanoid
		local track = PeoUtils.GetAnimator(humanoid):LoadAnimation(script.Idle)
		local track2 = PeoUtils.GetAnimator(humanoid):LoadAnimation(script.Run)
		state._Tracks = { track, track2 }
		local v = "Idle"
		local v2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function GetAnimationTrack()
			if v == "Idle" then
				return track
			elseif v == "Walking" then
				return track2
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function OnUpdateAnimation()
			local animationTrack = GetAnimationTrack() -- equivalent call inferred; original call site unknown

			if not (animationTrack and animationTrack ~= v2) then
				return
			end

			if v2 then
				v2:Stop()
				v2 = nil
			end

			v2 = animationTrack
			v2:Play()
		end

		return (setmetatable(state, {
			__index = {
				PlayAnimation = function(_, childName: string, p)
					local v3 = p or script:FindFirstChild(childName)

					if v3 then
						return PeoUtils.PlayOneShotAnim(humanoid, v3)
					end
				end,
				UpdateAnimation = function(_)
					if humanoid.MoveDirection.Magnitude > 0 then
						v = "Walking"
					else
						v = "Idle"
					end

					OnUpdateAnimation() -- equivalent call inferred; original call site unknown
				end,
				UpdatePerformanceMode = function(_)
					if not v2 then
						return
					end

					v2:Stop()
					v2 = nil
				end,
				GetPerformanceMode = function(p)
					return p._PerformanceMode
				end,
				SetPerformanceMode = function(p, performanceMode: boolean)
					if p._PerformanceMode == performanceMode then
						return
					end

					p._PerformanceMode = performanceMode
				end
			}
		}))
	end
}