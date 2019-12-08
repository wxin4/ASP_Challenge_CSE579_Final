# coding=utf-8

import cv2
import numpy as np 
from inst_parse import Instance

class Grid(object):
    def __init__(self, size=(300,300), inst=None):
        self.size = size
        self.inst = inst
        self.obj_color = {'highway':[0,0,255], 'pickingStation':[255,0,0],
                        'robot':[0,255,0], 'shelf':[0,255,255]}
        
        self.obj_scale = {'highway':1.8, 'pickingStation':1.5, 'shelf':1.0
                         }
        
        # self.var_text = {'product':0.8, 'order':1}
    
    # def make_objs(self):

    
    def draw(self):
        self.canvas = np.ones((self.size[0],self.size[1],3),dtype='uint8')*255
        # draw grids
        line_width = 5

        grid_size = [self.size[0]//self.inst.shape[0], 
                    self.size[1]//self.inst.shape[1]]

        for i in range(line_width):
            self.canvas[i::grid_size[0],:] = (0,0,0)
            self.canvas[:, i::grid_size[1]] = (0,0,0)

        self.canvas = np.concatenate((self.canvas, np.zeros((self.size[0],line_width,3)) ), axis=1)
        self.canvas = np.concatenate((self.canvas, np.zeros((line_width, self.size[0]+line_width,3)) ), axis=0)
        
        # draw objects
        # for obj, instances in self.inst.obj_map.items():
        for obj in ['highway', 'pickingStation', 
                                'shelf', 'robot']:
            instances = self.inst.obj_map[obj]
            print(obj, instances)
            color = self.obj_color[obj]
            for idx, i in enumerate(instances):
                center = [grid_size[d]//2 + (i[d]-1)*grid_size[d] for d in [0,1]]
                print(obj, i, center)
                if obj == 'robot':
                    # print(obj, i, 'isdfsf')
                    ## make circle.
                    radius = grid_size[0]//4
                    self.canvas = cv2.circle(self.canvas, tuple(center), radius, color, -1)
                    # cv2.imshow('image',self.canvas)
                    # cv2.waitKey(0)

                else:
                    size = int(grid_size[0]//4 * self.obj_scale[obj])
                    self.canvas = cv2.rectangle(self.canvas, 
                        (center[0]-size, center[1]-size), 
                        (center[0]+size, center[1]+size), color, cv2.FILLED)
                    # if obj == 'shelf':
                    #     prds = self.inst.shelf_prd_map[idx+1]
                    #     print(prds, idx+1, 'shelf')
                    #     step_y = grid_size[0]//4
                    #     start_y = center[0] - step_y
                    #     start_x = center[1] - step_y
                    #     for pi, prd in enumerate(prds):
                    #         text = '{}:{}/u'.format(prd[0], prd[1])
                    #         self.canvas = cv2.putText(self.canvas, text, 
                    #                 (start_x, start_y + pi*step_y), cv2.FONT_HERSHEY_SIMPLEX,
                    #                     0.5, (0, 0, 0), 2, cv2.LINE_AA)

                    # cv2.imshow('image',self.canvas)
                    # cv2.waitKey(0)
        for obj in ['shelf', 'pickingStation']:
            instances = self.inst.obj_map[obj]
            for idx, i in enumerate(instances):
                center = [grid_size[d]//2 + (i[d]-1)*grid_size[d] for d in [0,1]]

                size = int(grid_size[0]//4 * self.obj_scale[obj])

                if obj == 'shelf':
                    prds = self.inst.shelf_prd_map[idx+1]
                    print(prds, idx+1, 'shelf')
                    step_y = grid_size[0]//4
                    start_y = center[0] - step_y
                    start_x = center[1] - step_y
                    for pi, prd in enumerate(prds):
                        text = '{}:{}/u'.format(prd[0], prd[1])
                        self.canvas = cv2.putText(self.canvas, text, 
                                (start_x, start_y + pi*step_y), cv2.FONT_HERSHEY_SIMPLEX,
                                    0.5, (0, 0, 0), 2, cv2.LINE_AA)
                
                if obj == 'pickingStation':
                    prds = self.inst.pick_prd_map[idx+1]
                    step_y = grid_size[0]//4
                    start_y = center[0] - step_y
                    start_x = center[1] - step_y

                    for pi, prd in enumerate(prds):
                        text = '{}:{}/u'.format(prd[0], prd[1])
                        self.canvas = cv2.putText(self.canvas, text, 
                                (start_x, start_y + pi*step_y), cv2.FONT_HERSHEY_SIMPLEX,
                                    0.5, (0, 0, 0), 2, cv2.LINE_AA)

                # cv2.imshow('image',self.canvas)
                # cv2.waitKey(0)

        # cv2.imshow(self.inst.name,self.canvas)
        # cv2.waitKey(0)
    def save_img(self):
        self.canvas = np.concatenate(
            (np.ones((30, self.canvas.shape[0],3),dtype='uint8')*255, self.canvas), axis=0)

        self.canvas = cv2.putText(self.canvas, self.inst.name, 
                                (self.canvas.shape[1]//2-30, 20), cv2.FONT_HERSHEY_SIMPLEX,
                                    0.5, (0, 0, 0), 1, cv2.LINE_AA)
        cv2.imwrite('{}.jpg'.format(self.inst.name), self.canvas)

if __name__ == "__main__":
    insts = ['./simpleInstances/inst{}.lp'.format(i) for i in range(1,9)]

    inst = Instance('./simpleInstances/inst1.lp')
    # inst = Instance('./simpleInstances/inst2.lp')
    # inst = Instance('./hardInstances/hard1.lp')
    # inst = Instanåce('./hardInstances/hard2.lp')
    grid = Grid(inst=inst, size=(300,300))
    # grid = Grid(inst=inst, size=(1000,1000))
    grid.draw()

    for i in insts:
        inst = Instance(i)
        grid = Grid(inst=inst, size=(300,300))
        grid.draw()
        grid.save_img()


