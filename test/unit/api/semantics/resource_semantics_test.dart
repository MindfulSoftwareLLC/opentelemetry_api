// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Resource Semantics', () {
    test('OTelSemanticExtension.toMapEntry should create a map entry with key and value', () {
      final entry = ClientResource.clientAddress.toMapEntry('127.0.0.1');
      expect(entry.key, equals('client.address'));
      expect(entry.value, equals('127.0.0.1'));
    });

    group('ClientResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(ClientResource.clientAddress.key, equals('client.address'));
        expect(ClientResource.clientPort.key, equals('client.port'));
      });
    });

    group('CloudResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(CloudResource.cloudProvider.key, equals('cloud.provider'));
        expect(CloudResource.cloudAccountId.key, equals('cloud.account.id'));
        expect(CloudResource.cloudRegion.key, equals('cloud.region'));
        expect(CloudResource.cloudAvailabilityZone.key, equals('cloud.availability_zone'));
        expect(CloudResource.cloudPlatform.key, equals('cloud.platform'));
      });
    });

    group('ComputeUnitResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(ComputeUnitResource.containerName.key, equals('container.name'));
        expect(ComputeUnitResource.containerId.key, equals('container.id'));
        expect(ComputeUnitResource.containerRuntime.key, equals('container.runtime'));
        expect(ComputeUnitResource.containerImageName.key, equals('container.image.name'));
        expect(ComputeUnitResource.containerImageTag.key, equals('container.image.tag'));
      });
    });

    group('ComputeInstanceResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(ComputeInstanceResource.hostId.key, equals('host.id'));
        expect(ComputeInstanceResource.hostName.key, equals('host.name'));
        expect(ComputeInstanceResource.hostType.key, equals('host.type'));
        expect(ComputeInstanceResource.hostImageName.key, equals('host.image.name'));
        expect(ComputeInstanceResource.hostImageId.key, equals('host.image.id'));
        expect(ComputeInstanceResource.hostImageVersion.key, equals('host.image.version'));
      });
    });

    group('DatabaseResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(DatabaseResource.dbSystem.key, equals('db.system'));
        expect(DatabaseResource.dbConnectionString.key, equals('db.connection_string'));
        expect(DatabaseResource.dbUser.key, equals('db.user'));
        expect(DatabaseResource.dbName.key, equals('db.name'));
        expect(DatabaseResource.dbStatement.key, equals('db.statement'));
        expect(DatabaseResource.dbOperation.key, equals('db.operation'));
      });
    });

    group('DeploymentResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(DeploymentResource.deploymentId.key, equals('deployment.id'));
        expect(DeploymentResource.deploymentName.key, equals('deployment.name'));
        expect(DeploymentResource.deploymentEnvironmentName.key, equals('deployment.environment.name'));
      });
    });

    group('DeviceResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(DeviceResource.deviceId.key, equals('device.id'));
        expect(DeviceResource.deviceModelIdentifier.key, equals('device.model.identifier'));
        expect(DeviceResource.deviceModelName.key, equals('device.model.name'));
        expect(DeviceResource.deviceManufacturer.key, equals('device.manufacturer'));
      });
    });

    group('ErrorResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(ErrorResource.errorType.key, equals('error.type'));
      });
    });

    group('EnvironmentResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(EnvironmentResource.deploymentEnvironment.key, equals('deployment.environment'));
      });
    });

    group('ExceptionResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(ExceptionResource.exceptionType.key, equals('exception.type'));
        expect(ExceptionResource.exceptionMessage.key, equals('exception.message'));
        expect(ExceptionResource.exceptionStacktrace.key, equals('exception.stacktrace'));
      });
    });

    group('FeatureFlagResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(FeatureFlagResource.featureFlagKey.key, equals('feature_flag.key'));
        expect(FeatureFlagResource.featureFlagVariant.key, equals('feature_flag.variant'));
        expect(FeatureFlagResource.featureFlagProviderName.key, equals('feature_flag.provider_name'));
        expect(FeatureFlagResource.featureFlagContextId.key, equals('feature_flag.context.id'));
        expect(FeatureFlagResource.featureFlagEvaluationReason.key, equals('feature_flag.evaluation.reason'));
        expect(FeatureFlagResource.featureFlagEvaluationErrorMessage.key, equals('feature_flag.evaluation.error.message'));
        expect(FeatureFlagResource.featureFlagSetId.key, equals('feature_flag.set.id'));
        expect(FeatureFlagResource.featureFlagVersion.key, equals('feature_flag.version'));
      });
    });

    group('FileResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(FileResource.filePath.key, equals('file.path'));
        expect(FileResource.fileName.key, equals('file.name'));
        expect(FileResource.fileExtension.key, equals('file.extension'));
        expect(FileResource.fileSize.key, equals('file.size'));
        expect(FileResource.fileCreated.key, equals('file.created'));
        expect(FileResource.fileModified.key, equals('file.modified'));
        expect(FileResource.fileAccessed.key, equals('file.accessed'));
        expect(FileResource.fileChanged.key, equals('file.changed'));
        expect(FileResource.fileOwnerId.key, equals('file.owner.id'));
        expect(FileResource.fileOwnerName.key, equals('file.owner.name'));
        expect(FileResource.fileGroupId.key, equals('file.group.id'));
        expect(FileResource.fileGroupName.key, equals('file.group.name'));
        expect(FileResource.fileMode.key, equals('file.mode'));
        expect(FileResource.fileInode.key, equals('file.inode'));
        expect(FileResource.fileAttributes.key, equals('file.attributes'));
        expect(FileResource.fileSymbolicLinkTargetPath.key, equals('file.symbolic_link.target_path'));
        expect(FileResource.fileForkName.key, equals('file.fork_name'));
        expect(FileResource.fileDirectory.key, equals('file.directory'));
      });
    });

    group('GenAIResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(GenAIResource.genAiOperationName.key, equals('gen_ai.operation.name'));
        expect(GenAIResource.genAiRequestEncodingFormats.key, equals('gen_ai.request.encoding_formats'));
        expect(GenAIResource.genAiRequestFrequencyPenalty.key, equals('gen_ai.request.frequency_penalty'));
        expect(GenAIResource.genAiRequestMaxTokens.key, equals('gen_ai.request.max_tokens'));
        expect(GenAIResource.genAiRequestModel.key, equals('gen_ai.request.model'));
        expect(GenAIResource.genAiRequestPresencePenalty.key, equals('gen_ai.request.presence_penalty'));
        expect(GenAIResource.genAiRequestSeed.key, equals('gen_ai.request.seed'));
      });
    });

    group('GeneralResourceResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(GeneralResourceResource.serviceName.key, equals('service.name'));
        expect(GeneralResourceResource.serviceVersion.key, equals('service.version'));
        expect(GeneralResourceResource.telemetrySdkName.key, equals('telemetry.sdk.name'));
        expect(GeneralResourceResource.telemetrySdkVersion.key, equals('telemetry.sdk.version'));
        expect(GeneralResourceResource.telemetryAutoVersion.key, equals('telemetry.auto.version'));
      });
    });

    group('GraphQLResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(GraphQLResource.graphqlDocument.key, equals('graphql.document'));
        expect(GraphQLResource.graphqlOperationName.key, equals('graphql.operation.name'));
        expect(GraphQLResource.graphqlOperationType.key, equals('graphql.operation.type'));
      });
    });

    group('HostResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(HostResource.hostArch.key, equals('host.arch'));
        expect(HostResource.hostCpuCacheL2Size.key, equals('host.cpu.cache.l2.size'));
        expect(HostResource.hostCpuFamily.key, equals('host.cpu.family'));
        expect(HostResource.hostCpuModelId.key, equals('host.cpu.model.id'));
        expect(HostResource.hostCpuModelName.key, equals('host.cpu.model.name'));
        expect(HostResource.hostCpuStepping.key, equals('host.cpu.stepping'));
        expect(HostResource.hostCpuVendorId.key, equals('host.cpu.vendor.id'));
        expect(HostResource.hostId.key, equals('host.id'));
        expect(HostResource.hostImageId.key, equals('host.image.id'));
        expect(HostResource.hostImageName.key, equals('host.image.name'));
        expect(HostResource.hostImageVersion.key, equals('host.image.version'));
        expect(HostResource.hostName.key, equals('host.name'));
        expect(HostResource.hostType.key, equals('host.type'));
        expect(HostResource.hostMac.key, equals('host.mac'));
        expect(HostResource.hostIp.key, equals('host.ip'));
      });
    });

    group('HttpResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(HttpResource.httpConnectionState.key, equals('http.connection.state'));
        expect(HttpResource.requestMethod.key, equals('http.request.method'));
        expect(HttpResource.requestMethodOriginal.key, equals('http.request.method_original'));
        expect(HttpResource.requestResendCount.key, equals('http.request.resend_count'));
        expect(HttpResource.responseStatusCode.key, equals('http.response.status_code'));
        expect(HttpResource.httpRoute.key, equals('http.route'));
        expect(HttpResource.connectionState.key, equals('http.connection.state'));
        expect(HttpResource.requestSize.key, equals('http.request.size'));
        expect(HttpResource.requestBodySize.key, equals('http.request.body.size'));
        expect(HttpResource.responseSize.key, equals('http.response.size'));
        expect(HttpResource.responseBodySize.key, equals('http.response.body.size'));
      });
    });

    group('HttpHeaderAttribute', () {
      test('should generate correct header keys', () {
        final requestHeader = HttpHeaderAttribute.request('content-type');
        expect(requestHeader.key, equals('http.request.header.content-type'));

        final responseHeader = HttpHeaderAttribute.response('content-length');
        expect(responseHeader.key, equals('http.response.header.content-length'));

        // Test case transformation
        final mixedCaseHeader = HttpHeaderAttribute.request('Content-Type');
        expect(mixedCaseHeader.key, equals('http.request.header.content-type'));
      });
    });

    group('KubernetesResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(KubernetesResource.k8sClusterName.key, equals('k8s.cluster.name'));
        expect(KubernetesResource.k8sResourcepaceName.key, equals('k8s.Resourcepace.name'));
        expect(KubernetesResource.k8sPodName.key, equals('k8s.pod.name'));
        expect(KubernetesResource.k8sPodUid.key, equals('k8s.pod.uid'));
        expect(KubernetesResource.k8sContainerName.key, equals('k8s.container.name'));
        expect(KubernetesResource.k8sReplicaSetUid.key, equals('k8s.replicaset.uid'));
        expect(KubernetesResource.k8sReplicaSetName.key, equals('k8s.replicaset.name'));
        expect(KubernetesResource.k8sDeploymentUid.key, equals('k8s.deployment.uid'));
        expect(KubernetesResource.k8sDeploymentName.key, equals('k8s.deployment.name'));
        expect(KubernetesResource.k8sStatefulSetUid.key, equals('k8s.statefulset.uid'));
        expect(KubernetesResource.k8sStatefulSetName.key, equals('k8s.statefulset.name'));
        expect(KubernetesResource.k8sDaemonSetUid.key, equals('k8s.daemonset.uid'));
        expect(KubernetesResource.k8sDaemonSetName.key, equals('k8s.daemonset.name'));
        expect(KubernetesResource.k8sJobUid.key, equals('k8s.job.uid'));
        expect(KubernetesResource.k8sJobName.key, equals('k8s.job.name'));
        expect(KubernetesResource.k8sCronJobUid.key, equals('k8s.cronjob.uid'));
        expect(KubernetesResource.k8sCronJobName.key, equals('k8s.cronjob.name'));
      });
    });

    group('MessagingResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(MessagingResource.messagingSystem.key, equals('messaging.system'));
        expect(MessagingResource.messagingDestination.key, equals('messaging.destination'));
        expect(MessagingResource.messagingDestinationKind.key, equals('messaging.destination_kind'));
        expect(MessagingResource.messagingTempDestination.key, equals('messaging.temp_destination'));
        expect(MessagingResource.messagingProtocol.key, equals('messaging.protocol'));
        expect(MessagingResource.messagingProtocolVersion.key, equals('messaging.protocol_version'));
      });
    });

    group('NetworkResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(NetworkResource.networkType.key, equals('network.type'));
        expect(NetworkResource.networkCarrierName.key, equals('network.carrier.name'));
        expect(NetworkResource.networkCarrierMcc.key, equals('network.carrier.mcc'));
        expect(NetworkResource.networkCarrierMnc.key, equals('network.carrier.mnc'));
        expect(NetworkResource.networkCarrierIcc.key, equals('network.carrier.icc'));
      });
    });

    group('OperatingSystemResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(OperatingSystemResource.osType.key, equals('os.type'));
        expect(OperatingSystemResource.osDescription.key, equals('os.description'));
        expect(OperatingSystemResource.osName.key, equals('os.name'));
        expect(OperatingSystemResource.osVersion.key, equals('os.version'));
      });
    });

    group('ProcessResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(ProcessResource.processPid.key, equals('process.pid'));
        expect(ProcessResource.processExecutableName.key, equals('process.executable.name'));
        expect(ProcessResource.processExecutablePath.key, equals('process.executable.path'));
        expect(ProcessResource.processCommand.key, equals('process.command'));
        expect(ProcessResource.processCommandLine.key, equals('process.command_line'));
        expect(ProcessResource.processOwner.key, equals('process.owner'));
        expect(ProcessResource.processRuntimeName.key, equals('process.runtime.name'));
        expect(ProcessResource.processRuntimeVersion.key, equals('process.runtime.version'));
        expect(ProcessResource.processRuntimeDescription.key, equals('process.runtime.description'));
      });
    });

    group('RPCResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(RPCResource.rpcSystem.key, equals('rpc.system'));
        expect(RPCResource.rpcService.key, equals('rpc.service'));
        expect(RPCResource.rpcMethod.key, equals('rpc.method'));
      });
    });

    group('ServiceResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(ServiceResource.serviceName.key, equals('service.name'));
        expect(ServiceResource.serviceResourcepace.key, equals('service.Resourcepace'));
        expect(ServiceResource.serviceInstanceId.key, equals('service.instance.id'));
        expect(ServiceResource.serviceVersion.key, equals('service.version'));
      });
    });

    group('SourceCodeResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(SourceCodeResource.codeFunctionName.key, equals('code.function.name'));
        expect(SourceCodeResource.codeResourcepace.key, equals('code.Resourcepace'));
        expect(SourceCodeResource.codeFilePath.key, equals('code.file.path'));
        expect(SourceCodeResource.codeLineNumber.key, equals('code.line.number'));
        expect(SourceCodeResource.codeColumnNumber.key, equals('code.column.number'));
        expect(SourceCodeResource.codeStacktrace.key, equals('code.stacktrace'));
      });
    });

    group('TelemetryDistroResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(TelemetryDistroResource.distroName.key, equals('telemetry.distro.name'));
        expect(TelemetryDistroResource.distroVersion.key, equals('telemetry.distro.version'));
      });
    });

    group('TelemetrySDKResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(TelemetrySDKResource.sdkName.key, equals('telemetry.sdk.name'));
        expect(TelemetrySDKResource.sdkLanguage.key, equals('telemetry.sdk.language'));
        expect(TelemetrySDKResource.sdkVersion.key, equals('telemetry.sdk.version'));
      });
    });

    group('VersionResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(VersionResource.schemaUrl.key, equals('schema.url'));
      });
    });
  });
}
