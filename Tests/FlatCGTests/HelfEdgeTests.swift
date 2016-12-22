
import XCTest
import simd
import GLMath
@testable import FlatCG

class EulerOperationTests: XCTestCase {

    func testEmpty() {
        let hull = Hull3D.empty
        XCTAssert(hull.isEmpty)
        XCTAssertEqual(hull.vertexCount, 0)
        XCTAssertEqual(hull.edgeCount, 0)
        XCTAssertEqual(hull.halfEdgeCount, 0)
        XCTAssertEqual(hull.faceCount, 0)
    }

    func testMkeVEFS() {
        let p0 = Point2D.origin
        let p1 = Point2D(1, 0)
        let hull = Hull2D.empty
        let eid = hull.makeVEFS(p0, p1)
        let e = HalfEdge(hull: hull, id: eid)
        XCTAssert(e.isValid)
        XCTAssertEqual(e.next, e.mate)
        XCTAssertEqual(e.prev, e.mate)
        XCTAssertEqual(e.origin!.position!, p0)
        XCTAssertEqual(e.target!.position!, p1)
        XCTAssert(e.face!.isNull)
        XCTAssertEqual(hull.faceCount, 0)
        XCTAssertEqual(hull.vertexCount, 2)
        XCTAssertEqual(hull.edgeCount, 1)
    }

    func testMakeEV() {
        let p0 = Point2D.origin
        let p1 = Point2D(1, 0)
        let p2 = Point2D(1, 1)
        let p3 = Point2D(0, 1)
        let hull = Hull2D.empty
        let e0 = hull.makeVEFS(p0, p1)

        let e1 = hull.makeEV(p2, e0, e0)
        XCTAssertNotNil(e1)
        XCTAssertEqual(hull.edgeCount, 2)
        XCTAssertEqual(hull.vertexCount, 3)
        var e = HalfEdge(hull: hull, id: e1!)
        XCTAssert(e.isValid)
        XCTAssert(e.face!.isNull)
        XCTAssert(e.next!.id == e0)
        XCTAssertEqual(e.prev?.id, e.mate?.id)
        XCTAssertEqual(e.origin!.position!, p2)
        XCTAssertEqual(e.mate!.origin!.position!, p0)

        let e2 = hull.makeEV(p3, e.mate!.id, e0)
        XCTAssertNotNil(e2)
        XCTAssertEqual(hull.edgeCount, 3)
        XCTAssertEqual(hull.vertexCount, 4)
        e = HalfEdge(hull: hull, id: e2!)
        XCTAssert(e.isValid)
        XCTAssert(e.face!.isNull)
        XCTAssertEqual(e.origin!.position!, p3)
        XCTAssertEqual(e.target!.position!, p0)
        XCTAssertEqual(e.next!.id, e0)
        XCTAssertEqual(e.prev!.id, e1)
        XCTAssertEqual(e.next?.next, e.next?.mate)
        XCTAssertEqual(e.next!.mate!.next, e.mate)
        XCTAssertEqual(e.mate?.next, e.prev?.mate)
    }

    func testKillEV() {
        let p0 = Point2D.origin
        let p1 = Point2D(1, 0)
        let p2 = Point2D(1, 1)
        let p3 = Point2D(0, 1)
        let hull = Hull2D.empty
        let e0 = hull.makeVEFS(p0, p1)
        let e1 = hull.makeEV(p2, e0)
        var e = HalfEdge(hull: hull, id: e1)
        let e2 = hull.makeEV(p3, e.mate!.id, e0)!

        XCTAssertEqual(hull.edgeCount, 3)
        XCTAssertEqual(hull.vertexCount, 4)

        hull.killEV(e2)
        XCTAssertEqual(hull.edgeCount, 2)
        XCTAssertEqual(hull.vertexCount, 3)
        e = HalfEdge(hull: hull, id: e1)
        XCTAssertEqual(e.next!.id, e0)

        hull.killEV(e1)
        XCTAssertEqual(hull.edgeCount, 1)
        XCTAssertEqual(hull.vertexCount, 2)

        e = HalfEdge(hull: hull, id: e0)
        XCTAssert(e.face!.isNull)
        XCTAssertEqual(e.next, e.prev)
        XCTAssertEqual(e.next, e.mate)

        hull.killEV(e0)
        XCTAssertEqual(hull.edgeCount, 0)
        XCTAssertEqual(hull.vertexCount, 0)
        XCTAssert(hull.isEmpty)
    }

    func testMakeEF() {
        let p0 = Point2D.origin
        let p1 = Point2D(1, 0)
        let p2 = Point2D(1, 1)
        let p3 = Point2D(0, 1)
        let hull = Hull2D.empty
        let e0 = hull.makeVEFS(p0, p1)
        let e1 = hull.makeEV(p2, e0)
        var e = HalfEdge(hull: hull, id: e1)
        let e2 = hull.makeEV(p3, e.mate!.id, e0)!

        e = HalfEdge(hull: hull, id: e0)
        let e3 = hull.makeEF(e1, e.mate!.id)!
        XCTAssertEqual(hull.faceCount, 1)
        XCTAssertEqual(hull.edgeCount, 4)
        XCTAssertEqual(hull.halfEdgeCount, 8)
        e = HalfEdge(hull: hull, id: e3)
        let f = e.face
        XCTAssertEqual(e.origin!.position, p1)
        XCTAssertEqual(e.target!.position, p2)
        XCTAssertFalse(e.face!.isNull)
        XCTAssert(e.mate!.face!.isNull)
        XCTAssertEqual(e.next!.id, e1)
        XCTAssertEqual(e.prev!.id, e0)
        XCTAssertEqual(e.next!.next!.id, e2)
        XCTAssertEqual(e.prev!.prev!.prev!.prev!, e)
        // Loop.
        let e4 = hull.makeEF(e.id)
        XCTAssertEqual(hull.faceCount, 2)
        XCTAssertEqual(hull.edgeCount, 5)
        e = HalfEdge(hull: hull, id: e4)
        XCTAssertEqual(e.origin, e.target)
        XCTAssertFalse(e.face!.isNull)
        XCTAssertFalse(e.mate!.face!.isNull)
        XCTAssertNotEqual(e.face, f)
        XCTAssertEqual(e.mate?.face, f)
        XCTAssertEqual(e.next!, e)
        XCTAssertEqual(e.mate!.next!.id, e3)
        XCTAssertEqual(e.mate!.prev!.id, e0)

        let e5 = hull.makeEF(e2, e3)!
        XCTAssertEqual(hull.faceCount, 3)
        XCTAssertEqual(hull.edgeCount, 6)
        e = HalfEdge(hull: hull, id: e5)
        XCTAssertNotEqual(e.face, e.mate?.face)
        XCTAssertFalse(e.face!.isNull)
        XCTAssertFalse(e.mate!.face!.isNull)
        XCTAssertEqual(e.origin!.position, p1)
        XCTAssertEqual(e.target!.position, p3)
        XCTAssertEqual(e.next!.id, e2)
        XCTAssertEqual(e.prev!.mate!.id, e4)
        XCTAssertEqual(e.mate!.next!.id, e3)
        XCTAssertEqual(e.mate!.prev!.id, e1)
    }

    func testKillEF() {
        let p0 = Point2D.origin
        let p1 = Point2D(1, 0)
        let p2 = Point2D(1, 1)
        let p3 = Point2D(0, 1)
        let hull = Hull2D.empty
        let e0 = hull.makeVEFS(p0, p1)
        let e1 = hull.makeEV(p2, e0)
        var e = HalfEdge(hull: hull, id: e1)
        let e2 = hull.makeEV(p3, e.mate!.id, e0)!
        e = HalfEdge(hull: hull, id: e0)
        let e3 = hull.makeEF(e1, e.mate!.id)!
        e = HalfEdge(hull: hull, id: e3)
        let e4 = hull.makeEF(e.id)
        let e5 = hull.makeEF(e2, e3)!

        XCTAssertEqual(hull.edgeCount, 6)
        XCTAssertEqual(hull.faceCount, 3)
        hull.killEV(e4)
        XCTAssertEqual(hull.edgeCount, 6)
        XCTAssertEqual(hull.faceCount, 3)
        hull.killEF(e4)
        XCTAssertEqual(hull.edgeCount, 5)
        XCTAssertEqual(hull.faceCount, 2)
        e = HalfEdge(hull: hull, id: e0)
        XCTAssertEqual(e.next!.id, e5)
        XCTAssertEqual(e.next!.next!.id, e2)

        hull.killEF(e5)
        XCTAssertEqual(hull.edgeCount, 4)
        XCTAssertEqual(hull.faceCount, 1)
        e = HalfEdge(hull: hull, id: e0)
        XCTAssertEqual(e.next!.id, e3)
        XCTAssertEqual(e.prev!.id, e2)
        XCTAssertEqual(e.next!.next!.id, e1)
        XCTAssertEqual(e.next!.next!.next!.id, e2)

        hull.killEF(e0)
        XCTAssertEqual(hull.edgeCount, 3)
        XCTAssertEqual(hull.faceCount, 0)
        e = HalfEdge(hull: hull, id: e1)
        for eg in e.face!.edges.sequence {
            XCTAssert(eg.face!.isNull)
        }
        for eg in e.mate!.face!.edges.sequence {
            XCTAssert(eg.face!.isNull)
        }
    }

    func testKillEmakeR() {
        let hull = Hull2D.empty
        let e0 = hull.makeVEFS(Point2D(-2, -2), Point2D(2, -2))
        var e = HalfEdge(hull: hull, id: e0)
        let e1 = hull.makeEV(Point2D(-2, 2), e0)
        let e2 = hull.makeEV(Point2D(2, 2), e1)
        let e3 = hull.makeEF(e2, e.mate!.id)!
        e = HalfEdge(hull: hull, id: e3)
        let f0 = e.face

        let es = e.face!.edges.sequence
        for eg in es {
            XCTAssertEqual(eg.face, f0)
            XCTAssert(eg.mate!.face!.isNull)
        }
        XCTAssertEqual(e.next!.id, e2)
        XCTAssertEqual(e.next!.next!.id, e1)
        XCTAssertEqual(e.next!.next!.next!.id, e0)
        XCTAssertEqual(e.next!.next!.next!.next!.id, e3)

        let e4 = hull.makeEV(Point2D(-1, -1), e0)
        e = HalfEdge(hull: hull, id: e4)
        XCTAssertEqual(e.face, e.mate?.face)
        XCTAssertEqual(e.face, f0)
        XCTAssertEqual(e.next!.id, e0)

        let ie0 = hull.makeEV(Point2D(1, -1), e4)
        let ie1 = hull.makeEV(Point2D(1, 1), ie0)
        let ie2 = hull.makeEV(Point2D(-1, 1), ie1)
        e = HalfEdge(hull: hull, id: ie0)
        let ie3 = hull.makeEF(e.mate!.id, ie2)!
        e = HalfEdge(hull: hull, id: ie3).mate!
        XCTAssertEqual(e.face, f0)
        XCTAssertEqual(e.prev!.mate!.id, e4)
        XCTAssertEqual(e.prev!.prev!.id, e1)
        XCTAssertEqual(e.prev!.mate!.next!.id, e0)

        hull.killEmakeR(e4)
        e = HalfEdge(hull: hull, id: e0)
        XCTAssertEqual(e.prev!.id, e1)
        XCTAssertEqual(hull.edgeCount, 8)
        XCTAssertEqual(hull.vertexCount, 8)
        XCTAssertEqual(hull.faceCount, 2)

        let ie4 = hull.makeEkillR(ie1, e2)!
        e = HalfEdge(hull: hull, id: ie4)
        XCTAssertEqual(e.face, f0)
        XCTAssertEqual(e.next!.id, e2)
        XCTAssertEqual(e.prev!.id, ie2)
        XCTAssertEqual(e.mate!.next!.id, ie1)
        XCTAssertEqual(e.mate!.prev!.id, e3)
    }

    func testKillFmakeRH() {
        let hull = Hull2D.empty
        let e0 = hull.makeVEFS(Point2D(-2, -2), Point2D(2, -2))
        let e1 = hull.makeEV(Point2D(-2, 2), e0)
        let e2 = hull.makeEV(Point2D(2, 2), e1)
        var e = HalfEdge(hull: hull, id: e0)
        XCTAssert(e.isValid)
        let _ = hull.makeEF(e2, e.mate!.id)
        let e4 = hull.makeEV(Point2D(-1, -1), e0)
        let ie0 = hull.makeEV(Point2D(1, -1), e4)
        let ie1 = hull.makeEV(Point2D(1, 1), ie0)
        let ie2 = hull.makeEV(Point2D(-1, 1), ie1)
        e = HalfEdge(hull: hull, id: ie0)
        let ie3 = hull.makeEF(e.mate!.id, ie2)!
        hull.killEmakeR(e4)
        e = HalfEdge(hull: hull, id: e0)
        hull.killFmakeRH(ie3, e.mate!.id)
        e = HalfEdge(hull: hull, id: ie3)
        XCTAssert(e.face!.isNull)
    }
}

class ModelingTests: XCTestCase {

    func testFromPolygon() {
        let poly = Polygon(Point2D(1, 1), Point2D(-1, 1), Point2D(-1, -1), Point2D(1, -1))
        let f = Hull.from(polygon: poly)!
        XCTAssertFalse(f.isNull)
        let hull = f.hull
        XCTAssertEqual(hull.faceCount, 1)
        XCTAssertEqual(hull.vertexCount, 4)
        XCTAssertEqual(hull.edgeCount, 4)
        let e = f.edge
        XCTAssertEqual(e.origin!.position!, Point2D(1, 1))
        XCTAssertEqual(e.target!.position!, Point2D(-1, 1))
        XCTAssertEqual(e.prev!.origin!.position!, Point2D(1, -1))
        XCTAssertEqual(e.prev!.prev!.origin!.position!, Point2D(-1, -1))
        XCTAssertEqual(e.prev!.prev, e.next!.next)
    }

    func testSplitFace() {
        let poly = Polygon(Point2D(1, 1), Point2D(-1, 1), Point2D(-1, -1), Point2D(1, -1))
        let f = Hull.from(polygon: poly)!
        let v = f.split(at: Point2D(0, 0))!
        XCTAssert(v.isValid)
        XCTAssert(f.isValid)
        XCTAssertEqual(v.position!, Point2D(0, 0))
        let hull = f.hull
        XCTAssertEqual(hull.faceCount, 4)
        XCTAssertEqual(hull.vertexCount, 5)
        XCTAssertEqual(hull.edgeCount, 8)
        XCTAssertEqual(v.position!, Point2D(0, 0))
        XCTAssert(f.vertices.sequence.contains(v))
    }

    // splitFace, killVertex

    func testPerformance() {
        // Millions of faces.
    }
}

class HullTests: XCTestCase {

    func testEdgeSequnce() {
        let points = [Point2D(1, 1), Point2D(-1, 1), Point2D(-1, -1), Point2D(1, -1)]
        let f = Hull.from(polygon: Polygon(points: points))!
        let vertices = f.hull.edges.map { $0.origin!.id }
        XCTAssertEqual(vertices.count, f.hull.edgeCount)
    }

    func testVertexArray() {
        let points = [Point2D(1, 1), Point2D(-1, 1), Point2D(-1, -1), Point2D(1, -1)]
        let f = Hull.from(polygon: Polygon(points: points))!
        XCTAssertEqual(points, f.hull.vertices)
    }

    func testFaces() {
        let points = [Point2D(1, 1), Point2D(-1, 1), Point2D(-1, -1), Point2D(1, -1)]
        let f = Hull.from(polygon: Polygon(points: points))!
        let _ = f.split(at: Point2D(0, 0))
        XCTAssertEqual(f.hull.faces.1.count, 12)
    }

    func testLines() {
        let points = [Point2D(1, 1), Point2D(-1, 1), Point2D(-1, -1), Point2D(1, -1)]
        let f = Hull.from(polygon: Polygon(points: points))!
        XCTAssertEqual(f.hull.lines.1.count, 8)
        let _ = f.split(at: Point2D(0, 0))
        XCTAssertEqual(f.hull.lines.1.count, 16)
    }
}

class CirculatorTests: XCTestCase {

    func testSequence() {
        let poly = Polygon(Point2D(1, 1), Point2D(-1, 1), Point2D(-1, -1), Point2D(1, -1))
        let f = Hull.from(polygon: poly)!
        let v = f.split(at: Point2D(0, 0))!

        let vfs = v.faces.sequence.map { $0 }
        XCTAssertEqual(vfs.count, 4)
        XCTAssert(vfs.contains(f))
        let ves = v.edges.sequence.map { $0 }
        XCTAssertEqual(ves.count, 4)
        XCTAssert(ves.contains(f.edge.next!.mate!))
        XCTAssert(ves.contains(f.edge.prev!))
        let vns = v.neighbors.sequence.map { $0.position! }
        XCTAssertEqual(vns.count, 4)
        XCTAssert(vns.contains(Point2D(1, 1)))
        XCTAssert(vns.contains(Point2D(-1, 1)))
        XCTAssert(vns.contains(Point2D(-1, -1)))
        XCTAssert(vns.contains(Point2D(-1, 1)))

        let fvs = f.vertices.sequence.map { $0 }
        XCTAssertEqual(fvs.count, 3)
        XCTAssert(fvs.contains(v))
        let fes = f.edges.sequence.map { $0 }
        XCTAssertEqual(fes.count, 3)
        XCTAssert(fes.contains(f.edge))
        let fns = f.neighbors.sequence.filter { !$0.isNull }.map { $0 }
        XCTAssertEqual(fns.count, 2)
    }

    func testInvalidReference() {
        // TODO:
    }
}
