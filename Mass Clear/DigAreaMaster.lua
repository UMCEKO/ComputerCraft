-- CODE PREP --
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

local robo={
    fuel={
        val=80,
        needed=0
    },
    pos={
        current={
            direction=1,
            x=0,
            y=0,
            z=0
        },
        home={
            direction=1,
            x=0,
            y=0,
            z=0
        }
    }
}

TempX={}
TempY={}
TempZ={}
TempDirection={}
Menu={}


TermWidth, TermHeight=term.getSize()

term.clear()
for i = 1, TermHeight, 1 do
    print()
end


-- The program will take the starting position as the origin.
-- Turtle faces the +Z direction (robo.pos.current.direction 1) from the starting point.

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
    print("Home XYZ:",robo.pos.home.x,"/",robo.pos.home.y,"/",robo.pos.home.z)
    if Calibrated then
        print("XYZ:",robo.pos.current.x,"/",robo.pos.current.y,"/",robo.pos.current.z)
        print("Facing:",robo.pos.current.direction)
    else
        print("Relative XYZ:",robo.pos.current.x,"/",robo.pos.current.y,"/",robo.pos.current.z)
        print("Facing (taking starting direction as north):",robo.pos.current.direction)
    end
    print("Fuel required for returning:",FuelReqForReturning())
    print("Fuel:",turtle.getFuelLevel(),"/",turtle.getFuelLimit())
    ProgressBar((turtle.getFuelLevel()/turtle.getFuelLimit())*20,20)
    print()
    print("Needed Fuel:",robo.fuel.needed)
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
    RotateDirection(robo.pos.home.direction)
end

function GoForward()
    if not Refueling then
        MovementWithoutRefueling=MovementWithoutRefueling+1
    end
    if MovementWithoutRefueling>MaxMovementWithoutRefueling then
        MovementWithoutRefueling=0
        SaveRefPoint(4)
        Refueling=true
        Refuel()
        Refueling=false
        GotoRefPoint(4)
    end
    local i=1
    while turtle.detect() do
        i=i+1
        if turtle.detect() then
            turtle.dig()
        end
        if i>9 then
            if turtle.detect() then
                FinishUp()
                error("\n\nEncountered an unbreakable object.",2)
            end
        end
    end
    turtle.forward()
    if robo.pos.current.direction==0 then
        robo.pos.current.x=robo.pos.current.x+1
    elseif robo.pos.current.direction==1 then
        robo.pos.current.z=robo.pos.current.z-1
    elseif robo.pos.current.direction==2 then
        robo.pos.current.x=robo.pos.current.x-1
    elseif robo.pos.current.direction==3 then
        robo.pos.current.z=robo.pos.current.z+1
    end

    DisplayUpdate()
end

function GoBackwards()
    turtle.back()
    if robo.pos.current.direction==0 then
        robo.pos.current.x=robo.pos.current.x-1
    elseif robo.pos.current.direction==1 then
        robo.pos.current.z=robo.pos.current.z+1
    elseif robo.pos.current.direction==2 then
        robo.pos.current.x=robo.pos.current.x+1
    elseif robo.pos.current.direction==3 then
        robo.pos.current.z=robo.pos.current.z-1
    end
end

function GoDown()
    if not Refueling then
        MovementWithoutRefueling=MovementWithoutRefueling+1
    end
    if MovementWithoutRefueling>MaxMovementWithoutRefueling then
        MovementWithoutRefueling=0
        SaveRefPoint(4)
        Refueling=true
        Refuel()
        Refueling=false
        GotoRefPoint(4)
    end
    if turtle.detectDown() then
        turtle.digDown()
    end
    if turtle.detectDown() then
        FinishUp()
        error("\n\nEncountered an unbreakable object down below.",2)
    end
    turtle.down()
    robo.pos.current.y=robo.pos.current.y-1
    DisplayUpdate()
end

function GoUp()
    if not Refueling then
        MovementWithoutRefueling=MovementWithoutRefueling+1
    end
    if MovementWithoutRefueling>MaxMovementWithoutRefueling then
        MovementWithoutRefueling=0
        SaveRefPoint(4)
        Refueling=true
        Refuel()
        Refueling=false
        GotoRefPoint(4)
    end
    if turtle.detectUp() then
        turtle.digUp()
    end
    if turtle.detectUp() then
        FinishUp()
        error("\n\nEncountered an unbreakable object up.",2)
    end
    turtle.up()
    robo.pos.current.y=robo.pos.current.y+1
    DisplayUpdate()
end

function RotateLeft()
    turtle.turnLeft()
    robo.pos.current.direction=(robo.pos.current.direction+1)%4
end

function RotateRight()
    turtle.turnRight()
    robo.pos.current.direction=(robo.pos.current.direction-1)%4
end

function RotateDirection(desiredDirection)
    if desiredDirection%4==0 then
        if robo.pos.current.direction==1 then
            RotateRight()
        elseif robo.pos.current.direction==2 then
            RotateRight()
            RotateRight()
        elseif robo.pos.current.direction==3 then
            RotateLeft()
        end

    elseif desiredDirection%4==1 then
        if robo.pos.current.direction==0 then
            RotateLeft()
        elseif robo.pos.current.direction==2 then
            RotateRight()
        elseif robo.pos.current.direction==3 then
            RotateLeft()
            RotateLeft()
        end

    elseif desiredDirection%4==2 then
        if robo.pos.current.direction==1 then
            RotateLeft()
        elseif robo.pos.current.direction==0 then
            RotateRight()
            RotateRight()
        elseif robo.pos.current.direction==3 then
            RotateRight()
        end

    elseif desiredDirection%4==3 then
        if robo.pos.current.direction==1 then
            RotateRight()
            RotateRight()
        elseif robo.pos.current.direction==2 then
            RotateLeft()
        elseif robo.pos.current.direction==0 then
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
        turtle.select(i)
        turtle.dropUp(64)
    end
    turtle.select(temp)
end

function DropAllItemsDown()
    term.clear()
    if peripheral.isPresent("bottom") then
        print("Please place a chest below me...")
        repeat
            sleep(1)
        until peripheral.isPresent("top")
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
    return math.abs(robo.pos.home.x-robo.pos.current.x)+math.abs(robo.pos.home.y-robo.pos.current.y)+math.abs(robo.pos.home.z-robo.pos.current.z)
end

function FuelReqForGoingToCoords(x,y,z)
    return math.abs(robo.pos.current.x-x)+math.abs(robo.pos.current.y-y)+math.abs(robo.pos.current.z-z)
end

function GoToCoordinates(x,y,z)
    if x==nil then
        x=robo.pos.current.x
    end
    if y==nil then
        y=robo.pos.current.y
    end
    if z==nil then
        z=robo.pos.current.z
    end
    if y<-59 and Calibrated then
        Home()
        error("Way too dangerous to go below Y -59. Returning.",9)
    end
    robo.fuel.needed=robo.fuel.needed+math.abs(robo.pos.current.x-x)+math.abs(robo.pos.current.y-y)+math.abs(robo.pos.current.z-z)
    Refuel()
    if math.abs(robo.pos.home.x-robo.pos.current.x)<2 and math.abs(robo.pos.home.z-robo.pos.current.z)<2 then




        if robo.pos.current.x>x then
            RotateDirection(2)
            for i = 1, math.abs(robo.pos.current.x-x), 1 do
                GoForward()
            end
        end
        if robo.pos.current.z>z then
            RotateDirection(1)
            for i = 1, math.abs(robo.pos.current.z-z), 1 do
                GoForward()
            end
        end
        
        if robo.pos.current.z<z then
            RotateDirection(3)
            for i = 1, math.abs(robo.pos.current.z-z), 1 do
                GoForward()
            end
        end
        if robo.pos.current.x<x then
            RotateDirection(0)
            for i = 1, math.abs(robo.pos.current.x-x), 1 do
                GoForward()
            end
        end

        if robo.pos.current.y<y then
            for i = 1, math.abs(robo.pos.current.y-y), 1 do
                GoUp()
            end
        end
        if robo.pos.current.y>y then
            for i = 1, math.abs(robo.pos.current.y-y), 1 do
                GoDown()
            end
        end

    else

        if robo.pos.current.y<y then
            for i = 1, math.abs(robo.pos.current.y-y), 1 do
                GoUp()
            end
        end
        if robo.pos.current.y>y then
            for i = 1, math.abs(robo.pos.current.y-y), 1 do
                GoDown()
            end
        end

        if robo.pos.current.x>x then
            RotateDirection(2)
            for i = 1, math.abs(robo.pos.current.x-x), 1 do
                GoForward()
            end
        end
        if robo.pos.current.z>z then
            RotateDirection(1)
            for i = 1, math.abs(robo.pos.current.z-z), 1 do
                GoForward()
            end
        end
        if robo.pos.current.z<z then
            RotateDirection(3)
            for i = 1, math.abs(robo.pos.current.z-z), 1 do
                GoForward()
            end
        end
        if robo.pos.current.x<x then
            RotateDirection(0)
            for i = 1, math.abs(robo.pos.current.x-x), 1 do
                GoForward()
            end
        end


    end

end

function SaveRefPoint(number)
    if number==nil then
        number=0
    end
    TempDirection[number]=robo.pos.current.direction
    TempX[number]=robo.pos.current.x
    TempY[number]=robo.pos.current.y
    TempZ[number]=robo.pos.current.z
end

function GotoRefPoint(number)
    if number==nil then
        number=0
    end
    robo.fuel.needed=robo.fuel.needed+math.abs(TempX[number]-robo.pos.current.x)+math.abs(TempY[number]-robo.pos.current.y)+math.abs(TempZ[number]-robo.pos.current.z)
    Refuel()
    GoToCoordinates(TempX[number],TempY[number],TempZ[number])
    RotateDirection(TempDirection[number])
end

function SetHome()
    robo.pos.home.x=robo.pos.current.x
    robo.pos.home.y=robo.pos.current.y
    robo.pos.home.z=robo.pos.current.z
    robo.pos.home.direction=robo.pos.current.direction
end

function Home()
    GoToCoordinates(robo.pos.home.x,robo.pos.home.y,robo.pos.home.z)
end

function FuelValCalibration()
    local oldVal=turtle.getFuelLevel()
    turtle.select(16)
    turtle.suckUp(1)
    if not turtle.refuel(1) then
        robo.fuel.val=80
        turtle.select(1)
        return false
    end
    turtle.select(1)
    robo.fuel.val=turtle.getFuelLevel()-oldVal
    return true
end

function Refuel()
    if ((0.1>turtle.getFuelLevel()/turtle.getFuelLimit() or FuelReqForReturning()*2+MaxMovementWithoutRefueling*2+2>turtle.getFuelLevel()) and robo.fuel.needed~=0) or (robo.pos.current.x==robo.pos.home.x and robo.pos.current.y==robo.pos.home.y and robo.pos.current.z==robo.pos.home.z) then
        local slot
        slot=turtle.getSelectedSlot()
        turtle.select(16)
        SaveRefPoint(5)
        robo.fuel.needed=robo.fuel.needed+FuelReqForReturning()*2
        local toBeRefueled
        local fuelBefore=turtle.getFuelLevel()
        if robo.fuel.needed>turtle.getFuelLimit() then
            toBeRefueled=turtle.getFuelLimit()-turtle.getFuelLevel()
        else
            toBeRefueled=robo.fuel.needed
        end
        local totalRefueled=toBeRefueled
        Home()
        FuelValCalibration()
        toBeRefueled=toBeRefueled-(turtle.getFuelLevel()-fuelBefore)
        local fuelItemCountToBeUsed=math.ceil(toBeRefueled/robo.fuel.val)
        turtle.select(AvailibleSpace())
        while toBeRefueled>0 and turtle.getFuelLevel()~=turtle.getFuelLimit() do
            fuelBefore=turtle.getFuelLevel()
            term.clear()
            print()
            print("Fuel:",totalRefueled-toBeRefueled,"/",totalRefueled)
            ProgressBar(((totalRefueled-toBeRefueled)/totalRefueled)*20,20)
            print()
            if fuelItemCountToBeUsed>64 then
                local tempBefore=turtle.getFuelLevel()
                turtle.suckUp(64)
                turtle.refuel(64)
                local fuelUsed=(turtle.getFuelLevel()-tempBefore)/robo.fuel.val
                fuelItemCountToBeUsed=fuelItemCountToBeUsed-fuelUsed
            else
                local tempBefore=turtle.getFuelLevel()
                turtle.suckUp(fuelItemCountToBeUsed)
                turtle.refuel(fuelItemCountToBeUsed)
                local fuelUsed=(turtle.getFuelLevel()-tempBefore)/robo.fuel.val
                fuelItemCountToBeUsed=fuelItemCountToBeUsed-fuelUsed
            end
            toBeRefueled=toBeRefueled-(turtle.getFuelLevel()-fuelBefore)
        end
        turtle.select(1)
        robo.fuel.needed=robo.fuel.needed-totalRefueled
        GotoRefPoint(5)
        turtle.select(slot)
    end
end


function GetAvailibleSpaces()--
    local x=0
    for i = 1, 16, 1 do
        if turtle.getItemSpace()==64 then
            x=x+1
        end
    end
    return x
end

function AvailibleSpace()--
    local x=0
    for i = 1, 16, 1 do
        if turtle.getItemSpace(i)==64 then
            x=i
            return x
        end
    end
    return nil
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
    Quarry(xwidth,ywidth,zwidth,FuelReqForGoingToCoords(xmax,ymax,zmax)*2,xmax,ymax,zmax,rotateDir)
    GotoRefPoint(1)
end

function DigRadius(radius,depth,x,y,z)
    x=math.floor(x)
    z=math.floor(z)
    y=math.floor(y)
    DigCoordinates(x+radius,x-radius,y,y-depth+1,z+radius,z-radius)
end

function Quarry(rows,depth,columns,passFuel,gotoX,gotoY,gotoZ,rotateDir) --mines an area taking the top right back corner as the starting point.
    if passFuel==nil then
        passFuel=0
    end
    if turtle.getFuelLevel()<math.ceil((rows*columns)*((depth/3)+(depth%3)))+passFuel then
        robo.fuel.needed=robo.fuel.needed+math.ceil((rows*columns)*((depth/3)+(depth%3)))+3
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
            robo.fuel.needed=robo.fuel.needed+(temp*2)+4
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
    RotateDirection(robo.pos.home.direction)
    local rows=radius+1
    local columns=radius*2+1
    robo.fuel.needed=robo.fuel.needed+(rows*columns)+rows+columns+1
    Refuel()
    for i = 1, columns, 1 do
        for j = 1, rows-1, 1 do
            if turtle.getItemSpace(16)<64 then
                SaveRefPoint(3)
                local temp=FuelReqForReturning()
                Home()
                DropAllItems()
                turtle.select(1)
                robo.fuel.needed=robo.fuel.needed+((rows+columns+temp)*2)/robo.fuel.val
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

function MineAreaWithXTurtles(radius,depth,x,y,z,turtcount)
    turtcount=math.sqrt(turtcount)
    local sidelength=radius*2+1 
    local sideperturtle=sidelength/turtcount
    local radiusperturtle=(sideperturtle-1)/2
    local zturtcenter=z-radius+radiusperturtle
    local xturtcenter=x-radius+radiusperturtle
    local sidecount=sidelength/sideperturtle
    local output=false
    local turtleno=0
    if sidelength%turtcount~=0 or radiusperturtle%1~=0 or turtcount%1~=0 or sidecount%1~=0 then
        print(sidelength .. " " .. turtcount .. " " .. radiusperturtle .. " " .. turtcount .. " " .. sidecount)
        return false
    end
    turtle.select(16)
    for i = 1, sidecount, 1 do
        for k = 1, sidecount, 1 do
            turtleno=turtleno+1
            turtle.suckDown(1)
            print("Placing the turtle no." .. turtleno)
            repeat
                sleep(0.05)
            until turtle.place()
            repeat
                T = peripheral.wrap("front")
            until T
            T.turnOn()
            print("Waiting for the turtle no." .. turtleno .. " to wake up")
            repeat
                os.sleep(0.05)
                output=redstone.getInput("front")
            until output==true

            DataToBeSent={
                Option=PhoneData.Option,
                Pos={
                    X=robo.pos.home.x,
                    Y=robo.pos.home.y,
                    Z=robo.pos.home.z,
                    Dir=robo.pos.current.direction
                },
                DigInfo={
                    radius=radiusperturtle,
                    depth=depth,
                    x=xturtcenter,
                    y=y-2,
                    z=zturtcenter
                }
            }
            RawDataToBeSent=textutils.serialiseJSON(DataToBeSent)

            print("Broadcasting the dig area information to  turtle no." .. turtleno)
            sleep(0.05)
            rednet.broadcast(RawDataToBeSent,"RawMasterData")

            repeat
                os.sleep(0.05)
                output=redstone.getInput("front")
            until output==false
            print("turtle no." .. turtleno .. "is on its way.")
            xturtcenter=xturtcenter+radiusperturtle*2+1
        end
        zturtcenter=zturtcenter+radiusperturtle*2+1
        xturtcenter=x-radius+radiusperturtle
    end
    turtle.select(16)
    print("valid turt count")
end

function MineAreaWithXTurtlesDoubles(x1,y1,z1,x2,y2,z2,turtcount)
    local turtcountperedge=math.sqrt(turtcount)
    local edgelength=math.abs(x2-x1)+1
    local edgeperturt=edgelength/turtcountperedge
    x2=x1+edgeperturt-1
    z2=z1+edgeperturt-1
    local x1perm=x1
    local x2perm=x2
    local output
    local turtleno=0
    --local output=false
    --turtle.select(16)
    for i = 1, turtcountperedge, 1 do
        for k = 1, turtcountperedge, 1 do
            --code
            turtle.suckDown(1)
            turtleno=turtleno+1
            print("Placing the turtle no." .. turtleno)
            repeat
                sleep(0.05)
            until turtle.place()
            repeat
                T = peripheral.wrap("front")
            until T
            T.turnOn()
            print("Waiting for the turtle no." .. turtleno .. " to wake up")
            repeat
                os.sleep(0.05)
                output=redstone.getInput("front")
            until output==true
            print("Broadcasting the dig area information to  turtle no." .. turtleno)

            DataToBeSent={
                Option=PhoneData.Option,
                Pos={
                    X=robo.pos.home.x,
                    Y=robo.pos.home.y,
                    Z=robo.pos.home.z,
                    Dir=robo.pos.current.direction
                },
                DigInfo={
                    x1=x1,
                    y1=y1,
                    z1=z1,
                    x2=x2,
                    y2=y2,
                    z2=z2
                }
            }
            RawDataToBeSent=textutils.serialiseJSON(DataToBeSent)

            sleep(0.05)
            rednet.broadcast(RawDataToBeSent,"RawMasterData")
            repeat
                os.sleep(0.05)
                output=redstone.getInput("front")
            until output==false
            print("turtle no." .. (((i-1)*k)+k) .. "is on its way.")
            x1=x1+edgeperturt
            x2=x2+edgeperturt
        end
        x1=x1perm
        x2=x2perm
        z1=z1+edgeperturt
        z2=z2+edgeperturt
    end
    --turtle.select(16)
    print("valid turt count")
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
            robo.fuel.needed=robo.fuel.needed+2
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
            robo.pos.current.x=x2
            robo.pos.current.y=y2
            robo.pos.current.z=z2
            if x2>x1 then
                robo.pos.current.direction=0
            elseif x1>x2 then
                robo.pos.current.direction=2
            end
            if z2>z1 then
                robo.pos.current.direction=3
            elseif z1>z2 then
                robo.pos.current.direction=1
            end
            calibrating(14)
            SetHome()
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
rednet.open("right")
rednet.open("left")
CalibrateGPS()
-- MASTER START --

rednet.host("M45T3R","DIGAREA")
if robo.pos.current.direction~=0 then
    DisplayUpdate()
    print("Please position the turtle so that it faces the +x (east)")
    error("Wrong way.")
end
local a
while true do

    a , RawPhoneData=rednet.receive("RawPhoneData")
    PhoneData=textutils.unserialiseJSON(RawPhoneData)

    if PhoneData.Option==1 or PhoneData.Option==3 then
        if type(PhoneData.dig.radius)=="number" and type(PhoneData.dig.depth)=="number" and type(PhoneData.dig.x)=="number" and type(PhoneData.dig.y)=="number" and type(PhoneData.dig.z)=="number" and type(PhoneData.turtleCount)=="number" then
            sleep(0.05)
            rednet.send(a , "Successful execution!")
            MineAreaWithXTurtles(PhoneData.dig.radius,PhoneData.dig.depth,PhoneData.dig.x,PhoneData.dig.y,PhoneData.dig.z,PhoneData.turtleCount)
        else
            sleep(0.05)
            rednet.broadcast("ERROR!","ERROR!")
        end
    elseif PhoneData.Option==2 or PhoneData.Option==4 then
        if type(PhoneData.dig.x1)=="number" and type(PhoneData.dig.y1)=="number" and type(PhoneData.dig.z1)=="number" and type(PhoneData.dig.x2)=="number" and type(PhoneData.dig.y2)=="number" and type(PhoneData.dig.z2)=="number" and type(PhoneData.turtleCount)=="number" then
            sleep(0.05)
            rednet.send(a ,"Successful execution!")
            MineAreaWithXTurtlesDoubles(PhoneData.dig.x1,PhoneData.dig.y1,PhoneData.dig.z1,PhoneData.dig.x2,PhoneData.dig.y2,PhoneData.dig.z2,PhoneData.turtleCount)
        else
            sleep(0.05)
            rednet.broadcast("ERROR!","ERROR!")
        end
    else
        print(PhoneData.Option)
    end

end


--rednet.send(a, "ERROR! Details\n X:" .. XDIG .. " type " .. type(XDIG) .. "\nY:" .. YDIG .. " type " .. type(YDIG) .. "\nZ:" .. ZDIG .. " type " .. type(ZDIG) .. "\nRadius:" .. RADIUS .. " type " .. type(RADIUS) .. "\nDepth:" .. DEPTH .. " type " .. type(DEPTH) .. "\nTurtle count:" .. TURTCOUNT .. " type " .. type(TURTCOUNT) )
