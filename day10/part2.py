#!/usr/bin/env python3

from ortools.sat.python import cp_model
import sys 


def main():
    input_path = sys.argv[1] 

    sw = SolverWrapper()

    with open(input_path, 'r') as f:
        print(
            sum(
                map(
                    lambda data: sw.solve(data[0], data[1]), 
                    map(
                        parse_row,
                        list(
                            map(lambda x: x.strip(),
                                f.readlines()
                                )
                            )
                        )
                    )
                )
            )
      


def parse_row(row: str):
    vectors = []
    target  = None

    for elem in reversed(row.split(" ")):
        if elem[0] == "(":
            new_row = [0] * len(target)
            
            for i in [ int(n) for n in elem[1:-1].split(',') ]:
                new_row[i] = 1 
            
            vectors.append(new_row)

        elif elem[0] == "{":
            target = [ int(n) for n in elem[1:-1].split(',') ]

    return vectors, target 


class SolverWrapper():
    solver : cp_model.CpSolver

    def __init__(self):
        self.solver = cp_model.CpSolver()
    
    def solve(self, vectors, target):
        model = cp_model.CpModel()
        N = len(vectors)
        M = len(target)

        xs = [model.NewIntVar(0, 1000, f"x_{i}") for i in range(N)]

        for j in range(M):
            model.Add(sum(vectors[i][j] * xs[i] for i in range(N)) == target[j])
        
        model.Minimize(sum(xs))

        self.solver.Solve(model)

        return sum((self.solver.Value(var) for var in xs))



if __name__ == '__main__':
    main()
