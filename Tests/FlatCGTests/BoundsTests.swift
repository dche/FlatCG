
import XCTest
import simd
import FlatUtil
import GLMath
@testable import FlatCG

class BoundsTests: XCTestCase {

    func testOfPoints() {
        var points = [Point3D]()
        let n = 1_000
        for _ in 0 ..< n {
            points.append(Point3D(vec3.random()))
        }
        let b = Bounds3D(of: points)
        for i in 0 ..< n {
            XCTAssert(b.contains(point: points[i]))
        }
    }

    func testEmpty() {
        let b = Bounds3D.empty
        XCTAssert(b.isEmpty)
        XCTAssertFalse(b.contains(point: Point3D.origin))
        XCTAssertEqual(b.merge(b), b)
        XCTAssertEqual(b.surfaceArea, 0)
        XCTAssertEqual(b.diagnal, vec3.zero)
        XCTAssertEqual(b.center, Point3D.origin)
    }

    func testSingular() {
        let p = Point2D(2, 4)
        let b = Bounds2D(p)
        XCTAssert(b.contains(point: p))
        XCTAssertFalse(b.isEmpty)
        XCTAssertEqual(b.surfaceArea, 0)
        XCTAssertEqual(b.diagnal, vec2.zero)
        XCTAssertEqual(b.extent, vec2.zero)
        XCTAssertEqual(b.center, p)

        let nb = b.merge(point: Point2D.origin)
        XCTAssertEqual(nb.center, Point2D(1, 2))
    }

    func testContainsPoint() {
        let p0 = Point2D.origin
        let p1 = Point2D(-1, 2)
        let p2 = Point2D(3, 4)
        let b = Bounds2D(of: [p0, p1, p2])
        XCTAssert(b.contains(point: p0))
        XCTAssert(b.contains(point: p1))
        XCTAssert(b.contains(point: p2))
        XCTAssertFalse(b.contains(point: p1 + p2.vector))
        XCTAssert(b.contains(point: b.center))
    }

    func testCenter() {
        let b = Bounds2D(Point2D(-1, -1), Point2D(1, 1))
        XCTAssertEqual(b.center, Point2D.origin)
    }

    func testExtent() {
        let b = Bounds2D(Point2D(-1, -1), Point2D(1, 1))
        XCTAssertEqual(b.extent, vec2(1, 1))
    }

    func testSurfaceArea() {
        let b2 = Bounds2D(Point2D.origin, Point2D(1, 2))
        XCTAssertEqual(b2.surfaceArea, 2)
        let b3 = Bounds3D(Point3D.origin, Point3D(1, 2, 3))
        XCTAssertEqual(b3.surfaceArea, 22)
    }

    func testExpand() {
        var b = Bounds2D(Point2D(0, 0))
        b = b.expand(2)
        XCTAssertEqual(b.pmin, Point2D(-2, -2))
        XCTAssertEqual(b.pmax, Point2D(2, 2))
        let nb = b.expand(-2)
        XCTAssertEqual(b, nb)
    }

    func testTransform() {
        // 2D
        var b2 = Bounds2D(Point2D(0, 0), Point2D(1, 2))
        b2 = b2.translate(vec2(2, 3))
        XCTAssertEqual(b2.pmin, Point2D(2, 3))
        XCTAssertEqual(b2.pmax, Point2D(3, 5))
        b2 = b2.scale(x: 1, y: 2)
        XCTAssertEqual(b2.pmin, Point2D(2, 6))
        XCTAssertEqual(b2.pmax, Point2D(3, 10))
        b2 = b2.rotate(angle: .half_pi)
        XCTAssert(b2.pmin.isClose(to: Point2D(-10, 2), tolerance: .epsilon * 10))
        XCTAssert(b2.pmax.isClose(to: Point2D(-6, 3), tolerance: .epsilon))
        // 3D
        var b3 = Bounds3D(Point3D.origin, Point3D(1, 2, 3))
        b3 = b3.translate(vec3(2, 3, 4))
        XCTAssertEqual(b3.pmin, Point3D(2, 3, 4))
        XCTAssertEqual(b3.pmax, Point3D(3, 5, 7))
        b3 = b3.scale(0.5)
        XCTAssertEqual(b3.pmin, Point3D(1, 1.5, 2))
        XCTAssertEqual(b3.pmax, Point3D(1.5, 2.5, 3.5))
        b3 = b3.rotate(around: Normal3D(vec3.z), angle: .half_pi)
        XCTAssert(b3.pmin.isClose(to: Point3D(-2.5, 1, 2), tolerance: .epsilon * 100))
        XCTAssert(b3.pmax.isClose(to: Point3D(-1.5, 1.5, 3.5), tolerance: .epsilon * 10))
    }

    func testContainsPerformance() {
        // SWFIT EVOLUTION: If `Poitn2D` is used, it can be 2x slower!
        var points = [Point3D]()
        let n = 1_000_000
        for _ in 0 ..< n {
            points.append(Point3D(vec3.random()))
        }
        let b = Bounds3D(of: points)
        measure {
            for i in 0 ..< n {
                let _ = b.contains(point: points[i])
            }
        }
    }

    func testConstructionPerformance() {
        var points = [Point3D]()
        let n = 1_000_000
        for _ in 0 ..< n {
            points.append(Point3D(vec3.random()))
        }
        measure {
            let _ = Bounds3D(of: points)
        }
    }
}
