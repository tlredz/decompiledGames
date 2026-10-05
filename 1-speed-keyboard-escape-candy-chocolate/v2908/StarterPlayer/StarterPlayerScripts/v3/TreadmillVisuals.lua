local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local v = {}

local function setupCharacterVisuals(maid, character)
	maid:Cleanup()
	local v2 = true
	maid:Add(function()
		v2 = false
	end)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local animator = humanoid and humanoid:WaitForChild("Animator", 10)

	if v2 and animator then
		local track = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getRunAnim()
			local animate = character:FindFirstChild("Animate")

			if not animate then
				return nil
			end

			local run = animate:FindFirstChild("run")
			return run and run:FindFirstChildOfClass("Animation")
		end

		local function updateAnimation()
			if character:GetAttribute("IsOnTreadmill") then
				if not track then
					local runAnim = getRunAnim() -- equivalent call inferred; original call site unknown

					if runAnim then
						track = animator:LoadAnimation(runAnim)
						track.Priority = Enum.AnimationPriority.Movement
						track.Looped = true
					end
				end

				if track and not track.IsPlaying then
					track:Play(0.3)
				end
			elseif track then
				track:Stop(0.3)
				track:Destroy()
				track = nil
				task.defer(function()
					if humanoid.Parent then
						humanoid:ChangeState(Enum.HumanoidStateType.Landed)
					end
				end)
			end
		end

		local isOnTreadmillChangedConnection = character:GetAttributeChangedSignal("IsOnTreadmill"):Connect(updateAnimation)
		updateAnimation()
		maid:Add(function()
			if track then
				track:Stop(0)
				track:Destroy()
				track = nil
			end
		end)
		maid:Add(isOnTreadmillChangedConnection)
	end
end

local function watchPlayer(player)
	local v2 = Janitor.new()
	local v3 = Janitor.new()
	local characterAddedConnection = player.CharacterAdded:Connect(function(character)
		setupCharacterVisuals(v3, character)
	end)

	if player.Character then
		task.spawn(setupCharacterVisuals, v3, player.Character)
	end

	v[player] = v2
	v2:Add(characterAddedConnection)
	v2:Add(v3, "Cleanup")
end

Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(function(player)
	local v2 = v[player]

	if v2 then
		v2:Cleanup()
		v[player] = nil
	end
end)

for _, v2 in ipairs(Players:GetPlayers()) do
	watchPlayer(v2)
end