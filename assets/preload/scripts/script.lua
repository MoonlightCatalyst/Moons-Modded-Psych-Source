function onCreatePost()
	for i = 0, getProperty('unspawnNotes.length')-1 do
      --Check if the note is an Sustain Note
        if getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true);
        end
    end
end


function goodNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote then
        if getPropertyFromGroup('notes', id, 'gfNote') or noteType == 'GF Sing' then
            setProperty('gf.holdTimer', 0);
        else
           setProperty('boyfriend.holdTimer', 0);
        end
    end
end


function opponentNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote then
        if getPropertyFromGroup('notes', id, 'gfNote') or noteType == 'GF Sing' then
            setProperty('gf.holdTimer', 0);
        else
            setProperty('dad.holdTimer', 0);
        end
    end
end

function onUpdatePost()
    setTextString('timeTxt', formatTime(getSongPosition() - noteOffset) .. ' / ' .. formatTime(songLength))
    
    if dadName == 'bf' then
        triggerEvent('Change Character', 'dad', 'bf-opponent')
    end
end

function formatTime(millisecond)
    local seconds = math.floor(millisecond / 1000)

    return string.format("%01d:%02d", (seconds / 60) % 60, seconds % 60)  
end