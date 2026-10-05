local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local localPlayer = Players.LocalPlayer
return {
	new = function(value: string, p, p2: string?)
		local v = p2 == "Account" and "Account" or "Slot"
		local v2 = {}

		for k in string.gmatch(value, "[^/]+") do
			table.insert(v2, k)
		end

		local v3 = cleanit.new()
		local v4 = nil
		local changed = simplesignal.new()
		local flag = false
		local flag2 = false
		local v6 = false
		local v7 = nil
		local v8 = nil
		local v9 = p
		local scheduleRelink

		local function push()
			if flag or flag2 then
				return
			end

			local value2

			if v8 == nil or v8.Parent == nil then
				value2 = p
			else
				value2 = v8.Value
			end

			if value2 == v9 then
				return
			end

			v9 = value2
			changed:Fire(value2)
		end

		local function relink()
			-- [DEDUP] synthesized from 2 duplicated terminal regions
			local function deduplicatedTail()
				if not flag then
					if flag2 then
						return
					end

					local value2

					if v8 == nil or v8.Parent == nil then
						value2 = p
					else
						value2 = v8.Value
					end

					if value2 == v9 then
						return
					end

					v9 = value2
					changed:Fire(value2)
				end
			end

			if flag then
				return
			end

			if v4 ~= nil then
				v4:Destroy()
				v4 = nil
			end

			v8 = nil

			if v7 == nil or v7.Parent == nil then
				return deduplicatedTail()
			else
				local v10 = cleanit.new()
				v4 = v10
				local v11 = v7

				for i = 1, #v2 - 1 do
					local v12 = v2[i]
					local instance = v11:FindFirstChild(v12)

					if instance == nil or not (instance:IsA("Folder") or instance:IsA("Configuration")) then
						local v13 = v12
						v10:Connect(v11.ChildAdded, function(p3)
							if p3.Name == v13 then
								scheduleRelink()
							end
						end)

						if instance ~= nil then
							v10:Connect(instance.Destroying, scheduleRelink)
						end

						if flag or flag2 then
							return
						end

						local value2

						if v8 == nil or v8.Parent == nil then
							value2 = p
						else
							value2 = v8.Value
						end

						if value2 == v9 then
							return
						end

						v9 = value2
						changed:Fire(value2)
						return
					else
						v10:Connect(instance.Destroying, scheduleRelink)
						v11 = instance
					end
				end

				local v12 = v2[#v2]
				v10:Connect(v11.ChildAdded, function(p3)
					if p3.Name == v12 then
						scheduleRelink()
					end
				end)
				local valueBase = v11:FindFirstChild(v12)

				if valueBase ~= nil and valueBase:IsA("ValueBase") then
					v8 = valueBase
					v10:Connect(valueBase:GetPropertyChangedSignal("Value"), push)
					v10:Connect(valueBase.Destroying, scheduleRelink)
				end

				return deduplicatedTail()
			end
		end

		scheduleRelink = function()
			if flag or v6 then
				return
			end

			v6 = true
			task.defer(function()
				v6 = false

				if flag then
					return
				end

				relink()
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setBase(p3)
			if v7 == p3 then
				return
			end

			v7 = p3
			relink()
		end

		local v10 = {
			Changed = changed,
			Get = function(_)
				if flag then
					return p
				end

				return v9
			end,
			Destroy = function(self)
				if flag then
					return
				end

				flag = true

				if v4 ~= nil then
					v4:Destroy()
					v4 = nil
				end

				v3:Destroy()
				changed:Destroy()
				v8 = nil
			end
		}
		task.spawn(function()
			local _, v11, v12 = Utility.GetData(localPlayer, true)

			if flag or v11 == nil then
				return
			end

			v3:Connect(v11.Destroying, function()
				flag2 = true
				setBase(nil) -- equivalent call inferred; original call site unknown
			end)

			if v == "Account" then
				setBase(v11) -- equivalent call inferred; original call site unknown
			else
				local slots = v11:WaitForChild("slots")

				if flag then
					return
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function follow()
					setBase(slots:FindFirstChild("Slot" .. tostring(v12.Value))) -- equivalent call inferred; original call site unknown
				end

				v3:Connect(v12:GetPropertyChangedSignal("Value"), follow)
				follow() -- equivalent call inferred; original call site unknown
			end
		end)
		return v10
	end
}