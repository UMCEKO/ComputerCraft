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
        val=720,
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
    print("Home XYZ:",robo.pos.home.x,"/",robo.pos.home.y,"/",robo.pos.home.z)
    print("XYZ:",robo.pos.current.x,"/",robo.pos.current.y,"/",robo.pos.current.z)
    print("Facing:",robo.pos.current.direction)
    print("Fuel required for returning:",FuelReqForReturning())
    print("Fuel:",turtle.getFuelLevel(),"/",turtle.getFuelLimit())
    print()
    print("Needed Fuel:",robo.fuel.needed)
end


function FinishUp()
    print(1)
    GoToCoordinates(robo.pos.home.x-2,robo.pos.home.y+3,robo.pos.home.z+1)
    DropAllItemsUp()
    GoToCoordinates(robo.pos.home.x-2,robo.pos.home.y+2,robo.pos.home.z+1)
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
    while not turtle.down() do
        if not turtle.digDown() then
            FinishUp()
            error("\n\nEncountered an unbreakable object down below.",2)
        end
    end
    robo.pos.current.y=robo.pos.current.y-1
    DisplayUpdate()
end

function GoUp()
    while not turtle.up() do
        if not turtle.digUp() then
            FinishUp()
            error("\n\nEncountered an unbreakable object down below.",2)
        end
    end
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
    if y<-59 then
        GoToCoordinates(robo.pos.home.x-2,robo.pos.home.y+2,robo.pos.home.z+1)
        error("Way too dangerous to go below Y -59. Returning.",9)
    end
    if math.abs(robo.pos.home.x-robo.pos.current.x)<5 and math.abs(robo.pos.home.z-robo.pos.current.z)<5 then

        if robo.pos.current.x<x then
            RotateDirection(0)
            for i = 1, math.abs(robo.pos.current.x-x), 1 do
                GoForward()
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

        if robo.pos.current.y>y then
            for i = 1, math.abs(robo.pos.current.y-y), 1 do
                GoDown()
            end
        end
        if robo.pos.current.y<y then
            for i = 1, math.abs(robo.pos.current.y-y), 1 do
                GoUp()
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

        if robo.pos.current.x<x then
            RotateDirection(0)
            for i = 1, math.abs(robo.pos.current.x-x), 1 do
                GoForward()
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


function Refuel()
    if ((0.1>turtle.getFuelLevel()/turtle.getFuelLimit() or FuelReqForReturning()*2+MaxMovementWithoutRefueling*2+2>turtle.getFuelLevel()) and robo.fuel.needed~=0) or (robo.pos.current.x==robo.pos.home.x and robo.pos.current.y==robo.pos.home.y and robo.pos.current.z==robo.pos.home.z) then
        local slot
        slot=turtle.getSelectedSlot()
        turtle.select(16)
        local toBeRefueled
        local fuelBefore=turtle.getFuelLevel()
        if robo.fuel.needed>turtle.getFuelLimit() then
            toBeRefueled=turtle.getFuelLimit()-turtle.getFuelLevel()
        else
            toBeRefueled=robo.fuel.needed
        end
        local totalRefueled=toBeRefueled
        robo.fuel.val=720
        toBeRefueled=toBeRefueled-(turtle.getFuelLevel()-fuelBefore)
        local fuelItemCountToBeUsed=math.ceil(toBeRefueled/robo.fuel.val)
        turtle.select(AvailibleSpace())
        while toBeRefueled>0 and turtle.getFuelLevel()~=turtle.getFuelLimit() do
            fuelBefore=turtle.getFuelLevel()
            term.clear()
            print()
            print("Fuel:",totalRefueled-toBeRefueled,"/",totalRefueled)
            print()
            if fuelItemCountToBeUsed>64 then
                local tempBefore=turtle.getFuelLevel()
                turtle.suck(64)
                turtle.refuel(64)
                local fuelUsed=(turtle.getFuelLevel()-tempBefore)/robo.fuel.val
                fuelItemCountToBeUsed=fuelItemCountToBeUsed-fuelUsed
            else
                local tempBefore=turtle.getFuelLevel()
                turtle.suck(fuelItemCountToBeUsed)

                turtle.refuel()
                local fuelUsed=(turtle.getFuelLevel()-tempBefore)/robo.fuel.val
                fuelItemCountToBeUsed=fuelItemCountToBeUsed-fuelUsed
            end
            toBeRefueled=toBeRefueled-(turtle.getFuelLevel()-fuelBefore)
        end
        turtle.select(1)
        robo.fuel.needed=robo.fuel.needed-totalRefueled
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
        if turtle.getItemSpace()==64 then
            x=i
            break
        end
    end
    if x==0 then
        x=1
    end
    return x
end


-- REDNET --






-- MAIN PROGRAMS --


--When i first wrote this code, only god and I knew what I wrote, now only god knows...

function DigCoordinates(x1,x2,y1,y2,z1,z2)
    --mathematical stuff :5head:
    local xwidth=math.abs(x1-x2)+1
    local xmax=math.max(x1,x2)
    local ywidth=math.abs(y1-y2)+1
    local ymax=math.max(y1,y2)
    local zwidth=math.abs(z1-z2)+1
    local zmax=math.max(z1,z2)
    local rotateDir=1
    Quarry(xwidth,ywidth,zwidth,FuelReqForGoingToCoords(xmax,ymax,zmax)*2,xmax,ymax,zmax,rotateDir)
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
    if turtle.getFuelLevel()<(math.ceil((rows*columns)*((depth/3)+(depth%3))))+((math.abs(robo.pos.home.x-gotoX)+math.abs(robo.pos.home.y-gotoY)+math.abs(robo.pos.home.z-gotoZ))*(3+((rows*depth*columns)/400)))+3 then
        robo.fuel.needed=robo.fuel.needed+(math.ceil((rows*columns)*((depth/3)+(depth%3))))+((math.abs(robo.pos.home.x-gotoX)+math.abs(robo.pos.home.y-gotoY)+math.abs(robo.pos.home.z-gotoZ))*(3+((rows*depth*columns)/400)))+3
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
            GoToCoordinates(robo.pos.home.x-2,robo.pos.home.y+3,robo.pos.home.z+1)
            DropAllItemsUp()
            turtle.select(1)
            GotoRefPoint(2)
        end
    end
    if gotoX~=nil and gotoY~=nil and gotoZ~=nil and rotateDir~=nil then
        GoUp()
        GoUp()
        GoUp()
        GoUp()
        GoUp()
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
    GoToCoordinates(robo.pos.home.x-2,robo.pos.home.y+3,robo.pos.home.z+1)
    DropAllItemsUp()
    GoToCoordinates(robo.pos.home.x-2,robo.pos.home.y+2,robo.pos.home.z+1)
end



--CALIBRATING--

term.clear()
print("Initializing...")


-- TURTLE START --
local a,radius,depth,x,y,z,x1,x2,y1,y2,z1,z2
print("1")  
rednet.open("right")
print("2")
rednet.host("asd","asd")
print("3")
redstone.setOutput("back",true)
a,RawMasterData=rednet.receive("RawMasterData")
MasterData=textutils.unserialiseJSON(RawMasterData)
robo.pos.current.x=MasterData.Pos.X
robo.pos.current.y=MasterData.Pos.Y
robo.pos.current.z=MasterData.Pos.Z
robo.pos.current.direction=MasterData.Pos.Dir

if MasterData.Option==1 or MasterData.Option==3 then
    SetHome()
    redstone.setOutput("back",false)
    sleep(0.05)
    rednet.close("right")
    DigRadius(MasterData.DigInfo.radius,MasterData.DigInfo.depth,MasterData.DigInfo.x,MasterData.DigInfo.y,MasterData.DigInfo.z)
elseif MasterData.Option==2 or MasterData.Option==4 then
    SetHome()
    redstone.setOutput("back",false)
    sleep(0.05)
    rednet.close("right")
    DigCoordinates(MasterData.DigInfo.x1,MasterData.DigInfo.x2,MasterData.DigInfo.y1,MasterData.DigInfo.y2,MasterData.DigInfo.z1,MasterData.DigInfo.z2)
end