
import XCTest
import GLMath
@testable import FlatCG

class PoseTests: XCTestCase {

    struct Cam: HasPose {

        // SWIFT EVOLUTION: Should not to specify `PointType` and `RotationType`.

        typealias PoseType = Pose3D

        typealias PointType = Point3D

        typealias RotationType = Quaternion

        var pose = Pose3D()

        static func == (lhs: Cam, rhs: Cam) -> Bool {
            return lhs.pose == rhs.pose
        }
    }

    func testMove() {
        var cam = Cam()
        cam.move(to: Point3D(1, 2, 3))
        XCTAssertEqual(cam.position, Point3D(1, 2, 3))
        cam.move(vec3(-1, 0, 0))
        XCTAssertEqual(cam.position.x, 0)
    }

    func testRotation() {
        var cam = Cam()
        let q = Quaternion(axis: vec3(0, 1, 0), angle: .half_pi)
        cam.rotate(to: q)
        cam.rotate(q)
        XCTAssert(cam.rotation.isClose(to: q * q, tolerance: .epsilon))
    }

    func testDirection() {
        var cam = Cam()
        XCTAssertEqual(cam.direction, Pose3D.initialDirection)
        let q = Quaternion(axis: vec3(0, 1, 0), angle: .half_pi)
        cam.rotate(to: q)
        XCTAssert(cam.direction.vector.isClose(to: vec3(-1, 0, 0), tolerance: .epsilon * 10))

        // TODO: Test set `direction`.
    }

    func testRightDirection() {
        var cam = Cam()
        XCTAssertEqual(cam.rightDirection, Pose3D.initialRightDirection)
        let q = Quaternion(axis: vec3(0, 1, 0), angle: .half_pi)
        cam.rotate(to: q)
        XCTAssert(cam.rightDirection.vector.isClose(to: Pose3D.initialDirection.vector, tolerance: .epsilon * 10))
    }

    func testUpDirection() {
        var cam = Cam()
        XCTAssertEqual(cam.upDirection, Normal(0, 1, 0))
        let q = Quaternion(axis: vec3(0, 1, 0), angle: .half_pi)
        cam.rotate(to: q)
        XCTAssert(cam.upDirection.vector.isClose(to: vec3(0, 1, 0), tolerance: .epsilon * 100))
    }
}
