require(script.Parent.Parent.Parent.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Parent.Parent.Parent.Misc.FayeUtility)
local Player = {}
local AnimatorStorage = require(script.AnimatorStorage)
local OverlapFixer = require(script.OverlapFixer)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lerps = require(script.Parent.Lerps)
local Spring = require(script.Parent.Spring)
local linear = Enum.EasingStyle.Linear
local out = Enum.EasingDirection.Out

function ApplyProperty(p, p2: string, p3: string, p4, p5, p6: number, items, _: boolean, p7)
	if p2 == "number" then
		p[p3] = p5 + (p4 - p5) * p6
	elseif items ~= nil then
		if p7 then
			for _, item in items do
				p[item[1]] = item[2](p6)
			end
		else
			p[p3] = items(p6)
		end
	end
end

function update(p: number)
	if AnimatorStorage.Count == 0 then
		AnimatorStorage.Step:Disconnect()
		AnimatorStorage.Step = nil
	end

	for i = AnimatorStorage.Count, 1, -1 do
		local id = AnimatorStorage.Ids[i]
		local v = AnimatorStorage.Holder[id]

		if v == nil then
			AnimatorStorage.Ids[i] = nil
		elseif v.Entity == nil or v.Entity.Parent == nil then
			if v.Delete == nil then
				Player.Remove(id)
			else
				v.Delete()
			end
		else
			v.Elapsed += p

			if v.Ran == false then
				warn((`Animation: {id} Errored.`))
				v.Delete(true)
			else
				v.Ran = false

				if v.Elapsed <= v.DelayTime and v.Direction then
					v.Ran = true
				else
					local max = FayeUtility.max((v.Elapsed - v.DelayTime) % v.Time, 0)
					local v2, value

					if v.Direction == false then
						v2 = v.Time - max
						value = 0
					else
						v2 = max
						value = 1
					end

					local v3 = v2 / v.Time
					local flag = nil

					if v.ProgBefore == nil or not (max < v.ProgBefore) then
						if v.EasingStyle == nil then
							if v.Frequency ~= nil then
								value = Spring(v3, v.Frequency, v.Damping)
							end
						else
							value = TweenService:GetValue(v3, v.EasingStyle, v.EasingDirection)
						end
					elseif v.Reverse == true and v.Direction == true then
						v.Direction = false
					else
						v.Direction = true

						if v.RepeatsLeft == 0 then
							flag = true
						else
							if v.Reverse then
								v.ProgBefore = nil
								v.Elapsed = 0
							end

							if v.RepeatsLeft >= 1 then
								v.RepeatsLeft -= 1
							end
						end
					end

					ApplyProperty(v.Entity, v.PropertyType, v.Property, v.To, v.Default, value, v.Lerp, flag, v.IsBasic)

					if v.Others ~= nil then
						for i2 = v.Others.Count, 1, -1 do
							local other = v.Others[i2]

							if other.Entity == nil or other.Entity.Parent == nil then
								warn("Remove")
								FayeUtility.tr(v.Others, i2)
								v.Others.Count -= 1
							else
								ApplyProperty(
									other.Entity,
									other.PropertyType,
									other.Property,
									v.To,
									other.Default,
									value,
									other.Lerp,
									flag
								)
							end
						end

						if v.Others.Count <= 0 then
							v.Others = nil
						end
					end

					if flag then
						if v.IsValue then
							v.Delete(true, true)
						else
							v.Delete(true)
						end
					else
						v.Ran = true

						if v.Elapsed ~= 0 then
							v.ProgBefore = max
						end
					end
				end
			end
		end
	end
end

function Player.Add(p: string, to, data, delete, entity, property: string, others, isValue: boolean?, propertyType: string, initial, isBasic: boolean?, value: number?, flag: boolean?, p3: number?)
	local v = data ~= nil

	if property == nil or property == "" then
		return
	end

	if AnimatorStorage.TweenserviceBanned[propertyType] or v and data.Frequency ~= nil then
		local v2 = {
			To = to,
			Elapsed = value or 0,
			Direction = flag or true,
			PropertyType = propertyType,
			ProgBefore = p3 or nil,
			RepeatsLeft = not v and 0 or data.RepeatCount or 0,
			Delete = delete,
			Reverse = 0,
			Time = 0,
			Entity = 0,
			IsValue = 0,
			Property = 0,
			DelayTime = 0,
			Multiplier = 0,
			IsBasic = 0
		}
		local reverse

		if v then
			reverse = data.Reverse or nil
		end

		v2.Reverse = reverse
		v2.Time = not v and 1 or data.Time or 1
		v2.Entity = entity
		v2.IsValue = isValue
		v2.Property = property
		v2.DelayTime = not v and 0 or data.DelayTime or 0
		v2.Multiplier = AnimatorStorage.Multipliers[propertyType]
		v2.IsBasic = isBasic

		if data == nil then
			v2.EasingStyle = linear
			v2.EasingDirection = out
		elseif data.EasingStyle then
			v2.EasingStyle = data.EasingStyle
			v2.EasingDirection = data.EasingDirection or out
		else
			v2.Frequency = data.Frequency or 1
			v2.Damping = data.Damping or 0.25
		end

		if isBasic == nil and others ~= nil then
			v2.Others = others

			for i = 1, v2.Others.Count do
				if initial ~= nil then
					v2.Others[i].Entity[v2.Others[i].Property] = initial
				end

				v2.Others[i].Default = v2.Initial or v2.Others[i].Entity[v2.Others[i].Property]
				v2.Others[i].Lerp = Lerps[v2.Others[i].PropertyType](v2.Others[i].Default, to)
			end
		end

		if initial ~= nil then
			v2.Initial = initial
			entity[property] = initial
		end

		if isBasic and property ~= nil then
			v2.Lerp = {}
			local v4 = 1

			for k, item in pairs(to) do
				v2.Lerp[v4] = { k, (Lerps[typeof(item)](v2.Entity[k], item)) }
				v4 += 1
			end
		else
			v2.Default = v2.Initial or v2.Entity[v2.Property]
			v2.Lerp = Lerps[v2.PropertyType](v2.Default, to)
		end

		OverlapFixer.Add(entity, property, delete)

		if AnimatorStorage.Ids == nil then
			AnimatorStorage.Ids = {}
		end

		FayeUtility.tins(AnimatorStorage.Ids, p)

		if AnimatorStorage.Holder == nil then
			AnimatorStorage.Holder = {}
		end

		AnimatorStorage.Holder[p] = v2

		if AnimatorStorage.Count == 0 then
			AnimatorStorage.Count = 1
			AnimatorStorage.Step = RunService.PreRender:Connect(update)
		else
			AnimatorStorage.Count += 1
		end
	else
		local time = 1
		local easingStyle = linear
		local easingDirection = out
		local repeatCount = 0
		local reverse = false
		local delayTime = 0

		if v == true then
			time = data.Time or time
			easingStyle = data.EasingStyle or easingStyle
			easingDirection = data.EasingDirection or easingDirection
			repeatCount = data.RepeatCount or repeatCount
			reverse = data.Reverse or false
			delayTime = data.DelayTime or delayTime
		end

		local tweenInfo = TweenInfo.new(time, easingStyle, easingDirection, repeatCount, reverse, delayTime)
		local tween = TweenService:Create(entity, tweenInfo, isBasic and to or {
			[property] = to
		})
		local completedConnection = tween.Completed:Connect(function(_)
			if AnimatorStorage ~= nil and AnimatorStorage.RegularTweenHolder ~= nil and AnimatorStorage.RegularTweenHolder[p] ~= nil or isBasic then
				if isValue then
					delete(true, true)
				else
					delete(true)
				end
			end
		end)
		OverlapFixer.Add(entity, property, delete)

		if isBasic then
			return tween, completedConnection
		end

		if AnimatorStorage.RegularTweenHolder == nil then
			AnimatorStorage.RegularTweenHolder = {}
		end

		if initial ~= nil then
			entity[property] = initial
		end

		AnimatorStorage.RegularTweenCount += 1
		AnimatorStorage.RegularTweenHolder[p] = {
			Info = tweenInfo,
			To = to,
			Initial = initial,
			Delete = delete,
			IsValue = isValue,
			Property = property
		}
		AnimatorStorage.RegularTweenHolder[p].Main = tween
		AnimatorStorage.RegularTweenHolder[p].Main:Play()

		if others ~= nil then
			AnimatorStorage.RegularTweenHolder[p].Others = {
				Count = 0
			}

			for i = 1, others.Count do
				if others[i] == nil then
					continue
				end

				if initial ~= nil then
					others[i].Entity[property] = initial
				end

				local others2 = AnimatorStorage.RegularTweenHolder[p].Others
				others2[i] = {
					Main = TweenService:Create(others[i].Entity, AnimatorStorage.RegularTweenHolder[p].Info, {
						[others[i].Property] = to
					}),
					Property = others[i].Property
				}
				AnimatorStorage.RegularTweenHolder[p].Others[i].Main:Play()
				AnimatorStorage.RegularTweenHolder[p].Others.Count = i
			end
		end

		AnimatorStorage.RegularTweenHolder[p].Connection = completedConnection
	end
end

function Player.Remove(p: string)
	if p == nil then
		return
	end

	if AnimatorStorage.Holder == nil or AnimatorStorage.Holder[p] == nil then
		if AnimatorStorage.RegularTweenHolder == nil or AnimatorStorage.RegularTweenHolder[p] == nil then
			return
		end

		local v = AnimatorStorage.RegularTweenHolder[p]
		OverlapFixer.Remove(v.Main.Instance, v.Property)
		AnimatorStorage.RegularTweenHolder[p] = nil
		v.Main:Cancel()

		if v.Others ~= nil then
			for i = v.Others.Count, 1, -1 do
				v.Others[i].Main:Cancel()
				v.Others[i] = nil
			end

			v.Others.Count = nil
			v.Others = nil
		end

		v.Connection:Disconnect()
		AnimatorStorage.RegularTweenCount -= 1

		if AnimatorStorage.RegularTweenCount == 0 then
			AnimatorStorage.RegularTweenHolder = nil
		end

		return true
	else
		local v = AnimatorStorage.Holder[p]
		AnimatorStorage.Holder[p] = nil
		OverlapFixer.Remove(v.Entity, v.Property)
		FayeUtility.TableRemove(AnimatorStorage.Ids, p)
		AnimatorStorage.Count -= 1

		if AnimatorStorage.Count == 0 and AnimatorStorage.Step ~= nil then
			AnimatorStorage.Holder = nil
			AnimatorStorage.Ids = nil
			AnimatorStorage.Step:Disconnect()
		end

		return true
	end
end

return Player