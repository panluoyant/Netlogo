# Powder Game
pure patch construction (only the scope display uses a turtle) 

### latest changes: display all elements and their details with user-message, you can choose to place elements in user-message, disable skin and background music ( "net" reserved), detail adjustment, optimization

### Existing elements and their parameters: 
- Air: Not fixed, gas, density 1.29kg/m³, color 0
- Powder: Not fixed, solid, density 900kg/m³, color 36
- Water: Not fixed, liquid, density 1000kg/m³, color blue
- Ice: Fixed, Solid, Density 900kg/m³, Color 98
- Snow: Not Fixed, Solid, Density 500kg/m³, Color 9.9 
- Water Vapor: Not fixed, Gas, Density 1kg/m³, Color 8
- Flammable Gas: Not fixed, Gas, Density 0.74kg/m³, Color 7
- Oil: Not fixed, liquid, density 900kg/m³, color 11
- Fire: Not fixed, solid, density 1kg/m³, color red
- Magma : Not fixed, liquid, density 2000kg/m³, color orange 
- Stone: Not fixed, solid, density 2200kg/m³, color 4
- Salt : Not fixed, solid, density 800kg/m³, color 9
- Brine: Not fixed, liquid, density 1030kg/m³, color sky
- Steel : Fixed, Solid, Density 7800kg/m³, Color 2
- Wood: Fixed, Solid, Density 500kg/m³, Color 34
- Seed: Fixed, solid, density 800kg/m³, color 54
- Acid: Not fixed, liquid, density 1840kg/m³, color 57
- Mercury: Not fixed, liquid, density 13600kg/m³, color 6
- Torch: Fixed, solid, density 99999kg/m³, color 27 
- Spark: Not fixed, gas, density 1.28kg/m³, color 44 
- Fuse: Fixed, solid, density 99999kg/m³, color 32
- Clone: Fixed, Solid, Density 99999kg/m³, Color 35
- Wall: Fixed, Solid, Density 99999kg/m³, Color 5

#### tips:
The density is to try to refer to the moving speed of the elements in reality (random range) is proportional to the density difference. 
The melting speed of steel and mercury in magma is 1/5 of that of stone. 
When seeds encounter water and powder at the same time It will sprout.
Don't let the element cycle fall! This will be very stuck! 
The saved archive is in the data format of Netlogo world, so you can import the saved archive through import-a:world. 
The saved archive is only temporarily saved. 
If you need to exit the experiment, you can save the entire experiment to a local archive/export the archive to txt. 
The import archive is used Turtle universe 1.1.9 new compatible fetch, so older versions are not available.
