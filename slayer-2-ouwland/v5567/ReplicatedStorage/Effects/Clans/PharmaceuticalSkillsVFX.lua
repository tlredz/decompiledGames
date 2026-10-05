local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local sounds = script:WaitForChild("Sounds")

local function speaker(folder, cFrame: CFrame, childName: string, p: number?)
	local sound = sounds:FindFirstChild(childName)

	if sound == nil or not sound:IsA("Sound") then
		return nil
	end

	local part = Instance.new("Part")
	part.Name = "PharmaceuticalSpeaker"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = cFrame
	part.Parent = folder
	local clone = sound:Clone()
	clone.Parent = part
	clone:Play()

	if p ~= nil then
		DebrisModule:AddItem(part, p)
	end

	return clone
end

return function(p, cframe: CFrame, value: number?, value2: number?)
	if p == nil or cframe == nil then
		return
	end

	local v = value or 0
	local v2 = v + (value2 or 0)
	local folder = Instance.new("Folder")
	folder.Name = "PharmaceuticalRing"
	folder.Parent = workspace.Debree
	DebrisModule:AddItem(folder, v2)
	local position = cframe.Position
	speaker(folder, CFrame.new(position), "PS2pharmeceuticalskillsINIT", v2)
	local v3 = speaker(folder, CFrame.new(position), "PS2pharmeceuticalskillsLOOP")
	local impact = script:FindFirstChild("Impact")

	if impact ~= nil then
		local clone = impact:Clone()
		clone.Parent = folder
		clone:PivotTo(CFrame.new(position - createVector(0, 1, 0)))
		Ouwmit.Emit(clone, Ouwmit.Owned(p))
	end

	local wind = script:FindFirstChild("Wind")

	if wind ~= nil then
		local clone = wind:Clone()
		clone.Parent = folder
		clone:PivotTo(cframe)
		Ouwmit.Emit(clone, Ouwmit.Owned(p))
	end

	local circle = script:FindFirstChild("Circle")

	if circle ~= nil then
		local clone = circle:Clone()
		clone.Parent = folder
		clone:PivotTo(CFrame.new(position - createVector(0, 2.65, 0)))
		task.delay(v, function()
			if clone.Parent == nil then
				return
			end

			Ouwmit.Enable(clone, false)
		end)
	end

	task.delay(math.max(v - 0.2, 0), function()
		if folder.Parent == nil then
			return
		end

		if v3 ~= nil then
			v3:Stop()
		end

		speaker(folder, CFrame.new(position), "PS2pharmeceuticalskillsFADEAWAY", (value2 or 0) + 0.2 + 1)
	end)
end