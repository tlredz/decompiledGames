local enum = Enum
local v = ""
local Enums = {}

local function a(p: string, p2: number)
	pcall(function()
		local v2 = enum[v]
		local v3 = v2 and v2[p]

		if v3 then
			Enums[v3] = p2
		end
	end)
end

local function s(p: string)
	v = p
end

v = "AccessModifierType"
local v2 = "Allow"
local v3 = 0
pcall(function()
	local v4 = enum[v]
	local v5 = v4 and v4[v2]

	if v5 then
		Enums[v5] = v3
	end
end)
local v4 = "Deny"
local v5 = 1
pcall(function()
	local v6 = enum[v]
	local v7 = v6 and v6[v4]

	if v7 then
		Enums[v7] = v5
	end
end)
v = "AccessoryType"
local v6 = "Unknown"
local v7 = 2
pcall(function()
	local v8 = enum[v]
	local v9 = v8 and v8[v6]

	if v9 then
		Enums[v9] = v7
	end
end)
local v8 = "Hat"
local v9 = 3
pcall(function()
	local v10 = enum[v]
	local v11 = v10 and v10[v8]

	if v11 then
		Enums[v11] = v9
	end
end)
local v10 = "Hair"
local v11 = 4
pcall(function()
	local v12 = enum[v]
	local v13 = v12 and v12[v10]

	if v13 then
		Enums[v13] = v11
	end
end)
local v12 = "Face"
local v13 = 5
pcall(function()
	local v14 = enum[v]
	local v15 = v14 and v14[v12]

	if v15 then
		Enums[v15] = v13
	end
end)
local v14 = "Neck"
local v15 = 6
pcall(function()
	local v16 = enum[v]
	local v17 = v16 and v16[v14]

	if v17 then
		Enums[v17] = v15
	end
end)
local v16 = "Shoulder"
local v17 = 7
pcall(function()
	local v18 = enum[v]
	local v19 = v18 and v18[v16]

	if v19 then
		Enums[v19] = v17
	end
end)
local v18 = "Front"
local v19 = 8
pcall(function()
	local v20 = enum[v]
	local v21 = v20 and v20[v18]

	if v21 then
		Enums[v21] = v19
	end
end)
local v20 = "Back"
local v21 = 9
pcall(function()
	local v22 = enum[v]
	local v23 = v22 and v22[v20]

	if v23 then
		Enums[v23] = v21
	end
end)
local v22 = "Waist"
local v23 = 10
pcall(function()
	local v24 = enum[v]
	local v25 = v24 and v24[v22]

	if v25 then
		Enums[v25] = v23
	end
end)
local v24 = "TShirt"
local v25 = 11
pcall(function()
	local v26 = enum[v]
	local v27 = v26 and v26[v24]

	if v27 then
		Enums[v27] = v25
	end
end)
local v26 = "Shirt"
local v27 = 12
pcall(function()
	local v28 = enum[v]
	local v29 = v28 and v28[v26]

	if v29 then
		Enums[v29] = v27
	end
end)
local v28 = "Pants"
local v29 = 13
pcall(function()
	local v30 = enum[v]
	local v31 = v30 and v30[v28]

	if v31 then
		Enums[v31] = v29
	end
end)
local v30 = "Jacket"
local v31 = 14
pcall(function()
	local v32 = enum[v]
	local v33 = v32 and v32[v30]

	if v33 then
		Enums[v33] = v31
	end
end)
local v32 = "Sweater"
local v33 = 15
pcall(function()
	local v34 = enum[v]
	local v35 = v34 and v34[v32]

	if v35 then
		Enums[v35] = v33
	end
end)
local v34 = "Shorts"
local v35 = 16
pcall(function()
	local v36 = enum[v]
	local v37 = v36 and v36[v34]

	if v37 then
		Enums[v37] = v35
	end
end)
local v36 = "LeftShoe"
local v37 = 17
pcall(function()
	local v38 = enum[v]
	local v39 = v38 and v38[v36]

	if v39 then
		Enums[v39] = v37
	end
end)
local v38 = "RightShoe"
local v39 = 18
pcall(function()
	local v40 = enum[v]
	local v41 = v40 and v40[v38]

	if v41 then
		Enums[v41] = v39
	end
end)
local v40 = "DressSkirt"
local v41 = 19
pcall(function()
	local v42 = enum[v]
	local v43 = v42 and v42[v40]

	if v43 then
		Enums[v43] = v41
	end
end)
local v42 = "Eyebrow"
local v43 = 20
pcall(function()
	local v44 = enum[v]
	local v45 = v44 and v44[v42]

	if v45 then
		Enums[v45] = v43
	end
end)
local v44 = "Eyelash"
local v45 = 21
pcall(function()
	local v46 = enum[v]
	local v47 = v46 and v46[v44]

	if v47 then
		Enums[v47] = v45
	end
end)
v = "ActionOnAutoResumeSync"
local v46 = "DontResume"
local v47 = 22
pcall(function()
	local v48 = enum[v]
	local v49 = v48 and v48[v46]

	if v49 then
		Enums[v49] = v47
	end
end)
local v48 = "KeepStudio"
local v49 = 23
pcall(function()
	local v50 = enum[v]
	local v51 = v50 and v50[v48]

	if v51 then
		Enums[v51] = v49
	end
end)
local v50 = "KeepLocal"
local v51 = 24
pcall(function()
	local v52 = enum[v]
	local v53 = v52 and v52[v50]

	if v53 then
		Enums[v53] = v51
	end
end)
v = "ActionOnStopSync"
local v52 = "AlwaysAsk"
local v53 = 25
pcall(function()
	local v54 = enum[v]
	local v55 = v54 and v54[v52]

	if v55 then
		Enums[v55] = v53
	end
end)
local v54 = "KeepLocalFiles"
local v55 = 26
pcall(function()
	local v56 = enum[v]
	local v57 = v56 and v56[v54]

	if v57 then
		Enums[v57] = v55
	end
end)
local v56 = "DeleteLocalFiles"
local v57 = 27
pcall(function()
	local v58 = enum[v]
	local v59 = v58 and v58[v56]

	if v59 then
		Enums[v59] = v57
	end
end)
v = "ActionType"
local v58 = "Nothing"
local v59 = 28
pcall(function()
	local v60 = enum[v]
	local v61 = v60 and v60[v58]

	if v61 then
		Enums[v61] = v59
	end
end)
local v60 = "Pause"
local v61 = 29
pcall(function()
	local v62 = enum[v]
	local v63 = v62 and v62[v60]

	if v63 then
		Enums[v63] = v61
	end
end)
local v62 = "Lose"
local v63 = 30
pcall(function()
	local v64 = enum[v]
	local v65 = v64 and v64[v62]

	if v65 then
		Enums[v65] = v63
	end
end)
local v64 = "Draw"
local v65 = 31
pcall(function()
	local v66 = enum[v]
	local v67 = v66 and v66[v64]

	if v67 then
		Enums[v67] = v65
	end
end)
local v66 = "Win"
local v67 = 32
pcall(function()
	local v68 = enum[v]
	local v69 = v68 and v68[v66]

	if v69 then
		Enums[v69] = v67
	end
end)
v = "ActuatorRelativeTo"
local v68 = "Attachment0"
local v69 = 33
pcall(function()
	local v70 = enum[v]
	local v71 = v70 and v70[v68]

	if v71 then
		Enums[v71] = v69
	end
end)
local v70 = "Attachment1"
local v71 = 34
pcall(function()
	local v72 = enum[v]
	local v73 = v72 and v72[v70]

	if v73 then
		Enums[v73] = v71
	end
end)
local v72 = "World"
local v73 = 35
pcall(function()
	local v74 = enum[v]
	local v75 = v74 and v74[v72]

	if v75 then
		Enums[v75] = v73
	end
end)
v = "ActuatorType"
local v74 = "None"
local v75 = 36
pcall(function()
	local v76 = enum[v]
	local v77 = v76 and v76[v74]

	if v77 then
		Enums[v77] = v75
	end
end)
local v76 = "Motor"
local v77 = 37
pcall(function()
	local v78 = enum[v]
	local v79 = v78 and v78[v76]

	if v79 then
		Enums[v79] = v77
	end
end)
local v78 = "Servo"
local v79 = 38
pcall(function()
	local v80 = enum[v]
	local v81 = v80 and v80[v78]

	if v81 then
		Enums[v81] = v79
	end
end)
v = "AdAvailabilityResult"
local v80 = "IsAvailable"
local v81 = 39
pcall(function()
	local v82 = enum[v]
	local v83 = v82 and v82[v80]

	if v83 then
		Enums[v83] = v81
	end
end)
local v82 = "DeviceIneligible"
local v83 = 40
pcall(function()
	local v84 = enum[v]
	local v85 = v84 and v84[v82]

	if v85 then
		Enums[v85] = v83
	end
end)
local v84 = "ExperienceIneligible"
local v85 = 41
pcall(function()
	local v86 = enum[v]
	local v87 = v86 and v86[v84]

	if v87 then
		Enums[v87] = v85
	end
end)
local v86 = "InternalError"
local v87 = 42
pcall(function()
	local v88 = enum[v]
	local v89 = v88 and v88[v86]

	if v89 then
		Enums[v89] = v87
	end
end)
local v88 = "NoFill"
local v89 = 43
pcall(function()
	local v90 = enum[v]
	local v91 = v90 and v90[v88]

	if v91 then
		Enums[v91] = v89
	end
end)
local v90 = "PlayerIneligible"
local v91 = 44
pcall(function()
	local v92 = enum[v]
	local v93 = v92 and v92[v90]

	if v93 then
		Enums[v93] = v91
	end
end)
local v92 = "PublisherIneligible"
local v93 = 45
pcall(function()
	local v94 = enum[v]
	local v95 = v94 and v94[v92]

	if v95 then
		Enums[v95] = v93
	end
end)
v = "AdEventType"
local v94 = "RewardedAdLoaded"
local v95 = 46
pcall(function()
	local v96 = enum[v]
	local v97 = v96 and v96[v94]

	if v97 then
		Enums[v97] = v95
	end
end)
local v96 = "RewardedAdGrant"
local v97 = 47
pcall(function()
	local v98 = enum[v]
	local v99 = v98 and v98[v96]

	if v99 then
		Enums[v99] = v97
	end
end)
local v98 = "RewardedAdUnloaded"
local v99 = 48
pcall(function()
	local v100 = enum[v]
	local v101 = v100 and v100[v98]

	if v101 then
		Enums[v101] = v99
	end
end)
local v100 = "VideoLoaded"
local v101 = 49
pcall(function()
	local v102 = enum[v]
	local v103 = v102 and v102[v100]

	if v103 then
		Enums[v103] = v101
	end
end)
local v102 = "VideoRemoved"
local v103 = 50
pcall(function()
	local v104 = enum[v]
	local v105 = v104 and v104[v102]

	if v105 then
		Enums[v105] = v103
	end
end)
local v104 = "UserCompletedVideo"
local v105 = 51
pcall(function()
	local v106 = enum[v]
	local v107 = v106 and v106[v104]

	if v107 then
		Enums[v107] = v105
	end
end)
v = "AdFormat"
local v106 = "RewardedVideo"
local v107 = 52
pcall(function()
	local v108 = enum[v]
	local v109 = v108 and v108[v106]

	if v109 then
		Enums[v109] = v107
	end
end)
v = "AdShape"
local v108 = "HorizontalRectangle"
local v109 = 53
pcall(function()
	local v110 = enum[v]
	local v111 = v110 and v110[v108]

	if v111 then
		Enums[v111] = v109
	end
end)
v = "AdTeleportMethod"
local v110 = "Undefined"
local v111 = 54
pcall(function()
	local v112 = enum[v]
	local v113 = v112 and v112[v110]

	if v113 then
		Enums[v113] = v111
	end
end)
local v112 = "PortalForward"
local v113 = 55
pcall(function()
	local v114 = enum[v]
	local v115 = v114 and v114[v112]

	if v115 then
		Enums[v115] = v113
	end
end)
local v114 = "InGameMenuBackButton"
local v115 = 56
pcall(function()
	local v116 = enum[v]
	local v117 = v116 and v116[v114]

	if v117 then
		Enums[v117] = v115
	end
end)
local v116 = "UIBackButton"
local v117 = 57
pcall(function()
	local v118 = enum[v]
	local v119 = v118 and v118[v116]

	if v119 then
		Enums[v119] = v117
	end
end)
v = "AdUIEventType"
local v118 = "AdLabelClicked"
local v119 = 58
pcall(function()
	local v120 = enum[v]
	local v121 = v120 and v120[v118]

	if v121 then
		Enums[v121] = v119
	end
end)
local v120 = "VolumeButtonClicked"
local v121 = 59
pcall(function()
	local v122 = enum[v]
	local v123 = v122 and v122[v120]

	if v123 then
		Enums[v123] = v121
	end
end)
local v122 = "FullscreenButtonClicked"
local v123 = 60
pcall(function()
	local v124 = enum[v]
	local v125 = v124 and v124[v122]

	if v125 then
		Enums[v125] = v123
	end
end)
local v124 = "PlayButtonClicked"
local v125 = 61
pcall(function()
	local v126 = enum[v]
	local v127 = v126 and v126[v124]

	if v127 then
		Enums[v127] = v125
	end
end)
local v126 = "PauseButtonClicked"
local v127 = 62
pcall(function()
	local v128 = enum[v]
	local v129 = v128 and v128[v126]

	if v129 then
		Enums[v129] = v127
	end
end)
local v128 = "CloseButtonClicked"
local v129 = 63
pcall(function()
	local v130 = enum[v]
	local v131 = v130 and v130[v128]

	if v131 then
		Enums[v131] = v129
	end
end)
local v130 = "WhyThisAdClicked"
local v131 = 64
pcall(function()
	local v132 = enum[v]
	local v133 = v132 and v132[v130]

	if v133 then
		Enums[v133] = v131
	end
end)
local v132 = "PlayEventTriggered"
local v133 = 65
pcall(function()
	local v134 = enum[v]
	local v135 = v134 and v134[v132]

	if v135 then
		Enums[v135] = v133
	end
end)
local v134 = "PauseEventTriggered"
local v135 = 66
pcall(function()
	local v136 = enum[v]
	local v137 = v136 and v136[v134]

	if v137 then
		Enums[v137] = v135
	end
end)
v = "AdUIType"
local v136 = "None"
local v137 = 67
pcall(function()
	local v138 = enum[v]
	local v139 = v138 and v138[v136]

	if v139 then
		Enums[v139] = v137
	end
end)
local v138 = "Image"
local v139 = 68
pcall(function()
	local v140 = enum[v]
	local v141 = v140 and v140[v138]

	if v141 then
		Enums[v141] = v139
	end
end)
local v140 = "Video"
local v141 = 69
pcall(function()
	local v142 = enum[v]
	local v143 = v142 and v142[v140]

	if v143 then
		Enums[v143] = v141
	end
end)
v = "AdUnitStatus"
local v142 = "Inactive"
local v143 = 70
pcall(function()
	local v144 = enum[v]
	local v145 = v144 and v144[v142]

	if v145 then
		Enums[v145] = v143
	end
end)
local v144 = "Active"
local v145 = 71
pcall(function()
	local v146 = enum[v]
	local v147 = v146 and v146[v144]

	if v147 then
		Enums[v147] = v145
	end
end)
v = "AdornCullingMode"
local v146 = "Automatic"
local v147 = 72
pcall(function()
	local v148 = enum[v]
	local v149 = v148 and v148[v146]

	if v149 then
		Enums[v149] = v147
	end
end)
local v148 = "Never"
local v149 = 73
pcall(function()
	local v150 = enum[v]
	local v151 = v150 and v150[v148]

	if v151 then
		Enums[v151] = v149
	end
end)
v = "AlignType"
local v150 = "PrimaryAxisParallel"
local v151 = 74
pcall(function()
	local v152 = enum[v]
	local v153 = v152 and v152[v150]

	if v153 then
		Enums[v153] = v151
	end
end)
local v152 = "PrimaryAxisPerpendicular"
local v153 = 75
pcall(function()
	local v154 = enum[v]
	local v155 = v154 and v154[v152]

	if v155 then
		Enums[v155] = v153
	end
end)
local v154 = "PrimaryAxisLookAt"
local v155 = 76
pcall(function()
	local v156 = enum[v]
	local v157 = v156 and v156[v154]

	if v157 then
		Enums[v157] = v155
	end
end)
local v156 = "AllAxes"
local v157 = 77
pcall(function()
	local v158 = enum[v]
	local v159 = v158 and v158[v156]

	if v159 then
		Enums[v159] = v157
	end
end)
local v158 = "Parallel"
local v159 = 78
pcall(function()
	local v160 = enum[v]
	local v161 = v160 and v160[v158]

	if v161 then
		Enums[v161] = v159
	end
end)
local v160 = "Perpendicular"
local v161 = 79
pcall(function()
	local v162 = enum[v]
	local v163 = v162 and v162[v160]

	if v163 then
		Enums[v163] = v161
	end
end)
v = "AlphaMode"
local v162 = "Overlay"
local v163 = 80
pcall(function()
	local v164 = enum[v]
	local v165 = v164 and v164[v162]

	if v165 then
		Enums[v165] = v163
	end
end)
local v164 = "Transparency"
local v165 = 81
pcall(function()
	local v166 = enum[v]
	local v167 = v166 and v166[v164]

	if v167 then
		Enums[v167] = v165
	end
end)
local v166 = "TintMask"
local v167 = 82
pcall(function()
	local v168 = enum[v]
	local v169 = v168 and v168[v166]

	if v169 then
		Enums[v169] = v167
	end
end)
v = "AnalyticsCustomFieldKeys"
local v168 = "CustomField01"
local v169 = 83
pcall(function()
	local v170 = enum[v]
	local v171 = v170 and v170[v168]

	if v171 then
		Enums[v171] = v169
	end
end)
local v170 = "CustomField02"
local v171 = 84
pcall(function()
	local v172 = enum[v]
	local v173 = v172 and v172[v170]

	if v173 then
		Enums[v173] = v171
	end
end)
local v172 = "CustomField03"
local v173 = 85
pcall(function()
	local v174 = enum[v]
	local v175 = v174 and v174[v172]

	if v175 then
		Enums[v175] = v173
	end
end)
v = "AnalyticsEconomyAction"
local v174 = "Default"
local v175 = 86
pcall(function()
	local v176 = enum[v]
	local v177 = v176 and v176[v174]

	if v177 then
		Enums[v177] = v175
	end
end)
local v176 = "Acquire"
local v177 = 87
pcall(function()
	local v178 = enum[v]
	local v179 = v178 and v178[v176]

	if v179 then
		Enums[v179] = v177
	end
end)
local v178 = "Spend"
local v179 = 88
pcall(function()
	local v180 = enum[v]
	local v181 = v180 and v180[v178]

	if v181 then
		Enums[v181] = v179
	end
end)
v = "AnalyticsEconomyFlowType"
local v180 = "Sink"
local v181 = 89
pcall(function()
	local v182 = enum[v]
	local v183 = v182 and v182[v180]

	if v183 then
		Enums[v183] = v181
	end
end)
local v182 = "Source"
local v183 = 90
pcall(function()
	local v184 = enum[v]
	local v185 = v184 and v184[v182]

	if v185 then
		Enums[v185] = v183
	end
end)
v = "AnalyticsEconomyTransactionType"
local v184 = "IAP"
local v185 = 91
pcall(function()
	local v186 = enum[v]
	local v187 = v186 and v186[v184]

	if v187 then
		Enums[v187] = v185
	end
end)
local v186 = "Shop"
local v187 = 92
pcall(function()
	local v188 = enum[v]
	local v189 = v188 and v188[v186]

	if v189 then
		Enums[v189] = v187
	end
end)
local v188 = "Gameplay"
local v189 = 93
pcall(function()
	local v190 = enum[v]
	local v191 = v190 and v190[v188]

	if v191 then
		Enums[v191] = v189
	end
end)
local v190 = "ContextualPurchase"
local v191 = 94
pcall(function()
	local v192 = enum[v]
	local v193 = v192 and v192[v190]

	if v193 then
		Enums[v193] = v191
	end
end)
local v192 = "TimedReward"
local v193 = 95
pcall(function()
	local v194 = enum[v]
	local v195 = v194 and v194[v192]

	if v195 then
		Enums[v195] = v193
	end
end)
local v194 = "Onboarding"
local v195 = 96
pcall(function()
	local v196 = enum[v]
	local v197 = v196 and v196[v194]

	if v197 then
		Enums[v197] = v195
	end
end)
v = "AnalyticsLogLevel"
local v196 = "Trace"
local v197 = 97
pcall(function()
	local v198 = enum[v]
	local v199 = v198 and v198[v196]

	if v199 then
		Enums[v199] = v197
	end
end)
local v198 = "Debug"
local v199 = 98
pcall(function()
	local v200 = enum[v]
	local v201 = v200 and v200[v198]

	if v201 then
		Enums[v201] = v199
	end
end)
local v200 = "Information"
local v201 = 99
pcall(function()
	local v202 = enum[v]
	local v203 = v202 and v202[v200]

	if v203 then
		Enums[v203] = v201
	end
end)
local v202 = "Warning"
local v203 = 100
pcall(function()
	local v204 = enum[v]
	local v205 = v204 and v204[v202]

	if v205 then
		Enums[v205] = v203
	end
end)
local v204 = "Error"
local v205 = 101
pcall(function()
	local v206 = enum[v]
	local v207 = v206 and v206[v204]

	if v207 then
		Enums[v207] = v205
	end
end)
local v206 = "Fatal"
local v207 = 102
pcall(function()
	local v208 = enum[v]
	local v209 = v208 and v208[v206]

	if v209 then
		Enums[v209] = v207
	end
end)
v = "AnalyticsProgressionStatus"
local v208 = "Default"
local v209 = 103
pcall(function()
	local v210 = enum[v]
	local v211 = v210 and v210[v208]

	if v211 then
		Enums[v211] = v209
	end
end)
local v210 = "Begin"
local v211 = 104
pcall(function()
	local v212 = enum[v]
	local v213 = v212 and v212[v210]

	if v213 then
		Enums[v213] = v211
	end
end)
local v212 = "Complete"
local v213 = 105
pcall(function()
	local v214 = enum[v]
	local v215 = v214 and v214[v212]

	if v215 then
		Enums[v215] = v213
	end
end)
local v214 = "Abandon"
local v215 = 106
pcall(function()
	local v216 = enum[v]
	local v217 = v216 and v216[v214]

	if v217 then
		Enums[v217] = v215
	end
end)
local v216 = "Fail"
local v217 = 107
pcall(function()
	local v218 = enum[v]
	local v219 = v218 and v218[v216]

	if v219 then
		Enums[v219] = v217
	end
end)
v = "AnalyticsProgressionType"
local v218 = "Custom"
local v219 = 108
pcall(function()
	local v220 = enum[v]
	local v221 = v220 and v220[v218]

	if v221 then
		Enums[v221] = v219
	end
end)
local v220 = "Start"
local v221 = 109
pcall(function()
	local v222 = enum[v]
	local v223 = v222 and v222[v220]

	if v223 then
		Enums[v223] = v221
	end
end)
local v222 = "Fail"
local v223 = 110
pcall(function()
	local v224 = enum[v]
	local v225 = v224 and v224[v222]

	if v225 then
		Enums[v225] = v223
	end
end)
local v224 = "Complete"
local v225 = 111
pcall(function()
	local v226 = enum[v]
	local v227 = v226 and v226[v224]

	if v227 then
		Enums[v227] = v225
	end
end)
v = "AnimationClipFromVideoStatus"
local v226 = "Initializing"
local v227 = 112
pcall(function()
	local v228 = enum[v]
	local v229 = v228 and v228[v226]

	if v229 then
		Enums[v229] = v227
	end
end)
local v228 = "Pending"
local v229 = 113
pcall(function()
	local v230 = enum[v]
	local v231 = v230 and v230[v228]

	if v231 then
		Enums[v231] = v229
	end
end)
local v230 = "Processing"
local v231 = 114
pcall(function()
	local v232 = enum[v]
	local v233 = v232 and v232[v230]

	if v233 then
		Enums[v233] = v231
	end
end)
local v232 = "ErrorGeneric"
local v233 = 115
pcall(function()
	local v234 = enum[v]
	local v235 = v234 and v234[v232]

	if v235 then
		Enums[v235] = v233
	end
end)
local v234 = "Success"
local v235 = 116
pcall(function()
	local v236 = enum[v]
	local v237 = v236 and v236[v234]

	if v237 then
		Enums[v237] = v235
	end
end)
local v236 = "ErrorVideoTooLong"
local v237 = 117
pcall(function()
	local v238 = enum[v]
	local v239 = v238 and v238[v236]

	if v239 then
		Enums[v239] = v237
	end
end)
local v238 = "ErrorNoPersonDetected"
local v239 = 118
pcall(function()
	local v240 = enum[v]
	local v241 = v240 and v240[v238]

	if v241 then
		Enums[v241] = v239
	end
end)
local v240 = "ErrorVideoUnstable"
local v241 = 119
pcall(function()
	local v242 = enum[v]
	local v243 = v242 and v242[v240]

	if v243 then
		Enums[v243] = v241
	end
end)
local v242 = "Timeout"
local v243 = 120
pcall(function()
	local v244 = enum[v]
	local v245 = v244 and v244[v242]

	if v245 then
		Enums[v245] = v243
	end
end)
local v244 = "Cancelled"
local v245 = 121
pcall(function()
	local v246 = enum[v]
	local v247 = v246 and v246[v244]

	if v247 then
		Enums[v247] = v245
	end
end)
local v246 = "ErrorMultiplePeople"
local v247 = 122
pcall(function()
	local v248 = enum[v]
	local v249 = v248 and v248[v246]

	if v249 then
		Enums[v249] = v247
	end
end)
local v248 = "ErrorUploadingVideo"
local v249 = 123
pcall(function()
	local v250 = enum[v]
	local v251 = v250 and v250[v248]

	if v251 then
		Enums[v251] = v249
	end
end)
v = "AnimationPriority"
local v250 = "Core"
local v251 = 124
pcall(function()
	local v252 = enum[v]
	local v253 = v252 and v252[v250]

	if v253 then
		Enums[v253] = v251
	end
end)
local v252 = "Idle"
local v253 = 125
pcall(function()
	local v254 = enum[v]
	local v255 = v254 and v254[v252]

	if v255 then
		Enums[v255] = v253
	end
end)
local v254 = "Movement"
local v255 = 126
pcall(function()
	local v256 = enum[v]
	local v257 = v256 and v256[v254]

	if v257 then
		Enums[v257] = v255
	end
end)
local v256 = "Action"
local v257 = 127
pcall(function()
	local v258 = enum[v]
	local v259 = v258 and v258[v256]

	if v259 then
		Enums[v259] = v257
	end
end)
local v258 = "Action2"
local v259 = 128
pcall(function()
	local v260 = enum[v]
	local v261 = v260 and v260[v258]

	if v261 then
		Enums[v261] = v259
	end
end)
local v260 = "Action3"
local v261 = 129
pcall(function()
	local v262 = enum[v]
	local v263 = v262 and v262[v260]

	if v263 then
		Enums[v263] = v261
	end
end)
local v262 = "Action4"
local v263 = 130
pcall(function()
	local v264 = enum[v]
	local v265 = v264 and v264[v262]

	if v265 then
		Enums[v265] = v263
	end
end)
v = "AnimatorRetargetingMode"
local v264 = "Default"
local v265 = 131
pcall(function()
	local v266 = enum[v]
	local v267 = v266 and v266[v264]

	if v267 then
		Enums[v267] = v265
	end
end)
local v266 = "Disabled"
local v267 = 132
pcall(function()
	local v268 = enum[v]
	local v269 = v268 and v268[v266]

	if v269 then
		Enums[v269] = v267
	end
end)
local v268 = "Enabled"
local v269 = 133
pcall(function()
	local v270 = enum[v]
	local v271 = v270 and v270[v268]

	if v271 then
		Enums[v271] = v269
	end
end)
v = "AnnotationEditingMode"
local v270 = "None"
local v271 = 134
pcall(function()
	local v272 = enum[v]
	local v273 = v272 and v272[v270]

	if v273 then
		Enums[v273] = v271
	end
end)
local v272 = "PlacingNew"
local v273 = 135
pcall(function()
	local v274 = enum[v]
	local v275 = v274 and v274[v272]

	if v275 then
		Enums[v275] = v273
	end
end)
local v274 = "WritingNew"
local v275 = 136
pcall(function()
	local v276 = enum[v]
	local v277 = v276 and v276[v274]

	if v277 then
		Enums[v277] = v275
	end
end)
v = "AnnotationRequestStatus"
local v276 = "Success"
local v277 = 137
pcall(function()
	local v278 = enum[v]
	local v279 = v278 and v278[v276]

	if v279 then
		Enums[v279] = v277
	end
end)
local v278 = "Loading"
local v279 = 138
pcall(function()
	local v280 = enum[v]
	local v281 = v280 and v280[v278]

	if v281 then
		Enums[v281] = v279
	end
end)
local v280 = "ErrorInternalFailure"
local v281 = 139
pcall(function()
	local v282 = enum[v]
	local v283 = v282 and v282[v280]

	if v283 then
		Enums[v283] = v281
	end
end)
local v282 = "ErrorNotFound"
local v283 = 140
pcall(function()
	local v284 = enum[v]
	local v285 = v284 and v284[v282]

	if v285 then
		Enums[v285] = v283
	end
end)
local v284 = "ErrorModerated"
local v285 = 141
pcall(function()
	local v286 = enum[v]
	local v287 = v286 and v286[v284]

	if v287 then
		Enums[v287] = v285
	end
end)
v = "AnnotationRequestType"
local v286 = "Unknown"
local v287 = 142
pcall(function()
	local v288 = enum[v]
	local v289 = v288 and v288[v286]

	if v289 then
		Enums[v289] = v287
	end
end)
local v288 = "Create"
local v289 = 143
pcall(function()
	local v290 = enum[v]
	local v291 = v290 and v290[v288]

	if v291 then
		Enums[v291] = v289
	end
end)
local v290 = "Resolve"
local v291 = 144
pcall(function()
	local v292 = enum[v]
	local v293 = v292 and v292[v290]

	if v293 then
		Enums[v293] = v291
	end
end)
local v292 = "Delete"
local v293 = 145
pcall(function()
	local v294 = enum[v]
	local v295 = v294 and v294[v292]

	if v295 then
		Enums[v295] = v293
	end
end)
local v294 = "Edit"
local v295 = 146
pcall(function()
	local v296 = enum[v]
	local v297 = v296 and v296[v294]

	if v297 then
		Enums[v297] = v295
	end
end)
v = "AppLifecycleManagerState"
local v296 = "Detached"
local v297 = 147
pcall(function()
	local v298 = enum[v]
	local v299 = v298 and v298[v296]

	if v299 then
		Enums[v299] = v297
	end
end)
local v298 = "Active"
local v299 = 148
pcall(function()
	local v300 = enum[v]
	local v301 = v300 and v300[v298]

	if v301 then
		Enums[v301] = v299
	end
end)
local v300 = "Inactive"
local v301 = 149
pcall(function()
	local v302 = enum[v]
	local v303 = v302 and v302[v300]

	if v303 then
		Enums[v303] = v301
	end
end)
local v302 = "Hidden"
local v303 = 150
pcall(function()
	local v304 = enum[v]
	local v305 = v304 and v304[v302]

	if v305 then
		Enums[v305] = v303
	end
end)
v = "AppShellActionType"
local v304 = "None"
local v305 = 151
pcall(function()
	local v306 = enum[v]
	local v307 = v306 and v306[v304]

	if v307 then
		Enums[v307] = v305
	end
end)
local v306 = "OpenApp"
local v307 = 152
pcall(function()
	local v308 = enum[v]
	local v309 = v308 and v308[v306]

	if v309 then
		Enums[v309] = v307
	end
end)
local v308 = "TapChatTab"
local v309 = 153
pcall(function()
	local v310 = enum[v]
	local v311 = v310 and v310[v308]

	if v311 then
		Enums[v311] = v309
	end
end)
local v310 = "TapConversationEntry"
local v311 = 154
pcall(function()
	local v312 = enum[v]
	local v313 = v312 and v312[v310]

	if v313 then
		Enums[v313] = v311
	end
end)
local v312 = "TapAvatarTab"
local v313 = 155
pcall(function()
	local v314 = enum[v]
	local v315 = v314 and v314[v312]

	if v315 then
		Enums[v315] = v313
	end
end)
local v314 = "ReadConversation"
local v315 = 156
pcall(function()
	local v316 = enum[v]
	local v317 = v316 and v316[v314]

	if v317 then
		Enums[v317] = v315
	end
end)
local v316 = "TapGamePageTab"
local v317 = 157
pcall(function()
	local v318 = enum[v]
	local v319 = v318 and v318[v316]

	if v319 then
		Enums[v319] = v317
	end
end)
local v318 = "TapHomePageTab"
local v319 = 158
pcall(function()
	local v320 = enum[v]
	local v321 = v320 and v320[v318]

	if v321 then
		Enums[v321] = v319
	end
end)
local v320 = "GamePageLoaded"
local v321 = 159
pcall(function()
	local v322 = enum[v]
	local v323 = v322 and v322[v320]

	if v323 then
		Enums[v323] = v321
	end
end)
local v322 = "HomePageLoaded"
local v323 = 160
pcall(function()
	local v324 = enum[v]
	local v325 = v324 and v324[v322]

	if v325 then
		Enums[v325] = v323
	end
end)
local v324 = "AvatarEditorPageLoaded"
local v325 = 161
pcall(function()
	local v326 = enum[v]
	local v327 = v326 and v326[v324]

	if v327 then
		Enums[v327] = v325
	end
end)
v = "AppShellFeature"
local v326 = "None"
local v327 = 162
pcall(function()
	local v328 = enum[v]
	local v329 = v328 and v328[v326]

	if v329 then
		Enums[v329] = v327
	end
end)
local v328 = "Chat"
local v329 = 163
pcall(function()
	local v330 = enum[v]
	local v331 = v330 and v330[v328]

	if v331 then
		Enums[v331] = v329
	end
end)
local v330 = "AvatarEditor"
local v331 = 164
pcall(function()
	local v332 = enum[v]
	local v333 = v332 and v332[v330]

	if v333 then
		Enums[v333] = v331
	end
end)
local v332 = "GamePage"
local v333 = 165
pcall(function()
	local v334 = enum[v]
	local v335 = v334 and v334[v332]

	if v335 then
		Enums[v335] = v333
	end
end)
local v334 = "HomePage"
local v335 = 166
pcall(function()
	local v336 = enum[v]
	local v337 = v336 and v336[v334]

	if v337 then
		Enums[v337] = v335
	end
end)
local v336 = "More"
local v337 = 167
pcall(function()
	local v338 = enum[v]
	local v339 = v338 and v338[v336]

	if v339 then
		Enums[v339] = v337
	end
end)
local v338 = "Landing"
local v339 = 168
pcall(function()
	local v340 = enum[v]
	local v341 = v340 and v340[v338]

	if v341 then
		Enums[v341] = v339
	end
end)
v = "AppUpdateStatus"
local v340 = "Unknown"
local v341 = 169
pcall(function()
	local v342 = enum[v]
	local v343 = v342 and v342[v340]

	if v343 then
		Enums[v343] = v341
	end
end)
local v342 = "NotSupported"
local v343 = 170
pcall(function()
	local v344 = enum[v]
	local v345 = v344 and v344[v342]

	if v345 then
		Enums[v345] = v343
	end
end)
local v344 = "Failed"
local v345 = 171
pcall(function()
	local v346 = enum[v]
	local v347 = v346 and v346[v344]

	if v347 then
		Enums[v347] = v345
	end
end)
local v346 = "NotAvailable"
local v347 = 172
pcall(function()
	local v348 = enum[v]
	local v349 = v348 and v348[v346]

	if v349 then
		Enums[v349] = v347
	end
end)
local v348 = "Available"
local v349 = 173
pcall(function()
	local v350 = enum[v]
	local v351 = v350 and v350[v348]

	if v351 then
		Enums[v351] = v349
	end
end)
local v350 = "AvailableBoundChannel"
local v351 = 174
pcall(function()
	local v352 = enum[v]
	local v353 = v352 and v352[v350]

	if v353 then
		Enums[v353] = v351
	end
end)
v = "ApplyStrokeMode"
local v352 = "Contextual"
local v353 = 175
pcall(function()
	local v354 = enum[v]
	local v355 = v354 and v354[v352]

	if v355 then
		Enums[v355] = v353
	end
end)
local v354 = "Border"
local v355 = 176
pcall(function()
	local v356 = enum[v]
	local v357 = v356 and v356[v354]

	if v357 then
		Enums[v357] = v355
	end
end)
v = "AspectType"
local v356 = "FitWithinMaxSize"
local v357 = 177
pcall(function()
	local v358 = enum[v]
	local v359 = v358 and v358[v356]

	if v359 then
		Enums[v359] = v357
	end
end)
local v358 = "ScaleWithParentSize"
local v359 = 178
pcall(function()
	local v360 = enum[v]
	local v361 = v360 and v360[v358]

	if v361 then
		Enums[v361] = v359
	end
end)
v = "AssetCreatorType"
local v360 = "User"
local v361 = 179
pcall(function()
	local v362 = enum[v]
	local v363 = v362 and v362[v360]

	if v363 then
		Enums[v363] = v361
	end
end)
local v362 = "Group"
local v363 = 180
pcall(function()
	local v364 = enum[v]
	local v365 = v364 and v364[v362]

	if v365 then
		Enums[v365] = v363
	end
end)
v = "AssetFetchStatus"
local v364 = "Success"
local v365 = 181
pcall(function()
	local v366 = enum[v]
	local v367 = v366 and v366[v364]

	if v367 then
		Enums[v367] = v365
	end
end)
local v366 = "Failure"
local v367 = 182
pcall(function()
	local v368 = enum[v]
	local v369 = v368 and v368[v366]

	if v369 then
		Enums[v369] = v367
	end
end)
local v368 = "None"
local v369 = 183
pcall(function()
	local v370 = enum[v]
	local v371 = v370 and v370[v368]

	if v371 then
		Enums[v371] = v369
	end
end)
local v370 = "Loading"
local v371 = 184
pcall(function()
	local v372 = enum[v]
	local v373 = v372 and v372[v370]

	if v373 then
		Enums[v373] = v371
	end
end)
local v372 = "TimedOut"
local v373 = 185
pcall(function()
	local v374 = enum[v]
	local v375 = v374 and v374[v372]

	if v375 then
		Enums[v375] = v373
	end
end)
v = "AssetType"
local v374 = "Image"
local v375 = 186
pcall(function()
	local v376 = enum[v]
	local v377 = v376 and v376[v374]

	if v377 then
		Enums[v377] = v375
	end
end)
local v376 = "TShirt"
local v377 = 187
pcall(function()
	local v378 = enum[v]
	local v379 = v378 and v378[v376]

	if v379 then
		Enums[v379] = v377
	end
end)
local v378 = "Audio"
local v379 = 188
pcall(function()
	local v380 = enum[v]
	local v381 = v380 and v380[v378]

	if v381 then
		Enums[v381] = v379
	end
end)
local v380 = "Mesh"
local v381 = 189
pcall(function()
	local v382 = enum[v]
	local v383 = v382 and v382[v380]

	if v383 then
		Enums[v383] = v381
	end
end)
local v382 = "Lua"
local v383 = 190
pcall(function()
	local v384 = enum[v]
	local v385 = v384 and v384[v382]

	if v385 then
		Enums[v385] = v383
	end
end)
local v384 = "Hat"
local v385 = 191
pcall(function()
	local v386 = enum[v]
	local v387 = v386 and v386[v384]

	if v387 then
		Enums[v387] = v385
	end
end)
local v386 = "Place"
local v387 = 192
pcall(function()
	local v388 = enum[v]
	local v389 = v388 and v388[v386]

	if v389 then
		Enums[v389] = v387
	end
end)
local v388 = "Model"
local v389 = 193
pcall(function()
	local v390 = enum[v]
	local v391 = v390 and v390[v388]

	if v391 then
		Enums[v391] = v389
	end
end)
local v390 = "Shirt"
local v391 = 194
pcall(function()
	local v392 = enum[v]
	local v393 = v392 and v392[v390]

	if v393 then
		Enums[v393] = v391
	end
end)
local v392 = "Pants"
local v393 = 195
pcall(function()
	local v394 = enum[v]
	local v395 = v394 and v394[v392]

	if v395 then
		Enums[v395] = v393
	end
end)
local v394 = "Decal"
local v395 = 196
pcall(function()
	local v396 = enum[v]
	local v397 = v396 and v396[v394]

	if v397 then
		Enums[v397] = v395
	end
end)
local v396 = "Head"
local v397 = 197
pcall(function()
	local v398 = enum[v]
	local v399 = v398 and v398[v396]

	if v399 then
		Enums[v399] = v397
	end
end)
local v398 = "Face"
local v399 = 198
pcall(function()
	local v400 = enum[v]
	local v401 = v400 and v400[v398]

	if v401 then
		Enums[v401] = v399
	end
end)
local v400 = "Gear"
local v401 = 199
pcall(function()
	local v402 = enum[v]
	local v403 = v402 and v402[v400]

	if v403 then
		Enums[v403] = v401
	end
end)
local v402 = "Badge"
local v403 = 200
pcall(function()
	local v404 = enum[v]
	local v405 = v404 and v404[v402]

	if v405 then
		Enums[v405] = v403
	end
end)
local v404 = "Animation"
local v405 = 201
pcall(function()
	local v406 = enum[v]
	local v407 = v406 and v406[v404]

	if v407 then
		Enums[v407] = v405
	end
end)
local v406 = "Torso"
local v407 = 202
pcall(function()
	local v408 = enum[v]
	local v409 = v408 and v408[v406]

	if v409 then
		Enums[v409] = v407
	end
end)
local v408 = "RightArm"
local v409 = 203
pcall(function()
	local v410 = enum[v]
	local v411 = v410 and v410[v408]

	if v411 then
		Enums[v411] = v409
	end
end)
local v410 = "LeftArm"
local v411 = 204
pcall(function()
	local v412 = enum[v]
	local v413 = v412 and v412[v410]

	if v413 then
		Enums[v413] = v411
	end
end)
local v412 = "LeftLeg"
local v413 = 205
pcall(function()
	local v414 = enum[v]
	local v415 = v414 and v414[v412]

	if v415 then
		Enums[v415] = v413
	end
end)
local v414 = "RightLeg"
local v415 = 206
pcall(function()
	local v416 = enum[v]
	local v417 = v416 and v416[v414]

	if v417 then
		Enums[v417] = v415
	end
end)
local v416 = "Package"
local v417 = 207
pcall(function()
	local v418 = enum[v]
	local v419 = v418 and v418[v416]

	if v419 then
		Enums[v419] = v417
	end
end)
local v418 = "GamePass"
local v419 = 208
pcall(function()
	local v420 = enum[v]
	local v421 = v420 and v420[v418]

	if v421 then
		Enums[v421] = v419
	end
end)
local v420 = "Plugin"
local v421 = 209
pcall(function()
	local v422 = enum[v]
	local v423 = v422 and v422[v420]

	if v423 then
		Enums[v423] = v421
	end
end)
local v422 = "MeshPart"
local v423 = 210
pcall(function()
	local v424 = enum[v]
	local v425 = v424 and v424[v422]

	if v425 then
		Enums[v425] = v423
	end
end)
local v424 = "HairAccessory"
local v425 = 211
pcall(function()
	local v426 = enum[v]
	local v427 = v426 and v426[v424]

	if v427 then
		Enums[v427] = v425
	end
end)
local v426 = "FaceAccessory"
local v427 = 212
pcall(function()
	local v428 = enum[v]
	local v429 = v428 and v428[v426]

	if v429 then
		Enums[v429] = v427
	end
end)
local v428 = "NeckAccessory"
local v429 = 213
pcall(function()
	local v430 = enum[v]
	local v431 = v430 and v430[v428]

	if v431 then
		Enums[v431] = v429
	end
end)
local v430 = "ShoulderAccessory"
local v431 = 214
pcall(function()
	local v432 = enum[v]
	local v433 = v432 and v432[v430]

	if v433 then
		Enums[v433] = v431
	end
end)
local v432 = "FrontAccessory"
local v433 = 215
pcall(function()
	local v434 = enum[v]
	local v435 = v434 and v434[v432]

	if v435 then
		Enums[v435] = v433
	end
end)
local v434 = "BackAccessory"
local v435 = 216
pcall(function()
	local v436 = enum[v]
	local v437 = v436 and v436[v434]

	if v437 then
		Enums[v437] = v435
	end
end)
local v436 = "WaistAccessory"
local v437 = 217
pcall(function()
	local v438 = enum[v]
	local v439 = v438 and v438[v436]

	if v439 then
		Enums[v439] = v437
	end
end)
local v438 = "ClimbAnimation"
local v439 = 218
pcall(function()
	local v440 = enum[v]
	local v441 = v440 and v440[v438]

	if v441 then
		Enums[v441] = v439
	end
end)
local v440 = "DeathAnimation"
local v441 = 219
pcall(function()
	local v442 = enum[v]
	local v443 = v442 and v442[v440]

	if v443 then
		Enums[v443] = v441
	end
end)
local v442 = "FallAnimation"
local v443 = 220
pcall(function()
	local v444 = enum[v]
	local v445 = v444 and v444[v442]

	if v445 then
		Enums[v445] = v443
	end
end)
local v444 = "IdleAnimation"
local v445 = 221
pcall(function()
	local v446 = enum[v]
	local v447 = v446 and v446[v444]

	if v447 then
		Enums[v447] = v445
	end
end)
local v446 = "JumpAnimation"
local v447 = 222
pcall(function()
	local v448 = enum[v]
	local v449 = v448 and v448[v446]

	if v449 then
		Enums[v449] = v447
	end
end)
local v448 = "RunAnimation"
local v449 = 223
pcall(function()
	local v450 = enum[v]
	local v451 = v450 and v450[v448]

	if v451 then
		Enums[v451] = v449
	end
end)
local v450 = "SwimAnimation"
local v451 = 224
pcall(function()
	local v452 = enum[v]
	local v453 = v452 and v452[v450]

	if v453 then
		Enums[v453] = v451
	end
end)
local v452 = "WalkAnimation"
local v453 = 225
pcall(function()
	local v454 = enum[v]
	local v455 = v454 and v454[v452]

	if v455 then
		Enums[v455] = v453
	end
end)
local v454 = "PoseAnimation"
local v455 = 226
pcall(function()
	local v456 = enum[v]
	local v457 = v456 and v456[v454]

	if v457 then
		Enums[v457] = v455
	end
end)
local v456 = "EarAccessory"
local v457 = 227
pcall(function()
	local v458 = enum[v]
	local v459 = v458 and v458[v456]

	if v459 then
		Enums[v459] = v457
	end
end)
local v458 = "EyeAccessory"
local v459 = 228
pcall(function()
	local v460 = enum[v]
	local v461 = v460 and v460[v458]

	if v461 then
		Enums[v461] = v459
	end
end)
local v460 = "EmoteAnimation"
local v461 = 229
pcall(function()
	local v462 = enum[v]
	local v463 = v462 and v462[v460]

	if v463 then
		Enums[v463] = v461
	end
end)
local v462 = "Video"
local v463 = 230
pcall(function()
	local v464 = enum[v]
	local v465 = v464 and v464[v462]

	if v465 then
		Enums[v465] = v463
	end
end)
local v464 = "TShirtAccessory"
local v465 = 231
pcall(function()
	local v466 = enum[v]
	local v467 = v466 and v466[v464]

	if v467 then
		Enums[v467] = v465
	end
end)
local v466 = "ShirtAccessory"
local v467 = 232
pcall(function()
	local v468 = enum[v]
	local v469 = v468 and v468[v466]

	if v469 then
		Enums[v469] = v467
	end
end)
local v468 = "PantsAccessory"
local v469 = 233
pcall(function()
	local v470 = enum[v]
	local v471 = v470 and v470[v468]

	if v471 then
		Enums[v471] = v469
	end
end)
local v470 = "JacketAccessory"
local v471 = 234
pcall(function()
	local v472 = enum[v]
	local v473 = v472 and v472[v470]

	if v473 then
		Enums[v473] = v471
	end
end)
local v472 = "SweaterAccessory"
local v473 = 235
pcall(function()
	local v474 = enum[v]
	local v475 = v474 and v474[v472]

	if v475 then
		Enums[v475] = v473
	end
end)
local v474 = "ShortsAccessory"
local v475 = 236
pcall(function()
	local v476 = enum[v]
	local v477 = v476 and v476[v474]

	if v477 then
		Enums[v477] = v475
	end
end)
local v476 = "LeftShoeAccessory"
local v477 = 237
pcall(function()
	local v478 = enum[v]
	local v479 = v478 and v478[v476]

	if v479 then
		Enums[v479] = v477
	end
end)
local v478 = "RightShoeAccessory"
local v479 = 238
pcall(function()
	local v480 = enum[v]
	local v481 = v480 and v480[v478]

	if v481 then
		Enums[v481] = v479
	end
end)
local v480 = "DressSkirtAccessory"
local v481 = 239
pcall(function()
	local v482 = enum[v]
	local v483 = v482 and v482[v480]

	if v483 then
		Enums[v483] = v481
	end
end)
local v482 = "FontFamily"
local v483 = 240
pcall(function()
	local v484 = enum[v]
	local v485 = v484 and v484[v482]

	if v485 then
		Enums[v485] = v483
	end
end)
local v484 = "EyebrowAccessory"
local v485 = 241
pcall(function()
	local v486 = enum[v]
	local v487 = v486 and v486[v484]

	if v487 then
		Enums[v487] = v485
	end
end)
local v486 = "EyelashAccessory"
local v487 = 242
pcall(function()
	local v488 = enum[v]
	local v489 = v488 and v488[v486]

	if v489 then
		Enums[v489] = v487
	end
end)
local v488 = "MoodAnimation"
local v489 = 243
pcall(function()
	local v490 = enum[v]
	local v491 = v490 and v490[v488]

	if v491 then
		Enums[v491] = v489
	end
end)
local v490 = "DynamicHead"
local v491 = 244
pcall(function()
	local v492 = enum[v]
	local v493 = v492 and v492[v490]

	if v493 then
		Enums[v493] = v491
	end
end)
v = "AssetTypeVerification"
local v492 = "Default"
local v493 = 245
pcall(function()
	local v494 = enum[v]
	local v495 = v494 and v494[v492]

	if v495 then
		Enums[v495] = v493
	end
end)
local v494 = "ClientOnly"
local v495 = 246
pcall(function()
	local v496 = enum[v]
	local v497 = v496 and v496[v494]

	if v497 then
		Enums[v497] = v495
	end
end)
local v496 = "Always"
local v497 = 247
pcall(function()
	local v498 = enum[v]
	local v499 = v498 and v498[v496]

	if v499 then
		Enums[v499] = v497
	end
end)
v = "AudioApiRollout"
local v498 = "Disabled"
local v499 = 248
pcall(function()
	local v500 = enum[v]
	local v501 = v500 and v500[v498]

	if v501 then
		Enums[v501] = v499
	end
end)
local v500 = "Automatic"
local v501 = 249
pcall(function()
	local v502 = enum[v]
	local v503 = v502 and v502[v500]

	if v503 then
		Enums[v503] = v501
	end
end)
local v502 = "Enabled"
local v503 = 250
pcall(function()
	local v504 = enum[v]
	local v505 = v504 and v504[v502]

	if v505 then
		Enums[v505] = v503
	end
end)
v = "AudioChannelLayout"
local v504 = "Mono"
local v505 = 251
pcall(function()
	local v506 = enum[v]
	local v507 = v506 and v506[v504]

	if v507 then
		Enums[v507] = v505
	end
end)
local v506 = "Stereo"
local v507 = 252
pcall(function()
	local v508 = enum[v]
	local v509 = v508 and v508[v506]

	if v509 then
		Enums[v509] = v507
	end
end)
local v508 = "Quad"
local v509 = 253
pcall(function()
	local v510 = enum[v]
	local v511 = v510 and v510[v508]

	if v511 then
		Enums[v511] = v509
	end
end)
local v510 = "Surround_5"
local v511 = 254
pcall(function()
	local v512 = enum[v]
	local v513 = v512 and v512[v510]

	if v513 then
		Enums[v513] = v511
	end
end)
local v512 = "Surround_5_1"
local v513 = 255
pcall(function()
	local v514 = enum[v]
	local v515 = v514 and v514[v512]

	if v515 then
		Enums[v515] = v513
	end
end)
local v514 = "Surround_7_1"
local v515 = 256
pcall(function()
	local v516 = enum[v]
	local v517 = v516 and v516[v514]

	if v517 then
		Enums[v517] = v515
	end
end)
local v516 = "Surround_7_1_4"
local v517 = 257
pcall(function()
	local v518 = enum[v]
	local v519 = v518 and v518[v516]

	if v519 then
		Enums[v519] = v517
	end
end)
v = "AudioFilterType"
local v518 = "Peak"
local v519 = 258
pcall(function()
	local v520 = enum[v]
	local v521 = v520 and v520[v518]

	if v521 then
		Enums[v521] = v519
	end
end)
local v520 = "LowShelf"
local v521 = 259
pcall(function()
	local v522 = enum[v]
	local v523 = v522 and v522[v520]

	if v523 then
		Enums[v523] = v521
	end
end)
local v522 = "HighShelf"
local v523 = 260
pcall(function()
	local v524 = enum[v]
	local v525 = v524 and v524[v522]

	if v525 then
		Enums[v525] = v523
	end
end)
local v524 = "Lowpass12dB"
local v525 = 261
pcall(function()
	local v526 = enum[v]
	local v527 = v526 and v526[v524]

	if v527 then
		Enums[v527] = v525
	end
end)
local v526 = "Lowpass24dB"
local v527 = 262
pcall(function()
	local v528 = enum[v]
	local v529 = v528 and v528[v526]

	if v529 then
		Enums[v529] = v527
	end
end)
local v528 = "Lowpass48dB"
local v529 = 263
pcall(function()
	local v530 = enum[v]
	local v531 = v530 and v530[v528]

	if v531 then
		Enums[v531] = v529
	end
end)
local v530 = "Highpass12dB"
local v531 = 264
pcall(function()
	local v532 = enum[v]
	local v533 = v532 and v532[v530]

	if v533 then
		Enums[v533] = v531
	end
end)
local v532 = "Highpass24dB"
local v533 = 265
pcall(function()
	local v534 = enum[v]
	local v535 = v534 and v534[v532]

	if v535 then
		Enums[v535] = v533
	end
end)
local v534 = "Highpass48dB"
local v535 = 266
pcall(function()
	local v536 = enum[v]
	local v537 = v536 and v536[v534]

	if v537 then
		Enums[v537] = v535
	end
end)
local v536 = "Bandpass"
local v537 = 267
pcall(function()
	local v538 = enum[v]
	local v539 = v538 and v538[v536]

	if v539 then
		Enums[v539] = v537
	end
end)
local v538 = "Notch"
local v539 = 268
pcall(function()
	local v540 = enum[v]
	local v541 = v540 and v540[v538]

	if v541 then
		Enums[v541] = v539
	end
end)
local v540 = "Lowpass6dB"
local v541 = 269
pcall(function()
	local v542 = enum[v]
	local v543 = v542 and v542[v540]

	if v543 then
		Enums[v543] = v541
	end
end)
v = "AudioSimulationFidelity"
local v542 = "None"
local v543 = 270
pcall(function()
	local v544 = enum[v]
	local v545 = v544 and v544[v542]

	if v545 then
		Enums[v545] = v543
	end
end)
local v544 = "Automatic"
local v545 = 271
pcall(function()
	local v546 = enum[v]
	local v547 = v546 and v546[v544]

	if v547 then
		Enums[v547] = v545
	end
end)
v = "AudioSubType"
local v546 = "Music"
local v547 = 272
pcall(function()
	local v548 = enum[v]
	local v549 = v548 and v548[v546]

	if v549 then
		Enums[v549] = v547
	end
end)
local v548 = "SoundEffect"
local v549 = 273
pcall(function()
	local v550 = enum[v]
	local v551 = v550 and v550[v548]

	if v551 then
		Enums[v551] = v549
	end
end)
v = "AudioWindowSize"
local v550 = "Small"
local v551 = 274
pcall(function()
	local v552 = enum[v]
	local v553 = v552 and v552[v550]

	if v553 then
		Enums[v553] = v551
	end
end)
local v552 = "Medium"
local v553 = 275
pcall(function()
	local v554 = enum[v]
	local v555 = v554 and v554[v552]

	if v555 then
		Enums[v555] = v553
	end
end)
local v554 = "Large"
local v555 = 276
pcall(function()
	local v556 = enum[v]
	local v557 = v556 and v556[v554]

	if v557 then
		Enums[v557] = v555
	end
end)
v = "AutoIndentRule"
local v556 = "Off"
local v557 = 277
pcall(function()
	local v558 = enum[v]
	local v559 = v558 and v558[v556]

	if v559 then
		Enums[v559] = v557
	end
end)
local v558 = "Absolute"
local v559 = 278
pcall(function()
	local v560 = enum[v]
	local v561 = v560 and v560[v558]

	if v561 then
		Enums[v561] = v559
	end
end)
local v560 = "Relative"
local v561 = 279
pcall(function()
	local v562 = enum[v]
	local v563 = v562 and v562[v560]

	if v563 then
		Enums[v563] = v561
	end
end)
v = "AutomaticSize"
local v562 = "None"
local v563 = 280
pcall(function()
	local v564 = enum[v]
	local v565 = v564 and v564[v562]

	if v565 then
		Enums[v565] = v563
	end
end)
local v564 = "X"
local v565 = 281
pcall(function()
	local v566 = enum[v]
	local v567 = v566 and v566[v564]

	if v567 then
		Enums[v567] = v565
	end
end)
local v566 = "Y"
local v567 = 282
pcall(function()
	local v568 = enum[v]
	local v569 = v568 and v568[v566]

	if v569 then
		Enums[v569] = v567
	end
end)
local v568 = "XY"
local v569 = 283
pcall(function()
	local v570 = enum[v]
	local v571 = v570 and v570[v568]

	if v571 then
		Enums[v571] = v569
	end
end)
v = "AvatarAssetType"
local v570 = "TShirt"
local v571 = 284
pcall(function()
	local v572 = enum[v]
	local v573 = v572 and v572[v570]

	if v573 then
		Enums[v573] = v571
	end
end)
local v572 = "Hat"
local v573 = 285
pcall(function()
	local v574 = enum[v]
	local v575 = v574 and v574[v572]

	if v575 then
		Enums[v575] = v573
	end
end)
local v574 = "Shirt"
local v575 = 286
pcall(function()
	local v576 = enum[v]
	local v577 = v576 and v576[v574]

	if v577 then
		Enums[v577] = v575
	end
end)
local v576 = "Pants"
local v577 = 287
pcall(function()
	local v578 = enum[v]
	local v579 = v578 and v578[v576]

	if v579 then
		Enums[v579] = v577
	end
end)
local v578 = "Head"
local v579 = 288
pcall(function()
	local v580 = enum[v]
	local v581 = v580 and v580[v578]

	if v581 then
		Enums[v581] = v579
	end
end)
local v580 = "Face"
local v581 = 289
pcall(function()
	local v582 = enum[v]
	local v583 = v582 and v582[v580]

	if v583 then
		Enums[v583] = v581
	end
end)
local v582 = "Gear"
local v583 = 290
pcall(function()
	local v584 = enum[v]
	local v585 = v584 and v584[v582]

	if v585 then
		Enums[v585] = v583
	end
end)
local v584 = "Torso"
local v585 = 291
pcall(function()
	local v586 = enum[v]
	local v587 = v586 and v586[v584]

	if v587 then
		Enums[v587] = v585
	end
end)
local v586 = "RightArm"
local v587 = 292
pcall(function()
	local v588 = enum[v]
	local v589 = v588 and v588[v586]

	if v589 then
		Enums[v589] = v587
	end
end)
local v588 = "LeftArm"
local v589 = 293
pcall(function()
	local v590 = enum[v]
	local v591 = v590 and v590[v588]

	if v591 then
		Enums[v591] = v589
	end
end)
local v590 = "LeftLeg"
local v591 = 294
pcall(function()
	local v592 = enum[v]
	local v593 = v592 and v592[v590]

	if v593 then
		Enums[v593] = v591
	end
end)
local v592 = "RightLeg"
local v593 = 295
pcall(function()
	local v594 = enum[v]
	local v595 = v594 and v594[v592]

	if v595 then
		Enums[v595] = v593
	end
end)
local v594 = "HairAccessory"
local v595 = 296
pcall(function()
	local v596 = enum[v]
	local v597 = v596 and v596[v594]

	if v597 then
		Enums[v597] = v595
	end
end)
local v596 = "FaceAccessory"
local v597 = 297
pcall(function()
	local v598 = enum[v]
	local v599 = v598 and v598[v596]

	if v599 then
		Enums[v599] = v597
	end
end)
local v598 = "NeckAccessory"
local v599 = 298
pcall(function()
	local v600 = enum[v]
	local v601 = v600 and v600[v598]

	if v601 then
		Enums[v601] = v599
	end
end)
local v600 = "ShoulderAccessory"
local v601 = 299
pcall(function()
	local v602 = enum[v]
	local v603 = v602 and v602[v600]

	if v603 then
		Enums[v603] = v601
	end
end)
local v602 = "FrontAccessory"
local v603 = 300
pcall(function()
	local v604 = enum[v]
	local v605 = v604 and v604[v602]

	if v605 then
		Enums[v605] = v603
	end
end)
local v604 = "BackAccessory"
local v605 = 301
pcall(function()
	local v606 = enum[v]
	local v607 = v606 and v606[v604]

	if v607 then
		Enums[v607] = v605
	end
end)
local v606 = "WaistAccessory"
local v607 = 302
pcall(function()
	local v608 = enum[v]
	local v609 = v608 and v608[v606]

	if v609 then
		Enums[v609] = v607
	end
end)
local v608 = "ClimbAnimation"
local v609 = 303
pcall(function()
	local v610 = enum[v]
	local v611 = v610 and v610[v608]

	if v611 then
		Enums[v611] = v609
	end
end)
local v610 = "FallAnimation"
local v611 = 304
pcall(function()
	local v612 = enum[v]
	local v613 = v612 and v612[v610]

	if v613 then
		Enums[v613] = v611
	end
end)
local v612 = "IdleAnimation"
local v613 = 305
pcall(function()
	local v614 = enum[v]
	local v615 = v614 and v614[v612]

	if v615 then
		Enums[v615] = v613
	end
end)
local v614 = "JumpAnimation"
local v615 = 306
pcall(function()
	local v616 = enum[v]
	local v617 = v616 and v616[v614]

	if v617 then
		Enums[v617] = v615
	end
end)
local v616 = "RunAnimation"
local v617 = 307
pcall(function()
	local v618 = enum[v]
	local v619 = v618 and v618[v616]

	if v619 then
		Enums[v619] = v617
	end
end)
local v618 = "SwimAnimation"
local v619 = 308
pcall(function()
	local v620 = enum[v]
	local v621 = v620 and v620[v618]

	if v621 then
		Enums[v621] = v619
	end
end)
local v620 = "WalkAnimation"
local v621 = 309
pcall(function()
	local v622 = enum[v]
	local v623 = v622 and v622[v620]

	if v623 then
		Enums[v623] = v621
	end
end)
local v622 = "MoodAnimation"
local v623 = 310
pcall(function()
	local v624 = enum[v]
	local v625 = v624 and v624[v622]

	if v625 then
		Enums[v625] = v623
	end
end)
local v624 = "EmoteAnimation"
local v625 = 311
pcall(function()
	local v626 = enum[v]
	local v627 = v626 and v626[v624]

	if v627 then
		Enums[v627] = v625
	end
end)
local v626 = "TShirtAccessory"
local v627 = 312
pcall(function()
	local v628 = enum[v]
	local v629 = v628 and v628[v626]

	if v629 then
		Enums[v629] = v627
	end
end)
local v628 = "ShirtAccessory"
local v629 = 313
pcall(function()
	local v630 = enum[v]
	local v631 = v630 and v630[v628]

	if v631 then
		Enums[v631] = v629
	end
end)
local v630 = "PantsAccessory"
local v631 = 314
pcall(function()
	local v632 = enum[v]
	local v633 = v632 and v632[v630]

	if v633 then
		Enums[v633] = v631
	end
end)
local v632 = "JacketAccessory"
local v633 = 315
pcall(function()
	local v634 = enum[v]
	local v635 = v634 and v634[v632]

	if v635 then
		Enums[v635] = v633
	end
end)
local v634 = "SweaterAccessory"
local v635 = 316
pcall(function()
	local v636 = enum[v]
	local v637 = v636 and v636[v634]

	if v637 then
		Enums[v637] = v635
	end
end)
local v636 = "ShortsAccessory"
local v637 = 317
pcall(function()
	local v638 = enum[v]
	local v639 = v638 and v638[v636]

	if v639 then
		Enums[v639] = v637
	end
end)
local v638 = "LeftShoeAccessory"
local v639 = 318
pcall(function()
	local v640 = enum[v]
	local v641 = v640 and v640[v638]

	if v641 then
		Enums[v641] = v639
	end
end)
local v640 = "RightShoeAccessory"
local v641 = 319
pcall(function()
	local v642 = enum[v]
	local v643 = v642 and v642[v640]

	if v643 then
		Enums[v643] = v641
	end
end)
local v642 = "DressSkirtAccessory"
local v643 = 320
pcall(function()
	local v644 = enum[v]
	local v645 = v644 and v644[v642]

	if v645 then
		Enums[v645] = v643
	end
end)
local v644 = "EyebrowAccessory"
local v645 = 321
pcall(function()
	local v646 = enum[v]
	local v647 = v646 and v646[v644]

	if v647 then
		Enums[v647] = v645
	end
end)
local v646 = "EyelashAccessory"
local v647 = 322
pcall(function()
	local v648 = enum[v]
	local v649 = v648 and v648[v646]

	if v649 then
		Enums[v649] = v647
	end
end)
local v648 = "DynamicHead"
local v649 = 323
pcall(function()
	local v650 = enum[v]
	local v651 = v650 and v650[v648]

	if v651 then
		Enums[v651] = v649
	end
end)
v = "AvatarChatServiceFeature"
local v650 = "None"
local v651 = 324
pcall(function()
	local v652 = enum[v]
	local v653 = v652 and v652[v650]

	if v653 then
		Enums[v653] = v651
	end
end)
local v652 = "UniverseAudio"
local v653 = 325
pcall(function()
	local v654 = enum[v]
	local v655 = v654 and v654[v652]

	if v655 then
		Enums[v655] = v653
	end
end)
local v654 = "UniverseVideo"
local v655 = 326
pcall(function()
	local v656 = enum[v]
	local v657 = v656 and v656[v654]

	if v657 then
		Enums[v657] = v655
	end
end)
local v656 = "PlaceAudio"
local v657 = 327
pcall(function()
	local v658 = enum[v]
	local v659 = v658 and v658[v656]

	if v659 then
		Enums[v659] = v657
	end
end)
local v658 = "PlaceVideo"
local v659 = 328
pcall(function()
	local v660 = enum[v]
	local v661 = v660 and v660[v658]

	if v661 then
		Enums[v661] = v659
	end
end)
local v660 = "UserAudioEligible"
local v661 = 329
pcall(function()
	local v662 = enum[v]
	local v663 = v662 and v662[v660]

	if v663 then
		Enums[v663] = v661
	end
end)
local v662 = "UserAudio"
local v663 = 330
pcall(function()
	local v664 = enum[v]
	local v665 = v664 and v664[v662]

	if v665 then
		Enums[v665] = v663
	end
end)
local v664 = "UserVideoEligible"
local v665 = 331
pcall(function()
	local v666 = enum[v]
	local v667 = v666 and v666[v664]

	if v667 then
		Enums[v667] = v665
	end
end)
local v666 = "UserVideo"
local v667 = 332
pcall(function()
	local v668 = enum[v]
	local v669 = v668 and v668[v666]

	if v669 then
		Enums[v669] = v667
	end
end)
local v668 = "UserBanned"
local v669 = 333
pcall(function()
	local v670 = enum[v]
	local v671 = v670 and v670[v668]

	if v671 then
		Enums[v671] = v669
	end
end)
local v670 = "UserVerifiedForVoice"
local v671 = 334
pcall(function()
	local v672 = enum[v]
	local v673 = v672 and v672[v670]

	if v673 then
		Enums[v673] = v671
	end
end)
v = "AvatarContextMenuOption"
local v672 = "Friend"
local v673 = 335
pcall(function()
	local v674 = enum[v]
	local v675 = v674 and v674[v672]

	if v675 then
		Enums[v675] = v673
	end
end)
local v674 = "Chat"
local v675 = 336
pcall(function()
	local v676 = enum[v]
	local v677 = v676 and v676[v674]

	if v677 then
		Enums[v677] = v675
	end
end)
local v676 = "Emote"
local v677 = 337
pcall(function()
	local v678 = enum[v]
	local v679 = v678 and v678[v676]

	if v679 then
		Enums[v679] = v677
	end
end)
local v678 = "InspectMenu"
local v679 = 338
pcall(function()
	local v680 = enum[v]
	local v681 = v680 and v680[v678]

	if v681 then
		Enums[v681] = v679
	end
end)
v = "AvatarGenerationError"
local v680 = "None"
local v681 = 339
pcall(function()
	local v682 = enum[v]
	local v683 = v682 and v682[v680]

	if v683 then
		Enums[v683] = v681
	end
end)
local v682 = "Unknown"
local v683 = 340
pcall(function()
	local v684 = enum[v]
	local v685 = v684 and v684[v682]

	if v685 then
		Enums[v685] = v683
	end
end)
local v684 = "DownloadFailed"
local v685 = 341
pcall(function()
	local v686 = enum[v]
	local v687 = v686 and v686[v684]

	if v687 then
		Enums[v687] = v685
	end
end)
local v686 = "Canceled"
local v687 = 342
pcall(function()
	local v688 = enum[v]
	local v689 = v688 and v688[v686]

	if v689 then
		Enums[v689] = v687
	end
end)
local v688 = "Offensive"
local v689 = 343
pcall(function()
	local v690 = enum[v]
	local v691 = v690 and v690[v688]

	if v691 then
		Enums[v691] = v689
	end
end)
local v690 = "Timeout"
local v691 = 344
pcall(function()
	local v692 = enum[v]
	local v693 = v692 and v692[v690]

	if v693 then
		Enums[v693] = v691
	end
end)
local v692 = "JobNotFound"
local v693 = 345
pcall(function()
	local v694 = enum[v]
	local v695 = v694 and v694[v692]

	if v695 then
		Enums[v695] = v693
	end
end)
v = "AvatarItemType"
local v694 = "Asset"
local v695 = 346
pcall(function()
	local v696 = enum[v]
	local v697 = v696 and v696[v694]

	if v697 then
		Enums[v697] = v695
	end
end)
local v696 = "Bundle"
local v697 = 347
pcall(function()
	local v698 = enum[v]
	local v699 = v698 and v698[v696]

	if v699 then
		Enums[v699] = v697
	end
end)
v = "AvatarPromptResult"
local v698 = "Success"
local v699 = 348
pcall(function()
	local v700 = enum[v]
	local v701 = v700 and v700[v698]

	if v701 then
		Enums[v701] = v699
	end
end)
local v700 = "PermissionDenied"
local v701 = 349
pcall(function()
	local v702 = enum[v]
	local v703 = v702 and v702[v700]

	if v703 then
		Enums[v703] = v701
	end
end)
local v702 = "Failed"
local v703 = 350
pcall(function()
	local v704 = enum[v]
	local v705 = v704 and v704[v702]

	if v705 then
		Enums[v705] = v703
	end
end)
v = "AvatarThumbnailCustomizationType"
local v704 = "Closeup"
local v705 = 351
pcall(function()
	local v706 = enum[v]
	local v707 = v706 and v706[v704]

	if v707 then
		Enums[v707] = v705
	end
end)
local v706 = "FullBody"
local v707 = 352
pcall(function()
	local v708 = enum[v]
	local v709 = v708 and v708[v706]

	if v709 then
		Enums[v709] = v707
	end
end)
v = "AvatarUnificationMode"
local v708 = "Default"
local v709 = 353
pcall(function()
	local v710 = enum[v]
	local v711 = v710 and v710[v708]

	if v711 then
		Enums[v711] = v709
	end
end)
local v710 = "Disabled"
local v711 = 354
pcall(function()
	local v712 = enum[v]
	local v713 = v712 and v712[v710]

	if v713 then
		Enums[v713] = v711
	end
end)
local v712 = "Enabled"
local v713 = 355
pcall(function()
	local v714 = enum[v]
	local v715 = v714 and v714[v712]

	if v715 then
		Enums[v715] = v713
	end
end)
v = "Axis"
local v714 = "X"
local v715 = 356
pcall(function()
	local v716 = enum[v]
	local v717 = v716 and v716[v714]

	if v717 then
		Enums[v717] = v715
	end
end)
local v716 = "Y"
local v717 = 357
pcall(function()
	local v718 = enum[v]
	local v719 = v718 and v718[v716]

	if v719 then
		Enums[v719] = v717
	end
end)
local v718 = "Z"
local v719 = 358
pcall(function()
	local v720 = enum[v]
	local v721 = v720 and v720[v718]

	if v721 then
		Enums[v721] = v719
	end
end)
v = "BenefitType"
local v720 = "DeveloperProduct"
local v721 = 359
pcall(function()
	local v722 = enum[v]
	local v723 = v722 and v722[v720]

	if v723 then
		Enums[v723] = v721
	end
end)
local v722 = "AvatarAsset"
local v723 = 360
pcall(function()
	local v724 = enum[v]
	local v725 = v724 and v724[v722]

	if v725 then
		Enums[v725] = v723
	end
end)
local v724 = "AvatarBundle"
local v725 = 361
pcall(function()
	local v726 = enum[v]
	local v727 = v726 and v726[v724]

	if v727 then
		Enums[v727] = v725
	end
end)
v = "BinType"
local v726 = "Script"
local v727 = 362
pcall(function()
	local v728 = enum[v]
	local v729 = v728 and v728[v726]

	if v729 then
		Enums[v729] = v727
	end
end)
local v728 = "GameTool"
local v729 = 363
pcall(function()
	local v730 = enum[v]
	local v731 = v730 and v730[v728]

	if v731 then
		Enums[v731] = v729
	end
end)
local v730 = "Grab"
local v731 = 364
pcall(function()
	local v732 = enum[v]
	local v733 = v732 and v732[v730]

	if v733 then
		Enums[v733] = v731
	end
end)
local v732 = "Clone"
local v733 = 365
pcall(function()
	local v734 = enum[v]
	local v735 = v734 and v734[v732]

	if v735 then
		Enums[v735] = v733
	end
end)
local v734 = "Hammer"
local v735 = 366
pcall(function()
	local v736 = enum[v]
	local v737 = v736 and v736[v734]

	if v737 then
		Enums[v737] = v735
	end
end)
v = "BodyPart"
local v736 = "Head"
local v737 = 367
pcall(function()
	local v738 = enum[v]
	local v739 = v738 and v738[v736]

	if v739 then
		Enums[v739] = v737
	end
end)
local v738 = "Torso"
local v739 = 368
pcall(function()
	local v740 = enum[v]
	local v741 = v740 and v740[v738]

	if v741 then
		Enums[v741] = v739
	end
end)
local v740 = "LeftArm"
local v741 = 369
pcall(function()
	local v742 = enum[v]
	local v743 = v742 and v742[v740]

	if v743 then
		Enums[v743] = v741
	end
end)
local v742 = "RightArm"
local v743 = 370
pcall(function()
	local v744 = enum[v]
	local v745 = v744 and v744[v742]

	if v745 then
		Enums[v745] = v743
	end
end)
local v744 = "LeftLeg"
local v745 = 371
pcall(function()
	local v746 = enum[v]
	local v747 = v746 and v746[v744]

	if v747 then
		Enums[v747] = v745
	end
end)
local v746 = "RightLeg"
local v747 = 372
pcall(function()
	local v748 = enum[v]
	local v749 = v748 and v748[v746]

	if v749 then
		Enums[v749] = v747
	end
end)
v = "BodyPartR15"
local v748 = "Head"
local v749 = 373
pcall(function()
	local v750 = enum[v]
	local v751 = v750 and v750[v748]

	if v751 then
		Enums[v751] = v749
	end
end)
local v750 = "UpperTorso"
local v751 = 374
pcall(function()
	local v752 = enum[v]
	local v753 = v752 and v752[v750]

	if v753 then
		Enums[v753] = v751
	end
end)
local v752 = "LowerTorso"
local v753 = 375
pcall(function()
	local v754 = enum[v]
	local v755 = v754 and v754[v752]

	if v755 then
		Enums[v755] = v753
	end
end)
local v754 = "LeftFoot"
local v755 = 376
pcall(function()
	local v756 = enum[v]
	local v757 = v756 and v756[v754]

	if v757 then
		Enums[v757] = v755
	end
end)
local v756 = "LeftLowerLeg"
local v757 = 377
pcall(function()
	local v758 = enum[v]
	local v759 = v758 and v758[v756]

	if v759 then
		Enums[v759] = v757
	end
end)
local v758 = "LeftUpperLeg"
local v759 = 378
pcall(function()
	local v760 = enum[v]
	local v761 = v760 and v760[v758]

	if v761 then
		Enums[v761] = v759
	end
end)
local v760 = "RightFoot"
local v761 = 379
pcall(function()
	local v762 = enum[v]
	local v763 = v762 and v762[v760]

	if v763 then
		Enums[v763] = v761
	end
end)
local v762 = "RightLowerLeg"
local v763 = 380
pcall(function()
	local v764 = enum[v]
	local v765 = v764 and v764[v762]

	if v765 then
		Enums[v765] = v763
	end
end)
local v764 = "RightUpperLeg"
local v765 = 381
pcall(function()
	local v766 = enum[v]
	local v767 = v766 and v766[v764]

	if v767 then
		Enums[v767] = v765
	end
end)
local v766 = "LeftHand"
local v767 = 382
pcall(function()
	local v768 = enum[v]
	local v769 = v768 and v768[v766]

	if v769 then
		Enums[v769] = v767
	end
end)
local v768 = "LeftLowerArm"
local v769 = 383
pcall(function()
	local v770 = enum[v]
	local v771 = v770 and v770[v768]

	if v771 then
		Enums[v771] = v769
	end
end)
local v770 = "LeftUpperArm"
local v771 = 384
pcall(function()
	local v772 = enum[v]
	local v773 = v772 and v772[v770]

	if v773 then
		Enums[v773] = v771
	end
end)
local v772 = "RightHand"
local v773 = 385
pcall(function()
	local v774 = enum[v]
	local v775 = v774 and v774[v772]

	if v775 then
		Enums[v775] = v773
	end
end)
local v774 = "RightLowerArm"
local v775 = 386
pcall(function()
	local v776 = enum[v]
	local v777 = v776 and v776[v774]

	if v777 then
		Enums[v777] = v775
	end
end)
local v776 = "RightUpperArm"
local v777 = 387
pcall(function()
	local v778 = enum[v]
	local v779 = v778 and v778[v776]

	if v779 then
		Enums[v779] = v777
	end
end)
local v778 = "RootPart"
local v779 = 388
pcall(function()
	local v780 = enum[v]
	local v781 = v780 and v780[v778]

	if v781 then
		Enums[v781] = v779
	end
end)
local v780 = "Unknown"
local v781 = 389
pcall(function()
	local v782 = enum[v]
	local v783 = v782 and v782[v780]

	if v783 then
		Enums[v783] = v781
	end
end)
v = "BorderMode"
local v782 = "Outline"
local v783 = 390
pcall(function()
	local v784 = enum[v]
	local v785 = v784 and v784[v782]

	if v785 then
		Enums[v785] = v783
	end
end)
local v784 = "Middle"
local v785 = 391
pcall(function()
	local v786 = enum[v]
	local v787 = v786 and v786[v784]

	if v787 then
		Enums[v787] = v785
	end
end)
local v786 = "Inset"
local v787 = 392
pcall(function()
	local v788 = enum[v]
	local v789 = v788 and v788[v786]

	if v789 then
		Enums[v789] = v787
	end
end)
v = "BreakReason"
local v788 = "Other"
local v789 = 393
pcall(function()
	local v790 = enum[v]
	local v791 = v790 and v790[v788]

	if v791 then
		Enums[v791] = v789
	end
end)
local v790 = "Error"
local v791 = 394
pcall(function()
	local v792 = enum[v]
	local v793 = v792 and v792[v790]

	if v793 then
		Enums[v793] = v791
	end
end)
local v792 = "SpecialBreakpoint"
local v793 = 395
pcall(function()
	local v794 = enum[v]
	local v795 = v794 and v794[v792]

	if v795 then
		Enums[v795] = v793
	end
end)
local v794 = "UserBreakpoint"
local v795 = 396
pcall(function()
	local v796 = enum[v]
	local v797 = v796 and v796[v794]

	if v797 then
		Enums[v797] = v795
	end
end)
v = "BreakpointRemoveReason"
local v796 = "Requested"
local v797 = 397
pcall(function()
	local v798 = enum[v]
	local v799 = v798 and v798[v796]

	if v799 then
		Enums[v799] = v797
	end
end)
local v798 = "ScriptChanged"
local v799 = 398
pcall(function()
	local v800 = enum[v]
	local v801 = v800 and v800[v798]

	if v801 then
		Enums[v801] = v799
	end
end)
local v800 = "ScriptRemoved"
local v801 = 399
pcall(function()
	local v802 = enum[v]
	local v803 = v802 and v802[v800]

	if v803 then
		Enums[v803] = v801
	end
end)
v = "BulkMoveMode"
local v802 = "FireAllEvents"
local v803 = 400
pcall(function()
	local v804 = enum[v]
	local v805 = v804 and v804[v802]

	if v805 then
		Enums[v805] = v803
	end
end)
local v804 = "FireCFrameChanged"
local v805 = 401
pcall(function()
	local v806 = enum[v]
	local v807 = v806 and v806[v804]

	if v807 then
		Enums[v807] = v805
	end
end)
v = "BundleType"
local v806 = "BodyParts"
local v807 = 402
pcall(function()
	local v808 = enum[v]
	local v809 = v808 and v808[v806]

	if v809 then
		Enums[v809] = v807
	end
end)
local v808 = "Animations"
local v809 = 403
pcall(function()
	local v810 = enum[v]
	local v811 = v810 and v810[v808]

	if v811 then
		Enums[v811] = v809
	end
end)
local v810 = "Shoes"
local v811 = 404
pcall(function()
	local v812 = enum[v]
	local v813 = v812 and v812[v810]

	if v813 then
		Enums[v813] = v811
	end
end)
local v812 = "DynamicHead"
local v813 = 405
pcall(function()
	local v814 = enum[v]
	local v815 = v814 and v814[v812]

	if v815 then
		Enums[v815] = v813
	end
end)
local v814 = "DynamicHeadAvatar"
local v815 = 406
pcall(function()
	local v816 = enum[v]
	local v817 = v816 and v816[v814]

	if v817 then
		Enums[v817] = v815
	end
end)
v = "Button"
local v816 = "Jump"
local v817 = 407
pcall(function()
	local v818 = enum[v]
	local v819 = v818 and v818[v816]

	if v819 then
		Enums[v819] = v817
	end
end)
local v818 = "Dismount"
local v819 = 408
pcall(function()
	local v820 = enum[v]
	local v821 = v820 and v820[v818]

	if v821 then
		Enums[v821] = v819
	end
end)
v = "ButtonStyle"
local v820 = "Custom"
local v821 = 409
pcall(function()
	local v822 = enum[v]
	local v823 = v822 and v822[v820]

	if v823 then
		Enums[v823] = v821
	end
end)
local v822 = "RobloxButtonDefault"
local v823 = 410
pcall(function()
	local v824 = enum[v]
	local v825 = v824 and v824[v822]

	if v825 then
		Enums[v825] = v823
	end
end)
local v824 = "RobloxButton"
local v825 = 411
pcall(function()
	local v826 = enum[v]
	local v827 = v826 and v826[v824]

	if v827 then
		Enums[v827] = v825
	end
end)
local v826 = "RobloxRoundButton"
local v827 = 412
pcall(function()
	local v828 = enum[v]
	local v829 = v828 and v828[v826]

	if v829 then
		Enums[v829] = v827
	end
end)
local v828 = "RobloxRoundDefaultButton"
local v829 = 413
pcall(function()
	local v830 = enum[v]
	local v831 = v830 and v830[v828]

	if v831 then
		Enums[v831] = v829
	end
end)
local v830 = "RobloxRoundDropdownButton"
local v831 = 414
pcall(function()
	local v832 = enum[v]
	local v833 = v832 and v832[v830]

	if v833 then
		Enums[v833] = v831
	end
end)
v = "CageType"
local v832 = "Inner"
local v833 = 415
pcall(function()
	local v834 = enum[v]
	local v835 = v834 and v834[v832]

	if v835 then
		Enums[v835] = v833
	end
end)
local v834 = "Outer"
local v835 = 416
pcall(function()
	local v836 = enum[v]
	local v837 = v836 and v836[v834]

	if v837 then
		Enums[v837] = v835
	end
end)
v = "CameraMode"
local v836 = "Classic"
local v837 = 417
pcall(function()
	local v838 = enum[v]
	local v839 = v838 and v838[v836]

	if v839 then
		Enums[v839] = v837
	end
end)
local v838 = "LockFirstPerson"
local v839 = 418
pcall(function()
	local v840 = enum[v]
	local v841 = v840 and v840[v838]

	if v841 then
		Enums[v841] = v839
	end
end)
v = "CameraPanMode"
local v840 = "Classic"
local v841 = 419
pcall(function()
	local v842 = enum[v]
	local v843 = v842 and v842[v840]

	if v843 then
		Enums[v843] = v841
	end
end)
local v842 = "EdgeBump"
local v843 = 420
pcall(function()
	local v844 = enum[v]
	local v845 = v844 and v844[v842]

	if v845 then
		Enums[v845] = v843
	end
end)
v = "CameraSpeedAdjustBinding"
local v844 = "None"
local v845 = 421
pcall(function()
	local v846 = enum[v]
	local v847 = v846 and v846[v844]

	if v847 then
		Enums[v847] = v845
	end
end)
local v846 = "RmbScroll"
local v847 = 422
pcall(function()
	local v848 = enum[v]
	local v849 = v848 and v848[v846]

	if v849 then
		Enums[v849] = v847
	end
end)
local v848 = "AltScroll"
local v849 = 423
pcall(function()
	local v850 = enum[v]
	local v851 = v850 and v850[v848]

	if v851 then
		Enums[v851] = v849
	end
end)
v = "CameraType"
local v850 = "Fixed"
local v851 = 424
pcall(function()
	local v852 = enum[v]
	local v853 = v852 and v852[v850]

	if v853 then
		Enums[v853] = v851
	end
end)
local v852 = "Attach"
local v853 = 425
pcall(function()
	local v854 = enum[v]
	local v855 = v854 and v854[v852]

	if v855 then
		Enums[v855] = v853
	end
end)
local v854 = "Watch"
local v855 = 426
pcall(function()
	local v856 = enum[v]
	local v857 = v856 and v856[v854]

	if v857 then
		Enums[v857] = v855
	end
end)
local v856 = "Track"
local v857 = 427
pcall(function()
	local v858 = enum[v]
	local v859 = v858 and v858[v856]

	if v859 then
		Enums[v859] = v857
	end
end)
local v858 = "Follow"
local v859 = 428
pcall(function()
	local v860 = enum[v]
	local v861 = v860 and v860[v858]

	if v861 then
		Enums[v861] = v859
	end
end)
local v860 = "Custom"
local v861 = 429
pcall(function()
	local v862 = enum[v]
	local v863 = v862 and v862[v860]

	if v863 then
		Enums[v863] = v861
	end
end)
local v862 = "Scriptable"
local v863 = 430
pcall(function()
	local v864 = enum[v]
	local v865 = v864 and v864[v862]

	if v865 then
		Enums[v865] = v863
	end
end)
local v864 = "Orbital"
local v865 = 431
pcall(function()
	local v866 = enum[v]
	local v867 = v866 and v866[v864]

	if v867 then
		Enums[v867] = v865
	end
end)
v = "CatalogCategoryFilter"
local v866 = "None"
local v867 = 432
pcall(function()
	local v868 = enum[v]
	local v869 = v868 and v868[v866]

	if v869 then
		Enums[v869] = v867
	end
end)
local v868 = "Featured"
local v869 = 433
pcall(function()
	local v870 = enum[v]
	local v871 = v870 and v870[v868]

	if v871 then
		Enums[v871] = v869
	end
end)
local v870 = "Collectibles"
local v871 = 434
pcall(function()
	local v872 = enum[v]
	local v873 = v872 and v872[v870]

	if v873 then
		Enums[v873] = v871
	end
end)
local v872 = "CommunityCreations"
local v873 = 435
pcall(function()
	local v874 = enum[v]
	local v875 = v874 and v874[v872]

	if v875 then
		Enums[v875] = v873
	end
end)
local v874 = "Premium"
local v875 = 436
pcall(function()
	local v876 = enum[v]
	local v877 = v876 and v876[v874]

	if v877 then
		Enums[v877] = v875
	end
end)
local v876 = "Recommended"
local v877 = 437
pcall(function()
	local v878 = enum[v]
	local v879 = v878 and v878[v876]

	if v879 then
		Enums[v879] = v877
	end
end)
v = "CatalogSortAggregation"
local v878 = "Past12Hours"
local v879 = 438
pcall(function()
	local v880 = enum[v]
	local v881 = v880 and v880[v878]

	if v881 then
		Enums[v881] = v879
	end
end)
local v880 = "PastDay"
local v881 = 439
pcall(function()
	local v882 = enum[v]
	local v883 = v882 and v882[v880]

	if v883 then
		Enums[v883] = v881
	end
end)
local v882 = "Past3Days"
local v883 = 440
pcall(function()
	local v884 = enum[v]
	local v885 = v884 and v884[v882]

	if v885 then
		Enums[v885] = v883
	end
end)
local v884 = "PastWeek"
local v885 = 441
pcall(function()
	local v886 = enum[v]
	local v887 = v886 and v886[v884]

	if v887 then
		Enums[v887] = v885
	end
end)
local v886 = "PastMonth"
local v887 = 442
pcall(function()
	local v888 = enum[v]
	local v889 = v888 and v888[v886]

	if v889 then
		Enums[v889] = v887
	end
end)
local v888 = "AllTime"
local v889 = 443
pcall(function()
	local v890 = enum[v]
	local v891 = v890 and v890[v888]

	if v891 then
		Enums[v891] = v889
	end
end)
v = "CatalogSortType"
local v890 = "Relevance"
local v891 = 444
pcall(function()
	local v892 = enum[v]
	local v893 = v892 and v892[v890]

	if v893 then
		Enums[v893] = v891
	end
end)
local v892 = "PriceHighToLow"
local v893 = 445
pcall(function()
	local v894 = enum[v]
	local v895 = v894 and v894[v892]

	if v895 then
		Enums[v895] = v893
	end
end)
local v894 = "PriceLowToHigh"
local v895 = 446
pcall(function()
	local v896 = enum[v]
	local v897 = v896 and v896[v894]

	if v897 then
		Enums[v897] = v895
	end
end)
local v896 = "MostFavorited"
local v897 = 447
pcall(function()
	local v898 = enum[v]
	local v899 = v898 and v898[v896]

	if v899 then
		Enums[v899] = v897
	end
end)
local v898 = "RecentlyCreated"
local v899 = 448
pcall(function()
	local v900 = enum[v]
	local v901 = v900 and v900[v898]

	if v901 then
		Enums[v901] = v899
	end
end)
local v900 = "Bestselling"
local v901 = 449
pcall(function()
	local v902 = enum[v]
	local v903 = v902 and v902[v900]

	if v903 then
		Enums[v903] = v901
	end
end)
v = "CellBlock"
local v902 = "Solid"
local v903 = 450
pcall(function()
	local v904 = enum[v]
	local v905 = v904 and v904[v902]

	if v905 then
		Enums[v905] = v903
	end
end)
local v904 = "VerticalWedge"
local v905 = 451
pcall(function()
	local v906 = enum[v]
	local v907 = v906 and v906[v904]

	if v907 then
		Enums[v907] = v905
	end
end)
local v906 = "CornerWedge"
local v907 = 452
pcall(function()
	local v908 = enum[v]
	local v909 = v908 and v908[v906]

	if v909 then
		Enums[v909] = v907
	end
end)
local v908 = "InverseCornerWedge"
local v909 = 453
pcall(function()
	local v910 = enum[v]
	local v911 = v910 and v910[v908]

	if v911 then
		Enums[v911] = v909
	end
end)
local v910 = "HorizontalWedge"
local v911 = 454
pcall(function()
	local v912 = enum[v]
	local v913 = v912 and v912[v910]

	if v913 then
		Enums[v913] = v911
	end
end)
v = "CellMaterial"
local v912 = "Empty"
local v913 = 455
pcall(function()
	local v914 = enum[v]
	local v915 = v914 and v914[v912]

	if v915 then
		Enums[v915] = v913
	end
end)
local v914 = "Grass"
local v915 = 456
pcall(function()
	local v916 = enum[v]
	local v917 = v916 and v916[v914]

	if v917 then
		Enums[v917] = v915
	end
end)
local v916 = "Sand"
local v917 = 457
pcall(function()
	local v918 = enum[v]
	local v919 = v918 and v918[v916]

	if v919 then
		Enums[v919] = v917
	end
end)
local v918 = "Brick"
local v919 = 458
pcall(function()
	local v920 = enum[v]
	local v921 = v920 and v920[v918]

	if v921 then
		Enums[v921] = v919
	end
end)
local v920 = "Granite"
local v921 = 459
pcall(function()
	local v922 = enum[v]
	local v923 = v922 and v922[v920]

	if v923 then
		Enums[v923] = v921
	end
end)
local v922 = "Asphalt"
local v923 = 460
pcall(function()
	local v924 = enum[v]
	local v925 = v924 and v924[v922]

	if v925 then
		Enums[v925] = v923
	end
end)
local v924 = "Iron"
local v925 = 461
pcall(function()
	local v926 = enum[v]
	local v927 = v926 and v926[v924]

	if v927 then
		Enums[v927] = v925
	end
end)
local v926 = "Aluminum"
local v927 = 462
pcall(function()
	local v928 = enum[v]
	local v929 = v928 and v928[v926]

	if v929 then
		Enums[v929] = v927
	end
end)
local v928 = "Gold"
local v929 = 463
pcall(function()
	local v930 = enum[v]
	local v931 = v930 and v930[v928]

	if v931 then
		Enums[v931] = v929
	end
end)
local v930 = "WoodPlank"
local v931 = 464
pcall(function()
	local v932 = enum[v]
	local v933 = v932 and v932[v930]

	if v933 then
		Enums[v933] = v931
	end
end)
local v932 = "WoodLog"
local v933 = 465
pcall(function()
	local v934 = enum[v]
	local v935 = v934 and v934[v932]

	if v935 then
		Enums[v935] = v933
	end
end)
local v934 = "Gravel"
local v935 = 466
pcall(function()
	local v936 = enum[v]
	local v937 = v936 and v936[v934]

	if v937 then
		Enums[v937] = v935
	end
end)
local v936 = "CinderBlock"
local v937 = 467
pcall(function()
	local v938 = enum[v]
	local v939 = v938 and v938[v936]

	if v939 then
		Enums[v939] = v937
	end
end)
local v938 = "MossyStone"
local v939 = 468
pcall(function()
	local v940 = enum[v]
	local v941 = v940 and v940[v938]

	if v941 then
		Enums[v941] = v939
	end
end)
local v940 = "Cement"
local v941 = 469
pcall(function()
	local v942 = enum[v]
	local v943 = v942 and v942[v940]

	if v943 then
		Enums[v943] = v941
	end
end)
local v942 = "RedPlastic"
local v943 = 470
pcall(function()
	local v944 = enum[v]
	local v945 = v944 and v944[v942]

	if v945 then
		Enums[v945] = v943
	end
end)
local v944 = "BluePlastic"
local v945 = 471
pcall(function()
	local v946 = enum[v]
	local v947 = v946 and v946[v944]

	if v947 then
		Enums[v947] = v945
	end
end)
local v946 = "Water"
local v947 = 472
pcall(function()
	local v948 = enum[v]
	local v949 = v948 and v948[v946]

	if v949 then
		Enums[v949] = v947
	end
end)
v = "CellOrientation"
local v948 = "NegZ"
local v949 = 473
pcall(function()
	local v950 = enum[v]
	local v951 = v950 and v950[v948]

	if v951 then
		Enums[v951] = v949
	end
end)
local v950 = "X"
local v951 = 474
pcall(function()
	local v952 = enum[v]
	local v953 = v952 and v952[v950]

	if v953 then
		Enums[v953] = v951
	end
end)
local v952 = "Z"
local v953 = 475
pcall(function()
	local v954 = enum[v]
	local v955 = v954 and v954[v952]

	if v955 then
		Enums[v955] = v953
	end
end)
local v954 = "NegX"
local v955 = 476
pcall(function()
	local v956 = enum[v]
	local v957 = v956 and v956[v954]

	if v957 then
		Enums[v957] = v955
	end
end)
v = "CenterDialogType"
local v956 = "UnsolicitedDialog"
local v957 = 477
pcall(function()
	local v958 = enum[v]
	local v959 = v958 and v958[v956]

	if v959 then
		Enums[v959] = v957
	end
end)
local v958 = "PlayerInitiatedDialog"
local v959 = 478
pcall(function()
	local v960 = enum[v]
	local v961 = v960 and v960[v958]

	if v961 then
		Enums[v961] = v959
	end
end)
local v960 = "ModalDialog"
local v961 = 479
pcall(function()
	local v962 = enum[v]
	local v963 = v962 and v962[v960]

	if v963 then
		Enums[v963] = v961
	end
end)
local v962 = "QuitDialog"
local v963 = 480
pcall(function()
	local v964 = enum[v]
	local v965 = v964 and v964[v962]

	if v965 then
		Enums[v965] = v963
	end
end)
v = "CharacterControlMode"
local v964 = "Default"
local v965 = 481
pcall(function()
	local v966 = enum[v]
	local v967 = v966 and v966[v964]

	if v967 then
		Enums[v967] = v965
	end
end)
local v966 = "Legacy"
local v967 = 482
pcall(function()
	local v968 = enum[v]
	local v969 = v968 and v968[v966]

	if v969 then
		Enums[v969] = v967
	end
end)
local v968 = "NoCharacterController"
local v969 = 483
pcall(function()
	local v970 = enum[v]
	local v971 = v970 and v970[v968]

	if v971 then
		Enums[v971] = v969
	end
end)
local v970 = "LuaCharacterController"
local v971 = 484
pcall(function()
	local v972 = enum[v]
	local v973 = v972 and v972[v970]

	if v973 then
		Enums[v973] = v971
	end
end)
v = "ChatCallbackType"
local v972 = "OnCreatingChatWindow"
local v973 = 485
pcall(function()
	local v974 = enum[v]
	local v975 = v974 and v974[v972]

	if v975 then
		Enums[v975] = v973
	end
end)
local v974 = "OnClientSendingMessage"
local v975 = 486
pcall(function()
	local v976 = enum[v]
	local v977 = v976 and v976[v974]

	if v977 then
		Enums[v977] = v975
	end
end)
local v976 = "OnClientFormattingMessage"
local v977 = 487
pcall(function()
	local v978 = enum[v]
	local v979 = v978 and v978[v976]

	if v979 then
		Enums[v979] = v977
	end
end)
local v978 = "OnServerReceivingMessage"
local v979 = 488
pcall(function()
	local v980 = enum[v]
	local v981 = v980 and v980[v978]

	if v981 then
		Enums[v981] = v979
	end
end)
v = "ChatColor"
local v980 = "Blue"
local v981 = 489
pcall(function()
	local v982 = enum[v]
	local v983 = v982 and v982[v980]

	if v983 then
		Enums[v983] = v981
	end
end)
local v982 = "Green"
local v983 = 490
pcall(function()
	local v984 = enum[v]
	local v985 = v984 and v984[v982]

	if v985 then
		Enums[v985] = v983
	end
end)
local v984 = "Red"
local v985 = 491
pcall(function()
	local v986 = enum[v]
	local v987 = v986 and v986[v984]

	if v987 then
		Enums[v987] = v985
	end
end)
local v986 = "White"
local v987 = 492
pcall(function()
	local v988 = enum[v]
	local v989 = v988 and v988[v986]

	if v989 then
		Enums[v989] = v987
	end
end)
v = "ChatMode"
local v988 = "Menu"
local v989 = 493
pcall(function()
	local v990 = enum[v]
	local v991 = v990 and v990[v988]

	if v991 then
		Enums[v991] = v989
	end
end)
local v990 = "TextAndMenu"
local v991 = 494
pcall(function()
	local v992 = enum[v]
	local v993 = v992 and v992[v990]

	if v993 then
		Enums[v993] = v991
	end
end)
v = "ChatPrivacyMode"
local v992 = "AllUsers"
local v993 = 495
pcall(function()
	local v994 = enum[v]
	local v995 = v994 and v994[v992]

	if v995 then
		Enums[v995] = v993
	end
end)
local v994 = "NoOne"
local v995 = 496
pcall(function()
	local v996 = enum[v]
	local v997 = v996 and v996[v994]

	if v997 then
		Enums[v997] = v995
	end
end)
local v996 = "Friends"
local v997 = 497
pcall(function()
	local v998 = enum[v]
	local v999 = v998 and v998[v996]

	if v999 then
		Enums[v999] = v997
	end
end)
v = "ChatRestrictionStatus"
local v998 = "Unknown"
local v999 = 498
pcall(function()
	local v1000 = enum[v]
	local v1001 = v1000 and v1000[v998]

	if v1001 then
		Enums[v1001] = v999
	end
end)
local v1000 = "NotRestricted"
local v1001 = 499
pcall(function()
	local v1002 = enum[v]
	local v1003 = v1002 and v1002[v1000]

	if v1003 then
		Enums[v1003] = v1001
	end
end)
local v1002 = "Restricted"
local v1003 = 500
pcall(function()
	local v1004 = enum[v]
	local v1005 = v1004 and v1004[v1002]

	if v1005 then
		Enums[v1005] = v1003
	end
end)
v = "ChatStyle"
local v1004 = "Classic"
local v1005 = 501
pcall(function()
	local v1006 = enum[v]
	local v1007 = v1006 and v1006[v1004]

	if v1007 then
		Enums[v1007] = v1005
	end
end)
local v1006 = "Bubble"
local v1007 = 502
pcall(function()
	local v1008 = enum[v]
	local v1009 = v1008 and v1008[v1006]

	if v1009 then
		Enums[v1009] = v1007
	end
end)
local v1008 = "ClassicAndBubble"
local v1009 = 503
pcall(function()
	local v1010 = enum[v]
	local v1011 = v1010 and v1010[v1008]

	if v1011 then
		Enums[v1011] = v1009
	end
end)
v = "ChatVersion"
local v1010 = "LegacyChatService"
local v1011 = 504
pcall(function()
	local v1012 = enum[v]
	local v1013 = v1012 and v1012[v1010]

	if v1013 then
		Enums[v1013] = v1011
	end
end)
local v1012 = "TextChatService"
local v1013 = 505
pcall(function()
	local v1014 = enum[v]
	local v1015 = v1014 and v1014[v1012]

	if v1015 then
		Enums[v1015] = v1013
	end
end)
v = "ClientAnimatorThrottlingMode"
local v1014 = "Default"
local v1015 = 506
pcall(function()
	local v1016 = enum[v]
	local v1017 = v1016 and v1016[v1014]

	if v1017 then
		Enums[v1017] = v1015
	end
end)
local v1016 = "Disabled"
local v1017 = 507
pcall(function()
	local v1018 = enum[v]
	local v1019 = v1018 and v1018[v1016]

	if v1019 then
		Enums[v1019] = v1017
	end
end)
local v1018 = "Enabled"
local v1019 = 508
pcall(function()
	local v1020 = enum[v]
	local v1021 = v1020 and v1020[v1018]

	if v1021 then
		Enums[v1021] = v1019
	end
end)
v = "CloseReason"
local v1020 = "Unknown"
local v1021 = 509
pcall(function()
	local v1022 = enum[v]
	local v1023 = v1022 and v1022[v1020]

	if v1023 then
		Enums[v1023] = v1021
	end
end)
local v1022 = "RobloxMaintenance"
local v1023 = 510
pcall(function()
	local v1024 = enum[v]
	local v1025 = v1024 and v1024[v1022]

	if v1025 then
		Enums[v1025] = v1023
	end
end)
local v1024 = "DeveloperShutdown"
local v1025 = 511
pcall(function()
	local v1026 = enum[v]
	local v1027 = v1026 and v1026[v1024]

	if v1027 then
		Enums[v1027] = v1025
	end
end)
local v1026 = "DeveloperUpdate"
local v1027 = 512
pcall(function()
	local v1028 = enum[v]
	local v1029 = v1028 and v1028[v1026]

	if v1029 then
		Enums[v1029] = v1027
	end
end)
local v1028 = "ServerEmpty"
local v1029 = 513
pcall(function()
	local v1030 = enum[v]
	local v1031 = v1030 and v1030[v1028]

	if v1031 then
		Enums[v1031] = v1029
	end
end)
local v1030 = "OutOfMemory"
local v1031 = 514
pcall(function()
	local v1032 = enum[v]
	local v1033 = v1032 and v1032[v1030]

	if v1033 then
		Enums[v1033] = v1031
	end
end)
v = "CollaboratorStatus"
local v1032 = "None"
local v1033 = 515
pcall(function()
	local v1034 = enum[v]
	local v1035 = v1034 and v1034[v1032]

	if v1035 then
		Enums[v1035] = v1033
	end
end)
local v1034 = "Editing3D"
local v1035 = 516
pcall(function()
	local v1036 = enum[v]
	local v1037 = v1036 and v1036[v1034]

	if v1037 then
		Enums[v1037] = v1035
	end
end)
local v1036 = "Scripting"
local v1037 = 517
pcall(function()
	local v1038 = enum[v]
	local v1039 = v1038 and v1038[v1036]

	if v1039 then
		Enums[v1039] = v1037
	end
end)
local v1038 = "PrivateScripting"
local v1039 = 518
pcall(function()
	local v1040 = enum[v]
	local v1041 = v1040 and v1040[v1038]

	if v1041 then
		Enums[v1041] = v1039
	end
end)
v = "CollisionFidelity"
local v1040 = "Default"
local v1041 = 519
pcall(function()
	local v1042 = enum[v]
	local v1043 = v1042 and v1042[v1040]

	if v1043 then
		Enums[v1043] = v1041
	end
end)
local v1042 = "Hull"
local v1043 = 520
pcall(function()
	local v1044 = enum[v]
	local v1045 = v1044 and v1044[v1042]

	if v1045 then
		Enums[v1045] = v1043
	end
end)
local v1044 = "Box"
local v1045 = 521
pcall(function()
	local v1046 = enum[v]
	local v1047 = v1046 and v1046[v1044]

	if v1047 then
		Enums[v1047] = v1045
	end
end)
local v1046 = "PreciseConvexDecomposition"
local v1047 = 522
pcall(function()
	local v1048 = enum[v]
	local v1049 = v1048 and v1048[v1046]

	if v1049 then
		Enums[v1049] = v1047
	end
end)
v = "CommandPermission"
local v1048 = "Plugin"
local v1049 = 523
pcall(function()
	local v1050 = enum[v]
	local v1051 = v1050 and v1050[v1048]

	if v1051 then
		Enums[v1051] = v1049
	end
end)
local v1050 = "LocalUser"
local v1051 = 524
pcall(function()
	local v1052 = enum[v]
	local v1053 = v1052 and v1052[v1050]

	if v1053 then
		Enums[v1053] = v1051
	end
end)
v = "CompileTarget"
local v1052 = "Client"
local v1053 = 525
pcall(function()
	local v1054 = enum[v]
	local v1055 = v1054 and v1054[v1052]

	if v1055 then
		Enums[v1055] = v1053
	end
end)
local v1054 = "CoreScript"
local v1055 = 526
pcall(function()
	local v1056 = enum[v]
	local v1057 = v1056 and v1056[v1054]

	if v1057 then
		Enums[v1057] = v1055
	end
end)
local v1056 = "Studio"
local v1057 = 527
pcall(function()
	local v1058 = enum[v]
	local v1059 = v1058 and v1058[v1056]

	if v1059 then
		Enums[v1059] = v1057
	end
end)
local v1058 = "CoreScriptRaw"
local v1059 = 528
pcall(function()
	local v1060 = enum[v]
	local v1061 = v1060 and v1060[v1058]

	if v1061 then
		Enums[v1061] = v1059
	end
end)
v = "CompletionAcceptanceBehavior"
local v1060 = "Insert"
local v1061 = 529
pcall(function()
	local v1062 = enum[v]
	local v1063 = v1062 and v1062[v1060]

	if v1063 then
		Enums[v1063] = v1061
	end
end)
local v1062 = "Replace"
local v1063 = 530
pcall(function()
	local v1064 = enum[v]
	local v1065 = v1064 and v1064[v1062]

	if v1065 then
		Enums[v1065] = v1063
	end
end)
local v1064 = "ReplaceOnEnterInsertOnTab"
local v1065 = 531
pcall(function()
	local v1066 = enum[v]
	local v1067 = v1066 and v1066[v1064]

	if v1067 then
		Enums[v1067] = v1065
	end
end)
local v1066 = "InsertOnEnterReplaceOnTab"
local v1067 = 532
pcall(function()
	local v1068 = enum[v]
	local v1069 = v1068 and v1068[v1066]

	if v1069 then
		Enums[v1069] = v1067
	end
end)
v = "CompletionItemKind"
local v1068 = "Text"
local v1069 = 533
pcall(function()
	local v1070 = enum[v]
	local v1071 = v1070 and v1070[v1068]

	if v1071 then
		Enums[v1071] = v1069
	end
end)
local v1070 = "Method"
local v1071 = 534
pcall(function()
	local v1072 = enum[v]
	local v1073 = v1072 and v1072[v1070]

	if v1073 then
		Enums[v1073] = v1071
	end
end)
local v1072 = "Function"
local v1073 = 535
pcall(function()
	local v1074 = enum[v]
	local v1075 = v1074 and v1074[v1072]

	if v1075 then
		Enums[v1075] = v1073
	end
end)
local v1074 = "Constructor"
local v1075 = 536
pcall(function()
	local v1076 = enum[v]
	local v1077 = v1076 and v1076[v1074]

	if v1077 then
		Enums[v1077] = v1075
	end
end)
local v1076 = "Field"
local v1077 = 537
pcall(function()
	local v1078 = enum[v]
	local v1079 = v1078 and v1078[v1076]

	if v1079 then
		Enums[v1079] = v1077
	end
end)
local v1078 = "Variable"
local v1079 = 538
pcall(function()
	local v1080 = enum[v]
	local v1081 = v1080 and v1080[v1078]

	if v1081 then
		Enums[v1081] = v1079
	end
end)
local v1080 = "Class"
local v1081 = 539
pcall(function()
	local v1082 = enum[v]
	local v1083 = v1082 and v1082[v1080]

	if v1083 then
		Enums[v1083] = v1081
	end
end)
local v1082 = "Interface"
local v1083 = 540
pcall(function()
	local v1084 = enum[v]
	local v1085 = v1084 and v1084[v1082]

	if v1085 then
		Enums[v1085] = v1083
	end
end)
local v1084 = "Module"
local v1085 = 541
pcall(function()
	local v1086 = enum[v]
	local v1087 = v1086 and v1086[v1084]

	if v1087 then
		Enums[v1087] = v1085
	end
end)
local v1086 = "Property"
local v1087 = 542
pcall(function()
	local v1088 = enum[v]
	local v1089 = v1088 and v1088[v1086]

	if v1089 then
		Enums[v1089] = v1087
	end
end)
local v1088 = "Unit"
local v1089 = 543
pcall(function()
	local v1090 = enum[v]
	local v1091 = v1090 and v1090[v1088]

	if v1091 then
		Enums[v1091] = v1089
	end
end)
local v1090 = "Value"
local v1091 = 544
pcall(function()
	local v1092 = enum[v]
	local v1093 = v1092 and v1092[v1090]

	if v1093 then
		Enums[v1093] = v1091
	end
end)
local v1092 = "Enum"
local v1093 = 545
pcall(function()
	local v1094 = enum[v]
	local v1095 = v1094 and v1094[v1092]

	if v1095 then
		Enums[v1095] = v1093
	end
end)
local v1094 = "Keyword"
local v1095 = 546
pcall(function()
	local v1096 = enum[v]
	local v1097 = v1096 and v1096[v1094]

	if v1097 then
		Enums[v1097] = v1095
	end
end)
local v1096 = "Snippet"
local v1097 = 547
pcall(function()
	local v1098 = enum[v]
	local v1099 = v1098 and v1098[v1096]

	if v1099 then
		Enums[v1099] = v1097
	end
end)
local v1098 = "Color"
local v1099 = 548
pcall(function()
	local v1100 = enum[v]
	local v1101 = v1100 and v1100[v1098]

	if v1101 then
		Enums[v1101] = v1099
	end
end)
local v1100 = "File"
local v1101 = 549
pcall(function()
	local v1102 = enum[v]
	local v1103 = v1102 and v1102[v1100]

	if v1103 then
		Enums[v1103] = v1101
	end
end)
local v1102 = "Reference"
local v1103 = 550
pcall(function()
	local v1104 = enum[v]
	local v1105 = v1104 and v1104[v1102]

	if v1105 then
		Enums[v1105] = v1103
	end
end)
local v1104 = "Folder"
local v1105 = 551
pcall(function()
	local v1106 = enum[v]
	local v1107 = v1106 and v1106[v1104]

	if v1107 then
		Enums[v1107] = v1105
	end
end)
local v1106 = "EnumMember"
local v1107 = 552
pcall(function()
	local v1108 = enum[v]
	local v1109 = v1108 and v1108[v1106]

	if v1109 then
		Enums[v1109] = v1107
	end
end)
local v1108 = "Constant"
local v1109 = 553
pcall(function()
	local v1110 = enum[v]
	local v1111 = v1110 and v1110[v1108]

	if v1111 then
		Enums[v1111] = v1109
	end
end)
local v1110 = "Struct"
local v1111 = 554
pcall(function()
	local v1112 = enum[v]
	local v1113 = v1112 and v1112[v1110]

	if v1113 then
		Enums[v1113] = v1111
	end
end)
local v1112 = "Event"
local v1113 = 555
pcall(function()
	local v1114 = enum[v]
	local v1115 = v1114 and v1114[v1112]

	if v1115 then
		Enums[v1115] = v1113
	end
end)
local v1114 = "Operator"
local v1115 = 556
pcall(function()
	local v1116 = enum[v]
	local v1117 = v1116 and v1116[v1114]

	if v1117 then
		Enums[v1117] = v1115
	end
end)
local v1116 = "TypeParameter"
local v1117 = 557
pcall(function()
	local v1118 = enum[v]
	local v1119 = v1118 and v1118[v1116]

	if v1119 then
		Enums[v1119] = v1117
	end
end)
v = "CompletionItemTag"
local v1118 = "Deprecated"
local v1119 = 558
pcall(function()
	local v1120 = enum[v]
	local v1121 = v1120 and v1120[v1118]

	if v1121 then
		Enums[v1121] = v1119
	end
end)
local v1120 = "IncorrectIndexType"
local v1121 = 559
pcall(function()
	local v1122 = enum[v]
	local v1123 = v1122 and v1122[v1120]

	if v1123 then
		Enums[v1123] = v1121
	end
end)
local v1122 = "PluginPermissions"
local v1123 = 560
pcall(function()
	local v1124 = enum[v]
	local v1125 = v1124 and v1124[v1122]

	if v1125 then
		Enums[v1125] = v1123
	end
end)
local v1124 = "CommandLinePermissions"
local v1125 = 561
pcall(function()
	local v1126 = enum[v]
	local v1127 = v1126 and v1126[v1124]

	if v1127 then
		Enums[v1127] = v1125
	end
end)
local v1126 = "RobloxPermissions"
local v1127 = 562
pcall(function()
	local v1128 = enum[v]
	local v1129 = v1128 and v1128[v1126]

	if v1129 then
		Enums[v1129] = v1127
	end
end)
local v1128 = "AddParens"
local v1129 = 563
pcall(function()
	local v1130 = enum[v]
	local v1131 = v1130 and v1130[v1128]

	if v1131 then
		Enums[v1131] = v1129
	end
end)
local v1130 = "PutCursorInParens"
local v1131 = 564
pcall(function()
	local v1132 = enum[v]
	local v1133 = v1132 and v1132[v1130]

	if v1133 then
		Enums[v1133] = v1131
	end
end)
local v1132 = "TypeCorrect"
local v1133 = 565
pcall(function()
	local v1134 = enum[v]
	local v1135 = v1134 and v1134[v1132]

	if v1135 then
		Enums[v1135] = v1133
	end
end)
local v1134 = "ClientServerBoundaryViolation"
local v1135 = 566
pcall(function()
	local v1136 = enum[v]
	local v1137 = v1136 and v1136[v1134]

	if v1137 then
		Enums[v1137] = v1135
	end
end)
local v1136 = "Invalidated"
local v1137 = 567
pcall(function()
	local v1138 = enum[v]
	local v1139 = v1138 and v1138[v1136]

	if v1139 then
		Enums[v1139] = v1137
	end
end)
local v1138 = "PutCursorBeforeEnd"
local v1139 = 568
pcall(function()
	local v1140 = enum[v]
	local v1141 = v1140 and v1140[v1138]

	if v1141 then
		Enums[v1141] = v1139
	end
end)
v = "CompletionTriggerKind"
local v1140 = "Invoked"
local v1141 = 569
pcall(function()
	local v1142 = enum[v]
	local v1143 = v1142 and v1142[v1140]

	if v1143 then
		Enums[v1143] = v1141
	end
end)
local v1142 = "TriggerCharacter"
local v1143 = 570
pcall(function()
	local v1144 = enum[v]
	local v1145 = v1144 and v1144[v1142]

	if v1145 then
		Enums[v1145] = v1143
	end
end)
local v1144 = "TriggerForIncompleteCompletions"
local v1145 = 571
pcall(function()
	local v1146 = enum[v]
	local v1147 = v1146 and v1146[v1144]

	if v1147 then
		Enums[v1147] = v1145
	end
end)
v = "ComputerCameraMovementMode"
local v1146 = "Default"
local v1147 = 572
pcall(function()
	local v1148 = enum[v]
	local v1149 = v1148 and v1148[v1146]

	if v1149 then
		Enums[v1149] = v1147
	end
end)
local v1148 = "Classic"
local v1149 = 573
pcall(function()
	local v1150 = enum[v]
	local v1151 = v1150 and v1150[v1148]

	if v1151 then
		Enums[v1151] = v1149
	end
end)
local v1150 = "Follow"
local v1151 = 574
pcall(function()
	local v1152 = enum[v]
	local v1153 = v1152 and v1152[v1150]

	if v1153 then
		Enums[v1153] = v1151
	end
end)
local v1152 = "Orbital"
local v1153 = 575
pcall(function()
	local v1154 = enum[v]
	local v1155 = v1154 and v1154[v1152]

	if v1155 then
		Enums[v1155] = v1153
	end
end)
local v1154 = "CameraToggle"
local v1155 = 576
pcall(function()
	local v1156 = enum[v]
	local v1157 = v1156 and v1156[v1154]

	if v1157 then
		Enums[v1157] = v1155
	end
end)
v = "ComputerMovementMode"
local v1156 = "Default"
local v1157 = 577
pcall(function()
	local v1158 = enum[v]
	local v1159 = v1158 and v1158[v1156]

	if v1159 then
		Enums[v1159] = v1157
	end
end)
local v1158 = "KeyboardMouse"
local v1159 = 578
pcall(function()
	local v1160 = enum[v]
	local v1161 = v1160 and v1160[v1158]

	if v1161 then
		Enums[v1161] = v1159
	end
end)
local v1160 = "ClickToMove"
local v1161 = 579
pcall(function()
	local v1162 = enum[v]
	local v1163 = v1162 and v1162[v1160]

	if v1163 then
		Enums[v1163] = v1161
	end
end)
v = "ConfigSnapshotErrorState"
local v1162 = "None"
local v1163 = 580
pcall(function()
	local v1164 = enum[v]
	local v1165 = v1164 and v1164[v1162]

	if v1165 then
		Enums[v1165] = v1163
	end
end)
local v1164 = "LoadFailed"
local v1165 = 581
pcall(function()
	local v1166 = enum[v]
	local v1167 = v1166 and v1166[v1164]

	if v1167 then
		Enums[v1167] = v1165
	end
end)
v = "ConnectionError"
local v1166 = "OK"
local v1167 = 582
pcall(function()
	local v1168 = enum[v]
	local v1169 = v1168 and v1168[v1166]

	if v1169 then
		Enums[v1169] = v1167
	end
end)
local v1168 = "Unknown"
local v1169 = 583
pcall(function()
	local v1170 = enum[v]
	local v1171 = v1170 and v1170[v1168]

	if v1171 then
		Enums[v1171] = v1169
	end
end)
local v1170 = "DisconnectErrors"
local v1171 = 584
pcall(function()
	local v1172 = enum[v]
	local v1173 = v1172 and v1172[v1170]

	if v1173 then
		Enums[v1173] = v1171
	end
end)
local v1172 = "DisconnectBadhash"
local v1173 = 585
pcall(function()
	local v1174 = enum[v]
	local v1175 = v1174 and v1174[v1172]

	if v1175 then
		Enums[v1175] = v1173
	end
end)
local v1174 = "DisconnectSecurityKeyMismatch"
local v1175 = 586
pcall(function()
	local v1176 = enum[v]
	local v1177 = v1176 and v1176[v1174]

	if v1177 then
		Enums[v1177] = v1175
	end
end)
local v1176 = "DisconnectProtocolMismatch"
local v1177 = 587
pcall(function()
	local v1178 = enum[v]
	local v1179 = v1178 and v1178[v1176]

	if v1179 then
		Enums[v1179] = v1177
	end
end)
local v1178 = "DisconnectReceivePacketError"
local v1179 = 588
pcall(function()
	local v1180 = enum[v]
	local v1181 = v1180 and v1180[v1178]

	if v1181 then
		Enums[v1181] = v1179
	end
end)
local v1180 = "DisconnectReceivePacketStreamError"
local v1181 = 589
pcall(function()
	local v1182 = enum[v]
	local v1183 = v1182 and v1182[v1180]

	if v1183 then
		Enums[v1183] = v1181
	end
end)
local v1182 = "DisconnectSendPacketError"
local v1183 = 590
pcall(function()
	local v1184 = enum[v]
	local v1185 = v1184 and v1184[v1182]

	if v1185 then
		Enums[v1185] = v1183
	end
end)
local v1184 = "DisconnectIllegalTeleport"
local v1185 = 591
pcall(function()
	local v1186 = enum[v]
	local v1187 = v1186 and v1186[v1184]

	if v1187 then
		Enums[v1187] = v1185
	end
end)
local v1186 = "DisconnectDuplicatePlayer"
local v1187 = 592
pcall(function()
	local v1188 = enum[v]
	local v1189 = v1188 and v1188[v1186]

	if v1189 then
		Enums[v1189] = v1187
	end
end)
local v1188 = "DisconnectDuplicateTicket"
local v1189 = 593
pcall(function()
	local v1190 = enum[v]
	local v1191 = v1190 and v1190[v1188]

	if v1191 then
		Enums[v1191] = v1189
	end
end)
local v1190 = "DisconnectTimeout"
local v1191 = 594
pcall(function()
	local v1192 = enum[v]
	local v1193 = v1192 and v1192[v1190]

	if v1193 then
		Enums[v1193] = v1191
	end
end)
local v1192 = "DisconnectLuaKick"
local v1193 = 595
pcall(function()
	local v1194 = enum[v]
	local v1195 = v1194 and v1194[v1192]

	if v1195 then
		Enums[v1195] = v1193
	end
end)
local v1194 = "DisconnectOnRemoteSysStats"
local v1195 = 596
pcall(function()
	local v1196 = enum[v]
	local v1197 = v1196 and v1196[v1194]

	if v1197 then
		Enums[v1197] = v1195
	end
end)
local v1196 = "DisconnectHashTimeout"
local v1197 = 597
pcall(function()
	local v1198 = enum[v]
	local v1199 = v1198 and v1198[v1196]

	if v1199 then
		Enums[v1199] = v1197
	end
end)
local v1198 = "DisconnectCloudEditKick"
local v1199 = 598
pcall(function()
	local v1200 = enum[v]
	local v1201 = v1200 and v1200[v1198]

	if v1201 then
		Enums[v1201] = v1199
	end
end)
local v1200 = "DisconnectPlayerless"
local v1201 = 599
pcall(function()
	local v1202 = enum[v]
	local v1203 = v1202 and v1202[v1200]

	if v1203 then
		Enums[v1203] = v1201
	end
end)
local v1202 = "DisconnectNewSecurityKeyMismatch"
local v1203 = 600
pcall(function()
	local v1204 = enum[v]
	local v1205 = v1204 and v1204[v1202]

	if v1205 then
		Enums[v1205] = v1203
	end
end)
local v1204 = "DisconnectEvicted"
local v1205 = 601
pcall(function()
	local v1206 = enum[v]
	local v1207 = v1206 and v1206[v1204]

	if v1207 then
		Enums[v1207] = v1205
	end
end)
local v1206 = "DisconnectDevMaintenance"
local v1207 = 602
pcall(function()
	local v1208 = enum[v]
	local v1209 = v1208 and v1208[v1206]

	if v1209 then
		Enums[v1209] = v1207
	end
end)
local v1208 = "DisconnectRobloxMaintenance"
local v1209 = 603
pcall(function()
	local v1210 = enum[v]
	local v1211 = v1210 and v1210[v1208]

	if v1211 then
		Enums[v1211] = v1209
	end
end)
local v1210 = "DisconnectRejoin"
local v1211 = 604
pcall(function()
	local v1212 = enum[v]
	local v1213 = v1212 and v1212[v1210]

	if v1213 then
		Enums[v1213] = v1211
	end
end)
local v1212 = "DisconnectConnectionLost"
local v1213 = 605
pcall(function()
	local v1214 = enum[v]
	local v1215 = v1214 and v1214[v1212]

	if v1215 then
		Enums[v1215] = v1213
	end
end)
local v1214 = "DisconnectIdle"
local v1215 = 606
pcall(function()
	local v1216 = enum[v]
	local v1217 = v1216 and v1216[v1214]

	if v1217 then
		Enums[v1217] = v1215
	end
end)
local v1216 = "DisconnectRaknetErrors"
local v1217 = 607
pcall(function()
	local v1218 = enum[v]
	local v1219 = v1218 and v1218[v1216]

	if v1219 then
		Enums[v1219] = v1217
	end
end)
local v1218 = "DisconnectWrongVersion"
local v1219 = 608
pcall(function()
	local v1220 = enum[v]
	local v1221 = v1220 and v1220[v1218]

	if v1221 then
		Enums[v1221] = v1219
	end
end)
local v1220 = "DisconnectBySecurityPolicy"
local v1221 = 609
pcall(function()
	local v1222 = enum[v]
	local v1223 = v1222 and v1222[v1220]

	if v1223 then
		Enums[v1223] = v1221
	end
end)
local v1222 = "DisconnectBlockedIP"
local v1223 = 610
pcall(function()
	local v1224 = enum[v]
	local v1225 = v1224 and v1224[v1222]

	if v1225 then
		Enums[v1225] = v1223
	end
end)
local v1224 = "DisconnectClientFailure"
local v1225 = 611
pcall(function()
	local v1226 = enum[v]
	local v1227 = v1226 and v1226[v1224]

	if v1227 then
		Enums[v1227] = v1225
	end
end)
local v1226 = "DisconnectClientRequest"
local v1227 = 612
pcall(function()
	local v1228 = enum[v]
	local v1229 = v1228 and v1228[v1226]

	if v1229 then
		Enums[v1229] = v1227
	end
end)
local v1228 = "DisconnectPrivateServerKickout"
local v1229 = 613
pcall(function()
	local v1230 = enum[v]
	local v1231 = v1230 and v1230[v1228]

	if v1231 then
		Enums[v1231] = v1229
	end
end)
local v1230 = "DisconnectModeratedGame"
local v1231 = 614
pcall(function()
	local v1232 = enum[v]
	local v1233 = v1232 and v1232[v1230]

	if v1233 then
		Enums[v1233] = v1231
	end
end)
local v1232 = "ServerShutdown"
local v1233 = 615
pcall(function()
	local v1234 = enum[v]
	local v1235 = v1234 and v1234[v1232]

	if v1235 then
		Enums[v1235] = v1233
	end
end)
local v1234 = "ReplicatorTimeout"
local v1235 = 616
pcall(function()
	local v1236 = enum[v]
	local v1237 = v1236 and v1236[v1234]

	if v1237 then
		Enums[v1237] = v1235
	end
end)
local v1236 = "PlayerRemoved"
local v1237 = 617
pcall(function()
	local v1238 = enum[v]
	local v1239 = v1238 and v1238[v1236]

	if v1239 then
		Enums[v1239] = v1237
	end
end)
local v1238 = "DisconnectOutOfMemoryKeepPlayingLeave"
local v1239 = 618
pcall(function()
	local v1240 = enum[v]
	local v1241 = v1240 and v1240[v1238]

	if v1241 then
		Enums[v1241] = v1239
	end
end)
local v1240 = "DisconnectRomarkEndOfTest"
local v1241 = 619
pcall(function()
	local v1242 = enum[v]
	local v1243 = v1242 and v1242[v1240]

	if v1243 then
		Enums[v1243] = v1241
	end
end)
local v1242 = "DisconnectCollaboratorPermissionRevoked"
local v1243 = 620
pcall(function()
	local v1244 = enum[v]
	local v1245 = v1244 and v1244[v1242]

	if v1245 then
		Enums[v1245] = v1243
	end
end)
local v1244 = "DisconnectCollaboratorUnderage"
local v1245 = 621
pcall(function()
	local v1246 = enum[v]
	local v1247 = v1246 and v1246[v1244]

	if v1247 then
		Enums[v1247] = v1245
	end
end)
local v1246 = "NetworkInternal"
local v1247 = 622
pcall(function()
	local v1248 = enum[v]
	local v1249 = v1248 and v1248[v1246]

	if v1249 then
		Enums[v1249] = v1247
	end
end)
local v1248 = "NetworkSend"
local v1249 = 623
pcall(function()
	local v1250 = enum[v]
	local v1251 = v1250 and v1250[v1248]

	if v1251 then
		Enums[v1251] = v1249
	end
end)
local v1250 = "NetworkTimeout"
local v1251 = 624
pcall(function()
	local v1252 = enum[v]
	local v1253 = v1252 and v1252[v1250]

	if v1253 then
		Enums[v1253] = v1251
	end
end)
local v1252 = "NetworkMisbehavior"
local v1253 = 625
pcall(function()
	local v1254 = enum[v]
	local v1255 = v1254 and v1254[v1252]

	if v1255 then
		Enums[v1255] = v1253
	end
end)
local v1254 = "NetworkSecurity"
local v1255 = 626
pcall(function()
	local v1256 = enum[v]
	local v1257 = v1256 and v1256[v1254]

	if v1257 then
		Enums[v1257] = v1255
	end
end)
local v1256 = "ReplacementReady"
local v1257 = 627
pcall(function()
	local v1258 = enum[v]
	local v1259 = v1258 and v1258[v1256]

	if v1259 then
		Enums[v1259] = v1257
	end
end)
local v1258 = "ServerEmpty"
local v1259 = 628
pcall(function()
	local v1260 = enum[v]
	local v1261 = v1260 and v1260[v1258]

	if v1261 then
		Enums[v1261] = v1259
	end
end)
local v1260 = "PhantomFreeze"
local v1261 = 629
pcall(function()
	local v1262 = enum[v]
	local v1263 = v1262 and v1262[v1260]

	if v1263 then
		Enums[v1263] = v1261
	end
end)
local v1262 = "AndroidAnticheatKick"
local v1263 = 630
pcall(function()
	local v1264 = enum[v]
	local v1265 = v1264 and v1264[v1262]

	if v1265 then
		Enums[v1265] = v1263
	end
end)
local v1264 = "AndroidEmulatorKick"
local v1265 = 631
pcall(function()
	local v1266 = enum[v]
	local v1267 = v1266 and v1266[v1264]

	if v1267 then
		Enums[v1267] = v1265
	end
end)
local v1266 = "PlacelaunchErrors"
local v1267 = 632
pcall(function()
	local v1268 = enum[v]
	local v1269 = v1268 and v1268[v1266]

	if v1269 then
		Enums[v1269] = v1267
	end
end)
local v1268 = "PlacelaunchDisabled"
local v1269 = 633
pcall(function()
	local v1270 = enum[v]
	local v1271 = v1270 and v1270[v1268]

	if v1271 then
		Enums[v1271] = v1269
	end
end)
local v1270 = "PlacelaunchError"
local v1271 = 634
pcall(function()
	local v1272 = enum[v]
	local v1273 = v1272 and v1272[v1270]

	if v1273 then
		Enums[v1273] = v1271
	end
end)
local v1272 = "PlacelaunchGameEnded"
local v1273 = 635
pcall(function()
	local v1274 = enum[v]
	local v1275 = v1274 and v1274[v1272]

	if v1275 then
		Enums[v1275] = v1273
	end
end)
local v1274 = "PlacelaunchGameFull"
local v1275 = 636
pcall(function()
	local v1276 = enum[v]
	local v1277 = v1276 and v1276[v1274]

	if v1277 then
		Enums[v1277] = v1275
	end
end)
local v1276 = "PlacelaunchUserLeft"
local v1277 = 637
pcall(function()
	local v1278 = enum[v]
	local v1279 = v1278 and v1278[v1276]

	if v1279 then
		Enums[v1279] = v1277
	end
end)
local v1278 = "PlacelaunchRestricted"
local v1279 = 638
pcall(function()
	local v1280 = enum[v]
	local v1281 = v1280 and v1280[v1278]

	if v1281 then
		Enums[v1281] = v1279
	end
end)
local v1280 = "PlacelaunchUnauthorized"
local v1281 = 639
pcall(function()
	local v1282 = enum[v]
	local v1283 = v1282 and v1282[v1280]

	if v1283 then
		Enums[v1283] = v1281
	end
end)
local v1282 = "PlacelaunchFlooded"
local v1283 = 640
pcall(function()
	local v1284 = enum[v]
	local v1285 = v1284 and v1284[v1282]

	if v1285 then
		Enums[v1285] = v1283
	end
end)
local v1284 = "PlacelaunchHashExpired"
local v1285 = 641
pcall(function()
	local v1286 = enum[v]
	local v1287 = v1286 and v1286[v1284]

	if v1287 then
		Enums[v1287] = v1285
	end
end)
local v1286 = "PlacelaunchHashException"
local v1287 = 642
pcall(function()
	local v1288 = enum[v]
	local v1289 = v1288 and v1288[v1286]

	if v1289 then
		Enums[v1289] = v1287
	end
end)
local v1288 = "PlacelaunchPartyCannotFit"
local v1289 = 643
pcall(function()
	local v1290 = enum[v]
	local v1291 = v1290 and v1290[v1288]

	if v1291 then
		Enums[v1291] = v1289
	end
end)
local v1290 = "PlacelaunchHttpError"
local v1291 = 644
pcall(function()
	local v1292 = enum[v]
	local v1293 = v1292 and v1292[v1290]

	if v1293 then
		Enums[v1293] = v1291
	end
end)
local v1292 = "PlacelaunchUserPrivacyUnauthorized"
local v1293 = 645
pcall(function()
	local v1294 = enum[v]
	local v1295 = v1294 and v1294[v1292]

	if v1295 then
		Enums[v1295] = v1293
	end
end)
local v1294 = "PlacelaunchCreatorBan"
local v1295 = 646
pcall(function()
	local v1296 = enum[v]
	local v1297 = v1296 and v1296[v1294]

	if v1297 then
		Enums[v1297] = v1295
	end
end)
local v1296 = "PlacelaunchCustomMessage"
local v1297 = 647
pcall(function()
	local v1298 = enum[v]
	local v1299 = v1298 and v1298[v1296]

	if v1299 then
		Enums[v1299] = v1297
	end
end)
local v1298 = "PlacelaunchOtherError"
local v1299 = 648
pcall(function()
	local v1300 = enum[v]
	local v1301 = v1300 and v1300[v1298]

	if v1301 then
		Enums[v1301] = v1299
	end
end)
local v1300 = "TeleportErrors"
local v1301 = 649
pcall(function()
	local v1302 = enum[v]
	local v1303 = v1302 and v1302[v1300]

	if v1303 then
		Enums[v1303] = v1301
	end
end)
local v1302 = "TeleportFailure"
local v1303 = 650
pcall(function()
	local v1304 = enum[v]
	local v1305 = v1304 and v1304[v1302]

	if v1305 then
		Enums[v1305] = v1303
	end
end)
local v1304 = "TeleportGameNotFound"
local v1305 = 651
pcall(function()
	local v1306 = enum[v]
	local v1307 = v1306 and v1306[v1304]

	if v1307 then
		Enums[v1307] = v1305
	end
end)
local v1306 = "TeleportGameEnded"
local v1307 = 652
pcall(function()
	local v1308 = enum[v]
	local v1309 = v1308 and v1308[v1306]

	if v1309 then
		Enums[v1309] = v1307
	end
end)
local v1308 = "TeleportGameFull"
local v1309 = 653
pcall(function()
	local v1310 = enum[v]
	local v1311 = v1310 and v1310[v1308]

	if v1311 then
		Enums[v1311] = v1309
	end
end)
local v1310 = "TeleportUnauthorized"
local v1311 = 654
pcall(function()
	local v1312 = enum[v]
	local v1313 = v1312 and v1312[v1310]

	if v1313 then
		Enums[v1313] = v1311
	end
end)
local v1312 = "TeleportFlooded"
local v1313 = 655
pcall(function()
	local v1314 = enum[v]
	local v1315 = v1314 and v1314[v1312]

	if v1315 then
		Enums[v1315] = v1313
	end
end)
local v1314 = "TeleportIsTeleporting"
local v1315 = 656
pcall(function()
	local v1316 = enum[v]
	local v1317 = v1316 and v1316[v1314]

	if v1317 then
		Enums[v1317] = v1315
	end
end)
v = "ConnectionState"
local v1316 = "Connected"
local v1317 = 657
pcall(function()
	local v1318 = enum[v]
	local v1319 = v1318 and v1318[v1316]

	if v1319 then
		Enums[v1319] = v1317
	end
end)
local v1318 = "Disconnected"
local v1319 = 658
pcall(function()
	local v1320 = enum[v]
	local v1321 = v1320 and v1320[v1318]

	if v1321 then
		Enums[v1321] = v1319
	end
end)
v = "ContentSourceType"
local v1320 = "None"
local v1321 = 659
pcall(function()
	local v1322 = enum[v]
	local v1323 = v1322 and v1322[v1320]

	if v1323 then
		Enums[v1323] = v1321
	end
end)
local v1322 = "Uri"
local v1323 = 660
pcall(function()
	local v1324 = enum[v]
	local v1325 = v1324 and v1324[v1322]

	if v1325 then
		Enums[v1325] = v1323
	end
end)
local v1324 = "Object"
local v1325 = 661
pcall(function()
	local v1326 = enum[v]
	local v1327 = v1326 and v1326[v1324]

	if v1327 then
		Enums[v1327] = v1325
	end
end)
v = "ContextActionPriority"
local v1326 = "Low"
local v1327 = 662
pcall(function()
	local v1328 = enum[v]
	local v1329 = v1328 and v1328[v1326]

	if v1329 then
		Enums[v1329] = v1327
	end
end)
local v1328 = "Medium"
local v1329 = 663
pcall(function()
	local v1330 = enum[v]
	local v1331 = v1330 and v1330[v1328]

	if v1331 then
		Enums[v1331] = v1329
	end
end)
local v1330 = "High"
local v1331 = 664
pcall(function()
	local v1332 = enum[v]
	local v1333 = v1332 and v1332[v1330]

	if v1333 then
		Enums[v1333] = v1331
	end
end)
v = "ContextActionResult"
local v1332 = "Sink"
local v1333 = 665
pcall(function()
	local v1334 = enum[v]
	local v1335 = v1334 and v1334[v1332]

	if v1335 then
		Enums[v1335] = v1333
	end
end)
local v1334 = "Pass"
local v1335 = 666
pcall(function()
	local v1336 = enum[v]
	local v1337 = v1336 and v1336[v1334]

	if v1337 then
		Enums[v1337] = v1335
	end
end)
v = "ControlMode"
local v1336 = "Classic"
local v1337 = 667
pcall(function()
	local v1338 = enum[v]
	local v1339 = v1338 and v1338[v1336]

	if v1339 then
		Enums[v1339] = v1337
	end
end)
local v1338 = "MouseLockSwitch"
local v1339 = 668
pcall(function()
	local v1340 = enum[v]
	local v1341 = v1340 and v1340[v1338]

	if v1341 then
		Enums[v1341] = v1339
	end
end)
v = "CoreGuiType"
local v1340 = "PlayerList"
local v1341 = 669
pcall(function()
	local v1342 = enum[v]
	local v1343 = v1342 and v1342[v1340]

	if v1343 then
		Enums[v1343] = v1341
	end
end)
local v1342 = "Health"
local v1343 = 670
pcall(function()
	local v1344 = enum[v]
	local v1345 = v1344 and v1344[v1342]

	if v1345 then
		Enums[v1345] = v1343
	end
end)
local v1344 = "Backpack"
local v1345 = 671
pcall(function()
	local v1346 = enum[v]
	local v1347 = v1346 and v1346[v1344]

	if v1347 then
		Enums[v1347] = v1345
	end
end)
local v1346 = "Chat"
local v1347 = 672
pcall(function()
	local v1348 = enum[v]
	local v1349 = v1348 and v1348[v1346]

	if v1349 then
		Enums[v1349] = v1347
	end
end)
local v1348 = "All"
local v1349 = 673
pcall(function()
	local v1350 = enum[v]
	local v1351 = v1350 and v1350[v1348]

	if v1351 then
		Enums[v1351] = v1349
	end
end)
local v1350 = "EmotesMenu"
local v1351 = 674
pcall(function()
	local v1352 = enum[v]
	local v1353 = v1352 and v1352[v1350]

	if v1353 then
		Enums[v1353] = v1351
	end
end)
local v1352 = "SelfView"
local v1353 = 675
pcall(function()
	local v1354 = enum[v]
	local v1355 = v1354 and v1354[v1352]

	if v1355 then
		Enums[v1355] = v1353
	end
end)
local v1354 = "Captures"
local v1355 = 676
pcall(function()
	local v1356 = enum[v]
	local v1357 = v1356 and v1356[v1354]

	if v1357 then
		Enums[v1357] = v1355
	end
end)
v = "CreateAssetResult"
local v1356 = "Success"
local v1357 = 677
pcall(function()
	local v1358 = enum[v]
	local v1359 = v1358 and v1358[v1356]

	if v1359 then
		Enums[v1359] = v1357
	end
end)
local v1358 = "PermissionDenied"
local v1359 = 678
pcall(function()
	local v1360 = enum[v]
	local v1361 = v1360 and v1360[v1358]

	if v1361 then
		Enums[v1361] = v1359
	end
end)
local v1360 = "UploadFailed"
local v1361 = 679
pcall(function()
	local v1362 = enum[v]
	local v1363 = v1362 and v1362[v1360]

	if v1363 then
		Enums[v1363] = v1361
	end
end)
local v1362 = "Unknown"
local v1363 = 680
pcall(function()
	local v1364 = enum[v]
	local v1365 = v1364 and v1364[v1362]

	if v1365 then
		Enums[v1365] = v1363
	end
end)
v = "CreateOutfitFailure"
local v1364 = "InvalidName"
local v1365 = 681
pcall(function()
	local v1366 = enum[v]
	local v1367 = v1366 and v1366[v1364]

	if v1367 then
		Enums[v1367] = v1365
	end
end)
local v1366 = "OutfitLimitReached"
local v1367 = 682
pcall(function()
	local v1368 = enum[v]
	local v1369 = v1368 and v1368[v1366]

	if v1369 then
		Enums[v1369] = v1367
	end
end)
local v1368 = "Other"
local v1369 = 683
pcall(function()
	local v1370 = enum[v]
	local v1371 = v1370 and v1370[v1368]

	if v1371 then
		Enums[v1371] = v1369
	end
end)
v = "CreatorType"
local v1370 = "User"
local v1371 = 684
pcall(function()
	local v1372 = enum[v]
	local v1373 = v1372 and v1372[v1370]

	if v1373 then
		Enums[v1373] = v1371
	end
end)
local v1372 = "Group"
local v1373 = 685
pcall(function()
	local v1374 = enum[v]
	local v1375 = v1374 and v1374[v1372]

	if v1375 then
		Enums[v1375] = v1373
	end
end)
v = "CreatorTypeFilter"
local v1374 = "User"
local v1375 = 686
pcall(function()
	local v1376 = enum[v]
	local v1377 = v1376 and v1376[v1374]

	if v1377 then
		Enums[v1377] = v1375
	end
end)
local v1376 = "Group"
local v1377 = 687
pcall(function()
	local v1378 = enum[v]
	local v1379 = v1378 and v1378[v1376]

	if v1379 then
		Enums[v1379] = v1377
	end
end)
local v1378 = "All"
local v1379 = 688
pcall(function()
	local v1380 = enum[v]
	local v1381 = v1380 and v1380[v1378]

	if v1381 then
		Enums[v1381] = v1379
	end
end)
v = "CurrencyType"
local v1380 = "Default"
local v1381 = 689
pcall(function()
	local v1382 = enum[v]
	local v1383 = v1382 and v1382[v1380]

	if v1383 then
		Enums[v1383] = v1381
	end
end)
local v1382 = "Robux"
local v1383 = 690
pcall(function()
	local v1384 = enum[v]
	local v1385 = v1384 and v1384[v1382]

	if v1385 then
		Enums[v1385] = v1383
	end
end)
local v1384 = "Tix"
local v1385 = 691
pcall(function()
	local v1386 = enum[v]
	local v1387 = v1386 and v1386[v1384]

	if v1387 then
		Enums[v1387] = v1385
	end
end)
v = "CustomCameraMode"
local v1386 = "Default"
local v1387 = 692
pcall(function()
	local v1388 = enum[v]
	local v1389 = v1388 and v1388[v1386]

	if v1389 then
		Enums[v1389] = v1387
	end
end)
local v1388 = "Classic"
local v1389 = 693
pcall(function()
	local v1390 = enum[v]
	local v1391 = v1390 and v1390[v1388]

	if v1391 then
		Enums[v1391] = v1389
	end
end)
local v1390 = "Follow"
local v1391 = 694
pcall(function()
	local v1392 = enum[v]
	local v1393 = v1392 and v1392[v1390]

	if v1393 then
		Enums[v1393] = v1391
	end
end)
v = "DataStoreRequestType"
local v1392 = "GetAsync"
local v1393 = 695
pcall(function()
	local v1394 = enum[v]
	local v1395 = v1394 and v1394[v1392]

	if v1395 then
		Enums[v1395] = v1393
	end
end)
local v1394 = "SetIncrementAsync"
local v1395 = 696
pcall(function()
	local v1396 = enum[v]
	local v1397 = v1396 and v1396[v1394]

	if v1397 then
		Enums[v1397] = v1395
	end
end)
local v1396 = "UpdateAsync"
local v1397 = 697
pcall(function()
	local v1398 = enum[v]
	local v1399 = v1398 and v1398[v1396]

	if v1399 then
		Enums[v1399] = v1397
	end
end)
local v1398 = "GetSortedAsync"
local v1399 = 698
pcall(function()
	local v1400 = enum[v]
	local v1401 = v1400 and v1400[v1398]

	if v1401 then
		Enums[v1401] = v1399
	end
end)
local v1400 = "SetIncrementSortedAsync"
local v1401 = 699
pcall(function()
	local v1402 = enum[v]
	local v1403 = v1402 and v1402[v1400]

	if v1403 then
		Enums[v1403] = v1401
	end
end)
local v1402 = "OnUpdate"
local v1403 = 700
pcall(function()
	local v1404 = enum[v]
	local v1405 = v1404 and v1404[v1402]

	if v1405 then
		Enums[v1405] = v1403
	end
end)
local v1404 = "ListAsync"
local v1405 = 701
pcall(function()
	local v1406 = enum[v]
	local v1407 = v1406 and v1406[v1404]

	if v1407 then
		Enums[v1407] = v1405
	end
end)
local v1406 = "GetVersionAsync"
local v1407 = 702
pcall(function()
	local v1408 = enum[v]
	local v1409 = v1408 and v1408[v1406]

	if v1409 then
		Enums[v1409] = v1407
	end
end)
local v1408 = "RemoveVersionAsync"
local v1409 = 703
pcall(function()
	local v1410 = enum[v]
	local v1411 = v1410 and v1410[v1408]

	if v1411 then
		Enums[v1411] = v1409
	end
end)
v = "DebuggerEndReason"
local v1410 = "ClientRequest"
local v1411 = 704
pcall(function()
	local v1412 = enum[v]
	local v1413 = v1412 and v1412[v1410]

	if v1413 then
		Enums[v1413] = v1411
	end
end)
local v1412 = "Timeout"
local v1413 = 705
pcall(function()
	local v1414 = enum[v]
	local v1415 = v1414 and v1414[v1412]

	if v1415 then
		Enums[v1415] = v1413
	end
end)
local v1414 = "InvalidHost"
local v1415 = 706
pcall(function()
	local v1416 = enum[v]
	local v1417 = v1416 and v1416[v1414]

	if v1417 then
		Enums[v1417] = v1415
	end
end)
local v1416 = "Disconnected"
local v1417 = 707
pcall(function()
	local v1418 = enum[v]
	local v1419 = v1418 and v1418[v1416]

	if v1419 then
		Enums[v1419] = v1417
	end
end)
local v1418 = "ServerShutdown"
local v1419 = 708
pcall(function()
	local v1420 = enum[v]
	local v1421 = v1420 and v1420[v1418]

	if v1421 then
		Enums[v1421] = v1419
	end
end)
local v1420 = "ServerProtocolMismatch"
local v1421 = 709
pcall(function()
	local v1422 = enum[v]
	local v1423 = v1422 and v1422[v1420]

	if v1423 then
		Enums[v1423] = v1421
	end
end)
local v1422 = "ConfigurationFailed"
local v1423 = 710
pcall(function()
	local v1424 = enum[v]
	local v1425 = v1424 and v1424[v1422]

	if v1425 then
		Enums[v1425] = v1423
	end
end)
local v1424 = "RpcError"
local v1425 = 711
pcall(function()
	local v1426 = enum[v]
	local v1427 = v1426 and v1426[v1424]

	if v1427 then
		Enums[v1427] = v1425
	end
end)
v = "DebuggerExceptionBreakMode"
local v1426 = "Never"
local v1427 = 712
pcall(function()
	local v1428 = enum[v]
	local v1429 = v1428 and v1428[v1426]

	if v1429 then
		Enums[v1429] = v1427
	end
end)
local v1428 = "Always"
local v1429 = 713
pcall(function()
	local v1430 = enum[v]
	local v1431 = v1430 and v1430[v1428]

	if v1431 then
		Enums[v1431] = v1429
	end
end)
local v1430 = "Unhandled"
local v1431 = 714
pcall(function()
	local v1432 = enum[v]
	local v1433 = v1432 and v1432[v1430]

	if v1433 then
		Enums[v1433] = v1431
	end
end)
v = "DebuggerFrameType"
local v1432 = "C"
local v1433 = 715
pcall(function()
	local v1434 = enum[v]
	local v1435 = v1434 and v1434[v1432]

	if v1435 then
		Enums[v1435] = v1433
	end
end)
local v1434 = "Lua"
local v1435 = 716
pcall(function()
	local v1436 = enum[v]
	local v1437 = v1436 and v1436[v1434]

	if v1437 then
		Enums[v1437] = v1435
	end
end)
v = "DebuggerPauseReason"
local v1436 = "Unknown"
local v1437 = 717
pcall(function()
	local v1438 = enum[v]
	local v1439 = v1438 and v1438[v1436]

	if v1439 then
		Enums[v1439] = v1437
	end
end)
local v1438 = "Requested"
local v1439 = 718
pcall(function()
	local v1440 = enum[v]
	local v1441 = v1440 and v1440[v1438]

	if v1441 then
		Enums[v1441] = v1439
	end
end)
local v1440 = "Breakpoint"
local v1441 = 719
pcall(function()
	local v1442 = enum[v]
	local v1443 = v1442 and v1442[v1440]

	if v1443 then
		Enums[v1443] = v1441
	end
end)
local v1442 = "Exception"
local v1443 = 720
pcall(function()
	local v1444 = enum[v]
	local v1445 = v1444 and v1444[v1442]

	if v1445 then
		Enums[v1445] = v1443
	end
end)
local v1444 = "SingleStep"
local v1445 = 721
pcall(function()
	local v1446 = enum[v]
	local v1447 = v1446 and v1446[v1444]

	if v1447 then
		Enums[v1447] = v1445
	end
end)
local v1446 = "Entrypoint"
local v1447 = 722
pcall(function()
	local v1448 = enum[v]
	local v1449 = v1448 and v1448[v1446]

	if v1449 then
		Enums[v1449] = v1447
	end
end)
v = "DebuggerStatus"
local v1448 = "Success"
local v1449 = 723
pcall(function()
	local v1450 = enum[v]
	local v1451 = v1450 and v1450[v1448]

	if v1451 then
		Enums[v1451] = v1449
	end
end)
local v1450 = "Timeout"
local v1451 = 724
pcall(function()
	local v1452 = enum[v]
	local v1453 = v1452 and v1452[v1450]

	if v1453 then
		Enums[v1453] = v1451
	end
end)
local v1452 = "ConnectionLost"
local v1453 = 725
pcall(function()
	local v1454 = enum[v]
	local v1455 = v1454 and v1454[v1452]

	if v1455 then
		Enums[v1455] = v1453
	end
end)
local v1454 = "InvalidResponse"
local v1455 = 726
pcall(function()
	local v1456 = enum[v]
	local v1457 = v1456 and v1456[v1454]

	if v1457 then
		Enums[v1457] = v1455
	end
end)
local v1456 = "InternalError"
local v1457 = 727
pcall(function()
	local v1458 = enum[v]
	local v1459 = v1458 and v1458[v1456]

	if v1459 then
		Enums[v1459] = v1457
	end
end)
local v1458 = "InvalidState"
local v1459 = 728
pcall(function()
	local v1460 = enum[v]
	local v1461 = v1460 and v1460[v1458]

	if v1461 then
		Enums[v1461] = v1459
	end
end)
local v1460 = "RpcError"
local v1461 = 729
pcall(function()
	local v1462 = enum[v]
	local v1463 = v1462 and v1462[v1460]

	if v1463 then
		Enums[v1463] = v1461
	end
end)
local v1462 = "InvalidArgument"
local v1463 = 730
pcall(function()
	local v1464 = enum[v]
	local v1465 = v1464 and v1464[v1462]

	if v1465 then
		Enums[v1465] = v1463
	end
end)
local v1464 = "ConnectionClosed"
local v1465 = 731
pcall(function()
	local v1466 = enum[v]
	local v1467 = v1466 and v1466[v1464]

	if v1467 then
		Enums[v1467] = v1465
	end
end)
v = "DevCameraOcclusionMode"
local v1466 = "Zoom"
local v1467 = 732
pcall(function()
	local v1468 = enum[v]
	local v1469 = v1468 and v1468[v1466]

	if v1469 then
		Enums[v1469] = v1467
	end
end)
local v1468 = "Invisicam"
local v1469 = 733
pcall(function()
	local v1470 = enum[v]
	local v1471 = v1470 and v1470[v1468]

	if v1471 then
		Enums[v1471] = v1469
	end
end)
v = "DevComputerCameraMovementMode"
local v1470 = "UserChoice"
local v1471 = 734
pcall(function()
	local v1472 = enum[v]
	local v1473 = v1472 and v1472[v1470]

	if v1473 then
		Enums[v1473] = v1471
	end
end)
local v1472 = "Classic"
local v1473 = 735
pcall(function()
	local v1474 = enum[v]
	local v1475 = v1474 and v1474[v1472]

	if v1475 then
		Enums[v1475] = v1473
	end
end)
local v1474 = "Follow"
local v1475 = 736
pcall(function()
	local v1476 = enum[v]
	local v1477 = v1476 and v1476[v1474]

	if v1477 then
		Enums[v1477] = v1475
	end
end)
local v1476 = "Orbital"
local v1477 = 737
pcall(function()
	local v1478 = enum[v]
	local v1479 = v1478 and v1478[v1476]

	if v1479 then
		Enums[v1479] = v1477
	end
end)
local v1478 = "CameraToggle"
local v1479 = 738
pcall(function()
	local v1480 = enum[v]
	local v1481 = v1480 and v1480[v1478]

	if v1481 then
		Enums[v1481] = v1479
	end
end)
v = "DevComputerMovementMode"
local v1480 = "UserChoice"
local v1481 = 739
pcall(function()
	local v1482 = enum[v]
	local v1483 = v1482 and v1482[v1480]

	if v1483 then
		Enums[v1483] = v1481
	end
end)
local v1482 = "KeyboardMouse"
local v1483 = 740
pcall(function()
	local v1484 = enum[v]
	local v1485 = v1484 and v1484[v1482]

	if v1485 then
		Enums[v1485] = v1483
	end
end)
local v1484 = "ClickToMove"
local v1485 = 741
pcall(function()
	local v1486 = enum[v]
	local v1487 = v1486 and v1486[v1484]

	if v1487 then
		Enums[v1487] = v1485
	end
end)
local v1486 = "Scriptable"
local v1487 = 742
pcall(function()
	local v1488 = enum[v]
	local v1489 = v1488 and v1488[v1486]

	if v1489 then
		Enums[v1489] = v1487
	end
end)
v = "DevTouchCameraMovementMode"
local v1488 = "UserChoice"
local v1489 = 743
pcall(function()
	local v1490 = enum[v]
	local v1491 = v1490 and v1490[v1488]

	if v1491 then
		Enums[v1491] = v1489
	end
end)
local v1490 = "Classic"
local v1491 = 744
pcall(function()
	local v1492 = enum[v]
	local v1493 = v1492 and v1492[v1490]

	if v1493 then
		Enums[v1493] = v1491
	end
end)
local v1492 = "Follow"
local v1493 = 745
pcall(function()
	local v1494 = enum[v]
	local v1495 = v1494 and v1494[v1492]

	if v1495 then
		Enums[v1495] = v1493
	end
end)
local v1494 = "Orbital"
local v1495 = 746
pcall(function()
	local v1496 = enum[v]
	local v1497 = v1496 and v1496[v1494]

	if v1497 then
		Enums[v1497] = v1495
	end
end)
v = "DevTouchMovementMode"
local v1496 = "UserChoice"
local v1497 = 747
pcall(function()
	local v1498 = enum[v]
	local v1499 = v1498 and v1498[v1496]

	if v1499 then
		Enums[v1499] = v1497
	end
end)
local v1498 = "Thumbstick"
local v1499 = 748
pcall(function()
	local v1500 = enum[v]
	local v1501 = v1500 and v1500[v1498]

	if v1501 then
		Enums[v1501] = v1499
	end
end)
local v1500 = "DPad"
local v1501 = 749
pcall(function()
	local v1502 = enum[v]
	local v1503 = v1502 and v1502[v1500]

	if v1503 then
		Enums[v1503] = v1501
	end
end)
local v1502 = "Thumbpad"
local v1503 = 750
pcall(function()
	local v1504 = enum[v]
	local v1505 = v1504 and v1504[v1502]

	if v1505 then
		Enums[v1505] = v1503
	end
end)
local v1504 = "ClickToMove"
local v1505 = 751
pcall(function()
	local v1506 = enum[v]
	local v1507 = v1506 and v1506[v1504]

	if v1507 then
		Enums[v1507] = v1505
	end
end)
local v1506 = "Scriptable"
local v1507 = 752
pcall(function()
	local v1508 = enum[v]
	local v1509 = v1508 and v1508[v1506]

	if v1509 then
		Enums[v1509] = v1507
	end
end)
local v1508 = "DynamicThumbstick"
local v1509 = 753
pcall(function()
	local v1510 = enum[v]
	local v1511 = v1510 and v1510[v1508]

	if v1511 then
		Enums[v1511] = v1509
	end
end)
v = "DeveloperMemoryTag"
local v1510 = "Internal"
local v1511 = 754
pcall(function()
	local v1512 = enum[v]
	local v1513 = v1512 and v1512[v1510]

	if v1513 then
		Enums[v1513] = v1511
	end
end)
local v1512 = "HttpCache"
local v1513 = 755
pcall(function()
	local v1514 = enum[v]
	local v1515 = v1514 and v1514[v1512]

	if v1515 then
		Enums[v1515] = v1513
	end
end)
local v1514 = "Instances"
local v1515 = 756
pcall(function()
	local v1516 = enum[v]
	local v1517 = v1516 and v1516[v1514]

	if v1517 then
		Enums[v1517] = v1515
	end
end)
local v1516 = "Signals"
local v1517 = 757
pcall(function()
	local v1518 = enum[v]
	local v1519 = v1518 and v1518[v1516]

	if v1519 then
		Enums[v1519] = v1517
	end
end)
local v1518 = "LuaHeap"
local v1519 = 758
pcall(function()
	local v1520 = enum[v]
	local v1521 = v1520 and v1520[v1518]

	if v1521 then
		Enums[v1521] = v1519
	end
end)
local v1520 = "Script"
local v1521 = 759
pcall(function()
	local v1522 = enum[v]
	local v1523 = v1522 and v1522[v1520]

	if v1523 then
		Enums[v1523] = v1521
	end
end)
local v1522 = "PhysicsCollision"
local v1523 = 760
pcall(function()
	local v1524 = enum[v]
	local v1525 = v1524 and v1524[v1522]

	if v1525 then
		Enums[v1525] = v1523
	end
end)
local v1524 = "PhysicsParts"
local v1525 = 761
pcall(function()
	local v1526 = enum[v]
	local v1527 = v1526 and v1526[v1524]

	if v1527 then
		Enums[v1527] = v1525
	end
end)
local v1526 = "GraphicsSolidModels"
local v1527 = 762
pcall(function()
	local v1528 = enum[v]
	local v1529 = v1528 and v1528[v1526]

	if v1529 then
		Enums[v1529] = v1527
	end
end)
local v1528 = "GraphicsMeshParts"
local v1529 = 763
pcall(function()
	local v1530 = enum[v]
	local v1531 = v1530 and v1530[v1528]

	if v1531 then
		Enums[v1531] = v1529
	end
end)
local v1530 = "GraphicsParticles"
local v1531 = 764
pcall(function()
	local v1532 = enum[v]
	local v1533 = v1532 and v1532[v1530]

	if v1533 then
		Enums[v1533] = v1531
	end
end)
local v1532 = "GraphicsParts"
local v1533 = 765
pcall(function()
	local v1534 = enum[v]
	local v1535 = v1534 and v1534[v1532]

	if v1535 then
		Enums[v1535] = v1533
	end
end)
local v1534 = "GraphicsSpatialHash"
local v1535 = 766
pcall(function()
	local v1536 = enum[v]
	local v1537 = v1536 and v1536[v1534]

	if v1537 then
		Enums[v1537] = v1535
	end
end)
local v1536 = "GraphicsTerrain"
local v1537 = 767
pcall(function()
	local v1538 = enum[v]
	local v1539 = v1538 and v1538[v1536]

	if v1539 then
		Enums[v1539] = v1537
	end
end)
local v1538 = "GraphicsTexture"
local v1539 = 768
pcall(function()
	local v1540 = enum[v]
	local v1541 = v1540 and v1540[v1538]

	if v1541 then
		Enums[v1541] = v1539
	end
end)
local v1540 = "GraphicsTextureCharacter"
local v1541 = 769
pcall(function()
	local v1542 = enum[v]
	local v1543 = v1542 and v1542[v1540]

	if v1543 then
		Enums[v1543] = v1541
	end
end)
local v1542 = "Sounds"
local v1543 = 770
pcall(function()
	local v1544 = enum[v]
	local v1545 = v1544 and v1544[v1542]

	if v1545 then
		Enums[v1545] = v1543
	end
end)
local v1544 = "StreamingSounds"
local v1545 = 771
pcall(function()
	local v1546 = enum[v]
	local v1547 = v1546 and v1546[v1544]

	if v1547 then
		Enums[v1547] = v1545
	end
end)
local v1546 = "TerrainVoxels"
local v1547 = 772
pcall(function()
	local v1548 = enum[v]
	local v1549 = v1548 and v1548[v1546]

	if v1549 then
		Enums[v1549] = v1547
	end
end)
local v1548 = "Gui"
local v1549 = 773
pcall(function()
	local v1550 = enum[v]
	local v1551 = v1550 and v1550[v1548]

	if v1551 then
		Enums[v1551] = v1549
	end
end)
local v1550 = "Animation"
local v1551 = 774
pcall(function()
	local v1552 = enum[v]
	local v1553 = v1552 and v1552[v1550]

	if v1553 then
		Enums[v1553] = v1551
	end
end)
local v1552 = "Navigation"
local v1553 = 775
pcall(function()
	local v1554 = enum[v]
	local v1555 = v1554 and v1554[v1552]

	if v1555 then
		Enums[v1555] = v1553
	end
end)
local v1554 = "GeometryCSG"
local v1555 = 776
pcall(function()
	local v1556 = enum[v]
	local v1557 = v1556 and v1556[v1554]

	if v1557 then
		Enums[v1557] = v1555
	end
end)
v = "DeviceFeatureType"
local v1556 = "DeviceCapture"
local v1557 = 777
pcall(function()
	local v1558 = enum[v]
	local v1559 = v1558 and v1558[v1556]

	if v1559 then
		Enums[v1559] = v1557
	end
end)
v = "DeviceForm"
local v1558 = "Console"
local v1559 = 778
pcall(function()
	local v1560 = enum[v]
	local v1561 = v1560 and v1560[v1558]

	if v1561 then
		Enums[v1561] = v1559
	end
end)
local v1560 = "Phone"
local v1561 = 779
pcall(function()
	local v1562 = enum[v]
	local v1563 = v1562 and v1562[v1560]

	if v1563 then
		Enums[v1563] = v1561
	end
end)
local v1562 = "Tablet"
local v1563 = 780
pcall(function()
	local v1564 = enum[v]
	local v1565 = v1564 and v1564[v1562]

	if v1565 then
		Enums[v1565] = v1563
	end
end)
local v1564 = "Desktop"
local v1565 = 781
pcall(function()
	local v1566 = enum[v]
	local v1567 = v1566 and v1566[v1564]

	if v1567 then
		Enums[v1567] = v1565
	end
end)
local v1566 = "VR"
local v1567 = 782
pcall(function()
	local v1568 = enum[v]
	local v1569 = v1568 and v1568[v1566]

	if v1569 then
		Enums[v1569] = v1567
	end
end)
v = "DeviceLevel"
local v1568 = "Low"
local v1569 = 783
pcall(function()
	local v1570 = enum[v]
	local v1571 = v1570 and v1570[v1568]

	if v1571 then
		Enums[v1571] = v1569
	end
end)
local v1570 = "Medium"
local v1571 = 784
pcall(function()
	local v1572 = enum[v]
	local v1573 = v1572 and v1572[v1570]

	if v1573 then
		Enums[v1573] = v1571
	end
end)
local v1572 = "High"
local v1573 = 785
pcall(function()
	local v1574 = enum[v]
	local v1575 = v1574 and v1574[v1572]

	if v1575 then
		Enums[v1575] = v1573
	end
end)
v = "DeviceType"
local v1574 = "Unknown"
local v1575 = 786
pcall(function()
	local v1576 = enum[v]
	local v1577 = v1576 and v1576[v1574]

	if v1577 then
		Enums[v1577] = v1575
	end
end)
local v1576 = "Desktop"
local v1577 = 787
pcall(function()
	local v1578 = enum[v]
	local v1579 = v1578 and v1578[v1576]

	if v1579 then
		Enums[v1579] = v1577
	end
end)
local v1578 = "Tablet"
local v1579 = 788
pcall(function()
	local v1580 = enum[v]
	local v1581 = v1580 and v1580[v1578]

	if v1581 then
		Enums[v1581] = v1579
	end
end)
local v1580 = "Phone"
local v1581 = 789
pcall(function()
	local v1582 = enum[v]
	local v1583 = v1582 and v1582[v1580]

	if v1583 then
		Enums[v1583] = v1581
	end
end)
v = "DialogBehaviorType"
local v1582 = "SinglePlayer"
local v1583 = 790
pcall(function()
	local v1584 = enum[v]
	local v1585 = v1584 and v1584[v1582]

	if v1585 then
		Enums[v1585] = v1583
	end
end)
local v1584 = "MultiplePlayers"
local v1585 = 791
pcall(function()
	local v1586 = enum[v]
	local v1587 = v1586 and v1586[v1584]

	if v1587 then
		Enums[v1587] = v1585
	end
end)
v = "DialogPurpose"
local v1586 = "Quest"
local v1587 = 792
pcall(function()
	local v1588 = enum[v]
	local v1589 = v1588 and v1588[v1586]

	if v1589 then
		Enums[v1589] = v1587
	end
end)
local v1588 = "Help"
local v1589 = 793
pcall(function()
	local v1590 = enum[v]
	local v1591 = v1590 and v1590[v1588]

	if v1591 then
		Enums[v1591] = v1589
	end
end)
local v1590 = "Shop"
local v1591 = 794
pcall(function()
	local v1592 = enum[v]
	local v1593 = v1592 and v1592[v1590]

	if v1593 then
		Enums[v1593] = v1591
	end
end)
v = "DialogTone"
local v1592 = "Neutral"
local v1593 = 795
pcall(function()
	local v1594 = enum[v]
	local v1595 = v1594 and v1594[v1592]

	if v1595 then
		Enums[v1595] = v1593
	end
end)
local v1594 = "Friendly"
local v1595 = 796
pcall(function()
	local v1596 = enum[v]
	local v1597 = v1596 and v1596[v1594]

	if v1597 then
		Enums[v1597] = v1595
	end
end)
local v1596 = "Enemy"
local v1597 = 797
pcall(function()
	local v1598 = enum[v]
	local v1599 = v1598 and v1598[v1596]

	if v1599 then
		Enums[v1599] = v1597
	end
end)
v = "DominantAxis"
local v1598 = "Width"
local v1599 = 798
pcall(function()
	local v1600 = enum[v]
	local v1601 = v1600 and v1600[v1598]

	if v1601 then
		Enums[v1601] = v1599
	end
end)
local v1600 = "Height"
local v1601 = 799
pcall(function()
	local v1602 = enum[v]
	local v1603 = v1602 and v1602[v1600]

	if v1603 then
		Enums[v1603] = v1601
	end
end)
v = "DraftStatusCode"
local v1602 = "OK"
local v1603 = 800
pcall(function()
	local v1604 = enum[v]
	local v1605 = v1604 and v1604[v1602]

	if v1605 then
		Enums[v1605] = v1603
	end
end)
local v1604 = "DraftOutdated"
local v1605 = 801
pcall(function()
	local v1606 = enum[v]
	local v1607 = v1606 and v1606[v1604]

	if v1607 then
		Enums[v1607] = v1605
	end
end)
local v1606 = "ScriptRemoved"
local v1607 = 802
pcall(function()
	local v1608 = enum[v]
	local v1609 = v1608 and v1608[v1606]

	if v1609 then
		Enums[v1609] = v1607
	end
end)
local v1608 = "DraftCommitted"
local v1609 = 803
pcall(function()
	local v1610 = enum[v]
	local v1611 = v1610 and v1610[v1608]

	if v1611 then
		Enums[v1611] = v1609
	end
end)
v = "DragDetectorDragStyle"
local v1610 = "TranslateLine"
local v1611 = 804
pcall(function()
	local v1612 = enum[v]
	local v1613 = v1612 and v1612[v1610]

	if v1613 then
		Enums[v1613] = v1611
	end
end)
local v1612 = "TranslatePlane"
local v1613 = 805
pcall(function()
	local v1614 = enum[v]
	local v1615 = v1614 and v1614[v1612]

	if v1615 then
		Enums[v1615] = v1613
	end
end)
local v1614 = "TranslatePlaneOrLine"
local v1615 = 806
pcall(function()
	local v1616 = enum[v]
	local v1617 = v1616 and v1616[v1614]

	if v1617 then
		Enums[v1617] = v1615
	end
end)
local v1616 = "TranslateLineOrPlane"
local v1617 = 807
pcall(function()
	local v1618 = enum[v]
	local v1619 = v1618 and v1618[v1616]

	if v1619 then
		Enums[v1619] = v1617
	end
end)
local v1618 = "TranslateViewPlane"
local v1619 = 808
pcall(function()
	local v1620 = enum[v]
	local v1621 = v1620 and v1620[v1618]

	if v1621 then
		Enums[v1621] = v1619
	end
end)
local v1620 = "RotateAxis"
local v1621 = 809
pcall(function()
	local v1622 = enum[v]
	local v1623 = v1622 and v1622[v1620]

	if v1623 then
		Enums[v1623] = v1621
	end
end)
local v1622 = "RotateTrackball"
local v1623 = 810
pcall(function()
	local v1624 = enum[v]
	local v1625 = v1624 and v1624[v1622]

	if v1625 then
		Enums[v1625] = v1623
	end
end)
local v1624 = "Scriptable"
local v1625 = 811
pcall(function()
	local v1626 = enum[v]
	local v1627 = v1626 and v1626[v1624]

	if v1627 then
		Enums[v1627] = v1625
	end
end)
local v1626 = "BestForDevice"
local v1627 = 812
pcall(function()
	local v1628 = enum[v]
	local v1629 = v1628 and v1628[v1626]

	if v1629 then
		Enums[v1629] = v1627
	end
end)
v = "DragDetectorPermissionPolicy"
local v1628 = "Nobody"
local v1629 = 813
pcall(function()
	local v1630 = enum[v]
	local v1631 = v1630 and v1630[v1628]

	if v1631 then
		Enums[v1631] = v1629
	end
end)
local v1630 = "Everybody"
local v1631 = 814
pcall(function()
	local v1632 = enum[v]
	local v1633 = v1632 and v1632[v1630]

	if v1633 then
		Enums[v1633] = v1631
	end
end)
local v1632 = "Scriptable"
local v1633 = 815
pcall(function()
	local v1634 = enum[v]
	local v1635 = v1634 and v1634[v1632]

	if v1635 then
		Enums[v1635] = v1633
	end
end)
v = "DragDetectorResponseStyle"
local v1634 = "Geometric"
local v1635 = 816
pcall(function()
	local v1636 = enum[v]
	local v1637 = v1636 and v1636[v1634]

	if v1637 then
		Enums[v1637] = v1635
	end
end)
local v1636 = "Physical"
local v1637 = 817
pcall(function()
	local v1638 = enum[v]
	local v1639 = v1638 and v1638[v1636]

	if v1639 then
		Enums[v1639] = v1637
	end
end)
local v1638 = "Custom"
local v1639 = 818
pcall(function()
	local v1640 = enum[v]
	local v1641 = v1640 and v1640[v1638]

	if v1641 then
		Enums[v1641] = v1639
	end
end)
v = "DraggerCoordinateSpace"
local v1640 = "Object"
local v1641 = 819
pcall(function()
	local v1642 = enum[v]
	local v1643 = v1642 and v1642[v1640]

	if v1643 then
		Enums[v1643] = v1641
	end
end)
local v1642 = "World"
local v1643 = 820
pcall(function()
	local v1644 = enum[v]
	local v1645 = v1644 and v1644[v1642]

	if v1645 then
		Enums[v1645] = v1643
	end
end)
v = "DraggerMovementMode"
local v1644 = "Geometric"
local v1645 = 821
pcall(function()
	local v1646 = enum[v]
	local v1647 = v1646 and v1646[v1644]

	if v1647 then
		Enums[v1647] = v1645
	end
end)
local v1646 = "Physical"
local v1647 = 822
pcall(function()
	local v1648 = enum[v]
	local v1649 = v1648 and v1648[v1646]

	if v1649 then
		Enums[v1649] = v1647
	end
end)
v = "DraggingScrollBar"
local v1648 = "None"
local v1649 = 823
pcall(function()
	local v1650 = enum[v]
	local v1651 = v1650 and v1650[v1648]

	if v1651 then
		Enums[v1651] = v1649
	end
end)
local v1650 = "Horizontal"
local v1651 = 824
pcall(function()
	local v1652 = enum[v]
	local v1653 = v1652 and v1652[v1650]

	if v1653 then
		Enums[v1653] = v1651
	end
end)
local v1652 = "Vertical"
local v1653 = 825
pcall(function()
	local v1654 = enum[v]
	local v1655 = v1654 and v1654[v1652]

	if v1655 then
		Enums[v1655] = v1653
	end
end)
v = "EasingDirection"
local v1654 = "In"
local v1655 = 826
pcall(function()
	local v1656 = enum[v]
	local v1657 = v1656 and v1656[v1654]

	if v1657 then
		Enums[v1657] = v1655
	end
end)
local v1656 = "Out"
local v1657 = 827
pcall(function()
	local v1658 = enum[v]
	local v1659 = v1658 and v1658[v1656]

	if v1659 then
		Enums[v1659] = v1657
	end
end)
local v1658 = "InOut"
local v1659 = 828
pcall(function()
	local v1660 = enum[v]
	local v1661 = v1660 and v1660[v1658]

	if v1661 then
		Enums[v1661] = v1659
	end
end)
v = "EasingStyle"
local v1660 = "Linear"
local v1661 = 829
pcall(function()
	local v1662 = enum[v]
	local v1663 = v1662 and v1662[v1660]

	if v1663 then
		Enums[v1663] = v1661
	end
end)
local v1662 = "Sine"
local v1663 = 830
pcall(function()
	local v1664 = enum[v]
	local v1665 = v1664 and v1664[v1662]

	if v1665 then
		Enums[v1665] = v1663
	end
end)
local v1664 = "Back"
local v1665 = 831
pcall(function()
	local v1666 = enum[v]
	local v1667 = v1666 and v1666[v1664]

	if v1667 then
		Enums[v1667] = v1665
	end
end)
local v1666 = "Quad"
local v1667 = 832
pcall(function()
	local v1668 = enum[v]
	local v1669 = v1668 and v1668[v1666]

	if v1669 then
		Enums[v1669] = v1667
	end
end)
local v1668 = "Quart"
local v1669 = 833
pcall(function()
	local v1670 = enum[v]
	local v1671 = v1670 and v1670[v1668]

	if v1671 then
		Enums[v1671] = v1669
	end
end)
local v1670 = "Quint"
local v1671 = 834
pcall(function()
	local v1672 = enum[v]
	local v1673 = v1672 and v1672[v1670]

	if v1673 then
		Enums[v1673] = v1671
	end
end)
local v1672 = "Bounce"
local v1673 = 835
pcall(function()
	local v1674 = enum[v]
	local v1675 = v1674 and v1674[v1672]

	if v1675 then
		Enums[v1675] = v1673
	end
end)
local v1674 = "Elastic"
local v1675 = 836
pcall(function()
	local v1676 = enum[v]
	local v1677 = v1676 and v1676[v1674]

	if v1677 then
		Enums[v1677] = v1675
	end
end)
local v1676 = "Exponential"
local v1677 = 837
pcall(function()
	local v1678 = enum[v]
	local v1679 = v1678 and v1678[v1676]

	if v1679 then
		Enums[v1679] = v1677
	end
end)
local v1678 = "Circular"
local v1679 = 838
pcall(function()
	local v1680 = enum[v]
	local v1681 = v1680 and v1680[v1678]

	if v1681 then
		Enums[v1681] = v1679
	end
end)
local v1680 = "Cubic"
local v1681 = 839
pcall(function()
	local v1682 = enum[v]
	local v1683 = v1682 and v1682[v1680]

	if v1683 then
		Enums[v1683] = v1681
	end
end)
v = "EditableStatus"
local v1682 = "Unknown"
local v1683 = 840
pcall(function()
	local v1684 = enum[v]
	local v1685 = v1684 and v1684[v1682]

	if v1685 then
		Enums[v1685] = v1683
	end
end)
local v1684 = "Allowed"
local v1685 = 841
pcall(function()
	local v1686 = enum[v]
	local v1687 = v1686 and v1686[v1684]

	if v1687 then
		Enums[v1687] = v1685
	end
end)
local v1686 = "Disallowed"
local v1687 = 842
pcall(function()
	local v1688 = enum[v]
	local v1689 = v1688 and v1688[v1686]

	if v1689 then
		Enums[v1689] = v1687
	end
end)
v = "ElasticBehavior"
local v1688 = "WhenScrollable"
local v1689 = 843
pcall(function()
	local v1690 = enum[v]
	local v1691 = v1690 and v1690[v1688]

	if v1691 then
		Enums[v1691] = v1689
	end
end)
local v1690 = "Always"
local v1691 = 844
pcall(function()
	local v1692 = enum[v]
	local v1693 = v1692 and v1692[v1690]

	if v1693 then
		Enums[v1693] = v1691
	end
end)
local v1692 = "Never"
local v1693 = 845
pcall(function()
	local v1694 = enum[v]
	local v1695 = v1694 and v1694[v1692]

	if v1695 then
		Enums[v1695] = v1693
	end
end)
v = "EnviromentalPhysicsThrottle"
local v1694 = "DefaultAuto"
local v1695 = 846
pcall(function()
	local v1696 = enum[v]
	local v1697 = v1696 and v1696[v1694]

	if v1697 then
		Enums[v1697] = v1695
	end
end)
local v1696 = "Disabled"
local v1697 = 847
pcall(function()
	local v1698 = enum[v]
	local v1699 = v1698 and v1698[v1696]

	if v1699 then
		Enums[v1699] = v1697
	end
end)
local v1698 = "Always"
local v1699 = 848
pcall(function()
	local v1700 = enum[v]
	local v1701 = v1700 and v1700[v1698]

	if v1701 then
		Enums[v1701] = v1699
	end
end)
local v1700 = "Skip2"
local v1701 = 849
pcall(function()
	local v1702 = enum[v]
	local v1703 = v1702 and v1702[v1700]

	if v1703 then
		Enums[v1703] = v1701
	end
end)
local v1702 = "Skip4"
local v1703 = 850
pcall(function()
	local v1704 = enum[v]
	local v1705 = v1704 and v1704[v1702]

	if v1705 then
		Enums[v1705] = v1703
	end
end)
local v1704 = "Skip8"
local v1705 = 851
pcall(function()
	local v1706 = enum[v]
	local v1707 = v1706 and v1706[v1704]

	if v1707 then
		Enums[v1707] = v1705
	end
end)
local v1706 = "Skip16"
local v1707 = 852
pcall(function()
	local v1708 = enum[v]
	local v1709 = v1708 and v1708[v1706]

	if v1709 then
		Enums[v1709] = v1707
	end
end)
v = "ExperienceAuthScope"
local v1708 = "DefaultScope"
local v1709 = 853
pcall(function()
	local v1710 = enum[v]
	local v1711 = v1710 and v1710[v1708]

	if v1711 then
		Enums[v1711] = v1709
	end
end)
local v1710 = "CreatorAssetsCreate"
local v1711 = 854
pcall(function()
	local v1712 = enum[v]
	local v1713 = v1712 and v1712[v1710]

	if v1713 then
		Enums[v1713] = v1711
	end
end)
v = "ExplosionType"
local v1712 = "NoCraters"
local v1713 = 855
pcall(function()
	local v1714 = enum[v]
	local v1715 = v1714 and v1714[v1712]

	if v1715 then
		Enums[v1715] = v1713
	end
end)
local v1714 = "Craters"
local v1715 = 856
pcall(function()
	local v1716 = enum[v]
	local v1717 = v1716 and v1716[v1714]

	if v1717 then
		Enums[v1717] = v1715
	end
end)
v = "FACSDataLod"
local v1716 = "LOD0"
local v1717 = 857
pcall(function()
	local v1718 = enum[v]
	local v1719 = v1718 and v1718[v1716]

	if v1719 then
		Enums[v1719] = v1717
	end
end)
local v1718 = "LOD1"
local v1719 = 858
pcall(function()
	local v1720 = enum[v]
	local v1721 = v1720 and v1720[v1718]

	if v1721 then
		Enums[v1721] = v1719
	end
end)
local v1720 = "LODCount"
local v1721 = 859
pcall(function()
	local v1722 = enum[v]
	local v1723 = v1722 and v1722[v1720]

	if v1723 then
		Enums[v1723] = v1721
	end
end)
v = "FacialAgeEstimationResultType"
local v1722 = "Complete"
local v1723 = 860
pcall(function()
	local v1724 = enum[v]
	local v1725 = v1724 and v1724[v1722]

	if v1725 then
		Enums[v1725] = v1723
	end
end)
local v1724 = "Cancel"
local v1725 = 861
pcall(function()
	local v1726 = enum[v]
	local v1727 = v1726 and v1726[v1724]

	if v1727 then
		Enums[v1727] = v1725
	end
end)
local v1726 = "Error"
local v1727 = 862
pcall(function()
	local v1728 = enum[v]
	local v1729 = v1728 and v1728[v1726]

	if v1729 then
		Enums[v1729] = v1727
	end
end)
v = "FacialAnimationStreamingState"
local v1728 = "None"
local v1729 = 863
pcall(function()
	local v1730 = enum[v]
	local v1731 = v1730 and v1730[v1728]

	if v1731 then
		Enums[v1731] = v1729
	end
end)
local v1730 = "Audio"
local v1731 = 864
pcall(function()
	local v1732 = enum[v]
	local v1733 = v1732 and v1732[v1730]

	if v1733 then
		Enums[v1733] = v1731
	end
end)
local v1732 = "Video"
local v1733 = 865
pcall(function()
	local v1734 = enum[v]
	local v1735 = v1734 and v1734[v1732]

	if v1735 then
		Enums[v1735] = v1733
	end
end)
local v1734 = "Place"
local v1735 = 866
pcall(function()
	local v1736 = enum[v]
	local v1737 = v1736 and v1736[v1734]

	if v1737 then
		Enums[v1737] = v1735
	end
end)
local v1736 = "Server"
local v1737 = 867
pcall(function()
	local v1738 = enum[v]
	local v1739 = v1738 and v1738[v1736]

	if v1739 then
		Enums[v1739] = v1737
	end
end)
v = "FacsActionUnit"
local v1738 = "ChinRaiserUpperLip"
local v1739 = 868
pcall(function()
	local v1740 = enum[v]
	local v1741 = v1740 and v1740[v1738]

	if v1741 then
		Enums[v1741] = v1739
	end
end)
local v1740 = "ChinRaiser"
local v1741 = 869
pcall(function()
	local v1742 = enum[v]
	local v1743 = v1742 and v1742[v1740]

	if v1743 then
		Enums[v1743] = v1741
	end
end)
local v1742 = "FlatPucker"
local v1743 = 870
pcall(function()
	local v1744 = enum[v]
	local v1745 = v1744 and v1744[v1742]

	if v1745 then
		Enums[v1745] = v1743
	end
end)
local v1744 = "Funneler"
local v1745 = 871
pcall(function()
	local v1746 = enum[v]
	local v1747 = v1746 and v1746[v1744]

	if v1747 then
		Enums[v1747] = v1745
	end
end)
local v1746 = "LowerLipSuck"
local v1747 = 872
pcall(function()
	local v1748 = enum[v]
	local v1749 = v1748 and v1748[v1746]

	if v1749 then
		Enums[v1749] = v1747
	end
end)
local v1748 = "LipPresser"
local v1749 = 873
pcall(function()
	local v1750 = enum[v]
	local v1751 = v1750 and v1750[v1748]

	if v1751 then
		Enums[v1751] = v1749
	end
end)
local v1750 = "LipsTogether"
local v1751 = 874
pcall(function()
	local v1752 = enum[v]
	local v1753 = v1752 and v1752[v1750]

	if v1753 then
		Enums[v1753] = v1751
	end
end)
local v1752 = "MouthLeft"
local v1753 = 875
pcall(function()
	local v1754 = enum[v]
	local v1755 = v1754 and v1754[v1752]

	if v1755 then
		Enums[v1755] = v1753
	end
end)
local v1754 = "MouthRight"
local v1755 = 876
pcall(function()
	local v1756 = enum[v]
	local v1757 = v1756 and v1756[v1754]

	if v1757 then
		Enums[v1757] = v1755
	end
end)
local v1756 = "Pucker"
local v1757 = 877
pcall(function()
	local v1758 = enum[v]
	local v1759 = v1758 and v1758[v1756]

	if v1759 then
		Enums[v1759] = v1757
	end
end)
local v1758 = "UpperLipSuck"
local v1759 = 878
pcall(function()
	local v1760 = enum[v]
	local v1761 = v1760 and v1760[v1758]

	if v1761 then
		Enums[v1761] = v1759
	end
end)
local v1760 = "LeftCheekPuff"
local v1761 = 879
pcall(function()
	local v1762 = enum[v]
	local v1763 = v1762 and v1762[v1760]

	if v1763 then
		Enums[v1763] = v1761
	end
end)
local v1762 = "LeftDimpler"
local v1763 = 880
pcall(function()
	local v1764 = enum[v]
	local v1765 = v1764 and v1764[v1762]

	if v1765 then
		Enums[v1765] = v1763
	end
end)
local v1764 = "LeftLipCornerDown"
local v1765 = 881
pcall(function()
	local v1766 = enum[v]
	local v1767 = v1766 and v1766[v1764]

	if v1767 then
		Enums[v1767] = v1765
	end
end)
local v1766 = "LeftLowerLipDepressor"
local v1767 = 882
pcall(function()
	local v1768 = enum[v]
	local v1769 = v1768 and v1768[v1766]

	if v1769 then
		Enums[v1769] = v1767
	end
end)
local v1768 = "LeftLipCornerPuller"
local v1769 = 883
pcall(function()
	local v1770 = enum[v]
	local v1771 = v1770 and v1770[v1768]

	if v1771 then
		Enums[v1771] = v1769
	end
end)
local v1770 = "LeftLipStretcher"
local v1771 = 884
pcall(function()
	local v1772 = enum[v]
	local v1773 = v1772 and v1772[v1770]

	if v1773 then
		Enums[v1773] = v1771
	end
end)
local v1772 = "LeftUpperLipRaiser"
local v1773 = 885
pcall(function()
	local v1774 = enum[v]
	local v1775 = v1774 and v1774[v1772]

	if v1775 then
		Enums[v1775] = v1773
	end
end)
local v1774 = "RightCheekPuff"
local v1775 = 886
pcall(function()
	local v1776 = enum[v]
	local v1777 = v1776 and v1776[v1774]

	if v1777 then
		Enums[v1777] = v1775
	end
end)
local v1776 = "RightDimpler"
local v1777 = 887
pcall(function()
	local v1778 = enum[v]
	local v1779 = v1778 and v1778[v1776]

	if v1779 then
		Enums[v1779] = v1777
	end
end)
local v1778 = "RightLipCornerDown"
local v1779 = 888
pcall(function()
	local v1780 = enum[v]
	local v1781 = v1780 and v1780[v1778]

	if v1781 then
		Enums[v1781] = v1779
	end
end)
local v1780 = "RightLowerLipDepressor"
local v1781 = 889
pcall(function()
	local v1782 = enum[v]
	local v1783 = v1782 and v1782[v1780]

	if v1783 then
		Enums[v1783] = v1781
	end
end)
local v1782 = "RightLipCornerPuller"
local v1783 = 890
pcall(function()
	local v1784 = enum[v]
	local v1785 = v1784 and v1784[v1782]

	if v1785 then
		Enums[v1785] = v1783
	end
end)
local v1784 = "RightLipStretcher"
local v1785 = 891
pcall(function()
	local v1786 = enum[v]
	local v1787 = v1786 and v1786[v1784]

	if v1787 then
		Enums[v1787] = v1785
	end
end)
local v1786 = "RightUpperLipRaiser"
local v1787 = 892
pcall(function()
	local v1788 = enum[v]
	local v1789 = v1788 and v1788[v1786]

	if v1789 then
		Enums[v1789] = v1787
	end
end)
local v1788 = "JawDrop"
local v1789 = 893
pcall(function()
	local v1790 = enum[v]
	local v1791 = v1790 and v1790[v1788]

	if v1791 then
		Enums[v1791] = v1789
	end
end)
local v1790 = "JawLeft"
local v1791 = 894
pcall(function()
	local v1792 = enum[v]
	local v1793 = v1792 and v1792[v1790]

	if v1793 then
		Enums[v1793] = v1791
	end
end)
local v1792 = "JawRight"
local v1793 = 895
pcall(function()
	local v1794 = enum[v]
	local v1795 = v1794 and v1794[v1792]

	if v1795 then
		Enums[v1795] = v1793
	end
end)
local v1794 = "Corrugator"
local v1795 = 896
pcall(function()
	local v1796 = enum[v]
	local v1797 = v1796 and v1796[v1794]

	if v1797 then
		Enums[v1797] = v1795
	end
end)
local v1796 = "LeftBrowLowerer"
local v1797 = 897
pcall(function()
	local v1798 = enum[v]
	local v1799 = v1798 and v1798[v1796]

	if v1799 then
		Enums[v1799] = v1797
	end
end)
local v1798 = "LeftOuterBrowRaiser"
local v1799 = 898
pcall(function()
	local v1800 = enum[v]
	local v1801 = v1800 and v1800[v1798]

	if v1801 then
		Enums[v1801] = v1799
	end
end)
local v1800 = "LeftNoseWrinkler"
local v1801 = 899
pcall(function()
	local v1802 = enum[v]
	local v1803 = v1802 and v1802[v1800]

	if v1803 then
		Enums[v1803] = v1801
	end
end)
local v1802 = "LeftInnerBrowRaiser"
local v1803 = 900
pcall(function()
	local v1804 = enum[v]
	local v1805 = v1804 and v1804[v1802]

	if v1805 then
		Enums[v1805] = v1803
	end
end)
local v1804 = "RightBrowLowerer"
local v1805 = 901
pcall(function()
	local v1806 = enum[v]
	local v1807 = v1806 and v1806[v1804]

	if v1807 then
		Enums[v1807] = v1805
	end
end)
local v1806 = "RightOuterBrowRaiser"
local v1807 = 902
pcall(function()
	local v1808 = enum[v]
	local v1809 = v1808 and v1808[v1806]

	if v1809 then
		Enums[v1809] = v1807
	end
end)
local v1808 = "RightInnerBrowRaiser"
local v1809 = 903
pcall(function()
	local v1810 = enum[v]
	local v1811 = v1810 and v1810[v1808]

	if v1811 then
		Enums[v1811] = v1809
	end
end)
local v1810 = "RightNoseWrinkler"
local v1811 = 904
pcall(function()
	local v1812 = enum[v]
	local v1813 = v1812 and v1812[v1810]

	if v1813 then
		Enums[v1813] = v1811
	end
end)
local v1812 = "EyesLookDown"
local v1813 = 905
pcall(function()
	local v1814 = enum[v]
	local v1815 = v1814 and v1814[v1812]

	if v1815 then
		Enums[v1815] = v1813
	end
end)
local v1814 = "EyesLookLeft"
local v1815 = 906
pcall(function()
	local v1816 = enum[v]
	local v1817 = v1816 and v1816[v1814]

	if v1817 then
		Enums[v1817] = v1815
	end
end)
local v1816 = "EyesLookUp"
local v1817 = 907
pcall(function()
	local v1818 = enum[v]
	local v1819 = v1818 and v1818[v1816]

	if v1819 then
		Enums[v1819] = v1817
	end
end)
local v1818 = "EyesLookRight"
local v1819 = 908
pcall(function()
	local v1820 = enum[v]
	local v1821 = v1820 and v1820[v1818]

	if v1821 then
		Enums[v1821] = v1819
	end
end)
local v1820 = "LeftCheekRaiser"
local v1821 = 909
pcall(function()
	local v1822 = enum[v]
	local v1823 = v1822 and v1822[v1820]

	if v1823 then
		Enums[v1823] = v1821
	end
end)
local v1822 = "LeftEyeUpperLidRaiser"
local v1823 = 910
pcall(function()
	local v1824 = enum[v]
	local v1825 = v1824 and v1824[v1822]

	if v1825 then
		Enums[v1825] = v1823
	end
end)
local v1824 = "LeftEyeClosed"
local v1825 = 911
pcall(function()
	local v1826 = enum[v]
	local v1827 = v1826 and v1826[v1824]

	if v1827 then
		Enums[v1827] = v1825
	end
end)
local v1826 = "RightCheekRaiser"
local v1827 = 912
pcall(function()
	local v1828 = enum[v]
	local v1829 = v1828 and v1828[v1826]

	if v1829 then
		Enums[v1829] = v1827
	end
end)
local v1828 = "RightEyeUpperLidRaiser"
local v1829 = 913
pcall(function()
	local v1830 = enum[v]
	local v1831 = v1830 and v1830[v1828]

	if v1831 then
		Enums[v1831] = v1829
	end
end)
local v1830 = "RightEyeClosed"
local v1831 = 914
pcall(function()
	local v1832 = enum[v]
	local v1833 = v1832 and v1832[v1830]

	if v1833 then
		Enums[v1833] = v1831
	end
end)
local v1832 = "TongueDown"
local v1833 = 915
pcall(function()
	local v1834 = enum[v]
	local v1835 = v1834 and v1834[v1832]

	if v1835 then
		Enums[v1835] = v1833
	end
end)
local v1834 = "TongueOut"
local v1835 = 916
pcall(function()
	local v1836 = enum[v]
	local v1837 = v1836 and v1836[v1834]

	if v1837 then
		Enums[v1837] = v1835
	end
end)
local v1836 = "TongueUp"
local v1837 = 917
pcall(function()
	local v1838 = enum[v]
	local v1839 = v1838 and v1838[v1836]

	if v1839 then
		Enums[v1839] = v1837
	end
end)
v = "FeedRankingScoreType"
local v1838 = "Content"
local v1839 = 918
pcall(function()
	local v1840 = enum[v]
	local v1841 = v1840 and v1840[v1838]

	if v1841 then
		Enums[v1841] = v1839
	end
end)
local v1840 = "Final"
local v1841 = 919
pcall(function()
	local v1842 = enum[v]
	local v1843 = v1842 and v1842[v1840]

	if v1843 then
		Enums[v1843] = v1841
	end
end)
local v1842 = "GameJoin"
local v1843 = 920
pcall(function()
	local v1844 = enum[v]
	local v1845 = v1844 and v1844[v1842]

	if v1845 then
		Enums[v1845] = v1843
	end
end)
local v1844 = "Interaction"
local v1845 = 921
pcall(function()
	local v1846 = enum[v]
	local v1847 = v1846 and v1846[v1844]

	if v1847 then
		Enums[v1847] = v1845
	end
end)
local v1846 = "Invalid"
local v1847 = 922
pcall(function()
	local v1848 = enum[v]
	local v1849 = v1848 and v1848[v1846]

	if v1849 then
		Enums[v1849] = v1847
	end
end)
local v1848 = "Sharing"
local v1849 = 923
pcall(function()
	local v1850 = enum[v]
	local v1851 = v1850 and v1850[v1848]

	if v1851 then
		Enums[v1851] = v1849
	end
end)
v = "FieldOfViewMode"
local v1850 = "Vertical"
local v1851 = 924
pcall(function()
	local v1852 = enum[v]
	local v1853 = v1852 and v1852[v1850]

	if v1853 then
		Enums[v1853] = v1851
	end
end)
local v1852 = "Diagonal"
local v1853 = 925
pcall(function()
	local v1854 = enum[v]
	local v1855 = v1854 and v1854[v1852]

	if v1855 then
		Enums[v1855] = v1853
	end
end)
local v1854 = "MaxAxis"
local v1855 = 926
pcall(function()
	local v1856 = enum[v]
	local v1857 = v1856 and v1856[v1854]

	if v1857 then
		Enums[v1857] = v1855
	end
end)
v = "FillDirection"
local v1856 = "Horizontal"
local v1857 = 927
pcall(function()
	local v1858 = enum[v]
	local v1859 = v1858 and v1858[v1856]

	if v1859 then
		Enums[v1859] = v1857
	end
end)
local v1858 = "Vertical"
local v1859 = 928
pcall(function()
	local v1860 = enum[v]
	local v1861 = v1860 and v1860[v1858]

	if v1861 then
		Enums[v1861] = v1859
	end
end)
v = "FilterErrorType"
local v1860 = "BackslashNotEscapingAnything"
local v1861 = 929
pcall(function()
	local v1862 = enum[v]
	local v1863 = v1862 and v1862[v1860]

	if v1863 then
		Enums[v1863] = v1861
	end
end)
local v1862 = "BadBespokeFilter"
local v1863 = 930
pcall(function()
	local v1864 = enum[v]
	local v1865 = v1864 and v1864[v1862]

	if v1865 then
		Enums[v1865] = v1863
	end
end)
local v1864 = "BadName"
local v1865 = 931
pcall(function()
	local v1866 = enum[v]
	local v1867 = v1866 and v1866[v1864]

	if v1867 then
		Enums[v1867] = v1865
	end
end)
local v1866 = "IncompleteOr"
local v1867 = 932
pcall(function()
	local v1868 = enum[v]
	local v1869 = v1868 and v1868[v1866]

	if v1869 then
		Enums[v1869] = v1867
	end
end)
local v1868 = "IncompleteParenthesis"
local v1869 = 933
pcall(function()
	local v1870 = enum[v]
	local v1871 = v1870 and v1870[v1868]

	if v1871 then
		Enums[v1871] = v1869
	end
end)
local v1870 = "InvalidDoubleStar"
local v1871 = 934
pcall(function()
	local v1872 = enum[v]
	local v1873 = v1872 and v1872[v1870]

	if v1873 then
		Enums[v1873] = v1871
	end
end)
local v1872 = "InvalidTilde"
local v1873 = 935
pcall(function()
	local v1874 = enum[v]
	local v1875 = v1874 and v1874[v1872]

	if v1875 then
		Enums[v1875] = v1873
	end
end)
local v1874 = "PropertyBadOperator"
local v1875 = 936
pcall(function()
	local v1876 = enum[v]
	local v1877 = v1876 and v1876[v1874]

	if v1877 then
		Enums[v1877] = v1875
	end
end)
local v1876 = "PropertyDoesNotExist"
local v1877 = 937
pcall(function()
	local v1878 = enum[v]
	local v1879 = v1878 and v1878[v1876]

	if v1879 then
		Enums[v1879] = v1877
	end
end)
local v1878 = "PropertyInvalidField"
local v1879 = 938
pcall(function()
	local v1880 = enum[v]
	local v1881 = v1880 and v1880[v1878]

	if v1881 then
		Enums[v1881] = v1879
	end
end)
local v1880 = "PropertyInvalidValue"
local v1881 = 939
pcall(function()
	local v1882 = enum[v]
	local v1883 = v1882 and v1882[v1880]

	if v1883 then
		Enums[v1883] = v1881
	end
end)
local v1882 = "PropertyUnsupportedFields"
local v1883 = 940
pcall(function()
	local v1884 = enum[v]
	local v1885 = v1884 and v1884[v1882]

	if v1885 then
		Enums[v1885] = v1883
	end
end)
local v1884 = "PropertyUnsupportedProperty"
local v1885 = 941
pcall(function()
	local v1886 = enum[v]
	local v1887 = v1886 and v1886[v1884]

	if v1887 then
		Enums[v1887] = v1885
	end
end)
local v1886 = "UnexpectedNameIndex"
local v1887 = 942
pcall(function()
	local v1888 = enum[v]
	local v1889 = v1888 and v1888[v1886]

	if v1889 then
		Enums[v1889] = v1887
	end
end)
local v1888 = "UnexpectedToken"
local v1889 = 943
pcall(function()
	local v1890 = enum[v]
	local v1891 = v1890 and v1890[v1888]

	if v1891 then
		Enums[v1891] = v1889
	end
end)
local v1890 = "UnfinishedBinaryOperator"
local v1891 = 944
pcall(function()
	local v1892 = enum[v]
	local v1893 = v1892 and v1892[v1890]

	if v1893 then
		Enums[v1893] = v1891
	end
end)
local v1892 = "UnfinishedQuote"
local v1893 = 945
pcall(function()
	local v1894 = enum[v]
	local v1895 = v1894 and v1894[v1892]

	if v1895 then
		Enums[v1895] = v1893
	end
end)
local v1894 = "UnknownBespokeFilter"
local v1895 = 946
pcall(function()
	local v1896 = enum[v]
	local v1897 = v1896 and v1896[v1894]

	if v1897 then
		Enums[v1897] = v1895
	end
end)
local v1896 = "WildcardInProperty"
local v1897 = 947
pcall(function()
	local v1898 = enum[v]
	local v1899 = v1898 and v1898[v1896]

	if v1899 then
		Enums[v1899] = v1897
	end
end)
v = "FilterResult"
local v1898 = "Accepted"
local v1899 = 948
pcall(function()
	local v1900 = enum[v]
	local v1901 = v1900 and v1900[v1898]

	if v1901 then
		Enums[v1901] = v1899
	end
end)
local v1900 = "Rejected"
local v1901 = 949
pcall(function()
	local v1902 = enum[v]
	local v1903 = v1902 and v1902[v1900]

	if v1903 then
		Enums[v1903] = v1901
	end
end)
v = "FinishRecordingOperation"
local v1902 = "Cancel"
local v1903 = 950
pcall(function()
	local v1904 = enum[v]
	local v1905 = v1904 and v1904[v1902]

	if v1905 then
		Enums[v1905] = v1903
	end
end)
local v1904 = "Commit"
local v1905 = 951
pcall(function()
	local v1906 = enum[v]
	local v1907 = v1906 and v1906[v1904]

	if v1907 then
		Enums[v1907] = v1905
	end
end)
local v1906 = "Append"
local v1907 = 952
pcall(function()
	local v1908 = enum[v]
	local v1909 = v1908 and v1908[v1906]

	if v1909 then
		Enums[v1909] = v1907
	end
end)
v = "FluidFidelity"
local v1908 = "Automatic"
local v1909 = 953
pcall(function()
	local v1910 = enum[v]
	local v1911 = v1910 and v1910[v1908]

	if v1911 then
		Enums[v1911] = v1909
	end
end)
local v1910 = "UseCollisionGeometry"
local v1911 = 954
pcall(function()
	local v1912 = enum[v]
	local v1913 = v1912 and v1912[v1910]

	if v1913 then
		Enums[v1913] = v1911
	end
end)
local v1912 = "UsePreciseGeometry"
local v1913 = 955
pcall(function()
	local v1914 = enum[v]
	local v1915 = v1914 and v1914[v1912]

	if v1915 then
		Enums[v1915] = v1913
	end
end)
v = "FluidForces"
local v1914 = "Default"
local v1915 = 956
pcall(function()
	local v1916 = enum[v]
	local v1917 = v1916 and v1916[v1914]

	if v1917 then
		Enums[v1917] = v1915
	end
end)
local v1916 = "Experimental"
local v1917 = 957
pcall(function()
	local v1918 = enum[v]
	local v1919 = v1918 and v1918[v1916]

	if v1919 then
		Enums[v1919] = v1917
	end
end)
v = "Font"
local v1918 = "Legacy"
local v1919 = 958
pcall(function()
	local v1920 = enum[v]
	local v1921 = v1920 and v1920[v1918]

	if v1921 then
		Enums[v1921] = v1919
	end
end)
local v1920 = "Arial"
local v1921 = 959
pcall(function()
	local v1922 = enum[v]
	local v1923 = v1922 and v1922[v1920]

	if v1923 then
		Enums[v1923] = v1921
	end
end)
local v1922 = "ArialBold"
local v1923 = 960
pcall(function()
	local v1924 = enum[v]
	local v1925 = v1924 and v1924[v1922]

	if v1925 then
		Enums[v1925] = v1923
	end
end)
local v1924 = "SourceSans"
local v1925 = 961
pcall(function()
	local v1926 = enum[v]
	local v1927 = v1926 and v1926[v1924]

	if v1927 then
		Enums[v1927] = v1925
	end
end)
local v1926 = "SourceSansBold"
local v1927 = 962
pcall(function()
	local v1928 = enum[v]
	local v1929 = v1928 and v1928[v1926]

	if v1929 then
		Enums[v1929] = v1927
	end
end)
local v1928 = "SourceSansLight"
local v1929 = 963
pcall(function()
	local v1930 = enum[v]
	local v1931 = v1930 and v1930[v1928]

	if v1931 then
		Enums[v1931] = v1929
	end
end)
local v1930 = "SourceSansItalic"
local v1931 = 964
pcall(function()
	local v1932 = enum[v]
	local v1933 = v1932 and v1932[v1930]

	if v1933 then
		Enums[v1933] = v1931
	end
end)
local v1932 = "Bodoni"
local v1933 = 965
pcall(function()
	local v1934 = enum[v]
	local v1935 = v1934 and v1934[v1932]

	if v1935 then
		Enums[v1935] = v1933
	end
end)
local v1934 = "Garamond"
local v1935 = 966
pcall(function()
	local v1936 = enum[v]
	local v1937 = v1936 and v1936[v1934]

	if v1937 then
		Enums[v1937] = v1935
	end
end)
local v1936 = "Cartoon"
local v1937 = 967
pcall(function()
	local v1938 = enum[v]
	local v1939 = v1938 and v1938[v1936]

	if v1939 then
		Enums[v1939] = v1937
	end
end)
local v1938 = "Code"
local v1939 = 968
pcall(function()
	local v1940 = enum[v]
	local v1941 = v1940 and v1940[v1938]

	if v1941 then
		Enums[v1941] = v1939
	end
end)
local v1940 = "Highway"
local v1941 = 969
pcall(function()
	local v1942 = enum[v]
	local v1943 = v1942 and v1942[v1940]

	if v1943 then
		Enums[v1943] = v1941
	end
end)
local v1942 = "SciFi"
local v1943 = 970
pcall(function()
	local v1944 = enum[v]
	local v1945 = v1944 and v1944[v1942]

	if v1945 then
		Enums[v1945] = v1943
	end
end)
local v1944 = "Arcade"
local v1945 = 971
pcall(function()
	local v1946 = enum[v]
	local v1947 = v1946 and v1946[v1944]

	if v1947 then
		Enums[v1947] = v1945
	end
end)
local v1946 = "Fantasy"
local v1947 = 972
pcall(function()
	local v1948 = enum[v]
	local v1949 = v1948 and v1948[v1946]

	if v1949 then
		Enums[v1949] = v1947
	end
end)
local v1948 = "Antique"
local v1949 = 973
pcall(function()
	local v1950 = enum[v]
	local v1951 = v1950 and v1950[v1948]

	if v1951 then
		Enums[v1951] = v1949
	end
end)
local v1950 = "SourceSansSemibold"
local v1951 = 974
pcall(function()
	local v1952 = enum[v]
	local v1953 = v1952 and v1952[v1950]

	if v1953 then
		Enums[v1953] = v1951
	end
end)
local v1952 = "Gotham"
local v1953 = 975
pcall(function()
	local v1954 = enum[v]
	local v1955 = v1954 and v1954[v1952]

	if v1955 then
		Enums[v1955] = v1953
	end
end)
local v1954 = "GothamMedium"
local v1955 = 976
pcall(function()
	local v1956 = enum[v]
	local v1957 = v1956 and v1956[v1954]

	if v1957 then
		Enums[v1957] = v1955
	end
end)
local v1956 = "GothamBold"
local v1957 = 977
pcall(function()
	local v1958 = enum[v]
	local v1959 = v1958 and v1958[v1956]

	if v1959 then
		Enums[v1959] = v1957
	end
end)
local v1958 = "GothamBlack"
local v1959 = 978
pcall(function()
	local v1960 = enum[v]
	local v1961 = v1960 and v1960[v1958]

	if v1961 then
		Enums[v1961] = v1959
	end
end)
local v1960 = "AmaticSC"
local v1961 = 979
pcall(function()
	local v1962 = enum[v]
	local v1963 = v1962 and v1962[v1960]

	if v1963 then
		Enums[v1963] = v1961
	end
end)
local v1962 = "Bangers"
local v1963 = 980
pcall(function()
	local v1964 = enum[v]
	local v1965 = v1964 and v1964[v1962]

	if v1965 then
		Enums[v1965] = v1963
	end
end)
local v1964 = "Creepster"
local v1965 = 981
pcall(function()
	local v1966 = enum[v]
	local v1967 = v1966 and v1966[v1964]

	if v1967 then
		Enums[v1967] = v1965
	end
end)
local v1966 = "DenkOne"
local v1967 = 982
pcall(function()
	local v1968 = enum[v]
	local v1969 = v1968 and v1968[v1966]

	if v1969 then
		Enums[v1969] = v1967
	end
end)
local v1968 = "Fondamento"
local v1969 = 983
pcall(function()
	local v1970 = enum[v]
	local v1971 = v1970 and v1970[v1968]

	if v1971 then
		Enums[v1971] = v1969
	end
end)
local v1970 = "FredokaOne"
local v1971 = 984
pcall(function()
	local v1972 = enum[v]
	local v1973 = v1972 and v1972[v1970]

	if v1973 then
		Enums[v1973] = v1971
	end
end)
local v1972 = "GrenzeGotisch"
local v1973 = 985
pcall(function()
	local v1974 = enum[v]
	local v1975 = v1974 and v1974[v1972]

	if v1975 then
		Enums[v1975] = v1973
	end
end)
local v1974 = "IndieFlower"
local v1975 = 986
pcall(function()
	local v1976 = enum[v]
	local v1977 = v1976 and v1976[v1974]

	if v1977 then
		Enums[v1977] = v1975
	end
end)
local v1976 = "JosefinSans"
local v1977 = 987
pcall(function()
	local v1978 = enum[v]
	local v1979 = v1978 and v1978[v1976]

	if v1979 then
		Enums[v1979] = v1977
	end
end)
local v1978 = "Jura"
local v1979 = 988
pcall(function()
	local v1980 = enum[v]
	local v1981 = v1980 and v1980[v1978]

	if v1981 then
		Enums[v1981] = v1979
	end
end)
local v1980 = "Kalam"
local v1981 = 989
pcall(function()
	local v1982 = enum[v]
	local v1983 = v1982 and v1982[v1980]

	if v1983 then
		Enums[v1983] = v1981
	end
end)
local v1982 = "LuckiestGuy"
local v1983 = 990
pcall(function()
	local v1984 = enum[v]
	local v1985 = v1984 and v1984[v1982]

	if v1985 then
		Enums[v1985] = v1983
	end
end)
local v1984 = "Merriweather"
local v1985 = 991
pcall(function()
	local v1986 = enum[v]
	local v1987 = v1986 and v1986[v1984]

	if v1987 then
		Enums[v1987] = v1985
	end
end)
local v1986 = "Michroma"
local v1987 = 992
pcall(function()
	local v1988 = enum[v]
	local v1989 = v1988 and v1988[v1986]

	if v1989 then
		Enums[v1989] = v1987
	end
end)
local v1988 = "Nunito"
local v1989 = 993
pcall(function()
	local v1990 = enum[v]
	local v1991 = v1990 and v1990[v1988]

	if v1991 then
		Enums[v1991] = v1989
	end
end)
local v1990 = "Oswald"
local v1991 = 994
pcall(function()
	local v1992 = enum[v]
	local v1993 = v1992 and v1992[v1990]

	if v1993 then
		Enums[v1993] = v1991
	end
end)
local v1992 = "PatrickHand"
local v1993 = 995
pcall(function()
	local v1994 = enum[v]
	local v1995 = v1994 and v1994[v1992]

	if v1995 then
		Enums[v1995] = v1993
	end
end)
local v1994 = "PermanentMarker"
local v1995 = 996
pcall(function()
	local v1996 = enum[v]
	local v1997 = v1996 and v1996[v1994]

	if v1997 then
		Enums[v1997] = v1995
	end
end)
local v1996 = "Roboto"
local v1997 = 997
pcall(function()
	local v1998 = enum[v]
	local v1999 = v1998 and v1998[v1996]

	if v1999 then
		Enums[v1999] = v1997
	end
end)
local v1998 = "RobotoCondensed"
local v1999 = 998
pcall(function()
	local v2000 = enum[v]
	local v2001 = v2000 and v2000[v1998]

	if v2001 then
		Enums[v2001] = v1999
	end
end)
local v2000 = "RobotoMono"
local v2001 = 999
pcall(function()
	local v2002 = enum[v]
	local v2003 = v2002 and v2002[v2000]

	if v2003 then
		Enums[v2003] = v2001
	end
end)
local v2002 = "Sarpanch"
local v2003 = 1000
pcall(function()
	local v2004 = enum[v]
	local v2005 = v2004 and v2004[v2002]

	if v2005 then
		Enums[v2005] = v2003
	end
end)
local v2004 = "SpecialElite"
local v2005 = 1001
pcall(function()
	local v2006 = enum[v]
	local v2007 = v2006 and v2006[v2004]

	if v2007 then
		Enums[v2007] = v2005
	end
end)
local v2006 = "TitilliumWeb"
local v2007 = 1002
pcall(function()
	local v2008 = enum[v]
	local v2009 = v2008 and v2008[v2006]

	if v2009 then
		Enums[v2009] = v2007
	end
end)
local v2008 = "Ubuntu"
local v2009 = 1003
pcall(function()
	local v2010 = enum[v]
	local v2011 = v2010 and v2010[v2008]

	if v2011 then
		Enums[v2011] = v2009
	end
end)
local v2010 = "BuilderSans"
local v2011 = 1004
pcall(function()
	local v2012 = enum[v]
	local v2013 = v2012 and v2012[v2010]

	if v2013 then
		Enums[v2013] = v2011
	end
end)
local v2012 = "BuilderSansMedium"
local v2013 = 1005
pcall(function()
	local v2014 = enum[v]
	local v2015 = v2014 and v2014[v2012]

	if v2015 then
		Enums[v2015] = v2013
	end
end)
local v2014 = "BuilderSansBold"
local v2015 = 1006
pcall(function()
	local v2016 = enum[v]
	local v2017 = v2016 and v2016[v2014]

	if v2017 then
		Enums[v2017] = v2015
	end
end)
local v2016 = "BuilderSansExtraBold"
local v2017 = 1007
pcall(function()
	local v2018 = enum[v]
	local v2019 = v2018 and v2018[v2016]

	if v2019 then
		Enums[v2019] = v2017
	end
end)
local v2018 = "Arimo"
local v2019 = 1008
pcall(function()
	local v2020 = enum[v]
	local v2021 = v2020 and v2020[v2018]

	if v2021 then
		Enums[v2021] = v2019
	end
end)
local v2020 = "ArimoBold"
local v2021 = 1009
pcall(function()
	local v2022 = enum[v]
	local v2023 = v2022 and v2022[v2020]

	if v2023 then
		Enums[v2023] = v2021
	end
end)
local v2022 = "Unknown"
local v2023 = 1010
pcall(function()
	local v2024 = enum[v]
	local v2025 = v2024 and v2024[v2022]

	if v2025 then
		Enums[v2025] = v2023
	end
end)
v = "FontSize"
local v2024 = "Size8"
local v2025 = 1011
pcall(function()
	local v2026 = enum[v]
	local v2027 = v2026 and v2026[v2024]

	if v2027 then
		Enums[v2027] = v2025
	end
end)
local v2026 = "Size9"
local v2027 = 1012
pcall(function()
	local v2028 = enum[v]
	local v2029 = v2028 and v2028[v2026]

	if v2029 then
		Enums[v2029] = v2027
	end
end)
local v2028 = "Size10"
local v2029 = 1013
pcall(function()
	local v2030 = enum[v]
	local v2031 = v2030 and v2030[v2028]

	if v2031 then
		Enums[v2031] = v2029
	end
end)
local v2030 = "Size11"
local v2031 = 1014
pcall(function()
	local v2032 = enum[v]
	local v2033 = v2032 and v2032[v2030]

	if v2033 then
		Enums[v2033] = v2031
	end
end)
local v2032 = "Size12"
local v2033 = 1015
pcall(function()
	local v2034 = enum[v]
	local v2035 = v2034 and v2034[v2032]

	if v2035 then
		Enums[v2035] = v2033
	end
end)
local v2034 = "Size14"
local v2035 = 1016
pcall(function()
	local v2036 = enum[v]
	local v2037 = v2036 and v2036[v2034]

	if v2037 then
		Enums[v2037] = v2035
	end
end)
local v2036 = "Size18"
local v2037 = 1017
pcall(function()
	local v2038 = enum[v]
	local v2039 = v2038 and v2038[v2036]

	if v2039 then
		Enums[v2039] = v2037
	end
end)
local v2038 = "Size24"
local v2039 = 1018
pcall(function()
	local v2040 = enum[v]
	local v2041 = v2040 and v2040[v2038]

	if v2041 then
		Enums[v2041] = v2039
	end
end)
local v2040 = "Size36"
local v2041 = 1019
pcall(function()
	local v2042 = enum[v]
	local v2043 = v2042 and v2042[v2040]

	if v2043 then
		Enums[v2043] = v2041
	end
end)
local v2042 = "Size48"
local v2043 = 1020
pcall(function()
	local v2044 = enum[v]
	local v2045 = v2044 and v2044[v2042]

	if v2045 then
		Enums[v2045] = v2043
	end
end)
local v2044 = "Size28"
local v2045 = 1021
pcall(function()
	local v2046 = enum[v]
	local v2047 = v2046 and v2046[v2044]

	if v2047 then
		Enums[v2047] = v2045
	end
end)
local v2046 = "Size32"
local v2047 = 1022
pcall(function()
	local v2048 = enum[v]
	local v2049 = v2048 and v2048[v2046]

	if v2049 then
		Enums[v2049] = v2047
	end
end)
local v2048 = "Size42"
local v2049 = 1023
pcall(function()
	local v2050 = enum[v]
	local v2051 = v2050 and v2050[v2048]

	if v2051 then
		Enums[v2051] = v2049
	end
end)
local v2050 = "Size60"
local v2051 = 1024
pcall(function()
	local v2052 = enum[v]
	local v2053 = v2052 and v2052[v2050]

	if v2053 then
		Enums[v2053] = v2051
	end
end)
local v2052 = "Size96"
local v2053 = 1025
pcall(function()
	local v2054 = enum[v]
	local v2055 = v2054 and v2054[v2052]

	if v2055 then
		Enums[v2055] = v2053
	end
end)
v = "FontStyle"
local v2054 = "Normal"
local v2055 = 1026
pcall(function()
	local v2056 = enum[v]
	local v2057 = v2056 and v2056[v2054]

	if v2057 then
		Enums[v2057] = v2055
	end
end)
local v2056 = "Italic"
local v2057 = 1027
pcall(function()
	local v2058 = enum[v]
	local v2059 = v2058 and v2058[v2056]

	if v2059 then
		Enums[v2059] = v2057
	end
end)
v = "FontWeight"
local v2058 = "Thin"
local v2059 = 1028
pcall(function()
	local v2060 = enum[v]
	local v2061 = v2060 and v2060[v2058]

	if v2061 then
		Enums[v2061] = v2059
	end
end)
local v2060 = "ExtraLight"
local v2061 = 1029
pcall(function()
	local v2062 = enum[v]
	local v2063 = v2062 and v2062[v2060]

	if v2063 then
		Enums[v2063] = v2061
	end
end)
local v2062 = "Light"
local v2063 = 1030
pcall(function()
	local v2064 = enum[v]
	local v2065 = v2064 and v2064[v2062]

	if v2065 then
		Enums[v2065] = v2063
	end
end)
local v2064 = "Regular"
local v2065 = 1031
pcall(function()
	local v2066 = enum[v]
	local v2067 = v2066 and v2066[v2064]

	if v2067 then
		Enums[v2067] = v2065
	end
end)
local v2066 = "Medium"
local v2067 = 1032
pcall(function()
	local v2068 = enum[v]
	local v2069 = v2068 and v2068[v2066]

	if v2069 then
		Enums[v2069] = v2067
	end
end)
local v2068 = "SemiBold"
local v2069 = 1033
pcall(function()
	local v2070 = enum[v]
	local v2071 = v2070 and v2070[v2068]

	if v2071 then
		Enums[v2071] = v2069
	end
end)
local v2070 = "Bold"
local v2071 = 1034
pcall(function()
	local v2072 = enum[v]
	local v2073 = v2072 and v2072[v2070]

	if v2073 then
		Enums[v2073] = v2071
	end
end)
local v2072 = "ExtraBold"
local v2073 = 1035
pcall(function()
	local v2074 = enum[v]
	local v2075 = v2074 and v2074[v2072]

	if v2075 then
		Enums[v2075] = v2073
	end
end)
local v2074 = "Heavy"
local v2075 = 1036
pcall(function()
	local v2076 = enum[v]
	local v2077 = v2076 and v2076[v2074]

	if v2077 then
		Enums[v2077] = v2075
	end
end)
v = "ForceLimitMode"
local v2076 = "Magnitude"
local v2077 = 1037
pcall(function()
	local v2078 = enum[v]
	local v2079 = v2078 and v2078[v2076]

	if v2079 then
		Enums[v2079] = v2077
	end
end)
local v2078 = "PerAxis"
local v2079 = 1038
pcall(function()
	local v2080 = enum[v]
	local v2081 = v2080 and v2080[v2078]

	if v2081 then
		Enums[v2081] = v2079
	end
end)
v = "FormFactor"
local v2080 = "Symmetric"
local v2081 = 1039
pcall(function()
	local v2082 = enum[v]
	local v2083 = v2082 and v2082[v2080]

	if v2083 then
		Enums[v2083] = v2081
	end
end)
local v2082 = "Brick"
local v2083 = 1040
pcall(function()
	local v2084 = enum[v]
	local v2085 = v2084 and v2084[v2082]

	if v2085 then
		Enums[v2085] = v2083
	end
end)
local v2084 = "Plate"
local v2085 = 1041
pcall(function()
	local v2086 = enum[v]
	local v2087 = v2086 and v2086[v2084]

	if v2087 then
		Enums[v2087] = v2085
	end
end)
local v2086 = "Custom"
local v2087 = 1042
pcall(function()
	local v2088 = enum[v]
	local v2089 = v2088 and v2088[v2086]

	if v2089 then
		Enums[v2089] = v2087
	end
end)
v = "FrameStyle"
local v2088 = "Custom"
local v2089 = 1043
pcall(function()
	local v2090 = enum[v]
	local v2091 = v2090 and v2090[v2088]

	if v2091 then
		Enums[v2091] = v2089
	end
end)
local v2090 = "ChatBlue"
local v2091 = 1044
pcall(function()
	local v2092 = enum[v]
	local v2093 = v2092 and v2092[v2090]

	if v2093 then
		Enums[v2093] = v2091
	end
end)
local v2092 = "RobloxSquare"
local v2093 = 1045
pcall(function()
	local v2094 = enum[v]
	local v2095 = v2094 and v2094[v2092]

	if v2095 then
		Enums[v2095] = v2093
	end
end)
local v2094 = "RobloxRound"
local v2095 = 1046
pcall(function()
	local v2096 = enum[v]
	local v2097 = v2096 and v2096[v2094]

	if v2097 then
		Enums[v2097] = v2095
	end
end)
local v2096 = "ChatGreen"
local v2097 = 1047
pcall(function()
	local v2098 = enum[v]
	local v2099 = v2098 and v2098[v2096]

	if v2099 then
		Enums[v2099] = v2097
	end
end)
local v2098 = "ChatRed"
local v2099 = 1048
pcall(function()
	local v2100 = enum[v]
	local v2101 = v2100 and v2100[v2098]

	if v2101 then
		Enums[v2101] = v2099
	end
end)
local v2100 = "DropShadow"
local v2101 = 1049
pcall(function()
	local v2102 = enum[v]
	local v2103 = v2102 and v2102[v2100]

	if v2103 then
		Enums[v2103] = v2101
	end
end)
v = "FramerateManagerMode"
local v2102 = "Automatic"
local v2103 = 1050
pcall(function()
	local v2104 = enum[v]
	local v2105 = v2104 and v2104[v2102]

	if v2105 then
		Enums[v2105] = v2103
	end
end)
local v2104 = "On"
local v2105 = 1051
pcall(function()
	local v2106 = enum[v]
	local v2107 = v2106 and v2106[v2104]

	if v2107 then
		Enums[v2107] = v2105
	end
end)
local v2106 = "Off"
local v2107 = 1052
pcall(function()
	local v2108 = enum[v]
	local v2109 = v2108 and v2108[v2106]

	if v2109 then
		Enums[v2109] = v2107
	end
end)
v = "FriendRequestEvent"
local v2108 = "Issue"
local v2109 = 1053
pcall(function()
	local v2110 = enum[v]
	local v2111 = v2110 and v2110[v2108]

	if v2111 then
		Enums[v2111] = v2109
	end
end)
local v2110 = "Revoke"
local v2111 = 1054
pcall(function()
	local v2112 = enum[v]
	local v2113 = v2112 and v2112[v2110]

	if v2113 then
		Enums[v2113] = v2111
	end
end)
local v2112 = "Accept"
local v2113 = 1055
pcall(function()
	local v2114 = enum[v]
	local v2115 = v2114 and v2114[v2112]

	if v2115 then
		Enums[v2115] = v2113
	end
end)
local v2114 = "Deny"
local v2115 = 1056
pcall(function()
	local v2116 = enum[v]
	local v2117 = v2116 and v2116[v2114]

	if v2117 then
		Enums[v2117] = v2115
	end
end)
v = "FriendStatus"
local v2116 = "Unknown"
local v2117 = 1057
pcall(function()
	local v2118 = enum[v]
	local v2119 = v2118 and v2118[v2116]

	if v2119 then
		Enums[v2119] = v2117
	end
end)
local v2118 = "NotFriend"
local v2119 = 1058
pcall(function()
	local v2120 = enum[v]
	local v2121 = v2120 and v2120[v2118]

	if v2121 then
		Enums[v2121] = v2119
	end
end)
local v2120 = "Friend"
local v2121 = 1059
pcall(function()
	local v2122 = enum[v]
	local v2123 = v2122 and v2122[v2120]

	if v2123 then
		Enums[v2123] = v2121
	end
end)
local v2122 = "FriendRequestSent"
local v2123 = 1060
pcall(function()
	local v2124 = enum[v]
	local v2125 = v2124 and v2124[v2122]

	if v2125 then
		Enums[v2125] = v2123
	end
end)
local v2124 = "FriendRequestReceived"
local v2125 = 1061
pcall(function()
	local v2126 = enum[v]
	local v2127 = v2126 and v2126[v2124]

	if v2127 then
		Enums[v2127] = v2125
	end
end)
v = "FunctionalTestResult"
local v2126 = "Passed"
local v2127 = 1062
pcall(function()
	local v2128 = enum[v]
	local v2129 = v2128 and v2128[v2126]

	if v2129 then
		Enums[v2129] = v2127
	end
end)
local v2128 = "Warning"
local v2129 = 1063
pcall(function()
	local v2130 = enum[v]
	local v2131 = v2130 and v2130[v2128]

	if v2131 then
		Enums[v2131] = v2129
	end
end)
local v2130 = "Error"
local v2131 = 1064
pcall(function()
	local v2132 = enum[v]
	local v2133 = v2132 and v2132[v2130]

	if v2133 then
		Enums[v2133] = v2131
	end
end)
v = "GameAvatarType"
local v2132 = "R6"
local v2133 = 1065
pcall(function()
	local v2134 = enum[v]
	local v2135 = v2134 and v2134[v2132]

	if v2135 then
		Enums[v2135] = v2133
	end
end)
local v2134 = "R15"
local v2135 = 1066
pcall(function()
	local v2136 = enum[v]
	local v2137 = v2136 and v2136[v2134]

	if v2137 then
		Enums[v2137] = v2135
	end
end)
local v2136 = "PlayerChoice"
local v2137 = 1067
pcall(function()
	local v2138 = enum[v]
	local v2139 = v2138 and v2138[v2136]

	if v2139 then
		Enums[v2139] = v2137
	end
end)
v = "GamepadType"
local v2138 = "Unknown"
local v2139 = 1068
pcall(function()
	local v2140 = enum[v]
	local v2141 = v2140 and v2140[v2138]

	if v2141 then
		Enums[v2141] = v2139
	end
end)
local v2140 = "PS4"
local v2141 = 1069
pcall(function()
	local v2142 = enum[v]
	local v2143 = v2142 and v2142[v2140]

	if v2143 then
		Enums[v2143] = v2141
	end
end)
local v2142 = "PS5"
local v2143 = 1070
pcall(function()
	local v2144 = enum[v]
	local v2145 = v2144 and v2144[v2142]

	if v2145 then
		Enums[v2145] = v2143
	end
end)
local v2144 = "XboxOne"
local v2145 = 1071
pcall(function()
	local v2146 = enum[v]
	local v2147 = v2146 and v2146[v2144]

	if v2147 then
		Enums[v2147] = v2145
	end
end)
v = "GearGenreSetting"
local v2146 = "AllGenres"
local v2147 = 1072
pcall(function()
	local v2148 = enum[v]
	local v2149 = v2148 and v2148[v2146]

	if v2149 then
		Enums[v2149] = v2147
	end
end)
local v2148 = "MatchingGenreOnly"
local v2149 = 1073
pcall(function()
	local v2150 = enum[v]
	local v2151 = v2150 and v2150[v2148]

	if v2151 then
		Enums[v2151] = v2149
	end
end)
v = "GearType"
local v2150 = "MeleeWeapons"
local v2151 = 1074
pcall(function()
	local v2152 = enum[v]
	local v2153 = v2152 and v2152[v2150]

	if v2153 then
		Enums[v2153] = v2151
	end
end)
local v2152 = "RangedWeapons"
local v2153 = 1075
pcall(function()
	local v2154 = enum[v]
	local v2155 = v2154 and v2154[v2152]

	if v2155 then
		Enums[v2155] = v2153
	end
end)
local v2154 = "Explosives"
local v2155 = 1076
pcall(function()
	local v2156 = enum[v]
	local v2157 = v2156 and v2156[v2154]

	if v2157 then
		Enums[v2157] = v2155
	end
end)
local v2156 = "PowerUps"
local v2157 = 1077
pcall(function()
	local v2158 = enum[v]
	local v2159 = v2158 and v2158[v2156]

	if v2159 then
		Enums[v2159] = v2157
	end
end)
local v2158 = "NavigationEnhancers"
local v2159 = 1078
pcall(function()
	local v2160 = enum[v]
	local v2161 = v2160 and v2160[v2158]

	if v2161 then
		Enums[v2161] = v2159
	end
end)
local v2160 = "MusicalInstruments"
local v2161 = 1079
pcall(function()
	local v2162 = enum[v]
	local v2163 = v2162 and v2162[v2160]

	if v2163 then
		Enums[v2163] = v2161
	end
end)
local v2162 = "SocialItems"
local v2163 = 1080
pcall(function()
	local v2164 = enum[v]
	local v2165 = v2164 and v2164[v2162]

	if v2165 then
		Enums[v2165] = v2163
	end
end)
local v2164 = "BuildingTools"
local v2165 = 1081
pcall(function()
	local v2166 = enum[v]
	local v2167 = v2166 and v2166[v2164]

	if v2167 then
		Enums[v2167] = v2165
	end
end)
local v2166 = "Transport"
local v2167 = 1082
pcall(function()
	local v2168 = enum[v]
	local v2169 = v2168 and v2168[v2166]

	if v2169 then
		Enums[v2169] = v2167
	end
end)
v = "Genre"
local v2168 = "All"
local v2169 = 1083
pcall(function()
	local v2170 = enum[v]
	local v2171 = v2170 and v2170[v2168]

	if v2171 then
		Enums[v2171] = v2169
	end
end)
local v2170 = "TownAndCity"
local v2171 = 1084
pcall(function()
	local v2172 = enum[v]
	local v2173 = v2172 and v2172[v2170]

	if v2173 then
		Enums[v2173] = v2171
	end
end)
local v2172 = "Fantasy"
local v2173 = 1085
pcall(function()
	local v2174 = enum[v]
	local v2175 = v2174 and v2174[v2172]

	if v2175 then
		Enums[v2175] = v2173
	end
end)
local v2174 = "SciFi"
local v2175 = 1086
pcall(function()
	local v2176 = enum[v]
	local v2177 = v2176 and v2176[v2174]

	if v2177 then
		Enums[v2177] = v2175
	end
end)
local v2176 = "Ninja"
local v2177 = 1087
pcall(function()
	local v2178 = enum[v]
	local v2179 = v2178 and v2178[v2176]

	if v2179 then
		Enums[v2179] = v2177
	end
end)
local v2178 = "Scary"
local v2179 = 1088
pcall(function()
	local v2180 = enum[v]
	local v2181 = v2180 and v2180[v2178]

	if v2181 then
		Enums[v2181] = v2179
	end
end)
local v2180 = "Pirate"
local v2181 = 1089
pcall(function()
	local v2182 = enum[v]
	local v2183 = v2182 and v2182[v2180]

	if v2183 then
		Enums[v2183] = v2181
	end
end)
local v2182 = "Adventure"
local v2183 = 1090
pcall(function()
	local v2184 = enum[v]
	local v2185 = v2184 and v2184[v2182]

	if v2185 then
		Enums[v2185] = v2183
	end
end)
local v2184 = "Sports"
local v2185 = 1091
pcall(function()
	local v2186 = enum[v]
	local v2187 = v2186 and v2186[v2184]

	if v2187 then
		Enums[v2187] = v2185
	end
end)
local v2186 = "Funny"
local v2187 = 1092
pcall(function()
	local v2188 = enum[v]
	local v2189 = v2188 and v2188[v2186]

	if v2189 then
		Enums[v2189] = v2187
	end
end)
local v2188 = "WildWest"
local v2189 = 1093
pcall(function()
	local v2190 = enum[v]
	local v2191 = v2190 and v2190[v2188]

	if v2191 then
		Enums[v2191] = v2189
	end
end)
local v2190 = "War"
local v2191 = 1094
pcall(function()
	local v2192 = enum[v]
	local v2193 = v2192 and v2192[v2190]

	if v2193 then
		Enums[v2193] = v2191
	end
end)
local v2192 = "SkatePark"
local v2193 = 1095
pcall(function()
	local v2194 = enum[v]
	local v2195 = v2194 and v2194[v2192]

	if v2195 then
		Enums[v2195] = v2193
	end
end)
local v2194 = "Tutorial"
local v2195 = 1096
pcall(function()
	local v2196 = enum[v]
	local v2197 = v2196 and v2196[v2194]

	if v2197 then
		Enums[v2197] = v2195
	end
end)
v = "GraphicsMode"
local v2196 = "Automatic"
local v2197 = 1097
pcall(function()
	local v2198 = enum[v]
	local v2199 = v2198 and v2198[v2196]

	if v2199 then
		Enums[v2199] = v2197
	end
end)
local v2198 = "Direct3D11"
local v2199 = 1098
pcall(function()
	local v2200 = enum[v]
	local v2201 = v2200 and v2200[v2198]

	if v2201 then
		Enums[v2201] = v2199
	end
end)
local v2200 = "OpenGL"
local v2201 = 1099
pcall(function()
	local v2202 = enum[v]
	local v2203 = v2202 and v2202[v2200]

	if v2203 then
		Enums[v2203] = v2201
	end
end)
local v2202 = "Metal"
local v2203 = 1100
pcall(function()
	local v2204 = enum[v]
	local v2205 = v2204 and v2204[v2202]

	if v2205 then
		Enums[v2205] = v2203
	end
end)
local v2204 = "Vulkan"
local v2205 = 1101
pcall(function()
	local v2206 = enum[v]
	local v2207 = v2206 and v2206[v2204]

	if v2207 then
		Enums[v2207] = v2205
	end
end)
local v2206 = "NoGraphics"
local v2207 = 1102
pcall(function()
	local v2208 = enum[v]
	local v2209 = v2208 and v2208[v2206]

	if v2209 then
		Enums[v2209] = v2207
	end
end)
v = "GraphicsOptimizationMode"
local v2208 = "Performance"
local v2209 = 1103
pcall(function()
	local v2210 = enum[v]
	local v2211 = v2210 and v2210[v2208]

	if v2211 then
		Enums[v2211] = v2209
	end
end)
local v2210 = "Balanced"
local v2211 = 1104
pcall(function()
	local v2212 = enum[v]
	local v2213 = v2212 and v2212[v2210]

	if v2213 then
		Enums[v2213] = v2211
	end
end)
local v2212 = "Quality"
local v2213 = 1105
pcall(function()
	local v2214 = enum[v]
	local v2215 = v2214 and v2214[v2212]

	if v2215 then
		Enums[v2215] = v2213
	end
end)
v = "GuiState"
local v2214 = "Idle"
local v2215 = 1106
pcall(function()
	local v2216 = enum[v]
	local v2217 = v2216 and v2216[v2214]

	if v2217 then
		Enums[v2217] = v2215
	end
end)
local v2216 = "Hover"
local v2217 = 1107
pcall(function()
	local v2218 = enum[v]
	local v2219 = v2218 and v2218[v2216]

	if v2219 then
		Enums[v2219] = v2217
	end
end)
local v2218 = "Press"
local v2219 = 1108
pcall(function()
	local v2220 = enum[v]
	local v2221 = v2220 and v2220[v2218]

	if v2221 then
		Enums[v2221] = v2219
	end
end)
local v2220 = "NonInteractable"
local v2221 = 1109
pcall(function()
	local v2222 = enum[v]
	local v2223 = v2222 and v2222[v2220]

	if v2223 then
		Enums[v2223] = v2221
	end
end)
v = "GuiType"
local v2222 = "Core"
local v2223 = 1110
pcall(function()
	local v2224 = enum[v]
	local v2225 = v2224 and v2224[v2222]

	if v2225 then
		Enums[v2225] = v2223
	end
end)
local v2224 = "Custom"
local v2225 = 1111
pcall(function()
	local v2226 = enum[v]
	local v2227 = v2226 and v2226[v2224]

	if v2227 then
		Enums[v2227] = v2225
	end
end)
local v2226 = "PlayerNameplates"
local v2227 = 1112
pcall(function()
	local v2228 = enum[v]
	local v2229 = v2228 and v2228[v2226]

	if v2229 then
		Enums[v2229] = v2227
	end
end)
local v2228 = "CustomBillboards"
local v2229 = 1113
pcall(function()
	local v2230 = enum[v]
	local v2231 = v2230 and v2230[v2228]

	if v2231 then
		Enums[v2231] = v2229
	end
end)
local v2230 = "CoreBillboards"
local v2231 = 1114
pcall(function()
	local v2232 = enum[v]
	local v2233 = v2232 and v2232[v2230]

	if v2233 then
		Enums[v2233] = v2231
	end
end)
v = "HandlesStyle"
local v2232 = "Resize"
local v2233 = 1115
pcall(function()
	local v2234 = enum[v]
	local v2235 = v2234 and v2234[v2232]

	if v2235 then
		Enums[v2235] = v2233
	end
end)
local v2234 = "Movement"
local v2235 = 1116
pcall(function()
	local v2236 = enum[v]
	local v2237 = v2236 and v2236[v2234]

	if v2237 then
		Enums[v2237] = v2235
	end
end)
v = "HapticEffectType"
local v2236 = "Custom"
local v2237 = 1117
pcall(function()
	local v2238 = enum[v]
	local v2239 = v2238 and v2238[v2236]

	if v2239 then
		Enums[v2239] = v2237
	end
end)
local v2238 = "UIHover"
local v2239 = 1118
pcall(function()
	local v2240 = enum[v]
	local v2241 = v2240 and v2240[v2238]

	if v2241 then
		Enums[v2241] = v2239
	end
end)
local v2240 = "UIClick"
local v2241 = 1119
pcall(function()
	local v2242 = enum[v]
	local v2243 = v2242 and v2242[v2240]

	if v2243 then
		Enums[v2243] = v2241
	end
end)
local v2242 = "UINotification"
local v2243 = 1120
pcall(function()
	local v2244 = enum[v]
	local v2245 = v2244 and v2244[v2242]

	if v2245 then
		Enums[v2245] = v2243
	end
end)
local v2244 = "GameplayExplosion"
local v2245 = 1121
pcall(function()
	local v2246 = enum[v]
	local v2247 = v2246 and v2246[v2244]

	if v2247 then
		Enums[v2247] = v2245
	end
end)
local v2246 = "GameplayCollision"
local v2247 = 1122
pcall(function()
	local v2248 = enum[v]
	local v2249 = v2248 and v2248[v2246]

	if v2249 then
		Enums[v2249] = v2247
	end
end)
v = "HighlightDepthMode"
local v2248 = "AlwaysOnTop"
local v2249 = 1123
pcall(function()
	local v2250 = enum[v]
	local v2251 = v2250 and v2250[v2248]

	if v2251 then
		Enums[v2251] = v2249
	end
end)
local v2250 = "Occluded"
local v2251 = 1124
pcall(function()
	local v2252 = enum[v]
	local v2253 = v2252 and v2252[v2250]

	if v2253 then
		Enums[v2253] = v2251
	end
end)
v = "HorizontalAlignment"
local v2252 = "Center"
local v2253 = 1125
pcall(function()
	local v2254 = enum[v]
	local v2255 = v2254 and v2254[v2252]

	if v2255 then
		Enums[v2255] = v2253
	end
end)
local v2254 = "Left"
local v2255 = 1126
pcall(function()
	local v2256 = enum[v]
	local v2257 = v2256 and v2256[v2254]

	if v2257 then
		Enums[v2257] = v2255
	end
end)
local v2256 = "Right"
local v2257 = 1127
pcall(function()
	local v2258 = enum[v]
	local v2259 = v2258 and v2258[v2256]

	if v2259 then
		Enums[v2259] = v2257
	end
end)
v = "HoverAnimateSpeed"
local v2258 = "VerySlow"
local v2259 = 1128
pcall(function()
	local v2260 = enum[v]
	local v2261 = v2260 and v2260[v2258]

	if v2261 then
		Enums[v2261] = v2259
	end
end)
local v2260 = "Slow"
local v2261 = 1129
pcall(function()
	local v2262 = enum[v]
	local v2263 = v2262 and v2262[v2260]

	if v2263 then
		Enums[v2263] = v2261
	end
end)
local v2262 = "Medium"
local v2263 = 1130
pcall(function()
	local v2264 = enum[v]
	local v2265 = v2264 and v2264[v2262]

	if v2265 then
		Enums[v2265] = v2263
	end
end)
local v2264 = "Fast"
local v2265 = 1131
pcall(function()
	local v2266 = enum[v]
	local v2267 = v2266 and v2266[v2264]

	if v2267 then
		Enums[v2267] = v2265
	end
end)
local v2266 = "VeryFast"
local v2267 = 1132
pcall(function()
	local v2268 = enum[v]
	local v2269 = v2268 and v2268[v2266]

	if v2269 then
		Enums[v2269] = v2267
	end
end)
v = "HttpCachePolicy"
local v2268 = "None"
local v2269 = 1133
pcall(function()
	local v2270 = enum[v]
	local v2271 = v2270 and v2270[v2268]

	if v2271 then
		Enums[v2271] = v2269
	end
end)
local v2270 = "Full"
local v2271 = 1134
pcall(function()
	local v2272 = enum[v]
	local v2273 = v2272 and v2272[v2270]

	if v2273 then
		Enums[v2273] = v2271
	end
end)
local v2272 = "DataOnly"
local v2273 = 1135
pcall(function()
	local v2274 = enum[v]
	local v2275 = v2274 and v2274[v2272]

	if v2275 then
		Enums[v2275] = v2273
	end
end)
local v2274 = "Default"
local v2275 = 1136
pcall(function()
	local v2276 = enum[v]
	local v2277 = v2276 and v2276[v2274]

	if v2277 then
		Enums[v2277] = v2275
	end
end)
local v2276 = "InternalRedirectRefresh"
local v2277 = 1137
pcall(function()
	local v2278 = enum[v]
	local v2279 = v2278 and v2278[v2276]

	if v2279 then
		Enums[v2279] = v2277
	end
end)
v = "HttpCompression"
local v2278 = "None"
local v2279 = 1138
pcall(function()
	local v2280 = enum[v]
	local v2281 = v2280 and v2280[v2278]

	if v2281 then
		Enums[v2281] = v2279
	end
end)
local v2280 = "Gzip"
local v2281 = 1139
pcall(function()
	local v2282 = enum[v]
	local v2283 = v2282 and v2282[v2280]

	if v2283 then
		Enums[v2283] = v2281
	end
end)
v = "HttpContentType"
local v2282 = "ApplicationJson"
local v2283 = 1140
pcall(function()
	local v2284 = enum[v]
	local v2285 = v2284 and v2284[v2282]

	if v2285 then
		Enums[v2285] = v2283
	end
end)
local v2284 = "ApplicationXml"
local v2285 = 1141
pcall(function()
	local v2286 = enum[v]
	local v2287 = v2286 and v2286[v2284]

	if v2287 then
		Enums[v2287] = v2285
	end
end)
local v2286 = "ApplicationUrlEncoded"
local v2287 = 1142
pcall(function()
	local v2288 = enum[v]
	local v2289 = v2288 and v2288[v2286]

	if v2289 then
		Enums[v2289] = v2287
	end
end)
local v2288 = "TextPlain"
local v2289 = 1143
pcall(function()
	local v2290 = enum[v]
	local v2291 = v2290 and v2290[v2288]

	if v2291 then
		Enums[v2291] = v2289
	end
end)
local v2290 = "TextXml"
local v2291 = 1144
pcall(function()
	local v2292 = enum[v]
	local v2293 = v2292 and v2292[v2290]

	if v2293 then
		Enums[v2293] = v2291
	end
end)
v = "HttpError"
local v2292 = "OK"
local v2293 = 1145
pcall(function()
	local v2294 = enum[v]
	local v2295 = v2294 and v2294[v2292]

	if v2295 then
		Enums[v2295] = v2293
	end
end)
local v2294 = "InvalidUrl"
local v2295 = 1146
pcall(function()
	local v2296 = enum[v]
	local v2297 = v2296 and v2296[v2294]

	if v2297 then
		Enums[v2297] = v2295
	end
end)
local v2296 = "DnsResolve"
local v2297 = 1147
pcall(function()
	local v2298 = enum[v]
	local v2299 = v2298 and v2298[v2296]

	if v2299 then
		Enums[v2299] = v2297
	end
end)
local v2298 = "ConnectFail"
local v2299 = 1148
pcall(function()
	local v2300 = enum[v]
	local v2301 = v2300 and v2300[v2298]

	if v2301 then
		Enums[v2301] = v2299
	end
end)
local v2300 = "OutOfMemory"
local v2301 = 1149
pcall(function()
	local v2302 = enum[v]
	local v2303 = v2302 and v2302[v2300]

	if v2303 then
		Enums[v2303] = v2301
	end
end)
local v2302 = "TimedOut"
local v2303 = 1150
pcall(function()
	local v2304 = enum[v]
	local v2305 = v2304 and v2304[v2302]

	if v2305 then
		Enums[v2305] = v2303
	end
end)
local v2304 = "TooManyRedirects"
local v2305 = 1151
pcall(function()
	local v2306 = enum[v]
	local v2307 = v2306 and v2306[v2304]

	if v2307 then
		Enums[v2307] = v2305
	end
end)
local v2306 = "InvalidRedirect"
local v2307 = 1152
pcall(function()
	local v2308 = enum[v]
	local v2309 = v2308 and v2308[v2306]

	if v2309 then
		Enums[v2309] = v2307
	end
end)
local v2308 = "NetFail"
local v2309 = 1153
pcall(function()
	local v2310 = enum[v]
	local v2311 = v2310 and v2310[v2308]

	if v2311 then
		Enums[v2311] = v2309
	end
end)
local v2310 = "Aborted"
local v2311 = 1154
pcall(function()
	local v2312 = enum[v]
	local v2313 = v2312 and v2312[v2310]

	if v2313 then
		Enums[v2313] = v2311
	end
end)
local v2312 = "SslConnectFail"
local v2313 = 1155
pcall(function()
	local v2314 = enum[v]
	local v2315 = v2314 and v2314[v2312]

	if v2315 then
		Enums[v2315] = v2313
	end
end)
local v2314 = "SslVerificationFail"
local v2315 = 1156
pcall(function()
	local v2316 = enum[v]
	local v2317 = v2316 and v2316[v2314]

	if v2317 then
		Enums[v2317] = v2315
	end
end)
local v2316 = "Unknown"
local v2317 = 1157
pcall(function()
	local v2318 = enum[v]
	local v2319 = v2318 and v2318[v2316]

	if v2319 then
		Enums[v2319] = v2317
	end
end)
v = "HttpRequestType"
local v2318 = "Default"
local v2319 = 1158
pcall(function()
	local v2320 = enum[v]
	local v2321 = v2320 and v2320[v2318]

	if v2321 then
		Enums[v2321] = v2319
	end
end)
local v2320 = "MarketplaceService"
local v2321 = 1159
pcall(function()
	local v2322 = enum[v]
	local v2323 = v2322 and v2322[v2320]

	if v2323 then
		Enums[v2323] = v2321
	end
end)
local v2322 = "Players"
local v2323 = 1160
pcall(function()
	local v2324 = enum[v]
	local v2325 = v2324 and v2324[v2322]

	if v2325 then
		Enums[v2325] = v2323
	end
end)
local v2324 = "Chat"
local v2325 = 1161
pcall(function()
	local v2326 = enum[v]
	local v2327 = v2326 and v2326[v2324]

	if v2327 then
		Enums[v2327] = v2325
	end
end)
local v2326 = "Avatar"
local v2327 = 1162
pcall(function()
	local v2328 = enum[v]
	local v2329 = v2328 and v2328[v2326]

	if v2329 then
		Enums[v2329] = v2327
	end
end)
local v2328 = "Analytics"
local v2329 = 1163
pcall(function()
	local v2330 = enum[v]
	local v2331 = v2330 and v2330[v2328]

	if v2331 then
		Enums[v2331] = v2329
	end
end)
local v2330 = "Localization"
local v2331 = 1164
pcall(function()
	local v2332 = enum[v]
	local v2333 = v2332 and v2332[v2330]

	if v2333 then
		Enums[v2333] = v2331
	end
end)
v = "HumanoidCollisionType"
local v2332 = "OuterBox"
local v2333 = 1165
pcall(function()
	local v2334 = enum[v]
	local v2335 = v2334 and v2334[v2332]

	if v2335 then
		Enums[v2335] = v2333
	end
end)
local v2334 = "InnerBox"
local v2335 = 1166
pcall(function()
	local v2336 = enum[v]
	local v2337 = v2336 and v2336[v2334]

	if v2337 then
		Enums[v2337] = v2335
	end
end)
v = "HumanoidDisplayDistanceType"
local v2336 = "Viewer"
local v2337 = 1167
pcall(function()
	local v2338 = enum[v]
	local v2339 = v2338 and v2338[v2336]

	if v2339 then
		Enums[v2339] = v2337
	end
end)
local v2338 = "Subject"
local v2339 = 1168
pcall(function()
	local v2340 = enum[v]
	local v2341 = v2340 and v2340[v2338]

	if v2341 then
		Enums[v2341] = v2339
	end
end)
local v2340 = "None"
local v2341 = 1169
pcall(function()
	local v2342 = enum[v]
	local v2343 = v2342 and v2342[v2340]

	if v2343 then
		Enums[v2343] = v2341
	end
end)
v = "HumanoidHealthDisplayType"
local v2342 = "DisplayWhenDamaged"
local v2343 = 1170
pcall(function()
	local v2344 = enum[v]
	local v2345 = v2344 and v2344[v2342]

	if v2345 then
		Enums[v2345] = v2343
	end
end)
local v2344 = "AlwaysOn"
local v2345 = 1171
pcall(function()
	local v2346 = enum[v]
	local v2347 = v2346 and v2346[v2344]

	if v2347 then
		Enums[v2347] = v2345
	end
end)
local v2346 = "AlwaysOff"
local v2347 = 1172
pcall(function()
	local v2348 = enum[v]
	local v2349 = v2348 and v2348[v2346]

	if v2349 then
		Enums[v2349] = v2347
	end
end)
v = "HumanoidRigType"
local v2348 = "R6"
local v2349 = 1173
pcall(function()
	local v2350 = enum[v]
	local v2351 = v2350 and v2350[v2348]

	if v2351 then
		Enums[v2351] = v2349
	end
end)
local v2350 = "R15"
local v2351 = 1174
pcall(function()
	local v2352 = enum[v]
	local v2353 = v2352 and v2352[v2350]

	if v2353 then
		Enums[v2353] = v2351
	end
end)
v = "HumanoidStateType"
local v2352 = "FallingDown"
local v2353 = 1175
pcall(function()
	local v2354 = enum[v]
	local v2355 = v2354 and v2354[v2352]

	if v2355 then
		Enums[v2355] = v2353
	end
end)
local v2354 = "Ragdoll"
local v2355 = 1176
pcall(function()
	local v2356 = enum[v]
	local v2357 = v2356 and v2356[v2354]

	if v2357 then
		Enums[v2357] = v2355
	end
end)
local v2356 = "GettingUp"
local v2357 = 1177
pcall(function()
	local v2358 = enum[v]
	local v2359 = v2358 and v2358[v2356]

	if v2359 then
		Enums[v2359] = v2357
	end
end)
local v2358 = "Jumping"
local v2359 = 1178
pcall(function()
	local v2360 = enum[v]
	local v2361 = v2360 and v2360[v2358]

	if v2361 then
		Enums[v2361] = v2359
	end
end)
local v2360 = "Swimming"
local v2361 = 1179
pcall(function()
	local v2362 = enum[v]
	local v2363 = v2362 and v2362[v2360]

	if v2363 then
		Enums[v2363] = v2361
	end
end)
local v2362 = "Freefall"
local v2363 = 1180
pcall(function()
	local v2364 = enum[v]
	local v2365 = v2364 and v2364[v2362]

	if v2365 then
		Enums[v2365] = v2363
	end
end)
local v2364 = "Flying"
local v2365 = 1181
pcall(function()
	local v2366 = enum[v]
	local v2367 = v2366 and v2366[v2364]

	if v2367 then
		Enums[v2367] = v2365
	end
end)
local v2366 = "Landed"
local v2367 = 1182
pcall(function()
	local v2368 = enum[v]
	local v2369 = v2368 and v2368[v2366]

	if v2369 then
		Enums[v2369] = v2367
	end
end)
local v2368 = "Running"
local v2369 = 1183
pcall(function()
	local v2370 = enum[v]
	local v2371 = v2370 and v2370[v2368]

	if v2371 then
		Enums[v2371] = v2369
	end
end)
local v2370 = "RunningNoPhysics"
local v2371 = 1184
pcall(function()
	local v2372 = enum[v]
	local v2373 = v2372 and v2372[v2370]

	if v2373 then
		Enums[v2373] = v2371
	end
end)
local v2372 = "StrafingNoPhysics"
local v2373 = 1185
pcall(function()
	local v2374 = enum[v]
	local v2375 = v2374 and v2374[v2372]

	if v2375 then
		Enums[v2375] = v2373
	end
end)
local v2374 = "Climbing"
local v2375 = 1186
pcall(function()
	local v2376 = enum[v]
	local v2377 = v2376 and v2376[v2374]

	if v2377 then
		Enums[v2377] = v2375
	end
end)
local v2376 = "Seated"
local v2377 = 1187
pcall(function()
	local v2378 = enum[v]
	local v2379 = v2378 and v2378[v2376]

	if v2379 then
		Enums[v2379] = v2377
	end
end)
local v2378 = "PlatformStanding"
local v2379 = 1188
pcall(function()
	local v2380 = enum[v]
	local v2381 = v2380 and v2380[v2378]

	if v2381 then
		Enums[v2381] = v2379
	end
end)
local v2380 = "Dead"
local v2381 = 1189
pcall(function()
	local v2382 = enum[v]
	local v2383 = v2382 and v2382[v2380]

	if v2383 then
		Enums[v2383] = v2381
	end
end)
local v2382 = "Physics"
local v2383 = 1190
pcall(function()
	local v2384 = enum[v]
	local v2385 = v2384 and v2384[v2382]

	if v2385 then
		Enums[v2385] = v2383
	end
end)
local v2384 = "None"
local v2385 = 1191
pcall(function()
	local v2386 = enum[v]
	local v2387 = v2386 and v2386[v2384]

	if v2387 then
		Enums[v2387] = v2385
	end
end)
v = "IKCollisionsMode"
local v2386 = "NoCollisions"
local v2387 = 1192
pcall(function()
	local v2388 = enum[v]
	local v2389 = v2388 and v2388[v2386]

	if v2389 then
		Enums[v2389] = v2387
	end
end)
local v2388 = "OtherMechanismsAnchored"
local v2389 = 1193
pcall(function()
	local v2390 = enum[v]
	local v2391 = v2390 and v2390[v2388]

	if v2391 then
		Enums[v2391] = v2389
	end
end)
local v2390 = "IncludeContactedMechanisms"
local v2391 = 1194
pcall(function()
	local v2392 = enum[v]
	local v2393 = v2392 and v2392[v2390]

	if v2393 then
		Enums[v2393] = v2391
	end
end)
v = "IKControlConstraintSupport"
local v2392 = "Default"
local v2393 = 1195
pcall(function()
	local v2394 = enum[v]
	local v2395 = v2394 and v2394[v2392]

	if v2395 then
		Enums[v2395] = v2393
	end
end)
local v2394 = "Disabled"
local v2395 = 1196
pcall(function()
	local v2396 = enum[v]
	local v2397 = v2396 and v2396[v2394]

	if v2397 then
		Enums[v2397] = v2395
	end
end)
local v2396 = "Enabled"
local v2397 = 1197
pcall(function()
	local v2398 = enum[v]
	local v2399 = v2398 and v2398[v2396]

	if v2399 then
		Enums[v2399] = v2397
	end
end)
v = "IKControlType"
local v2398 = "Transform"
local v2399 = 1198
pcall(function()
	local v2400 = enum[v]
	local v2401 = v2400 and v2400[v2398]

	if v2401 then
		Enums[v2401] = v2399
	end
end)
local v2400 = "Position"
local v2401 = 1199
pcall(function()
	local v2402 = enum[v]
	local v2403 = v2402 and v2402[v2400]

	if v2403 then
		Enums[v2403] = v2401
	end
end)
local v2402 = "Rotation"
local v2403 = 1200
pcall(function()
	local v2404 = enum[v]
	local v2405 = v2404 and v2404[v2402]

	if v2405 then
		Enums[v2405] = v2403
	end
end)
local v2404 = "LookAt"
local v2405 = 1201
pcall(function()
	local v2406 = enum[v]
	local v2407 = v2406 and v2406[v2404]

	if v2407 then
		Enums[v2407] = v2405
	end
end)
v = "IXPLoadingStatus"
local v2406 = "None"
local v2407 = 1202
pcall(function()
	local v2408 = enum[v]
	local v2409 = v2408 and v2408[v2406]

	if v2409 then
		Enums[v2409] = v2407
	end
end)
local v2408 = "Pending"
local v2409 = 1203
pcall(function()
	local v2410 = enum[v]
	local v2411 = v2410 and v2410[v2408]

	if v2411 then
		Enums[v2411] = v2409
	end
end)
local v2410 = "Initialized"
local v2411 = 1204
pcall(function()
	local v2412 = enum[v]
	local v2413 = v2412 and v2412[v2410]

	if v2413 then
		Enums[v2413] = v2411
	end
end)
local v2412 = "ErrorInvalidUser"
local v2413 = 1205
pcall(function()
	local v2414 = enum[v]
	local v2415 = v2414 and v2414[v2412]

	if v2415 then
		Enums[v2415] = v2413
	end
end)
local v2414 = "ErrorConnection"
local v2415 = 1206
pcall(function()
	local v2416 = enum[v]
	local v2417 = v2416 and v2416[v2414]

	if v2417 then
		Enums[v2417] = v2415
	end
end)
local v2416 = "ErrorJsonParse"
local v2417 = 1207
pcall(function()
	local v2418 = enum[v]
	local v2419 = v2418 and v2418[v2416]

	if v2419 then
		Enums[v2419] = v2417
	end
end)
local v2418 = "ErrorTimedOut"
local v2419 = 1208
pcall(function()
	local v2420 = enum[v]
	local v2421 = v2420 and v2420[v2418]

	if v2421 then
		Enums[v2421] = v2419
	end
end)
v = "ImageAlphaType"
local v2420 = "Default"
local v2421 = 1209
pcall(function()
	local v2422 = enum[v]
	local v2423 = v2422 and v2422[v2420]

	if v2423 then
		Enums[v2423] = v2421
	end
end)
local v2422 = "LockCanvasAlpha"
local v2423 = 1210
pcall(function()
	local v2424 = enum[v]
	local v2425 = v2424 and v2424[v2422]

	if v2425 then
		Enums[v2425] = v2423
	end
end)
local v2424 = "LockCanvasColor"
local v2425 = 1211
pcall(function()
	local v2426 = enum[v]
	local v2427 = v2426 and v2426[v2424]

	if v2427 then
		Enums[v2427] = v2425
	end
end)
v = "ImageCombineType"
local v2426 = "BlendSourceOver"
local v2427 = 1212
pcall(function()
	local v2428 = enum[v]
	local v2429 = v2428 and v2428[v2426]

	if v2429 then
		Enums[v2429] = v2427
	end
end)
local v2428 = "Overwrite"
local v2429 = 1213
pcall(function()
	local v2430 = enum[v]
	local v2431 = v2430 and v2430[v2428]

	if v2431 then
		Enums[v2431] = v2429
	end
end)
local v2430 = "Add"
local v2431 = 1214
pcall(function()
	local v2432 = enum[v]
	local v2433 = v2432 and v2432[v2430]

	if v2433 then
		Enums[v2433] = v2431
	end
end)
local v2432 = "Multiply"
local v2433 = 1215
pcall(function()
	local v2434 = enum[v]
	local v2435 = v2434 and v2434[v2432]

	if v2435 then
		Enums[v2435] = v2433
	end
end)
local v2434 = "AlphaBlend"
local v2435 = 1216
pcall(function()
	local v2436 = enum[v]
	local v2437 = v2436 and v2436[v2434]

	if v2437 then
		Enums[v2437] = v2435
	end
end)
v = "InOut"
local v2436 = "Edge"
local v2437 = 1217
pcall(function()
	local v2438 = enum[v]
	local v2439 = v2438 and v2438[v2436]

	if v2439 then
		Enums[v2439] = v2437
	end
end)
local v2438 = "Inset"
local v2439 = 1218
pcall(function()
	local v2440 = enum[v]
	local v2441 = v2440 and v2440[v2438]

	if v2441 then
		Enums[v2441] = v2439
	end
end)
local v2440 = "Center"
local v2441 = 1219
pcall(function()
	local v2442 = enum[v]
	local v2443 = v2442 and v2442[v2440]

	if v2443 then
		Enums[v2443] = v2441
	end
end)
v = "InfoType"
local v2442 = "Asset"
local v2443 = 1220
pcall(function()
	local v2444 = enum[v]
	local v2445 = v2444 and v2444[v2442]

	if v2445 then
		Enums[v2445] = v2443
	end
end)
local v2444 = "Product"
local v2445 = 1221
pcall(function()
	local v2446 = enum[v]
	local v2447 = v2446 and v2446[v2444]

	if v2447 then
		Enums[v2447] = v2445
	end
end)
local v2446 = "GamePass"
local v2447 = 1222
pcall(function()
	local v2448 = enum[v]
	local v2449 = v2448 and v2448[v2446]

	if v2449 then
		Enums[v2449] = v2447
	end
end)
local v2448 = "Subscription"
local v2449 = 1223
pcall(function()
	local v2450 = enum[v]
	local v2451 = v2450 and v2450[v2448]

	if v2451 then
		Enums[v2451] = v2449
	end
end)
local v2450 = "Bundle"
local v2451 = 1224
pcall(function()
	local v2452 = enum[v]
	local v2453 = v2452 and v2452[v2450]

	if v2453 then
		Enums[v2453] = v2451
	end
end)
v = "InitialDockState"
local v2452 = "Top"
local v2453 = 1225
pcall(function()
	local v2454 = enum[v]
	local v2455 = v2454 and v2454[v2452]

	if v2455 then
		Enums[v2455] = v2453
	end
end)
local v2454 = "Bottom"
local v2455 = 1226
pcall(function()
	local v2456 = enum[v]
	local v2457 = v2456 and v2456[v2454]

	if v2457 then
		Enums[v2457] = v2455
	end
end)
local v2456 = "Left"
local v2457 = 1227
pcall(function()
	local v2458 = enum[v]
	local v2459 = v2458 and v2458[v2456]

	if v2459 then
		Enums[v2459] = v2457
	end
end)
local v2458 = "Right"
local v2459 = 1228
pcall(function()
	local v2460 = enum[v]
	local v2461 = v2460 and v2460[v2458]

	if v2461 then
		Enums[v2461] = v2459
	end
end)
local v2460 = "Float"
local v2461 = 1229
pcall(function()
	local v2462 = enum[v]
	local v2463 = v2462 and v2462[v2460]

	if v2463 then
		Enums[v2463] = v2461
	end
end)
v = "InputActionType"
local v2462 = "Bool"
local v2463 = 1230
pcall(function()
	local v2464 = enum[v]
	local v2465 = v2464 and v2464[v2462]

	if v2465 then
		Enums[v2465] = v2463
	end
end)
local v2464 = "Float"
local v2465 = 1231
pcall(function()
	local v2466 = enum[v]
	local v2467 = v2466 and v2466[v2464]

	if v2467 then
		Enums[v2467] = v2465
	end
end)
local v2466 = "Direction2D"
local v2467 = 1232
pcall(function()
	local v2468 = enum[v]
	local v2469 = v2468 and v2468[v2466]

	if v2469 then
		Enums[v2469] = v2467
	end
end)
v = "InputType"
local v2468 = "NoInput"
local v2469 = 1233
pcall(function()
	local v2470 = enum[v]
	local v2471 = v2470 and v2470[v2468]

	if v2471 then
		Enums[v2471] = v2469
	end
end)
local v2470 = "Constant"
local v2471 = 1234
pcall(function()
	local v2472 = enum[v]
	local v2473 = v2472 and v2472[v2470]

	if v2473 then
		Enums[v2473] = v2471
	end
end)
local v2472 = "Sin"
local v2473 = 1235
pcall(function()
	local v2474 = enum[v]
	local v2475 = v2474 and v2474[v2472]

	if v2475 then
		Enums[v2475] = v2473
	end
end)
v = "IntermediateMeshGenerationResult"
local v2474 = "HighQualityMesh"
local v2475 = 1236
pcall(function()
	local v2476 = enum[v]
	local v2477 = v2476 and v2476[v2474]

	if v2477 then
		Enums[v2477] = v2475
	end
end)
v = "InterpolationThrottlingMode"
local v2476 = "Default"
local v2477 = 1237
pcall(function()
	local v2478 = enum[v]
	local v2479 = v2478 and v2478[v2476]

	if v2479 then
		Enums[v2479] = v2477
	end
end)
local v2478 = "Disabled"
local v2479 = 1238
pcall(function()
	local v2480 = enum[v]
	local v2481 = v2480 and v2480[v2478]

	if v2481 then
		Enums[v2481] = v2479
	end
end)
local v2480 = "Enabled"
local v2481 = 1239
pcall(function()
	local v2482 = enum[v]
	local v2483 = v2482 and v2482[v2480]

	if v2483 then
		Enums[v2483] = v2481
	end
end)
v = "InviteState"
local v2482 = "Placed"
local v2483 = 1240
pcall(function()
	local v2484 = enum[v]
	local v2485 = v2484 and v2484[v2482]

	if v2485 then
		Enums[v2485] = v2483
	end
end)
local v2484 = "Accepted"
local v2485 = 1241
pcall(function()
	local v2486 = enum[v]
	local v2487 = v2486 and v2486[v2484]

	if v2487 then
		Enums[v2487] = v2485
	end
end)
local v2486 = "Declined"
local v2487 = 1242
pcall(function()
	local v2488 = enum[v]
	local v2489 = v2488 and v2488[v2486]

	if v2489 then
		Enums[v2489] = v2487
	end
end)
local v2488 = "Missed"
local v2489 = 1243
pcall(function()
	local v2490 = enum[v]
	local v2491 = v2490 and v2490[v2488]

	if v2491 then
		Enums[v2491] = v2489
	end
end)
v = "ItemLineAlignment"
local v2490 = "Automatic"
local v2491 = 1244
pcall(function()
	local v2492 = enum[v]
	local v2493 = v2492 and v2492[v2490]

	if v2493 then
		Enums[v2493] = v2491
	end
end)
local v2492 = "Start"
local v2493 = 1245
pcall(function()
	local v2494 = enum[v]
	local v2495 = v2494 and v2494[v2492]

	if v2495 then
		Enums[v2495] = v2493
	end
end)
local v2494 = "Center"
local v2495 = 1246
pcall(function()
	local v2496 = enum[v]
	local v2497 = v2496 and v2496[v2494]

	if v2497 then
		Enums[v2497] = v2495
	end
end)
local v2496 = "End"
local v2497 = 1247
pcall(function()
	local v2498 = enum[v]
	local v2499 = v2498 and v2498[v2496]

	if v2499 then
		Enums[v2499] = v2497
	end
end)
local v2498 = "Stretch"
local v2499 = 1248
pcall(function()
	local v2500 = enum[v]
	local v2501 = v2500 and v2500[v2498]

	if v2501 then
		Enums[v2501] = v2499
	end
end)
v = "JoinSource"
local v2500 = "CreatedItemAttribution"
local v2501 = 1249
pcall(function()
	local v2502 = enum[v]
	local v2503 = v2502 and v2502[v2500]

	if v2503 then
		Enums[v2503] = v2501
	end
end)
v = "JointCreationMode"
local v2502 = "All"
local v2503 = 1250
pcall(function()
	local v2504 = enum[v]
	local v2505 = v2504 and v2504[v2502]

	if v2505 then
		Enums[v2505] = v2503
	end
end)
local v2504 = "Surface"
local v2505 = 1251
pcall(function()
	local v2506 = enum[v]
	local v2507 = v2506 and v2506[v2504]

	if v2507 then
		Enums[v2507] = v2505
	end
end)
local v2506 = "None"
local v2507 = 1252
pcall(function()
	local v2508 = enum[v]
	local v2509 = v2508 and v2508[v2506]

	if v2509 then
		Enums[v2509] = v2507
	end
end)
v = "KeyCode"
local v2508 = "Unknown"
local v2509 = 1253
pcall(function()
	local v2510 = enum[v]
	local v2511 = v2510 and v2510[v2508]

	if v2511 then
		Enums[v2511] = v2509
	end
end)
local v2510 = "Backspace"
local v2511 = 1254
pcall(function()
	local v2512 = enum[v]
	local v2513 = v2512 and v2512[v2510]

	if v2513 then
		Enums[v2513] = v2511
	end
end)
local v2512 = "Tab"
local v2513 = 1255
pcall(function()
	local v2514 = enum[v]
	local v2515 = v2514 and v2514[v2512]

	if v2515 then
		Enums[v2515] = v2513
	end
end)
local v2514 = "Clear"
local v2515 = 1256
pcall(function()
	local v2516 = enum[v]
	local v2517 = v2516 and v2516[v2514]

	if v2517 then
		Enums[v2517] = v2515
	end
end)
local v2516 = "Return"
local v2517 = 1257
pcall(function()
	local v2518 = enum[v]
	local v2519 = v2518 and v2518[v2516]

	if v2519 then
		Enums[v2519] = v2517
	end
end)
local v2518 = "Pause"
local v2519 = 1258
pcall(function()
	local v2520 = enum[v]
	local v2521 = v2520 and v2520[v2518]

	if v2521 then
		Enums[v2521] = v2519
	end
end)
local v2520 = "Escape"
local v2521 = 1259
pcall(function()
	local v2522 = enum[v]
	local v2523 = v2522 and v2522[v2520]

	if v2523 then
		Enums[v2523] = v2521
	end
end)
local v2522 = "Space"
local v2523 = 1260
pcall(function()
	local v2524 = enum[v]
	local v2525 = v2524 and v2524[v2522]

	if v2525 then
		Enums[v2525] = v2523
	end
end)
local v2524 = "QuotedDouble"
local v2525 = 1261
pcall(function()
	local v2526 = enum[v]
	local v2527 = v2526 and v2526[v2524]

	if v2527 then
		Enums[v2527] = v2525
	end
end)
local v2526 = "Hash"
local v2527 = 1262
pcall(function()
	local v2528 = enum[v]
	local v2529 = v2528 and v2528[v2526]

	if v2529 then
		Enums[v2529] = v2527
	end
end)
local v2528 = "Dollar"
local v2529 = 1263
pcall(function()
	local v2530 = enum[v]
	local v2531 = v2530 and v2530[v2528]

	if v2531 then
		Enums[v2531] = v2529
	end
end)
local v2530 = "Percent"
local v2531 = 1264
pcall(function()
	local v2532 = enum[v]
	local v2533 = v2532 and v2532[v2530]

	if v2533 then
		Enums[v2533] = v2531
	end
end)
local v2532 = "Ampersand"
local v2533 = 1265
pcall(function()
	local v2534 = enum[v]
	local v2535 = v2534 and v2534[v2532]

	if v2535 then
		Enums[v2535] = v2533
	end
end)
local v2534 = "Quote"
local v2535 = 1266
pcall(function()
	local v2536 = enum[v]
	local v2537 = v2536 and v2536[v2534]

	if v2537 then
		Enums[v2537] = v2535
	end
end)
local v2536 = "LeftParenthesis"
local v2537 = 1267
pcall(function()
	local v2538 = enum[v]
	local v2539 = v2538 and v2538[v2536]

	if v2539 then
		Enums[v2539] = v2537
	end
end)
local v2538 = "RightParenthesis"
local v2539 = 1268
pcall(function()
	local v2540 = enum[v]
	local v2541 = v2540 and v2540[v2538]

	if v2541 then
		Enums[v2541] = v2539
	end
end)
local v2540 = "Asterisk"
local v2541 = 1269
pcall(function()
	local v2542 = enum[v]
	local v2543 = v2542 and v2542[v2540]

	if v2543 then
		Enums[v2543] = v2541
	end
end)
local v2542 = "Plus"
local v2543 = 1270
pcall(function()
	local v2544 = enum[v]
	local v2545 = v2544 and v2544[v2542]

	if v2545 then
		Enums[v2545] = v2543
	end
end)
local v2544 = "Comma"
local v2545 = 1271
pcall(function()
	local v2546 = enum[v]
	local v2547 = v2546 and v2546[v2544]

	if v2547 then
		Enums[v2547] = v2545
	end
end)
local v2546 = "Minus"
local v2547 = 1272
pcall(function()
	local v2548 = enum[v]
	local v2549 = v2548 and v2548[v2546]

	if v2549 then
		Enums[v2549] = v2547
	end
end)
local v2548 = "Period"
local v2549 = 1273
pcall(function()
	local v2550 = enum[v]
	local v2551 = v2550 and v2550[v2548]

	if v2551 then
		Enums[v2551] = v2549
	end
end)
local v2550 = "Slash"
local v2551 = 1274
pcall(function()
	local v2552 = enum[v]
	local v2553 = v2552 and v2552[v2550]

	if v2553 then
		Enums[v2553] = v2551
	end
end)
local v2552 = "Zero"
local v2553 = 1275
pcall(function()
	local v2554 = enum[v]
	local v2555 = v2554 and v2554[v2552]

	if v2555 then
		Enums[v2555] = v2553
	end
end)
local v2554 = "One"
local v2555 = 1276
pcall(function()
	local v2556 = enum[v]
	local v2557 = v2556 and v2556[v2554]

	if v2557 then
		Enums[v2557] = v2555
	end
end)
local v2556 = "Two"
local v2557 = 1277
pcall(function()
	local v2558 = enum[v]
	local v2559 = v2558 and v2558[v2556]

	if v2559 then
		Enums[v2559] = v2557
	end
end)
local v2558 = "Three"
local v2559 = 1278
pcall(function()
	local v2560 = enum[v]
	local v2561 = v2560 and v2560[v2558]

	if v2561 then
		Enums[v2561] = v2559
	end
end)
local v2560 = "Four"
local v2561 = 1279
pcall(function()
	local v2562 = enum[v]
	local v2563 = v2562 and v2562[v2560]

	if v2563 then
		Enums[v2563] = v2561
	end
end)
local v2562 = "Five"
local v2563 = 1280
pcall(function()
	local v2564 = enum[v]
	local v2565 = v2564 and v2564[v2562]

	if v2565 then
		Enums[v2565] = v2563
	end
end)
local v2564 = "Six"
local v2565 = 1281
pcall(function()
	local v2566 = enum[v]
	local v2567 = v2566 and v2566[v2564]

	if v2567 then
		Enums[v2567] = v2565
	end
end)
local v2566 = "Seven"
local v2567 = 1282
pcall(function()
	local v2568 = enum[v]
	local v2569 = v2568 and v2568[v2566]

	if v2569 then
		Enums[v2569] = v2567
	end
end)
local v2568 = "Eight"
local v2569 = 1283
pcall(function()
	local v2570 = enum[v]
	local v2571 = v2570 and v2570[v2568]

	if v2571 then
		Enums[v2571] = v2569
	end
end)
local v2570 = "Nine"
local v2571 = 1284
pcall(function()
	local v2572 = enum[v]
	local v2573 = v2572 and v2572[v2570]

	if v2573 then
		Enums[v2573] = v2571
	end
end)
local v2572 = "Colon"
local v2573 = 1285
pcall(function()
	local v2574 = enum[v]
	local v2575 = v2574 and v2574[v2572]

	if v2575 then
		Enums[v2575] = v2573
	end
end)
local v2574 = "Semicolon"
local v2575 = 1286
pcall(function()
	local v2576 = enum[v]
	local v2577 = v2576 and v2576[v2574]

	if v2577 then
		Enums[v2577] = v2575
	end
end)
local v2576 = "LessThan"
local v2577 = 1287
pcall(function()
	local v2578 = enum[v]
	local v2579 = v2578 and v2578[v2576]

	if v2579 then
		Enums[v2579] = v2577
	end
end)
local v2578 = "Equals"
local v2579 = 1288
pcall(function()
	local v2580 = enum[v]
	local v2581 = v2580 and v2580[v2578]

	if v2581 then
		Enums[v2581] = v2579
	end
end)
local v2580 = "GreaterThan"
local v2581 = 1289
pcall(function()
	local v2582 = enum[v]
	local v2583 = v2582 and v2582[v2580]

	if v2583 then
		Enums[v2583] = v2581
	end
end)
local v2582 = "Question"
local v2583 = 1290
pcall(function()
	local v2584 = enum[v]
	local v2585 = v2584 and v2584[v2582]

	if v2585 then
		Enums[v2585] = v2583
	end
end)
local v2584 = "At"
local v2585 = 1291
pcall(function()
	local v2586 = enum[v]
	local v2587 = v2586 and v2586[v2584]

	if v2587 then
		Enums[v2587] = v2585
	end
end)
local v2586 = "LeftBracket"
local v2587 = 1292
pcall(function()
	local v2588 = enum[v]
	local v2589 = v2588 and v2588[v2586]

	if v2589 then
		Enums[v2589] = v2587
	end
end)
local v2588 = "BackSlash"
local v2589 = 1293
pcall(function()
	local v2590 = enum[v]
	local v2591 = v2590 and v2590[v2588]

	if v2591 then
		Enums[v2591] = v2589
	end
end)
local v2590 = "RightBracket"
local v2591 = 1294
pcall(function()
	local v2592 = enum[v]
	local v2593 = v2592 and v2592[v2590]

	if v2593 then
		Enums[v2593] = v2591
	end
end)
local v2592 = "Caret"
local v2593 = 1295
pcall(function()
	local v2594 = enum[v]
	local v2595 = v2594 and v2594[v2592]

	if v2595 then
		Enums[v2595] = v2593
	end
end)
local v2594 = "Underscore"
local v2595 = 1296
pcall(function()
	local v2596 = enum[v]
	local v2597 = v2596 and v2596[v2594]

	if v2597 then
		Enums[v2597] = v2595
	end
end)
local v2596 = "Backquote"
local v2597 = 1297
pcall(function()
	local v2598 = enum[v]
	local v2599 = v2598 and v2598[v2596]

	if v2599 then
		Enums[v2599] = v2597
	end
end)
local v2598 = "A"
local v2599 = 1298
pcall(function()
	local v2600 = enum[v]
	local v2601 = v2600 and v2600[v2598]

	if v2601 then
		Enums[v2601] = v2599
	end
end)
local v2600 = "B"
local v2601 = 1299
pcall(function()
	local v2602 = enum[v]
	local v2603 = v2602 and v2602[v2600]

	if v2603 then
		Enums[v2603] = v2601
	end
end)
local v2602 = "C"
local v2603 = 1300
pcall(function()
	local v2604 = enum[v]
	local v2605 = v2604 and v2604[v2602]

	if v2605 then
		Enums[v2605] = v2603
	end
end)
local v2604 = "D"
local v2605 = 1301
pcall(function()
	local v2606 = enum[v]
	local v2607 = v2606 and v2606[v2604]

	if v2607 then
		Enums[v2607] = v2605
	end
end)
local v2606 = "E"
local v2607 = 1302
pcall(function()
	local v2608 = enum[v]
	local v2609 = v2608 and v2608[v2606]

	if v2609 then
		Enums[v2609] = v2607
	end
end)
local v2608 = "F"
local v2609 = 1303
pcall(function()
	local v2610 = enum[v]
	local v2611 = v2610 and v2610[v2608]

	if v2611 then
		Enums[v2611] = v2609
	end
end)
local v2610 = "G"
local v2611 = 1304
pcall(function()
	local v2612 = enum[v]
	local v2613 = v2612 and v2612[v2610]

	if v2613 then
		Enums[v2613] = v2611
	end
end)
local v2612 = "H"
local v2613 = 1305
pcall(function()
	local v2614 = enum[v]
	local v2615 = v2614 and v2614[v2612]

	if v2615 then
		Enums[v2615] = v2613
	end
end)
local v2614 = "I"
local v2615 = 1306
pcall(function()
	local v2616 = enum[v]
	local v2617 = v2616 and v2616[v2614]

	if v2617 then
		Enums[v2617] = v2615
	end
end)
local v2616 = "J"
local v2617 = 1307
pcall(function()
	local v2618 = enum[v]
	local v2619 = v2618 and v2618[v2616]

	if v2619 then
		Enums[v2619] = v2617
	end
end)
local v2618 = "K"
local v2619 = 1308
pcall(function()
	local v2620 = enum[v]
	local v2621 = v2620 and v2620[v2618]

	if v2621 then
		Enums[v2621] = v2619
	end
end)
local v2620 = "L"
local v2621 = 1309
pcall(function()
	local v2622 = enum[v]
	local v2623 = v2622 and v2622[v2620]

	if v2623 then
		Enums[v2623] = v2621
	end
end)
local v2622 = "M"
local v2623 = 1310
pcall(function()
	local v2624 = enum[v]
	local v2625 = v2624 and v2624[v2622]

	if v2625 then
		Enums[v2625] = v2623
	end
end)
local v2624 = "N"
local v2625 = 1311
pcall(function()
	local v2626 = enum[v]
	local v2627 = v2626 and v2626[v2624]

	if v2627 then
		Enums[v2627] = v2625
	end
end)
local v2626 = "O"
local v2627 = 1312
pcall(function()
	local v2628 = enum[v]
	local v2629 = v2628 and v2628[v2626]

	if v2629 then
		Enums[v2629] = v2627
	end
end)
local v2628 = "P"
local v2629 = 1313
pcall(function()
	local v2630 = enum[v]
	local v2631 = v2630 and v2630[v2628]

	if v2631 then
		Enums[v2631] = v2629
	end
end)
local v2630 = "Q"
local v2631 = 1314
pcall(function()
	local v2632 = enum[v]
	local v2633 = v2632 and v2632[v2630]

	if v2633 then
		Enums[v2633] = v2631
	end
end)
local v2632 = "R"
local v2633 = 1315
pcall(function()
	local v2634 = enum[v]
	local v2635 = v2634 and v2634[v2632]

	if v2635 then
		Enums[v2635] = v2633
	end
end)
local v2634 = "S"
local v2635 = 1316
pcall(function()
	local v2636 = enum[v]
	local v2637 = v2636 and v2636[v2634]

	if v2637 then
		Enums[v2637] = v2635
	end
end)
local v2636 = "T"
local v2637 = 1317
pcall(function()
	local v2638 = enum[v]
	local v2639 = v2638 and v2638[v2636]

	if v2639 then
		Enums[v2639] = v2637
	end
end)
local v2638 = "U"
local v2639 = 1318
pcall(function()
	local v2640 = enum[v]
	local v2641 = v2640 and v2640[v2638]

	if v2641 then
		Enums[v2641] = v2639
	end
end)
local v2640 = "V"
local v2641 = 1319
pcall(function()
	local v2642 = enum[v]
	local v2643 = v2642 and v2642[v2640]

	if v2643 then
		Enums[v2643] = v2641
	end
end)
local v2642 = "W"
local v2643 = 1320
pcall(function()
	local v2644 = enum[v]
	local v2645 = v2644 and v2644[v2642]

	if v2645 then
		Enums[v2645] = v2643
	end
end)
local v2644 = "X"
local v2645 = 1321
pcall(function()
	local v2646 = enum[v]
	local v2647 = v2646 and v2646[v2644]

	if v2647 then
		Enums[v2647] = v2645
	end
end)
local v2646 = "Y"
local v2647 = 1322
pcall(function()
	local v2648 = enum[v]
	local v2649 = v2648 and v2648[v2646]

	if v2649 then
		Enums[v2649] = v2647
	end
end)
local v2648 = "Z"
local v2649 = 1323
pcall(function()
	local v2650 = enum[v]
	local v2651 = v2650 and v2650[v2648]

	if v2651 then
		Enums[v2651] = v2649
	end
end)
local v2650 = "LeftCurly"
local v2651 = 1324
pcall(function()
	local v2652 = enum[v]
	local v2653 = v2652 and v2652[v2650]

	if v2653 then
		Enums[v2653] = v2651
	end
end)
local v2652 = "Pipe"
local v2653 = 1325
pcall(function()
	local v2654 = enum[v]
	local v2655 = v2654 and v2654[v2652]

	if v2655 then
		Enums[v2655] = v2653
	end
end)
local v2654 = "RightCurly"
local v2655 = 1326
pcall(function()
	local v2656 = enum[v]
	local v2657 = v2656 and v2656[v2654]

	if v2657 then
		Enums[v2657] = v2655
	end
end)
local v2656 = "Tilde"
local v2657 = 1327
pcall(function()
	local v2658 = enum[v]
	local v2659 = v2658 and v2658[v2656]

	if v2659 then
		Enums[v2659] = v2657
	end
end)
local v2658 = "Delete"
local v2659 = 1328
pcall(function()
	local v2660 = enum[v]
	local v2661 = v2660 and v2660[v2658]

	if v2661 then
		Enums[v2661] = v2659
	end
end)
local v2660 = "KeypadZero"
local v2661 = 1329
pcall(function()
	local v2662 = enum[v]
	local v2663 = v2662 and v2662[v2660]

	if v2663 then
		Enums[v2663] = v2661
	end
end)
local v2662 = "KeypadOne"
local v2663 = 1330
pcall(function()
	local v2664 = enum[v]
	local v2665 = v2664 and v2664[v2662]

	if v2665 then
		Enums[v2665] = v2663
	end
end)
local v2664 = "KeypadTwo"
local v2665 = 1331
pcall(function()
	local v2666 = enum[v]
	local v2667 = v2666 and v2666[v2664]

	if v2667 then
		Enums[v2667] = v2665
	end
end)
local v2666 = "KeypadThree"
local v2667 = 1332
pcall(function()
	local v2668 = enum[v]
	local v2669 = v2668 and v2668[v2666]

	if v2669 then
		Enums[v2669] = v2667
	end
end)
local v2668 = "KeypadFour"
local v2669 = 1333
pcall(function()
	local v2670 = enum[v]
	local v2671 = v2670 and v2670[v2668]

	if v2671 then
		Enums[v2671] = v2669
	end
end)
local v2670 = "KeypadFive"
local v2671 = 1334
pcall(function()
	local v2672 = enum[v]
	local v2673 = v2672 and v2672[v2670]

	if v2673 then
		Enums[v2673] = v2671
	end
end)
local v2672 = "KeypadSix"
local v2673 = 1335
pcall(function()
	local v2674 = enum[v]
	local v2675 = v2674 and v2674[v2672]

	if v2675 then
		Enums[v2675] = v2673
	end
end)
local v2674 = "KeypadSeven"
local v2675 = 1336
pcall(function()
	local v2676 = enum[v]
	local v2677 = v2676 and v2676[v2674]

	if v2677 then
		Enums[v2677] = v2675
	end
end)
local v2676 = "KeypadEight"
local v2677 = 1337
pcall(function()
	local v2678 = enum[v]
	local v2679 = v2678 and v2678[v2676]

	if v2679 then
		Enums[v2679] = v2677
	end
end)
local v2678 = "KeypadNine"
local v2679 = 1338
pcall(function()
	local v2680 = enum[v]
	local v2681 = v2680 and v2680[v2678]

	if v2681 then
		Enums[v2681] = v2679
	end
end)
local v2680 = "KeypadPeriod"
local v2681 = 1339
pcall(function()
	local v2682 = enum[v]
	local v2683 = v2682 and v2682[v2680]

	if v2683 then
		Enums[v2683] = v2681
	end
end)
local v2682 = "KeypadDivide"
local v2683 = 1340
pcall(function()
	local v2684 = enum[v]
	local v2685 = v2684 and v2684[v2682]

	if v2685 then
		Enums[v2685] = v2683
	end
end)
local v2684 = "KeypadMultiply"
local v2685 = 1341
pcall(function()
	local v2686 = enum[v]
	local v2687 = v2686 and v2686[v2684]

	if v2687 then
		Enums[v2687] = v2685
	end
end)
local v2686 = "KeypadMinus"
local v2687 = 1342
pcall(function()
	local v2688 = enum[v]
	local v2689 = v2688 and v2688[v2686]

	if v2689 then
		Enums[v2689] = v2687
	end
end)
local v2688 = "KeypadPlus"
local v2689 = 1343
pcall(function()
	local v2690 = enum[v]
	local v2691 = v2690 and v2690[v2688]

	if v2691 then
		Enums[v2691] = v2689
	end
end)
local v2690 = "KeypadEnter"
local v2691 = 1344
pcall(function()
	local v2692 = enum[v]
	local v2693 = v2692 and v2692[v2690]

	if v2693 then
		Enums[v2693] = v2691
	end
end)
local v2692 = "KeypadEquals"
local v2693 = 1345
pcall(function()
	local v2694 = enum[v]
	local v2695 = v2694 and v2694[v2692]

	if v2695 then
		Enums[v2695] = v2693
	end
end)
local v2694 = "Up"
local v2695 = 1346
pcall(function()
	local v2696 = enum[v]
	local v2697 = v2696 and v2696[v2694]

	if v2697 then
		Enums[v2697] = v2695
	end
end)
local v2696 = "Down"
local v2697 = 1347
pcall(function()
	local v2698 = enum[v]
	local v2699 = v2698 and v2698[v2696]

	if v2699 then
		Enums[v2699] = v2697
	end
end)
local v2698 = "Right"
local v2699 = 1348
pcall(function()
	local v2700 = enum[v]
	local v2701 = v2700 and v2700[v2698]

	if v2701 then
		Enums[v2701] = v2699
	end
end)
local v2700 = "Left"
local v2701 = 1349
pcall(function()
	local v2702 = enum[v]
	local v2703 = v2702 and v2702[v2700]

	if v2703 then
		Enums[v2703] = v2701
	end
end)
local v2702 = "Insert"
local v2703 = 1350
pcall(function()
	local v2704 = enum[v]
	local v2705 = v2704 and v2704[v2702]

	if v2705 then
		Enums[v2705] = v2703
	end
end)
local v2704 = "Home"
local v2705 = 1351
pcall(function()
	local v2706 = enum[v]
	local v2707 = v2706 and v2706[v2704]

	if v2707 then
		Enums[v2707] = v2705
	end
end)
local v2706 = "End"
local v2707 = 1352
pcall(function()
	local v2708 = enum[v]
	local v2709 = v2708 and v2708[v2706]

	if v2709 then
		Enums[v2709] = v2707
	end
end)
local v2708 = "PageUp"
local v2709 = 1353
pcall(function()
	local v2710 = enum[v]
	local v2711 = v2710 and v2710[v2708]

	if v2711 then
		Enums[v2711] = v2709
	end
end)
local v2710 = "PageDown"
local v2711 = 1354
pcall(function()
	local v2712 = enum[v]
	local v2713 = v2712 and v2712[v2710]

	if v2713 then
		Enums[v2713] = v2711
	end
end)
local v2712 = "F1"
local v2713 = 1355
pcall(function()
	local v2714 = enum[v]
	local v2715 = v2714 and v2714[v2712]

	if v2715 then
		Enums[v2715] = v2713
	end
end)
local v2714 = "F2"
local v2715 = 1356
pcall(function()
	local v2716 = enum[v]
	local v2717 = v2716 and v2716[v2714]

	if v2717 then
		Enums[v2717] = v2715
	end
end)
local v2716 = "F3"
local v2717 = 1357
pcall(function()
	local v2718 = enum[v]
	local v2719 = v2718 and v2718[v2716]

	if v2719 then
		Enums[v2719] = v2717
	end
end)
local v2718 = "F4"
local v2719 = 1358
pcall(function()
	local v2720 = enum[v]
	local v2721 = v2720 and v2720[v2718]

	if v2721 then
		Enums[v2721] = v2719
	end
end)
local v2720 = "F5"
local v2721 = 1359
pcall(function()
	local v2722 = enum[v]
	local v2723 = v2722 and v2722[v2720]

	if v2723 then
		Enums[v2723] = v2721
	end
end)
local v2722 = "F6"
local v2723 = 1360
pcall(function()
	local v2724 = enum[v]
	local v2725 = v2724 and v2724[v2722]

	if v2725 then
		Enums[v2725] = v2723
	end
end)
local v2724 = "F7"
local v2725 = 1361
pcall(function()
	local v2726 = enum[v]
	local v2727 = v2726 and v2726[v2724]

	if v2727 then
		Enums[v2727] = v2725
	end
end)
local v2726 = "F8"
local v2727 = 1362
pcall(function()
	local v2728 = enum[v]
	local v2729 = v2728 and v2728[v2726]

	if v2729 then
		Enums[v2729] = v2727
	end
end)
local v2728 = "F9"
local v2729 = 1363
pcall(function()
	local v2730 = enum[v]
	local v2731 = v2730 and v2730[v2728]

	if v2731 then
		Enums[v2731] = v2729
	end
end)
local v2730 = "F10"
local v2731 = 1364
pcall(function()
	local v2732 = enum[v]
	local v2733 = v2732 and v2732[v2730]

	if v2733 then
		Enums[v2733] = v2731
	end
end)
local v2732 = "F11"
local v2733 = 1365
pcall(function()
	local v2734 = enum[v]
	local v2735 = v2734 and v2734[v2732]

	if v2735 then
		Enums[v2735] = v2733
	end
end)
local v2734 = "F12"
local v2735 = 1366
pcall(function()
	local v2736 = enum[v]
	local v2737 = v2736 and v2736[v2734]

	if v2737 then
		Enums[v2737] = v2735
	end
end)
local v2736 = "F13"
local v2737 = 1367
pcall(function()
	local v2738 = enum[v]
	local v2739 = v2738 and v2738[v2736]

	if v2739 then
		Enums[v2739] = v2737
	end
end)
local v2738 = "F14"
local v2739 = 1368
pcall(function()
	local v2740 = enum[v]
	local v2741 = v2740 and v2740[v2738]

	if v2741 then
		Enums[v2741] = v2739
	end
end)
local v2740 = "F15"
local v2741 = 1369
pcall(function()
	local v2742 = enum[v]
	local v2743 = v2742 and v2742[v2740]

	if v2743 then
		Enums[v2743] = v2741
	end
end)
local v2742 = "NumLock"
local v2743 = 1370
pcall(function()
	local v2744 = enum[v]
	local v2745 = v2744 and v2744[v2742]

	if v2745 then
		Enums[v2745] = v2743
	end
end)
local v2744 = "CapsLock"
local v2745 = 1371
pcall(function()
	local v2746 = enum[v]
	local v2747 = v2746 and v2746[v2744]

	if v2747 then
		Enums[v2747] = v2745
	end
end)
local v2746 = "ScrollLock"
local v2747 = 1372
pcall(function()
	local v2748 = enum[v]
	local v2749 = v2748 and v2748[v2746]

	if v2749 then
		Enums[v2749] = v2747
	end
end)
local v2748 = "RightShift"
local v2749 = 1373
pcall(function()
	local v2750 = enum[v]
	local v2751 = v2750 and v2750[v2748]

	if v2751 then
		Enums[v2751] = v2749
	end
end)
local v2750 = "LeftShift"
local v2751 = 1374
pcall(function()
	local v2752 = enum[v]
	local v2753 = v2752 and v2752[v2750]

	if v2753 then
		Enums[v2753] = v2751
	end
end)
local v2752 = "RightControl"
local v2753 = 1375
pcall(function()
	local v2754 = enum[v]
	local v2755 = v2754 and v2754[v2752]

	if v2755 then
		Enums[v2755] = v2753
	end
end)
local v2754 = "LeftControl"
local v2755 = 1376
pcall(function()
	local v2756 = enum[v]
	local v2757 = v2756 and v2756[v2754]

	if v2757 then
		Enums[v2757] = v2755
	end
end)
local v2756 = "RightAlt"
local v2757 = 1377
pcall(function()
	local v2758 = enum[v]
	local v2759 = v2758 and v2758[v2756]

	if v2759 then
		Enums[v2759] = v2757
	end
end)
local v2758 = "LeftAlt"
local v2759 = 1378
pcall(function()
	local v2760 = enum[v]
	local v2761 = v2760 and v2760[v2758]

	if v2761 then
		Enums[v2761] = v2759
	end
end)
local v2760 = "RightMeta"
local v2761 = 1379
pcall(function()
	local v2762 = enum[v]
	local v2763 = v2762 and v2762[v2760]

	if v2763 then
		Enums[v2763] = v2761
	end
end)
local v2762 = "LeftMeta"
local v2763 = 1380
pcall(function()
	local v2764 = enum[v]
	local v2765 = v2764 and v2764[v2762]

	if v2765 then
		Enums[v2765] = v2763
	end
end)
local v2764 = "LeftSuper"
local v2765 = 1381
pcall(function()
	local v2766 = enum[v]
	local v2767 = v2766 and v2766[v2764]

	if v2767 then
		Enums[v2767] = v2765
	end
end)
local v2766 = "RightSuper"
local v2767 = 1382
pcall(function()
	local v2768 = enum[v]
	local v2769 = v2768 and v2768[v2766]

	if v2769 then
		Enums[v2769] = v2767
	end
end)
local v2768 = "Mode"
local v2769 = 1383
pcall(function()
	local v2770 = enum[v]
	local v2771 = v2770 and v2770[v2768]

	if v2771 then
		Enums[v2771] = v2769
	end
end)
local v2770 = "Compose"
local v2771 = 1384
pcall(function()
	local v2772 = enum[v]
	local v2773 = v2772 and v2772[v2770]

	if v2773 then
		Enums[v2773] = v2771
	end
end)
local v2772 = "Help"
local v2773 = 1385
pcall(function()
	local v2774 = enum[v]
	local v2775 = v2774 and v2774[v2772]

	if v2775 then
		Enums[v2775] = v2773
	end
end)
local v2774 = "Print"
local v2775 = 1386
pcall(function()
	local v2776 = enum[v]
	local v2777 = v2776 and v2776[v2774]

	if v2777 then
		Enums[v2777] = v2775
	end
end)
local v2776 = "SysReq"
local v2777 = 1387
pcall(function()
	local v2778 = enum[v]
	local v2779 = v2778 and v2778[v2776]

	if v2779 then
		Enums[v2779] = v2777
	end
end)
local v2778 = "Break"
local v2779 = 1388
pcall(function()
	local v2780 = enum[v]
	local v2781 = v2780 and v2780[v2778]

	if v2781 then
		Enums[v2781] = v2779
	end
end)
local v2780 = "Menu"
local v2781 = 1389
pcall(function()
	local v2782 = enum[v]
	local v2783 = v2782 and v2782[v2780]

	if v2783 then
		Enums[v2783] = v2781
	end
end)
local v2782 = "Power"
local v2783 = 1390
pcall(function()
	local v2784 = enum[v]
	local v2785 = v2784 and v2784[v2782]

	if v2785 then
		Enums[v2785] = v2783
	end
end)
local v2784 = "Euro"
local v2785 = 1391
pcall(function()
	local v2786 = enum[v]
	local v2787 = v2786 and v2786[v2784]

	if v2787 then
		Enums[v2787] = v2785
	end
end)
local v2786 = "Undo"
local v2787 = 1392
pcall(function()
	local v2788 = enum[v]
	local v2789 = v2788 and v2788[v2786]

	if v2789 then
		Enums[v2789] = v2787
	end
end)
local v2788 = "ButtonX"
local v2789 = 1393
pcall(function()
	local v2790 = enum[v]
	local v2791 = v2790 and v2790[v2788]

	if v2791 then
		Enums[v2791] = v2789
	end
end)
local v2790 = "ButtonY"
local v2791 = 1394
pcall(function()
	local v2792 = enum[v]
	local v2793 = v2792 and v2792[v2790]

	if v2793 then
		Enums[v2793] = v2791
	end
end)
local v2792 = "ButtonA"
local v2793 = 1395
pcall(function()
	local v2794 = enum[v]
	local v2795 = v2794 and v2794[v2792]

	if v2795 then
		Enums[v2795] = v2793
	end
end)
local v2794 = "ButtonB"
local v2795 = 1396
pcall(function()
	local v2796 = enum[v]
	local v2797 = v2796 and v2796[v2794]

	if v2797 then
		Enums[v2797] = v2795
	end
end)
local v2796 = "ButtonR1"
local v2797 = 1397
pcall(function()
	local v2798 = enum[v]
	local v2799 = v2798 and v2798[v2796]

	if v2799 then
		Enums[v2799] = v2797
	end
end)
local v2798 = "ButtonL1"
local v2799 = 1398
pcall(function()
	local v2800 = enum[v]
	local v2801 = v2800 and v2800[v2798]

	if v2801 then
		Enums[v2801] = v2799
	end
end)
local v2800 = "ButtonR2"
local v2801 = 1399
pcall(function()
	local v2802 = enum[v]
	local v2803 = v2802 and v2802[v2800]

	if v2803 then
		Enums[v2803] = v2801
	end
end)
local v2802 = "ButtonL2"
local v2803 = 1400
pcall(function()
	local v2804 = enum[v]
	local v2805 = v2804 and v2804[v2802]

	if v2805 then
		Enums[v2805] = v2803
	end
end)
local v2804 = "ButtonR3"
local v2805 = 1401
pcall(function()
	local v2806 = enum[v]
	local v2807 = v2806 and v2806[v2804]

	if v2807 then
		Enums[v2807] = v2805
	end
end)
local v2806 = "ButtonL3"
local v2807 = 1402
pcall(function()
	local v2808 = enum[v]
	local v2809 = v2808 and v2808[v2806]

	if v2809 then
		Enums[v2809] = v2807
	end
end)
local v2808 = "ButtonStart"
local v2809 = 1403
pcall(function()
	local v2810 = enum[v]
	local v2811 = v2810 and v2810[v2808]

	if v2811 then
		Enums[v2811] = v2809
	end
end)
local v2810 = "ButtonSelect"
local v2811 = 1404
pcall(function()
	local v2812 = enum[v]
	local v2813 = v2812 and v2812[v2810]

	if v2813 then
		Enums[v2813] = v2811
	end
end)
local v2812 = "DPadLeft"
local v2813 = 1405
pcall(function()
	local v2814 = enum[v]
	local v2815 = v2814 and v2814[v2812]

	if v2815 then
		Enums[v2815] = v2813
	end
end)
local v2814 = "DPadRight"
local v2815 = 1406
pcall(function()
	local v2816 = enum[v]
	local v2817 = v2816 and v2816[v2814]

	if v2817 then
		Enums[v2817] = v2815
	end
end)
local v2816 = "DPadUp"
local v2817 = 1407
pcall(function()
	local v2818 = enum[v]
	local v2819 = v2818 and v2818[v2816]

	if v2819 then
		Enums[v2819] = v2817
	end
end)
local v2818 = "DPadDown"
local v2819 = 1408
pcall(function()
	local v2820 = enum[v]
	local v2821 = v2820 and v2820[v2818]

	if v2821 then
		Enums[v2821] = v2819
	end
end)
local v2820 = "Thumbstick1"
local v2821 = 1409
pcall(function()
	local v2822 = enum[v]
	local v2823 = v2822 and v2822[v2820]

	if v2823 then
		Enums[v2823] = v2821
	end
end)
local v2822 = "Thumbstick2"
local v2823 = 1410
pcall(function()
	local v2824 = enum[v]
	local v2825 = v2824 and v2824[v2822]

	if v2825 then
		Enums[v2825] = v2823
	end
end)
local v2824 = "World0"
local v2825 = 1411
pcall(function()
	local v2826 = enum[v]
	local v2827 = v2826 and v2826[v2824]

	if v2827 then
		Enums[v2827] = v2825
	end
end)
local v2826 = "World1"
local v2827 = 1412
pcall(function()
	local v2828 = enum[v]
	local v2829 = v2828 and v2828[v2826]

	if v2829 then
		Enums[v2829] = v2827
	end
end)
local v2828 = "World2"
local v2829 = 1413
pcall(function()
	local v2830 = enum[v]
	local v2831 = v2830 and v2830[v2828]

	if v2831 then
		Enums[v2831] = v2829
	end
end)
local v2830 = "World3"
local v2831 = 1414
pcall(function()
	local v2832 = enum[v]
	local v2833 = v2832 and v2832[v2830]

	if v2833 then
		Enums[v2833] = v2831
	end
end)
local v2832 = "World4"
local v2833 = 1415
pcall(function()
	local v2834 = enum[v]
	local v2835 = v2834 and v2834[v2832]

	if v2835 then
		Enums[v2835] = v2833
	end
end)
local v2834 = "World5"
local v2835 = 1416
pcall(function()
	local v2836 = enum[v]
	local v2837 = v2836 and v2836[v2834]

	if v2837 then
		Enums[v2837] = v2835
	end
end)
local v2836 = "World6"
local v2837 = 1417
pcall(function()
	local v2838 = enum[v]
	local v2839 = v2838 and v2838[v2836]

	if v2839 then
		Enums[v2839] = v2837
	end
end)
local v2838 = "World7"
local v2839 = 1418
pcall(function()
	local v2840 = enum[v]
	local v2841 = v2840 and v2840[v2838]

	if v2841 then
		Enums[v2841] = v2839
	end
end)
local v2840 = "World8"
local v2841 = 1419
pcall(function()
	local v2842 = enum[v]
	local v2843 = v2842 and v2842[v2840]

	if v2843 then
		Enums[v2843] = v2841
	end
end)
local v2842 = "World9"
local v2843 = 1420
pcall(function()
	local v2844 = enum[v]
	local v2845 = v2844 and v2844[v2842]

	if v2845 then
		Enums[v2845] = v2843
	end
end)
local v2844 = "World10"
local v2845 = 1421
pcall(function()
	local v2846 = enum[v]
	local v2847 = v2846 and v2846[v2844]

	if v2847 then
		Enums[v2847] = v2845
	end
end)
local v2846 = "World11"
local v2847 = 1422
pcall(function()
	local v2848 = enum[v]
	local v2849 = v2848 and v2848[v2846]

	if v2849 then
		Enums[v2849] = v2847
	end
end)
local v2848 = "World12"
local v2849 = 1423
pcall(function()
	local v2850 = enum[v]
	local v2851 = v2850 and v2850[v2848]

	if v2851 then
		Enums[v2851] = v2849
	end
end)
local v2850 = "World13"
local v2851 = 1424
pcall(function()
	local v2852 = enum[v]
	local v2853 = v2852 and v2852[v2850]

	if v2853 then
		Enums[v2853] = v2851
	end
end)
local v2852 = "World14"
local v2853 = 1425
pcall(function()
	local v2854 = enum[v]
	local v2855 = v2854 and v2854[v2852]

	if v2855 then
		Enums[v2855] = v2853
	end
end)
local v2854 = "World15"
local v2855 = 1426
pcall(function()
	local v2856 = enum[v]
	local v2857 = v2856 and v2856[v2854]

	if v2857 then
		Enums[v2857] = v2855
	end
end)
local v2856 = "World16"
local v2857 = 1427
pcall(function()
	local v2858 = enum[v]
	local v2859 = v2858 and v2858[v2856]

	if v2859 then
		Enums[v2859] = v2857
	end
end)
local v2858 = "World17"
local v2859 = 1428
pcall(function()
	local v2860 = enum[v]
	local v2861 = v2860 and v2860[v2858]

	if v2861 then
		Enums[v2861] = v2859
	end
end)
local v2860 = "World18"
local v2861 = 1429
pcall(function()
	local v2862 = enum[v]
	local v2863 = v2862 and v2862[v2860]

	if v2863 then
		Enums[v2863] = v2861
	end
end)
local v2862 = "World19"
local v2863 = 1430
pcall(function()
	local v2864 = enum[v]
	local v2865 = v2864 and v2864[v2862]

	if v2865 then
		Enums[v2865] = v2863
	end
end)
local v2864 = "World20"
local v2865 = 1431
pcall(function()
	local v2866 = enum[v]
	local v2867 = v2866 and v2866[v2864]

	if v2867 then
		Enums[v2867] = v2865
	end
end)
local v2866 = "World21"
local v2867 = 1432
pcall(function()
	local v2868 = enum[v]
	local v2869 = v2868 and v2868[v2866]

	if v2869 then
		Enums[v2869] = v2867
	end
end)
local v2868 = "World22"
local v2869 = 1433
pcall(function()
	local v2870 = enum[v]
	local v2871 = v2870 and v2870[v2868]

	if v2871 then
		Enums[v2871] = v2869
	end
end)
local v2870 = "World23"
local v2871 = 1434
pcall(function()
	local v2872 = enum[v]
	local v2873 = v2872 and v2872[v2870]

	if v2873 then
		Enums[v2873] = v2871
	end
end)
local v2872 = "World24"
local v2873 = 1435
pcall(function()
	local v2874 = enum[v]
	local v2875 = v2874 and v2874[v2872]

	if v2875 then
		Enums[v2875] = v2873
	end
end)
local v2874 = "World25"
local v2875 = 1436
pcall(function()
	local v2876 = enum[v]
	local v2877 = v2876 and v2876[v2874]

	if v2877 then
		Enums[v2877] = v2875
	end
end)
local v2876 = "World26"
local v2877 = 1437
pcall(function()
	local v2878 = enum[v]
	local v2879 = v2878 and v2878[v2876]

	if v2879 then
		Enums[v2879] = v2877
	end
end)
local v2878 = "World27"
local v2879 = 1438
pcall(function()
	local v2880 = enum[v]
	local v2881 = v2880 and v2880[v2878]

	if v2881 then
		Enums[v2881] = v2879
	end
end)
local v2880 = "World28"
local v2881 = 1439
pcall(function()
	local v2882 = enum[v]
	local v2883 = v2882 and v2882[v2880]

	if v2883 then
		Enums[v2883] = v2881
	end
end)
local v2882 = "World29"
local v2883 = 1440
pcall(function()
	local v2884 = enum[v]
	local v2885 = v2884 and v2884[v2882]

	if v2885 then
		Enums[v2885] = v2883
	end
end)
local v2884 = "World30"
local v2885 = 1441
pcall(function()
	local v2886 = enum[v]
	local v2887 = v2886 and v2886[v2884]

	if v2887 then
		Enums[v2887] = v2885
	end
end)
local v2886 = "World31"
local v2887 = 1442
pcall(function()
	local v2888 = enum[v]
	local v2889 = v2888 and v2888[v2886]

	if v2889 then
		Enums[v2889] = v2887
	end
end)
local v2888 = "World32"
local v2889 = 1443
pcall(function()
	local v2890 = enum[v]
	local v2891 = v2890 and v2890[v2888]

	if v2891 then
		Enums[v2891] = v2889
	end
end)
local v2890 = "World33"
local v2891 = 1444
pcall(function()
	local v2892 = enum[v]
	local v2893 = v2892 and v2892[v2890]

	if v2893 then
		Enums[v2893] = v2891
	end
end)
local v2892 = "World34"
local v2893 = 1445
pcall(function()
	local v2894 = enum[v]
	local v2895 = v2894 and v2894[v2892]

	if v2895 then
		Enums[v2895] = v2893
	end
end)
local v2894 = "World35"
local v2895 = 1446
pcall(function()
	local v2896 = enum[v]
	local v2897 = v2896 and v2896[v2894]

	if v2897 then
		Enums[v2897] = v2895
	end
end)
local v2896 = "World36"
local v2897 = 1447
pcall(function()
	local v2898 = enum[v]
	local v2899 = v2898 and v2898[v2896]

	if v2899 then
		Enums[v2899] = v2897
	end
end)
local v2898 = "World37"
local v2899 = 1448
pcall(function()
	local v2900 = enum[v]
	local v2901 = v2900 and v2900[v2898]

	if v2901 then
		Enums[v2901] = v2899
	end
end)
local v2900 = "World38"
local v2901 = 1449
pcall(function()
	local v2902 = enum[v]
	local v2903 = v2902 and v2902[v2900]

	if v2903 then
		Enums[v2903] = v2901
	end
end)
local v2902 = "World39"
local v2903 = 1450
pcall(function()
	local v2904 = enum[v]
	local v2905 = v2904 and v2904[v2902]

	if v2905 then
		Enums[v2905] = v2903
	end
end)
local v2904 = "World40"
local v2905 = 1451
pcall(function()
	local v2906 = enum[v]
	local v2907 = v2906 and v2906[v2904]

	if v2907 then
		Enums[v2907] = v2905
	end
end)
local v2906 = "World41"
local v2907 = 1452
pcall(function()
	local v2908 = enum[v]
	local v2909 = v2908 and v2908[v2906]

	if v2909 then
		Enums[v2909] = v2907
	end
end)
local v2908 = "World42"
local v2909 = 1453
pcall(function()
	local v2910 = enum[v]
	local v2911 = v2910 and v2910[v2908]

	if v2911 then
		Enums[v2911] = v2909
	end
end)
local v2910 = "World43"
local v2911 = 1454
pcall(function()
	local v2912 = enum[v]
	local v2913 = v2912 and v2912[v2910]

	if v2913 then
		Enums[v2913] = v2911
	end
end)
local v2912 = "World44"
local v2913 = 1455
pcall(function()
	local v2914 = enum[v]
	local v2915 = v2914 and v2914[v2912]

	if v2915 then
		Enums[v2915] = v2913
	end
end)
local v2914 = "World45"
local v2915 = 1456
pcall(function()
	local v2916 = enum[v]
	local v2917 = v2916 and v2916[v2914]

	if v2917 then
		Enums[v2917] = v2915
	end
end)
local v2916 = "World46"
local v2917 = 1457
pcall(function()
	local v2918 = enum[v]
	local v2919 = v2918 and v2918[v2916]

	if v2919 then
		Enums[v2919] = v2917
	end
end)
local v2918 = "World47"
local v2919 = 1458
pcall(function()
	local v2920 = enum[v]
	local v2921 = v2920 and v2920[v2918]

	if v2921 then
		Enums[v2921] = v2919
	end
end)
local v2920 = "World48"
local v2921 = 1459
pcall(function()
	local v2922 = enum[v]
	local v2923 = v2922 and v2922[v2920]

	if v2923 then
		Enums[v2923] = v2921
	end
end)
local v2922 = "World49"
local v2923 = 1460
pcall(function()
	local v2924 = enum[v]
	local v2925 = v2924 and v2924[v2922]

	if v2925 then
		Enums[v2925] = v2923
	end
end)
local v2924 = "World50"
local v2925 = 1461
pcall(function()
	local v2926 = enum[v]
	local v2927 = v2926 and v2926[v2924]

	if v2927 then
		Enums[v2927] = v2925
	end
end)
local v2926 = "World51"
local v2927 = 1462
pcall(function()
	local v2928 = enum[v]
	local v2929 = v2928 and v2928[v2926]

	if v2929 then
		Enums[v2929] = v2927
	end
end)
local v2928 = "World52"
local v2929 = 1463
pcall(function()
	local v2930 = enum[v]
	local v2931 = v2930 and v2930[v2928]

	if v2931 then
		Enums[v2931] = v2929
	end
end)
local v2930 = "World53"
local v2931 = 1464
pcall(function()
	local v2932 = enum[v]
	local v2933 = v2932 and v2932[v2930]

	if v2933 then
		Enums[v2933] = v2931
	end
end)
local v2932 = "World54"
local v2933 = 1465
pcall(function()
	local v2934 = enum[v]
	local v2935 = v2934 and v2934[v2932]

	if v2935 then
		Enums[v2935] = v2933
	end
end)
local v2934 = "World55"
local v2935 = 1466
pcall(function()
	local v2936 = enum[v]
	local v2937 = v2936 and v2936[v2934]

	if v2937 then
		Enums[v2937] = v2935
	end
end)
local v2936 = "World56"
local v2937 = 1467
pcall(function()
	local v2938 = enum[v]
	local v2939 = v2938 and v2938[v2936]

	if v2939 then
		Enums[v2939] = v2937
	end
end)
local v2938 = "World57"
local v2939 = 1468
pcall(function()
	local v2940 = enum[v]
	local v2941 = v2940 and v2940[v2938]

	if v2941 then
		Enums[v2941] = v2939
	end
end)
local v2940 = "World58"
local v2941 = 1469
pcall(function()
	local v2942 = enum[v]
	local v2943 = v2942 and v2942[v2940]

	if v2943 then
		Enums[v2943] = v2941
	end
end)
local v2942 = "World59"
local v2943 = 1470
pcall(function()
	local v2944 = enum[v]
	local v2945 = v2944 and v2944[v2942]

	if v2945 then
		Enums[v2945] = v2943
	end
end)
local v2944 = "World60"
local v2945 = 1471
pcall(function()
	local v2946 = enum[v]
	local v2947 = v2946 and v2946[v2944]

	if v2947 then
		Enums[v2947] = v2945
	end
end)
local v2946 = "World61"
local v2947 = 1472
pcall(function()
	local v2948 = enum[v]
	local v2949 = v2948 and v2948[v2946]

	if v2949 then
		Enums[v2949] = v2947
	end
end)
local v2948 = "World62"
local v2949 = 1473
pcall(function()
	local v2950 = enum[v]
	local v2951 = v2950 and v2950[v2948]

	if v2951 then
		Enums[v2951] = v2949
	end
end)
local v2950 = "World63"
local v2951 = 1474
pcall(function()
	local v2952 = enum[v]
	local v2953 = v2952 and v2952[v2950]

	if v2953 then
		Enums[v2953] = v2951
	end
end)
local v2952 = "World64"
local v2953 = 1475
pcall(function()
	local v2954 = enum[v]
	local v2955 = v2954 and v2954[v2952]

	if v2955 then
		Enums[v2955] = v2953
	end
end)
local v2954 = "World65"
local v2955 = 1476
pcall(function()
	local v2956 = enum[v]
	local v2957 = v2956 and v2956[v2954]

	if v2957 then
		Enums[v2957] = v2955
	end
end)
local v2956 = "World66"
local v2957 = 1477
pcall(function()
	local v2958 = enum[v]
	local v2959 = v2958 and v2958[v2956]

	if v2959 then
		Enums[v2959] = v2957
	end
end)
local v2958 = "World67"
local v2959 = 1478
pcall(function()
	local v2960 = enum[v]
	local v2961 = v2960 and v2960[v2958]

	if v2961 then
		Enums[v2961] = v2959
	end
end)
local v2960 = "World68"
local v2961 = 1479
pcall(function()
	local v2962 = enum[v]
	local v2963 = v2962 and v2962[v2960]

	if v2963 then
		Enums[v2963] = v2961
	end
end)
local v2962 = "World69"
local v2963 = 1480
pcall(function()
	local v2964 = enum[v]
	local v2965 = v2964 and v2964[v2962]

	if v2965 then
		Enums[v2965] = v2963
	end
end)
local v2964 = "World70"
local v2965 = 1481
pcall(function()
	local v2966 = enum[v]
	local v2967 = v2966 and v2966[v2964]

	if v2967 then
		Enums[v2967] = v2965
	end
end)
local v2966 = "World71"
local v2967 = 1482
pcall(function()
	local v2968 = enum[v]
	local v2969 = v2968 and v2968[v2966]

	if v2969 then
		Enums[v2969] = v2967
	end
end)
local v2968 = "World72"
local v2969 = 1483
pcall(function()
	local v2970 = enum[v]
	local v2971 = v2970 and v2970[v2968]

	if v2971 then
		Enums[v2971] = v2969
	end
end)
local v2970 = "World73"
local v2971 = 1484
pcall(function()
	local v2972 = enum[v]
	local v2973 = v2972 and v2972[v2970]

	if v2973 then
		Enums[v2973] = v2971
	end
end)
local v2972 = "World74"
local v2973 = 1485
pcall(function()
	local v2974 = enum[v]
	local v2975 = v2974 and v2974[v2972]

	if v2975 then
		Enums[v2975] = v2973
	end
end)
local v2974 = "World75"
local v2975 = 1486
pcall(function()
	local v2976 = enum[v]
	local v2977 = v2976 and v2976[v2974]

	if v2977 then
		Enums[v2977] = v2975
	end
end)
local v2976 = "World76"
local v2977 = 1487
pcall(function()
	local v2978 = enum[v]
	local v2979 = v2978 and v2978[v2976]

	if v2979 then
		Enums[v2979] = v2977
	end
end)
local v2978 = "World77"
local v2979 = 1488
pcall(function()
	local v2980 = enum[v]
	local v2981 = v2980 and v2980[v2978]

	if v2981 then
		Enums[v2981] = v2979
	end
end)
local v2980 = "World78"
local v2981 = 1489
pcall(function()
	local v2982 = enum[v]
	local v2983 = v2982 and v2982[v2980]

	if v2983 then
		Enums[v2983] = v2981
	end
end)
local v2982 = "World79"
local v2983 = 1490
pcall(function()
	local v2984 = enum[v]
	local v2985 = v2984 and v2984[v2982]

	if v2985 then
		Enums[v2985] = v2983
	end
end)
local v2984 = "World80"
local v2985 = 1491
pcall(function()
	local v2986 = enum[v]
	local v2987 = v2986 and v2986[v2984]

	if v2987 then
		Enums[v2987] = v2985
	end
end)
local v2986 = "World81"
local v2987 = 1492
pcall(function()
	local v2988 = enum[v]
	local v2989 = v2988 and v2988[v2986]

	if v2989 then
		Enums[v2989] = v2987
	end
end)
local v2988 = "World82"
local v2989 = 1493
pcall(function()
	local v2990 = enum[v]
	local v2991 = v2990 and v2990[v2988]

	if v2991 then
		Enums[v2991] = v2989
	end
end)
local v2990 = "World83"
local v2991 = 1494
pcall(function()
	local v2992 = enum[v]
	local v2993 = v2992 and v2992[v2990]

	if v2993 then
		Enums[v2993] = v2991
	end
end)
local v2992 = "World84"
local v2993 = 1495
pcall(function()
	local v2994 = enum[v]
	local v2995 = v2994 and v2994[v2992]

	if v2995 then
		Enums[v2995] = v2993
	end
end)
local v2994 = "World85"
local v2995 = 1496
pcall(function()
	local v2996 = enum[v]
	local v2997 = v2996 and v2996[v2994]

	if v2997 then
		Enums[v2997] = v2995
	end
end)
local v2996 = "World86"
local v2997 = 1497
pcall(function()
	local v2998 = enum[v]
	local v2999 = v2998 and v2998[v2996]

	if v2999 then
		Enums[v2999] = v2997
	end
end)
local v2998 = "World87"
local v2999 = 1498
pcall(function()
	local v3000 = enum[v]
	local v3001 = v3000 and v3000[v2998]

	if v3001 then
		Enums[v3001] = v2999
	end
end)
local v3000 = "World88"
local v3001 = 1499
pcall(function()
	local v3002 = enum[v]
	local v3003 = v3002 and v3002[v3000]

	if v3003 then
		Enums[v3003] = v3001
	end
end)
local v3002 = "World89"
local v3003 = 1500
pcall(function()
	local v3004 = enum[v]
	local v3005 = v3004 and v3004[v3002]

	if v3005 then
		Enums[v3005] = v3003
	end
end)
local v3004 = "World90"
local v3005 = 1501
pcall(function()
	local v3006 = enum[v]
	local v3007 = v3006 and v3006[v3004]

	if v3007 then
		Enums[v3007] = v3005
	end
end)
local v3006 = "World91"
local v3007 = 1502
pcall(function()
	local v3008 = enum[v]
	local v3009 = v3008 and v3008[v3006]

	if v3009 then
		Enums[v3009] = v3007
	end
end)
local v3008 = "World92"
local v3009 = 1503
pcall(function()
	local v3010 = enum[v]
	local v3011 = v3010 and v3010[v3008]

	if v3011 then
		Enums[v3011] = v3009
	end
end)
local v3010 = "World93"
local v3011 = 1504
pcall(function()
	local v3012 = enum[v]
	local v3013 = v3012 and v3012[v3010]

	if v3013 then
		Enums[v3013] = v3011
	end
end)
local v3012 = "World94"
local v3013 = 1505
pcall(function()
	local v3014 = enum[v]
	local v3015 = v3014 and v3014[v3012]

	if v3015 then
		Enums[v3015] = v3013
	end
end)
local v3014 = "World95"
local v3015 = 1506
pcall(function()
	local v3016 = enum[v]
	local v3017 = v3016 and v3016[v3014]

	if v3017 then
		Enums[v3017] = v3015
	end
end)
local v3016 = "MouseLeftButton"
local v3017 = 1507
pcall(function()
	local v3018 = enum[v]
	local v3019 = v3018 and v3018[v3016]

	if v3019 then
		Enums[v3019] = v3017
	end
end)
local v3018 = "MouseRightButton"
local v3019 = 1508
pcall(function()
	local v3020 = enum[v]
	local v3021 = v3020 and v3020[v3018]

	if v3021 then
		Enums[v3021] = v3019
	end
end)
local v3020 = "MouseMiddleButton"
local v3021 = 1509
pcall(function()
	local v3022 = enum[v]
	local v3023 = v3022 and v3022[v3020]

	if v3023 then
		Enums[v3023] = v3021
	end
end)
local v3022 = "MouseBackButton"
local v3023 = 1510
pcall(function()
	local v3024 = enum[v]
	local v3025 = v3024 and v3024[v3022]

	if v3025 then
		Enums[v3025] = v3023
	end
end)
local v3024 = "MouseNoButton"
local v3025 = 1511
pcall(function()
	local v3026 = enum[v]
	local v3027 = v3026 and v3026[v3024]

	if v3027 then
		Enums[v3027] = v3025
	end
end)
local v3026 = "MouseX"
local v3027 = 1512
pcall(function()
	local v3028 = enum[v]
	local v3029 = v3028 and v3028[v3026]

	if v3029 then
		Enums[v3029] = v3027
	end
end)
local v3028 = "MouseY"
local v3029 = 1513
pcall(function()
	local v3030 = enum[v]
	local v3031 = v3030 and v3030[v3028]

	if v3031 then
		Enums[v3031] = v3029
	end
end)
v = "KeyInterpolationMode"
local v3030 = "Constant"
local v3031 = 1514
pcall(function()
	local v3032 = enum[v]
	local v3033 = v3032 and v3032[v3030]

	if v3033 then
		Enums[v3033] = v3031
	end
end)
local v3032 = "Linear"
local v3033 = 1515
pcall(function()
	local v3034 = enum[v]
	local v3035 = v3034 and v3034[v3032]

	if v3035 then
		Enums[v3035] = v3033
	end
end)
local v3034 = "Cubic"
local v3035 = 1516
pcall(function()
	local v3036 = enum[v]
	local v3037 = v3036 and v3036[v3034]

	if v3037 then
		Enums[v3037] = v3035
	end
end)
v = "KeywordFilterType"
local v3036 = "Include"
local v3037 = 1517
pcall(function()
	local v3038 = enum[v]
	local v3039 = v3038 and v3038[v3036]

	if v3039 then
		Enums[v3039] = v3037
	end
end)
local v3038 = "Exclude"
local v3039 = 1518
pcall(function()
	local v3040 = enum[v]
	local v3041 = v3040 and v3040[v3038]

	if v3041 then
		Enums[v3041] = v3039
	end
end)
v = "Language"
local v3040 = "Default"
local v3041 = 1519
pcall(function()
	local v3042 = enum[v]
	local v3043 = v3042 and v3042[v3040]

	if v3043 then
		Enums[v3043] = v3041
	end
end)
v = "LeftRight"
local v3042 = "Left"
local v3043 = 1520
pcall(function()
	local v3044 = enum[v]
	local v3045 = v3044 and v3044[v3042]

	if v3045 then
		Enums[v3045] = v3043
	end
end)
local v3044 = "Center"
local v3045 = 1521
pcall(function()
	local v3046 = enum[v]
	local v3047 = v3046 and v3046[v3044]

	if v3047 then
		Enums[v3047] = v3045
	end
end)
local v3046 = "Right"
local v3047 = 1522
pcall(function()
	local v3048 = enum[v]
	local v3049 = v3048 and v3048[v3046]

	if v3049 then
		Enums[v3049] = v3047
	end
end)
v = "LexemeType"
local v3048 = "Eof"
local v3049 = 1523
pcall(function()
	local v3050 = enum[v]
	local v3051 = v3050 and v3050[v3048]

	if v3051 then
		Enums[v3051] = v3049
	end
end)
local v3050 = "Name"
local v3051 = 1524
pcall(function()
	local v3052 = enum[v]
	local v3053 = v3052 and v3052[v3050]

	if v3053 then
		Enums[v3053] = v3051
	end
end)
local v3052 = "QuotedString"
local v3053 = 1525
pcall(function()
	local v3054 = enum[v]
	local v3055 = v3054 and v3054[v3052]

	if v3055 then
		Enums[v3055] = v3053
	end
end)
local v3054 = "Number"
local v3055 = 1526
pcall(function()
	local v3056 = enum[v]
	local v3057 = v3056 and v3056[v3054]

	if v3057 then
		Enums[v3057] = v3055
	end
end)
local v3056 = "And"
local v3057 = 1527
pcall(function()
	local v3058 = enum[v]
	local v3059 = v3058 and v3058[v3056]

	if v3059 then
		Enums[v3059] = v3057
	end
end)
local v3058 = "Or"
local v3059 = 1528
pcall(function()
	local v3060 = enum[v]
	local v3061 = v3060 and v3060[v3058]

	if v3061 then
		Enums[v3061] = v3059
	end
end)
local v3060 = "Equal"
local v3061 = 1529
pcall(function()
	local v3062 = enum[v]
	local v3063 = v3062 and v3062[v3060]

	if v3063 then
		Enums[v3063] = v3061
	end
end)
local v3062 = "TildeEqual"
local v3063 = 1530
pcall(function()
	local v3064 = enum[v]
	local v3065 = v3064 and v3064[v3062]

	if v3065 then
		Enums[v3065] = v3063
	end
end)
local v3064 = "GreaterThan"
local v3065 = 1531
pcall(function()
	local v3066 = enum[v]
	local v3067 = v3066 and v3066[v3064]

	if v3067 then
		Enums[v3067] = v3065
	end
end)
local v3066 = "GreaterThanEqual"
local v3067 = 1532
pcall(function()
	local v3068 = enum[v]
	local v3069 = v3068 and v3068[v3066]

	if v3069 then
		Enums[v3069] = v3067
	end
end)
local v3068 = "LessThan"
local v3069 = 1533
pcall(function()
	local v3070 = enum[v]
	local v3071 = v3070 and v3070[v3068]

	if v3071 then
		Enums[v3071] = v3069
	end
end)
local v3070 = "LessThanEqual"
local v3071 = 1534
pcall(function()
	local v3072 = enum[v]
	local v3073 = v3072 and v3072[v3070]

	if v3073 then
		Enums[v3073] = v3071
	end
end)
local v3072 = "Colon"
local v3073 = 1535
pcall(function()
	local v3074 = enum[v]
	local v3075 = v3074 and v3074[v3072]

	if v3075 then
		Enums[v3075] = v3073
	end
end)
local v3074 = "Dot"
local v3075 = 1536
pcall(function()
	local v3076 = enum[v]
	local v3077 = v3076 and v3076[v3074]

	if v3077 then
		Enums[v3077] = v3075
	end
end)
local v3076 = "LeftParenthesis"
local v3077 = 1537
pcall(function()
	local v3078 = enum[v]
	local v3079 = v3078 and v3078[v3076]

	if v3079 then
		Enums[v3079] = v3077
	end
end)
local v3078 = "RightParenthesis"
local v3079 = 1538
pcall(function()
	local v3080 = enum[v]
	local v3081 = v3080 and v3080[v3078]

	if v3081 then
		Enums[v3081] = v3079
	end
end)
local v3080 = "Star"
local v3081 = 1539
pcall(function()
	local v3082 = enum[v]
	local v3083 = v3082 and v3082[v3080]

	if v3083 then
		Enums[v3083] = v3081
	end
end)
local v3082 = "DoubleStar"
local v3083 = 1540
pcall(function()
	local v3084 = enum[v]
	local v3085 = v3084 and v3084[v3082]

	if v3085 then
		Enums[v3085] = v3083
	end
end)
local v3084 = "ReservedSpecial"
local v3085 = 1541
pcall(function()
	local v3086 = enum[v]
	local v3087 = v3086 and v3086[v3084]

	if v3087 then
		Enums[v3087] = v3085
	end
end)
v = "LightingStyle"
local v3086 = "Realistic"
local v3087 = 1542
pcall(function()
	local v3088 = enum[v]
	local v3089 = v3088 and v3088[v3086]

	if v3089 then
		Enums[v3089] = v3087
	end
end)
local v3088 = "Soft"
local v3089 = 1543
pcall(function()
	local v3090 = enum[v]
	local v3091 = v3090 and v3090[v3088]

	if v3091 then
		Enums[v3091] = v3089
	end
end)
v = "Limb"
local v3090 = "Head"
local v3091 = 1544
pcall(function()
	local v3092 = enum[v]
	local v3093 = v3092 and v3092[v3090]

	if v3093 then
		Enums[v3093] = v3091
	end
end)
local v3092 = "Torso"
local v3093 = 1545
pcall(function()
	local v3094 = enum[v]
	local v3095 = v3094 and v3094[v3092]

	if v3095 then
		Enums[v3095] = v3093
	end
end)
local v3094 = "LeftArm"
local v3095 = 1546
pcall(function()
	local v3096 = enum[v]
	local v3097 = v3096 and v3096[v3094]

	if v3097 then
		Enums[v3097] = v3095
	end
end)
local v3096 = "RightArm"
local v3097 = 1547
pcall(function()
	local v3098 = enum[v]
	local v3099 = v3098 and v3098[v3096]

	if v3099 then
		Enums[v3099] = v3097
	end
end)
local v3098 = "LeftLeg"
local v3099 = 1548
pcall(function()
	local v3100 = enum[v]
	local v3101 = v3100 and v3100[v3098]

	if v3101 then
		Enums[v3101] = v3099
	end
end)
local v3100 = "RightLeg"
local v3101 = 1549
pcall(function()
	local v3102 = enum[v]
	local v3103 = v3102 and v3102[v3100]

	if v3103 then
		Enums[v3103] = v3101
	end
end)
local v3102 = "Unknown"
local v3103 = 1550
pcall(function()
	local v3104 = enum[v]
	local v3105 = v3104 and v3104[v3102]

	if v3105 then
		Enums[v3105] = v3103
	end
end)
v = "LineJoinMode"
local v3104 = "Round"
local v3105 = 1551
pcall(function()
	local v3106 = enum[v]
	local v3107 = v3106 and v3106[v3104]

	if v3107 then
		Enums[v3107] = v3105
	end
end)
local v3106 = "Bevel"
local v3107 = 1552
pcall(function()
	local v3108 = enum[v]
	local v3109 = v3108 and v3108[v3106]

	if v3109 then
		Enums[v3109] = v3107
	end
end)
local v3108 = "Miter"
local v3109 = 1553
pcall(function()
	local v3110 = enum[v]
	local v3111 = v3110 and v3110[v3108]

	if v3111 then
		Enums[v3111] = v3109
	end
end)
v = "ListDisplayMode"
local v3110 = "Horizontal"
local v3111 = 1554
pcall(function()
	local v3112 = enum[v]
	local v3113 = v3112 and v3112[v3110]

	if v3113 then
		Enums[v3113] = v3111
	end
end)
local v3112 = "Vertical"
local v3113 = 1555
pcall(function()
	local v3114 = enum[v]
	local v3115 = v3114 and v3114[v3112]

	if v3115 then
		Enums[v3115] = v3113
	end
end)
v = "ListenerLocation"
local v3114 = "Default"
local v3115 = 1556
pcall(function()
	local v3116 = enum[v]
	local v3117 = v3116 and v3116[v3114]

	if v3117 then
		Enums[v3117] = v3115
	end
end)
local v3116 = "None"
local v3117 = 1557
pcall(function()
	local v3118 = enum[v]
	local v3119 = v3118 and v3118[v3116]

	if v3119 then
		Enums[v3119] = v3117
	end
end)
local v3118 = "Character"
local v3119 = 1558
pcall(function()
	local v3120 = enum[v]
	local v3121 = v3120 and v3120[v3118]

	if v3121 then
		Enums[v3121] = v3119
	end
end)
local v3120 = "Camera"
local v3121 = 1559
pcall(function()
	local v3122 = enum[v]
	local v3123 = v3122 and v3122[v3120]

	if v3123 then
		Enums[v3123] = v3121
	end
end)
v = "ListenerType"
local v3122 = "Camera"
local v3123 = 1560
pcall(function()
	local v3124 = enum[v]
	local v3125 = v3124 and v3124[v3122]

	if v3125 then
		Enums[v3125] = v3123
	end
end)
local v3124 = "CFrame"
local v3125 = 1561
pcall(function()
	local v3126 = enum[v]
	local v3127 = v3126 and v3126[v3124]

	if v3127 then
		Enums[v3127] = v3125
	end
end)
local v3126 = "ObjectPosition"
local v3127 = 1562
pcall(function()
	local v3128 = enum[v]
	local v3129 = v3128 and v3128[v3126]

	if v3129 then
		Enums[v3129] = v3127
	end
end)
local v3128 = "ObjectCFrame"
local v3129 = 1563
pcall(function()
	local v3130 = enum[v]
	local v3131 = v3130 and v3130[v3128]

	if v3131 then
		Enums[v3131] = v3129
	end
end)
v = "LiveEditingAtomicUpdateResponse"
local v3130 = "Success"
local v3131 = 1564
pcall(function()
	local v3132 = enum[v]
	local v3133 = v3132 and v3132[v3130]

	if v3133 then
		Enums[v3133] = v3131
	end
end)
local v3132 = "FailureGuidNotFound"
local v3133 = 1565
pcall(function()
	local v3134 = enum[v]
	local v3135 = v3134 and v3134[v3132]

	if v3135 then
		Enums[v3135] = v3133
	end
end)
local v3134 = "FailureHashMismatch"
local v3135 = 1566
pcall(function()
	local v3136 = enum[v]
	local v3137 = v3136 and v3136[v3134]

	if v3137 then
		Enums[v3137] = v3135
	end
end)
local v3136 = "FailureOperationIllegal"
local v3137 = 1567
pcall(function()
	local v3138 = enum[v]
	local v3139 = v3138 and v3138[v3136]

	if v3139 then
		Enums[v3139] = v3137
	end
end)
v = "LiveEditingBroadcastMessageType"
local v3138 = "Normal"
local v3139 = 1568
pcall(function()
	local v3140 = enum[v]
	local v3141 = v3140 and v3140[v3138]

	if v3141 then
		Enums[v3141] = v3139
	end
end)
local v3140 = "Warning"
local v3141 = 1569
pcall(function()
	local v3142 = enum[v]
	local v3143 = v3142 and v3142[v3140]

	if v3143 then
		Enums[v3143] = v3141
	end
end)
local v3142 = "Error"
local v3143 = 1570
pcall(function()
	local v3144 = enum[v]
	local v3145 = v3144 and v3144[v3142]

	if v3145 then
		Enums[v3145] = v3143
	end
end)
v = "LoadCharacterLayeredClothing"
local v3144 = "Default"
local v3145 = 1571
pcall(function()
	local v3146 = enum[v]
	local v3147 = v3146 and v3146[v3144]

	if v3147 then
		Enums[v3147] = v3145
	end
end)
local v3146 = "Disabled"
local v3147 = 1572
pcall(function()
	local v3148 = enum[v]
	local v3149 = v3148 and v3148[v3146]

	if v3149 then
		Enums[v3149] = v3147
	end
end)
local v3148 = "Enabled"
local v3149 = 1573
pcall(function()
	local v3150 = enum[v]
	local v3151 = v3150 and v3150[v3148]

	if v3151 then
		Enums[v3151] = v3149
	end
end)
v = "LoadDynamicHeads"
local v3150 = "Default"
local v3151 = 1574
pcall(function()
	local v3152 = enum[v]
	local v3153 = v3152 and v3152[v3150]

	if v3153 then
		Enums[v3153] = v3151
	end
end)
local v3152 = "Disabled"
local v3153 = 1575
pcall(function()
	local v3154 = enum[v]
	local v3155 = v3154 and v3154[v3152]

	if v3155 then
		Enums[v3155] = v3153
	end
end)
local v3154 = "Enabled"
local v3155 = 1576
pcall(function()
	local v3156 = enum[v]
	local v3157 = v3156 and v3156[v3154]

	if v3157 then
		Enums[v3157] = v3155
	end
end)
v = "LocationType"
local v3156 = "Character"
local v3157 = 1577
pcall(function()
	local v3158 = enum[v]
	local v3159 = v3158 and v3158[v3156]

	if v3159 then
		Enums[v3159] = v3157
	end
end)
local v3158 = "Camera"
local v3159 = 1578
pcall(function()
	local v3160 = enum[v]
	local v3161 = v3160 and v3160[v3158]

	if v3161 then
		Enums[v3161] = v3159
	end
end)
local v3160 = "ObjectPosition"
local v3161 = 1579
pcall(function()
	local v3162 = enum[v]
	local v3163 = v3162 and v3162[v3160]

	if v3163 then
		Enums[v3163] = v3161
	end
end)
v = "MarketplaceBulkPurchasePromptStatus"
local v3162 = "Completed"
local v3163 = 1580
pcall(function()
	local v3164 = enum[v]
	local v3165 = v3164 and v3164[v3162]

	if v3165 then
		Enums[v3165] = v3163
	end
end)
local v3164 = "Aborted"
local v3165 = 1581
pcall(function()
	local v3166 = enum[v]
	local v3167 = v3166 and v3166[v3164]

	if v3167 then
		Enums[v3167] = v3165
	end
end)
local v3166 = "Error"
local v3167 = 1582
pcall(function()
	local v3168 = enum[v]
	local v3169 = v3168 and v3168[v3166]

	if v3169 then
		Enums[v3169] = v3167
	end
end)
v = "MarketplaceItemPurchaseStatus"
local v3168 = "Success"
local v3169 = 1583
pcall(function()
	local v3170 = enum[v]
	local v3171 = v3170 and v3170[v3168]

	if v3171 then
		Enums[v3171] = v3169
	end
end)
local v3170 = "SystemError"
local v3171 = 1584
pcall(function()
	local v3172 = enum[v]
	local v3173 = v3172 and v3172[v3170]

	if v3173 then
		Enums[v3173] = v3171
	end
end)
local v3172 = "AlreadyOwned"
local v3173 = 1585
pcall(function()
	local v3174 = enum[v]
	local v3175 = v3174 and v3174[v3172]

	if v3175 then
		Enums[v3175] = v3173
	end
end)
local v3174 = "InsufficientRobux"
local v3175 = 1586
pcall(function()
	local v3176 = enum[v]
	local v3177 = v3176 and v3176[v3174]

	if v3177 then
		Enums[v3177] = v3175
	end
end)
local v3176 = "QuantityLimitExceeded"
local v3177 = 1587
pcall(function()
	local v3178 = enum[v]
	local v3179 = v3178 and v3178[v3176]

	if v3179 then
		Enums[v3179] = v3177
	end
end)
local v3178 = "QuotaExceeded"
local v3179 = 1588
pcall(function()
	local v3180 = enum[v]
	local v3181 = v3180 and v3180[v3178]

	if v3181 then
		Enums[v3181] = v3179
	end
end)
local v3180 = "NotForSale"
local v3181 = 1589
pcall(function()
	local v3182 = enum[v]
	local v3183 = v3182 and v3182[v3180]

	if v3183 then
		Enums[v3183] = v3181
	end
end)
local v3182 = "NotAvailableForPurchaser"
local v3183 = 1590
pcall(function()
	local v3184 = enum[v]
	local v3185 = v3184 and v3184[v3182]

	if v3185 then
		Enums[v3185] = v3183
	end
end)
local v3184 = "PriceMismatch"
local v3185 = 1591
pcall(function()
	local v3186 = enum[v]
	local v3187 = v3186 and v3186[v3184]

	if v3187 then
		Enums[v3187] = v3185
	end
end)
local v3186 = "SoldOut"
local v3187 = 1592
pcall(function()
	local v3188 = enum[v]
	local v3189 = v3188 and v3188[v3186]

	if v3189 then
		Enums[v3189] = v3187
	end
end)
local v3188 = "PurchaserIsSeller"
local v3189 = 1593
pcall(function()
	local v3190 = enum[v]
	local v3191 = v3190 and v3190[v3188]

	if v3191 then
		Enums[v3191] = v3189
	end
end)
local v3190 = "InsufficientMembership"
local v3191 = 1594
pcall(function()
	local v3192 = enum[v]
	local v3193 = v3192 and v3192[v3190]

	if v3193 then
		Enums[v3193] = v3191
	end
end)
local v3192 = "PlaceInvalid"
local v3193 = 1595
pcall(function()
	local v3194 = enum[v]
	local v3195 = v3194 and v3194[v3192]

	if v3195 then
		Enums[v3195] = v3193
	end
end)
v = "MarketplaceProductType"
local v3194 = "AvatarAsset"
local v3195 = 1596
pcall(function()
	local v3196 = enum[v]
	local v3197 = v3196 and v3196[v3194]

	if v3197 then
		Enums[v3197] = v3195
	end
end)
local v3196 = "AvatarBundle"
local v3197 = 1597
pcall(function()
	local v3198 = enum[v]
	local v3199 = v3198 and v3198[v3196]

	if v3199 then
		Enums[v3199] = v3197
	end
end)
v = "MarkupKind"
local v3198 = "PlainText"
local v3199 = 1598
pcall(function()
	local v3200 = enum[v]
	local v3201 = v3200 and v3200[v3198]

	if v3201 then
		Enums[v3201] = v3199
	end
end)
local v3200 = "Markdown"
local v3201 = 1599
pcall(function()
	local v3202 = enum[v]
	local v3203 = v3202 and v3202[v3200]

	if v3203 then
		Enums[v3203] = v3201
	end
end)
v = "MatchmakingType"
local v3202 = "Default"
local v3203 = 1600
pcall(function()
	local v3204 = enum[v]
	local v3205 = v3204 and v3204[v3202]

	if v3205 then
		Enums[v3205] = v3203
	end
end)
local v3204 = "XboxOnly"
local v3205 = 1601
pcall(function()
	local v3206 = enum[v]
	local v3207 = v3206 and v3206[v3204]

	if v3207 then
		Enums[v3207] = v3205
	end
end)
local v3206 = "PlayStationOnly"
local v3207 = 1602
pcall(function()
	local v3208 = enum[v]
	local v3209 = v3208 and v3208[v3206]

	if v3209 then
		Enums[v3209] = v3207
	end
end)
v = "Material"
local v3208 = "Plastic"
local v3209 = 1603
pcall(function()
	local v3210 = enum[v]
	local v3211 = v3210 and v3210[v3208]

	if v3211 then
		Enums[v3211] = v3209
	end
end)
local v3210 = "SmoothPlastic"
local v3211 = 1604
pcall(function()
	local v3212 = enum[v]
	local v3213 = v3212 and v3212[v3210]

	if v3213 then
		Enums[v3213] = v3211
	end
end)
local v3212 = "Neon"
local v3213 = 1605
pcall(function()
	local v3214 = enum[v]
	local v3215 = v3214 and v3214[v3212]

	if v3215 then
		Enums[v3215] = v3213
	end
end)
local v3214 = "Wood"
local v3215 = 1606
pcall(function()
	local v3216 = enum[v]
	local v3217 = v3216 and v3216[v3214]

	if v3217 then
		Enums[v3217] = v3215
	end
end)
local v3216 = "WoodPlanks"
local v3217 = 1607
pcall(function()
	local v3218 = enum[v]
	local v3219 = v3218 and v3218[v3216]

	if v3219 then
		Enums[v3219] = v3217
	end
end)
local v3218 = "Marble"
local v3219 = 1608
pcall(function()
	local v3220 = enum[v]
	local v3221 = v3220 and v3220[v3218]

	if v3221 then
		Enums[v3221] = v3219
	end
end)
local v3220 = "Slate"
local v3221 = 1609
pcall(function()
	local v3222 = enum[v]
	local v3223 = v3222 and v3222[v3220]

	if v3223 then
		Enums[v3223] = v3221
	end
end)
local v3222 = "Concrete"
local v3223 = 1610
pcall(function()
	local v3224 = enum[v]
	local v3225 = v3224 and v3224[v3222]

	if v3225 then
		Enums[v3225] = v3223
	end
end)
local v3224 = "Granite"
local v3225 = 1611
pcall(function()
	local v3226 = enum[v]
	local v3227 = v3226 and v3226[v3224]

	if v3227 then
		Enums[v3227] = v3225
	end
end)
local v3226 = "Brick"
local v3227 = 1612
pcall(function()
	local v3228 = enum[v]
	local v3229 = v3228 and v3228[v3226]

	if v3229 then
		Enums[v3229] = v3227
	end
end)
local v3228 = "Pebble"
local v3229 = 1613
pcall(function()
	local v3230 = enum[v]
	local v3231 = v3230 and v3230[v3228]

	if v3231 then
		Enums[v3231] = v3229
	end
end)
local v3230 = "Cobblestone"
local v3231 = 1614
pcall(function()
	local v3232 = enum[v]
	local v3233 = v3232 and v3232[v3230]

	if v3233 then
		Enums[v3233] = v3231
	end
end)
local v3232 = "Rock"
local v3233 = 1615
pcall(function()
	local v3234 = enum[v]
	local v3235 = v3234 and v3234[v3232]

	if v3235 then
		Enums[v3235] = v3233
	end
end)
local v3234 = "Sandstone"
local v3235 = 1616
pcall(function()
	local v3236 = enum[v]
	local v3237 = v3236 and v3236[v3234]

	if v3237 then
		Enums[v3237] = v3235
	end
end)
local v3236 = "Basalt"
local v3237 = 1617
pcall(function()
	local v3238 = enum[v]
	local v3239 = v3238 and v3238[v3236]

	if v3239 then
		Enums[v3239] = v3237
	end
end)
local v3238 = "CrackedLava"
local v3239 = 1618
pcall(function()
	local v3240 = enum[v]
	local v3241 = v3240 and v3240[v3238]

	if v3241 then
		Enums[v3241] = v3239
	end
end)
local v3240 = "Limestone"
local v3241 = 1619
pcall(function()
	local v3242 = enum[v]
	local v3243 = v3242 and v3242[v3240]

	if v3243 then
		Enums[v3243] = v3241
	end
end)
local v3242 = "Pavement"
local v3243 = 1620
pcall(function()
	local v3244 = enum[v]
	local v3245 = v3244 and v3244[v3242]

	if v3245 then
		Enums[v3245] = v3243
	end
end)
local v3244 = "CorrodedMetal"
local v3245 = 1621
pcall(function()
	local v3246 = enum[v]
	local v3247 = v3246 and v3246[v3244]

	if v3247 then
		Enums[v3247] = v3245
	end
end)
local v3246 = "DiamondPlate"
local v3247 = 1622
pcall(function()
	local v3248 = enum[v]
	local v3249 = v3248 and v3248[v3246]

	if v3249 then
		Enums[v3249] = v3247
	end
end)
local v3248 = "Foil"
local v3249 = 1623
pcall(function()
	local v3250 = enum[v]
	local v3251 = v3250 and v3250[v3248]

	if v3251 then
		Enums[v3251] = v3249
	end
end)
local v3250 = "Metal"
local v3251 = 1624
pcall(function()
	local v3252 = enum[v]
	local v3253 = v3252 and v3252[v3250]

	if v3253 then
		Enums[v3253] = v3251
	end
end)
local v3252 = "Grass"
local v3253 = 1625
pcall(function()
	local v3254 = enum[v]
	local v3255 = v3254 and v3254[v3252]

	if v3255 then
		Enums[v3255] = v3253
	end
end)
local v3254 = "LeafyGrass"
local v3255 = 1626
pcall(function()
	local v3256 = enum[v]
	local v3257 = v3256 and v3256[v3254]

	if v3257 then
		Enums[v3257] = v3255
	end
end)
local v3256 = "Sand"
local v3257 = 1627
pcall(function()
	local v3258 = enum[v]
	local v3259 = v3258 and v3258[v3256]

	if v3259 then
		Enums[v3259] = v3257
	end
end)
local v3258 = "Fabric"
local v3259 = 1628
pcall(function()
	local v3260 = enum[v]
	local v3261 = v3260 and v3260[v3258]

	if v3261 then
		Enums[v3261] = v3259
	end
end)
local v3260 = "Snow"
local v3261 = 1629
pcall(function()
	local v3262 = enum[v]
	local v3263 = v3262 and v3262[v3260]

	if v3263 then
		Enums[v3263] = v3261
	end
end)
local v3262 = "Mud"
local v3263 = 1630
pcall(function()
	local v3264 = enum[v]
	local v3265 = v3264 and v3264[v3262]

	if v3265 then
		Enums[v3265] = v3263
	end
end)
local v3264 = "Ground"
local v3265 = 1631
pcall(function()
	local v3266 = enum[v]
	local v3267 = v3266 and v3266[v3264]

	if v3267 then
		Enums[v3267] = v3265
	end
end)
local v3266 = "Asphalt"
local v3267 = 1632
pcall(function()
	local v3268 = enum[v]
	local v3269 = v3268 and v3268[v3266]

	if v3269 then
		Enums[v3269] = v3267
	end
end)
local v3268 = "Salt"
local v3269 = 1633
pcall(function()
	local v3270 = enum[v]
	local v3271 = v3270 and v3270[v3268]

	if v3271 then
		Enums[v3271] = v3269
	end
end)
local v3270 = "Ice"
local v3271 = 1634
pcall(function()
	local v3272 = enum[v]
	local v3273 = v3272 and v3272[v3270]

	if v3273 then
		Enums[v3273] = v3271
	end
end)
local v3272 = "Glacier"
local v3273 = 1635
pcall(function()
	local v3274 = enum[v]
	local v3275 = v3274 and v3274[v3272]

	if v3275 then
		Enums[v3275] = v3273
	end
end)
local v3274 = "Glass"
local v3275 = 1636
pcall(function()
	local v3276 = enum[v]
	local v3277 = v3276 and v3276[v3274]

	if v3277 then
		Enums[v3277] = v3275
	end
end)
local v3276 = "ForceField"
local v3277 = 1637
pcall(function()
	local v3278 = enum[v]
	local v3279 = v3278 and v3278[v3276]

	if v3279 then
		Enums[v3279] = v3277
	end
end)
local v3278 = "Air"
local v3279 = 1638
pcall(function()
	local v3280 = enum[v]
	local v3281 = v3280 and v3280[v3278]

	if v3281 then
		Enums[v3281] = v3279
	end
end)
local v3280 = "Water"
local v3281 = 1639
pcall(function()
	local v3282 = enum[v]
	local v3283 = v3282 and v3282[v3280]

	if v3283 then
		Enums[v3283] = v3281
	end
end)
local v3282 = "Cardboard"
local v3283 = 1640
pcall(function()
	local v3284 = enum[v]
	local v3285 = v3284 and v3284[v3282]

	if v3285 then
		Enums[v3285] = v3283
	end
end)
local v3284 = "Carpet"
local v3285 = 1641
pcall(function()
	local v3286 = enum[v]
	local v3287 = v3286 and v3286[v3284]

	if v3287 then
		Enums[v3287] = v3285
	end
end)
local v3286 = "CeramicTiles"
local v3287 = 1642
pcall(function()
	local v3288 = enum[v]
	local v3289 = v3288 and v3288[v3286]

	if v3289 then
		Enums[v3289] = v3287
	end
end)
local v3288 = "ClayRoofTiles"
local v3289 = 1643
pcall(function()
	local v3290 = enum[v]
	local v3291 = v3290 and v3290[v3288]

	if v3291 then
		Enums[v3291] = v3289
	end
end)
local v3290 = "RoofShingles"
local v3291 = 1644
pcall(function()
	local v3292 = enum[v]
	local v3293 = v3292 and v3292[v3290]

	if v3293 then
		Enums[v3293] = v3291
	end
end)
local v3292 = "Leather"
local v3293 = 1645
pcall(function()
	local v3294 = enum[v]
	local v3295 = v3294 and v3294[v3292]

	if v3295 then
		Enums[v3295] = v3293
	end
end)
local v3294 = "Plaster"
local v3295 = 1646
pcall(function()
	local v3296 = enum[v]
	local v3297 = v3296 and v3296[v3294]

	if v3297 then
		Enums[v3297] = v3295
	end
end)
local v3296 = "Rubber"
local v3297 = 1647
pcall(function()
	local v3298 = enum[v]
	local v3299 = v3298 and v3298[v3296]

	if v3299 then
		Enums[v3299] = v3297
	end
end)
v = "MaterialPattern"
local v3298 = "Regular"
local v3299 = 1648
pcall(function()
	local v3300 = enum[v]
	local v3301 = v3300 and v3300[v3298]

	if v3301 then
		Enums[v3301] = v3299
	end
end)
local v3300 = "Organic"
local v3301 = 1649
pcall(function()
	local v3302 = enum[v]
	local v3303 = v3302 and v3302[v3300]

	if v3303 then
		Enums[v3303] = v3301
	end
end)
v = "MembershipType"
local v3302 = "None"
local v3303 = 1650
pcall(function()
	local v3304 = enum[v]
	local v3305 = v3304 and v3304[v3302]

	if v3305 then
		Enums[v3305] = v3303
	end
end)
local v3304 = "BuildersClub"
local v3305 = 1651
pcall(function()
	local v3306 = enum[v]
	local v3307 = v3306 and v3306[v3304]

	if v3307 then
		Enums[v3307] = v3305
	end
end)
local v3306 = "TurboBuildersClub"
local v3307 = 1652
pcall(function()
	local v3308 = enum[v]
	local v3309 = v3308 and v3308[v3306]

	if v3309 then
		Enums[v3309] = v3307
	end
end)
local v3308 = "OutrageousBuildersClub"
local v3309 = 1653
pcall(function()
	local v3310 = enum[v]
	local v3311 = v3310 and v3310[v3308]

	if v3311 then
		Enums[v3311] = v3309
	end
end)
local v3310 = "Premium"
local v3311 = 1654
pcall(function()
	local v3312 = enum[v]
	local v3313 = v3312 and v3312[v3310]

	if v3313 then
		Enums[v3313] = v3311
	end
end)
v = "MeshPartDetailLevel"
local v3312 = "DistanceBased"
local v3313 = 1655
pcall(function()
	local v3314 = enum[v]
	local v3315 = v3314 and v3314[v3312]

	if v3315 then
		Enums[v3315] = v3313
	end
end)
local v3314 = "Level00"
local v3315 = 1656
pcall(function()
	local v3316 = enum[v]
	local v3317 = v3316 and v3316[v3314]

	if v3317 then
		Enums[v3317] = v3315
	end
end)
local v3316 = "Level01"
local v3317 = 1657
pcall(function()
	local v3318 = enum[v]
	local v3319 = v3318 and v3318[v3316]

	if v3319 then
		Enums[v3319] = v3317
	end
end)
local v3318 = "Level02"
local v3319 = 1658
pcall(function()
	local v3320 = enum[v]
	local v3321 = v3320 and v3320[v3318]

	if v3321 then
		Enums[v3321] = v3319
	end
end)
local v3320 = "Level03"
local v3321 = 1659
pcall(function()
	local v3322 = enum[v]
	local v3323 = v3322 and v3322[v3320]

	if v3323 then
		Enums[v3323] = v3321
	end
end)
local v3322 = "Level04"
local v3323 = 1660
pcall(function()
	local v3324 = enum[v]
	local v3325 = v3324 and v3324[v3322]

	if v3325 then
		Enums[v3325] = v3323
	end
end)
v = "MeshPartHeadsAndAccessories"
local v3324 = "Default"
local v3325 = 1661
pcall(function()
	local v3326 = enum[v]
	local v3327 = v3326 and v3326[v3324]

	if v3327 then
		Enums[v3327] = v3325
	end
end)
local v3326 = "Disabled"
local v3327 = 1662
pcall(function()
	local v3328 = enum[v]
	local v3329 = v3328 and v3328[v3326]

	if v3329 then
		Enums[v3329] = v3327
	end
end)
local v3328 = "Enabled"
local v3329 = 1663
pcall(function()
	local v3330 = enum[v]
	local v3331 = v3330 and v3330[v3328]

	if v3331 then
		Enums[v3331] = v3329
	end
end)
v = "MeshScaleUnit"
local v3330 = "Stud"
local v3331 = 1664
pcall(function()
	local v3332 = enum[v]
	local v3333 = v3332 and v3332[v3330]

	if v3333 then
		Enums[v3333] = v3331
	end
end)
local v3332 = "Meter"
local v3333 = 1665
pcall(function()
	local v3334 = enum[v]
	local v3335 = v3334 and v3334[v3332]

	if v3335 then
		Enums[v3335] = v3333
	end
end)
local v3334 = "CM"
local v3335 = 1666
pcall(function()
	local v3336 = enum[v]
	local v3337 = v3336 and v3336[v3334]

	if v3337 then
		Enums[v3337] = v3335
	end
end)
local v3336 = "MM"
local v3337 = 1667
pcall(function()
	local v3338 = enum[v]
	local v3339 = v3338 and v3338[v3336]

	if v3339 then
		Enums[v3339] = v3337
	end
end)
local v3338 = "Foot"
local v3339 = 1668
pcall(function()
	local v3340 = enum[v]
	local v3341 = v3340 and v3340[v3338]

	if v3341 then
		Enums[v3341] = v3339
	end
end)
local v3340 = "Inch"
local v3341 = 1669
pcall(function()
	local v3342 = enum[v]
	local v3343 = v3342 and v3342[v3340]

	if v3343 then
		Enums[v3343] = v3341
	end
end)
v = "MeshType"
local v3342 = "Head"
local v3343 = 1670
pcall(function()
	local v3344 = enum[v]
	local v3345 = v3344 and v3344[v3342]

	if v3345 then
		Enums[v3345] = v3343
	end
end)
local v3344 = "Torso"
local v3345 = 1671
pcall(function()
	local v3346 = enum[v]
	local v3347 = v3346 and v3346[v3344]

	if v3347 then
		Enums[v3347] = v3345
	end
end)
local v3346 = "Wedge"
local v3347 = 1672
pcall(function()
	local v3348 = enum[v]
	local v3349 = v3348 and v3348[v3346]

	if v3349 then
		Enums[v3349] = v3347
	end
end)
local v3348 = "Sphere"
local v3349 = 1673
pcall(function()
	local v3350 = enum[v]
	local v3351 = v3350 and v3350[v3348]

	if v3351 then
		Enums[v3351] = v3349
	end
end)
local v3350 = "Cylinder"
local v3351 = 1674
pcall(function()
	local v3352 = enum[v]
	local v3353 = v3352 and v3352[v3350]

	if v3353 then
		Enums[v3353] = v3351
	end
end)
local v3352 = "FileMesh"
local v3353 = 1675
pcall(function()
	local v3354 = enum[v]
	local v3355 = v3354 and v3354[v3352]

	if v3355 then
		Enums[v3355] = v3353
	end
end)
local v3354 = "Brick"
local v3355 = 1676
pcall(function()
	local v3356 = enum[v]
	local v3357 = v3356 and v3356[v3354]

	if v3357 then
		Enums[v3357] = v3355
	end
end)
local v3356 = "Prism"
local v3357 = 1677
pcall(function()
	local v3358 = enum[v]
	local v3359 = v3358 and v3358[v3356]

	if v3359 then
		Enums[v3359] = v3357
	end
end)
local v3358 = "Pyramid"
local v3359 = 1678
pcall(function()
	local v3360 = enum[v]
	local v3361 = v3360 and v3360[v3358]

	if v3361 then
		Enums[v3361] = v3359
	end
end)
local v3360 = "ParallelRamp"
local v3361 = 1679
pcall(function()
	local v3362 = enum[v]
	local v3363 = v3362 and v3362[v3360]

	if v3363 then
		Enums[v3363] = v3361
	end
end)
local v3362 = "RightAngleRamp"
local v3363 = 1680
pcall(function()
	local v3364 = enum[v]
	local v3365 = v3364 and v3364[v3362]

	if v3365 then
		Enums[v3365] = v3363
	end
end)
local v3364 = "CornerWedge"
local v3365 = 1681
pcall(function()
	local v3366 = enum[v]
	local v3367 = v3366 and v3366[v3364]

	if v3367 then
		Enums[v3367] = v3365
	end
end)
v = "MessageType"
local v3366 = "MessageOutput"
local v3367 = 1682
pcall(function()
	local v3368 = enum[v]
	local v3369 = v3368 and v3368[v3366]

	if v3369 then
		Enums[v3369] = v3367
	end
end)
local v3368 = "MessageInfo"
local v3369 = 1683
pcall(function()
	local v3370 = enum[v]
	local v3371 = v3370 and v3370[v3368]

	if v3371 then
		Enums[v3371] = v3369
	end
end)
local v3370 = "MessageWarning"
local v3371 = 1684
pcall(function()
	local v3372 = enum[v]
	local v3373 = v3372 and v3372[v3370]

	if v3373 then
		Enums[v3373] = v3371
	end
end)
local v3372 = "MessageError"
local v3373 = 1685
pcall(function()
	local v3374 = enum[v]
	local v3375 = v3374 and v3374[v3372]

	if v3375 then
		Enums[v3375] = v3373
	end
end)
v = "ModelLevelOfDetail"
local v3374 = "Automatic"
local v3375 = 1686
pcall(function()
	local v3376 = enum[v]
	local v3377 = v3376 and v3376[v3374]

	if v3377 then
		Enums[v3377] = v3375
	end
end)
local v3376 = "StreamingMesh"
local v3377 = 1687
pcall(function()
	local v3378 = enum[v]
	local v3379 = v3378 and v3378[v3376]

	if v3379 then
		Enums[v3379] = v3377
	end
end)
local v3378 = "Disabled"
local v3379 = 1688
pcall(function()
	local v3380 = enum[v]
	local v3381 = v3380 and v3380[v3378]

	if v3381 then
		Enums[v3381] = v3379
	end
end)
v = "ModelStreamingBehavior"
local v3380 = "Default"
local v3381 = 1689
pcall(function()
	local v3382 = enum[v]
	local v3383 = v3382 and v3382[v3380]

	if v3383 then
		Enums[v3383] = v3381
	end
end)
local v3382 = "Legacy"
local v3383 = 1690
pcall(function()
	local v3384 = enum[v]
	local v3385 = v3384 and v3384[v3382]

	if v3385 then
		Enums[v3385] = v3383
	end
end)
local v3384 = "Improved"
local v3385 = 1691
pcall(function()
	local v3386 = enum[v]
	local v3387 = v3386 and v3386[v3384]

	if v3387 then
		Enums[v3387] = v3385
	end
end)
v = "ModelStreamingMode"
local v3386 = "Default"
local v3387 = 1692
pcall(function()
	local v3388 = enum[v]
	local v3389 = v3388 and v3388[v3386]

	if v3389 then
		Enums[v3389] = v3387
	end
end)
local v3388 = "Atomic"
local v3389 = 1693
pcall(function()
	local v3390 = enum[v]
	local v3391 = v3390 and v3390[v3388]

	if v3391 then
		Enums[v3391] = v3389
	end
end)
local v3390 = "Persistent"
local v3391 = 1694
pcall(function()
	local v3392 = enum[v]
	local v3393 = v3392 and v3392[v3390]

	if v3393 then
		Enums[v3393] = v3391
	end
end)
local v3392 = "PersistentPerPlayer"
local v3393 = 1695
pcall(function()
	local v3394 = enum[v]
	local v3395 = v3394 and v3394[v3392]

	if v3395 then
		Enums[v3395] = v3393
	end
end)
local v3394 = "Nonatomic"
local v3395 = 1696
pcall(function()
	local v3396 = enum[v]
	local v3397 = v3396 and v3396[v3394]

	if v3397 then
		Enums[v3397] = v3395
	end
end)
v = "ModerationStatus"
local v3396 = "ReviewedApproved"
local v3397 = 1697
pcall(function()
	local v3398 = enum[v]
	local v3399 = v3398 and v3398[v3396]

	if v3399 then
		Enums[v3399] = v3397
	end
end)
local v3398 = "ReviewedRejected"
local v3399 = 1698
pcall(function()
	local v3400 = enum[v]
	local v3401 = v3400 and v3400[v3398]

	if v3401 then
		Enums[v3401] = v3399
	end
end)
local v3400 = "NotReviewed"
local v3401 = 1699
pcall(function()
	local v3402 = enum[v]
	local v3403 = v3402 and v3402[v3400]

	if v3403 then
		Enums[v3403] = v3401
	end
end)
local v3402 = "NotApplicable"
local v3403 = 1700
pcall(function()
	local v3404 = enum[v]
	local v3405 = v3404 and v3404[v3402]

	if v3405 then
		Enums[v3405] = v3403
	end
end)
local v3404 = "Invalid"
local v3405 = 1701
pcall(function()
	local v3406 = enum[v]
	local v3407 = v3406 and v3406[v3404]

	if v3407 then
		Enums[v3407] = v3405
	end
end)
v = "ModifierKey"
local v3406 = "Shift"
local v3407 = 1702
pcall(function()
	local v3408 = enum[v]
	local v3409 = v3408 and v3408[v3406]

	if v3409 then
		Enums[v3409] = v3407
	end
end)
local v3408 = "Ctrl"
local v3409 = 1703
pcall(function()
	local v3410 = enum[v]
	local v3411 = v3410 and v3410[v3408]

	if v3411 then
		Enums[v3411] = v3409
	end
end)
local v3410 = "Alt"
local v3411 = 1704
pcall(function()
	local v3412 = enum[v]
	local v3413 = v3412 and v3412[v3410]

	if v3413 then
		Enums[v3413] = v3411
	end
end)
local v3412 = "Meta"
local v3413 = 1705
pcall(function()
	local v3414 = enum[v]
	local v3415 = v3414 and v3414[v3412]

	if v3415 then
		Enums[v3415] = v3413
	end
end)
v = "MouseBehavior"
local v3414 = "Default"
local v3415 = 1706
pcall(function()
	local v3416 = enum[v]
	local v3417 = v3416 and v3416[v3414]

	if v3417 then
		Enums[v3417] = v3415
	end
end)
local v3416 = "LockCenter"
local v3417 = 1707
pcall(function()
	local v3418 = enum[v]
	local v3419 = v3418 and v3418[v3416]

	if v3419 then
		Enums[v3419] = v3417
	end
end)
local v3418 = "LockCurrentPosition"
local v3419 = 1708
pcall(function()
	local v3420 = enum[v]
	local v3421 = v3420 and v3420[v3418]

	if v3421 then
		Enums[v3421] = v3419
	end
end)
v = "MoveState"
local v3420 = "Stopped"
local v3421 = 1709
pcall(function()
	local v3422 = enum[v]
	local v3423 = v3422 and v3422[v3420]

	if v3423 then
		Enums[v3423] = v3421
	end
end)
local v3422 = "Coasting"
local v3423 = 1710
pcall(function()
	local v3424 = enum[v]
	local v3425 = v3424 and v3424[v3422]

	if v3425 then
		Enums[v3425] = v3423
	end
end)
local v3424 = "Pushing"
local v3425 = 1711
pcall(function()
	local v3426 = enum[v]
	local v3427 = v3426 and v3426[v3424]

	if v3427 then
		Enums[v3427] = v3425
	end
end)
local v3426 = "Stopping"
local v3427 = 1712
pcall(function()
	local v3428 = enum[v]
	local v3429 = v3428 and v3428[v3426]

	if v3429 then
		Enums[v3429] = v3427
	end
end)
local v3428 = "AirFree"
local v3429 = 1713
pcall(function()
	local v3430 = enum[v]
	local v3431 = v3430 and v3430[v3428]

	if v3431 then
		Enums[v3431] = v3429
	end
end)
v = "MoverConstraintRootBehaviorMode"
local v3430 = "Default"
local v3431 = 1714
pcall(function()
	local v3432 = enum[v]
	local v3433 = v3432 and v3432[v3430]

	if v3433 then
		Enums[v3433] = v3431
	end
end)
local v3432 = "Disabled"
local v3433 = 1715
pcall(function()
	local v3434 = enum[v]
	local v3435 = v3434 and v3434[v3432]

	if v3435 then
		Enums[v3435] = v3433
	end
end)
local v3434 = "Enabled"
local v3435 = 1716
pcall(function()
	local v3436 = enum[v]
	local v3437 = v3436 and v3436[v3434]

	if v3437 then
		Enums[v3437] = v3435
	end
end)
v = "MuteState"
local v3436 = "Unmuted"
local v3437 = 1717
pcall(function()
	local v3438 = enum[v]
	local v3439 = v3438 and v3438[v3436]

	if v3439 then
		Enums[v3439] = v3437
	end
end)
local v3438 = "Muted"
local v3439 = 1718
pcall(function()
	local v3440 = enum[v]
	local v3441 = v3440 and v3440[v3438]

	if v3441 then
		Enums[v3441] = v3439
	end
end)
v = "NameOcclusion"
local v3440 = "NoOcclusion"
local v3441 = 1719
pcall(function()
	local v3442 = enum[v]
	local v3443 = v3442 and v3442[v3440]

	if v3443 then
		Enums[v3443] = v3441
	end
end)
local v3442 = "EnemyOcclusion"
local v3443 = 1720
pcall(function()
	local v3444 = enum[v]
	local v3445 = v3444 and v3444[v3442]

	if v3445 then
		Enums[v3445] = v3443
	end
end)
local v3444 = "OccludeAll"
local v3445 = 1721
pcall(function()
	local v3446 = enum[v]
	local v3447 = v3446 and v3446[v3444]

	if v3447 then
		Enums[v3447] = v3445
	end
end)
v = "NetworkOwnership"
local v3446 = "Automatic"
local v3447 = 1722
pcall(function()
	local v3448 = enum[v]
	local v3449 = v3448 and v3448[v3446]

	if v3449 then
		Enums[v3449] = v3447
	end
end)
local v3448 = "Manual"
local v3449 = 1723
pcall(function()
	local v3450 = enum[v]
	local v3451 = v3450 and v3450[v3448]

	if v3451 then
		Enums[v3451] = v3449
	end
end)
local v3450 = "OnContact"
local v3451 = 1724
pcall(function()
	local v3452 = enum[v]
	local v3453 = v3452 and v3452[v3450]

	if v3453 then
		Enums[v3453] = v3451
	end
end)
v = "NetworkStatus"
local v3452 = "Unknown"
local v3453 = 1725
pcall(function()
	local v3454 = enum[v]
	local v3455 = v3454 and v3454[v3452]

	if v3455 then
		Enums[v3455] = v3453
	end
end)
local v3454 = "Connected"
local v3455 = 1726
pcall(function()
	local v3456 = enum[v]
	local v3457 = v3456 and v3456[v3454]

	if v3457 then
		Enums[v3457] = v3455
	end
end)
local v3456 = "Disconnected"
local v3457 = 1727
pcall(function()
	local v3458 = enum[v]
	local v3459 = v3458 and v3458[v3456]

	if v3459 then
		Enums[v3459] = v3457
	end
end)
v = "NoiseType"
local v3458 = "SimplexGabor"
local v3459 = 1728
pcall(function()
	local v3460 = enum[v]
	local v3461 = v3460 and v3460[v3458]

	if v3461 then
		Enums[v3461] = v3459
	end
end)
v = "NormalId"
local v3460 = "Right"
local v3461 = 1729
pcall(function()
	local v3462 = enum[v]
	local v3463 = v3462 and v3462[v3460]

	if v3463 then
		Enums[v3463] = v3461
	end
end)
local v3462 = "Top"
local v3463 = 1730
pcall(function()
	local v3464 = enum[v]
	local v3465 = v3464 and v3464[v3462]

	if v3465 then
		Enums[v3465] = v3463
	end
end)
local v3464 = "Back"
local v3465 = 1731
pcall(function()
	local v3466 = enum[v]
	local v3467 = v3466 and v3466[v3464]

	if v3467 then
		Enums[v3467] = v3465
	end
end)
local v3466 = "Left"
local v3467 = 1732
pcall(function()
	local v3468 = enum[v]
	local v3469 = v3468 and v3468[v3466]

	if v3469 then
		Enums[v3469] = v3467
	end
end)
local v3468 = "Bottom"
local v3469 = 1733
pcall(function()
	local v3470 = enum[v]
	local v3471 = v3470 and v3470[v3468]

	if v3471 then
		Enums[v3471] = v3469
	end
end)
local v3470 = "Front"
local v3471 = 1734
pcall(function()
	local v3472 = enum[v]
	local v3473 = v3472 and v3472[v3470]

	if v3473 then
		Enums[v3473] = v3471
	end
end)
v = "NotificationButtonType"
local v3472 = "Primary"
local v3473 = 1735
pcall(function()
	local v3474 = enum[v]
	local v3475 = v3474 and v3474[v3472]

	if v3475 then
		Enums[v3475] = v3473
	end
end)
local v3474 = "Secondary"
local v3475 = 1736
pcall(function()
	local v3476 = enum[v]
	local v3477 = v3476 and v3476[v3474]

	if v3477 then
		Enums[v3477] = v3475
	end
end)
v = "OperationType"
local v3476 = "Null"
local v3477 = 1737
pcall(function()
	local v3478 = enum[v]
	local v3479 = v3478 and v3478[v3476]

	if v3479 then
		Enums[v3479] = v3477
	end
end)
local v3478 = "Union"
local v3479 = 1738
pcall(function()
	local v3480 = enum[v]
	local v3481 = v3480 and v3480[v3478]

	if v3481 then
		Enums[v3481] = v3479
	end
end)
local v3480 = "Subtraction"
local v3481 = 1739
pcall(function()
	local v3482 = enum[v]
	local v3483 = v3482 and v3482[v3480]

	if v3483 then
		Enums[v3483] = v3481
	end
end)
local v3482 = "Intersection"
local v3483 = 1740
pcall(function()
	local v3484 = enum[v]
	local v3485 = v3484 and v3484[v3482]

	if v3485 then
		Enums[v3485] = v3483
	end
end)
local v3484 = "Primitive"
local v3485 = 1741
pcall(function()
	local v3486 = enum[v]
	local v3487 = v3486 and v3486[v3484]

	if v3487 then
		Enums[v3487] = v3485
	end
end)
v = "OrientationAlignmentMode"
local v3486 = "OneAttachment"
local v3487 = 1742
pcall(function()
	local v3488 = enum[v]
	local v3489 = v3488 and v3488[v3486]

	if v3489 then
		Enums[v3489] = v3487
	end
end)
local v3488 = "TwoAttachment"
local v3489 = 1743
pcall(function()
	local v3490 = enum[v]
	local v3491 = v3490 and v3490[v3488]

	if v3491 then
		Enums[v3491] = v3489
	end
end)
v = "OutfitSource"
local v3490 = "All"
local v3491 = 1744
pcall(function()
	local v3492 = enum[v]
	local v3493 = v3492 and v3492[v3490]

	if v3493 then
		Enums[v3493] = v3491
	end
end)
local v3492 = "Created"
local v3493 = 1745
pcall(function()
	local v3494 = enum[v]
	local v3495 = v3494 and v3494[v3492]

	if v3495 then
		Enums[v3495] = v3493
	end
end)
local v3494 = "Purchased"
local v3495 = 1746
pcall(function()
	local v3496 = enum[v]
	local v3497 = v3496 and v3496[v3494]

	if v3497 then
		Enums[v3497] = v3495
	end
end)
v = "OutfitType"
local v3496 = "All"
local v3497 = 1747
pcall(function()
	local v3498 = enum[v]
	local v3499 = v3498 and v3498[v3496]

	if v3499 then
		Enums[v3499] = v3497
	end
end)
local v3498 = "Avatar"
local v3499 = 1748
pcall(function()
	local v3500 = enum[v]
	local v3501 = v3500 and v3500[v3498]

	if v3501 then
		Enums[v3501] = v3499
	end
end)
local v3500 = "DynamicHead"
local v3501 = 1749
pcall(function()
	local v3502 = enum[v]
	local v3503 = v3502 and v3502[v3500]

	if v3503 then
		Enums[v3503] = v3501
	end
end)
v = "OutputLayoutMode"
local v3502 = "Horizontal"
local v3503 = 1750
pcall(function()
	local v3504 = enum[v]
	local v3505 = v3504 and v3504[v3502]

	if v3505 then
		Enums[v3505] = v3503
	end
end)
local v3504 = "Vertical"
local v3505 = 1751
pcall(function()
	local v3506 = enum[v]
	local v3507 = v3506 and v3506[v3504]

	if v3507 then
		Enums[v3507] = v3505
	end
end)
v = "OverrideMouseIconBehavior"
local v3506 = "None"
local v3507 = 1752
pcall(function()
	local v3508 = enum[v]
	local v3509 = v3508 and v3508[v3506]

	if v3509 then
		Enums[v3509] = v3507
	end
end)
local v3508 = "ForceShow"
local v3509 = 1753
pcall(function()
	local v3510 = enum[v]
	local v3511 = v3510 and v3510[v3508]

	if v3511 then
		Enums[v3511] = v3509
	end
end)
local v3510 = "ForceHide"
local v3511 = 1754
pcall(function()
	local v3512 = enum[v]
	local v3513 = v3512 and v3512[v3510]

	if v3513 then
		Enums[v3513] = v3511
	end
end)
v = "PackagePermission"
local v3512 = "None"
local v3513 = 1755
pcall(function()
	local v3514 = enum[v]
	local v3515 = v3514 and v3514[v3512]

	if v3515 then
		Enums[v3515] = v3513
	end
end)
local v3514 = "NoAccess"
local v3515 = 1756
pcall(function()
	local v3516 = enum[v]
	local v3517 = v3516 and v3516[v3514]

	if v3517 then
		Enums[v3517] = v3515
	end
end)
local v3516 = "Revoked"
local v3517 = 1757
pcall(function()
	local v3518 = enum[v]
	local v3519 = v3518 and v3518[v3516]

	if v3519 then
		Enums[v3519] = v3517
	end
end)
local v3518 = "UseView"
local v3519 = 1758
pcall(function()
	local v3520 = enum[v]
	local v3521 = v3520 and v3520[v3518]

	if v3521 then
		Enums[v3521] = v3519
	end
end)
local v3520 = "Edit"
local v3521 = 1759
pcall(function()
	local v3522 = enum[v]
	local v3523 = v3522 and v3522[v3520]

	if v3523 then
		Enums[v3523] = v3521
	end
end)
local v3522 = "Own"
local v3523 = 1760
pcall(function()
	local v3524 = enum[v]
	local v3525 = v3524 and v3524[v3522]

	if v3525 then
		Enums[v3525] = v3523
	end
end)
v = "PartType"
local v3524 = "Ball"
local v3525 = 1761
pcall(function()
	local v3526 = enum[v]
	local v3527 = v3526 and v3526[v3524]

	if v3527 then
		Enums[v3527] = v3525
	end
end)
local v3526 = "Block"
local v3527 = 1762
pcall(function()
	local v3528 = enum[v]
	local v3529 = v3528 and v3528[v3526]

	if v3529 then
		Enums[v3529] = v3527
	end
end)
local v3528 = "Cylinder"
local v3529 = 1763
pcall(function()
	local v3530 = enum[v]
	local v3531 = v3530 and v3530[v3528]

	if v3531 then
		Enums[v3531] = v3529
	end
end)
local v3530 = "Wedge"
local v3531 = 1764
pcall(function()
	local v3532 = enum[v]
	local v3533 = v3532 and v3532[v3530]

	if v3533 then
		Enums[v3533] = v3531
	end
end)
local v3532 = "CornerWedge"
local v3533 = 1765
pcall(function()
	local v3534 = enum[v]
	local v3535 = v3534 and v3534[v3532]

	if v3535 then
		Enums[v3535] = v3533
	end
end)
v = "ParticleEmitterShape"
local v3534 = "Box"
local v3535 = 1766
pcall(function()
	local v3536 = enum[v]
	local v3537 = v3536 and v3536[v3534]

	if v3537 then
		Enums[v3537] = v3535
	end
end)
local v3536 = "Sphere"
local v3537 = 1767
pcall(function()
	local v3538 = enum[v]
	local v3539 = v3538 and v3538[v3536]

	if v3539 then
		Enums[v3539] = v3537
	end
end)
local v3538 = "Cylinder"
local v3539 = 1768
pcall(function()
	local v3540 = enum[v]
	local v3541 = v3540 and v3540[v3538]

	if v3541 then
		Enums[v3541] = v3539
	end
end)
local v3540 = "Disc"
local v3541 = 1769
pcall(function()
	local v3542 = enum[v]
	local v3543 = v3542 and v3542[v3540]

	if v3543 then
		Enums[v3543] = v3541
	end
end)
v = "ParticleEmitterShapeInOut"
local v3542 = "Outward"
local v3543 = 1770
pcall(function()
	local v3544 = enum[v]
	local v3545 = v3544 and v3544[v3542]

	if v3545 then
		Enums[v3545] = v3543
	end
end)
local v3544 = "Inward"
local v3545 = 1771
pcall(function()
	local v3546 = enum[v]
	local v3547 = v3546 and v3546[v3544]

	if v3547 then
		Enums[v3547] = v3545
	end
end)
local v3546 = "InAndOut"
local v3547 = 1772
pcall(function()
	local v3548 = enum[v]
	local v3549 = v3548 and v3548[v3546]

	if v3549 then
		Enums[v3549] = v3547
	end
end)
v = "ParticleEmitterShapeStyle"
local v3548 = "Volume"
local v3549 = 1773
pcall(function()
	local v3550 = enum[v]
	local v3551 = v3550 and v3550[v3548]

	if v3551 then
		Enums[v3551] = v3549
	end
end)
local v3550 = "Surface"
local v3551 = 1774
pcall(function()
	local v3552 = enum[v]
	local v3553 = v3552 and v3552[v3550]

	if v3553 then
		Enums[v3553] = v3551
	end
end)
v = "ParticleFlipbookLayout_"
local v3552 = "None"
local v3553 = 1775
pcall(function()
	local v3554 = enum[v]
	local v3555 = v3554 and v3554[v3552]

	if v3555 then
		Enums[v3555] = v3553
	end
end)
local v3554 = "Grid2x2"
local v3555 = 1776
pcall(function()
	local v3556 = enum[v]
	local v3557 = v3556 and v3556[v3554]

	if v3557 then
		Enums[v3557] = v3555
	end
end)
local v3556 = "Grid4x4"
local v3557 = 1777
pcall(function()
	local v3558 = enum[v]
	local v3559 = v3558 and v3558[v3556]

	if v3559 then
		Enums[v3559] = v3557
	end
end)
local v3558 = "Grid8x8"
local v3559 = 1778
pcall(function()
	local v3560 = enum[v]
	local v3561 = v3560 and v3560[v3558]

	if v3561 then
		Enums[v3561] = v3559
	end
end)
v = "ParticleFlipbookMode"
local v3560 = "Loop"
local v3561 = 1779
pcall(function()
	local v3562 = enum[v]
	local v3563 = v3562 and v3562[v3560]

	if v3563 then
		Enums[v3563] = v3561
	end
end)
local v3562 = "OneShot"
local v3563 = 1780
pcall(function()
	local v3564 = enum[v]
	local v3565 = v3564 and v3564[v3562]

	if v3565 then
		Enums[v3565] = v3563
	end
end)
local v3564 = "PingPong"
local v3565 = 1781
pcall(function()
	local v3566 = enum[v]
	local v3567 = v3566 and v3566[v3564]

	if v3567 then
		Enums[v3567] = v3565
	end
end)
local v3566 = "Random"
local v3567 = 1782
pcall(function()
	local v3568 = enum[v]
	local v3569 = v3568 and v3568[v3566]

	if v3569 then
		Enums[v3569] = v3567
	end
end)
v = "ParticleFlipbookTextureCompatible"
local v3568 = "NotCompatible"
local v3569 = 1783
pcall(function()
	local v3570 = enum[v]
	local v3571 = v3570 and v3570[v3568]

	if v3571 then
		Enums[v3571] = v3569
	end
end)
local v3570 = "Compatible"
local v3571 = 1784
pcall(function()
	local v3572 = enum[v]
	local v3573 = v3572 and v3572[v3570]

	if v3573 then
		Enums[v3573] = v3571
	end
end)
local v3572 = "Unknown"
local v3573 = 1785
pcall(function()
	local v3574 = enum[v]
	local v3575 = v3574 and v3574[v3572]

	if v3575 then
		Enums[v3575] = v3573
	end
end)
v = "ParticleOrientation"
local v3574 = "FacingCamera"
local v3575 = 1786
pcall(function()
	local v3576 = enum[v]
	local v3577 = v3576 and v3576[v3574]

	if v3577 then
		Enums[v3577] = v3575
	end
end)
local v3576 = "FacingCameraWorldUp"
local v3577 = 1787
pcall(function()
	local v3578 = enum[v]
	local v3579 = v3578 and v3578[v3576]

	if v3579 then
		Enums[v3579] = v3577
	end
end)
local v3578 = "VelocityParallel"
local v3579 = 1788
pcall(function()
	local v3580 = enum[v]
	local v3581 = v3580 and v3580[v3578]

	if v3581 then
		Enums[v3581] = v3579
	end
end)
local v3580 = "VelocityPerpendicular"
local v3581 = 1789
pcall(function()
	local v3582 = enum[v]
	local v3583 = v3582 and v3582[v3580]

	if v3583 then
		Enums[v3583] = v3581
	end
end)
v = "PathStatus"
local v3582 = "Success"
local v3583 = 1790
pcall(function()
	local v3584 = enum[v]
	local v3585 = v3584 and v3584[v3582]

	if v3585 then
		Enums[v3585] = v3583
	end
end)
local v3584 = "NoPath"
local v3585 = 1791
pcall(function()
	local v3586 = enum[v]
	local v3587 = v3586 and v3586[v3584]

	if v3587 then
		Enums[v3587] = v3585
	end
end)
local v3586 = "ClosestNoPath"
local v3587 = 1792
pcall(function()
	local v3588 = enum[v]
	local v3589 = v3588 and v3588[v3586]

	if v3589 then
		Enums[v3589] = v3587
	end
end)
local v3588 = "ClosestOutOfRange"
local v3589 = 1793
pcall(function()
	local v3590 = enum[v]
	local v3591 = v3590 and v3590[v3588]

	if v3591 then
		Enums[v3591] = v3589
	end
end)
local v3590 = "FailStartNotEmpty"
local v3591 = 1794
pcall(function()
	local v3592 = enum[v]
	local v3593 = v3592 and v3592[v3590]

	if v3593 then
		Enums[v3593] = v3591
	end
end)
local v3592 = "FailFinishNotEmpty"
local v3593 = 1795
pcall(function()
	local v3594 = enum[v]
	local v3595 = v3594 and v3594[v3592]

	if v3595 then
		Enums[v3595] = v3593
	end
end)
v = "PathWaypointAction"
local v3594 = "Walk"
local v3595 = 1796
pcall(function()
	local v3596 = enum[v]
	local v3597 = v3596 and v3596[v3594]

	if v3597 then
		Enums[v3597] = v3595
	end
end)
local v3596 = "Jump"
local v3597 = 1797
pcall(function()
	local v3598 = enum[v]
	local v3599 = v3598 and v3598[v3596]

	if v3599 then
		Enums[v3599] = v3597
	end
end)
local v3598 = "Custom"
local v3599 = 1798
pcall(function()
	local v3600 = enum[v]
	local v3601 = v3600 and v3600[v3598]

	if v3601 then
		Enums[v3601] = v3599
	end
end)
v = "PathfindingUseImprovedSearch"
local v3600 = "Default"
local v3601 = 1799
pcall(function()
	local v3602 = enum[v]
	local v3603 = v3602 and v3602[v3600]

	if v3603 then
		Enums[v3603] = v3601
	end
end)
local v3602 = "Disabled"
local v3603 = 1800
pcall(function()
	local v3604 = enum[v]
	local v3605 = v3604 and v3604[v3602]

	if v3605 then
		Enums[v3605] = v3603
	end
end)
local v3604 = "Enabled"
local v3605 = 1801
pcall(function()
	local v3606 = enum[v]
	local v3607 = v3606 and v3606[v3604]

	if v3607 then
		Enums[v3607] = v3605
	end
end)
v = "PermissionLevelShown"
local v3606 = "Game"
local v3607 = 1802
pcall(function()
	local v3608 = enum[v]
	local v3609 = v3608 and v3608[v3606]

	if v3609 then
		Enums[v3609] = v3607
	end
end)
local v3608 = "RobloxGame"
local v3609 = 1803
pcall(function()
	local v3610 = enum[v]
	local v3611 = v3610 and v3610[v3608]

	if v3611 then
		Enums[v3611] = v3609
	end
end)
local v3610 = "RobloxScript"
local v3611 = 1804
pcall(function()
	local v3612 = enum[v]
	local v3613 = v3612 and v3612[v3610]

	if v3613 then
		Enums[v3613] = v3611
	end
end)
local v3612 = "Studio"
local v3613 = 1805
pcall(function()
	local v3614 = enum[v]
	local v3615 = v3614 and v3614[v3612]

	if v3615 then
		Enums[v3615] = v3613
	end
end)
local v3614 = "Roblox"
local v3615 = 1806
pcall(function()
	local v3616 = enum[v]
	local v3617 = v3616 and v3616[v3614]

	if v3617 then
		Enums[v3617] = v3615
	end
end)
v = "PhysicsSimulationRate"
local v3616 = "Fixed240Hz"
local v3617 = 1807
pcall(function()
	local v3618 = enum[v]
	local v3619 = v3618 and v3618[v3616]

	if v3619 then
		Enums[v3619] = v3617
	end
end)
local v3618 = "Fixed120Hz"
local v3619 = 1808
pcall(function()
	local v3620 = enum[v]
	local v3621 = v3620 and v3620[v3618]

	if v3621 then
		Enums[v3621] = v3619
	end
end)
local v3620 = "Fixed60Hz"
local v3621 = 1809
pcall(function()
	local v3622 = enum[v]
	local v3623 = v3622 and v3622[v3620]

	if v3623 then
		Enums[v3623] = v3621
	end
end)
v = "PhysicsSteppingMethod"
local v3622 = "Default"
local v3623 = 1810
pcall(function()
	local v3624 = enum[v]
	local v3625 = v3624 and v3624[v3622]

	if v3625 then
		Enums[v3625] = v3623
	end
end)
local v3624 = "Fixed"
local v3625 = 1811
pcall(function()
	local v3626 = enum[v]
	local v3627 = v3626 and v3626[v3624]

	if v3627 then
		Enums[v3627] = v3625
	end
end)
local v3626 = "Adaptive"
local v3627 = 1812
pcall(function()
	local v3628 = enum[v]
	local v3629 = v3628 and v3628[v3626]

	if v3629 then
		Enums[v3629] = v3627
	end
end)
v = "Platform"
local v3628 = "Windows"
local v3629 = 1813
pcall(function()
	local v3630 = enum[v]
	local v3631 = v3630 and v3630[v3628]

	if v3631 then
		Enums[v3631] = v3629
	end
end)
local v3630 = "OSX"
local v3631 = 1814
pcall(function()
	local v3632 = enum[v]
	local v3633 = v3632 and v3632[v3630]

	if v3633 then
		Enums[v3633] = v3631
	end
end)
local v3632 = "IOS"
local v3633 = 1815
pcall(function()
	local v3634 = enum[v]
	local v3635 = v3634 and v3634[v3632]

	if v3635 then
		Enums[v3635] = v3633
	end
end)
local v3634 = "Android"
local v3635 = 1816
pcall(function()
	local v3636 = enum[v]
	local v3637 = v3636 and v3636[v3634]

	if v3637 then
		Enums[v3637] = v3635
	end
end)
local v3636 = "XBoxOne"
local v3637 = 1817
pcall(function()
	local v3638 = enum[v]
	local v3639 = v3638 and v3638[v3636]

	if v3639 then
		Enums[v3639] = v3637
	end
end)
local v3638 = "PS4"
local v3639 = 1818
pcall(function()
	local v3640 = enum[v]
	local v3641 = v3640 and v3640[v3638]

	if v3641 then
		Enums[v3641] = v3639
	end
end)
local v3640 = "PS3"
local v3641 = 1819
pcall(function()
	local v3642 = enum[v]
	local v3643 = v3642 and v3642[v3640]

	if v3643 then
		Enums[v3643] = v3641
	end
end)
local v3642 = "XBox360"
local v3643 = 1820
pcall(function()
	local v3644 = enum[v]
	local v3645 = v3644 and v3644[v3642]

	if v3645 then
		Enums[v3645] = v3643
	end
end)
local v3644 = "WiiU"
local v3645 = 1821
pcall(function()
	local v3646 = enum[v]
	local v3647 = v3646 and v3646[v3644]

	if v3647 then
		Enums[v3647] = v3645
	end
end)
local v3646 = "NX"
local v3647 = 1822
pcall(function()
	local v3648 = enum[v]
	local v3649 = v3648 and v3648[v3646]

	if v3649 then
		Enums[v3649] = v3647
	end
end)
local v3648 = "Ouya"
local v3649 = 1823
pcall(function()
	local v3650 = enum[v]
	local v3651 = v3650 and v3650[v3648]

	if v3651 then
		Enums[v3651] = v3649
	end
end)
local v3650 = "AndroidTV"
local v3651 = 1824
pcall(function()
	local v3652 = enum[v]
	local v3653 = v3652 and v3652[v3650]

	if v3653 then
		Enums[v3653] = v3651
	end
end)
local v3652 = "Chromecast"
local v3653 = 1825
pcall(function()
	local v3654 = enum[v]
	local v3655 = v3654 and v3654[v3652]

	if v3655 then
		Enums[v3655] = v3653
	end
end)
local v3654 = "Linux"
local v3655 = 1826
pcall(function()
	local v3656 = enum[v]
	local v3657 = v3656 and v3656[v3654]

	if v3657 then
		Enums[v3657] = v3655
	end
end)
local v3656 = "SteamOS"
local v3657 = 1827
pcall(function()
	local v3658 = enum[v]
	local v3659 = v3658 and v3658[v3656]

	if v3659 then
		Enums[v3659] = v3657
	end
end)
local v3658 = "WebOS"
local v3659 = 1828
pcall(function()
	local v3660 = enum[v]
	local v3661 = v3660 and v3660[v3658]

	if v3661 then
		Enums[v3661] = v3659
	end
end)
local v3660 = "DOS"
local v3661 = 1829
pcall(function()
	local v3662 = enum[v]
	local v3663 = v3662 and v3662[v3660]

	if v3663 then
		Enums[v3663] = v3661
	end
end)
local v3662 = "BeOS"
local v3663 = 1830
pcall(function()
	local v3664 = enum[v]
	local v3665 = v3664 and v3664[v3662]

	if v3665 then
		Enums[v3665] = v3663
	end
end)
local v3664 = "UWP"
local v3665 = 1831
pcall(function()
	local v3666 = enum[v]
	local v3667 = v3666 and v3666[v3664]

	if v3667 then
		Enums[v3667] = v3665
	end
end)
local v3666 = "PS5"
local v3667 = 1832
pcall(function()
	local v3668 = enum[v]
	local v3669 = v3668 and v3668[v3666]

	if v3669 then
		Enums[v3669] = v3667
	end
end)
local v3668 = "MetaOS"
local v3669 = 1833
pcall(function()
	local v3670 = enum[v]
	local v3671 = v3670 and v3670[v3668]

	if v3671 then
		Enums[v3671] = v3669
	end
end)
local v3670 = "None"
local v3671 = 1834
pcall(function()
	local v3672 = enum[v]
	local v3673 = v3672 and v3672[v3670]

	if v3673 then
		Enums[v3673] = v3671
	end
end)
v = "PlaybackState"
local v3672 = "Begin"
local v3673 = 1835
pcall(function()
	local v3674 = enum[v]
	local v3675 = v3674 and v3674[v3672]

	if v3675 then
		Enums[v3675] = v3673
	end
end)
local v3674 = "Delayed"
local v3675 = 1836
pcall(function()
	local v3676 = enum[v]
	local v3677 = v3676 and v3676[v3674]

	if v3677 then
		Enums[v3677] = v3675
	end
end)
local v3676 = "Playing"
local v3677 = 1837
pcall(function()
	local v3678 = enum[v]
	local v3679 = v3678 and v3678[v3676]

	if v3679 then
		Enums[v3679] = v3677
	end
end)
local v3678 = "Paused"
local v3679 = 1838
pcall(function()
	local v3680 = enum[v]
	local v3681 = v3680 and v3680[v3678]

	if v3681 then
		Enums[v3681] = v3679
	end
end)
local v3680 = "Completed"
local v3681 = 1839
pcall(function()
	local v3682 = enum[v]
	local v3683 = v3682 and v3682[v3680]

	if v3683 then
		Enums[v3683] = v3681
	end
end)
local v3682 = "Cancelled"
local v3683 = 1840
pcall(function()
	local v3684 = enum[v]
	local v3685 = v3684 and v3684[v3682]

	if v3685 then
		Enums[v3685] = v3683
	end
end)
v = "PlayerActions"
local v3684 = "CharacterForward"
local v3685 = 1841
pcall(function()
	local v3686 = enum[v]
	local v3687 = v3686 and v3686[v3684]

	if v3687 then
		Enums[v3687] = v3685
	end
end)
local v3686 = "CharacterBackward"
local v3687 = 1842
pcall(function()
	local v3688 = enum[v]
	local v3689 = v3688 and v3688[v3686]

	if v3689 then
		Enums[v3689] = v3687
	end
end)
local v3688 = "CharacterLeft"
local v3689 = 1843
pcall(function()
	local v3690 = enum[v]
	local v3691 = v3690 and v3690[v3688]

	if v3691 then
		Enums[v3691] = v3689
	end
end)
local v3690 = "CharacterRight"
local v3691 = 1844
pcall(function()
	local v3692 = enum[v]
	local v3693 = v3692 and v3692[v3690]

	if v3693 then
		Enums[v3693] = v3691
	end
end)
local v3692 = "CharacterJump"
local v3693 = 1845
pcall(function()
	local v3694 = enum[v]
	local v3695 = v3694 and v3694[v3692]

	if v3695 then
		Enums[v3695] = v3693
	end
end)
v = "PlayerCharacterDestroyBehavior"
local v3694 = "Default"
local v3695 = 1846
pcall(function()
	local v3696 = enum[v]
	local v3697 = v3696 and v3696[v3694]

	if v3697 then
		Enums[v3697] = v3695
	end
end)
local v3696 = "Disabled"
local v3697 = 1847
pcall(function()
	local v3698 = enum[v]
	local v3699 = v3698 and v3698[v3696]

	if v3699 then
		Enums[v3699] = v3697
	end
end)
local v3698 = "Enabled"
local v3699 = 1848
pcall(function()
	local v3700 = enum[v]
	local v3701 = v3700 and v3700[v3698]

	if v3701 then
		Enums[v3701] = v3699
	end
end)
v = "PlayerChatType"
local v3700 = "All"
local v3701 = 1849
pcall(function()
	local v3702 = enum[v]
	local v3703 = v3702 and v3702[v3700]

	if v3703 then
		Enums[v3703] = v3701
	end
end)
local v3702 = "Team"
local v3703 = 1850
pcall(function()
	local v3704 = enum[v]
	local v3705 = v3704 and v3704[v3702]

	if v3705 then
		Enums[v3705] = v3703
	end
end)
local v3704 = "Whisper"
local v3705 = 1851
pcall(function()
	local v3706 = enum[v]
	local v3707 = v3706 and v3706[v3704]

	if v3707 then
		Enums[v3707] = v3705
	end
end)
v = "PlayerDataErrorState"
local v3706 = "LoadFailed"
local v3707 = 1852
pcall(function()
	local v3708 = enum[v]
	local v3709 = v3708 and v3708[v3706]

	if v3709 then
		Enums[v3709] = v3707
	end
end)
local v3708 = "FlushFailed"
local v3709 = 1853
pcall(function()
	local v3710 = enum[v]
	local v3711 = v3710 and v3710[v3708]

	if v3711 then
		Enums[v3711] = v3709
	end
end)
local v3710 = "ReleaseFailed"
local v3711 = 1854
pcall(function()
	local v3712 = enum[v]
	local v3713 = v3712 and v3712[v3710]

	if v3713 then
		Enums[v3713] = v3711
	end
end)
local v3712 = "None"
local v3713 = 1855
pcall(function()
	local v3714 = enum[v]
	local v3715 = v3714 and v3714[v3712]

	if v3715 then
		Enums[v3715] = v3713
	end
end)
v = "PlayerDataLoadFailureBehavior"
local v3714 = "Failure"
local v3715 = 1856
pcall(function()
	local v3716 = enum[v]
	local v3717 = v3716 and v3716[v3714]

	if v3717 then
		Enums[v3717] = v3715
	end
end)
local v3716 = "FallbackToDefault"
local v3717 = 1857
pcall(function()
	local v3718 = enum[v]
	local v3719 = v3718 and v3718[v3716]

	if v3719 then
		Enums[v3719] = v3717
	end
end)
local v3718 = "Kick"
local v3719 = 1858
pcall(function()
	local v3720 = enum[v]
	local v3721 = v3720 and v3720[v3718]

	if v3721 then
		Enums[v3721] = v3719
	end
end)
v = "PoseEasingDirection"
local v3720 = "In"
local v3721 = 1859
pcall(function()
	local v3722 = enum[v]
	local v3723 = v3722 and v3722[v3720]

	if v3723 then
		Enums[v3723] = v3721
	end
end)
local v3722 = "Out"
local v3723 = 1860
pcall(function()
	local v3724 = enum[v]
	local v3725 = v3724 and v3724[v3722]

	if v3725 then
		Enums[v3725] = v3723
	end
end)
local v3724 = "InOut"
local v3725 = 1861
pcall(function()
	local v3726 = enum[v]
	local v3727 = v3726 and v3726[v3724]

	if v3727 then
		Enums[v3727] = v3725
	end
end)
v = "PoseEasingStyle"
local v3726 = "Linear"
local v3727 = 1862
pcall(function()
	local v3728 = enum[v]
	local v3729 = v3728 and v3728[v3726]

	if v3729 then
		Enums[v3729] = v3727
	end
end)
local v3728 = "Constant"
local v3729 = 1863
pcall(function()
	local v3730 = enum[v]
	local v3731 = v3730 and v3730[v3728]

	if v3731 then
		Enums[v3731] = v3729
	end
end)
local v3730 = "Elastic"
local v3731 = 1864
pcall(function()
	local v3732 = enum[v]
	local v3733 = v3732 and v3732[v3730]

	if v3733 then
		Enums[v3733] = v3731
	end
end)
local v3732 = "Cubic"
local v3733 = 1865
pcall(function()
	local v3734 = enum[v]
	local v3735 = v3734 and v3734[v3732]

	if v3735 then
		Enums[v3735] = v3733
	end
end)
local v3734 = "Bounce"
local v3735 = 1866
pcall(function()
	local v3736 = enum[v]
	local v3737 = v3736 and v3736[v3734]

	if v3737 then
		Enums[v3737] = v3735
	end
end)
local v3736 = "CubicV2"
local v3737 = 1867
pcall(function()
	local v3738 = enum[v]
	local v3739 = v3738 and v3738[v3736]

	if v3739 then
		Enums[v3739] = v3737
	end
end)
v = "PositionAlignmentMode"
local v3738 = "OneAttachment"
local v3739 = 1868
pcall(function()
	local v3740 = enum[v]
	local v3741 = v3740 and v3740[v3738]

	if v3741 then
		Enums[v3741] = v3739
	end
end)
local v3740 = "TwoAttachment"
local v3741 = 1869
pcall(function()
	local v3742 = enum[v]
	local v3743 = v3742 and v3742[v3740]

	if v3743 then
		Enums[v3743] = v3741
	end
end)
v = "PreferredTextSize"
local v3742 = "Medium"
local v3743 = 1870
pcall(function()
	local v3744 = enum[v]
	local v3745 = v3744 and v3744[v3742]

	if v3745 then
		Enums[v3745] = v3743
	end
end)
local v3744 = "Large"
local v3745 = 1871
pcall(function()
	local v3746 = enum[v]
	local v3747 = v3746 and v3746[v3744]

	if v3747 then
		Enums[v3747] = v3745
	end
end)
local v3746 = "Larger"
local v3747 = 1872
pcall(function()
	local v3748 = enum[v]
	local v3749 = v3748 and v3748[v3746]

	if v3749 then
		Enums[v3749] = v3747
	end
end)
local v3748 = "Largest"
local v3749 = 1873
pcall(function()
	local v3750 = enum[v]
	local v3751 = v3750 and v3750[v3748]

	if v3751 then
		Enums[v3751] = v3749
	end
end)
v = "PrimalPhysicsSolver"
local v3750 = "Default"
local v3751 = 1874
pcall(function()
	local v3752 = enum[v]
	local v3753 = v3752 and v3752[v3750]

	if v3753 then
		Enums[v3753] = v3751
	end
end)
local v3752 = "Experimental"
local v3753 = 1875
pcall(function()
	local v3754 = enum[v]
	local v3755 = v3754 and v3754[v3752]

	if v3755 then
		Enums[v3755] = v3753
	end
end)
local v3754 = "Disabled"
local v3755 = 1876
pcall(function()
	local v3756 = enum[v]
	local v3757 = v3756 and v3756[v3754]

	if v3757 then
		Enums[v3757] = v3755
	end
end)
v = "PrimitiveType"
local v3756 = "Null"
local v3757 = 1877
pcall(function()
	local v3758 = enum[v]
	local v3759 = v3758 and v3758[v3756]

	if v3759 then
		Enums[v3759] = v3757
	end
end)
local v3758 = "Ball"
local v3759 = 1878
pcall(function()
	local v3760 = enum[v]
	local v3761 = v3760 and v3760[v3758]

	if v3761 then
		Enums[v3761] = v3759
	end
end)
local v3760 = "Cylinder"
local v3761 = 1879
pcall(function()
	local v3762 = enum[v]
	local v3763 = v3762 and v3762[v3760]

	if v3763 then
		Enums[v3763] = v3761
	end
end)
local v3762 = "Block"
local v3763 = 1880
pcall(function()
	local v3764 = enum[v]
	local v3765 = v3764 and v3764[v3762]

	if v3765 then
		Enums[v3765] = v3763
	end
end)
local v3764 = "Wedge"
local v3765 = 1881
pcall(function()
	local v3766 = enum[v]
	local v3767 = v3766 and v3766[v3764]

	if v3767 then
		Enums[v3767] = v3765
	end
end)
local v3766 = "CornerWedge"
local v3767 = 1882
pcall(function()
	local v3768 = enum[v]
	local v3769 = v3768 and v3768[v3766]

	if v3769 then
		Enums[v3769] = v3767
	end
end)
v = "PrivilegeType"
local v3768 = "Owner"
local v3769 = 1883
pcall(function()
	local v3770 = enum[v]
	local v3771 = v3770 and v3770[v3768]

	if v3771 then
		Enums[v3771] = v3769
	end
end)
local v3770 = "Admin"
local v3771 = 1884
pcall(function()
	local v3772 = enum[v]
	local v3773 = v3772 and v3772[v3770]

	if v3773 then
		Enums[v3773] = v3771
	end
end)
local v3772 = "Member"
local v3773 = 1885
pcall(function()
	local v3774 = enum[v]
	local v3775 = v3774 and v3774[v3772]

	if v3775 then
		Enums[v3775] = v3773
	end
end)
local v3774 = "Visitor"
local v3775 = 1886
pcall(function()
	local v3776 = enum[v]
	local v3777 = v3776 and v3776[v3774]

	if v3777 then
		Enums[v3777] = v3775
	end
end)
local v3776 = "Banned"
local v3777 = 1887
pcall(function()
	local v3778 = enum[v]
	local v3779 = v3778 and v3778[v3776]

	if v3779 then
		Enums[v3779] = v3777
	end
end)
v = "ProductLocationRestriction"
local v3778 = "AvatarShop"
local v3779 = 1888
pcall(function()
	local v3780 = enum[v]
	local v3781 = v3780 and v3780[v3778]

	if v3781 then
		Enums[v3781] = v3779
	end
end)
local v3780 = "AllowedGames"
local v3781 = 1889
pcall(function()
	local v3782 = enum[v]
	local v3783 = v3782 and v3782[v3780]

	if v3783 then
		Enums[v3783] = v3781
	end
end)
local v3782 = "AllGames"
local v3783 = 1890
pcall(function()
	local v3784 = enum[v]
	local v3785 = v3784 and v3784[v3782]

	if v3785 then
		Enums[v3785] = v3783
	end
end)
v = "ProductPurchaseChannel"
local v3784 = "InExperience"
local v3785 = 1891
pcall(function()
	local v3786 = enum[v]
	local v3787 = v3786 and v3786[v3784]

	if v3787 then
		Enums[v3787] = v3785
	end
end)
local v3786 = "ExperienceDetailsPage"
local v3787 = 1892
pcall(function()
	local v3788 = enum[v]
	local v3789 = v3788 and v3788[v3786]

	if v3789 then
		Enums[v3789] = v3787
	end
end)
local v3788 = "AdReward"
local v3789 = 1893
pcall(function()
	local v3790 = enum[v]
	local v3791 = v3790 and v3790[v3788]

	if v3791 then
		Enums[v3791] = v3789
	end
end)
local v3790 = "CommerceProduct"
local v3791 = 1894
pcall(function()
	local v3792 = enum[v]
	local v3793 = v3792 and v3792[v3790]

	if v3793 then
		Enums[v3793] = v3791
	end
end)
v = "ProductPurchaseDecision"
local v3792 = "NotProcessedYet"
local v3793 = 1895
pcall(function()
	local v3794 = enum[v]
	local v3795 = v3794 and v3794[v3792]

	if v3795 then
		Enums[v3795] = v3793
	end
end)
local v3794 = "PurchaseGranted"
local v3795 = 1896
pcall(function()
	local v3796 = enum[v]
	local v3797 = v3796 and v3796[v3794]

	if v3797 then
		Enums[v3797] = v3795
	end
end)
v = "PromptCreateAssetResult"
local v3796 = "Success"
local v3797 = 1897
pcall(function()
	local v3798 = enum[v]
	local v3799 = v3798 and v3798[v3796]

	if v3799 then
		Enums[v3799] = v3797
	end
end)
local v3798 = "PermissionDenied"
local v3799 = 1898
pcall(function()
	local v3800 = enum[v]
	local v3801 = v3800 and v3800[v3798]

	if v3801 then
		Enums[v3801] = v3799
	end
end)
local v3800 = "Timeout"
local v3801 = 1899
pcall(function()
	local v3802 = enum[v]
	local v3803 = v3802 and v3802[v3800]

	if v3803 then
		Enums[v3803] = v3801
	end
end)
local v3802 = "UploadFailed"
local v3803 = 1900
pcall(function()
	local v3804 = enum[v]
	local v3805 = v3804 and v3804[v3802]

	if v3805 then
		Enums[v3805] = v3803
	end
end)
local v3804 = "NoUserInput"
local v3805 = 1901
pcall(function()
	local v3806 = enum[v]
	local v3807 = v3806 and v3806[v3804]

	if v3807 then
		Enums[v3807] = v3805
	end
end)
local v3806 = "UnknownFailure"
local v3807 = 1902
pcall(function()
	local v3808 = enum[v]
	local v3809 = v3808 and v3808[v3806]

	if v3809 then
		Enums[v3809] = v3807
	end
end)
v = "PromptCreateAvatarResult"
local v3808 = "Success"
local v3809 = 1903
pcall(function()
	local v3810 = enum[v]
	local v3811 = v3810 and v3810[v3808]

	if v3811 then
		Enums[v3811] = v3809
	end
end)
local v3810 = "PermissionDenied"
local v3811 = 1904
pcall(function()
	local v3812 = enum[v]
	local v3813 = v3812 and v3812[v3810]

	if v3813 then
		Enums[v3813] = v3811
	end
end)
local v3812 = "Timeout"
local v3813 = 1905
pcall(function()
	local v3814 = enum[v]
	local v3815 = v3814 and v3814[v3812]

	if v3815 then
		Enums[v3815] = v3813
	end
end)
local v3814 = "UploadFailed"
local v3815 = 1906
pcall(function()
	local v3816 = enum[v]
	local v3817 = v3816 and v3816[v3814]

	if v3817 then
		Enums[v3817] = v3815
	end
end)
local v3816 = "NoUserInput"
local v3817 = 1907
pcall(function()
	local v3818 = enum[v]
	local v3819 = v3818 and v3818[v3816]

	if v3819 then
		Enums[v3819] = v3817
	end
end)
local v3818 = "InvalidHumanoidDescription"
local v3819 = 1908
pcall(function()
	local v3820 = enum[v]
	local v3821 = v3820 and v3820[v3818]

	if v3821 then
		Enums[v3821] = v3819
	end
end)
local v3820 = "UGCValidationFailed"
local v3821 = 1909
pcall(function()
	local v3822 = enum[v]
	local v3823 = v3822 and v3822[v3820]

	if v3823 then
		Enums[v3823] = v3821
	end
end)
local v3822 = "ModeratedName"
local v3823 = 1910
pcall(function()
	local v3824 = enum[v]
	local v3825 = v3824 and v3824[v3822]

	if v3825 then
		Enums[v3825] = v3823
	end
end)
local v3824 = "MaxOutfits"
local v3825 = 1911
pcall(function()
	local v3826 = enum[v]
	local v3827 = v3826 and v3826[v3824]

	if v3827 then
		Enums[v3827] = v3825
	end
end)
local v3826 = "PurchaseFailure"
local v3827 = 1912
pcall(function()
	local v3828 = enum[v]
	local v3829 = v3828 and v3828[v3826]

	if v3829 then
		Enums[v3829] = v3827
	end
end)
local v3828 = "UnknownFailure"
local v3829 = 1913
pcall(function()
	local v3830 = enum[v]
	local v3831 = v3830 and v3830[v3828]

	if v3831 then
		Enums[v3831] = v3829
	end
end)
local v3830 = "TokenInvalid"
local v3831 = 1914
pcall(function()
	local v3832 = enum[v]
	local v3833 = v3832 and v3832[v3830]

	if v3833 then
		Enums[v3833] = v3831
	end
end)
v = "PromptPublishAssetResult"
local v3832 = "Success"
local v3833 = 1915
pcall(function()
	local v3834 = enum[v]
	local v3835 = v3834 and v3834[v3832]

	if v3835 then
		Enums[v3835] = v3833
	end
end)
local v3834 = "PermissionDenied"
local v3835 = 1916
pcall(function()
	local v3836 = enum[v]
	local v3837 = v3836 and v3836[v3834]

	if v3837 then
		Enums[v3837] = v3835
	end
end)
local v3836 = "Timeout"
local v3837 = 1917
pcall(function()
	local v3838 = enum[v]
	local v3839 = v3838 and v3838[v3836]

	if v3839 then
		Enums[v3839] = v3837
	end
end)
local v3838 = "UploadFailed"
local v3839 = 1918
pcall(function()
	local v3840 = enum[v]
	local v3841 = v3840 and v3840[v3838]

	if v3841 then
		Enums[v3841] = v3839
	end
end)
local v3840 = "NoUserInput"
local v3841 = 1919
pcall(function()
	local v3842 = enum[v]
	local v3843 = v3842 and v3842[v3840]

	if v3843 then
		Enums[v3843] = v3841
	end
end)
local v3842 = "UnknownFailure"
local v3843 = 1920
pcall(function()
	local v3844 = enum[v]
	local v3845 = v3844 and v3844[v3842]

	if v3845 then
		Enums[v3845] = v3843
	end
end)
v = "PropertyStatus"
local v3844 = "Ok"
local v3845 = 1921
pcall(function()
	local v3846 = enum[v]
	local v3847 = v3846 and v3846[v3844]

	if v3847 then
		Enums[v3847] = v3845
	end
end)
local v3846 = "Warning"
local v3847 = 1922
pcall(function()
	local v3848 = enum[v]
	local v3849 = v3848 and v3848[v3846]

	if v3849 then
		Enums[v3849] = v3847
	end
end)
local v3848 = "Error"
local v3849 = 1923
pcall(function()
	local v3850 = enum[v]
	local v3851 = v3850 and v3850[v3848]

	if v3851 then
		Enums[v3851] = v3849
	end
end)
v = "ProximityPromptExclusivity"
local v3850 = "OnePerButton"
local v3851 = 1924
pcall(function()
	local v3852 = enum[v]
	local v3853 = v3852 and v3852[v3850]

	if v3853 then
		Enums[v3853] = v3851
	end
end)
local v3852 = "OneGlobally"
local v3853 = 1925
pcall(function()
	local v3854 = enum[v]
	local v3855 = v3854 and v3854[v3852]

	if v3855 then
		Enums[v3855] = v3853
	end
end)
local v3854 = "AlwaysShow"
local v3855 = 1926
pcall(function()
	local v3856 = enum[v]
	local v3857 = v3856 and v3856[v3854]

	if v3857 then
		Enums[v3857] = v3855
	end
end)
v = "ProximityPromptInputType"
local v3856 = "Keyboard"
local v3857 = 1927
pcall(function()
	local v3858 = enum[v]
	local v3859 = v3858 and v3858[v3856]

	if v3859 then
		Enums[v3859] = v3857
	end
end)
local v3858 = "Gamepad"
local v3859 = 1928
pcall(function()
	local v3860 = enum[v]
	local v3861 = v3860 and v3860[v3858]

	if v3861 then
		Enums[v3861] = v3859
	end
end)
local v3860 = "Touch"
local v3861 = 1929
pcall(function()
	local v3862 = enum[v]
	local v3863 = v3862 and v3862[v3860]

	if v3863 then
		Enums[v3863] = v3861
	end
end)
v = "ProximityPromptStyle"
local v3862 = "Default"
local v3863 = 1930
pcall(function()
	local v3864 = enum[v]
	local v3865 = v3864 and v3864[v3862]

	if v3865 then
		Enums[v3865] = v3863
	end
end)
local v3864 = "Custom"
local v3865 = 1931
pcall(function()
	local v3866 = enum[v]
	local v3867 = v3866 and v3866[v3864]

	if v3867 then
		Enums[v3867] = v3865
	end
end)
v = "QualityLevel"
local v3866 = "Automatic"
local v3867 = 1932
pcall(function()
	local v3868 = enum[v]
	local v3869 = v3868 and v3868[v3866]

	if v3869 then
		Enums[v3869] = v3867
	end
end)
local v3868 = "Level01"
local v3869 = 1933
pcall(function()
	local v3870 = enum[v]
	local v3871 = v3870 and v3870[v3868]

	if v3871 then
		Enums[v3871] = v3869
	end
end)
local v3870 = "Level02"
local v3871 = 1934
pcall(function()
	local v3872 = enum[v]
	local v3873 = v3872 and v3872[v3870]

	if v3873 then
		Enums[v3873] = v3871
	end
end)
local v3872 = "Level03"
local v3873 = 1935
pcall(function()
	local v3874 = enum[v]
	local v3875 = v3874 and v3874[v3872]

	if v3875 then
		Enums[v3875] = v3873
	end
end)
local v3874 = "Level04"
local v3875 = 1936
pcall(function()
	local v3876 = enum[v]
	local v3877 = v3876 and v3876[v3874]

	if v3877 then
		Enums[v3877] = v3875
	end
end)
local v3876 = "Level05"
local v3877 = 1937
pcall(function()
	local v3878 = enum[v]
	local v3879 = v3878 and v3878[v3876]

	if v3879 then
		Enums[v3879] = v3877
	end
end)
local v3878 = "Level06"
local v3879 = 1938
pcall(function()
	local v3880 = enum[v]
	local v3881 = v3880 and v3880[v3878]

	if v3881 then
		Enums[v3881] = v3879
	end
end)
local v3880 = "Level07"
local v3881 = 1939
pcall(function()
	local v3882 = enum[v]
	local v3883 = v3882 and v3882[v3880]

	if v3883 then
		Enums[v3883] = v3881
	end
end)
local v3882 = "Level08"
local v3883 = 1940
pcall(function()
	local v3884 = enum[v]
	local v3885 = v3884 and v3884[v3882]

	if v3885 then
		Enums[v3885] = v3883
	end
end)
local v3884 = "Level09"
local v3885 = 1941
pcall(function()
	local v3886 = enum[v]
	local v3887 = v3886 and v3886[v3884]

	if v3887 then
		Enums[v3887] = v3885
	end
end)
local v3886 = "Level10"
local v3887 = 1942
pcall(function()
	local v3888 = enum[v]
	local v3889 = v3888 and v3888[v3886]

	if v3889 then
		Enums[v3889] = v3887
	end
end)
local v3888 = "Level11"
local v3889 = 1943
pcall(function()
	local v3890 = enum[v]
	local v3891 = v3890 and v3890[v3888]

	if v3891 then
		Enums[v3891] = v3889
	end
end)
local v3890 = "Level12"
local v3891 = 1944
pcall(function()
	local v3892 = enum[v]
	local v3893 = v3892 and v3892[v3890]

	if v3893 then
		Enums[v3893] = v3891
	end
end)
local v3892 = "Level13"
local v3893 = 1945
pcall(function()
	local v3894 = enum[v]
	local v3895 = v3894 and v3894[v3892]

	if v3895 then
		Enums[v3895] = v3893
	end
end)
local v3894 = "Level14"
local v3895 = 1946
pcall(function()
	local v3896 = enum[v]
	local v3897 = v3896 and v3896[v3894]

	if v3897 then
		Enums[v3897] = v3895
	end
end)
local v3896 = "Level15"
local v3897 = 1947
pcall(function()
	local v3898 = enum[v]
	local v3899 = v3898 and v3898[v3896]

	if v3899 then
		Enums[v3899] = v3897
	end
end)
local v3898 = "Level16"
local v3899 = 1948
pcall(function()
	local v3900 = enum[v]
	local v3901 = v3900 and v3900[v3898]

	if v3901 then
		Enums[v3901] = v3899
	end
end)
local v3900 = "Level17"
local v3901 = 1949
pcall(function()
	local v3902 = enum[v]
	local v3903 = v3902 and v3902[v3900]

	if v3903 then
		Enums[v3903] = v3901
	end
end)
local v3902 = "Level18"
local v3903 = 1950
pcall(function()
	local v3904 = enum[v]
	local v3905 = v3904 and v3904[v3902]

	if v3905 then
		Enums[v3905] = v3903
	end
end)
local v3904 = "Level19"
local v3905 = 1951
pcall(function()
	local v3906 = enum[v]
	local v3907 = v3906 and v3906[v3904]

	if v3907 then
		Enums[v3907] = v3905
	end
end)
local v3906 = "Level20"
local v3907 = 1952
pcall(function()
	local v3908 = enum[v]
	local v3909 = v3908 and v3908[v3906]

	if v3909 then
		Enums[v3909] = v3907
	end
end)
local v3908 = "Level21"
local v3909 = 1953
pcall(function()
	local v3910 = enum[v]
	local v3911 = v3910 and v3910[v3908]

	if v3911 then
		Enums[v3911] = v3909
	end
end)
v = "R15CollisionType"
local v3910 = "OuterBox"
local v3911 = 1954
pcall(function()
	local v3912 = enum[v]
	local v3913 = v3912 and v3912[v3910]

	if v3913 then
		Enums[v3913] = v3911
	end
end)
local v3912 = "InnerBox"
local v3913 = 1955
pcall(function()
	local v3914 = enum[v]
	local v3915 = v3914 and v3914[v3912]

	if v3915 then
		Enums[v3915] = v3913
	end
end)
v = "RaycastFilterType"
local v3914 = "Exclude"
local v3915 = 1956
pcall(function()
	local v3916 = enum[v]
	local v3917 = v3916 and v3916[v3914]

	if v3917 then
		Enums[v3917] = v3915
	end
end)
local v3916 = "Include"
local v3917 = 1957
pcall(function()
	local v3918 = enum[v]
	local v3919 = v3918 and v3918[v3916]

	if v3919 then
		Enums[v3919] = v3917
	end
end)
v = "RejectCharacterDeletions"
local v3918 = "Default"
local v3919 = 1958
pcall(function()
	local v3920 = enum[v]
	local v3921 = v3920 and v3920[v3918]

	if v3921 then
		Enums[v3921] = v3919
	end
end)
local v3920 = "Disabled"
local v3921 = 1959
pcall(function()
	local v3922 = enum[v]
	local v3923 = v3922 and v3922[v3920]

	if v3923 then
		Enums[v3923] = v3921
	end
end)
local v3922 = "Enabled"
local v3923 = 1960
pcall(function()
	local v3924 = enum[v]
	local v3925 = v3924 and v3924[v3922]

	if v3925 then
		Enums[v3925] = v3923
	end
end)
v = "RenderFidelity"
local v3924 = "Automatic"
local v3925 = 1961
pcall(function()
	local v3926 = enum[v]
	local v3927 = v3926 and v3926[v3924]

	if v3927 then
		Enums[v3927] = v3925
	end
end)
local v3926 = "Precise"
local v3927 = 1962
pcall(function()
	local v3928 = enum[v]
	local v3929 = v3928 and v3928[v3926]

	if v3929 then
		Enums[v3929] = v3927
	end
end)
local v3928 = "Performance"
local v3929 = 1963
pcall(function()
	local v3930 = enum[v]
	local v3931 = v3930 and v3930[v3928]

	if v3931 then
		Enums[v3931] = v3929
	end
end)
v = "RenderPriority"
local v3930 = "First"
local v3931 = 1964
pcall(function()
	local v3932 = enum[v]
	local v3933 = v3932 and v3932[v3930]

	if v3933 then
		Enums[v3933] = v3931
	end
end)
local v3932 = "Input"
local v3933 = 1965
pcall(function()
	local v3934 = enum[v]
	local v3935 = v3934 and v3934[v3932]

	if v3935 then
		Enums[v3935] = v3933
	end
end)
local v3934 = "Camera"
local v3935 = 1966
pcall(function()
	local v3936 = enum[v]
	local v3937 = v3936 and v3936[v3934]

	if v3937 then
		Enums[v3937] = v3935
	end
end)
local v3936 = "Character"
local v3937 = 1967
pcall(function()
	local v3938 = enum[v]
	local v3939 = v3938 and v3938[v3936]

	if v3939 then
		Enums[v3939] = v3937
	end
end)
local v3938 = "Last"
local v3939 = 1968
pcall(function()
	local v3940 = enum[v]
	local v3941 = v3940 and v3940[v3938]

	if v3941 then
		Enums[v3941] = v3939
	end
end)
v = "RenderingCacheOptimizationMode"
local v3940 = "Default"
local v3941 = 1969
pcall(function()
	local v3942 = enum[v]
	local v3943 = v3942 and v3942[v3940]

	if v3943 then
		Enums[v3943] = v3941
	end
end)
local v3942 = "Disabled"
local v3943 = 1970
pcall(function()
	local v3944 = enum[v]
	local v3945 = v3944 and v3944[v3942]

	if v3945 then
		Enums[v3945] = v3943
	end
end)
local v3944 = "Enabled"
local v3945 = 1971
pcall(function()
	local v3946 = enum[v]
	local v3947 = v3946 and v3946[v3944]

	if v3947 then
		Enums[v3947] = v3945
	end
end)
v = "RenderingTestComparisonMethod"
local v3946 = "psnr"
local v3947 = 1972
pcall(function()
	local v3948 = enum[v]
	local v3949 = v3948 and v3948[v3946]

	if v3949 then
		Enums[v3949] = v3947
	end
end)
local v3948 = "diff"
local v3949 = 1973
pcall(function()
	local v3950 = enum[v]
	local v3951 = v3950 and v3950[v3948]

	if v3951 then
		Enums[v3951] = v3949
	end
end)
v = "ReplicateInstanceDestroySetting"
local v3950 = "Default"
local v3951 = 1974
pcall(function()
	local v3952 = enum[v]
	local v3953 = v3952 and v3952[v3950]

	if v3953 then
		Enums[v3953] = v3951
	end
end)
local v3952 = "Disabled"
local v3953 = 1975
pcall(function()
	local v3954 = enum[v]
	local v3955 = v3954 and v3954[v3952]

	if v3955 then
		Enums[v3955] = v3953
	end
end)
local v3954 = "Enabled"
local v3955 = 1976
pcall(function()
	local v3956 = enum[v]
	local v3957 = v3956 and v3956[v3954]

	if v3957 then
		Enums[v3957] = v3955
	end
end)
v = "ResamplerMode"
local v3956 = "Default"
local v3957 = 1977
pcall(function()
	local v3958 = enum[v]
	local v3959 = v3958 and v3958[v3956]

	if v3959 then
		Enums[v3959] = v3957
	end
end)
local v3958 = "Pixelated"
local v3959 = 1978
pcall(function()
	local v3960 = enum[v]
	local v3961 = v3960 and v3960[v3958]

	if v3961 then
		Enums[v3961] = v3959
	end
end)
v = "ReservedHighlightId"
local v3960 = "Standard"
local v3961 = 1979
pcall(function()
	local v3962 = enum[v]
	local v3963 = v3962 and v3962[v3960]

	if v3963 then
		Enums[v3963] = v3961
	end
end)
local v3962 = "Selection"
local v3963 = 1980
pcall(function()
	local v3964 = enum[v]
	local v3965 = v3964 and v3964[v3962]

	if v3965 then
		Enums[v3965] = v3963
	end
end)
local v3964 = "Hover"
local v3965 = 1981
pcall(function()
	local v3966 = enum[v]
	local v3967 = v3966 and v3966[v3964]

	if v3967 then
		Enums[v3967] = v3965
	end
end)
local v3966 = "Active"
local v3967 = 1982
pcall(function()
	local v3968 = enum[v]
	local v3969 = v3968 and v3968[v3966]

	if v3969 then
		Enums[v3969] = v3967
	end
end)
v = "RestPose"
local v3968 = "Default"
local v3969 = 1983
pcall(function()
	local v3970 = enum[v]
	local v3971 = v3970 and v3970[v3968]

	if v3971 then
		Enums[v3971] = v3969
	end
end)
local v3970 = "RotationsReset"
local v3971 = 1984
pcall(function()
	local v3972 = enum[v]
	local v3973 = v3972 and v3972[v3970]

	if v3973 then
		Enums[v3973] = v3971
	end
end)
local v3972 = "Custom"
local v3973 = 1985
pcall(function()
	local v3974 = enum[v]
	local v3975 = v3974 and v3974[v3972]

	if v3975 then
		Enums[v3975] = v3973
	end
end)
v = "ReturnKeyType"
local v3974 = "Default"
local v3975 = 1986
pcall(function()
	local v3976 = enum[v]
	local v3977 = v3976 and v3976[v3974]

	if v3977 then
		Enums[v3977] = v3975
	end
end)
local v3976 = "Done"
local v3977 = 1987
pcall(function()
	local v3978 = enum[v]
	local v3979 = v3978 and v3978[v3976]

	if v3979 then
		Enums[v3979] = v3977
	end
end)
local v3978 = "Go"
local v3979 = 1988
pcall(function()
	local v3980 = enum[v]
	local v3981 = v3980 and v3980[v3978]

	if v3981 then
		Enums[v3981] = v3979
	end
end)
local v3980 = "Next"
local v3981 = 1989
pcall(function()
	local v3982 = enum[v]
	local v3983 = v3982 and v3982[v3980]

	if v3983 then
		Enums[v3983] = v3981
	end
end)
local v3982 = "Search"
local v3983 = 1990
pcall(function()
	local v3984 = enum[v]
	local v3985 = v3984 and v3984[v3982]

	if v3985 then
		Enums[v3985] = v3983
	end
end)
local v3984 = "Send"
local v3985 = 1991
pcall(function()
	local v3986 = enum[v]
	local v3987 = v3986 and v3986[v3984]

	if v3987 then
		Enums[v3987] = v3985
	end
end)
v = "ReverbType"
local v3986 = "NoReverb"
local v3987 = 1992
pcall(function()
	local v3988 = enum[v]
	local v3989 = v3988 and v3988[v3986]

	if v3989 then
		Enums[v3989] = v3987
	end
end)
local v3988 = "GenericReverb"
local v3989 = 1993
pcall(function()
	local v3990 = enum[v]
	local v3991 = v3990 and v3990[v3988]

	if v3991 then
		Enums[v3991] = v3989
	end
end)
local v3990 = "PaddedCell"
local v3991 = 1994
pcall(function()
	local v3992 = enum[v]
	local v3993 = v3992 and v3992[v3990]

	if v3993 then
		Enums[v3993] = v3991
	end
end)
local v3992 = "Room"
local v3993 = 1995
pcall(function()
	local v3994 = enum[v]
	local v3995 = v3994 and v3994[v3992]

	if v3995 then
		Enums[v3995] = v3993
	end
end)
local v3994 = "Bathroom"
local v3995 = 1996
pcall(function()
	local v3996 = enum[v]
	local v3997 = v3996 and v3996[v3994]

	if v3997 then
		Enums[v3997] = v3995
	end
end)
local v3996 = "LivingRoom"
local v3997 = 1997
pcall(function()
	local v3998 = enum[v]
	local v3999 = v3998 and v3998[v3996]

	if v3999 then
		Enums[v3999] = v3997
	end
end)
local v3998 = "StoneRoom"
local v3999 = 1998
pcall(function()
	local v4000 = enum[v]
	local v4001 = v4000 and v4000[v3998]

	if v4001 then
		Enums[v4001] = v3999
	end
end)
local v4000 = "Auditorium"
local v4001 = 1999
pcall(function()
	local v4002 = enum[v]
	local v4003 = v4002 and v4002[v4000]

	if v4003 then
		Enums[v4003] = v4001
	end
end)
local v4002 = "ConcertHall"
local v4003 = 2000
pcall(function()
	local v4004 = enum[v]
	local v4005 = v4004 and v4004[v4002]

	if v4005 then
		Enums[v4005] = v4003
	end
end)
local v4004 = "Cave"
local v4005 = 2001
pcall(function()
	local v4006 = enum[v]
	local v4007 = v4006 and v4006[v4004]

	if v4007 then
		Enums[v4007] = v4005
	end
end)
local v4006 = "Arena"
local v4007 = 2002
pcall(function()
	local v4008 = enum[v]
	local v4009 = v4008 and v4008[v4006]

	if v4009 then
		Enums[v4009] = v4007
	end
end)
local v4008 = "Hangar"
local v4009 = 2003
pcall(function()
	local v4010 = enum[v]
	local v4011 = v4010 and v4010[v4008]

	if v4011 then
		Enums[v4011] = v4009
	end
end)
local v4010 = "CarpettedHallway"
local v4011 = 2004
pcall(function()
	local v4012 = enum[v]
	local v4013 = v4012 and v4012[v4010]

	if v4013 then
		Enums[v4013] = v4011
	end
end)
local v4012 = "Hallway"
local v4013 = 2005
pcall(function()
	local v4014 = enum[v]
	local v4015 = v4014 and v4014[v4012]

	if v4015 then
		Enums[v4015] = v4013
	end
end)
local v4014 = "StoneCorridor"
local v4015 = 2006
pcall(function()
	local v4016 = enum[v]
	local v4017 = v4016 and v4016[v4014]

	if v4017 then
		Enums[v4017] = v4015
	end
end)
local v4016 = "Alley"
local v4017 = 2007
pcall(function()
	local v4018 = enum[v]
	local v4019 = v4018 and v4018[v4016]

	if v4019 then
		Enums[v4019] = v4017
	end
end)
local v4018 = "Forest"
local v4019 = 2008
pcall(function()
	local v4020 = enum[v]
	local v4021 = v4020 and v4020[v4018]

	if v4021 then
		Enums[v4021] = v4019
	end
end)
local v4020 = "City"
local v4021 = 2009
pcall(function()
	local v4022 = enum[v]
	local v4023 = v4022 and v4022[v4020]

	if v4023 then
		Enums[v4023] = v4021
	end
end)
local v4022 = "Mountains"
local v4023 = 2010
pcall(function()
	local v4024 = enum[v]
	local v4025 = v4024 and v4024[v4022]

	if v4025 then
		Enums[v4025] = v4023
	end
end)
local v4024 = "Quarry"
local v4025 = 2011
pcall(function()
	local v4026 = enum[v]
	local v4027 = v4026 and v4026[v4024]

	if v4027 then
		Enums[v4027] = v4025
	end
end)
local v4026 = "Plain"
local v4027 = 2012
pcall(function()
	local v4028 = enum[v]
	local v4029 = v4028 and v4028[v4026]

	if v4029 then
		Enums[v4029] = v4027
	end
end)
local v4028 = "ParkingLot"
local v4029 = 2013
pcall(function()
	local v4030 = enum[v]
	local v4031 = v4030 and v4030[v4028]

	if v4031 then
		Enums[v4031] = v4029
	end
end)
local v4030 = "SewerPipe"
local v4031 = 2014
pcall(function()
	local v4032 = enum[v]
	local v4033 = v4032 and v4032[v4030]

	if v4033 then
		Enums[v4033] = v4031
	end
end)
local v4032 = "UnderWater"
local v4033 = 2015
pcall(function()
	local v4034 = enum[v]
	local v4035 = v4034 and v4034[v4032]

	if v4035 then
		Enums[v4035] = v4033
	end
end)
v = "RibbonTool"
local v4034 = "Select"
local v4035 = 2016
pcall(function()
	local v4036 = enum[v]
	local v4037 = v4036 and v4036[v4034]

	if v4037 then
		Enums[v4037] = v4035
	end
end)
local v4036 = "Scale"
local v4037 = 2017
pcall(function()
	local v4038 = enum[v]
	local v4039 = v4038 and v4038[v4036]

	if v4039 then
		Enums[v4039] = v4037
	end
end)
local v4038 = "Rotate"
local v4039 = 2018
pcall(function()
	local v4040 = enum[v]
	local v4041 = v4040 and v4040[v4038]

	if v4041 then
		Enums[v4041] = v4039
	end
end)
local v4040 = "Move"
local v4041 = 2019
pcall(function()
	local v4042 = enum[v]
	local v4043 = v4042 and v4042[v4040]

	if v4043 then
		Enums[v4043] = v4041
	end
end)
local v4042 = "Transform"
local v4043 = 2020
pcall(function()
	local v4044 = enum[v]
	local v4045 = v4044 and v4044[v4042]

	if v4045 then
		Enums[v4045] = v4043
	end
end)
local v4044 = "ColorPicker"
local v4045 = 2021
pcall(function()
	local v4046 = enum[v]
	local v4047 = v4046 and v4046[v4044]

	if v4047 then
		Enums[v4047] = v4045
	end
end)
local v4046 = "MaterialPicker"
local v4047 = 2022
pcall(function()
	local v4048 = enum[v]
	local v4049 = v4048 and v4048[v4046]

	if v4049 then
		Enums[v4049] = v4047
	end
end)
local v4048 = "Group"
local v4049 = 2023
pcall(function()
	local v4050 = enum[v]
	local v4051 = v4050 and v4050[v4048]

	if v4051 then
		Enums[v4051] = v4049
	end
end)
local v4050 = "Ungroup"
local v4051 = 2024
pcall(function()
	local v4052 = enum[v]
	local v4053 = v4052 and v4052[v4050]

	if v4053 then
		Enums[v4053] = v4051
	end
end)
local v4052 = "None"
local v4053 = 2025
pcall(function()
	local v4054 = enum[v]
	local v4055 = v4054 and v4054[v4052]

	if v4055 then
		Enums[v4055] = v4053
	end
end)
local v4054 = "PivotEditor"
local v4055 = 2026
pcall(function()
	local v4056 = enum[v]
	local v4057 = v4056 and v4056[v4054]

	if v4057 then
		Enums[v4057] = v4055
	end
end)
v = "RigScale"
local v4056 = "Default"
local v4057 = 2027
pcall(function()
	local v4058 = enum[v]
	local v4059 = v4058 and v4058[v4056]

	if v4059 then
		Enums[v4059] = v4057
	end
end)
local v4058 = "Rthro"
local v4059 = 2028
pcall(function()
	local v4060 = enum[v]
	local v4061 = v4060 and v4060[v4058]

	if v4061 then
		Enums[v4061] = v4059
	end
end)
local v4060 = "RthroNarrow"
local v4061 = 2029
pcall(function()
	local v4062 = enum[v]
	local v4063 = v4062 and v4062[v4060]

	if v4063 then
		Enums[v4063] = v4061
	end
end)
v = "RigType"
local v4062 = "R15"
local v4063 = 2030
pcall(function()
	local v4064 = enum[v]
	local v4065 = v4064 and v4064[v4062]

	if v4065 then
		Enums[v4065] = v4063
	end
end)
local v4064 = "Custom"
local v4065 = 2031
pcall(function()
	local v4066 = enum[v]
	local v4067 = v4066 and v4066[v4064]

	if v4067 then
		Enums[v4067] = v4065
	end
end)
local v4066 = "None"
local v4067 = 2032
pcall(function()
	local v4068 = enum[v]
	local v4069 = v4068 and v4068[v4066]

	if v4069 then
		Enums[v4069] = v4067
	end
end)
v = "RollOffMode"
local v4068 = "Inverse"
local v4069 = 2033
pcall(function()
	local v4070 = enum[v]
	local v4071 = v4070 and v4070[v4068]

	if v4071 then
		Enums[v4071] = v4069
	end
end)
local v4070 = "Linear"
local v4071 = 2034
pcall(function()
	local v4072 = enum[v]
	local v4073 = v4072 and v4072[v4070]

	if v4073 then
		Enums[v4073] = v4071
	end
end)
local v4072 = "LinearSquare"
local v4073 = 2035
pcall(function()
	local v4074 = enum[v]
	local v4075 = v4074 and v4074[v4072]

	if v4075 then
		Enums[v4075] = v4073
	end
end)
local v4074 = "InverseTapered"
local v4075 = 2036
pcall(function()
	local v4076 = enum[v]
	local v4077 = v4076 and v4076[v4074]

	if v4077 then
		Enums[v4077] = v4075
	end
end)
v = "RolloutState"
local v4076 = "Default"
local v4077 = 2037
pcall(function()
	local v4078 = enum[v]
	local v4079 = v4078 and v4078[v4076]

	if v4079 then
		Enums[v4079] = v4077
	end
end)
local v4078 = "Disabled"
local v4079 = 2038
pcall(function()
	local v4080 = enum[v]
	local v4081 = v4080 and v4080[v4078]

	if v4081 then
		Enums[v4081] = v4079
	end
end)
local v4080 = "Enabled"
local v4081 = 2039
pcall(function()
	local v4082 = enum[v]
	local v4083 = v4082 and v4082[v4080]

	if v4083 then
		Enums[v4083] = v4081
	end
end)
v = "RotationOrder"
local v4082 = "XYZ"
local v4083 = 2040
pcall(function()
	local v4084 = enum[v]
	local v4085 = v4084 and v4084[v4082]

	if v4085 then
		Enums[v4085] = v4083
	end
end)
local v4084 = "XZY"
local v4085 = 2041
pcall(function()
	local v4086 = enum[v]
	local v4087 = v4086 and v4086[v4084]

	if v4087 then
		Enums[v4087] = v4085
	end
end)
local v4086 = "YZX"
local v4087 = 2042
pcall(function()
	local v4088 = enum[v]
	local v4089 = v4088 and v4088[v4086]

	if v4089 then
		Enums[v4089] = v4087
	end
end)
local v4088 = "YXZ"
local v4089 = 2043
pcall(function()
	local v4090 = enum[v]
	local v4091 = v4090 and v4090[v4088]

	if v4091 then
		Enums[v4091] = v4089
	end
end)
local v4090 = "ZXY"
local v4091 = 2044
pcall(function()
	local v4092 = enum[v]
	local v4093 = v4092 and v4092[v4090]

	if v4093 then
		Enums[v4093] = v4091
	end
end)
local v4092 = "ZYX"
local v4093 = 2045
pcall(function()
	local v4094 = enum[v]
	local v4095 = v4094 and v4094[v4092]

	if v4095 then
		Enums[v4095] = v4093
	end
end)
v = "RotationType"
local v4094 = "MovementRelative"
local v4095 = 2046
pcall(function()
	local v4096 = enum[v]
	local v4097 = v4096 and v4096[v4094]

	if v4097 then
		Enums[v4097] = v4095
	end
end)
local v4096 = "CameraRelative"
local v4097 = 2047
pcall(function()
	local v4098 = enum[v]
	local v4099 = v4098 and v4098[v4096]

	if v4099 then
		Enums[v4099] = v4097
	end
end)
v = "RtlTextSupport"
local v4098 = "Default"
local v4099 = 2048
pcall(function()
	local v4100 = enum[v]
	local v4101 = v4100 and v4100[v4098]

	if v4101 then
		Enums[v4101] = v4099
	end
end)
local v4100 = "Disabled"
local v4101 = 2049
pcall(function()
	local v4102 = enum[v]
	local v4103 = v4102 and v4102[v4100]

	if v4103 then
		Enums[v4103] = v4101
	end
end)
local v4102 = "Enabled"
local v4103 = 2050
pcall(function()
	local v4104 = enum[v]
	local v4105 = v4104 and v4104[v4102]

	if v4105 then
		Enums[v4105] = v4103
	end
end)
v = "RunContext"
local v4104 = "Legacy"
local v4105 = 2051
pcall(function()
	local v4106 = enum[v]
	local v4107 = v4106 and v4106[v4104]

	if v4107 then
		Enums[v4107] = v4105
	end
end)
local v4106 = "Server"
local v4107 = 2052
pcall(function()
	local v4108 = enum[v]
	local v4109 = v4108 and v4108[v4106]

	if v4109 then
		Enums[v4109] = v4107
	end
end)
local v4108 = "Client"
local v4109 = 2053
pcall(function()
	local v4110 = enum[v]
	local v4111 = v4110 and v4110[v4108]

	if v4111 then
		Enums[v4111] = v4109
	end
end)
local v4110 = "Plugin"
local v4111 = 2054
pcall(function()
	local v4112 = enum[v]
	local v4113 = v4112 and v4112[v4110]

	if v4113 then
		Enums[v4113] = v4111
	end
end)
v = "RunState"
local v4112 = "Stopped"
local v4113 = 2055
pcall(function()
	local v4114 = enum[v]
	local v4115 = v4114 and v4114[v4112]

	if v4115 then
		Enums[v4115] = v4113
	end
end)
local v4114 = "Running"
local v4115 = 2056
pcall(function()
	local v4116 = enum[v]
	local v4117 = v4116 and v4116[v4114]

	if v4117 then
		Enums[v4117] = v4115
	end
end)
local v4116 = "Paused"
local v4117 = 2057
pcall(function()
	local v4118 = enum[v]
	local v4119 = v4118 and v4118[v4116]

	if v4119 then
		Enums[v4119] = v4117
	end
end)
v = "RuntimeUndoBehavior"
local v4118 = "Aggregate"
local v4119 = 2058
pcall(function()
	local v4120 = enum[v]
	local v4121 = v4120 and v4120[v4118]

	if v4121 then
		Enums[v4121] = v4119
	end
end)
local v4120 = "Snapshot"
local v4121 = 2059
pcall(function()
	local v4122 = enum[v]
	local v4123 = v4122 and v4122[v4120]

	if v4123 then
		Enums[v4123] = v4121
	end
end)
local v4122 = "Hybrid"
local v4123 = 2060
pcall(function()
	local v4124 = enum[v]
	local v4125 = v4124 and v4124[v4122]

	if v4125 then
		Enums[v4125] = v4123
	end
end)
v = "SafeAreaCompatibility"
local v4124 = "None"
local v4125 = 2061
pcall(function()
	local v4126 = enum[v]
	local v4127 = v4126 and v4126[v4124]

	if v4127 then
		Enums[v4127] = v4125
	end
end)
local v4126 = "FullscreenExtension"
local v4127 = 2062
pcall(function()
	local v4128 = enum[v]
	local v4129 = v4128 and v4128[v4126]

	if v4129 then
		Enums[v4129] = v4127
	end
end)
v = "SalesTypeFilter"
local v4128 = "All"
local v4129 = 2063
pcall(function()
	local v4130 = enum[v]
	local v4131 = v4130 and v4130[v4128]

	if v4131 then
		Enums[v4131] = v4129
	end
end)
local v4130 = "Collectibles"
local v4131 = 2064
pcall(function()
	local v4132 = enum[v]
	local v4133 = v4132 and v4132[v4130]

	if v4133 then
		Enums[v4133] = v4131
	end
end)
local v4132 = "Premium"
local v4133 = 2065
pcall(function()
	local v4134 = enum[v]
	local v4135 = v4134 and v4134[v4132]

	if v4135 then
		Enums[v4135] = v4133
	end
end)
v = "SandboxedInstanceMode"
local v4134 = "Default"
local v4135 = 2066
pcall(function()
	local v4136 = enum[v]
	local v4137 = v4136 and v4136[v4134]

	if v4137 then
		Enums[v4137] = v4135
	end
end)
local v4136 = "Experimental"
local v4137 = 2067
pcall(function()
	local v4138 = enum[v]
	local v4139 = v4138 and v4138[v4136]

	if v4139 then
		Enums[v4139] = v4137
	end
end)
v = "SaveAvatarThumbnailCustomizationFailure"
local v4138 = "BadThumbnailType"
local v4139 = 2068
pcall(function()
	local v4140 = enum[v]
	local v4141 = v4140 and v4140[v4138]

	if v4141 then
		Enums[v4141] = v4139
	end
end)
local v4140 = "BadYRotDeg"
local v4141 = 2069
pcall(function()
	local v4142 = enum[v]
	local v4143 = v4142 and v4142[v4140]

	if v4143 then
		Enums[v4143] = v4141
	end
end)
local v4142 = "BadFieldOfViewDeg"
local v4143 = 2070
pcall(function()
	local v4144 = enum[v]
	local v4145 = v4144 and v4144[v4142]

	if v4145 then
		Enums[v4145] = v4143
	end
end)
local v4144 = "BadDistanceScale"
local v4145 = 2071
pcall(function()
	local v4146 = enum[v]
	local v4147 = v4146 and v4146[v4144]

	if v4147 then
		Enums[v4147] = v4145
	end
end)
local v4146 = "Other"
local v4147 = 2072
pcall(function()
	local v4148 = enum[v]
	local v4149 = v4148 and v4148[v4146]

	if v4149 then
		Enums[v4149] = v4147
	end
end)
local v4148 = "Throttled"
local v4149 = 2073
pcall(function()
	local v4150 = enum[v]
	local v4151 = v4150 and v4150[v4148]

	if v4151 then
		Enums[v4151] = v4149
	end
end)
v = "SaveFilter"
local v4150 = "SaveWorld"
local v4151 = 2074
pcall(function()
	local v4152 = enum[v]
	local v4153 = v4152 and v4152[v4150]

	if v4153 then
		Enums[v4153] = v4151
	end
end)
local v4152 = "SaveGame"
local v4153 = 2075
pcall(function()
	local v4154 = enum[v]
	local v4155 = v4154 and v4154[v4152]

	if v4155 then
		Enums[v4155] = v4153
	end
end)
local v4154 = "SaveAll"
local v4155 = 2076
pcall(function()
	local v4156 = enum[v]
	local v4157 = v4156 and v4156[v4154]

	if v4157 then
		Enums[v4157] = v4155
	end
end)
v = "SavedQualitySetting"
local v4156 = "Automatic"
local v4157 = 2077
pcall(function()
	local v4158 = enum[v]
	local v4159 = v4158 and v4158[v4156]

	if v4159 then
		Enums[v4159] = v4157
	end
end)
local v4158 = "QualityLevel1"
local v4159 = 2078
pcall(function()
	local v4160 = enum[v]
	local v4161 = v4160 and v4160[v4158]

	if v4161 then
		Enums[v4161] = v4159
	end
end)
local v4160 = "QualityLevel2"
local v4161 = 2079
pcall(function()
	local v4162 = enum[v]
	local v4163 = v4162 and v4162[v4160]

	if v4163 then
		Enums[v4163] = v4161
	end
end)
local v4162 = "QualityLevel3"
local v4163 = 2080
pcall(function()
	local v4164 = enum[v]
	local v4165 = v4164 and v4164[v4162]

	if v4165 then
		Enums[v4165] = v4163
	end
end)
local v4164 = "QualityLevel4"
local v4165 = 2081
pcall(function()
	local v4166 = enum[v]
	local v4167 = v4166 and v4166[v4164]

	if v4167 then
		Enums[v4167] = v4165
	end
end)
local v4166 = "QualityLevel5"
local v4167 = 2082
pcall(function()
	local v4168 = enum[v]
	local v4169 = v4168 and v4168[v4166]

	if v4169 then
		Enums[v4169] = v4167
	end
end)
local v4168 = "QualityLevel6"
local v4169 = 2083
pcall(function()
	local v4170 = enum[v]
	local v4171 = v4170 and v4170[v4168]

	if v4171 then
		Enums[v4171] = v4169
	end
end)
local v4170 = "QualityLevel7"
local v4171 = 2084
pcall(function()
	local v4172 = enum[v]
	local v4173 = v4172 and v4172[v4170]

	if v4173 then
		Enums[v4173] = v4171
	end
end)
local v4172 = "QualityLevel8"
local v4173 = 2085
pcall(function()
	local v4174 = enum[v]
	local v4175 = v4174 and v4174[v4172]

	if v4175 then
		Enums[v4175] = v4173
	end
end)
local v4174 = "QualityLevel9"
local v4175 = 2086
pcall(function()
	local v4176 = enum[v]
	local v4177 = v4176 and v4176[v4174]

	if v4177 then
		Enums[v4177] = v4175
	end
end)
local v4176 = "QualityLevel10"
local v4177 = 2087
pcall(function()
	local v4178 = enum[v]
	local v4179 = v4178 and v4178[v4176]

	if v4179 then
		Enums[v4179] = v4177
	end
end)
v = "ScaleType"
local v4178 = "Stretch"
local v4179 = 2088
pcall(function()
	local v4180 = enum[v]
	local v4181 = v4180 and v4180[v4178]

	if v4181 then
		Enums[v4181] = v4179
	end
end)
local v4180 = "Slice"
local v4181 = 2089
pcall(function()
	local v4182 = enum[v]
	local v4183 = v4182 and v4182[v4180]

	if v4183 then
		Enums[v4183] = v4181
	end
end)
local v4182 = "Tile"
local v4183 = 2090
pcall(function()
	local v4184 = enum[v]
	local v4185 = v4184 and v4184[v4182]

	if v4185 then
		Enums[v4185] = v4183
	end
end)
local v4184 = "Fit"
local v4185 = 2091
pcall(function()
	local v4186 = enum[v]
	local v4187 = v4186 and v4186[v4184]

	if v4187 then
		Enums[v4187] = v4185
	end
end)
local v4186 = "Crop"
local v4187 = 2092
pcall(function()
	local v4188 = enum[v]
	local v4189 = v4188 and v4188[v4186]

	if v4189 then
		Enums[v4189] = v4187
	end
end)
v = "ScopeCheckResult"
local v4188 = "ConsentAccepted"
local v4189 = 2093
pcall(function()
	local v4190 = enum[v]
	local v4191 = v4190 and v4190[v4188]

	if v4191 then
		Enums[v4191] = v4189
	end
end)
local v4190 = "InvalidScopes"
local v4191 = 2094
pcall(function()
	local v4192 = enum[v]
	local v4193 = v4192 and v4192[v4190]

	if v4193 then
		Enums[v4193] = v4191
	end
end)
local v4192 = "Timeout"
local v4193 = 2095
pcall(function()
	local v4194 = enum[v]
	local v4195 = v4194 and v4194[v4192]

	if v4195 then
		Enums[v4195] = v4193
	end
end)
local v4194 = "NoUserInput"
local v4195 = 2096
pcall(function()
	local v4196 = enum[v]
	local v4197 = v4196 and v4196[v4194]

	if v4197 then
		Enums[v4197] = v4195
	end
end)
local v4196 = "BackendError"
local v4197 = 2097
pcall(function()
	local v4198 = enum[v]
	local v4199 = v4198 and v4198[v4196]

	if v4199 then
		Enums[v4199] = v4197
	end
end)
local v4198 = "UnexpectedError"
local v4199 = 2098
pcall(function()
	local v4200 = enum[v]
	local v4201 = v4200 and v4200[v4198]

	if v4201 then
		Enums[v4201] = v4199
	end
end)
local v4200 = "InvalidArgument"
local v4201 = 2099
pcall(function()
	local v4202 = enum[v]
	local v4203 = v4202 and v4202[v4200]

	if v4203 then
		Enums[v4203] = v4201
	end
end)
local v4202 = "ConsentDenied"
local v4203 = 2100
pcall(function()
	local v4204 = enum[v]
	local v4205 = v4204 and v4204[v4202]

	if v4205 then
		Enums[v4205] = v4203
	end
end)
v = "ScreenInsets"
local v4204 = "None"
local v4205 = 2101
pcall(function()
	local v4206 = enum[v]
	local v4207 = v4206 and v4206[v4204]

	if v4207 then
		Enums[v4207] = v4205
	end
end)
local v4206 = "DeviceSafeInsets"
local v4207 = 2102
pcall(function()
	local v4208 = enum[v]
	local v4209 = v4208 and v4208[v4206]

	if v4209 then
		Enums[v4209] = v4207
	end
end)
local v4208 = "CoreUISafeInsets"
local v4209 = 2103
pcall(function()
	local v4210 = enum[v]
	local v4211 = v4210 and v4210[v4208]

	if v4211 then
		Enums[v4211] = v4209
	end
end)
local v4210 = "TopbarSafeInsets"
local v4211 = 2104
pcall(function()
	local v4212 = enum[v]
	local v4213 = v4212 and v4212[v4210]

	if v4213 then
		Enums[v4213] = v4211
	end
end)
v = "ScreenOrientation"
local v4212 = "LandscapeLeft"
local v4213 = 2105
pcall(function()
	local v4214 = enum[v]
	local v4215 = v4214 and v4214[v4212]

	if v4215 then
		Enums[v4215] = v4213
	end
end)
local v4214 = "LandscapeRight"
local v4215 = 2106
pcall(function()
	local v4216 = enum[v]
	local v4217 = v4216 and v4216[v4214]

	if v4217 then
		Enums[v4217] = v4215
	end
end)
local v4216 = "LandscapeSensor"
local v4217 = 2107
pcall(function()
	local v4218 = enum[v]
	local v4219 = v4218 and v4218[v4216]

	if v4219 then
		Enums[v4219] = v4217
	end
end)
local v4218 = "Portrait"
local v4219 = 2108
pcall(function()
	local v4220 = enum[v]
	local v4221 = v4220 and v4220[v4218]

	if v4221 then
		Enums[v4221] = v4219
	end
end)
local v4220 = "Sensor"
local v4221 = 2109
pcall(function()
	local v4222 = enum[v]
	local v4223 = v4222 and v4222[v4220]

	if v4223 then
		Enums[v4223] = v4221
	end
end)
v = "ScrollBarInset"
local v4222 = "None"
local v4223 = 2110
pcall(function()
	local v4224 = enum[v]
	local v4225 = v4224 and v4224[v4222]

	if v4225 then
		Enums[v4225] = v4223
	end
end)
local v4224 = "ScrollBar"
local v4225 = 2111
pcall(function()
	local v4226 = enum[v]
	local v4227 = v4226 and v4226[v4224]

	if v4227 then
		Enums[v4227] = v4225
	end
end)
local v4226 = "Always"
local v4227 = 2112
pcall(function()
	local v4228 = enum[v]
	local v4229 = v4228 and v4228[v4226]

	if v4229 then
		Enums[v4229] = v4227
	end
end)
v = "ScrollingDirection"
local v4228 = "X"
local v4229 = 2113
pcall(function()
	local v4230 = enum[v]
	local v4231 = v4230 and v4230[v4228]

	if v4231 then
		Enums[v4231] = v4229
	end
end)
local v4230 = "Y"
local v4231 = 2114
pcall(function()
	local v4232 = enum[v]
	local v4233 = v4232 and v4232[v4230]

	if v4233 then
		Enums[v4233] = v4231
	end
end)
local v4232 = "XY"
local v4233 = 2115
pcall(function()
	local v4234 = enum[v]
	local v4235 = v4234 and v4234[v4232]

	if v4235 then
		Enums[v4235] = v4233
	end
end)
v = "SecurityCapability"
local v4234 = "RunClientScript"
local v4235 = 2116
pcall(function()
	local v4236 = enum[v]
	local v4237 = v4236 and v4236[v4234]

	if v4237 then
		Enums[v4237] = v4235
	end
end)
local v4236 = "RunServerScript"
local v4237 = 2117
pcall(function()
	local v4238 = enum[v]
	local v4239 = v4238 and v4238[v4236]

	if v4239 then
		Enums[v4239] = v4237
	end
end)
local v4238 = "AccessOutsideWrite"
local v4239 = 2118
pcall(function()
	local v4240 = enum[v]
	local v4241 = v4240 and v4240[v4238]

	if v4241 then
		Enums[v4241] = v4239
	end
end)
local v4240 = "AssetRequire"
local v4241 = 2119
pcall(function()
	local v4242 = enum[v]
	local v4243 = v4242 and v4242[v4240]

	if v4243 then
		Enums[v4243] = v4241
	end
end)
local v4242 = "LoadString"
local v4243 = 2120
pcall(function()
	local v4244 = enum[v]
	local v4245 = v4244 and v4244[v4242]

	if v4245 then
		Enums[v4245] = v4243
	end
end)
local v4244 = "ScriptGlobals"
local v4245 = 2121
pcall(function()
	local v4246 = enum[v]
	local v4247 = v4246 and v4246[v4244]

	if v4247 then
		Enums[v4247] = v4245
	end
end)
local v4246 = "CreateInstances"
local v4247 = 2122
pcall(function()
	local v4248 = enum[v]
	local v4249 = v4248 and v4248[v4246]

	if v4249 then
		Enums[v4249] = v4247
	end
end)
local v4248 = "Basic"
local v4249 = 2123
pcall(function()
	local v4250 = enum[v]
	local v4251 = v4250 and v4250[v4248]

	if v4251 then
		Enums[v4251] = v4249
	end
end)
local v4250 = "Audio"
local v4251 = 2124
pcall(function()
	local v4252 = enum[v]
	local v4253 = v4252 and v4252[v4250]

	if v4253 then
		Enums[v4253] = v4251
	end
end)
local v4252 = "DataStore"
local v4253 = 2125
pcall(function()
	local v4254 = enum[v]
	local v4255 = v4254 and v4254[v4252]

	if v4255 then
		Enums[v4255] = v4253
	end
end)
local v4254 = "Network"
local v4255 = 2126
pcall(function()
	local v4256 = enum[v]
	local v4257 = v4256 and v4256[v4254]

	if v4257 then
		Enums[v4257] = v4255
	end
end)
local v4256 = "Physics"
local v4257 = 2127
pcall(function()
	local v4258 = enum[v]
	local v4259 = v4258 and v4258[v4256]

	if v4259 then
		Enums[v4259] = v4257
	end
end)
local v4258 = "UI"
local v4259 = 2128
pcall(function()
	local v4260 = enum[v]
	local v4261 = v4260 and v4260[v4258]

	if v4261 then
		Enums[v4261] = v4259
	end
end)
local v4260 = "CSG"
local v4261 = 2129
pcall(function()
	local v4262 = enum[v]
	local v4263 = v4262 and v4262[v4260]

	if v4263 then
		Enums[v4263] = v4261
	end
end)
local v4262 = "Chat"
local v4263 = 2130
pcall(function()
	local v4264 = enum[v]
	local v4265 = v4264 and v4264[v4262]

	if v4265 then
		Enums[v4265] = v4263
	end
end)
local v4264 = "Animation"
local v4265 = 2131
pcall(function()
	local v4266 = enum[v]
	local v4267 = v4266 and v4266[v4264]

	if v4267 then
		Enums[v4267] = v4265
	end
end)
local v4266 = "Avatar"
local v4267 = 2132
pcall(function()
	local v4268 = enum[v]
	local v4269 = v4268 and v4268[v4266]

	if v4269 then
		Enums[v4269] = v4267
	end
end)
local v4268 = "Input"
local v4269 = 2133
pcall(function()
	local v4270 = enum[v]
	local v4271 = v4270 and v4270[v4268]

	if v4271 then
		Enums[v4271] = v4269
	end
end)
local v4270 = "Environment"
local v4271 = 2134
pcall(function()
	local v4272 = enum[v]
	local v4273 = v4272 and v4272[v4270]

	if v4273 then
		Enums[v4273] = v4271
	end
end)
local v4272 = "RemoteEvent"
local v4273 = 2135
pcall(function()
	local v4274 = enum[v]
	local v4275 = v4274 and v4274[v4272]

	if v4275 then
		Enums[v4275] = v4273
	end
end)
local v4274 = "LegacySound"
local v4275 = 2136
pcall(function()
	local v4276 = enum[v]
	local v4277 = v4276 and v4276[v4274]

	if v4277 then
		Enums[v4277] = v4275
	end
end)
local v4276 = "Players"
local v4277 = 2137
pcall(function()
	local v4278 = enum[v]
	local v4279 = v4278 and v4278[v4276]

	if v4279 then
		Enums[v4279] = v4277
	end
end)
local v4278 = "CapabilityControl"
local v4279 = 2138
pcall(function()
	local v4280 = enum[v]
	local v4281 = v4280 and v4280[v4278]

	if v4281 then
		Enums[v4281] = v4279
	end
end)
v = "SelectionBehavior"
local v4280 = "Escape"
local v4281 = 2139
pcall(function()
	local v4282 = enum[v]
	local v4283 = v4282 and v4282[v4280]

	if v4283 then
		Enums[v4283] = v4281
	end
end)
local v4282 = "Stop"
local v4283 = 2140
pcall(function()
	local v4284 = enum[v]
	local v4285 = v4284 and v4284[v4282]

	if v4285 then
		Enums[v4285] = v4283
	end
end)
v = "SelectionRenderMode"
local v4284 = "Outlines"
local v4285 = 2141
pcall(function()
	local v4286 = enum[v]
	local v4287 = v4286 and v4286[v4284]

	if v4287 then
		Enums[v4287] = v4285
	end
end)
local v4286 = "BoundingBoxes"
local v4287 = 2142
pcall(function()
	local v4288 = enum[v]
	local v4289 = v4288 and v4288[v4286]

	if v4289 then
		Enums[v4289] = v4287
	end
end)
local v4288 = "Both"
local v4289 = 2143
pcall(function()
	local v4290 = enum[v]
	local v4291 = v4290 and v4290[v4288]

	if v4291 then
		Enums[v4291] = v4289
	end
end)
v = "SelfViewPosition"
local v4290 = "LastPosition"
local v4291 = 2144
pcall(function()
	local v4292 = enum[v]
	local v4293 = v4292 and v4292[v4290]

	if v4293 then
		Enums[v4293] = v4291
	end
end)
local v4292 = "TopLeft"
local v4293 = 2145
pcall(function()
	local v4294 = enum[v]
	local v4295 = v4294 and v4294[v4292]

	if v4295 then
		Enums[v4295] = v4293
	end
end)
local v4294 = "TopRight"
local v4295 = 2146
pcall(function()
	local v4296 = enum[v]
	local v4297 = v4296 and v4296[v4294]

	if v4297 then
		Enums[v4297] = v4295
	end
end)
local v4296 = "BottomLeft"
local v4297 = 2147
pcall(function()
	local v4298 = enum[v]
	local v4299 = v4298 and v4298[v4296]

	if v4299 then
		Enums[v4299] = v4297
	end
end)
local v4298 = "BottomRight"
local v4299 = 2148
pcall(function()
	local v4300 = enum[v]
	local v4301 = v4300 and v4300[v4298]

	if v4301 then
		Enums[v4301] = v4299
	end
end)
v = "SensorMode"
local v4300 = "Floor"
local v4301 = 2149
pcall(function()
	local v4302 = enum[v]
	local v4303 = v4302 and v4302[v4300]

	if v4303 then
		Enums[v4303] = v4301
	end
end)
local v4302 = "Ladder"
local v4303 = 2150
pcall(function()
	local v4304 = enum[v]
	local v4305 = v4304 and v4304[v4302]

	if v4305 then
		Enums[v4305] = v4303
	end
end)
v = "SensorUpdateType"
local v4304 = "OnRead"
local v4305 = 2151
pcall(function()
	local v4306 = enum[v]
	local v4307 = v4306 and v4306[v4304]

	if v4307 then
		Enums[v4307] = v4305
	end
end)
local v4306 = "Manual"
local v4307 = 2152
pcall(function()
	local v4308 = enum[v]
	local v4309 = v4308 and v4308[v4306]

	if v4309 then
		Enums[v4309] = v4307
	end
end)
v = "ServerLiveEditingMode"
local v4308 = "Uninitialized"
local v4309 = 2153
pcall(function()
	local v4310 = enum[v]
	local v4311 = v4310 and v4310[v4308]

	if v4311 then
		Enums[v4311] = v4309
	end
end)
local v4310 = "Enabled"
local v4311 = 2154
pcall(function()
	local v4312 = enum[v]
	local v4313 = v4312 and v4312[v4310]

	if v4313 then
		Enums[v4313] = v4311
	end
end)
local v4312 = "Disabled"
local v4313 = 2155
pcall(function()
	local v4314 = enum[v]
	local v4315 = v4314 and v4314[v4312]

	if v4315 then
		Enums[v4315] = v4313
	end
end)
v = "ServiceVisibility"
local v4314 = "Always"
local v4315 = 2156
pcall(function()
	local v4316 = enum[v]
	local v4317 = v4316 and v4316[v4314]

	if v4317 then
		Enums[v4317] = v4315
	end
end)
local v4316 = "Off"
local v4317 = 2157
pcall(function()
	local v4318 = enum[v]
	local v4319 = v4318 and v4318[v4316]

	if v4319 then
		Enums[v4319] = v4317
	end
end)
local v4318 = "WithChildren"
local v4319 = 2158
pcall(function()
	local v4320 = enum[v]
	local v4321 = v4320 and v4320[v4318]

	if v4321 then
		Enums[v4321] = v4319
	end
end)
v = "Severity"
local v4320 = "Error"
local v4321 = 2159
pcall(function()
	local v4322 = enum[v]
	local v4323 = v4322 and v4322[v4320]

	if v4323 then
		Enums[v4323] = v4321
	end
end)
local v4322 = "Warning"
local v4323 = 2160
pcall(function()
	local v4324 = enum[v]
	local v4325 = v4324 and v4324[v4322]

	if v4325 then
		Enums[v4325] = v4323
	end
end)
local v4324 = "Information"
local v4325 = 2161
pcall(function()
	local v4326 = enum[v]
	local v4327 = v4326 and v4326[v4324]

	if v4327 then
		Enums[v4327] = v4325
	end
end)
local v4326 = "Hint"
local v4327 = 2162
pcall(function()
	local v4328 = enum[v]
	local v4329 = v4328 and v4328[v4326]

	if v4329 then
		Enums[v4329] = v4327
	end
end)
v = "ShowAdResult"
local v4328 = "ShowCompleted"
local v4329 = 2163
pcall(function()
	local v4330 = enum[v]
	local v4331 = v4330 and v4330[v4328]

	if v4331 then
		Enums[v4331] = v4329
	end
end)
local v4330 = "AdNotReady"
local v4331 = 2164
pcall(function()
	local v4332 = enum[v]
	local v4333 = v4332 and v4332[v4330]

	if v4333 then
		Enums[v4333] = v4331
	end
end)
local v4332 = "AdAlreadyShowing"
local v4333 = 2165
pcall(function()
	local v4334 = enum[v]
	local v4335 = v4334 and v4334[v4332]

	if v4335 then
		Enums[v4335] = v4333
	end
end)
local v4334 = "InternalError"
local v4335 = 2166
pcall(function()
	local v4336 = enum[v]
	local v4337 = v4336 and v4336[v4334]

	if v4337 then
		Enums[v4337] = v4335
	end
end)
local v4336 = "ShowInterrupted"
local v4337 = 2167
pcall(function()
	local v4338 = enum[v]
	local v4339 = v4338 and v4338[v4336]

	if v4339 then
		Enums[v4339] = v4337
	end
end)
local v4338 = "InsufficientMemory"
local v4339 = 2168
pcall(function()
	local v4340 = enum[v]
	local v4341 = v4340 and v4340[v4338]

	if v4341 then
		Enums[v4341] = v4339
	end
end)
v = "SignalBehavior"
local v4340 = "Default"
local v4341 = 2169
pcall(function()
	local v4342 = enum[v]
	local v4343 = v4342 and v4342[v4340]

	if v4343 then
		Enums[v4343] = v4341
	end
end)
local v4342 = "Immediate"
local v4343 = 2170
pcall(function()
	local v4344 = enum[v]
	local v4345 = v4344 and v4344[v4342]

	if v4345 then
		Enums[v4345] = v4343
	end
end)
local v4344 = "Deferred"
local v4345 = 2171
pcall(function()
	local v4346 = enum[v]
	local v4347 = v4346 and v4346[v4344]

	if v4347 then
		Enums[v4347] = v4345
	end
end)
local v4346 = "AncestryDeferred"
local v4347 = 2172
pcall(function()
	local v4348 = enum[v]
	local v4349 = v4348 and v4348[v4346]

	if v4349 then
		Enums[v4349] = v4347
	end
end)
v = "SizeConstraint"
local v4348 = "RelativeXY"
local v4349 = 2173
pcall(function()
	local v4350 = enum[v]
	local v4351 = v4350 and v4350[v4348]

	if v4351 then
		Enums[v4351] = v4349
	end
end)
local v4350 = "RelativeXX"
local v4351 = 2174
pcall(function()
	local v4352 = enum[v]
	local v4353 = v4352 and v4352[v4350]

	if v4353 then
		Enums[v4353] = v4351
	end
end)
local v4352 = "RelativeYY"
local v4353 = 2175
pcall(function()
	local v4354 = enum[v]
	local v4355 = v4354 and v4354[v4352]

	if v4355 then
		Enums[v4355] = v4353
	end
end)
v = "SolverConvergenceMetricType"
local v4354 = "IterationBased"
local v4355 = 2176
pcall(function()
	local v4356 = enum[v]
	local v4357 = v4356 and v4356[v4354]

	if v4357 then
		Enums[v4357] = v4355
	end
end)
local v4356 = "AlgorithmAgnostic"
local v4357 = 2177
pcall(function()
	local v4358 = enum[v]
	local v4359 = v4358 and v4358[v4356]

	if v4359 then
		Enums[v4359] = v4357
	end
end)
v = "SolverConvergenceVisualizationMode"
local v4358 = "Disabled"
local v4359 = 2178
pcall(function()
	local v4360 = enum[v]
	local v4361 = v4360 and v4360[v4358]

	if v4361 then
		Enums[v4361] = v4359
	end
end)
local v4360 = "PerIsland"
local v4361 = 2179
pcall(function()
	local v4362 = enum[v]
	local v4363 = v4362 and v4362[v4360]

	if v4363 then
		Enums[v4363] = v4361
	end
end)
local v4362 = "PerEdge"
local v4363 = 2180
pcall(function()
	local v4364 = enum[v]
	local v4365 = v4364 and v4364[v4362]

	if v4365 then
		Enums[v4365] = v4363
	end
end)
v = "SortDirection"
local v4364 = "Ascending"
local v4365 = 2181
pcall(function()
	local v4366 = enum[v]
	local v4367 = v4366 and v4366[v4364]

	if v4367 then
		Enums[v4367] = v4365
	end
end)
local v4366 = "Descending"
local v4367 = 2182
pcall(function()
	local v4368 = enum[v]
	local v4369 = v4368 and v4368[v4366]

	if v4369 then
		Enums[v4369] = v4367
	end
end)
v = "SortOrder"
local v4368 = "Name"
local v4369 = 2183
pcall(function()
	local v4370 = enum[v]
	local v4371 = v4370 and v4370[v4368]

	if v4371 then
		Enums[v4371] = v4369
	end
end)
local v4370 = "Custom"
local v4371 = 2184
pcall(function()
	local v4372 = enum[v]
	local v4373 = v4372 and v4372[v4370]

	if v4373 then
		Enums[v4373] = v4371
	end
end)
local v4372 = "LayoutOrder"
local v4373 = 2185
pcall(function()
	local v4374 = enum[v]
	local v4375 = v4374 and v4374[v4372]

	if v4375 then
		Enums[v4375] = v4373
	end
end)
v = "SpecialKey"
local v4374 = "Insert"
local v4375 = 2186
pcall(function()
	local v4376 = enum[v]
	local v4377 = v4376 and v4376[v4374]

	if v4377 then
		Enums[v4377] = v4375
	end
end)
local v4376 = "Home"
local v4377 = 2187
pcall(function()
	local v4378 = enum[v]
	local v4379 = v4378 and v4378[v4376]

	if v4379 then
		Enums[v4379] = v4377
	end
end)
local v4378 = "End"
local v4379 = 2188
pcall(function()
	local v4380 = enum[v]
	local v4381 = v4380 and v4380[v4378]

	if v4381 then
		Enums[v4381] = v4379
	end
end)
local v4380 = "PageUp"
local v4381 = 2189
pcall(function()
	local v4382 = enum[v]
	local v4383 = v4382 and v4382[v4380]

	if v4383 then
		Enums[v4383] = v4381
	end
end)
local v4382 = "PageDown"
local v4383 = 2190
pcall(function()
	local v4384 = enum[v]
	local v4385 = v4384 and v4384[v4382]

	if v4385 then
		Enums[v4385] = v4383
	end
end)
local v4384 = "ChatHotkey"
local v4385 = 2191
pcall(function()
	local v4386 = enum[v]
	local v4387 = v4386 and v4386[v4384]

	if v4387 then
		Enums[v4387] = v4385
	end
end)
v = "StartCorner"
local v4386 = "TopLeft"
local v4387 = 2192
pcall(function()
	local v4388 = enum[v]
	local v4389 = v4388 and v4388[v4386]

	if v4389 then
		Enums[v4389] = v4387
	end
end)
local v4388 = "TopRight"
local v4389 = 2193
pcall(function()
	local v4390 = enum[v]
	local v4391 = v4390 and v4390[v4388]

	if v4391 then
		Enums[v4391] = v4389
	end
end)
local v4390 = "BottomLeft"
local v4391 = 2194
pcall(function()
	local v4392 = enum[v]
	local v4393 = v4392 and v4392[v4390]

	if v4393 then
		Enums[v4393] = v4391
	end
end)
local v4392 = "BottomRight"
local v4393 = 2195
pcall(function()
	local v4394 = enum[v]
	local v4395 = v4394 and v4394[v4392]

	if v4395 then
		Enums[v4395] = v4393
	end
end)
v = "StateObjectFieldType"
local v4394 = "Boolean"
local v4395 = 2196
pcall(function()
	local v4396 = enum[v]
	local v4397 = v4396 and v4396[v4394]

	if v4397 then
		Enums[v4397] = v4395
	end
end)
local v4396 = "CFrame"
local v4397 = 2197
pcall(function()
	local v4398 = enum[v]
	local v4399 = v4398 and v4398[v4396]

	if v4399 then
		Enums[v4399] = v4397
	end
end)
local v4398 = "Color3"
local v4399 = 2198
pcall(function()
	local v4400 = enum[v]
	local v4401 = v4400 and v4400[v4398]

	if v4401 then
		Enums[v4401] = v4399
	end
end)
local v4400 = "Float"
local v4401 = 2199
pcall(function()
	local v4402 = enum[v]
	local v4403 = v4402 and v4402[v4400]

	if v4403 then
		Enums[v4403] = v4401
	end
end)
local v4402 = "Instance"
local v4403 = 2200
pcall(function()
	local v4404 = enum[v]
	local v4405 = v4404 and v4404[v4402]

	if v4405 then
		Enums[v4405] = v4403
	end
end)
local v4404 = "Random"
local v4405 = 2201
pcall(function()
	local v4406 = enum[v]
	local v4407 = v4406 and v4406[v4404]

	if v4407 then
		Enums[v4407] = v4405
	end
end)
local v4406 = "Vector2"
local v4407 = 2202
pcall(function()
	local v4408 = enum[v]
	local v4409 = v4408 and v4408[v4406]

	if v4409 then
		Enums[v4409] = v4407
	end
end)
local v4408 = "Vector3"
local v4409 = 2203
pcall(function()
	local v4410 = enum[v]
	local v4411 = v4410 and v4410[v4408]

	if v4411 then
		Enums[v4411] = v4409
	end
end)
local v4410 = "INVALID"
local v4411 = 2204
pcall(function()
	local v4412 = enum[v]
	local v4413 = v4412 and v4412[v4410]

	if v4413 then
		Enums[v4413] = v4411
	end
end)
v = "Status"
local v4412 = "Poison"
local v4413 = 2205
pcall(function()
	local v4414 = enum[v]
	local v4415 = v4414 and v4414[v4412]

	if v4415 then
		Enums[v4415] = v4413
	end
end)
local v4414 = "Confusion"
local v4415 = 2206
pcall(function()
	local v4416 = enum[v]
	local v4417 = v4416 and v4416[v4414]

	if v4417 then
		Enums[v4417] = v4415
	end
end)
v = "StreamOutBehavior"
local v4416 = "Default"
local v4417 = 2207
pcall(function()
	local v4418 = enum[v]
	local v4419 = v4418 and v4418[v4416]

	if v4419 then
		Enums[v4419] = v4417
	end
end)
local v4418 = "LowMemory"
local v4419 = 2208
pcall(function()
	local v4420 = enum[v]
	local v4421 = v4420 and v4420[v4418]

	if v4421 then
		Enums[v4421] = v4419
	end
end)
local v4420 = "Opportunistic"
local v4421 = 2209
pcall(function()
	local v4422 = enum[v]
	local v4423 = v4422 and v4422[v4420]

	if v4423 then
		Enums[v4423] = v4421
	end
end)
v = "StreamingIntegrityMode"
local v4422 = "Default"
local v4423 = 2210
pcall(function()
	local v4424 = enum[v]
	local v4425 = v4424 and v4424[v4422]

	if v4425 then
		Enums[v4425] = v4423
	end
end)
local v4424 = "Disabled"
local v4425 = 2211
pcall(function()
	local v4426 = enum[v]
	local v4427 = v4426 and v4426[v4424]

	if v4427 then
		Enums[v4427] = v4425
	end
end)
local v4426 = "MinimumRadiusPause"
local v4427 = 2212
pcall(function()
	local v4428 = enum[v]
	local v4429 = v4428 and v4428[v4426]

	if v4429 then
		Enums[v4429] = v4427
	end
end)
local v4428 = "PauseOutsideLoadedArea"
local v4429 = 2213
pcall(function()
	local v4430 = enum[v]
	local v4431 = v4430 and v4430[v4428]

	if v4431 then
		Enums[v4431] = v4429
	end
end)
v = "StreamingPauseMode"
local v4430 = "Default"
local v4431 = 2214
pcall(function()
	local v4432 = enum[v]
	local v4433 = v4432 and v4432[v4430]

	if v4433 then
		Enums[v4433] = v4431
	end
end)
local v4432 = "Disabled"
local v4433 = 2215
pcall(function()
	local v4434 = enum[v]
	local v4435 = v4434 and v4434[v4432]

	if v4435 then
		Enums[v4435] = v4433
	end
end)
local v4434 = "ClientPhysicsPause"
local v4435 = 2216
pcall(function()
	local v4436 = enum[v]
	local v4437 = v4436 and v4436[v4434]

	if v4437 then
		Enums[v4437] = v4435
	end
end)
v = "StudioCloseMode"
local v4436 = "None"
local v4437 = 2217
pcall(function()
	local v4438 = enum[v]
	local v4439 = v4438 and v4438[v4436]

	if v4439 then
		Enums[v4439] = v4437
	end
end)
local v4438 = "CloseStudio"
local v4439 = 2218
pcall(function()
	local v4440 = enum[v]
	local v4441 = v4440 and v4440[v4438]

	if v4441 then
		Enums[v4441] = v4439
	end
end)
local v4440 = "CloseDoc"
local v4441 = 2219
pcall(function()
	local v4442 = enum[v]
	local v4443 = v4442 and v4442[v4440]

	if v4443 then
		Enums[v4443] = v4441
	end
end)
local v4442 = "LogOut"
local v4443 = 2220
pcall(function()
	local v4444 = enum[v]
	local v4445 = v4444 and v4444[v4442]

	if v4445 then
		Enums[v4445] = v4443
	end
end)
v = "StudioDataModelType"
local v4444 = "Edit"
local v4445 = 2221
pcall(function()
	local v4446 = enum[v]
	local v4447 = v4446 and v4446[v4444]

	if v4447 then
		Enums[v4447] = v4445
	end
end)
local v4446 = "PlayClient"
local v4447 = 2222
pcall(function()
	local v4448 = enum[v]
	local v4449 = v4448 and v4448[v4446]

	if v4449 then
		Enums[v4449] = v4447
	end
end)
local v4448 = "PlayServer"
local v4449 = 2223
pcall(function()
	local v4450 = enum[v]
	local v4451 = v4450 and v4450[v4448]

	if v4451 then
		Enums[v4451] = v4449
	end
end)
local v4450 = "Standalone"
local v4451 = 2224
pcall(function()
	local v4452 = enum[v]
	local v4453 = v4452 and v4452[v4450]

	if v4453 then
		Enums[v4453] = v4451
	end
end)
local v4452 = "None"
local v4453 = 2225
pcall(function()
	local v4454 = enum[v]
	local v4455 = v4454 and v4454[v4452]

	if v4455 then
		Enums[v4455] = v4453
	end
end)
v = "StudioPlaceUpdateFailureReason"
local v4454 = "Other"
local v4455 = 2226
pcall(function()
	local v4456 = enum[v]
	local v4457 = v4456 and v4456[v4454]

	if v4457 then
		Enums[v4457] = v4455
	end
end)
local v4456 = "TeamCreateConflict"
local v4457 = 2227
pcall(function()
	local v4458 = enum[v]
	local v4459 = v4458 and v4458[v4456]

	if v4459 then
		Enums[v4459] = v4457
	end
end)
v = "StudioScriptEditorColorCategories"
local v4458 = "Default"
local v4459 = 2228
pcall(function()
	local v4460 = enum[v]
	local v4461 = v4460 and v4460[v4458]

	if v4461 then
		Enums[v4461] = v4459
	end
end)
local v4460 = "Operator"
local v4461 = 2229
pcall(function()
	local v4462 = enum[v]
	local v4463 = v4462 and v4462[v4460]

	if v4463 then
		Enums[v4463] = v4461
	end
end)
local v4462 = "Number"
local v4463 = 2230
pcall(function()
	local v4464 = enum[v]
	local v4465 = v4464 and v4464[v4462]

	if v4465 then
		Enums[v4465] = v4463
	end
end)
local v4464 = "String"
local v4465 = 2231
pcall(function()
	local v4466 = enum[v]
	local v4467 = v4466 and v4466[v4464]

	if v4467 then
		Enums[v4467] = v4465
	end
end)
local v4466 = "Comment"
local v4467 = 2232
pcall(function()
	local v4468 = enum[v]
	local v4469 = v4468 and v4468[v4466]

	if v4469 then
		Enums[v4469] = v4467
	end
end)
local v4468 = "Keyword"
local v4469 = 2233
pcall(function()
	local v4470 = enum[v]
	local v4471 = v4470 and v4470[v4468]

	if v4471 then
		Enums[v4471] = v4469
	end
end)
local v4470 = "Builtin"
local v4471 = 2234
pcall(function()
	local v4472 = enum[v]
	local v4473 = v4472 and v4472[v4470]

	if v4473 then
		Enums[v4473] = v4471
	end
end)
local v4472 = "Method"
local v4473 = 2235
pcall(function()
	local v4474 = enum[v]
	local v4475 = v4474 and v4474[v4472]

	if v4475 then
		Enums[v4475] = v4473
	end
end)
local v4474 = "Property"
local v4475 = 2236
pcall(function()
	local v4476 = enum[v]
	local v4477 = v4476 and v4476[v4474]

	if v4477 then
		Enums[v4477] = v4475
	end
end)
local v4476 = "Nil"
local v4477 = 2237
pcall(function()
	local v4478 = enum[v]
	local v4479 = v4478 and v4478[v4476]

	if v4479 then
		Enums[v4479] = v4477
	end
end)
local v4478 = "Bool"
local v4479 = 2238
pcall(function()
	local v4480 = enum[v]
	local v4481 = v4480 and v4480[v4478]

	if v4481 then
		Enums[v4481] = v4479
	end
end)
local v4480 = "Function"
local v4481 = 2239
pcall(function()
	local v4482 = enum[v]
	local v4483 = v4482 and v4482[v4480]

	if v4483 then
		Enums[v4483] = v4481
	end
end)
local v4482 = "Local"
local v4483 = 2240
pcall(function()
	local v4484 = enum[v]
	local v4485 = v4484 and v4484[v4482]

	if v4485 then
		Enums[v4485] = v4483
	end
end)
local v4484 = "Self"
local v4485 = 2241
pcall(function()
	local v4486 = enum[v]
	local v4487 = v4486 and v4486[v4484]

	if v4487 then
		Enums[v4487] = v4485
	end
end)
local v4486 = "LuauKeyword"
local v4487 = 2242
pcall(function()
	local v4488 = enum[v]
	local v4489 = v4488 and v4488[v4486]

	if v4489 then
		Enums[v4489] = v4487
	end
end)
local v4488 = "FunctionName"
local v4489 = 2243
pcall(function()
	local v4490 = enum[v]
	local v4491 = v4490 and v4490[v4488]

	if v4491 then
		Enums[v4491] = v4489
	end
end)
local v4490 = "TODO"
local v4491 = 2244
pcall(function()
	local v4492 = enum[v]
	local v4493 = v4492 and v4492[v4490]

	if v4493 then
		Enums[v4493] = v4491
	end
end)
local v4492 = "Background"
local v4493 = 2245
pcall(function()
	local v4494 = enum[v]
	local v4495 = v4494 and v4494[v4492]

	if v4495 then
		Enums[v4495] = v4493
	end
end)
local v4494 = "SelectionText"
local v4495 = 2246
pcall(function()
	local v4496 = enum[v]
	local v4497 = v4496 and v4496[v4494]

	if v4497 then
		Enums[v4497] = v4495
	end
end)
local v4496 = "SelectionBackground"
local v4497 = 2247
pcall(function()
	local v4498 = enum[v]
	local v4499 = v4498 and v4498[v4496]

	if v4499 then
		Enums[v4499] = v4497
	end
end)
local v4498 = "FindSelectionBackground"
local v4499 = 2248
pcall(function()
	local v4500 = enum[v]
	local v4501 = v4500 and v4500[v4498]

	if v4501 then
		Enums[v4501] = v4499
	end
end)
local v4500 = "MatchingWordBackground"
local v4501 = 2249
pcall(function()
	local v4502 = enum[v]
	local v4503 = v4502 and v4502[v4500]

	if v4503 then
		Enums[v4503] = v4501
	end
end)
local v4502 = "Warning"
local v4503 = 2250
pcall(function()
	local v4504 = enum[v]
	local v4505 = v4504 and v4504[v4502]

	if v4505 then
		Enums[v4505] = v4503
	end
end)
local v4504 = "Error"
local v4505 = 2251
pcall(function()
	local v4506 = enum[v]
	local v4507 = v4506 and v4506[v4504]

	if v4507 then
		Enums[v4507] = v4505
	end
end)
local v4506 = "Info"
local v4507 = 2252
pcall(function()
	local v4508 = enum[v]
	local v4509 = v4508 and v4508[v4506]

	if v4509 then
		Enums[v4509] = v4507
	end
end)
local v4508 = "Hint"
local v4509 = 2253
pcall(function()
	local v4510 = enum[v]
	local v4511 = v4510 and v4510[v4508]

	if v4511 then
		Enums[v4511] = v4509
	end
end)
local v4510 = "Whitespace"
local v4511 = 2254
pcall(function()
	local v4512 = enum[v]
	local v4513 = v4512 and v4512[v4510]

	if v4513 then
		Enums[v4513] = v4511
	end
end)
local v4512 = "ActiveLine"
local v4513 = 2255
pcall(function()
	local v4514 = enum[v]
	local v4515 = v4514 and v4514[v4512]

	if v4515 then
		Enums[v4515] = v4513
	end
end)
local v4514 = "DebuggerCurrentLine"
local v4515 = 2256
pcall(function()
	local v4516 = enum[v]
	local v4517 = v4516 and v4516[v4514]

	if v4517 then
		Enums[v4517] = v4515
	end
end)
local v4516 = "DebuggerErrorLine"
local v4517 = 2257
pcall(function()
	local v4518 = enum[v]
	local v4519 = v4518 and v4518[v4516]

	if v4519 then
		Enums[v4519] = v4517
	end
end)
local v4518 = "Ruler"
local v4519 = 2258
pcall(function()
	local v4520 = enum[v]
	local v4521 = v4520 and v4520[v4518]

	if v4521 then
		Enums[v4521] = v4519
	end
end)
local v4520 = "Bracket"
local v4521 = 2259
pcall(function()
	local v4522 = enum[v]
	local v4523 = v4522 and v4522[v4520]

	if v4523 then
		Enums[v4523] = v4521
	end
end)
local v4522 = "Type"
local v4523 = 2260
pcall(function()
	local v4524 = enum[v]
	local v4525 = v4524 and v4524[v4522]

	if v4525 then
		Enums[v4525] = v4523
	end
end)
local v4524 = "MenuPrimaryText"
local v4525 = 2261
pcall(function()
	local v4526 = enum[v]
	local v4527 = v4526 and v4526[v4524]

	if v4527 then
		Enums[v4527] = v4525
	end
end)
local v4526 = "MenuSecondaryText"
local v4527 = 2262
pcall(function()
	local v4528 = enum[v]
	local v4529 = v4528 and v4528[v4526]

	if v4529 then
		Enums[v4529] = v4527
	end
end)
local v4528 = "MenuSelectedText"
local v4529 = 2263
pcall(function()
	local v4530 = enum[v]
	local v4531 = v4530 and v4530[v4528]

	if v4531 then
		Enums[v4531] = v4529
	end
end)
local v4530 = "MenuBackground"
local v4531 = 2264
pcall(function()
	local v4532 = enum[v]
	local v4533 = v4532 and v4532[v4530]

	if v4533 then
		Enums[v4533] = v4531
	end
end)
local v4532 = "MenuSelectedBackground"
local v4533 = 2265
pcall(function()
	local v4534 = enum[v]
	local v4535 = v4534 and v4534[v4532]

	if v4535 then
		Enums[v4535] = v4533
	end
end)
local v4534 = "MenuScrollbarBackground"
local v4535 = 2266
pcall(function()
	local v4536 = enum[v]
	local v4537 = v4536 and v4536[v4534]

	if v4537 then
		Enums[v4537] = v4535
	end
end)
local v4536 = "MenuScrollbarHandle"
local v4537 = 2267
pcall(function()
	local v4538 = enum[v]
	local v4539 = v4538 and v4538[v4536]

	if v4539 then
		Enums[v4539] = v4537
	end
end)
local v4538 = "MenuBorder"
local v4539 = 2268
pcall(function()
	local v4540 = enum[v]
	local v4541 = v4540 and v4540[v4538]

	if v4541 then
		Enums[v4541] = v4539
	end
end)
local v4540 = "DocViewCodeBackground"
local v4541 = 2269
pcall(function()
	local v4542 = enum[v]
	local v4543 = v4542 and v4542[v4540]

	if v4543 then
		Enums[v4543] = v4541
	end
end)
local v4542 = "AICOOverlayText"
local v4543 = 2270
pcall(function()
	local v4544 = enum[v]
	local v4545 = v4544 and v4544[v4542]

	if v4545 then
		Enums[v4545] = v4543
	end
end)
local v4544 = "AICOOverlayButtonBackground"
local v4545 = 2271
pcall(function()
	local v4546 = enum[v]
	local v4547 = v4546 and v4546[v4544]

	if v4547 then
		Enums[v4547] = v4545
	end
end)
local v4546 = "AICOOverlayButtonBackgroundHover"
local v4547 = 2272
pcall(function()
	local v4548 = enum[v]
	local v4549 = v4548 and v4548[v4546]

	if v4549 then
		Enums[v4549] = v4547
	end
end)
local v4548 = "AICOOverlayButtonBackgroundPressed"
local v4549 = 2273
pcall(function()
	local v4550 = enum[v]
	local v4551 = v4550 and v4550[v4548]

	if v4551 then
		Enums[v4551] = v4549
	end
end)
local v4550 = "IndentationRuler"
local v4551 = 2274
pcall(function()
	local v4552 = enum[v]
	local v4553 = v4552 and v4552[v4550]

	if v4553 then
		Enums[v4553] = v4551
	end
end)
v = "StudioScriptEditorColorPresets"
local v4552 = "RobloxDefault"
local v4553 = 2275
pcall(function()
	local v4554 = enum[v]
	local v4555 = v4554 and v4554[v4552]

	if v4555 then
		Enums[v4555] = v4553
	end
end)
local v4554 = "Extra1"
local v4555 = 2276
pcall(function()
	local v4556 = enum[v]
	local v4557 = v4556 and v4556[v4554]

	if v4557 then
		Enums[v4557] = v4555
	end
end)
local v4556 = "Extra2"
local v4557 = 2277
pcall(function()
	local v4558 = enum[v]
	local v4559 = v4558 and v4558[v4556]

	if v4559 then
		Enums[v4559] = v4557
	end
end)
local v4558 = "Custom"
local v4559 = 2278
pcall(function()
	local v4560 = enum[v]
	local v4561 = v4560 and v4560[v4558]

	if v4561 then
		Enums[v4561] = v4559
	end
end)
v = "StudioStyleGuideColor"
local v4560 = "MainBackground"
local v4561 = 2279
pcall(function()
	local v4562 = enum[v]
	local v4563 = v4562 and v4562[v4560]

	if v4563 then
		Enums[v4563] = v4561
	end
end)
local v4562 = "Titlebar"
local v4563 = 2280
pcall(function()
	local v4564 = enum[v]
	local v4565 = v4564 and v4564[v4562]

	if v4565 then
		Enums[v4565] = v4563
	end
end)
local v4564 = "Dropdown"
local v4565 = 2281
pcall(function()
	local v4566 = enum[v]
	local v4567 = v4566 and v4566[v4564]

	if v4567 then
		Enums[v4567] = v4565
	end
end)
local v4566 = "Tooltip"
local v4567 = 2282
pcall(function()
	local v4568 = enum[v]
	local v4569 = v4568 and v4568[v4566]

	if v4569 then
		Enums[v4569] = v4567
	end
end)
local v4568 = "Notification"
local v4569 = 2283
pcall(function()
	local v4570 = enum[v]
	local v4571 = v4570 and v4570[v4568]

	if v4571 then
		Enums[v4571] = v4569
	end
end)
local v4570 = "ScrollBar"
local v4571 = 2284
pcall(function()
	local v4572 = enum[v]
	local v4573 = v4572 and v4572[v4570]

	if v4573 then
		Enums[v4573] = v4571
	end
end)
local v4572 = "ScrollBarBackground"
local v4573 = 2285
pcall(function()
	local v4574 = enum[v]
	local v4575 = v4574 and v4574[v4572]

	if v4575 then
		Enums[v4575] = v4573
	end
end)
local v4574 = "TabBar"
local v4575 = 2286
pcall(function()
	local v4576 = enum[v]
	local v4577 = v4576 and v4576[v4574]

	if v4577 then
		Enums[v4577] = v4575
	end
end)
local v4576 = "Tab"
local v4577 = 2287
pcall(function()
	local v4578 = enum[v]
	local v4579 = v4578 and v4578[v4576]

	if v4579 then
		Enums[v4579] = v4577
	end
end)
local v4578 = "FilterButtonDefault"
local v4579 = 2288
pcall(function()
	local v4580 = enum[v]
	local v4581 = v4580 and v4580[v4578]

	if v4581 then
		Enums[v4581] = v4579
	end
end)
local v4580 = "FilterButtonHover"
local v4581 = 2289
pcall(function()
	local v4582 = enum[v]
	local v4583 = v4582 and v4582[v4580]

	if v4583 then
		Enums[v4583] = v4581
	end
end)
local v4582 = "FilterButtonChecked"
local v4583 = 2290
pcall(function()
	local v4584 = enum[v]
	local v4585 = v4584 and v4584[v4582]

	if v4585 then
		Enums[v4585] = v4583
	end
end)
local v4584 = "FilterButtonAccent"
local v4585 = 2291
pcall(function()
	local v4586 = enum[v]
	local v4587 = v4586 and v4586[v4584]

	if v4587 then
		Enums[v4587] = v4585
	end
end)
local v4586 = "FilterButtonBorder"
local v4587 = 2292
pcall(function()
	local v4588 = enum[v]
	local v4589 = v4588 and v4588[v4586]

	if v4589 then
		Enums[v4589] = v4587
	end
end)
local v4588 = "FilterButtonBorderAlt"
local v4589 = 2293
pcall(function()
	local v4590 = enum[v]
	local v4591 = v4590 and v4590[v4588]

	if v4591 then
		Enums[v4591] = v4589
	end
end)
local v4590 = "RibbonTab"
local v4591 = 2294
pcall(function()
	local v4592 = enum[v]
	local v4593 = v4592 and v4592[v4590]

	if v4593 then
		Enums[v4593] = v4591
	end
end)
local v4592 = "RibbonTabTopBar"
local v4593 = 2295
pcall(function()
	local v4594 = enum[v]
	local v4595 = v4594 and v4594[v4592]

	if v4595 then
		Enums[v4595] = v4593
	end
end)
local v4594 = "Button"
local v4595 = 2296
pcall(function()
	local v4596 = enum[v]
	local v4597 = v4596 and v4596[v4594]

	if v4597 then
		Enums[v4597] = v4595
	end
end)
local v4596 = "MainButton"
local v4597 = 2297
pcall(function()
	local v4598 = enum[v]
	local v4599 = v4598 and v4598[v4596]

	if v4599 then
		Enums[v4599] = v4597
	end
end)
local v4598 = "RibbonButton"
local v4599 = 2298
pcall(function()
	local v4600 = enum[v]
	local v4601 = v4600 and v4600[v4598]

	if v4601 then
		Enums[v4601] = v4599
	end
end)
local v4600 = "ViewPortBackground"
local v4601 = 2299
pcall(function()
	local v4602 = enum[v]
	local v4603 = v4602 and v4602[v4600]

	if v4603 then
		Enums[v4603] = v4601
	end
end)
local v4602 = "InputFieldBackground"
local v4603 = 2300
pcall(function()
	local v4604 = enum[v]
	local v4605 = v4604 and v4604[v4602]

	if v4605 then
		Enums[v4605] = v4603
	end
end)
local v4604 = "Item"
local v4605 = 2301
pcall(function()
	local v4606 = enum[v]
	local v4607 = v4606 and v4606[v4604]

	if v4607 then
		Enums[v4607] = v4605
	end
end)
local v4606 = "TableItem"
local v4607 = 2302
pcall(function()
	local v4608 = enum[v]
	local v4609 = v4608 and v4608[v4606]

	if v4609 then
		Enums[v4609] = v4607
	end
end)
local v4608 = "CategoryItem"
local v4609 = 2303
pcall(function()
	local v4610 = enum[v]
	local v4611 = v4610 and v4610[v4608]

	if v4611 then
		Enums[v4611] = v4609
	end
end)
local v4610 = "GameSettingsTableItem"
local v4611 = 2304
pcall(function()
	local v4612 = enum[v]
	local v4613 = v4612 and v4612[v4610]

	if v4613 then
		Enums[v4613] = v4611
	end
end)
local v4612 = "GameSettingsTooltip"
local v4613 = 2305
pcall(function()
	local v4614 = enum[v]
	local v4615 = v4614 and v4614[v4612]

	if v4615 then
		Enums[v4615] = v4613
	end
end)
local v4614 = "EmulatorBar"
local v4615 = 2306
pcall(function()
	local v4616 = enum[v]
	local v4617 = v4616 and v4616[v4614]

	if v4617 then
		Enums[v4617] = v4615
	end
end)
local v4616 = "EmulatorDropDown"
local v4617 = 2307
pcall(function()
	local v4618 = enum[v]
	local v4619 = v4618 and v4618[v4616]

	if v4619 then
		Enums[v4619] = v4617
	end
end)
local v4618 = "ColorPickerFrame"
local v4619 = 2308
pcall(function()
	local v4620 = enum[v]
	local v4621 = v4620 and v4620[v4618]

	if v4621 then
		Enums[v4621] = v4619
	end
end)
local v4620 = "CurrentMarker"
local v4621 = 2309
pcall(function()
	local v4622 = enum[v]
	local v4623 = v4622 and v4622[v4620]

	if v4623 then
		Enums[v4623] = v4621
	end
end)
local v4622 = "Border"
local v4623 = 2310
pcall(function()
	local v4624 = enum[v]
	local v4625 = v4624 and v4624[v4622]

	if v4625 then
		Enums[v4625] = v4623
	end
end)
local v4624 = "DropShadow"
local v4625 = 2311
pcall(function()
	local v4626 = enum[v]
	local v4627 = v4626 and v4626[v4624]

	if v4627 then
		Enums[v4627] = v4625
	end
end)
local v4626 = "Shadow"
local v4627 = 2312
pcall(function()
	local v4628 = enum[v]
	local v4629 = v4628 and v4628[v4626]

	if v4629 then
		Enums[v4629] = v4627
	end
end)
local v4628 = "Light"
local v4629 = 2313
pcall(function()
	local v4630 = enum[v]
	local v4631 = v4630 and v4630[v4628]

	if v4631 then
		Enums[v4631] = v4629
	end
end)
local v4630 = "Dark"
local v4631 = 2314
pcall(function()
	local v4632 = enum[v]
	local v4633 = v4632 and v4632[v4630]

	if v4633 then
		Enums[v4633] = v4631
	end
end)
local v4632 = "Mid"
local v4633 = 2315
pcall(function()
	local v4634 = enum[v]
	local v4635 = v4634 and v4634[v4632]

	if v4635 then
		Enums[v4635] = v4633
	end
end)
local v4634 = "MainText"
local v4635 = 2316
pcall(function()
	local v4636 = enum[v]
	local v4637 = v4636 and v4636[v4634]

	if v4637 then
		Enums[v4637] = v4635
	end
end)
local v4636 = "SubText"
local v4637 = 2317
pcall(function()
	local v4638 = enum[v]
	local v4639 = v4638 and v4638[v4636]

	if v4639 then
		Enums[v4639] = v4637
	end
end)
local v4638 = "TitlebarText"
local v4639 = 2318
pcall(function()
	local v4640 = enum[v]
	local v4641 = v4640 and v4640[v4638]

	if v4641 then
		Enums[v4641] = v4639
	end
end)
local v4640 = "BrightText"
local v4641 = 2319
pcall(function()
	local v4642 = enum[v]
	local v4643 = v4642 and v4642[v4640]

	if v4643 then
		Enums[v4643] = v4641
	end
end)
local v4642 = "DimmedText"
local v4643 = 2320
pcall(function()
	local v4644 = enum[v]
	local v4645 = v4644 and v4644[v4642]

	if v4645 then
		Enums[v4645] = v4643
	end
end)
local v4644 = "LinkText"
local v4645 = 2321
pcall(function()
	local v4646 = enum[v]
	local v4647 = v4646 and v4646[v4644]

	if v4647 then
		Enums[v4647] = v4645
	end
end)
local v4646 = "WarningText"
local v4647 = 2322
pcall(function()
	local v4648 = enum[v]
	local v4649 = v4648 and v4648[v4646]

	if v4649 then
		Enums[v4649] = v4647
	end
end)
local v4648 = "ErrorText"
local v4649 = 2323
pcall(function()
	local v4650 = enum[v]
	local v4651 = v4650 and v4650[v4648]

	if v4651 then
		Enums[v4651] = v4649
	end
end)
local v4650 = "InfoText"
local v4651 = 2324
pcall(function()
	local v4652 = enum[v]
	local v4653 = v4652 and v4652[v4650]

	if v4653 then
		Enums[v4653] = v4651
	end
end)
local v4652 = "SensitiveText"
local v4653 = 2325
pcall(function()
	local v4654 = enum[v]
	local v4655 = v4654 and v4654[v4652]

	if v4655 then
		Enums[v4655] = v4653
	end
end)
local v4654 = "ScriptSideWidget"
local v4655 = 2326
pcall(function()
	local v4656 = enum[v]
	local v4657 = v4656 and v4656[v4654]

	if v4657 then
		Enums[v4657] = v4655
	end
end)
local v4656 = "ScriptBackground"
local v4657 = 2327
pcall(function()
	local v4658 = enum[v]
	local v4659 = v4658 and v4658[v4656]

	if v4659 then
		Enums[v4659] = v4657
	end
end)
local v4658 = "ScriptText"
local v4659 = 2328
pcall(function()
	local v4660 = enum[v]
	local v4661 = v4660 and v4660[v4658]

	if v4661 then
		Enums[v4661] = v4659
	end
end)
local v4660 = "ScriptSelectionText"
local v4661 = 2329
pcall(function()
	local v4662 = enum[v]
	local v4663 = v4662 and v4662[v4660]

	if v4663 then
		Enums[v4663] = v4661
	end
end)
local v4662 = "ScriptSelectionBackground"
local v4663 = 2330
pcall(function()
	local v4664 = enum[v]
	local v4665 = v4664 and v4664[v4662]

	if v4665 then
		Enums[v4665] = v4663
	end
end)
local v4664 = "ScriptFindSelectionBackground"
local v4665 = 2331
pcall(function()
	local v4666 = enum[v]
	local v4667 = v4666 and v4666[v4664]

	if v4667 then
		Enums[v4667] = v4665
	end
end)
local v4666 = "ScriptMatchingWordSelectionBackground"
local v4667 = 2332
pcall(function()
	local v4668 = enum[v]
	local v4669 = v4668 and v4668[v4666]

	if v4669 then
		Enums[v4669] = v4667
	end
end)
local v4668 = "ScriptOperator"
local v4669 = 2333
pcall(function()
	local v4670 = enum[v]
	local v4671 = v4670 and v4670[v4668]

	if v4671 then
		Enums[v4671] = v4669
	end
end)
local v4670 = "ScriptNumber"
local v4671 = 2334
pcall(function()
	local v4672 = enum[v]
	local v4673 = v4672 and v4672[v4670]

	if v4673 then
		Enums[v4673] = v4671
	end
end)
local v4672 = "ScriptString"
local v4673 = 2335
pcall(function()
	local v4674 = enum[v]
	local v4675 = v4674 and v4674[v4672]

	if v4675 then
		Enums[v4675] = v4673
	end
end)
local v4674 = "ScriptComment"
local v4675 = 2336
pcall(function()
	local v4676 = enum[v]
	local v4677 = v4676 and v4676[v4674]

	if v4677 then
		Enums[v4677] = v4675
	end
end)
local v4676 = "ScriptKeyword"
local v4677 = 2337
pcall(function()
	local v4678 = enum[v]
	local v4679 = v4678 and v4678[v4676]

	if v4679 then
		Enums[v4679] = v4677
	end
end)
local v4678 = "ScriptBuiltInFunction"
local v4679 = 2338
pcall(function()
	local v4680 = enum[v]
	local v4681 = v4680 and v4680[v4678]

	if v4681 then
		Enums[v4681] = v4679
	end
end)
local v4680 = "ScriptWarning"
local v4681 = 2339
pcall(function()
	local v4682 = enum[v]
	local v4683 = v4682 and v4682[v4680]

	if v4683 then
		Enums[v4683] = v4681
	end
end)
local v4682 = "ScriptError"
local v4683 = 2340
pcall(function()
	local v4684 = enum[v]
	local v4685 = v4684 and v4684[v4682]

	if v4685 then
		Enums[v4685] = v4683
	end
end)
local v4684 = "ScriptInformation"
local v4685 = 2341
pcall(function()
	local v4686 = enum[v]
	local v4687 = v4686 and v4686[v4684]

	if v4687 then
		Enums[v4687] = v4685
	end
end)
local v4686 = "ScriptHint"
local v4687 = 2342
pcall(function()
	local v4688 = enum[v]
	local v4689 = v4688 and v4688[v4686]

	if v4689 then
		Enums[v4689] = v4687
	end
end)
local v4688 = "ScriptWhitespace"
local v4689 = 2343
pcall(function()
	local v4690 = enum[v]
	local v4691 = v4690 and v4690[v4688]

	if v4691 then
		Enums[v4691] = v4689
	end
end)
local v4690 = "ScriptRuler"
local v4691 = 2344
pcall(function()
	local v4692 = enum[v]
	local v4693 = v4692 and v4692[v4690]

	if v4693 then
		Enums[v4693] = v4691
	end
end)
local v4692 = "DocViewCodeBackground"
local v4693 = 2345
pcall(function()
	local v4694 = enum[v]
	local v4695 = v4694 and v4694[v4692]

	if v4695 then
		Enums[v4695] = v4693
	end
end)
local v4694 = "DebuggerCurrentLine"
local v4695 = 2346
pcall(function()
	local v4696 = enum[v]
	local v4697 = v4696 and v4696[v4694]

	if v4697 then
		Enums[v4697] = v4695
	end
end)
local v4696 = "DebuggerErrorLine"
local v4697 = 2347
pcall(function()
	local v4698 = enum[v]
	local v4699 = v4698 and v4698[v4696]

	if v4699 then
		Enums[v4699] = v4697
	end
end)
local v4698 = "DiffFilePathText"
local v4699 = 2348
pcall(function()
	local v4700 = enum[v]
	local v4701 = v4700 and v4700[v4698]

	if v4701 then
		Enums[v4701] = v4699
	end
end)
local v4700 = "DiffTextHunkInfo"
local v4701 = 2349
pcall(function()
	local v4702 = enum[v]
	local v4703 = v4702 and v4702[v4700]

	if v4703 then
		Enums[v4703] = v4701
	end
end)
local v4702 = "DiffTextNoChange"
local v4703 = 2350
pcall(function()
	local v4704 = enum[v]
	local v4705 = v4704 and v4704[v4702]

	if v4705 then
		Enums[v4705] = v4703
	end
end)
local v4704 = "DiffTextAddition"
local v4705 = 2351
pcall(function()
	local v4706 = enum[v]
	local v4707 = v4706 and v4706[v4704]

	if v4707 then
		Enums[v4707] = v4705
	end
end)
local v4706 = "DiffTextDeletion"
local v4707 = 2352
pcall(function()
	local v4708 = enum[v]
	local v4709 = v4708 and v4708[v4706]

	if v4709 then
		Enums[v4709] = v4707
	end
end)
local v4708 = "DiffTextSeparatorBackground"
local v4709 = 2353
pcall(function()
	local v4710 = enum[v]
	local v4711 = v4710 and v4710[v4708]

	if v4711 then
		Enums[v4711] = v4709
	end
end)
local v4710 = "DiffTextNoChangeBackground"
local v4711 = 2354
pcall(function()
	local v4712 = enum[v]
	local v4713 = v4712 and v4712[v4710]

	if v4713 then
		Enums[v4713] = v4711
	end
end)
local v4712 = "DiffTextAdditionBackground"
local v4713 = 2355
pcall(function()
	local v4714 = enum[v]
	local v4715 = v4714 and v4714[v4712]

	if v4715 then
		Enums[v4715] = v4713
	end
end)
local v4714 = "DiffTextDeletionBackground"
local v4715 = 2356
pcall(function()
	local v4716 = enum[v]
	local v4717 = v4716 and v4716[v4714]

	if v4717 then
		Enums[v4717] = v4715
	end
end)
local v4716 = "DiffLineNum"
local v4717 = 2357
pcall(function()
	local v4718 = enum[v]
	local v4719 = v4718 and v4718[v4716]

	if v4719 then
		Enums[v4719] = v4717
	end
end)
local v4718 = "DiffLineNumSeparatorBackground"
local v4719 = 2358
pcall(function()
	local v4720 = enum[v]
	local v4721 = v4720 and v4720[v4718]

	if v4721 then
		Enums[v4721] = v4719
	end
end)
local v4720 = "DiffLineNumNoChangeBackground"
local v4721 = 2359
pcall(function()
	local v4722 = enum[v]
	local v4723 = v4722 and v4722[v4720]

	if v4723 then
		Enums[v4723] = v4721
	end
end)
local v4722 = "DiffLineNumAdditionBackground"
local v4723 = 2360
pcall(function()
	local v4724 = enum[v]
	local v4725 = v4724 and v4724[v4722]

	if v4725 then
		Enums[v4725] = v4723
	end
end)
local v4724 = "DiffLineNumDeletionBackground"
local v4725 = 2361
pcall(function()
	local v4726 = enum[v]
	local v4727 = v4726 and v4726[v4724]

	if v4727 then
		Enums[v4727] = v4725
	end
end)
local v4726 = "DiffFilePathBackground"
local v4727 = 2362
pcall(function()
	local v4728 = enum[v]
	local v4729 = v4728 and v4728[v4726]

	if v4729 then
		Enums[v4729] = v4727
	end
end)
local v4728 = "DiffFilePathBorder"
local v4729 = 2363
pcall(function()
	local v4730 = enum[v]
	local v4731 = v4730 and v4730[v4728]

	if v4731 then
		Enums[v4731] = v4729
	end
end)
local v4730 = "ChatIncomingBgColor"
local v4731 = 2364
pcall(function()
	local v4732 = enum[v]
	local v4733 = v4732 and v4732[v4730]

	if v4733 then
		Enums[v4733] = v4731
	end
end)
local v4732 = "ChatIncomingTextColor"
local v4733 = 2365
pcall(function()
	local v4734 = enum[v]
	local v4735 = v4734 and v4734[v4732]

	if v4735 then
		Enums[v4735] = v4733
	end
end)
local v4734 = "ChatOutgoingBgColor"
local v4735 = 2366
pcall(function()
	local v4736 = enum[v]
	local v4737 = v4736 and v4736[v4734]

	if v4737 then
		Enums[v4737] = v4735
	end
end)
local v4736 = "ChatOutgoingTextColor"
local v4737 = 2367
pcall(function()
	local v4738 = enum[v]
	local v4739 = v4738 and v4738[v4736]

	if v4739 then
		Enums[v4739] = v4737
	end
end)
local v4738 = "ChatModeratedMessageColor"
local v4739 = 2368
pcall(function()
	local v4740 = enum[v]
	local v4741 = v4740 and v4740[v4738]

	if v4741 then
		Enums[v4741] = v4739
	end
end)
local v4740 = "Separator"
local v4741 = 2369
pcall(function()
	local v4742 = enum[v]
	local v4743 = v4742 and v4742[v4740]

	if v4743 then
		Enums[v4743] = v4741
	end
end)
local v4742 = "ButtonBorder"
local v4743 = 2370
pcall(function()
	local v4744 = enum[v]
	local v4745 = v4744 and v4744[v4742]

	if v4745 then
		Enums[v4745] = v4743
	end
end)
local v4744 = "ButtonText"
local v4745 = 2371
pcall(function()
	local v4746 = enum[v]
	local v4747 = v4746 and v4746[v4744]

	if v4747 then
		Enums[v4747] = v4745
	end
end)
local v4746 = "InputFieldBorder"
local v4747 = 2372
pcall(function()
	local v4748 = enum[v]
	local v4749 = v4748 and v4748[v4746]

	if v4749 then
		Enums[v4749] = v4747
	end
end)
local v4748 = "CheckedFieldBackground"
local v4749 = 2373
pcall(function()
	local v4750 = enum[v]
	local v4751 = v4750 and v4750[v4748]

	if v4751 then
		Enums[v4751] = v4749
	end
end)
local v4750 = "CheckedFieldBorder"
local v4751 = 2374
pcall(function()
	local v4752 = enum[v]
	local v4753 = v4752 and v4752[v4750]

	if v4753 then
		Enums[v4753] = v4751
	end
end)
local v4752 = "CheckedFieldIndicator"
local v4753 = 2375
pcall(function()
	local v4754 = enum[v]
	local v4755 = v4754 and v4754[v4752]

	if v4755 then
		Enums[v4755] = v4753
	end
end)
local v4754 = "HeaderSection"
local v4755 = 2376
pcall(function()
	local v4756 = enum[v]
	local v4757 = v4756 and v4756[v4754]

	if v4757 then
		Enums[v4757] = v4755
	end
end)
local v4756 = "Midlight"
local v4757 = 2377
pcall(function()
	local v4758 = enum[v]
	local v4759 = v4758 and v4758[v4756]

	if v4759 then
		Enums[v4759] = v4757
	end
end)
local v4758 = "StatusBar"
local v4759 = 2378
pcall(function()
	local v4760 = enum[v]
	local v4761 = v4760 and v4760[v4758]

	if v4761 then
		Enums[v4761] = v4759
	end
end)
local v4760 = "DialogButton"
local v4761 = 2379
pcall(function()
	local v4762 = enum[v]
	local v4763 = v4762 and v4762[v4760]

	if v4763 then
		Enums[v4763] = v4761
	end
end)
local v4762 = "DialogButtonText"
local v4763 = 2380
pcall(function()
	local v4764 = enum[v]
	local v4765 = v4764 and v4764[v4762]

	if v4765 then
		Enums[v4765] = v4763
	end
end)
local v4764 = "DialogButtonBorder"
local v4765 = 2381
pcall(function()
	local v4766 = enum[v]
	local v4767 = v4766 and v4766[v4764]

	if v4767 then
		Enums[v4767] = v4765
	end
end)
local v4766 = "DialogMainButton"
local v4767 = 2382
pcall(function()
	local v4768 = enum[v]
	local v4769 = v4768 and v4768[v4766]

	if v4769 then
		Enums[v4769] = v4767
	end
end)
local v4768 = "DialogMainButtonText"
local v4769 = 2383
pcall(function()
	local v4770 = enum[v]
	local v4771 = v4770 and v4770[v4768]

	if v4771 then
		Enums[v4771] = v4769
	end
end)
local v4770 = "InfoBarWarningBackground"
local v4771 = 2384
pcall(function()
	local v4772 = enum[v]
	local v4773 = v4772 and v4772[v4770]

	if v4773 then
		Enums[v4773] = v4771
	end
end)
local v4772 = "InfoBarWarningText"
local v4773 = 2385
pcall(function()
	local v4774 = enum[v]
	local v4775 = v4774 and v4774[v4772]

	if v4775 then
		Enums[v4775] = v4773
	end
end)
local v4774 = "ScriptEditorCurrentLine"
local v4775 = 2386
pcall(function()
	local v4776 = enum[v]
	local v4777 = v4776 and v4776[v4774]

	if v4777 then
		Enums[v4777] = v4775
	end
end)
local v4776 = "ScriptMethod"
local v4777 = 2387
pcall(function()
	local v4778 = enum[v]
	local v4779 = v4778 and v4778[v4776]

	if v4779 then
		Enums[v4779] = v4777
	end
end)
local v4778 = "ScriptProperty"
local v4779 = 2388
pcall(function()
	local v4780 = enum[v]
	local v4781 = v4780 and v4780[v4778]

	if v4781 then
		Enums[v4781] = v4779
	end
end)
local v4780 = "ScriptNil"
local v4781 = 2389
pcall(function()
	local v4782 = enum[v]
	local v4783 = v4782 and v4782[v4780]

	if v4783 then
		Enums[v4783] = v4781
	end
end)
local v4782 = "ScriptBool"
local v4783 = 2390
pcall(function()
	local v4784 = enum[v]
	local v4785 = v4784 and v4784[v4782]

	if v4785 then
		Enums[v4785] = v4783
	end
end)
local v4784 = "ScriptFunction"
local v4785 = 2391
pcall(function()
	local v4786 = enum[v]
	local v4787 = v4786 and v4786[v4784]

	if v4787 then
		Enums[v4787] = v4785
	end
end)
local v4786 = "ScriptLocal"
local v4787 = 2392
pcall(function()
	local v4788 = enum[v]
	local v4789 = v4788 and v4788[v4786]

	if v4789 then
		Enums[v4789] = v4787
	end
end)
local v4788 = "ScriptSelf"
local v4789 = 2393
pcall(function()
	local v4790 = enum[v]
	local v4791 = v4790 and v4790[v4788]

	if v4791 then
		Enums[v4791] = v4789
	end
end)
local v4790 = "ScriptLuauKeyword"
local v4791 = 2394
pcall(function()
	local v4792 = enum[v]
	local v4793 = v4792 and v4792[v4790]

	if v4793 then
		Enums[v4793] = v4791
	end
end)
local v4792 = "ScriptFunctionName"
local v4793 = 2395
pcall(function()
	local v4794 = enum[v]
	local v4795 = v4794 and v4794[v4792]

	if v4795 then
		Enums[v4795] = v4793
	end
end)
local v4794 = "ScriptTodo"
local v4795 = 2396
pcall(function()
	local v4796 = enum[v]
	local v4797 = v4796 and v4796[v4794]

	if v4797 then
		Enums[v4797] = v4795
	end
end)
local v4796 = "ScriptBracket"
local v4797 = 2397
pcall(function()
	local v4798 = enum[v]
	local v4799 = v4798 and v4798[v4796]

	if v4799 then
		Enums[v4799] = v4797
	end
end)
local v4798 = "AttributeCog"
local v4799 = 2398
pcall(function()
	local v4800 = enum[v]
	local v4801 = v4800 and v4800[v4798]

	if v4801 then
		Enums[v4801] = v4799
	end
end)
local v4800 = "AICOOverlayText"
local v4801 = 2399
pcall(function()
	local v4802 = enum[v]
	local v4803 = v4802 and v4802[v4800]

	if v4803 then
		Enums[v4803] = v4801
	end
end)
local v4802 = "AICOOverlayButtonBackground"
local v4803 = 2400
pcall(function()
	local v4804 = enum[v]
	local v4805 = v4804 and v4804[v4802]

	if v4805 then
		Enums[v4805] = v4803
	end
end)
local v4804 = "AICOOverlayButtonBackgroundHover"
local v4805 = 2401
pcall(function()
	local v4806 = enum[v]
	local v4807 = v4806 and v4806[v4804]

	if v4807 then
		Enums[v4807] = v4805
	end
end)
local v4806 = "AICOOverlayButtonBackgroundPressed"
local v4807 = 2402
pcall(function()
	local v4808 = enum[v]
	local v4809 = v4808 and v4808[v4806]

	if v4809 then
		Enums[v4809] = v4807
	end
end)
local v4808 = "OnboardingCover"
local v4809 = 2403
pcall(function()
	local v4810 = enum[v]
	local v4811 = v4810 and v4810[v4808]

	if v4811 then
		Enums[v4811] = v4809
	end
end)
local v4810 = "OnboardingHighlight"
local v4811 = 2404
pcall(function()
	local v4812 = enum[v]
	local v4813 = v4812 and v4812[v4810]

	if v4813 then
		Enums[v4813] = v4811
	end
end)
local v4812 = "OnboardingShadow"
local v4813 = 2405
pcall(function()
	local v4814 = enum[v]
	local v4815 = v4814 and v4814[v4812]

	if v4815 then
		Enums[v4815] = v4813
	end
end)
local v4814 = "BreakpointMarker"
local v4815 = 2406
pcall(function()
	local v4816 = enum[v]
	local v4817 = v4816 and v4816[v4814]

	if v4817 then
		Enums[v4817] = v4815
	end
end)
local v4816 = "DiffLineNumHover"
local v4817 = 2407
pcall(function()
	local v4818 = enum[v]
	local v4819 = v4818 and v4818[v4816]

	if v4819 then
		Enums[v4819] = v4817
	end
end)
local v4818 = "DiffLineNumSeparatorBackgroundHover"
local v4819 = 2408
pcall(function()
	local v4820 = enum[v]
	local v4821 = v4820 and v4820[v4818]

	if v4821 then
		Enums[v4821] = v4819
	end
end)
v = "StudioStyleGuideModifier"
local v4820 = "Default"
local v4821 = 2409
pcall(function()
	local v4822 = enum[v]
	local v4823 = v4822 and v4822[v4820]

	if v4823 then
		Enums[v4823] = v4821
	end
end)
local v4822 = "Selected"
local v4823 = 2410
pcall(function()
	local v4824 = enum[v]
	local v4825 = v4824 and v4824[v4822]

	if v4825 then
		Enums[v4825] = v4823
	end
end)
local v4824 = "Pressed"
local v4825 = 2411
pcall(function()
	local v4826 = enum[v]
	local v4827 = v4826 and v4826[v4824]

	if v4827 then
		Enums[v4827] = v4825
	end
end)
local v4826 = "Disabled"
local v4827 = 2412
pcall(function()
	local v4828 = enum[v]
	local v4829 = v4828 and v4828[v4826]

	if v4829 then
		Enums[v4829] = v4827
	end
end)
local v4828 = "Hover"
local v4829 = 2413
pcall(function()
	local v4830 = enum[v]
	local v4831 = v4830 and v4830[v4828]

	if v4831 then
		Enums[v4831] = v4829
	end
end)
v = "Style"
local v4830 = "AlternatingSupports"
local v4831 = 2414
pcall(function()
	local v4832 = enum[v]
	local v4833 = v4832 and v4832[v4830]

	if v4833 then
		Enums[v4833] = v4831
	end
end)
local v4832 = "BridgeStyleSupports"
local v4833 = 2415
pcall(function()
	local v4834 = enum[v]
	local v4835 = v4834 and v4834[v4832]

	if v4835 then
		Enums[v4835] = v4833
	end
end)
local v4834 = "NoSupports"
local v4835 = 2416
pcall(function()
	local v4836 = enum[v]
	local v4837 = v4836 and v4836[v4834]

	if v4837 then
		Enums[v4837] = v4835
	end
end)
v = "SubscriptionExpirationReason"
local v4836 = "ProductInactive"
local v4837 = 2417
pcall(function()
	local v4838 = enum[v]
	local v4839 = v4838 and v4838[v4836]

	if v4839 then
		Enums[v4839] = v4837
	end
end)
local v4838 = "ProductDeleted"
local v4839 = 2418
pcall(function()
	local v4840 = enum[v]
	local v4841 = v4840 and v4840[v4838]

	if v4841 then
		Enums[v4841] = v4839
	end
end)
local v4840 = "SubscriberCancelled"
local v4841 = 2419
pcall(function()
	local v4842 = enum[v]
	local v4843 = v4842 and v4842[v4840]

	if v4843 then
		Enums[v4843] = v4841
	end
end)
local v4842 = "SubscriberRefunded"
local v4843 = 2420
pcall(function()
	local v4844 = enum[v]
	local v4845 = v4844 and v4844[v4842]

	if v4845 then
		Enums[v4845] = v4843
	end
end)
local v4844 = "Lapsed"
local v4845 = 2421
pcall(function()
	local v4846 = enum[v]
	local v4847 = v4846 and v4846[v4844]

	if v4847 then
		Enums[v4847] = v4845
	end
end)
v = "SubscriptionPaymentStatus"
local v4846 = "Paid"
local v4847 = 2422
pcall(function()
	local v4848 = enum[v]
	local v4849 = v4848 and v4848[v4846]

	if v4849 then
		Enums[v4849] = v4847
	end
end)
local v4848 = "Refunded"
local v4849 = 2423
pcall(function()
	local v4850 = enum[v]
	local v4851 = v4850 and v4850[v4848]

	if v4851 then
		Enums[v4851] = v4849
	end
end)
v = "SubscriptionPeriod"
local v4850 = "Month"
local v4851 = 2424
pcall(function()
	local v4852 = enum[v]
	local v4853 = v4852 and v4852[v4850]

	if v4853 then
		Enums[v4853] = v4851
	end
end)
v = "SubscriptionState"
local v4852 = "NeverSubscribed"
local v4853 = 2425
pcall(function()
	local v4854 = enum[v]
	local v4855 = v4854 and v4854[v4852]

	if v4855 then
		Enums[v4855] = v4853
	end
end)
local v4854 = "SubscribedWillRenew"
local v4855 = 2426
pcall(function()
	local v4856 = enum[v]
	local v4857 = v4856 and v4856[v4854]

	if v4857 then
		Enums[v4857] = v4855
	end
end)
local v4856 = "SubscribedWillNotRenew"
local v4857 = 2427
pcall(function()
	local v4858 = enum[v]
	local v4859 = v4858 and v4858[v4856]

	if v4859 then
		Enums[v4859] = v4857
	end
end)
local v4858 = "SubscribedRenewalPaymentPending"
local v4859 = 2428
pcall(function()
	local v4860 = enum[v]
	local v4861 = v4860 and v4860[v4858]

	if v4861 then
		Enums[v4861] = v4859
	end
end)
local v4860 = "Expired"
local v4861 = 2429
pcall(function()
	local v4862 = enum[v]
	local v4863 = v4862 and v4862[v4860]

	if v4863 then
		Enums[v4863] = v4861
	end
end)
v = "SurfaceConstraint"
local v4862 = "None"
local v4863 = 2430
pcall(function()
	local v4864 = enum[v]
	local v4865 = v4864 and v4864[v4862]

	if v4865 then
		Enums[v4865] = v4863
	end
end)
local v4864 = "Hinge"
local v4865 = 2431
pcall(function()
	local v4866 = enum[v]
	local v4867 = v4866 and v4866[v4864]

	if v4867 then
		Enums[v4867] = v4865
	end
end)
local v4866 = "SteppingMotor"
local v4867 = 2432
pcall(function()
	local v4868 = enum[v]
	local v4869 = v4868 and v4868[v4866]

	if v4869 then
		Enums[v4869] = v4867
	end
end)
local v4868 = "Motor"
local v4869 = 2433
pcall(function()
	local v4870 = enum[v]
	local v4871 = v4870 and v4870[v4868]

	if v4871 then
		Enums[v4871] = v4869
	end
end)
v = "SurfaceGuiShape"
local v4870 = "Flat"
local v4871 = 2434
pcall(function()
	local v4872 = enum[v]
	local v4873 = v4872 and v4872[v4870]

	if v4873 then
		Enums[v4873] = v4871
	end
end)
local v4872 = "CurvedHorizontally"
local v4873 = 2435
pcall(function()
	local v4874 = enum[v]
	local v4875 = v4874 and v4874[v4872]

	if v4875 then
		Enums[v4875] = v4873
	end
end)
v = "SurfaceGuiSizingMode"
local v4874 = "FixedSize"
local v4875 = 2436
pcall(function()
	local v4876 = enum[v]
	local v4877 = v4876 and v4876[v4874]

	if v4877 then
		Enums[v4877] = v4875
	end
end)
local v4876 = "PixelsPerStud"
local v4877 = 2437
pcall(function()
	local v4878 = enum[v]
	local v4879 = v4878 and v4878[v4876]

	if v4879 then
		Enums[v4879] = v4877
	end
end)
v = "SurfaceType"
local v4878 = "Smooth"
local v4879 = 2438
pcall(function()
	local v4880 = enum[v]
	local v4881 = v4880 and v4880[v4878]

	if v4881 then
		Enums[v4881] = v4879
	end
end)
local v4880 = "Glue"
local v4881 = 2439
pcall(function()
	local v4882 = enum[v]
	local v4883 = v4882 and v4882[v4880]

	if v4883 then
		Enums[v4883] = v4881
	end
end)
local v4882 = "Weld"
local v4883 = 2440
pcall(function()
	local v4884 = enum[v]
	local v4885 = v4884 and v4884[v4882]

	if v4885 then
		Enums[v4885] = v4883
	end
end)
local v4884 = "Studs"
local v4885 = 2441
pcall(function()
	local v4886 = enum[v]
	local v4887 = v4886 and v4886[v4884]

	if v4887 then
		Enums[v4887] = v4885
	end
end)
local v4886 = "Inlet"
local v4887 = 2442
pcall(function()
	local v4888 = enum[v]
	local v4889 = v4888 and v4888[v4886]

	if v4889 then
		Enums[v4889] = v4887
	end
end)
local v4888 = "Universal"
local v4889 = 2443
pcall(function()
	local v4890 = enum[v]
	local v4891 = v4890 and v4890[v4888]

	if v4891 then
		Enums[v4891] = v4889
	end
end)
local v4890 = "Hinge"
local v4891 = 2444
pcall(function()
	local v4892 = enum[v]
	local v4893 = v4892 and v4892[v4890]

	if v4893 then
		Enums[v4893] = v4891
	end
end)
local v4892 = "Motor"
local v4893 = 2445
pcall(function()
	local v4894 = enum[v]
	local v4895 = v4894 and v4894[v4892]

	if v4895 then
		Enums[v4895] = v4893
	end
end)
local v4894 = "SteppingMotor"
local v4895 = 2446
pcall(function()
	local v4896 = enum[v]
	local v4897 = v4896 and v4896[v4894]

	if v4897 then
		Enums[v4897] = v4895
	end
end)
local v4896 = "SmoothNoOutlines"
local v4897 = 2447
pcall(function()
	local v4898 = enum[v]
	local v4899 = v4898 and v4898[v4896]

	if v4899 then
		Enums[v4899] = v4897
	end
end)
v = "SwipeDirection"
local v4898 = "Right"
local v4899 = 2448
pcall(function()
	local v4900 = enum[v]
	local v4901 = v4900 and v4900[v4898]

	if v4901 then
		Enums[v4901] = v4899
	end
end)
local v4900 = "Left"
local v4901 = 2449
pcall(function()
	local v4902 = enum[v]
	local v4903 = v4902 and v4902[v4900]

	if v4903 then
		Enums[v4903] = v4901
	end
end)
local v4902 = "Up"
local v4903 = 2450
pcall(function()
	local v4904 = enum[v]
	local v4905 = v4904 and v4904[v4902]

	if v4905 then
		Enums[v4905] = v4903
	end
end)
local v4904 = "Down"
local v4905 = 2451
pcall(function()
	local v4906 = enum[v]
	local v4907 = v4906 and v4906[v4904]

	if v4907 then
		Enums[v4907] = v4905
	end
end)
local v4906 = "None"
local v4907 = 2452
pcall(function()
	local v4908 = enum[v]
	local v4909 = v4908 and v4908[v4906]

	if v4909 then
		Enums[v4909] = v4907
	end
end)
v = "SystemThemeValue"
local v4908 = "error"
local v4909 = 2453
pcall(function()
	local v4910 = enum[v]
	local v4911 = v4910 and v4910[v4908]

	if v4911 then
		Enums[v4911] = v4909
	end
end)
local v4910 = "light"
local v4911 = 2454
pcall(function()
	local v4912 = enum[v]
	local v4913 = v4912 and v4912[v4910]

	if v4913 then
		Enums[v4913] = v4911
	end
end)
local v4912 = "dark"
local v4913 = 2455
pcall(function()
	local v4914 = enum[v]
	local v4915 = v4914 and v4914[v4912]

	if v4915 then
		Enums[v4915] = v4913
	end
end)
local v4914 = "systemLight"
local v4915 = 2456
pcall(function()
	local v4916 = enum[v]
	local v4917 = v4916 and v4916[v4914]

	if v4917 then
		Enums[v4917] = v4915
	end
end)
local v4916 = "systemDark"
local v4917 = 2457
pcall(function()
	local v4918 = enum[v]
	local v4919 = v4918 and v4918[v4916]

	if v4919 then
		Enums[v4919] = v4917
	end
end)
v = "TableMajorAxis"
local v4918 = "RowMajor"
local v4919 = 2458
pcall(function()
	local v4920 = enum[v]
	local v4921 = v4920 and v4920[v4918]

	if v4921 then
		Enums[v4921] = v4919
	end
end)
local v4920 = "ColumnMajor"
local v4921 = 2459
pcall(function()
	local v4922 = enum[v]
	local v4923 = v4922 and v4922[v4920]

	if v4923 then
		Enums[v4923] = v4921
	end
end)
v = "TeamCreateErrorState"
local v4922 = "PlaceSizeTooLarge"
local v4923 = 2460
pcall(function()
	local v4924 = enum[v]
	local v4925 = v4924 and v4924[v4922]

	if v4925 then
		Enums[v4925] = v4923
	end
end)
local v4924 = "PlaceSizeApproachingLimit"
local v4925 = 2461
pcall(function()
	local v4926 = enum[v]
	local v4927 = v4926 and v4926[v4924]

	if v4927 then
		Enums[v4927] = v4925
	end
end)
local v4926 = "NoError"
local v4927 = 2462
pcall(function()
	local v4928 = enum[v]
	local v4929 = v4928 and v4928[v4926]

	if v4929 then
		Enums[v4929] = v4927
	end
end)
v = "Technology"
local v4928 = "Voxel"
local v4929 = 2463
pcall(function()
	local v4930 = enum[v]
	local v4931 = v4930 and v4930[v4928]

	if v4931 then
		Enums[v4931] = v4929
	end
end)
local v4930 = "Compatibility"
local v4931 = 2464
pcall(function()
	local v4932 = enum[v]
	local v4933 = v4932 and v4932[v4930]

	if v4933 then
		Enums[v4933] = v4931
	end
end)
local v4932 = "ShadowMap"
local v4933 = 2465
pcall(function()
	local v4934 = enum[v]
	local v4935 = v4934 and v4934[v4932]

	if v4935 then
		Enums[v4935] = v4933
	end
end)
local v4934 = "Future"
local v4935 = 2466
pcall(function()
	local v4936 = enum[v]
	local v4937 = v4936 and v4936[v4934]

	if v4937 then
		Enums[v4937] = v4935
	end
end)
local v4936 = "Legacy"
local v4937 = 2467
pcall(function()
	local v4938 = enum[v]
	local v4939 = v4938 and v4938[v4936]

	if v4939 then
		Enums[v4939] = v4937
	end
end)
local v4938 = "Unified"
local v4939 = 2468
pcall(function()
	local v4940 = enum[v]
	local v4941 = v4940 and v4940[v4938]

	if v4941 then
		Enums[v4941] = v4939
	end
end)
v = "TeleportMethod"
local v4940 = "TeleportToSpawnByName"
local v4941 = 2469
pcall(function()
	local v4942 = enum[v]
	local v4943 = v4942 and v4942[v4940]

	if v4943 then
		Enums[v4943] = v4941
	end
end)
local v4942 = "TeleportToPlaceInstance"
local v4943 = 2470
pcall(function()
	local v4944 = enum[v]
	local v4945 = v4944 and v4944[v4942]

	if v4945 then
		Enums[v4945] = v4943
	end
end)
local v4944 = "TeleportToPrivateServer"
local v4945 = 2471
pcall(function()
	local v4946 = enum[v]
	local v4947 = v4946 and v4946[v4944]

	if v4947 then
		Enums[v4947] = v4945
	end
end)
local v4946 = "TeleportPartyAsync"
local v4947 = 2472
pcall(function()
	local v4948 = enum[v]
	local v4949 = v4948 and v4948[v4946]

	if v4949 then
		Enums[v4949] = v4947
	end
end)
local v4948 = "TeleportToVIPServer"
local v4949 = 2473
pcall(function()
	local v4950 = enum[v]
	local v4951 = v4950 and v4950[v4948]

	if v4951 then
		Enums[v4951] = v4949
	end
end)
local v4950 = "TeleportToInstanceBack"
local v4951 = 2474
pcall(function()
	local v4952 = enum[v]
	local v4953 = v4952 and v4952[v4950]

	if v4953 then
		Enums[v4953] = v4951
	end
end)
local v4952 = "TeleportUnknown"
local v4953 = 2475
pcall(function()
	local v4954 = enum[v]
	local v4955 = v4954 and v4954[v4952]

	if v4955 then
		Enums[v4955] = v4953
	end
end)
v = "TeleportResult"
local v4954 = "Success"
local v4955 = 2476
pcall(function()
	local v4956 = enum[v]
	local v4957 = v4956 and v4956[v4954]

	if v4957 then
		Enums[v4957] = v4955
	end
end)
local v4956 = "Failure"
local v4957 = 2477
pcall(function()
	local v4958 = enum[v]
	local v4959 = v4958 and v4958[v4956]

	if v4959 then
		Enums[v4959] = v4957
	end
end)
local v4958 = "GameNotFound"
local v4959 = 2478
pcall(function()
	local v4960 = enum[v]
	local v4961 = v4960 and v4960[v4958]

	if v4961 then
		Enums[v4961] = v4959
	end
end)
local v4960 = "GameEnded"
local v4961 = 2479
pcall(function()
	local v4962 = enum[v]
	local v4963 = v4962 and v4962[v4960]

	if v4963 then
		Enums[v4963] = v4961
	end
end)
local v4962 = "GameFull"
local v4963 = 2480
pcall(function()
	local v4964 = enum[v]
	local v4965 = v4964 and v4964[v4962]

	if v4965 then
		Enums[v4965] = v4963
	end
end)
local v4964 = "Unauthorized"
local v4965 = 2481
pcall(function()
	local v4966 = enum[v]
	local v4967 = v4966 and v4966[v4964]

	if v4967 then
		Enums[v4967] = v4965
	end
end)
local v4966 = "Flooded"
local v4967 = 2482
pcall(function()
	local v4968 = enum[v]
	local v4969 = v4968 and v4968[v4966]

	if v4969 then
		Enums[v4969] = v4967
	end
end)
local v4968 = "IsTeleporting"
local v4969 = 2483
pcall(function()
	local v4970 = enum[v]
	local v4971 = v4970 and v4970[v4968]

	if v4971 then
		Enums[v4971] = v4969
	end
end)
v = "TeleportState"
local v4970 = "RequestedFromServer"
local v4971 = 2484
pcall(function()
	local v4972 = enum[v]
	local v4973 = v4972 and v4972[v4970]

	if v4973 then
		Enums[v4973] = v4971
	end
end)
local v4972 = "Started"
local v4973 = 2485
pcall(function()
	local v4974 = enum[v]
	local v4975 = v4974 and v4974[v4972]

	if v4975 then
		Enums[v4975] = v4973
	end
end)
local v4974 = "WaitingForServer"
local v4975 = 2486
pcall(function()
	local v4976 = enum[v]
	local v4977 = v4976 and v4976[v4974]

	if v4977 then
		Enums[v4977] = v4975
	end
end)
local v4976 = "Failed"
local v4977 = 2487
pcall(function()
	local v4978 = enum[v]
	local v4979 = v4978 and v4978[v4976]

	if v4979 then
		Enums[v4979] = v4977
	end
end)
local v4978 = "InProgress"
local v4979 = 2488
pcall(function()
	local v4980 = enum[v]
	local v4981 = v4980 and v4980[v4978]

	if v4981 then
		Enums[v4981] = v4979
	end
end)
v = "TeleportType"
local v4980 = "ToPlace"
local v4981 = 2489
pcall(function()
	local v4982 = enum[v]
	local v4983 = v4982 and v4982[v4980]

	if v4983 then
		Enums[v4983] = v4981
	end
end)
local v4982 = "ToInstance"
local v4983 = 2490
pcall(function()
	local v4984 = enum[v]
	local v4985 = v4984 and v4984[v4982]

	if v4985 then
		Enums[v4985] = v4983
	end
end)
local v4984 = "ToReservedServer"
local v4985 = 2491
pcall(function()
	local v4986 = enum[v]
	local v4987 = v4986 and v4986[v4984]

	if v4987 then
		Enums[v4987] = v4985
	end
end)
local v4986 = "ToVIPServer"
local v4987 = 2492
pcall(function()
	local v4988 = enum[v]
	local v4989 = v4988 and v4988[v4986]

	if v4989 then
		Enums[v4989] = v4987
	end
end)
local v4988 = "ToInstanceBack"
local v4989 = 2493
pcall(function()
	local v4990 = enum[v]
	local v4991 = v4990 and v4990[v4988]

	if v4991 then
		Enums[v4991] = v4989
	end
end)
v = "TerrainAcquisitionMethod"
local v4990 = "None"
local v4991 = 2494
pcall(function()
	local v4992 = enum[v]
	local v4993 = v4992 and v4992[v4990]

	if v4993 then
		Enums[v4993] = v4991
	end
end)
local v4992 = "Legacy"
local v4993 = 2495
pcall(function()
	local v4994 = enum[v]
	local v4995 = v4994 and v4994[v4992]

	if v4995 then
		Enums[v4995] = v4993
	end
end)
local v4994 = "Template"
local v4995 = 2496
pcall(function()
	local v4996 = enum[v]
	local v4997 = v4996 and v4996[v4994]

	if v4997 then
		Enums[v4997] = v4995
	end
end)
local v4996 = "Generate"
local v4997 = 2497
pcall(function()
	local v4998 = enum[v]
	local v4999 = v4998 and v4998[v4996]

	if v4999 then
		Enums[v4999] = v4997
	end
end)
local v4998 = "Import"
local v4999 = 2498
pcall(function()
	local v5000 = enum[v]
	local v5001 = v5000 and v5000[v4998]

	if v5001 then
		Enums[v5001] = v4999
	end
end)
local v5000 = "Convert"
local v5001 = 2499
pcall(function()
	local v5002 = enum[v]
	local v5003 = v5002 and v5002[v5000]

	if v5003 then
		Enums[v5003] = v5001
	end
end)
local v5002 = "EditAddTool"
local v5003 = 2500
pcall(function()
	local v5004 = enum[v]
	local v5005 = v5004 and v5004[v5002]

	if v5005 then
		Enums[v5005] = v5003
	end
end)
local v5004 = "EditSeaLevelTool"
local v5005 = 2501
pcall(function()
	local v5006 = enum[v]
	local v5007 = v5006 and v5006[v5004]

	if v5007 then
		Enums[v5007] = v5005
	end
end)
local v5006 = "EditReplaceTool"
local v5007 = 2502
pcall(function()
	local v5008 = enum[v]
	local v5009 = v5008 and v5008[v5006]

	if v5009 then
		Enums[v5009] = v5007
	end
end)
local v5008 = "RegionFillTool"
local v5009 = 2503
pcall(function()
	local v5010 = enum[v]
	local v5011 = v5010 and v5010[v5008]

	if v5011 then
		Enums[v5011] = v5009
	end
end)
local v5010 = "RegionPasteTool"
local v5011 = 2504
pcall(function()
	local v5012 = enum[v]
	local v5013 = v5012 and v5012[v5010]

	if v5013 then
		Enums[v5013] = v5011
	end
end)
local v5012 = "Other"
local v5013 = 2505
pcall(function()
	local v5014 = enum[v]
	local v5015 = v5014 and v5014[v5012]

	if v5015 then
		Enums[v5015] = v5013
	end
end)
v = "TerrainFace"
local v5014 = "Top"
local v5015 = 2506
pcall(function()
	local v5016 = enum[v]
	local v5017 = v5016 and v5016[v5014]

	if v5017 then
		Enums[v5017] = v5015
	end
end)
local v5016 = "Side"
local v5017 = 2507
pcall(function()
	local v5018 = enum[v]
	local v5019 = v5018 and v5018[v5016]

	if v5019 then
		Enums[v5019] = v5017
	end
end)
local v5018 = "Bottom"
local v5019 = 2508
pcall(function()
	local v5020 = enum[v]
	local v5021 = v5020 and v5020[v5018]

	if v5021 then
		Enums[v5021] = v5019
	end
end)
v = "TextChatMessageStatus"
local v5020 = "Unknown"
local v5021 = 2509
pcall(function()
	local v5022 = enum[v]
	local v5023 = v5022 and v5022[v5020]

	if v5023 then
		Enums[v5023] = v5021
	end
end)
local v5022 = "Success"
local v5023 = 2510
pcall(function()
	local v5024 = enum[v]
	local v5025 = v5024 and v5024[v5022]

	if v5025 then
		Enums[v5025] = v5023
	end
end)
local v5024 = "Sending"
local v5025 = 2511
pcall(function()
	local v5026 = enum[v]
	local v5027 = v5026 and v5026[v5024]

	if v5027 then
		Enums[v5027] = v5025
	end
end)
local v5026 = "TextFilterFailed"
local v5027 = 2512
pcall(function()
	local v5028 = enum[v]
	local v5029 = v5028 and v5028[v5026]

	if v5029 then
		Enums[v5029] = v5027
	end
end)
local v5028 = "Floodchecked"
local v5029 = 2513
pcall(function()
	local v5030 = enum[v]
	local v5031 = v5030 and v5030[v5028]

	if v5031 then
		Enums[v5031] = v5029
	end
end)
local v5030 = "InvalidPrivacySettings"
local v5031 = 2514
pcall(function()
	local v5032 = enum[v]
	local v5033 = v5032 and v5032[v5030]

	if v5033 then
		Enums[v5033] = v5031
	end
end)
local v5032 = "InvalidTextChannelPermissions"
local v5033 = 2515
pcall(function()
	local v5034 = enum[v]
	local v5035 = v5034 and v5034[v5032]

	if v5035 then
		Enums[v5035] = v5033
	end
end)
local v5034 = "MessageTooLong"
local v5035 = 2516
pcall(function()
	local v5036 = enum[v]
	local v5037 = v5036 and v5036[v5034]

	if v5037 then
		Enums[v5037] = v5035
	end
end)
local v5036 = "ModerationTimeout"
local v5037 = 2517
pcall(function()
	local v5038 = enum[v]
	local v5039 = v5038 and v5038[v5036]

	if v5039 then
		Enums[v5039] = v5037
	end
end)
v = "TextDirection"
local v5038 = "Auto"
local v5039 = 2518
pcall(function()
	local v5040 = enum[v]
	local v5041 = v5040 and v5040[v5038]

	if v5041 then
		Enums[v5041] = v5039
	end
end)
local v5040 = "LeftToRight"
local v5041 = 2519
pcall(function()
	local v5042 = enum[v]
	local v5043 = v5042 and v5042[v5040]

	if v5043 then
		Enums[v5043] = v5041
	end
end)
local v5042 = "RightToLeft"
local v5043 = 2520
pcall(function()
	local v5044 = enum[v]
	local v5045 = v5044 and v5044[v5042]

	if v5045 then
		Enums[v5045] = v5043
	end
end)
v = "TextFilterContext"
local v5044 = "PublicChat"
local v5045 = 2521
pcall(function()
	local v5046 = enum[v]
	local v5047 = v5046 and v5046[v5044]

	if v5047 then
		Enums[v5047] = v5045
	end
end)
local v5046 = "PrivateChat"
local v5047 = 2522
pcall(function()
	local v5048 = enum[v]
	local v5049 = v5048 and v5048[v5046]

	if v5049 then
		Enums[v5049] = v5047
	end
end)
v = "TextInputType"
local v5048 = "Default"
local v5049 = 2523
pcall(function()
	local v5050 = enum[v]
	local v5051 = v5050 and v5050[v5048]

	if v5051 then
		Enums[v5051] = v5049
	end
end)
local v5050 = "NoSuggestions"
local v5051 = 2524
pcall(function()
	local v5052 = enum[v]
	local v5053 = v5052 and v5052[v5050]

	if v5053 then
		Enums[v5053] = v5051
	end
end)
local v5052 = "Number"
local v5053 = 2525
pcall(function()
	local v5054 = enum[v]
	local v5055 = v5054 and v5054[v5052]

	if v5055 then
		Enums[v5055] = v5053
	end
end)
local v5054 = "Email"
local v5055 = 2526
pcall(function()
	local v5056 = enum[v]
	local v5057 = v5056 and v5056[v5054]

	if v5057 then
		Enums[v5057] = v5055
	end
end)
local v5056 = "Phone"
local v5057 = 2527
pcall(function()
	local v5058 = enum[v]
	local v5059 = v5058 and v5058[v5056]

	if v5059 then
		Enums[v5059] = v5057
	end
end)
local v5058 = "Password"
local v5059 = 2528
pcall(function()
	local v5060 = enum[v]
	local v5061 = v5060 and v5060[v5058]

	if v5061 then
		Enums[v5061] = v5059
	end
end)
local v5060 = "PasswordShown"
local v5061 = 2529
pcall(function()
	local v5062 = enum[v]
	local v5063 = v5062 and v5062[v5060]

	if v5063 then
		Enums[v5063] = v5061
	end
end)
local v5062 = "Username"
local v5063 = 2530
pcall(function()
	local v5064 = enum[v]
	local v5065 = v5064 and v5064[v5062]

	if v5065 then
		Enums[v5065] = v5063
	end
end)
local v5064 = "OneTimePassword"
local v5065 = 2531
pcall(function()
	local v5066 = enum[v]
	local v5067 = v5066 and v5066[v5064]

	if v5067 then
		Enums[v5067] = v5065
	end
end)
v = "TextTruncate"
local v5066 = "None"
local v5067 = 2532
pcall(function()
	local v5068 = enum[v]
	local v5069 = v5068 and v5068[v5066]

	if v5069 then
		Enums[v5069] = v5067
	end
end)
local v5068 = "AtEnd"
local v5069 = 2533
pcall(function()
	local v5070 = enum[v]
	local v5071 = v5070 and v5070[v5068]

	if v5071 then
		Enums[v5071] = v5069
	end
end)
local v5070 = "SplitWord"
local v5071 = 2534
pcall(function()
	local v5072 = enum[v]
	local v5073 = v5072 and v5072[v5070]

	if v5073 then
		Enums[v5073] = v5071
	end
end)
v = "TextXAlignment"
local v5072 = "Left"
local v5073 = 2535
pcall(function()
	local v5074 = enum[v]
	local v5075 = v5074 and v5074[v5072]

	if v5075 then
		Enums[v5075] = v5073
	end
end)
local v5074 = "Right"
local v5075 = 2536
pcall(function()
	local v5076 = enum[v]
	local v5077 = v5076 and v5076[v5074]

	if v5077 then
		Enums[v5077] = v5075
	end
end)
local v5076 = "Center"
local v5077 = 2537
pcall(function()
	local v5078 = enum[v]
	local v5079 = v5078 and v5078[v5076]

	if v5079 then
		Enums[v5079] = v5077
	end
end)
v = "TextYAlignment"
local v5078 = "Top"
local v5079 = 2538
pcall(function()
	local v5080 = enum[v]
	local v5081 = v5080 and v5080[v5078]

	if v5081 then
		Enums[v5081] = v5079
	end
end)
local v5080 = "Center"
local v5081 = 2539
pcall(function()
	local v5082 = enum[v]
	local v5083 = v5082 and v5082[v5080]

	if v5083 then
		Enums[v5083] = v5081
	end
end)
local v5082 = "Bottom"
local v5083 = 2540
pcall(function()
	local v5084 = enum[v]
	local v5085 = v5084 and v5084[v5082]

	if v5085 then
		Enums[v5085] = v5083
	end
end)
v = "TextureMode"
local v5084 = "Stretch"
local v5085 = 2541
pcall(function()
	local v5086 = enum[v]
	local v5087 = v5086 and v5086[v5084]

	if v5087 then
		Enums[v5087] = v5085
	end
end)
local v5086 = "Wrap"
local v5087 = 2542
pcall(function()
	local v5088 = enum[v]
	local v5089 = v5088 and v5088[v5086]

	if v5089 then
		Enums[v5089] = v5087
	end
end)
local v5088 = "Static"
local v5089 = 2543
pcall(function()
	local v5090 = enum[v]
	local v5091 = v5090 and v5090[v5088]

	if v5091 then
		Enums[v5091] = v5089
	end
end)
v = "TextureQueryType"
local v5090 = "NonHumanoid"
local v5091 = 2544
pcall(function()
	local v5092 = enum[v]
	local v5093 = v5092 and v5092[v5090]

	if v5093 then
		Enums[v5093] = v5091
	end
end)
local v5092 = "NonHumanoidOrphaned"
local v5093 = 2545
pcall(function()
	local v5094 = enum[v]
	local v5095 = v5094 and v5094[v5092]

	if v5095 then
		Enums[v5095] = v5093
	end
end)
local v5094 = "Humanoid"
local v5095 = 2546
pcall(function()
	local v5096 = enum[v]
	local v5097 = v5096 and v5096[v5094]

	if v5097 then
		Enums[v5097] = v5095
	end
end)
local v5096 = "HumanoidOrphaned"
local v5097 = 2547
pcall(function()
	local v5098 = enum[v]
	local v5099 = v5098 and v5098[v5096]

	if v5099 then
		Enums[v5099] = v5097
	end
end)
v = "ThreadPoolConfig"
local v5098 = "PerCore4"
local v5099 = 2548
pcall(function()
	local v5100 = enum[v]
	local v5101 = v5100 and v5100[v5098]

	if v5101 then
		Enums[v5101] = v5099
	end
end)
local v5100 = "PerCore3"
local v5101 = 2549
pcall(function()
	local v5102 = enum[v]
	local v5103 = v5102 and v5102[v5100]

	if v5103 then
		Enums[v5103] = v5101
	end
end)
local v5102 = "PerCore2"
local v5103 = 2550
pcall(function()
	local v5104 = enum[v]
	local v5105 = v5104 and v5104[v5102]

	if v5105 then
		Enums[v5105] = v5103
	end
end)
local v5104 = "PerCore1"
local v5105 = 2551
pcall(function()
	local v5106 = enum[v]
	local v5107 = v5106 and v5106[v5104]

	if v5107 then
		Enums[v5107] = v5105
	end
end)
local v5106 = "Auto"
local v5107 = 2552
pcall(function()
	local v5108 = enum[v]
	local v5109 = v5108 and v5108[v5106]

	if v5109 then
		Enums[v5109] = v5107
	end
end)
local v5108 = "Threads1"
local v5109 = 2553
pcall(function()
	local v5110 = enum[v]
	local v5111 = v5110 and v5110[v5108]

	if v5111 then
		Enums[v5111] = v5109
	end
end)
local v5110 = "Threads2"
local v5111 = 2554
pcall(function()
	local v5112 = enum[v]
	local v5113 = v5112 and v5112[v5110]

	if v5113 then
		Enums[v5113] = v5111
	end
end)
local v5112 = "Threads3"
local v5113 = 2555
pcall(function()
	local v5114 = enum[v]
	local v5115 = v5114 and v5114[v5112]

	if v5115 then
		Enums[v5115] = v5113
	end
end)
local v5114 = "Threads4"
local v5115 = 2556
pcall(function()
	local v5116 = enum[v]
	local v5117 = v5116 and v5116[v5114]

	if v5117 then
		Enums[v5117] = v5115
	end
end)
local v5116 = "Threads8"
local v5117 = 2557
pcall(function()
	local v5118 = enum[v]
	local v5119 = v5118 and v5118[v5116]

	if v5119 then
		Enums[v5119] = v5117
	end
end)
local v5118 = "Threads16"
local v5119 = 2558
pcall(function()
	local v5120 = enum[v]
	local v5121 = v5120 and v5120[v5118]

	if v5121 then
		Enums[v5121] = v5119
	end
end)
v = "ThrottlingPriority"
local v5120 = "Extreme"
local v5121 = 2559
pcall(function()
	local v5122 = enum[v]
	local v5123 = v5122 and v5122[v5120]

	if v5123 then
		Enums[v5123] = v5121
	end
end)
local v5122 = "ElevatedOnServer"
local v5123 = 2560
pcall(function()
	local v5124 = enum[v]
	local v5125 = v5124 and v5124[v5122]

	if v5125 then
		Enums[v5125] = v5123
	end
end)
local v5124 = "Default"
local v5125 = 2561
pcall(function()
	local v5126 = enum[v]
	local v5127 = v5126 and v5126[v5124]

	if v5127 then
		Enums[v5127] = v5125
	end
end)
v = "ThumbnailSize"
local v5126 = "Size48x48"
local v5127 = 2562
pcall(function()
	local v5128 = enum[v]
	local v5129 = v5128 and v5128[v5126]

	if v5129 then
		Enums[v5129] = v5127
	end
end)
local v5128 = "Size180x180"
local v5129 = 2563
pcall(function()
	local v5130 = enum[v]
	local v5131 = v5130 and v5130[v5128]

	if v5131 then
		Enums[v5131] = v5129
	end
end)
local v5130 = "Size420x420"
local v5131 = 2564
pcall(function()
	local v5132 = enum[v]
	local v5133 = v5132 and v5132[v5130]

	if v5133 then
		Enums[v5133] = v5131
	end
end)
local v5132 = "Size60x60"
local v5133 = 2565
pcall(function()
	local v5134 = enum[v]
	local v5135 = v5134 and v5134[v5132]

	if v5135 then
		Enums[v5135] = v5133
	end
end)
local v5134 = "Size100x100"
local v5135 = 2566
pcall(function()
	local v5136 = enum[v]
	local v5137 = v5136 and v5136[v5134]

	if v5137 then
		Enums[v5137] = v5135
	end
end)
local v5136 = "Size150x150"
local v5137 = 2567
pcall(function()
	local v5138 = enum[v]
	local v5139 = v5138 and v5138[v5136]

	if v5139 then
		Enums[v5139] = v5137
	end
end)
local v5138 = "Size352x352"
local v5139 = 2568
pcall(function()
	local v5140 = enum[v]
	local v5141 = v5140 and v5140[v5138]

	if v5141 then
		Enums[v5141] = v5139
	end
end)
v = "ThumbnailType"
local v5140 = "HeadShot"
local v5141 = 2569
pcall(function()
	local v5142 = enum[v]
	local v5143 = v5142 and v5142[v5140]

	if v5143 then
		Enums[v5143] = v5141
	end
end)
local v5142 = "AvatarBust"
local v5143 = 2570
pcall(function()
	local v5144 = enum[v]
	local v5145 = v5144 and v5144[v5142]

	if v5145 then
		Enums[v5145] = v5143
	end
end)
local v5144 = "AvatarThumbnail"
local v5145 = 2571
pcall(function()
	local v5146 = enum[v]
	local v5147 = v5146 and v5146[v5144]

	if v5147 then
		Enums[v5147] = v5145
	end
end)
v = "TickCountSampleMethod"
local v5146 = "Fast"
local v5147 = 2572
pcall(function()
	local v5148 = enum[v]
	local v5149 = v5148 and v5148[v5146]

	if v5149 then
		Enums[v5149] = v5147
	end
end)
local v5148 = "Benchmark"
local v5149 = 2573
pcall(function()
	local v5150 = enum[v]
	local v5151 = v5150 and v5150[v5148]

	if v5151 then
		Enums[v5151] = v5149
	end
end)
local v5150 = "Precise"
local v5151 = 2574
pcall(function()
	local v5152 = enum[v]
	local v5153 = v5152 and v5152[v5150]

	if v5153 then
		Enums[v5153] = v5151
	end
end)
v = "TonemapperPreset"
local v5152 = "Default"
local v5153 = 2575
pcall(function()
	local v5154 = enum[v]
	local v5155 = v5154 and v5154[v5152]

	if v5155 then
		Enums[v5155] = v5153
	end
end)
local v5154 = "Retro"
local v5155 = 2576
pcall(function()
	local v5156 = enum[v]
	local v5157 = v5156 and v5156[v5154]

	if v5157 then
		Enums[v5157] = v5155
	end
end)
v = "TopBottom"
local v5156 = "Top"
local v5157 = 2577
pcall(function()
	local v5158 = enum[v]
	local v5159 = v5158 and v5158[v5156]

	if v5159 then
		Enums[v5159] = v5157
	end
end)
local v5158 = "Center"
local v5159 = 2578
pcall(function()
	local v5160 = enum[v]
	local v5161 = v5160 and v5160[v5158]

	if v5161 then
		Enums[v5161] = v5159
	end
end)
local v5160 = "Bottom"
local v5161 = 2579
pcall(function()
	local v5162 = enum[v]
	local v5163 = v5162 and v5162[v5160]

	if v5163 then
		Enums[v5163] = v5161
	end
end)
v = "TouchCameraMovementMode"
local v5162 = "Default"
local v5163 = 2580
pcall(function()
	local v5164 = enum[v]
	local v5165 = v5164 and v5164[v5162]

	if v5165 then
		Enums[v5165] = v5163
	end
end)
local v5164 = "Classic"
local v5165 = 2581
pcall(function()
	local v5166 = enum[v]
	local v5167 = v5166 and v5166[v5164]

	if v5167 then
		Enums[v5167] = v5165
	end
end)
local v5166 = "Follow"
local v5167 = 2582
pcall(function()
	local v5168 = enum[v]
	local v5169 = v5168 and v5168[v5166]

	if v5169 then
		Enums[v5169] = v5167
	end
end)
local v5168 = "Orbital"
local v5169 = 2583
pcall(function()
	local v5170 = enum[v]
	local v5171 = v5170 and v5170[v5168]

	if v5171 then
		Enums[v5171] = v5169
	end
end)
v = "TouchMovementMode"
local v5170 = "Default"
local v5171 = 2584
pcall(function()
	local v5172 = enum[v]
	local v5173 = v5172 and v5172[v5170]

	if v5173 then
		Enums[v5173] = v5171
	end
end)
local v5172 = "Thumbstick"
local v5173 = 2585
pcall(function()
	local v5174 = enum[v]
	local v5175 = v5174 and v5174[v5172]

	if v5175 then
		Enums[v5175] = v5173
	end
end)
local v5174 = "DPad"
local v5175 = 2586
pcall(function()
	local v5176 = enum[v]
	local v5177 = v5176 and v5176[v5174]

	if v5177 then
		Enums[v5177] = v5175
	end
end)
local v5176 = "Thumbpad"
local v5177 = 2587
pcall(function()
	local v5178 = enum[v]
	local v5179 = v5178 and v5178[v5176]

	if v5179 then
		Enums[v5179] = v5177
	end
end)
local v5178 = "ClickToMove"
local v5179 = 2588
pcall(function()
	local v5180 = enum[v]
	local v5181 = v5180 and v5180[v5178]

	if v5181 then
		Enums[v5181] = v5179
	end
end)
local v5180 = "DynamicThumbstick"
local v5181 = 2589
pcall(function()
	local v5182 = enum[v]
	local v5183 = v5182 and v5182[v5180]

	if v5183 then
		Enums[v5183] = v5181
	end
end)
v = "TrackerError"
local v5182 = "Ok"
local v5183 = 2590
pcall(function()
	local v5184 = enum[v]
	local v5185 = v5184 and v5184[v5182]

	if v5185 then
		Enums[v5185] = v5183
	end
end)
local v5184 = "NoService"
local v5185 = 2591
pcall(function()
	local v5186 = enum[v]
	local v5187 = v5186 and v5186[v5184]

	if v5187 then
		Enums[v5187] = v5185
	end
end)
local v5186 = "InitFailed"
local v5187 = 2592
pcall(function()
	local v5188 = enum[v]
	local v5189 = v5188 and v5188[v5186]

	if v5189 then
		Enums[v5189] = v5187
	end
end)
local v5188 = "NoVideo"
local v5189 = 2593
pcall(function()
	local v5190 = enum[v]
	local v5191 = v5190 and v5190[v5188]

	if v5191 then
		Enums[v5191] = v5189
	end
end)
local v5190 = "VideoError"
local v5191 = 2594
pcall(function()
	local v5192 = enum[v]
	local v5193 = v5192 and v5192[v5190]

	if v5193 then
		Enums[v5193] = v5191
	end
end)
local v5192 = "VideoNoPermission"
local v5193 = 2595
pcall(function()
	local v5194 = enum[v]
	local v5195 = v5194 and v5194[v5192]

	if v5195 then
		Enums[v5195] = v5193
	end
end)
local v5194 = "VideoUnsupported"
local v5195 = 2596
pcall(function()
	local v5196 = enum[v]
	local v5197 = v5196 and v5196[v5194]

	if v5197 then
		Enums[v5197] = v5195
	end
end)
local v5196 = "NoAudio"
local v5197 = 2597
pcall(function()
	local v5198 = enum[v]
	local v5199 = v5198 and v5198[v5196]

	if v5199 then
		Enums[v5199] = v5197
	end
end)
local v5198 = "AudioError"
local v5199 = 2598
pcall(function()
	local v5200 = enum[v]
	local v5201 = v5200 and v5200[v5198]

	if v5201 then
		Enums[v5201] = v5199
	end
end)
local v5200 = "AudioNoPermission"
local v5201 = 2599
pcall(function()
	local v5202 = enum[v]
	local v5203 = v5202 and v5202[v5200]

	if v5203 then
		Enums[v5203] = v5201
	end
end)
local v5202 = "UnsupportedDevice"
local v5203 = 2600
pcall(function()
	local v5204 = enum[v]
	local v5205 = v5204 and v5204[v5202]

	if v5205 then
		Enums[v5205] = v5203
	end
end)
v = "TrackerExtrapolationFlagMode"
local v5204 = "Auto"
local v5205 = 2601
pcall(function()
	local v5206 = enum[v]
	local v5207 = v5206 and v5206[v5204]

	if v5207 then
		Enums[v5207] = v5205
	end
end)
local v5206 = "ForceDisabled"
local v5207 = 2602
pcall(function()
	local v5208 = enum[v]
	local v5209 = v5208 and v5208[v5206]

	if v5209 then
		Enums[v5209] = v5207
	end
end)
local v5208 = "ExtrapolateFacsAndPose"
local v5209 = 2603
pcall(function()
	local v5210 = enum[v]
	local v5211 = v5210 and v5210[v5208]

	if v5211 then
		Enums[v5211] = v5209
	end
end)
local v5210 = "ExtrapolateFacsOnly"
local v5211 = 2604
pcall(function()
	local v5212 = enum[v]
	local v5213 = v5212 and v5212[v5210]

	if v5213 then
		Enums[v5213] = v5211
	end
end)
v = "TrackerFaceTrackingStatus"
local v5212 = "FaceTrackingSuccess"
local v5213 = 2605
pcall(function()
	local v5214 = enum[v]
	local v5215 = v5214 and v5214[v5212]

	if v5215 then
		Enums[v5215] = v5213
	end
end)
local v5214 = "FaceTrackingNoFaceFound"
local v5215 = 2606
pcall(function()
	local v5216 = enum[v]
	local v5217 = v5216 and v5216[v5214]

	if v5217 then
		Enums[v5217] = v5215
	end
end)
local v5216 = "FaceTrackingUnknown"
local v5217 = 2607
pcall(function()
	local v5218 = enum[v]
	local v5219 = v5218 and v5218[v5216]

	if v5219 then
		Enums[v5219] = v5217
	end
end)
local v5218 = "FaceTrackingLost"
local v5219 = 2608
pcall(function()
	local v5220 = enum[v]
	local v5221 = v5220 and v5220[v5218]

	if v5221 then
		Enums[v5221] = v5219
	end
end)
local v5220 = "FaceTrackingHasTrackingError"
local v5221 = 2609
pcall(function()
	local v5222 = enum[v]
	local v5223 = v5222 and v5222[v5220]

	if v5223 then
		Enums[v5223] = v5221
	end
end)
local v5222 = "FaceTrackingIsOccluded"
local v5223 = 2610
pcall(function()
	local v5224 = enum[v]
	local v5225 = v5224 and v5224[v5222]

	if v5225 then
		Enums[v5225] = v5223
	end
end)
local v5224 = "FaceTrackingUninitialized"
local v5225 = 2611
pcall(function()
	local v5226 = enum[v]
	local v5227 = v5226 and v5226[v5224]

	if v5227 then
		Enums[v5227] = v5225
	end
end)
v = "TrackerLodFlagMode"
local v5226 = "Auto"
local v5227 = 2612
pcall(function()
	local v5228 = enum[v]
	local v5229 = v5228 and v5228[v5226]

	if v5229 then
		Enums[v5229] = v5227
	end
end)
local v5228 = "ForceFalse"
local v5229 = 2613
pcall(function()
	local v5230 = enum[v]
	local v5231 = v5230 and v5230[v5228]

	if v5231 then
		Enums[v5231] = v5229
	end
end)
local v5230 = "ForceTrue"
local v5231 = 2614
pcall(function()
	local v5232 = enum[v]
	local v5233 = v5232 and v5232[v5230]

	if v5233 then
		Enums[v5233] = v5231
	end
end)
v = "TrackerLodValueMode"
local v5232 = "Auto"
local v5233 = 2615
pcall(function()
	local v5234 = enum[v]
	local v5235 = v5234 and v5234[v5232]

	if v5235 then
		Enums[v5235] = v5233
	end
end)
local v5234 = "Force0"
local v5235 = 2616
pcall(function()
	local v5236 = enum[v]
	local v5237 = v5236 and v5236[v5234]

	if v5237 then
		Enums[v5237] = v5235
	end
end)
local v5236 = "Force1"
local v5237 = 2617
pcall(function()
	local v5238 = enum[v]
	local v5239 = v5238 and v5238[v5236]

	if v5239 then
		Enums[v5239] = v5237
	end
end)
v = "TrackerMode"
local v5238 = "None"
local v5239 = 2618
pcall(function()
	local v5240 = enum[v]
	local v5241 = v5240 and v5240[v5238]

	if v5241 then
		Enums[v5241] = v5239
	end
end)
local v5240 = "Audio"
local v5241 = 2619
pcall(function()
	local v5242 = enum[v]
	local v5243 = v5242 and v5242[v5240]

	if v5243 then
		Enums[v5243] = v5241
	end
end)
local v5242 = "Video"
local v5243 = 2620
pcall(function()
	local v5244 = enum[v]
	local v5245 = v5244 and v5244[v5242]

	if v5245 then
		Enums[v5245] = v5243
	end
end)
local v5244 = "AudioVideo"
local v5245 = 2621
pcall(function()
	local v5246 = enum[v]
	local v5247 = v5246 and v5246[v5244]

	if v5247 then
		Enums[v5247] = v5245
	end
end)
v = "TrackerPromptEvent"
local v5246 = "LODCameraRecommendDisable"
local v5247 = 2622
pcall(function()
	local v5248 = enum[v]
	local v5249 = v5248 and v5248[v5246]

	if v5249 then
		Enums[v5249] = v5247
	end
end)
v = "TrackerType"
local v5248 = "None"
local v5249 = 2623
pcall(function()
	local v5250 = enum[v]
	local v5251 = v5250 and v5250[v5248]

	if v5251 then
		Enums[v5251] = v5249
	end
end)
local v5250 = "Face"
local v5251 = 2624
pcall(function()
	local v5252 = enum[v]
	local v5253 = v5252 and v5252[v5250]

	if v5253 then
		Enums[v5253] = v5251
	end
end)
local v5252 = "UpperBody"
local v5253 = 2625
pcall(function()
	local v5254 = enum[v]
	local v5255 = v5254 and v5254[v5252]

	if v5255 then
		Enums[v5255] = v5253
	end
end)
v = "TriStateBoolean"
local v5254 = "False"
local v5255 = 2626
pcall(function()
	local v5256 = enum[v]
	local v5257 = v5256 and v5256[v5254]

	if v5257 then
		Enums[v5257] = v5255
	end
end)
local v5256 = "True"
local v5257 = 2627
pcall(function()
	local v5258 = enum[v]
	local v5259 = v5258 and v5258[v5256]

	if v5259 then
		Enums[v5259] = v5257
	end
end)
local v5258 = "Unknown"
local v5259 = 2628
pcall(function()
	local v5260 = enum[v]
	local v5261 = v5260 and v5260[v5258]

	if v5261 then
		Enums[v5261] = v5259
	end
end)
v = "TweenStatus"
local v5260 = "Canceled"
local v5261 = 2629
pcall(function()
	local v5262 = enum[v]
	local v5263 = v5262 and v5262[v5260]

	if v5263 then
		Enums[v5263] = v5261
	end
end)
local v5262 = "Completed"
local v5263 = 2630
pcall(function()
	local v5264 = enum[v]
	local v5265 = v5264 and v5264[v5262]

	if v5265 then
		Enums[v5265] = v5263
	end
end)
v = "UICaptureMode"
local v5264 = "All"
local v5265 = 2631
pcall(function()
	local v5266 = enum[v]
	local v5267 = v5266 and v5266[v5264]

	if v5267 then
		Enums[v5267] = v5265
	end
end)
local v5266 = "None"
local v5267 = 2632
pcall(function()
	local v5268 = enum[v]
	local v5269 = v5268 and v5268[v5266]

	if v5269 then
		Enums[v5269] = v5267
	end
end)
v = "UIDragDetectorBoundingBehavior"
local v5268 = "Automatic"
local v5269 = 2633
pcall(function()
	local v5270 = enum[v]
	local v5271 = v5270 and v5270[v5268]

	if v5271 then
		Enums[v5271] = v5269
	end
end)
local v5270 = "EntireObject"
local v5271 = 2634
pcall(function()
	local v5272 = enum[v]
	local v5273 = v5272 and v5272[v5270]

	if v5273 then
		Enums[v5273] = v5271
	end
end)
local v5272 = "HitPoint"
local v5273 = 2635
pcall(function()
	local v5274 = enum[v]
	local v5275 = v5274 and v5274[v5272]

	if v5275 then
		Enums[v5275] = v5273
	end
end)
v = "UIDragDetectorDragRelativity"
local v5274 = "Absolute"
local v5275 = 2636
pcall(function()
	local v5276 = enum[v]
	local v5277 = v5276 and v5276[v5274]

	if v5277 then
		Enums[v5277] = v5275
	end
end)
local v5276 = "Relative"
local v5277 = 2637
pcall(function()
	local v5278 = enum[v]
	local v5279 = v5278 and v5278[v5276]

	if v5279 then
		Enums[v5279] = v5277
	end
end)
v = "UIDragDetectorDragSpace"
local v5278 = "Parent"
local v5279 = 2638
pcall(function()
	local v5280 = enum[v]
	local v5281 = v5280 and v5280[v5278]

	if v5281 then
		Enums[v5281] = v5279
	end
end)
local v5280 = "LayerCollector"
local v5281 = 2639
pcall(function()
	local v5282 = enum[v]
	local v5283 = v5282 and v5282[v5280]

	if v5283 then
		Enums[v5283] = v5281
	end
end)
local v5282 = "Reference"
local v5283 = 2640
pcall(function()
	local v5284 = enum[v]
	local v5285 = v5284 and v5284[v5282]

	if v5285 then
		Enums[v5285] = v5283
	end
end)
v = "UIDragDetectorDragStyle"
local v5284 = "TranslatePlane"
local v5285 = 2641
pcall(function()
	local v5286 = enum[v]
	local v5287 = v5286 and v5286[v5284]

	if v5287 then
		Enums[v5287] = v5285
	end
end)
local v5286 = "TranslateLine"
local v5287 = 2642
pcall(function()
	local v5288 = enum[v]
	local v5289 = v5288 and v5288[v5286]

	if v5289 then
		Enums[v5289] = v5287
	end
end)
local v5288 = "Rotate"
local v5289 = 2643
pcall(function()
	local v5290 = enum[v]
	local v5291 = v5290 and v5290[v5288]

	if v5291 then
		Enums[v5291] = v5289
	end
end)
local v5290 = "Scriptable"
local v5291 = 2644
pcall(function()
	local v5292 = enum[v]
	local v5293 = v5292 and v5292[v5290]

	if v5293 then
		Enums[v5293] = v5291
	end
end)
v = "UIDragDetectorResponseStyle"
local v5292 = "Offset"
local v5293 = 2645
pcall(function()
	local v5294 = enum[v]
	local v5295 = v5294 and v5294[v5292]

	if v5295 then
		Enums[v5295] = v5293
	end
end)
local v5294 = "Scale"
local v5295 = 2646
pcall(function()
	local v5296 = enum[v]
	local v5297 = v5296 and v5296[v5294]

	if v5297 then
		Enums[v5297] = v5295
	end
end)
local v5296 = "CustomOffset"
local v5297 = 2647
pcall(function()
	local v5298 = enum[v]
	local v5299 = v5298 and v5298[v5296]

	if v5299 then
		Enums[v5299] = v5297
	end
end)
local v5298 = "CustomScale"
local v5299 = 2648
pcall(function()
	local v5300 = enum[v]
	local v5301 = v5300 and v5300[v5298]

	if v5301 then
		Enums[v5301] = v5299
	end
end)
v = "UIDragSpeedAxisMapping"
local v5300 = "XY"
local v5301 = 2649
pcall(function()
	local v5302 = enum[v]
	local v5303 = v5302 and v5302[v5300]

	if v5303 then
		Enums[v5303] = v5301
	end
end)
local v5302 = "XX"
local v5303 = 2650
pcall(function()
	local v5304 = enum[v]
	local v5305 = v5304 and v5304[v5302]

	if v5305 then
		Enums[v5305] = v5303
	end
end)
local v5304 = "YY"
local v5305 = 2651
pcall(function()
	local v5306 = enum[v]
	local v5307 = v5306 and v5306[v5304]

	if v5307 then
		Enums[v5307] = v5305
	end
end)
v = "UIFlexAlignment"
local v5306 = "None"
local v5307 = 2652
pcall(function()
	local v5308 = enum[v]
	local v5309 = v5308 and v5308[v5306]

	if v5309 then
		Enums[v5309] = v5307
	end
end)
local v5308 = "Fill"
local v5309 = 2653
pcall(function()
	local v5310 = enum[v]
	local v5311 = v5310 and v5310[v5308]

	if v5311 then
		Enums[v5311] = v5309
	end
end)
local v5310 = "SpaceAround"
local v5311 = 2654
pcall(function()
	local v5312 = enum[v]
	local v5313 = v5312 and v5312[v5310]

	if v5313 then
		Enums[v5313] = v5311
	end
end)
local v5312 = "SpaceBetween"
local v5313 = 2655
pcall(function()
	local v5314 = enum[v]
	local v5315 = v5314 and v5314[v5312]

	if v5315 then
		Enums[v5315] = v5313
	end
end)
local v5314 = "SpaceEvenly"
local v5315 = 2656
pcall(function()
	local v5316 = enum[v]
	local v5317 = v5316 and v5316[v5314]

	if v5317 then
		Enums[v5317] = v5315
	end
end)
v = "UIFlexMode"
local v5316 = "None"
local v5317 = 2657
pcall(function()
	local v5318 = enum[v]
	local v5319 = v5318 and v5318[v5316]

	if v5319 then
		Enums[v5319] = v5317
	end
end)
local v5318 = "Grow"
local v5319 = 2658
pcall(function()
	local v5320 = enum[v]
	local v5321 = v5320 and v5320[v5318]

	if v5321 then
		Enums[v5321] = v5319
	end
end)
local v5320 = "Shrink"
local v5321 = 2659
pcall(function()
	local v5322 = enum[v]
	local v5323 = v5322 and v5322[v5320]

	if v5323 then
		Enums[v5323] = v5321
	end
end)
local v5322 = "Fill"
local v5323 = 2660
pcall(function()
	local v5324 = enum[v]
	local v5325 = v5324 and v5324[v5322]

	if v5325 then
		Enums[v5325] = v5323
	end
end)
local v5324 = "Custom"
local v5325 = 2661
pcall(function()
	local v5326 = enum[v]
	local v5327 = v5326 and v5326[v5324]

	if v5327 then
		Enums[v5327] = v5325
	end
end)
v = "UITheme"
local v5326 = "Light"
local v5327 = 2662
pcall(function()
	local v5328 = enum[v]
	local v5329 = v5328 and v5328[v5326]

	if v5329 then
		Enums[v5329] = v5327
	end
end)
local v5328 = "Dark"
local v5329 = 2663
pcall(function()
	local v5330 = enum[v]
	local v5331 = v5330 and v5330[v5328]

	if v5331 then
		Enums[v5331] = v5329
	end
end)
v = "UiMessageType"
local v5330 = "UiMessageError"
local v5331 = 2664
pcall(function()
	local v5332 = enum[v]
	local v5333 = v5332 and v5332[v5330]

	if v5333 then
		Enums[v5333] = v5331
	end
end)
local v5332 = "UiMessageInfo"
local v5333 = 2665
pcall(function()
	local v5334 = enum[v]
	local v5335 = v5334 and v5334[v5332]

	if v5335 then
		Enums[v5335] = v5333
	end
end)
v = "UsageContext"
local v5334 = "Default"
local v5335 = 2666
pcall(function()
	local v5336 = enum[v]
	local v5337 = v5336 and v5336[v5334]

	if v5337 then
		Enums[v5337] = v5335
	end
end)
local v5336 = "Preview"
local v5337 = 2667
pcall(function()
	local v5338 = enum[v]
	local v5339 = v5338 and v5338[v5336]

	if v5339 then
		Enums[v5339] = v5337
	end
end)
v = "UserCFrame"
local v5338 = "Head"
local v5339 = 2668
pcall(function()
	local v5340 = enum[v]
	local v5341 = v5340 and v5340[v5338]

	if v5341 then
		Enums[v5341] = v5339
	end
end)
local v5340 = "LeftHand"
local v5341 = 2669
pcall(function()
	local v5342 = enum[v]
	local v5343 = v5342 and v5342[v5340]

	if v5343 then
		Enums[v5343] = v5341
	end
end)
local v5342 = "RightHand"
local v5343 = 2670
pcall(function()
	local v5344 = enum[v]
	local v5345 = v5344 and v5344[v5342]

	if v5345 then
		Enums[v5345] = v5343
	end
end)
local v5344 = "Floor"
local v5345 = 2671
pcall(function()
	local v5346 = enum[v]
	local v5347 = v5346 and v5346[v5344]

	if v5347 then
		Enums[v5347] = v5345
	end
end)
v = "UserInputState"
local v5346 = "Begin"
local v5347 = 2672
pcall(function()
	local v5348 = enum[v]
	local v5349 = v5348 and v5348[v5346]

	if v5349 then
		Enums[v5349] = v5347
	end
end)
local v5348 = "Change"
local v5349 = 2673
pcall(function()
	local v5350 = enum[v]
	local v5351 = v5350 and v5350[v5348]

	if v5351 then
		Enums[v5351] = v5349
	end
end)
local v5350 = "End"
local v5351 = 2674
pcall(function()
	local v5352 = enum[v]
	local v5353 = v5352 and v5352[v5350]

	if v5353 then
		Enums[v5353] = v5351
	end
end)
local v5352 = "Cancel"
local v5353 = 2675
pcall(function()
	local v5354 = enum[v]
	local v5355 = v5354 and v5354[v5352]

	if v5355 then
		Enums[v5355] = v5353
	end
end)
local v5354 = "None"
local v5355 = 2676
pcall(function()
	local v5356 = enum[v]
	local v5357 = v5356 and v5356[v5354]

	if v5357 then
		Enums[v5357] = v5355
	end
end)
v = "UserInputType"
local v5356 = "MouseButton1"
local v5357 = 2677
pcall(function()
	local v5358 = enum[v]
	local v5359 = v5358 and v5358[v5356]

	if v5359 then
		Enums[v5359] = v5357
	end
end)
local v5358 = "MouseButton2"
local v5359 = 2678
pcall(function()
	local v5360 = enum[v]
	local v5361 = v5360 and v5360[v5358]

	if v5361 then
		Enums[v5361] = v5359
	end
end)
local v5360 = "MouseButton3"
local v5361 = 2679
pcall(function()
	local v5362 = enum[v]
	local v5363 = v5362 and v5362[v5360]

	if v5363 then
		Enums[v5363] = v5361
	end
end)
local v5362 = "MouseWheel"
local v5363 = 2680
pcall(function()
	local v5364 = enum[v]
	local v5365 = v5364 and v5364[v5362]

	if v5365 then
		Enums[v5365] = v5363
	end
end)
local v5364 = "MouseMovement"
local v5365 = 2681
pcall(function()
	local v5366 = enum[v]
	local v5367 = v5366 and v5366[v5364]

	if v5367 then
		Enums[v5367] = v5365
	end
end)
local v5366 = "Touch"
local v5367 = 2682
pcall(function()
	local v5368 = enum[v]
	local v5369 = v5368 and v5368[v5366]

	if v5369 then
		Enums[v5369] = v5367
	end
end)
local v5368 = "Keyboard"
local v5369 = 2683
pcall(function()
	local v5370 = enum[v]
	local v5371 = v5370 and v5370[v5368]

	if v5371 then
		Enums[v5371] = v5369
	end
end)
local v5370 = "Focus"
local v5371 = 2684
pcall(function()
	local v5372 = enum[v]
	local v5373 = v5372 and v5372[v5370]

	if v5373 then
		Enums[v5373] = v5371
	end
end)
local v5372 = "Accelerometer"
local v5373 = 2685
pcall(function()
	local v5374 = enum[v]
	local v5375 = v5374 and v5374[v5372]

	if v5375 then
		Enums[v5375] = v5373
	end
end)
local v5374 = "Gyro"
local v5375 = 2686
pcall(function()
	local v5376 = enum[v]
	local v5377 = v5376 and v5376[v5374]

	if v5377 then
		Enums[v5377] = v5375
	end
end)
local v5376 = "Gamepad1"
local v5377 = 2687
pcall(function()
	local v5378 = enum[v]
	local v5379 = v5378 and v5378[v5376]

	if v5379 then
		Enums[v5379] = v5377
	end
end)
local v5378 = "Gamepad2"
local v5379 = 2688
pcall(function()
	local v5380 = enum[v]
	local v5381 = v5380 and v5380[v5378]

	if v5381 then
		Enums[v5381] = v5379
	end
end)
local v5380 = "Gamepad3"
local v5381 = 2689
pcall(function()
	local v5382 = enum[v]
	local v5383 = v5382 and v5382[v5380]

	if v5383 then
		Enums[v5383] = v5381
	end
end)
local v5382 = "Gamepad4"
local v5383 = 2690
pcall(function()
	local v5384 = enum[v]
	local v5385 = v5384 and v5384[v5382]

	if v5385 then
		Enums[v5385] = v5383
	end
end)
local v5384 = "Gamepad5"
local v5385 = 2691
pcall(function()
	local v5386 = enum[v]
	local v5387 = v5386 and v5386[v5384]

	if v5387 then
		Enums[v5387] = v5385
	end
end)
local v5386 = "Gamepad6"
local v5387 = 2692
pcall(function()
	local v5388 = enum[v]
	local v5389 = v5388 and v5388[v5386]

	if v5389 then
		Enums[v5389] = v5387
	end
end)
local v5388 = "Gamepad7"
local v5389 = 2693
pcall(function()
	local v5390 = enum[v]
	local v5391 = v5390 and v5390[v5388]

	if v5391 then
		Enums[v5391] = v5389
	end
end)
local v5390 = "Gamepad8"
local v5391 = 2694
pcall(function()
	local v5392 = enum[v]
	local v5393 = v5392 and v5392[v5390]

	if v5393 then
		Enums[v5393] = v5391
	end
end)
local v5392 = "TextInput"
local v5393 = 2695
pcall(function()
	local v5394 = enum[v]
	local v5395 = v5394 and v5394[v5392]

	if v5395 then
		Enums[v5395] = v5393
	end
end)
local v5394 = "InputMethod"
local v5395 = 2696
pcall(function()
	local v5396 = enum[v]
	local v5397 = v5396 and v5396[v5394]

	if v5397 then
		Enums[v5397] = v5395
	end
end)
local v5396 = "None"
local v5397 = 2697
pcall(function()
	local v5398 = enum[v]
	local v5399 = v5398 and v5398[v5396]

	if v5399 then
		Enums[v5399] = v5397
	end
end)
v = "VRComfortSetting"
local v5398 = "Comfort"
local v5399 = 2698
pcall(function()
	local v5400 = enum[v]
	local v5401 = v5400 and v5400[v5398]

	if v5401 then
		Enums[v5401] = v5399
	end
end)
local v5400 = "Normal"
local v5401 = 2699
pcall(function()
	local v5402 = enum[v]
	local v5403 = v5402 and v5402[v5400]

	if v5403 then
		Enums[v5403] = v5401
	end
end)
local v5402 = "Expert"
local v5403 = 2700
pcall(function()
	local v5404 = enum[v]
	local v5405 = v5404 and v5404[v5402]

	if v5405 then
		Enums[v5405] = v5403
	end
end)
local v5404 = "Custom"
local v5405 = 2701
pcall(function()
	local v5406 = enum[v]
	local v5407 = v5406 and v5406[v5404]

	if v5407 then
		Enums[v5407] = v5405
	end
end)
v = "VRControllerModelMode"
local v5406 = "Disabled"
local v5407 = 2702
pcall(function()
	local v5408 = enum[v]
	local v5409 = v5408 and v5408[v5406]

	if v5409 then
		Enums[v5409] = v5407
	end
end)
local v5408 = "Transparent"
local v5409 = 2703
pcall(function()
	local v5410 = enum[v]
	local v5411 = v5410 and v5410[v5408]

	if v5411 then
		Enums[v5411] = v5409
	end
end)
v = "VRDeviceType"
local v5410 = "Unknown"
local v5411 = 2704
pcall(function()
	local v5412 = enum[v]
	local v5413 = v5412 and v5412[v5410]

	if v5413 then
		Enums[v5413] = v5411
	end
end)
local v5412 = "OculusRift"
local v5413 = 2705
pcall(function()
	local v5414 = enum[v]
	local v5415 = v5414 and v5414[v5412]

	if v5415 then
		Enums[v5415] = v5413
	end
end)
local v5414 = "HTCVive"
local v5415 = 2706
pcall(function()
	local v5416 = enum[v]
	local v5417 = v5416 and v5416[v5414]

	if v5417 then
		Enums[v5417] = v5415
	end
end)
local v5416 = "ValveIndex"
local v5417 = 2707
pcall(function()
	local v5418 = enum[v]
	local v5419 = v5418 and v5418[v5416]

	if v5419 then
		Enums[v5419] = v5417
	end
end)
local v5418 = "OculusQuest"
local v5419 = 2708
pcall(function()
	local v5420 = enum[v]
	local v5421 = v5420 and v5420[v5418]

	if v5421 then
		Enums[v5421] = v5419
	end
end)
v = "VRLaserPointerMode"
local v5420 = "Disabled"
local v5421 = 2709
pcall(function()
	local v5422 = enum[v]
	local v5423 = v5422 and v5422[v5420]

	if v5423 then
		Enums[v5423] = v5421
	end
end)
local v5422 = "Pointer"
local v5423 = 2710
pcall(function()
	local v5424 = enum[v]
	local v5425 = v5424 and v5424[v5422]

	if v5425 then
		Enums[v5425] = v5423
	end
end)
local v5424 = "DualPointer"
local v5425 = 2711
pcall(function()
	local v5426 = enum[v]
	local v5427 = v5426 and v5426[v5424]

	if v5427 then
		Enums[v5427] = v5425
	end
end)
v = "VRSafetyBubbleMode"
local v5426 = "NoOne"
local v5427 = 2712
pcall(function()
	local v5428 = enum[v]
	local v5429 = v5428 and v5428[v5426]

	if v5429 then
		Enums[v5429] = v5427
	end
end)
local v5428 = "OnlyFriends"
local v5429 = 2713
pcall(function()
	local v5430 = enum[v]
	local v5431 = v5430 and v5430[v5428]

	if v5431 then
		Enums[v5431] = v5429
	end
end)
local v5430 = "Anyone"
local v5431 = 2714
pcall(function()
	local v5432 = enum[v]
	local v5433 = v5432 and v5432[v5430]

	if v5433 then
		Enums[v5433] = v5431
	end
end)
v = "VRScaling"
local v5432 = "World"
local v5433 = 2715
pcall(function()
	local v5434 = enum[v]
	local v5435 = v5434 and v5434[v5432]

	if v5435 then
		Enums[v5435] = v5433
	end
end)
local v5434 = "Off"
local v5435 = 2716
pcall(function()
	local v5436 = enum[v]
	local v5437 = v5436 and v5436[v5434]

	if v5437 then
		Enums[v5437] = v5435
	end
end)
v = "VRSessionState"
local v5436 = "Undefined"
local v5437 = 2717
pcall(function()
	local v5438 = enum[v]
	local v5439 = v5438 and v5438[v5436]

	if v5439 then
		Enums[v5439] = v5437
	end
end)
local v5438 = "Idle"
local v5439 = 2718
pcall(function()
	local v5440 = enum[v]
	local v5441 = v5440 and v5440[v5438]

	if v5441 then
		Enums[v5441] = v5439
	end
end)
local v5440 = "Visible"
local v5441 = 2719
pcall(function()
	local v5442 = enum[v]
	local v5443 = v5442 and v5442[v5440]

	if v5443 then
		Enums[v5443] = v5441
	end
end)
local v5442 = "Focused"
local v5443 = 2720
pcall(function()
	local v5444 = enum[v]
	local v5445 = v5444 and v5444[v5442]

	if v5445 then
		Enums[v5445] = v5443
	end
end)
local v5444 = "Stopping"
local v5445 = 2721
pcall(function()
	local v5446 = enum[v]
	local v5447 = v5446 and v5446[v5444]

	if v5447 then
		Enums[v5447] = v5445
	end
end)
v = "VRTouchpad"
local v5446 = "Left"
local v5447 = 2722
pcall(function()
	local v5448 = enum[v]
	local v5449 = v5448 and v5448[v5446]

	if v5449 then
		Enums[v5449] = v5447
	end
end)
local v5448 = "Right"
local v5449 = 2723
pcall(function()
	local v5450 = enum[v]
	local v5451 = v5450 and v5450[v5448]

	if v5451 then
		Enums[v5451] = v5449
	end
end)
v = "VRTouchpadMode"
local v5450 = "Touch"
local v5451 = 2724
pcall(function()
	local v5452 = enum[v]
	local v5453 = v5452 and v5452[v5450]

	if v5453 then
		Enums[v5453] = v5451
	end
end)
local v5452 = "VirtualThumbstick"
local v5453 = 2725
pcall(function()
	local v5454 = enum[v]
	local v5455 = v5454 and v5454[v5452]

	if v5455 then
		Enums[v5455] = v5453
	end
end)
local v5454 = "ABXY"
local v5455 = 2726
pcall(function()
	local v5456 = enum[v]
	local v5457 = v5456 and v5456[v5454]

	if v5457 then
		Enums[v5457] = v5455
	end
end)
v = "VelocityConstraintMode"
local v5456 = "Line"
local v5457 = 2727
pcall(function()
	local v5458 = enum[v]
	local v5459 = v5458 and v5458[v5456]

	if v5459 then
		Enums[v5459] = v5457
	end
end)
local v5458 = "Plane"
local v5459 = 2728
pcall(function()
	local v5460 = enum[v]
	local v5461 = v5460 and v5460[v5458]

	if v5461 then
		Enums[v5461] = v5459
	end
end)
local v5460 = "Vector"
local v5461 = 2729
pcall(function()
	local v5462 = enum[v]
	local v5463 = v5462 and v5462[v5460]

	if v5463 then
		Enums[v5463] = v5461
	end
end)
v = "VerticalAlignment"
local v5462 = "Center"
local v5463 = 2730
pcall(function()
	local v5464 = enum[v]
	local v5465 = v5464 and v5464[v5462]

	if v5465 then
		Enums[v5465] = v5463
	end
end)
local v5464 = "Top"
local v5465 = 2731
pcall(function()
	local v5466 = enum[v]
	local v5467 = v5466 and v5466[v5464]

	if v5467 then
		Enums[v5467] = v5465
	end
end)
local v5466 = "Bottom"
local v5467 = 2732
pcall(function()
	local v5468 = enum[v]
	local v5469 = v5468 and v5468[v5466]

	if v5469 then
		Enums[v5469] = v5467
	end
end)
v = "VerticalScrollBarPosition"
local v5468 = "Right"
local v5469 = 2733
pcall(function()
	local v5470 = enum[v]
	local v5471 = v5470 and v5470[v5468]

	if v5471 then
		Enums[v5471] = v5469
	end
end)
local v5470 = "Left"
local v5471 = 2734
pcall(function()
	local v5472 = enum[v]
	local v5473 = v5472 and v5472[v5470]

	if v5473 then
		Enums[v5473] = v5471
	end
end)
v = "VibrationMotor"
local v5472 = "Large"
local v5473 = 2735
pcall(function()
	local v5474 = enum[v]
	local v5475 = v5474 and v5474[v5472]

	if v5475 then
		Enums[v5475] = v5473
	end
end)
local v5474 = "Small"
local v5475 = 2736
pcall(function()
	local v5476 = enum[v]
	local v5477 = v5476 and v5476[v5474]

	if v5477 then
		Enums[v5477] = v5475
	end
end)
local v5476 = "LeftTrigger"
local v5477 = 2737
pcall(function()
	local v5478 = enum[v]
	local v5479 = v5478 and v5478[v5476]

	if v5479 then
		Enums[v5479] = v5477
	end
end)
local v5478 = "RightTrigger"
local v5479 = 2738
pcall(function()
	local v5480 = enum[v]
	local v5481 = v5480 and v5480[v5478]

	if v5481 then
		Enums[v5481] = v5479
	end
end)
local v5480 = "LeftHand"
local v5481 = 2739
pcall(function()
	local v5482 = enum[v]
	local v5483 = v5482 and v5482[v5480]

	if v5483 then
		Enums[v5483] = v5481
	end
end)
local v5482 = "RightHand"
local v5483 = 2740
pcall(function()
	local v5484 = enum[v]
	local v5485 = v5484 and v5484[v5482]

	if v5485 then
		Enums[v5485] = v5483
	end
end)
v = "VideoDeviceCaptureQuality"
local v5484 = "Default"
local v5485 = 2741
pcall(function()
	local v5486 = enum[v]
	local v5487 = v5486 and v5486[v5484]

	if v5487 then
		Enums[v5487] = v5485
	end
end)
local v5486 = "Low"
local v5487 = 2742
pcall(function()
	local v5488 = enum[v]
	local v5489 = v5488 and v5488[v5486]

	if v5489 then
		Enums[v5489] = v5487
	end
end)
local v5488 = "Medium"
local v5489 = 2743
pcall(function()
	local v5490 = enum[v]
	local v5491 = v5490 and v5490[v5488]

	if v5491 then
		Enums[v5491] = v5489
	end
end)
local v5490 = "High"
local v5491 = 2744
pcall(function()
	local v5492 = enum[v]
	local v5493 = v5492 and v5492[v5490]

	if v5493 then
		Enums[v5493] = v5491
	end
end)
v = "VideoError"
local v5492 = "Ok"
local v5493 = 2745
pcall(function()
	local v5494 = enum[v]
	local v5495 = v5494 and v5494[v5492]

	if v5495 then
		Enums[v5495] = v5493
	end
end)
local v5494 = "Eof"
local v5495 = 2746
pcall(function()
	local v5496 = enum[v]
	local v5497 = v5496 and v5496[v5494]

	if v5497 then
		Enums[v5497] = v5495
	end
end)
local v5496 = "EAgain"
local v5497 = 2747
pcall(function()
	local v5498 = enum[v]
	local v5499 = v5498 and v5498[v5496]

	if v5499 then
		Enums[v5499] = v5497
	end
end)
local v5498 = "BadParameter"
local v5499 = 2748
pcall(function()
	local v5500 = enum[v]
	local v5501 = v5500 and v5500[v5498]

	if v5501 then
		Enums[v5501] = v5499
	end
end)
local v5500 = "AllocFailed"
local v5501 = 2749
pcall(function()
	local v5502 = enum[v]
	local v5503 = v5502 and v5502[v5500]

	if v5503 then
		Enums[v5503] = v5501
	end
end)
local v5502 = "CodecInitFailed"
local v5503 = 2750
pcall(function()
	local v5504 = enum[v]
	local v5505 = v5504 and v5504[v5502]

	if v5505 then
		Enums[v5505] = v5503
	end
end)
local v5504 = "CodecCloseFailed"
local v5505 = 2751
pcall(function()
	local v5506 = enum[v]
	local v5507 = v5506 and v5506[v5504]

	if v5507 then
		Enums[v5507] = v5505
	end
end)
local v5506 = "DecodeFailed"
local v5507 = 2752
pcall(function()
	local v5508 = enum[v]
	local v5509 = v5508 and v5508[v5506]

	if v5509 then
		Enums[v5509] = v5507
	end
end)
local v5508 = "ParsingFailed"
local v5509 = 2753
pcall(function()
	local v5510 = enum[v]
	local v5511 = v5510 and v5510[v5508]

	if v5511 then
		Enums[v5511] = v5509
	end
end)
local v5510 = "Unsupported"
local v5511 = 2754
pcall(function()
	local v5512 = enum[v]
	local v5513 = v5512 and v5512[v5510]

	if v5513 then
		Enums[v5513] = v5511
	end
end)
local v5512 = "Generic"
local v5513 = 2755
pcall(function()
	local v5514 = enum[v]
	local v5515 = v5514 and v5514[v5512]

	if v5515 then
		Enums[v5515] = v5513
	end
end)
local v5514 = "DownloadFailed"
local v5515 = 2756
pcall(function()
	local v5516 = enum[v]
	local v5517 = v5516 and v5516[v5514]

	if v5517 then
		Enums[v5517] = v5515
	end
end)
local v5516 = "StreamNotFound"
local v5517 = 2757
pcall(function()
	local v5518 = enum[v]
	local v5519 = v5518 and v5518[v5516]

	if v5519 then
		Enums[v5519] = v5517
	end
end)
local v5518 = "EncodeFailed"
local v5519 = 2758
pcall(function()
	local v5520 = enum[v]
	local v5521 = v5520 and v5520[v5518]

	if v5521 then
		Enums[v5521] = v5519
	end
end)
local v5520 = "CreateFailed"
local v5521 = 2759
pcall(function()
	local v5522 = enum[v]
	local v5523 = v5522 and v5522[v5520]

	if v5523 then
		Enums[v5523] = v5521
	end
end)
local v5522 = "NoPermission"
local v5523 = 2760
pcall(function()
	local v5524 = enum[v]
	local v5525 = v5524 and v5524[v5522]

	if v5525 then
		Enums[v5525] = v5523
	end
end)
local v5524 = "NoService"
local v5525 = 2761
pcall(function()
	local v5526 = enum[v]
	local v5527 = v5526 and v5526[v5524]

	if v5527 then
		Enums[v5527] = v5525
	end
end)
local v5526 = "ReleaseFailed"
local v5527 = 2762
pcall(function()
	local v5528 = enum[v]
	local v5529 = v5528 and v5528[v5526]

	if v5529 then
		Enums[v5529] = v5527
	end
end)
local v5528 = "Unknown"
local v5529 = 2763
pcall(function()
	local v5530 = enum[v]
	local v5531 = v5530 and v5530[v5528]

	if v5531 then
		Enums[v5531] = v5529
	end
end)
v = "ViewMode"
local v5530 = "None"
local v5531 = 2764
pcall(function()
	local v5532 = enum[v]
	local v5533 = v5532 and v5532[v5530]

	if v5533 then
		Enums[v5533] = v5531
	end
end)
local v5532 = "GeometryComplexity"
local v5533 = 2765
pcall(function()
	local v5534 = enum[v]
	local v5535 = v5534 and v5534[v5532]

	if v5535 then
		Enums[v5535] = v5533
	end
end)
local v5534 = "Transparent"
local v5535 = 2766
pcall(function()
	local v5536 = enum[v]
	local v5537 = v5536 and v5536[v5534]

	if v5537 then
		Enums[v5537] = v5535
	end
end)
local v5536 = "Decal"
local v5537 = 2767
pcall(function()
	local v5538 = enum[v]
	local v5539 = v5538 and v5538[v5536]

	if v5539 then
		Enums[v5539] = v5537
	end
end)
v = "VirtualCursorMode"
local v5538 = "Default"
local v5539 = 2768
pcall(function()
	local v5540 = enum[v]
	local v5541 = v5540 and v5540[v5538]

	if v5541 then
		Enums[v5541] = v5539
	end
end)
local v5540 = "Disabled"
local v5541 = 2769
pcall(function()
	local v5542 = enum[v]
	local v5543 = v5542 and v5542[v5540]

	if v5543 then
		Enums[v5543] = v5541
	end
end)
local v5542 = "Enabled"
local v5543 = 2770
pcall(function()
	local v5544 = enum[v]
	local v5545 = v5544 and v5544[v5542]

	if v5545 then
		Enums[v5545] = v5543
	end
end)
v = "VirtualInputMode"
local v5544 = "None"
local v5545 = 2771
pcall(function()
	local v5546 = enum[v]
	local v5547 = v5546 and v5546[v5544]

	if v5547 then
		Enums[v5547] = v5545
	end
end)
local v5546 = "Recording"
local v5547 = 2772
pcall(function()
	local v5548 = enum[v]
	local v5549 = v5548 and v5548[v5546]

	if v5549 then
		Enums[v5549] = v5547
	end
end)
local v5548 = "Playing"
local v5549 = 2773
pcall(function()
	local v5550 = enum[v]
	local v5551 = v5550 and v5550[v5548]

	if v5551 then
		Enums[v5551] = v5549
	end
end)
v = "VoiceChatDistanceAttenuationType"
local v5550 = "Inverse"
local v5551 = 2774
pcall(function()
	local v5552 = enum[v]
	local v5553 = v5552 and v5552[v5550]

	if v5553 then
		Enums[v5553] = v5551
	end
end)
local v5552 = "Legacy"
local v5553 = 2775
pcall(function()
	local v5554 = enum[v]
	local v5555 = v5554 and v5554[v5552]

	if v5555 then
		Enums[v5555] = v5553
	end
end)
v = "VoiceChatState"
local v5554 = "Idle"
local v5555 = 2776
pcall(function()
	local v5556 = enum[v]
	local v5557 = v5556 and v5556[v5554]

	if v5557 then
		Enums[v5557] = v5555
	end
end)
local v5556 = "Joining"
local v5557 = 2777
pcall(function()
	local v5558 = enum[v]
	local v5559 = v5558 and v5558[v5556]

	if v5559 then
		Enums[v5559] = v5557
	end
end)
local v5558 = "JoiningRetry"
local v5559 = 2778
pcall(function()
	local v5560 = enum[v]
	local v5561 = v5560 and v5560[v5558]

	if v5561 then
		Enums[v5561] = v5559
	end
end)
local v5560 = "Joined"
local v5561 = 2779
pcall(function()
	local v5562 = enum[v]
	local v5563 = v5562 and v5562[v5560]

	if v5563 then
		Enums[v5563] = v5561
	end
end)
local v5562 = "Leaving"
local v5563 = 2780
pcall(function()
	local v5564 = enum[v]
	local v5565 = v5564 and v5564[v5562]

	if v5565 then
		Enums[v5565] = v5563
	end
end)
local v5564 = "Ended"
local v5565 = 2781
pcall(function()
	local v5566 = enum[v]
	local v5567 = v5566 and v5566[v5564]

	if v5567 then
		Enums[v5567] = v5565
	end
end)
local v5566 = "Failed"
local v5567 = 2782
pcall(function()
	local v5568 = enum[v]
	local v5569 = v5568 and v5568[v5566]

	if v5569 then
		Enums[v5569] = v5567
	end
end)
v = "VoiceControlPath"
local v5568 = "Publish"
local v5569 = 2783
pcall(function()
	local v5570 = enum[v]
	local v5571 = v5570 and v5570[v5568]

	if v5571 then
		Enums[v5571] = v5569
	end
end)
local v5570 = "Subscribe"
local v5571 = 2784
pcall(function()
	local v5572 = enum[v]
	local v5573 = v5572 and v5572[v5570]

	if v5573 then
		Enums[v5573] = v5571
	end
end)
local v5572 = "Join"
local v5573 = 2785
pcall(function()
	local v5574 = enum[v]
	local v5575 = v5574 and v5574[v5572]

	if v5575 then
		Enums[v5575] = v5573
	end
end)
v = "VolumetricAudio"
local v5574 = "Disabled"
local v5575 = 2786
pcall(function()
	local v5576 = enum[v]
	local v5577 = v5576 and v5576[v5574]

	if v5577 then
		Enums[v5577] = v5575
	end
end)
local v5576 = "Automatic"
local v5577 = 2787
pcall(function()
	local v5578 = enum[v]
	local v5579 = v5578 and v5578[v5576]

	if v5579 then
		Enums[v5579] = v5577
	end
end)
local v5578 = "Enabled"
local v5579 = 2788
pcall(function()
	local v5580 = enum[v]
	local v5581 = v5580 and v5580[v5578]

	if v5581 then
		Enums[v5581] = v5579
	end
end)
v = "WaterDirection"
local v5580 = "NegX"
local v5581 = 2789
pcall(function()
	local v5582 = enum[v]
	local v5583 = v5582 and v5582[v5580]

	if v5583 then
		Enums[v5583] = v5581
	end
end)
local v5582 = "X"
local v5583 = 2790
pcall(function()
	local v5584 = enum[v]
	local v5585 = v5584 and v5584[v5582]

	if v5585 then
		Enums[v5585] = v5583
	end
end)
local v5584 = "NegY"
local v5585 = 2791
pcall(function()
	local v5586 = enum[v]
	local v5587 = v5586 and v5586[v5584]

	if v5587 then
		Enums[v5587] = v5585
	end
end)
local v5586 = "Y"
local v5587 = 2792
pcall(function()
	local v5588 = enum[v]
	local v5589 = v5588 and v5588[v5586]

	if v5589 then
		Enums[v5589] = v5587
	end
end)
local v5588 = "NegZ"
local v5589 = 2793
pcall(function()
	local v5590 = enum[v]
	local v5591 = v5590 and v5590[v5588]

	if v5591 then
		Enums[v5591] = v5589
	end
end)
local v5590 = "Z"
local v5591 = 2794
pcall(function()
	local v5592 = enum[v]
	local v5593 = v5592 and v5592[v5590]

	if v5593 then
		Enums[v5593] = v5591
	end
end)
v = "WaterForce"
local v5592 = "None"
local v5593 = 2795
pcall(function()
	local v5594 = enum[v]
	local v5595 = v5594 and v5594[v5592]

	if v5595 then
		Enums[v5595] = v5593
	end
end)
local v5594 = "Small"
local v5595 = 2796
pcall(function()
	local v5596 = enum[v]
	local v5597 = v5596 and v5596[v5594]

	if v5597 then
		Enums[v5597] = v5595
	end
end)
local v5596 = "Medium"
local v5597 = 2797
pcall(function()
	local v5598 = enum[v]
	local v5599 = v5598 and v5598[v5596]

	if v5599 then
		Enums[v5599] = v5597
	end
end)
local v5598 = "Strong"
local v5599 = 2798
pcall(function()
	local v5600 = enum[v]
	local v5601 = v5600 and v5600[v5598]

	if v5601 then
		Enums[v5601] = v5599
	end
end)
local v5600 = "Max"
local v5601 = 2799
pcall(function()
	local v5602 = enum[v]
	local v5603 = v5602 and v5602[v5600]

	if v5603 then
		Enums[v5603] = v5601
	end
end)
v = "WebSocketState"
local v5602 = "Connecting"
local v5603 = 2800
pcall(function()
	local v5604 = enum[v]
	local v5605 = v5604 and v5604[v5602]

	if v5605 then
		Enums[v5605] = v5603
	end
end)
local v5604 = "Open"
local v5605 = 2801
pcall(function()
	local v5606 = enum[v]
	local v5607 = v5606 and v5606[v5604]

	if v5607 then
		Enums[v5607] = v5605
	end
end)
local v5606 = "Closing"
local v5607 = 2802
pcall(function()
	local v5608 = enum[v]
	local v5609 = v5608 and v5608[v5606]

	if v5609 then
		Enums[v5609] = v5607
	end
end)
local v5608 = "Closed"
local v5609 = 2803
pcall(function()
	local v5610 = enum[v]
	local v5611 = v5610 and v5610[v5608]

	if v5611 then
		Enums[v5611] = v5609
	end
end)
v = "WeldConstraintPreserve"
local v5610 = "All"
local v5611 = 2804
pcall(function()
	local v5612 = enum[v]
	local v5613 = v5612 and v5612[v5610]

	if v5613 then
		Enums[v5613] = v5611
	end
end)
local v5612 = "None"
local v5613 = 2805
pcall(function()
	local v5614 = enum[v]
	local v5615 = v5614 and v5614[v5612]

	if v5615 then
		Enums[v5615] = v5613
	end
end)
local v5614 = "Touching"
local v5615 = 2806
pcall(function()
	local v5616 = enum[v]
	local v5617 = v5616 and v5616[v5614]

	if v5617 then
		Enums[v5617] = v5615
	end
end)
v = "WhisperChatPrivacyMode"
local v5616 = "AllUsers"
local v5617 = 2807
pcall(function()
	local v5618 = enum[v]
	local v5619 = v5618 and v5618[v5616]

	if v5619 then
		Enums[v5619] = v5617
	end
end)
local v5618 = "NoOne"
local v5619 = 2808
pcall(function()
	local v5620 = enum[v]
	local v5621 = v5620 and v5620[v5618]

	if v5621 then
		Enums[v5621] = v5619
	end
end)
v = "WrapLayerAutoSkin"
local v5620 = "Disabled"
local v5621 = 2809
pcall(function()
	local v5622 = enum[v]
	local v5623 = v5622 and v5622[v5620]

	if v5623 then
		Enums[v5623] = v5621
	end
end)
local v5622 = "EnabledPreserve"
local v5623 = 2810
pcall(function()
	local v5624 = enum[v]
	local v5625 = v5624 and v5624[v5622]

	if v5625 then
		Enums[v5625] = v5623
	end
end)
local v5624 = "EnabledOverride"
local v5625 = 2811
pcall(function()
	local v5626 = enum[v]
	local v5627 = v5626 and v5626[v5624]

	if v5627 then
		Enums[v5627] = v5625
	end
end)
v = "WrapLayerDebugMode"
local v5626 = "None"
local v5627 = 2812
pcall(function()
	local v5628 = enum[v]
	local v5629 = v5628 and v5628[v5626]

	if v5629 then
		Enums[v5629] = v5627
	end
end)
local v5628 = "BoundCage"
local v5629 = 2813
pcall(function()
	local v5630 = enum[v]
	local v5631 = v5630 and v5630[v5628]

	if v5631 then
		Enums[v5631] = v5629
	end
end)
local v5630 = "LayerCage"
local v5631 = 2814
pcall(function()
	local v5632 = enum[v]
	local v5633 = v5632 and v5632[v5630]

	if v5633 then
		Enums[v5633] = v5631
	end
end)
local v5632 = "BoundCageAndLinks"
local v5633 = 2815
pcall(function()
	local v5634 = enum[v]
	local v5635 = v5634 and v5634[v5632]

	if v5635 then
		Enums[v5635] = v5633
	end
end)
local v5634 = "Reference"
local v5635 = 2816
pcall(function()
	local v5636 = enum[v]
	local v5637 = v5636 and v5636[v5634]

	if v5637 then
		Enums[v5637] = v5635
	end
end)
local v5636 = "Rbf"
local v5637 = 2817
pcall(function()
	local v5638 = enum[v]
	local v5639 = v5638 and v5638[v5636]

	if v5639 then
		Enums[v5639] = v5637
	end
end)
local v5638 = "OuterCage"
local v5639 = 2818
pcall(function()
	local v5640 = enum[v]
	local v5641 = v5640 and v5640[v5638]

	if v5641 then
		Enums[v5641] = v5639
	end
end)
local v5640 = "ReferenceMeshAfterMorph"
local v5641 = 2819
pcall(function()
	local v5642 = enum[v]
	local v5643 = v5642 and v5642[v5640]

	if v5643 then
		Enums[v5643] = v5641
	end
end)
local v5642 = "HSROuterDetail"
local v5643 = 2820
pcall(function()
	local v5644 = enum[v]
	local v5645 = v5644 and v5644[v5642]

	if v5645 then
		Enums[v5645] = v5643
	end
end)
local v5644 = "HSROuter"
local v5645 = 2821
pcall(function()
	local v5646 = enum[v]
	local v5647 = v5646 and v5646[v5644]

	if v5647 then
		Enums[v5647] = v5645
	end
end)
local v5646 = "HSRInner"
local v5647 = 2822
pcall(function()
	local v5648 = enum[v]
	local v5649 = v5648 and v5648[v5646]

	if v5649 then
		Enums[v5649] = v5647
	end
end)
local v5648 = "HSRInnerReverse"
local v5649 = 2823
pcall(function()
	local v5650 = enum[v]
	local v5651 = v5650 and v5650[v5648]

	if v5651 then
		Enums[v5651] = v5649
	end
end)
local v5650 = "LayerCageFittedToBase"
local v5651 = 2824
pcall(function()
	local v5652 = enum[v]
	local v5653 = v5652 and v5652[v5650]

	if v5653 then
		Enums[v5653] = v5651
	end
end)
local v5652 = "LayerCageFittedToPrev"
local v5653 = 2825
pcall(function()
	local v5654 = enum[v]
	local v5655 = v5654 and v5654[v5652]

	if v5655 then
		Enums[v5655] = v5653
	end
end)
v = "WrapTargetDebugMode"
local v5654 = "None"
local v5655 = 2826
pcall(function()
	local v5656 = enum[v]
	local v5657 = v5656 and v5656[v5654]

	if v5657 then
		Enums[v5657] = v5655
	end
end)
local v5656 = "TargetCageOriginal"
local v5657 = 2827
pcall(function()
	local v5658 = enum[v]
	local v5659 = v5658 and v5658[v5656]

	if v5659 then
		Enums[v5659] = v5657
	end
end)
local v5658 = "TargetCageCompressed"
local v5659 = 2828
pcall(function()
	local v5660 = enum[v]
	local v5661 = v5660 and v5660[v5658]

	if v5661 then
		Enums[v5661] = v5659
	end
end)
local v5660 = "TargetCageInterface"
local v5661 = 2829
pcall(function()
	local v5662 = enum[v]
	local v5663 = v5662 and v5662[v5660]

	if v5663 then
		Enums[v5663] = v5661
	end
end)
local v5662 = "TargetLayerCageOriginal"
local v5663 = 2830
pcall(function()
	local v5664 = enum[v]
	local v5665 = v5664 and v5664[v5662]

	if v5665 then
		Enums[v5665] = v5663
	end
end)
local v5664 = "TargetLayerCageCompressed"
local v5665 = 2831
pcall(function()
	local v5666 = enum[v]
	local v5667 = v5666 and v5666[v5664]

	if v5667 then
		Enums[v5667] = v5665
	end
end)
local v5666 = "TargetLayerInterface"
local v5667 = 2832
pcall(function()
	local v5668 = enum[v]
	local v5669 = v5668 and v5668[v5666]

	if v5669 then
		Enums[v5669] = v5667
	end
end)
local v5668 = "Rbf"
local v5669 = 2833
pcall(function()
	local v5670 = enum[v]
	local v5671 = v5670 and v5670[v5668]

	if v5671 then
		Enums[v5671] = v5669
	end
end)
local v5670 = "OuterCageDetail"
local v5671 = 2834
pcall(function()
	local v5672 = enum[v]
	local v5673 = v5672 and v5672[v5670]

	if v5673 then
		Enums[v5673] = v5671
	end
end)
v = "ZIndexBehavior"
local v5672 = "Global"
local v5673 = 2835
pcall(function()
	local v5674 = enum[v]
	local v5675 = v5674 and v5674[v5672]

	if v5675 then
		Enums[v5675] = v5673
	end
end)
local v5674 = "Sibling"
local v5675 = 2836
pcall(function()
	local v5676 = enum[v]
	local v5677 = v5676 and v5676[v5674]

	if v5677 then
		Enums[v5677] = v5675
	end
end)
v = "ParticleFlipbookLayout"
local v5676 = "None"
local v5677 = 2837
pcall(function()
	local v5678 = enum[v]
	local v5679 = v5678 and v5678[v5676]

	if v5679 then
		Enums[v5679] = v5677
	end
end)
local v5678 = "Grid2x2"
local v5679 = 2838
pcall(function()
	local v5680 = enum[v]
	local v5681 = v5680 and v5680[v5678]

	if v5681 then
		Enums[v5681] = v5679
	end
end)
local v5680 = "Grid4x4"
local v5681 = 2839
pcall(function()
	local v5682 = enum[v]
	local v5683 = v5682 and v5682[v5680]

	if v5683 then
		Enums[v5683] = v5681
	end
end)
local v5682 = "Grid8x8"
local v5683 = 2840
pcall(function()
	local v5684 = enum[v]
	local v5685 = v5684 and v5684[v5682]

	if v5685 then
		Enums[v5685] = v5683
	end
end)
local v5684 = "Custom"
local v5685 = 2841
pcall(function()
	local v5686 = enum[v]
	local v5687 = v5686 and v5686[v5684]

	if v5687 then
		Enums[v5687] = v5685
	end
end)
return Enums