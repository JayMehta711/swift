// RUN: %empty-directory(%t)

// Resilient protocol definition
// RUN: %target-swift-frontend -emit-ir -enable-resilience -module-name=resilient_protocol %S/../Inputs/resilient_protocol.swift | %FileCheck -check-prefix=CHECK-DEFINITION %s

// Resilient protocol usage
// RUN: %target-swift-frontend -emit-module -enable-resilience -emit-module-path=%t/resilient_protocol.swiftmodule -module-name=resilient_protocol %S/../Inputs/resilient_protocol.swift

// RUN: %target-swift-frontend -I %t -emit-ir -enable-resilience -assume-parsing-unqualified-ownership-sil %s | %FileCheck %s -DINT=i%target-ptrsize -check-prefix=CHECK-USAGE

// ----------------------------------------------------------------------------
// Resilient protocol definition
// ----------------------------------------------------------------------------

// Protocol descriptor
// CHECK-DEFINITION-LABEL: @"$S18resilient_protocol29ProtocolWithAssocTypeDefaultsMp" ={{( protected)?}} constant
// CHECK-DEFINITION-SAME: $S2T118resilient_protocol29ProtocolWithAssocTypeDefaultsPTM
// CHECK-DEFINITION-SAME: $S2T218resilient_protocol29ProtocolWithAssocTypeDefaultsPTM

// Protocol requirements base descriptor
// CHECK-DEFINITION: @"$S18resilient_protocol21ResilientBaseProtocolTL" ={{( dllexport)?}}{{( protected)?}} alias %swift.protocol_requirement, getelementptr (%swift.protocol_requirement, %swift.protocol_requirement* getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, %swift.protocol_requirement }>, <{ i32, i32, i32, i32, i32, i32, %swift.protocol_requirement }>* @"$S18resilient_protocol21ResilientBaseProtocolMp", i32 0, i32 6), i32 -1)

// Associated type requirement aliases

// CHECK-DEFINITION: @"$S1T18resilient_protocol24ProtocolWithRequirementsPTl" ={{( dllexport)?}}{{( protected)?}} alias

// Default associated type witnesses
// CHECK-DEFINITION-LABEL: define internal swiftcc %swift.metadata_response @"$S2T118resilient_protocol29ProtocolWithAssocTypeDefaultsPTM"

// CHECK-DEFINITION-LABEL: define internal swiftcc %swift.metadata_response @"$S2T218resilient_protocol29ProtocolWithAssocTypeDefaultsPTM"
// CHECK-DEFINITION: getelementptr inbounds i8*, i8** [[WTABLE:%.*]], i32 1
// CHECK-DEFINITION: call{{.*}}S18resilient_protocol7WrapperVMa

import resilient_protocol

// ----------------------------------------------------------------------------
// Resilient witness tables
// ----------------------------------------------------------------------------
// CHECK-USAGE-LABEL: $S31protocol_resilience_descriptors34ConformsToProtocolWithRequirementsVyxG010resilient_A00fgH0AAWr" = internal
// CHECK-USAGE-SAME: {{got.|__imp_}}$S1T18resilient_protocol24ProtocolWithRequirementsPTl
// CHECK-USAGE-SAME: $S31protocol_resilience_descriptors34ConformsToProtocolWithRequirementsVyxG010resilient_A00fgH0AA1TWt
public struct ConformsToProtocolWithRequirements<Element>
    : ProtocolWithRequirements {
  public typealias T = Element
  public func first() { }
  public func second() { }
}

public protocol P { }
public struct ConditionallyConforms<Element> { }
public struct Y { }

// CHECK-USAGE: @"$Sx1T_MXA" =
// CHECK-USAGE-SAME: i32 0
// CHECK-USAGE-SAME: @"{{got.|__imp_}}$S18resilient_protocol24ProtocolWithRequirementsMp"
// CHECK-USAGE-SAME: @"$Sx1T_MXA"
// CHECK-USAGE-SAME: %swift.protocol_requirement** @"{{got.|__imp_}}$S1T18resilient_protocol24ProtocolWithRequirementsPTl"

// CHECK-USAGE: @"$S31protocol_resilience_descriptors21ConditionallyConformsVyxG010resilient_A024ProtocolWithRequirementsAaeFRzAA1YV1TRtzlMc"
extension ConditionallyConforms: ProtocolWithRequirements
where Element: ProtocolWithRequirements, Element.T == Y {
  public typealias T = Element.T
  public func first() { }
  public func second() { }
}

// ----------------------------------------------------------------------------
// Resilient protocol usage
// ----------------------------------------------------------------------------

// CHECK-USAGE: define{{( dllexport)?}}{{( protected)?}} swiftcc %swift.type* @"$S31protocol_resilience_descriptors17assocTypeMetadatay1TQzmxm010resilient_A024ProtocolWithRequirementsRzlF"(%swift.type*, %swift.type* [[PWD:%.*]], i8** [[WTABLE:%.*]])
public func assocTypeMetadata<PWR: ProtocolWithRequirements>(_: PWR.Type) -> PWR.T.Type {
  // CHECK-USAGE: [[WITNESS_ADDR:%.*]] = getelementptr inbounds i8*, i8** %PWR.ProtocolWithRequirements, [[INT]] udiv ([[INT]] sub ([[INT]] ptrtoint (%swift.protocol_requirement* @"$S1T18resilient_protocol24ProtocolWithRequirementsPTl" to [[INT]]), [[INT]] ptrtoint (%swift.protocol_requirement* @"$S18resilient_protocol24ProtocolWithRequirementsTL" to [[INT]])), [[INT]] 8
  // CHECK-USAGE: load i8*, i8** [[WITNESS_ADDR]], align {{(4|8)}}
  return PWR.T.self
}
