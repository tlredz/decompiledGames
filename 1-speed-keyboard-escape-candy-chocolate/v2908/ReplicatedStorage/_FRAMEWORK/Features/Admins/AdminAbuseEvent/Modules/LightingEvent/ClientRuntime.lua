local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
require(script.Parent.Parent.Parent)
local SoundFade = require(ReplicatedStorage.Utilities.Events.SoundFade)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local KeycapVisuals = require(script.Parent.KeycapVisuals)
local StrikeEffects = require(script.Parent.StrikeEffects)
return {
	create = function(p)
		local folder = Instance.new("Folder")
		folder.Name = "LightingEventVisuals"
		folder.Parent = Workspace
		p.janitor:Add(folder)
		local v = KeycapVisuals.create(folder)
		local v2 = StrikeEffects.create(folder)
		local v3 = {}
		local v4 = {}
		local v5 = {}
		local v6 = {}
		local v7 = 0
		local v8 = nil
		local v9 = nil
		local v10 = nil
		local v11 = nil
		local flag = false
		local heartbeatConnection = nil

		local function playNextTrack()
			if not flag and v8 then
				local musicSoundId = Config.musicSoundIds[math.random(1, #Config.musicSoundIds)]

				if #Config.musicSoundIds > 1 then
					while musicSoundId == v10 do
						musicSoundId = Config.musicSoundIds[math.random(1, #Config.musicSoundIds)]
					end
				end

				v10 = musicSoundId
				v8.SoundId = musicSoundId
				v8.TimePosition = 0
				v8:Play()
				v9:fadeIn()
			end
		end

		local function burstAt(position: Vector3, color: Color3, flag2: boolean, p2: number)
			local currentCamera = Workspace.CurrentCamera

			if currentCamera and (currentCamera.CFrame.Position - position).Magnitude > Config.visualDistanceStuds then
				return
			end

			local part = Instance.new("Part")
			part.Name = flag2 and "SuperLightningRadius" or "LightningClaimBurst"
			part.Shape = Enum.PartType.Ball
			part.Size = flag2 and createVector(2, 2, 2) or createVector(1, 1, 1)
			part.Position = position
			part.Color = color
			part.Material = Enum.Material.Neon
			part.Transparency = flag2 and 0.42 or 0.15
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Parent = folder
			local v12 = flag2 and 1.1 or 0.32
			local v13 = not flag2 and 10 or Config.superStrikeRadiusStuds * 2
			local tween = TweenService:Create(
				part,
				TweenInfo.new(v12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(v13, v13, v13),
					Transparency = 1
				}
			)
			tween:Play()
			table.insert(v6, {
				part = part,
				tween = tween,
				expiresAt = p2 + v12 + 0.05
			})
		end

		local function impact(data, serverTimeNow: number)
			if data.isSuper then
				if serverTimeNow < data.impactAt + 1.1 then
					burstAt(
						(data.cframe * CFrame.new(0, data.size.Y / 2, 0)).Position,
						Config.superColor,
						true,
						serverTimeNow
					)
				end
			elseif not v5[data.id] and serverTimeNow < data.expiresAt then
				v.add(data)
			end
		end

		local function update()
			local serverTimeNow = Workspace:GetServerTimeNow()

			for k, v12 in v3 do
				if not (v12.impactAt <= serverTimeNow) then
					continue
				end

				v3[k] = nil
				impact(v12, serverTimeNow)
			end

			v2.update(serverTimeNow)
			v.update(serverTimeNow)

			for i = #v6, 1, -1 do
				local v12 = v6[i]

				if not (v12.expiresAt <= serverTimeNow) then
					continue
				end

				v12.tween:Cancel()
				v12.part:Destroy()
				table.remove(v6, i)
			end

			if v7 <= serverTimeNow then
				v7 = serverTimeNow + Config.keycapCheckIntervalSeconds

				for k, v12 in v4 do
					if v12 <= serverTimeNow then
						v4[k] = nil
					end
				end

				for k, v12 in v5 do
					if v12 <= serverTimeNow then
						v5[k] = nil
					end
				end
			end
		end

		local function stop()
			if not flag then
				flag = true

				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end

				v.destroy()
				v2.destroy()

				for _, v12 in v6 do
					v12.tween:Cancel()
					v12.part:Destroy()
				end

				table.clear(v6)
				table.clear(v3)
				table.clear(v4)
				table.clear(v5)

				if v9 then
					v9:cancel()
				end

				if v8 then
					v8:Stop()
				end
			end
		end

		p.janitor:Add(stop)
		return {
			onStart = function()
				local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
				v11 = NotificationSystem

				if #Config.musicSoundIds > 0 then
					local sound = Instance.new("Sound")
					sound.Name = "LightingEventMusic"
					sound.Volume = 0
					sound.Looped = false
					sound:SetAttribute("IsEventSound", true)
					sound.Parent = SoundService
					v8 = sound
					v9 = SoundFade.new(sound, {
						fadeIn = 0.5,
						fadeOut = 1,
						volume = Config.musicVolume
					})
					p.janitor:Add(sound.Ended:Connect(playNextTrack))
					p.janitor:Add(sound)
					playNextTrack()
				end

				heartbeatConnection = RunService.Heartbeat:Connect(update)
				p.janitor:Add(heartbeatConnection)
			end,
			onServerEvent = function(data)
				if flag then
					return
				end

				local serverTimeNow = Workspace:GetServerTimeNow()

				if data.kind == "claim" then
					v5[data.id] = serverTimeNow + Config.electrifiedDurationSeconds + Config.strikeWarningSeconds

					if not data.isSuper then
						v3[data.id] = nil
						v.remove(data.id)
					end

					burstAt(data.cframe.Position, data.color, false, serverTimeNow)
					local v12

					if data.isSuper then
						v12 = `SUPER LIGHTNING! +x{data.chargeCount} XP! Event XP x{data.multiplier}`
					else
						v12 = `+x{data.chargeCount} XP! Event XP x{data.multiplier}`
					end

					v11:ShowGeneralNotification(v12, data.color, data.isSuper and 3.5 or 2.5)
				elseif not v4[data.id] and serverTimeNow < data.expiresAt then
					v4[data.id] = data.expiresAt

					if data.kind == "strike" then
						v2.strike(data, serverTimeNow)
					end

					if data.impactAt <= serverTimeNow then
						impact(data, serverTimeNow)
					else
						v3[data.id] = data
					end
				end
			end,
			onStop = stop
		}
	end
}