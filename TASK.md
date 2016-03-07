The program is to read data file containing bus traffic information and then produce answers about the data. 
The commands / queries come in the standard input, and the program is supposed to produce the output to the standard output. Please note 
that the program’s output should be exactly as required, no extra characters, no extra spaces, commas, etc. Example files will be provided.
There are three data files. One has information about bus stops in the form: stop <stop-number> <x> <y> where <stop-number> is a bus stop 
number, and x and y are positive integer coordinates, e.g. stop 1 998 8765 stop 5 550 8889
For simplicity, you may think of the coordinates as distances in meters from a fixed origin in East and North direction. Thus, coordinate 
point (100,100) would be 100 meters to the East and 100 meters to the North from the origin. The distance between (100,100) and (100,101) 
would be 1 (meter), and the distance between (100,100) and (101,101) would be square root of 2 (meters).
Another file contains information about bus lines: line <line-number> [<stop-number>] [<stop-number>] The line describes information about 
a bus line, saying that a line with number <line-number> consists of the bus first driving (Direction 0) through the first list bus stop 
numbers (starts from the first and finishes at the last) and then (Direction 1) from driving through the second list of bus stop numbers 
the same way. We assume here that there are stops in both lists, and the first list’s last item is the same as the second list’s first item, 
and vica versa. For instance: line 3 [6,7,19,2,55] [55,54,6] line 4 [3,5,6,18,19] [19,21,22,3]
Finally, there is a file that describes positions that have been recorded from buses on the move: 
pos <time> <vehicle-number> <line-number> <direction> <x> <y> meaning that at time <time> (an integer), 
the bus <vehicle-number> (integer) has been on line <line-number> (integer) going on direction <direction> (0 or 1) at position (<x>,<y>) 
where both <x> and <y> are positive integers, marking the coordinates. For instance the first line of the following example data means that at 
time 876 the bus with vehicle id 34 was traveling line 4 on direction 0 at the point 550 8889 (which in fact is by a bus stop for the data above). 
You may think that the file contains one day of traffic and the times are something like seconds from midnight. Each vehicle has a unique id. 
The input is sorted by (time, vehicle-number) in ascending order. Each vehicle-number is unique, so this determines the input order. 
pos 876 34 4 0 550 8889 pos 877 34 4 0 550 8889 pos 878 34 4 0 551 8891

The program should answer the following queries:
stopschedule <stop-no> <dist> The answer contains all bus lines (with times) that have departed from that bus stop, ordered by departure time. 
A bus is considered to have left the bus stop <stop-no> at time <t> if the bus has been at time <t> at the same place for at least 1 second with 
a distance at most <dist> from the bus stop, and then started to move. If there are no departures, output a single line No departures. Else, the 
answer should contain, for each departure, a line: <time> <line-no> where the line contains the integer for the time and the integer for the bus line 
(separated by a simple space). For instance for the query stopschedule 5 2 using the data above, the answer is just one line: 877 4
changes <stop-no> <dist> <min-time> <max-time> The answer contains all possible ways to change a bus at bus stop <stop-no> as follows. The 
departure schedule for a bus stop is supposed to be the one obtained similarly as in query stopschedule <stop-no> <dist> and a change from bus 
line <n1> to bus line <n2> should appear in the answer, if the time-distance between arrival of a bus of line <n1> and departure of a bus of line 
<n2> is at least <min-time> and at most <max-time> and the arrival was before departure. Notice that the stopschedule only includes departures – 
you should similarly calculate also arrivals. Each change should be given in the form <arr-time> <n1> <depart-time> <n2>, e.g. 
(not related to the data above: 8760 3 8777 4 If there are no acceptable bus changes, then output a single line No changes
fastestroute <depart-stop> <start-time> <arr-stop> <dist> Calculate the fastest way to arrive to <arr-stop> from <depart-stop> starting your 
journey at <start-time>. The previous queries’ implementations should help you considerably in solving this. The <dist> parameter is used in 
calculations to figure out when a bus has stopped at a bus stop, like before. If there is no acceptable route, then you should output a single 
line “No route”. Else the output should be such that in the first line there is the first departure time and line, and in the last line there is 
the last arrival time and line. All lines between describe the necessary bus changes, in the order they are to be taken, containing 
<stop-no> <arr-time> <n1> <depart-time> <n2>, where <stop-no> is the bus stop for the change and the rest are as in changes. 
567 2 5 587 2 599 3 663 5
When your program is started, it is given the filenames as arguments – first the bus stop file, then the bus line file, and finally the bus 
position file, e.g. mycoursework mystops.txt mylines.txt mypositions.txt
If your program does not answer according to the instructions, it will be penalized in marking – however it does not need to answer all the 
queries correctly to be accepted. If it does not know how to answer a query, then it should print out a single line saying: Not implemented
