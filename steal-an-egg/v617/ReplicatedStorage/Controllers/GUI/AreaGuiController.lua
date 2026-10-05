local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AreaNotificationTracker = require(script.Parent.Parent.Game.GuardAreasController.AreaNotificationTracker)
require(ReplicatedStorage.Data.Areas)
local GUI = require(ReplicatedStorage.Client.GUI)
local SwapGradient = require(ReplicatedStorage.Shared.Utils.SwapGradient)
local GuiTransitionGroup = require(ReplicatedStorage.Client.UI.VFX.GuiTransitionGroup)
local SubBiomeCycle = require(ReplicatedStorage.Shared.Util.SubBiomeCycle)
local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
return {
	Start = function()
		local areaGui = GUI.AreaGui()
		local frame = areaGui.Frame
		local main = frame.Texts.Main
		local emoji = frame.Texts.Emoji
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = 22
		local count = 0
		local v2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyAreaGradient(p, active)
			local gradient

			if active ~= nil then
				gradient = active.Gradient
			end

			if gradient == nil then
				SwapGradient(main, p.Rarity.RarityGradient)
				return
			end

			uIGradient.Color = gradient
			SwapGradient(main, uIGradient)
		end

		local function renderArea(p, p2: string)
			local active = SubBiomeCycle.Active(p2)

			if active == nil then
				main.Text = `{p.DisplayName}`
				emoji.Text = `{p.Emoji}`
			else
				main.Text = `{active.DisplayName}`
				emoji.Text = `{active.Emoji or p.Emoji}`
			end

			applyAreaGradient(p, active) -- equivalent call inferred; original call site unknown
		end

		local function showArea(p, p2: string)
			count += 1
			local v3 = count

			if workspace:GetAttribute("Event_DragonEggEvent") then
				return
			end

			local v4 = v2
			assert(v4 ~= nil, "AreaGui transition group must be initialized before show")
			v4:Halt()
			renderArea(p, p2)
			v4:SnapHidden()
			areaGui.Enabled = true
			v4:Reveal(tweenInfo)
			task.delay(1, function()
				if v3 ~= count then
					return
				end

				v4:Halt()
				v4:Conceal(tweenInfo2)
				task.delay(tweenInfo2.Time, function()
					if v3 ~= count then
						return
					end

					areaGui.Enabled = false
					v4:Rehome()
				end)
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function start()
			v2 = GuiTransitionGroup.new(areaGui, areaGui, 0.02)
			areaGui.Enabled = false
			AreaNotificationTracker.Start(showArea)
		end

		;({
			Start = function()
				start() -- equivalent call inferred; original call site unknown
			end
		}).Start()
	end
}