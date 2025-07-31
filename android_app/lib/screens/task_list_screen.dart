import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'setup_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _deviceName = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
    _refreshTasks();
    
    // 每30秒自动刷新任务
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _refreshTasks();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadDeviceInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _deviceName = prefs.getString('device_name') ?? 'Unknown Device';
    });
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Task> tasks = await ApiService.getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('获取任务失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateTaskStatus(Task task, String status, String result) async {
    bool success = await ApiService.updateTaskStatus(task.id, status, result);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('任务状态更新成功'),
          backgroundColor: Colors.green,
        ),
      );
      _refreshTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('描述: ${task.description}'),
              SizedBox(height: 16),
              Text('状态: ${_getStatusText(task.status)}'),
              SizedBox(height: 16),
              Text('创建时间: ${task.createdAt.substring(0, 19)}'),
            ],
          ),
          actions: [
            if (task.status == 'sent')
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showResultDialog(task, 'completed');
                },
                child: Text('标记完成'),
              ),
            if (task.status == 'sent')
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showResultDialog(task, 'failed');
                },
                child: Text('标记失败'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(Task task, String status) {
    final TextEditingController resultController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status == 'completed' ? '任务完成' : '任务失败'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('请输入执行结果或失败原因：'),
              SizedBox(height: 16),
              TextField(
                controller: resultController,
                decoration: InputDecoration(
                  hintText: status == 'completed' ? '如：已完成扫地任务' : '如：设备故障',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateTaskStatus(task, status, resultController.text);
              },
              child: Text('确认'),
            ),
          ],
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '待执行';
      case 'sent':
        return '已发送';
      case 'completed':
        return '已完成';
      case 'failed':
        return '失败';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'sent':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'sent':
        return Icons.send;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SetupScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('任务管理器'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshTasks,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('重新配置'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              children: [
                Icon(Icons.phone_android, size: 32, color: Colors.blue),
                SizedBox(height: 8),
                Text(
                  _deviceName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '在线 - ${_tasks.length} 个任务',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              '暂无任务',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '等待服务器分配新任务...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshTasks,
                        child: ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            Task task = _tasks[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(task.status),
                                  child: Icon(
                                    _getStatusIcon(task.status),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.description.isNotEmpty)
                                      Text(task.description),
                                    SizedBox(height: 4),
                                    Text(
                                      '状态: ${_getStatusText(task.status)}',
                                      style: TextStyle(
                                        color: _getStatusColor(task.status),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: task.status == 'sent'
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.check, color: Colors.green),
                                            onPressed: () => _showResultDialog(task, 'completed'),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close, color: Colors.red),
                                            onPressed: () => _showResultDialog(task, 'failed'),
                                          ),
                                        ],
                                      )
                                    : null,
                                onTap: () => _showTaskDialog(task),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}