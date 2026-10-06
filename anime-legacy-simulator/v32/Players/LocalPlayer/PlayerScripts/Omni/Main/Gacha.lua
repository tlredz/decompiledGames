local module = require("@game/ReplicatedStorage/Omni")
local gachaRoll = module.Instance:WaitForChild("PlayerGui"):WaitForChild("GachaRoll")
local main = gachaRoll:WaitForChild("Main")
local scroll = main:WaitForChild("Scroll")
local arrows = main:WaitForChild("Arrows")
local shownup = main:WaitForChild("Shownup")
local gachaRoll2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("GachaRoll")
local reward = gachaRoll2:WaitForChild("Reward")
local arrow = gachaRoll2:WaitForChild("Arrow")
local flag = false
local flag2 = false
local v = {}

local function IsCancelled(p)
	if flag2 then
		return true
	end

	local isCancelled = p.Options and p.Options.IsCancelled
	return isCancelled ~= nil and isCancelled() == true
end

local function ClearFrames(instance)
	for _, frame in instance:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

local function CleanAnimation(state, flag3: boolean?)
	if state.TickSound then
		state.TickSound:cancel()
		state.TickSound = nil
	end

	if state.EndSound then
		if not flag3 then
			state.EndSound:cancel()
		end

		state.EndSound = nil
	end

	for _, instance in state.Instances do
		instance:Destroy()
	end

	table.clear(state.Instances)

	if not state.OwnsGui then
		return
	end

	state.OwnsGui = false
	main.Position = state.MainPosition
	gachaRoll.Enabled = false

	if state.HidingFrames then
		state.HidingFrames = false
		module.Frame:RemoveFramesHider("Gacha")
	end
end

local function BuildReward(state, data, layoutOrder: number)
	local clone = reward:Clone()
	table.insert(state.Instances, clone)
	clone.LayoutOrder = layoutOrder
	clone.Main.Title.Text = data.Name or ""
	clone.Main.Icon.Image = data.Icon or ""

	if data.Icon then
		clone.Main.Icon.Visible = true
		clone.Main.Viewport.Visible = false
	else
		module.Utils.Camera.ViewportCharacter({
			Viewport = clone.Main.Viewport,
			Animation = module.Utils.Characters.GetCharacterAnimation(data.Name, "Idle"),
			Character = module.Utils.Characters.Get({
				Name = data.Name,
				RemoveHumanoidStates = true
			})
		})
		clone.Main.Icon.Visible = false
		clone.Main.Viewport.Visible = true
	end

	clone.Main.UIGradient:SetAttribute("Rarity", data.Rarity)
	clone.Parent = scroll
	clone.Visible = true
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetHiddenGoal(p)
	local v2 = math.max(main.AbsoluteSize.X, 1)
	local v3 = p.AbsolutePosition.X - scroll.AbsolutePosition.X
	return (math.min(
		0,
		(gachaRoll.AbsolutePosition.X + gachaRoll.AbsoluteSize.X + math.max(p.AbsoluteSize.X, 6) - main.AbsolutePosition.X - v3) / v2
	))
end

local function WaitForAnimation(state, p: number)
	local lastTime = os.clock()

	while os.clock() - lastTime < p do
		local v2

		if flag2 then
			v2 = true
		else
			local isCancelled = state.Options and state.Options.IsCancelled

			if isCancelled == nil then
				v2 = false
			else
				v2 = isCancelled() == true
			end
		end

		if v2 then
			return false
		else
			task.wait()
		end
	end

	local v2

	if flag2 then
		v2 = true
	else
		local isCancelled = state.Options and state.Options.IsCancelled

		if isCancelled == nil then
			v2 = false
		else
			v2 = isCancelled() == true
		end
	end

	return not v2
end

local function RunAnimation(state)
	local v2

	if flag2 then
		v2 = true
	else
		local isCancelled = state.Options and state.Options.IsCancelled

		if isCancelled == nil then
			v2 = false
		else
			v2 = isCancelled() == true
		end
	end

	if v2 then
		return false
	end

	local options = state.Options or {}

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		if options.OnTransition then
			options.OnTransition()
		end

		local v3

		if flag2 then
			v3 = true
		else
			local isCancelled = state.Options and state.Options.IsCancelled

			if isCancelled == nil then
				v3 = false
			else
				v3 = isCancelled() == true
			end
		end

		return not v3
	end

	local finalRewards = state.FinalRewards
	local possible = state.Possible
	local luck = state.Luck
	local count = #finalRewards
	local v3 = math.max(state.Duration, 0.6)
	local v4 = math.max(options.RollTime or v3 * 0.75, 0.44999999999999996)
	local v5 = v3 * 0.25

	if state.HideAnimation then
		if not WaitForAnimation(state, v4 + v5 + 0.5) then
			return false
		end

		for _, finalReward in finalRewards do
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Drop", {
				Type = options.DropType,
				GachaName = options.GachaName,
				Name = finalReward.Name,
				Rarity = finalReward.Rarity,
				Amount = 1
			})
		end

		return true
	else
		local v6 = math.random(45, 70)
		local v7 = v6 + 1
		state.MainPosition = main.Position
		state.OwnsGui = true
		ClearFrames(arrows)
		ClearFrames(scroll)
		shownup:ClearAllChildren()

		for i = 1, v6 do
			local roll = module.Utils.Luck.Roll(possible.Chances, luck or 0)
			local v8 = roll and possible.Info[roll]

			if not v8 then
				roll = next(possible.Info)
				v8 = roll and possible.Info[roll]
			end

			if v8 then
				BuildReward(state, {
					Name = roll,
					Rarity = v8.Rarity,
					Icon = v8.Icon
				}, i)
			end
		end

		local v8 = {}

		for k, finalReward in finalRewards do
			v8[k] = BuildReward(state, finalReward, v7 + k - 1)
		end

		local v9 = math.max(0, (math.ceil((1 - (count * 0.05 + 0.5)) / 0.1 - 1e-6)))
		local v10 = v7 + count - 1

		for i = 1, v9 do
			local roll = module.Utils.Luck.Roll(possible.Chances, luck or 0)
			local v11 = roll and possible.Info[roll]

			if not v11 then
				roll = next(possible.Info)
				v11 = roll and possible.Info[roll]
			end

			if v11 then
				BuildReward(state, {
					Name = roll,
					Rarity = v11.Rarity,
					Icon = v11.Icon
				}, v10 + i)
			end
		end

		arrows.Size = UDim2.fromScale(count * 0.1, arrows.Size.Y.Scale)
		local clones = {}

		for i = 1, count do
			local clone = arrow:Clone()
			table.insert(state.Instances, clone)
			clone.LayoutOrder = i
			clone.Size = UDim2.fromScale(1 / count, 1)
			clone.Visible = true
			clone.Parent = arrows
			clones[i] = clone
		end

		local v11 = 0.5 - (v7 - 1) * 0.1 - count * 0.05
		scroll.Position = UDim2.fromScale(0, 0.5)
		gachaRoll.Enabled = true
		state.HidingFrames = true
		module.Frame:AddFramesHider("Gacha")

		if options.OnStart then
			options.OnStart()
		end

		if options.HideResult then
			task.wait()
		end

		local sigmoid = module.Utils.Number.Sigmoid(5)
		local sigmoid2 = module.Utils.Number.Sigmoid(-5)
		local lastTime = os.clock()
		local v12 = 0

		while true do
			local v13

			if flag2 then
				v13 = true
			else
				local isCancelled = state.Options and state.Options.IsCancelled

				if isCancelled == nil then
					v13 = false
				else
					v13 = isCancelled() == true
				end
			end

			if v13 then
				return false
			end

			local v14 = math.min(os.clock() - lastTime, v4)
			local v15 = math.clamp(v14 / v4, 0, 1)
			local v16 = (module.Utils.Number.Sigmoid((v15 - 0.5) * 10) - sigmoid2) / (sigmoid - sigmoid2)

			if options.HideResult then
				v11 = GetHiddenGoal(v8[1])
			end

			local v17 = v11 * v16
			local rotation = math.sin(math.abs(v17) % 0.05 / 0.05 * 3.141592653589793) * 45
			local v19 = math.floor(math.abs(v17) / 0.1)

			if v19 ~= v12 then
				local tickSound = module.Sound:PlayEffect("Gacha.Tick", {
					Cooldown = 0.04,
					MaxVoices = 1
				})

				if tickSound:getStatus() == module.Libs.Promise.Status.Started then
					state.TickSound = tickSound
				end

				v12 = v19
			end

			for _, v20 in clones do
				v20.Main.Rotation = rotation
			end

			scroll.Position = UDim2.fromScale(v17, 0.5)

			if options.OnStep then
				options.OnStep(v14)
			end

			if v15 >= 1 then
				local v20

				if flag2 then
					v20 = true
				else
					local isCancelled = state.Options and state.Options.IsCancelled

					if isCancelled == nil then
						v20 = false
					else
						v20 = isCancelled() == true
					end
				end

				if v20 then
					return false
				end

				for _, v21 in clones do
					v21.Main.Rotation = 0
				end

				if options.HideResult then
					CleanAnimation(state)
					return deduplicatedTail()
				else
					local clones2 = {}

					if state.TickSound then
						state.TickSound:cancel()
						state.TickSound = nil
					end

					state.EndSound = module.Sound:PlayEffect("Gacha.End", {
						MaxVoices = 1
					})

					for k, v21 in v8 do
						local v22 = 0.5 - count * 0.05 + (k - 1) * 0.1 + 0.05
						local clone = v21:Clone()
						table.insert(state.Instances, clone)
						clone.Name = "Shown" .. k
						clone.AnchorPoint = Vector2.new(0.5, 0.5)
						clone.Position = UDim2.fromScale(v22, 0.5)
						clone.Size = UDim2.fromScale(0.1, 1)
						clone.Parent = shownup
						clone.Visible = true
						local clone2 = reward:Clone()
						table.insert(state.Instances, clone2)
						clone2.LayoutOrder = v21.LayoutOrder
						clone2.Visible = true
						clone2.Parent = scroll
						v21:Destroy()
						clones2[k] = clone
					end

					local lastTime2 = os.clock()

					while true do
						local v21

						if flag2 then
							v21 = true
						else
							local isCancelled = state.Options and state.Options.IsCancelled

							if isCancelled == nil then
								v21 = false
							else
								v21 = isCancelled() == true
							end
						end

						if v21 then
							return false
						end

						local v22 = math.clamp((os.clock() - lastTime2) / v5, 0, 1)
						local v23 = (module.Utils.Number.Sigmoid((v22 - 0.5) * 10) - sigmoid2) / (sigmoid - sigmoid2)

						for _, v24 in clones2 do
							v24.Size = UDim2.fromScale(0.1 + 0.01 * v23, 1 + 0.1 * v23)
						end

						if v22 >= 1 then
							if not WaitForAnimation(state, 0.5) then
								return false
							end

							CleanAnimation(state, true)
							return deduplicatedTail()
						else
							task.wait()
						end
					end
				end
			else
				task.wait()
			end
		end
	end
end

local function ProcessAnimation(p)
	local v2, v3 = xpcall(function()
		return (RunAnimation(p))
	end, debug.traceback)
	CleanAnimation(p)

	if not v2 then
		warn("Gacha animation failed: " .. tostring(v3))
	end

	local onFinish = p.Options and p.Options.OnFinish

	if not onFinish then
		return
	end

	local v4, v5 = xpcall(function()
		onFinish(v2 and v3 == true)
	end, debug.traceback)

	if not v4 then
		warn("Gacha completion failed: " .. tostring(v5))
	end
end

local Gacha = {
	Animation = function(duration: number, finalRewards, possible, luck: number?, options)
		if #finalRewards == 0 then
			return
		end

		local v3 = {
			Duration = duration,
			FinalRewards = finalRewards,
			Possible = possible,
			Luck = luck,
			Options = options,
			HideAnimation = options ~= nil and options.DropType ~= nil and not options.HideResult and module.Data.Settings["Hide Gacha Animation"] == true,
			Instances = {}
		}
		table.insert(v, v3)

		if flag then
			return
		end

		flag = true

		while #v > 0 do
			ProcessAnimation(table.remove(v, 1))
		end

		flag = false
	end
}
script.Destroying:Connect(function()
	flag2 = true
end)
return Gacha