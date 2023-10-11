


-- CODE PREP -- 

local a
NeededFuel=0

MovementWithoutRefueling=0
MaxMovementWithoutRefueling=75

Refueling=false
UseWireless=false
RedWorking=false
RedPhoneFound=false

term.setTextColor(8)

--white     	1
--orange	    2
--magenta	    4
--lightBlue 	8
--yellow	    16
--lime  	    32
--pink      	64
--gray	        128
--lightGray 	256
--cyan	        512
--purple	    1024
--blue	        2048
--brown     	4096
--green     	8192
--red	        16384
--black     	32768

FuelVal=80

Direction=1
XPos=0
YPos=0
ZPos=0

DirectionHome=Direction
XHome=XPos
YHome=YPos
ZHome=ZPos

TempX={}
TempY={}
TempZ={}
TempDirection={}

Menu1=0
Menu2=0
Menu3=0
Menu4=0
Menu5=0
Menu6=0

TermWidth, TermHeight=term.getSize()

term.clear()
for i = 1, TermHeight, 1 do
    print()
end


-- The program will take the starting position as the origin.
-- Turtle faces the +Z direction (Direction 1) from the starting point.

--              forward=1   -Z
--                  |                               up +y
--  -X    left=2  <-+->  right=0     +X                 
--                  |                              down -y
--             backwards=3  +Z

--SaveRefPoint used 1-5



function DisplayUpdate()
    local fuelPerc
    term.clear()
    print("Menu1=" .. Menu1 .. " Menu2=" .. Menu2 .. " Menu3=" .. Menu3 .. " Menu4=" .. Menu4)
    print("Home XYZ:",XHome,"/",YHome,"/",ZHome)
    if Calibrated then
        print("XYZ:",XPos,"/",YPos,"/",ZPos)
        print("Facing:",Direction)
    else
        print("Relative XYZ:",XPos,"/",YPos,"/",ZPos)
        print("Facing (taking starting direction as north):",Direction)
    end
    print("Fuel required for returning:",FuelReqForReturning())
    print("Fuel:",turtle.getFuelLevel(),"/",turtle.getFuelLimit())
    ProgressBar((turtle.getFuelLevel()/turtle.getFuelLimit())*20,20)
    print()
    print("Needed Fuel:",NeededFuel)
end

function ProgressBar(currVal,maxVal)
    currVal=math.ceil(currVal)
    local cursorx,cursory=term.getCursorPos()

    if maxVal+2>TermWidth-cursorx or maxVal==nil then
        maxVal=TermWidth-cursorx
    end
    if currVal>maxVal then
        error("can't draw 1",1)
    elseif  TermWidth-cursorx<=3 then
        error("can't draw 2",2)
    elseif currVal<0 then
        error("can't draw 3",3)
    elseif maxVal<1 then
        error("can't draw 4",4)
    end

    term.write("|")
    local cursorx,cursory=term.getCursorPos()
    if currVal/maxVal<0.25 then
        paintutils.drawLine(cursorx,cursory,cursorx+currVal,cursory,colors.red)
    elseif currVal/maxVal<0.50 then
        paintutils.drawLine(cursorx,cursory,cursorx+currVal,cursory,colors.yellow)
    elseif currVal/maxVal<0.75 then
        paintutils.drawLine(cursorx,cursory,cursorx+currVal,cursory,colors.lime)
    else
        paintutils.drawLine(cursorx,cursory,cursorx+currVal,cursory,colors.green)
    end
    local cursorx,cursory=term.getCursorPos()
    paintutils.drawLine(cursorx,cursory,cursorx+(maxVal-currVal),cursory,colors.black)
    term.write("|")
end

function ColoredText(string,color)
    local asd
    asd=term.getTextColor()
    term.setTextColor(color)
    print(string)
    term.setTextColor(asd)
end

function PrintLine(char)
    local termw,termh=term.getSize()
    for i = 1, termw, 1 do
        term.write(char)
    end
end

function FinishUp()
    print(1)
    Home()
    DropAllItemsUp ()
    RotateDirection(DirectionHome)
end

function GoForward()
    while not turtle.forward() do
        while turtle.detect() do
            local success,data
            success,data=turtle.inspect()
            if data.name=="computercraft:turtle_normal" or data.name=="computercraft:turtle_advanced" then
                do break end
            end
            while not turtle.dig() do
                FinishUp()
                error("\n\nEncountered an unbreakable object.",2)
            end
        end
    end
    if Direction==0 then
        XPos=XPos+1
    elseif Direction==1 then
        ZPos=ZPos-1
    elseif Direction==2 then
        XPos=XPos-1
    elseif Direction==3 then
        ZPos=ZPos+1
    end
    DisplayUpdate()
    return true
end

function GoBackwards()
    while not turtle.back() do
        RotateLeft()
        RotateLeft()
        turtle.dig()
        RotateLeft()
        RotateLeft()
    end
    if Direction==0 then
        XPos=XPos-1
    elseif Direction==1 then
        ZPos=ZPos+1
    elseif Direction==2 then
        XPos=XPos+1
    elseif Direction==3 then
        ZPos=ZPos-1
    end
end

function GoDown()
    while not turtle.down() do
        if not turtle.digDown() then
            FinishUp()
            error("\n\nEncountered an unbreakable object down below.",2)
        end
    end
    YPos=YPos-1
    DisplayUpdate()
end

function GoUp()
    while not turtle.up() do
        if not turtle.digUp() then
            FinishUp()
            error("\n\nEncountered an unbreakable object down below.",2)
        end
    end
    YPos=YPos+1
    DisplayUpdate()
end

function RotateLeft()
    turtle.turnLeft()
    Direction=(Direction+1)%4
end

function RotateRight()
    turtle.turnRight()
    Direction=(Direction-1)%4
end

function RotateDirection(desiredDirection)
    if desiredDirection%4==0 then
        if Direction==1 then
            RotateRight()
        elseif Direction==2 then
            RotateRight()
            RotateRight()
        elseif Direction==3 then
            RotateLeft()
        end

    elseif desiredDirection%4==1 then
        if Direction==0 then
            RotateLeft()
        elseif Direction==2 then
            RotateRight()
        elseif Direction==3 then
            RotateLeft()
            RotateLeft()
        end

    elseif desiredDirection%4==2 then
        if Direction==1 then
            RotateLeft()
        elseif Direction==0 then
            RotateRight()
            RotateRight()
        elseif Direction==3 then
            RotateRight()
        end

    elseif desiredDirection%4==3 then
        if Direction==1 then
            RotateRight()
            RotateRight()
        elseif Direction==2 then
            RotateLeft()
        elseif Direction==0 then
            RotateRight()
        end

    end
end

function DropAllItems()
    term.clear()
    if peripheral.isPresent("front") then
        print("Please place a chest below me...")
        repeat
            sleep(1)
        until peripheral.isPresent("front")
        print("Thanks.")
    end
    local temp=turtle.getSelectedSlot()
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.drop(64)
    end
    turtle.select(temp)
end

function DropAllItemsUp()
    term.clear()
    if not peripheral.isPresent("top") then
        print("Please place a chest on top of me...")
        repeat
            sleep(1)
        until peripheral.isPresent("top")
        print("Thanks.")
    end
    local temp=turtle.getSelectedSlot()
    for i = 1, 16, 1 do
        if turtle.getItemSpace(i)<64 then
            turtle.select(i)
            turtle.dropUp(64)
        end
    end
    turtle.select(temp)
end

function DropAllItemsDown()
    term.clear()
    if peripheral.isPresent("bottom") then
        print("Please place a chest below me...")
        repeat
            sleep(1)
        until peripheral.isPresent("bottom")
        print("Thanks.")
    end
        local temp=turtle.getSelectedSlot()
        for i = 1, 16, 1 do
            turtle.select(i)
            turtle.dropDown(64)
        end
        turtle.select(temp)

end

function FuelReqForReturning()
    return math.abs(XHome-XPos)+math.abs(YHome-YPos)+math.abs(ZHome-ZPos)
end

function FuelReqForGoingToCoords(x,y,z)
    return math.abs(XPos-x)+math.abs(YPos-y)+math.abs(ZPos-z)
end

function GoToCoordinates(x,y,z)
    if x==nil then
        x=XPos
    end
    if y==nil then
        y=YPos
    end
    if z==nil then
        z=ZPos
    end
    if y<-59 then
        GoToCoordinates(XHome-2,YHome+2,ZHome+1)
        error("Way too dangerous to go below Y -59. Returning.",9)
    end
    if math.abs(XHome-XPos)<2 and math.abs(ZHome-ZPos)<2 then

        if XPos<x then
            RotateDirection(0)
            for i = 1, math.abs(XPos-x), 1 do
                GoForward()
            end
        end
        if XPos>x then
            RotateDirection(2)
            for i = 1, math.abs(XPos-x), 1 do
                GoForward()
            end
        end
        if ZPos>z then
            RotateDirection(1)
            for i = 1, math.abs(ZPos-z), 1 do
                GoForward()
            end
        end
        if ZPos<z then
            RotateDirection(3)
            for i = 1, math.abs(ZPos-z), 1 do
                GoForward()
            end
        end

        if YPos>y then
            for i = 1, math.abs(YPos-y), 1 do
                GoDown()
            end
        end
        if YPos<y then
            for i = 1, math.abs(YPos-y), 1 do
                GoUp()
            end
        end

    else


        if YPos<y then
            for i = 1, math.abs(YPos-y), 1 do
                GoUp()
            end
        end
        if YPos>y then
            for i = 1, math.abs(YPos-y), 1 do
                GoDown()
            end
        end

        if XPos<x then
            RotateDirection(0)
            for i = 1, math.abs(XPos-x), 1 do
                GoForward()
            end
        end
        if XPos>x then
            RotateDirection(2)
            for i = 1, math.abs(XPos-x), 1 do
                GoForward()
            end
        end
        if ZPos>z then
            RotateDirection(1)
            for i = 1, math.abs(ZPos-z), 1 do
                GoForward()
            end
        end
        if ZPos<z then
            RotateDirection(3)
            for i = 1, math.abs(ZPos-z), 1 do
                GoForward()
            end
        end

    end

end

function SaveRefPoint(number)
    if number==nil then
        number=0
    end
    TempDirection[number]=Direction
    TempX[number]=XPos
    TempY[number]=YPos
    TempZ[number]=ZPos
end

function GotoRefPoint(number)
    if number==nil then
        number=0
    end
    GoToCoordinates(TempX[number],TempY[number],TempZ[number])
    RotateDirection(TempDirection[number])
end

function SetHome()
    XHome=XPos
    YHome=YPos
    ZHome=ZPos
    DirectionHome=Direction
end

function Home()
    GoToCoordinates(XHome,YHome,ZHome)
end



function Refuel()
    local function FuelValCalibration()
        print("c")
        local oldVal=turtle.getFuelLevel()
        turtle.select(16)
        turtle.suckDown(1)
        if not turtle.refuel(1) then
            FuelVal=80
            turtle.select(1)
            return false
        end
        turtle.select(1)
        FuelVal=turtle.getFuelLevel()-oldVal
        return true
    end

    if ((0.1>turtle.getFuelLevel()/turtle.getFuelLimit() or FuelReqForReturning()*2+MaxMovementWithoutRefueling*2+2>turtle.getFuelLevel()) and NeededFuel~=0) or (XPos==XHome and YPos==YHome and ZPos==ZHome) then
        local slot
        slot=turtle.getSelectedSlot()
        turtle.select(16)
        SaveRefPoint(5)
        NeededFuel=NeededFuel+FuelReqForReturning()*2
        local toBeRefueled
        local fuelBefore=turtle.getFuelLevel()
        if NeededFuel>turtle.getFuelLimit() then
            toBeRefueled=turtle.getFuelLimit()-turtle.getFuelLevel()
        else
            toBeRefueled=NeededFuel
        end
        local totalRefueled=toBeRefueled
        Home()
        print("a")
        FuelValCalibration()
        toBeRefueled=toBeRefueled-(turtle.getFuelLevel()-fuelBefore)
        local fuelItemCountToBeUsed=math.ceil(toBeRefueled/FuelVal)
        turtle.select(AvailibleSpace())
        print("b")
        while toBeRefueled>0 and turtle.getFuelLevel()~=turtle.getFuelLimit() do
            fuelBefore=turtle.getFuelLevel()
            term.clear()
            print()
            print("Fuel:",totalRefueled-toBeRefueled,"/",totalRefueled)
            ProgressBar(((totalRefueled-toBeRefueled)/totalRefueled)*20,20)
            print()
            if fuelItemCountToBeUsed>64 then
                local tempBefore=turtle.getFuelLevel()
                turtle.suckDown(64)
                turtle.refuel(64)
                local fuelUsed=(turtle.getFuelLevel()-tempBefore)/FuelVal
                fuelItemCountToBeUsed=fuelItemCountToBeUsed-fuelUsed
            else
                local tempBefore=turtle.getFuelLevel()
                turtle.suckDown(fuelItemCountToBeUsed)
                turtle.refuel(fuelItemCountToBeUsed)
                local fuelUsed=(turtle.getFuelLevel()-tempBefore)/FuelVal
                fuelItemCountToBeUsed=fuelItemCountToBeUsed-fuelUsed
            end
            toBeRefueled=toBeRefueled-(turtle.getFuelLevel()-fuelBefore)
        end
        turtle.select(1)
        NeededFuel=NeededFuel-totalRefueled
        GotoRefPoint(5)
        turtle.select(slot)
    end
end

function GetAvailibleSpaces()--
    local TotalSpace=0
    for i = 1, 16, 1 do
        if turtle.getItemSpace(i)==64 then
            TotalSpace=TotalSpace+1
        end
    end
    return TotalSpace
end

function AvailibleSpace()--
    local x=nil
    for i = 1, 16, 1 do
        if turtle.getItemSpace(i)==64 then
            x=i
            break
        end
    end
    if x==nil then
        return false
    end
    return x
end


-- REDNET --


function RedCalibrate()
    local a,b
    if Calibrated then
        term.clear()
        print("REDNET Calibrating...")
        if peripheral.isPresent("left") or peripheral.isPresent("right") then
            print("Modem found.")
            if peripheral.isPresent("left") then
                rednet.open("left")
            else
                rednet.open("right")
            end


            PhoneID=rednet.lookup("activation","UmutPhone")
            if PhoneID==nil then
                return
            end
            print("Looked up phone id, found:" .. PhoneID)
            rednet.send(PhoneID,"asd","activation") --
            b , a = rednet.receive() --



            if a=="Done" then
                RedWorking=true
                return true
            else
                RedWorking=false
                return false
            end
        else
            print("Modem not found.")
            RedWorking=false
            return false
        end
    end
end

function EndTransmission()
    if RedPhoneFound then
        rednet.send(PhoneID,"END","47001")
        RedPhoneFound=false
    end
end

function IsHome()
    if XPos==XHome and YPos==YHome and ZPos==ZHome then
        return true
    end
    return false
end

-- MAIN PROGRAMS --


--When i first wrote this code, only god and I knew what I wrote, now only god knows...

function DigCoordinates(x1,x2,y1,y2,z1,z2)
    SaveRefPoint(1)

    --mathematical stuff :5head:
    local xwidth=math.abs(x1-x2)+1
    local xmax=math.max(x1,x2)
    local ywidth=math.abs(y1-y2)+1
    local ymax=math.max(y1,y2)
    local zwidth=math.abs(z1-z2)+1
    local zmax=math.max(z1,z2)
    local rotateDir=1
    NeededFuel=NeededFuel+((xmax+ymax+zmax)*2)+FuelReqForGoingToCoords(x1,y1,z1)
    Quarry(xwidth,ywidth,zwidth,xmax,ymax,zmax,rotateDir)
    GotoRefPoint(1)
end

function DigRadius(radius,depth,x,y,z)
    x=math.floor(x)
    z=math.floor(z)
    y=math.floor(y)
    DigCoordinates(x+radius,x-radius,y,y-depth+1,z+radius,z-radius)
end

function Quarry(rows,depth,columns,gotoX,gotoY,gotoZ,rotateDir) --mines an area taking the top right back corner as the starting point.
    if NeededFuel+10+math.ceil((rows*columns)*((depth/3)+(depth%3)))+3-turtle.getFuelLevel()>0 then
        NeededFuel=NeededFuel+math.ceil((rows*columns)*((depth/3)+(depth%3)))+3
        NeededFuel=NeededFuel+10-turtle.getFuelLevel()
        Refuel()
    end

    local function breakAllThree()
        GoForward()
        if turtle.detectUp() then
            turtle.digUp()
        end
        if turtle.detectDown() then
            turtle.digDown()
        end
    end
    local function breakBelowAnd()
        GoForward()
        if turtle.detectDown() then
            turtle.digDown()
        end
    end
    local function invCheck()
        if turtle.getItemSpace(16)<64 then
            SaveRefPoint(2)
            local temp=FuelReqForReturning()
            Home()
            DropAllItemsUp()
            turtle.select(1)
            NeededFuel=NeededFuel+(temp*2)+4
            Refuel()
            GotoRefPoint(2)
        end
    end
    if gotoX~=nil and gotoY~=nil and gotoZ~=nil and rotateDir~=nil then
        GoToCoordinates(gotoX,gotoY,gotoZ)
        RotateDirection(rotateDir)
    end
    local y=1 --forth back
    local k=1 --Current Depth
    do
    end
    if depth>2 then
        GoDown()
        k=k+1
    end
    while true do
        if depth==2 or (depth-k-1==0 and depth%3~=0) then
            if turtle.detectDown() then
                turtle.digDown()
            end
            for i = 1, columns, 1 do
                for j = 1, rows-1, 1 do
                    invCheck()
                    breakBelowAnd()
                end
                if (columns-i~=0 and columns%2==1) or (columns-i~=0 and columns%2==0 and y%2==1) then
                    if i%2==1 then
                        RotateLeft()
                        breakBelowAnd()
                        RotateLeft()
                    else
                        RotateRight()
                        breakBelowAnd()
                        RotateRight()
                    end
                elseif columns-i~=0 and columns%2==0 and y%2==0 then
                    if i%2==1 then
                        RotateRight()
                        breakBelowAnd()
                        RotateRight()
                    else
                        RotateLeft()
                        breakBelowAnd()
                        RotateLeft()
                    end
                end
            end
            RotateRight()
            RotateRight()
            if turtle.detectUp() then
                turtle.digUp()
            end
            break
        elseif depth-k>=2 or depth%3==0 then
            if turtle.detectDown() then
                turtle.digDown()
            end
            for i = 1, columns, 1 do
                for j = 1, rows-1, 1 do
                    invCheck()
                    breakAllThree()
                end
                if (columns-i~=0 and columns%2==1) or (columns-i~=0 and columns%2==0 and y%2==1) then
                    if i%2==1 then
                        RotateLeft()
                        breakAllThree()
                        RotateLeft()
                    else
                        RotateRight()
                        breakAllThree()
                        RotateRight()
                    end
                elseif columns-i~=0 and columns%2==0 and y%2==0 then
                    if i%2==1 then
                        RotateRight()
                        breakAllThree()
                        RotateRight()
                    else
                        RotateLeft()
                        breakAllThree()
                        RotateLeft()
                    end
                end
            end
            RotateRight()
            RotateRight()
            if turtle.detectUp() then
                turtle.digUp()
            end
        else
            for i = 1, columns, 1 do
                for j = 1, rows-1, 1 do
                    invCheck()
                    GoForward()
                end
                if (columns-i~=0 and columns%2==1) or (columns-i~=0 and columns%2==0 and y%2==1) then
                    if i%2==1 then
                        RotateLeft()
                        GoForward()
                        RotateLeft()
                    else
                        RotateRight()
                        GoForward()
                        RotateRight()
                    end
                elseif columns-i~=0 and columns%2==0 and y%2==0 then
                    if i%2==1 then
                        RotateRight()
                        GoForward()
                        RotateRight()
                    else
                        RotateLeft()
                        GoForward()
                        RotateLeft()
                    end
                end
            end
            RotateRight()
            RotateRight()
            if k<depth then
                GoDown()
                k=k+1
            end
            break
        end
        if k+4<=depth then
            GoDown()
            k=k+1
            GoDown()
            k=k+1
            GoDown()
            k=k+1
        elseif k+2<=depth then
            GoDown()
            k=k+1
            GoDown()
            k=k+1
        else
            break
        end
        y=y+1
    end
    FinishUp()
end

function Miner(radius)
    local function breakAllThree()
        if turtle.detectUp() then
            turtle.digUp()
        end
        if turtle.detectDown() then
            turtle.digDown()
        end
        GoForward()
    end
    GoForward()
    RotateRight()
    for i = 1, radius, 1 do
        breakAllThree()
    end
    RotateDirection(DirectionHome)
    local rows=radius+1
    local columns=radius*2+1
    NeededFuel=NeededFuel+(rows*columns)+rows+columns+1
    Refuel()
    for i = 1, columns, 1 do
        for j = 1, rows-1, 1 do
            if turtle.getItemSpace(16)<64 then
                SaveRefPoint(3)
                local temp=FuelReqForReturning()
                Home()
                DropAllItems()
                turtle.select(1)
                NeededFuel=NeededFuel+((rows+columns+temp)*2)/FuelVal
                Refuel()
                GotoRefPoint(3)
            end
            breakAllThree()
        end
        if i%2==1 then
            RotateLeft()
            breakAllThree()
            RotateLeft()
        else
            RotateRight()
            breakAllThree()
            RotateRight()
        end
    end
    RotateRight()
    RotateRight()
    FinishUp()
end


--CALIBRATING--


function CalibrateGPS()
    local function calibrating(a)
        term.clear()
        print("Calibrating")
        ProgressBar(a,24)
        print()
    end
    calibrating(0)
    if gps.locate() then
        if turtle.getFuelLevel()<3 then
            NeededFuel=NeededFuel+2
            Refuel()
        end
        calibrating(1)
        local coords={}
        local x1,y1,z1=gps.locate() 
        calibrating(2)
        if turtle.forward() then
            calibrating(6)
            local x2,y2,z2=gps.locate()
            calibrating(7)
            XPos=x2
            YPos=y2
            ZPos=z2
            if x2>x1 then
                Direction=0
            elseif x1>x2 then
                Direction=2
            end
            if z2>z1 then
                Direction=3
            elseif z1>z2 then
                Direction=1
            end
            calibrating(14)
            GoBackwards()
            calibrating(24)
            Calibrated=true
            print("Calibration successful!")
            return 1
        else
            return 2
        end
    else
        return 0
    end
end
term.clear()
PrintLine('-')
print("Initializing...")
Output=CalibrateGPS()


function FillGround(xwidth,zwidth)
    local function RefillInv()
        SaveRefPoint()
        Home()
        for i = 1, 16, 1 do
            turtle.suckUp(64)
        end 
        GotoRefPoint()
    end
    local function findItem()
        for i = 1, 16, 1 do
            if turtle.getItemSpace(i)~=64 then
                return i
            end
        end
        return false
    end
    for i = 1, xwidth, 1 do
        for k = 1, zwidth, 1 do
            while not turtle.placeDown() do
                local itemFound=findItem()
                if itemFound~=false then
                    turtle.select(itemFound)
                else
                    RefillInv()
                end
            end
            GoForward()
        end
        if i%2==0 then
            RotateRight()
            GoForward()
            while not turtle.placeDown() do
                local itemFound=findItem()
                if itemFound~=false then
                    turtle.select(itemFound)
                else
                    RefillInv()
                end
            end
            RotateRight()
        else
            RotateLeft()
            GoForward()
            while not turtle.placeDown() do
                local itemFound=findItem()
                if itemFound~=false then
                    turtle.select(itemFound)
                else
                    RefillInv()
                end
            end
            RotateLeft()
        end
    end
end

--EXECUTING--


while true do
    RedCalibrate()
    if RedWorking and Calibrated then
        local x1,x2,y1,y2,z1,z2,a
        RedWorking=false
        NeededFuel = 0
        term.clear()
        print("Please look at your phone.")
        SetHome()
        sleep(0.1)
        rednet.send(PhoneID,        (
            "==========================" ..
            "\nWireless Terminal" ..
            "\n==========================" ..
            "\n1- Quarry" ..
            "\n2- Mine" ..
            "\n3- Dig Current Pos Radius" ..
            "\n4- Dig Pos"..
            "\n5- New Home" ..
            "\n6- Reuel " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit() .. " " .. (turtle.getFuelLevel()/turtle.getFuelLimit())*100 .. "%" ..
            "\n" ..
            "\n" ..
            "\n" ..
            "\n" ..
            "\n" ..
            "\n" ..
            "\n" ..
            "\n9- Shut down" .. 
            "\nPlease input what you want to do:"
        ), "Menu")
        a,Selection=rednet.receive("answer")
        Selection=tonumber(Selection)
        term.clear()
        sleep(0.1)
        if Selection == 1 then
            rednet.send(PhoneID,3)
            sleep(0.1)
            rednet.send(PhoneID,"Please input the rows of the location.")
            a,Menu1=rednet.receive(nil,20)
            sleep(0.1)
            rednet.send(PhoneID,"Please input the depth of the location.")
            a,Menu2=rednet.receive(nil,20)
            sleep(0.1)
            rednet.send(PhoneID,"Please input the columns of the location.")
            a,Menu3=rednet.receive(nil,20)
            RotateDirection(DirectionHome)
            GoForward()
            GoForward()
            GoDown()
            Quarry(Menu1, Menu2, Menu3)
        elseif Selection == 2 then
            rednet.send(PhoneID,1)
            sleep(0.1)
            rednet.send(PhoneID,"Please enter radius of the mining area.")
            a,Menu1 = rednet.receive(nil,20)
            Miner(Menu1)
        elseif Selection == 3 then
            rednet.send(PhoneID,"digcoords3")
            a,x1=rednet.receive()
            a,y1=rednet.receive()
            a,z1=rednet.receive()
            a,Menu1=rednet.receive(nil,20)
            a,Menu2=rednet.receive(nil,20)
            DigRadius(Menu1,Menu2,x1,y1,z1)
        elseif Selection == 4 then
            rednet.send(PhoneID,"digcoords2")
            sleep(0.1)
            a,x1=rednet.receive()
            a,y1=rednet.receive()
            a,z1=rednet.receive()
            a,x2=rednet.receive()
            a,y2=rednet.receive()
            a,z2=rednet.receive()
            x1=tonumber(x1)
            y1=tonumber(y1)
            z1=tonumber(z1)
            x2=tonumber(x2)
            y2=tonumber(y2)
            z2=tonumber(z2)
            DigCoordinates(x1, x2, y1, y2, z1, z2)
        elseif Selection == 5 then
            rednet.send(PhoneID,"digcoords1")
            a,Menu1=rednet.receive()
            a,Menu2=rednet.receive()
            a,Menu3=rednet.receive()
            NeededFuel = FuelReqForGoingToCoords(Menu1, Menu2, Menu3)
            Refuel()
            GoToCoordinates = FuelReqForGoingToCoords(Menu1,Menu2,Menu3)
        elseif Selection == 6 then
            rednet.send(PhoneID,1)
            sleep(0.1)
            rednet.send("Please enter the fuel amount you want to reach.")
            a,Menu1 = rednet.receive()
            NeededFuel = Menu1 - turtle.getFuelLevel()
            Refuel()
        elseif Selection == 9 then
            os.exit()
        end
    else
        NeededFuel = 0
        term.clear()
        SetHome()
        PrintLine('=')
        print("UMUT TURTLE PROGRAM")
        PrintLine('=')
        print("1- Quarry")
        print("2- Mine")
        term.write("3- Refuel ")
        term.write(turtle.getFuelLevel())
        term.write(" / ")
        term.write(turtle.getFuelLimit())
        term.write(" ")
        ProgressBar((turtle.getFuelLevel() / turtle.getFuelLimit()) * 5, 5)
        print()
        if Calibrated then
            print("4- Dig Pos")
            print("5- New Home")
            print("6- Fill Up Ground")
        else
            print("4- Manual Calibration")
            print("5-")
            print("6- Fill Up Ground")
        end
        PrintLine('-')
        if Output == 0 then
            local asd
            asd = term.getTextColor()
            term.setTextColor(16384)
            print("NO GPS SIGNAL!")
            term.setTextColor(asd)
        elseif Output == 1 then
            local asd
            asd = term.getTextColor()
            term.setTextColor(32)
            print("SUCCESSFULLY CALIBRATED USING GPS!")
            term.setTextColor(asd)
        elseif Output == 2 then
            local asd
            asd = term.getTextColor()
            term.setTextColor(16384)
            print("UNABLE TO CALIBRATE DUE TO BEING BLOCKED!")
            term.setTextColor(asd)
        elseif Output == 3 then
            local asd
            asd = term.getTextColor()
            term.setTextColor(32)
            print("SUCCESSFULLY CALIBRATED USING MANUAL CALIBRATION!")
            term.setTextColor(asd)
        else
            print("UNKNOWN CALIBRATION ERROR!!")
        end
    
    
    
        print("Please input what you want to do:")
        Selection=tonumber(io.read())
    
    
        term.clear()
        if Selection == 1 then
            print("Please input the rows of the location.")
            Menu1 = tonumber(io.read())
            print("Please input the depth of the location.")
            Menu2 = tonumber(io.read())
            print("Please input the columns of the location.")
            Menu3 = tonumber(io.read())
            RotateDirection(DirectionHome)
            if turtle.getFuelLevel()<math.ceil((Menu1*Menu3)*((Menu2/3)+(Menu2%3)))+6 then
                NeededFuel=NeededFuel+math.ceil((Menu1*Menu3)*((Menu2/3)+(Menu2%3)))+6
                Refuel()
            end
            GoForward()
            GoForward()
            GoDown()
            Quarry(Menu1, Menu2, Menu3)
        elseif Selection == 2 then
            print("Please enter radius of the mining area.")
            Menu1 = tonumber(io.read())
            Miner(Menu1)
        elseif Selection == 3 then
            print("Please enter the fuel amount you want to reach.")
            Menu1 = tonumber(io.read())
            NeededFuel = Menu1 - turtle.getFuelLevel()
            Refuel()
        elseif Selection == 4 and Calibrated then
            print("Please input the x coord of the first location.")
            Menu1 = tonumber(io.read())
            print("Please input the y coord of the first location.")
            Menu2 = tonumber(io.read())
            print("Please input the z coord of the first location.")
            Menu3 = tonumber(io.read())
            print("Please input the x coord of the second location.")
            Menu4 = tonumber(io.read())
            print("Please input the y coord of the second location.")
            Menu5 = tonumber(io.read())
            print("Please input the z coord of the second location.")
            Menu6 = tonumber(io.read())
            DigCoordinates(Menu1, Menu4, Menu2, Menu5, Menu3, Menu6)
        elseif Selection == 4 and not Calibrated then
            term.clear()
            print("X:")
            XPos = tonumber(io.read())
            term.clear()
            print("Y:")
            YPos = tonumber(io.read())
            term.clear()
            print("Z:")
            ZPos = tonumber(io.read())
            term.clear()
            print("north,n,-z,1\nwest,w,-x,2\nsouth,s,+z,3\neast,e,+x,0\nDirection:")
            Direction = io.read()
            DirectionText = string.lower(Direction)
            if DirectionText == "north" or DirectionText == "n" or DirectionText == "-z" then
                Direction = 1
            elseif DirectionText == "west" or DirectionText == "w" or DirectionText == "-x" then
                Direction = 2
            elseif DirectionText == "south" or DirectionText == "s" or DirectionText == "+z" then
                Direction = 3
            elseif DirectionText == "east" or DirectionText == "e" or DirectionText == "+x" then
                Direction = 0
            end
            Direction = tonumber(Direction)
            Calibrated = true
            Output = 3
            if YPos == nil or ZPos == nil or XPos == nil or Direction == nil then
                error("\n\nPlease only input numbers. Thanks.", 1)
            end
        elseif Calibrated and Selection == 5 then
            print("Please input the x coordinate of the location.")
            Menu1 = tonumber(io.read())
            print("Please input the y coordinate of the location.")
            Menu2 = tonumber(io.read())
            print("Please input the z coordinate of the location.")
            Menu3 = tonumber(io.read())
            NeededFuel = FuelReqForGoingToCoords(Menu1, Menu2, Menu3)
            Refuel()
            GoToCoordinates(Menu1,Menu2,Menu3)
        elseif Selection == 6 then
            print("Please enter the x width of the area.")
            Menu1 = tonumber(io.read())
            print("Please enter the z width of the area.")
            Menu2 = tonumber(io.read())
            NeededFuel = (Menu1*Menu2)+(((Menu1*Menu2)/640)*(Menu1+Menu2))
            Refuel()
            FillGround(Menu1,Menu2)
        end    
    end
    
end