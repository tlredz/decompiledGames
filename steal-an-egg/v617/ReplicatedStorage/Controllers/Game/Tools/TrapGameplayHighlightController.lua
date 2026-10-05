local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
local Player = require(ReplicatedStorage.Shared.Player)
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 255, 255)
local PLACED_TRAP = Constants.TAGS_MAP.Traps.PLACED_TRAP
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		local world = Workspace.World
		assert(world:IsA("Folder"), "Workspace.World must be a Folder")
		local areas = world.Areas
		assert(areas:IsA("Folder"), "Workspace.World.Areas must be a Folder")
		local separationLine = areas.SeparationLine
		assert(separationLine:IsA("BasePart"), "Workspace.World.Areas.SeparationLine must be a BasePart")
		local v = {}
		local v2 = nil
		local v3 = false

		local function getOrCreateState(p)
			local v4 = v[p]

			if v4 then
				return v4
			end

			local v5 = {
				Highlight = nil,
				Tween = nil,
				FadeOutVersion = 0
			}
			v[p] = v5
			return v5
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancelTween(p)
			local tween = p.Tween

			if tween then
				p.Tween = nil
				tween:Cancel()
			end
		end

		local function isOwnedTrap(instance)
			return instance:GetAttribute("Owner") == localPlayer.Name
		end

		local function showTrapHighlight(instance)
			if instance:GetAttribute("Owner") ~= localPlayer.Name then
				return
			end

			local v4 = v[instance]

			if not v4 then
				v4 = {
					Highlight = nil,
					Tween = nil,
					FadeOutVersion = 0
				}
				v[instance] = v4
			end

			v4.FadeOutVersion += 1
			cancelTween(v4) -- equivalent call inferred; original call site unknown
			local highlight = instance:FindFirstChild("TrapGameplayHighlight")

			if not (highlight and highlight:IsA("Highlight")) then
				highlight = Instance.new("Highlight")
				highlight.Name = "TrapGameplayHighlight"
				highlight.Parent = instance
			end

			highlight.Adornee = instance
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = color
			highlight.FillTransparency = 1
			highlight.OutlineColor = color
			highlight.OutlineTransparency = 1
			v4.Highlight = highlight
			local tween = TweenService:Create(highlight, tweenInfo, {
				OutlineTransparency = 0.3
			})
			v4.Tween = tween
			tween:Play()
		end

		local function hideTrapHighlight(p)
			local v4 = v[p]

			if not v4 then
				return
			end

			local highlight = v4.Highlight

			if not highlight then
				return
			end

			v4.FadeOutVersion += 1
			local fadeOutVersion = v4.FadeOutVersion
			cancelTween(v4) -- equivalent call inferred; original call site unknown
			local tween = TweenService:Create(highlight, tweenInfo, {
				OutlineTransparency = 1
			})
			tween:Play()
			v4.Tween = tween
			tween.Completed:Once(function(p2)
				if p2 ~= Enum.PlaybackState.Completed or v4.FadeOutVersion ~= fadeOutVersion then
					return
				end

				if highlight.Parent then
					highlight:Destroy()
				end

				v4.Highlight = nil
				v4.Tween = nil
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTrapHighlightsVisible(flag: boolean)
			for k in pairs(v) do
				if flag then
					showTrapHighlight(k)
				else
					hideTrapHighlight(k)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cleanupTrap(p)
			local v4 = v[p]

			if not v4 then
				return
			end

			cancelTween(v4) -- equivalent call inferred; original call site unknown
			local highlight = v4.Highlight

			if highlight and highlight.Parent then
				highlight:Destroy()
			end

			v[p] = nil
		end

		local function trackTrap(part)
			if not (part:IsA("BasePart") and part:GetAttribute("Owner") == localPlayer.Name) then
				return
			end

			if not v[part] then
				v[part] = {
					Highlight = nil,
					Tween = nil,
					FadeOutVersion = 0
				}
			end

			if v3 then
				showTrapHighlight(part)
			end

			part.Destroying:Once(function()
				cleanupTrap(part) -- equivalent call inferred; original call site unknown
			end)
		end

		local function untrackTrap(part)
			if not part:IsA("BasePart") then
				return
			end

			if v3 then
				hideTrapHighlight(part)
				return
			end

			cleanupTrap(part) -- equivalent call inferred; original call site unknown
		end

		for _, v4 in ipairs(CollectionService:GetTagged(PLACED_TRAP)) do
			trackTrap(v4)
		end

		CollectionService:GetInstanceAddedSignal(PLACED_TRAP):Connect(trackTrap)
		CollectionService:GetInstanceRemovedSignal(PLACED_TRAP):Connect(untrackTrap)
		RunService.PreRender:Connect(function()
			local part = Player.FindRootPart(localPlayer)

			if part == nil or not part:IsA("BasePart") then
				return
			end

			local position = part.Position
			local v4 = v2
			v2 = position

			if v4 == nil then
				v3 = GuardAreaGeometry.IsPastLine(separationLine, position)

				if v3 then
					setTrapHighlightsVisible(true) -- equivalent call inferred; original call site unknown
				end
			elseif GuardAreaGeometry.CrossedLineInward(separationLine, v4, position) then
				v3 = true
				setTrapHighlightsVisible(true) -- equivalent call inferred; original call site unknown
			elseif GuardAreaGeometry.CrossedLineOutward(separationLine, v4, position) then
				v3 = false
				setTrapHighlightsVisible(false) -- equivalent call inferred; original call site unknown
			end
		end)
	end
}