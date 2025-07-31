class Task {
  final int id;
  final String title;
  final String description;
  final String assignedDevice;
  final String status;
  final String createdAt;
  final String? completedAt;
  final String? result;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedDevice,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.result,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      assignedDevice: json['assigned_device'],
      status: json['status'],
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
      result: json['result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_device': assignedDevice,
      'status': status,
      'created_at': createdAt,
      'completed_at': completedAt,
      'result': result,
    };
  }
}