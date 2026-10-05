local DialogueController = require(game.ReplicatedStorage.DialogueController)
local Sound = require(game.ReplicatedStorage.Util.Sound)

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayRandomSound(p: string, p2: number, position, value: number?)
	local v = math.random(1, p2)
	Sound:Play(string.format("%s_%02d", p, v), position, nil, nil, value or 2)
end

return function(value)
	return function(p, p2, _, object)
		local boss = p2.WorldModel:GetChildren()[1]:FindFirstChild("Boss")
		local animation = Instance.new("Animation", boss)
		animation.AnimationId = "rbxassetid://10714395441"
		local track = boss.Humanoid:LoadAnimation(animation)
		track:Play()
		task.delay(1.8, function()
			track:AdjustSpeed(0)
		end)
		local v = false
		object:Once(function()
			v = true
		end)

		if DialogueController.Active then
			DialogueController:Close()
		end

		while DialogueController.Active do
			task.wait()
		end

		if not v then
			object:Wait()
		end

		DialogueController:Start({
			Title = "???",
			Get = function()
				task.spawn(function()
					local total = 0

					while DialogueController.Active do
						total += task.wait()

						if not (total > 3) then
							continue
						end

						DialogueController:Close()
						break
					end
				end)
				PlayRandomSound("Halloween_Event_Skeleton_Point_Animation", 8, p.Part.Position) -- equivalent call inferred; original call site unknown
				return {
					Text = { value or "How did you get here? GET RID OF THEM!!!" }
				}
			end
		})
	end
end