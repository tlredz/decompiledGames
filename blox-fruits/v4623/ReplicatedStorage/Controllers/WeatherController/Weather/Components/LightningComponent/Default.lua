local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local _ = game.Players.LocalPlayer
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local assets = script.Assets
local thunderBolts = assets.ThunderBolts
local count = #thunderBolts:GetChildren()

local function DeleteImpactAfterDuration(folder, value: number?)
	local v = value or 0

	if not value then
		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end
	end

	task.delay(v, function()
		folder:Destroy()
	end)
end

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
end

local folder = Instance.new("Folder")
folder.Name = "Visuals:" .. script.Name
folder.Parent = _WorldOrigin
return function(p, _: number)
	if not assets then
		return
	end

	local v = {
		Position = p.BottomPosition,
		Normal = createVector(0, 0, 0)
	}
	local position = v.Position
	local v2 = math.random(1, count)
	local clone = thunderBolts["Thunder" .. tostring(v2)]:Clone()
	clone.CFrame = CFrame.new(v.Position)
	clone.Parent = folder
	DeleteImpactAfterDuration(clone)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local clone2 = assets.ThunderBoltImpact:Clone()
	clone2.CFrame = clone.CFrame
	clone2.Parent = folder
	local part = Instance.new("Part")
	part.Name = script.Name .. ":SoundPart"
	part.Size = createVector(0, 0, 0)
	part.CanQuery = false
	part.CanTouch = false
	part.CanCollide = false
	part.Anchored = true
	part.Position = position
	part.Parent = workspace._WorldOrigin
	local Sound = require(game.ReplicatedStorage.Util.Sound)
	Sound:Play("WeatherSounds.LightningFlash", part)
	local Sound2 = require(game.ReplicatedStorage.Util.Sound)
	Sound2:Play("WeatherSounds.LightningStrike", part)
	DeleteImpactAfterDuration(part, 0 + 5)
	DeleteImpactAfterDuration(clone2)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end