return {
	ARREST_RANGE = 10,
	REQUEST_TIMEOUT = 10,
	REQUEST_DEBOUNCE = 2,
	SCAN_INTERVAL = 0.2,
	BUSY_TAG_NAME = "ClientToClient",
	WELD_NAME = "HandcuffsWeld",
	PROMPT_TEXT = "Arrest",
	PROMPT_NAME = "HandcuffsArrestPrompt",
	ESCORT_OFFSET = CFrame.new(1, 0, -2),
	ESCORT_WALK_SPEED_THRESHOLD = 0.5,
	ANIM_FADE_TIME = 0.5,
	VICTIM_CUFFS_TEMPLATE_NAME = "Handcuffs",
	LEFT_RING_NAME = "Handle",
	RIGHT_RING_NAME = "Cuff",
	DANGLING_MANAGED_ATTR = "DanglingToolManaged",
	DANGLING_SIM_PART_ATTR = "DanglingSimPart",
	STAY_INVISIBLE_ATTR = "HandcuffsStayInvisible",
	LEFT_RING_OFFSET = CFrame.Angles(1.5707963267948966, 3.141592653589793, 0),
	RIGHT_RING_OFFSET = CFrame.Angles(1.5707963267948966, 0, 0),
	GetRequestText = function(p)
		return (`{p.DisplayName} wants to handcuff you`)
	end
}