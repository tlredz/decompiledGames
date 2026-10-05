local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = require(game.ReplicatedStorage.Util.Debris)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local fn = not workspace.StreamingEnabled and function(p)
	return p
end or require(game.ReplicatedStorage.Util.EncodeObj)
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local tweenEvent = script.TweenEvent
local simulatedTweenEvent = script.SimulatedTweenEvent

local function serializeTweenInfo(data)
	return {
		data.Time or 1,
		data.EasingStyle or Enum.EasingStyle.Quad,
		data.EasingDirection or Enum.EasingDirection.Out,
		data.RepeatCount or 0,
		data.Reverses or false,
		data.DelayTime or 0
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deserializeTweenInfo(list)
	return TweenInfo.new(unpack(list))
end

local function assignProperties(p, items)
	for k, item in pairs(items) do
		p[k] = item
	end
end

local function fireAllClients(...)
	if RunService:IsRunning() then
		tweenEvent:FireAllClients(...)
	else
		simulatedTweenEvent:Fire(...)
	end
end

local v6 = {
	Create = function(self, instance, p, p2, flag: boolean?)
		local v7 = {
			Range = 900,
			DontUpdate = {}
		}
		local v8 = serializeTweenInfo(p)
		local destroyingConnection = nil

		local function play(p3: number?, player, flag2: boolean?)
			local v9 = os.time() + v8[1]
			local v10 = v8[1]

			if instance and instance.Parent == workspace._WorldOrigin then
				Debris:AddItem(instance, v10 + 7)
			end

			v[instance] = v[instance] or os.time()
			local v11 = flag2 or false
			v7.Paused = false

			if not v3[instance] then
				destroyingConnection = instance.Destroying:Once(function()
					v7:Destroy()
				end)
				v3[instance] = destroyingConnection
			end

			if player == nil and not v11 then
				v[instance] = v9
				fireAllClients("RunTween", fn(instance), v8, p2, v7.Range)
			elseif v11 and player == nil then
				v10 += v[instance] - os.time()
				v[instance] = v9 + (v[instance] - os.time())
				fireAllClients("QueueTween", fn(instance), v8, p2, v7.Range)
			elseif v11 then
				tweenEvent:FireClient(player, "QueueTween", fn(instance), v8, p2, v7.Range)
			else
				tweenEvent:FireClient(player, "RunTween", fn(instance), v8, p2, v7.Range)
			end

			if flag then
				if p3 and player == nil then
					local v12 = v[instance]
					local count = 0

					repeat
						task.wait(1)
						count += 1
					until v10 <= count or v7.Stopped or v5[instance]

					if not instance:IsDescendantOf(workspace) then
						return
					end

					if v[instance] == v12 then
						v[instance] = nil
					end

					if v7.Paused == nil or v7.Paused == false then
						if v5[instance] then
							v5[instance] = false
							return
						end

						local v13 = instance

						for k, v15 in pairs(p2) do
							v13[k] = v15
						end
					end
				elseif not player then
					task.spawn(function()
						local v12 = v[instance]
						local count = 0

						repeat
							task.wait(1)
							count += 1
						until v10 <= count or v7.Stopped or v5[instance]

						if not instance:IsDescendantOf(workspace) then
							return
						end

						if v[instance] == v12 then
							v[instance] = nil
						end

						if v7.Paused == nil or v7.Paused == false then
							if v5[instance] then
								v5[instance] = false
								return
							end

							local v13 = instance

							for k, v15 in pairs(p2) do
								v13[k] = v15
							end
						end
					end)
				end
			end
		end

		function v7:Destroy()
			if destroyingConnection then
				destroyingConnection:Disconnect()
				v3[instance] = nil
			end

			v[instance] = nil
			v5[instance] = nil
			fireAllClients("Destroy", fn(instance))
		end

		function v7:Play(p3, p4)
			play(p3, p4)
		end

		function v7.QueuePlay(_, p3, p4)
			play(p3, p4, true)
		end

		function v7:Pause(player)
			if player == nil then
				v7.Paused = true
				fireAllClients("PauseTween", fn(instance))
			else
				table.insert(v7.DontUpdate, player)
				tweenEvent:FireClient(player, "PauseTween", fn(instance))
			end
		end

		function v7:Stop(player)
			if player ~= nil then
				tweenEvent:FireClient(player, "StopTween", fn(instance))
				return
			end

			v5[instance] = true
			v7.Stopped = true
			fireAllClients("StopTween", fn(instance))
		end

		function v7.ForceFinish(_, player)
			if player ~= nil then
				tweenEvent:FireClient(player, "ForceFinish", fn(instance))
				return
			end

			v7:Stop()
			fireAllClients("ForceFinish", fn(instance), v8, p2, v7.Range)
		end

		return v7
	end,
	_SimulatedOnTween = simulatedTweenEvent,
	_OnTweenUpdate = function(p: string, p2, list, options, p3: number)
		if not (list and p2) then
			return
		end

		local instance = fn(p2)

		if not instance then
			return
		end

		if not v4[instance] then
			v4[instance] = instance.AncestryChanged:Connect(function(_, parent)
				if not parent then
					local connection = v4[instance]
					assert(connection, "bad connection")
					connection:Disconnect()
					v4[instance] = nil
					v[instance] = nil
					v5[instance] = nil
					v2[instance] = nil
				end
			end)
		end

		if instance:IsA("BasePart") or instance:IsA("SpecialMesh") then
			if instance:IsA("SpecialMesh") and instance.Parent and instance.Parent:IsA("BasePart") then
				if p3 < (instance.Parent.Position - workspace.CurrentCamera.CFrame.Position).Magnitude then
					return
				end
			elseif instance:IsA("BasePart") and p3 < (instance.Position - workspace.CurrentCamera.CFrame.Position).Magnitude then
				return
			end
		end

		local v7 = deserializeTweenInfo(list) -- equivalent call inferred; original call site unknown

		local function runTween(flag: boolean?)
			local v8 = os.time() + v7.Time
			v[instance] = v[instance] or os.time()
			local v9 = v[instance]

			if flag and v[instance] >= os.time() then
				local v10 = v[instance] - os.time()
				v[instance] = v8 + v10
				v9 = v[instance]
				task.wait(v10)
			else
				v[instance] = v8
			end

			if v2[instance] then
				v2[instance]:Cancel()
			end

			local tween = TweenService:Create(instance, v7, options)
			v2[instance] = tween
			tween:Play()
			task.wait(v7.Time or 1)

			if v[instance] == v9 then
				v[instance] = nil
			end

			if v2[instance] == tween then
				v2[instance] = nil
			end
		end

		if p == "RunTween" then
			runTween()
		elseif p == "QueueTween" then
			runTween(true)
		elseif p == "StopTween" then
			if not v2[instance] then
				warn("Tween being Stopped does not exist.")
				return
			end

			v2[instance]:Cancel()
			v2[instance] = nil
		elseif p == "ForceFinish" then
			if v2[instance] then
				v2[instance]:Cancel()
				v2[instance] = nil
			end

			for k, v8 in pairs(options or {}) do
				instance[k] = v8
			end
		elseif p == "PauseTween" then
			if v2[instance] then
				v2[instance]:Pause()
			else
				warn("Tween being paused does not exist.")
			end
		elseif p == "Destroy" and v2[instance] then
			v2[instance]:Cancel()
			v2[instance] = nil
		end
	end
}

if not RunService:IsClient() then
	return v6
end

local RunService2 = game:GetService("RunService")

if not RunService2:IsRunning() or GlobalUtil.FFlags.IsUnitTest ~= false then
	return v6
end

tweenEvent.OnClientEvent:Connect(v6._OnTweenUpdate)
return TweenService