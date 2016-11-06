
import XCTest
import simd
import FlatUtil
import GLMath
@testable import FlatCG

class PlaneTests: XCTestCase {

    func testConstruction() {
        XCTAssertNil(Plane(a: 0, b: 0, c: Float(1).ulp * 0.1, d: 0))
        XCTAssertNotNil(Plane(a: 0, b: 0, c: Float(1).ulp * 10, d: 0))
    }

    func testDistanceToPoint() {
        let p = Plane(normal: Normal(1, 0, 0), t: 1)
        XCTAssert(p.contains(point: Point3D(-1, 0, 0)))
        XCTAssertEqual(p.distanceTo(point: Point3D(-1, 0, 0)), 0)
        XCTAssertEqual(Point3D(5, 5, 5).distanceTo(plane: p), 6)
    }

    func testContainsPoint() {
        let p = Plane(normal: Normal(0, 1, 0), t: -1)
        XCTAssert(p.contains(point: Point3D(0, 1, 0)))
    }

    func testInsidePlane() {
        let p = Plane(normal: Normal(0, 1, 0), t: -1)
        XCTAssert(Point3D(0, 2, 0).inside(plane: p))
    }
}
