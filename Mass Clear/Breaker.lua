function DropAllItemsDown()
    term.clear()
    local temp=turtle.getSelectedSlot()
    for i = 1, 16, 1 do
        if turtle.getItemCount(i)~=0 then
            turtle.select(i)
            turtle.dropDown(64)
        end
    end
    turtle.select(temp)

end

while true do
    turtle.digUp()
    DropAllItemsDown()
end