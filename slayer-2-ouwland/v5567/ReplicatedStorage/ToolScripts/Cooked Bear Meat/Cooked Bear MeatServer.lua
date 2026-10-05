local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local Item = require(ServerStorage.SAM.Services.Removers.Item)
local CookedBearMeatServer = {}

function CookedBearMeatServer.MouseDown(p, instance, p2, p3: string)
	if not (Checker.check(p) and p2.Thread == nil) then
		return
	end

	local data = Utility.GetData(p)

	if not (data ~= nil and Utility.HeldItem(data, p3) ~= nil) then
		return
	end

	local v, v2 = ManuelCancel.new(p, 5)
	v:Connect(function()
		if p2.Thread then
			task.cancel(p2.Thread)
			p2.Thread = nil
		end
	end)
	p2.Thread = task.spawn(function()
		task.wait(0.27)
		p2.Thread = nil
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if Checker.check_victim(script, instance, instance) == nil or humanoid == nil or humanoid.Health <= 0 then
			v2()
			return
		end

		if not Item(p, p3, nil, nil, "Consumed") then
			v2()
			return
		end

		humanoid.Health = math.clamp(humanoid.Health + 50, 0, humanoid.MaxHealth)
		local getvaluesfolder = Utility.getvaluesfolder(p)

		if getvaluesfolder ~= nil then
			PlayerStatResolver.Invalidate(p, "Health Regen Speed")
			Utility.AddTimedValue(getvaluesfolder, "Health Regen Speed", 5, "NumberValue", 3)
		end

		v2()
	end)
end

function CookedBearMeatServer.MouseUp(_, _, p)
	if p.Thread then
		task.cancel(p.Thread)
		p.Thread = nil
	end
end

return CookedBearMeatServer