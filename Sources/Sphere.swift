//
// FlatCG - Sphere.swift
//
// Copyright (c) 2016 The GLMath authors.
// Licensed under MIT License.

import GLMath

/// Sphere in 3D Euclidean space.
public struct Sphere: Equatable {

    /// Center point of the sphere.
    public let center: Point3D

    /// Radius of the sphere. This value could be `0`.
    public let radius: Float

    /// Constructs a `Sphere`.
    ///
    /// Returns `nil` if `radius` is negative.
    public init? (center: Point3D, radius: Float) {
        guard radius >= 0 else { return nil }

        self.center = center
        self.radius = radius
    }
}

extension Sphere {

    public init? (x: Float, y: Float, z: Float, radius: Float) {
        self.init(center: Point3D(x, y, z), radius: radius)
    }

    public static func == (lhs: Sphere, rhs: Sphere) -> Bool {
        return lhs.center == rhs.center && lhs.radius == rhs.radius
    }
}

extension Sphere: Interpolatable {

    public typealias NumberType = Point3D.NumberType

    public func interpolate(between other: Sphere, t: Float) -> Sphere {
        let c = self.center.interpolate(between: other.center, t: t)
        let r = max(self.radius.interpolate(between: other.radius, t: t), 0)
        return Sphere(center: c, radius: r)!
    }
}

extension Sphere: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Sphere(center: \(center), radius: \(radius))"
    }
}

// MARK: Sphere point relationship.

extension Sphere {

    /// Returns `true` if the `point` is inside the receiver.
    public func contains(point: Point3D) -> Bool {
        return (point - self.center).squareLength < self.radius * self.radius
    }
}
