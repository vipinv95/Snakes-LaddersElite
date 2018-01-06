local widget = require ( "widget" )

local composer = require( "composer" )

local scene = composer.newScene()

local data = require("loadsave")

local WonCount = require("WonCount")

local LostCount = require("LostCount")

local Levels = require("Levels")

local FreezeOwned = require("FreezeOwned")
local TenOwned = require("TenOwned")
local ShieldOwned = require("ShieldOwned")
local x2Owned = require("x2Owned")

local Bought = require("Bought")

local ads = require("ads")

local leaving = false

if ( system.getInfo( "platformName" ) == "Android" ) then
    bannerAppID = "ca-app-pub-8488786023585485/5689904057"  --for your Android banner
    interstitialAppID = "ca-app-pub-8488786023585485/6423104056"  --for your Android interstitial
end
 
local adProvider = "admob"

local buttonTap = audio.loadSound( "button_tap.mp3" )
local diceSound = audio.loadSound( "dice_roll.mp3" )

local ActivateGoldenDie = false

OwnFreezeText = FreezeOwned.init({
		fontSize = 18,
		font = "COOPBL.TTF",
		filename = "FreezeOwned.txt"
	})
	OwnFreezeText.text = FreezeOwned.load()
	OwnFreezeText.x = display.contentWidth*0.27
	OwnFreezeText.y = display.contentHeight*0.442
	
	OwnTenText = TenOwned.init({
		fontSize = 18,
		font = "COOPBL.TTF",
		filename = "TenOwned.txt"
	})
	OwnTenText.text = TenOwned.load()
	OwnTenText.x = display.contentWidth*0.27
	OwnTenText.y = display.contentHeight*0.612
	
	OwnShieldText = ShieldOwned.init({
		fontSize = 18,
		font = "COOPBL.TTF",
		filename = "ShieldOwned.txt"
	})
	OwnShieldText.text = ShieldOwned.load()
	OwnShieldText.x = display.contentWidth*0.77
	OwnShieldText.y = display.contentHeight*0.442
	
	Own2xText = x2Owned.init({
		fontSize = 18,
		font = "COOPBL.TTF",
		filename = "x2Owned.txt"
	})
	Own2xText.text = x2Owned.load()
	Own2xText.x = display.contentWidth*0.77
	Own2xText.y = display.contentHeight*0.612

	display.remove(Own2xText)
	display.remove(OwnFreezeText)
	display.remove(OwnShieldText)
	display.remove(OwnTenText)
	
math.randomseed( os.time() )

local move
local dur_pawn = 300
local delay_pawn = 150
xpos = 0
ypos = 0
background = display.newImage("mainMenu_background.png",0,0)
local s = (display.contentWidth/1225)*0.13
local b = (display.contentWidth/1225)*3.4
local d = (display.contentWidth/1225)*2
local sprite = (display.contentWidth/1225)*0.22
local pawn_number
local dice = display.newImage("one_dice.png")
dice.isVisible = false


local red_pawn = nil
local orange_pawn = nil
local blue_pawn = nil
local purple_pawn = nil

local red_there = false
local orange_there = false
local blue_there = false
local purple_there = false 

local power1
local power2
local power3
local power4
local power5

	local function networkConnection()
    local socket = require("socket")
    local test = socket.tcp()
    test:settimeout(2)  -- Set timeout to 1 second
    local netConn = test:connect("www.google.com", 80)
    if netConn == nil then
        return false
    end
    test:close()
    return true
end

local goShield = display.newImage("Shield_inv1.png",display.contentWidth/2,display.contentHeight/2)
goShield:scale((display.contentWidth/1225)*0.65,(display.contentWidth/1225)*0.65)
goShield.isVisible = false

mySettings = data.loadTable("mySettings.json")

mySettings.style = "Elite"

mySettings.win = false
mySettings.quit = false

mySettings.eliteScore = 0

mySettings.starPowerup = false

mySettings.red_pawn_xpos = 0
mySettings.red_pawn_ypos = 9

mySettings.orange_pawn_xpos = 0
mySettings.orange_pawn_ypos = 9

mySettings.blue_pawn_xpos = 0
mySettings.blue_pawn_ypos = 9

mySettings.purple_pawn_xpos = 0
mySettings.purple_pawn_ypos = 9

mySettings.red_usedTen = false
mySettings.orange_usedTen = false
mySettings.blue_usedTen = false
mySettings.purple_usedTen = false

mySettings.red_there = false
mySettings.orange_there = false
mySettings.blue_there = false
mySettings.purple_there = false

mySettings.red_doubles = false
mySettings.orange_doubles = false
mySettings.blue_doubles = false
mySettings.purple_doubles = false

mySettings.red_freeze_num = 0
mySettings.red_six_num = 0
mySettings.red_shield_num = 0
mySettings.red_doubles_num = 0

mySettings.orange_freeze_num = 0
mySettings.orange_six_num = 0
mySettings.orange_shield_num = 0
mySettings.orange_doubles_num = 0

mySettings.blue_freeze_num = 0
mySettings.blue_six_num = 0
mySettings.blue_shield_num = 0
mySettings.blue_doubles_num = 0

mySettings.purple_freeze_num = 0
mySettings.purple_six_num = 0
mySettings.purple_shield_num = 0
mySettings.purple_doubles_num = 0

mySettings.allowPowerup = false

data.saveTable(mySettings,"mySettings.json")

	local BoughtText = Bought.init({
		fontSize = 24,
		font = "COOPBL.TTF",
		filename = "boughtfile.txt"
	})
	BoughtText.x = display.contentWidth*0.29
	BoughtText.y = display.contentHeight*0.275
	BoughtText:setFillColor(0.55,0.27,0.07)
	
	display.remove(BoughtText)

	menu_bar = display.newImage("menu_bar.png", display.contentWidth/2,((display.contentHeight-display.contentWidth)/2)*0.99)
	menu_bar:scale((display.contentWidth/1322),(display.contentWidth/1322)*1.5)
	menu_bar.anchorX = 0.5
	menu_bar.anchorY = 1
	gold_bar = display.newImage("gold_bar.png", display.contentWidth*0.06,((display.contentHeight-display.contentWidth)/2)*0.79)
	gold_bar:scale((display.contentWidth/1322)*0.7,(display.contentWidth/1322)*0.7)	
	
	local options = {
    width = 62,
    height = 62,
    numFrames = 6,
    sheetContentWidth = 372,
    sheetContentHeight = 62
}
local progressSheet = graphics.newImageSheet( "progress_bar.png", options )

-- Create the widget
local progressView = widget.newProgressView(
    {
        sheet = progressSheet,
        fillOuterLeftFrame = 1,
        fillOuterMiddleFrame = 2,
        fillOuterRightFrame = 3,
        fillOuterWidth = 62,
        fillOuterHeight = 62,
        fillInnerLeftFrame = 4,
        fillInnerMiddleFrame = 5,
        fillInnerRightFrame = 6,
        fillWidth = 62,
        fillHeight = 62,
        width = 300,
        isAnimated = true
    }
)
progressView.anchorX = 0

progressView.x = display.contentWidth*0.38
progressView.y = ((display.contentHeight-display.contentWidth)/2)*0.78
progressView:scale(0.3,0.3)
-- Set the progress to 50%

	
	level_star = display.newImage("level_star.png", display.contentWidth*0.4,((display.contentHeight-display.contentWidth)/2)*0.78)
	level_star:scale((display.contentWidth/1322)*1.05,(display.contentWidth/1322)*1.05)
	
	
	LevelText = Levels.init({
		fontSize = 18,
		font = "COOPBL.TTF",
		x = display.contentWidth*0.5,
		y = display.contentHeight*0.56,
		filename = "levelfile.txt"
	})
	
	LevelText.anchorX = 0.5
	LevelText.anchorY = 0.5
	
	LevelText.x = display.contentWidth*0.4
	LevelText.y = ((display.contentHeight-display.contentWidth)/2)*0.78
	
	progressView:setProgress( Levels.fraction() )
	
	
	GoldText = Levels.init({
		fontSize = 18,
		font = "COOPBL.TTF",
		filename = "goldfile.txt"
	})

	GoldText.anchorX = 0
	GoldText.anchorY = 0.5
	
	GoldText.x = display.contentWidth*0.12
	GoldText.y = ((display.contentHeight-display.contentWidth)/2)*0.78
	if tonumber(GoldText.text) > 999999 then
		GoldText.size = 16
	end
	
	WonText = WonCount.init({
		fontSize = 18,
		font = "COOPBL.TTF",
		filename = "WonCount.txt"
	})
		WonText.isVisible = false
	LostText = LostCount.init({
		fontSize = 18,
		font = "COOPBL.TTF",
		filename = "LostCount.txt"
	})
		LostText.isVisible = false
		
	local ratio = display.newText("Won : Lost",display.contentWidth*0.84,((display.contentHeight-display.contentWidth)/2)*0.71,"COOPBL.TTF",16)
	ratio:setFillColor(0.55,0.27,0.07)
	local ratio1 = display.newText(tostring(WonCount.load()).." : "..tostring(LostCount.load()),display.contentWidth*0.84,((display.contentHeight-display.contentWidth)/2)*0.85,"COOPBL.TTF",16)
	ratio1:setFillColor(0.55,0.27,0.07)

local function power( event )
	local options = {
		isModal = true
	}
	if event.phase == "began" then
		infoButton:scale(0.8,0.8)
		timer.performWithDelay(100,function()infoButton:scale(1.25,1.25);end)
	end
	if event.phase == "ended" then
		if mySettings.soundOn then
			audio.play( buttonTap )
		end
	data.saveTable(mySettings,"mySettings.json")
	composer.showOverlay("overlayInfo",options)
	end
	
	return true
end

local function usepower( event )
	local options = {
		isModal = true
	}
	if event.phase == "began" then
		powerupButton:scale(0.8,0.8)
		timer.performWithDelay(100,function()powerupButton:scale(1.25,1.25);end)
	end
	if event.phase == "ended" then
		if mySettings.soundOn then
			audio.play( buttonTap )
		end
	data.saveTable(mySettings,"mySettings.json")
	composer.showOverlay("overlayUsePowerup",options)
	end
	
	return true
end

local function goHome( event )
	local options = {
		isModal = true
	}
	if event.phase == "began" then
		homeButton:scale(0.8,0.8)
		timer.performWithDelay(100,function()homeButton:scale(1.25,1.25);end)
	end
	if event.phase == "ended" then
		if mySettings.soundOn then
			audio.play( buttonTap )
		end
	data.saveTable(mySettings,"mySettings.json")
	composer.showOverlay("overlayQuit",options)
	
	end
end
local function restart( event )
	local options = {
		isModal = true
	}
	if event.phase == "began" then
		retry:scale(0.8,0.8)
		timer.performWithDelay(100,function()retry:scale(1.25,1.25);end)
	end
	if event.phase == "ended" then
		if mySettings.soundOn then
			audio.play( buttonTap )
		end
	data.saveTable(mySettings,"mySettings.json")
	composer.showOverlay("overlaySettings",options)
	end
	
	return true
	
end

	optionsBoard = display.newImage("optionsBoard.png", display.contentWidth/2,display.contentHeight*0.97)
	optionsBoard:scale((display.contentWidth/1829),(display.contentWidth/1829))

homeButton = widget.newButton{
	defaultFile = "homeButton.png",
	onEvent = goHome
}
	homeButton.x = display.contentWidth*0.125
	homeButton.y = display.contentHeight*0.915
	homeButton:scale((display.contentWidth/619)*0.23,(display.contentWidth/619)*0.23)
	
powerupButton = widget.newButton{
	defaultFile = "powerupButton.png",
	onEvent = usepower
}
powerupButton.x = display.contentWidth*0.375
powerupButton.y = display.contentHeight*0.915
powerupButton:scale((display.contentWidth/619)*0.23,(display.contentWidth/619)*0.23)

infoButton = widget.newButton{
	defaultFile = "powerupInfo.png",
	onEvent = power
}
infoButton.x = display.contentWidth*0.625
infoButton.y = display.contentHeight*0.915
infoButton:scale((display.contentWidth/619)*0.23,(display.contentWidth/619)*0.23)
retry = widget.newButton{
	defaultFile = "restartButton.png",
	onEvent = restart
}
retry.x = display.contentWidth*0.875
retry.y = display.contentHeight*0.915
retry:scale((display.contentWidth/619)*0.23,(display.contentWidth/619)*0.23)



local sheetOptions =
{
    width = 1056,
    height = 320,
	sheetContentWidth = 4224,
	sheetContentHeight= 320,
    numFrames = 4
}
local sheet_dice_button = graphics.newImageSheet( "dice_ani.png", sheetOptions )
local sequences_dice_button = {
    -- consecutive frames sequence
    {
        name = "Flying",
        start = 1,
        count = 4,
        time = 200,
        loopCount = 0,
        loopDirection = "bounce"
    }
}
local dice_button = display.newSprite( sheet_dice_button, sequences_dice_button )

dice_button:play()
dice_button.x = (-1)*display.contentWidth/2
dice_button.y = display.contentWidth/5
dice_button:scale(0.07,0.07)

function goAway()
	dice_button:pause()
	dice_button:setFrame(1)
	if math.random( 80 ) == 67 and networkConnection() then
	composer.showOverlay("overlayReward",{isModal=true})
	transition.to(dice_button,{time = 1800,onComplete=function()transition.to(dice_button,{time=20, iterations = 150, onComplete = function()incrementGold();end});end})	
	
	end
end



-- *** 2D Ladder Array ***

-- 2D array to check whether there is snake or ladder

snake_ladder = {}
for f=1, 10 do
    snake_ladder[f] = {}
    for g=1, 10 do
        snake_ladder[f][g] = 0
    end
end

snake_ladder[9][8] = 1
snake_ladder[3][7] = 1
snake_ladder[1][5] = 1
snake_ladder[9][3] = 1
snake_ladder[3][1] = 1
snake_ladder[9][1] = 1

snake_ladder[8][10] = 2
snake_ladder[6][8] = 2
snake_ladder[7][7] = 2
snake_ladder[1][7] = 2
snake_ladder[2][4] = 2
snake_ladder[8][4] = 2
snake_ladder[3][3] = 2

snake_ladder[10][10] = 3
snake_ladder[1][9] = 3
snake_ladder[10][8] = 3

snake_ladder[10][6] = 3

snake_ladder[10][4] = 3
snake_ladder[1][3] = 3
snake_ladder[10][2] = 3


snake_ladder[1][1] = 4


snake_ladder[2][9] = 5
snake_ladder[7][8] = 5
snake_ladder[4][7] = 5
snake_ladder[7][6] = 5
snake_ladder[6][5] = 5
snake_ladder[3][4] = 5
snake_ladder[5][3] = 5

-- 2D array for snake's ending x position 

snake_ladder_x = {}
for d=1, 10 do
    snake_ladder_x[d] = {}
    for e=1, 10 do
        snake_ladder_x[d][e] = 0
    end
end

snake_ladder_x[9][8] = 5
snake_ladder_x[3][7] = 4
snake_ladder_x[1][5] = 1
snake_ladder_x[9][3] = 7
snake_ladder_x[3][1] = 4
snake_ladder_x[9][1] = 9

snake_ladder_x[8][10] = 7
snake_ladder_x[6][8] = 4
snake_ladder_x[7][7] = 7
snake_ladder_x[1][7] = 3
snake_ladder_x[2][4] = 0
snake_ladder_x[8][4] = 6
snake_ladder_x[3][3] = 2

snake_ladder_x[10][10] = 10
snake_ladder_x[1][9] = 1
snake_ladder_x[10][8] = 10

snake_ladder_x[10][6] = 10

snake_ladder_x[10][4] = 10
snake_ladder_x[1][3] = 1
snake_ladder_x[10][2] = 10

-- 2D array for snake's ending y position 

snake_ladder_y = {}
for a=1, 10 do
    snake_ladder_y[a] = {}
    for b=1, 10 do
        snake_ladder_y[a][b] = 0
    end
end

snake_ladder_y[9][8] = 8
snake_ladder_y[3][7] = 9
snake_ladder_y[1][5] = 7
snake_ladder_y[9][3] = 6
snake_ladder_y[3][1] = 6
snake_ladder_y[9][1] = 4

snake_ladder_y[8][10] = 8
snake_ladder_y[6][8] = 5
snake_ladder_y[7][7] = 5
snake_ladder_y[1][7] = 4
snake_ladder_y[2][4] = 1
snake_ladder_y[8][4] = 1
snake_ladder_y[3][3] = 1

snake_ladder_y[10][10] = 9
snake_ladder_y[1][9] = 8
snake_ladder_y[10][8] = 7

snake_ladder_y[10][6] = 5

snake_ladder_y[10][4] = 3
snake_ladder_y[1][3] = 2
snake_ladder_y[10][2] = 1


	turn = {}
	
	if mySettings.players == 2 then
		players = 2
	elseif mySettings.players == 3 then
		players = 3
	elseif mySettings.players == 4 then
		players = 4
	end
		if mySettings.pawnColor == "Red" then 
				turn[1] = 1
				pawn_number = 1
				mySettings.pawnNumber = 1
				data.saveTable(mySettings,"mySettings.json")
			if players == 2 then 
				turn[2] = 2
			elseif players == 3 then
				turn[2] = 2
				turn[3] = 3
			elseif players == 4 then
				turn[2] = 2
				turn[3] = 3
				turn[4] = 4
			end
		elseif mySettings.pawnColor == "Orange" then 
				turn[1] = 2
				pawn_number = 2
				mySettings.pawnNumber = 2
				data.saveTable(mySettings,"mySettings.json")
			if players == 2 then 
				turn[2] = 1
			elseif players == 3 then
				turn[2] = 1
				turn[3] = 3
			elseif players == 4 then
				turn[2] = 1
				turn[3] = 3
				turn[4] = 4
			end
		elseif mySettings.pawnColor == "Blue" then 
				turn[1] = 3
				pawn_number = 3
				mySettings.pawnNumber = 3
				data.saveTable(mySettings,"mySettings.json")
			if players == 2 then 
				turn[2] = 1
			elseif players == 3 then
				turn[2] = 1
				turn[3] = 2
			elseif players == 4 then
				turn[2] = 1
				turn[3] = 2
				turn[4] = 4
			end
		elseif mySettings.pawnColor == "Purple" then 
				turn[1] = 4
				pawn_number = 4
				mySettings.pawnNumber = 4
				data.saveTable(mySettings,"mySettings.json")
			if players == 2 then 
				turn[2] = 1
			elseif players == 3 then
				turn[2] = 1
				turn[3] = 2
			elseif players == 4 then
				turn[2] = 1
				turn[3] = 2
				turn[4] = 3
			end
		end	
	
	function shuffle(array)
    local n, random, j = table.getn(array), math.random
    for i=1, n do
        j,k = random(n), random(n)
        array[j],array[k] = array[k],array[j]
    end
		return array
	end

		shuffle( turn )
		pturn = turn[1]
		
		mySettings.turn = turn
		data.saveTable(mySettings,"mySettings.json")
		
	if mySettings.boardColor == "Green" then
		board = display.newImage("green_board_elite.png",0,0)
		board.isVisible = true
		board.width = display.contentWidth
		board.height = display.contentWidth
		board.x = display.contentWidth/2
		board.y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth/2
	elseif mySettings.boardColor == "Red" then
		board = display.newImage("red_board_elite.png",0,0)
		board.isVisible = true
		board.width = display.contentWidth
		board.height = display.contentWidth
		board.x = display.contentWidth/2
		board.y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth/2
	end
	
if mySettings.pawnNumber == 1 then
mySettings.red_freeze_num = mySettings.FreezeBought
mySettings.red_six_num = mySettings.TenBought
mySettings.red_shield_num = mySettings.ShieldBought
mySettings.red_doubles_num = mySettings.x2Bought
data.saveTable(mySettings,"mySettings.json")
elseif mySettings.pawnNumber == 2 then
mySettings.orange_freeze_num = mySettings.FreezeBought
mySettings.orange_six_num = mySettings.TenBought
mySettings.orange_shield_num = mySettings.ShieldBought
mySettings.orange_doubles_num = mySettings.x2Bought
data.saveTable(mySettings,"mySettings.json")
elseif mySettings.pawnNumber == 3 then
mySettings.blue_freeze_num = mySettings.FreezeBought
mySettings.blue_six_num = mySettings.TenBought
mySettings.blue_shield_num = mySettings.ShieldBought
mySettings.blue_doubles_num = mySettings.x2Bought
data.saveTable(mySettings,"mySettings.json")
elseif mySettings.pawnNumber == 4 then
mySettings.purple_freeze_num = mySettings.FreezeBought
mySettings.purple_six_num = mySettings.TenBought
mySettings.purple_shield_num = mySettings.ShieldBought
mySettings.purple_doubles_num = mySettings.x2Bought
data.saveTable(mySettings,"mySettings.json")
end

	
	for j=1, players do
	
	if turn[j] == 1 then
	
	-- ***RED PAWN***

red_pawn = display.newImage("red_pawn.png",0,0)
mySettings.red_pawn_xpos = 0
mySettings.red_pawn_ypos = 9
red_pawn.x = display.contentWidth*(0.05+(0.0945*mySettings.red_pawn_xpos))
red_pawn.y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*mySettings.red_pawn_ypos))
red_pawn:scale(s,s)

red_there = true
mySettings.red_there = true
mySettings.red_frozen = false
data.saveTable(mySettings,"mySettings.json")

	elseif turn[j] == 2 then

-- ***ORANGE PAWN***

orange_pawn = display.newImage("orange_pawn.png",0,0)
mySettings.orange_pawn_xpos = 0
mySettings.orange_pawn_ypos = 9
orange_pawn.x = display.contentWidth*(0.098+(0.0945*mySettings.orange_pawn_xpos))
orange_pawn.y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*mySettings.orange_pawn_ypos))
orange_pawn:scale(s,s)

orange_there = true
mySettings.orange_there = true
mySettings.orange_frozen = false
data.saveTable(mySettings,"mySettings.json")

	elseif turn[j] == 3 then

-- ***BLUE PAWN***

blue_pawn = display.newImage("blue_pawn.png",0,0)
mySettings.blue_pawn_xpos = 0
mySettings.blue_pawn_ypos = 9
blue_pawn.x = display.contentWidth*(0.05+(0.0945*mySettings.blue_pawn_xpos))
blue_pawn.y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*mySettings.blue_pawn_ypos))
blue_pawn:scale(s,s)

blue_there = true
mySettings.blue_there = true
mySettings.blue_frozen = false
data.saveTable(mySettings,"mySettings.json")

	elseif turn[j] == 4 then

-- ***PURPLE PAWN***

purple_pawn = display.newImage("purple_pawn.png",0,0)
mySettings.purple_pawn_xpos = 0
mySettings.purple_pawn_ypos = 9
purple_pawn.x = display.contentWidth*(0.098+(0.0945*mySettings.purple_pawn_xpos))
purple_pawn.y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*mySettings.purple_pawn_ypos))
purple_pawn:scale(s,s)

purple_there = true
mySettings.purple_there = true
mySettings.purple_frozen = false
data.saveTable(mySettings,"mySettings.json")
	end
end


	
	local function myTapListener( event )
	
		if event.phase == "ended" then
			dice_button:removeEventListener("touch",myTapListener)
			player_turn()
			
			dice_button:play()
			transition.to(dice_button, {time = 1300, x = display.contentWidth*1.5, y = display.contentWidth/5, xScale = 0.07, yScale = 0.07, onComplete  = function()dice_button.isVisible=false;dice_button.x = (-1)*display.contentWidth/2;dice_button.y = display.contentWidth/5;end})
		end
		return true
	end
	

local function adListener( event )
    --(more on this later)
end
function Initializer()
if networkConnection() and not mySettings.adInitialized then
local appID = "ca-app-pub-8488786023585485/5689904057"
if not mySettings.removeAds then
ads.init( "admob", appID, adListener )
ads.show( "banner", { x=(display.contentWidth/2)-160, y=0, appId="ca-app-pub-8488786023585485/5689904057" } )
end
mySettings.adInitialized = true
data.saveTable(mySettings,"mySettings.json")
else
if networkConnection() then
if not mySettings.removeAds then
ads.show( "banner", { x=(display.contentWidth/2)-160, y=0, appId="ca-app-pub-8488786023585485/5689904057" } )
end
end
data.saveTable(mySettings,"mySettings.json")
end
end

timer.performWithDelay(4000,function()Initializer();end)


-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

-- -------------------------------------------------------------------------------


	-- ***DICE ROLL***
	
	
function player_turn()
	if turn[1] == pturn then
		if pturn == 1 then
			if mySettings.red_frozen then
				mySettings.red_frozen = false
				pturn = turn[2]
				automatic()
			else
			pturn = turn[2]
			dice_roll( red_pawn )
			end
		elseif pturn == 2 then
			if mySettings.orange_frozen then
				mySettings.orange_frozen = false
				pturn = turn[2]
				automatic()
			else
			pturn = turn[2]
			dice_roll( orange_pawn )
			end
		elseif pturn == 3 then
			if mySettings.blue_frozen then
				mySettings.blue_frozen = false
				pturn = turn[2]
				automatic()
			else
			pturn = turn[2]
			dice_roll( blue_pawn )
			end
		elseif pturn == 4 then
			if mySettings.purple_frozen then
				mySettings.purple_frozen = false
				pturn = turn[2]
				automatic()
			else
			pturn = turn[2]
			dice_roll( purple_pawn )
			end
		end
		
	elseif turn[2] == pturn then
		if pturn == 1 then
			if mySettings.red_frozen then
				mySettings.red_frozen = false
				if players >= 3 then
					pturn = turn[3]
				elseif players == 2 then
					pturn = turn[1]
				end
				automatic()
			else
				if players >= 3 then
					pturn = turn[3]
				elseif players == 2 then
					pturn = turn[1]
				end
			dice_roll( red_pawn )
			end
		elseif pturn == 2 then
			if mySettings.orange_frozen then
				mySettings.orange_frozen = false
				if players >= 3 then
					pturn = turn[3]
				elseif players == 2 then
					pturn = turn[1]
				end
				automatic()
			else
				if players >= 3 then
					pturn = turn[3]
				elseif players == 2 then
					pturn = turn[1]
				end
			dice_roll( orange_pawn )
			end
		elseif pturn == 3 then
			if mySettings.blue_frozen then
				mySettings.blue_frozen = false
				if players >= 3 then
					pturn = turn[3]
				elseif players == 2 then
					pturn = turn[1]
				end
				automatic()
			else
				if players >= 3 then
					pturn = turn[3]
				elseif players == 2 then
					pturn = turn[1]
				end
			dice_roll( blue_pawn )
			end
		elseif pturn == 4 then
			if mySettings.purple_frozen then
				mySettings.purple_frozen = false
				if players >= 3 then
					pturn = turn[3]
				elseif players == 2 then
					pturn = turn[1]
				end
				automatic()
			else
				if players >= 3 then
					pturn = turn[3]
				elseif players == 2 then
					pturn = turn[1]
				end
			dice_roll( purple_pawn )
			end
		end
			
	elseif turn[3] == pturn then
		if pturn == 1 then
			if mySettings.red_frozen then
				mySettings.red_frozen = false
				if players == 4 then 
					pturn = turn[4]
				elseif players == 3 then
					pturn = turn[1]
				end
				automatic()
			else	
				if players == 4 then 
					pturn = turn[4]
				elseif players == 3 then
					pturn = turn[1]
				end
			dice_roll( red_pawn )
			end
		elseif pturn == 2 then
			if mySettings.orange_frozen then
				mySettings.orange_frozen = false
				if players == 4 then 
					pturn = turn[4]
				elseif players == 3 then
					pturn = turn[1]
				end
				automatic()
			else
				if players == 4 then 
					pturn = turn[4]
				elseif players == 3 then
					pturn = turn[1]
				end
			dice_roll( orange_pawn )
			end
		elseif pturn == 3 then
			if mySettings.blue_frozen then
				mySettings.blue_frozen = false
				if players == 4 then 
					pturn = turn[4]
				elseif players == 3 then
					pturn = turn[1]
				end
				automatic()
			else
				if players == 4 then 
					pturn = turn[4]
				elseif players == 3 then
					pturn = turn[1]
				end
			dice_roll( blue_pawn )
			end
		elseif pturn == 4 then
			if mySettings.purple_frozen then
				mySettings.purple_frozen = false
				if players == 4 then 
					pturn = turn[4]
				elseif players == 3 then
					pturn = turn[1]
				end
				automatic()
			else
				if players == 4 then 
					pturn = turn[4]
				elseif players == 3 then
					pturn = turn[1]
				end
			dice_roll( purple_pawn )
			end
		end
			
	elseif turn[4] == pturn then
		if pturn == 1 then
			if mySettings.red_frozen then
				mySettings.red_frozen = false
				pturn = turn[1]
				automatic()
			else
				pturn = turn[1]
				dice_roll( red_pawn )
			end
		elseif pturn == 2 then
			if mySettings.orange_frozen then
				mySettings.orange_frozen = false
				pturn = turn[1]
				automatic()
			else
				pturn = turn[1]
				dice_roll( orange_pawn )
			end
		elseif pturn == 3 then
			if mySettings.blue_frozen then
				mySettings.blue_frozen = false
				pturn = turn[1]
				automatic()
			else
				pturn = turn[1]
				dice_roll( blue_pawn )
			end
		elseif pturn == 4 then
			if mySettings.purple_frozen then
				mySettings.purple_frozen = false
				pturn = turn[1]
				automatic()
			else
				pturn = turn[1]
				dice_roll( purple_pawn )
			end
		end
				
	end
end
		
		function dice_roll( pawn_color ) 
		if mySettings.soundOn then
			audio.play( diceSound )
		end
	flag = 1
	local rand = math.random( 6 )
	if pawn_color == red_pawn and mySettings.red_doubles then
		flag = 2
		mySettings.red_doubles = false
		move = (rand*2) + 1
	elseif pawn_color == orange_pawn and mySettings.orange_doubles then
		flag = 2
		mySettings.orange_doubles = false
		move = (rand*2) + 1
	elseif pawn_color == blue_pawn and mySettings.blue_doubles then
		flag = 2
		mySettings.blue_doubles = false
		move = (rand*2) + 1
	elseif pawn_color == purple_pawn and mySettings.purple_doubles then
		flag = 2
		mySettings.purple_doubles = false
		move = (rand*2) + 1
	else
		move = rand + 1
	end

	local dur = 750
	if rand == 1 then
		if tonumber(Bought.load()) == 1 and ActivateGoldenDie then
		dice = display.newImage( "one_dice_gold.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		else
		dice = display.newImage( "one_dice.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		end
		dice:scale(d,d)
		dice.isVisible = true
		local trans1 = transition.to(dice, {time = dur, x = display.contentWidth*(0.05+(0.0945*math.random( 3, 8 )))})
		local trans2 = transition.to(dice, {time = dur, y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*math.random( 3, 8 )))})
		local trans3 = transition.to(dice, {time = dur, delay=2000*flag, alpha=0, onComplete = automatic })
		
			if pawn_color == red_pawn then
				transition_help(red_pawn)
			elseif pawn_color == orange_pawn then				
				transition_help(orange_pawn)
			elseif pawn_color == blue_pawn then				
				transition_help(blue_pawn)
			elseif pawn_color == purple_pawn then				
				transition_help(purple_pawn)
			end			
		ActivateGoldenDie = false
	elseif rand == 2 then
		if tonumber(Bought.load()) == 1 and ActivateGoldenDie then
		dice = display.newImage( "two_dice_gold.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )		
		else
		dice = display.newImage( "two_dice.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		end
		dice:scale(d,d)
		dice.isVisible = true
		local trans1 = transition.to(dice, {time = dur, x = display.contentWidth*(0.05+(0.0945*math.random( 3, 8 )))})
		local trans2 = transition.to(dice, {time = dur, y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*math.random( 3, 8 )))})
		local trans3 = transition.to(dice, {time = dur, delay=2500*flag, alpha=0, onComplete = automatic })
		
			if pawn_color == red_pawn then
				transition_help(red_pawn)
			elseif pawn_color == orange_pawn then
				transition_help(orange_pawn)
			elseif pawn_color == blue_pawn then
				transition_help(blue_pawn)
			elseif pawn_color == purple_pawn then
				transition_help(purple_pawn)
			end
		ActivateGoldenDie = false
	elseif rand == 3 then
		if tonumber(Bought.load()) == 1 and ActivateGoldenDie then
		dice = display.newImage( "three_dice_gold.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		else
		dice = display.newImage( "three_dice.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		end
		dice:scale(d,d)
		dice.isVisible = true
		local trans1 = transition.to(dice, {time = dur, x = display.contentWidth*(0.05+(0.0945*math.random( 3, 8 )))})
		local trans2 = transition.to(dice, {time = dur, y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*math.random( 3, 8 )))})
		local trans3 = transition.to(dice, {time = dur, delay=3100*flag, alpha=0, onComplete = automatic })
		
			if pawn_color == red_pawn then
				transition_help(red_pawn)
			elseif pawn_color == orange_pawn then
				transition_help(orange_pawn)
			elseif pawn_color == blue_pawn then
				transition_help(blue_pawn)
			elseif pawn_color == purple_pawn then
				transition_help(purple_pawn)
			end
		ActivateGoldenDie = false
	elseif rand == 4 then
		if tonumber(Bought.load()) == 1 and ActivateGoldenDie then
		dice = display.newImage( "four_dice_gold.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		else
		dice = display.newImage( "four_dice.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		end
		dice:scale(d,d)
		dice.isVisible = true
		local trans1 = transition.to(dice, {time = dur, x = display.contentWidth*(0.05+(0.0945*math.random( 3, 8 )))})
		local trans2 = transition.to(dice, {time = dur, y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*math.random( 3, 8 )))})
		local trans3 = transition.to(dice, {time = dur, delay=3300*flag, alpha=0, onComplete = automatic })
		
			if pawn_color == red_pawn then
				transition_help(red_pawn)
			elseif pawn_color == orange_pawn then
				transition_help(orange_pawn)
			elseif pawn_color == blue_pawn then
				transition_help(blue_pawn)
			elseif pawn_color == purple_pawn then
				transition_help(purple_pawn)
			end
		ActivateGoldenDie = false
	elseif rand == 5 then
		if tonumber(Bought.load()) == 1 and ActivateGoldenDie then
		dice = display.newImage( "five_dice_gold.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		else
		dice = display.newImage( "five_dice.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		end
		dice:scale(d,d)
		dice.isVisible = true
		local trans1 = transition.to(dice, {time = dur, x = display.contentWidth*(0.05+(0.0945*math.random( 3, 8 )))})
		local trans2 = transition.to(dice, {time = dur, y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*math.random( 3, 8 )))})
		local trans3 = transition.to(dice, {time = dur, delay=3800*flag, alpha=0, onComplete = automatic })
		
			if pawn_color == red_pawn then
				transition_help(red_pawn)
			elseif pawn_color == orange_pawn then
				transition_help(orange_pawn)
			elseif pawn_color == blue_pawn then
				transition_help(blue_pawn)
			elseif pawn_color == purple_pawn then	
				transition_help(purple_pawn)
			end
		ActivateGoldenDie = false
	elseif rand == 6 then
		if tonumber(Bought.load()) == 1 and ActivateGoldenDie then
		dice = display.newImage( "six_dice_gold.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		else
		dice = display.newImage( "six_dice.png",display.contentWidth*1.1*(math.random( 2 ) - 1),((display.contentHeight-display.contentWidth)/2)+math.random( display.contentWidth -50) )
		end
		dice:scale(d,d)
		dice.isVisible = true
		local trans1 = transition.to(dice, {time = dur, x = display.contentWidth*(0.05+(0.0945*math.random( 3, 8 )))})
		local trans2 = transition.to(dice, {time = dur, y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*math.random( 3, 8 )))})
		local trans3 = transition.to(dice, {time = dur, delay=4300*flag, alpha=0, onComplete = automatic })
				
			if pawn_color == red_pawn then
				transition_help(red_pawn)
			elseif pawn_color == orange_pawn then
				transition_help(orange_pawn)
			elseif pawn_color == blue_pawn then
				transition_help(blue_pawn)
			elseif pawn_color == purple_pawn then
				transition_help(purple_pawn)
			end
		ActivateGoldenDie = false
	end	
	return true
end
function check_highest()
local red_score = 0
local orange_score = 0
local blue_score = 0
local purple_score = 0
	if pturn == 1 then
		
		if mySettings.orange_there then
		
			if (mySettings.orange_pawn_ypos % 2) ~= 0 then
				orange_score = orange_score + (((mySettings.orange_pawn_xpos + 1)+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			else
				orange_score = orange_score + ((((10 - mySettings.orange_pawn_xpos))+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.blue_there then
		
			if (mySettings.blue_pawn_ypos % 2) ~= 0 then
				blue_score = blue_score + (((mySettings.blue_pawn_xpos + 1)+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			else
				blue_score = blue_score + ((((10 - mySettings.blue_pawn_xpos))+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.purple_there then
		
			if (mySettings.purple_pawn_ypos % 2) ~= 0 then
				purple_score = purple_score + (((mySettings.purple_pawn_xpos + 1)+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			else
				purple_score = purple_score + ((((10 - mySettings.purple_pawn_xpos))+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			end
		end
		
		if (orange_score >= blue_score) and (orange_score >= purple_score) then
		mySettings.top_pos = 2
		elseif (blue_score >= orange_score) and (blue_score >= purple_score) then
		mySettings.top_pos = 3
		else
		mySettings.top_pos = 4
		end
		data.saveTable(mySettings, "mySettings.json")
	
	elseif pturn == 2 then
		
		if mySettings.red_there then
		
			if (mySettings.red_pawn_ypos % 2) ~= 0 then
				red_score = red_score + (((mySettings.red_pawn_xpos + 1)+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			else
				red_score = red_score + ((((10 - mySettings.red_pawn_xpos))+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.blue_there then
		
			if (mySettings.blue_pawn_ypos % 2) ~= 0 then
				blue_score = blue_score + (((mySettings.blue_pawn_xpos + 1)+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			else
				blue_score = blue_score + ((((10 - mySettings.blue_pawn_xpos))+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.purple_there then
		
			if (mySettings.purple_pawn_ypos % 2) ~= 0 then
				purple_score = purple_score + (((mySettings.purple_pawn_xpos + 1)+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			else
				purple_score = purple_score + ((((10 - mySettings.purple_pawn_xpos))+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			end
		end
		
		if (red_score >= blue_score) and (red_score >= purple_score) then
		mySettings.top_pos = 1
		elseif (blue_score >= red_score) and (blue_score >= purple_score) then
		mySettings.top_pos = 3
		else
		mySettings.top_pos = 4
		end
		data.saveTable(mySettings, "mySettings.json")
		
	elseif pturn == 3 then
		
		if mySettings.orange_there then
		
			if (mySettings.orange_pawn_ypos % 2) ~= 0 then
				orange_score = orange_score + (((mySettings.orange_pawn_xpos + 1)+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			else
				orange_score = orange_score + ((((10 - mySettings.orange_pawn_xpos))+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.red_there then
		
			if (mySettings.red_pawn_ypos % 2) ~= 0 then
				red_score = red_score + (((mySettings.red_pawn_xpos + 1)+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			else
				red_score = red_score + ((((10 - mySettings.red_pawn_xpos))+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.purple_there then
		
			if (mySettings.purple_pawn_ypos % 2) ~= 0 then
				purple_score = purple_score + (((mySettings.purple_pawn_xpos + 1)+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			else
				purple_score = purple_score + ((((10 - mySettings.purple_pawn_xpos))+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			end
		end
		
		if (red_score >= orange_score) and (red_score >= purple_score) then
		mySettings.top_pos = 1
		elseif (orange_score >= red_score) and (orange_score >= purple_score) then
		mySettings.top_pos = 2
		else
		mySettings.top_pos = 4
		end
		data.saveTable(mySettings, "mySettings.json")
		
	elseif pturn == 4 then
		
		if mySettings.orange_there then
		
			if (mySettings.orange_pawn_ypos % 2) ~= 0 then
				orange_score = orange_score + (((mySettings.orange_pawn_xpos + 1)+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			else
				orange_score = orange_score + ((((10 - mySettings.orange_pawn_xpos))+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.blue_there then
		
			if (mySettings.blue_pawn_ypos % 2) ~= 0 then
				blue_score = blue_score + (((mySettings.blue_pawn_xpos + 1)+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			else
				blue_score = blue_score + ((((10 - mySettings.blue_pawn_xpos))+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.red_there then
		
			if (mySettings.red_pawn_ypos % 2) ~= 0 then
				red_score = red_score + (((mySettings.red_pawn_xpos + 1)+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			else
				red_score = red_score + ((((10 - mySettings.red_pawn_xpos))+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			end
		end
		
		if (red_score >= orange_score) and (red_score >= blue_score) then
		mySettings.top_pos = 1
		elseif (orange_score >= red_score) and (orange_score >= blue_score) then
		mySettings.top_pos = 2
		else
		mySettings.top_pos = 3
		end
		data.saveTable(mySettings, "mySettings.json")
		
	end
end
counter = 1
function incrementGold()
counter = counter + 1
if GoldText~=nil then
GoldText.text = tostring(tonumber(GoldText.text) + 2)
end
if counter <= 150 then
transition.to(dice_button,{time = 20, onComplete=function()incrementGold();end})
else
counter = 1
end
end
function automatic()	
	if not mySettings.adInitialized then
	timer.performWithDelay(4000,function()Initializer();end)
	end
	data.saveTable(mySettings,"mySettings.json")
	if mySettings.starPowerup then
		mySettings.starPowerup = false
		timer.performWithDelay(3600,automatic)
		else
	if pturn ~= pawn_number then
		if mySettings.win or mySettings.quit then
		return true
		else
		
		local rand1 = math.random( 3 )
		if pturn == 1 then
		if ((rand1 == 1 and mySettings.red_pawn_ypos < 4) or mySettings.orange_pawn_ypos < 1 or mySettings.blue_pawn_ypos < 1 or mySettings.purple_pawn_ypos < 1) and not mySettings.red_frozen then
			--if rand1 ~= 1 then
				check_highest()
				if mySettings.top_pos == 2 then
					computerPowerup(2,2)
				elseif mySettings.top_pos == 3 then
					computerPowerup(2,3)
				elseif mySettings.top_pos == 4 then
					computerPowerup(2,4)
				end
			--[[else
				local rand2 = math.random( 4 )
				while rand2 == 1 or ((rand2 == 4) and not mySettings.purple_there) or ((rand2 == 2) and not mySettings.orange_there) or ((rand2 == 3) and not mySettings.blue_there) do
					rand2 = math.random( 4 )
				end
				computerPowerup(0,rand2)
			end]]
		end
		elseif pturn == 2 then
		if ((rand1 == 1 and mySettings.orange_pawn_ypos < 4) or mySettings.red_pawn_ypos < 1 or mySettings.blue_pawn_ypos < 1 or mySettings.purple_pawn_ypos < 1) and not mySettings.orange_frozen then
			--if rand1 ~= 1 then
				check_highest()
				if mySettings.top_pos == 1 then
					computerPowerup(2,1)
				elseif mySettings.top_pos == 3 then
					computerPowerup(2,3)
				elseif mySettings.top_pos == 4 then
					computerPowerup(2,4)
				end
			--[[else
				local rand2 = math.random( 4 )
				while rand2 == 2 or ((rand2 == 1) and not mySettings.red_there) or ((rand2 == 4) and not mySettings.purple_there) or ((rand2 == 3) and not mySettings.blue_there) do
					rand2 = math.random( 4 )
				end
				computerPowerup(0,rand2)
			end]]
		end
		elseif pturn == 3 then
		if ((rand1 == 1 and mySettings.blue_pawn_ypos < 4) or mySettings.orange_pawn_ypos < 1 or mySettings.red_pawn_ypos < 1 or mySettings.purple_pawn_ypos < 1) and not mySettings.blue_frozen then
			--if rand1 ~= 1 then
				check_highest()
				if mySettings.top_pos == 2 then
					computerPowerup(2,2)
				elseif mySettings.top_pos == 1 then
					computerPowerup(2,1)
				elseif mySettings.top_pos == 4 then
					computerPowerup(2,4)
				end
			--[[else
				local rand2 = math.random( 4 )
				while rand2 == 3 or ((rand2 == 1) and not mySettings.red_there) or ((rand2 == 2) and not mySettings.orange_there) or ((rand2 == 4) and not mySettings.purple_there) do
					rand2 = math.random( 4 )
				end
				computerPowerup(0,rand2)
			end]]
		end
		elseif pturn == 4 then
		if ((rand1 == 1 and mySettings.purple_pawn_ypos < 4) or mySettings.orange_pawn_ypos < 1 or mySettings.blue_pawn_ypos < 1 or mySettings.red_pawn_ypos < 1) and not mySettings.purple_frozen then
			--if rand1 ~= 1 then
				check_highest()
				if mySettings.top_pos == 2 then
					computerPowerup(2,2)
				elseif mySettings.top_pos == 3 then
					computerPowerup(2,3)
				elseif mySettings.top_pos == 1 then
					computerPowerup(2,1)
				end
			--[[else
				local rand2 = math.random( 4 )
				while rand2 == 4 or ((rand2 == 1) and not mySettings.red_there) or ((rand2 == 2) and not mySettings.orange_there) or ((rand2 == 3) and not mySettings.blue_there) do
					rand2 = math.random( 4 )
				end
				computerPowerup(0,rand2)
			end]]
		end
		end
		timer.performWithDelay(1000,player_turn)
		end
	elseif pturn == pawn_number then
		
		if mySettings.win or mySettings.quit then
			display.remove(dice)
		return true
		else
		
		if pturn == 1 and mySettings.red_frozen then
			player_turn()
		elseif pturn == 2 and mySettings.orange_frozen then
			player_turn()
		elseif pturn == 3 and mySettings.blue_frozen then
			player_turn()
		elseif pturn == 4 and mySettings.purple_frozen then
			player_turn()
		else
		
		mySettings.allowPowerup = true
		if  math.random( 6 ) == 5 and tonumber(Bought.load()) == 1 then
		GoldPowerup = true
		end
		ActivateGoldenDie = true
		dice_button.isVisible = true
		if dice_button ~= nil then
		transition.to(dice_button, {time = 1300, x = display.contentWidth/2, y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth/2, xScale = 0.24, yScale = 0.24, onComplete = function()if dice_button~= nil then dice_button:addEventListener("touch",myTapListener)end;goAway();end})
		end
		
		end
		end
	end
	end
end

function computerPowerup(nearWin,who)

		if pturn == 1 then
			if mySettings.red_six_num > 0 then
				mySettings.red_six_num = mySettings.red_six_num - 1
				local RedTen = display.newImage("RedTen.png",display.contentWidth/2,display.contentHeight*0.8)
				RedTen:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(RedTen,{time = 3000, delay = 700, alpha = 0})
				
				if who == 2 then
					mySettings.currently_ten = 2
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				elseif who == 3 then
					mySettings.currently_ten = 3
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				elseif who == 4 then
					mySettings.currently_ten = 4
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				end
				
			elseif mySettings.red_freeze_num > 0 then
				mySettings.red_freeze_num = mySettings.red_freeze_num - 1 
				local RedFreeze = display.newImage("RedFreeze.png",display.contentWidth/2,display.contentHeight*0.8)
				RedFreeze:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(RedFreeze,{time = 3000, delay = 700, alpha = 0})
				if who == 2 then
					mySettings.orange_frozen = true
					mySettings.currently_frozen = 2
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				elseif who == 3 then
					mySettings.blue_frozen = true
					mySettings.currently_frozen = 3
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				elseif who == 4 then
					mySettings.purple_frozen = true
					mySettings.currently_frozen = 4
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				end
			elseif mySettings.red_doubles_num > 0 then
				local RedDoubles = display.newImage("Red2x.png",display.contentWidth/2,display.contentHeight*0.8)
				RedDoubles:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(RedDoubles,{time = 3000, delay = 700, alpha = 0})
				mySettings.red_doubles_num = mySettings.red_doubles_num - 1
				mySettings.red_doubles = true
				data.saveTable(mySettings,"mySettings.json")
			else 
				return true
			end	
		elseif pturn == 2 then
			if mySettings.orange_six_num > 0 then
				mySettings.orange_six_num = mySettings.orange_six_num - 1
				local OrangeTen = display.newImage("OrangeTen.png",display.contentWidth/2,display.contentHeight*0.8)
				OrangeTen:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(OrangeTen,{time = 3000, delay = 700, alpha = 0})
				if who == 1 then
					mySettings.currently_ten = 1
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				elseif who == 3 then
					mySettings.currently_ten = 3
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				elseif who == 4 then
					mySettings.currently_ten = 4
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				end
				
			elseif mySettings.orange_freeze_num > 0 then
				mySettings.orange_freeze_num = mySettings.orange_freeze_num - 1 
				local OrangeFreeze = display.newImage("OrangeFreeze.png",display.contentWidth/2,display.contentHeight*0.8)
				OrangeFreeze:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(OrangeFreeze,{time = 3000, delay = 700, alpha = 0})
				if who == 1 then
					mySettings.red_frozen = true
					mySettings.currently_frozen = 1
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				elseif who == 3 then
					mySettings.blue_frozen = true
					mySettings.currently_frozen = 3
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				elseif who == 4 then
					mySettings.purple_frozen = true
					mySettings.currently_frozen = 4
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				end
			elseif mySettings.orange_doubles_num > 0 then
				local OrangeDoubles = display.newImage("Orange2x.png",display.contentWidth/2,display.contentHeight*0.8)
				OrangeDoubles:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(OrangeDoubles,{time = 3000, delay = 700, alpha = 0})
				
				mySettings.orange_doubles_num = mySettings.orange_doubles_num - 1
				mySettings.orange_doubles = true
				data.saveTable(mySettings,"mySettings.json")
			else 
				return true
			end	
		elseif pturn == 3 then
			if mySettings.blue_six_num > 0 then
				mySettings.blue_six_num = mySettings.blue_six_num - 1
				
				local BlueTen = display.newImage("BlueTen.png",display.contentWidth/2,display.contentHeight*0.8)
				BlueTen:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(BlueTen,{time = 3000, delay = 700, alpha = 0})
				
				if who == 2 then
					mySettings.currently_ten = 2
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				elseif who == 1 then
					mySettings.currently_ten = 1
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				elseif who == 4 then
					mySettings.currently_ten = 4
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				end
				
			elseif mySettings.blue_freeze_num > 0 then
				mySettings.blue_freeze_num = mySettings.blue_freeze_num - 1 
				
				local BlueFreeze = display.newImage("BlueFreeze.png",display.contentWidth/2,display.contentHeight*0.8)
				BlueFreeze:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(BlueFreeze,{time = 3000, delay = 700, alpha = 0})
				
				if who == 2 then
					mySettings.orange_frozen = true
					mySettings.currently_frozen = 2
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				elseif who == 1 then
					mySettings.red_frozen = true
					mySettings.currently_frozen = 1
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				elseif who == 4 then
					mySettings.purple_frozen = true
					mySettings.currently_frozen = 4
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				end
			elseif mySettings.blue_doubles_num > 0 then
			
				local BlueDoubles = display.newImage("Blue2x.png",display.contentWidth/2,display.contentHeight*0.8)
				BlueDoubles:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(BlueDoubles,{time = 3000, delay = 700, alpha = 0})
				
				mySettings.blue_doubles_num = mySettings.blue_doubles_num - 1
				mySettings.blue_doubles = true
				data.saveTable(mySettings,"mySettings.json")
			else 
				return true
			end	
		elseif pturn == 4 then
			if mySettings.purple_six_num > 0 then
				mySettings.purple_six_num = mySettings.purple_six_num - 1
				
				local PurpleTen = display.newImage("PurpleTen.png",display.contentWidth/2,display.contentHeight*0.8)
				PurpleTen:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(PurpleTen,{time = 3000, delay = 700, alpha = 0})
				
				if who == 2 then
					mySettings.currently_ten = 2
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				elseif who == 3 then
					mySettings.currently_ten = 3
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				elseif who == 1 then
					mySettings.currently_ten = 1
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayminusTen")
					minusTen(who)
				end
				
			elseif mySettings.purple_freeze_num > 0 then
				mySettings.purple_freeze_num = mySettings.purple_freeze_num - 1 
				
				local PurpleFreeze = display.newImage("PurpleFreeze.png",display.contentWidth/2,display.contentHeight*0.8)
				PurpleFreeze:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(PurpleFreeze,{time = 3000, delay = 700, alpha = 0})
				
				if who == 2 then
					mySettings.orange_frozen = true
					mySettings.currently_frozen = 2
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				elseif who == 3 then
					mySettings.blue_frozen = true
					mySettings.currently_frozen = 3
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				elseif who == 1 then
					mySettings.red_frozen = true
					mySettings.currently_frozen = 1
					data.saveTable(mySettings,"mySettings.json")
					composer.showOverlay("overlayFrozen")
				end
			elseif mySettings.purple_doubles_num > 0 then
			
				local PurpleDoubles = display.newImage("Purple2x.png",display.contentWidth/2,display.contentHeight*0.8)
				PurpleDoubles:scale((display.contentWidth/2296),(display.contentWidth/2296))
				transition.to(PurpleDoubles,{time = 3000, delay = 700, alpha = 0})
			
				mySettings.purple_doubles_num = mySettings.purple_doubles_num - 1
				mySettings.purple_doubles = true
				data.saveTable(mySettings,"mySettings.json")
			else 
				return true
			end			
		end		
	
	data.saveTable(mySettings,"mySettings.json")
end

function count_score()
mySettings.eliteScore = 0 
local scorecalc = 2950
	if pawn_number == 1 then
		
		if mySettings.orange_there then
		
		if (mySettings.red_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.red_pawn_xpos + 1)+(10*(10-(mySettings.red_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.red_pawn_xpos))+(10*(10-(mySettings.red_pawn_ypos + 1)))))
		end
		
			if (mySettings.orange_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.orange_pawn_xpos + 1)+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.orange_pawn_xpos))+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.blue_there then
		if (mySettings.red_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.red_pawn_xpos + 1)+(10*(10-(mySettings.red_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.red_pawn_xpos))+(10*(10-(mySettings.red_pawn_ypos + 1)))))
		end
		
			if (mySettings.blue_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.blue_pawn_xpos + 1)+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.blue_pawn_xpos))+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.purple_there then
		if (mySettings.red_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.red_pawn_xpos + 1)+(10*(10-(mySettings.red_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.red_pawn_xpos))+(10*(10-(mySettings.red_pawn_ypos + 1)))))
		end
		
			if (mySettings.purple_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.purple_pawn_xpos + 1)+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.purple_pawn_xpos))+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			end
		end
	
	elseif pawn_number == 2 then
		
		if mySettings.red_there then
		
		if (mySettings.orange_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.orange_pawn_xpos + 1)+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.orange_pawn_xpos))+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
		end
		
			if (mySettings.red_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.red_pawn_xpos + 1)+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.red_pawn_xpos))+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.blue_there then
		if (mySettings.orange_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.orange_pawn_xpos + 1)+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.orange_pawn_xpos))+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
		end
		
			if (mySettings.blue_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.blue_pawn_xpos + 1)+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.blue_pawn_xpos))+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.purple_there then
		if (mySettings.orange_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.orange_pawn_xpos + 1)+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.orange_pawn_xpos))+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
		end
		
			if (mySettings.purple_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.purple_pawn_xpos + 1)+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.purple_pawn_xpos))+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			end
		end
	elseif pawn_number == 3 then
		
		if mySettings.orange_there then
		
		if (mySettings.blue_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.blue_pawn_xpos + 1)+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.blue_pawn_xpos))+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
		end
		
			if (mySettings.orange_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.orange_pawn_xpos + 1)+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.orange_pawn_xpos))+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.red_there then
		if (mySettings.blue_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.blue_pawn_xpos + 1)+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.blue_pawn_xpos))+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
		end
		
			if (mySettings.red_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.red_pawn_xpos + 1)+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.red_pawn_xpos))+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.purple_there then
		if (mySettings.blue_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.blue_pawn_xpos + 1)+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.blue_pawn_xpos))+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
		end
		
			if (mySettings.purple_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.purple_pawn_xpos + 1)+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.purple_pawn_xpos))+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
			end
		end
		
	elseif pawn_number == 4 then
		
		if mySettings.orange_there then
		
		if (mySettings.purple_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.purple_pawn_xpos + 1)+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.purple_pawn_xpos))+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
		end
		
			if (mySettings.orange_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.orange_pawn_xpos + 1)+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.orange_pawn_xpos))+(10*(10-(mySettings.orange_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.blue_there then
		if (mySettings.purple_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.purple_pawn_xpos + 1)+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.purple_pawn_xpos))+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
		end
		
			if (mySettings.blue_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.blue_pawn_xpos + 1)+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.blue_pawn_xpos))+(10*(10-(mySettings.blue_pawn_ypos + 1)))))
			end
		end
		
		if mySettings.red_there then
		if (mySettings.purple_pawn_ypos % 2) ~= 0 then
			scorecalc = scorecalc + (10*((mySettings.purple_pawn_xpos + 1)+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
		else
			scorecalc = scorecalc + (10*(((10 - mySettings.purple_pawn_xpos))+(10*(10-(mySettings.purple_pawn_ypos + 1)))))
		end
		
			if (mySettings.red_pawn_ypos % 2) ~= 0 then
				scorecalc = scorecalc - (10*((mySettings.red_pawn_xpos + 1)+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			else
				scorecalc = scorecalc - (10*(((10 - mySettings.red_pawn_xpos))+(10*(10-(mySettings.red_pawn_ypos + 1)))))
			end
		end
		
	end
	mySettings.eliteScore = scorecalc
	data.saveTable(mySettings,"mySettings.json")
end

function minusTen(who)

	if who == 1 then
		if mySettings.red_pawn_ypos > 8 then
			mySettings.red_pawn_xpos = 0
			mySettings.red_pawn_ypos = 9
			data.saveTable(mySettings,"mySettings.json")
		else
			mySettings.red_pawn_xpos = 9 - mySettings.red_pawn_xpos
			mySettings.red_pawn_ypos = mySettings.red_pawn_ypos + 1
			data.saveTable(mySettings,"mySettings.json")
		end
		transition.to(red_pawn, {time = 2000, x = display.contentWidth*(0.05+(0.0945*(mySettings.red_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(mySettings.red_pawn_ypos)))})
	elseif who == 2 then
		if mySettings.orange_pawn_ypos > 8 then
			mySettings.orange_pawn_xpos = 0
			mySettings.orange_pawn_ypos = 9
			data.saveTable(mySettings,"mySettings.json")
		else
			mySettings.orange_pawn_xpos = 9 - mySettings.orange_pawn_xpos
			mySettings.orange_pawn_ypos = mySettings.orange_pawn_ypos + 1
			data.saveTable(mySettings,"mySettings.json")
		end
		transition.to(orange_pawn, {time = 2000, x = display.contentWidth*(0.098+(0.0945*(mySettings.orange_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(mySettings.orange_pawn_ypos)))})
	elseif who == 3 then
		if mySettings.blue_pawn_ypos > 8 then
			mySettings.blue_pawn_xpos = 0
			mySettings.blue_pawn_ypos = 9
			data.saveTable(mySettings,"mySettings.json")
		else
			mySettings.blue_pawn_xpos = 9 - mySettings.blue_pawn_xpos
			mySettings.blue_pawn_ypos = mySettings.blue_pawn_ypos + 1
			data.saveTable(mySettings,"mySettings.json")
		end
		transition.to(blue_pawn, {time = 2000, x = display.contentWidth*(0.05+(0.0945*(mySettings.blue_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(mySettings.blue_pawn_ypos)))})
	elseif who == 4 then
		if mySettings.purple_pawn_ypos > 8 then
			mySettings.purple_pawn_xpos = 0
			mySettings.purple_pawn_ypos = 9
			data.saveTable(mySettings,"mySettings.json")
		else
			mySettings.purple_pawn_xpos = 9 - mySettings.purple_pawn_xpos
			mySettings.purple_pawn_ypos = mySettings.purple_pawn_ypos + 1
			data.saveTable(mySettings,"mySettings.json")
		end
		transition.to(purple_pawn, {time = 2000, x = display.contentWidth*(0.098+(0.0945*(mySettings.purple_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(mySettings.purple_pawn_ypos)))})
	end
end

function transition_help( obj )
	move = move - 1
	if obj == red_pawn then
	check_snake_ladder(mySettings.red_pawn_xpos, mySettings.red_pawn_ypos, red_pawn, move)
	elseif obj == orange_pawn then
	check_snake_ladder(mySettings.orange_pawn_xpos, mySettings.orange_pawn_ypos, orange_pawn, move)
	elseif obj == blue_pawn then
	check_snake_ladder(mySettings.blue_pawn_xpos, mySettings.blue_pawn_ypos, blue_pawn, move)
	elseif obj == purple_pawn then
	check_snake_ladder(mySettings.purple_pawn_xpos, mySettings.purple_pawn_ypos, purple_pawn, move)
	end
	
end

function trans_snake_ladder( obj )
	if obj == red_pawn then
				move_snake_ladder(mySettings.red_pawn_xpos, mySettings.red_pawn_ypos, red_pawn )
			elseif obj == orange_pawn then
				move_snake_ladder(mySettings.orange_pawn_xpos, mySettings.orange_pawn_ypos, orange_pawn )
			elseif obj == blue_pawn then
				move_snake_ladder(mySettings.blue_pawn_xpos, mySettings.blue_pawn_ypos, blue_pawn )
			elseif obj == purple_pawn then
				move_snake_ladder(mySettings.purple_pawn_xpos, mySettings.purple_pawn_ypos, purple_pawn )
			end
			
end	

function check_snake_ladder( Xposition, Yposition, pawn_color, steps )
if steps > 0 then
snake_ladder[1][7] = 3
snake_ladder[1][5] = 3
snake_ladder[10][10] = 3
	
	if snake_ladder[Xposition+1][Yposition+1] == 3 then
		

		if pawn_color == red_pawn then 
			mySettings.red_pawn_ypos = mySettings.red_pawn_ypos - 1
			local trans2 = transition.to(red_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.05+(0.0945*(mySettings.red_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(Yposition-1))), onComplete = transition_help, transition = easing.inOutQuad})
		elseif pawn_color == orange_pawn then 
			mySettings.orange_pawn_ypos = mySettings.orange_pawn_ypos - 1
			local trans2 = transition.to(orange_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.098+(0.0945*(mySettings.orange_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(Yposition-1))), onComplete = transition_help, transition = easing.inOutQuad})
		elseif pawn_color == blue_pawn then 
			mySettings.blue_pawn_ypos = mySettings.blue_pawn_ypos - 1
			local trans2 = transition.to(blue_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.05+(0.0945*(mySettings.blue_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(Yposition-1))), onComplete = transition_help, transition = easing.inOutQuad})
		elseif pawn_color == purple_pawn then 
			mySettings.purple_pawn_ypos = mySettings.purple_pawn_ypos - 1
			local trans2 = transition.to(purple_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.098+(0.0945*(mySettings.purple_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(Yposition-1))), onComplete = transition_help, transition = easing.inOutQuad})
		end
	elseif snake_ladder[Xposition+1][Yposition+1] == 4 then
		if pawn_color == red_pawn then mySettings.Winner = "red_pawn"
		elseif pawn_color == orange_pawn then mySettings.Winner = "orange_pawn"
		elseif pawn_color == blue_pawn then mySettings.Winner = "blue_pawn"
		elseif pawn_color == purple_pawn then mySettings.Winner = "purple_pawn"
		end
		Bought.load()
		Bought.set(0)
		Bought.save()
		mySettings.win = true
		mySettings.style = "Elite"
		data.saveTable(mySettings,"mySettings.json")
		count_score()
		timer.performWithDelay(1500, function() display.remove(dice);composer.gotoScene("winner");end)
	else
		if Yposition%2 ~= 0 then
			if pawn_color == red_pawn then 
				mySettings.red_pawn_xpos = mySettings.red_pawn_xpos + 1
				local trans1 = transition.to(red_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.05+(0.0945*(Xposition+1))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(mySettings.red_pawn_ypos))), onComplete = transition_help})
			elseif pawn_color == orange_pawn then 
				mySettings.orange_pawn_xpos = mySettings.orange_pawn_xpos + 1
				local trans1 = transition.to(orange_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.098+(0.0945*(Xposition+1))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(mySettings.orange_pawn_ypos))), onComplete = transition_help})
			elseif pawn_color == blue_pawn then 
				mySettings.blue_pawn_xpos = mySettings.blue_pawn_xpos + 1
				local trans1 = transition.to(blue_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.05+(0.0945*(Xposition+1))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(mySettings.blue_pawn_ypos))), onComplete = transition_help})
			elseif pawn_color == purple_pawn then 
				mySettings.purple_pawn_xpos = mySettings.purple_pawn_xpos + 1
				local trans1 = transition.to(purple_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.098+(0.0945*(Xposition+1))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(mySettings.purple_pawn_ypos))), onComplete = transition_help})
			end
		elseif Yposition%2 == 0 then
			if pawn_color == red_pawn then 
				mySettings.red_pawn_xpos = mySettings.red_pawn_xpos - 1
				local trans2 = transition.to(red_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.05+(0.0945*(Xposition-1))), onComplete = transition_help, transition = easing.inOutQuad})
			elseif pawn_color == orange_pawn then 
				mySettings.orange_pawn_xpos = mySettings.orange_pawn_xpos - 1
				local trans2 = transition.to(orange_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.098+(0.0945*(Xposition-1))), onComplete = transition_help, transition = easing.inOutQuad})
			elseif pawn_color == blue_pawn then 
				mySettings.blue_pawn_xpos = mySettings.blue_pawn_xpos - 1
				local trans2 = transition.to(blue_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.05+(0.0945*(Xposition-1))), onComplete = transition_help, transition = easing.inOutQuad})
			elseif pawn_color == purple_pawn then 
				mySettings.purple_pawn_xpos = mySettings.purple_pawn_xpos - 1
				local trans2 = transition.to(purple_pawn, {time = dur_pawn, delay = delay_pawn, x = display.contentWidth*(0.098+(0.0945*(Xposition-1))), onComplete = transition_help, transition = easing.inOutQuad})
			end
		end
	end
	else 
		trans_snake_ladder(pawn_color)
	--[[	
	if pturn ~= pawn_number then
		timer.performWithDelay(2000,player_turn)
	end
	]]
	
	end
end

function powerupAnimation()
	iterations = 0
	if GoldPowerup and notStar then
	empty = display.newImage("empty_gold.png",display.contentWidth/2,display.contentHeight/2)
	GoldPowerup = false
	else
	empty = display.newImage("empty.png",display.contentWidth/2,display.contentHeight/2)
	end
	empty:scale((display.contentWidth/467)*0.5,(display.contentWidth/467)*0.5)
	shadow = display.newImage("power_shadow.png",display.contentWidth/2,((display.contentHeight-display.contentWidth)/2)+display.contentWidth*0.87)
	shadow:scale((display.contentWidth/467)*0.5,(display.contentWidth/467)*0.5)
	power1 = display.newImage("freeze_motion.png",display.contentWidth*0.5,25+display.contentHeight*0.5)
	power1:scale((display.contentWidth/467)*0.45,(display.contentWidth/467)*0.45)
	transition.to(power1,{time = 10, delta = true, y = -45})
	transition.to(power1,{time = 10, delay = 50, alpha = 0.95, onComplete = function()powerupAnimation1();display.remove(power1);end})
end
function powerupAnimation1()
	power2 = display.newImage("minus_ten_motion.png",display.contentWidth*0.5,30+display.contentHeight*0.5)
	power2:scale((display.contentWidth/467)*0.4,(display.contentWidth/467)*0.4)
	transition.to(power2,{time = 10, delta = true, y = -40})
	if ((iterations >= 7) and (mySettings.powerupRand == 3)) then
	transition.to(power2,{time = 10, delay = 50, alpha = 0.95, onComplete = function()overlayPowerup();display.remove(power2);end})
	else
	transition.to(power2,{time = 10, delay = 50, alpha = 0.95, onComplete = function()powerupAnimation2();display.remove(power2);end})
	end
	iterations = iterations + 1
end
function powerupAnimation2()
	power3 = display.newImage("shield_motion.png",display.contentWidth*0.5,20+display.contentHeight*0.5)
	power3:scale((display.contentWidth/467)*0.45,(display.contentWidth/467)*0.45)
	transition.to(power3,{time = 10, delta = true, y = -25})
	if ((iterations >= 7) and (mySettings.powerupRand == 4)) then
	transition.to(power3,{time = 10, delay = 50, alpha = 0.95, onComplete = function()overlayPowerup();display.remove(power3);end})
	else
	transition.to(power3,{time = 10, delay = 50, alpha = 0.95, onComplete = function()powerupAnimation3();display.remove(power3);end})
	end
end
function powerupAnimation3()
	power4 = display.newImage("2x_motion.png",display.contentWidth*0.5,30+display.contentHeight*0.5)
	power4:scale((display.contentWidth/467)*0.45,(display.contentWidth/467)*0.45)
	transition.to(power4,{time = 10, delta = true, y = -45})
	if ((iterations >= 7) and (mySettings.powerupRand == 1)) then
	transition.to(power4,{time = 10, delay = 50, alpha = 0.95, onComplete = function()overlayPowerup();display.remove(power4);end})
	else
	transition.to(power4,{time = 10, delay = 50, alpha = 0.95, onComplete = function()powerupAnimation4();display.remove(power4);end})
	end
end
function powerupAnimation4()
	power5 = display.newImage("freeze_motion.png",display.contentWidth*0.5,30+display.contentHeight*0.5)
	power5:scale((display.contentWidth/467)*0.45,(display.contentWidth/467)*0.45)
	transition.to(power5,{time = 10, delta = true, y = -35})
	if ((iterations >= 7) and (mySettings.powerupRand == 2)) then
	transition.to(power5,{time = 10, delay = 50, alpha = 0.95, onComplete = function()overlayPowerup();display.remove(power5);end})
	else
	transition.to(power5,{time = 10, delay = 50, alpha = 0.95, onComplete = function()powerupAnimation1();display.remove(power5);end})
	end
end

function overlayPowerup(rand)
	local rand = mySettings.powerupRand
	local power_img
 	
		if rand == 1 then
			
			power_img = display.newImage("Freeze.png",display.contentWidth/2,40+display.contentHeight/2)
			
		elseif rand == 2 then
			power_img = display.newImage("Six.png",display.contentWidth/2,40+display.contentHeight/2)
			
		elseif rand == 3 then
			power_img = display.newImage("Shield.png",display.contentWidth/2,40+display.contentHeight/2)
	
		elseif rand == 4 then
			power_img = display.newImage("2x.png",display.contentWidth/2,40+display.contentHeight/2)
		
		end
	
		power_img:scale((display.contentWidth/467)*0.5,(display.contentWidth/467)*0.5)
		
		transition.to(power_img,{time = 100, delta = true, y = -40})
		transition.to(empty,{time = 100, delay = 2300, alpha = 0})
		transition.to(power_img,{time = 100, delay = 2300, alpha = 0, onComplete = function()display.remove(empty);display.remove(shadow);end})
		
end

function move_snake_ladder ( Xposition, Yposition, pawn_color)
	snake_ladder[1][5] = 1
	snake_ladder[1][7] = 2
	snake_ladder[10][10] = 5
	
	if snake_ladder[Xposition+1][Yposition+1] == 2 or snake_ladder[Xposition+1][Yposition+1] == 1 then
		if snake_ladder[Xposition+1][Yposition+1] == 1 and pawn_color == red_pawn and mySettings.red_shield_num > 0 then
			if mySettings.ShieldBought >= mySettings.red_shield_num then
				ShieldOwned.add(-1)
				ShieldOwned.save()
			end	
			mySettings.red_shield_num = mySettings.red_shield_num - 1
			goShield.isVisible = true
			transition.to(goShield,{time = 700, y = -130, delta = true})
			transition.to(goShield,{time = 600, alpha = 0, onComplete = function(obj)display.remove(obj);end})
			goShield = display.newImage("Shield_inv1.png",display.contentWidth/2,display.contentHeight/2)
			goShield:scale((display.contentWidth/1225)*0.65,(display.contentWidth/1225)*0.65)
			goShield.isVisible = false
		elseif snake_ladder[Xposition+1][Yposition+1] == 1 and pawn_color == orange_pawn and mySettings.orange_shield_num > 0 then
			if mySettings.ShieldBought >= mySettings.orange_shield_num then
				ShieldOwned.add(-1)
				ShieldOwned.save()
			end	
			mySettings.orange_shield_num = mySettings.orange_shield_num - 1
			goShield.isVisible = true
			transition.to(goShield,{time = 700, y = -130, delta = true})
			transition.to(goShield,{time = 600, alpha = 0, onComplete = function(obj)display.remove(obj);end})
			goShield = display.newImage("Shield_inv1.png",display.contentWidth/2,display.contentHeight/2)
			goShield:scale((display.contentWidth/1225)*0.65,(display.contentWidth/1225)*0.65)
			goShield.isVisible = false
		elseif snake_ladder[Xposition+1][Yposition+1] == 1 and pawn_color == blue_pawn and mySettings.blue_shield_num > 0 then
			if mySettings.ShieldBought >= mySettings.blue_shield_num then
				ShieldOwned.add(-1)
				ShieldOwned.save()
			end	
			mySettings.blue_shield_num = mySettings.blue_shield_num - 1
			goShield.isVisible = true
			transition.to(goShield,{time = 700, y = -130, delta = true})
			transition.to(goShield,{time = 600, alpha = 0, onComplete = function(obj)display.remove(obj);end})
			goShield = display.newImage("Shield_inv1.png",display.contentWidth/2,display.contentHeight/2)
			goShield:scale((display.contentWidth/1225)*0.65,(display.contentWidth/1225)*0.65)
			goShield.isVisible = false
		elseif snake_ladder[Xposition+1][Yposition+1] == 1 and pawn_color == purple_pawn and mySettings.purple_shield_num > 0 then
			if mySettings.ShieldBought >= mySettings.purple_shield_num then
				ShieldOwned.add(-1)
				ShieldOwned.save()
			end	
			mySettings.purple_shield_num = mySettings.purple_shield_num - 1
			goShield.isVisible = true
			transition.to(goShield,{time = 700, y = -130, delta = true})
			transition.to(goShield,{time = 600, alpha = 0, onComplete = function(obj)display.remove(obj);end})
			goShield = display.newImage("Shield_inv1.png",display.contentWidth/2,display.contentHeight/2)
			goShield:scale((display.contentWidth/1225)*0.65,(display.contentWidth/1225)*0.65)
			goShield.isVisible = false
		else
			if pawn_color == red_pawn then 
				mySettings.red_pawn_xpos = snake_ladder_x[Xposition+1][Yposition+1]
				mySettings.red_pawn_ypos = snake_ladder_y[Xposition+1][Yposition+1]
				local trans2 = transition.to(red_pawn, {time = 500, delay = 300, x = display.contentWidth*(0.05+(0.0945*(mySettings.red_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(mySettings.red_pawn_ypos)))})
			elseif pawn_color == orange_pawn then 
				mySettings.orange_pawn_xpos = snake_ladder_x[Xposition+1][Yposition+1]
				mySettings.orange_pawn_ypos = snake_ladder_y[Xposition+1][Yposition+1]
				local trans2 = transition.to(orange_pawn, {time = 500, delay = 300, x = display.contentWidth*(0.098+(0.0945*(mySettings.orange_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(mySettings.orange_pawn_ypos)))})
			elseif pawn_color == blue_pawn then 
				mySettings.blue_pawn_xpos = snake_ladder_x[Xposition+1][Yposition+1]
				mySettings.blue_pawn_ypos = snake_ladder_y[Xposition+1][Yposition+1]
				local trans2 = transition.to(blue_pawn, {time = 500, delay = 300, x = display.contentWidth*(0.05+(0.0945*(mySettings.blue_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(mySettings.blue_pawn_ypos)))})
			elseif pawn_color == purple_pawn then 
				mySettings.purple_pawn_xpos = snake_ladder_x[Xposition+1][Yposition+1]
				mySettings.purple_pawn_ypos = snake_ladder_y[Xposition+1][Yposition+1]
				local trans2 = transition.to(purple_pawn, {time = 500, delay = 300, x = display.contentWidth*(0.098+(0.0945*(mySettings.purple_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(mySettings.purple_pawn_ypos)))})
			end
		end
	elseif snake_ladder[Xposition+1][Yposition+1] == 4 then
		ads.hide()
		if pawn_color == red_pawn then mySettings.Winner = "red_pawn"
		elseif pawn_color == orange_pawn then mySettings.Winner = "orange_pawn"
		elseif pawn_color == blue_pawn then mySettings.Winner = "blue_pawn"
		elseif pawn_color == purple_pawn then mySettings.Winner = "purple_pawn"
		end
		mySettings.win = true
		mySettings.style = "Elite"
		data.saveTable(mySettings,"mySettings.json")
		count_score()
		timer.performWithDelay(1500, function() display.remove(dice);composer.gotoScene("winner");end)
		
	elseif snake_ladder[Xposition+1][Yposition+1] == 5 then
		mySettings.starPowerup = true
		local rands = math.random( 4 )
		mySettings.powerupRand = rands
		--data.saveTable(mySettings,"mySettings.json")
		if pawn_color == red_pawn then
			if rands == 1 then 
				mySettings.red_freeze_num = mySettings.red_freeze_num + 1
				data.saveTable(mySettings,"mySettings.json")
			
			elseif rands == 2 then 
				mySettings.red_six_num = mySettings.red_six_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 3 then 
				mySettings.red_shield_num = mySettings.red_shield_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 4 then 
				mySettings.red_doubles_num = mySettings.red_doubles_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			end
		elseif pawn_color == orange_pawn then
			if rands == 1 then 
				mySettings.orange_freeze_num = mySettings.orange_freeze_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 2 then 
				mySettings.orange_six_num = mySettings.orange_six_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 3 then 
				mySettings.orange_shield_num = mySettings.orange_shield_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 4 then 
				mySettings.orange_doubles_num = mySettings.orange_doubles_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			end
		elseif pawn_color == blue_pawn then
			if rands == 1 then 
				mySettings.blue_freeze_num = mySettings.blue_freeze_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 2 then 
				mySettings.blue_six_num = mySettings.blue_six_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 3 then 
				mySettings.blue_shield_num = mySettings.blue_shield_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 4 then 
				mySettings.blue_doubles_num = mySettings.blue_doubles_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			end
		elseif pawn_color == purple_pawn then
			if rands == 1 then 
				mySettings.purple_freeze_num = mySettings.purple_freeze_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 2 then 
				mySettings.purple_six_num = mySettings.purple_six_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 3 then 
				mySettings.purple_shield_num = mySettings.purple_shield_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 4 then 
				mySettings.purple_doubles_num = mySettings.purple_doubles_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			end
		end
			--local option = {effect = "fade",time = 400,params ={rand_num = rands}}
			--	composer.showOverlay("overlayPowerup",option)
			notStar = false
			powerupAnimation()
	elseif 	snake_ladder[Xposition+1][Yposition+1] ~= 5 and GoldPowerup then
	mySettings.starPowerup = true
		local rands = math.random( 4 )
		mySettings.powerupRand = rands
		--data.saveTable(mySettings,"mySettings.json")
		if pawn_color == red_pawn and mySettings.pawnNumber == 1 then
			if rands == 1 then 
				mySettings.red_freeze_num = mySettings.red_freeze_num + 1
				data.saveTable(mySettings,"mySettings.json")
			
			elseif rands == 2 then 
				mySettings.red_six_num = mySettings.red_six_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 3 then 
				mySettings.red_shield_num = mySettings.red_shield_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 4 then 
				mySettings.red_doubles_num = mySettings.red_doubles_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			end
		elseif pawn_color == orange_pawn and mySettings.pawnNumber == 2 then
			if rands == 1 then 
				mySettings.orange_freeze_num = mySettings.orange_freeze_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 2 then 
				mySettings.orange_six_num = mySettings.orange_six_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 3 then 
				mySettings.orange_shield_num = mySettings.orange_shield_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 4 then 
				mySettings.orange_doubles_num = mySettings.orange_doubles_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			end
		elseif pawn_color == blue_pawn and mySettings.pawnNumber == 3 then
			if rands == 1 then 
				mySettings.blue_freeze_num = mySettings.blue_freeze_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 2 then 
				mySettings.blue_six_num = mySettings.blue_six_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 3 then 
				mySettings.blue_shield_num = mySettings.blue_shield_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 4 then 
				mySettings.blue_doubles_num = mySettings.blue_doubles_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			end
		elseif pawn_color == purple_pawn and mySettings.pawnNumber == 4 then
			if rands == 1 then 
				mySettings.purple_freeze_num = mySettings.purple_freeze_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 2 then 
				mySettings.purple_six_num = mySettings.purple_six_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 3 then 
				mySettings.purple_shield_num = mySettings.purple_shield_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			elseif rands == 4 then 
				mySettings.purple_doubles_num = mySettings.purple_doubles_num + 1
				data.saveTable(mySettings,"mySettings.json")
				
			end
		end
			--local option = {effect = "fade",time = 400,params ={rand_num = rands}}
			--	composer.showOverlay("overlayPowerup",option)
			notStar = true
			powerupAnimation()
	end
	
end


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view
	
	sceneGroup:insert(background)
		sceneGroup:insert(board)
		if red_pawn ~= nil then
		sceneGroup:insert(red_pawn)
		end
		if orange_pawn ~= nil then
		sceneGroup:insert(orange_pawn)
		end
		if blue_pawn ~= nil then
		sceneGroup:insert(blue_pawn)
		end
		if purple_pawn ~= nil then
		sceneGroup:insert(purple_pawn)
		end
		
		sceneGroup:insert(menu_bar)
		sceneGroup:insert(gold_bar)
		sceneGroup:insert(GoldText)
		sceneGroup:insert(progressView)
		sceneGroup:insert(level_star)
		sceneGroup:insert(LevelText)
		sceneGroup:insert(WonText)
		sceneGroup:insert(LostText)
		sceneGroup:insert(ratio)
		sceneGroup:insert(ratio1)
		sceneGroup:insert(optionsBoard)
		sceneGroup:insert(powerupButton)
		sceneGroup:insert(homeButton)
		sceneGroup:insert(infoButton)
		sceneGroup:insert(retry)
		sceneGroup:insert(dice)
		sceneGroup:insert(dice_button)
		
				
		if power1 ~= nil then
		sceneGroup:insert(power1)
		end
		if power2 ~= nil then
		sceneGroup:insert(power2)
		end
		if power3 ~= nil then
		sceneGroup:insert(power3)
		end
		if power4 ~= nil then
		sceneGroup:insert(power4)
		end
		if power5 ~= nil then
		sceneGroup:insert(power5)
		end
		automatic()
	
	
	
	
    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
	
	
end

function scene:UsedTen()

	if mySettings.red_usedTen then
		mySettings.red_usedTen = false
		local trans4 = transition.to(red_pawn, {time = 700, x = display.contentWidth*(0.05+(0.0945*(mySettings.red_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(mySettings.red_pawn_ypos)))})
	elseif mySettings.orange_usedTen then
		mySettings.orange_usedTen = false
		local trans4 = transition.to(orange_pawn, {time = 700, x = display.contentWidth*(0.098+(0.0945*(mySettings.orange_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.03+(0.0945*(mySettings.orange_pawn_ypos)))})
	elseif mySettings.blue_usedTen then
		mySettings.blue_usedTen = false
		local trans4 = transition.to(blue_pawn, {time = 700, x = display.contentWidth*(0.05+(0.0945*(mySettings.blue_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(mySettings.blue_pawn_ypos)))})
	elseif mySettings.purple_usedTen then
		mySettings.purple_usedTen = false
		local trans4 = transition.to(purple_pawn, {time = 700, x = display.contentWidth*(0.098+(0.0945*(mySettings.purple_pawn_xpos))), y = ((display.contentHeight-display.contentWidth)/2)+display.contentWidth*(0.08+(0.0945*(mySettings.purple_pawn_ypos)))})
	end
	
end
-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "did" ) then
	ads.hide()	
	if not mySettings.removeAds then
	ads.show( "banner", { x=(display.contentWidth/2)-160, y=0, appId="ca-app-pub-8488786023585485/5689904057" } )
	end
		
		--automatic()
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "will" ) then
	

        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.
    end
	
	
	
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
		--transition.cancel()
		
		dice.isVisible = false
		dice_button.isVisible = false
		display.remove(dice)
		dice.isVisible = false
		display.remove(dice_button)
		dice_button.isVisible = false
		display.remove(empty)
		
		display.remove(shadow)
		
		display.remove(power1)
		
		display.remove(power2)
		
		display.remove(power3)
		
		display.remove(power4)
		
		display.remove(power5)
		
		
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
		--transition.cancel()
		display.remove(dice)
		display.remove(dice_button)
		display.remove(empty)
		display.remove(shadow)
		display.remove(power1)
		display.remove(power2)
		display.remove(power3)
		display.remove(power4)
		display.remove(power5)
		--transition.cancel()
		
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

	display.remove(dice)
	display.remove(dice_button)
		display.remove(empty)
		display.remove(shadow)
		display.remove(power1)
		display.remove(power2)
		display.remove(power3)
		display.remove(power4)
		display.remove(power5)
		transition.cancel()

	
    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene