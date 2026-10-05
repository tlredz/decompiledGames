local createVector = vector.create
game:GetService("CollectionService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local BiofuelProcessorModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()
local v = {}
local clones = {}

function BiofuelProcessorModule.Init()
	Connections()
end

function PivotModelToProcessor(folder, instance)
	if not instance then
		return
	end

	folder:PivotTo(instance:FindFirstChild("IntakeInner").CFrame + createVector(0, 2, 0))

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = true
	end
end

function SpinShrinkAndDescend(instance, _)
	local total = 0

	repeat
		local v2 = RunService.RenderStepped:Wait()
		total += v2
		instance:PivotTo(instance:GetPivot() * CFrame.new(0, -2 * v2, 0) * CFrame.Angles(0, math.rad(360 * v2), 0))
		instance:ScaleTo((math.clamp(1 - total, 0.1, 1)))

		if total >= 1 then
			instance:Destroy()
		end
	until total > 1
end

function ProcessItem(instance, instance2, p, _)
	v[instance2] = true
	task.delay(15, function()
		v[instance2] = nil
	end)
	local _ = instance2:GetPivot().Position
	local _ = instance:FindFirstChild("Intake").Position + createVector(0, 2, 0)
	local clone = instance2:Clone()
	v[clone] = true
	task.delay(15, function()
		v[clone] = nil
	end)

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	local highlight = clone:FindFirstChildWhichIsA("Highlight", true)

	if highlight then
		highlight:Destroy()
	end

	local billboardGui = clone:FindFirstChildWhichIsA("BillboardGui", true)

	if billboardGui then
		billboardGui:Destroy()
	end

	clone:PivotTo(instance2.PrimaryPart.CFrame)
	clone.Parent = instance2.Parent
	instance2:Destroy()
	table.insert(clones, clone)
	task.spawn(function()
		PivotModelToProcessor(clone, instance)
		SpinShrinkAndDescend(clone, p)

		if clone then
			for k, v2 in pairs(clones) do
				if v2 == clone then
					table.remove(clones, k)
				end
			end
		end
	end)
end

function Connections()
	Client.Events.ProcessItemToBiofuel:Connect(ProcessItem)
	Client.Utility.ForAllTagged("BiofuelProcessor", function(instance)
		local touchZone = instance:WaitForChild("TouchZone")
		local allowProcess = instance:WaitForChild("AllowProcess")
		touchZone.Touched:Connect(function(otherPart)
			local parent = otherPart.Parent

			if parent and parent.Parent then
				if v[parent] or not allowProcess:GetAttribute(string.gsub(parent.Name, " ", "_")) then
					return
				end

				local owner = parent:GetAttribute("Owner")

				if owner == nil or owner == localPlayer.UserId then
					local _ = parent.Parent
					task.spawn(function()
						ProcessItem(instance, parent, true)
					end)
					local v2 = Client.Events.RequestProcessToBiofuel:InvokeServer(instance, parent)

					if v2 then
						local _ = v2.Success
					end
				end
			end
		end)
	end)
end

return BiofuelProcessorModule