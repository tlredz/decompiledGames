local Component = require(game.ReplicatedStorage.Modules.Component)
require(game.ReplicatedStorage.Util.Signal2)
require(game.ReplicatedStorage.Types.SlappingArenaTypes)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local RunService = game:GetService("RunService")
local renderStepped = RunService.RenderStepped
local camera = workspace.Camera
local v = Component.new({
	Tag = "ArenaCameraDirector",
	Ancestors = { game.Players.LocalPlayer }
})

function v.Construct(_) end

local function QuadraticBezier(p, p2, p3, p4)
	local v2 = 1 - p4
	return v2 * v2 * p + 2 * v2 * p4 * p2 + p4 * p4 * p3
end

function v:Start()
	self.Maid = Maid.new()
	self.Maid:GiveTask(self.Instance:GetAttributeChangedSignal("TargetCFrame"):Connect(function()
		self.Instance:SetAttribute("ClientTargetCFrame", nil)
		self.Maid.tweenTask = nil
	end))
	self.Maid:GiveTask(self.Instance.ChildAdded:Connect(function(child)
		if child.Name == "tween" then
			local dontReset = child:GetAttribute("dontReset")
			self.Instance:SetAttribute("ClientTargetCFrame", nil)
			self.Maid.tweenTask = task.spawn(function()
				local v2 = child
				local value = v2.Value
				local cFrame

				if dontReset then
					cFrame = camera.CFrame
				else
					cFrame = self.Instance:GetAttribute("TargetCFrame")
				end

				local time = v2:GetAttribute("time")
				local lastTime = tick()
				local v3 = lastTime + time
				local midpoint = (cFrame.Position + value.Position) / 2
				local magnitude = (value.Position - cFrame.Position).Magnitude
				local cframe = CFrame.new(cFrame.Position + (value.Position - cFrame.Position) * 0.4, value.Position)

				while tick() < v3 do
					local v5 = math.clamp((tick() - lastTime) / (v3 - lastTime), 0, 1)
					local v6 = midpoint + cframe.RightVector * magnitude * 0.75
					local instance = self.Instance
					local rotation = cFrame:Lerp(v2.Value, v5).Rotation
					local position = cFrame.Position
					local position2 = value.Position
					local v7 = 1 - v5
					instance:SetAttribute(
						"ClientTargetCFrame",
						rotation + (v7 * v7 * position + 2 * v7 * v5 * v6 + v5 * v5 * position2)
					)
					renderStepped:Wait()
				end
			end)
		end
	end))
end

function v:Stop()
	self.Maid:Destroy()
	self.Maid = nil
end

function v.RenderSteppedUpdate(p)
	if p.Instance:GetAttribute("TargetCFrame") then
		camera.CFrame = p.Instance:GetAttribute("ClientTargetCFrame") or p.Instance:GetAttribute("TargetCFrame")
	end
end

return v