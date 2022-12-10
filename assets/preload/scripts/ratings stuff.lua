-- Combo numbers --

local uno = 0
local dos = 0
local thr = 0
local fuo = 0

local unoMis = 0
local dosMis = 0
local thrMis = 0
local fuoMis = 0

local MAXED = false -- Kinda useless, who tf has 9999 notes, much less 10000?? | Don't even work right
local tens = false  -- For
local hund = false  -- Ever
local thous = false -- For the fourth digit to appear
local eh = 0        -- Make the sprites load in the way it does

-- Opponent Combo Numbers --

local unoOp = 0
local dosOp = 0
local thrOp = 0
local fuoOp = 0

local MAXEDOP = false -- Kinda useless, who tf has 9999 notes, much less 10000?? | Don't even work right
local tensOp = false  -- For
local hundOp = false  -- Ever
local thousOp = false -- For the fourth digit to appear
local ehOp = 0        -- Make the sprites load in the way it does

-- Settings (Player) --

local visible = true  -- Show it?

local pixel = false   -- Want pixel combo?

local showComboThng = true           -- Show that "unused" combo thing

local foreverComboCount = false       -- Shows combo nnumber how forever engine does it 
local countMisses = false              -- forever engine is pretty cool

local missSprite = false              -- Show a thing when you fuck up | Forever engine miss sprite, my beloved |

local ratingGrab = {'sick', 'good', 'bad', 'shit'} -- What it'll grab | Make sure sprite is in mods/images
local numPrefix = 'num'                -- Easier to change numbers | Name it like "rednum" or "Invnum"
local numSuffix = ''

local combType = 'combo'               -- For swappin with pixel 'n such
local missType = 'miss'

local constantGameCam = false           -- Keeps thing hooked onto game character or item

local defaultPosRating = {450, 280}    -- Positions it'll use for ratings when not on player combo | HUD 'n Other cam | default numbers: 450, 300
local defaultPosNum = {450, 365}                                                                                    --| default numbers: 450, 385

local defaultPosRateGame = {nil, nil}  -- Position for game cam | Defaults to my preset if untouched 
local defaultPosNumGame = {nil, nil}

local comboThngPos = {nil, nil}        -- You alreaady know
local comboThngPosGame = {nil, nil} 


local ratingScale = {0.69, 0.69}        -- You can guess what these are for | DEFAULT: rating = 0.69, 0.69 | num = 0.5, 0.5
local numScale = {0.5, 0.5}             -- IF you mess with the numScale, be sure to adjust it's spacing down below as they might overlap
local combThgnScale = {0.58, 0.58}

local onPlayerCombo = false  -- If it'll show on where the player has the ratings offsets, not 100% perfect | INCOMPATIBLE with 'game' & 'other' cam | Make sure RATINGS is tied to HUD

local camSet = 'game'    -- Should it be on the Hud or Game or Other?  Hud | Game | Other  (NOTICE: for the game cam, I have its default set to rely on Gfs position)

-- Settings (Opponent) --

local visibleOp = false   -- Show it?

local pixelOp = false

local foreverComboCountOp = false

local ratingGrabOp = {'sick', 'good', 'bad', 'shit'}
local numPrefixOp = 'num'
local numSuffixOp = ''

local defaultPosRatingOp = {350, 440}   -- Positions it'll use | default numbers: 350, 440
local defaultPosNumOp = {380, 535}                           --| default numbers: 380, 535

local defaultPosRateGameOp = {nil, nil} -- Position for game cam
local defaultPosNumGameOp = {nil, nil}

local ratingScaleOp = {0.69, 0.69} -- DEFAULT: rating = 0.69, 0.69 | num = 0.5, 0.5
local numScaleOp = {0.5, 0.5}

local onPlayerComboOp = false

local camSetOp = 'hud'  -- Hud | Game | Other

local randGoods = false -- Makes some goods occasionally appear 
local randBads = false  -- Makes some bads occasionally appear         | Should you turn all these on? Probably not
local randShits = false -- Makes some shits occasionally appear 
local chanceGood
local chanceBad 
local chanceShit

-- Settings (Both) --

local ratingSpecial = {'dodge'}      -- <example> | For special notes (optional) | mods/images or path please
local ratingSpecialOp = {'dodge'}
local specialType = 'Bullet_Note'    -- <example> | What's the note type called

-- Modes (Player) --

local simpleMode = false -- Only 1 set of numbers and ratings are shown at a time | Helps prevent lag

local stationaryMode = false -- Prevent the Rating hop | Simple mode recommended

local hideRating = false  -- Hides rating, not numbers (who coulda guessed)
local hideNums = false    -- Hides numbers, not ratings (who coulda guessed)


local colorRatings = false  -- Color the ratings based on which you get, Sick is blue, good is green, etc
local colorSyncing = false -- Let the colors shine tonight | Rating takes color of direction pressed | Not for custom colors | Overwrites colorRatings
local colorFade = false    -- Fades color back to baseColor's value
local fcColorRating = false -- Colors Ratings based of FC level, like andromeda!!! (Turn off others, they overide this)

local colorNumbers = false -- Same as above, but for numbers
local colorSyncNums = false
local colorFadeNums = false
local fcColorNums = false -- Colors numbers based of FC level, like andromeda!!! (Turn off others, they overide this)

local combColor = false
local combColorFade = false

-- Modes (Opponent) --

local simpleModeOp = false

local stationaryModeOp = false

local hideRatingOp = false 
local hideNumsOp = false 


local colorRatingsOp = true -- Ratings based on which you get
local colorSyncingOp = true -- Rating takes color of direction pressed 
local colorFadeOp = true  -- Fade to base

local colorNumbersOp = true -- Same as above, but for numbers
local colorSyncNumsOp = true
local colorFadeNumsOp = true

-- Colors --

    -- For color modes --
 -- Best with base ratings --
 
    -- Chad Hex color please --
local sickColor = '68fafc'
local goodColor = '48f048' -- less obnoxious green | ori: 00d426
local badColor = 'fffecb'
local baseColor = 'ffffff' 
    -- no shit color cuz you don't deserve a color

local colorSync0 = 'c24b99' -- left  | '9a25d9' = original
local colorSync1 = '68fafc' -- down  | '68fafc' = original
local colorSync2 = '12fa05' -- up    | '21c400' = original
local colorSync3 = 'f9393f' -- right | 'ff1900' = original

local combUse -- Uses previously set colors, so no unique value

-- Opponent (Coulda just made it take the colors up there, but noooo Gotta add more options) --

local sickColorOp = '68fafc'
local goodColorOp = '48f048'
local badColorOp = 'fffecb'
local baseColorOp = 'ffffff'    

local colorSync0Op = 'c24b99'
local colorSync1Op = '68fafc'
local colorSync2Op = '12fa05'
local colorSync3Op = 'f9393f'

-- ANIMATED RATINGS Settings --
local ANIMATED = false        -- Uses rating settings from up there
--local ANIMATEDOP = false   -- Later  

    -- If your ratings are all seperate. if not, just name them all the same
    local fileNames = {'ratings/testRating', 'ratings/testRating', 'ratings/testRating', 'ratings/testRating'}         
    local animNames = {'sick_', 'good_', 'bad_', 'shit_'}  -- Names of animations on .xml
    local animFrameRate = 60

    local animRatePos = {450, 280}
    local animRatePosGame = {nil, nil}
    local animRateOffsts = {490, 230}   -- If "onPlayerCombo" and its not quite where you want
    local animRatScale = {5, 5}

    local veloctitty = true             -- Should it hop like the regular ratings
    local ratPixl = true                -- Is the rating pixelly
    local colorAnim = false             -- Color it like regular
    local singleAnim = false            -- Only one rating at a time
    local animFade = true               -- Should it fade like regular ratings
        local initDelay = 0.2           -- Incase your rating fades before it completes the animation (How long it shows before the fade)


-- Dont touch these unless you know what you're doing | I don't sadly :(
local xAyy = 440 -- (exists just to shove the thing when you got combo of 1000)
local xAyyOp = 440 
local once = false -- for said option
local onceOp = false
local brokeCombo = nil -- only one set of 0's will appear if you miss more than 1 time in a row
local doThing = false

--------------------------------------------------------------------------|The Code Shit|---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------|By Unholywanderer04|------------------------------------------------------------------------------------------

function onCreate() -- bbPantsZoo
    curver = 0

    bit = string.gsub(version,"%.","")
    curver = tonumber(bit)

    if curver >= 60 then 
        doThing = true
        --debugPrint('Doing thingggg')
    end
end

function onDestroy()
    if doThing == false then
        setPropertyFromClass('ClientPrefs', 'hideHud', false) -- (Fail Safe) So the stupid thing actually (hopefully) unhides once you complete a song >:(
    end
end

function onCreatePost()
    if getPropertyFromClass('PlayState', 'isPixelStage') == true then
        pixel = true
        pixelOp = true
    end

        -- Can't call this stuff outside of a function so --
        -- Checks if BOTH values are nil. Why? just cause --

                    -- Rating game POS check --
    if defaultPosRateGame[1] == nil and defaultPosRateGame[2] == nil then
        defaultPosRateGame[1] = getProperty('gf.x') + -200
        defaultPosRateGame[2] = getProperty('gf.y') + 70
    end


                    -- Number game POS check --
    if defaultPosNumGame[1] == nil and defaultPosNumGame[2] == nil then
        defaultPosNumGame[1] = getProperty('gf.x') + -160
        defaultPosNumGame[2] = getProperty('gf.y') + 200
    end


                        -- Animated --
    if animRatePosGame[1] == nil and animRatePosGame[2] == nil then
        animRatePosGame[1] = getProperty('gf.x') + 400
        animRatePosGame[2] = getProperty('gf.y') + 200
    end
   
    -- Pixel shit, move this to onUpdate if you're gonna do sumthin wacky --
    -- But if it's for setting a stage, like the school, just keep it here --

    if pixel == true then 
        ratingGrab[1] = 'pixelUI/sick-pixel' 
        ratingGrab[2] = 'pixelUI/good-pixel'
        ratingGrab[3] = 'pixelUI/bad-pixel' 
        ratingGrab[4] = 'pixelUI/shit-pixel'

        ratingScale[1] = 5
        ratingScale[2] = 5

        numPrefix = 'pixelUI/num'
        numSuffix = '-pixel'
        numScale[1] = 5
        numScale[2] = 5

        defaultPosRateGame[1] = getProperty('gf.x') + 300
        defaultPosRateGame[2] = getProperty('gf.y') + 50
        defaultPosNumGame[1] = getProperty('gf.x') + 300
        defaultPosNumGame[2] = getProperty('gf.y') + 150
    
        combType = 'pixelUI/combo-pixel'
        missType = 'pixelUI/miss-pixel'
        combThgnScale[1] = 4
        combThgnScale[2] = 4

        colorSync0 = 'e276ff'
        colorSync1 = '3dcaff'
        colorSync2 = '71e300'
        colorSync3 = 'ff884e'

        sickColor = '3dcaff'
        goodColor = '71e300'
    end

    if pixelOp == true then
        ratingGrabOp[1] = 'pixelUI/sick-pixel' 
        ratingGrabOp[2] = 'pixelUI/good-pixel'
        ratingGrabOp[3] = 'pixelUI/bad-pixel' 
        ratingGrabOp[4] = 'pixelUI/shit-pixel'

        ratingScaleOp[1] = 5
        ratingScaleOp[2] = 5

        numPrefixOp = 'pixelUI/num'
        numSuffixOp = '-pixel'
        numScaleOp[1] = 5
        numScaleOp[2] = 5

        defaultPosRateGameOp[1] = getProperty('gf.x') - 150
        defaultPosRateGameOp[2] = getProperty('gf.y') + 150
        defaultPosNumGameOp[1] = getProperty('gf.x') - 150
        defaultPosNumGameOp[2] = getProperty('gf.y') + 250

        colorSync0Op = 'e276ff'
        colorSync1Op = '3dcaff'
        colorSync2Op = '71e300'
        colorSync3Op = 'ff884e'

        sickColorOp = '3dcaff'
        goodColorOp = '71e300'
    end

    if showComboThng == true then
        if comboThngPos[1] == nil and comboThngPos[2] == nil then
            comboThngPos[1] = defaultPosNum[1] + 30
            comboThngPos[2] = defaultPosNum[2] + 50
        end
        if comboThngPosGame[1] == nil and comboThngPosGame[2] == nil then
            comboThngPosGame[1] = defaultPosNumGame[1] + 600
            comboThngPosGame[2] = defaultPosNumGame[2] + 80
        end
    end

    if visible == true then -- getting rid of this crashes the game??? alright????
        --setPropertyFromClass('ClientPrefs', 'hideHud', true)
    end
end

function onUpdate()
    if visible == true then
        if doThing == true then
            setProperty('showRating', false)
            setProperty('showComboNum', false)
        else    
            setPropertyFromClass('ClientPrefs', 'hideHud', true) -- If you're gonna do cool rating shit, mess with it here
        end
    end

    if visible == false then
        if doThing == true then
            setProperty('showRating', true)
            setProperty('showComboNum', true)
        else
            setPropertyFromClass('ClientPrefs', 'hideHud', false)
        end
    end

    if constantGameCam == true then
        -- For your moving characters and things --
        if not pixel then
            defaultPosRateGame[1], defaultPosRateGame[2] = getProperty('boyfriend.x') + 400, getProperty('boyfriend.y') + 200
            defaultPosNumGame[1], defaultPosNumGame[2] = getProperty('boyfriend.x') + 400, getProperty('boyfriend.y') + 300
            if foreverComboCount and not thous then
                comboThngPosGame[1], comboThngPosGame[2] = defaultPosNumGame[1] + 30, defaultPosNumGame[2] + 20
            end

            defaultPosRateGameOp[1], defaultPosRateGameOp[2] = getProperty('boyfriend.x') + 100, getProperty('boyfriend.y') + 400
            defaultPosNumGameOp[1], defaultPosNumGameOp[2] = getProperty('boyfriend.x') + 90, getProperty('boyfriend.y') + 500

            animRatePosGame[1], animRatePosGame[2] = getProperty('boyfriend.x') + 400, getProperty('boyfriend.y') + 200
        end
    end
            -- forever my beloved --
    if getProperty('combo') >= 9 and tens == false and foreverComboCount then
        tens = true -- better than on good note hit
    end
    if getProperty('combo') >= 99 and hund == false and foreverComboCount then
        hund = true 
    end
    if getProperty('combo') >= 999 and thous == false then
        thous = true
    end

    if thous == true and once == false then -- shoves the numbers to the right a bit once 1000 is reached --
        if foreverComboCount and showComboThng then
            once = true
            comboThngPosGame[1] = defaultPosNumGame[1] + 60 -- combo gets covered, so move it a bit
            comboThngPos[1] = defaultPosNum[1] + 60
        else
            once = true
            defaultPosNum[1] = defaultPosNum[1] + 20
            defaultPosNumGame[1] = defaultPosNumGame[1] + 20
            xAyy = xAyy + 20
        end
    elseif thous == false and once == true then -- missed with 1000+ combo
        if foreverComboCount and showComboThng then
            once = false
            comboThngPosGame[1] = defaultPosNumGame[1] - 60
            comboThngPos[1] = defaultPosNum[1] - 60
        else
            once = false
            defaultPosNum[1] = defaultPosNum[1] - 20
            defaultPosNumGame[1] = defaultPosNumGame[1] - 20
            xAyy = xAyy - 20
        end
    end

    if thousOp == true and onceOp == false and not foreverComboCountOp then     
        onceOp = true
        defaultPosNumOp[1] = defaultPosNumOp[1] + 20
        defaultPosNumGameOp[1] = defaultPosNumGameOp[1] + 20
        xAyyOp = xAyyOp + 20
    end

    if (getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SEVEN') or getPropertyFromClass('flixel.FlxG', 'keys.justPressed.EIGHT')) and doThing == false then
        setPropertyFromClass('ClientPrefs', 'hideHud', false)
    end

    -- These are here for more randomness --
    chanceGood = math.random(1, 50)
    chanceBad = math.random(1, 65)
    chanceShit = math.random(1, 74)
end

function goodNoteHit(id, direction, noteType, isSustainNote) 
if not isSustainNote then
if songName == 'Cheating' or songName == 'Unfairness' or songName == 'Exploitation' then
    for i = 0, getProperty('notes.length')-1 do
      if getPropertyFromGroup('notes', i, 'texture') == 'NOTE_assets_3D-alt' then
        combType = '3D/combo'
        numPrefix = '3D/num'
        numSuffix = ''
        ratingGrab = {'3D/sick', '3D/good', '3D/bad', '3D/shit'}
      else
        ratingGrab = {'sick', 'good', 'bad', 'shit'} 
        combType = 'combo'
        numSuffix = ''
        numPrefix = 'num'
      end
    end
else
    if boyfriendName == '3d-bf' then
        combType = '3dUi/combo-3d'
        numPrefix = '3dUi/num'
        numSuffix = '-3d'
        ratingGrab = {'3dUi/sick-3d', '3dUi/good-3d', '3dUi/bad-3d', '3dUi/shit-3d'}
      else
      for i = 0, getProperty('notes.length')-1 do
        if getPropertyFromGroup('notes', i, 'texture') == 'NOTE_assets_3D' then
            combType = '3dUi/combo-3d'
            numPrefix = '3dUi/num'
            numSuffix = '-3d'
            ratingGrab = {'3dUi/sick-3d', '3dUi/good-3d', '3dUi/bad-3d', '3dUi/shit-3d'}
        else
            ratingGrab = {'sick', 'good', 'bad', 'shit'} 
            combType = 'combo'
            numSuffix = ''
            numPrefix = 'num'
        end
      end
    end
end
end
    defaultPosRateGame[1], defaultPosRateGame[2] = getProperty('gf.x') + 400, getProperty('gf.y') + 200
    defaultPosNumGame[1], defaultPosNumGame[2] = getProperty('gf.x') + 450, getProperty('gf.y') + 350

    if visible == true then
        comboOffset = getPropertyFromClass('ClientPrefs', 'comboOffset') -- rating offsets ( [1] Rating X | [2] Rating Y | [3] Number X | [4] Number Y ) 
        if not isSustainNote then
            brokeCombo = false
            if simpleMode == true then
                eh = 0 -- Keeps 'eh' at 0 so it can't spawn more than one at a time
            end

            -- Took from Whitty mod >:)
            strumTime = getPropertyFromGroup('notes', id, 'strumTime')
            hmm = getRating(strumTime - getSongPosition() + getPropertyFromClass('ClientPrefs','ratingOffset'), noteType)

            -- small thing, checks rating color
            ratingColo = ''
            ratiNum = 0

            if hmm == 'sick' then
                ratingColo = sickColor
                ratiNum = 1
            elseif hmm == 'good' then
                ratingColo = goodColor
                ratiNum = 2
            elseif hmm == 'bad' then
                ratingColo = badColor
                ratiNum = 3
            elseif hmm == 'shit' then
                ratingColo = baseColor
                ratiNum = 4
            else
                ratingColo = baseColor
                ratiNum = nil
            end
            anHmm = hmm
            if hideRating == true then -- so the color gets set based on rating, THEN it removes the rating
                hmm = ''
                ratiNum = nil
            end

            grabby = {colorSync0, colorSync1, colorSync2, colorSync3}
            thisOne = nil
            numUse = nil

            if colorRatings == true and colorSyncing == false then
                thisOne = ratingColo
                combUse = ratingColo
            elseif colorSyncing == true then
                if hmm ~= 'shit' then thisOne = grabby[direction+1] else thisOne = baseColor end
                combUse = grabby[direction+1]
            elseif fcColorRating == true then
                if getProperty('ratingFC') == 'SFC' then
                    thisOne = sickColor
                    combUse = sickColor
                elseif getProperty('ratingFC') == 'GFC' then
                    thisOne = goodColor
                    combUse = goodColor
                elseif getProperty('ratingFC') == 'FC' then
                    thisOne = badColor
                    combUse = badColor
                else
                    thisOne = baseColor
                    combUse = baseColor
                end
            else
                thisOne = baseColor
                combUse = baseColor
            end
            
            if combColor == false then
                combUse = baseColor
            end

            if colorNumbers == true and colorSyncNums == false then
                numUse = ratingColo
            elseif colorSyncNums == true then
                numUse = grabby[direction+1]
            elseif fcColorNums == true then
                if getProperty('ratingFC') == 'SFC' then
                    numUse = sickColor
                elseif getProperty('ratingFC') == 'GFC' then
                    numUse = goodColor
                elseif getProperty('ratingFC') == 'FC' then
                    numUse = badColor
                else
                    numUse = baseColor
                end
            else
                numUse = baseColor
            end

            -------------------------------Ratings---------------------------------------            

            -- This grabs the default Rating images in either assets/shared/images or mods/images depending on if you're using a mod AND if there are Rating images in there.
            -- I recommend making a folder for ratings if you do some wacky things, specifially for ease of access.
            if ANIMATED then
                animatedAss(hmm)
            else
                if onPlayerCombo == true and camSet == 'hud' then
                    if ratiNum ~= nil then
                        makeLuaSprite(hmm ..'ly' .. eh, ratingGrab[ratiNum], 400 + comboOffset[1], 230 - comboOffset[2])
                    end
                elseif camSet == 'game' then
                    if ratiNum ~= nil then
                        makeLuaSprite(hmm ..'ly' .. eh, ratingGrab[ratiNum], defaultPosRateGame[1], defaultPosRateGame[2]) -- default position for game cam
                    end
                else
                    if ratiNum ~= nil then
                        makeLuaSprite(hmm ..'ly' .. eh, ratingGrab[ratiNum], defaultPosRating[1], defaultPosRating[2]) -- Default position for any other cam, hud, other, etc
                    end
                end
                setProperty(hmm ..'ly'.. eh .. '.color', getColorFromHex(thisOne))
                setObjectCamera(hmm ..'ly' .. eh, camSet)
                setObjectOrder(hmm ..'ly' .. eh, getObjectOrder('strumLineNotes')-1)
                scaleObject(hmm ..'ly' .. eh, ratingScale[1], ratingScale[2])
                if pixel == true then
                    setProperty(hmm ..'ly' .. eh .. '.antialiasing', false)
                end
                addLuaSprite(hmm ..'ly' .. eh, true)
                if stationaryMode == false then
                    setProperty(hmm ..'ly' .. eh .. '.acceleration.y', 550)
                    setProperty(hmm ..'ly'.. eh ..'.velocity.x', math.random(0,10))
                    setProperty(hmm ..'ly'.. eh ..'.velocity.y', -180)
                end
                doTweenAlpha('nachotween' .. eh .. hmm, hmm ..'ly' .. eh, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
                if colorFade == true then
                    doTweenColor('cool' .. eh, hmm ..'ly' .. eh, baseColor, 0.2 + (stepCrochet * 0.002), 'quartIn')
                end
                if getProperty(hmm ..'ly'.. eh ..'.alpha') == 0 then -- don't think this works :(, not with the default mode
                    removeLuaSprite(hmm ..'ly'.. eh, false)
                end  
            end

            if showComboThng == true then
                if onPlayerCombo == true and camSet == 'hud' then
                    makeLuaSprite('combThing' .. eh, combType, 450 + comboOffset[3], 430 - comboOffset[4])
                elseif camSet == 'game' then
                    if getProperty('combo') > 10 then
                    makeLuaSprite('combThing' .. eh, combType, comboThngPosGame[1], comboThngPosGame[2])
                    end
                else
                    makeLuaSprite('combThing' .. eh, combType, comboThngPos[1], comboThngPos[2])
                end
                setObjectCamera('combThing' .. eh, camSet)
                if pixel == true then
                   setProperty('combThing' .. eh .. '.antialiasing', false)
                end
                setObjectOrder('combThing' .. eh, getObjectOrder('strumLineNotes')-1)
                scaleObject('combThing' .. eh, combThgnScale[1], combThgnScale[2])
                setProperty('combThing' .. eh .. '.color', getColorFromHex(combUse))
                addLuaSprite('combThing' .. eh, true)
                if stationaryMode == false then
                    setProperty('combThing' .. eh .. '.acceleration.y', 550)
                    setProperty('combThing' .. eh .. '.velocity.x', math.random(0,10))
                    setProperty('combThing' .. eh .. '.velocity.y', -200)
                end
                doTweenAlpha('nachotweenComb' .. eh, 'combThing' .. eh, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
                if combColorFade == true then
                    doTweenColor('coolCom' .. eh, 'combThing' .. eh, baseColor, 0.2 + (stepCrochet * 0.002), 'quartIn')
                end
                if getProperty('combThing'.. eh .. '.alpha') == 0 then
                   removeLuaSprite('combThing'.. eh, true)
                end   
            end

            -------------------------------Special---------------------------------------

                --example--
            --[[if noteType == specialType then
                if onPlayerCombo == true and camSet == 'hud' then
                    makeLuaSprite('specially' .. eh, ratingSpecial[1], 400 + comboOffset[1], 230 - comboOffset[2])
                elseif camSet == 'game' then
                    makeLuaSprite('specially' .. eh, ratingSpecial[1], defaultPosRateGame[1], defaultPosRateGame[2]) -- default position for game cam | change if you want
                else
                    makeLuaSprite('specially' .. eh, ratingSpecial[1], defaultPosRating[1], defaultPosRating[2])
                end
                setProperty('specially'.. eh .. '.color', getColorFromHex(baseColor)) -- change if ya want
                setObjectCamera('specially' .. eh, camSet)
                setObjectOrder('specially' .. eh, getObjectOrder('strumLineNotes')-1)
                scaleObject('specially' .. eh, ratingScale[1], ratingScale[2])
                --if pixel == true then -- if you actually have ppixel versions, uncomment
                --    setProperty('specially' .. eh .. '.antialiasing', false)
                --end
                addLuaSprite('specially' .. eh, true)
                if stationaryMode == false then
                    setProperty('specially' .. eh .. '.acceleration.y', 550)
                    setProperty('specially'.. eh ..'.velocity.x', math.random(0,10))
                    setProperty('specially'.. eh ..'.velocity.y', -180)
                end
                doTweenAlpha('nachotweenSpec' .. eh, 'specially' .. eh, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
                if colorFade == true then
                --    doTweenColor('coolSpec' .. eh, 'specially' .. eh, baseColor, 0.2 + (stepCrochet * 0.002), 'quartIn')
                end
                if getProperty('specially'.. eh ..'.alpha') == 0 then
                    removeLuaSprite('specially'.. eh, false)
                end 
            end]]

            eh = eh + 1 -- makes the sprites spawn the way they do

            if eh > 100 then
                eh = 0 -- So it begins to overwrite inital sprites (stops lag)
            end

            -------------------------------Counter---------------------------------------
           
            uno = uno + 1
            if uno > 9 and MAXED ~= true then
               uno = 0
               dos = dos + 1
               if dos > 9 then
                    dos = 0
                    thr = thr + 1
                    if thr > 9 then
                        --thous = true
                        thr = 0
                        fuo = fuo + 1
                        if fuo == 9 and thr == 9 and dos == 9 and uno == 9 then -- questionable at best | I'm not bothering to fix this | 10,000 note havin ass
                            MAXED = true
                        end
                    end
                end
            elseif MAXED == true then
                -- who tf puts over 10000 notes
                uno = 9
                dos = 9
                thr = 9
                fuo = 9
            end
            
            --------------------------------Numbers----------------------------------------
                               
            if hideNums == false then
                numbers = {'1','2','3','4','5','6','7','8','9'}
                numbers[0] = '0'
                    
                numCount = 0 -- 1
                if tens == true then numCount = 1 end -- 01
                if hund == true or foreverComboCount == false then numCount = 2 end -- 001
                if thous == true then numCount = 3 end -- 0001
                    
                for i = 0, numCount, 1 do
                    sequence = nil
                    if not foreverComboCount then multBy = (i * 43) else multBy = (((i + 2) - numCount) * 43) end -- spacing and spawning
                    if i == 0 then
                        sequence = numPrefix .. numbers[uno] .. numSuffix
                    elseif i == 1 then
                        sequence = numPrefix .. numbers[dos] .. numSuffix
                    elseif i == 2 then
                        sequence = numPrefix .. numbers[thr] .. numSuffix
                    elseif i == 3 then
                        sequence = numPrefix .. numbers[fuo] .. numSuffix
                    end

                    if onPlayerCombo == true and camSet == 'hud' then
                        makeLuaSprite('num' .. eh .. i, sequence, xAyy + comboOffset[3] - multBy, 390 - comboOffset[4])
                    elseif camSet == 'game' then
                        if getProperty('combo') > 10 then
                        makeLuaSprite('num' .. eh .. i, sequence, defaultPosNumGame[1] - multBy, defaultPosNumGame[2])
                        end
                    else
                        makeLuaSprite('num' .. eh .. i, sequence, defaultPosNum[1] - multBy, defaultPosNum[2])
                    end
                    setObjectCamera('num' .. eh .. i, camSet)
                    setProperty('num'.. eh .. i .. '.color', getColorFromHex(numUse))
                    setObjectOrder('num' .. eh .. i, getObjectOrder('strumLineNotes')-1)
                    if pixel then
                        setProperty('num' .. eh .. i .. '.antialiasing', false)
                    end
                    scaleObject('num' .. eh .. i, numScale[1], numScale[2])
                    addLuaSprite('num' .. eh .. i, true)
                    if stationaryMode == false then
                        setProperty('num' .. eh .. i .. '.acceleration.y', math.random(200, 400))
                        setProperty('num'.. eh .. i ..'.velocity.x', math.random(-5, 5))
                        setProperty('num'.. eh .. i ..'.velocity.y', math.random(-140, -160))
                    end
                    doTweenAlpha('nachotweenNumGo' .. eh .. i, 'num' .. eh .. i, 0, 0.2 + (stepCrochet * 0.008), 'quartIn')
                    if colorFadeNums == true then
                        doTweenColor('itsjustafad' .. eh .. i, 'num' .. eh .. i, baseColor, 0.2 + (stepCrochet * 0.005), 'quartIn')
                    end
                end
            end
        end
    end
end

local missTen = false
local missHund = false
local missThou = false
function noteMiss(id, direction, noteType, isSustainNote) --Sets back to 0
    eh = eh + 1
    if missSprite == true then
        if onPlayerCombo == true and camSet == 'hud' then
            if simpleMode == true then id = 0 end
            makeLuaSprite('looser' .. eh, missType, 410 + comboOffset[1], 230 - comboOffset[2])
        elseif camSet == 'game' then
            if simpleMode == true then eh = 0 end
            makeLuaSprite('looser' .. eh, missType, defaultPosRateGame[1], defaultPosRateGame[2])
        else
            if simpleMode == true then eh = 0 end
            makeLuaSprite('looser' .. eh, missType, defaultPosRating[1], defaultPosRating[2])
        end
        setObjectCamera('looser' .. eh, camSet)
        if pixel == true then
            setProperty('looser' .. eh .. '.antialiasing', false)
            scaleObject('looser' .. eh, ratingScale[1] + 0.25, ratingScale[2] + 0.25)
        else
            scaleObject('looser' .. eh, ratingScale[1] + 0.2, ratingScale[2] + 0.2)
        end
        setObjectOrder('looser' .. eh, getObjectOrder('strumLineNotes')-1)
        addLuaSprite('looser' .. eh, true)
        if stationaryMode == false then
            setProperty('looser' .. eh .. '.acceleration.y', 550)
            setProperty('looser' .. eh .. '.velocity.x', math.random(0,10))
            setProperty('looser' .. eh .. '.velocity.y', -200)
        end
        doTweenAlpha('nachotweenBru' .. eh, 'looser' .. eh, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
        if getProperty('looser'.. eh .. '.alpha') == 0 then
           removeLuaSprite('looser'.. eh, true)
        end
    end

    unoMis = unoMis + 1
    if unoMis > 9 then -- doesn't go above 1000, no need to, you don't suck THAT much
        missTen = true
        unoMis = 0
        dosMis = dosMis + 1
        if dosMis > 9 then
            missHund = true
            dosMis = 0
            thrMis = thrMis + 1
        end
    end


    if hideNums == false then
        numbers = {'1','2','3','4','5','6','7','8','9'}
        numbers[0] = '0'

        numCount = 1
        if missTen == true or not countMisses then numCount = 2 elseif missHund == true then numCount = 3 end
        if countMisses then if missHund then numCount = 3 end end
        blap = getProperty('songMisses')
        if pixel then
            mPrefi = 'pixelUI/'
        else
            mPrefi = ''
        end
        for i = 0, numCount do
            sequence = nil
            multBy = (((i + 2) - numCount) * 43) -- spacing and spawning

            if i == 0 then -- 1
                sequence = numPrefix .. numbers[unoMis] .. numSuffix
            elseif i == 1 then -- 01
                sequence = mPrefi .. 'minus' .. numSuffix
                if blap >= 10 then
                sequence = numPrefix .. numbers[dosMis] .. numSuffix end
            elseif i == 2 then -- 001
                if blap >= 10 and blap < 100 then sequence = mPrefi .. 'minus' .. numSuffix
                else sequence = numPrefix .. numbers[thrMis] .. numSuffix end -- > -10 miss
            elseif i == 3 then -- 0001
                if blap >= 100 and blap < 999 then sequence = mPrefi .. 'minus' .. numSuffix
                elseif blap >= 1000 then sequence = numPrefix .. numbers[fuoMis] .. numSuffix end -- > -100 miss
            end -- 1000? get better

            if countMisses == false then 
               sequence = numPrefix .. '0' .. numSuffix
            end
        end
    end

    uno = 0
    dos = 0
    thr = 0
    fuo = 0

    tens = false -- oops
    hund = false
    thous = false -- forgot this
    brokeCombo = true
end

function animatedAss(rating)
    fakeEh = eh
    if singleAnim == true then fakeEh = 0 end
    if onPlayerCombo == true and camSet == 'hud' then
        if ratiNum ~= nil then
            makeAnimatedLuaSprite(anHmm ..'ly'.. fakeEh, fileNames[ratiNum], animRateOffsts[1] + comboOffset[1], animRateOffsts[2] - comboOffset[2])
            addAnimationByPrefix(anHmm..'ly'.. fakeEh, 'yeah', animNames[ratiNum], animFrameRate, false)
        end
    elseif camSet == 'game' then
        if ratiNum ~= nil then
            makeAnimatedLuaSprite(anHmm ..'ly'.. fakeEh, fileNames[ratiNum], animRatePosGame[1], animRatePosGame[2])
            addAnimationByPrefix(anHmm..'ly'.. fakeEh, 'yeah', animNames[ratiNum], animFrameRate, false)
        end
    else
        if ratiNum ~= nil then
            makeAnimatedLuaSprite(anHmm ..'ly'.. fakeEh, fileNames[ratiNum], animRatePos[1], animRatePos[2])
            addAnimationByPrefix(anHmm..'ly'.. fakeEh, 'yeah', animNames[ratiNum], animFrameRate, false)
        end
    end
    if colorAnim == true then
        setProperty(anHmm ..'ly'.. fakeEh .. '.color', getColorFromHex(thisOne))
    end
    setObjectCamera(anHmm ..'ly'.. fakeEh, camSet)
    setObjectOrder(anHmm ..'ly'.. fakeEh, getObjectOrder('strumLineNotes')-1)
    scaleObject(anHmm ..'ly'.. fakeEh, animRatScale[1], animRatScale[2])
    playAnim(anHmm..'ly'.. fakeEh, 'yeah', false)
    if ratPixl == true then
        setProperty(anHmm ..'ly'.. fakeEh ..'.antialiasing', false)
    end
    addLuaSprite(anHmm ..'ly'.. fakeEh, true)
    if veloctitty == true then
        setProperty(anHmm ..'ly'.. fakeEh ..'.acceleration.y', 550)
        setProperty(anHmm ..'ly'.. fakeEh ..'.velocity.x', math.random(0,10))
        setProperty(anHmm ..'ly'.. fakeEh ..'.velocity.y', -180)
    end
    if animFade == true then
        doTweenAlpha('nachotweenAnim' .. anHmm .. fakeEh, anHmm ..'ly' .. fakeEh, 0, initDelay + (stepCrochet * 0.004), 'quartIn')
    end
    if colorFade == true and colorAnim == true then
        doTweenColor('coolAnim', anHmm ..'ly'.. fakeEh, baseColor, 0.2 + (stepCrochet * 0.002), 'quartIn')
    end
end
---------------------------- Daddy Dearest <3 (Opponent) ---------------------------------

function opponentNoteHit(id, direction, noteType, isSustainNote) 
    hmmOp = rateGet(noteType)
    if visibleOp == true then
        comboOffset = getPropertyFromClass('ClientPrefs', 'comboOffset') -- rating offsets
        if not isSustainNote then

            if simpleModeOp == true then
                ehOp = 0 -- Keeps 'eh' at 0 so it can't spawn more than one at a time
            end

            if hideRatingOp == true then
                hmmOp = ''
            end

            ratingColoOp = ''
            ratiNumOp = 0

            if hmmOp == 'sick' then
                ratingColoOp = sickColorOp
                ratiNumOp = 1
            elseif hmmOp == 'good' then
                ratingColoOp = goodColorOp
                ratiNumOp = 2
            elseif hmmOp == 'bad' then
                ratingColoOp = badColorOp
                ratiNumOp = 3
            elseif hmmOp == 'shit' then
                ratingColoOp = baseColorOp
                ratiNumOp = 4
            else
                ratingColoOp = baseColorOp
                ratiNumOp = nil
            end

            grabbyOp = {colorSync0Op, colorSync1Op, colorSync2Op, colorSync3Op}
            thisOneOp = nil

            -- man! :)
            if colorRatingsOp == true and colorSyncingOp == false then
                thisOneOp = ratingColoOp
            elseif colorSyncingOp == true then
                thisOneOp = grabbyOp[direction+1]
            else
                thisOneOp = baseColorOp
            end

            -- yeah baby
            if colorNumbersOp == true and colorSyncNumsOp == false then
                numUseOp = ratingColoOp
            elseif colorSyncNumsOp == true then
                numUseOp = grabbyOp[direction+1]
            else
                numUseOp = baseColorOp
            end

            -------------------------------Ratings---------------------------------------
            
            if onPlayerComboOp == true and camSetOp == 'hud' then
                if ratiNumOp ~= nil then
                    makeLuaSprite(hmmOp ..'lyOp' .. ehOp, ratingGrabOp[ratiNumOp], 400 + comboOffset[1], 230 - comboOffset[2])
                end
            elseif camSetOp == 'game' then
                if ratiNumOp ~= nil then
                    makeLuaSprite(hmmOp ..'lyOp' .. ehOp, ratingGrabOp[ratiNumOp], defaultPosRateGameOp[1], defaultPosRateGameOp[2])
                end
            else
                if ratiNumOp ~= nil then
                    makeLuaSprite(hmmOp ..'lyOp' .. ehOp, ratingGrabOp[ratiNumOp], defaultPosRatingOp[1], defaultPosRatingOp[2])
                end
            end
            setProperty(hmmOp ..'lyOp'.. ehOp .. '.color', getColorFromHex(thisOneOp))
            setObjectCamera(hmmOp ..'lyOp' .. ehOp, camSetOp)
            setObjectOrder(hmmOp ..'lyOp' .. ehOp, getObjectOrder('strumLineNotes')-1)
            scaleObject(hmmOp ..'lyOp' .. ehOp, ratingScaleOp[1], ratingScaleOp[2])
            if pixelOp == true then
                setProperty(hmmOp ..'lyOp' .. ehOp .. '.antialiasing', false)
            end
            addLuaSprite(hmmOp ..'lyOp' .. ehOp, true)
            if stationaryModeOp == false then
                setProperty(hmmOp ..'lyOp' .. ehOp .. '.acceleration.y', 550)
                setProperty(hmmOp ..'lyOp'.. ehOp ..'.velocity.x', math.random(0,10))
                setProperty(hmmOp ..'lyOp'.. ehOp ..'.velocity.y', -180)
            end
            doTweenAlpha('nachotweenSickO' .. ehOp, hmmOp ..'lyOp' .. ehOp, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
            if colorFadeOp == true then
                doTweenColor('coolSOp' .. ehOp, hmmOp ..'lyOp' .. ehOp, baseColorOp, 0.2 + (stepCrochet * 0.002), 'quartIn')
            end
            if getProperty(hmmOp ..'lyOp'.. ehOp ..'.alpha') == 0 then
                removeLuaSprite(hmmOp ..'lyOp'.. ehOp, false)
            end 

            -------------------------------Special---------------------------------------

            -- example --
            if noteType == specialType then
                if onPlayerComboOp == true and camSetOp == 'hud' then
                    makeLuaSprite('speciallyOp' .. ehOp, ratingSpecialOp[1], 400 + comboOffset[1], 230 - comboOffset[2])
                elseif camSetOp == 'game' then
                    makeLuaSprite('speciallyOp' .. ehOp, ratingSpecialOp[1], defaultPosRateGameOp[1], defaultPosRateGameOp[2]) -- default position for game cam | change if you want
                else
                    makeLuaSprite('speciallyOp' .. ehOp, ratingSpecialOp[1], defaultPosRatingOp[1], defaultPosRatingOp[2])
                end
                setProperty('speciallyOp'.. ehOp .. '.color', getColorFromHex(baseColorOp)) -- change if ya want
                setObjectCamera('speciallyOp' .. ehOp, camSetOp)
                setObjectOrder('speciallyOp' .. ehOp, getObjectOrder('strumLineNotes')-1)
                scaleObject('speciallyOp' .. ehOp, ratingScaleOp[1], ratingScaleOp[2])
                --if pixel == true then -- if you actually have pixel versions, uncomment
                --    setProperty('speciallyOp' .. ehOp .. '.antialiasing', false)
                --end
                addLuaSprite('speciallyOp' .. ehOp, true)
                if stationaryModeOp == false then
                    setProperty('speciallyOp' .. ehOp .. '.acceleration.y', 550)
                    setProperty('speciallyOp'.. ehOp ..'.velocity.x', math.random(0,10))
                    setProperty('speciallyOp'.. ehOp ..'.velocity.y', -180)
                end
                doTweenAlpha('nachotweenSpecOp' .. ehOp, 'speciallyOp' .. ehOp, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
                if colorFadeOp == true then
                --    doTweenColor('coolSpecOp' .. ehOp, 'speciallyOp' .. ehOp, baseColorOp, 0.2 + (stepCrochet * 0.002), 'quartIn')
                end
                if getProperty('speciallyOp'.. ehOp ..'.alpha') == 0 then
                    removeLuaSprite('speciallyOp'.. ehOp, false)
                end 
            end

            ehOp = ehOp + 1 -- makes it look right

            if ehOp > 100 then
                ehOp = 0 
            end

            -------------------------------Counter---------------------------------------

            unoOp = unoOp + 1
            if unoOp > 9 and MAXEDOP ~= true then
                tensOp = true
                unoOp = 0
                dosOp = dosOp + 1
                if dosOp > 9 then
                    hundOp = true
                    dosOp = 0
                    thrOp = thrOp + 1
                    if thrOp > 9 then
                        thousOp = true
                        thrOp = 0
                        if fuoOp ~= 9 then
                            fuoOp = fuoOp + 1
                        elseif fuoOp > 9 then -- ?? and thrOp == 9 and dosOp == 9 and unoOp == 9 then
                            MAXEDOP = true
                        end
                    end
                end
            end
            if MAXEDOP == true then
                -- who tf puts over 10000 notes
                unoOp = 9
                dosOp = 9
                thrOp = 9
                fuoOp = 9
            end
           
            --------------------------------Numbers----------------------------------------

            if hideNumsOp == false then
                numbers = {'1','2','3','4','5','6','7','8','9'}
                numbers[0] = '0'
                    
                numCount = 0 -- 1
                if tensOp == true then numCount = 1 end -- 01
                if hundOp == true or foreverComboCountOp == false then numCount = 2 end -- 001
                if thousOp == true then numCount = 3 end -- 0001
                    
                for i = 0, numCount, 1 do
                    sequence = nil
                    if not foreverComboCountOp then multBy = (i * 43) else multBy = (((i + 2) - numCount) * 43) end
                    if i == 0 then
                        sequence = numPrefixOp .. numbers[unoOp] .. numSuffixOp
                    elseif i == 1 then
                        sequence = numPrefixOp .. numbers[dosOp] .. numSuffixOp
                    elseif i == 2 then
                        sequence = numPrefixOp .. numbers[thrOp] .. numSuffixOp
                    elseif i == 3 then
                        sequence = numPrefixOp .. numbers[fuoOp] .. numSuffixOp
                    end
                
                    if onPlayerComboOp == true and camSetOp == 'hud' then
                        makeLuaSprite('numOp' .. ehOp .. i, sequence, xAyyOp + comboOffset[3] - multBy, 390 - comboOffset[4])
                    elseif camSet == 'game' then
                        makeLuaSprite('numOp' .. ehOp .. i, sequence, defaultPosNumGameOp[1] - multBy, defaultPosNumGameOp[2])
                    else
                        makeLuaSprite('numOp' .. ehOp .. i, sequence, defaultPosNumOp[1] - multBy, defaultPosNumOp[2])
                    end
                    setObjectCamera('numOp' .. ehOp .. i, camSetOp)
                    setProperty('numOp'.. ehOp .. i .. '.color', getColorFromHex(numUseOp))
                    setObjectOrder('numOp' .. ehOp .. i, getObjectOrder('strumLineNotes')-1)
                    if pixelOp then
                        setProperty('numOp' .. ehOp .. i .. '.antialiasing', false)
                    end
                    scaleObject('numOp' .. ehOp .. i, numScaleOp[1], numScaleOp[2])
                    addLuaSprite('numOp' .. ehOp .. i, true)
                    if stationaryModeOp == false then
                        setProperty('numOp' .. ehOp .. i .. '.acceleration.y', math.random(200, 400))
                        setProperty('numOp'.. ehOp .. i ..'.velocity.x', math.random(-5, 5))
                        setProperty('numOp'.. ehOp .. i ..'.velocity.y', math.random(-140, -160))
                    end
                    doTweenAlpha('nachotweenNumOpGo' .. ehOp .. i, 'numOp' .. ehOp .. i, 0, 0.2 + (stepCrochet * 0.008), 'quartIn')
                    if colorFadeNumsOp == true then
                        doTweenColor('itsjustafadOp' .. ehOp .. i, 'numOp' .. ehOp .. i, baseColorOp, 0.2 + (stepCrochet * 0.005), 'quartIn')
                    end
                end
            end
        end
    end
end

function rateGet(noteType)
    -- Change to mess with the frequency | can be a lil' iffy at times --
    if noteType == specialType then
        return 'special' -- prevents rating so custom one can pop up, doesn't matter what it's called, just can't be sick, good, etc
    end
    if chanceGood >= 48 and randGoods == true then
        return 'good'
    elseif chanceBad >= 63 and randBads == true then
        return 'bad'
    elseif chanceShit >= 72 and randShits == true then
        return 'shit'
    else
        return 'sick'
    end
end

----- BbPanzu >:) ----------

function getRating(diff, noteType)
    if noteType == specialType then
        return ''  -- prevents rating so custom one can pop up, doesn't matter what it's called, just can't be sick, good, etc
    end

	diff = math.abs(diff)
	if diff <= getPropertyFromClass('ClientPrefs', 'badWindow') then
		if diff <= getPropertyFromClass('ClientPrefs', 'goodWindow') then
			if diff <= getPropertyFromClass('ClientPrefs', 'sickWindow') then
				return 'sick'
			end
			return 'good'
		end
		return 'bad'
	end
	return 'shit'
end