//
// FlatCG - Line.swift
//
// Copyright (c) 2016 The GLMath authors.
// Licensed under MIT License.

import simd
import GLMath

/// Line `Segment` in Euclidean space.
public struct Segment<PointType: Point> {

    public typealias DirectionType = Normal<PointType>

    /// Start point.
    public let start: PointType

    /// End point.
    public let end: PointType

    /// Direction from start point to end point.
    public var direction: DirectionType {
        return DirectionType(end - start)
    }

    /// Length of the segment.
    public var length: PointType.VectorType.Component {
        return start.distance(to: end)
    }

    /// Constructs a line segment.
    ///
    /// Returns `nil` if the `startPoint` and `endPoint` are too close.
    public init? (startPoint: PointType, endPoint: PointType) {
        let v = endPoint - startPoint
        guard !(dot(v, v) ~== 0) else {
            return nil
        }
        self.start = startPoint
        self.end = endPoint
    }
}

extension Segment: Equatable {
    public static func == (lhs: Segment, rhs: Segment) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}

extension Segment {

    /// Minimal distance from a `point` to the line segment.
    public func distance(to point: PointType) -> PointType.VectorType.Component {
        let vp = point - self.start
        let vl = self.end - self.start
        let v = vp.projection(on: vl)
        // `v` is perpendicular to `vl`.
        guard !v.isZero else {
            return vp.length
        }
        if v.squareLength < vl.squareLength && (vl - v).squareLength < vl.squareLength {
            let ln = Line<PointType>(origin: start, direction: DirectionType(vl))
            return ln.distance(to: point)
        }
        if v.dot(vl) <= 0 {
            return point.distance(to: self.start)
        }
        return point.distance(to: self.end)
    }

    public static prefix func - (rhs: Segment) -> Segment {
        return Segment(startPoint: rhs.end, endPoint: rhs.start)!
    }
}

extension Segment: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Segment(start: \(start), end: \(end))"
    }
}

/// Strait line in Euclidean space.
public struct Line<PointType: Point> {

    public typealias DirectionType = Normal<PointType>

    /// A point on the line.
    public let origin: PointType

    /// Direction of the `Line`.
    public let direction: DirectionType

    /// Constructs a `Line` with given `origin` and `direction`.
    public init (origin: PointType, direction: DirectionType) {
        self.origin = origin
        self.direction = direction
    }

    public init? (origin: PointType, to: PointType) {
        guard let seg = Segment<PointType>(startPoint: origin, endPoint: to) else {
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

public typealias Ray = Line3D

// MARK: Line point relationship.

extension Line {

    /// Returns the point on the line that
    public func point(at t: PointType.VectorType.Component) -> PointType {
        return origin + direction.vector * t
    }

    /// Returns the minimal distance from `point` to the receiver.
    public func distance(to point: PointType) -> PointType.VectorType.Component {
        let v = point - self.origin
        let cos = dot(self.direction.vector, normalize(v))
        return sqrt(v.dot(v) * (1 - cos * cos))
    }
}
