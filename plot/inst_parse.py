from collections import defaultdict

class Instance(object):
    def __init__(self, inst_file=None):
        self.obj_map = {'highway':[], 'pickingStation':[],
                        'robot':[], 'shelf':[]
                        }
        self.var_map = {'product':[], 'order':[]}
        # self.obj_offset = {}
                        # 'order':[]}
        self.name = inst_file.split('/')[-1]
        self.inst_file = inst_file
        self.parse()

        self.prd_on_shelf()
        self.prd_on_pick()

        print(self.shape)
        print(self.obj_map)
    
    def parse(self):
        nxn_line = None
        with open(self.inst_file) as f:
            for line in f:
                if '%' in line:
                    continue
                if 'node' in line:
                    nxn_line = line
                segs = line.split(',')
                for obj in self.obj_map:

                    if obj in segs[0]:
                        # pos = line[-8:-5].split(',')
                        pos = line.split(')')[-4].split('(')[-1]
                        pos = pos.split(',')
                        # .split(',')
                        # print(pos, obj, line)
                        self.obj_map[obj].append(
                            [int(pos[0]), int(pos[1])])
                if 'product' in segs[0]:
                    prod_id = segs[1].split(')')[0]
                    pair = line.split(')')[-4].split('(')[-1].split(',')
                    # print(prod_id)
                    # print(pair)
                    self.var_map['product'].append(
                        [int(prod_id), int(pair[0]), int(pair[1])])
                if 'order' in segs[0]:
                    ord_id = segs[1].split(')')[0]
                    pair = None
                    if 'pickingStation' in line:
                        pst_id = segs[-1][:-4]
                    elif 'line' in line:
                        pair = line.split(')')[-4].split('(')[-1].split(',')
                    print(pst_id)
                    print(pair)
                    if pair:
                        self.var_map['order'].append(
                            [int(ord_id), int(pst_id), int(pair[0]), int(pair[1])])
                


        shape = nxn_line.split(')')[-4].split('(')[-1].split(',')
        self.shape = [int(shape[0]), int(shape[1])]

    def prd_on_shelf(self):
        self.shelf_prd_map = defaultdict(list)
        for prod_item in self.var_map['product']:
            self.shelf_prd_map[prod_item[1]].append([prod_item[0], prod_item[2]])
        
        for k, v in self.shelf_prd_map.items():
            self.shelf_prd_map[k]= sorted(v, key=lambda x: x[0])
        
    def prd_on_pick(self):
        self.pick_prd_map = defaultdict(list)
        for prod_item in self.var_map['order']:
            self.pick_prd_map[prod_item[1]].append([prod_item[2], prod_item[3]])
        
        for k, v in self.pick_prd_map.items():
            self.pick_prd_map[k]= sorted(v, key=lambda x: x[0])




if __name__ == "__main__":
    # inst_file= './simpleInstances/inst1.lp'
    inst_file= './simpleInstances/inst6.lp'

    inst = Instance(inst_file)
    print(inst.shape)
    print(inst.obj_map)