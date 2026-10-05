local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local expressions = {
	Happy = { "Mouth_Grin", "R_hapy_blink", "L_hapy_blink" },
	Reset = {
		"Mouth_Confused",
		"L_blink",
		"R_blink",
		"L_eyebrow_angryLong"
	},
	Normal = {
		"L_Big_iris",
		"L_eyeball",
		"R_Big_iris",
		"R_eyeball",
		"Mouth_Grin"
	},
	NormalBlink = { "L_blink", "R_blink", "Mouth_Grin" },
	SlightlyAngry = {
		"Mouth_Smile",
		"L_eyeball",
		"R_eyeball",
		"L_Big_iris",
		"R_Big_iris",
		"L_eyebrow_confused",
		"R_eyebrow_confused"
	},
	SlightlyAngryBlink = {
		"Mouth_Smile",
		"L_blink",
		"R_blink",
		"L_eyebrow_confused",
		"R_eyebrow_confused"
	},
	Angry = {
		"Mouth_Cute",
		"L_angy_eyeball",
		"L_angry_iris",
		"L_eyeRedDot",
		"R_angy_eyeball",
		"R_angry_iris",
		"R_eyeRedDot",
		"L_eyebrow_angry",
		"R_eyebrow_angry"
	},
	Angry_Blink = {
		"Mouth_Cute",
		"L_blink",
		"Nose_Shadow",
		"R_blink",
		"R_eyebrow_confused"
	},
	Worried = {
		"Mouth_Confused",
		"L_eyeball",
		"L_Big_iris",
		"R_eyeball",
		"R_Big_iris",
		"L_eyebrow_confused",
		"R_eyebrow_confused"
	},
	WorriedBlink = {
		"Mouth_Confused",
		"L_blink",
		"R_blink",
		"L_eyebrow_confused",
		"R_eyebrow_confused"
	},
	HappyGossip = {
		"Mouth_Grin",
		"L_eyelid",
		"R_eyelid",
		"L_eyeball",
		"R_eyeball",
		"L_Big_iris",
		"R_Big_iris"
	},
	SadGossip = {
		"Mouth_Grin",
		"L_eyelid",
		"R_eyelid",
		"L_eyeball",
		"R_eyeball",
		"L_Big_iris",
		"R_Big_iris",
		"L_sad_eyebrow"
	},
	Smile = {
		"Mouth_Smile",
		"L_eyeball",
		"R_eyeball",
		"L_Big_iris",
		"R_Big_iris"
	},
	SmileBlink = { "Mouth_Smile", "L_blink", "R_blink" },
	Annoyed = {
		"Mouth_Confused",
		"L_angy_eyeball",
		"R_angy_eyeball",
		"L_angry_iris",
		"R_angry_iris",
		"L_eyebrow_confused",
		"R_eyebrow_confused"
	},
	AnnoyedBlink = {
		"Mouth_Confused",
		"L_blink",
		"R_blink",
		"L_eyebrow_confused",
		"R_eyebrow_confused"
	},
	Intrigued = {
		"Mouth_Confused",
		"L_eyeball",
		"R_eyeball",
		"L_Big_iris",
		"R_Big_iris"
	},
	IntriguedBlink = { "Mouth_Confused", "L_hapy_blink", "R_hapy_blink" }
}
expressions.AngryBlink = expressions.Angry_Blink
local FacialExpressions = {
	Expressions = expressions
}
local v2 = {
	SlightlyAngry = true,
	Worried = true,
	Happy = true
}
local heldBrowPoses = {
	DF_eyebrows_1_L = CFrame.new(0, 0.266506, 0.147925, 1, 0, 0, 0, 0.971162, -0.238419, 0, 0.238419, 0.971162),
	DF_eyebrows_1_R = CFrame.new(
		-0.000403,
		0.112882,
		0.050024,
		0.999997,
		0.000752,
		-0.002203,
		-0.000953,
		0.995717,
		-0.092449,
		0.002124,
		0.092451,
		0.995715
	)
}
local v4 = {
	SlightlyAngry = true,
	Worried = true
}
FacialExpressions.HeldBrowPoses = heldBrowPoses

local function blinkOf(p)
	local v5 = p .. "Blink"

	if expressions[v5] then
		p = v5 or p
	end

	return p
end

function FacialExpressions.Setup(_, object, folder)
	local partsByName = {}

	local function scan(folder2)
		for _, part in pairs(folder2:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			if partsByName[part.Name] then
				warn("[FacialExpressions] face parts " .. partsByName[part.Name]:GetFullName() .. " and " .. part:GetFullName() .. " share a name; only the first is driven")
			else
				partsByName[part.Name] = part
			end
		end
	end

	scan(folder:WaitForChild("Face"))
	local v5 = {}

	for k, v6 in pairs(expressions) do
		local count = 0

		for _, v7 in v6 do
			if partsByName[v7] then
				count += 1
			else
				warn("[FacialExpressions] " .. folder:GetFullName() .. " expression " .. k .. " names face part " .. v7 .. ", which is not under Face")
			end
		end

		v5[k] = count
	end

	local v6 = nil

	local function express(p)
		if v5[p] == 0 then
			return
		end

		local v7 = expressions[p]
		v6 = p

		for k, v8 in pairs(partsByName) do
			v8.Transparency = table.find(v7, k) and 0 or 1
		end
	end

	if v5.Normal == 0 then
		warn("[FacialExpressions] " .. folder:GetFullName() .. " has none of Normal's face parts; its face is left as authored")
	end

	express("Normal")
	local v7 = {}
	local v8 = {}

	local function browBone(k)
		local v9 = v7[k]

		if v9 and v9.bone.Parent then
			return v9
		end

		for _, bone in folder:GetDescendants() do
			if not (bone:IsA("Bone") and bone.Name == k) then
				continue
			end

			local v10 = {
				bone = bone,
				rest = bone.CFrame
			}
			v7[k] = v10
			return v10
		end

		if not v8[k] then
			v8[k] = true
			warn("[FacialExpressions] " .. folder:GetFullName() .. " has no bone " .. k .. "; the held faces keep the clips' brow pose")
		end

		return nil
	end

	local v9 = false

	local function raiseBrows(p)
		if p == v9 then
			return
		end

		v9 = p

		for k, v10 in pairs(heldBrowPoses) do
			local v11 = browBone(k)

			if v11 then
				v11.bone.CFrame = p and v11.rest * v10 or v11.rest
			end
		end
	end

	local v10 = nil

	local function applyStateFace()
		local facialExpression = folder:GetAttribute("FacialExpression")
		local v11 = expressions[facialExpression] ~= nil

		if facialExpression ~= nil and not v11 then
			warn("[FacialExpressions] unknown FacialExpression attribute: " .. tostring(facialExpression))
		end

		local v12

		if v11 and v2[facialExpression] and facialExpression then
			v12 = facialExpression
		end

		v10 = v12
		raiseBrows(v10 ~= nil and v4[v10] == true)

		if v11 then
			express(facialExpression)
		end
	end

	folder:GetAttributeChangedSignal("FacialExpression"):Connect(applyStateFace)
	applyStateFace()
	local v11 = nil

	local function applyBlink()
		if folder:GetAttribute("FacialBlink") == true then
			local v12 = v10 or v6

			if v12 then
				local v13 = v12 .. "Blink"
				local v14

				if expressions[v13] then
					v14 = v13 or v12
				else
					v14 = v12
				end

				if v14 ~= v12 then
					v11 = v12
					local v16 = v12 .. "Blink"

					if expressions[v16] then
						v12 = v16 or v12
					end

					express(v12)
				end
			end
		elseif v11 then
			local v12 = v11
			v11 = nil
			local v13 = v6
			local v14 = v12 .. "Blink"
			local v15

			if expressions[v14] then
				v15 = v14 or v12
			else
				v15 = v12
			end

			if v13 == v15 then
				express(v10 or v12)
			end
		end
	end

	folder:GetAttributeChangedSignal("FacialBlink"):Connect(applyBlink)

	local function getAllAnimationEventNames(p: string)
		local keyframeMarkers = {}
		local recurse

		recurse = function(instance)
			for _, keyframeMarker in pairs(instance:GetChildren()) do
				if keyframeMarker:IsA("KeyframeMarker") then
					table.insert(keyframeMarkers, keyframeMarker)
				end

				if #keyframeMarker:GetChildren() > 0 then
					recurse(keyframeMarker)
				end
			end
		end

		recurse((KeyframeSequenceProvider:GetKeyframeSequenceAsync(p)))
		return keyframeMarkers
	end

	object.AnimationPlayed:Connect(function(object2)
		local connections = {}
		connections[#connections + 1] = object2:GetMarkerReachedSignal("Expression"):Connect(function(value)
			local playingAnimationTracks = object:GetPlayingAnimationTracks()

			if #playingAnimationTracks == 0 then
				return
			end

			table.sort(playingAnimationTracks, function(a, b)
				return a.Priority.Value > b.Priority.Value
			end)

			if playingAnimationTracks[1] ~= object2 then
				return
			end

			if not expressions[value] then
				warn("[FacialExpressions] unknown Expression marker: " .. tostring(value))
				return
			end

			if not v10 then
				express(value)
				return
			end

			local v14

			if string.sub(value, -5) == "Blink" then
				v14 = v10
				local v15 = v14 .. "Blink"

				if expressions[v15] then
					v14 = v15 or v14
				end

				if not v14 then
					v14 = v10
				end
			else
				v14 = v10
			end

			express(v14)
		end)
		connections[#connections + 1] = object2.Ended:Connect(function()
			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)
		end)
	end)
end

return FacialExpressions