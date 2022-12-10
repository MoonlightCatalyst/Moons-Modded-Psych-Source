--[[ setting stuffs ]]
local following = true
local offsets = {["dad"] = 15, ["boyfriend"] = 15}
local manual = {["dad"] = {0, 0}, ["boyfriend"] = {0, 0},
	["enabled"] = false
}

--[[ internal stuffs ]]
local anims = {["singL"] = true, ["singD"] = false, ["singU"] = false, ["singR"] = true}
local singing = {["dad"] = false, ["boyfriend"] = false}
local function get_pos(char)
	if manual["enabled"] then return manual[char] else
		local mid, pos = {getMidpointX(char), getMidpointY(char)}, getProperty(char .. ".cameraPosition")
		local offset = getProperty((mustHitSection and char or "opponent") .. "CameraOffset")
		return {mid[1] + (mustHitSection and -100 or 150) + (mustHitSection and -pos[1] or pos[1]) + offset[1],
		mid[2] - 100 + pos[2] + offset[2]}
	end
end
local function follow(char)
	local anim, pos, offset = getProperty(char .. ".animation.curAnim.name"):sub(1, 5), get_pos(char), offsets[char]
	local pos_clone, horizontal = {pos[1], pos[2]}, anims[anim]
	if following then if horizontal then pos_clone[1] = pos_clone[1] + (anim == "singL" and -offset or offset)
		elseif horizontal == false then pos_clone[2] = pos_clone[2] + (anim == "singU" and -offset or offset) end
	end
	setProperty("camFollow.x", pos_clone[1]); setProperty("camFollow.y", pos_clone[2])
end
function onStartCountdown() setProperty("isCameraOnForcedPos", true); follow("dad") end
function onBeatHit() if curBeat % 4 == 0 then follow(mustHitSection and "boyfriend" or "dad") end end
local function check_idle(char) local anim = getProperty(char .. ".animation.curAnim.name")
	if anim == "idle" then if singing[char] then follow(char) end singing[char] = false end
end
function onTimerCompleted(tag)
	if mustHitSection then if tag == "follow_boyfriend_idle" then check_idle("boyfriend") end
	elseif tag == "follow_dad_idle" then check_idle("dad") end
end
local function follow_note(note_type, sustained)
	if note_type ~= "No Animation" then 
		local char = mustHitSection and "boyfriend" or "dad"
		if not sustained then follow(char) end
		singing[char] = true
		runTimer("follow_" .. char .. "_idle", (stepCrochet * getProperty(char .. ".singDuration") + 30) / 1000)
	end
end
function goodNoteHit(id, direction, note_type, sustained) follow_note(note_type, sustained) end
function opponentNoteHit(id, direction, note_type, sustained) follow_note(note_type, sustained) end
