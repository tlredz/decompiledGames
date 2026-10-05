local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Item = require(ServerStorage.SAM.Services.Removers.Item)

local function giveReward(_, state)
	if state.Health <= state.MaxHealth then
		state.Health = math.clamp(state.Health + 50, 0, state.MaxHealth)
	end
end

local BandageServer = {}

function BandageServer.MouseDown(p, instance, p2, p3: string)
	if not (Checker.check(p) and p2.Thread == nil) then
		return
	end

	local data = Utility.GetData(p)

	if not (data ~= nil and Utility.HeldItem(data, p3) ~= nil) then
		return
	end

	local v, v2 = ManuelCancel.new(p, 3.416666666666667)
	v:Connect(function()
		if p2.Thread then
			task.cancel(p2.Thread)
			p2.Thread = nil
		end
	end)
	p2.WrapStarted = os.clock()
	p2.Thread = task.spawn(function()
		task.wait(0.7083333333333334)

		if Checker.check_victim(script, instance, instance) == nil then
			v2()
			p2.Thread = nil
		else
			task.wait(0.7083333333333334)

			if Item(p, p3) then
				local humanoid = instance:FindFirstChildOfClass("Humanoid")

				if humanoid ~= nil and humanoid.Health > 0 and humanoid.Health <= humanoid.MaxHealth then
					humanoid.Health = math.clamp(humanoid.Health + 50, 0, humanoid.MaxHealth)
				end

				v2()
				p2.Thread = nil
			else
				v2()
				p2.Thread = nil
			end
		end
	end)
end

function BandageServer.MouseUp(_, _, state)
	if state.Thread == nil then
		return
	end

	local wrapStarted = state.WrapStarted

	if wrapStarted ~= nil and os.clock() - wrapStarted >= 1.2666666666666668 then
		return
	end

	task.cancel(state.Thread)
	state.Thread = nil
end

return BandageServer