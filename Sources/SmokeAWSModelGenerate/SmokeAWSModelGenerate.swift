// Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//
// SmokeAWSModelGenerate.swift
// SmokeAWSModelGenerate
//

import Foundation
import ServiceModelCodeGeneration
import ServiceModelEntities
import CoralToJSONServiceModel
import ServiceModelGenerate

public struct SmokeAWSModelGenerate {
    static let asyncResultType = AsyncResultType(typeName: "HTTPResult",
                                                 libraryImport: "SmokeHTTPClient")
    
    public static func generateFromModel(
        modelFilePath: String,
        customizations: CodeGenerationCustomizations,
        applicationDescription: ApplicationDescription,
        modelOverride: ModelOverride?,
        signAllHeaders: Bool) throws {
            func generatorFunction(codeGenerator: ServiceModelCodeGenerator,
                                   serviceModel: CoralToJSONServiceModel) throws {
                try codeGenerator.generateFromCoralToJSONServiceModel(
                    coralToJSONServiceModel: serviceModel,
                    signAllHeaders: signAllHeaders
                )
            }
        
            try ServiceModelGenerate.generateFromModel(
                    modelFilePath: modelFilePath,
                    customizations: customizations,
                    applicationDescription: applicationDescription,
                    modelOverride: modelOverride,
                    generatorFunction: generatorFunction)
    }
}

extension ServiceModelCodeGenerator {
    
    func generateFromCoralToJSONServiceModel(
            coralToJSONServiceModel: CoralToJSONServiceModel,
            signAllHeaders: Bool) throws {
        let awsClientAttributes = coralToJSONServiceModel.getAWSClientAttributes()
        
        let clientProtocolDelegate = ClientProtocolDelegate(
            baseName: applicationDescription.baseName,
            asyncResultType: SmokeAWSModelGenerate.asyncResultType)
        let mockClientDelegate = MockClientDelegate(
            baseName: applicationDescription.baseName,
            isThrowingMock: false,
            asyncResultType: SmokeAWSModelGenerate.asyncResultType)
        let throwingClientDelegate = MockClientDelegate(
            baseName: applicationDescription.baseName,
            isThrowingMock: true,
            asyncResultType: SmokeAWSModelGenerate.asyncResultType)
        let awsClientDelegate = AWSClientDelegate(
            baseName: applicationDescription.baseName,
            clientAttributes: awsClientAttributes,
            asyncResultType: SmokeAWSModelGenerate.asyncResultType,
            signAllHeaders: signAllHeaders)
        let awsModelErrorsDelegate = AWSModelErrorsDelegate(awsClientAttributes: awsClientAttributes)
        
        generateClient(delegate: clientProtocolDelegate)
        generateClient(delegate: mockClientDelegate)
        generateClient(delegate: throwingClientDelegate)
        generateClient(delegate: awsClientDelegate)
        generateModelOperationsEnum()
        generateModelOperationClientInput()
        generateModelOperationClientOutput()
        generateModelStructures()
        generateModelTypes()
        generateModelErrors(delegate: awsModelErrorsDelegate)
        generateDefaultInstances(generationType: .internalTypes)
    }
}
