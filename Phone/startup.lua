
rednet.open("back")
rednet.host("activation","UmutPhone")

function RedStart()
    local WorkerID,message,menu,a,optioncount,x,y,z
    print("Looking for computer...")
    WorkerID=rednet.receive("activation") --
    print("Got a request to connect, sending confirmation.")
    sleep(0.10)
    rednet.send(WorkerID,"Done") --
    print("Sent confirmation to:" .. WorkerID)
    a,menu=rednet.receive("Menu")
    print(menu)
    Selection=tonumber(io.read())
    sleep(0.10)
    rednet.send(WorkerID,Selection,"answer")
    a,optioncount=rednet.receive()
    
    if optioncount=="digcoords1" then
        print("Please go to the location and press enter.")
        io.read()
        x,y,z=gps.locate()
        x=math.floor(x)
        y=math.floor(y)-1
        z=math.floor(z)
        sleep(0.10)
        rednet.send(WorkerID,x)
        sleep(0.10)
        rednet.send(WorkerID,y)
        sleep(0.10)
        rednet.send(WorkerID,z)
        return
    end
    if optioncount=="digcoords2" then
        print("Please go to the first location and press enter.")
        io.read()
        x,y,z=gps.locate()
        x=math.floor(x)
        y=math.floor(y)-1
        z=math.floor(z)
        sleep(0.10)
        rednet.send(WorkerID,x)
        sleep(0.10)
        rednet.send(WorkerID,y)
        sleep(0.10)
        rednet.send(WorkerID,z)
        print("Please go to the second location and press enter.")
        io.read()
        x,y,z=gps.locate()
        x=math.floor(x)
        y=math.floor(y)-1
        z=math.floor(z)
        sleep(0.10)
        rednet.send(WorkerID,x)
        sleep(0.10)
        rednet.send(WorkerID,y)
        sleep(0.10)
        rednet.send(WorkerID,z)
        return
    end
    if optioncount=="digcoords3" then
        x,y,z=gps.locate()
        x=math.floor(x)
        y=math.floor(y)-1
        z=math.floor(z)
        print("The turtle will mine, taking the center as XYZ:" .. x .. "/" .. y .. "/" .. z)
        sleep(0.10)
        rednet.send(WorkerID,x)
        sleep(0.10)
        rednet.send(WorkerID,y)
        sleep(0.10)
        rednet.send(WorkerID,z)
        print("Please input the radius of the area you want to get mined.")
        message=tonumber(io.read())
        sleep(0.10)
        rednet.send(WorkerID,message)
        print(message)
        print("Please input the depth of the area you want to get mined.")
        message=tonumber(io.read())
        sleep(0.10)
        rednet.send(WorkerID,message)
        return
    end
    print(optioncount)
    optioncount=tonumber(optioncount)
    print(optioncount)
    if type(optioncount)~="number" then
        print(optioncount)
        error("wtf",1)
    end
    for i = 1, optioncount, 1 do
        a,message=rednet.receive()
        print(message)
        message=tonumber(io.read())
        sleep(0.10)
        rednet.send(WorkerID,message)
    end
end




while true do
    RedStart()
end

