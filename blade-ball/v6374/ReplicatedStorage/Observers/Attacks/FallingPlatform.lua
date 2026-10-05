local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
local isServer = RunService:IsServer()
local random = Random.new()
return Observers.observeTag("Boss_FallingPlatform", function(model)
	local main

	if model:IsA("Model") then
		main = model:WaitForChild("Main", 5)
	else
		main = model
	end

	if not main then
		warn("Failed to find BasePart for FallingPlatform:", model)
		return nil
	end

	local fallHeight = model:GetAttribute("FallHeight") or 400
	local v = math.min(1.75 * (main.Size.X + main.Size.Z) / 55, 1.25)

	if isServer then
		local thread = nil
		local touchedConnection = main.Touched:Connect(function(otherPart)
			if otherPart.Parent and otherPart.Parent:FindFirstChildOfClass("Humanoid") then
				if model:GetAttribute("Falling") then
					return
				end

				if thread and coroutine.status(thread) ~= "dead" then
					pcall(task.cancel, thread)
				end

				model:SetAttribute("Falling", workspace:GetServerTimeNow())
				thread = task.delay(v + 1 + 1 + 8, function()
					model:SetAttribute("Falling", nil)
				end)
			end
		end)
		return function()
			if touchedConnection then
				touchedConnection:Disconnect()
				touchedConnection = nil
			end

			if thread and coroutine.status(thread) ~= "dead" then
				pcall(task.cancel, thread)
			end
		end
	else
		local cFrameValue = Instance.new("CFrameValue")
		local pivot = model:GetPivot()
		local changedConnection = cFrameValue.Changed:Connect(function(p)
			model:PivotTo(pivot * p)
		end)
		local v2 = true
		local v3 = nil
		local v4 = nil
		local thread = nil

		local function updateFalling()
			local falling = model:GetAttribute("Falling")

			if v3 == falling then
				return
			end

			local thread2 = coroutine.running()

			local function isActive()
				return v2 and thread == thread2
			end

			v3 = falling

			if falling then
				-- equivalent calls inferred from this helper; original call sites unknown
				local function getTimeUntil(p: number)
					return falling + p - workspace:GetServerTimeNow()
				end

				local v5 = main.Size.Magnitude * 0.01
				local identity = CFrame.identity
				local total = 0.05
				local postSimulationConnection = nil
				postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
					if getTimeUntil(v) <= 0 or not v2 or thread ~= thread2 then
						postSimulationConnection:Disconnect()
						return
					end

					total += dt

					if total >= 0.05 then
						identity = CFrame.new(
							random:NextNumber(-v5, v5),
							random:NextNumber(-v5, v5) * 0.5,
							random:NextNumber(-v5, v5)
						)
						total = 0
					end

					cFrameValue.Value = cFrameValue.Value:Lerp(identity, dt * 0.4 * 60)
				end)

				while getTimeUntil(v) > 0 and v2 and thread == thread2 do
					task.wait()
				end

				if not v2 or thread ~= thread2 then
					return
				end

				v4 = FastUtils.fastTween(
					cFrameValue,
					TweenInfo.new(getTimeUntil(v + 1), Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Value = CFrame.new(0, -fallHeight, 0)
					}
				).Completed:Wait()
				v4 = nil

				if not v2 or thread ~= thread2 then
					return
				end

				local timeUntil = getTimeUntil(v + 1 + 8) -- equivalent call inferred; original call site unknown
				local v6 = timeUntil < 1 and 0 or timeUntil
				v4 = FastUtils.fastTween(
					cFrameValue,
					TweenInfo.new(math.min(1, timeUntil), Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, v6),
					{
						Value = CFrame.identity
					}
				).Completed:Wait()
				v4 = nil

				if v2 and thread == thread2 then
				end
			else
				cFrameValue.Value = CFrame.identity

				if v4 then
					v4:Cancel()
					v4:Destroy()
					v4 = nil
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestUpdateFalling()
			if thread and coroutine.status(thread) ~= "dead" then
				pcall(task.cancel, thread)
			end

			thread = task.defer(updateFalling)
		end

		local fallingChangedConnection = model:GetAttributeChangedSignal("Falling"):Connect(requestUpdateFalling)
		requestUpdateFalling() -- equivalent call inferred; original call site unknown
		return function()
			v2 = false
			changedConnection:Disconnect()
			fallingChangedConnection:Disconnect()

			if v4 then
				v4:Cancel()
				v4:Destroy()
				v4 = nil
			end

			cFrameValue:Destroy()
			model:PivotTo(pivot)
		end
	end
end, { workspace })