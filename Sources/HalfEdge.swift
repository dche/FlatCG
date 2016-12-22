//
// FlatCG - HalfEdge.swift
//
// Half edge data structure.
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

/// An implementation of half-edge data structure for generational
/// geometric modeling.
///
///
final public class Hull<T: Point> {

    // Vertex list. Geometric information stored here.
    fileprivate var _vertices: [T] = []

    // Half edge list.
    fileprivate var _edges: [Int] = []

    // Version of edges.
    fileprivate var _edgeVersions: [Int] = []

    // Face list. Only version is stored.
    fileprivate var _faces: [Int] = []

    fileprivate var _freeVertices = Set<Int>()

    fileprivate var _freeEdges = Set<Int>()

    fileprivate var _freeFaces = Set<Int>()

    // Version of the `Hull`.
    fileprivate var _version = 0

    init () {}
}

public typealias Hull2D = Hull<Point2D>
public typealias Hull3D = Hull<Point3D>

extension Hull {

    /// Number of vertices.
    public var vertexCount: Int { return _vertices.count - _freeVertices.count }

    /// Number of edges.
    public var edgeCount: Int { return _edges.count / 8 - _freeEdges.count }

    /// Number of half edges. It is double of `edgeCount` of course.
    public var halfEdgeCount: Int { return edgeCount * 2 }

    /// Number of faces.
    public var faceCount: Int { return _faces.count - _freeFaces.count }

    /// If the `Hull` contains no vertex.
    public var isEmpty: Bool { return vertexCount < 1 }
}

extension Hull: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Hull<\(T.self)>(edges: \(edgeCount), vertices: \(vertexCount), faces: \(faceCount))"
    }
}

// MARK: Memory management.

// Connectivity issues are handled in Euler operators.

fileprivate extension Hull {

    func add(vertex: T) -> Int {
        guard _freeVertices.isEmpty else {
            let i = _freeVertices.removeFirst()
            return i
        }
        _vertices.append(vertex)
        return _vertices.count - 1
    }

    func remove(vertex: Int) {
        assert(!_freeVertices.contains(vertex))
        _freeVertices.insert(vertex)
    }

    func allocEdge() -> Int {
        _version += 1
        guard _freeEdges.isEmpty else {
            let i = _freeEdges.removeFirst()
            _edgeVersions[i * 2] = _version
            _edgeVersions[i * 2 + 1] = _version
            return i
        }
        // Half edge layout: (origin, prev, next, face).
        _edges.append(contentsOf: [-1, -1, -1, -1, -1, -1, -1, -1])
        _edgeVersions.append(_version)
        _edgeVersions.append(_version)
        return _edges.count / 8 - 1
    }

    func remove(edge: Int) {
        _version += 1
        let e = edge / 2
        let me = self.mate(edge)
        assert(!_freeEdges.contains(e))
        _freeEdges.insert(e)
        _edgeVersions[edge] = _version
        _edgeVersions[me] = _version
    }

    func allocFace() -> Int {
        _version += 1
        guard _freeFaces.isEmpty else {
            let i = _freeFaces.removeFirst()
            _faces[i] = _version
            return i
        }
        _faces.append(_version)
        return _faces.count - 1
    }

    func remove(face: Int) {
        _version += 1
        assert(!_freeFaces.contains(face))
        _faces[face] = _version
        _freeFaces.insert(face)
    }

    // TODO: public func compact() {}
}

// MARK: Low level operations.

fileprivate extension Hull {

    func vertex(_ v: Int) -> T {
        assert(v >= 0 && v < _vertices.count)
        assert(!_freeVertices.contains(v))
        return _vertices[v]
    }

    func mate(_ e: Int) -> Int {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        // if e % 2 == 0 { return e + 1 }
        // else { return e - 1 }
        return e + 1 - e % 2 * 2
    }

    func addEdge(from v0: Int, to v1: Int) -> Int {
        assert(v0 >= 0 && v0 < _vertices.count)
        assert(!_freeVertices.contains(v0))
        assert(v1 >= 0 && v1 < _vertices.count)
        assert(!_freeVertices.contains(v1))
        let e = allocEdge()
        let he0 = e * 2
        let he1 = he0 + 1
        setOrigin(he0, v0)
        setOrigin(he1, v1)
        return he0
    }

    func addFace(_ e: Int) -> Int {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        return self.allocFace()
    }

    func origin(_ e: Int) -> Int {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        return _edges[e * 4]
    }

    func setOrigin(_ e: Int, _ v: Int) {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        assert(v >= 0 && v < _vertices.count)
        assert(!_freeVertices.contains(v))
        _version += 1
        _edgeVersions[e] = _version
        _edges[e * 4] = v
    }

    func target(_ e: Int) -> Int {
        return origin(mate(e))
    }

    func setTarget(_ e: Int, _ v: Int) {
        setOrigin(mate(e), v)
    }

    func prev(_ e: Int) -> Int {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        return _edges[e * 4 + 1]
    }

    func setPrev(_ e: Int, _ p: Int) {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        assert(p >= 0 && p < _edges.count)
        assert(!_freeEdges.contains(p))
        _edges[e * 4 + 1] = p
        // setNext(p, e)
        _edges[p * 4 + 2] = e
    }

    func next(_ e: Int) -> Int {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        return _edges[e * 4 + 2]
    }

    func setNext(_ e: Int, _ n: Int) {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        assert(n >= 0 && n < _edges.count / 4)
        assert(!_freeEdges.contains(n / 2))
        _edges[e * 4 + 2] = n
        // setPrev(n, e)
        _edges[n * 4 + 1] = e
    }

    func edge(_ e: Int) -> Int {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        return e / 2
    }

    func face(_ e: Int) -> Int {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        return _edges[e * 4 + 3]
    }

    func setFace(_ e: Int, _ f: Int) {
        assert(e >= 0 && e < _edges.count / 4)
        assert(!_freeEdges.contains(e / 2))
        assert(f >= -1 && f < _faces.count)
        assert(!_freeFaces.contains(f))
        _version += 1
        // if !isNull(face: f) { _faces[f] = _version }
        _edgeVersions[e] = _version
        _edges[e * 4 + 3] = f
    }

    func isNull(face f: Int) -> Bool {
        return f < 0
    }
}

// Raw edge circulator used internally.
fileprivate struct Ring: IteratorProtocol {

    typealias Element = Int

    var _current: Int

    let after: (Int) -> Int

    mutating func next() -> Int? {
        let r = _current
        _current = self.after(r)
        return r
    }

    init (current: Int, next: @escaping (Int) -> Int) {
        self._current = current
        self.after = next
    }

    func contains(_ e: Int) -> Bool {
        var s = _current
        repeat {
            guard s != e else { return true }
            s = after(s)
        } while s != _current
        return false
    }

    var sequence: IteratorSequence<AnyIterator<Int>> {
        let head = _current
        var current: Int? = head
        let iter = AnyIterator<Int>() {
            guard let i = current else { return nil }
            let e = self.after(i)
            if e == head { current = nil } else { current = e }
            return i
        }
        return IteratorSequence(iter)
    }
}

fileprivate extension Hull {

    func ring(edge: Int) -> Ring {
        assert(edge >= 0 && edge < _edges.count / 4)
        assert(!_freeEdges.contains(edge / 2))
        return Ring(current: edge, next: self.next)
    }
}

///
public struct HalfEdge<T: Point> {

    public typealias PointType = T

    public let hull: Hull<T>

    let id: Int

    fileprivate let version: Int

    init (hull: Hull<T>, id: Int) {
        self.hull = hull
        self.id = id
        self.version = hull._version
    }

    /// Tests if the edge the receiver references to is still valid.
    public var isValid: Bool {
        return self.version >= self.hull._edgeVersions[self.id]
    }
}

///
public struct Circulator<T: Point, S>: IteratorProtocol {

    public typealias Element = S

    /// The element upon which the `Circulator` is defined.
    /// If `principal` is invalid by a modification to the `hull`, the
    /// circulator is invalid either, even though its current element
    /// is valid.
    public let principal: HalfEdge<T>

    private var _current: HalfEdge<T>?

    private let after: (HalfEdge<T>) -> HalfEdge<T>?

    private let transform: (HalfEdge<T>) -> S?

    fileprivate init (
        principal: HalfEdge<T>,
        next: @escaping (HalfEdge<T>) -> HalfEdge<T>?,
        transform: @escaping (HalfEdge<T>) -> S?
    ) {
        self.principal = principal
        self._current = principal
        self.after = next
        self.transform = transform
    }

    public mutating func next() -> Element? {
        guard let r = _current else { return nil }
        guard principal.isValid && r.isValid else { return nil }
        _current = self.after(r)
        return transform(r)
    }

    /// A lazy sequence that starts at the `principal` edge and ends at
    /// previous element of `principal`.
    public var sequence: IteratorSequence<AnyIterator<S>> {
        let head = principal
        var eg: HalfEdge<T>? = principal
        let iter = AnyIterator<S>() {
            guard let r = eg else { return nil }
            guard head.isValid && r.isValid else { return nil }
            eg = self.after(r)
            // Terminate.
            if eg == head { eg = nil }
            return self.transform(r)
        }
        return IteratorSequence(iter)
    }

    public func map<R>(_ fn: @escaping (S) -> R?) -> Circulator<T, R> {
        let t: (HalfEdge<T>) -> R? = { self.transform($0).flatMap { fn($0) } }
        return Circulator<T, R>(principal: principal, next: after, transform: t)
    }
}

/// A structure that references to a vertex in the half edge data structure.
///
/// The vertex reference is defined by an `HalfEdge` originated from the
/// vertex, for performence
public struct Vertex<T: Point> {

    public typealias PointType = T

    /// A incident half edge that is origniated from the vertex.
    public let edge: HalfEdge<T>

    public var hull: Hull<T> { return self.edge.hull }

    init (edge: HalfEdge<T>) {
        self.edge = edge
    }
}

/// The structure that represents a face in the half edge data structure.
public struct Face<T: Point> {

    public typealias PointType = T

    public let edge: HalfEdge<T>

    fileprivate let version: Int

    public var hull: Hull<T> { return self.edge.hull }

    init (edge: HalfEdge<T>) {
        self.edge = edge
        self.version = edge.hull._version
    }
}

extension HalfEdge: Hashable {

    public static func == (lhs: HalfEdge, rhs: HalfEdge) -> Bool {
        return lhs.id == rhs.id
    }

    public var hashValue: Int { return id }
}

extension HalfEdge {

    /// The mate half-edge of the receiver.
    public var mate: HalfEdge<T>? {
        guard self.isValid else { return nil }
        return HalfEdge<T>(hull: hull, id: hull.mate(id))
    }

    public var next: HalfEdge<T>? {
        guard self.isValid else { return nil }
        return HalfEdge(hull: hull, id: hull.next(id))
    }

    public var prev: HalfEdge<T>? {
        guard self.isValid else { return nil }
        return HalfEdge(hull: hull, id: hull.prev(id))
    }

    public var origin: Vertex<T>? {
        guard self.isValid else { return nil }
        return Vertex<T>(edge: self)
    }

    public var target: Vertex<T>? {
        return self.mate.map { Vertex<T>(edge: $0) }
    }

    /// Adjacent `Face` of this half edge.
    public var face: Face<T>? {
        guard self.isValid else { return nil }
        return Face<T>(edge: self)
    }

    /// Tests if the receiver is a boundary edge.
    public var isBorder: Bool {
        guard self.isValid else { return false }
        return face!.isNull || mate!.face!.isNull
    }
}

extension Vertex: Hashable {

    var id: Int { return self.hull.origin(self.edge.id) }

    public static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.id == rhs.id
    }

    public var hashValue: Int { return id }
}

extension Vertex {

    public var isValid: Bool {
        return self.edge.isValid
    }

    /// The geometric position of the vertex.
    public var position: T? {
        guard self.isValid else { return nil }
        return hull.vertex(id)
    }

    /// A circulate of all edges originated to the vertex, in CCW order.
    public var edges: Circulator<T, HalfEdge<T>> {
        let n: (HalfEdge<T>) -> HalfEdge<T>? = { $0.mate?.next }
        let t: (HalfEdge<T>) -> HalfEdge<T> = { $0 }
        return Circulator<T, HalfEdge<T>>(principal: self.edge, next: n, transform: t)
    }

    /// A circulator of adjacent faces of the vertex, in CCW order.
    public var faces: Circulator<T, Face<T>> {
        return self.edges.map { $0.face }
    }

    /// A circulator of adjacent vertices. They are the target vertices
    /// of indicent edges of the receiver.
    public var neighbors: Circulator<T, Vertex<T>> {
        return self.edges.map { $0.target }
    }
}

extension Face: Hashable {

    var id: Int { return self.hull.face(self.edge.id) }

    public static func == (lhs: Face, rhs: Face) -> Bool {
        return lhs.id == rhs.id
    }

    public var hashValue: Int { return id }
}

extension Face {

    public var isValid: Bool {
        guard self.edge.isValid else { return false }
        let fid = self.id
        if hull.isNull(face: fid) { return true }
        return self.version >= self.hull._faces[fid]
    }

    /// Tests if the `Face` is __null__ face.
    ///
    /// The null face is the face of the half edges on the boundary.
    /// Null face is not counted as a face of the `Hull`.
    public var isNull: Bool {
        guard self.isValid else { return true }
        return hull.isNull(face: id)
    }

    /// A circulator of all the edges of the face in the CCW order.
    public var edges: Circulator<T, HalfEdge<T>> {
        let n: (HalfEdge<T>) -> HalfEdge<T>? = { $0.next }
        let t: (HalfEdge<T>) -> HalfEdge<T> = { $0 }
        return Circulator<T, HalfEdge<T>>(principal: self.edge, next: n, transform: t)
    }

    /// A circulator of origin points of edges of the face, in CCW order.
    public var vertices: Circulator<T, Vertex<T>> {
        return self.edges.map { $0.origin }
    }

    /// Adjacent faces of the face.
    public var neighbors: Circulator<T, Face<T>> {
        return self.edges.map { $0.mate?.face }
    }
}

extension Hull {

    /// A sequnce of all edges.
    ///
    /// - note: We have not the Edge entity. Edge is represented by one of its
    /// `HalfEdge`.
    public var edges: AnySequence<HalfEdge<T>> {
        var i = 0
        let iter = AnyIterator.init { () -> HalfEdge<T>? in
            while self._freeEdges.contains(i) && i < self._edges.count {
                i += 8
            }
            guard i < self._edges.count else { return nil }
            let e = HalfEdge<T>(hull: self, id: i / 4)
            i += 8
            return e
        }
        return AnySequence.init {
            return iter
        }
    }

    /// Geometric position of all vertices of the `Hull`.
    ///
    /// - note: Not all data are valid if there's any vertex is ever removed.
    /// You should always use indices in `faces` or `lines` to reference valid
    /// vertices.
    public var vertices: [T] { return _vertices }

    ///
    public var faces: ([T], [UInt32]) {
        var r = [UInt32](repeating: 0, count: self.faceCount * 3)
        var a = [Bool](repeating: false, count: self._faces.count)
        var j = 0

        func addFace(_ f: Face<T>) {
            if f.isNull || a[f.id] { return }
            a[f.id] = true
            let pj = j
            for v in f.vertices.sequence {
                r[j] = UInt32(v.id)
                j += 1
                if j - pj > 2 {
                    // TODO: Warning or just crash.
                    break
                }
            }
        }

        for e in edges {
            addFace(e.face!)
            addFace(e.mate!.face!)
        }
        return (_vertices, r)
    }

    ///
    public var lines: ([T], [UInt32]) {
        var r = [UInt32](repeating: 0, count: self.edgeCount * 2)
        var i = 0
        for e in edges {
            let eid = e.id
            r[i] = UInt32(self.origin(eid))
            r[i + 1] = UInt32(self.target(eid))
            i += 2
        }
        assert(i == self.edgeCount * 2)
        return (_vertices, r)
    }

    // TODO: public var points: ([T], [UInt32]) {}
}

// MARK: Euler operators.

extension Hull {

    func makeVEFS(_ p0: T, _ p1: T) -> Int {
        let v0 = self.add(vertex: p0)
        let v1 = self.add(vertex: p1)
        let ne = self.addEdge(from: v0, to: v1)
        let me = self.mate(ne)

        self.setNext(ne, me)
        self.setNext(me, ne)
        // Initial face is `Nil`.
        return ne
    }

    // func killVEFS(_ e: Int) {}

    // A special case of `makeEV`.
    func makeEV(_ p: T, _ e: Int) -> Int {
        let v = self.add(vertex: p)
        let ne = self.addEdge(from: v, to: self.origin(e))
        let me = self.mate(ne)

        self.setNext(self.prev(e), me)
        self.setNext(me, ne)
        self.setNext(ne, e)

        let f = self.face(e)
        self.setFace(ne, f)
        self.setFace(me, f)
        return ne
    }

    // Makes an edge from vertex `p` to edge `e0`'s origin, and then sets the
    // origin of `e0` and target of preceding edge of `e1` to `p`.
    //
    // 4 existed half edges are affected.
    func makeEV(_ p: T, _ e0: Int, _ e1: Int) -> Int? {
        guard e0 != e1 else { return makeEV(p, e0) }
        guard self.origin(e0) == self.origin(e1) else { return nil }

        let e2 = self.prev(e0)
        let e3 = self.prev(e1)
        let v = self.add(vertex: p)
        let ne = self.addEdge(from: v, to: self.origin(e0))
        let me = self.mate(ne)

        self.setOrigin(e0, v)
        self.setTarget(e3, v)

        self.setNext(e2, me)
        self.setNext(me, e0)
        self.setNext(ne, e1)
        self.setNext(e3, ne)

        self.setFace(ne, self.face(e1))
        self.setFace(me, self.face(e0))

        return ne
    }

    // Removes half edge `e` and its origin vertex.
    //
    // This is the reverse operation of `makeEV`.
    func killEV(_ e: Int) {
        guard self.origin(e) != self.target(e) else { return }

        let me = self.mate(e)
        let e0 = self.next(me)
        let e3 = self.prev(e)

        let v = self.target(e)
        self.remove(vertex: self.origin(e))

        guard e0 != e else {
            if self.next(e) == me {
                self.remove(vertex: self.origin(me))
            } else {
                self.setNext(self.prev(me), self.next(e))
            }
            self.remove(edge: e)
            return
        }

        self.setOrigin(e0, v)
        self.setTarget(e3, v)

        self.setNext(self.prev(me), e0)
        self.setNext(e3, self.next(e))

        self.remove(edge: e)
    }

    // Makes an edge from origin of `e` to the same vertex.
    //
    // This operation effectivly creates a loop inside of the face of `e`.
    //
    // - returns ID of new created edge.
    func makeEF(_ e: Int) -> Int {
        let v = self.origin(e)
        let e1 = self.prev(e)
        let ne = self.addEdge(from: v, to: v)
        let me = self.mate(ne)

        self.setNext(me, e)
        self.setNext(e1, me)

        self.setNext(ne, ne)
        self.setFace(ne, self.addFace(ne))
        self.setFace(me, self.face(e))

        return ne
    }

    // Makes an edge from origin of `e1` to origin of `e0`.
    //
    // Returns `nil` if `e0` and `e1` do not share same face.
    func makeEF(_ e0: Int, _ e1: Int) -> Int? {
        guard e0 != e1 else { return makeEF(e0) }
        guard self.ring(edge: e0).contains(e1) else { return nil }

        let f = self.face(e0)
        assert(self.face(e1) == f)

        let ne = self.addEdge(from: self.origin(e1), to: self.origin(e0))
        let me = self.mate(ne)

        self.setNext(self.prev(e1), ne)
        self.setNext(me, e1)
        self.setNext(self.prev(e0), me)
        self.setNext(ne, e0)

        let nf = self.addFace(ne)
        var e = ne
        repeat {
            self.setFace(e, nf)
            e = self.next(e)
        } while e != ne
        self.setFace(me, f)

        assert(self.face(e0) == nf)
        assert(self.face(e1) == f)
        return ne
    }

    // Merges 2 faces into 1 by removing edge `e` and face of `e`.
    //
    // - parameter e: The `HalfEdge` that specifies the face to to killed.
    func killEF(_ e: Int) {
        let me = self.mate(e)
        let f = self.face(me)

        guard f != self.face(e) else { return }

        var se = self.next(e)
        while se != e {
            self.setFace(se, f)
            se = self.next(se)
        }

        self.setNext(self.prev(e), self.next(me))
        self.setNext(self.prev(me), self.next(e))

        self.remove(face: self.face(e))
        self.remove(edge: e)
    }

    ///
    func makeEkillR(_ e0: Int, _ e1: Int) -> Int? {
        let f = self.face(e0)
        // CHECK: Should `guard` be changed to `assert`?
        guard self.face(e1) == f else { return nil }
        guard !self.ring(edge: e0).contains(e1) else { return nil }

        let ne = self.addEdge(from: self.origin(e0), to: self.origin(e1))
        let me = self.mate(ne)

        self.setNext(self.prev(e1), me)
        self.setNext(self.prev(e0), ne)
        self.setNext(ne, e1)
        self.setNext(me, e0)

        self.setFace(ne, f)
        self.setFace(me, f)
        return ne
    }

    func killEmakeR(_ e: Int) {
        let f = self.face(e)
        guard self.face(self.mate(e)) == f else { return }

        let me = self.mate(e)
        self.setNext(self.prev(e), self.next(me))
        self.setNext(self.prev(me), self.next(e))
        self.remove(edge: e)
    }

    func killFmakeRH(_ e0: Int, _ e1: Int) {
        let f = self.face(e1)
        let f0 = self.face(e0)
        guard f0 != f && self.face(self.mate(e0)) != f else { return }
        // Remove `f0`.
        for e in self.ring(edge: e0).sequence { self.setFace(e, f) }
        self.remove(face: f0)
    }

    // func makeFkillRH(_ e: Int) {}
}

// MARK: High level modeling operations.

extension Hull {

    /// The empty `Hull` that does not contain any vertex.
    public static var empty: Hull<T> { return Hull<T>() }
}

extension Face {

    /// Splits the face.
    public func split(at point: T) -> Vertex<T>? {
        guard self.isValid && !self.isNull else { return nil }
        var ne = self.hull.makeEV(point, self.edge.id)
        assert(self.edge.prev!.id == ne)
        let sv = self.edge.origin!.id
        let hull = self.hull
        var e = hull.next(hull.next(ne))
        while hull.origin(e) != sv  {
            ne = hull.makeEF(e, ne)!
            assert(hull.next(ne) == e)
            e = hull.next(e)
        }
        assert(self.isValid)
        return Vertex<T>(edge: self.edge.prev!)
    }
}

extension Hull where T.VectorType: Vector2 {

    /// Constructs a half-edge data structure from a simple polygon
    /// without hole.
    ///
    /// - returns: The new creaeted `Face` defined by the polygon.
    public static func from(polygon: Polygon<T>) -> Face<T>? {
        let hull = Hull<T>.empty
        let pts = polygon.points
        guard pts.count > 1 else { return nil }

        let e0 = hull.makeVEFS(pts[0], pts[1])
        var e = hull.mate(e0)
        for p in pts.suffix(2) {
            e = hull.makeEV(p, e)
        }
        let _ = hull.makeEF(e0, e)!
        return HalfEdge<T>(hull: hull, id: e0).face
    }
}

extension Hull where T.VectorType: Vector3 {

    // TODO: Polygon to double faces, extrude.
}
