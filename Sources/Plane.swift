//
// FlatCG - Plane.swift
//
// Copyright (c) 2016 The GLMath authors.
// Licensed under MIT License.

import simd
import GLMath

/// Plane in 3D Euclidean space.
public struct Plane: Equatable {

    /// Plane normal.
    public let normal: Normal3D

    /// Distance from origin point to the plane.
    public let t: Float

    /// Constructs a `Plane`.
    ///
    /// - parameter normal:
    /// - parameter t:
    public init (normal: Normal3D, t: Float) {
        self.normal = normal
        self.t = t
    }

    /// Constructs a `Plane` with factors of a plane equation:
    /// `a * x + b * y + c * z = d`.
    public init? (a: Float, b: Float, c: Float, d: Float) {
        let v = vec3(a, b, c)
        guard !(v ~== vec3.zero) else { return nil }
        self.normal = Normal(v)
        self.t = d / v.length
    }

    public static func == (lhs: Plane, rhs: Plane) -> Bool {
        return lhs.normal == rhs.normal && lhs.t == rhs.t
    }

    public static prefix func - (rhs: Plane) -> Plane {
        return Plane(normal: -rhs.normal, t: rhs.t)
    }
}

extension Plane: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Plane(normal: \(normal), t: \(t))"
    }
}

// MARK: Plane point relationship.

extension Plane {

    /// Returns the signed distance from `point` to `self`.
    public func distanceTo(point: Point3D) -> Float {
        return point.vector.dot(self.normal.vector) + self.t
    }

    /// Returns `true` if `point` is on the `Plane`.
    public func contains(point: Point3D) -> Bool {
        return point.vector.dot(self.normal.vector) ~== -self.t
    }
}

extension Point3D {

    /// Returns the signed distance from `self` to `plane`.
    public func distanceTo(plane: Plane) -> Float {
        return plane.distanceTo(point: self)
    }

    /// Returns `true` if the receiver is inside of the positive half space
    /// of `plane`.
    public func inside(plane: Plane) -> Bool {
        return plane.distanceTo(point: self) > 0
    }
}

// MARK: Plane line relationship.

// TODO: 
