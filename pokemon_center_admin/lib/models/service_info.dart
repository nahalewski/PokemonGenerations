enum ServiceStatus {
  offline,
  starting,
  online,
  failed,
  building,
}

class ServiceInfo {
  final String id;
  final String name;
  final String description;
  final int? port;
  final String? path;
  final List<String> supportedUrls;
  final bool autoStart;
  final ServiceStatus status;
  final String? lastLog;

  const ServiceInfo({
    required this.id,
    required this.name,
    required this.description,
    this.port,
    this.path,
    this.supportedUrls = const [],
    this.autoStart = false,
    this.status = ServiceStatus.offline,
    this.lastLog,
  });

  ServiceInfo copyWith({
    bool? autoStart,
    ServiceStatus? status,
    String? lastLog,
  }) {
    return ServiceInfo(
      id: id,
      name: name,
      description: description,
      port: port,
      path: path,
      supportedUrls: supportedUrls,
      autoStart: autoStart ?? this.autoStart,
      status: status ?? this.status,
      lastLog: lastLog ?? this.lastLog,
    );
  }
}
