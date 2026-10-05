local object = setmetatable({}, {
	__mode = "v"
})
local object2 = setmetatable({}, {
	__mode = "v"
})
setmetatable({}, {
	__mode = "k"
})
local ParticleOptimizer = {}
local v = false
local clock = os.clock

function ParticleOptimizer.registerParticle(p)
	if not script:GetAttribute("EnableOptimizations") then
		return
	end

	if not table.find(object, p) then
		table.insert(object, p)
	end

	v = true
end

function ParticleOptimizer.registerBeam(p)
	if not script:GetAttribute("EnableOptimizations") then
		return
	end

	if not table.find(object2, p) then
		table.insert(object2, p)
	end

	v = true
end

function ParticleOptimizer.registerDescendants(folder)
	if not script:GetAttribute("EnableOptimizations") then
		return
	end

	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			ParticleOptimizer.registerParticle(effect)
		elseif effect:IsA("Beam") then
			ParticleOptimizer.registerBeam(effect)
		end
	end
end

local v2 = 0
local v3 = 0
local v4 = 0
local v5 = 0
local v6 = 0
local v7 = 0
local v8 = 0
local v9 = 0
local v10 = 0
local v11 = 0
local v12 = 0
local v13 = 0
local v14 = 0
local v15 = 0
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("RenderSteppedBeginProfile", -99999, function(_)
	local now = clock()
	v2 = now
	v3 = now - v14
end)
local RunService2 = game:GetService("RunService")
RunService2:BindToRenderStep("RenderSteppedEndProfile", 99999, function(_)
	local now = clock()
	v4 = now
	v5 = now - v2
end)
local RunService3 = game:GetService("RunService")
RunService3.PreAnimation:Connect(function(_)
	local now = clock()
	v6 = now
	v7 = now - v4
end)
local RunService4 = game:GetService("RunService")
RunService4.PreSimulation:Connect(function(_)
	local now = clock()
	v8 = now
	v9 = now - v6
end)
local RunService5 = game:GetService("RunService")
RunService5.PostSimulation:Connect(function(_)
	local now = clock()
	v10 = now
	v11 = now - v8
end)
task.spawn(function()
	while task.wait(-10) do
		local now = clock()
		v12 = now
		v13 = now - v10
	end
end)
local RunService6 = game:GetService("RunService")
RunService6.Heartbeat:Connect(function(_)
	local now = clock()
	v14 = now
	v15 = now - v12
end)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Equals then
		for _, v16 in object do
			v16:Clear()
		end
	end
end)
local v16 = {
	"Heartbeat",
	"DelayedScripts",
	"PostSimulation",
	"PreSimulation",
	"PreAnimation",
	"RenderSteppedEnd",
	"RenderSteppedBegin"
}

local function getLagSource()
	local v17 = 0
	local v18 = 0

	for k, v19 in {
		v15,
		v13,
		v11,
		v9,
		v7,
		v5,
		v3
	} do
		if not (v17 < v19) then
			continue
		end

		v18 = k
		v17 = v19
	end

	return v16[v18], v17
end

NumberSequence.new(0)
task.spawn(function()
	task.wait(15)

	repeat
		task.wait()
		local Global = require(game.ReplicatedStorage.Global)
	until Global.isClientFramedropping

	local Global = require(game.ReplicatedStorage.Global)
	local isClientFramedropping = Global.isClientFramedropping
	local v17 = nil
	local v18 = nil
	local RunService7 = game:GetService("RunService")
	RunService7.Heartbeat:Connect(function(_)
		if not script:GetAttribute("EnableOptimizations") then
			return
		end

		v18 = isClientFramedropping()

		if v18 then
			if not v17 or v then
				local v19 = table.maxn(object)

				for i = 1, math.min(v19 / 3 * v18, v19) do
					local v20 = object[i]

					if v20 then
						v20:Clear()
					end
				end

				v = false
			end
		elseif v17 then
			warn("Framedropped for", tick() - v17, "seconds..", "with severity", v18)
			v17 = nil
		end
	end)
end)
return ParticleOptimizer