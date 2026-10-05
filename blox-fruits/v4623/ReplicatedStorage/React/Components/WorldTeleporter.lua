local SoundService = game:GetService("SoundService")
local React = require(game.ReplicatedStorage.Packages.React)
local Spring = require(game.ReplicatedStorage.Packages.Spring)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local Audio = require(game.ReplicatedStorage.Audio)
local Core = require(script.Core)
local RingLayout = require(script.RingLayout)
local Border = require(script.Border)
local Celebration = require(script.Celebration)
local DebugLabel = require(script.DebugLabel)
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local Theme = require(game.ReplicatedStorage.React.Contexts.WorldTeleporter.Theme)
local useTeleportable = require(game.ReplicatedStorage.React.Hooks.Island.useTeleportable)
local useAll = require(game.ReplicatedStorage.React.Hooks.Island.useAll)
local useSpringEffect = require(game.ReplicatedStorage.React.Hooks.Animation.useSpringEffect)
local useFlood = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useFlood)
local useCollapse = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useCollapse)
local useSoundLoudness = require(game.ReplicatedStorage.React.Hooks.Animation.useSoundLoudness)
local useThemeTransition = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useThemeTransition)
local usePuzzle = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.usePuzzle)
require(script.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(script.CONSTANTS)
local CELEBRATION = CONSTANTS2.CELEBRATION
local v = {
	SoundId = "rbxassetid://9165268097",
	Volume = 1,
	Scale = 0.00125,
	Decay = 6,
	Tempo = nil,
	Looped = true,
	FadeOut = 3
}
local createElement = React.createElement

local function getIfEveryIslandUnlocked(items, list)
	if #list == 0 then
		return false
	end

	local v2 = {}

	for _, v3 in list do
		v2[v3.Index.Key] = true
	end

	for _, item in items do
		if not (table.find(item.Tags, "GatewayBlocked") or table.find(item.Tags, "NavigationBlocked") or v2[item.Index.Key]) then
			return false
		end
	end

	return true
end

return function(props)
	local v2 = useTeleportable()
	local v3 = useAll()
	local islands = React.useMemo(function()
		local clone = table.clone(v2)
		table.sort(clone, function(a, b)
			return Map.getMinimumLevel(a) < Map.getMinimumLevel(b)
		end)
		return table.freeze(clone)
	end, { v2 })
	local isEveryIslandUnlocked = React.useMemo(function()
		return (getIfEveryIslandUnlocked(v3, v2))
	end, { v3, v2 })
	local v6

	if props.OnCelebrationComplete == nil then
		v6 = false
	else
		v6 = isEveryIslandUnlocked
	end

	local puzzle = usePuzzle(islands, v6, props.OnPuzzleComplete)
	local state, setState = React.useState(nil)
	local hasDoubleRing = #islands > CONSTANTS2.MID_RING_LIMIT
	local v9 = state ~= nil or puzzle.IsSolved
	local state2, setState2 = React.useState(props.IsOpen and "Default" or "Offscreen")
	local v10 = useThemeTransition(
		puzzle.IsSolved and CONSTANTS2.GOLDEN_THEME or puzzle.Theme or props.Theme or CONSTANTS2.DEFAULT_THEME,
		state2 ~= "Offscreen"
	)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local collapse, onHoldComplete = useCollapse(puzzle.IsSolved, props.OnCelebrationComplete)
	local v13 = useFlood(ref, puzzle.IsSolved, collapse)
	local v14 = puzzle.IsSolved and collapse < 1
	local v16

	if puzzle.IsSolved and not (collapse >= 1) then
		v16 = v
	end

	local pulse = useSoundLoudness(v16, puzzle.IsSolved and collapse < 1)
	local viewport = v13.Viewport
	local isOpen = props.IsOpen
	local ref3 = React.useRef(isOpen)
	ref3.current = isOpen
	useSpringEffect(isOpen and 1 or 0, Spring.new(0.85, 1.25, 0), true, function(p: number, _: number)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function fade(current)
			if current then
				current.Visible = p > 0
				current.GroupTransparency = 1 - p
			end
		end

		fade(ref.current) -- equivalent call inferred; original call site unknown
		fade(ref2.current) -- equivalent call inferred; original call site unknown
	end, function()
		setState2("Moving")
	end, function()
		setState2(ref3.current and "Default" or "Offscreen")
	end)
	local provider = Theme.Provider
	local mergeCanvasGroup = RobloxTypes.mergeCanvasGroup({
		ref = ref,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = v13.Size,
		Position = v13.Position,
		AnchorPoint = v13.AnchorPoint
	}, props)
	local v30 = {
		BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
		BackgroundColor3 = v10.Background:Lerp(v10.Primary, 0.5 + 0.5 * v13.Alpha),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Size = UDim2.fromScale(CONSTANTS2.BACKGROUND_SCALE, CONSTANTS2.BACKGROUND_SCALE),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5)
	}

	if viewport then
		viewport = createElement(Celebration, {
			GroupRef = ref2,
			IsPlaying = v13.Alpha >= 1 and collapse < 1,
			Pulse = pulse,
			Collapse = collapse,
			OnHoldComplete = onHoldComplete,
			Title = props.CompletionTitle or CELEBRATION.TITLE,
			Subtitle = CELEBRATION.SUBTITLE,
			Islands = islands,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = viewport.Size,
			ZIndex = 30
		})
	end

	return createElement(DrawContextProvider, {
		Context = state2
	}, {
		Theme = createElement(provider, {
			value = v10
		}, {
			Gateway = createElement("CanvasGroup", mergeCanvasGroup, {
				Background = createElement("Frame", v30, {
					Celebration = viewport,
					Core = createElement(Core, {
						OnClick = state and not v14 and function()
							if v14 then
								return
							end

							props.OnSelect(state)
						end or nil,
						IsSolved = puzzle.IsSolved,
						HasDoubleRing = hasDoubleRing,
						SelectedIsland = state,
						IsNameVisible = not puzzle.IsSolved,
						IsActive = v9,
						Pulse = pulse
					}),
					Rings = createElement(RingLayout, {
						Islands = puzzle.Orbit,
						Centered = state,
						IsExpanded = v9,
						OnSelect = function(p)
							if v14 then
								return
							end

							local ascendingtone = Audio.fx["world-teleporter"]["ascending-tones"][`{math.clamp(#puzzle.Chain + 1, 1, 12)}.ogg`]

							if ascendingtone then
								local sound = Instance.new("Sound")
								sound.SoundId = ascendingtone
								sound.PlayOnRemove = true
								sound.Parent = SoundService
								sound:Destroy()
							end

							puzzle.Select(p)
							setState(p)
						end
					}),
					UICorner = createElement("UICorner", {
						CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
					}),
					Border = createElement(Border, {}),
					UIAspectRatio = createElement("UIAspectRatioConstraint", {
						AspectRatio = 1
					})
				}),
				Debug = props.IsDebug and createElement(DebugLabel, {
					Puzzle = puzzle,
					IsEveryIslandUnlocked = isEveryIslandUnlocked,
					TotalCount = #islands
				})
			})
		})
	})
end