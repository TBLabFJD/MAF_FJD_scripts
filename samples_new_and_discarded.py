# -*- coding: utf-8 -*-
"""
Created on Fri Mar 26 19:37:16 2021

@author: gonza
"""

import argparse



def main():

    # Arguments
    parser = argparse.ArgumentParser(description="Get two list of duplicate samples depending if they are new or discarded")
    parser.add_argument('-d', '--discarded', help='\t\t List of discarded samples by relatness', required=False)
    parser.add_argument('-u', '--duplicates', help='\t\t List of duplicate samples in the new batch', required=False)
    parser.add_argument('-o', '--discardedout', help='\t\t List of duplicate discarded sample', required=False)
    parser.add_argument('-n', '--newout', help='\t\t List of duplicate new sample', required=False)  
    args = parser.parse_args()


    with open(args.discarded) as f:
        discarded = f.read().splitlines()
        
    with open(args.duplicates) as f:
        duplicates = f.read().splitlines()

    discarded = set(discarded)
    duplicates = set(duplicates)
    duplicates = set(["dUpTaGgG" + i for i in duplicates])
    
    discardedout = list(duplicates.intersection(discarded))
    newout = list(duplicates-discarded)


    f=open(args.discardedout,'w')
    for muestra in discardedout:
        f.write(muestra+'\n')
    f.close()


    f=open(args.newout,'w')
    for muestra in newout:
        f.write(muestra+'\n')
    f.close()





if __name__ == "__main__":
    main()
    
    
