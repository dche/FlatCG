//
// FlatCG - Transform.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

/// Transformation over Euclidean vector space.
public struct Transform<T: Point> {

    public typealias PointType = T

    public typealias MatrixType = T.TransformMatrixType

    /// The transformation matrix.
    public let matrix: MatrixType

    /// The inverse transformation matrix.
    public let invMatrix: MatrixType

    init (matrix: MatrixType, invMatrix: MatrixType) {
        self.matrix = matrix
        self.invMatrix = invMatrix
    }

    public func compose(_ other: Transform<T>) -> Transform<T> {
        return Transform(
            matrix: other.matrix * self.matrix,
            invMatrix: self.invMatrix * other.invMatrix
        )
    }

    /// The inverse transformation of `self`.
    public var inverse: Transform<T> {
        return Transform(matrix: self.invMatrix, invMatrix: self.matrix)
    }

    /// The `identity` transformation.
    public static var identity: Transform<T> {
        return Transform(
            matrix: MatrixType.identity,
            invMatrix: MatrixType.identity
        )
    }
}

extension Transform: Equatable {

    public static func ==<T: Point> (lhs: Transform<T>, rhs: Transform<T>) -> Bool {
        return lhs.matrix == rhs.matrix
    }
}

public typealias Transform2D = Transform<Point2D>
public typealias Transform3D = Transform<Point3D>
