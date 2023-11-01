import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftDiagnostics

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(PublicInitialiserMacroMacros)
import PublicInitialiserMacroMacros

let PublicInitialiserMacro: [String: Macro.Type] = [
    "PublicInitialiser": PublicInitialiser.self
]
#endif

final class PublicInitialiserMacroTests: XCTestCase {
    func testPublicInitMacro() {
        assertMacroExpansion(
            """
            @PublicInitialiser
            public class Foo {
            }
            """,
            expandedSource:  """
            public class Foo {
            
                public init() {
                }
            }
            """,
            macros: PublicInitialiserMacro
        )
    }
    
    func testPublicInitMacro_withExistingPublicInitiliser() {
        assertMacroExpansion(
            """
            @PublicInitialiser
            public class Foo {
                public init() { }
            }
            """,
            expandedSource:  """
            public class Foo {
                public init() { }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "A public, parameterless parameter already exists", line: 1, column: 1, severity: DiagnosticSeverity.warning)
            ],
            macros: PublicInitialiserMacro
        )
    }
    
    func testPublicInitMacro_withExistingPublicInitiliser_withParameters() {
        assertMacroExpansion(
            """
            @PublicInitialiser
            public class Foo {
                public init(param: Int) { }
            }
            """,
            expandedSource:  """
            public class Foo {
                public init(param: Int) { }
            
                public init() {
                }
            }
            """,
            macros: PublicInitialiserMacro
        )
    }
    
    func testPublicInitMacro_onAnInvalidType() {
        assertMacroExpansion(
            """
            @PublicInitialiser
            enum Foo {
            }
            """,
            expandedSource: """
            enum Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@PublicInitialiser can only be applied to a class or a struct", line: 1, column: 1)
            ],
            macros: PublicInitialiserMacro
        )
    }
}
