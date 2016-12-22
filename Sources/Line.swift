//
// FlatCG - Line.swift
//
// Copyright (c) 2016 The GLMath authors.
// Licensed under MIT License.

import simd
import GLMath

/// Strait line in Euclidean space.
public struct Line<T: Point> {

    public typealias DirectionType = Normal<T>

    /// A point on the line.
    public let origin: T

    /// Direction of the `Line`.
    public let direction: DirectionType

    /// Constructs a `Line` with given `origin` and `direction`.
    public init (origin: T, direction: DirectionType) {
        self.origin = origin
        self.direction = direction
    }

    public init? (origin: T, to: T) {
        guard let seg = Segment<T>(start: origin, end: to) else {
            return nil
        }
        self.init (origin: origin, direction: seg.direction)
    }

    public static prefix func - (rhs: Line) -> Line {
        return Line(origin: rhs.origin, direction: -rhs.direction)
    }
}

extension Line: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Line(origin: \(origin), direction: \(direction))"
    }
}

public typealias Line2D = Line<Point2D>

public typealias Line3D = Line<Point3D>

// MARK: Line point relationship.

extension Line {

    /// Returns the point on the line that
    public func point(at t: T.VectorType.Component) -> T {
        return origin + direction.vector * t
    }

    /// Returns the minimal distance from `point` to the receiver.
    public func distance(to point: T) -> T.VectorType.Component {
        let v = point - self.origin
        let cos = dot(self.direction.vector, normalize(v))
        return sqrt(v.dot(v) * (1 - cos * cos))
    }
}
