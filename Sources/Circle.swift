//
// FlatCG - Circle.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import GLMath

/// A 2D circle.
public struct Circle: Equatable {

    /// Center of the circle.
    public let center: Point2D

    /// Radius of the circle.
    public let radius: Float

    /// Constructs a `Circle` with given `center` and `radius`.
    ///
    /// Returns `nil` if `radius` is negative.
    public init? (center: Point2D, radius: Float) {
        guard radius >= 0 else { return nil }

        self.center = center
        self.radius = radius
    }
}

extension Circle {

    public init? (x: Float, y: Float, radius: Float) {
        self.init(center: Point2D(x, y), radius: radius)
    }

    public static func == (lhs: Circle, rhs: Circle) -> Bool {
        return lhs.center == rhs.center && lhs.radius == rhs.radius
    }
}

extension Circle: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Circle(center: \(center), radius: \(radius))"
    }
}

extension Circle: Interpolatable {

    public typealias NumberType = Point2D.NumberType

    public func interpolate(between other: Circle, t: Float) -> Circle {
        let c = self.center.interpolate(between: other.center, t: t)
        let r = max(self.radius.interpolate(between: other.radius, t: t), 0)
        return Circle(center: c, radius: r)!
    }
}

extension Circle {

    /// Retruns `true` if `point` is inside the receiver.
    public func contains(point: Point2D) -> Bool {
        return (point - self.center).squareLength < self.radius * self.radius
    }
}
