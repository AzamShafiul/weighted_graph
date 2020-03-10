import intsets, random, sequtils, tables, strutils

type
  Node = int
  Edge[T] = tuple[src, dst: T, weight: int]

type GraphMap[T] = ref object
  ## Create a mapping between arbitrary objects to an internal node-id.
  keyToNode: Table[T, Node]
    ## Provide a lookup from a key to a node-id.
  nodeToKey: Table[Node, T]
    ## Provide a reverse lookup from a node-id to a key.

proc newGraphMap[T](): GraphMap[T] =
  result.new()
  result.keyToNode = initTable[T, Node]()
  result.nodeToKey = initTable[Node, T]()

proc register[T](GM: GraphMap, A: T, n: Node): Node =
  ## Register a node-id and the associated object.
  result = n
  GM.keyToNode[A] = n
  GM.nodeToKey[n] = A

proc register[T](GM: GraphMap, A: T): Node {.raises: [KeyError].} =
  ## Map the provided node to a newly generated node-id.
  ## Raise an error if the node is already registered in the graph.
  if A in GM.keyToNode:
    raise KeyError.newException("Attempting to reregister a node that is " &
                                "already present in the graph mapping.")
  while true:
    # Repeat until a unique id is generated.
    let id: Node = rand(int.high)
    if id in GM.nodeToKey:
      continue
    return GM.register(A, id)

proc unregister[T](GM: GraphMap, A: T): Node {.raises: [KeyError].} =
  ## Unmap the provided node.
  ## Raise an error if the node is not already registered in the graph.
  if not (A in GM.keyToNode):
    raise KeyError.newException("Attempting to unregister a node that " &
                                "is not present in the graph mapping.")

  result = GM.keyToNode[A]
  GM.nodeToKey.del(result)
  GM.keyToNode.del(A)
type GraphSet = ref object
  nodes: IntSet
  outEdges: Table[Node, IntSet]
  inEdges: Table[Node, IntSet]
  weight: Table[string, int]
proc newGraphSet(): GraphSet =
  result.new()
  result.nodes = initIntSet()
  result.outEdges = initTable[Node, IntSet]()
  result.inEdges = initTable[Node, IntSet]()
  result.weight = initTable[string, int]()

# Procedures dealing with Edge manipulation.
proc addEdge(GS: GraphSet, src: Node, dst: Node, wgt: int) =
  GS.outEdges[src].incl(dst)
  GS.inEdges[dst].incl(src)
  var w = initIntSet()
  w.incl(src)
  w.incl(dst)
  GS.weight[$w] = wgt
  

proc delEdge(GS: GraphSet, src: Node, dst: Node) =
  GS.outEdges[src].excl(dst)
  GS.inEdges[dst].excl(src)

# Procedures dealing with Node manipulation.
proc addNode(GS: GraphSet, n: Node) =
  ## Add the node-id to our graph.
  ## We are assured that the node-id is unique because of the GraphMap.
  GS.nodes.incl(n)
  GS.outEdges[n] = initIntSet()
  GS.inEdges[n] = initIntSet()

proc delNode(GS: GraphSet, n: Node) =
  ## Delete a node-id from the GraphSet.
  ## Delete all edges going to and from the provided node-id.
  for outEdge in GS.outEdges[n]:
    GS.delEdge(n, outEdge)
  for inEdge in GS.inEdges[n]:
    GS.delEdge(inEdge, n)
  GS.outEdges.del(n)
  GS.inEdges.del(n)
  GS.nodes.excl(n)


# Implementation for the base Graph type.
type Graph[T] = ref object of RootObj
  map: GraphMap[T]
  graph: GraphSet
type
  SimpleGraph*[T] = ref object of Graph[T]
type DirectedGraph*[T] = ref object of Graph[T]



proc initGraph*[T](G: Graph[T])=
  G.map = newGraphMap[T]()
  G.graph = newGraphSet()

proc `[]`[T](G: Graph[T], A: T): Node {.raises: [KeyError].} =
  ## Handy alias for node-id lookup.
  result = G.map.keyToNode[A]

# Procedures dealing with Node manipulation.
proc addNode*[T](G: Graph[T], A: T) {.raises: [KeyError].} =
  ## Add a new node to the graph.
  G.graph.addNode(G.map.register(A))


proc delNode*[T](G: Graph[T], A: T) {.raises: [KeyError].} =
  ## Delete a node from the graph.
  G.graph.delNode(G.map.unregister(A))

proc hasNode*[T](G: Graph[T], A: T): bool=
  result = A in G.map.keyToNode

# XXX: Iterator here caused some issues with inheritance.
proc nodes*[T](G: Graph[T]): seq[T] =
  result = toSeq(G.map.keyToNode.keys)

# Procedures dealing with Edge manipulation.
proc addEdge*[T](G: Graph[T], A: T, B: T, C: int) {.raises: [KeyError].} =
  ## Add a new edge to the graph.

  G.graph.addEdge(G[A], G[B], C)

proc delEdge*[T](G: Graph[T], A: T, B: T) {.raises: [KeyError].} =
  ## Delete an edge from the graph.
  G.graph.delEdge(G[A], G[B])

proc edges*[T](G: Graph[T], A: T, out_edges: bool = true): seq[Edge[T]] =
  let collection =
    if out_edges:
      G.graph.outEdges[G[A]]
    else:
      G.graph.inEdges[G[A]]
  result = @[]
  

  for node in collection.items:
    var w = initIntSet()
    w.incl(G[A])
    w.incl(node)
    result.add((A, G.map.nodeToKey[node], G.graph.weight[$w]))

proc edges*[T](G: Graph[T], out_edges: bool = true): seq[Edge[T]] =
  result = @[]
  for node in G.nodes:
    for edge in G.edges(node, out_edges):
      result.add(edge)

proc hasEdge*[T](G: Graph[T], A: T, B: T): bool =
  ## This proc checks for the presence of an edge in either direction to
  ## satisfy the properties of a directionless simple graph.
  if not G.hasNode(A) or not G.hasNode(B):
    return false
  result = G[B] in G.graph.outEdges[G[A]]


#Implementation for the SimpleGraph Type.

proc hasEdge*[T](G: SimpleGraph[T], A: T, B: T): bool =
  ## SimpleGraph pays no heed to direction.
  result = (procCall(Graph[T](G).hasEdge(A, B)) or
            procCall(Graph[T](G).hasEdge(B, A)))