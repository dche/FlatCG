//
// FlatCG - Pose.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

/// Types that describe poses of solid bodies in Euclidean space.
///
/// This type just records the amount of rotation from initial pose to the
/// final pose. How the rotation is performed is determined by the concrete
/// `RotationType`.
public protocol Pose: Equatable, CustomDebugStringConvertible {

    associatedtype PointType: Point

    associatedtype RotationType: Rotation

    /// Position.
    var position: PointType { get set }

    /// Amount of rotation from initial pose.
    var rotation: RotationType { get set }

    typealias DirectionType = Normal<PointType>

    static var initialDirection: DirectionType { get }

    static var initialRightDirection: DirectionType { get }

    /// Forward direction.
    var direction: DirectionType { get set }

    /// Right direction.
    var rightDirection: DirectionType { get set }

    //
    // var objectToWorldTransform: Transform<PointType> { get }

    /// Sets the forward direction to the vector from `position` to `at`.
    mutating func look(at: PointType)
}

extension Pose {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.position == rhs.position && lhs.rotation == rhs.rotation
    }

    public var debugDescription: String {
        return "Pose(position: \(self.position), rotation: \(self.rotation))"
    }
}
extension Pose {

    /// Changes `self`'s `position` to `point`.
    mutating public func move(to point: PointType) {
        self.position = point
    }

    /// Moves `self` from current position with `vector`'s direciton and
    /// length.
    mutating public func move(_ vector: PointType.VectorType) {
        self.move(to: self.position + vector)
    }
}

extension Pose where PointType.VectorType: FloatVector2 {

    /// Moves `self` along the `X` axis.
    mutating public func move(x: PointType.VectorType.Component) {
        self.move(PointType.VectorType(x, PointType.VectorType.Component.zero))
    }

    /// Moves `self` along the `Y` axis.
    mutating public func move(y: PointType.VectorType.Component) {
        self.move(PointType.VectorType(PointType.VectorType.Component.zero, y))
    }
}

extension Pose where PointType.VectorType: FloatVector3 {

    /// Moves `self` along the `X` axis.
    mutating public func move(x: PointType.VectorType.Component) {
        let zero = PointType.VectorType.Component.zero
        self.move(PointType.VectorType(x, zero, zero))
    }

    /// Moves `self` along the `Y` axis.
    mutating public func move(y: PointType.VectorType.Component) {
        let zero = PointType.VectorType.Component.zero
        self.move(PointType.VectorType(zero, y, zero))
    }

    /// Moves `self` along the `Z` axis.
    mutating public func move(z: PointType.VectorType.Component) {
        let zero = PointType.VectorType.Component.zero
        self.move(PointType.VectorType(zero, zero, z))
    }
}

extension Pose {

    /// Changes `self`'s `rotation` to a new value given by `rotation`.
    mutating public func rotate(to rotation: RotationType) {
        self.rotation = rotation
    }

    /// Adds `amount` of rotation to `self`.
    mutating public func rotate(_ amount: RotationType) {
        self.rotate(to: self.rotation.compose(amount))
    }
}

extension Pose where RotationType == Quaternion {

    mutating public func pitch(_ radian: Float) {
        self.rotate(Quaternion.pitch(radian))
    }

    mutating public func yaw(_ radian: Float) {
        self.rotate(Quaternion.yaw(radian))
    }

    mutating public func roll(_ radian: Float) {
        self.rotate(Quaternion.roll(radian))
    }
}

extension Pose where PointType == RotationType.PointType {

    mutating public func move(forward distance: DirectionType.Component) {
        move(direction.vector * distance)
    }

    mutating public func move(backward distance: DirectionType.Component) {
        move(forward: -distance)
    }

    mutating public func move(right distance: DirectionType.Component) {
        move(rightDirection.vector * distance)
    }

    mutating public func move(left distance: DirectionType.Component) {
        move(right: -distance)
    }
}

///
public protocol HasPose: Pose {

    associatedtype PoseType: Pose

    var pose: PoseType { get set }
}

extension HasPose where PointType == PoseType.PointType {

    public var position: PointType {
        get { return pose.position }
        set { pose.position = newValue }
    }

    public mutating func look(at point: PointType) {
        pose.look(at: point)
    }
}

extension HasPose where PointType == PoseType.PointType, RotationType == PoseType.RotationType {

    public var rotation: RotationType {
        get { return pose.rotation }
        set { pose.rotation = newValue }
    }

    public var direction: DirectionType {
        get {
            return pose.direction
        }
        set {
            pose.direction = newValue
        }
    }

    public var rightDirection: DirectionType {
        get {
            return pose.rightDirection
        }
        set {
            pose.rightDirection = newValue
        }
    }

    public static var initialDirection: DirectionType {
        return PoseType.initialDirection
    }

    public static var initialRightDirection: DirectionType {
        return PoseType.initialRightDirection
    }
}

/// Pose in 2D Euclidean space.
public struct Pose2D: Pose {

    public typealias PointType = Point2D

    public typealias RotationType = Rotation2D

    public var position: Point2D

    public var rotation: Rotation2D

    public var direction: Normal2D {
        get {
            return Normal(vector: rotation.apply(Pose2D.initialDirection.vector))
        }
        set {
            let v = newValue.vector
            let theta = atan2(v.y, v.x) + .tau - .half_pi
            self.rotation = Rotation2D(angle: theta)
        }
    }

    public var rightDirection: Normal2D {
        get {
            return Normal<Point2D>(vector: rotation.apply(Pose2D.initialRightDirection.vector))
        }
        set {
            let v = newValue.vector
            let theta = atan2(v.y, v.x) + .tau
            self.rotation = Rotation2D(angle: theta)
        }
    }

    public mutating func look(at point: Point2D) {
        self.direction = Normal(vector: point - self.position)
    }

    public static let initialDirection = Normal<Point2D>(vec2(0, 1))

    public static let initialRightDirection = Normal<Point2D>(vec2(1, 0))

    public init () {
        self.position = Point2D.origin
        self.rotation = Rotation2D.identity
    }
}

/// Pose in 3D Euclidean space.
public struct Pose3D: Pose {

    public typealias PointType = Point3D

    public typealias RotationType = Quaternion

    public var position: Point3D

    public var rotation: Quaternion

    mutating public func move(upward distance: Float) {
        move(upDirection.vector * distance)
    }

    mutating public func move(downward distance: Float) {
        move(upward: -distance)
    }

    public var direction: Normal3D {
        get {
            return Normal(vector: rotation.apply(Pose3D.initialDirection.vector))
        }
        set {
            self.rotate(Quaternion(fromDirection: self.direction, to: newValue))
        }
    }

    public var rightDirection: Normal3D {
        get {
            return Normal(vector: rotation.apply(Pose3D.initialRightDirection.vector))
        }
        set {
            self.rotate(Quaternion(fromDirection: self.rightDirection, to: newValue))
        }
    }

    public var upDirection: Normal3D {
        get {
            return Normal(vector: cross(rightDirection.vector, direction.vector))
        }
        set {
            self.rotate(Quaternion(fromDirection: self.upDirection, to: newValue))
        }
    }

    public mutating func look(at point: Point3D) {
        self.direction = Normal(vector: point - self.position)
    }

    public static let initialDirection = Normal<Point3D>(vec3(0, 0, -1))

    public static let initialRightDirection = Normal<Point3D>(vec3(1, 0, 0))

    public init () {
        self.position = Point3D.origin
        self.rotation = Quaternion.identity
    }
}

extension HasPose where PoseType == Pose3D, PointType == Point3D, RotationType == Quaternion {

    public var upDirection: DirectionType {
        get {
            return pose.upDirection
        }
        set {
            pose.upDirection = newValue
        }
    }
}
