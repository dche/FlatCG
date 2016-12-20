//
// FlatCG - Sphere.swift
//
// Copyright (c) 2016 The GLMath authors.
// Licensed under MIT License.

import GLMath

/// The (_n-sphere_)[https://en.wikipedia.org/wiki/N-sphere], which is the
/// generalized concept of circle and sphere.
public struct Nsphere<T: Point>: Equatable, CustomDebugStringConvertible {

    /// Center of the n-sphere.
    public let center: T

    /// Radius of the n-sphere.
    public let radius: T.VectorType.Component

    /// Constructs a `Nsphere` with given `center` and `radius`.
    ///
    /// Returns `nil` if `radius` is negative.
    public init? (center: T, radius: T.VectorType.Component) {
        guard radius >= 0 else { return nil }

        self.center = center
        self.radius = radius
    }
}

extension Nsphere {

    public static func == (lhs: Nsphere, rhs: Nsphere) -> Bool {
        return lhs.center == rhs.center && lhs.radius == rhs.radius
    }

    public var debugDescription: String {
        return "Nsphere(center: \(center), radius: \(radius))"
    }
}

// MARK: Sphere point relationship.

extension Nsphere {

    /// Returns `true` if the `point` is inside the receiver.
    public func contains(point: T) -> Bool {
        return (point - self.center).squareLength < self.radius * self.radius
    }
}

extension Nsphere where T.VectorType: Vector2 {

    public init? (
        x: T.VectorType.Component,
        y: T.VectorType.Component,
        radius: T.VectorType.Component
    ) {
        self.init(center: T(T.VectorType(x, y)), radius: radius)
    }
}

extension Nsphere where T.VectorType: Vector3 {

    public init? (
        x: T.VectorType.Component,
        y: T.VectorType.Component,
        z: T.VectorType.Component,
        radius: T.VectorType.Component
    ) {
        self.init(center: T(T.VectorType(x, y, z)), radius: radius)
    }
}

public typealias Circle = Nsphere<Point2D>
public typealias Sphere = Nsphere<Point3D>
