
import XCTest
import simd
import FlatUtil
import GLMath
@testable import FlatCG

class BoundsTests: XCTestCase {

    func testCenter() {
        let b = Bounds(Point2D(-1, -1), Point2D(1, 1))
        XCTAssertEqual(b.center, Point2D.origin)
    }

    func testExtent() {
        let b = Bounds(Point2D(-1, -1), Point2D(1, 1))
        XCTAssertEqual(b.extent, vec2(1, 1))
    }

    func testOfPoints() {
        var points = [Point3D]()
        let n = 1_000
        for _ in 0 ..< n {
            points.append(Point3D(vec3.random()))
        }
        let b = Bounds(of: points)!
        for i in 0 ..< n {
            XCTAssert(b.contains(point: points[i]))
        }
    }

    func testContainsPerformance() {
        var points = [Point3D]()
        let n = 1_000_000
        for _ in 0 ..< n {
            points.append(Point3D(vec3.random()))
        }
        let b = Bounds(of: points)!
        measure {
            for i in 0 ..< n {
                let _ = b.contains(point: points[i])
            }
        }
    }
}
