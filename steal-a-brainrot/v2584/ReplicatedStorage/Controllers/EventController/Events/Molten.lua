local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Molten = {}
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
require(ReplicatedStorage.Packages.Observers)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local maid = Trove.new()

function Molten.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	task.spawn(function()
		SoundController:PlaySound("Sounds.Events.Molten.LavaActivate")
	end)

	local function getTimeLeftForSync(p: number, p2: number?)
		return activeEventData.startedAt + p - (p2 or workspace:GetServerTimeNow())
	end

	local clone

	if ServerData.IsBiggerServer() then
		clone = ReplicatedStorage.Models.Events.Molten.CratersBigger:Clone()
	else
		clone = ReplicatedStorage.Models.Events.Molten.Craters:Clone()
	end

	if ServerData.IsTsunamiServer() then
		clone:ClearAllChildren()
	end

	clone.Parent = workspace
	local children = clone:GetChildren()
	table.sort(children, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	local pivots = {}

	for _, v in children do
		pivots[v] = v.PrimaryPart:GetPivot()
	end

	maid:Add(function()
		for _, v in children do
			local extentsSize = v:GetExtentsSize()
			TweenService:Create(
				v.PrimaryPart,
				TweenInfo.new(1 + math.random() + math.random(), Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					CFrame = pivots[v] - Vector3.new(0, extentsSize.Y * 1.1, 0)
				}
			):Play()
		end

		task.wait(3)
		clone:Destroy()
	end)
	local clone2 = ShakePresets.BumpS:Clone()
	maid:Add(clone2)
	clone2.Sustain = true
	maid:Add(ShakePresets.BindShakeToCamera(clone2, workspace.CurrentCamera))
	clone2:Start()
	local v = activeEventData.startedAt + 4 - workspace:GetServerTimeNow()
	maid:Add(task.delay(v, function()
		clone2:StopSustain()
	end))
	local clone3

	if ServerData.IsJumpLTMServer() then
		clone3 = nil
	elseif ServerData.IsTsunamiServer() then
		clone3 = maid:Clone(script.MoltenWeatherTsunami)
	else
		clone3 = maid:Clone(script.MoltenWeather)
	end

	if clone3 then
		VFX.disable(clone3)
		clone3.Parent = workspace
	end

	if clone3 and ServerData.IsBiggerServer() then
		ClientEventUtils.resizeEffects(clone3, 2)
	end

	maid:Add(task.delay(v, function()
		EffectController:Activate("Blink")
		local atmosphere = Lighting:FindFirstChild("Atmosphere")

		if atmosphere then
			atmosphere.Parent = script
			maid:Add(function()
				atmosphere.Parent = Lighting
			end)
		end

		local clone = maid:Clone(script.AtmosphereMolten)
		clone.Parent = Lighting
		local cartoon = Lighting:FindFirstChild("Cartoon")

		if cartoon then
			cartoon.Parent = script
			maid:Add(function()
				cartoon.Parent = Lighting
			end)
		end

		local clone_2 = maid:Clone(script.SkyMolten)
		clone_2.Parent = Lighting

		if ServerData.IsJumpLTMServer() then
			maid:Add(JumpLTMWeather.Cover(script.MoltenWeather))
		elseif clone3 then
			VFX.enable(clone3)
		end
	end))
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	EffectController:Run("MoltenEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("MoltenEvent", "GrassRecolor")
	end)
	local random = Random.new()

	for _, v2 in ipairs(children) do
		local extentsSize = v2:GetExtentsSize()
		local primaryPartCFrame = v2:GetPrimaryPartCFrame()
		v2:PivotTo(primaryPartCFrame * CFrame.new(0, -extentsSize.Y * 1.1, 0))
		TweenService:Create(
			v2.PrimaryPart,
			TweenInfo.new(random:NextNumber(3, 7), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				CFrame = primaryPartCFrame
			}
		):Play()
	end

	CycleController:Update()
	SoundController:UpdateOST()
end

function Molten.OnStop(_)
	maid:Destroy()
end

function Molten.OnLoad(_) end

return Molten