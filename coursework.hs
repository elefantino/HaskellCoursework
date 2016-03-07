import System.Environment
import System.IO
import Control.Exception.Base
import Data.List


--helping functions


--extracting elements of tuples since standard functions are implemented only for 2-elements tuples
tByIndex n (a,b,c) 
	|n==0 = a
	|n==1 = b
	|otherwise = c

--delete duplicates from the list of busstops in the route
deldups [] = []
deldups (x:xs) = if x `elem` xs then deldups xs	else x : deldups xs

--convert a list of strings into a list of tuples
convertToListTuples1 :: [[Char]] -> [(Int, Int, Int)]
convertToListTuples1 [] = []
convertToListTuples1 (x:xs) = (read(a!!1)::Int, read(a!!2)::Int, read(a!!3)::Int) : convertToListTuples1 xs
		where a = words x

convertToListTuples2 :: [[Char]] -> [(Int,[Int])]
convertToListTuples2 [] = []
convertToListTuples2 (x:xs) = (read(a!!1)::Int, head route : deldups route) : convertToListTuples2 xs
		where a = words x
		      route = (read(a!!2)::[Int]) ++ (read(a!!3)::[Int])

convertToListTuples3 :: [[Char]] -> [(Int, Int, Int, Int, Int, Int)]
convertToListTuples3 [] = []
convertToListTuples3 (x:xs) = (read(a!!1)::Int, read(a!!2)::Int, read(a!!3)::Int, read(a!!4)::Int, read(a!!5)::Int, read(a!!6)::Int) : convertToListTuples3 xs
		where a = words x

--find coordinates by StopNumber
findStopCoordinates s [] = []
findStopCoordinates s ss = [(x,y) | (n,x,y) <- ss, n==s]
findStopCoordinatesD d [] = []
findStopCoordinatesD d ss = [(xd,yd) | (x,y) <- ss, xd <- [x-d..x+d], yd <- [y-d..y+d]]
--find position by coordinates
findPos [] _ = []
findPos _ [] = []
findPos ss ps = [(t,l,v) | (x1,y1) <- ss, (t,v,l,dir,x2,y2) <- ps, x1==x2, y1==y2]
--find positions (t,l,v) in the third file by StopN and Dist, sort by time
findPosByStopAndDist s d l1 l3 = sort $ findPos (findStopCoordinatesD (round(sqrt(fromIntegral d))) (findStopCoordinates s l1)) l3

--find the departures (exclude waiting time on the bus stop)
--if we don't care of the time, t=0; otherwise we begin with time t (for the 3d query)
departures :: (Num a, Ord a) => [(a, a, a)] -> a -> [(a, a)]
departures [] _ = []
departures ((t1,l1,v1):xs) 0 	  
	|length xs==0 = (t1,l1) : departures xs 0            					--the last element 
	|l1==l2 && v1==v2 && abs(t2-t1)<2 = departures xs 0 					--stop: 1 second or more for 1 vehicle
	|otherwise = (t1,l1) : departures xs 0
		where (t2,l2,v2) = (tByIndex 0 (xs!!0), tByIndex 1 (xs!!0), tByIndex 2 (xs!!0)) --for comparison with the next element
departures ((t1,l1,v1):xs) t 	  
	|t>t1 = departures xs t 	
	|length xs==0 = (t1,l1) : departures xs t 	
	|l1==l2 && v1==v2 && abs(t2-t1)<2 = departures xs t 	
	|otherwise = (t1,l1) : departures xs t
		where (t2,l2,v2) = (tByIndex 0 (xs!!0), tByIndex 1 (xs!!0), tByIndex 2 (xs!!0)) 
arrivals :: (Num a, Ord a) => [(a, a, a)] -> a -> [(a, a)]
arrivals [] _ = []
arrivals xs t = reverse $ departures (reverse xs) t

--printing functions
depPrint [] = []
depPrint xs = [(show a)++" "++(show b) | (a,b) <- xs] 
chPrint [] = []
chPrint xs = [(show a)++" "++(show b) ++" "++(show c) ++" "++(show d) | (a,b,c,d) <- xs]

--functions for the 3d query
findNextStop _ [] = 0
findNextStop s (x:xs)
	|length xs == 0 = x
	|x == s = head xs
	|otherwise =  findNextStop s xs
nsThisLine l s l2 = findNextStop s (findLine l2 l)
findLine [] _ = []
findLine ((line,r):l2) l = if l == line then r else findLine l2 l 

--Go to the next node, compare with the destination (main working function to find routes to the destination):
--if it is the destination, stop
--if not, remember the node and go to the next node. 
--When reach the node visited, stop. 
--Result = [(departure time, departure line),(arrival time, arrival line)]
nextNode s t arr d l1 l2 l3 _ visitednodes foundroutes [] = []
nextNode s t arr d l1 l2 l3 line visitednodes foundroutes startpoints 	
	|length atal == 0 || length dtdl == 0 = foundroutes 		
	|ns == arr = (take 1 startpoints) ++ atal ++ foundroutes
	|ns `elem` visitednodes = foundroutes
	|otherwise = nextNode ns atime arr d l1 l2 l3 aline (ns:visitednodes) foundroutes startpoints 
		where dtdl = take 1 $ filter (\(x,y) -> y==line) (departures (findPosByStopAndDist s d l1 l3) t)
		      [(dtime,dline)] = dtdl		--departure time and line
	              --[(stime,_)] = take 1 startpoints
		      ns = nsThisLine dline s l2 	--next bus stop
		      atal = take 1 $ filter (\(x,y) -> y==dline) (arrivals (findPosByStopAndDist ns d l1 l3) dtime)
		      [(atime,aline)] = atal		--arrival time and line
		       

--find all direct unique routes departing from time t on busstop s to busstop arr
directRoute s t arr d l1 l2 l3 [] = []
directRoute s t arr d l1 l2 l3 (x:startpoints) 
	|length nn == 0 = directRoute s t arr d l1 l2 l3 startpoints
	|otherwise = nn : directRoute s t arr d l1 l2 l3 startpoints
		where (_,l) = x
		      nn = nextNode s t arr d l1 l2 l3 l [] [] [x]

--select the minimum arrival time
directRouteFastest [] = []
directRouteFastest (r:rx)
	|length rx == 0 = r 
	|t1 < t2 = r
	|otherwise = m
	where [(_,_),(t1,_)] = r 
	      m = directRouteFastest rx	
	      [(_,_),(t2,_)] = m      

--select first unique lines (look above)
uniqueLines :: Eq t1 => [t1] -> [(t, t1)] -> [(t, t1)]
uniqueLines _ [] = []
uniqueLines lines ((t,l):xs) = if l `elem` lines then uniqueLines lines xs else (t,l) : uniqueLines (l:lines) xs		      


--main functions


-- 1. stopschedule stopN dist
f1 s d l1 l2 l3 = if f == [] then "No departures\n" else unlines f 
	where deps = departures (findPosByStopAndDist s d l1 l3) 0 
	      f = depPrint deps 

--2. changes stopN dist mintime maxtime
f2 s d mint maxt l1 l2 l3 = if ch == [] then "No changes\n" else unlines ch 
	where xs = findPosByStopAndDist s d l1 l3 
	      fd = departures xs 0
	      fa = arrivals xs 0
	      ch = chPrint [(at,al,dt,dl) | (at,al) <- fa, (dt,dl) <- fd, dt<=maxt, dt>=mint, at<=maxt, at>=mint, at<dt, al/=dl]

--3. fastestroute depStopN time arrStopN dist 
--eg fastestroute 5 870 19 1
f3 s t arr d l1 l2 l3 = if f == [] then "No route\n" else unlines f 
	where startpoints = uniqueLines [] $ departures (findPosByStopAndDist s d l1 l3) t
	      --nextstop1 = nextNode s t arr d l1 l2 l3 [] [] startpoints
	      nextstop = directRouteFastest $ directRoute s t arr d l1 l2 l3 startpoints
	      f = depPrint nextstop
	      	      	      

--output


doIt ("stopschedule":s:d:_) l1 l2 l3 = do
	let x = f1 (read s::Int) (read d::Int) l1 l2 l3
	putStrLn x
	doCommand l1 l2 l3
doIt ("changes":s:d:mint:maxt:_) l1 l2 l3 = do
	let x = f2 (read s::Int) (read d::Int) (read mint::Int) (read maxt::Int) l1 l2 l3
	putStrLn x
	doCommand l1 l2 l3
doIt ("fastestroute":depstop:startt:arrstop:d:_) l1 l2 l3 = do
	let x = f3 (read depstop::Int) (read startt::Int) (read arrstop::Int) (read d::Int) l1 l2 l3
	putStrLn x
	doCommand l1 l2 l3
doIt c l1 l2 l3 = do
	putStrLn $ "Unrecognised or incomplete command\n"
	doCommand l1 l2 l3


-- process input and error handling


doCommand l1 l2 l3 = do
	command <- getLine
	doIt (words command) l1 l2 l3

-- if not compiled, start with the command :main mystops.txt mylines.txt mypositions.txt
-- handler processes possible errors in input
main = toTry `catch` handler  
            
toTry :: IO ()  
toTry = do
	(f1:f2:f3:_) <- getArgs
	handle1 <- openFile f1 ReadMode
	content1 <- hGetContents handle1
	handle2 <- openFile f2 ReadMode
	content2 <- hGetContents handle2
	handle3 <- openFile f3 ReadMode
	content3 <- hGetContents handle3
	let l1 = convertToListTuples1 (lines content1)
	    l2 = convertToListTuples2 (lines content2)
	    l3 = convertToListTuples3 (lines content3)
	doCommand l1 l2 l3

handler :: SomeException -> IO ()
handler ex = putStrLn $ "Caught exception: " ++ show ex

