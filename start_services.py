import subprocess
import os
import sys
import time
import signal
import psutil
import shutil

def is_mongodb_running():
    """Verifica se o MongoDB já está rodando"""
    for proc in psutil.process_iter(['name']):
        if 'mongod' in proc.info['name'].lower():
            return True
    return False

def start_mongodb():
    """Inicia o MongoDB se não estiver rodando"""
    if not is_mongodb_running():
        print("Iniciando MongoDB...")
        # Cria o diretório de dados se não existir
        data_dir = os.path.join(os.getcwd(), 'mongodb_data')
        os.makedirs(data_dir, exist_ok=True)
        
        # Inicia o MongoDB
        mongod_process = subprocess.Popen(
            ['mongod', '--dbpath', data_dir],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        # Aguarda o MongoDB iniciar
        time.sleep(5)
        print("MongoDB iniciado com sucesso!")
        return mongod_process
    else:
        print("MongoDB já está rodando!")
        return None

def find_npm():
    """Encontra o caminho do npm"""
    npm_path = shutil.which('npm')
    if npm_path is None:
        # Tenta encontrar o npm no diretório padrão do Node.js
        default_paths = [
            r'C:\Program Files\nodejs\npm.cmd',
            r'C:\Program Files (x86)\nodejs\npm.cmd',
            os.path.expanduser('~\\AppData\\Roaming\\npm\\npm.cmd')
        ]
        for path in default_paths:
            if os.path.exists(path):
                return path
        raise FileNotFoundError("npm não encontrado. Por favor, instale o Node.js")
    return npm_path

def start_node_server():
    """Inicia o servidor Node.js"""
    print("Iniciando servidor Node.js...")
    
    # Encontra o caminho do npm
    npm_path = find_npm()
    print(f"Usando npm em: {npm_path}")
    
    # Muda para o diretório do projeto
    api_dir = os.path.join(os.getcwd(), 'aguaviva_api')
    if not os.path.exists(api_dir):
        raise FileNotFoundError(f"Diretório {api_dir} não encontrado")
    
    os.chdir(api_dir)
    
    # Verifica se o package.json existe
    if not os.path.exists('package.json'):
        raise FileNotFoundError("package.json não encontrado")
    
    # Inicia o servidor Node.js
    try:
        node_process = subprocess.Popen(
            [npm_path, 'start'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            shell=True  # Usa shell para Windows
        )
        return node_process
    except Exception as e:
        print(f"Erro ao iniciar o servidor Node.js: {e}")
        raise

def handle_exit(signum, frame):
    """Manipula o sinal de saída para encerrar os processos"""
    print("\nEncerrando serviços...")
    processes = []
    
    # Adiciona processos que existem
    if 'mongod_process' in globals() and mongod_process:
        processes.append(mongod_process)
    if 'node_process' in globals() and node_process:
        processes.append(node_process)
    
    # Encerra os processos
    for proc in processes:
        try:
            proc.terminate()
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
        except Exception as e:
            print(f"Erro ao encerrar processo: {e}")
    
    sys.exit(0)

if __name__ == "__main__":
    # Registra o manipulador de sinal para Ctrl+C
    signal.signal(signal.SIGINT, handle_exit)
    signal.signal(signal.SIGTERM, handle_exit)
    
    mongod_process = None
    node_process = None
    
    try:
        # Inicia o MongoDB
        mongod_process = start_mongodb()
        
        # Inicia o servidor Node.js
        node_process = start_node_server()
        
        print("\nServiços iniciados com sucesso!")
        print("Pressione Ctrl+C para encerrar os serviços")
        
        # Mantém o script rodando e mostra os logs
        while True:
            if node_process.stdout:
                output = node_process.stdout.readline()
                if output:
                    print(output.strip())
            
            if node_process.stderr:
                error = node_process.stderr.readline()
                if error:
                    print("Erro:", error.strip())
            
            # Verifica se o processo ainda está rodando
            if node_process.poll() is not None:
                print("Servidor Node.js encerrado!")
                break
            
            time.sleep(0.1)
            
    except Exception as e:
        print(f"Erro ao iniciar serviços: {e}")
        handle_exit(None, None) 