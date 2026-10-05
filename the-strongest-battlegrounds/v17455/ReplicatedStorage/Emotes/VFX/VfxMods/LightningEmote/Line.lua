local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleDestroy(clone)
	task.delay(15, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
end

local template = script.Template
local v = {
	Length = { 2, 15 },
	CurveSize = { 25, 9 },
	Duration = { 0.3, 1 },
	Dealy = { 0, 0.5 }
}
local rad = math.rad
local random = Random.new()

function create_part(p)
	task.delay(random:NextNumber(v.Dealy[1], v.Dealy[2]), function()
		local clone = template:Clone()
		scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
		game.Debris:AddItem(clone, 4)
		clone.Parent = workspace.Thrown
		clone.Anchored = true
		clone.CFrame = p * CFrame.Angles(
			rad((random:NextNumber(-360, 360))),
			rad((random:NextNumber(-360, 360))),
			(rad((random:NextNumber(-360, 360))))
		)
		local att2 = clone.Att2
		local beam = clone.Beam
		local width0 = beam.Width0
		local width1 = beam.Width1
		local number4 = random:NextNumber(v.Duration[1], v.Duration[2])
		local integer = random:NextInteger(v.CurveSize[1], v.CurveSize[2])
		beam.CurveSize0 = integer
		beam.CurveSize1 = integer
		TweenService:Create(clone, TweenInfo.new(number4), {
			CFrame = clone.CFrame * CFrame.Angles(0, 2.9670597283903604, 0)
		}):Play()
		TweenService:Create(att2, TweenInfo.new(number4), {
			CFrame = CFrame.new(random:NextNumber(v.Length[1], v.Length[2]), 0, 0) * CFrame.Angles(
				0,
				1.5707963267948966,
				0
			)
		}):Play()
		TweenService:Create(beam, TweenInfo.new(number4), {
			CurveSize0 = integer,
			CurveSize1 = integer
		}):Play()
		beam.Width0 = 0
		beam.Width1 = 0
		TweenService:Create(beam, TweenInfo.new(number4 / 2), {
			Width0 = width0,
			Width1 = width1
		}):Play()
		task.delay(number4 / 2, function()
			TweenService:Create(beam, TweenInfo.new(number4 / 2), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end)
		Debris:AddItem(clone, number4)
	end)
end

return function(p: number, p2)
	for _ = 1, p do
		create_part(p2)
	end
end