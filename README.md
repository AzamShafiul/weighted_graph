# weighted_graph
Graph data structure with weight library for Nim

Examples
===
```var G:SimpleGraph[int] = SimpleGraph[int]()
G.initGraph()
G.addNode(0)
G.addNode(1)
G.addNode(2)
G.addNode(3)
echo G.nodes()#@[1, 2, 3, 0]
G.delNode(3)
echo G.nodes()#@[1, 2, 0]
echo G.hasNode(1)#true
G.addEdge(0,1,19)
G.addEdge(0,2,14)
G.addEdge(1,2,14)
echo G.hasEdge(0,1)#true
echo G.hasEdge(1,0)#true beacuse undirected graph
echo G.edges()#@[(src: 1, dst: 2, weight: 14), (src: 0, dst: 1, weight: 19), (src: 0, dst: 2, weight: 14)]
echo G.edges(0)#@[(src: 0, dst: 1, weight: 19), (src: 0, dst: 2, weight: 14)]
G.delEdge(1,2)
echo G.edges()#@[(src: 0, dst: 1, weight: 19), (src: 0, dst: 2, weight: 14)]

var Gd: DirectedGraph[char] = DirectedGraph[char]()
Gd.initGraph()
Gd.addNode('a')
Gd.addNode('b')
Gd.addNode('c')
Gd.addNode('d')
echo Gd.nodes()#@['a', 'b', 'c', 'd']
Gd.delNode('d')
echo Gd.nodes()#@['a', 'b', 'c']
echo Gd.hasNode('b')#true
Gd.addEdge('a','b',19)
Gd.addEdge('a','c',14)
Gd.addEdge('b','c',14)
echo Gd.hasEdge('a','b')#true
echo Gd.hasEdge('b','a')#false beacuse directed graph
echo Gd.edges()#@[(src: 'a', dst: 'b', weight: 19), (src: 'a', dst: 'c', weight: 14), (src: 'b', dst: 'c', weight: 14)]
echo Gd.edges('a')#@[(src: 'a', dst: 'b', weight: 19), (src: 'a', dst: 'c', weight: 14)]
Gd.delEdge('b','c')
echo Gd.edges()#@[(src: 'a', dst: 'b', weight: 19), (src: 'a', dst: 'c', weight: 14)]
```
