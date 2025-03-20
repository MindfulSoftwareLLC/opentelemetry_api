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

      test('toString should return the key', () {
        expect(ClientResource.clientAddress.toString(), equals('client.address'));
        expect(ClientResource.clientPort.toString(), equals('client.port'));
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

      test('toString should return the key', () {
        expect(CloudResource.cloudProvider.toString(), equals('cloud.provider'));
        expect(CloudResource.cloudRegion.toString(), equals('cloud.region'));
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

      test('toString should return the key', () {
        expect(ComputeUnitResource.containerName.toString(), equals('container.name'));
        expect(ComputeUnitResource.containerId.toString(), equals('container.id'));
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

      test('toString should return the key', () {
        expect(ComputeInstanceResource.hostId.toString(), equals('host.id'));
        expect(ComputeInstanceResource.hostName.toString(), equals('host.name'));
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

      test('toString should return the key', () {
        expect(DatabaseResource.dbSystem.toString(), equals('db.system'));
        expect(DatabaseResource.dbName.toString(), equals('db.name'));
      });
    });

    group('DeploymentResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(DeploymentResource.deploymentId.key, equals('deployment.id'));
        expect(DeploymentResource.deploymentName.key, equals('deployment.name'));
        expect(DeploymentResource.deploymentEnvironmentName.key, equals('deployment.environment.name'));
      });

      test('toString should return the key', () {
        expect(DeploymentResource.deploymentId.toString(), equals('deployment.id'));
        expect(DeploymentResource.deploymentName.toString(), equals('deployment.name'));
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

      test('toString should return the key', () {
        expect(DeviceResource.deviceId.toString(), equals('device.id'));
        expect(DeviceResource.deviceModelName.toString(), equals('device.model.name'));
      });
    });

    group('ErrorResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(ErrorResource.errorType.key, equals('error.type'));
      });

      test('toString should return the key', () {
        expect(ErrorResource.errorType.toString(), equals('error.type'));
      });
    });

    group('EnvironmentResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(EnvironmentResource.deploymentEnvironment.key, equals('deployment.environment'));
      });

      test('toString should return the key', () {
        expect(EnvironmentResource.deploymentEnvironment.toString(), equals('deployment.environment'));
      });
    });

    group('ExceptionResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(ExceptionResource.exceptionType.key, equals('exception.type'));
        expect(ExceptionResource.exceptionMessage.key, equals('exception.message'));
        expect(ExceptionResource.exceptionStacktrace.key, equals('exception.stacktrace'));
      });

      test('toString should return the key', () {
        expect(ExceptionResource.exceptionType.toString(), equals('exception.type'));
        expect(ExceptionResource.exceptionMessage.toString(), equals('exception.message'));
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

      test('toString should return the key', () {
        expect(FeatureFlagResource.featureFlagKey.toString(), equals('feature_flag.key'));
        expect(FeatureFlagResource.featureFlagVariant.toString(), equals('feature_flag.variant'));
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

      test('toString should return the key', () {
        expect(GeneralResourceResource.serviceName.toString(), equals('service.name'));
        expect(GeneralResourceResource.telemetrySdkName.toString(), equals('telemetry.sdk.name'));
      });
    });

    group('GraphQLResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(GraphQLResource.graphqlDocument.key, equals('graphql.document'));
        expect(GraphQLResource.graphqlOperationName.key, equals('graphql.operation.name'));
        expect(GraphQLResource.graphqlOperationType.key, equals('graphql.operation.type'));
      });

      test('toString should return the key', () {
        expect(GraphQLResource.graphqlDocument.toString(), equals('graphql.document'));
        expect(GraphQLResource.graphqlOperationName.toString(), equals('graphql.operation.name'));
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

      test('toString should return the key', () {
        expect(HttpResource.httpConnectionState.toString(), equals('http.connection.state'));
        expect(HttpResource.requestMethod.toString(), equals('http.request.method'));
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

      test('toString should return the key', () {
        expect(KubernetesResource.k8sClusterName.toString(), equals('k8s.cluster.name'));
        expect(KubernetesResource.k8sPodName.toString(), equals('k8s.pod.name'));
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

      test('toString should return the key', () {
        expect(MessagingResource.messagingSystem.toString(), equals('messaging.system'));
        expect(MessagingResource.messagingDestination.toString(), equals('messaging.destination'));
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

      test('toString should return the key', () {
        expect(NetworkResource.networkType.toString(), equals('network.type'));
        expect(NetworkResource.networkCarrierName.toString(), equals('network.carrier.name'));
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

      test('toString should return the key', () {
        expect(OperatingSystemResource.osType.toString(), equals('os.type'));
        expect(OperatingSystemResource.osName.toString(), equals('os.name'));
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

      test('toString should return the key', () {
        expect(ProcessResource.processPid.toString(), equals('process.pid'));
        expect(ProcessResource.processOwner.toString(), equals('process.owner'));
      });
    });

    group('RPCResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(RPCResource.rpcSystem.key, equals('rpc.system'));
        expect(RPCResource.rpcService.key, equals('rpc.service'));
        expect(RPCResource.rpcMethod.key, equals('rpc.method'));
      });

      test('toString should return the key', () {
        expect(RPCResource.rpcSystem.toString(), equals('rpc.system'));
        expect(RPCResource.rpcMethod.toString(), equals('rpc.method'));
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

      test('toString should return the key', () {
        expect(ServiceResource.serviceName.toString(), equals('service.name'));
        expect(ServiceResource.serviceVersion.toString(), equals('service.version'));
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

      test('toString should return the key', () {
        expect(SourceCodeResource.codeFunctionName.toString(), equals('code.function.name'));
        expect(SourceCodeResource.codeFilePath.toString(), equals('code.file.path'));
      });
    });

    group('TelemetryDistroResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(TelemetryDistroResource.distroName.key, equals('telemetry.distro.name'));
        expect(TelemetryDistroResource.distroVersion.key, equals('telemetry.distro.version'));
      });

      test('toString should return the key', () {
        expect(TelemetryDistroResource.distroName.toString(), equals('telemetry.distro.name'));
        expect(TelemetryDistroResource.distroVersion.toString(), equals('telemetry.distro.version'));
      });
    });

    group('TelemetrySDKResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(TelemetrySDKResource.sdkName.key, equals('telemetry.sdk.name'));
        expect(TelemetrySDKResource.sdkLanguage.key, equals('telemetry.sdk.language'));
        expect(TelemetrySDKResource.sdkVersion.key, equals('telemetry.sdk.version'));
      });

      test('toString should return the key', () {
        expect(TelemetrySDKResource.sdkName.toString(), equals('telemetry.sdk.name'));
        expect(TelemetrySDKResource.sdkLanguage.toString(), equals('telemetry.sdk.language'));
      });
    });

    group('VersionResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(VersionResource.schemaUrl.key, equals('schema.url'));
      });

      test('toString should return the key', () {
        expect(VersionResource.schemaUrl.toString(), equals('schema.url'));
      });
    });
  });
}
