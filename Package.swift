//
// FlatCG - Package.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import PackageDescription

let package = Package(
    name: "FlatCG",
    dependencies: [
        .Package(url: "https://github.com/dche/GLMath.git",
                 majorVersion: 0),
    ]
)
