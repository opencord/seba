{{/* vim: set filetype=mustache: */}}
{{/*
Copyright 2018-present Open Networking Foundation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}
{{- define "nem-att.basicFixturesTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
description: Some basic fixtures
imports:
  - custom_types/siterole.yaml
  - custom_types/slicerole.yaml
  - custom_types/networkparametertype.yaml
  - custom_types/networktemplate.yaml
  - custom_types/deployment.yaml
topology_template:
  node_templates:

# -----------------------------------------------------------------------------
# Network Parameter Types
# -----------------------------------------------------------------------------
    s_tag:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: s_tag
    c_tag:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: c_tag
    next_hop:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: next_hop
    device:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: device
    bridge:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: bridge
    neutron_port_name:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: neutron_port_name

# ----------------------------------------------------------------------------
# Roles
# ----------------------------------------------------------------------------
    siterole#admin:
      type: tosca.nodes.SiteRole
      properties:
        role: admin
    siterole#pi:
      type: tosca.nodes.SiteRole
      properties:
        role: pi
    siterole#tech:
      type: tosca.nodes.SiteRole
      properties:
        role: tech
    slicerole#admin:
      type: tosca.nodes.SliceRole
      properties:
        role: admin
    slicerole#access:
      type: tosca.nodes.SliceRole
      properties:
        role: access

# -----------------------------------------------------------------------------
# Network Templates
# -----------------------------------------------------------------------------
    Private:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: Private
        visibility: private
        translation: none

    Public shared IPv4:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: Public shared IPv4
        visibility: private
        translation: NAT
        shared_network_name: nat-net

    Public dedicated IPv4:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: Public dedicated IPv4
        visibility: public
        translation: none
        shared_network_name: ext-net

# -----------------------------------------------------------------------------
# Deployment
# -----------------------------------------------------------------------------
    MyDeployment:
      type: tosca.nodes.Deployment
      properties:
        name: MyDeployment
{{- end -}}


{{- define "nem-att.serviceGraphTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/fabricservice.yaml
  - custom_types/fabriccrossconnectservice.yaml
  - custom_types/hippieossservice.yaml
  - custom_types/onosservice.yaml
  - custom_types/rcordservice.yaml
  - custom_types/servicedependency.yaml
  - custom_types/servicegraphconstraint.yaml
  - custom_types/voltservice.yaml
description: rcord-fc service graph
topology_template:
  node_templates:

# These services must be defined before loading the graph

    service#ONOS_Fabric:
      type: tosca.nodes.ONOSService
      properties:
        name: ONOS_Fabric
        must-exist: true

    service#ONOS_VOLTHA:
      type: tosca.nodes.ONOSService
      properties:
        name: ONOS_VOLTHA
        must-exist: true

    service#fabric:
      type: tosca.nodes.FabricService
      properties:
        name: fabric
        must-exist: true

    service#rcord:
      type: tosca.nodes.RCORDService
      properties:
        name: rcord
        must-exist: true

    service#volt:
      type: tosca.nodes.VOLTService
      properties:
        name: volt
        must-exist: true

    service#fabric-crossconnect:
      type: tosca.nodes.FabricCrossconnectService
      properties:
        name: fabric-crossconnect
        must-exist: true

    # The nem-att service graph
    service_dependency#onos-fabric_fabric:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#ONOS_Fabric
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#fabric
            relationship: tosca.relationships.BelongsToOne

    service_dependency#rcord_volt:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#rcord
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne

    service_dependency#onos_voltha_volt:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    service_dependency#volt_fabric-crossconnect:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#fabric-crossconnect
            relationship: tosca.relationships.BelongsToOne

    service_dependency#onos_fabric_fabric-crossconnect:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#fabric-crossconnect
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#ONOS_Fabric
            relationship: tosca.relationships.BelongsToOne

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '[[null, "rcord"], ["ONOS_VOLTHA", "volt"], ["ONOS_Fabric", "fabric-crossconnect"], ["fabric", null]]'

    # hippie-oss
    service#oss:
      type: tosca.nodes.HippieOSSService
      properties:
        name: hippie-oss
        kind: oss
        create_on_discovery: false

    service_dependency#oss_volt:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#oss
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
{{- end -}}

{{- define "nem-att.fabricAppTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/onosapp.yaml
  - custom_types/onosservice.yaml
description: ONOS service and app for fabric
topology_template:
  node_templates:
    service#ONOS_Fabric:
      type: tosca.nodes.ONOSService
      properties:
          name: ONOS_Fabric
          kind: platform
          rest_hostname: {{ .Values.onosFabricRestService | quote }}
          rest_port: 8181

    onos_app#segmentrouting:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.segmentrouting
        app_id: org.onosproject.segmentrouting
      requirements:
        - owner:
            node: service#ONOS_Fabric
            relationship: tosca.relationships.BelongsToOne

    onos_app#netcfghostprovider:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.netcfghostprovider
        app_id: org.onosproject.netcfghostprovider
      requirements:
        - owner:
            node: service#ONOS_Fabric
            relationship: tosca.relationships.BelongsToOne

    onos_app#openflow:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.openflow
        app_id: org.onosproject.openflow
      requirements:
        - owner:
            node: service#ONOS_Fabric
            relationship: tosca.relationships.BelongsToOne
{{- end -}}

{{- define "nem-att.volthaOnosTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/onosapp.yaml
   - custom_types/onosservice.yaml
   - custom_types/serviceinstanceattribute.yaml

description: Configures the VOLTHA ONOS service

topology_template:
  node_templates:

    service#ONOS_VOLTHA:
      type: tosca.nodes.ONOSService
      properties:
          name: ONOS_VOLTHA
          kind: platform
          rest_hostname: {{ .Values.onosVolthaRestService | quote }}
          rest_port: 8181

    onos_app#openflow-base:
      type: tosca.nodes.ONOSApp
      properties:
        name: openflow-base
        app_id: org.onosproject.openflow-base
      requirements:
        - owner:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    onos_app#hostprovider:
      type: tosca.nodes.ONOSApp
      properties:
        name: hostprovider
        app_id: org.onosproject.hostprovider
      requirements:
        - owner:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    onos_app#cord-config:
      type: tosca.nodes.ONOSApp
      properties:
        name: cord-config
        app_id: org.opencord.config
        url: {{ .Values.cordConfigAppUrl }}
        version: 1.4.0
      requirements:
        - owner:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    onos_app#olt:
      type: tosca.nodes.ONOSApp
      properties:
        name: olt
        app_id: org.opencord.olt
        url: {{ .Values.oltAppUrl }}
        version: 2.0.0.SNAPSHOT
        dependencies: org.opencord.config
      requirements:
        - owner:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    onos_app#sadis:
      type: tosca.nodes.ONOSApp
      properties:
        name: sadis
        app_id: org.opencord.sadis
        url: {{ .Values.sadisAppUrl }}
        version: 2.1.0
      requirements:
        - owner:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    onos_app#dhcpl2relay:
      type: tosca.nodes.ONOSApp
      properties:
        name: dhcpl2relay
        app_id: org.opencord.dhcpl2relay
        url: {{ .Values.dhcpl2relayAppUrl }}
        version: 1.5.0.SNAPSHOT
        dependencies: org.opencord.sadis
      requirements:
        - owner:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    onos_app#aaa:
      type: tosca.nodes.ONOSApp
      properties:
        name: aaa
        app_id: org.opencord.aaa
        url: {{ .Values.aaaAppUrl }}
        version: 1.8.0.SNAPSHOT
        dependencies: org.opencord.sadis
      requirements:
        - owner:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    onos_app#kafka:
      type: tosca.nodes.ONOSApp
      properties:
        name: kafka
        app_id: org.opencord.kafka
        url: {{ .Values.kafkaAppUrl }}
        version: 1.0.0.SNAPSHOT
        dependencies: org.opencord.olt,org.opencord.aaa,org.opencord.dhcpl2relay
      requirements:
        - owner:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    # CORD-Configuration
    cord-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/network/configuration/apps/org.opencord.kafka
        value: >
          {
            "kafka" : {
              "bootstrapServers" : {{ .Values.kafkaService | quote }}
            }
          }
      requirements:
        - service_instance:
            node: onos_app#olt
            relationship: tosca.relationships.BelongsToOne

    olt-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/configuration/org.opencord.olt.impl.Olt?preset=true
        value: >
          {
            "enableDhcpOnProvisioning" : true
          }
      requirements:
        - service_instance:
            node: onos_app#olt
            relationship: tosca.relationships.BelongsToOne

    dhcpl2relay-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/network/configuration/apps/org.opencord.dhcpl2relay
        value: >
          {
            "dhcpl2relay" : {
              "useOltUplinkForServerPktInOut" : true
            }
          }
      requirements:
        - service_instance:
            node: onos_app#dhcpl2relay
            relationship: tosca.relationships.BelongsToOne

    aaa-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/network/configuration/apps/org.opencord.aaa
        value: >
          {
            "AAA" : {
              "radiusConnectionType" : "socket",
              "radiusHost" : "freeradius.voltha.svc.cluster.local",
              "radiusServerPort" : "1812",
              "radiusSecret" : "SECRET"
            }
          }
      requirements:
        - service_instance:
            node: onos_app#aaa
            relationship: tosca.relationships.BelongsToOne
{{- end -}}
