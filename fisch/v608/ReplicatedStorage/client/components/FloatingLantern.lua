game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
require(packages.Net)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "FloatingLantern",
	Ancestors = { workspace }
})

function v:Construct()
	self.Trove = Trove.new()
	self.CurrentVelocity = CFrame.identity
end

function v.Start(data)
	local center = data.Instance:WaitForChild("Center")
	local root = data.Instance:WaitForChild("FloatingModel"):WaitForChild("Root")
	data.Trove:Connect(RunService.RenderStepped, function(p)
		local bobbingDirection = data.Instance:GetAttribute("BobbingDirection") or "y"
		local v2 = math.sin(tick() / (data.Instance:GetAttribute("BobbingTime") or 3) * 3.141592653589793) * (data.Instance:GetAttribute("BobbingDistance") or 2)
		local v3 = center.CFrame * CFrame.new(
			bobbingDirection:lower() == "x" and v2 or 0,
			bobbingDirection:lower() == "y" and v2 or 0,
			bobbingDirection:lower() == "z" and v2 or 0
		)
		local v4 = root
		local v5 = data
		local smoothDamp, currentVelocity = TweenService:SmoothDamp(
			root.CFrame,
			v3,
			data.CurrentVelocity,
			data.Instance:GetAttribute("FloatTime") or 0.25,
			nil,
			p
		)
		v4.CFrame = smoothDamp
		v5.CurrentVelocity = currentVelocity
	end)
end

function v.Stop(p)
	p.Trove:Clean()
end

return v