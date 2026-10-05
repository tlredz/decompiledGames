local createVector = vector.create
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local v = {
	"http://www.roblox.com/asset/?id=15040223498",
	"http://www.roblox.com/asset/?id=15040223840",
	"http://www.roblox.com/asset/?id=15040224172",
	"http://www.roblox.com/asset/?id=15040224480",
	"http://www.roblox.com/asset/?id=15040224807",
	"http://www.roblox.com/asset/?id=15040225127",
	"http://www.roblox.com/asset/?id=15040225500",
	"http://www.roblox.com/asset/?id=15040225812",
	"http://www.roblox.com/asset/?id=15040226242",
	"http://www.roblox.com/asset/?id=15040226630",
	"http://www.roblox.com/asset/?id=15040226958",
	"http://www.roblox.com/asset/?id=15040227423",
	"http://www.roblox.com/asset/?id=15040227681",
	"http://www.roblox.com/asset/?id=15040228027",
	"http://www.roblox.com/asset/?id=15040228366",
	"http://www.roblox.com/asset/?id=15040228707"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createFrameSkipper()
	local v2 = 1
	return function(p)
		local v3 = 60 / p
		v2 += 1

		if v3 <= v2 then
			v2 -= v3
			return false
		else
			return true
		end
	end
end

local function spawnSplash(parent)
	local splashMesh = parent:FindFirstChild("SplashMesh")
	local model = Instance.new("Model")
	model.Name = "SplashModel"
	model.Parent = parent
	local clone = splashMesh:Clone()
	clone.Parent = model
	local decal = clone:FindFirstChildOfClass("Decal")
	local _ = model:GetPivot().Position - parent:GetPivot().Position
	local frameSkipper = createFrameSkipper() -- equivalent call inferred; original call site unknown
	local v2 = 1
	heartbeatLoopFor2(0.4, function(p)
		if not frameSkipper(20) then
			decal.Texture = v[v2]

			if v2 == #v then
				model:Destroy()
				return
			else
				v2 = v2 % #v + 1
			end
		end

		local v3 = math.clamp(p / 0.4, 0, 1)
		model:ScaleTo(math.lerp(0.25, 2.5, v3) * 1)
		decal.Transparency = 1 - v3 ^ 0.1
		decal.Color3 = Color3.fromRGB(65, 30, 120):Lerp(Color3.fromRGB(400, 415, 1275), math.random())
		clone.CFrame = CFrame.Angles(0, -p * 2.5, 0) + clone.Position + createVector(0, 1, 0) * p * 4
	end, function()
		if model and model.Parent then
			model:Destroy()
		end
	end)
end

return function(instance)
	while instance and instance.Parent and instance:GetAttribute("Enabled") do
		spawnSplash(instance)

		if instance:GetAttribute("Enabled") then
			task.wait(0.2)
		else
			task.wait()
		end
	end
end