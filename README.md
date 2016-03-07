coursework.hs

It answers the questions about schecdule for a bus stop N, changes for a bus stop N (changes between min and max time),
fastest routes from point A to point B from time T

It must be loaded with 3 files as arguments. If not compliled, the command for loading is:
:main mystops.txt mylines.txt mypositions.txt
The files are loaded once in the beginning (into lists of tuples) and then the lists are used to answer the queries.

Then the commands/queries as an input can be:
1. stopschedule [bus stop number] [distance]
2. changes [bus stop number] [distance] [min time] [max time]
3. fastestroute [bus stop number] [start time] [arrival bus stop number] [distance]

The distance is defined as a rounded square root of a value. Then the result is used to find all possible sets of 
the coordinates (x,y) which suit the defined distance value.
The 3d query is not fully implemented because it only shows the start point and end point without changes.

Errors in a command spelling will be announced. 

In case of any error the program informs it in the format "Caught exception: [error]"

More detailed description of functions in the comments of coursework.hs

