local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local RiceSpirit = {
	Id = 0
}
local clone = nil
local v = nil
local v2 = nil
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local RunService = game:GetService("RunService")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local TweenService = game:GetService("TweenService")
local Config = require(script.Parent.Config)
local DEFAULT_RADIUS = Config.DEFAULT_RADIUS
local v3 = cleanit.new()
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local CollectionService = game:GetService("CollectionService")
local script2 = script
local track = nil

function RiceSpirit.Hold(player, p)
	DEFAULT_RADIUS = Config.DEFAULT_RADIUS
	local character = player.Character
	local humanoid = character.Humanoid
	local primaryPart = character.PrimaryPart
	local id = RiceSpirit.Id
	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = primaryPart
	local v4 = {}

	local function dropHighlight(k)
		local v5 = v4[k]
		v4[k] = nil

		if v5 == nil then
			return
		end

		TweenService:Create(v5, TweenInfo.new(0.3), {
			FillTransparency = 1,
			OutlineTransparency = 1
		}):Play()
		DebrisModule:AddItem(v5, 0.5)
	end

	v, v2 = Utility.CreateAlignOrientationWithAttachment(primaryPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 80,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(primaryPart.Position, p, primaryPart.CFrame)
	})
	v3:Connect(RunService.Heartbeat, function(_: number)
		p = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		v.CFrame = Utility.SafeLookAt(primaryPart.Position, p, v.CFrame)
	end)
	os.clock()
	track = humanoid.Animator:LoadAnimation(script.Startup)
	track:Play()
	task.delay(Config.ANIM_PAUSE_TIME, function()
		if RiceSpirit.Id == id then
			track:AdjustSpeed(0)
		end
	end)
	task.spawn(function()
		while RiceSpirit.Id == id do
			DEFAULT_RADIUS += 1
			local v5 = {}

			for _, v6 in ipairs(CollectionService:GetTagged("Humanoids")) do
				if not (v6 ~= nil and v6:IsDescendantOf(workspace.Humanoids) and v6.ClassName == "Model" and v6.PrimaryPart ~= nil) then
					continue
				end

				if not (v6 ~= character and vector.magnitude(v6.PrimaryPart.Position - primaryPart.Position) < DEFAULT_RADIUS / 2 and Checker.check_victim(
					script2,
					character,
					v6
				) ~= nil) then
					continue
				end

				table.insert(v5, v6)
			end

			for _, v6 in ipairs(v5) do
				if v4[v6] ~= nil then
					continue
				end

				local clone2 = script.YellowHighlight:Clone()
				clone2.Parent = v6
				clone2.Adornee = v6
				TweenService:Create(clone2, TweenInfo.new(0.3), {
					FillTransparency = 1.35,
					OutlineTransparency = 0
				}):Play()
				v4[v6] = clone2
			end

			for k in pairs(v4) do
				if table.find(v5, k) == nil then
					dropHighlight(k)
				end
			end

			task.wait(Config.RADIUS_GROWTH_INTERVAL)
		end

		for k in pairs(v4) do
			dropHighlight(k)
		end
	end)
	task.wait(Config.MIN_HOLD_DUR)
end

function RiceSpirit.UnHold(_)
	if track ~= nil then
		if track.TimePosition < Config.ANIM_PAUSE_TIME then
			track.TimePosition = Config.ANIM_PAUSE_TIME
		end

		track:AdjustSpeed(1)
	end

	v3:Clean()

	if clone ~= nil then
		clone:Destroy()
	end

	if v ~= nil then
		v:Destroy()
		v = nil
	end

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end
end

function RiceSpirit.Cancel(_)
	if track ~= nil then
		track:Stop()
		track = nil
	end

	v3:Clean()

	if clone ~= nil then
		clone:Destroy()
	end

	if v ~= nil then
		v:Destroy()
		v = nil
	end

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end
end

return RiceSpirit