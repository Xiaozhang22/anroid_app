#!/usr/bin/env python3
"""
任务管理系统服务器启动脚本
"""

import os
import sys

def check_dependencies():
    """检查依赖包是否安装"""
    try:
        import flask
        import flask_cors
        print("✓ 依赖包检查通过")
        return True
    except ImportError as e:
        print(f"✗ 依赖包缺失: {e}")
        print("请运行: pip install -r requirements.txt")
        return False

def main():
    print("=" * 50)
    print("任务管理系统启动")
    print("=" * 50)
    
    if not check_dependencies():
        sys.exit(1)
    
    print("启动Flask服务器...")
    print("Web管理界面: http://localhost:8080")
    print("按 Ctrl+C 停止服务器")
    print("-" * 50)
    
    # 启动Flask应用
    from app import app
    app.run(debug=True, host='0.0.0.0', port=8080)

if __name__ == "__main__":
    main()