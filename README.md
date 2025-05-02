Provides 2 main programs that do the following.

# Standalone
### Turtle:
- Able to dig a specific area, fill a specific area and dig between coordinates in a square shape.
- Returns to home to refuel when fuel is low
- Returns to home to empty out items when inventory is full

# Master-Servant architecture:
## MassClear: 
### Breaker: 
Breaks the block in front of it and puts it in the chest at the bottom. Used for retrieving the servants on the job completion. Master gives the coordinates to the breaker for turtles to go to the front of the breaker and make themselves be retrieved.
### DigAreaMaster:
Master turtle, manages all of the slaves and calculates and then loads the slaves with their own piece of work based on the information recieved from the portable terminal. This is so that the turtles do not get in each others way and can parralelize the work to finish it fast.
### Drop & DropUp:
Test scripts.
### MassClear:
Used for remote instruction passing.
### startup.lua:
The code to be loaded into the slaves. This can do the same things as standalone turtle but there are quite a few extra features, i do not remember them all.
