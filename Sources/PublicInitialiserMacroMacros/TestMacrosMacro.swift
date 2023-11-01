import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct PublicInitialiser: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
            throw PublicInitialiserErrors.nonClassStructType
        }
        
        let isTypePublic = declaration.modifiers
            .compactMap({$0.as(DeclModifierSyntax.self)})
            .contains(where: { $0.name.text == "public" })
        
        guard isTypePublic else {
            throw PublicInitialiserErrors.nonPublicType
        }
        
        let hasPublicParameterlessInitialiser = declaration.memberBlock.members
            .compactMap({ $0.decl.as(InitializerDeclSyntax.self) })
            .contains(where: { initDecl in
                initDecl.modifiers.contains(where: { $0.name.text == "public" }) &&
                initDecl.signature.parameterClause.parameters.isEmpty
            })
            
        guard !hasPublicParameterlessInitialiser else {
            context.diagnose(Diagnostic(node: node, message: PublicInitialiserAlreadyExistsDiagMessage()))
            return []
        }
        
        let initDecl = DeclSyntax("public init() {}")
        
        return [initDecl]
    }
}

@main
struct PublicInitialiserMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PublicInitialiser.self
    ]
}

enum PublicInitialiserErrors: CustomStringConvertible, Error {
    case nonPublicType
    case nonClassStructType
    
    var description: String {
        switch self {
            case .nonPublicType: "@PublicInitialiser can only be applied to a public type"
            case .nonClassStructType: "@PublicInitialiser can only be applied to a class or a struct"
        }
    }
}

struct PublicInitialiserAlreadyExistsDiagMessage: DiagnosticMessage {
    var message: String = "A public, parameterless parameter already exists"
    var diagnosticID = MessageID(domain: "", id: "")
    var severity = DiagnosticSeverity.warning
}
