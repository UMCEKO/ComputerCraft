

function RollClosest(x)
    if x%1>0.5 then
        return math.ceil(x)
    else
        return math.floor(x)
    end
end


rednet.open("back")

IP=rednet.lookup("M45T3R")

print(IP)

local x,y,z,radius,depth,count,a,message,x1,x2,y1,y2,z1,z2
x,y,z=gps.locate()
print(x)
print(y)
print(z)
while true do
    print("Please input the edge length of the area you want to dig.")
    radius=tonumber(io.read())
    if radius%2==1 then

        DataToBeSent={
            Option=1,
            dig={
                radius=(radius-1)/2,
                x=x,
                y=y,
                z=z,
            },
        }

        print("Please input the depth of the area you want to dig.")
        DataToBeSent.dig.depth=tonumber(io.read())

        TurtlePossibleVals="Possible values: 1"
        for i = 2, 2*DataToBeSent.dig.radius, 1 do
            local b=i*i
            if (2*DataToBeSent.dig.radius+1)%i==0 then
                TurtlePossibleVals=TurtlePossibleVals .. ", " .. b
            end
        end
        print("Availible Values:")
        print(TurtlePossibleVals)
        print("Please input the turtle count:")
        DataToBeSent.turtleCount=tonumber(io.read())

        RawDataToBeSent=textutils.serialiseJSON(DataToBeSent)
        rednet.send(IP,RawDataToBeSent,"RawPhoneData")

        a,message=rednet.receive("ERROR!",1)
        if a then
            print(message)
            break
        end
        break
    elseif radius%2==0 then

        DataToBeSent={
            Option=2,
            dig={}
        }

        --rednet.send(IP,2,"OPTION")
        x=RollClosest(x)
        z=RollClosest(z)
        y=math.floor(y)
        DataToBeSent.dig.x1=x-(radius/2)
        DataToBeSent.dig.x2=x+(radius/2)-1
        DataToBeSent.dig.z1=z-(radius/2)
        DataToBeSent.dig.z2=z+(radius/2)-1
        print(DataToBeSent.dig.x1,DataToBeSent.dig.z1,DataToBeSent.dig.x2,DataToBeSent.dig.z2,RollClosest(x),RollClosest(z))
        print("Please input the depth of the area you want to dig.")
        depth=tonumber(io.read())
        y=math.floor(y)
        DataToBeSent.dig.y1=y-2
        DataToBeSent.dig.y2=(y-2)-depth+1
        TurtlePossibleVals="Possible values: 1"
        for i = 2, math.abs(DataToBeSent.dig.x2-DataToBeSent.dig.x1), 1 do
            if (math.abs(DataToBeSent.dig.x2-DataToBeSent.dig.x1)+1)%i==0 then
                TurtlePossibleVals=TurtlePossibleVals .. ", " .. i*i
            end
        end
        print("Availible Values:")
        print(TurtlePossibleVals)
        print("Please input the turtle count:")
        DataToBeSent.turtleCount=tonumber(io.read())
        RawDataToBeSent=textutils.serialiseJSON(DataToBeSent)
        rednet.send(IP,RawDataToBeSent,"RawPhoneData")

        a,message=rednet.receive("ERROR!",1)
        if a then
            print(message)
            break
        end
        break
    end
end
