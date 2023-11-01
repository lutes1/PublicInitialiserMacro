// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: named(init))
public macro PublicInitialiser() = #externalMacro(module: "PublicInitialiserMacroMacros", type: "PublicInitialiser")
