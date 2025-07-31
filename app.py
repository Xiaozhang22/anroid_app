from flask import Flask, request, jsonify, render_template, redirect, url_for
from flask_cors import CORS
from datetime import datetime
import json
import os

app = Flask(__name__)
CORS(app)

# 存储任务和设备的简单内存数据结构
tasks = []
devices = {}
task_history = []

# 任务状态
TASK_STATUS = {
    'PENDING': 'pending',
    'SENT': 'sent', 
    'COMPLETED': 'completed',
    'FAILED': 'failed'
}

# 生成任务ID
def generate_task_id():
    return len(tasks) + 1

# 生成设备ID
def generate_device_id():
    return f"device_{len(devices) + 1}"

# API路由 - 设备注册
@app.route('/api/register', methods=['POST'])
def register_device():
    """设备注册API"""
    data = request.json
    device_name = data.get('device_name', f'Device_{len(devices) + 1}')
    device_id = generate_device_id()
    
    devices[device_id] = {
        'id': device_id,
        'name': device_name,
        'last_seen': datetime.now().isoformat(),
        'status': 'online'
    }
    
    return jsonify({
        'status': 'success',
        'device_id': device_id,
        'message': 'Device registered successfully'
    })

# API路由 - 获取任务
@app.route('/api/tasks/<device_id>', methods=['GET'])
def get_tasks(device_id):
    """设备获取分配给它的任务"""
    if device_id not in devices:
        return jsonify({'error': 'Device not found'}), 404
    
    # 更新设备最后在线时间
    devices[device_id]['last_seen'] = datetime.now().isoformat()
    
    # 获取分配给该设备的待执行任务
    device_tasks = [task for task in tasks 
                   if task.get('assigned_device') == device_id 
                   and task['status'] in [TASK_STATUS['PENDING'], TASK_STATUS['SENT']]]
    
    return jsonify({
        'status': 'success',
        'tasks': device_tasks
    })

# API路由 - 更新任务状态
@app.route('/api/tasks/<int:task_id>/status', methods=['POST'])
def update_task_status(task_id):
    """设备更新任务状态"""
    data = request.json
    device_id = data.get('device_id')
    status = data.get('status')
    result = data.get('result', '')
    
    if device_id not in devices:
        return jsonify({'error': 'Device not found'}), 404
    
    # 找到对应任务
    task = next((t for t in tasks if t['id'] == task_id), None)
    if not task:
        return jsonify({'error': 'Task not found'}), 404
    
    # 更新任务状态
    task['status'] = status
    task['completed_at'] = datetime.now().isoformat()
    task['result'] = result
    
    # 添加到历史记录
    task_history.append({
        'task_id': task_id,
        'device_id': device_id,
        'status': status,
        'result': result,
        'timestamp': datetime.now().isoformat()
    })
    
    return jsonify({
        'status': 'success',
        'message': 'Task status updated'
    })

# Web界面路由
@app.route('/')
def index():
    """主页 - 任务管理界面"""
    return render_template('index.html', 
                         tasks=tasks, 
                         devices=devices, 
                         task_history=task_history)

@app.route('/create_task', methods=['POST'])
def create_task():
    """创建新任务"""
    title = request.form.get('title')
    description = request.form.get('description')
    assigned_device = request.form.get('assigned_device')
    
    if not title or not assigned_device:
        return redirect(url_for('index'))
    
    task = {
        'id': generate_task_id(),
        'title': title,
        'description': description,
        'assigned_device': assigned_device,
        'status': TASK_STATUS['PENDING'],
        'created_at': datetime.now().isoformat(),
        'completed_at': None,
        'result': ''
    }
    
    tasks.append(task)
    return redirect(url_for('index'))

@app.route('/send_task/<int:task_id>')
def send_task(task_id):
    """发送任务给设备"""
    task = next((t for t in tasks if t['id'] == task_id), None)
    if task:
        task['status'] = TASK_STATUS['SENT']
        task['sent_at'] = datetime.now().isoformat()
    
    return redirect(url_for('index'))

@app.route('/api/devices', methods=['GET'])
def get_devices():
    """获取所有设备列表"""
    return jsonify({
        'status': 'success',
        'devices': list(devices.values())
    })

if __name__ == '__main__':
    # 创建模板目录
    os.makedirs('templates', exist_ok=True)
    os.makedirs('static', exist_ok=True)
    
    print("任务管理系统启动中...")
    print("Web管理界面: http://localhost:8080")
    print("API文档:")
    print("  设备注册: POST /api/register")
    print("  获取任务: GET /api/tasks/{device_id}")
    print("  更新状态: POST /api/tasks/{task_id}/status")
    
    app.run(debug=True, host='0.0.0.0', port=8080)