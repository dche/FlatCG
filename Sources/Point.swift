//
// FlatCG - Point.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

/// A point in Euclidean space.
public protocol Point: Equatable, ApproxEquatable, Interpolatable {

    /// `VectorType` determines the dimension and precision of a `Point`.
    associatedtype VectorType: FloatVector

    typealias Component = VectorType.Component

    // SWIFT EVOLUTION: Constraints between `VectorType` and `TransformMatrixType`
    //                  can not be defined.

    /// Type of affine transformation matrix.
    associatedtype TransformMatrixType: GenericSquareMatrix

    /// Vector representation of a `Point`.
    var vector: VectorType { get set }

    static func + (lhs: Self, rhs: VectorType) -> Self

    static func - (lhs: Self, rhs: Self) -> VectorType

    /// Constructs a point from a vector.
    init (_ vector: VectorType)

    /// The _origin_ point.
    static var origin: Self { get }
}

extension Point  {

    public static var origin: Self {
        return self.init(VectorType.zero)
    }

    /// Returns the distance from `self` to another point.
    public func distance(to: Self) -> Component {
        return self.vector.distance(to: to.vector)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.vector == rhs.vector
    }

    public static func + (lhs: Self, rhs: Self.VectorType) -> Self {
        return Self(lhs.vector + rhs)
    }

    public static func - (lhs: Self, rhs: Self) -> Self.VectorType {
        return lhs.vector - rhs.vector
    }
}

/// Point in 2D Euclidean space.
public struct Point2D: Point {

    public typealias VectorType = vec2
    public typealias TransformMatrixType = mat3

    public var vector: vec2

    public var x: Float {
        get { return vector.x }
        set { vector.x = newValue }
    }
    public var y: Float {
        get { return vector.y }
        set { vector.y = newValue }
    }

    public init (_ vector: vec2) {
        self.vector = vector
    }

    public init (_ x: Float, _ y: Float) {
        self.vector = vec2(x, y)
    }
}

// SWIFT EVOLUTION: Should be able to just extend `Point`.

extension Point2D {

    public typealias NumberType = Float

    public func isClose(to other: Point2D, tolerance: Float) -> Bool {
        return self.vector.isClose(to: other.vector, tolerance: tolerance)
    }

    public func interpolate(between y: Point2D, t: Float) -> Point2D {
        return Point2D(self.vector.interpolate(between: y.vector, t: t))
    }
}

extension Point2D: CustomStringConvertible {

    public var description: String {
        return "Point2D(x: \(self.x), y: \(self.y))"
    }
}

/// Point in 3D Euclidean space.
public struct Point3D: Point {

    public typealias VectorType = vec3
    public typealias TransformMatrixType = mat4

    public var vector: vec3

    public var x: Float {
        get { return vector.x }
        set { vector.x = newValue }
    }

    public var y: Float {
        get { return vector.y }
        set { vector.y = newValue }
    }

    public var z: Float {
        get { return vector.z }
        set { vector.z = newValue }
    }

    public init (_ vector: vec3) {
        self.vector = vector
    }

    public init (_ x: Float, _ y: Float, _ z: Float) {
        vector = vec3(x, y, z)
    }
}

extension Point3D {

    public typealias NumberType = Float

    public func isClose(to other: Point3D, tolerance: Float) -> Bool {
        return self.vector.isClose(to: other.vector, tolerance: tolerance)
    }

    public func interpolate(between y: Point3D, t: Float) -> Point3D {
        return Point3D(self.vector.interpolate(between: y.vector, t: t))
    }
}

extension Point3D: CustomStringConvertible {

    public var description: String {
        return "Point2D(x: \(self.x), y: \(self.y), z: \(self.z))"
    }
}
