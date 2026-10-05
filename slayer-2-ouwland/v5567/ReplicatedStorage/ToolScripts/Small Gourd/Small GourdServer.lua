local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Item = require(ServerStorage.SAM.Services.Removers.Item)
local Progression = require(ServerStorage.SAM.Services.Adders.Progression)
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)

local function findGourd(instance)
	local tool_Accessories = instance:FindFirstChild("Tool_Accessories")

	if tool_Accessories == nil then
		return nil
	end

	for _, child in ipairs(tool_Accessories:GetChildren()) do
		if child:GetAttribute("_ClanAccessory") ~= true then
			return child
		end
	end

	return nil
end

local SmallGourdServer = {}

function SmallGourdServer.Equipped(_, _, _, _: string) end

function SmallGourdServer.UnEquipped(_, _, _, _: string) end

function SmallGourdServer.MouseDown(p, instance, p2, p3: string)
	if not (Checker.check(p) and p2.Thread == nil) then
		return
	end

	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	local heldItem = Utility.HeldItem(data, p3)

	if heldItem == nil then
		return
	end

	local amount = heldItem:FindFirstChild("Amount")
	local v = amount == nil or amount.Value <= 1
	local v2, v3 = ManuelCancel.new(p, 5)
	v2:Connect(function()
		if p2.Thread then
			task.cancel(p2.Thread)
			p2.Thread = nil
		end
	end)
	p2.Thread = task.spawn(function()
		task.wait((v and 1.26 or 0.4166666666666667) - 0.05)
		p2.Thread = nil
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if Checker.check_victim(script, instance, instance) == nil or humanoid == nil or humanoid.Health <= 0 then
			v3()
			return
		end

		local model

		if v then
			model = findGourd(instance)
		end

		local pivot

		if model ~= nil then
			pivot = model:GetPivot()
		end

		local v4 = (model == nil or not model:IsA("Model")) and 1 or model:GetScale()

		if not Item(p, p3, nil, nil, "Consumed") then
			v3()
			return
		end

		local content = Progression(p, "Slayer", PlayerProgression.ProgressValue("Slayer", p3))

		if content ~= nil then
			SignalEvent.ToClient(p, "CurrencyNotification", {
				Content = content,
				Time = 5
			})
		end

		if pivot ~= nil then
			EffectsEvent.ToAllInRange(instance, "Gourdbreak", pivot, v4)
		end

		v3()
	end)
end

function SmallGourdServer.MouseUp(_, _, p)
	if p.Thread then
		task.cancel(p.Thread)
		p.Thread = nil
	end
end

return SmallGourdServer