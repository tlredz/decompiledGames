local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
require(script.Parent.Parent.Types)

local function FormatDuration(p: number)
	local v = math.max(0, (math.floor(p)))
	local v2 = math.floor(v / 86400)
	local v3 = math.floor(v % 86400 / 3600)
	local v4 = math.floor(v % 3600 / 60)
	local v5 = v % 60

	if v2 > 0 then
		return (`{v2}d {v3}h {v4}m {v5}s`)
	end

	if v3 > 0 then
		return (`{v3}h {v4}m {v5}s`)
	end

	if v4 > 0 then
		return (`{v4}m {v5}s`)
	end

	return (`{v5}s`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetServerType()
	if game.PrivateServerId == "" then
		return "Public"
	end

	if game.PrivateServerOwnerId == 0 then
		return "Reserved server"
	end

	return "VIP private server"
end

local function ReadNumber(callback, p: string, value: number?)
	local success, result = pcall(callback)

	if success and type(result) == "number" then
		return string.format(`%.{value or 2}f%s`, result, p)
	end

	return "Unavailable"
end

local function FormatBonusMap(bonusManager, result)
	local v = {}

	for k, item in result do
		for k2, v2 in item do
			local remainingTime = bonusManager:GetRemainingTime(v2)
			table.insert(v, (`{k} {k2} x{v2.mult} ({FormatDuration(remainingTime)})`))
		end
	end

	table.sort(v)

	if #v > 0 then
		return (table.concat(v, ", "))
	end

	return "None"
end

local function ReadLiveSystems()
	local v = {}
	local success, bonusManager = pcall(require, ReplicatedStorage.BonusManager)

	if success then
		local success2, result = pcall(function()
			return bonusManager:GetActiveServerBonuses()
		end)
		local success3, result2 = pcall(function()
			return bonusManager:GetActiveGlobalBonuses()
		end)
		table.insert(v, {
			Name = "Server bonuses",
			Value = not success2 and "Unavailable" or FormatBonusMap(bonusManager, result)
		})
		table.insert(v, {
			Name = "Global bonuses",
			Value = not success3 and "Unavailable" or FormatBonusMap(bonusManager, result2)
		})
	else
		table.insert(v, {
			Name = "Bonuses",
			Value = "Unavailable"
		})
	end

	local concert = ReplicatedStorage:FindFirstChild("Concert")
	local v2 = concert and concert:GetAttribute("ConcertActive") == true
	local v3 = concert and concert:GetAttribute("ConcertPremiere") == true
	table.insert(v, {
		Name = "Concert",
		Value = v2 and (v3 and "Active premiere" or "Active") or "Inactive"
	})
	return v
end

local function ReadOverview()
	local now = os.time()
	local v = math.max(0, workspace.DistributedGameTime)
	local success, result = pcall(function()
		local fields = {
			{
				Name = "Job ID",
				Value = game.JobId == "" and "Studio session" or game.JobId
			},
			{
				Name = "Place ID",
				Value = tostring(game.PlaceId)
			},
			{
				Name = "Universe ID",
				Value = tostring(game.GameId)
			},
			{
				Name = "Place version",
				Value = tostring(game.PlaceVersion)
			},
			{
				Name = "Server type",
				Value = GetServerType()
			}
		}

		if game.PrivateServerId ~= "" then
			table.insert(fields, {
				Name = "Private server ID",
				Value = game.PrivateServerId
			})
			table.insert(fields, {
				Name = "Private owner ID",
				Value = tostring(game.PrivateServerOwnerId)
			})
		end

		local v3 = {
			Name = "Runtime",
			Fields = {
				{
					Name = "Uptime",
					Value = FormatDuration(v)
				},
				{
					Name = "Players",
					Value = `{#Players:GetPlayers()} / {Players.MaxPlayers}`
				},
				{
					Name = "Studio",
					Value = RunService:IsStudio() and "Yes" or "No"
				}
			}
		}

		local function fn()
			return Stats:GetTotalMemoryUsageMb()
		end

		local success2, result2 = pcall(fn)
		local v5 = {
			Name = "Total memory",
			Value = (not success2 or type(result2) ~= "number") and "Unavailable" or string.format(
				`%.{1}f%s`,
				result2,
				" MB"
			)
		}

		local function fn2()
			return Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.LuaHeap)
		end

		local success3, result3 = pcall(fn2)
		local v6 = {
			Name = "Lua heap",
			Value = (not success3 or type(result3) ~= "number") and "Unavailable" or string.format(
				`%.{1}f%s`,
				result3,
				" MB"
			)
		}
		local success4, result4 = pcall(function()
			return workspace:GetRealPhysicsFPS()
		end)
		local v7 = {
			Name = "Physics FPS",
			Value = (not success4 or type(result4) ~= "number") and "Unavailable" or string.format(
				`%.{1}f%s`,
				result4,
				""
			)
		}

		local function fn3()
			return Stats.HeartbeatTime * 1000
		end

		local success5, result5 = pcall(fn3)
		local v8 = {
			Name = "Heartbeat",
			Value = (not success5 or type(result5) ~= "number") and "Unavailable" or string.format(
				`%.{2}f%s`,
				result5,
				" ms"
			)
		}

		local function fn4()
			return Stats.PhysicsStepTime * 1000
		end

		local success6, result6 = pcall(fn4)
		local v9 = {
			Name = "Physics step",
			Value = (not success6 or type(result6) ~= "number") and "Unavailable" or string.format(
				`%.{2}f%s`,
				result6,
				" ms"
			)
		}

		local function fn5()
			return Stats.DataReceiveKbps
		end

		local success7, result7 = pcall(fn5)
		local v10 = {
			Name = "Data received",
			Value = (not success7 or type(result7) ~= "number") and "Unavailable" or string.format(
				`%.{1}f%s`,
				result7,
				" Kbps"
			)
		}

		local function fn6()
			return Stats.DataSendKbps
		end

		local success8, result8 = pcall(fn6)
		local v11 = {
			Name = "Data sent",
			Value = (not success8 or type(result8) ~= "number") and "Unavailable" or string.format(
				`%.{1}f%s`,
				result8,
				" Kbps"
			)
		}

		local function fn7()
			return Stats.InstanceCount
		end

		local success9, result9 = pcall(fn7)
		local v12 = {
			Name = "Instances",
			Value = (not success9 or type(result9) ~= "number") and "Unavailable" or string.format(
				`%.{0}f%s`,
				result9,
				""
			)
		}

		local function fn8()
			return Stats.PrimitivesCount
		end

		local success10, result10 = pcall(fn8)
		local v13 = {
			Name = "Primitives",
			Value = (not success10 or type(result10) ~= "number") and "Unavailable" or string.format(
				`%.{0}f%s`,
				result10,
				""
			)
		}

		local function fn9()
			return Stats.MovingPrimitivesCount
		end

		local success11, result11 = pcall(fn9)
		return {
			{
				Name = "Identity",
				Fields = fields
			},
			v3,
			{
				Name = "Performance",
				Fields = {
					v5,
					v6,
					v7,
					v8,
					v9,
					v10,
					v11,
					v12,
					v13,
					{
						Name = "Moving primitives",
						Value = (not success11 or type(result11) ~= "number") and "Unavailable" or string.format(
							`%.{0}f%s`,
							result11,
							""
						)
					}
				}
			},
			{
				Name = "Live systems",
				Fields = ReadLiveSystems()
			}
		}
	end)
	return {
		Ok = success,
		Message = success and "" or tostring(result),
		Timestamp = now,
		StartedAt = now - math.floor(v),
		Sections = not success and {} or result
	}
end

local function ClearComponents(object)
	for _, v in object:GetAll() do
		v:Destroy()
	end
end

local function FormatCompactLocalTime(p: number, flag: boolean)
	local localTime = DateTime.fromUnixTimestamp(p):ToLocalTime()

	if flag then
		return string.format(
			"%02d/%02d/%02d %02d:%02d",
			localTime.Day,
			localTime.Month,
			localTime.Year % 100,
			localTime.Hour,
			localTime.Minute
		)
	end

	return string.format(
		"%02d/%02d %02d:%02d:%02d",
		localTime.Day,
		localTime.Month,
		localTime.Hour,
		localTime.Minute,
		localTime.Second
	)
end

local clientEvent = AdminRemote.RegisterClientEvent(
	"AdminMenu_ServerOverview_Get",
	"cui.dev.serverOverview",
	false,
	function()
		return (ReadOverview())
	end
)
return {
	DisplayName = "Server Stats",
	Permission = "cui.dev.serverOverview",
	Order = 5,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local count = 0
		local v = nil
		local v2 = nil
		local v3 = {
			["Job ID"] = true,
			["Private server ID"] = true,
			["Server bonuses"] = true,
			["Global bonuses"] = true
		}
		object:AddSplit(function(object2)
			object2:SetLeftSizePercent(0.56)
			v = object2.LeftComponents:AddField(function(object3)
				object3:SetTextVisible(false):SetValue("Start: loading..."):SetEnabled(false)
			end)
			v2 = object2.RightComponents:AddField(function(object3)
				object3:SetTextVisible(false):SetValue("Snap: loading..."):SetEnabled(false)
			end)
		end)
		local v4 = object:AddList(function(object2)
			object2:SetSizeY(264)
		end)

		local function Render(data)
			for _, v5 in v4.Components:GetAll() do
				v5:Destroy()
			end

			for _, section in data.Sections do
				local v5 = section
				v4.Components:AddTitle(function(object2)
					object2:SetTitle(v5.Name)
				end)
				local total = 1

				while total <= #section.Fields do
					local field = section.Fields[total]
					local field2 = section.Fields[total + 1]

					if v3[field.Name] or not field2 or v3[field2.Name] then
						local v6 = field
						v4.Components:AddField(function(object2)
							object2:SetText(v6.Name):SetValue(v6.Value):SetEnabled(false)
						end)
						total += 1
					else
						local v6 = field
						local v7 = field2
						v4.Components:AddSplit(function(p)
							p.LeftComponents:AddField(function(object2)
								object2:SetTextVisible(false):SetValue((`{v6.Name}: {v6.Value}`)):SetEnabled(false)
							end)
							p.RightComponents:AddField(function(object2)
								object2:SetTextVisible(false):SetValue((`{v7.Name}: {v7.Value}`)):SetEnabled(false)
							end)
						end)
						total += 2
					end
				end
			end
		end

		local function fn()
			if not clientEvent then
				return
			end

			count += 1
			local v5 = count
			clientEvent:Fire({}):andThen(function(data)
				if v5 ~= count or not data then
					return
				end

				if not data.Ok then
					NotificationSystem:ShowGeneralNotification(
						`Server overview failed: {data.Message}`,
						Color3.fromRGB(255, 100, 100),
						4
					)
					return
				end

				local v6 = v
				local startedAt = data.StartedAt
				local localTime = DateTime.fromUnixTimestamp(startedAt):ToLocalTime()
				v6:SetValue((`Start: {string.format(
					"%02d/%02d/%02d %02d:%02d",
					localTime.Day,
					localTime.Month,
					localTime.Year % 100,
					localTime.Hour,
					localTime.Minute
				)}`))
				local v7 = v2
				local timestamp = data.Timestamp
				local localTime2 = DateTime.fromUnixTimestamp(timestamp):ToLocalTime()
				v7:SetValue((`Snap: {string.format(
					"%02d/%02d %02d:%02d:%02d",
					localTime2.Day,
					localTime2.Month,
					localTime2.Hour,
					localTime2.Minute,
					localTime2.Second
				)}`))
				Render(data)
			end):catch(function(p)
				if v5 ~= count then
					return
				end

				NotificationSystem:ShowGeneralNotification(
					`Server overview request failed: {tostring(p)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		object:AddButton(function(object2)
			object2:SetButtonText("Refresh server snapshot"):SetYSize(22):SetEnabledPermission("cui.dev.serverOverview"):SetButtonCallback(fn)
		end)
		fn()
	end
}