import numpy as np

import json
import ga_utils
import csv
import sys

def create_obj_map(ga_params, seed_params_file):
    ga_params = ga_utils.create_parameters(ga_params)
    gap = {}
    for p in ga_params:
        gap[p.name] = p

    obj_map = {}
    with open(seed_params_file) as f_in:
        reader = csv.reader(f_in)
        header = next(reader)
        for row in reader:
            vals = []
            d = dict(zip(header,row))
            for k,v in gap.items():
                vals.append(v.parse(d[k]))
            
            obj_val = float(d['obj.val'])
            if obj_val != -1:
                obj_map[tuple(vals)] = obj_val
    
    return obj_map


def mutate(ga_params, params_file):
    ga_params = ga_utils.create_parameters(ga_params)
    gap = {}
    for p in ga_params:
        gap[p.name] = p

    lines = []
    with open(params_file) as f_in:
        reader = csv.reader(f_in)
        header = next(reader)
        for row in reader:
            d = dict(zip(header,row))
            line = []
            for k,v in gap.items():
                mut_v = v.mutate(v.parse(d[k]), mu=0, indpb=0.2)
                line.append(mut_v)
            line.append(-1)

            lines.append(line)
    
    with open('mut_params.csv', 'w') as f_out:
        writer = csv.writer(f_out)
        writer.writerow([x for x in gap.keys()] + ['obj.val'])
        writer.writerows(lines)

if __name__ == "__main__":
    create_obj_map(sys.argv[1], sys.argv[2])
