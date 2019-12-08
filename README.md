# How To Run

### First, get to the place where you downloaded this folder.
### Second, use the following command lines to test each of those.
main instance we used to test (4 by 4 grid, 2 robots, 2 pickingstations, 5 shelves, 3 products, 5 orders)
```sh
clingo src/iclingo.lp simpleInstances/inst2.lp src/solver.lp
```
visualization of inst2.lp: (make sure the test computer has python and cv2, numpy, etc. packages)
```sh
python plot/plot_grid.py
```
the 4 by 4 example that shows in the report is:
```sh
clingo src/iclingo.lp hardInstances/4*4.lp src/solver.lp
```
